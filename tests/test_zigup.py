import hashlib
import json
import os
import shlex
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from textwrap import dedent


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
        self.assertEqual(source.count("TMP_DIR=/tmp/zigup"), 1)
        # Give the unmodified CLI behaviour a private cleanup directory.
        self.script.write_text(
            source.replace(
                "TMP_DIR=/tmp/zigup", f"TMP_DIR={shlex.quote(str(self.root / 'tmp'))}"
            )
        )
        curl = self.commands / "curl"
        curl.write_text(
            dedent("""\
                #!/bin/bash
                if [[ "$#" == 2 &&
                      "$1" == -s &&
                      "$2" == https://ziglang.org/download/index.json ]]; then
                  cat "$FIXTURE_INDEX"
                elif [[ "$#" == 3 && "$1" == "$FIXTURE_URL" && "$2" == -o ]]; then
                  printf "%s\\n" "$1" >> "$FIXTURE_DOWNLOADS"
                  [[ "$FIXTURE_DOWNLOAD_FAILURE" == 0 ]] || exit 1
                  cp -- "$FIXTURE_ARCHIVE" "$3"
                else
                  echo "Unexpected network request" >&2
                  exit 1
                fi
                """)
        )
        curl.chmod(0o755)
        self.releases = {}
        self.archive = self.root / "release.tar.xz"
        self.archive_url = ""
        self.download_failure = False
        self.downloads = self.root / "downloads"
        self.downloads.touch()

    def release(self, version, key=None, *, cached=True):
        name = f"zig-x86_64-linux-{version}"
        binary = (self.install if cached else self.root / "staging") / name / "zig"
        binary.parent.mkdir(parents=True)
        binary.write_text(f"#!/bin/bash\nprintf '%s\\n' {shlex.quote(version)}\n")
        binary.chmod(0o755)
        url = (
            f"https://ziglang.org/builds/{name}.tar.xz"
            if "-dev." in version
            else f"https://ziglang.org/download/{version}/{name}.tar.xz"
        )
        metadata = {"tarball": url, "shasum": "unused", "size": "0"}
        if not cached:
            with tarfile.open(self.archive, "w:xz") as archive:
                archive.add(binary, arcname=f"{name}/zig")
            contents = self.archive.read_bytes()
            metadata.update(
                shasum=hashlib.sha256(contents).hexdigest(), size=str(len(contents))
            )
            self.archive_url = url
        self.releases[key or version] = {"x86_64-linux": metadata}
        return metadata

    def invoke(self, *arguments):
        self.index.write_text(json.dumps(self.releases))
        return subprocess.run(
            ["/bin/bash", str(self.script), *arguments],
            env={
                "HOME": str(self.root),
                "PATH": f"{self.commands}:/usr/bin:/bin",
                "FIXTURE_INDEX": str(self.index),
                "FIXTURE_URL": self.archive_url,
                "FIXTURE_ARCHIVE": str(self.archive),
                "FIXTURE_DOWNLOAD_FAILURE": str(int(self.download_failure)),
                "FIXTURE_DOWNLOADS": str(self.downloads),
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
        self.assert_active(version)
        self.assertFalse((self.root / "tmp").exists())
        return result

    def activate(self, version):
        (self.install / "zig-current").symlink_to(f"zig-x86_64-linux-{version}")
        (self.install / "zig_").symlink_to("zig-current/zig")

    def assert_active(self, version):
        self.assertEqual(
            os.readlink(self.install / "zig-current"), f"zig-x86_64-linux-{version}"
        )
        self.assertEqual(
            (self.install / "zig_").resolve(),
            self.install / f"zig-x86_64-linux-{version}/zig",
        )

        self.assertEqual(os.readlink(self.install / "zig_"), "zig-current/zig")
        result = subprocess.run(
            [str(self.install / "zig_"), "version"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
            env={"PATH": "/usr/bin:/bin", "LC_ALL": "C"},
            cwd=self.root,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, f"{version}\n")

    def seed_retention(self):
        for number in (1, 2, 3, 4, 5, 9, 10):
            self.release(f"0.15.{number}")
            self.release(f"0.16.0-dev.{number}+abcdef", key=f"dev-{number}")

    def installation_contents(self):
        return {
            path.name: (path / "zig").read_bytes()
            for path in self.install.iterdir()
            if path.is_dir() and not path.is_symlink()
        }

    def assert_update_failed(self, message):
        self.seed_retention()
        self.activate("0.15.1")
        before = self.installation_contents()
        result = self.invoke("0.17.0")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(message, result.stderr)
        self.assert_active("0.15.1")
        self.assertEqual(self.installation_contents(), before)
        self.assertFalse((self.root / "tmp").exists())

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
        self.activate("0.15.2")
        result = self.invoke("0.99")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Failed to acquire version info for 0.99", result.stderr)
        self.assert_active("0.15.2")
        self.assertFalse((self.root / "tmp").exists())

    def test_missing_architecture_does_not_select_older_release(self):
        self.release("0.15.1")
        self.activate("0.15.1")
        self.releases["0.15.2"] = {}
        result = self.invoke("0.15")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Failed to acquire version info for 0.15", result.stderr)
        self.assert_active("0.15.1")
        self.assertFalse((self.root / "tmp").exists())

    def test_cached_switch_reuses_existing_installation(self):
        self.release("0.15.1")
        self.release("0.15.2")
        self.activate("0.15.1")
        binary = self.install / "zig-x86_64-linux-0.15.2/zig"
        before = binary.stat()
        contents = binary.read_bytes()
        self.assert_selected("0.15.2", "0.15.2")
        self.assertEqual(self.downloads.read_text(), "")
        self.assertEqual(binary.read_bytes(), contents)
        self.assertEqual(binary.stat().st_ino, before.st_ino)
        self.assertEqual(binary.stat().st_mtime_ns, before.st_mtime_ns)

    def test_already_current_reports_success_without_downloading(self):
        self.release("0.15.2")
        self.activate("0.15.2")
        result = self.assert_selected("0.15.2", "0.15.2")
        self.assertIn("is already the latest version", result.stderr)
        self.assertEqual(self.downloads.read_text(), "")

    def test_fresh_install_extracts_executable_and_selects_it(self):
        self.release("0.17.0", cached=False)
        self.assert_selected("0.17.0", "0.17.0")
        self.assertEqual(self.downloads.read_text(), f"{self.archive_url}\n")

    def test_cached_directory_without_binary_is_downloaded(self):
        self.release("0.17.0", cached=False)
        (self.install / "zig-x86_64-linux-0.17.0").mkdir()
        self.assert_selected("0.17.0", "0.17.0")
        self.assertEqual(self.downloads.read_text(), f"{self.archive_url}\n")

    def test_cached_non_executable_binary_is_replaced(self):
        self.release("0.17.0", cached=False)
        binary = self.install / "zig-x86_64-linux-0.17.0/zig"
        binary.parent.mkdir()
        binary.write_text("incomplete")
        binary.chmod(0o644)
        self.assert_selected("0.17.0", "0.17.0")
        self.assertEqual(self.downloads.read_text(), f"{self.archive_url}\n")

    def test_download_failure_preserves_active_installation_and_cache(self):
        self.release("0.17.0", cached=False)
        self.download_failure = True
        self.assert_update_failed("Failed to download")

    def test_checksum_failure_preserves_active_installation_and_cache(self):
        metadata = self.release("0.17.0", cached=False)
        metadata["shasum"] = "0" * 64
        self.assert_update_failed("Failed to verify checksum")

    def test_size_mismatch_preserves_active_installation_and_cache(self):
        metadata = self.release("0.17.0", cached=False)
        metadata["size"] = str(self.archive.stat().st_size + 1)
        self.assert_update_failed("Download size mismatch")

    def test_extraction_failure_preserves_active_installation_and_cache(self):
        metadata = self.release("0.17.0", cached=False)
        self.archive.write_bytes(b"not an xz archive")
        metadata.update(
            shasum=hashlib.sha256(self.archive.read_bytes()).hexdigest(),
            size=str(self.archive.stat().st_size),
        )
        self.assert_update_failed("Failed to extract")

    def test_fresh_install_retains_five_latest_stable_releases(self):
        self.seed_retention()
        self.release("0.17.0", cached=False)
        self.assert_selected("0.17.0", "0.17.0")
        self.assertEqual(
            {path.name for path in self.install.glob("zig-x86_64-linux-0.15.*")},
            {f"zig-x86_64-linux-0.15.{n}" for n in (4, 5, 9, 10)},
        )

    def test_fresh_install_retains_five_latest_development_builds(self):
        self.seed_retention()
        self.release("0.18.0-dev.1+abcdef", key="master", cached=False)
        self.assert_selected("0.18.0-dev.1+abcdef", "master")
        self.assertEqual(
            {path.name for path in self.install.glob("zig-x86_64-linux-0.16.0-dev.*")},
            {f"zig-x86_64-linux-0.16.0-dev.{n}+abcdef" for n in (4, 5, 9, 10)},
        )

    def test_old_selected_stable_release_is_kept_as_extra(self):
        self.seed_retention()
        self.release("0.14.0", cached=False)
        self.assert_selected("0.14.0", "0.14.0")
        self.assertEqual(
            set(self.installation_contents()),
            {"zig-x86_64-linux-0.14.0"}
            | {f"zig-x86_64-linux-0.15.{n}" for n in (3, 4, 5, 9, 10)}
            | {f"zig-x86_64-linux-0.16.0-dev.{n}+abcdef" for n in (3, 4, 5, 9, 10)},
        )

    def test_old_selected_development_build_is_kept_as_extra(self):
        self.seed_retention()
        self.release("0.14.0-dev.1+abcdef", key="master", cached=False)
        self.assert_selected("0.14.0-dev.1+abcdef", "master")
        self.assertEqual(
            set(self.installation_contents()),
            {"zig-x86_64-linux-0.14.0-dev.1+abcdef"}
            | {f"zig-x86_64-linux-0.15.{n}" for n in (3, 4, 5, 9, 10)}
            | {f"zig-x86_64-linux-0.16.0-dev.{n}+abcdef" for n in (3, 4, 5, 9, 10)},
        )

    def assert_directory_survives_retention(self, name):
        self.seed_retention()
        directory = self.install / name
        directory.mkdir()
        (directory / "sentinel").write_text("preserve me")
        self.release("0.17.0", cached=False)
        self.assert_selected("0.17.0", "0.17.0")
        self.assertEqual((directory / "sentinel").read_text(), "preserve me")

    def test_retention_preserves_unrelated_directory(self):
        self.assert_directory_survives_retention("unrelated")

    def test_retention_preserves_other_architecture(self):
        self.assert_directory_survives_retention("zig-aarch64-linux-0.1.0")

    def test_retention_preserves_malformed_stable_version(self):
        self.assert_directory_survives_retention("zig-x86_64-linux-0.1")

    def test_retention_preserves_malformed_development_version(self):
        self.assert_directory_survives_retention("zig-x86_64-linux-0.1.0-dev.1+nothex")

    def test_retention_preserves_installation_symlink(self):
        self.seed_retention()
        target = self.root / "symlink-target"
        target.mkdir()
        (target / "sentinel").write_text("preserve me")
        link = self.install / "zig-x86_64-linux-0.1.0"
        link.symlink_to(target, target_is_directory=True)
        self.release("0.17.0", cached=False)
        self.assert_selected("0.17.0", "0.17.0")
        self.assertEqual(os.readlink(link), str(target))
        self.assertEqual((target / "sentinel").read_text(), "preserve me")

    def test_cached_switch_does_not_prune_installations(self):
        self.seed_retention()
        self.activate("0.15.1")
        before = self.installation_contents()
        self.assert_selected("0.15.2", "0.15.2")
        self.assertEqual(self.installation_contents(), before)

    def test_already_current_does_not_prune_installations(self):
        self.seed_retention()
        self.activate("0.15.1")
        before = self.installation_contents()
        self.assert_selected("0.15.1", "0.15.1")
        self.assertEqual(self.installation_contents(), before)


if __name__ == "__main__":
    unittest.main()
