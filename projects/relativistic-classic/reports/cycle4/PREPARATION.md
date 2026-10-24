# Cycle4 prepared — native timeout and full47 outcomes pending

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
| `diag4-e29-timeout-20261019-01` | `E29` | `fc8793e0c188295d3ea291dbcc8405f2784924d8a2cd2d96d53ce4cf7b1682ef` |
| `fixed-20261019-03` | `all` | `fbb0b46237d2f72c8a7427be5412f05d3328f3b9036423128640db27371bb3fb` |

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

Only maintained Environment changed: +259/-27 against the exact
pre-task Environment. `environment.patch` contains the full independent patch.
`preservation.json` separately compares callback bodies, E27/E28 start/final
branches, shared original launch, ProbeAlliances and the entire tileset tail;
`non-e29.patch` is empty. Every original assertion/record call survives with its
exact condition/name/detail. All12 other maintained source files match the
cycle3 source hashes. No native differential run of sibling cases was authorized;
byte preservation is structural evidence only.

Core SHA-256: `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6`

Verified logger SHA-256: `564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d`

Environment before: `021a504533130ffb3e3922f1ca2bca8f37e4209bc51e64906bceca5646e7e41f`

Environment after: `0b1c72c23fdc2cf90ad7ebdb993b1df5804b62ef3e036e21ceab6ea2b6dbfaf2`

Exactly ONE foreground run (30s tool timeout):

```sh
python3 -B -m unittest discover -s projects/relativistic-classic/tests -v
```

Observed exit0, stdout exactly empty. Exact stderr is in tooling-tests.stderr.txt
and embedded verbatim in preparation.json, alongside stdout and exit streams:

```text
test_bootstrap_keeps_exact_config_and_excludes_original_demo (test_build.BuildTests.test_bootstrap_keeps_exact_config_and_excludes_original_demo) ... ok
test_build_without_harness_preserves_empty_bootstrap_contract (test_build.BuildTests.test_build_without_harness_preserves_empty_bootstrap_contract) ... ok
test_collision_before_any_write (test_build.BuildTests.test_collision_before_any_write) ... ok
test_compiler_failure_records_exit_without_publication (test_build.BuildTests.test_compiler_failure_records_exit_without_publication) ... ok
test_destination_ancestor_of_input_rejected (test_build.BuildTests.test_destination_ancestor_of_input_rejected) ... ok
test_existing_run_is_immutable (test_build.BuildTests.test_existing_run_is_immutable) ... ok
test_failed_roundtrip_never_publishes_map (test_build.BuildTests.test_failed_roundtrip_never_publishes_map) ... ok
test_hardlink_input_alias_rejected (test_build.BuildTests.test_hardlink_input_alias_rejected) ... ok
test_harness_requires_entry (test_build.BuildTests.test_harness_requires_entry) ... ok
test_help (test_build.BuildTests.test_help) ... ok
test_invalid_entry_rejected (test_build.BuildTests.test_invalid_entry_rejected) ... ok
test_invalid_run_id_rejected (test_build.BuildTests.test_invalid_run_id_rejected) ... ok
test_nested_import_rejected_without_writes (test_build.BuildTests.test_nested_import_rejected_without_writes) ... ok
test_opaque_member_build_preservation (test_build.BuildTests.test_opaque_member_build_preservation) ... ok
test_recovery_bad_hash_no_writes (test_build.BuildTests.test_recovery_bad_hash_no_writes) ... ok
test_recovery_boundary_validation_no_writes (test_build.BuildTests.test_recovery_boundary_validation_no_writes) ... ok
test_recovery_exact_sources_and_repeated_rejection (test_build.BuildTests.test_recovery_exact_sources_and_repeated_rejection) ... ok
test_recovery_opaque_member_records_raw_evidence (test_build.BuildTests.test_recovery_opaque_member_records_raw_evidence) ... ok
test_success_entry_roundtrip_and_input_preservation (test_build.BuildTests.test_success_entry_roundtrip_and_input_preservation) ... ok
test_symlink_output_rejected (test_build.BuildTests.test_symlink_output_rejected) ... ok
test_documented_case_ids_match_runner_and_danger_is_last (test_lab.CatalogStructure.test_documented_case_ids_match_runner_and_danger_is_last) ... ok
test_bad_status (test_lab.Logs.test_bad_status) ... ok
test_counters_rejected (test_lab.Logs.test_counters_rejected) ... ok
test_duplicate_case (test_lab.Logs.test_duplicate_case) ... ok
test_duplicate_complete (test_lab.Logs.test_duplicate_complete) ... ok
test_fail_is_nonzero_with_machine_evidence (test_lab.Logs.test_fail_is_nonzero_with_machine_evidence) ... ok
test_freshness_equal_boundary_and_metadata (test_lab.Logs.test_freshness_equal_boundary_and_metadata) ... ok
test_incomplete (test_lab.Logs.test_incomplete) ... ok
test_invalid_run_id (test_lab.Logs.test_invalid_run_id) ... ok
test_mismatch (test_lab.Logs.test_mismatch) ... ok
test_missing_begin (test_lab.Logs.test_missing_begin) ... ok
test_nonfinite_freshness (test_lab.Logs.test_nonfinite_freshness) ... ok
test_normal_pass_and_exclusive_report (test_lab.Logs.test_normal_pass_and_exclusive_report) ... ok
test_observation_is_not_assertion (test_lab.Logs.test_observation_is_not_assertion) ... ok
test_report_never_overwritten (test_lab.Logs.test_report_never_overwritten) ... ok
test_skip_is_not_pass (test_lab.Logs.test_skip_is_not_pass) ... ok
test_stale (test_lab.Logs.test_stale) ... ok
test_symlink_report_parent_is_rejected (test_lab.Logs.test_symlink_report_parent_is_rejected) ... ok
test_unbegun_case (test_lab.Logs.test_unbegun_case) ... ok

----------------------------------------------------------------------
Ran 39 tests in 0.764s

OK
```

These39 existing tests establish tooling/catalog behavior, not missile physics.
No new Python physics/static-text GREEN was manufactured. The historical native
RED remains pre-fix evidence; native GREEN/PRESERVE belongs to the parent runs.
Preparation reuses existing guard/write_new/digest/json_bytes and exact-once
transform helpers, preflights all destinations/no symlinks/overlap, writes each
new output exclusively and reads every byte back. Source and old artifacts
remain unchanged by freezing; no test scratch/cache is retained in the worktree.

## Exact compiler recipes — NOT executed here

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 python -B /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/tools/build.py build --wc3 /home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 --base /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/baseline/original.w3x --timer-utils /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/libraries/TimerUtils.j --world-bounds /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/libraries/WorldBounds.j --dummy-recycler /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/libraries/DummyRecycler.j --core /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/Missiles.j --bootstrap /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/MapMain.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Config.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Support.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Lifecycle.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Motion.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Contact.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Environment.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Load.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Runner.j --entry LabRun --output-dir /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build --run-id diag4-e29-timeout-20261019-01
```

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 python -B /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/tools/build.py build --wc3 /home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 --base /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/baseline/original.w3x --timer-utils /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/libraries/TimerUtils.j --world-bounds /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/libraries/WorldBounds.j --dummy-recycler /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/libraries/DummyRecycler.j --core /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/Missiles.j --bootstrap /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/MapMain.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Config.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Support.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Lifecycle.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Motion.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Contact.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Environment.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Load.j --harness /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build/inputs-fixed-20261019-03/lab/Runner.j --entry LabRun --output-dir /home/snz/Documentos/ChatGPT/WDev/projects/relativistic-classic/build --run-id fixed-20261019-03
```

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
