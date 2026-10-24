import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).parents[1] / "compile_vjass.py"
SPEC = importlib.util.spec_from_file_location("compile_vjass", SCRIPT)
module = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(module)


class CompileLocalTests(unittest.TestCase):
    def test_launcher_mismatch_is_rejected_before_execution(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            launcher = root / "scripts/wc3.py"
            launcher.parent.mkdir()
            launcher.touch()
            (root / "wc3-environment.json").write_text(json.dumps({
                "jasshelper_dir": "compiler", "classic_common": "api/common.j",
                "classic_blizzard": "api/Blizzard.j",
            }))
            args = argparse.Namespace(local_launcher=launcher,
                jasshelper=root / "different/compiler.exe", pjass=root / "pjass",
                common=root / "common.j", blizzard=root / "Blizzard.j")
            with self.assertRaisesRegex(ValueError, "jasshelper differs"):
                module.validate_local_toolchain(args)

    def test_existing_output_is_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.j"
            source.write_bytes(b"source")
            output = root / "output.j"
            output.write_bytes(b"valuable existing output")
            argv = [sys.executable, str(SCRIPT)]
            for option in ["jasshelper", "pjass", "common", "blizzard", "input"]:
                argv += ["--" + option, str(source)]
            argv += ["--output", str(output)]
            result = subprocess.run(argv, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("output already exists", result.stderr)
            self.assertEqual(output.read_bytes(), b"valuable existing output")


if __name__ == "__main__":
    unittest.main()
