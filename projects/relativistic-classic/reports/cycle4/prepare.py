"""Private exclusive recipe: freeze ONLY L35's timeout control and one full47 input.

Execute once after source readback and the single tooling test run:
python3 -B projects/relativistic-classic/reports/cycle4/prepare.py
Never compiles, launches, observes games, modifies maintained source or overwrites.
"""
from pathlib import Path
import difflib
import importlib.util
import json
import shlex

PROJECT = Path(__file__).resolve().parents[2]
REPORT = Path(__file__).resolve().parent
SOURCE = PROJECT / 'src'
OLD = PROJECT / 'build/inputs-diag3-logger-stress-20261019-01/lab/Environment.j'
RUNS = ('diag4-e29-timeout-20261019-01', 'fixed-20261019-03')
PROFILE_LOGS = Path('/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx/drive_c/WarcraftIII/CustomMapData/Logs')
CORE = 'adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6'
LOGGER = '564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d'
TEST_COMMAND = 'python3 -B -m unittest discover -s projects/relativistic-classic/tests -v'


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


build = load('classic_build', PROJECT / 'tools/build.py')
previous = load('previous_recipe', PROJECT / 'reports/cycle2/prepare-m45-stress.py')
digest = build.digest
replace_once = previous.replace_once


def tree(root):
    assert all(not p.is_symlink() for p in (root, *root.parents, *root.rglob('*')))
    return {p.relative_to(root).as_posix(): p.read_bytes()
            for p in sorted(root.rglob('*.j'))}


def hashes(files):
    return {name: digest(data) for name, data in files.items()}


def patch(before, after, label):
    return ''.join(difflib.unified_diff(before.splitlines(True), after.splitlines(True),
                                       fromfile=label + '.before', tofile=label + '.after')).encode()


def function(text, name):
    # Only inspection; no native execution or private core inspection.
    marker = 'function ' + name + ' '
    start = text.rindex('\n', 0, text.index(marker)) + 1
    end = text.index('    endfunction\n', start) + len('    endfunction\n')
    return text[start:end]


def preserved(text, old):
    start = function(text, 'RM_EnvironmentStart')
    prefix = start.split('        else\n            call PanCameraToTimed(-2000.', 1)[0]
    step = function(text, 'RM_EnvironmentStep')
    final = step[step.index('        if RM_STAGE == RM_LIMIT then\n'):]
    if old:
        final = final.split('            else\n                if sightReady then', 1)[0]
        final += '            endif\n        endif\n    endfunction\n'
    return {
        'probe_alliances': function(text, 'ProbeAlliances'),
        'callbacks': text[text.index('    struct LabEnvironmentMissile '):text.index('    endstruct\n') + len('    endstruct\n')],
        'E27_E28_start': prefix,
        'common_start_launch': '        set RM_M[1] = m\n        call m.launch()\n',
        'E27_E28_final': final,
        'E46_and_tile_helpers': text[text.index('    private function TileX '):]}


def compiler(run, dest):
    order = ['lab/Config.j', 'lab/Support.j', 'lab/Lifecycle.j', 'lab/Motion.j',
             'lab/Contact.j', 'lab/Environment.j', 'lab/Load.j', 'lab/Runner.j']
    wc3 = '/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3'
    argv = [wc3, 'python', '-B', str(PROJECT / 'tools/build.py'), 'build',
            '--wc3', wc3, '--base', str(PROJECT / 'baseline/original.w3x'),
            '--timer-utils', str(dest / 'libraries/TimerUtils.j'),
            '--world-bounds', str(dest / 'libraries/WorldBounds.j'),
            '--dummy-recycler', str(dest / 'libraries/DummyRecycler.j'),
            '--core', str(dest / 'Missiles.j'), '--bootstrap', str(dest / 'MapMain.j')]
    for name in order:
        argv += ['--harness', str(dest / name)]
    argv += ['--entry', 'LabRun', '--output-dir', str(PROJECT / 'build'), '--run-id', run]
    return {'timer_utils': 'libraries/TimerUtils.j', 'world_bounds': 'libraries/WorldBounds.j',
            'dummy_recycler': 'libraries/DummyRecycler.j', 'core': 'Missiles.j',
            'harness_order': order, 'bootstrap': 'MapMain.j', 'entry': 'LabRun',
            'run_id': run, 'argv': argv, 'command': 'PYTHONDONTWRITEBYTECODE=1 ' + shlex.join(argv),
            'execution': 'NOT RUN; parent owns compiler/pJASS/archive checks and native evidence'}


