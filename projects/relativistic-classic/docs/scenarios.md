# RM28 in-map lab — S2 / S3 / S4

**Status: Tested in map — verified single-client map scope.** Current normal
fixed03 completed47/808/0/1:670PASS/137OBS/1multiplayerSKIP,
reader0/statusinconclusive. E29:34PASS/13OBS/1SKIP; all47 IDs, L99 last.
Candidate `build/fixed-20261019-03/fixed-20261019-03.w3x`, SHA-256
`4490afbf0824a89186faf22e3a948452b27fe0ae1a111f3d960a108228fb2694`.
**670 passing assertions, not808**. Independent comparison completed **true**,
comparison **exit0 / empty stderr**. Production readiness/native approval **false**.
No action required or in-scope pending checks. All games/observers complete.
See [FINAL](../reports/FINAL.md), [RESULTS](../reports/cycle4/RESULTS.md) and
[exact failed/corrected proof](../reports/cycle4/comparison/README.md).

## Independent assigned-scope gate completed

Inherited source inspector `mvevyvvm-a-ov94` found no introduced fixture defect.
Corrected independent check `mvexzndm-j-5179` actually executed with a25s timeout,
**exit0 and empty stderr**. It closes T6's assigned single-client
S3/S4/S8/S10 evidence/oracle gate and S11 comparison purpose using S12 permission;
this is not native review approval, multiplayer or universal production acceptance.

The first actual probe `mvexqx1v-i-bl4g` exited1 with empty stdout and
`KeyError: 'freshness'` at comparison.py:102. The historical fixed02 report omits
optional freshness (the reader records it only with `--not-before`). Exactly ONE
auxiliary correction allowed absence ONLY there: **historical freshness not
recorded, not reconstructed or accepted as PASS**. All three current freshness
checks remain mandatory; no input, assertion, source or native evidence changed.
V1 remains immutable. Earlier source-only scan and two unlaunched capability
checks remain historical; they are not erased or relabeled as execution.

The corrected command independently checked77 explicit copied inputs, current13
sources, both frozen manifests, Config specializations, sole negative predicate,
compiled/maps/logs/public streams, original before/after hashes and Git state.
All47 case IDs match, L99 last. All70 original M45 records retain exact details
and order. All26 original E29 names/details remain; original assertions PASS
except multiplayer. Non-E29 case/status/name multiplicities are preserved except
exactly intended M45 recovered launch flag and coordinate-fixture-live FAIL to PASS.
**36 dynamic detail differences** in C21/C25/C36–C42 include runtime handles and
C37/C38 matched expected/actual0-vs1 remaining-object swaps, both PASS. This is
not whole-log or universal detail equality. Raw locations are retained in the
copied `dynamic-differences.json`; omitted truncated OBS values are not inferred.

S12/L45's live explicit system-temp permission resolved the earlier no-scratch /
inside-WDev isolation blocks. That authorization was session/purpose-limited,
not standing consent for future outside access. No permission question, action
or in-scope check remains. No engine, test, build, comparison or GUI rerun was
performed for reporting; no source/map/native data changed. Temporary proof and
historical `/tmp/rc-item3-XNICaO` were not modified or deleted.

Historical fixed02 remains657PASS/124OBS/3FAIL/1SKIP reader1, not current candidate.
Cycle2 partial RED and [cycle3 controls](../reports/cycle3/RESULTS.md) stay immutable:
logger70PASS/701OBS reader0; E29 native .25s transfer FAIL (25PASS/31OBS/3FAIL/1SKIP),
not universal .5s cadence. Core/logger unchanged; current fixed03 includes the
verified logger and corrected E29 fixture. Baseline/logs/snapshots and original
70FAIL classification in `../reports/baseline-analysis.md` are preserved.
Tooling tests are not missile tests; this catalog is not exhaustive certification.
Diagnostic OBS tails truncate in native logging: omitted values not proved,
individual named assertions retained, no new fixture defect inferred. No screenshots
accessed/referenced/embedded. Multiplayer/editor-save/exhaustion uncertified.

## Historical reproduction recipe — not queued or newly authorized

