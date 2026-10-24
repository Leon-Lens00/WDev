"""Private exclusive recipe; prepare exactly two frozen inputs, never build or run maps.

Execute once: python3 -B projects/relativistic-classic/reports/cycle3/prepare.py
Uses existing build guards/writers and cycle2's unique-transform helper.
"""
from pathlib import Path
import difflib
import importlib.util
import json

PROJECT = Path(__file__).resolve().parents[2]
REPORT = Path(__file__).resolve().parent
SOURCE = PROJECT / 'src'
STRESS = PROJECT / 'build/inputs-diag2-m45-stress-20261019-01'
E29 = PROJECT / 'build/inputs-diag2-e29-20261019-01'
RUN_A = 'diag3-logger-stress-20261019-01'
RUN_B = 'diag3-e29-transfer-20261019-01'
DEST_A = PROJECT / ('build/inputs-' + RUN_A)
DEST_B = PROJECT / ('build/inputs-' + RUN_B)
CORE = 'adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6'


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


build = load('classic_build', PROJECT / 'tools/build.py')
previous = load('previous_stress_recipe', PROJECT / 'reports/cycle2/prepare-m45-stress.py')
digest = build.digest
replace_once = previous.replace_once


def tree(root):
    assert all(not p.is_symlink() for p in (root, *root.parents, *root.rglob('*')))
    return {p.relative_to(root).as_posix(): p.read_bytes()
            for p in sorted(root.rglob('*.j'))}


def hashes(files):
    return {name: digest(data) for name, data in files.items()}


def function(text, name):
    start = text.index('    function ' + name + ' ')
    end = text.index('    endfunction\n', start) + len('    endfunction\n')
    return text[start:end]


