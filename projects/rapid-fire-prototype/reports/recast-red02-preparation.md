# SCANNED_CORRECTION_READY — parent compilation02 pending

One bounded source correction only: in `RecastNativeTest.j` → `RemovedAbsent`, renamed local **region → fixtureIndex**. Exactly five identifier tokens/four lines changed; every other source byte is identical. Native controls, assertions, missing-interval FAILs, calibration, timing, public API and PairCore are unchanged. Partial S1/S2/S4 test setup only; T2 remains open.

## Actual compiler RED, not native behavior RED

Parent job29/build01 EXIT1; `build/rf-burst-recast-red-20261020-01/commands.json` records registered vjass EXIT1. Exact JassHelper log identifies PJASS generated line2775, `local integer region=0`: **`Symbol region already defined as type`**. Actual Classic common.j declares region as a native type. Wine descriptor diagnostics appear after the causal compiler error; no process restart/kill/query or environmental recovery was attempted.

No game/native recast01 result exists from this failed build. The correction has **not** been compiled; no compiler GREEN, instant-cast/window qualification or R03 behavior RED is claimed.

## Frozen before source change

NEW `reports/frozen-recast-red01/` retains16 files with guard/no overwrite and SHA256 manifest:

- Original harness SHA `9dc12b73bb7248af4b935ac29b848035dbe5aa361790e8075c6e5ed9fa620f63`, original01 logger/bootstrap/plan.
- Failed build01 entry/command/commands and saved result/stdout/stderr plus original01 reports.
- Exact registered JassHelper log, including trailing diagnostics, copied as bytes. SHA `0b669c656cdd6e23afe53b8d739c441568e03fda9a2c0be5cb30c0bca26ed7df`.

All16 frozen payloads match their manifest. Original artifacts remain in place; only the explicitly allowed live harness differs from its frozen01 source. Original01 plan/logger/bootstrap/build evidence were not edited; retain the failed build directory. All359 previously protected inputs/proof files remain unchanged. PairCore7fe99448… / instant base dea9c6cb… / core adc5ffd9… pins match.

## New02 recipe — not executed

Exact parent build invocation is `build-plan-recast-red02.json` **`.argv` / `.shell`**; `.inputs_sha256` pins all10 inputs. Imports use new **RecastLogRed02**, unchanged PairCore, corrected RecastNativeTest, new **RecastMapMainRed02**, with the same pinned core/libraries and instant-controller base. Logger/bootstrap are byte-identical01 copies except run-ID string01→02. Public entry **RF_StartRecastTest**, group **RFBurstRecast** unchanged.

- Run: `rf-burst-recast-red-20261020-02`.
- Output: `build/rf-burst-recast-red-20261020-02/rf-burst-recast-red-20261020-02.w3x` — **absent at handoff**.
- Relative native log: `Logs\RF-rf-burst-recast-red-20261020-02.txt`.
- Exact absolute log and freshness-aware public reader argv/report are in the02 plan; worker neither checks runtime logs/profile nor starts an observer/game.
- Corrected harness SHA `aec5c4735d594975644eef5f03118d23e4acffadc4afd3ee46ff8c389a769af0`.
- Plan SHA `78e4d6089474e792e2447451843067b492003ebcb18e2b8ebc4d0615e3bc42bc`.

Parent owns next foreground/background compilation arrangement and later exact-profile preflight BEFORE any observer/protected launch. No automatic native attempt or retry is queued.

## Static self-verification and unchanged expectations

ONE focused diff/hash/API/lint pass: exact frozen-source replacement and five-token-only diff verified; every other function unchanged; new02 variants run-label-only; all10 plan pins/359 protected files match. Lint EXIT0,0 errors/13 ownership warnings, empty stderr; no unknown direct calls including expressions. Exact argv/raw stdout/stderr, unified diff and source hashes are in `recast-red02-static.json`.

**Static limitation:** wc3lint/API lexical scanning does not generally detect reserved-type local-name collisions or compile JASS. The targeted check confirms actual common.j declares `region` and not `fixtureIndex`; this is not a substitute for parent JassHelper/pJASS results. Strongest status **Scanned**, corrected test-source scope only.

After actual compilation and native readiness, R03 still requires second matching caster/A00G/actual-point SPELL_EFFECT while observed SHOT count remains2 and before secondShot+.25, after a future-tick issue at secondShot+.125. Late/missing/wrong events remain fixture ABORT. Only if qualified, unchanged active-ignore PairCore is expected to yield4 shots/4 native hits/paired HP differential40 instead of6/6/60, producing **eight conditional behavior FAILs**. Global20-game-second/observer180-second budgets and all assertions are unchanged. None of those native outcomes has been observed here. No emitter correction, full S2 implementation, tooling rerun, odd/checkpoint/mirror edit or native command in this unit.
