import importlib.util
import sys
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "wc3lint.py"
SPEC = importlib.util.spec_from_file_location("wc3lint", SCRIPT)
wc3lint = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
sys.modules[SPEC.name] = wc3lint
SPEC.loader.exec_module(wc3lint)


class Wc3LintTests(unittest.TestCase):
    def scan(self, source: str):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Spell.j"
            path.write_text(source, encoding="utf-8")
            return wc3lint.scan_file(path)

    def test_modern_and_local_failures(self):
        findings = self.scan(
            """
function Test takes nothing returns nothing
    local integer id = FourCC("hfoo")
    if GetLocalPlayer() == Player(0) then
        set id = GetRandomInt(1, 2)
        call CreateUnit(Player(0), id, 0., 0., 0.)
    endif
    call BlzSetSpecialEffectScale(null, 2.)
endfunction
"""
        )
        rules = {finding.rule for finding in findings}
        self.assertTrue({"WC127-FOURCC", "WC127-BLZ", "SYNC-LOCAL-RNG", "SYNC-LOCAL-HANDLE"}.issubset(rules))

    def test_array_struct_lifecycle(self):
        findings = self.scan(
            """
struct Data extends array
endstruct
function Test takes nothing returns nothing
    local Data d = Data.create()
endfunction
"""
        )
        lifecycle = [finding for finding in findings if finding.rule == "ARRAY-STRUCT-LIFECYCLE"]
        self.assertEqual(len(lifecycle), 1)
        self.assertEqual(lifecycle[0].severity, "WARNING")

    def test_keyword_forward_declaration_is_allowed(self):
        findings = self.scan(
            """
library Tree
private keyword Parent
private struct Child
    Parent parent
endstruct
private struct Parent
    Child child
endstruct
endlibrary
"""
        )
        self.assertFalse(any(finding.severity == "ERROR" for finding in findings))

    def test_literals_and_comments_are_not_gameplay(self):
        source = '''\ufefffunction Test takes nothing returns nothing
    local string url = "https://example.invalid/BlzFake()"
    local string escaped = "escaped \\" BlzFake() /* not a comment */"
    local integer id = 'BlzA'
    /* if GetLocalPlayer() == Player(0) then
        call BlzFake()
        call CreateUnit(Player(0), 'hfoo', 0., 0., 0.)
    endif */
    call BJDebugMsg("GetLocalPlayer() CreateUnit() FourCC()") // BlzFake()
endfunction
'''
        self.assertEqual(self.scan(source), [])

    def test_string_url_does_not_hide_later_code(self):
        findings = self.scan('call Wrapper("https://example.invalid", BlzFake())\n')
        self.assertEqual([(f.rule, f.line) for f in findings], [("WC127-BLZ", 1)])

    def test_ignore_requires_a_real_line_comment(self):
        findings = self.scan('''call BlzFake("wc3lint: ignore ALL -- fake")
call BlzFake() // wc3lint: ignore WC127-BLZ -- deliberate compatibility fixture
call BlzFake() /* wc3lint: ignore ALL -- fake */
''')
        self.assertEqual([f.line for f in findings if f.rule == "WC127-BLZ"], [1, 3])

    def test_branch_after_local_condition_is_still_divergent(self):
        findings = self.scan('''function Test takes nothing returns nothing
if GetLocalPlayer() == Player(0) then
    call SetCameraPosition(0., 0.)
elseif true then
    call CreateUnit(Player(0), 'hfoo', 0., 0., 0.)
else
    call GetRandomInt(1, 2)
endif
call CreateUnit(Player(0), 'hfoo', 0., 0., 0.)
endfunction
''')
        self.assertEqual([f.line for f in findings if f.rule == "SYNC-LOCAL-HANDLE"], [5])
        self.assertEqual([f.line for f in findings if f.rule == "SYNC-LOCAL-RNG"], [7])

    def test_nested_local_branch_does_not_taint_sibling_branch(self):
        findings = self.scan('''if true then
    if GetLocalPlayer() == Player(0) then
        call CreateTimer()
    endif
else
    call CreateTimer()
endif
''')
        self.assertEqual([f.line for f in findings if f.rule == "SYNC-LOCAL-HANDLE"], [3])

    def test_resource_tracking_does_not_leak_between_methods(self):
        findings = self.scan('''struct Example
method one takes nothing returns nothing
local location p = Location(0., 0.)
local group g
local group alias
set alias = g
endmethod
method two takes nothing returns nothing
local location p
local group alias
set p = Location(1., 1.)
call FirstOfGroup(alias)
endmethod
endstruct
''')
        self.assertFalse(any(f.rule in {"LOCATION-OVERWRITE", "GROUP-ALIAS-CONSUME"} for f in findings))

    def test_module_context_survives_method_boundary(self):
        findings = self.scan('''module Example
method helper takes nothing returns nothing
endmethod
private static method onInit takes nothing returns nothing
endmethod
endmodule
''')
        self.assertEqual([f.line for f in findings if f.rule == "INIT-ORDER"], [4])

    def test_unclosed_comment_or_literal_is_not_a_clean_scan(self):
        for source, line in [('call BJDebugMsg("unfinished\n', 1), ('\n/* unfinished', 2), ("set id = 'oops", 1)]:
            with self.subTest(source=source):
                findings = self.scan(source)
                self.assertEqual([(f.rule, f.line, f.severity) for f in findings], [("LEX-INCOMPLETE", line, "ERROR")])

    def test_cli_scans_all_advertised_extensions(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for suffix in [".j", ".jass", ".vjass", ".J"]:
                path = root / ("bad" + suffix)
                path.write_text("call BlzFake()\n")
                result = subprocess.run([sys.executable, str(SCRIPT), str(path), "--json"], capture_output=True, text=True)
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertEqual(json.loads(result.stdout)["files"], 1)
            result = subprocess.run([sys.executable, str(SCRIPT), str(root), "--json"], capture_output=True, text=True)
            self.assertEqual(json.loads(result.stdout)["files"], 4)

    def test_cli_refuses_empty_unsupported_or_invalid_encoding(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            unsupported = root / "note.txt"
            unsupported.write_text("call BlzFake()\n")
            invalid = root / "invalid.j"
            for target in [root, unsupported]:
                result = subprocess.run([sys.executable, str(SCRIPT), str(target), "--json"], capture_output=True, text=True)
                self.assertEqual(result.returncode, 2)
            invalid.write_bytes(b"\xff\xfe")
            result = subprocess.run([sys.executable, str(SCRIPT), str(invalid), "--json"], capture_output=True, text=True)
            self.assertEqual(result.returncode, 2)


if __name__ == "__main__":
    unittest.main()
