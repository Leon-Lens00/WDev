import importlib.util
import struct
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "map_inventory.py"
SPEC = importlib.util.spec_from_file_location("map_inventory", SCRIPT)
inventory = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(inventory)


class InventoryTests(unittest.TestCase):
    @staticmethod
    def _custom_text(text):
        data = text.encode("utf-8")
        return struct.pack("<i", len(data) + 1) + data + b"\0"

    def test_detects_vjass_constructs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "Missile.j"
            source.write_text(
                """library Missile requires Table, TimerUtils
private keyword Node
struct Missile extends array
endstruct
//! textmacro MAKE takes NAME
//! endtextmacro
endlibrary
""",
                encoding="utf-8",
            )
            result = inventory.analyze_jass(source, root)
            self.assertEqual(result["libraries"][0]["name"], "Missile")
            self.assertEqual(result["libraries"][0]["requires"], ["Table", "TimerUtils"])
            self.assertEqual(result["keywords"], ["Node"])
            self.assertEqual(result["structs"][0]["extends"], "array")

    def test_dependency_inventory_ignores_optional_modifier(self):
        result = inventory.analyze_jass_text(
            "library Missiles requires optional WorldBounds, TimerUtils\nendlibrary\n",
            "Missiles.j",
        )

        self.assertEqual(result["libraries"][0]["requires"], ["TimerUtils", "WorldBounds"])

    def test_decodes_editable_vjass_from_wct(self):
        payload = (
            struct.pack("<i", 1)
            + b"Map header\0"
            + self._custom_text("globals\nendglobals")
            + struct.pack("<I", 2)
            + self._custom_text("library Missile\nendlibrary")
            + self._custom_text("")
        )

        result = inventory.analyze_wct_bytes(payload)

        self.assertEqual(result["version"], 1)
        self.assertEqual(result["comment"], "Map header")
        self.assertEqual(result["global_custom_script"], "globals\nendglobals")
        self.assertEqual(result["trigger_count"], 2)
        self.assertEqual(result["non_empty_trigger_count"], 1)
        self.assertEqual(result["triggers"][0]["text"], "library Missile\nendlibrary")
        self.assertEqual(result["triggers"][0]["vjass"]["libraries"][0]["name"], "Missile")

    def test_decodes_extended_wct_wrapper(self):
        payload = (
            struct.pack("<I", 0x80000004)
            + struct.pack("<i", 1)
            + b"Extended trigger data\0"
            + self._custom_text("globals\nendglobals")
            + self._custom_text("library Missile\nendlibrary")
        )

        result = inventory.analyze_wct_bytes(payload)

        self.assertEqual(result["wrapper_magic"], "0x80000004")
        self.assertEqual(result["version"], 1)
        self.assertEqual(result["comment"], "Extended trigger data")
        self.assertEqual(result["trigger_count"], 1)
        self.assertEqual(result["triggers"][0]["text"], "library Missile\nendlibrary")

    def test_rejects_truncated_wct(self):
        with self.assertRaisesRegex(ValueError, "truncated"):
            inventory.analyze_wct_bytes(struct.pack("<i", 1) + b"missing-null")


if __name__ == "__main__":
    unittest.main()