1. Set `RM_RUN_ID` in `src/lab/Config.j` to a never-used safe ID, for example
   `baseline-20261018-001`. Set `RM_SELECT` to `all`, a group, or a case ID below.
   The default `UNCONFIGURED` deliberately refuses to start/log. IDs must match
   `[A-Za-z0-9][A-Za-z0-9_.-]{0,79}`. Do not reuse an ID even after a crash.
2. Run the following build through the parent's long-command runner. This is a
   **recipe, not observed compiler evidence**. No `bash_background` tool was
   available to this writer, so the optional compiler invocation was not run.
3. Parent verifies the new artifact, launches/observes the identified 1.27b game,
   and records game launch Unix time. Never use the historical `run_case.py`.
4. Keep the game's new log, read it explicitly, then repeat with the working core
   and a different ID. Do not fix the core before obtaining baseline game RED.

```sh
WC3=/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3
P=projects/relativistic-classic
PYTHONDONTWRITEBYTECODE=1 "$WC3" python -B "$P/tools/build.py" build \
  --wc3 "$WC3" --base "$P/baseline/original.w3x" \
  --timer-utils "$P/src/libraries/TimerUtils.j" \
  --world-bounds "$P/src/libraries/WorldBounds.j" \
  --dummy-recycler "$P/src/libraries/DummyRecycler.j" \
  --core "$P/baseline/Missiles.j" --bootstrap "$P/src/MapMain.j" \
  --harness "$P/src/lab/Config.j" --harness "$P/src/lab/Support.j" \
  --harness "$P/src/lab/Lifecycle.j" --harness "$P/src/lab/Motion.j" \
  --harness "$P/src/lab/Contact.j" --harness "$P/src/lab/Environment.j" \
  --harness "$P/src/lab/Load.j" --harness "$P/src/lab/Runner.j" \
  --entry LabRun --output-dir "$P/build" --run-id baseline-20261018-001
```

**The existing builder does not inject `--run-id` into source.** Both values must
be set identically. Alternatively generate a new `build/<unique>-config.j` from
`Config.j`, replacing only its `RM_RUN_ID` / `RM_SELECT` literal declarations,
and substitute that path for the Config harness import; never import both.
Only the chosen config file belongs in a build. Imports must remain explicit;
there are no nested `//! import`s. For the later working comparison change
`--core` to `$P/src/Missiles.j`, not any library dependency or scenario equation.

`LabRun` is a global no-argument entry called by T1's generated `RCStartHarness`
after `InitBlizzard`. It starts automatically after 0.5 game seconds. It is
one-shot, not chat-only; rerunning requires a new map session and ID. Groups:
`lifecycle`, `motion`, `contact`, `environment`, `load`. Any single case below is
selectable, including dangerous `L99`. Invalid selections refuse to start.

## Evidence and log reader

Every record is persisted before advancing. Classic `PreloadGenClear`,
`PreloadGenStart`, `Preload`, `PreloadGenEnd(RM_LOG_FILE)` rewrite a cumulative
snapshot to `Logs\\RM28-<RUN_ID>.txt`, normally under the active game's
`CustomMapData/Logs/`. `RM_Log` now appends the row then synchronously calls
`TriggerEvaluate` on one private trigger, created by the `LabSupport` initializer
with one boolean condition. That condition performs the same Clear/Start/full
saved-lines loop/End before returning true. This narrowly isolates immediate
snapshot evaluation from the caller instruction context; there is no timer,
debounce, deferred batch, or per-record handle allocation. Record format, order,
counters and COMPLETE semantics remain unchanged. Work is still a full snapshot
per record, not an asymptotic improvement. Both cycle3 JassHelper/pJASS/archive
builds passed. Independent item3 verification confirmed compiled initialization
after InitBlizzard/before LabRun and unchanged append/counters/order. Actual
same700OBS stress completed with all70 original M45 assertions identical in
case/status/name/detail/order plus the retained phase OBS (phase5,periods10,
allocated/launched true, paused/finished false). This is bounded logger GREEN,
not full-feature acceptance or a measured VM ceiling. Maintained Support SHA-256
is `564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d`;
core remains unchanged; cycle4 changes only maintained Environment E29. The physical Wine/profile path and whether Preload file
output is enabled must be verified by parent in that game; no existing profile
logs are treated as current. No process is exited, killed or closed by the lab.

