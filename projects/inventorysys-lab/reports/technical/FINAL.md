# Needs your decision — technical probes executed; clean GUI unproved

**Native probes completed with FAILs; S1 is not met overall.** The original system is unchanged and **all seven owned games are closed** according to retained PID/profile and launcher evidence. T3 remains blocked on clean GUI proof, not on process closure. This T7 report analyzes existing evidence only; it performs no new test, reader, build, compiler, GUI, process check, correction or review round.

**Choose next:** authorize a **NEW bounded focus/input diagnosis before any GUI retry**, or accept this report with GUI unproved. Neither choice authorizes an automatic new game run.

| Spec | Disposition in the authorized observed scope |
| --- | --- |
| S1 | **UNMET overall:** technical in-game probes ran and closures are proved; actual clean GUI inventory open/close/selection is unproved. |
| S2 | Met: retained native compile/package and owned runtime evidence; not a gameplay approval. |
| S3 | Met: isolated fixture/verification children used; selected independent proof archived below. |
| S4 | Met: bounded corrections, regressions, new attempts and failed evidence retained; every owned instance closed. No further correction/retry here. |

## 1. Engine outcome — assertion counts, not bug counts

All run paths below are relative to this directory. Native rows refer to the **IL141 sequence field**, not physical Preload-file line numbers. Each mode has `game-result.json`, `reader.*`, its native `.pld`, `native-log-provenance.json`, `owned-session.json` and `closure.json` under `runs/itl-<mode>-20261019-03/`.

| Mode | Cases | PASS | FAIL | OBS | SKIP | COMPLETE sequence | Strict reader exit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| button | 21 | 55 | 56 | 25 | 0 | 381 | 1 |
| picture | 19 | 43 | 52 | 21 | 0 | 342 | 1 |
| text | 19 | 43 | 52 | 21 | 0 | 342 | 1 |
| camera | 1 | 1 | 1 | 1 | 0 | 9 | 1 |
| **Total** | **60** | **142** | **161** | **68** | **0** | — | **1 each; inconclusive** |

These are repeated assertions across cases, **not 161 distinct bugs**. Structural COMPLETE does not erase FAIL or OBS. SKIP=0 means no automatic case was skipped, not that multiplayer, RSS/FPS, long-duration behavior or GUI semantics were covered.

### Findings: observed behavior → static support → uncertainty

Source references in this section use the original, unmodified [`baseline/members/war3map.j`](../../baseline/members/war3map.j), prefixed below as `J`. Source was read only for correlation: no private storage getters or backing-array runtime oracles were used. Do not assume all failures have one cause.

**A. Owned UIButton timer retirement deficits, before harness cleanup**

- Button case 19: rows 321–323 show actual click/acquisition, suppression, then reacceptance; 327–330 record heartbeat 30, acquired=2, expired=2, released=0, destroyed=0, **deficit=2**. Case 20 destroys a pending button (342–345); 346–349 show heartbeat 16, acquired=1, expired=1, released=0, destroyed=0, **deficit=1**. Actual owned expiry readiness passed in both.
- Cleanup is separate: rows 331–332 retire 2 tracked timers, 350–351 retire 1, with unretired=0. This does **not** retroactively turn baseline deficits into PASS.
- Static support: `J:5381–5392`, `s__UIButton_enableButtonCallback`, gets the expired timer, enables the button and nulls its local timer without `ReleaseTimer`. Timer creation/polling uses that callback at `J:5416`.
- **Not InventoryCore_GracePeriod:** `J:6372–6379` explicitly calls `ReleaseTimer(t)` at 6378. The result is bounded owned-callback retirement evidence, not a claim about every timer or process-memory growth.

**B. Public destructor return does not prove native-unit removal**