def experiment(env):
    env = replace_once(env, '        private real diagnosticWithdrawalClock = 0.',
                       '        private real diagnosticTransferClock = 0.\n        private real diagnosticWithdrawalClock = 0.')
    start = env.index('    private function DiagnosticSample ')
    end = env.index('    // Save every incoming shared-vision edge', start)
    env = replace_once(env, env[start:end], '''    private function DiagnosticSample takes string phase returns nothing
        local real clock = TimerGetElapsed(RM_CLOCK)
        local unit dummy1 = RM_DUMMY[1]
        local unit dummy2 = RM_DUMMY[2]
        if RM_STAGE <= 10 then
            set dummy1 = RM_M[1].dummy
            set dummy2 = RM_M[2].dummy
        endif
        call RM_Record("OBS", "diag3-visibility-sample", "phase=" + phase + " stage=" + I2S(RM_STAGE) + " clock=" + R2S(clock) + " sinceTransfer=" + R2S(clock-diagnosticTransferClock) + " sinceWithdrawal=" + R2S(clock-diagnosticWithdrawalClock) + " rawReady=" + DiagnosticBoolean(diagnosticReady) + " rawP1=" + DiagnosticBoolean(IsVisibleToPlayer(100., 3000., Player(1))) + " rawP2=" + DiagnosticBoolean(IsVisibleToPlayer(100., 3000., Player(2))) + " primaryP1=" + DiagnosticBoolean(IsVisibleToPlayer(-800., 0., Player(1))) + " primaryP2=" + DiagnosticBoolean(IsVisibleToPlayer(-800., 0., Player(2))) + " fallbackP1=" + DiagnosticBoolean(IsVisibleToPlayer(2400., 0., Player(1))) + " fallbackP2=" + DiagnosticBoolean(IsVisibleToPlayer(2400., 0., Player(2))))
        call RM_Record("OBS", "diag3-public-state", "phase=" + phase + " stage=" + I2S(RM_STAGE) + " clock=" + R2S(clock) + " m1OwnerNull=" + DiagnosticBoolean(RM_M[1].owner == null) + " source1Type=" + I2S(GetUnitTypeId(RM_M[1].source)) + " source2Type=" + I2S(GetUnitTypeId(RM_M[2].source)) + " dummy1Owner=" + I2S(GetPlayerId(GetOwningPlayer(dummy1))) + " dummy1XY=" + R2S(GetUnitX(dummy1)) + "," + R2S(GetUnitY(dummy1)) + " dummy2Owner=" + I2S(GetPlayerId(GetOwningPlayer(dummy2))) + " dummy2XY=" + R2S(GetUnitX(dummy2)) + "," + R2S(GetUnitY(dummy2)))
        set dummy1 = null
        set dummy2 = null
    endfunction

''')
    env = replace_once(env, '                set RM_LIMIT = 16', '                set RM_LIMIT = 19')
    env = replace_once(env,
        '                set diagnosticBounds = DiagnosticInBounds(0., 3000.) and DiagnosticInBounds(100., 3000.)',
        '                set diagnosticBounds = DiagnosticInBounds(0., 3000.) and DiagnosticInBounds(100., 3000.) and DiagnosticInBounds(-200., 2800.) and DiagnosticInBounds(200., 3200.)')
    env = replace_once(env,
        '                set diagnosticHidden = not IsVisibleToPlayer(100., 3000., Player(2))',
        '                set diagnosticHidden = not IsVisibleToPlayer(100., 3000., Player(1)) and not IsVisibleToPlayer(100., 3000., Player(2))')
    env = replace_once(env,
        '                call RM_Record("OBS", "diag2-raw-initial-readiness", "bounds=" + DiagnosticBoolean(diagnosticBounds) + " hidden=" + DiagnosticBoolean(diagnosticHidden) + " center=0,3000 radius=200 probe=100,3000 owner=2 visible,true,false")',
        '                call RM_Record("OBS", "diag3-raw-initial-readiness", "bounds=" + DiagnosticBoolean(diagnosticBounds) + " hiddenBoth=" + DiagnosticBoolean(diagnosticHidden) + " rawP1=" + DiagnosticBoolean(IsVisibleToPlayer(100., 3000., Player(1))) + " rawP2=" + DiagnosticBoolean(IsVisibleToPlayer(100., 3000., Player(2))) + " center=0,3000 radius=200 probe=100,3000 owner=1 visible,true,false")')
    env = replace_once(env,
        '                    set diagnosticFog = CreateFogModifierRadius(Player(2), FOG_OF_WAR_VISIBLE, 0., 3000., 200., true, false)',
        '                    set diagnosticFog = CreateFogModifierRadius(Player(1), FOG_OF_WAR_VISIBLE, 0., 3000., 200., true, false)')
    env = replace_once(env,
        '                set diagnosticReady = IsVisibleToPlayer(100., 3000., Player(2))\n                call RM_Check(diagnosticReady, "diag2-raw-reveals", "initially hidden in-bounds raw probe100,3000 owner2 radius200")',
        '                set diagnosticReady = IsVisibleToPlayer(100., 3000., Player(1)) and not IsVisibleToPlayer(100., 3000., Player(2))\n                call RM_Check(diagnosticReady, "diag2-raw-reveals", "initially hidden to both; in-bounds raw probe100,3000 reveals owner1 radius200 and isolates owner2")')
    env = replace_once(env,
        '            set RM_M[1].owner = Player(2)\n            call SetUnitOwner(RM_U, Player(1), false)',
        '''            call DiagnosticSample("before-transfer")
            set diagnosticTransferClock = TimerGetElapsed(RM_CLOCK)
            set RM_M[1].owner = Player(2)
            call SetUnitOwner(RM_U, Player(1), false)
            call DiagnosticStop()
            if diagnosticReady then
                set diagnosticFog = CreateFogModifierRadius(Player(2), FOG_OF_WAR_VISIBLE, 0., 3000., 200., true, false)
                call FogModifierStart(diagnosticFog)
            endif
            // Core owner reconciliation occurs on its visit, not necessarily here.
            call DiagnosticSample("after-transfer")''')
    # Move withdrawal as one exact block; no ownerless assertion is changed.
    withdrawal_start = env.index('            // Cache public handles while alive;')
    withdrawal_end = env.index('            set RM_U = null\n', withdrawal_start) + len('            set RM_U = null\n')
    withdrawal = env[withdrawal_start:withdrawal_end]
    env = replace_once(env, withdrawal, '''            call DiagnosticSample("transfer-0.25s")
            if diagnosticReady then
                call RM_Check(not IsVisibleToPlayer(100., 3000., Player(1)) and IsVisibleToPlayer(100., 3000., Player(2)), "diag3-raw-owner-transfer", "old owner1 loses reveal and new owner2 gains reveal at scheduled0.25s; OBS separates old-retained from new-not-yet-visible")
            else
                call RM_Record("SKIP", "diag3-raw-owner-transfer", "raw readiness/reveal/isolation invalid; no native transfer success claimed")
            endif
        elseif RM_CASE == 29 and RM_STAGE >= 8 and RM_STAGE <= 10 then
            call DiagnosticSample("transfer-held")
            if RM_STAGE == 10 then
''' + ''.join('    ' + line for line in withdrawal.splitlines(True)) + '''            endif
''')
    env = replace_once(env, '        elseif RM_CASE == 29 and RM_STAGE == 8 then',
                       '        elseif RM_CASE == 29 and RM_STAGE == 11 then')
    env = replace_once(env, '        if RM_CASE == 29 and RM_STAGE >= 8 and RM_STAGE <= 16 then\n            call DiagnosticSample()\n            if RM_STAGE == 12 then',
                       '        if RM_CASE == 29 and RM_STAGE >= 11 and RM_STAGE <= 19 then\n            call DiagnosticSample("withdrawal")\n            if RM_STAGE == 15 then')
    env = replace_once(env, '// Additional checkpoint only: original stage8 assertions stay intact.',
                       '// Additional checkpoint only: original ownerless assertions stay intact at stage11.')
    env = replace_once(env, 'scheduled1.25s after stage7', 'scheduled1.25s after stage10')
    return env


