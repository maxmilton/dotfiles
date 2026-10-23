import subprocess
import tempfile
import unittest
from pathlib import Path


class SSHConfigTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix="ssh-config-test-")
        self.addCleanup(directory.cleanup)
        self.config_path = Path(directory.name) / "config"
        self.hosts_path = Path(directory.name) / "hosts.conf"
        source = (Path(__file__).resolve().parents[1] / ".ssh/config").read_text()
        self.assertEqual(source.count("Include hosts.conf"), 1)
        self.config_path.write_text(
            source.replace("Include hosts.conf", f'Include "{self.hosts_path}"')
        )

    def settings(self, config_path, host="audit.invalid"):
        result = subprocess.run(
            ["ssh", "-G", "-T", "-F", str(config_path), host],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return dict(line.split(" ", 1) for line in result.stdout.splitlines())

    def test_missing_private_include(self):
        self.assertFalse(self.hosts_path.exists())
        self.assertEqual(self.settings(self.config_path)["host"], "audit.invalid")

    def test_algorithms_follow_installed_defaults(self):
        actual = self.settings(self.config_path)
        defaults = self.settings("/dev/null")
        for name in ("hostkeyalgorithms", "kexalgorithms", "macs", "ciphers"):
            with self.subTest(setting=name):
                self.assertEqual(actual[name], defaults[name])

    def test_post_quantum_key_exchange_available(self):
        algorithms = self.settings(self.config_path)["kexalgorithms"].split(",")
        self.assertTrue(
            any(name.startswith(("mlkem", "sntrup")) for name in algorithms),
            algorithms,
        )

    def test_rsa_sha1_host_signatures_disabled(self):
        algorithms = self.settings(self.config_path)["hostkeyalgorithms"].split(",")
        self.assertNotIn("ssh-rsa", algorithms)
        self.assertNotIn("ssh-rsa-cert-v01@openssh.com", algorithms)

    def test_general_defaults(self):
        actual = self.settings(self.config_path)
        expected = {
            "hashknownhosts": "yes",
            "addkeystoagent": "true",
            "stricthostkeychecking": "ask",
            "updatehostkeys": "true",
            "forwardagent": "no",
            "forwardx11": "no",
        }
        for name, value in expected.items():
            with self.subTest(setting=name):
                self.assertEqual(actual[name], value)

    def test_private_host_overrides_defaults(self):
        self.hosts_path.write_text(
            "Host audit.invalid\n  AddKeysToAgent no\n  HashKnownHosts no\n"
        )
        actual = self.settings(self.config_path)
        self.assertEqual(actual["addkeystoagent"], "false")
        self.assertEqual(actual["hashknownhosts"], "no")

    def test_unmatched_host_keeps_defaults(self):
        self.hosts_path.write_text(
            "Host audit.invalid\n  AddKeysToAgent no\n  HashKnownHosts no\n"
        )
        actual = self.settings(self.config_path, "other.invalid")
        self.assertEqual(actual["addkeystoagent"], "true")
        self.assertEqual(actual["hashknownhosts"], "yes")


if __name__ == "__main__":
    unittest.main()