- All UI modes: case 1 rows 7–11 show exactly one constructor-native `uidm`, positive ID, direct projection movement (+64,+32), destructor before/after markers, then `actual-type=1969841261` rather than 0. Repeated hidden pairs (cases 2–17; e.g. rows 21 and 28) retain this immediate observation **before harness native cleanup**.
- UIText has direct static support: constructor creates the dummy (`J:5605–5607`); destroy only destroys its texttag and adjusts membership (`J:5644–5653`), omitting `RemoveUnit` and struct deallocation.
- **UIButton/UIPicture are different:** their destructors **do call RemoveUnit** (`J:5216–5224`, `5506–5514`). The immediate native type persistence is observed, but source alone does not establish its mechanism, engine removal-settling contract, or permanent native-unit leakage. Do not attribute these observations to the UIText omission or invent a common explanation.

**C. Unreclaimed class slots under the pinned allocator contract**

- UI cases 2–17 perform immediate same-class destroy/recreate with no intervening same-class allocation. Case 2 row 25 reports button 50→51, picture 24→25, text 23→24 rather than reuse; rows 18/24 provide constructor controls.
- Static support: freelist-first allocate/deallocate contracts at `J:1140–1165` (text), `1168–1193` (picture), `1196–1221` (button). Public destructors cited above never call those generated deallocators. This supports unreclaimed struct slots within this source contract, **not RSS**, exhaustion timing, long-match instability or a measured process leak.

**D. Class membership: bulk update misses one after A/B/C → destroy A → show D**

- Button case 21 rows 373–377; picture/text case 19 rows 334–338: all three units live and all direct movements pass readiness, but bulk comparison reports **changed=2, missing=1**. Member 2 remains at bulk X≈82.373 vs direct X≈178.373 (button/picture), or 79.680 vs 175.680 (text). Other two members agree.
- Static support: show appends at `CountShow` then increments (`J:5243–5248`, `5533–5538`, `5678–5683`); destroy copies from `AllShow[CountShow]` **before** decrement (`J:5220–5222`, `5510–5512`, `5648–5650`), unlike hide's decrement-first path. `updateAll` starts at `CountShow` (`J:5328–5335`, `5582–5590`, `5694–5701`), including an extra slot. D replacement matters to this correlation.
- This supports a visible-list bookkeeping finding through public/native position differences, not a private-array runtime inspection. Shared membership is explicitly not restored (button 378; picture/text 339); each disposable map ends. Native positions are not proof of visual text visibility, textures, equipment correctness or mouse UX.

**E. Camera: before marker, no return marker, watchdog FAIL**

- Camera case 1: row 3 prearms watchdog; row 4 creates public camera ID=2; row 5 is `before=Camera.destroy ... call-once no-retry`; row 6 is watchdog FAIL; row 7 says cleanup unknown; rows 8–9 persist RESULT/COMPLETE. **No after-return marker exists.**
- Static support: `J:3535–3544` releases vector/matrix fields then directly calls `s__Camera_destroy(this)` recursively.
- **Runtime mechanism remains unproved.** This mode has **no heartbeat telemetry**. Do not claim a proved crash, stack mechanism, whole-VM freeze, successful cleanup or allocator restoration. Only the bounded call nonreturn/watchdog observation and static recursion are established; no retry occurred.

Positive evidence remains useful: each UI case 1 constructor/projection passed; case 18 repeat-show/bulk/direct, hide and re-show controls passed (rows 306–309). UIText hide preserves native position, while button/picture hide moves to origin. The 16 hidden-pair short timing OBS is harness-inclusive, not FPS certification. Routine fixture cameras and last-case live texttags are bounded and retained until map shutdown.

## 2. Clean GUI attempt — logging success is not semantic success

The retained public manual reader exited **0**, reporting `observation_complete`, **1 chunk / 3 rows**, `USER_STOP`, dropped=0, **semantic_certification=false** (also `runtime_writing_verified=false`). `gui/techgui01/operator-evidence/IL141M-inv-manual-20261019-01--techgui01--0.pld` contains only:

