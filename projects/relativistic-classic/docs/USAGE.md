# Classic missile regression lab

Use this project to inspect the local fixes, build isolated test copies, and collect
scenario evidence. A successful build is not a successful gameplay test.

## Review the right files

| Path | Purpose |
| --- | --- |
| `src/Missiles.j` | Working Classic core, retaining upstream credits and public callbacks |
| `src/libraries/` | Recovered TimerUtils, WorldBounds and DummyRecycler dependencies |
| `src/lab/` | Scenario adapters, assertions and classic persistent logging |
| `baseline/` | Immutable original map and recovered source; never apply fixes here |
| `build/<run-id>/` | Frozen inputs, generated JASS, commands and one new test map |
| `reports/` | Actual compiler/build/game evidence and immutable baseline failures |
| `docs/scenarios.md` | Case catalog, equations, fixture requirements and log-reader contract |
| `docs/core-fixes.md` | Intended changes, ownership and circular-vision semantics |

The original map outside WDev is not a deliverable to overwrite. Existing build
runs and logs are preserved; choose a new run ID for every build/game attempt.

## Run and inspect a candidate

1. Follow `docs/scenarios.md` to build with the selected core and a unique matching
   `RM_RUN_ID`. `RM_SELECT` chooses `all`, a documented group or one case.
2. Use the reviewed workshop `wc3 play /absolute/path/to/new-map.w3x` launcher.
   It validates JASS and refuses an existing game in its profile; do not kill a
   user game to bypass that guard.
3. The suite starts automatically. Watch the case label and visible projectiles.
   A crash, hang or missing COMPLETE is incomplete evidence, never PASS.
4. Preserve `CustomMapData/Logs/RM28-<run-id>.txt` from the identified profile.
   The launcher runtime log is not the missile assertion log.
5. Run `tools/read_logs.py LOG --run-id ID --report NEW-REPORT.json`, optionally
   with `--not-before` set to the recorded launch time. The reader never rewrites
   the source log or an existing report.
6. Exit only the test session that this run launched. Keep other applications,
   editor sessions and historical logs untouched.

Log-reader exit 0 means no FAIL in a complete valid log; SKIP still produces an
inconclusive status. Exit 1 records assertion failures. Exit 2 rejects invalid,
stale, mismatched or incomplete evidence. OBS measurements are not assertions.

## Import boundaries

Keep one owner of the dummy/recycler, library variants and `SetUnitUserData`.
Do not mix this Classic core with the modern effect/Lua backends. Preserve
verified rawcodes and the existing dummy model/object; dependencies and source
provenance are recorded in recovery/toolchain reports.

These generated maps are **executable-test copies**, not editor-save-certified
packages. Their external source is authoritative; retained original WCT/WTG does
not describe the new executable script. Opening and saving them in World Editor
can replace the script. Rebuild through the reviewed project tooling instead.

## Scope of correctness

- Point-sampled unit/missile contact and rectangular item/destructable contact
  are existing contracts, not swept collision. High-speed tunneling remains a
  stated limitation unless a separate tested collision design replaces it.
- Acceleration remains a velocity increment per processed visit. Load-dependent
  callback timing is not an elapsed-time acceleration guarantee.
- `vision(radius)` is explicit circular revelation on Classic, not real unit
  sight, terrain/tree occlusion, detection, or erasure of explored terrain.
- One-client assertions do not certify synchronization. Multiplayer, exhaustion,
  arbitrary host-map integrations, editor round trips and performance require
  their own recorded evidence.

Consult [FINAL.md](../reports/FINAL.md) before using the current fixed03 candidate.
Status: **Tested in map**, `verified_singleclient_map`, not
production-ready; independent comparison true, native approval false. Recipes above
are not a grant to run. No automatic future execution or GUI action is pending.

## Current delivery and completed independent gate

Candidate: `build/fixed-20261019-03/fixed-20261019-03.w3x`, SHA-256
`4490afbf0824a89186faf22e3a948452b27fe0ae1a111f3d960a108228fb2694`.
ONE normal uninjected full47 completed47/808/0/1, reader0/statusinconclusive:
**670PASS/137OBS/0FAIL/1multiplayerSKIP**, E29 34PASS/13OBS/1SKIP, L99 last.
670 assertions passed, not808. Both builds JassHelper/pJASS/archive exit0;
39 existing tooling tests exit0 in0.764s. Evidence retained, not rerun here.
Negative game8 exit0/10m19s, full game10 exit0/5m50s, observer9 exit0/2m43s;
all games/observers complete, termination methods not inferred.

