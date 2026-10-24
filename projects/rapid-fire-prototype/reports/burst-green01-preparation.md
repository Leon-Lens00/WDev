# PREPARED_GREEN_B01_B02 — actual GREEN pending parent

**Minimal emitter candidate delivered after valid native RED; not compiled or native-tested here.** `PairCore.j` supplies four real fireball missiles on the existing single-cast public harness. Partial S1/S4/S5/S10/S11 only; T2 remains open. No unchanged assertion, fixture, damage calibration, cadence tolerance or health calculation was weakened.

## Parent quick path

1. Execute the exact `.argv` / `.shell` in `../build-plan-burst-green01.json` for compilation/archive checks. The unchanged builder receives explicit inputs; no worker compiler/build/game was run.
2. Before the observer, perform one read-only **exact-profile** occupancy preflight and retain the protected launcher guard. Launcher25 EXIT0 is wrapper evidence, not game closure/profile availability. No worker process query occurred.
3. Parent owns one fresh `rf-burst-green-20261019-01` run and event-driven observer (180-second budget). Use the plan's exact log and public reader template once on fresh COMPLETE, substituting actual launch Unix seconds. No polling-until-pass, retry, guard bypass or profile switch.
4. Preserve actual native evidence. If readiness and all candidate behavior pass, expected COMPLETE is `2|29|0|0` (13 PASS /16 OBS), reader EXIT0. **Prediction only**: compilation, readiness and actual GREEN remain unobserved. Independent Risk4/T4 assessment/verification is parent-owned after own checks, not launched here.

Plan `.inputs_sha256` pins all10 build inputs; `.import_order`, `.output_map`, `.log`, `.reader_argv_template` are authoritative exact paths. Entry `RF_StartBurstTest`, group `RFBurst` are unchanged.

- Output: `build/rf-burst-green-20261019-01/rf-burst-green-20261019-01.w3x`.
- Relative log: `Logs\RF-rf-burst-green-20261019-01.txt`.
- Imports: TimerUtils → WorldBounds → DummyRecycler → immutable Missiles → **BurstLogGreen01** → **PairCore** → unchanged **BurstNativeTest** → **BurstMapMainGreen01**.
- One-shot global12 game seconds, native effect deadline2s/order, observation3s/actual effect, observer180 wall seconds unchanged; logging/loading/game speed preclude a hard wall-clock guarantee.

## Actual RED and preservation

Parent observed valid native `rf-burst-red-20261019-01`: COMPLETE2/19/7FAIL/0SKIP, 4 PASS /8 OBS; reader1. Native10 calibration/source visible actor/positive HP loss and matching actual A00G cast effect passed; stub0shots/0hits, paired HP differential0. See preserved `burst-red01-results.md` and raw/reader/build/launch streams. This is actual behavioral RED, not readiness ABORT.

**Before implementation**, froze all four RED source files and original plan NEW `frozen-burst-red01/`, verifying each against original plan hashes. `preservation.json` fingerprints35 protected files: RED source/plan/map/build/raw/reader/launch streams plus shared pinned inputs. All35 matched after implementation/static checks. The four original sources and RED plan remain byte-identical. Unchanged public harness SHA:

`7184bd4cd7ceef0fd3c04b0e776e90a64a82ed23e8e65dce1f6f0e924dcfdcc7`

Base05 remains `ff34f3fcea03281163c81bdcb11a6f7285f12c289c7160f640d4fa242adfb3b3`; core remains `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6`. No T1 source, library, objects, serializer, old project or odd/checkpoint edits. Logger/bootstrap variants differ from RED only in run/map-label strings; executable fixture logic remains unchanged.

## Minimum implementation and public callback contract

`PairCore.j` deliberately retains library **RFBurstPair** and the RED ABI: `RB_InitializePair`, `RB_Dispose`, `RB_GetShotMissile/Source/X/Y`. Never import Core and Stub together.

