# Native03 — failed at neighborhood readiness

**NATIVE03FAILED_AT_NEIGHBORHOOD_READINESS.** Run `rf-pathing-20261019-03`, guarded launch attempt02, actually executed. Public saved [report](native-rf-pathing-20261019-03.json) and [raw log](RF-rf-pathing-20261019-03.txt): `COMPLETE|1|80|1|1`, **17 PASS /61 OBS /1 FAIL /1 SKIP**. All80 records belong to O01-open. Monitorjob10/public reader EXIT1; gamejob11 subsequently EXIT0 after approximately59s, from the authoritative exit notification and `native-launch-03-attempt02.exit.json`. Termination cause is not established; game exit0 does not override reader1.

Map SHA `309429218412216e866e12ce2a08847be8fc0f8bc65ee4f62fe1a9816cbd549e` is the saved build/launch identity, not a new rehash. Attempt02 proof remains in `native-launch-03-attempt02.{json,stdout.txt,stderr.txt,exit.json}`; reader proof in `native-reader-03-attempt02.{exit.json,stderr.txt,stdout.json}`. Report freshness: launch1792447961.1100638, source mtime1792447974.4079745; saved source SHA `83b27633812c0c2b246ba151bd56d9395a3a1c372464431081690c6384864ca3`. The original03 guard refusal and all01/02 proof remain unchanged.

## What worked, and where readiness stopped

At all three proposals: native Move accepted, positive observed displacement, order0 with3 stable XY intervals (0.375s stable window, reached at0.625s elapsed), live rest captured before reference removal. Independent strict SAME-anchor body placement was true within per-axis tolerance1. The stable-rest correction therefore worked for those observations, not for an entire neighborhood.

| Site | Actual rest anchor | First rejected neighbor wanted | Native actual placement |
|---|---|---|---|
| 0 | (-1295.402,-511.959) | (-975.402,-831.959) | (-912,-912) |
| 1 | (-1305.582,-1011.194) | (-1305.582,-1331.194) | (-1360,-1232) |
| 2 | (-2063.403,-512.010) | (-2383.403,-192.010) | (-2416,-272) |

Each rejected neighbor logged `occupies=false`, then `rest-observed-neighborhood-not-qualified`. There are14 body-placement OBS records:11 true and3 false, plus3 moved-rest references. These are observations, not17 geometry PASSs. All17 PASSs are **public-reference-clearance** checks (`removedType=0 presentInNativeGroup=false`): scoped removal evidence for those references only, not complete resource cleanup.

After the third proposal, FAIL **`open-fixture-aborted`**, detail **`no independent native local patch within three proposals`**. The one SKIP is `multiplayer-and-production-animation`; unreached cases are not individually SKIP/PASS.

## Proof limits and decision

Read-only `src/NativeProbe.j` Open phases2–4 require all12 body samples before creating the production actor, invoking Query/Eligible, executing Step/TryStep and advancing to the later cases. These three proposals failed earlier and finished in O01. No actor creation/step03, collision-candidate query, obstacle geometry, helper query visibility/restoration lifecycle or Channel03 was reached/accepted. Controller creation, path-helper initialization/guards and cleanup calls are not those proofs. Historical native01 Channel establishes scripted capability only, not final UI or03 acceptance.

No03 rejection by the item predicate or its tolerance is demonstrated. The cause of displaced neighbor placement (cliff/tree/other) is unknown; these three unsuitable coarse proposals do not prove that the whole map lacks a suitable area. No production350 mover, Stop/takeover/handoff/resume, burst/cadence/damage or animation/UI implementation/acceptance is delivered; multiplayer/editor-save and complete resource cleanup remain unproved.

**S19's ONE measurement is consumed. T1 blocked(awaiting-human-fixture-selection-decision); T2–T5 pending.** Recommended route ONLY: first inspect static pathing/terrain of the owned base to choose an adequate fixture area or local sites, rather than guess another origin or loosen samples. That inspection was not performed here. Any further native experiment needs a separate human decision; no03 retry or04 is authorized/queued. This unit only reads saved evidence and the relevant source branch, updates documentation/status/checkpoint and performs passive JSON/path/checkpoint readback; no new functional verification or runtime action.