```text
RM28|baseline-20261018-001|BEGIN|all
RM28|baseline-20261018-001|CASE|L01
RM28|baseline-20261018-001|CHECK|L01|FAIL|created-disposed|terminate before launch must dispose
...
RM28|baseline-20261018-001|COMPLETE|47|<checks>|<failures>|<skips>
```

The native Preload-generated JASS wrapper is expected; reader extracts record
strings without executing it. `COMPLETE` counts CHECKs including OBS and SKIP;
FAIL and SKIP counts are independently recomputed. Crash/hang means incomplete,
not PASS. Last CASE/CHECK is the progress checkpoint; a full log is rewritten
on each record to retain earlier evidence even if native buffering clears.

```sh
python3 -B projects/relativistic-classic/tools/read_logs.py \
  /explicit/current/CustomMapData/Logs/RM28-baseline-20261018-001.txt \
  --run-id baseline-20261018-001 --not-before 1792281600 \
  --report projects/relativistic-classic/reports/lab-baseline-20261018-001.json
```

Replace timestamp with **actual recorded game launch time**, not this example.
`--not-before` checks input mtime (equality accepted), rejects NaN/infinity/negative
values and includes mtime/threshold metadata in the report. Mtime alone is not
provenance: copying an old file can refresh it, so unique matching embedded ID is
also mandatory. The report includes source SHA-256. Never silently select a
historical FrozenThone log or accept runtime.log as assertion evidence.

CLI contract: stdout is one sorted-key JSON object; stderr is empty for a valid
complete log. Exit 0 means no FAIL, exit 1 means FAIL with full JSON evidence,
exit 2 means invalid/mismatched/stale/incomplete input (JSON `status: invalid`
and `error: ...` on stderr). Valid SKIPs yield `status: inconclusive`, never
passed. OBS entries are measurements, not PASS assertions; `status: passed`
means only that this complete log contains no FAIL/SKIP, not certification.
Rejected input never writes a report. `--report` exclusively creates a NEW file,
rejecting existing targets/symlink parents; source logs are always read-only.
Freshness is optional only when the caller intentionally omits the flag.

## Case catalog and exact expected rules

Automatic assertions below describe maintained sources. Baseline47 and current
fixed03 executed; current single-client results are above. These recipes do not
authorize another run; assigned independent comparison is now complete.
Counters are callback observations keyed by harness-owned `data`, not reads of
private scheduler/table state. Lifecycle disposal tests use public `allocated`,
callbacks and opaque live identity equality; hit tests use public `hitted` /
`flush` / `flushAll`. No static source-text assertion substitutes for a rule.

