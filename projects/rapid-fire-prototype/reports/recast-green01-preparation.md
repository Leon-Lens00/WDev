# PREPARED_RECAST_GREEN_NEEDS_NATIVE

**Minimal same-aim active-cast count reset delivered after qualified native R03 RED.** Strongest status **Scanned**, code-only until parent compilation/native GREEN. Partial S1/S2/S4; full S2/T2, latest aim/in-flight trajectory, animation/mover/UI remain deferred.

## Actual RED and pre-edit preservation

Parent observed RED02 `COMPLETE|3|69|8|0`:24PASS/37OBS/8FAIL, reader1/empty stderr/freshness/0ABORT. B01/B02 passed. R03 second native effect3.781 occurred at SHOT2 after3.640 and before next original boundary3.890. Actual4 shots/4 native hits10/paired HP differential40 versus6/6/60 establishes ignored-recast behavior RED, not compiler/fixture RED. This writer did not rerun native/reader proof.

**Before Core edit**, froze27 immutable files NEW `reports/frozen-recast-red02/`, guarded against overwrite, with raw bytes/SHA256/size/original and copied mtime_ns preserved. Includes old basic/RED Core, exact harness, RED02 labels/plan, map/compiled/build proof, native raw, immutable launch request metadata, reader stdout/stderr/exit/report, observer/results/preflight metadata. `preservation.json` maps each original path to its frozen copy and records raw SHA/source timestamp without normalization.

- Frozen old `sources/PairCore.j`: **`7fe99448ba2fff01e6bd67675c8a71e30ad7b11b35268e65b4f74ec0a64e1078`**, identical to the earlier minimal B01/B02 GREEN candidate. That candidate's source is not lost when the live path changes.
- Same harness SHA **`aec5c4735d594975644eef5f03118d23e4acffadc4afd3ee46ff8c389a769af0`**, live/frozen bytes identical.
- Native raw SHA **`8db4c8e7f2108785f802c5bf94cb67536d66bf48682bd56b9d15a5e74e8d254e`**, matching the saved public report; reader-recorded physical source mtime **1792462931.2066796** retained separately from the local raw copy's exact mtime_ns.
- Launcher32 completion remains **UNREPORTED**. Its potentially live stdout/stderr/exit were **not read, hashed or copied**. Only immutable launch request metadata was admitted. No process/profile query or action.

806 prior files were fingerprinted; **only the intended live PairCore path changes**. All other prior proof, frozen01, harness/base05/instant base/core/libraries and native maps remain unchanged. Old plans keep their historical Core pins; do not silently reuse those plans against the changed live Core—use the new plan or explicitly frozen source.

## Exact minimum code delta

After unchanged actual caster/A00G and PairReady alive/owner filters:

```jass
if remaining > 0 then
    // Reset count only: keep the running timer phase and fixed heading.
    set remaining = 4
    return false
endif
if notifying then
    // Preserve the idle/final-pulse reentrancy guard.
    return false
endif
```

No addition to remaining; no active-branch epoch change, TimerStart/PauseTimer, Emit, heading/facing, callback/diagnostic mutation, handle/API/framework. The former combined guard is split so a real active burst resets remaining, while the prior zero-remaining/notifying guard still blocks idle/final-pulse reentry. Fresh idle cast still follows the unchanged immediate4-shot/timer path; idle rate-limiting beyond that existing behavior is not implemented here.

Emit/epoch/Dispose/reinitialization/per-flight source-owner snapshots and spent-before-native-damage guards are byte-identical. Emit already commits remaining before external observer dispatch; after the observer it clears views/notifying only, so a reentrant active reset is not overwritten by a stale remaining assignment. This is source inspection, not native adversarial callback proof. Latest cast aim remains deferred; this unit intentionally retains the old fixed heading on active recast.

Core conceptual diff **+9/-4 authored lines**, including updated comments. No harness assertion, native qualification, calibration, HP/regen control, cadence, clearance or deadline change. Regression/public native effects—not producer log assertions—remain the acceptance oracle.

## Parent build/native path

Exact unchanged-builder invocation: **`build-plan-recast-green01.json` `.argv` / `.shell`**. All10 hashes are pinned; new logger/bootstrap are label-only RED02 variants. Import order is TimerUtils → WorldBounds → DummyRecycler → immutable Missiles → RecastLogGreen01 → corrected PairCore → **unchanged RecastNativeTest** → RecastMapMainGreen01.

- Run **`rf-burst-recast-green-20261020-01`**; group **RFBurstRecast**, entry **RF_StartRecastTest** unchanged.
- Output `build/rf-burst-recast-green-20261020-01/rf-burst-recast-green-20261020-01.w3x` — **absent at handoff**.
- Relative log `Logs\RF-rf-burst-recast-green-20261020-01.txt`; exact absolute profile log and freshness-aware reader/report argv in the plan.
- Same instant-controller base SHA `dea9c6cbac7e486d7c4fc11267fc1ed7b17c483d11f6f1025ecad6f45dc5c7ad`; core/library pins unchanged.
- PairCore SHA **`f82e92301dea1dd64a1993843e4f04c929a58bd032b9908f87fa96eb18426d52`**.
- Plan SHA **`e15d0d7a5321cbf301fb224d0511e099b1dd0dddc2afdaa3f077fb3e68e0c6b0`**.

Parent compiles, then owns ONE fresh exact-profile read-only preflight **before observer**, protected launcher and bounded180-second observation. Launcher exit0 never proves game closure/profile release. Global20-game-second harness deadline unchanged; not a hard wall-clock guarantee. No worker compiler/JassHelper/pJASS/game/process/GUI/install/commit/review actions, tooling reruns or odd/full-checkpoint writes.

Conditional expected GREEN: three cases,0FAIL/0SKIP **only after** actual compilation/readiness/second native effect qualification; R03 must produce6 real shots/6 native10 hits/source actor/HP differential60 and preserved cadence/no extra immediate shot. No fabricated native check totals, shot timestamps, new GREEN or broad zero-latency claim. Parent must capture the actual result; Risk4 assessment/escalation and independent verification follow own native GREEN, not launched here.

## Observed static verification

ONE finite focused Diff/API/lint/hash pass: lint EXIT0,0 errors/4 handle-factory ownership warnings, empty stderr, no unknown direct calls. Verified exact allowed Core delta, unchanged ownership/epoch/source/damage guards, same harness, all27 frozen SHA/mtime pairs, only intended change among806 prior files, label-only variants, all10 plan pins/JSON, compiled map absent. Exact argv/raw stdout/stderr/unified diff/full artifact hashes: `recast-green01-static.json`. Static evidence is **not compiler/native GREEN or adversarial lifecycle proof**.
