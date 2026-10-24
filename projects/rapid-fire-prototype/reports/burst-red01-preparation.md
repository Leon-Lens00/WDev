# PREPARED_RED_B01_B02 — native execution pending parent

**Delivered executable source and pinned plan, not compiled or native-proven.** One scripted cast tests default four-shot count, .25s cadence and real native damage/HP/source effects. The public paired-controller stub emits **nothing**. Parent must observe actual native RED before any production burst implementation. T2 remains in progress; all other requested behavior is deferred incrementally, not dropped.

## Parent quick path

1. Inspect `../build-plan-burst-red01.json`: `.argv` / `.shell` are the exact unchanged-builder invocation; `.import_order`, `.inputs_sha256`, `.output_map`, `.log`, `.reader_argv_template` pin the complete recipe. No worker build/compiler/game was run.
2. Parent compiles that recipe. Before starting an observer, perform one read-only **exact-profile** occupancy preflight; retain the protected launcher guard. Launcher22 EXIT0 is not proof of game closure. Run ID is reserved `rf-burst-red-20261019-01`; no runtime attempt has occurred here.
3. Establish the bounded event-driven observer for this exact log only, then launch. Observer budget180 wall seconds; no polling/retry/bypass. Call unchanged `read_logs.py` once on fresh COMPLETE, substituting the actual launch Unix timestamp in the plan's reader template.
4. Interpret readiness ABORT separately from behavior RED. Expected stub result **if every readiness guard passes**: `COMPLETE|2|19|7|0`, 4 PASS /8 OBS /7 FAIL, reader EXIT1. This is a prediction, **not observed evidence**. Preserve actual streams before a minimal GREEN change.

Output map: `build/rf-burst-red-20261019-01/rf-burst-red-20261019-01.w3x`.
Relative native log: `Logs\RF-rf-burst-red-20261019-01.txt`. BEGIN group `RFBurst`; public entry `RF_StartBurstTest`. The absolute profile log and reader output are in the plan, not searched or queried by this worker.

## Executable sources and public contract

Import order is TimerUtils → WorldBounds → DummyRecycler → pinned Missiles → `BurstLog.j` → `PairStub.j` → `BurstNativeTest.j` → `BurstMapMain.j`. The existing builder supplies `RCStartHarness`, calling `RF_StartBurstTest` after InitBlizzard.

All four new files are under `src/prototype/` (472 authored JASS lines, one coherent test/stub unit; advisory400 exceeded without minifying or omitting real-effect checks).

- `PairStub.j`: `RB_InitializePair(visible,logical,shotObserver)` validates the single-pair/rawcode/ability contract and installs only a native spell hook. `RB_Dispose()` releases that hook, not caller units/observer. No timer, shot, missile, damage, movement or animation behavior.
- The public observer contract for later GREEN is synchronous `TriggerEvaluate(shotObserver)` **once after a real launch**. `RB_GetShotMissile/Source/X/Y` expose callback-scoped public diagnostics; do not retain recycled IDs. The stub initializes these views and never dispatches a pulse.
- `BurstNativeTest.j` measures pulse timestamps with native `TimerGetElapsed`, not private remaining-shot fields or application timestamps. At every pulse it checks public core `Missiles.allocated`, `.launched`, `.dummy`, `.source`, `.x/.y`, native dummy existence and separate actor/caster identity, and actual actor-origin agreement. Those members were read from the actual immutable core, not invented.
- `BurstLog.j` adapts the existing Preload snapshot pattern in a new namespace/run ID without editing/importing old T1 sources. RM28 CASE/CHECK/COMPLETE counters are computed from actual records; no log-only green.
- `BurstMapMain.j` configures one runtime user P0 and calls no inherited demonstration. Existing W3I/WCT/WTG remain unchanged: not an editor-save or multiplayer certificate.

## Fixture and readiness — native, finite, no guessed armor getter

Unchanged base05 `ff34f3fcea03281163c81bdcb11a6f7285f12c289c7160f640d4fa242adfb3b3` supplies verified o000/o001/A00G. No new rawcode, object recipe, metadata, utility, or base was created. Ncl3=0 is sufficient for **scripted** Channel; final Visible UI/caster metadata are deferred.

| Role | Owner/type | Requested XY |
|---|---|---|
| Visible actor | P0 / o000 | (-2223.5,4352) |
| Logical caster | P0 / o001 | (-5500,-5500) |
| Target | P1 / o000 | (-1967.5,4352) |
| Regen control | P1 / o000 | (-1967.5,4864) |

