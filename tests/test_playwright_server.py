import re
import subprocess
import tempfile
import unittest
from pathlib import Path
from textwrap import dedent

SCRIPT = Path(__file__).resolve().parents[1] / ".local/bin/playwright_server.sh"


class PlaywrightServerTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix="playwright-server-test-")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name).resolve()
        self.project = self.root / "project"
        self.project.mkdir()
        self.commands = self.root / "commands"
        self.commands.mkdir()
        self.bun_cwd = self.root / "bun-cwd"
        self.podman_args = self.root / "podman-args"
        self.stub(
            "bun",
            """\
            #!/bin/bash
            [[ "$*" == "--bun playwright --version" ]] || exit 99
            pwd -P > "$FIXTURE_BUN_CWD"
            printf '%s\\n' "$FIXTURE_BUN_OUTPUT"
            exit "$FIXTURE_BUN_STATUS"
            """,
        )
        self.stub(
            "podman",
            """\
            #!/bin/bash
            printf '%s\\0' "$@" > "$FIXTURE_PODMAN_ARGS"
            """,
        )

    def stub(self, name, source):
        path = self.commands / name
        path.write_text(dedent(source))
        path.chmod(0o755)

    def invoke(self, bun_output, bun_status=0, args=()):
        return subprocess.run(
            ["/bin/bash", str(SCRIPT), *args],
            env={
                "PATH": f"{self.commands}:/usr/bin:/bin",
                "FIXTURE_BUN_CWD": str(self.bun_cwd),
                "FIXTURE_BUN_OUTPUT": bun_output,
                "FIXTURE_BUN_STATUS": str(bun_status),
                "FIXTURE_PODMAN_ARGS": str(self.podman_args),
                "LC_ALL": "C",
            },
            cwd=self.project,
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def test_starts_server_matching_project_version(self):
        result = self.invoke("Version 1.64.1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.bun_cwd.read_text(), f"{self.project}\n")
        args = self.podman_args.read_text().split("\0")[:-1]
        self.assertIn("127.0.0.1:3000:3000", args)
        self.assertIn("playwright-npm-cache:/home/pwuser/.npm", args)
        image = args.index("mcr.microsoft.com/playwright:v1.64.1-resolute")
        self.assertEqual(
            args[image + 1 :],
            [
                "npx",
                "-y",
                "--prefer-offline",
                "playwright@1.64.1",
                "run-server",
                "--port",
                "3000",
                "--host",
                "0.0.0.0",
            ],
        )

    def test_prints_runnable_test_command(self):
        result = self.invoke("Version 1.64.1")
        self.assertEqual(result.returncode, 0, result.stderr)
        command = re.search(r"^=+\n(.*?)\n=+", result.stderr, re.DOTALL | re.MULTILINE)
        self.assertIsNotNone(command, result.stderr)
        self.stub(
            "bun",
            """\
            #!/bin/bash
            printf '%s\\0' "$PW_TEST_CONNECT_WS_ENDPOINT" \\
              "$PW_TEST_CONNECT_EXPOSE_NETWORK" "$@"
            """,
        )
        output = subprocess.check_output(
            ["/bin/bash", "-c", command[1]],
            env={"PATH": f"{self.commands}:/usr/bin:/bin"},
            text=True,
            timeout=10,
        )
        self.assertEqual(
            output.split("\0")[:-1],
            ["ws://127.0.0.1:3000/", "<loopback>", "run", "test:e2e", "--project=*"],
        )

    def test_rejects_unexpected_version_output(self):
        for output in ("Version 1.64", "Version 1.64.1\\cjunk"):
            with self.subTest(output=output):
                result = self.invoke(output)
                self.assertEqual(result.returncode, 1)
                self.assertIn(
                    f"Unexpected Playwright version: {output}\n", result.stderr
                )
                self.assertFalse(self.podman_args.exists())

    def test_rejects_arguments(self):
        result = self.invoke("Version 1.64.1", args=["4000"])
        self.assertEqual(result.returncode, 1)
        self.assertIn("Usage:", result.stderr)
        self.assertFalse(self.bun_cwd.exists())
        self.assertFalse(self.podman_args.exists())

    def test_fails_without_project_playwright(self):
        result = self.invoke('error: Script not found "playwright"', bun_status=1)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Playwright not found in this project", result.stderr)
        self.assertFalse(self.podman_args.exists())


if __name__ == "__main__":
    unittest.main()
