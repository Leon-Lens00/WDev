# GUI03 — visual inventory open/close observed; bounded evaluation complete

**S1 actual computer-use evaluation and S7's bounded open/close probe are executed with limitations.** Inventory visibly opened and closed while recording was active; the parent viewed both actual images. The owned game is closed. **Native inventory-event correlation remains unproved**, not an additional user-required blocking gate or grounds to discard valid visual evidence. This is not library-wide correctness or semantic certification.

## Actual input and viewed states

| Sequence | Retained evidence / observed state |
| --- | --- |
| Focus, hero, chat | Worker `mvfxito7-u-49hx` verified game focus, selected Lich hero and chat closed before activation. |
| B to open, **1792455220.499839** | [Open input](gui/techgui03/b-open-input.json): actual `ydotool key 48:1 48:0`, exit 0; recording acknowledged. |
| Open state | [Viewed open-settled image](screens/techgui03-open-settled.png): **30-slot panel, page 1/5**, with **Recording / techgui03 / rows=2** banner. |
| B to close, **1792455237.7151105** | [Close input](gui/techgui03/b-close-input.json): same KEY_B=48 down/up, exit 0, hero selected. |
| Closed state | [Viewed closed image](screens/techgui03-closed.png): panel gone; same **Calis Wraithson, level 1 Lich** selected. |

The parent actually viewed both states; this report also inspected the retained images. Screenshot filenames alone are not the proof: the image content is paired with actual input records and the same owned identity/timeline. The recording remained active through the bounded open/close operation, then was stopped.

## Recorder correlation gap — unknown cause, not a failed visual probe

The [existing public reader result](gui/techgui03/operator-reader-techgui03.json) is `observation_complete`: exit **0** recorded in [closure.json](gui/techgui03/closure.json), **1 chunk / 3 rows**, `USER_STOP`, dropped=0. Rows are **BEGIN / STATS / TERMINAL** only; **no INV_OPEN/CLOSE** was captured. Keep `semantic_certification=false`, `native_inventory_events_verified=false` and `runtime_writing_verified=false`; do not fabricate callback evidence.

STATS **str=15 / agi=14 / int=20** matches the viewed Lich HUD. There is **no evidence of a wrong-hero explanation**. Missing native labels are a real recorder-correlation gap with **UNKNOWN root cause**. They were not an explicit user acceptance requirement. Visual operation is observed independently; recorder semantics are not certified.

The [operator chunk](gui/techgui03/operator-evidence/techgui03/IL141M-inv-manual-20261019-01--techgui03--0.pld) and [watcher-retained chunk](gui/techgui03/native-logs/IL141M-inv-manual-20261019-01--techgui03--0.pld) match SHA-256 `55348f185952b1d1e9038696fc086c04abdb8ba90abb8b784c69378ad2a4eb52`; see [operator manifest](gui/techgui03/operator-evidence/techgui03/source-manifest.json) and [native provenance](gui/techgui03/native-log-provenance.json).

## Final closure supersedes the intermediate live warning

- Identity: **PID 90578 / start 2862638**, label **techgui03**, floor **1792455090.6222274**; [process identity](gui/techgui03/process-identity.json) and [owned session](gui/techgui03/owned-session.json).
- Same validated manual map SHA-256: `26d7faf7953feb98a991222c77bf92c1fed58ffef534e2a874ba8ddd3a8f28fe` ([launch request](gui/techgui03/launch-request.json)). Repair label `techgui03r` was permitted but **not used** in retained data.
- Initial leading-dash `ydotool type` syntax was rejected and corrected with `--` **before recording began** (parent Log L32); no implementation change.
- [Intermediate operator record](gui/techgui03/desktop-closure-final.json), despite its filename, still shows the PID **live at 1792455289.8402395** after Alt+F4 and guarded Salir click.
- **Final watcher 26 exit 0 after 3m39s** proves PID absence/profile empty and fresh STOP captured at **1792455333.7249367** ([watcher record](gui/techgui03/process-watcher-closure.json)); **launcher 25 exit 0 after 3m53s**.
- [Parent closure](gui/techgui03/closure.json) reconciles those final records and launcher completion, superseding the earlier live warning. **Termination mechanism remains UNPROVED**; delivered exit input does not establish causality. No new process check was performed here.

**All nine owned task games are closed** (previous eight plus GUI03), **not nine successful GUI tests**.

## Scope and historical preservation

T3's bounded requested evaluation is **done with limitations**, not all-tests-green or blanket certification. The four native03 modes remain **60 cases / 142 PASS / 161 FAIL / 68 OBS / 0 SKIP**: repeated assertions, **not 161 distinct bugs**. Original core/configuration and all earlier maps/logs/reports remain unchanged. No multiplayer, RSS, FPS or long-duration certification follows.

[Historical FINAL](FINAL.md), [historical summary](summary.json) and [GUI02 addendum](GUI02-ADDENDUM.md) retain their original cutoffs and outcomes; this addendum does not rewrite GUI02's operation failure. [Machine result](gui/techgui03/result.json) separates positive visual evidence from absent native correlation and confirmed closure.

**No further game, recorder fix or verification is needed or authorized for this bounded visual evaluation.** Recorder-coverage investigation is optional, separate future work **only if requested**, not a currently blocked task. Report-time checks were structural-only JSON/evidence/hash/link processing; no tests, public readers, builds, GUI actions, process checks, source fixes or reviews were run.