def prepare():
    source = tree(SOURCE)
    assert len(source) == 13
    assert digest(source['Missiles.j']) == CORE
    assert digest(source['lab/Support.j']) == LOGGER
    baseline = json.loads((PROJECT / 'reports/cycle3/preparation.json').read_bytes())['source_after_sha256']
    before = dict(source)
    before['lab/Environment.j'] = OLD.read_bytes()
    assert hashes(before) == baseline, 'unrelated source change or wrong original fixture'
    old_env = before['lab/Environment.j'].decode()
    env = source['lab/Environment.j'].decode()
    old_parts, new_parts = preserved(old_env, True), preserved(env, False)
    assert old_parts == new_parts, 'non-E29 behavior changed'
    assert new_parts['common_start_launch'] in env
    original_calls = [line.strip() for line in old_env.splitlines()
                      if any(c in line for c in ('call RM_Check(', 'call RM_Equal(', 'call RM_Near(', 'call RM_Record('))]
    for line in original_calls:
        assert line in env, 'original condition/name/detail changed: ' + line
    transfer_before = function(env, 'ReferenceTransferReady')
    assert transfer_before.count('return ') == 1 and 'RM_M[' not in transfer_before
    transfer_after = transfer_before[:transfer_before.index('        return ')] + '        return false\n    endfunction\n'
    injected = replace_once(env, transfer_before, transfer_after)
    assert replace_once(injected, transfer_after, transfer_before) == env
    # Confirm ALL normal native gate expressions are independent of missile probes.
    gates = function(env, 'ReferenceReady') + transfer_before
    assert 'RM_M[' not in gates and ', 0., Player(' not in gates
    assert 'VISION_WAIT = 2.0' in env and 'set RM_LIMIT = 160' in env

    streams = {key: (REPORT / ('tooling-tests.' + suffix)).read_bytes()
               for key, suffix in [('stdout', 'stdout.txt'), ('stderr', 'stderr.txt'), ('exit', 'exit.txt')]}
    assert streams['exit'] == b'0\n' and streams['stdout'] == b''
    assert b'Ran 39 tests in ' in streams['stderr'] and streams['stderr'].endswith(b'\nOK\n')
    tests = {'command': TEST_COMMAND, 'runs': 1, 'timeout_seconds': 30,
             'exit_code': 0, 'stdout': streams['stdout'].decode(), 'stderr': streams['stderr'].decode(),
             'files': {k: 'tooling-tests.' + suffix for k, suffix in
                       [('stdout', 'stdout.txt'), ('stderr', 'stderr.txt'), ('exit', 'exit.txt')]},
             'sha256': hashes(streams), 'scope': '39 existing Python tooling tests ONLY; not game proof'}
    raw_log = PROJECT / 'reports/RM28-diag3-e29-transfer-20261019-01.txt'
    assert digest(raw_log.read_bytes()) == '2c2bd7cbe38dd5c1d425d8a9432222ce6d9b48266a99bbdd30eb03fc31e30271'
    files = {}
    records = []
    guards = []
    for run, selection in zip(RUNS, ('E29', 'all')):
        dest = PROJECT / ('build/inputs-' + run)
        # Check profile ID collision as well as project inputs, outputs and evidence.
        collision_paths = [dest, PROJECT / ('build/' + run), PROJECT / ('reports/RM28-' + run + '.txt'),
                           PROJECT / ('reports/lab-' + run + '.json'), PROFILE_LOGS / ('RM28-' + run + '.txt')]
        for p in collision_paths:
            assert not p.exists() and not p.is_symlink(), 'run ID collision: ' + str(p)
        guards += [dest]
        output = dict(source)
        config = replace_once(output['lab/Config.j'].decode(), 'RM_RUN_ID = "UNCONFIGURED"', 'RM_RUN_ID = "' + run + '"')
        if selection == 'E29':
            config = replace_once(config, 'RM_SELECT = "all"', 'RM_SELECT = "E29"')
            output['lab/Environment.j'] = injected.encode()
        output['lab/Config.j'] = config.encode()
        changed = sorted(n for n in output if output[n] != source[n])
        assert changed == (['lab/Config.j', 'lab/Environment.j'] if selection == 'E29' else ['lab/Config.j'])
        transform = None if selection == 'all' else {
            'function': 'private ReferenceTransferReady', 'matches': 1,
            'old_text': transfer_before, 'new_text': transfer_after,
            'old_sha256': digest(transfer_before.encode()), 'new_sha256': digest(transfer_after.encode()),
            'patch_sha256': digest(patch(env, injected, 'timeout-Environment.j')),
            'scope': 'ONLY transfer raw expected-state signal forced pending; no initial readiness or actual assertion injection'}
        manifest = {'run_id': run, 'selection': selection, 'status': 'Scanned', 'native_outcome': 'pending',
                    'input_path': str(dest), 'core_sha256': CORE, 'logger_sha256': LOGGER,
                    'source_before_sha256': hashes(before), 'source_after_sha256': hashes(source),
                    'input_sha256': hashes(output), 'changed_vs_src': changed,
                    'preparation_script_sha256': digest(Path(__file__).read_bytes()),
                    'compiler_import_recipe': compiler(run, dest), 'transformation': transform,
                    'guard': {'seconds': 2.0, 'runner_checkpoint_seconds': .25, 'transfer_phase': 8,
                              'timeout_checkpoint': 'first checkpoint with elapsed>=2.0 while raw predicate unready',
                              'abort_cleanup_phase': 13, 'abort_cleanup_seconds': 2.0,
                              'case_watchdog_checkpoints': 160, 'motion_intervals': 2, 'motion_speed': 1600},
                    'expected': {'cases': 1 if selection == 'E29' else 47,
                                 'reader_exit': 1 if selection == 'E29' else 'pending actual evidence; 0 only if no FAIL',
                                 'required_timeout': 'vision-reference-timeout phase=8 wait=native-reference' if selection == 'E29' else None,
                                 'cleanup_pass_names': ['vision-cleanup', 'vision-fallback-cleanup', 'vision-remove-once',
                                                       'vision-fallback-remove-once', 'vision-alliances-restored',
                                                       'vision-fog-flags-restored', 'vision-idle-no-extra-remove',
                                                       'vision-fallback-idle-no-extra-remove', 'idle-no-extra-remove'],
                                 'multiplayer': 'SKIP, never acceptance', 'complete': 'required, no hang',
                                 'negative_pass_count_if_all_prior_eligible': 28 if selection == 'E29' else None,
                                 'negative_fail_count_if_only_injected_timeout': 1 if selection == 'E29' else None},
                    'limits': ['No compiler/game executed by preparation; actual outcomes pending.',
                               'New guard had no prior seam; historical native .25s RED is not a fabricated timeout RED.',
                               'Negative snapshot tests response to pending signal, not engine physics.',
                               'Full47 uses uninjected fixture, unchanged 47 IDs and L99-last Runner.',
                               'No extra variants, core/logger edits, acceptance approval or automatic rounds.']}
        for name, data in output.items():
            files[dest / name] = data
        files[dest / 'manifest.json'] = build.json_bytes(manifest)
        records.append({'run_id': run, 'selection': selection, 'manifest': str(dest / 'manifest.json'),
                        'manifest_sha256': digest(files[dest / 'manifest.json']),
                        'input_sha256': hashes(output), 'compiler_command': manifest['compiler_import_recipe']['command']})
    preservation = {'scope': 'Independent byte preservation inspection, not a native differential execution',
                    'baseline_environment': str(OLD), 'baseline_sha256': digest(before['lab/Environment.j']),
                    'parts': {name: {'before_sha256': digest(old_parts[name].encode()),
                                     'after_sha256': digest(new_parts[name].encode()), 'identical': True}
                              for name in old_parts},
                    'original_assertion_and_record_calls_retained': original_calls,
                    'unrelated_sources_identical': sorted(n for n in source if n != 'lab/Environment.j'),
                    'non_e29_patch': 'non-e29.patch', 'non_e29_patch_empty': True}
    canonical_before = '\n'.join(old_parts.values())
    canonical_after = '\n'.join(new_parts.values())
    files[REPORT / 'non-e29.patch'] = patch(canonical_before, canonical_after, 'non-E29')
    assert files[REPORT / 'non-e29.patch'] == b''
    files[REPORT / 'preservation.json'] = build.json_bytes(preservation)
    files[REPORT / 'environment.patch'] = patch(old_env, env, 'Environment.j')
    files[REPORT / 'timeout-injection.patch'] = patch(env, injected, 'timeout-Environment.j')
    additions = sum(line.startswith('+') and not line.startswith('+++') for line in files[REPORT / 'environment.patch'].decode().splitlines())
    deletions = sum(line.startswith('-') and not line.startswith('---') for line in files[REPORT / 'environment.patch'].decode().splitlines())
    evidence = {'status': 'Scanned', 'spec_scope': ['S3', 'S4', 'S8', 'S9', 'S10'],
                'S5_S7': 'existing tool/profile provenance preserved; compiler/native commands parent-owned',
                'native_outcomes': 'pending; not GREEN or final candidate acceptance',
                'core_sha256': CORE, 'logger_sha256': LOGGER,
                'source_before_sha256': hashes(before), 'source_after_sha256': hashes(source),
                'maintained_source_changes': ['lab/Environment.j'],
                'patchstat_environment': {'additions': additions, 'deletions': deletions},
                'historical_red': {'path': str(raw_log), 'sha256': digest(raw_log.read_bytes()),
                                   'actual': 'COMPLETE1/60/3/1 reader1; raw and missile old owners retain vision at .25s; both settle by .5s in that run only'},
                'test_first_exception': 'New bounded guard and predicate seam did not exist before; no prior negative native run. Parent executes one actual injected timeout then exactly one full47.',
                'tooling_tests': tests, 'snapshots': records,
                'preservation_report': 'preservation.json', 'risk': 'item3 acceptance/test-oracle contract; independent fixture verifier after native checks',
                'scratch_created': [], 'native_authority': 'not invoked; no approval inferred'}
    files[REPORT / 'preparation.json'] = build.json_bytes(evidence)
    files[REPORT / 'PREPARATION.md'] = preparation_markdown(records, additions, deletions, tests, evidence).encode()
    inputs = [Path(__file__), PROJECT / 'tools/build.py', PROJECT / 'reports/cycle2/prepare-m45-stress.py',
              PROJECT / 'reports/cycle3/preparation.json', OLD, raw_log,
              *[SOURCE / n for n in source],
              *[REPORT / ('tooling-tests.' + suffix) for suffix in ('stdout.txt', 'stderr.txt', 'exit.txt')]]
    assert len({str(p).casefold() for p in files}) == len(files), 'case-insensitive destination overlap'
    # Existing shared helper preflights EVERY destination before the first write.
    build.guard([*guards, *files], inputs)
    for dest in guards:
        dest.mkdir()
    for path, data in files.items():
        build.write_new(path, data)
    for path, data in files.items():
        assert path.read_bytes() == data, 'readback mismatch: ' + str(path)
    assert tree(SOURCE) == source
    assert OLD.read_bytes() == before['lab/Environment.j']
    print(json.dumps({'status': 'Scanned', 'native_outcomes': 'pending', 'readback_verified': True,
                      'core_sha256': CORE, 'logger_sha256': LOGGER,
                      'source_environment_sha256': digest(source['lab/Environment.j']),
                      'environment_patchstat': {'additions': additions, 'deletions': deletions},
                      'snapshots': records}, sort_keys=True))


