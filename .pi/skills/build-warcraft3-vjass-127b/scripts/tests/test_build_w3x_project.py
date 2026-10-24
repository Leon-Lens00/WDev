import importlib.util
import json
import os
import struct
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "build_w3x_project.py"
SPEC = importlib.util.spec_from_file_location("build_w3x_project", SCRIPT)
build_w3x_project = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
sys.modules[SPEC.name] = build_w3x_project
SPEC.loader.exec_module(build_w3x_project)


def wct_fixture(global_script: str, tail: bytes = b"TAIL") -> bytes:
    encoded = global_script.encode("utf-8") + b"\0"
    return struct.pack("<I", 1) + b"comment\0" + struct.pack("<i", len(encoded)) + encoded + tail


class BuildW3xProjectTests(unittest.TestCase):
    def test_cli_rejects_collisions_without_writes(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'src').mkdir()
            for name in ('base.w3x', 'src/Main.j', 'external.j', 'MPQEditor.exe', 'asset', 'common.j', 'Blizzard.j', 'pjass.exe', 'clijasshelper.exe'):
                (root / name).write_bytes(b'fixture')
            (root / 'src/Main.j').write_text('//! import "../external.j"\n')
            config = {'target': 'Warcraft III 1.27b', 'common': 'common.j', 'pjass': 'pjass.exe', 'blizzard': 'Blizzard.j', 'jasshelper': 'clijasshelper.exe'}
            (root / 'tools.json').write_text(json.dumps(config))
            manifest = root / 'project.json'
            original = dict(name='Safety', target='Warcraft III 1.27b', base_map='base.w3x',
                            entrypoint='src/Main.j', source_root='src', toolchain='tools.json',
                            mpqeditor='MPQEditor.exe', output_map='dist/out.w3x', build_dir='build',
                            archive_files=[dict(source='asset', target='asset')])
            cases = []
            for field in ('output_map', 'report'):
                for target in ('base.w3x', 'src/Main.j', 'external.j', 'tools.json', 'MPQEditor.exe', 'asset', 'common.j', 'Blizzard.j', 'pjass.exe', 'clijasshelper.exe', 'project.json'):
                    cases.append({field: target})
            cases += [{'build_dir': 'src'}, {'build_dir': '.'}, {'output_map': 'build/compiler-input.j'},
                      {'report': 'build/base-extract/war3map.j'}, {'output_map': 'dist/out.w3x', 'report': 'dist/out.w3x'},
                      {'archive_files': [dict(source='asset', target='A'), dict(source='asset', target='a')]}]
            os.link(root / 'base.w3x', root / 'alias')
            (root / 'link').symlink_to(root / 'src/Main.j')
            cases += [{'report': 'alias'}, {'output_map': 'link'}]
            (root / 'build').mkdir()
            (root / 'redirect').mkdir()
            (root / 'redirect/base-extract').symlink_to(root / 'src', target_is_directory=True)
            cases += [{'build_dir': 'redirect'}, {}]
            for patch in cases:
                with self.subTest(patch=patch):
                    if not patch:
                        os.link(root / 'base.w3x', root / 'build/compiler-input.j')
                    manifest.write_text(json.dumps(original | patch))
                    before = {p: p.read_bytes() for p in root.rglob('*') if p.is_file()}
                    directories = {p for p in root.rglob('*') if p.is_dir()}
                    result = subprocess.run([sys.executable, '-B', str(SCRIPT), str(manifest)], text=True, capture_output=True)
                    self.assertEqual(result.returncode, 1, (result.stdout, result.stderr))
                    self.assertEqual(result.stdout, '')
                    self.assertRegex(result.stderr, r'^ERROR: .*?(collision|overwrite|overlap|duplicate)')
                    self.assertEqual(before, {p: p.read_bytes() for p in root.rglob('*') if p.is_file()})
                    self.assertEqual(directories, {p for p in root.rglob('*') if p.is_dir()})
                    self.assertFalse((root / 'dist').exists())

    def test_legacy_wct_keeps_unrelated_bytes(self):
        payload = b'// caf\xe9\r\n\r\n'
        original = struct.pack('<I', 1) + b'comment\xe9\0' + struct.pack('<i', len(payload) + 1) + payload + b'\0TAIL'
        updated = build_w3x_project.upsert_wct_import(original, 'Main.j')
        self.assertIn(payload, updated)
        self.assertTrue(updated.endswith(b'\0TAIL'))
        self.assertIn('café', build_w3x_project.read_wct_global_script(updated))
        self.assertEqual(updated, build_w3x_project.upsert_wct_import(updated, 'Main.j'))

    def test_load_project_resolves_relative_paths(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for name in ("base.w3x", "wc3toolchain.json", "MPQEditor.exe"):
                (root / name).write_bytes(b"fixture")
            (root / "src").mkdir()
            (root / "src/Main.j").write_text("library ProjectMain\nendlibrary\n", encoding="utf-8")
            manifest = root / "wc3project.json"
            manifest.write_text(
                json.dumps(
                    {
                        "name": "Test Map",
                        "target": "Warcraft III 1.27b",
                        "base_map": "base.w3x",
                        "entrypoint": "src/Main.j",
                        "toolchain": "wc3toolchain.json",
                        "mpqeditor": "MPQEditor.exe",
                        "output_map": "dist/TestMap.w3x",
                        "build_dir": "build",
                    }
                ),
                encoding="utf-8",
            )

            project = build_w3x_project.load_project(manifest)

        self.assertEqual(project.root, root.resolve())
        self.assertEqual(project.entrypoint, (root / "src/Main.j").resolve())
        self.assertEqual(project.output_map, (root / "dist/TestMap.w3x").resolve())
        self.assertTrue(project.sync_wct)

    def test_load_project_accepts_utf8_bom_from_windows_tools(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for name in ("base.w3x", "wc3toolchain.json", "MPQEditor.exe", "Main.j"):
                (root / name).write_bytes(b"fixture")
            manifest = root / "wc3project.json"
            manifest.write_text(
                json.dumps(
                    {
                        "name": "Windows JSON",
                        "target": "Warcraft III 1.27b",
                        "base_map": "base.w3x",
                        "entrypoint": "Main.j",
                        "toolchain": "wc3toolchain.json",
                        "mpqeditor": "MPQEditor.exe",
                        "output_map": "dist/TestMap.w3x",
                    }
                ),
                encoding="utf-8-sig",
            )

            project = build_w3x_project.load_project(manifest)

        self.assertEqual(project.name, "Windows JSON")

    def test_rejects_overwriting_the_base_map(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for name in ("base.w3x", "wc3toolchain.json", "MPQEditor.exe", "Main.j"):
                (root / name).write_bytes(b"fixture")
            manifest = root / "wc3project.json"
            manifest.write_text(
                json.dumps(
                    {
                        "name": "Unsafe",
                        "target": "Warcraft III 1.27b",
                        "base_map": "base.w3x",
                        "entrypoint": "Main.j",
                        "toolchain": "wc3toolchain.json",
                        "mpqeditor": "MPQEditor.exe",
                        "output_map": "base.w3x",
                    }
                ),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(ValueError, "overwrite base_map"):
                build_w3x_project.load_project(manifest)

    def test_compiler_input_imports_entrypoint_before_base_script(self):
        entrypoint = Path(r"C:\Maps\My Project\src\Main.j")
        base_script = "globals\nendglobals\nfunction main takes nothing returns nothing\nendfunction\n"

        rendered = build_w3x_project.render_compiler_input(entrypoint, base_script)

        self.assertTrue(rendered.startswith(f'//! import "{entrypoint.resolve()}"\n'))
        self.assertTrue(rendered.endswith(base_script))

    def test_source_tree_rejects_utf8_bom_with_actionable_error(self):
        with tempfile.TemporaryDirectory() as temporary:
            source_root = Path(temporary)
            (source_root / "Main.j").write_text(
                "library ProjectMain\nendlibrary\n",
                encoding="utf-8-sig",
            )

            with self.assertRaisesRegex(build_w3x_project.BuildError, "UTF-8 without BOM"):
                build_w3x_project.validate_source_tree(source_root)

    def test_upsert_wct_import_preserves_existing_script_and_tail(self):
        original = wct_fixture("call BJDebugMsg(\"existing\")\n")

        updated = build_w3x_project.upsert_wct_import(original, r"..\src\Main.j")
        updated_again = build_w3x_project.upsert_wct_import(updated, r"..\src\OtherMain.j")
        script = build_w3x_project.read_wct_global_script(updated_again)

        self.assertIn('call BJDebugMsg("existing")', script)
        self.assertIn('//! import "..\\src\\OtherMain.j"', script)
        self.assertNotIn('//! import "..\\src\\Main.j"', script)
        self.assertEqual(updated_again[-4:], b"TAIL")
        self.assertEqual(script.count(build_w3x_project.WCT_BEGIN), 1)

    def test_mpq_target_rejects_parent_traversal(self):
        with self.assertRaisesRegex(ValueError, "unsafe MPQ target"):
            build_w3x_project.validate_mpq_target(r"..\war3map.j")

    def test_mpq_add_command_replaces_target_with_compression(self):
        command = build_w3x_project.mpq_add_command(
            Path("MPQEditor.exe"), Path("Map.w3x"), Path("compiled.j"), "war3map.j"
        )
        self.assertEqual(
            command,
            ["MPQEditor.exe", "add", "Map.w3x", "compiled.j", "war3map.j", "/c"],
        )

    def test_prepare_base_archive_strips_and_preserves_warcraft_header(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            base_map = root / "Headered.w3x"
            header = b"HM3W" + b"\0" * 508
            archive = b"MPQ\x1a" + b"ARCHIVE"
            base_map.write_bytes(header + archive)

            staged, prefix = build_w3x_project.prepare_base_archive(base_map, root / "build")
            staged_bytes = staged.read_bytes()

        self.assertEqual(prefix, header)
        self.assertEqual(staged_bytes, archive)

    def test_build_project_runs_compile_injection_and_roundtrip_pipeline(self):
        self.run_pipeline()

    def test_headered_final_map_roundtrip(self):
        self.run_pipeline(header=True)

    def test_failed_injection_and_verification_keep_existing_destination(self):
        for failure in ('inject', 'verify', 'header', 'archive'):
            with self.subTest(failure=failure):
                self.run_pipeline(header=True, failure=failure)

    def run_pipeline(self, header=False, failure=None):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "src").mkdir()
            (root / "assets").mkdir()
            (root / "src/Main.j").write_text(
                "library ProjectMain initializer Init\n"
                "private function Init takes nothing returns nothing\n"
                "endfunction\n"
                "endlibrary\n",
                encoding="utf-8",
            )
            (root / "assets/dummy.mdx").write_bytes(b"model")
            base_map = root / "base.w3x"
            prefix = b'HM3W' + b'\0' * 508 if header else b''
            base_map.write_bytes(prefix + b"MPQ\x1aBASE-MAP")
            (root / "MPQEditor.exe").write_bytes(b"mpqeditor")
            for name, content in {
                "clijasshelper.exe": b"jasshelper",
                "pjass.exe": b"pjass",
                "common.j": b"native UnitAlive takes unit u returns boolean\n",
                "Blizzard.j": b"function BJDebugMsg takes string s returns nothing\nendfunction\n",
            }.items():
                (root / name).write_bytes(content)
            (root / "wc3toolchain.json").write_text(
                json.dumps(
                    {
                        "target": "Warcraft III 1.27b",
                        "jasshelper": "clijasshelper.exe",
                        "pjass": "pjass.exe",
                        "common": "common.j",
                        "blizzard": "Blizzard.j",
                    }
                ),
                encoding="utf-8",
            )
            manifest = root / "wc3project.json"
            manifest.write_text(
                json.dumps(
                    {
                        "name": "Pipeline Test",
                        "target": "Warcraft III 1.27b",
                        "base_map": "base.w3x",
                        "entrypoint": "src/Main.j",
                        "toolchain": "wc3toolchain.json",
                        "mpqeditor": "MPQEditor.exe",
                        "output_map": "dist/Test.w3x",
                        "build_dir": "build",
                        "archive_files": [
                            {"source": "assets/dummy.mdx", "target": r"war3mapImported\dummy.mdx"}
                        ],
                    }
                ),
                encoding="utf-8",
            )

            original_members = {
                "war3map.j": (
                    b"// caf\xe9\nglobals\nendglobals\n"
                    b"function config takes nothing returns nothing\nendfunction\n"
                    b"function main takes nothing returns nothing\nendfunction\n"
                ),
                "war3map.wct": wct_fixture(""),
            }
            injected: dict[str, bytes] = {}

            def fake_runner(command, **_kwargs):
                command = [str(item) for item in command]
                if len(command) > 1 and command[1] == "extract":
                    archive = Path(command[2])
                    target = command[3]
                    destination = Path(command[4])
                    output = build_w3x_project.disk_path_for_mpq(destination, target)
                    output.parent.mkdir(parents=True, exist_ok=True)
                    is_base = archive == base_map or archive == root / 'build/base-archive.mpq'
                    if not is_base:
                        self.assertNotEqual(archive, root / 'build/output-archive.mpq')
                        if header:
                            self.assertEqual(archive, root / 'build/final-extract/base-archive.mpq')
                    payload = original_members[target] if is_base else injected[target]
                    if failure == 'verify' and not is_base:
                        payload += b'corrupt'
                    output.write_bytes(payload)
                elif len(command) > 1 and command[1] == "add":
                    if failure == 'inject':
                        return subprocess.CompletedProcess(command, 1, stdout='', stderr='synthetic injection failure')
                    injected[command[4]] = Path(command[3]).read_bytes()
                elif len(command) > 1 and command[1] == "compact":
                    pass
                elif len(command) > 1 and command[1].endswith("wc3lint.py"):
                    pass
                elif len(command) > 1 and command[1].endswith("compile_vjass.py"):
                    output = Path(command[command.index("--output") + 1])
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_text("// compiled and validated\n", encoding="utf-8")
                    log = Path(command[command.index("--log") + 1])
                    log.write_text('{"compiled": true, "validated": true}', encoding="utf-8")
                return subprocess.CompletedProcess(command, 0, stdout="", stderr="")

            project = build_w3x_project.load_project(manifest)
            project.output_map.parent.mkdir()
            project.output_map.write_bytes(b'previous destination')
            original_assemble = build_w3x_project.assemble_headered_map

            def assemble(prefix, archive, output):
                original_assemble(prefix, archive, output)
                if failure == 'header':
                    output.write_bytes(b'FAIL' + output.read_bytes()[4:])
                elif failure == 'archive':
                    output.write_bytes(output.read_bytes() + b'corrupt')

            # Synthetic files are not executable certification; isolate the
            # pipeline from tool identification, which has its own tests.
            files = {key: {'path': str(root / name)} for key, name in {
                'jasshelper': 'clijasshelper.exe', 'pjass': 'pjass.exe',
                'common': 'common.j', 'blizzard': 'Blizzard.j'}.items()}
            with patch.object(build_w3x_project.check_toolchain, 'inspect_toolchain', return_value={'ok': True, 'files': files}), patch.object(build_w3x_project, 'assemble_headered_map', side_effect=assemble):
                if failure:
                    with self.assertRaises(build_w3x_project.BuildError):
                        build_w3x_project.build_project(project, runner=fake_runner)
                    self.assertEqual(project.output_map.read_bytes(), b'previous destination')
                    self.assertEqual(base_map.read_bytes(), prefix + b'MPQ\x1aBASE-MAP')
                    self.assertFalse(project.report.exists())
                    self.assertFalse(list(project.output_map.parent.glob('.wc3-*')))
                    return
                report = build_w3x_project.build_project(project, runner=fake_runner)

            self.assertIn('café', (root / 'build/compiler-input.j').read_text(encoding='utf-8'))
            self.assertTrue(project.output_map.read_bytes().startswith(prefix + b'MPQ\x1a'))
            self.assertTrue(report["ok"])
            self.assertEqual(report["verification_state"], "Validated")
            self.assertEqual(
                {item["target"] for item in report["verification"]},
                {"war3map.j", "war3map.wct", r"war3mapImported\dummy.mdx"},
            )
            self.assertTrue(project.output_map.is_file())
            self.assertTrue(project.report.is_file())
            self.assertIn(build_w3x_project.WCT_BEGIN.encode(), injected["war3map.wct"])
            self.assertEqual(base_map.read_bytes(), prefix + b"MPQ\x1aBASE-MAP")


if __name__ == "__main__":
    unittest.main()