| Case | Automatic assertions / observation |
|---|---|
| L01 | Create, terminate twice before launch: disposed, onRemove once, next allocation reuses released identity. Baseline expected RED. |
| L02 | Duplicate launch is harmless; finite straight flight onFinish/onRemove once. |
| L03 | Pause enters frozen queue once, position and period count stop; resume once and movement continues. A second isolated missile returns true from onResume and removes once. |
| L04 | Frozen terminate twice removes once; released identity reused; two new live identities distinct. Baseline expected RED for unreclaimed identity. |
| L05 | onPeriod explicitly terminates then returns false; one callback/remove, no subsequent dummy movement or public X write. Baseline expected RED for public X write. |
| L06 | Same explicit terminate with return true; idempotent remove and no continued public X write. |
| M7 | Unequal origin50/impact250: initial current, previous and next Z equal origin absolute terrain-relative height. Baseline expected RED. |
| M8 | Speed400 gives next X10; slope next Z equation; current Z must not advance during speed assignment; speed-then-arc next state coherent, repeating speed after arc uses same equation. Baseline expected RED. |
| M9 | Straight current/previous/next X increments10, next/current Y unchanged. |
| M10 | Arc30 degrees, getter and parabolic next Z equation at sampled travel. |
| M11 | Curve20 degrees, getter and lateral displacement equation. |
| M12 | Same-XY vertical duration1 flight: onFinish returns true, finish/remove once, final height near impact (6-unit tolerance); .01 source coordinate nudge is not treated as real horizontal travel. |
| M13 | onPeriod79 teleports homing target800→2000 after core cached old distance800: nextX790+step10 must not finish against stale distance800; finish once near2000. Callback-count trigger avoids timer-order ambiguity. Baseline expected RED. |
| M14 | Duration1 → speed=(exposed remaining planar distance)/1 captured before assignment, tolerance .01 unchanged; independent native SquareRoot/endpoint checks and OBS; finish in1±.075 seconds, once. |
| M15 | deflect clears target/reopens flight and moves toward new Y. |
| M16 | bounce sets travel0 and origin=current, then continues. |
| M17 | Speed change = processed periods × .25 / PERIOD (documented callback-based acceleration units). |
| M18 | Target killed during flight; callbacks continue (dead unit retains type, source continues homing). |
| M19 | Target removed: target cleared and callbacks continue without stall. |
| C20 | Unit hit once, hitted true; flush(widget) clears immediately and permits second hit; flushAll permits third. |
| C21 | At actual native item XY, equal absolute endpoints ground+100/radius10; assert planar overlap and Z separation from source item extent16. Z rejects; disabling Z permits hit; hitted/flush permits another hit. OBS native XY/terrain/life/visibility; no item relocation/healing. |
| C22 | Destructable hit once, hitted/flush permits second hit. |
| C23 | Persistent A hits retired B; after scheduler retirement new C must reuse B's opaque ID and still hit A; flushAll permits another hit. Baseline expected RED on generation safety. |
| C24 | 40000 units/s =1000 per tick, samples-500,+500 miss unit0 with radius10. Assert source's point-sampled outcome0, OBS no swept guarantee. |
| C25 | Item at90,90 hits radius100 rectangular enumeration though outside circle. Assert square semantics, OBS approximation. |
| C26 | onMissile terminates other and self returning false; each removes once, no duplicate contact or continued public position write. |
| E27 | Out-of-world boundary callback returns true: once and removes once. |
| E28 | Starts20 below local terrain: onTerrain once and removes once. Separate missile crosses surveyed W3E uphill edge -2048,1536→-1920,1536 at one below source wall equation: onCliff returns true/removes once. Only this cliff branch SKIPs if native levels do not confirm the surveyed uphill. |
| E29 | Two owner instances; requested600 radius reveals initially hidden probe400 away, not900 away; explicit owner and source-owner fallback; no cross-owner reveal; current visibility clears after termination. Unchanged actual visibility rules run immediately after independent translated native references settle, with a2s transition guard. Initially visible probes SKIP; invalid reference eligibility remains inconclusive. Multiplayer SKIP. |
| P30 | 150 live missiles; constant-speed and accelerated waves, once per-instance finish/remove; duration and impact tolerances; observed time/callback ranges. |
| P31 | Identical expected contract at151, with scheduler rounding tolerance only. |
| P32 | Identical expected contract at300, with scheduler rounding tolerance only. |
| M33 | deflectTarget binds public target and moves toward it. |
| P34 | Two waves of100 (200 repeated launches), terminal counts and idle cleanup checkpoint. |
| C35 | Unit collideZ upper boundary +64+radius hits once; +.125 beyond rejects; lower boundary -radius hits once; -.125 below rejects. Four independent stationary probes, source's fixed64 vertical extent. |
| C36 | Same four inclusive/exclusive Z probes centered at actual destructable XY: bottom=terrain there, top=bottom+GetDestructableOccluderHeight. OBS actual XY/life/terrain/occluder and interval; radius10 and .125 outside probes unchanged. |
| C37 | Unit first contact returns true; one callback/remove, scheduler retires, same-ID fresh missile hits both remaining units exactly once. |
| C38 | Same multi-unit fixture, contact explicitly terminates and returns false; fresh public callbacks expose any post-termination hit-memory writes. |
| C39 | Three items: first contact returns true; remaining two must both hit a same-ID fresh missile after retirement (private EnumItems continuation regression). |
| C40 | Same three-item lifetime rule with explicit terminate+false. |
| C41 | Three destructables: first contact returns true; same-ID fresh missile must hit remaining two (private EnumDestructables continuation regression). |
| C42 | Same three-destructable lifetime rule with explicit terminate+false. |
| C43 | Three missile targets: first contact returns true; fresh same-ID observer must hit remaining two. |
| C44 | Same missile-target rule with explicit terminate+false, pinning enumeration writes after observer removal. |
| M45 | Independent origin/impact XYZ, square, distance, radians angle, slope, degrees alpha and reverse getters; initial current/previous/next XYZ; diagonal next-XYZ equation, veloc, turn/travel resets and flags. Recheck every coordinate getter after public impact.move and origin.move. |
| E46 | Controlled native tileset change and restoration: distinguish initial callback from actual transitions, assert callback tile/public tileset, return-false continuation and return-true removal; restore/check type and variation across saved3×3 cell neighborhood. |
| L99 | LAST: onPause calls pause(false) then returns true; pause/resume/remove once; two new live allocations must differ (double-free reproduction). Baseline may hang/corrupt here; select alone to isolate. |

