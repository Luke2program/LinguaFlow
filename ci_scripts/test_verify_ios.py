"""Linux-runnable runner checks; these do not substitute for XCTest."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class VerificationRunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        mock = self.directory / "xcodebuild"
        mock.write_text("#!/bin/bash\nprintf '%s\\n' \"$@\" > \"$MOCK_ARGUMENTS\"\necho mock-build-stdout\necho mock-build-stderr >&2\nexit \"$MOCK_EXIT\"\n".replace('\"', '"'))
        mock.chmod(0o700)
        self.env = dict(os.environ, PATH=str(self.directory) + os.pathsep + os.environ["PATH"],
                        VERIFICATION_OUTPUT_DIR=str(self.directory / "evidence with spaces"),
                        MOCK_ARGUMENTS=str(self.directory / "arguments"), MOCK_EXIT="0")

    def run_verification(self):
        return subprocess.run(["bash", str(ROOT / "ci_scripts/verify_ios.sh")],
                              env=self.env, capture_output=True, text=True, cwd=self.directory)

    def test_success_retains_logs_revision_and_result_bundle_arguments(self):
        result = self.run_verification()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        run = next((self.directory / "evidence with spaces").iterdir())
        log = (run / "xcodebuild.log").read_text()
        self.assertIn("mock-build-stdout", log)
        self.assertIn("mock-build-stderr", log)
        revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True)
        self.assertEqual((run / "revision.txt").read_text(), revision)
        args = (self.directory / "arguments").read_text().splitlines()
        self.assertEqual(args[0], "test")
        self.assertEqual(args[args.index("-scheme") + 1], "LinguaFlow")
        self.assertEqual(args[args.index("-parallel-testing-enabled") + 1], "NO")
        self.assertEqual(args[args.index("-resultBundlePath") + 1], str(run / "TestResults.xcresult"))
        self.assertEqual(args[args.index("-derivedDataPath") + 1], str(run / "DerivedData"))

    def test_xcode_failure_is_not_hidden_by_tee(self):
        self.env["MOCK_EXIT"] = "65"
        result = self.run_verification()
        self.assertEqual(result.returncode, 65, result.stdout + result.stderr)
        self.assertTrue(list((self.directory / "evidence with spaces").glob("*/xcodebuild.log")))

    def test_retries_keep_separate_evidence_and_destination_override(self):
        self.env["IOS_TEST_DESTINATION"] = "platform=iOS Simulator,id=test-device"
        for _ in range(2):
            result = self.run_verification()
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(len(list((self.directory / "evidence with spaces").iterdir())), 2)
        args = (self.directory / "arguments").read_text().splitlines()
        self.assertEqual(args[args.index("-destination") + 1], self.env["IOS_TEST_DESTINATION"])

if __name__ == "__main__":
    unittest.main()