| Sequence | Time (ms) | Event | Meaning |
| ---: | ---: | --- | --- |
| 1 | 185187 | BEGIN | Recording began. |
| 2 | 185187 | STATS | str=22 agi=13 int=17 gold=0 sample. |
| 3 | 282750 | TERMINAL | reason=USER_STOP rows=3 dropped=0. |

Actual mouse/keyboard attempts and recorder acknowledgement are recorded in `operator-actions.json`; **they did not prove inventory opening/closing or selection**. There are no INV_OPEN/INV_CLOSE/selection events, and the operator states that screenshots do not show an opened panel. Screenshot names such as `techgui01-open.png` are not semantic evidence by themselves. No lingering-glow, equipment or multiplayer verdict follows from this attempt.

Observer job **22 timed out with exit 124 at 300 seconds** (`observer-timeout.json`), **not retried**. The operator later retained the genuine stop chunk and ran the public manual reader successfully. That later protocol result does **not** silently convert the observer timeout into PASS.

Input history: the legacy focus dispatcher failed (exit 7; intermediate `desktop-closure.json`); focus was later restored externally. Parent Log L25 records wtype producing no visible text while ydotool recorder commands succeeded. **Root cause is UNKNOWN**; this is not proof of a particular configuration/input bug, nor authority to change desktop configuration. Only new human authorization can open a bounded diagnosis, before any GUI retry.

## 3. Closure — all seven owned sessions closed

| Attempt | Owned PID | Launcher job / exit | Retained closure record |
| --- | ---: | --- | --- |
| button01 | 69143 | 8 / 0 | `runs/itl-button-20261019-01/closure.json` |
| button02 | 72555 | 11 / 0 | `runs/itl-button-20261019-02/closure.json` |
| button03 | 76894 | 13 / 0 | `runs/itl-button-20261019-03/closure.json` |
| picture03 | 78285 | 15 / 0 | `runs/itl-picture-20261019-03/closure.json` |
| text03 | 79284 | 17 / 0 | `runs/itl-text-20261019-03/closure.json` |
| camera03 | 80234 | 19 / 0 | `runs/itl-camera-20261019-03/closure.json` |
| techgui01 | 81879 | 21 / 0 | `gui/techgui01/closure.json` |

Every listed final record proves owned PID absence and an empty profile game-process list; ownership/start generations were retained. GUI closure precedence matters: worker `desktop-closure-final.json` at **1792452883.4007547** still saw PID 81879 alive. Parent's **fresh reconciliation at 1792452998.501886** proves absence/profile free (`parent-reconciliation.json`); final `closure.json` supersedes the still-live snapshot. Launcher 21 exited 0 after **7m10s**. Closure is established, but the **termination mechanism is not established** for these later exits. Alt+F4 confirmations, aborted affirmative guards or delivered clicks do not prove exit causality.

## 4. Check history — tooling and engine are separate

All results here were already recorded; **nothing in this table was rerun for T7**.