Every case has a post-cleanup half-second idle checkpoint asserting no extra
onRemove callbacks. Cleanup uses only launch (if needed), pause(false), terminate
and removal of lab-owned unit/item/destructable fixtures. C35–C44 centralize
fixture ownership/teardown. For contact reuse, three verified objects must lie inside the same enumeration;
requested placement0,0 is not proof of native placement. C39–C42 log actual native
item/tree XY/terrain/life/type (and item visibility), then derive one rectangle
radius=max(10,max_i(abs(actualX_i),abs(actualY_i))+1) around0,0 before launch.
That identical radius is reused for the fresh observer; lifetime tests do not
promise a fixed10 radius. Units/missile fixtures stay colocated with radius10.
Enumeration order is never assumed, and only the callback-identified first
object is removed before the fresh launch. After a .25-second retirement
checkpoint, the fresh missile MUST reuse the retired ID and produce one public
callback for EACH remaining object, not just a total that could hide suppression.
No hitted/private-table inspection stands in for that proof. C39/C41 catch the
specific original private-enumeration continuation even when callbacks return
true: native enumeration continues after termination, but must not contaminate
the next lifetime's hit memory. C38/C40/C42/C44 cover explicit terminate+false.
Failed baseline
unlaunched disposal is salvaged via public launch/terminate solely after its
assertions; leaked frozen struct IDs cannot be reclaimed through public API.
E29 restores and publicly checks prior fog/mask enable settings and all saved incoming shared-vision edges, including on abort; it checks onRemove exactly once per instance and an additional idle checkpoint.
E46 saves native tile type/variation at nine128-spaced cell centers around64,64;
`SetTerrainType(64,64,alternate,0,1,1)` changes one square cell. Both alternate
choices (`Ldrt`, `Lgrs`) were verified in the baseline W3E ground-tile inventory.
The whole saved3×3 neighborhood is restored with the same area1/shape1 call and
each type/variation is asserted; no height, cliff, map-file or archive mutation.
A return-false observer sees original→alternate→original exactly once each;
a second observer returns true only on the actual alternate transition. Initial
nonzero tileset notification is counted separately, never passed off as a
transition. Current full47 includes native paint/restore checks; independent
cross-run multiplicity/preservation proof is complete within assigned scope.
The W3E read-only inventory has native-survey candidates (cliff levels0/1), not
an assumed featureless map. E28 checks the chosen candidate with
GetTerrainCliffLevel before asserting its callback. If that candidate does not
match native geometry, the exact remaining fixture need is an adjacent128-unit
native uphill pair, with test absolute Z below
`(upperLevel-GetTerrainCliffLevel(WorldBounds.maxX,WorldBounds.maxY))*bj_CLIFFHEIGHT`.
Only that branch is SKIP; terrain and tileset branches still assert independently.
There is no `FlushParentHashtable`, local-player gameplay mutation, direct
allocator/scheduler mutation, damage system, or dummy user-data ownership.

## Cycle3 E29 temporal comparison — not universal acceptance

Actual FAILs: `vision-owner-transfer`, `vision-source-transfer`,
`diag3-raw-owner-transfer`. Readiness OBS bounds=true/hiddenBoth=true and
positive native reveal/isolation PASS. At transfer +.25s raw/primary/fallback
P1/P2=true/true: old owners retain and new owners gain vision. At +.5,.75,1s
raw/primary=false/true, fallback=true/false. The scheduled .25s oracle fails
native control in this run, not a Missiles-specific diagnosis, universal .5s
cadence or proof that all historical withdrawal failures share a cause.

