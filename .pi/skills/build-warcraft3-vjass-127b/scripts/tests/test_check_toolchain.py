import hashlib
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

    def snapshot(self, directory):
        return {p.name: p.read_bytes() for p in directory.iterdir() if p.is_file()}

    def cli(self, config, *options):
        before = self.snapshot(config.parent)
        result = subprocess.run(
            [sys.executable, '-B', str(SCRIPT), str(config), *options],
            text=True, capture_output=True, check=False,
        )
        self.assertEqual(self.snapshot(config.parent), before)
        self.assertEqual(result.stderr, '')
        return result

    def assert_cli_report(self, config, expected):
        result = self.cli(config, '--json')
        self.assertEqual(result.returncode, 0 if expected['ok'] else 1)
        self.assertEqual(result.stdout, json.dumps(expected, indent=2) + '\n')
        status = 'PASS (structural checks only; compatibility unverified)' if expected['ok'] else 'FAIL'
        lines = [f"{status}: {expected['target'] or 'unknown target'}"]
        for field in check_toolchain.REQUIRED_FILES:
            item = expected['files'].get(field)
            if not item:
                lines.append(f'- {field}: not configured')
            elif not item['exists']:
                lines.append(f"- {field}: missing ({item['path']})")
            elif 'sha256' not in item:
                lines.append(f"- {field}: unreadable ({item['path']})")
            else:
                lines.append(f"- {field}: {item['sha256']}  {item['path']}")
        for kind in ('errors', 'warnings'):
            for finding in expected[kind]:
                lines.append(f"{'ERROR' if kind == 'errors' else 'WARNING'} {finding['code']}: {finding['message']}")
        result = self.cli(config)
        self.assertEqual(result.returncode, 0 if expected['ok'] else 1)
        self.assertEqual(result.stdout, '\n'.join(lines) + '\n')

    def test_empty_required_files_are_rejected_without_writes(self):
        for field, name in [('jasshelper', 'clijasshelper.exe'), ('pjass', 'pjass.exe'),
                            ('common', 'common.j'), ('blizzard', 'Blizzard.j')]:
            with self.subTest(field=field), tempfile.TemporaryDirectory() as temporary:
                directory = Path(temporary)
                config = self.fixture(directory)
                (directory / name).write_bytes(b'')
                report = check_toolchain.inspect_toolchain(config)
                self.assertFalse(report['ok'])
                self.assertEqual(report['errors'], [check_toolchain.error(
                    'EMPTY_FILE', f'file is empty: {directory / name}', field=field)])
                self.assertEqual(report['files'][field]['size'], 0)
                self.assertEqual(report['files'][field]['sha256'], hashlib.sha256(b'').hexdigest())
                self.assert_cli_report(config, report)

    def test_bom_config_has_identical_report_and_cli_contract(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary))
            expected = check_toolchain.inspect_toolchain(config)
            config.write_bytes(b'\xef\xbb\xbf' + config.read_bytes())
            self.assertEqual(check_toolchain.inspect_toolchain(config), expected)
            self.assert_cli_report(config, expected)

    def test_success_explicitly_leaves_compatibility_unverified(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary))
            report = check_toolchain.inspect_toolchain(config)
            self.assertTrue(report['ok'])
            self.assertIs(report['compatibility_verified'], False)
            self.assertEqual(report['warnings'], [{
                'code': 'COMPATIBILITY_UNVERIFIED',
                'message': 'Structural checks and SHA-256 fingerprints do not verify 1.27b provenance, '
                           'complete API compatibility, compiler capabilities, execution, or in-game behavior.',
            }])
            self.assert_cli_report(config, report)

    def test_only_uncommented_unquoted_modern_declarations_are_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            config = self.fixture(directory)
            common = directory / 'common.j'
            common.write_text('// native BlzComment takes nothing returns nothing\n'
                              '/* function FourCC takes string s returns integer */\n'
                              '"escaped \\" // native BlzString takes nothing returns nothing"\n'
                              'native UnitAlive takes unit u returns boolean\n', encoding='utf-8')
            report = check_toolchain.inspect_toolchain(config)
            self.assertTrue(report['ok'])
            self.assert_cli_report(config, report)
            common.write_text(common.read_text() + '\nnative /* gap */ BlzReal takes nothing returns nothing\n')
            report = check_toolchain.inspect_toolchain(config)
            self.assertFalse(report['ok'])
            self.assertEqual([e['code'] for e in report['errors']], ['MODERN_API'])
            self.assertIn('BlzReal', report['errors'][0]['message'])
            self.assert_cli_report(config, report)

    def test_invalid_config_inputs_report_errors_without_tracebacks_or_writes(self):
        for payload, code in [(b'\xff', 'CONFIG_ENCODING'), (b'{', 'CONFIG_JSON'),
                              (b'[]', 'CONFIG_TYPE')]:
            with self.subTest(code=code), tempfile.TemporaryDirectory() as temporary:
                config = self.fixture(Path(temporary))
                config.write_bytes(payload)
                report = check_toolchain.inspect_toolchain(config)
                self.assertFalse(report['ok'])
                self.assertEqual([e['code'] for e in report['errors']], [code])
                self.assert_cli_report(config, report)

    def test_invalid_file_path_reports_error_without_writes(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary))
            data = json.loads(config.read_text())
            data['pjass'] = 'bad\x00path'
            config.write_text(json.dumps(data))
            report = check_toolchain.inspect_toolchain(config)
            self.assertFalse(report['ok'])
            self.assertEqual([e['code'] for e in report['errors']], ['FILE_READ'])
            self.assert_cli_report(config, report)

    def test_existing_target_and_missing_file_rejections_preserved_on_cli(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary), target='Warcraft III 1.36', modern=True)
            (config.parent / 'pjass.exe').unlink()
            report = check_toolchain.inspect_toolchain(config)
            self.assertEqual([e['code'] for e in report['errors']],
                             ['TARGET_MISMATCH', 'MISSING_FILE', 'MODERN_API'])
            self.assert_cli_report(config, report)

    def test_existing_frontend_warning_is_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            config = self.fixture(Path(temporary))
            data = json.loads(config.read_text())
            data['jasshelper'] = 'pjass.exe'
            config.write_text(json.dumps(data))
            report = check_toolchain.inspect_toolchain(config)
            self.assertTrue(report['ok'])
            self.assertEqual(report['warnings'][1], {
                'code': 'JASSHELPER_FRONTEND',
                'message': 'prefer clijasshelper.exe for deterministic command-line compilation',
                'field': 'jasshelper',
            })
            self.assert_cli_report(config, report)

    def test_help_retains_options_and_explains_evidence_boundary(self):
        result = subprocess.run(
            [sys.executable, '-B', str(SCRIPT), '--help'],
            text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stderr, '')
        self.assertIn('compatibility remains unverified', result.stdout)
        self.assertIn('No executable is invoked.', result.stdout)
        self.assertIn('config      Path to wc3toolchain.json', result.stdout)
        self.assertIn('--json      Emit JSON', result.stdout)

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
