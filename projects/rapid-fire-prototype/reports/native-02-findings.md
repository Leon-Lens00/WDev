# Native02 — FAILED: open readiness aborted

**Tested in map, failed readiness scope.** The parent's native02 JassHelper/pJASS/archive build exited0, but the single additional measurement authorized by S18 aborted before collision testing. **T1 is blocked awaiting a human readiness-correction decision; T2–T5 remain pending. No third run is authorized or queued.**

## Actual evidence

| Item | Saved outcome |
|---|---|
| Run | `rf-pathing-20261019-02` |
| Map | `build/rf-pathing-20261019-02/rf-pathing-20261019-02.w3x` |
| Map SHA-256 | `30331e7b6710d5e47cdcfc350176845e7ff8d2357f435c24935d6d08723d0509` (saved build identity; not rehashed here) |
| Build | JassHelper/pJASS/archive exit0; `probe-build-02.*` |
| Native completion | **`COMPLETE|1|59|1|1`**:3PASS /54OBS /1FAIL /1SKIP;59 CHECK records, not59 successful assertions |
| Reader | exit1, status failed, stderr empty; `native-reader-02.*` |
| Freshness | Launch1792443424.6365788; log mtime1792443490.1502047 |
| Log SHA-256 | `c2fe38bbd1101821c7c5eee781cb58f7361d74a02f37f4a59f933186513c37c4` (saved reader identity) |
| Gamejob6 | **Exit NOT REPORTED**; no0, open/closed state or termination method inferred. No process query, poll, close or kill performed. |

Raw proof remains `RF-rf-pathing-20261019-02.txt`, `native-rf-pathing-20261019-02.json`, build/launch/reader streams and source/build artifacts. This unit only reads saved evidence and updates reporting/checkpoint files; no reader rerun, implementation, test, build, game, experiment or retry occurred.

## Completed read-only review: actual gate and endpoints

Review `mvfqlfcd-7-k2mz` corrected the earlier parent hypothesis. `NativeReference.j:69–81` admits **squared goal distance<=64: an8-unit vicinity**, not<=1. The separate `NativeReference.j:49–54` body-placement test uses **per-axis<=1** and was never reached.

| Proposal | Requested goal | Actual final native coordinate | Observed state |
|---|---|---|---|
|0|(-1280,-512)|(-1295.402,-511.959)|order0, outside8; timeout1.875s|
|1|(-1280,-1024)|(-1305.582,-1011.194)|order0, outside8; timeout1.875s|
|2|(-2048,-512)|(-2063.405,-511.982)|order0, outside8; timeout1.875s|

The approximately15.4-unit rest distances at proposals0/2 do **not** establish a universal16-unit arrival radius or its cause. Native order0 near a requested goal does not prove occupancy of that requested coordinate.

`NativeProbe.j:207–219` bypasses body calibration after a reference timeout;258–264 fail/finish after three proposals. The recorded FAIL is `open-fixture-aborted`: `no independent native local patch within three proposals`.

## Reached versus unreached scope

**Actually passed:** three `public-reference-clearance` records (raw lines22/41/60) report removedType0 and absence from the native group. These are narrow reference-removal observations, **not proof that every resource was cleaned up**.

**Not reached:** actual actor creation (242–249), BodyOccupies/exact body-placement calibration, nine-point readiness, Query/Eligible/TryStep, helper query visibility/re-hide/removal, obstacle/gap/item measurements and Channel02. Helper initialization/guard calls occurred, but cannot validate its positioning/visibility lifecycle. None of these unexecuted phases passed or received an individual SKIP.

The sole final SKIP covers production/multiplayer/animation limits. Native01's scripted off-camera Channel proof remains unchanged; it is not a Channel02 result or final UI proof. No usable complete prototype, collision acceptance, production350 movement, Stop/handoff/resume or burst acceptance follows from02.

## Proposed next direction — not implemented or authorized

One parent-owned human decision remains: explicitly authorize a bounded readiness correction plus a new measurement, **or pause**. S18's one extra measurement has been consumed; the latest request, "Review the delivered subagent output and continue.", is not permission for an automatic third run.

A proposed correction would anchor the control to the **actual native-occupied resting coordinate before reference removal**, then establish exact body/neighborhood clearance and compare the candidate at that **same point**. Merely widening arrival tolerance or accepting order0 near the old goal would not prove goal occupancy. Do not loosen collision-item tolerance1 or drop footprint samples.

This is a proposal only. No source, recipe, raw record or historical entry was rewritten, no new measurement/verification was queued, and no native review approval or task completion is claimed. SpecsS1–S18 and all01/02 proof remain intact.