Withdrawal at end stage10 follows positive hold; all raw/missile probes false
by +.25s through +2.25s, original withdrawal assertions PASS; missiles alive
through +1.25s. Those historical original .25s intervals were unchanged. Verifier accepted logger scope only, S8 runtime pending at its time; parent later read E29. Risk: item3 shared logger verified. The separate L35 authorization now covers the cycle4 fixture below; historical evidence remains immutable.

## Cycle4 E29 reference-driven oracle — assigned verification complete

See [preparation](../reports/cycle4/PREPARATION.md) and its per-input manifests.
This is a fixture correction, not core physics, logger or CLI work. Original
case ID, boolean conditions, names, tolerances, radius/probe geometry and motion
interval remain intact. Two fixture-owned classic fog circles use the original
`FOG_OF_WAR_VISIBLE, true, false`, owners and radii, translated by +3000Y.
Runtime WorldBounds extents and initially hidden probes gate eligibility; no
references exist in E27/E28/E46 or other cases. Valid references must positively
reveal each owner and isolate the other before any visibility acceptance.
Invalid initial eligibility is SKIP/inconclusive, never PASS; the original
initial-visibility SKIPs and separate multiplayer SKIP remain.

The existing .25s runner drives private phases. Reference-only visibility gates
cover initial reveal, shrink/zero, negative/restored radius, stopped movement,
owner/source transfer, withdrawal and cleanup. No gate waits for an actual
missile visibility PASS: once native reference states match, unchanged actual
boolean assertions execute immediately and divergence FAILs. Public dummy
owners must first reconcile before raw owner transfer; the original public
owner checks remain. Ownerless actions precede raw Stop, conservatively after
public neutral ownership. Motion stays at1600 for exactly two runner intervals,
then stops BEFORE any movement-reference wait; the raw position is updated from
public stopped X, not a presumed simultaneous core visit.

Every wait is bounded by `VISION_WAIT=2.0` simulated seconds, sampled at runner
checkpoints. This is a fixture safety budget, NOT a universal native cadence,
new .5s deadline or visibility tolerance. OBS records phase, wait source, RM_CLOCK,
elapsed/deadline and raw/actual states. Public owner waits use only dummy owners;
native reference gates use only translated raw visibility, never missile probes.
`vision-reference-timeout` emits ONE FAIL for the failed transition with
`phase`, `wait`, `deadline`, `elapsed`; the fixture then disposes its missiles
and source through RM_Cleanup, Stops/Destroys all owned references and performs
a separately bounded abort-cleanup reference wait. Cleanup failure adds its own
explicit timeout and forces restoration without another wait. A maximum160
checkpoint watchdog emits `vision-case-watchdog` and forces restoration too.
Unreached original checks are explicitly OBS/incomplete coverage, not synthetic
PASS or silent SKIP. Cleanup tests current visibility before restoring global
flags, tests onRemove once per instance, checks saved fog/mask/alliance values,
and checks no extra remove events while idle. The unchanged Runner adds its
original half-second idle checkpoint and reaches COMPLETE.

Only the frozen `diag4-e29-timeout-20261019-01` Environment substitutes `false`
for the unique private TRANSFER-reference-ready return. Initial reference
readiness, native calls, all actual assertions, logger and core are uninjected.
Expected negative evidence is phase8 `vision-reference-timeout` at the first
checkpoint at/after2.0s since raw transfer was armed, public reader exit1,
COMPLETE, cleanup/onRemove/restoration PASS and no extra idle events. It tests
response to controlled pending input, not engine physics. Actual negative run
completed1/47/1/1 with28PASS/17OBS, exactly that timeout at2.000 and cleanup,
restoration/onRemove/idle PASS. Actual reader1 remains failed; previously saved
expected-negative validation exited0. [TIMEOUT](../reports/cycle4/TIMEOUT.md) and
[timeout proof](../reports/cycle4/timeout-result.json) remain unchanged; their
pending-fullrun checkpoint is superseded by cycle4 RESULTS. No guard RED was
invented; historical native .25s RED is pre-fix evidence only.
Normal uninjected fixed03 completed47/808/0/1, E29 all34PASS/13OBS/1multiplayerSKIP.
Inherited source/saved-proof inspection plus corrected executed comparison close
assigned S3/S4/S8 single-client/S10 gate. No comparison or native rerun here.

