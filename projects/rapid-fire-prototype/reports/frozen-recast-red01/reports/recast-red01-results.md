# R03 source prepared — actual compilation failed, no native RED

**RECAST_RED01_COMPILATION_FAILED_NATIVE_NOT_RUN.** Parent build job29 exited **1** after approximately3s. This is a compiler failure, **not behavior RED, native latency evidence or native GREEN**. No task newly completed; Specs unchanged.

## Prepared scope

Worker `mvg18x59-13-lc0t` delivered610 new JASS lines: retained B01/B02 regression plus fresh-scene R03 actual second matching SPELL_EFFECT at SHOT2, strictly before the next.25 boundary. RecastNativeTest reported SHA256 `9dc12b73bb7248af4b935ac29b848035dbe5aa361790e8075c6e5ed9fa620f63`; PairCore unchanged `7fe99448ba2fff01e6bd67675c8a71e30ad7b11b35268e65b4f74ec0a64e1078`. The **eight conditional expected behavior FAILs are NOT observed**. Actual active-window readiness, zero-latency and recast remain unproved. [Preparation](recast-red01-preparation.md) is the pre-build snapshot, not current compilation status.

## Saved actual compiler evidence

- [Job29 argv/exit](recast-red01-build.exit.json): EXIT1; [stdout](recast-red01-build.stdout.txt) empty; [stderr](recast-red01-build.stderr.txt) exactly `error: tool failed (1); see commands.json` followed by newline.
- [commands.json](../build/rf-burst-recast-red-20261020-01/commands.json): registered `vjass` returncode1, no valid JassHelper output.
- Actual registered log: `/home/snz/Documentos/ChatGPT/FrozenThone/runtime/wc3-tools/reports/vjass-20261019-210744-895709/jasshelper.log`. Preprocessing/structs succeeded; PJASS compilation failed at generated line2775 in `RFBurstRecastTest___RemovedAbsent`: `local integer region= 0`, **`Symbol region already defined as type`**.
- Compiled map `build/rf-burst-recast-red-20261020-01/rf-burst-recast-red-20261020-01.w3x` **ABSENT**. No native run.

Wine client descriptor errors are secondary noise, **not authorization to restart/kill/recover**. Profile availability remains UNKNOWN; future runtime still requires fresh exact-profile preflight before observer and protected guard. Earlier wrapper exits do not establish game closure.

## Next bounded correction — planned ONLY

Before editing, freeze01 harness/plan/logger/bootstrap and preserve all compile-failure evidence. Rename **ONLY RemovedAbsent's local `region`→`fixtureIndex`**, with new02 logger/bootstrap/plan/run-ID for the corrected build. No application recast fix, suppressed assertions, harness behavior or metadata changes. Parent has **not applied the correction or rebuilt**; this worker performs neither. Meaningful native RED is still required before any application recast correction.

T1 done SCOPED; T2 in_progress(compilationfailed/diagnosedboundedcorrectionnext); T3 full integration pending, T4 future units unverified/prior B01/B02 independent PASS unchanged, T5 pending. Full exact checkpoint mirror precedes the correction writer. Bookkeeping/passive saved-evidence/JSON/path readback only; no source/map/raw change, new check, compiler rerun or recovery action.
