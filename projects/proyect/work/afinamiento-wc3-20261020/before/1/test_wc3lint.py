import importlib.util
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