## Equations and load limits

- `PERIOD=.025`, speed is world units/s; nominal displacement `v*PERIOD`.
- Endpoints are terrain-relative at creation; absolute Z = input Z + ground Z.
  The desired coherent contract is current=origin until movement; next predicts
  one step. Setter-only changes must not move current coordinates.
- Let `d=origin.distance`, `s=travel`, `a=arc degrees`, `c=curve degrees`:
  `nextZ = origin.z + (impact.z-origin.z)*s/d + tan(a)*s*(d-s)/d`;
  lateral curve displacement = `4*tan(c)*s*(d-s)/d`.
  M45 uses independent endpoint deltas: square=`dx²+dy²`, distance=`sqrt(square)`,
  angle=`atan2(dy,dx)` radians, slope=`(impactZ-originZ)/distance`,
  alpha=`atan(slope)` degrees; reciprocal slope/alpha negate. Angles compare
  modulo2π (wrapped atan2(sin(error),cos(error))), not a new normalization
  requirement. Tolerances: .01 world units/degrees, .001 radians/slope,1 square
  unit. Getter checkpoints are spread across stages to bound log-thread work.
- Duration = remaining planar distance / speed. M14 uses public origin.distance
  minus travel captured before assignment, not ideal800; checks native
  SquareRoot(800²) and endpoint X independently and retains .01 speed tolerance.
  Baseline M45 logs exact square250000 but native root500.008, so ideal sqrt
  precision cannot be assumed. Coordinate .01 nudge applies only when squared or
  native distance is zero, not the800-unit path. Same-XY vertical fixture exposes
  that source nudge and height consistency; not a 3D speed claim.
- Acceleration in this recovered source is a **velocity increment per processed
  callback**, NOT units/s². With acceleration `.05`, callback number n observes
  speed `400 + (n-1)*.05/PERIOD` before orientation increments it. The same formula
  is asserted at all loads. It does **not** imply equal physical acceleration
  across load budgets; changing to elapsed-time acceleration requires a parent
  contract decision and new baseline expectations, not a fabricated test oracle.
- Constant-speed 800/400 =2s at every load. Allow
  `.025*(max(1,N/150)+2)` seconds and `10*max(1,N/150)+1` world units for timer,
  schedule phase and current-vs-next endpoint quantization, not arbitrary drift.
  Exact float equality is deliberately avoided.
- Load setup creates25 stationary missiles per .25s checkpoint; after12 setup
  ticks all N are concurrently active and a single arm step sets speed400.
  Setup callback counts are reset before measurement. Each wave gets2.5s after
  arming; two waves/case take11s. Only25 creates share a setup thread, avoiding a
  single 300-create classic instruction-budget burst. This is a concurrency test,
  not a claim about instantaneous spawning cost.
- The original catalog schedules under180 **game seconds**, absent a core hang/crash; cycle4 E29 additionally has bounded native-reference waits with a40-game-second maximum case watchdog plus cleanup/idle completion.
  Wall time/FPS is not bounded; snapshots, dummy creation and rendering alter
  wall-clock performance. There is no automatic kill/deadline/EndGame. A missing
  COMPLETE after a hang remains incomplete evidence for parent to investigate.

## Public API coverage / remaining inspection

