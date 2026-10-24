"""ITL public-tooling/static contracts, NOT engine-physics or native validation."""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

import test_build as fixtures

ROOT = fixtures.TOOL.parents[1]
SRC = ROOT / 'src/technical'
BASE = (ROOT / 'baseline/members/war3map.j').read_bytes()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class TechnicalContracts(unittest.TestCase):
    def sources(self):
        return {n: (SRC / n).read_text() for n in ('globals.j', 'early.j', 'functions.j')}

    def test_adapter_parameters_do_not_shadow_classic_handle_types(self):
        # Classic common.j type names are not safe parameter identifiers for
        # the target engine, even when the installed pJASS accepts the source.
        classic_types = {'agent', 'handle', 'event', 'timer', 'trigger', 'unit',
                         'player', 'group', 'force', 'effect', 'rect', 'location',
                         'boolexpr', 'conditionfunc', 'filterfunc'}
        collisions = []
        for filename, source in self.sources().items():
            for params in re.findall(r'^function \w+ takes (.*?) returns ', source, re.M):
                if params == 'nothing':
                    continue
                for parameter in params.split(','):
                    name = parameter.strip().split()[-1]
                    if name in classic_types:
                        collisions.append((filename, name))
        self.assertEqual(collisions, [])

    def test_four_modes_fail_closed_and_no_previous_autorun(self):
        sources = self.sources()
        late = sources['functions.j']
        for prefix, length in (('itl-button-', 11), ('itl-picture-', 12),
                               ('itl-text-', 9), ('itl-camera-', 11)):
            self.assertIn('SubString(ITL_RUN, 0, %d) == "%s"' % (length, prefix), late)
        self.assertIn('unknown mode - no fixture calls', late)
        self.assertIn('string ITL_RUN = "@RUN_ID@"', sources['globals.j'])
        self.assertNotIn('ILM_Init', late)
        self.assertNotIn('IL_Start', late)
        self.assertEqual(late.count('call s__Camera_destroy(ITL_Camera)'), 1)

    def test_only_original_public_api_and_native_oracles(self):
        sources = '\n'.join(self.sources().values())
        names = set(re.findall(r'\bs__\w+', sources))
        expected = {'s__Camera_create', 's__Camera_setPosition', 's__Camera_destroy'}
        for cls in ('UIButton', 'UIPicture', 'UIText'):
            expected.update('s__' + cls + '_' + method for method in
                            ('create', 'destroy', 'show', 'update', 'updateAll'))
        expected.add('s__UIButton_clickPeriodicSelect')
        self.assertEqual(names, expected)
        for name in names:
            self.assertRegex(BASE.decode('cp1252'), r'function ' + name + r' takes [^\r\n]+ returns (integer|nothing|boolean)')
            self.assertNotRegex(sources, name + r'\s*\[')
        for forbidden in ('LoadInteger(', 'GetTimerData(', 'SaveInteger(', 'SetUnitUserData(',
                          'GetHandleId(', 'Blz', 'FourCC', 'TriggerSleepAction', 'CreateWindow'):
            self.assertNotIn(forbidden, sources)
        for native in ('GroupEnumUnitsOfPlayer', 'IsUnitInGroup', 'GetUnitTypeId', 'GetUnitX', 'GetUnitY'):
            self.assertIn(native, sources)
        self.assertIn("GetUnitTypeId(ITL_Units[slot]) == 'uidm'", sources)
        self.assertTrue(sources.isascii())
        self.assertIn('UIText hide preserves native position', sources)
        self.assertIn('expected=removed actual-type=', sources)

    def test_byte_pinned_insertions_strip_exact_original_and_return_unchanged(self):
        module = load('itl_builder', fixtures.TOOL)
        manifest = json.loads((SRC / 'hooks.json').read_text())
        sources = self.sources()
        for mode in ('button', 'picture', 'text', 'camera'):
            spans = []
            result = module.assemble(BASE, sources['globals.j'].encode(), sources['functions.j'].encode(),
                                     'ITL_Init', 'itl-' + mode + '-static', early=sources['early.j'].encode(),
                                     hooks=manifest, metadata=spans)
            stripped = result
            for span in reversed(spans):
                payload = stripped[span['offset']:span['offset'] + span['size']]
                self.assertEqual(hashlib.sha256(payload).hexdigest(), span['sha256'])
                stripped = stripped[:span['offset']] + stripped[span['offset'] + span['size']:]
            self.assertEqual(stripped, BASE)
            self.assertEqual(result.count(b'call ITL_Init()'), 1)
            self.assertNotIn(b'call ILM_Init()', result)
            self.assertNotIn(b'call IL_Start()', result)
        hooks = manifest['functions']
        self.assertEqual({f['name'] for f in hooks}, {'NewTimerEx', 'ReleaseTimer',
                         's__UIButton_enableButtonCallback', 's__UIButton_clickL'})
        text = (SRC / 'hooks.json').read_text()
        self.assertIn('ITL_Capture(s__TimerUtils___tT[TimerUtils___tN], value)', text)
        self.assertIn('ITL_Expired(GetExpiredTimer())', text)
        self.assertNotIn('LoadInteger', text)
        for _, payload in module.manual_hooks(BASE, manifest):
            self.assertTrue(all(line.strip().startswith(b'call ILM_Log(') for line in payload.splitlines()))
        early = sources['early.j']
        for forbidden in ('CreateTimer(', 'ReleaseTimer(', 'PauseTimer(', 'Preload(', 'TriggerEvaluate('):
            self.assertNotIn(forbidden, early)

    def test_scheduled_bounds_watchdog_and_no_forged_after(self):
        late = self.sources()['functions.j']
        self.assertIn('TriggerAddCondition(ITL_Persist, Condition(function ITL_Flush))', late)
        self.assertIn('TriggerEvaluate(ITL_Persist)', late)
        self.assertIn('TriggerExecute(ITL_Work)', late)
        self.assertIn('ITL_LineCount >= 512', late)
        self.assertIn('ITL_Pair <= 16', late)
        self.assertIn('TimerStart(ITL_Watch, 4.', late)
        timeout = late.split('function ITL_Timeout takes', 1)[1].split('endfunction', 1)[0]
        self.assertIn('ITL_Record("FAIL"', timeout)
        self.assertIn('did not return', timeout)
        self.assertNotIn('after=', timeout)
        camera = late.split('function ITL_CameraProbe takes', 1)[1].split('endfunction', 1)[0]
        self.assertLess(camera.index('if ITL_Camera <= 0 then'), camera.index('call s__Camera_destroy'))
        self.assertLess(camera.index('before=Camera.destroy'), camera.index('call s__Camera_destroy'))
        self.assertGreater(camera.index('after=Camera.destroy'), camera.index('call s__Camera_destroy'))
        self.assertNotIn('s__Camera_destroy', timeout)
        self.assertIn('baseline-deficit before=harness-cleanup', late)
        self.assertIn('ITL_HarnessCleanup = true', late)
        self.assertIn('not ITL_Retired[i]', late)
        self.assertIn('not ITL_CleanupAttempted[i]', late)
        cleanup = late.split('function ITL_TimerCleanup takes', 1)[1].split('endfunction', 1)[0]
        self.assertLess(cleanup.index('set ITL_CleanupAttempted[i] = true'), cleanup.index('call ReleaseTimer'))
        self.assertIn('SelectUnit(ITL_Units[0], true)', late)
        self.assertIn('s__UIButton_clickPeriodicSelect(Player(0), true)', late)

    def test_membership_replaces_extra_slot_then_compares_direct_updates(self):
        late = self.sources()['functions.j']
        member = late.split('function ITL_Membership takes', 1)[1].split('endfunction', 1)[0]
        self.assertLess(member.index('ITL_Destroy(0)'), member.index('ITL_Create(3)'))
        self.assertLess(member.index('ITL_Create(3)'), member.index('ITL_UpdateAll()'))
        self.assertIn('missing=', member)
        self.assertIn('changed=', member)
        self.assertIn('ITL_Direct(i)', member)
        self.assertIn('ITL_ProjectionReady', member)
        self.assertIn('shared membership not restored', member)
        self.assertIn('routine-cameras=1 retained-until-map-shutdown', late)
        self.assertIn('immediate-id-reuse', late)
        self.assertNotIn('FPS', late)

    def test_source_signatures_and_allocator_contract(self):
        original = BASE.decode('cp1252')
        signatures = {
            's__UIButton_create': 'real minx,real maxy,real W,real H,real z,integer texture returns integer',
            's__UIPicture_create': 'real minx,real maxy,real w,real h,real z,integer texture returns integer',
            's__UIPicture_createEx': 'real minx,real maxy,real z,real scale,integer unitId,real modelWidth,real modelHeight,integer texture returns integer',
            's__UIText_create': 'real minx,real maxy,real z returns integer',
            's__UIText_createEx': 'player p,real minx,real maxy,real z returns integer',
            's__Camera_create': 'nothing returns integer',
            's__Camera_setPosition': 'integer this,real x,real y,real z returns nothing',
            's__Camera_destroy': 'integer this returns nothing',
            'NewTimerEx': 'integer value returns timer',
            'ReleaseTimer': 'timer t returns nothing',
            's__UIButton_clickPeriodicSelect': 'player p,boolean isLeft returns boolean',
        }
        for cls in ('UIButton', 'UIPicture', 'UIText'):
            for method in ('destroy', 'update'):
                signatures['s__' + cls + '_' + method] = 'integer this returns nothing'
            signatures['s__' + cls + '_updateAll'] = 'nothing returns nothing'
            flag = 'flag' if cls == 'UIButton' else 'show'
            signatures['s__' + cls + '_show'] = 'integer this,boolean ' + flag + ',integer Cam returns nothing'
            allocator = original.split('function s__' + cls + '__allocate takes', 1)[1].split('endfunction', 1)[0]
            self.assertLess(allocator.index('if ( this != 0 )'), allocator.index('else'))
            self.assertIn('set si__' + cls + '_F=si__' + cls + '_V[this]', allocator)
            destructor = original.split('function s__' + cls + '_deallocate takes', 1)[1].split('endfunction', 1)[0]
            self.assertIn('set si__' + cls + '_F=this', destructor)
            public_destroy = original.split('function s__' + cls + '_destroy takes', 1)[1].split('endfunction', 1)[0]
            self.assertNotIn('_deallocate(', public_destroy)
        for name, signature in signatures.items():
            self.assertIn('function ' + name + ' takes ' + signature, original)
        self.assertIn("s__Interface_DUMMY_TYPE= 'uidm'", original)
        self.assertIn('s__Interface_LEFT_CLICK_DELAY= 0.6', original)
        self.assertIn('CAMERA_DUMMY_PLAYER= Player(bj_PLAYER_NEUTRAL_EXTRA)', original)
        for slot in ('025', '029', '032'):
            self.assertTrue((ROOT / ('baseline/wct/trigger-' + slot + '.j')).is_file())
        grace = original.split('function InventoryCore_GracePeriod takes', 1)[1].split('endfunction', 1)[0]
        self.assertIn('call ReleaseTimer(t)', grace)
        callback = original.split('function s__UIButton_enableButtonCallback takes', 1)[1].split('endfunction', 1)[0]
        self.assertNotIn('ReleaseTimer', callback)

    def test_timer_boundary_counts_model_and_ownership_guards(self):
        # Public event-stream accounting model: expired is not retired; cleanup never
        # changes a baseline verdict. Handles are typed tokens, not integer IDs/pools.
        owned = object()
        unrelated = object()
        live = {}
        counts = dict(acquired=0, expired=0, retired=0, cleanup=0)
        events = [('acquire', unrelated, False), ('acquire', owned, True),
                  ('expired', owned, True), ('pause', owned, True),
                  ('release-rejected', owned, True)]
        def observe(event, handle, matches):
            if event == 'acquire' and matches:
                live[handle] = False
                counts['acquired'] += 1
            elif handle in live and not live[handle]:
                if event == 'expired':
                    counts['expired'] += 1
                elif event in ('release-success', 'destroy-success', 'harness-release'):
                    live[handle] = True
                    counts['cleanup' if event == 'harness-release' else 'retired'] += 1
        for event in events:
            observe(*event)
        self.assertEqual(counts, dict(acquired=1, expired=1, retired=0, cleanup=0))
        deficit_before_cleanup = counts['acquired'] - counts['retired']
        observe('harness-release', owned, True)
        observe('harness-release', owned, True)
        self.assertEqual(counts, dict(acquired=1, expired=1, retired=0, cleanup=1))
        self.assertEqual(deficit_before_cleanup, 1)
        for event in ('release-success', 'destroy-success'):
            fresh = object()
            observe('acquire', fresh, True)
            observe(event, fresh, True)
        self.assertEqual(counts['retired'], 2)
        early = self.sources()['early.j']
        self.assertIn('data == ITL_OwnedButton', early)
        self.assertIn('ITL_TimerGeneration[i] == ITL_Generation', early)
        self.assertIn('ITL_Timers[i] == t and not ITL_Retired[i]', early)
        self.assertIn('if ITL_HarnessCleanup then', early)
        self.assertIn('ITL_TimerCount < 8', early)
        manifest = json.loads((SRC / 'hooks.json').read_text())
        release = next(f for f in manifest['functions'] if f['name'] == 'ReleaseTimer')
        self.assertEqual(len(release['hooks']), 2)
        self.assertTrue(all(h['side'] == 'after' and h['count'] == 1 for h in release['hooks']))
        self.assertEqual({h['anchor'] for h in release['hooks']},
                         {'            call DestroyTimer(t)\r\n',
                          '            set TimerUtils___tN=TimerUtils___tN + 1\r\n'})

    def test_declaration_order(self):
        sources = self.sources()
        text = sources['early.j'] + sources['functions.j']
        names = re.findall(r'^function (\w+) takes', text, re.M)
        self.assertEqual(len(names), len(set(names)))
        self.assertTrue(all(n.startswith('ITL_') or n == 'ILM_Log' for n in names))
        for match in re.finditer(r'\b((?:ITL_\w+|ILM_Log))\(', text):
            self.assertLess(text.index('function ' + match[1] + ' takes'), match.start())
        for match in re.finditer(r'function (ITL_\w+)\)', text):
            self.assertLess(text.index('function ' + match[1] + ' takes'), match.start())

    def test_frozen_inputs_and_documented_evidence_limits(self):
        plan = json.loads((ROOT / 'reports/technical/plan.json').read_text())
        self.assertGreaterEqual(len(plan['frozen_inputs']), 7)
        for path, sha in plan['frozen_inputs'].items():
            self.assertEqual(hashlib.sha256((ROOT / path).read_bytes()).hexdigest(), sha, path)
        doc = (ROOT / 'docs/technical-testing.md').read_text()
        for text in ('four disposable maps', 'clean GUI companion', 'Multiplayer',
                     'not RSS', '512', '4-second', '--early-functions', '--hooks',
                     'close', 'FAIL', 'Scanned'):
            self.assertIn(text, doc)

    def test_strict_reader_expected_failure_timeout_and_incomplete(self):
        # Exercise the existing reader CLI, not an ITL-specific permissive parser.
        with tempfile.TemporaryDirectory(prefix='itl-reader-', dir=os.environ['TMPDIR']) as tmp:
            path = Path(tmp) / 'input.pld'
            for detail in ('baseline-deficit before=harness-cleanup acquired=1 expired=1 retired=0',
                           'watchdog did not return cleanup-unknown'):
                rows = [('BEGIN', '-', 'schema=1'), ('CASE', 'timer', 'before'),
                        ('CHECK', 'timer', 'before=public-call'), ('FAIL', 'timer', detail),
                        ('RESULT', 'timer', 'pass=0 fail=1 obs=0 skip=0'),
                        ('COMPLETE', '-', 'cases=1 pass=0 fail=1 obs=0 skip=0')]
                data = ''.join('IL141|itl-button-static|%d|%s|%s|%s\n' % (i, *row)
                               for i, row in enumerate(rows, 1)).encode()
                path.write_bytes(data)
                args = [os.sys.executable, '-B', str(ROOT / 'tools/read_logs.py'), str(path),
                        '--run-id', 'itl-button-static', '--not-before', '0']
                result = subprocess.run(args, capture_output=True, text=True, timeout=20)
                report = dict(run_id='itl-button-static', cases=1, inconclusive=False,
                              **{'pass': 0, 'fail': 1, 'obs': 0, 'skip': 0})
                self.assertEqual((result.returncode, result.stdout, result.stderr),
                                 (1, json.dumps(report, indent=2, sort_keys=True) + '\n', ''))
                self.assertEqual(path.read_bytes(), data)
                path.write_bytes(data[:data.rfind(b'IL141|')])
                incomplete = path.read_bytes()
                result = subprocess.run(args, capture_output=True, text=True, timeout=20)
                self.assertEqual((result.returncode, result.stdout, result.stderr),
                                 (2, '', 'error: invalid evidence\n'))
                self.assertEqual(path.read_bytes(), incomplete)


if __name__ == '__main__':
    unittest.main()
