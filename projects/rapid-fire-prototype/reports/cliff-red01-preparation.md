# Cliff RED01 — preparation only

**PREPARED_NOT_COMPILED_NOT_NATIVE — Scanned only.** T2 / S27 prepares partial S3. Parent may compile; no new gameplay, Core callback or library change is authorized. No native RED has been observed. S26 Tree GREEN remains historical scoped evidence; this harness adds no unit-hit/HP regression coverage.

## Files and handoff

- `src/prototype/CliffNativeTest.j`: 508-line flight-only `RFBurstCliffTest`, entry `RF_StartCliffTest`; two cases only.
- `CliffLogRed01.j` / `CliffMapMainRed01.j`: Tree GREEN protocol/bootstrap, labels changed only.
- `build-plan-cliff-red01.json`: exact parent build argv, ten input pins, import order, output and reader template. `parent_play_argv` is a proposal, NOT a grant. No builder/game/reader executed here.
- `cliff-red01-static-selection.json`: parent-forwarded recorded summary, not a fresh worker query or native observation. Raw terrain words are not native Z. No height conversion formula is asserted.
- `cliff-red01-preparation.json`: finite lexical/API/type-name/pin verification and captured command results. These checks neither compile vJASS nor validate engine semantics.

All paths above are relative to `projects/rapid-fire-prototype/` (report names under `reports/`). Existing base, Core6442, Tree86770, libraries and build artifacts are untouched. No README/checkpoint edits.

## Admission before behavior

R08 actual actor `(-3136,2624)`; R09 fresh actor `(-3952,5136)`; controller `(-5500,-5500)`. Each requires actual placement within1, live owned unpaused pair with stable identity, exact ability/order/facing guards, padded world bounds, and full1500+160 unit/destructable corridor enumeration. No destructable life filter, no enemy fixtures, no dummy/unknown-unit exemptions, no forced placement/fly/pathing changes.

Native `GetLocationZ(actualActor)+80` is the unchanged launch world Z. Survey all fifty 30-unit nominal current→next segments of the full1500 ray with native ground heights and cliff levels. R08 requires unchanged levels, no sampled ground intersection and walkclear ray. R09 requires the FIRST sampled ground intersection to coincide with an UPWARD level transition within600, no earlier sampled hills/intersections/transitions, no descent or unexpected level. It rejects an unsuitable ramp/no-wall/native-placement fixture rather than lowering Z. Full corridor beyond wall is still enumerated and surveyed.

For every step log native current/next levels and ground heights, launch Z, native NE-corner level, and library threshold `(nextLevel-nativeNEcornerLevel)*bj_CLIFFHEIGHT`. Actual library callback condition is `.onCliff.exists AND currentLevel<nextLevel AND z<threshold`; current Core has neither onCliff nor onTerrain. The condition is OBS only, never an admission gate or proof of a library bug. Physical wall admission is independent of that optional implementation.

The survey is discrete at the library's nominal30-unit samples, not a continuous/swept geometry proof or native terrain-ramp flag API. It may conservatively ABORT when physical contact does not coincide with a sampled upward transition. Static selection cannot guarantee admission. Native values, placements, corridor occupancy and viability remain entirely unobserved.

## Lifetime oracle fixed before any native result

Speed1200 × simulation.025 =30. `speed=` calls `predict`; `OnCliff` runs BEFORE `OnOrient`, including the first tick's origin→predicted30 window. `OnOrient` promotes one sample; `OnFinish` closes at1500. At these loads four flights do not invoke scheduler dilation. Observer period.03125 gives at most37.5 units of observation lag; add one simulation step30 for last-live uncertainty.

If the survey's first wall segment is `[L,H]`, where `H=L+30`, fixed wall last-live advance is `[max(0,L-67.5),H]`, and first-absence age is `[max(0,L/1200-.025),H/1200+.025+.03125]`. H≤600 makes the upper age≤.55625, strictly disjoint from max-range absence `[1.225,1.30625]`. Flat last-live advance1410..1500 (conservative90 covers30+37.5 and sample phase), y±2; full-range absence as above. No tolerance widening after failure.

Four callback-scoped public births require allocated/launched/separate e000 dummy, correct visible source, current origin, logical owner, worldZ and east30 predicted step. No erroneous Player0 native-dummy birth-owner requirement. Record public births and three .25 intervals (±.03125), then fresh bounded `Missiles.collection` scans of allocation/source/XY/Z. IDs/dummy IDs retained only as comparison tokens, never dereferenced after closure. Unobserved closure before allocator reuse ABORTs. Every serial retains last live advance/XY/time and first absence. Native closure is not dummy recycling.

After effect+2.5s, R08 must pass before R09. Before old pair disposal/unit removal/new creation, freshly scan original actor's collection and require all four observed closed. Different corridor y avoids old-dummy contamination; any old dummy entering the new corridor is an unknown object and ABORTs, not bypassed. No blind sleep or retry.

Admitted R09 late/far-range flights are **behavior FAIL**, never fixture ABORT. Per-serial `actual-past-physical-wall-travel` observations require actual live XY beyond H+30, and `qualified-RED-travel-evidence` records whether all four then finish near full range. A wrong-location absence or missing callback alone is NOT the expected qualified RED proof. Runtime stops after two assessed cases or fixture ABORT, effect deadline2s/global15s.

## Remaining proof

Native RED/GREEN TDD is inapplicable to this preparation-only worker: no meaningful native RED exists without separately authorized compilation and human gameplay. Parent compilation, then any separately authorized single native run and captured-reader assessment remain pending. No cliff collision, full S3, global integration, visual, editor-save or multiplayer acceptance is claimed.
