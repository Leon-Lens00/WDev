import importlib.util
import json
import subprocess
import sys
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

    def assert_cli(self, source, expected):
        """Assert the complete public text/JSON contract and read-only behavior."""
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Spell.j"
            original = source.encode("utf-8")
            path.write_bytes(original)
            records = [dict(severity=s, rule=r, path=str(path), line=n, message=m)
                       for s, r, n, m in expected]
            records.sort(key=lambda f: (f["path"], f["line"], f["severity"], f["rule"]))
            errors = sum(f["severity"] == "ERROR" for f in records)
            warnings = sum(f["severity"] == "WARNING" for f in records)
            text = "".join(f'{f["severity"]} {f["rule"]} {path}:{f["line"]} {f["message"]}\n'
                           for f in records)
            text += f"Scanned 1 file(s): {errors} error(s), {warnings} warning(s).\n"
            for flags in ([], ["--json"]):
                with self.subTest(flags=flags):
                    result = subprocess.run([sys.executable, "-B", str(SCRIPT), str(path), *flags],
                                            text=True, capture_output=True)
                    self.assertEqual(path.read_bytes(), original)
                    self.assertEqual(result.returncode, int(errors > 0))
                    self.assertEqual(result.stderr, "")
                    self.assertEqual(result.stdout, json.dumps({"files": 1, "findings": records}, indent=2) + "\n"
                                     if flags else text)

    def test_strings_comments_escapes_and_original_lines(self):
        self.assert_cli(
            'function Test takes nothing returns nothing\n'
            'call BJDebugMsg("BlzFake")\n'
            'call BJDebugMsg("escaped \\\" // BlzFake FourCC(")\n'
            '// BlzFake FourCC("hfoo")\n'
            '/* BlzFake\ncall FourCC("hfoo")\n*/\n'
            'call BJDebugMsg("url //") // BlzFake\n'
            'call BJDebugMsg("url //") /* comment */ call BlzReal()\n'
            'call BlzIgnored() // wc3lint: ignore WC127-BLZ -- reviewed\n'
            'endfunction\n',
            [("ERROR", "WC127-BLZ", 9, "Blz API is not vanilla Warcraft III 1.27b.")])

    def test_local_chain_and_nested_parent(self):
        self.assert_cli(
            'if GetLocalPlayer() == Player(0) then\n'
            'elseif true then\n'
            'call CreateUnit(Player(0), 0, 0., 0., 0.)\n'
            'else\nif true then\nelseif false then\n'
            'call GetRandomInt(1, 2)\nendif\nendif\n',
            [("WARNING", "SYNC-LOCAL-PLAYER", 1,
              "Trace all local-only writes and later uses; local safety is not proven by the branch alone."),
             ("ERROR", "SYNC-LOCAL-HANDLE", 3, "Do not allocate gameplay handles in a local-player branch."),
             ("ERROR", "SYNC-LOCAL-GAMEPLAY", 3, "Local-only gameplay mutation can desynchronize clients."),
             ("ERROR", "SYNC-LOCAL-RNG", 7, "Do not consume synchronized RNG in a local-player branch.")])

    def test_method_dataflow_scope(self):
        self.assert_cli(
            'struct Example\nmethod A takes nothing returns nothing\n'
            'local integer x\nlocal location p = Location(0., 0.)\n'
            'if GetLocalPlayer() == Player(0) then\nset x = 1\nendif\n'
            'set g = other\nset b = Condition(function Check)\ncall TriggerAddCondition(t, b)\n'
            'endmethod\nmethod B takes nothing returns nothing\nlocal integer x\n'
            'call SetUnitX(u, x)\nset p = Location(0., 0.)\n'
            'set u = FirstOfGroup(g)\ncall DestroyBoolExpr(b)\nendmethod\nendstruct\n',
            [("WARNING", "HANDLE-FACTORY", 4, "Document owner, lifetime, and cleanup or intentional persistence."),
             ("WARNING", "SYNC-LOCAL-PLAYER", 5,
              "Trace all local-only writes and later uses; local safety is not proven by the branch alone."),
             ("WARNING", "HANDLE-FACTORY", 9, "Document owner, lifetime, and cleanup or intentional persistence."),
             ("WARNING", "HANDLE-FACTORY", 15, "Document owner, lifetime, and cleanup or intentional persistence.")])

    def test_declared_fourcc_and_unresolved_helper(self):
        self.assert_cli('function FourCC takes string s returns integer\nreturn \'hfoo\'\nendfunction\n'
                        'call FourCC("hfoo")\n', [])
        self.assert_cli('call FourCC("hfoo")\n',
                        [("ERROR", "WC127-FOURCC", 1, "Use a verified four-character rawcode literal for 1.27b.")])
        self.assert_cli('function FourCC takes string s returns integer\n'
                        'call BlzFake()\nreturn 0\nendfunction\n',
                        [("ERROR", "WC127-BLZ", 2, "Blz API is not vanilla Warcraft III 1.27b.")])

    def test_existing_rules_and_function_scope_cli(self):
        self.assert_cli('function A takes nothing returns nothing\n'
                        'if GetLocalPlayer() == Player(0) then\nset x = 1\nendif\n'
                        'call SetUnitX(u, x)\nendfunction\n'
                        'function B takes nothing returns nothing\ncall SetUnitX(u, x)\n'
                        'call TriggerSleepAction(1.)\nendfunction\n',
                        [("WARNING", "SYNC-LOCAL-PLAYER", 2,
                          "Trace all local-only writes and later uses; local safety is not proven by the branch alone."),
                         ("ERROR", "LOCAL-TAINT", 5, "`x` was assigned locally and later reaches gameplay state."),
                         ("WARNING", "WAIT-IMPRECISE", 9,
                          "Waits are imprecise; review whether a timer/scheduler is required.")])

    def test_help_and_rejected_option_are_read_only(self):
        help_result = subprocess.run([sys.executable, "-B", str(SCRIPT), "--help"], text=True, capture_output=True)
        self.assertEqual((help_result.returncode, help_result.stderr), (0, ""))
        self.assertIn("conservative lexical scan", help_result.stdout)
        self.assertIn("references/lint-limitations.md", help_result.stdout)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Spell.j"
            path.write_bytes(b"// unchanged\n")
            result = subprocess.run([sys.executable, "-B", str(SCRIPT), str(path), "--unknown"],
                                    text=True, capture_output=True)
            self.assertEqual(path.read_bytes(), b"// unchanged\n")
            self.assertEqual((result.returncode, result.stdout), (2, ""))
            self.assertEqual(result.stderr, "usage: wc3lint.py [-h] [--json] path\n"
                             "wc3lint.py: error: unrecognized arguments: --unknown\n")

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


if __name__ == "__main__":
    unittest.main()
