"""Private evidence recipe: python3 -B projects/relativistic-classic/reports/cycle2/prepare-m45-stress.py.

Prepare one exclusive M45 log-volume snapshot; never compile or launch it.
Only frozen Config, Support and Motion differ. Maintained sources stay read-only.
"""
from pathlib import Path
import hashlib
import importlib.util
import json

PROJECT = Path(__file__).resolve().parents[2]
SOURCE = PROJECT / 'src'
DEST = PROJECT / 'build/inputs-diag2-m45-stress-20261019-01'
RUN_ID = 'diag2-m45-stress-20261019-01'
CORE_HASH = 'adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6'
PADDING = 700
BASE_CHECKS = 70
PROGRESS_CHECKS = 1
ARRAY_LIMIT = 8192


def digest(data):
    return hashlib.sha256(data).hexdigest()


def replace_once(text, old, new):
    assert text.count(old) == 1, 'transformation must match exactly once: ' + old
    return text.replace(old, new, 1)


def prepare():
    assert not DEST.exists() and not DEST.is_symlink(), 'destination already exists'
    assert all(not p.is_symlink() for p in (SOURCE, *SOURCE.parents)), 'symlink source root'
    tree = sorted(SOURCE.rglob('*'))
    assert tree and all(not p.is_symlink() for p in tree), 'symlink source rejected'
    paths = [p for p in tree if p.is_file()]
    assert paths and all(p.suffix == '.j' for p in paths), 'unexpected non-JASS source'
    original = {p.relative_to(SOURCE).as_posix(): p.read_bytes() for p in paths}
    assert digest(original['Missiles.j']) == CORE_HASH, 'fixed02 core hash mismatch'
    # Isolated M45: BEGIN + CASE + CHECKs + COMPLETE, no prior scenario rows.
    expected_checks = BASE_CHECKS + PADDING + PROGRESS_CHECKS
    expected_lines = expected_checks + 3
    assert PADDING == 700 and expected_lines <= ARRAY_LIMIT
    assert expected_checks < 2147483647 and expected_lines < 2147483647
    output = dict(original)

    config = output['lab/Config.j'].decode('utf-8')
    config = replace_once(config, 'RM_RUN_ID = "UNCONFIGURED"', 'RM_RUN_ID = "' + RUN_ID + '"')
    config = replace_once(config, 'RM_SELECT = "all"', 'RM_SELECT = "M45"')
    output['lab/Config.j'] = config.encode('utf-8')

    support = output['lab/Support.j'].decode('utf-8')
    support = replace_once(support, '''    function RM_Case takes string id returns nothing
        set current = id''', '''    function RM_Case takes string id returns nothing
        local integer padding = 1
        set current = id''')
    support = replace_once(support, '''        call RM_Log("CASE|" + id)
        call DisplayTimedTextToPlayer''', '''        call RM_Log("CASE|" + id)
        if id == "M45" then
            // Diagnostic OBS only: no missile state, assertions or per-row flush.
            // The next ordinary RM_Log persists this prefill with the same logger.
            loop
                exitwhen padding > 700
                set lines[lineCount] = "RM28|" + RM_RUN_ID + "|CHECK|" + current + "|OBS|diag2-log-padding-" + I2S(padding) + "|logger-volume-only"
                set lineCount = lineCount + 1
                set checks = checks + 1
                set padding = padding + 1
            endloop
        endif
        call DisplayTimedTextToPlayer''')
    output['lab/Support.j'] = support.encode('utf-8')

    motion = output['lab/Motion.j'].decode('utf-8')
    # All Motion edits are insertions; verify removal recovers the original bytes.
    insertions = []

    def insert_after(anchor, addition):
        nonlocal motion
        motion = replace_once(motion, anchor, anchor + addition)
        insertions.append(addition)

    insert_after('library LabMotion requires LabSupport\n', '''    globals
        private integer coordinateStartPhase = 0
    endglobals

    private function DiagnosticBoolean takes boolean value returns string
        if value then
            return "true"
        endif
        return "false"
    endfunction

''')
    insert_after('''        local real iz = RM_Ground(400., 600.)+250.
''', '''        set coordinateStartPhase = 1
''')
    insert_after('''        call RM_Near(m.z, oz, .01, "speed-preserves-current-z-independent")
''', '''        set coordinateStartPhase = 2
''')
    # Include adjacent context to avoid touching any sibling scenario's startup.
    motion = replace_once(motion, '''        set coordinateStartPhase = 2
        set m.speed = 0.
        call m.launch()
        call RM_Check(m.launched and not m.finished and not m.paused, "launched-public-flags", "public launch flags")
''', '''        set coordinateStartPhase = 2
        set m.speed = 0.
        set coordinateStartPhase = 3
        call m.launch()
        set coordinateStartPhase = 4
        call RM_Check(m.launched and not m.finished and not m.paused, "launched-public-flags", "public launch flags")
        set coordinateStartPhase = 5
''')
    insertions.extend(['        set coordinateStartPhase = 3\n',
                       '        set coordinateStartPhase = 4\n',
                       '        set coordinateStartPhase = 5\n'])
    checkpoint = '''            // Fresh runner timer thread; a saved phase alone is not an op-limit diagnosis.
            call RM_Record("OBS", "diag2-start-progress", "phase=" + I2S(coordinateStartPhase) + " periods=" + I2S(RM_PERIODS[1]) + " allocated=" + DiagnosticBoolean(m.allocated) + " launched=" + DiagnosticBoolean(m.launched) + " paused=" + DiagnosticBoolean(m.paused) + " finished=" + DiagnosticBoolean(m.finished))
'''
    motion = replace_once(motion, '''        // Split cold getter assertions across checkpoints, not one huge log thread.
        if RM_STAGE == 1 then
''', '''        // Split cold getter assertions across checkpoints, not one huge log thread.
        if RM_STAGE == 1 then
''' + checkpoint)
    insertions.append(checkpoint)
    restored = motion
    for addition in reversed(insertions):
        restored = replace_once(restored, addition, '')
    assert restored.encode('utf-8') == original['lab/Motion.j'], 'original Motion changed'
    output['lab/Motion.j'] = motion.encode('utf-8')
    changed = sorted(n for n in output if output[n] != original[n])
    assert changed == ['lab/Config.j', 'lab/Motion.j', 'lab/Support.j']

    manifest = {
        'run_id': RUN_ID, 'selection': 'M45', 'status': 'Scanned',
        'input_path': str(DEST), 'core_sha256': CORE_HASH,
        'changed_vs_src': changed,
        'source_sha256': {n: digest(b) for n, b in original.items()},
        'input_sha256': {n: digest(b) for n, b in output.items()},
        'preparation_script_sha256': digest(Path(__file__).read_bytes()),
        'preflight': {'padding_obs': PADDING, 'isolated_original_checks': BASE_CHECKS,
                      'progress_obs': PROGRESS_CHECKS, 'expected_checks_if_complete': expected_checks,
                      'expected_lines_if_complete': expected_lines, 'array_limit': ARRAY_LIMIT},
        'assumptions': [
            'Diagnostic only; candidate remains blocked. No compiler/game execution or cause/fix claimed.',
            'Isolated selection runs no prior missile scenarios; runner and other selection code are byte-identical.',
            'Exactly 700 synthetic harness OBS rows, not missile assertions; numbered 1 through 700.',
            'Padding increments existing lineCount/checks once per row; next ordinary RM_Log flushes it.',
            'Same cumulative logger, fixed02 core and original M45 assertions/equations/live condition.',
            'Phase2 means the speed-preserves-current-z-independent RM_Near returned; not proof of operation-limit exhaustion.',
            'Phase3 follows speedzero; phase4 follows launch; phase5 follows launched-public-flags RM_Check return.',
            'Only one stage1 OBS checkpoint on the fresh runner timer thread; no start logging added.',
            'Isolated unchanged-core M45 passing establishes context sensitivity, not logger causation.',
            'Expected counts assume every original check returns; native stress outcome remains pending.'
        ],
        'compiler_import_recipe': {
            'timer_utils': 'libraries/TimerUtils.j', 'world_bounds': 'libraries/WorldBounds.j',
            'dummy_recycler': 'libraries/DummyRecycler.j', 'core': 'Missiles.j',
            'harness_order': ['lab/Config.j', 'lab/Support.j', 'lab/Lifecycle.j', 'lab/Motion.j',
                              'lab/Contact.j', 'lab/Environment.j', 'lab/Load.j', 'lab/Runner.j'],
            'bootstrap': 'MapMain.j', 'entry': 'LabRun', 'run_id': RUN_ID
        }
    }
    # Reuse the existing exclusive-output guards/writer, including ancestor checks.
    spec = importlib.util.spec_from_file_location('classic_build', PROJECT / 'tools/build.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    outputs = [DEST / name for name in output] + [DEST / 'manifest.json']
    module.guard([DEST, *outputs], [*paths, Path(__file__)])
    DEST.mkdir()  # Atomic exclusivity claim: never merge with an earlier snapshot.
    for name, data in output.items():
        module.write_new(DEST / name, data)
    module.write_new(DEST / 'manifest.json', module.json_bytes(manifest))
    assert json.loads((DEST / 'manifest.json').read_bytes()) == manifest, 'manifest readback mismatch'
    assert sorted(p.relative_to(SOURCE).as_posix() for p in SOURCE.rglob('*') if p.is_file()) == sorted(original)
    for name, data in output.items():
        assert (DEST / name).read_bytes() == data, 'snapshot readback mismatch: ' + name
        assert (SOURCE / name).read_bytes() == original[name], 'maintained source changed: ' + name
    print(json.dumps({'input_path': str(DEST), 'core_sha256': CORE_HASH,
                      'changed_vs_src': changed, 'snapshot_jass_files': len(output),
                      'expected_checks_if_complete': expected_checks,
                      'expected_lines_if_complete': expected_lines,
                      'source_unchanged': True, 'readback_verified': True}, sort_keys=True))


if __name__ == '__main__':
    prepare()