def patch(before, after, label):
    return ''.join(difflib.unified_diff(before.splitlines(True), after.splitlines(True),
                                       fromfile=label + '.before', tofile=label + '.after')).encode()


def prepare():
    source, stress, e29 = tree(SOURCE), tree(STRESS), tree(E29)
    assert all(digest(t['Missiles.j']) == CORE for t in (source, stress, e29))
    old_manifest = json.loads((STRESS / 'manifest.json').read_bytes())
    e29_manifest = json.loads((E29 / 'manifest.json').read_bytes())
    assert hashes(stress) == old_manifest['input_sha256']
    assert hashes(e29) == e29_manifest['input_sha256']
    support = source['lab/Support.j'].decode()
    old_support = stress['lab/Support.j'].decode()
    # Verify historical RED logger equivalence except the exact retained RM_Case prefill.
    old_case = function(old_support, 'RM_Case')
    current_case = function(support, 'RM_Case')
    original_support = replace_once(old_support, old_case, current_case)
    assert digest(original_support.encode()) == old_manifest['source_sha256']['lab/Support.j']
    assert old_manifest['source_sha256']['lab/Support.j'] == 'd733ef12e5e130548a2715209edadb417e465a11582c02b5ec6df5bebdc91708'
    assert old_case.count('exitwhen padding > 700') == 1
    assert function(support, 'RM_Record') == function(original_support, 'RM_Record')
    assert function(support, 'RM_Complete') == function(original_support, 'RM_Complete')
    a = dict(stress)
    a['lab/Support.j'] = replace_once(support, current_case, old_case).encode()
    a['lab/Config.j'] = replace_once(a['lab/Config.j'].decode(),
        'RM_RUN_ID = "diag2-m45-stress-20261019-01"', 'RM_RUN_ID = "' + RUN_A + '"').encode()
    assert sorted(n for n in a if a[n] != stress[n]) == ['lab/Config.j', 'lab/Support.j']
    assert function(a['lab/Support.j'].decode(), 'RM_Case') == old_case
    assert a['lab/Motion.j'] == stress['lab/Motion.j'] and a['lab/Runner.j'] == stress['lab/Runner.j']
    b = dict(source)
    config = replace_once(b['lab/Config.j'].decode(), 'RM_RUN_ID = "UNCONFIGURED"', 'RM_RUN_ID = "' + RUN_B + '"')
    b['lab/Config.j'] = replace_once(config, 'RM_SELECT = "all"', 'RM_SELECT = "E29"').encode()
    env_before = e29['lab/Environment.j'].decode()
    env_after = experiment(env_before)
    b['lab/Environment.j'] = env_after.encode()
    assert sorted(n for n in b if b[n] != source[n]) == ['lab/Config.j', 'lab/Environment.j']
    # Preservation inspection, not a physics/native test: all maintained assertion/record
    # calls survive byte-for-byte; branch ordering inspected separately in e29.patch.
    for line in source['lab/Environment.j'].decode().splitlines():
        if any(call in line for call in ('call RM_Check(', 'call RM_Record(', 'call RM_Equal(', 'call RM_Near(')):
            assert line in env_after, 'maintained assertion/record changed: ' + line
    assert b['lab/Support.j'] == source['lab/Support.j']
    historical = PROJECT / 'reports/cycle2/RM28-diag2-m45-stress-20261019-01.partial.txt'
    assert digest(historical.read_bytes()) == '988af5dc815b791f283abeef804b52c136be1671e83d421afeaff184e77651f8'
    evidence = {
        'status': 'Scanned', 'native_green': 'pending', 'core_sha256': CORE,
        'historical_red_sha256': digest(historical.read_bytes()),
        'historical_original_support_sha256': digest(original_support.encode()),
        'historical_stress_support_sha256': digest(stress['lab/Support.j']),
        'corrected_support_sha256': digest(source['lab/Support.j']),
        'source_before_sha256': hashes(source),
        'source_after_sha256': hashes(source),
        'historical_stress_manifest_sha256': digest((STRESS / 'manifest.json').read_bytes()),
        'historical_e29_manifest_sha256': digest((E29 / 'manifest.json').read_bytes()),
        'checks': ['historical logger identical except retained prefill',
                   'stress differs only Config and corrected Support',
                   'all original maintained E29 assertion/record calls retained',
                   'no source core or maintained Environment mutation']}
    report_files = {
        REPORT / 'logger.patch': patch(original_support, support, 'Support.j'),
        REPORT / 'stress.patch': patch(old_support, a['lab/Support.j'].decode(), 'stress-Support.j'),
        REPORT / 'e29.patch': patch(env_before, env_after, 'frozen-Environment.j')}
    files = {}
    manifests = []
    for run, dest, output, baseline, selection in (
            (RUN_A, DEST_A, a, stress, 'M45'), (RUN_B, DEST_B, b, source, 'E29')):
        recipe = dict(old_manifest['compiler_import_recipe'], run_id=run)
        manifest = {
            'run_id': run, 'selection': selection, 'status': 'Scanned',
            'input_path': str(dest), 'core_sha256': CORE,
            'changed_vs_baseline': sorted(n for n in output if output[n] != baseline[n]),
            'baseline': str(STRESS if selection == 'M45' else SOURCE),
            'source_sha256': hashes(baseline), 'input_sha256': hashes(output),
            'fixture_baseline': str(E29) if selection == 'E29' else None,
            'fixture_environment_sha256': digest(e29['lab/Environment.j']) if selection == 'E29' else None,
            'preparation_script_sha256': digest(Path(__file__).read_bytes()),
            'compiler_import_recipe': recipe,
            'preflight': old_manifest['preflight'] if selection == 'M45' else {
                'transfer_stage': 6, 'original_transfer_assertions_stage': 7,
                'transfer_observation_stages': [6, 7, 8, 9, 10],
                'withdrawal_end_stage': 10, 'original_withdrawal_assertions_stage': 11,
                'withdrawal_observation_stages': list(range(11, 20)),
                'termination_stage': 15, 'restoration_stage': 19,
                'original_assertion_interval_seconds': .25},
            'limitations': ['Native GREEN pending; no compiler or game executed here.',
                            'Full synchronous cumulative snapshots still have cumulative total work.',
                            'OBS and invalid readiness never establish PASS or a latency cause.',
                            'Core reconciles on its visit; no simultaneous-visit assumption.',
                            'One authorized control per input; no automatic variants or production approval.']}
        for name, data in output.items():
            files[dest / name] = data
        files[dest / 'manifest.json'] = build.json_bytes(manifest)
        manifests.append({'run_id': run, 'path': str(dest / 'manifest.json'),
                          'sha256': digest(files[dest / 'manifest.json']),
                          'input_sha256': hashes(output)})
    evidence['snapshots'] = manifests
    report_files[REPORT / 'preparation.json'] = build.json_bytes(evidence)
    files.update(report_files)
    inputs = [Path(__file__), PROJECT / 'tools/build.py',
              PROJECT / 'reports/cycle2/prepare-m45-stress.py', historical,
              STRESS / 'manifest.json', E29 / 'manifest.json']
    inputs += [root / name for root, content in ((SOURCE, source), (STRESS, stress), (E29, e29)) for name in content]
    # ALL output paths are checked before the first artifact write; no merging.
    build.guard([DEST_A, DEST_B, *files], inputs)
    DEST_A.mkdir()
    DEST_B.mkdir()
    for path, data in files.items():
        build.write_new(path, data)
    for path, data in files.items():
        assert path.read_bytes() == data, 'readback mismatch: ' + str(path)
    assert tree(SOURCE) == source and tree(STRESS) == stress and tree(E29) == e29
    assert digest((SOURCE / 'Missiles.j').read_bytes()) == CORE
    print(json.dumps({'status': 'Scanned', 'native_green': 'pending',
                      'core_sha256': CORE, 'source_unchanged': True,
                      'readback_verified': True, 'snapshots': manifests}, sort_keys=True))


if __name__ == '__main__':
    prepare()
