# PREPARED_AIM_RED — native geometry/window qualification pending

**New executable harness/plan delivered; no compiler or game run.** Core stays `f82e92301dea1dd64a1993843e4f04c929a58bd032b9908f87fa96eb18426d52`, including the already-tested count reset but still no active-cast heading update. This unit prepares partial **S6** future-aim RED and existing-flight regression; S1/S2/S4/S5/S10/S11 remain regression scope. No static-actor test certifies **S14 while moving**, animation/UI/mover/full S2/T2 or a physical-defense matrix.

## Parent quick path and exact recipe

1. Inspect/execute `../build-plan-aim-red01.json` **`.argv` / `.shell`** for parent-owned compilation/archive validation. It pins all10 inputs and the unchanged old builder.
2. Parent performs ONE fresh read-only exact-profile preflight **before observer**, then protected launcher/event-driven observation. Launcher35 EXIT0 was wrapper completion, **not game closure/profile release**. No worker process query or runtime action.
3. Use the plan's exact log/reader template once on fresh COMPLETE; observer180 wall seconds, no polling-until-pass or automatic retry. Native failure to qualify geometry/window produces explicit FAIL ABORT/COMPLETE, not invented new-aim RED.
4. If all prior regressions and new native readiness qualify, current Core is expected to yield five EAST hits and zero NORTH hits: **four R04 aim-partition failures**, while R05 existing-flight assertions should already pass. These are predictions, not observations. Preserve this SAME harness byte-for-byte for future GREEN.

Run **rf-burst-aim-red-20261020-01**, group **RFBurstAim**, public entry **RF_StartAimTest**.

- Imports: TimerUtils → WorldBounds → DummyRecycler → immutable Missiles → AimLogRed01 → unchanged PairCore → AimNativeTest → AimMapMainRed01.
- Output: `build/rf-burst-aim-red-20261020-01/rf-burst-aim-red-20261020-01.w3x` (absent at handoff).
- Relative log: `Logs\RF-rf-burst-aim-red-20261020-01.txt`; absolute profile log and reader/report argv in plan.
- Base remains instant-controller `dea9c6cbac7e486d7c4fc11267fc1ed7b17c483d11f6f1025ecad6f45dc5c7ad`; no new objects/UI/metadata or helper changes.

## Previous three cases — exact semantics, new suite only

B01/B02 and R03 run first at their original coordinates, with the same native calibration, live-Missiles checks, actual damage/source, paired HP cancellation, cadence, first/second-effect guards, cleanup and deadlines. Original `RecastNativeTest.j` remains SHA **aec5c4735d594975644eef5f03118d23e4acffadc4afd3ee46ff8c389a769af0**.

Ten copied common function bodies—including SceneReady, RemovedAbsent, Assess, ResetObservations and SpawnScene—are byte-identical. R03 Assess differs only by its final transition into the aim scene; common event bodies are identical behind an aim-mode dispatch guard. Structural comparisons are preservation evidence, **not gameplay proof**. Existing native3/73/0/0 and independent reset-unit PASS remain historical scoped evidence, not verification of this new suite.

After R03's full observation window, require no allocated source flights, dispose/remove the old pair and validate next-tick type0/native-group absence before fresh aim creation. No old flight/event/calibration/HP baseline is reused. Old source/plans/maps/raw/independent proof were fingerprinted before source creation: **885 protected files match**, including Core, old harness, bases and libraries.

## Bounded geometry selection and actual native readiness

The former local test region has varying raw ground heights. A finite local strict flat-L query returned no candidate; a separate finite owned W3E-grid scan, retaining the **same flat-L/WPM predicates**, found110 candidates and selected the nearest one. This is static selection, not repeated native trials or terrain mutation. Evidence: `aim-red01-static-geometry.json`, `aim-red01-geometry-selection.json`; actual W3E/WPM hashes match the existing owned inputs.

Only the new aim scene uses:

| Role | Owner/type | Requested XY |
|---|---|---|
| Actor | P0/o000 |(-3136,2624)|
| Logical caster | P0/o001 |(-5500,-5500)|
| EAST target | P1/o000 |(-2880,2624)|
| NORTH target | P1/o000 |(-3136,2880)|
| EAST regen control | P1/o000 |(-2880,3136)|
| NORTH regen control | P1/o000 |(-3648,2880)|

Static L tiles have equal raw ground9715/layer1/no ramp-boundary, with open WPM footprints. Native truth is independently required: type/life/abilities/enemy/alliance/owner/pause and actual placement±1; actual target ranges254..258 and actual ray cosine≤.7071068 (separation≥45°). Only targets/controls are paused. No SetUnitXY placement coercion, actor movement, pathing toggle or terrain rewrite.

For **each actual ray**, finite17 longitudinal ×3 lateral samples span a48-unit corridor: fresh native walk restriction must be absent, cliff levels equal, actual ground Z within1 of the actor. Enumerate alive destructables/other units in its padded rectangle and reject blockers/overflow (128 bounds). Controls' actual placements keep them hundreds of units off both rays. This is bounded flat-corridor/LOS-obstacle readiness, not a native visibility/pathfinder/continuous-traversability theorem; **spawn is not walkability truth**. Unusable geometry is FAIL ABORT before behavioral assertions, with no fallback/retry.

