# Native04 — failed prerequisite; reference-design decision required

**Not a complete prototype or collision certificate.** Actual `rf-pathing-20261019-04`: `COMPLETE|12|1566|4|1`, **213 PASS /1348 OBS /4 FAIL /1 SKIP**, independently counted from the saved public [report](native-rf-pathing-20261019-04.json); saved [raw log](RF-rf-pathing-20261019-04.txt) contains1566 CHECKs and the same COMPLETE. Public reader/monitorjob13 EXIT1. Gamejob14 subsequently authoritative EXIT0 after2m28s; termination cause is not established, and exit0 does not override reader1.

Map SHA **`2e20c15e83fc3b5bf459a5cc72f5aad938f6dfb549e76811b6d6630f11286ad9`**; compiled script SHA `827e014d140c387066b1c2f1f5bdae6dd3c595b60b5de16c1a8684eda44e106e`, from saved parent build output, not new hashes. Streams: `probe-build-04.*`, `native-launch-04.*`, `native-reader-04.*`. Report freshness: launch1792449798.0046067/source mtime1792449828.5229068; saved raw SHA `89e0e0cc4913667a0e1a91eebd10ae83b950ece295a27e5527fc3ce87eaae884`. No stream/source/map/build-plan bytes were changed here.

## Invalid reference premise — no source edit

Read-only `NativeReference.j`57–64 confirms **RF_BodyOccupies is CreateUnit + type/XY<=1, with NO Move**. It measures spawn placement, **not walkability or traversability**. Its name/comments and earlier preparation descriptions must not be treated as movement truth. Opening Move/rest establishes only that opening movement/rest, not the later samples. The213 PASSs cannot repair this premise. Source/comments remain untouched; freeze04 first before any future correction. Diagnosis also uses parent-forwarded read-only review `mvfudw6n-h-6qsg`, not a new review invocation or runtime check.

## Four bounded readiness aborts, not four mover failures

| Case | Actual evidence and missing proof |
|---|---|
| S02-static-step | Remote(1792,-6656) spawned exactly, `occupies=true`; static/cliff readiness guard aborted. Actual04 walkability flag/cliff levels were NOT logged (their log is in the success branch). Historical blocked flag is not fresh04 evidence. **Blocked8-step phase never reached.** |
| D03-tree | Anchor(-1455.402,4352.040) candidate prepositive; actual tree(-1408,4352), life50, displaced47.402X. Strict placement guard aborted before alive/dead/removed-tree collision assertions. No universal grid/placement-cause inference. |
| G08-gap64 | Footmen(-1455.5,4289)/(-1455.5,4415), actual clearance64, raw range16=false for both. Midpoint request(-1455.5,4352) spawned(-1392,4304), `occupies=false`; guard aborted BEFORE candidate gap64 query. Cause unresolved; not production mover failure. |
| C11-cliff | Same remote exact spawn and readiness abort as S02; no actual04 walkability/cliff log or qualified cliff collision assertion. |

All4 FAIL records are `fixture-aborted`; each states no geometry assertions accepted. The sole SKIP is production/multiplayer/animation, not a full proof or a substitute for these aborts.

## Scoped positive observations — do not generalize

- **Open:** rank1 actual rest(-1455.402,4352.040) admitted by static layout gate; candidate open positive;8-unit XY-only step to(-2215.5,4352), facing90/order0. Static admission/spawn samples are not continuous native-movement truth.
- **Ground unit:** candidate prepositive, actual raw range16=true/candidate false while unit present, removal positive. This is unmasked local evidence, not universal unit footprint semantics.
- **Building:** calibrated center(-1408,4352), spawn-correlated axial/diagonal brackets192..224. Candidate edge(-1216,4352)/corner(-1216,4544) rejected; outside224 and removal positives observed. **No dedicated building-center negative.** Corner raw unit-range=false; item displacement caused the candidate rejection. Brackets remain spawn-correlated, not independently proven movement boundaries.
- **Gaps:** actual16 clearance/candidate reject, both raw native ranges true; actual32 clearance/candidate false is **OBS, not PASS**.64 candidate query was not reached.
- **Items/order:** query preserved actor XY/facing90/active Move851986; visible/hidden item state and coordinates restored. Explicit fixture-controller Stop then8-step accepted; oversized16-step rejected. This does not prove production Stop/takeover/handoff/resume or blocked8-step rejection.
- **Helper:** SetItemPosition visibility observed true, rehide false, query-exit visibility false/type0; local lifecycle/restoration evidence, **not complete resource cleanup**.
- **Bounds:** discrete footprint-crossing/out-of-bounds rejections, not continuous collision coverage.
- **Channel:** native order/effect/source/ability/target(-1359.402,4512.040) matched by0.750s; controller(-5500,-5500). Scripted capability only, not final UI/burst/damage/300% animation.

All production350 continuous movement, Stop/takeover/handoff/resume, burst/cadence/damage,300% animation/final UI, multiplayer/editor-save and complete resource cleanup remain unimplemented/unproved. No source fix or further experiment is implied by the scoped positives.

## One future decision, not an automatic05

**S20's bounded04 experiment is consumed. T1 blocked(awaiting-human-reference-design-decision); T2–T5 pending.** Proposal ONLY: separate spawn-placement checks from actual native MOVEMENT/walkability references, and qualify the tree at repeatable ACTUAL coordinates; preserve the collision predicate/safety thresholds. Parent presents one decision: authorize new bounded evidence-design correction/validation, or retain this blocked candidate. No blind rerun, sample/tolerance loosening,05 queue or new experiment is authorized here. This unit only updates findings/README/status/checkpoint and passively reads saved JSON/paths/checkpoint; no implementation/test/build/game/retry/process action or additional functional verification.
