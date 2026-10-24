import importlib.util
import json
import struct
import subprocess
import sys
import tempfile
import unittest
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
        entrypoint = Path("My Project/src/Main.j").resolve()
        base_script = "globals\nendglobals\nfunction main takes nothing returns nothing\nendfunction\n"

        rendered = build_w3x_project.render_compiler_input(entrypoint, base_script)

        self.assertTrue(rendered.startswith(f'//! import "{entrypoint}"\n'))
        self.assertTrue(rendered.endswith(base_script))

    @unittest.skipIf(sys.platform == "win32", "Wine path translation is for Linux")
    def test_linux_compiler_import_is_readable_inside_wine(self):
        entrypoint = Path("My Project/src/Main.j").resolve()
        rendered = build_w3x_project.render_compiler_input(entrypoint, "// base", wine_paths=True)
        wine_path = "Z:" + str(entrypoint).replace("/", "\\")
        self.assertEqual(rendered, f'//! import "{wine_path}"\n\n// base')

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
        self.exercise_pipeline(local=False)

    def test_local_backend_compiles_and_injects_binary_members_without_mpqeditor(self):
        self.exercise_pipeline(local=True)

    def exercise_pipeline(self, local):
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
            base_map.write_bytes(b"MPQ\x1aBASE-MAP")
            (root / "MPQEditor.exe").write_bytes(b"mpqeditor")
            (root / "wc3.py").write_text("# launcher fixture\n")
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
                    b"globals\nendglobals\n"
                    b"function config takes nothing returns nothing\nendfunction\n"
                    b"function main takes nothing returns nothing\nendfunction\n"
                ),
                "war3map.wct": wct_fixture(""),
            }
            injected: dict[str, bytes] = {}
            if local:
                config = json.loads(manifest.read_text())
                config.pop("mpqeditor")
                config["local_launcher"] = "wc3.py"
                manifest.write_text(json.dumps(config))

            def fake_runner(command, **_kwargs):
                command = [str(item) for item in command]
                if len(command) > 3 and command[2:4] == ["wc3ctl", "extract"]:
                    archive, target = Path(command[4]), command[5]
                    output = Path(command[command.index("-o") + 1])
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_bytes(original_members[target] if archive == base_map else injected[target])
                elif len(command) > 4 and command[2:5] == ["wc3ctl", "file", "set"]:
                    injected[command[6]] = Path(command[7]).read_bytes()
                    Path(command[command.index("-o") + 1]).write_bytes(b"updated archive")
                elif len(command) > 1 and command[1] == "extract":
                    archive = Path(command[2])
                    target = command[3]
                    destination = Path(command[4])
                    output = build_w3x_project.disk_path_for_mpq(destination, target)
                    output.parent.mkdir(parents=True, exist_ok=True)
                    payload = original_members[target] if archive == base_map else injected[target]
                    output.write_bytes(payload)
                elif len(command) > 1 and command[1] == "add":
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
            report = build_w3x_project.build_project(project, runner=fake_runner)

            self.assertTrue(report["ok"])
            self.assertEqual(report["verification_state"], "Validated")
            self.assertEqual(
                {item["target"] for item in report["verification"]},
                {"war3map.j", "war3map.wct", r"war3mapImported\dummy.mdx"},
            )
            self.assertTrue(project.output_map.is_file())
            self.assertTrue(project.report.is_file())
            self.assertIn(build_w3x_project.WCT_BEGIN.encode(), injected["war3map.wct"])
            self.assertEqual(base_map.read_bytes(), b"MPQ\x1aBASE-MAP")


if __name__ == "__main__":
    unittest.main()
