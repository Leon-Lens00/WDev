import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "check_toolchain.py"
SPEC = importlib.util.spec_from_file_location("check_toolchain", SCRIPT)
check_toolchain = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
sys.modules[SPEC.name] = check_toolchain
SPEC.loader.exec_module(check_toolchain)


class CheckToolchainTests(unittest.TestCase):
    def fixture(self, directory: Path, *, target: str = "Warcraft III 1.27b", modern: bool = False) -> Path:
        files = {
            "clijasshelper.exe": b"jasshelper fixture",
            "pjass.exe": b"pjass fixture",
            "common.j": (
                "native BlzSetSpecialEffectScale takes effect whichEffect, real scale returns nothing\n"
                if modern
                else "native UnitAlive takes unit whichUnit returns boolean\n"
            ).encode(),
            "Blizzard.j": b"function BJDebugMsg takes string msg returns nothing\nendfunction\n",
        }
        for name, content in files.items():
            (directory / name).write_bytes(content)
        config = directory / "wc3toolchain.json"
        config.write_text(
            json.dumps(
                {
                    "target": target,
                    "jasshelper": "clijasshelper.exe",
                    "pjass": "pjass.exe",
                    "common": "common.j",
                    "blizzard": "Blizzard.j",
                }
            ),
            encoding="utf-8",
        )
        return config

    def test_valid_classic_toolchain_reports_hashes_and_resolved_paths(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary))
            report = check_toolchain.inspect_toolchain(config)

        self.assertTrue(report["ok"])
        self.assertEqual(report["target"], "Warcraft III 1.27b")
        self.assertEqual(report["errors"], [])
        self.assertEqual(set(report["files"]), {"jasshelper", "pjass", "common", "blizzard"})
        for item in report["files"].values():
            self.assertTrue(Path(item["path"]).is_absolute())
            self.assertEqual(len(item["sha256"]), 64)
            self.assertGreater(item["size"], 0)

    def test_missing_file_is_a_validation_error(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            config = self.fixture(directory)
            (directory / "pjass.exe").unlink()
            report = check_toolchain.inspect_toolchain(config)

        self.assertFalse(report["ok"])
        self.assertTrue(any(error["code"] == "MISSING_FILE" and error["field"] == "pjass" for error in report["errors"]))

    def test_rejects_non_127b_target_and_modern_native_surface(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary), target="Warcraft III 1.36", modern=True)
            report = check_toolchain.inspect_toolchain(config)

        codes = {error["code"] for error in report["errors"]}
        self.assertFalse(report["ok"])
        self.assertTrue({"TARGET_MISMATCH", "MODERN_API"}.issubset(codes))

    def test_json_cli_returns_machine_readable_report(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary))
            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(config), "--json"],
                text=True,
                capture_output=True,
                check=False,
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(json.loads(result.stdout)["ok"])


if __name__ == "__main__":
    unittest.main()
