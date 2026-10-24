"""S1: source contracts only; never proof of native enumeration or expiry."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


def body(name):
    text = (ROOT / "src/technical/functions.j").read_text()
    return text.split("function " + name + " takes", 1)[1].split("endfunction", 1)[0]


class TechnicalOracleRegressions(unittest.TestCase):
    def test_fixture_uses_public_original_owner(self):
        original = (ROOT / "baseline/members/war3map.j").read_text(encoding="cp1252")
        self.assertIn("constant player s__Interface_PLAYER= CAMERA_DUMMY_PLAYER", original)
        for cls in ("UIButton", "UIPicture", "UIText"):
            ctor = original.split("function s__" + cls + "_create takes", 1)[1].split("endfunction", 1)[0]
            self.assertIn("CreateUnit(s__Interface_PLAYER, s__Interface_DUMMY_TYPE,", ctor)
        create = body("ITL_Create")
        self.assertEqual(re.findall(r"GroupEnumUnitsOfPlayer\((?:before|after), ([^,]+), null\)", create),
                         ["CAMERA_DUMMY_PLAYER", "CAMERA_DUMMY_PLAYER"])
        self.assertIn("GetOwningPlayer(u) == CAMERA_DUMMY_PLAYER", create)
        self.assertNotIn("Player(13)", create)

    def test_timer_deficit_requires_actual_owned_expiry(self):
        verdict = body("ITL_TimerVerdict")
        gate = re.search(r"local boolean ready = ([^\n]+)", verdict)[1]
        for prerequisite in ("ITL_Clicks > 0", "ITL_Acquired > 0",
                             "ITL_Beat > ITL_StartBeat", "ITL_ExpiredCount > 0"):
            self.assertIn(prerequisite, gate)
        self.assertLess(verdict.index("if ready then"), verdict.index("actual-deficit="))
        self.assertLess(verdict.index("actual-deficit="), verdict.index("call ITL_TimerCleanup()"))
