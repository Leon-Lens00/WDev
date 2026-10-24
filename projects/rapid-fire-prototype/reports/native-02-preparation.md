# Native02 — bounded correction PREPARED, not compiled

S18 authorizes one correction and one fresh experiment. This worker prepared only. **T1 remains in_progress/native02pending.** Native01 remains FAILED:77PASS/381OBS/24FAIL/1SKIP, reader1, game0/closed. None of its proof was replaced or reclassified as acceptance.

## Parent execution handoff

Use **`../build-plan-02.json`**: exact absolute build argv, source hashes, unchanged base05/dependencies/core, explicit harness order, output and reader template. Original `../build-plan.json` remains the immutable run01 plan. The new harness order adds `src/NativeReference.j` before NativeProbe. No nested imports or old Lab imports.

- Embedded run: **rf-pathing-20261019-02**.
- Expected relative Preload log: **Logs/RF-rf-pathing-20261019-02.txt**.
- Expected map: `build/rf-pathing-20261019-02/rf-pathing-20261019-02.w3x` (not created).
- Parent alone compiles/pJASS/packages/background-launches, once. Capture launch freshness and use the unchanged reader once on this new log. A missing/partial log is not PASS. No worker build/game was run.

## Evidence preservation and static checks

Before overwriting source, four run01 files were copied byte-for-byte to `frozen-pathing-01/` and verified against the original run01 build plan. `frozen-pathing-01/build-plan-01.json` is an exact copy of the original `build-plan.json`, not a replacement. `preservation.json` records190 protected original artifacts and67 pinned old inputs. Their hashes were checked again after preparation, unchanged; base05, schema adapter, dependencies and immutable old core were not edited.

`native-02-final-source-checks.json` records final source hashes and results. Initial all-source lint passed; after preserving fresh short-step coverage, a focused NativeProbe lint also passed:0 errors/20 total ownership warnings across final sources. Direct-call API scan found no unknown names. Earlier `native-02-preparation-checks.json` and `native-02-final-readback.json` are preserved intermediate snapshots; the final ready readback supersedes their NativeProbe hash. This is declaration/source inspection, **not JASS compilation or native GREEN**. No irrelevant serializer tests were rerun. RED is the preserved actual native01 failure, not Python physics or source-string assertions.

Source delta against frozen01: **+784/-306 lines** across the five JASS files (including95 new NativeReference lines). NativeProbe+633/-297; PathingCandidate+52/-5; ProbeLog+3/-3; bootstrap+1/-1. The larger coherent fixture state machine is necessary for independent body observations, actual geometry, guard/abort paths and finite cleanup; the400-line heuristic is advisory, not a cap or reason to omit controls.

Ownership: the reference module owns its ordinary body unit and group; each body is removed, checked on a later tick, and removed again during bounded abort cleanup if necessary. NativeProbe owns fixture units/tree/items, timer and cast trigger. The candidate owns its group/world rect and per-point helper/rect; helper items are removed before the next placement. Final cleanup is explicit, but external resource completeness remains unmeasured until native observation; no universal lifecycle certification is implied.

## Corrective rules

1. **Independent reference first.** Up to three proposed local patches start near the native01 accepted-step hint, not its unestablished origin. A normal ground unit of the same owned actor base performs a native64-unit Move with1.875s deadline. Exact body placement then checks nine local points plus three actor-step points before the real actor exists. Native Move arrival tolerance8 measures vicinity only; separate placement tolerance1 establishes exact native body occupancy. This is a native placement/occupancy reference, not a claim that CreateUnit reproduces all native navigation semantics or that sparse points prove a continuous clear area.
2. **No reference contamination.** References are removed immediately. A later timer callback checks public removed type and native group membership before creating another reference, blocker or query. An uncleared reference stops the probe with FAIL, rather than being excluded from the collision predicate. The real actor remains768 units away from the main blocker patch.
3. **Positive controls precede geometry.** Every dynamic fixture requires independent body occupancy and then a single candidate-positive query before creating its blocker. Native cache restoration is bounded by eight body-reference attempts/two seconds, independent of candidate eligibility. The candidate is never polled until it happens to pass. Failure explicitly aborts that fixture's geometry and cleans up; it does not yield negative PASSs from an already-false baseline.
4. **Actual geometry, no guessed building shape.** Building creation is first calibrated and removed. An actual center outside the bounded local patch aborts. At the calibrated center, native body/query positives qualify the center and two twelve-point rays at32-unit spacing. Recreated placement must be repeatable. Native body occupancy with the building present brackets the first axial and diagonal blocked-to-available transitions, at32-unit resolution. Candidate negatives/positives use those measured bracket points, not nominal±240 or an invented texture corner. Missing/nonmonotonic brackets abort. These are discrete body-boundary brackets, not exact polygon/corner or continuous-shape certification.
5. **Real gap widths.** Verified Footman radius31 and actor radius16 remain unchanged. Both future placement sites and the center are positively qualified; actual Footman coordinates, symmetry and clearance must establish requested16/32/64 within1 unit. Negative clearance is never renamed a requested gap. Independent body occupancy then qualifies the intended control; exact32 remains OBS. Removal requires a new independent positive control.
6. **Hidden helper after every positioning call.** Each point allocates a helper at a distant staging point, hides it, positions it, records actual public visibility before re-hide, explicitly hides again, and observes visibility at query exit. It is removed before another placement; public remaining type is recorded. Visibility/restoration/removal failures invalidate the query and cause bounded abort. No helper remains parked between cases. Native01 visibility/causality remains unmeasured; this correction does not retroactively explain its failures.
7. **Neighbor state and actor state.** All saved neighbor visibility/coordinates are compared through public getters after restoration. All queries compare actor XY/facing/order. The item case issues a controller-owned native Move order, verifies it is active, queries immediately, then controller Stop; this is synchronous query preservation, not a walking takeover/resume test. An8-unit item step actually runs candidate queries; its result and item restoration are checked. The16-unit oversized boundary remains separate and is not item-query proof.