Only E29 fixture changed; coreadc5ffd9 and verified logger56443489 remain
unchanged. Independent translated raw visibility gates preserve original actual
conditions; raw mutations follow public reconciliation, motion remains bounded,
transition guards2s. Frozen negative's sole predicate false reaches exact
`phase=8 wait=native-reference deadline=2.000 elapsed=2.000`; actual reader1,
28PASS/17OBS/1FAIL/1multiplayerSKIP. Abort cleanup/restoration/onRemove/idle PASS;
prior expected-negative validation0. Normal full47 has no injection.
See [cycle4 RESULTS](../reports/cycle4/RESULTS.md) for identities/proof/streams.

## Independent assigned-scope gate completed

Inherited source inspector `mvevyvvm-a-ov94` found no introduced fixture defect.
Corrected independent check `mvexzndm-j-5179` actually executed with a25s timeout,
**exit0 and empty stderr**. It closes T6's assigned single-client
S3/S4/S8/S10 evidence/oracle gate and S11 comparison purpose using S12 permission;
this is not native review approval, multiplayer or universal production acceptance.

The first actual probe `mvexqx1v-i-bl4g` exited1 with empty stdout and
`KeyError: 'freshness'` at comparison.py:102. The historical fixed02 report omits
optional freshness (the reader records it only with `--not-before`). Exactly ONE
auxiliary correction allowed absence ONLY there: **historical freshness not
recorded, not reconstructed or accepted as PASS**. All three current freshness
checks remain mandatory; no input, assertion, source or native evidence changed.
V1 remains immutable. Earlier source-only scan and two unlaunched capability
checks remain historical; they are not erased or relabeled as execution.

The corrected command independently checked77 explicit copied inputs, current13
sources, both frozen manifests, Config specializations, sole negative predicate,
compiled/maps/logs/public streams, original before/after hashes and Git state.
All47 case IDs match, L99 last. All70 original M45 records retain exact details
and order. All26 original E29 names/details remain; original assertions PASS
except multiplayer. Non-E29 case/status/name multiplicities are preserved except
exactly intended M45 recovered launch flag and coordinate-fixture-live FAIL to PASS.
**36 dynamic detail differences** in C21/C25/C36–C42 include runtime handles and
C37/C38 matched expected/actual0-vs1 remaining-object swaps, both PASS. This is
not whole-log or universal detail equality. Raw locations are retained in the
copied `dynamic-differences.json`; omitted truncated OBS values are not inferred.

S12/L45's live explicit system-temp permission resolved the earlier no-scratch /
inside-WDev isolation blocks. That authorization was session/purpose-limited,
not standing consent for future outside access. No permission question, action
or in-scope check remains. No engine, test, build, comparison or GUI rerun was
performed for reporting; no source/map/native data changed. Temporary proof and
historical `/tmp/rc-item3-XNICaO` were not modified or deleted.

[Exact comparison proof](../reports/cycle4/comparison/README.md).

## Historical diagnostics and limits

[Cycle2](../reports/cycle2/DIAGNOSIS.md) preserves partial stress RED; [cycle3](../reports/cycle3/RESULTS.md)
retains logger70PASS/701OBS reader0 with all70 original M45 assertions independently
identical, and E29 25PASS/31OBS/3FAIL/1SKIP reader1 including native .25s transfer
FAIL. Convergence at.5s in that run justified adapting the oracle, not universal
cadence or a common historical withdrawal cause. Separate withdrawal PASS.
Historical fixed02 still657PASS/124OBS/3FAIL/1SKIP reader1, map SHA-256
`b8b1b9a1e4a072f014a75122a1c96851175c07c7198532f1d900227ee1165859`;
not current candidate and lacks corrected logger. Old logs/snapshots unchanged.

Diagnostic OBS tails visibly truncate: omitted values not proved; named assertions
retained, not a newly established defect. No screenshots accessed/referenced/embedded;
ambiguous GUI captures excluded. Multiplayer/editor-save/exhaustion/arbitrary
integration/universal production remain uncertified. Standalone executable-test
maps are not release/editor-save-certified. Risk: item3 oracle contract verified for assigned scope; this reporting unit
docs/evidence only. Native
assessment unassessable/untracked, no approval/receipt. T5/T6/T8 done;
T7 closes after reporting metadata/copy readback, all eight then done. Historical `/tmp/rc-item3-XNICaO` untouched;
this reporting unit created no scratch; both authorized proof roots retained unchanged. No new controls, commits or publishing.

## Scoped reporting closure

The single foreground reporting-only readback exited0 with empty stderr:
3 JSON reports,7 Markdown reports and20 exact proof-file copies checked;
copied scripts parsed for syntax only, never executed. No redaction required.
[Readback evidence](../reports/cycle4/comparison/reporting-readback.json).
This supersedes the pre-readback T7 checkpoint above: **T1–T8 all done for scoped
work**, T6 assigned verification complete, T7 reporting complete. No action or
in-scope check pending. Native approval/production readiness remain false;
multiplayer/editor-save/exhaustion/arbitrary integration remain out of scope.