| Public surface | Coverage and limits |
|---|---|
| create, launch, terminate; allocated/launched/finished/paused | L01–L06/L99 and terminal counters; launched/finished indirectly through public effects and resets, not private queue counts. |
| pause; onPause/onResume | L03/L04/L99 false/resume+true paths; independent onResume returning true tested by L03's second missile. |
| onPeriod, onFinish, onRemove | All adapters; explicit terminate+false/true in L05/L06; onRemove correctly returns nothing. |
| onHit/onItem/onDestructable/onMissile; collision/collideZ | C20–C26 plus C35–C44: unit/destructable inclusive and exclusive upper/lower Z; each contact family has return-true and explicit terminate+false, lifetime reuse and per-remaining-object callback assertions. Missile collision remains planar per original API. |
| flush, flushAll, hitted | C20–C23. Missile-generation test uses callback counts, never passes a struct ID to widget-taking hitted/flush. |
| onBoundaries/onTerrain/onCliff/onTileset; tileset | E27/E28/E46: bounds/below-terrain, runtime-gated surveyed cliff, controlled tileset transitions and public type/variation restoration. Only unconfirmed cliff candidate SKIPs; tileset initialization is not mislabeled a transition. |
| speed, veloc, acceleration, duration, travel | M8/M14/M17, P30–P34; getter-backed units/observations, not elapsed-time acceleration certification. |
| arc/curve; origin/impact distance/slope/angle/alpha/square; x/y/z, prev/next XYZ | M7–M12 plus M45 independently derive all coordinate getters from supplied endpoints, native ground height and equations; public origin.move/impact.move update reciprocal links; diagonal XYZ prediction and turn reset asserted. No direct destroy/link of core-owned coordinates. |
| deflect, deflectTarget, bounce, target | M13/M15/M16/M18/M19/M33; target kill/removal continuation; path arrival after arbitrary moving targets still broader manual matrix. |
| source, owner, vision; dummy | E29; public ownership and fog visibility. Probe areas must be unrevealed/unoccluded. Actual lighting/trees may require a surveyed fixture. |
| model, scale, damage, data, type | M7–M19/M33 getter roundtrip; visible source-declared FireBall model and scale1; damage/type/data are client payload fields, no implicit damage behavior asserted. |
| collection/count | Intentionally not a test oracle for cleanup; callbacks/live identities/positions are used. Enumeration mutation means onMissile enumeration, not direct writes to readonly collection. |

Verified fixture provenance: `ntrg` occurs in recovered `CreateUnit` declarations;
`I001` occurs in recovered `CreateItem` and binary w3t; first recovered
`war3map.doo` destructable is `LTlt`. Custom dummy `e000` remains owned by the
unchanged core/recycler; its recovered object fields `usin` and `usid` are
both1 (read-only binary inventory), so E29's requested600 is not merely testing
the default dummy sight setting. FireBall model path is copied from original-harness
model assignment. No invented custom rawcodes or modern `Blz*`/Lua APIs.

Automatic mode displays case labels/failure messages, uses visible models and
centers camera for human inspection. Visual pitch, rotation, model death,
trajectory aesthetics, cliff walls, fog occlusion and camera following remain
human checks, not Python/console assertions. Two-client ownership agreement,
synchronization, long-duration resource exhaustion, allocator exhaustion and
maximum-map gameplay coexistence are pending. Neither Scanned nor a future
Compiled label proves those properties.

The source is deliberately split into logger/helpers and scenario adapters,
rather than compressing a behavior catalog into a 400-line monolith. Review
callbacks together with their corresponding assertions; core fixes are a later
separate work unit. The authored S4 assertion gaps named in the initial handoff
are now represented by C35–C44/M45/E46 and E28's surveyed branch. Remaining
bounds include conditional cliff fixture in other environments, visual inspection,
two-client synchronization
and long-duration/exhaustion tests—not a claim that Python tests certify the game.
The focused Python suite preserves all18 CLI tests and adds one catalog-only
structural test comparing runner ID mapping, unique count47, L99-last ordering
and the documented table/COMPLETE count. That metadata test is not a missile
behavior test or a substitute for any of the public-callback assertions above.

## Scoped reporting closure

The single foreground reporting-only readback exited0 with empty stderr:
3 JSON reports,7 Markdown reports and20 exact proof-file copies checked;
copied scripts parsed for syntax only, never executed. No redaction required.
[Readback evidence](../reports/cycle4/comparison/reporting-readback.json).
This supersedes the pre-readback T7 checkpoint above: **T1–T8 all done for scoped
work**, T6 assigned verification complete, T7 reporting complete. No action or
in-scope check pending. Native approval/production readiness remain false;
multiplayer/editor-save/exhaustion/arbitrary integration remain out of scope.
