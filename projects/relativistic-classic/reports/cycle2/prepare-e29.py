"""Prepare one exclusive E29 diagnostic snapshot; no compiler or game execution.

Run from any directory with python3 -B. Existing destinations are never reused.
The maintained src tree is read-only. Only Config.j and Environment.j change.
"""
from pathlib import Path
import hashlib
import json

PROJECT = Path(__file__).resolve().parents[2]
SOURCE = PROJECT / 'src'
DEST = PROJECT / 'build/inputs-diag2-e29-20261019-01'
RUN_ID = 'diag2-e29-20261019-01'
CORE_HASH = 'adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def replace_once(text, old, new):
    assert text.count(old) == 1, 'transformation must match exactly once: ' + old
    return text.replace(old, new, 1)


def prepare():
    # Check exclusivity and path redirection before any snapshot writes.
    assert not DEST.exists() and not DEST.is_symlink(), 'destination already exists'
    for path in (SOURCE, DEST.parent, DEST.parent.parent):
        assert not path.is_symlink(), 'symlink root rejected'
    paths = sorted(SOURCE.rglob('*.j'))
    assert paths and all(not p.is_symlink() for p in SOURCE.rglob('*')), 'symlink source rejected'
    original = {p.relative_to(SOURCE).as_posix(): p.read_bytes() for p in paths}
    assert digest(original['Missiles.j']) == CORE_HASH, 'fixed02 core hash mismatch'
    assert 'CreateFogModifierRadius(p, FOG_OF_WAR_VISIBLE, x, y, sight, true, false)' in original['Missiles.j'].decode()
    output = dict(original)
    config = output['lab/Config.j'].decode()
    config = replace_once(config, 'RM_RUN_ID = "UNCONFIGURED"', 'RM_RUN_ID = "' + RUN_ID + '"')
    config = replace_once(config, 'RM_SELECT = "all"', 'RM_SELECT = "E29"')
    output['lab/Config.j'] = config.encode()
    env = output['lab/Environment.j'].decode()
    env = replace_once(env, '        private boolean sightReady = false', '''        private fogmodifier diagnosticFog = null
        private boolean diagnosticBounds = false
        private boolean diagnosticHidden = false
        private boolean diagnosticReady = false
        private real diagnosticWithdrawalClock = 0.
        private boolean sightReady = false''')
    env = replace_once(env, '    // Save every incoming shared-vision edge to the two probe players.', '''    // Diagnostic-only helpers: explicit conversion, no invented native B2S.
    private function DiagnosticBoolean takes boolean value returns string
        if value then
            return "true"
        endif
        return "false"
    endfunction

    private function DiagnosticInBounds takes real x, real y returns boolean
        return x >= WorldBounds.minX and x <= WorldBounds.maxX and y >= WorldBounds.minY and y <= WorldBounds.maxY
    endfunction

    private function DiagnosticStop takes nothing returns nothing
        if diagnosticFog != null then
            call FogModifierStop(diagnosticFog)
            call DestroyFogModifier(diagnosticFog)
            set diagnosticFog = null
        endif
    endfunction

    private function DiagnosticSample takes nothing returns nothing
        call RM_Record("OBS", "diag2-withdrawal-sample", "stage=" + I2S(RM_STAGE) + " scheduledSince7=" + R2S((RM_STAGE-7)*.25) + " clock=" + R2S(TimerGetElapsed(RM_CLOCK)) + " clockSince7=" + R2S(TimerGetElapsed(RM_CLOCK)-diagnosticWithdrawalClock) + " rawReady=" + DiagnosticBoolean(diagnosticReady) + " rawP2=" + DiagnosticBoolean(IsVisibleToPlayer(100., 3000., Player(2))) + " primaryOldP2=" + DiagnosticBoolean(IsVisibleToPlayer(-800., 0., Player(2))) + " fallbackOldP1=" + DiagnosticBoolean(IsVisibleToPlayer(2400., 0., Player(1))))
        call RM_Record("OBS", "diag2-public-state", "stage=" + I2S(RM_STAGE) + " m1OwnerNull=" + DiagnosticBoolean(RM_M[1].owner == null) + " source1Type=" + I2S(GetUnitTypeId(RM_M[1].source)) + " source2Type=" + I2S(GetUnitTypeId(RM_M[2].source)) + " dummy1Owner=" + I2S(GetPlayerId(GetOwningPlayer(RM_DUMMY[1]))) + " dummy1XY=" + R2S(GetUnitX(RM_DUMMY[1])) + "," + R2S(GetUnitY(RM_DUMMY[1])) + " dummy2Owner=" + I2S(GetPlayerId(GetOwningPlayer(RM_DUMMY[2]))) + " dummy2XY=" + R2S(GetUnitX(RM_DUMMY[2])) + "," + R2S(GetUnitY(RM_DUMMY[2])))
    endfunction

    // Save every incoming shared-vision edge to the two probe players.''')
    env = replace_once(env, '            set RM_LIMIT = 12', '''            set RM_LIMIT = 12
            if RM_CASE == 29 then
                set RM_LIMIT = 16
                // Isolated control: no unit, source, missile or extra timer.
                set diagnosticBounds = DiagnosticInBounds(0., 3000.) and DiagnosticInBounds(100., 3000.)
                set diagnosticHidden = not IsVisibleToPlayer(100., 3000., Player(2))
                set diagnosticReady = diagnosticBounds and diagnosticHidden
                call RM_Record("OBS", "diag2-raw-initial-readiness", "bounds=" + DiagnosticBoolean(diagnosticBounds) + " hidden=" + DiagnosticBoolean(diagnosticHidden) + " center=0,3000 radius=200 probe=100,3000 owner=2 visible,true,false")
                if diagnosticReady then
                    set diagnosticFog = CreateFogModifierRadius(Player(2), FOG_OF_WAR_VISIBLE, 0., 3000., 200., true, false)
                    call FogModifierStart(diagnosticFog)
                endif
            endif''')
    env = replace_once(env, '        if RM_CASE == 29 and RM_STAGE == 1 then', '''        if RM_CASE == 29 and RM_STAGE == 1 then
            if diagnosticReady then
                set diagnosticReady = IsVisibleToPlayer(100., 3000., Player(2))
                call RM_Check(diagnosticReady, "diag2-raw-reveals", "initially hidden in-bounds raw probe100,3000 owner2 radius200")
            else
                call RM_Record("SKIP", "diag2-raw-reveals", "raw control ineligible: bounds or initial hidden readiness invalid")
            endif''')
    env = replace_once(env, '            set RM_M[1].owner = null\n            call RemoveUnit(RM_U)', '''            // Cache public handles while alive; post-termination dummy samples
            // describe these same handles (including recycler movement), not private state.
            set RM_DUMMY[1] = RM_M[1].dummy
            set RM_DUMMY[2] = RM_M[2].dummy
            set diagnosticWithdrawalClock = TimerGetElapsed(RM_CLOCK)
            call DiagnosticStop()
            set RM_M[1].owner = null
            call RemoveUnit(RM_U)''')
    env = replace_once(env, '''            call RM_M[1].terminate()
            call RM_M[2].terminate()
        endif
        if RM_STAGE == RM_LIMIT then''', '''        endif
        if RM_CASE == 29 and RM_STAGE >= 8 and RM_STAGE <= 16 then
            call DiagnosticSample()
            if RM_STAGE == 12 then
                // Additional checkpoint only: original stage8 assertions stay intact.
                if sightReady and fallbackReady then
                    call RM_Check(not IsVisibleToPlayer(-800., 0., Player(2)) and not IsVisibleToPlayer(2400., 0., Player(1)), "diag2-both-withdrawn-at-1.25s", "both previous effective owners lose reveal before termination; scheduled1.25s after stage7")
                else
                    call RM_Record("SKIP", "diag2-both-withdrawn-at-1.25s", "missile probes not initially eligible; no withdrawal success claimed")
                endif
                if not diagnosticReady then
                    call RM_Record("SKIP", "diag2-raw-withdrawal", "raw control not proven ready; samples are observations only")
                endif
                call RM_M[1].terminate()
                call RM_M[2].terminate()
            endif
        endif
        if RM_STAGE == RM_LIMIT then''')
    output['lab/Environment.j'] = env.encode()
    changed = [name for name in output if output[name] != original[name]]
    assert sorted(changed) == ['lab/Config.j', 'lab/Environment.j']
    # Preserve every original assertion/record line, including exact named failures.
    for line in original['lab/Environment.j'].decode().splitlines():
        if 'call RM_Check(' in line or 'call RM_Record(' in line or 'call RM_Equal(' in line:
            assert line in env, 'original assertion/record changed: ' + line
    manifest = {
        'run_id': RUN_ID, 'selection': 'E29', 'status': 'Scanned',
        'input_path': str(DEST), 'core_sha256': CORE_HASH,
        'changed_vs_src': sorted(changed),
        'source_sha256': {n: digest(b) for n, b in original.items()},
        'input_sha256': {n: digest(b) for n, b in output.items()},
        'preparation_script_sha256': digest(Path(__file__).read_bytes()),
        'assumptions': [
            'One isolated E29 execution; no compiler, game, latency cause or fix claimed.',
            'Runner ticks every .25s; scheduled stage12 minus stage7 is 1.25s; actual RM_CLOCK elapsed is recorded.',
            'Raw center/probe bounds and initial hidden state are runtime-gated before modifier creation.',
            'Raw control uses verified refreshVision signature and constants, not unit sight.',
            'Stage8 original checks remain at .25s; termination moves to end stage12; final cleanup stage16.',
            'Cached public dummy handles remain observable after termination; recycler changes are not missile-state claims.',
            'Post-termination public owner/source fields may be reset; no private missile state is read.',
            'OBS is not PASS; invalid readiness is never withdrawal success; candidate remains blocked.'
        ],
        'compiler_import_recipe': {
            'timer_utils': 'libraries/TimerUtils.j', 'world_bounds': 'libraries/WorldBounds.j',
            'dummy_recycler': 'libraries/DummyRecycler.j', 'core': 'Missiles.j',
            'harness_order': ['lab/Config.j', 'lab/Support.j', 'lab/Lifecycle.j', 'lab/Motion.j',
                              'lab/Contact.j', 'lab/Environment.j', 'lab/Load.j', 'lab/Runner.j'],
            'bootstrap': 'MapMain.j', 'entry': 'LabRun', 'run_id': RUN_ID
        }
    }
    # Existing exclusive-write helper preserves the project's no-overwrite invariant.
    import importlib.util
    spec = importlib.util.spec_from_file_location('classic_build', PROJECT / 'tools/build.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    module.guard([DEST], paths)
    DEST.mkdir()  # Atomic exclusivity claim; never merge or reuse a prior snapshot.
    for name, data in output.items():
        module.write_new(DEST / name, data)
    module.write_new(DEST / 'manifest.json', module.json_bytes(manifest))
    for name, data in output.items():
        assert (DEST / name).read_bytes() == data, 'snapshot readback mismatch'
        assert (SOURCE / name).read_bytes() == original[name], 'maintained source changed'
    print(json.dumps({'input_path': str(DEST), 'core_sha256': CORE_HASH,
                      'changed_vs_src': sorted(changed)}, sort_keys=True))


if __name__ == '__main__':
    prepare()