Calibrate EAST **and** NORTH independently with real native `UnitDamageTarget(actor,target,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)`: accepted call, one10±.01 damage event/source actor and next-phase positive native HP loss, controls undamaged. Reset all four bodies to identical safe native max−10 (readback±.001, >60 margin), exclude calibration from burst counts, capture paired baselines at the first real EAST effect. Every burst hit again checks native value/source, and each ray has its own same-type regen control. No invented armor/heading/animation getter.

## R04 — new aim for future shots (expected RED)

- Initial **actual EAST** caster/A00G/actual-point SPELL_EFFECT admits first emission and captures HP baselines. Its public pulse must expose a live allocated/launched missile, separate native dummy, visible source and actual actor origin.
- Save the borrowed first ID/dummy/source, public origin and initial x/y. Compute the expected old ray only from actual EAST target/origin XY—not Core's private heading or a nonexistent angle/generation API.
- The first pulse only schedules due=`firstShot+.0625`; a **future periodic harness tick**, not that observer, issues one native NORTH order to actual GetUnitXY. Pending/request/expected-event/phase/issue time are committed before IssuePointOrder, so synchronous effects are valid.
- Exact second native caster/A00G/NORTH-point effect must occur at observed SHOT count1, no native target impacts, SAME first flight still live/allocated/launched with matching dummy/source, strictly before firstShot+.25. Record first/due/issue/effect/latency and first-flight XY. Binary timing0 is not assumed universal instantaneous effect.
- Next periodic tick after dispatch, still before impact/shot2, sample the SAME first flight with the same liveness/source/dummy checks and zero target hits. Failure to admit this sample is fixture ABORT. Store actual x/y, forward advance and cross-track, then release the borrowed ID; never dereference it after later emissions/impact/possible recycling.
- Observe3 seconds from the second actual effect. Correct reset requires **5 real missiles /5 native10 hits/source visible actor**, EAST1/NORTH4, paired HP differentials10/40±.10, both controls undamaged/all four bodies alive, four adjacent.25±.03125 intervals, no immediate extra pulse. Actual shot/damage times are bounded to the first8 observations, with total counts still rejecting excess emissions.

Current fixed-old-heading Core should instead yield5 EAST/0 NORTH, paired differentials50/0. Expected new-aim FAILs: **east-first-only, north-four-future-hits, east-HP-differential10, north-HP-differential40**. Total count/reset/cadence/source/native damage checks should retain their positive behavior. No actual R04 result is claimed.

## R05 — existing first flight keeps heading (expected baseline PASS)

Same scene, separate semantic case. Use captured post-dispatch sample: positive old-ray advance and cross-track≤1. Require the first **actual EAST native10/source actor hit** while still only one shot has been emitted, before the second boundary, and no premature NORTH hit. Missing observations FAIL, not SKIP. This combines actual public flight motion with actual native damage/HP effects; notifications alone cannot pass the suite. Existing correct behavior is a regression, **not fabricated RED**. A retarget-all fix is separately exposed by the old-flight sample/first-impact checks and EAST/NORTH final partitions.

## Budgets, ownership and observed static evidence

One global25-game-second deadline, runner.03125; copied per-case deadlines unchanged; aim first-effect2s/order, next NORTH effect/sample before first impact/second cadence boundary, final window3s/actual second effect. Observer180 wall seconds; load/logging/game speed prevent a hard wall guarantee. Finite phases only, explicit COMPLETE on FAIL/ABORT, no Waits/retries/poll-until-pass.

Harness owns extra two unit handles plus one location/group/rect; removes/destroys them in Finish along with copied scene observers/timers. Borrowed missile/dummy handles are never destroyed or substituted for the actor. Native corridor callback handles are borrowed; no SetUnitUserData or local-player gameplay writes. Full adversarial lifecycle verification is not claimed.

ONE lint pass: **EXIT0,0 errors/28 handle-ownership warnings**, empty stderr. API lexical check initially misclassified `and (` / `or (` as function calls and the wrapper exited1; original evidence is retained in `aim-red01-static-initial.json`. One bounded classifier-only correction excluded those JASS language operators, yielding no unknown direct calls; **no source change or lint rerun**. Actual common.j declared type names plus primitives were checked against every new local identifier: no collision (including the prior `region` pitfall). Full exact lint stdout/stderr/argv/source/preservation evidence: `aim-red01-static.json`. Lexical checks still do not compile JASS or establish native readiness.

Authored source: **1085 new JASS lines** (982 harness +67 logger +36 bootstrap); conceptual new-harness delta versus preserved507-line recast harness **+480/−5**. Advisory400 exceeded for three complete regression cases plus fresh two-ray calibration/window/native-effect/R05 regression—not minimized or omitted checks to meet a line cap. Strongest status **Scanned** only. New geometry, inflight native cast/sample windows and R04/R05 outcomes remain unproved until parent compilation/native observation. No Core fix, native commands, new independent verification or odd/full-checkpoint work in this unit; T2 stays open.
