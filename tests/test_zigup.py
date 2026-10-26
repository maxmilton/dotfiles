import json
import os
import shlex
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


class ZigupTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix="zigup-test-")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.install = self.root / ".local/bin"
        self.install.mkdir(parents=True)
        self.commands = self.root / "commands"
        self.commands.mkdir()
        (self.commands / "shasum").symlink_to(shutil.which("shasum"))
        self.index = self.root / "index.json"
        self.script = self.root / "zigup.sh"
        source = (
            Path(__file__).resolve().parents[1] / ".local/bin/zigup.sh"
        ).read_text()
        # Give the unmodified CLI behaviour a private cleanup directory.
        self.script.write_text(
            source.replace(
                "TMP_DIR=/tmp/zigup", f"TMP_DIR={shlex.quote(str(self.root / 'tmp'))}"
            )
        )
        curl = self.commands / "curl"
        curl.write_text(
            "#!/bin/bash\n"
            'if [[ "$#" == 2 && "$1" == -s && "$2" == https://ziglang.org/download/index.json ]]; then\n'  # noqa: E501
            '  cat "$FIXTURE_INDEX"\n'
            "else\n"
            '  echo "Unexpected network request" >&2\n'
            "  exit 1\n"
            "fi\n"
        )
        curl.chmod(0o755)
        self.releases = {}

    def release(self, version, key=None):
        name = f"zig-x86_64-linux-{version}"
        binary = self.install / name / "zig"
        binary.parent.mkdir()
        binary.write_text(f"#!/bin/bash\nprintf '%s\\n' {shlex.quote(version)}\n")
        binary.chmod(0o755)
        self.releases[key or version] = {
            "x86_64-linux": {
                "tarball": f"https://ziglang.org/download/{version}/{name}.tar.xz",
                "shasum": "unused",
                "size": "0",
            }
        }

    def invoke(self, *arguments):
        self.index.write_text(json.dumps(self.releases))
        return subprocess.run(
            ["/bin/bash", str(self.script), *arguments],
            env={
                "HOME": str(self.root),
                "PATH": f"{self.commands}:/usr/bin:/bin",
                "FIXTURE_INDEX": str(self.index),
                "LC_ALL": "C",
            },
            cwd=self.root,
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def assert_selected(self, version, *arguments):
        result = self.invoke(*arguments)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            os.readlink(self.install / "zig-current"), f"zig-x86_64-linux-{version}"
        )
        self.assertEqual(
            (self.install / "zig_").resolve(),
            self.install / f"zig-x86_64-linux-{version}/zig",
        )

    def test_minor_selects_numeric_highest_patch(self):
        for version in ("0.15.9", "0.15.10", "0.15.2", "0.16.0"):
            self.release(version)
        self.assert_selected("0.15.10", "0.15")

    def test_major_selects_numeric_highest_release(self):
        for version in ("0.9.9", "0.15.2", "0.10.0", "1.0.0"):
            self.release(version)
        self.assert_selected("0.15.2", "0")

    def test_minor_matches_whole_components(self):
        self.release("0.1.2")
        self.release("0.15.2")
        self.assert_selected("0.1.2", "0.1")

    def test_partial_excludes_development_releases(self):
        self.release("0.15.2")
        self.release("0.15.3-dev.1+abcdef")
        self.release("0.18.0-dev.1+abcdef", key="master")
        self.assert_selected("0.15.2", "0.15")

    def test_full_version_stays_exact(self):
        self.release("0.15.1")
        self.release("0.15.2")
        self.assert_selected("0.15.1", "0.15.1")

    def test_stable_selects_highest_release(self):
        self.release("0.15.2")
        self.release("0.16.0")
        self.release("0.18.0-dev.1+abcdef", key="master")
        self.assert_selected("0.16.0", "stable")

    def test_explicit_master(self):
        self.release("0.18.0-dev.1+abcdef", key="master")
        self.assert_selected("0.18.0-dev.1+abcdef", "master")

    def test_default_is_master(self):
        self.release("0.18.0-dev.1+abcdef", key="master")
        self.assert_selected("0.18.0-dev.1+abcdef")

    def test_unmatched_partial_fails_without_switching(self):
        self.release("0.15.2")
        result = self.invoke("0.99")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Failed to acquire version info for 0.99", result.stderr)
        self.assertFalse((self.install / "zig-current").is_symlink())

    def test_missing_architecture_does_not_select_older_release(self):
        self.release("0.15.1")
        self.releases["0.15.2"] = {}
        result = self.invoke("0.15")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Failed to acquire version info for 0.15", result.stderr)
        self.assertFalse((self.install / "zig-current").is_symlink())


if __name__ == "__main__":
    unittest.main()