def preparation_markdown(records, additions, deletions, tests, evidence):
    table = '\n'.join('| `' + r['run_id'] + '` | `' + r['selection'] + '` | `' + r['manifest_sha256'] + '` |' for r in records)
    commands = '\n\n'.join('```sh\n' + r['compiler_command'] + '\n```' for r in records)
    return f'''# Cycle4 prepared — native timeout and full47 outcomes pending

**Strongest current status: Scanned, fixture/input scope only.** L35 authorizes
only E29 native-update-aware fixture correction, one controlled timeout test and
ONE full47 acceptance run. S3/S4/S8/S9/S10 implementation/preparation is covered;
S8 native acceptance and linked S5–S7 compiler/profile evidence remain parent-owned.
No game, compiler, native authority, GUI input, commit or provisional acceptance.

## Parent quick path

1. Inspect environment.patch, preservation.json and the empty non-e29.patch.
2. Compile ONLY the two frozen manifests below using their explicit recipes.
3. Run the E29 timeout control once, preserving actual launch time, unique public
   native log, exact reader stdout/stderr/exit and COMPLETE. Initial invalid
   readiness cannot establish a successful negative test.
4. With eligible earlier phases, require ONE `vision-reference-timeout` FAIL at
   phase8, wait=native-reference, deadline=2.000, elapsed at the first checkpoint
   at/after2.0s since raw transfer was armed. Guard is checked every.25 simulated
   seconds; this is a safety bound, not universal engine cadence. Expect reader1,
   28PASS/1FAIL/1multiplayerSKIP plus variable OBS, including original cleanup,
   per-instance onRemove and restoration/idle PASS. Missing proof is not success.
5. Run exactly ONE full47 with the normal uninjected fixture, all IDs unchanged
   and L99 last. Keep candidate blocked until actual results are reconciled.
   Any new failure/missing proof is one human decision, not an automatic rerun.
6. Parent obtains ONE independent item3 fixture verifier after native checks.

| Run | Selection | Manifest SHA-256 |
|---|---|---|
{table}

Both `build/inputs-<run>/manifest.json` files hash all13 JASS inputs, Config IDs,
maintained source-before/source-after bytes, core/logger and exact recipe. No
snapshot overwrote an existing file; no extra native variant was prepared.
The recipe checks both IDs against project build/log/report destinations and
the identified profile log directory before creating any output.

## Oracle and bounds

Two raw circles mirror original geometry/radii/owners at +3000Y, with original
classic visible,true,false parameters, runtime full-circle WorldBounds and
initial-hidden eligibility. Initial positive reveal/isolation is required.
Native-only reference predicates never contain actual missile visibility.
After raw expected state settles, unchanged actual assertions run immediately;
actual divergence FAILs rather than extending the wait. Initial actual-visibility
SKIPs and separate multiplayer SKIP remain. No private core state is inspected.

Phases1/2/3 gate initial/shrink-zero/negative-restored, phases4/5 retain EXACTLY
two .25 runner movement intervals at1600 and stop before waiting, phase6 gates
stopped movement, phase7 waits on public dummy owner reconciliation before raw
transfer, phase8 gates raw transfer then runs original actual transfer conditions.
Phase9 waits for public neutral owners after actual withdrawal before raw Stop;
phase10 gates withdrawal and terminates, phase11 gates cleanup, phase12 checks
restoration and no extra per-instance remove events. Original Runner adds its
half-second idle check. Cleanup reference state is already withdrawn in the
normal flow; it is checked again after actual termination, not inferred from
private handles or explored fog.

Every gated transition has a2.0 simulated-second bound. Timeout records ONE
named `vision-reference-timeout` per failed transition, with phase/wait/deadline/
elapsed detail. It uses existing RM_Cleanup for public missile/source disposal,
then Stop+Destroy of every owned reference and phase13's separate bounded abort
cleanup wait. Original cleanup visibility conditions execute before restoring
fog/mask/alliance values. If abort cleanup also times out, it fails explicitly
and restores immediately without another wait. A160-checkpoint case watchdog
(40 simulated seconds) emits `vision-case-watchdog` and forces restoration too.
No unbounded loop, new timer, synthetic PASS or silently skipped original rule.
Unreached rules after timeout are explicitly OBS/incomplete, not acceptance.
Saved native flags and all incoming probe alliance edges are checked restored;
onRemove must equal1 for EACH original instance, then stay unchanged while idle.

OBS includes phase, source, RM_CLOCK, elapsed/deadline, raw and actual states;
motion-stopped logs public/dummy position. Raw mutations occur later-or-equal to
actual requests, with public-owner checks before transfer, stop before raw move,
and neutral observation after withdrawal. There is no exact simultaneity claim.

## Controlled pending transfer, not engine physics

`timeout-injection.patch` is the ONLY diagnostic injection. Exact old/new private
`ReferenceTransferReady` function text and SHA-256 are in its manifest. The one
return is replaced by `false` only in the frozen E29 input. Actual visibility
assertions, initial readiness, global natives, logger/core and maintained source
are uninjected. A normal transfer may settle, but the REAL handler must still
abort at phase8's bound. Abort cleanup has at most its own2s reference wait,
then.25s internal idle and.5s unchanged runner idle before COMPLETE (scheduled
checkpoints; no wall-time guarantee). If native cleanup clears at its first.25s
checkpoint, COMPLETE follows1.0 simulated second after the timeout. A cleanup
failure must remain loud, restore values and advance, never hang.

This new guard had no previous seam or native test. No timeout RED was invented.
Historical actual native RED is immutable cycle3 COMPLETE1/60/3/1, reader1:
raw and both missile transfers retained old-owner visibility at.25s and settled
by.5s in that run. It disproves a Missiles-specific .25s interpretation, NOT a
universal .5s cadence or the cause of every earlier withdrawal failure. The old
native baseline was read only, not rerun. Negative/full47 native evidence is
pending; Python/static inspection is not engine GREEN.

## Preservation and actual tooling evidence

Only maintained Environment changed: +{additions}/-{deletions} against the exact
pre-task Environment. `environment.patch` contains the full independent patch.
`preservation.json` separately compares callback bodies, E27/E28 start/final
branches, shared original launch, ProbeAlliances and the entire tileset tail;
`non-e29.patch` is empty. Every original assertion/record call survives with its
exact condition/name/detail. All12 other maintained source files match the
cycle3 source hashes. No native differential run of sibling cases was authorized;
byte preservation is structural evidence only.

Core SHA-256: `{CORE}`

Verified logger SHA-256: `{LOGGER}`

Environment before: `{evidence['source_before_sha256']['lab/Environment.j']}`

Environment after: `{evidence['source_after_sha256']['lab/Environment.j']}`

Exactly ONE foreground run (30s tool timeout):

```sh
{TEST_COMMAND}
```

Observed exit0, stdout exactly empty. Exact stderr is in tooling-tests.stderr.txt
and embedded verbatim in preparation.json, alongside stdout and exit streams:

```text
{tests['stderr']}```

These39 existing tests establish tooling/catalog behavior, not missile physics.
No new Python physics/static-text GREEN was manufactured. The historical native
RED remains pre-fix evidence; native GREEN/PRESERVE belongs to the parent runs.
Preparation reuses existing guard/write_new/digest/json_bytes and exact-once
transform helpers, preflights all destinations/no symlinks/overlap, writes each
new output exclusively and reads every byte back. Source and old artifacts
remain unchanged by freezing; no test scratch/cache is retained in the worktree.

## Exact compiler recipes — NOT executed here

{commands}

Use actual game launch time for public read_logs.py --not-before; never accept
an old/profile-mismatched log. Public reader0 with multiplayer SKIP remains
inconclusive rather than full synchronization acceptance. Parent owns native
parameters/launch commands, log capture and exact exits. No default research,
extra controls, automatic rounds or background commands by this worker.

## Risks and evidence boundaries

- WARNING: item3 acceptance/test-oracle contract. Independent translated native
  references are conservative readiness signals, not missile physics proof.
  Independent fixture verification follows the actual two native checks.
- Compiler/pJASS/archive/lowering and runtime eligibility are still pending.
- Multiplayer, editor-save, exhaustion and arbitrary integration remain unproved.
  Existing retained verifier scratch `/tmp/rc-item3-XNICaO` was not accessed.
- No new scratch was created; no core/logger or old log/map/input was altered.

## Key Learnings
1. Native transfer latency invalidated the historical quarter-second oracle.
2. Reference gates must never wait for actual missile visibility.
3. Stopping motion first prevents cache waits from finishing missiles.
4. Public owner reconciliation prevents artificially earlier raw deadlines.
5. Timeout cleanup requires separately bounded restoration and completion.
'''


if __name__ == '__main__':
    prepare()