| Gate / history | Retained result | Evidence |
| --- | --- | --- |
| Initial adapter tooling | 10 focused / full **77** tests, exit 0 | Parent Log L9; `parent-tests.*` retains full 77. |
| Parameter-name regression | RED exit 1; 11 focused GREEN exit 0; full **78** exit 0 | `type-name-{red,green,suite}.*`; event→eventName only; engine causality unproved. |
| Initial independent verification | 11 focused / 78 suite exit 0; two oracle regressions RED exit 1; archive audit exit 0 over 8 maps | `verification/initial/`; two **harness** blockers, not InventorySys verdicts. |
| Parent bounded oracle correction | Two regressions RED exit **1**, GREEN exit **0**, full **80** exit **0** | `oracles-{red,green,suite}.*`; preserves old failures. |
| Native package 03 | Four pJASS exit 0, four wc3ctl exit 0, preservation/roundtrip exit 0 each | Each 03 `commands.json` / `build.json`; archived targeted proof. |
| Same independent targeted recheck | **13 tests exit 0**, recheck exit 0; **52 identities/map** over four 03 maps | `verification/targeted/{targeted.*,recheck.*,proof.json}`. |
| Frozen source 02→03 | **Only four expressions:** 3 owner substitutions to CAMERA_DUMMY_PLAYER; actual owned expiry prerequisite | `verification/targeted/source.diff`; other technical source bytes unchanged. |
| First button01 attempt | Observer 124 at 60s; no log/COMPLETE; main menu | Closure record / parent Log L11: **no native system conclusion**. |
| Corrected button02 attempt | Reader 1; 1 case / 0 PASS / 1 FAIL / 1 OBS | Wrong-owner fixture readiness failure; **not a core verdict**. |
| Four native03 modes | Reader 1 each, preserving all native FAILs | Section 1; these are **60 engine cases**, not 77/78/80 Python tests. |
| GUI observer / public reader | Observer **124**; later public reader **0**, protocol only | Section 2; clean GUI remains unproved. |
| Native ASSESS | **Unassessable (untracked); no native approval** | Parent Log L9/L18; independent source review/recheck already completed, no new round. |
| Delivery | No commits (identity unavailable); no publication | Parent task/Log; no Git actions performed for this report. |

**Risk line item 3:** adapter instrumentation at shared original UI/timer boundaries and destructive membership probes require careful interpretation. The scoped independent source review and targeted recheck are already complete; they validate their stated harness/preservation scope, not runtime success or GUI semantics. Initial diagnostic extractor/wrapper errors were corrected during that existing verification (Log L17), not product defects or a new report-time round.

## 5. Preservation, proof archive and limits

- Original map remains SHA-256 `a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada`; original script `6a168b922c994d230d80c7c59ad601cb260fa3066f22b579c8784bcf3d0b4e46`. No original core fix. Prior automatic/manual reports, sources, maps, logs and metadata are not overwritten. Original credits remain unchanged; this is local evaluation, not publication or redistribution permission.
- Existing archive proof covers original-script byte restoration, prefix/named-member and 52 identity preservation per 03 map. WCT/WTG preservation is not editor-save certification. The generic build metadata label “manual observational recorder” does not redefine these destructive technical probes as clean GUI evidence.
- **Independent proof is now durable:** [initial manifest](verification/initial/manifest.json) copies only focused/suite/oracle-red/reader/archives `.exit/.stdout/.stderr`, `audit_archives.py`, `generated-functions.txt` from the authorized `verify-cgXzme` child. [Targeted manifest](verification/targeted/manifest.json) copies only targeted/recheck `.command/.exit/.stdout/.stderr`, `recheck.py`, `source.diff`, `proof.json` from `recheck-GwJGxd`. Manifests record exact source/destination paths, SHA-256, sizes and recorded exits. No home/cache/fixture trees copied; scratch sources untouched; scripts are inert archived text, **never executed here**.
- [Evidence index](verification/evidence-index.json) hashes retained native results/logs/readers/provenance/ownership/closures, GUI records, original map/script and historical tooling records used here. [Machine summary](summary.json) separates engine, GUI, closure, tooling, preservation and limits.
- **Unavailable/not attempted:** multiplayer/two-client synchronization, RSS, FPS and long-duration proof. Single-client native coordinates cannot certify visual text, texture, inventory/equipment UX, synchronization or leak-free long matches. Previous user-operated prueba01 remains separate, unchanged evidence, not a substitute for this missing clean technical GUI proof.

**Report-only checks:** exclusive creation of new reports/proof files; JSON parsing, arithmetic over retained counters, copy/hash identity, retained log/provenance hashes and link/anchor consistency. No functional reruns and no new process/GUI verification. Historical outcomes above must not be mistaken for report-time commands.

## Next decision

1. **Authorize NEW bounded focus/input diagnosis before any GUI retry**, with separately bounded scope; or
2. **Accept this report with clean GUI unproved.**

Until that decision: no automatic retry, no core fixes, no extra verification round. T3 remains blocked; S1 remains unmet overall.