P0/P1 passive alliances are explicitly false both ways. Only target/control are paused; they have the same type, owner and health policy, with inherited weapons disabled/empty abilities from base05. Source facing is0. Type/life/enemy/native placement±1/ability/pause/facing/order guards and fresh native static walk-restriction flags precede input. The ray has9 bounded fresh static samples; **spawn placement is not movement truth**, and these samples do not claim continuous projectile/transit clearance. Actual native positions/HP/facing/currentOrder are logged. Aim uses **actual target XY**, not the requested coordinate. Control is512Y off the shot ray within the known static region.

Native calibration is exactly:

```jass
UnitDamageTarget(actor,target,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
```

Flags are attack=true, ranged=true; Classic attack type MELEE, damage type NORMAL, null weapon type. Calibration requires successful native return, exactly one target UNIT_DAMAGED event with GetEventDamage10±.01 and GetEventDamageSource=visible actor, positive next-phase native HP loss, and no control damage. Otherwise explicit `FAIL ABORT-fixture`/COMPLETE, **not fabricated rule RED**. No native armor getter exists here; native calibration is authoritative for this controlled scene. The event alone cannot distinguish attack/damage flags or certify a full physical defense matrix; S10 coverage is partial.

After calibration, both bodies receive the same native `min(max lives)-10` safe HP; exact .001 reset readbacks and >60 health margin are mandatory. Calibration is excluded from burst counters. At the actual matching cast event, the harness captures actual target/control starting HP. At the end:

`differential = (controlEnd-controlStart) - (targetEnd-targetStart)`

Expected40±.10 cancels same-type paired regeneration; this is not naive target HP-drop40 or a widened5HP tolerance. Control must receive zero damage events and both bodies must survive. Four actual target native events10 each/source visible actor are independently mandatory alongside public missile pulses.

## Cases and timing

| Case | Partial spec coverage | Required native/public effects | Expected no-op RED |
|---|---|---|---|
| B01-four-shot-native-effects | S1,S4,S5,S10,S11 | Accepted actual `IssuePointOrder(caster,"channel",actualTargetX,Y)`, exactly one matching native SPELL_EFFECT source/A00G/point; four public shot pulses with live launched separate core dummies; four target UNIT_DAMAGED10 events/source visible actor; paired HP differential40; undamaged control and surviving targets | Six behavior FAILs: count, real projectiles, native hit count, hit values, source, HP differential |
| B02-default-cadence | S1 | Same single-cast observations; three adjacent emission intervals .25±.03125 measured by native clock | One explicit missing-cadence-observations FAIL, not SKIP |

The harness observes the native cast event **before** the application's cast hook, admitting later synchronous immediate emissions. Actual event readbacks, not IssueOrder time, establish the3-second behavior horizon. Existing caster cast-point latency is allowed; event deadline2s from accepted order. Duplicate/wrong source/ability/point events abort explicitly. Runner period.03125, one-shot global deadline12 game seconds; finite phases, no retry-until-pass. Native logging/load overhead and game speed mean no hard wall-clock guarantee; parent observer budget180s.

## Static evidence, ownership, limits

One focused lint/API inspection: exit0, **0 errors /16 handle-factory ownership warnings**, empty stderr, no unknown direct calls including expressions. Exact argv/findings/API input hashes and per-source hashes are in `burst-red01-static.json`. Plan JSON roundtrip and every pinned input hash readback passed. Static scans are **not** compiler, native physics or RED/GREEN proof.

Ownership for the16 warnings: harness owns4 units,2 timers and3 observer triggers/attached conditions; Finish disposes app hook first, destroys observers, removes units and destroys timers, then completes/destroys logger writer. Pair module owns only castHook/its condition; logger owns writer/its condition. No unit userdata, local-player mutation, helper sampling, pooled-item churn or production performance changes. Logger snapshots at bounded case/events/checks, not every movement tick. Independent item4/T4 review remains later, not launched here.

Strongest current status: **Scanned**, Warcraft III Classic1.27b, only the new four source files/public B01/B02 harness scope. Parent compilation/archive checks and actual native readiness/RED remain unknown. Animation/300%/restart, recasts, angles/range/speed, obstacle termination, movement/handoff/lifecycle/UI, alternate physical defenses, multiplayer/editor-save and all-resource native cleanup proof remain deferred. No positive production behavior was implemented. T1's scoped real-cliff prerequisite and gap64 with-blocker native OBS-detour limitation remain unchanged. Parent already completed the full checkpoint mirror; this unit does not rewrite odd/history or that mirror.