- Initialization owns exactly one native cast trigger, one reused fire timer and one reused terrain-location handle. Caller retains unit/observer ownership. Dispose invalidates the epoch, cancels future emissions and destroys only module-owned handles; repeated Dispose is harmless by inspection, not native-proven.
- Correct live controller/A00G SPELL_EFFECT starts a four-shot burst. First emission is immediate; a single periodic.25s timer emits the remaining three. Count/timer state is committed **before** core creation and observer dispatch, with final emission pausing the timer before the callback.
- Heading is computed from actual actor XY to actual cast XY; each emission starts at then-current actor XY and extends1500 in that fixed heading at speed1200. No unit target/homing/retarget is assigned. These defaults are necessary to create the basic shots, not separate native range/speed acceptance.
- `RBProjectile extends Missiles` follows actual pinned-core create/launch/callback semantics, corroborated by existing read-only library subclasses. A real `.launch()` precedes synchronous `TriggerEvaluate(observer)` exactly once. Public diagnostics refer to that live launched missile/source/origin for the callback only, then clear if the same epoch remains. Native effects—not notifications alone—are still mandatory in the unchanged harness.
- No actor is substituted as a dummy. Core owns the actual dummy, effect, coordinates, allocator and recycling; no dummy/userdata ownership changes in this module.

### Collision and damage

Visual path is verified `Abilities\Weapons\FireBallMissile\FireBallMissile.mdl`. Technical defaults (not new user requirements): planar hit radius32 and terrain+80 launch height. One reusable location computes endpoint terrain-relative Z so constructor world height equals launch world height; no per-shot locations or accidental endpoint-terrain slope. No per-frame shot logging.

Every flight snapshots actor, logical controller and owner separately from current pair state. Skip self/logical/friendly/dead/removed impact units. First eligible enemy commits `spent=true` **before** native damage callback dispatch, calls exactly:

```jass
UnitDamageTarget(savedActor,hit,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
```

Then returns termination to the core, with no state writes after native damage dispatch. These are the exact calibrated physical flags (attack/ranged true, MELEE/NORMAL, null weapon type); no fire damage, Bloodlust, burn, AOE or invented proc/XP guarantee. Source removal/death/owner mismatch fails closed before damage and in the core period callback. Dispose does not retarget existing flights: live-source snapshots remain independent of later global pair/reinitialization. Full physical-defense/termination/lifecycle matrices remain deferred.

### Reentrancy — Risk4, not independently verified

Monotonic pair/burst epochs invalidate suspended emission work on cancellation/disposal/reinitialization. `notifying` prevents same-epoch recursive emission/recast; count/timer changes precede external code. After core creation, stale work terminates its own newly created projectile without mutating a newer epoch. After the observer, epoch is checked before clearing views or touching global state, so Dispose+Initialize+nested cast cannot be clobbered by the old return. Missile `spent` is committed before UNIT_DAMAGED handlers can reenter. The core retains responsibility for its scheduler/instance pinning. These are static design safeguards, **not engine proof** of all callback, timer recycling, removal or allocator-exhaustion paths.

## Explicit incomplete behavior

**Active casts are temporarily ignored**, rather than resetting remaining shots/direction. That is intentionally not final S1/S6 behavior; the next incremental recast RED must expose it before correction. Maximum rate across idle casts is likewise not implemented/tested. No actor facing/attack animation/300% or restoration,350 mover/Stop/takeover/resume, application tree/cliff/bounds controls, final Visible Channel UI, multiplayer/editor-save or full T2 acceptance. Known T1 gap64 native OBS-detour limit remains. This unit does not import probe instrumentation or change helper lifecycles/performance.

## Observed self-verification

One foreground focused lint/API scan: exit0,0 errors/22 handle-factory ownership warnings, empty stderr, no unknown direct calls including expressions. Exact argv/full stdout/stderr/API hashes, protected-file comparison and line sizes are retained in `burst-green01-static.json`. Core/public members and inherited callback dispatch were inspected in actual immutable source; lexical evidence does not compile vJASS or prove native physics.

Ownership warnings cover the unchanged RED/harness handles plus Core's location/timer/trigger/condition and new logger writer/condition. Core Dispose removes its handles, harness Finish remains unchanged, logger destroys its writer after COMPLETE; in-flight cleanup is core-owned. None of those static ownership observations certify all-resource cleanup in game.

Source scope: **365 new JASS lines** (Core262, logger67, bootstrap36), unchanged harness300. Core-versus-Stub conceptual diff +213/-20, but Stub is preserved, not deleted. Generated plans/evidence/frozen copies excluded from authored-line budget. Strongest current status: **Scanned**, new GREEN candidate scope, Classic1.27b. Actual native GREEN pending parent. Full checkpoint/mirror reconciliation remains parent-owned.
