"""Static adapter contracts only: these tests cannot establish JASS/game success."""
import importlib.util
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASE = (ROOT / 'baseline/members/war3map.j').read_bytes()
FUNCTIONS = (ROOT / 'src/functions.j').read_text()
GLOBALS = (ROOT / 'src/globals.j').read_text()
# Names and signatures verified against WCT 1/2/8 and ORIGINAL generated JASS.
PUBLIC = {
    's__Inventory__staticgetindex': ('unit u', 'integer'),
    's__Equipment__staticgetindex': ('unit u', 'integer'),
    's__Inventory_getItem': ('integer this,integer index', 'integer'),
    's__Inventory_getItemId': ('integer this,integer index', 'integer'),
    's__Inventory_itemsOfType': ('integer this,integer id', 'integer'),
    's__Inventory_setItem': ('integer this,integer index,integer itm', 'nothing'),
    's__Inventory_findFreeSlot': ('integer this,integer page', 'integer'),
    's__Inventory_addItem': ('integer this,integer itm', 'boolean'),
    's__Equipment_equip': ('integer this,integer itm,integer equipSlot', 'boolean'),
    's__Equipment_unequip': ('integer this,integer itm,integer slot', 'boolean'),
}


class AdapterContracts(unittest.TestCase):
    def test_all_lowered_calls_are_actual_public_functions_not_storage(self):
        names = set(re.findall(r'\bs__\w+', FUNCTIONS + GLOBALS))
        self.assertEqual(names, set(PUBLIC))
        for name, (args, result) in PUBLIC.items():
            self.assertIn(('function %s takes %s returns %s' % (name, args, result)).encode(), BASE)
            self.assertNotRegex(FUNCTIONS, re.escape(name) + r'\s*\[')
        self.assertNotRegex(FUNCTIONS + GLOBALS, r'\b(?:PlayerHero|InvEvent\w*|SocketInv|SocketLast|SocketSlot|LoadInteger|SaveInteger|SetUnitUserData)\b')
        self.assertNotIn('s__Inventory_create(', FUNCTIONS)
        self.assertNotIn('s__Equipment_create(', FUNCTIONS)
        self.assertNotIn('addSocket', FUNCTIONS)

    def test_all_adapter_symbols_are_prefixed_and_calls_declared_before_use(self):
        declarations = re.findall(r'^function (\w+) takes', FUNCTIONS, re.M)
        self.assertEqual(len(declarations), len(set(declarations)))
        self.assertTrue(all(name.startswith('IL_') for name in declarations))
        for match in re.finditer(r'\b(IL_\w+)\(', FUNCTIONS):
            declaration = FUNCTIONS.index('function ' + match[1] + ' takes')
            self.assertLess(declaration, match.start())
        for match in re.finditer(r'function (IL_\w+)\)', FUNCTIONS):
            self.assertLess(FUNCTIONS.index('function ' + match[1] + ' takes'), match.start())
        self.assertEqual(FUNCTIONS.count('function IL_Start takes nothing returns nothing'), 1)

    def test_public_assembler_preserves_original_startup_and_adapter_only_substitution(self):
        spec = importlib.util.spec_from_file_location('adapter_build', ROOT / 'tools/build.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        result = module.assemble(BASE, GLOBALS.encode(), FUNCTIONS.encode(), 'IL_Start', 'static-contract')
        inserted_g = GLOBALS.replace('@RUN_ID@', 'static-contract').encode()
        inserted_f = FUNCTIONS.replace('@RUN_ID@', 'static-contract').encode()
        self.assertEqual(result.count(b'    call IL_Start()'), 1)
        restored = result.replace(inserted_g, b'', 1).replace(inserted_f, b'', 1).replace(b'    call IL_Start()\r\n', b'', 1)
        self.assertEqual(restored, BASE)
        self.assertIn(b'call InitCustomTriggers()\r\n\r\n    call IL_Start()', result)
        self.assertNotIn(b'@RUN_ID@', result)

    def test_fixture_is_original_fixed_strength_three_in_slot_nine(self):
        source = (ROOT / 'baseline/wct/trigger-014.j').read_text()
        block = source.split("set itm = CreateInvItem('rst1'", 1)[1].split('// Necklace', 1)[0]
        self.assertIn('set itm.slot = 9', block)
        self.assertIn('call itm.addBonus(BONUS_STRENGTH, 3)', block)
        self.assertNotIn('addBonusRange', block)
        self.assertIn("GetInvItem('rst1')", FUNCTIONS)
        self.assertIn('GetHeroStr(IL_Hero, true) == IL_BaseStr+3', FUNCTIONS)
        self.assertIn('GetHeroStr(IL_Hero, true) == IL_BaseStr', FUNCTIONS)

    def test_scheduling_persistence_and_honest_watchdog(self):
        self.assertIn('TriggerAddCondition(IL_Persist, Condition(function IL_Flush))', FUNCTIONS)
        self.assertIn('call TriggerEvaluate(IL_Persist)', FUNCTIONS)
        self.assertIn('call TriggerExecute(IL_Work)', FUNCTIONS)
        self.assertIn('call TimerStart(IL_Next, 2., false, function IL_Dispatch)', FUNCTIONS)
        run = FUNCTIONS.split('function IL_Run takes', 1)[1].split('endfunction', 1)[0]
        self.assertLess(run.index('TimerStart(IL_Watch'), run.index('IL_ReadyHero()'))
        timeout = FUNCTIONS.split('function IL_Timeout takes', 1)[1].split('endfunction', 1)[0]
        self.assertIn('IL_Record("FAIL"', timeout)
        self.assertIn('did not return', timeout)
        self.assertNotIn('"PASS"', timeout)
        self.assertNotIn('after=scenario returned', timeout)
        self.assertIn('IL_Close()', timeout)

    def test_native_readiness_pickup_and_preservation_guards(self):
        self.assertIn('GroupEnumUnitsOfPlayer(g, Player(0), null)', FUNCTIONS)
        self.assertIn('n == 1', FUNCTIONS)
        self.assertIn('UNIT_TYPE_HERO', FUNCTIONS)
        self.assertIn('EVENT_PLAYER_UNIT_PICKUP_ITEM', FUNCTIONS)
        self.assertIn('UnitAddItem(IL_Hero, IL_Physical)', FUNCTIONS)
        self.assertIn('GetItemTypeId(IL_Physical) == 0', FUNCTIONS)
        self.assertIn('IL_PickEvents == 1', FUNCTIONS)
        self.assertIn('s__Inventory_getItemId(IL_Inv, 0) > 0', FUNCTIONS)
        for marker in ('add0', 'add31', 'wrong-slot0', 'occupied-slot8'):
            before, after = FUNCTIONS.split('"before=' + marker + '"', 1)
            self.assertIn('call IL_Snapshot()', before[-100:])
            self.assertIn('"after=' + marker + '"', after)
            self.assertIn('not ok and IL_Unchanged()', after.split('elseif', 1)[0])
        self.assertIn('IL_Owned[i] and s__Inventory_getItem(IL_Inv, i) == IL_Fixture', FUNCTIONS)
        self.assertIn('restore-original-custom-ids', FUNCTIONS)

    def test_bounded_matrix_and_explicit_non_certification(self):
        self.assertIn('if IL_Case == 14 then', FUNCTIONS)
        self.assertIn('IL_LineCount >= 512', FUNCTIONS)
        self.assertIn('StringLength(text) > 160', FUNCTIONS)
        for text in ('pages -', 'sell-drop -', 'sockets -', 'Camera.destroy'):
            self.assertIn('IL_Record("SKIP", "' + text, FUNCTIONS)
        for text in ('no public live-instance', 'original local-player', 'equipment fields'):
            self.assertIn('IL_Record("OBS", "' + text, FUNCTIONS)
        self.assertNotIn('call s__Camera_destroy', FUNCTIONS)
        self.assertNotRegex(FUNCTIONS, r'\b(?:Blz\w*|FourCC|ExecuteFunc|TriggerSleepAction)\s*\(')


if __name__ == '__main__':
    unittest.main()