Tolerance1, all nine±16 square samples, range600 and the two short substeps/cap10.9375 are **not loosened**. Actor accepted translation remains SetUnitX/SetUnitY only; no actor SetUnitPosition, pathing toggle, missile-dummy assignment, animation or production movement loop was introduced. No terrain/pathing rewrites are performed in02.

## Original twelve CASE IDs, guarded interpretation

| CASE | Corrected measurement / abort meaning |
|---|---|
| O01-open | Finite native Move/body qualification, later removal clearance, actual actor placement and open/8-step controls. No qualified patch or candidate-positive control: FAIL and whole-probe cleanup/COMPLETE, not an invalid geometry sweep. |
| S02-static-step | Paired positive and independently blocked native01 static/cliff sample, without terrain toggles. Fresh short-step control uses the independently prequalified actor goal, then an actual radius31 Footman52 units away: native range16 must be false at the current actor and true at goal+8. Guard actual placement/current actor position; query/reject8-step, preserve public state, remove blocker, verify native removal and positive afterward. Failed placement/overlap/removal readiness aborts. This is a known unit-blocked short step, not a fresh terrain-toggle step. |
| D03-tree | Qualified origin, actual root placement, independent negative body occupancy, alive negative; bounded native body readiness before dead/removed positive. Failure aborts remaining tree geometry. |
| U04-ground-unit | Qualified baseline and actual placement; independent negative body occupancy before candidate negative; independent removal positive. |
| B05-building | Calibration, positive ray controls, repeatable actual placement and measured native-body boundary brackets; otherwise explicit abort. |
| G06/G07/G08 | Actual16/32/64 clearances and independent body controls;32 OBS; before/removal positives. |
| I09-items | Prequalified actor-step points; actual active Move query witness, visible/hidden item restoration, queried8-step and separate unqueried16-step boundary. Failed baseline/order/item-query readiness aborts. |
| L10-bounds | Independent open positive paired with actual world bounds and discrete rejection observations. |
| C11-cliff | Paired positive, actual public blocked flag/body occupancy at the recorded01 cliff sample; not a new world scan or universal cliff proof. |
| A12-channel | Actual scripted point-order/effect/source/ability/target within2s; no final UI or burst inference. |

Fixture-abort FAILs can coexist with later valid cases; they are not a fixed count of independent algorithm defects. The final SKIP retains multiplayer/production-animation limits. COMPLETE may have fewer than12 CASEs after an early whole-probe abort or budget exhaustion; unreached cases are not accepted.

## Finite runtime budget and remaining limits

Timer period **0.125s**, global maximum **440 callbacks/55 nominal game seconds after the harness starts**. Reaching the budget logs explicit FAIL, cleans up and writes COMPLETE. Native Move guard1.875s; native restoration guard2s; Channel guard2s. Building ray scans are fixed25 baseline points and24 occupancy samples, not unbounded search. All native waits are event/timer phases inside the engine; no worker sleep, game, polling process or desktop action was used.

The parent's120-second observer includes map loading and all engine/log I/O, leaving65 seconds beyond the nominal55-second game budget. **No hard wall-clock guarantee is claimed**: loading, simulation pauses and cumulative Preload snapshot overhead have not been measured for02. If that budget is exceeded, the single experiment remains incomplete; no retry is authorized by this preparation.

Even a clean02 result would not establish a universal continuous footprint algorithm, arbitrary-large-building range coverage, sliding/pathfinding, production350-speed loop, Stop/takeover/resume, burst cadence/damage,300% visual animation, final Channel UI, multiplayer, editor-save or external resource-count correctness. The new short-step rejection control is unit-blocked, not a repetition of01's temporary terrain-toggle condition. Parent must interpret the actual measured scope before any T2 promise.
