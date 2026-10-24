# Native prerequisite01 — collision acceptance blocked

**Tested in map, failed prerequisite scope.** Exactly one prepared build and one fresh native run were executed by the parent. **T1 is blocked awaiting a human decision; T2–T5 remain pending.** No corrected experiment is authorized or queued.

## Observed evidence

| Item | Saved result |
|---|---|
| Run | `rf-pathing-20261019-01` |
| Map | `build/rf-pathing-20261019-01/rf-pathing-20261019-01.w3x` |
| Map SHA-256 | `922483311b1eb5d7ca4c9189109e559249f9d2064dfc086870662846016a37a3` |
| Build | Parent's exact prepared argv; JassHelper/pJASS/archive checks exit0 |
| Native log | `RF-rf-pathing-20261019-01.txt`; `COMPLETE|12|483|24|1` |
| Counts | **77PASS /381OBS /24FAIL /1SKIP**;483 CHECK records, not483 assertions |
| Reader/observer | Public reader and observerjob2 exit1; reader stderr empty |
| Freshness | Launch1792440660.7272184; source mtime1792440675.081454 |
| Log SHA-256 | `ddd6c55bfd5689e2602b65072fbe48325ee33789a919be9978511d61b5f370cf` |
| Game lifecycle | Nativejob3 completed and subsequently EXIT0; now closed. No agent close/kill; termination method not inferred. |

Saved proof: `probe-build-01.request.json`, `probe-build-01.stdout.txt`, `probe-build-01.stderr.txt`; `native-launch-01.{json,stdout.txt,stderr.txt,exit.json}`; raw log; `native-rf-pathing-20261019-01.json`; `native-reader-01.{stdout.json,stderr.txt,exit.json}`. Raw failures and prior preparation/RED/GREEN proof remain unchanged. This reporting unit inspected saved data only; it did not rerun the reader, source tests, build or game.

## All24 failures retained, three causal groups

Read-only diagnosis `mvfoygg5-4-7zw2` is the inherited diagnostic basis, not a new native experiment.

| Group | Count | Evidence and interpretation |
|---|---:|---|
| Unestablished origin |18| O01 open; D03 pre/dead/removed; U04 pre/removed; B05 center pre; G06 pre/removed; G07 pre/removed; G08 pre/positive/removed; I09 pre/with/removed; C11 open control all query(-512,-512), candidate=false, nativeWalkBlocked=false, cliff1. An open Shaman-traversable reference was never established. |
| Placement readiness |4| B05 building actual(-832,-192), not nominal(-512,-512). G06/G07/G08 actual clearances -71/-63/-47, not requested16/32/64. These fixtures did not establish their intended geometry. |
| Invalid nominal-coordinate oracle |2| B05 edge/corner assertions queried nominal points despite failed building placement readiness. They do **not** prove collision penetration. |

Native item examples: wanted(-528,-528)→actual(-496,-496); wanted(-512,-528)→actual(-464,-496). Squared tolerance1 correctly rejects these displacements. This is neither independent proof of Shaman traversability nor18 established algorithm bugs. **Do not weaken item tolerance or remove footprint samples to manufacture positive controls.**

U04's negative PASS is also masked by an already-false baseline; raw native range16=false. It does not establish ordinary-unit collision acceptance.

A concrete candidate omission was identified read-only: the helper item is hidden only at initialization, not re-hidden after positioning. Actual subsequent helper visibility and its causal role were **not observed**. No fix is made or cause asserted here.

## What actually passed, within narrow limits

- **Scripted Channel:** order accepted; native effect observed by0.750s; expected ability/source and actual target(-416,-352); controller(-5500,-5500). Hidden Ncl3=0 proves this scripted capability only, not final player-facing UI.
- **Public actor invariants:** query XY/facing/current order preserved. Accepted8-unit step(-1280,-512)→(-1272,-512), facing90/order0; static blocked-step rejection left public state unchanged. This was **not an active NativeMove order**.
- **Neighbor item restoration:** visible/hidden fixture item visibility and coordinates restored. The16-unit oversized step rejects before queries because cap=10.9375; it is not evidence that rejected-step item gating ran.
- **Discrete static/bounds observations:** recorded checks passed; actual cliff sample(1792,-6656) had walkBlocked=true. This does not repair the missing open control or establish continuous footprint collision.

Nine square footprint samples, range600 and two short substeps do not prove universal or continuous collision. Cleanup calls exist, but no external resource-count assertions establish cleanup completeness. Sole SKIP: `multiplayer-and-visual-animation`.

## Missing proof and next parent-owned decision

Required before geometry acceptance: verified positive baseline with an **independent native Shaman traversability reference**, actual native placement/footprint readiness for each blocker, valid before/after controls, and direct helper-item visibility observations. No active NativeMove preservation,350-speed movement loop, Stop/takeover/resume, burst cadence/damage, animation, multiplayer or editor-save acceptance was established.

The parent will present one closed choice: **authorize bounded corrected fixtures plus an additional native experiment addressing those missing observations, or retain this blocked candidate.** No permission is assumed, no experiment queued, and no implementation is performed by this evidence-only unit.

## Review authority and preservation

Parent-reported native ASSESS: **unassessable**, untracked declaration; plan writerSelfVerification=true / independentVerifier=false. No inspect/start/lineage or native approval exists. Unavailability is not approval.

S1/S9/S12/S15/S16/S17 prerequisite evidence is recorded only within these limits; no task is declared complete. SpecsS1–S17, source/recipes, all24 failures, earlier proof and old fixed03 scope are preserved. No new tests/build/game/retry, desktop action, process control, commit or publishing occurred.
