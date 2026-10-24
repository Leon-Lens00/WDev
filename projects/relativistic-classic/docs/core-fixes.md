# Local Classic core fixes — scoped evidence

**Combined artifact: Tested in map, verified single-client map scope.**
Current `fixed-20261019-03` completed47/808/0/1,670PASS/137OBS/1multiplayerSKIP,
reader0/statusinconclusive; E29 34PASS/13OBS/1SKIP, L99 last. **670**, not808,
passing assertions. Candidate `build/fixed-20261019-03/fixed-20261019-03.w3x`,
SHA-256 `4490afbf0824a89186faf22e3a948452b27fe0ae1a111f3d960a108228fb2694`.
Production readiness/native approval false; independent comparison completed true,
corrected comparison exit0 / empty stderr;
see [FINAL](../reports/FINAL.md) and [cycle4 RESULTS](../reports/cycle4/RESULTS.md).
Both builds JassHelper/pJASS/archive exit0;39 tooling tests exit0 in0.764s,
retained not rerun here. Both games/observers exited; no GUI action pending.
Core/logger unchanged; only E29 fixture adapted within L35. Saved circular
single-client evidence is not multiplayer/occlusion/universal acceptance.

Historical fixed02 remains657PASS/124OBS/3FAIL/1SKIP reader1, previous fixed01
29 failed records; old logs unchanged. Contact correction and earlier lifecycle
7/37/0/0 successes retain their scoped meaning. [Cycle3 controls](../reports/cycle3/RESULTS.md)
justified fixture adaptation; they are not release candidates. Baseline failures
remain immutable in [baseline02](../reports/RM28-baseline-20261019-02.txt).

## Intended public differences

| Cases | Repair |
|---|---|
| L01 | `terminate()` cleans a created, unlaunched missile, calls `onRemove` once and reclaims its ID. |
| L04 | Terminating a frozen missile removes frozen membership and reclaims its ID. |
| L05/L06/C26 | Explicit termination stops later callbacks, orientation and dummy writes, regardless of callback return value. Terminal XYZ remains unchanged. |
| C23 | An observer distinguishes a retired missile from a new lifetime using the same ID; `flushAll()` forgets missile and widget contacts. |
| C38/C44 | Terminal contact callbacks cannot repopulate hit memory after cleanup. Native item/destructable visitors also reject inactive instances before saving contacts. |

Boolean callbacks still return true to terminate and false to continue, subject
to explicit termination. Existing finish/resume fallbacks remain for live
instances. `onRemove` still returns nothing. Public signatures, subclass event
dispatch and the generated allocator are unchanged. Widget `hitted`/`flush`
remain widget operations, not struct-to-widget casts.

## Ownership review path

1. `OnRemove` marks `allocated = false` before dispatch to prevent recursive
   cleanup. Dummy, effect, coordinates and data remain readable during
   `onRemove`; cleanup/reset follows the callback. Collection removal is guarded
   for never-launched instances. Existing frozen swap-removal stays centralized.
2. `active` records ownership by a scheduler slot, including terminal slots not
   yet detached. `remove(i)` detaches that slot before `OnPause`; nested resume
   therefore owns a new slot rather than borrowing the old one. Small `pins`
   counters protect pause/resume/remove dispatch until it unwinds. Cleanup does
   not reset ownership or pins. The single internal `release()` helper calls the
   generated deallocator only when terminal, detached and unpinned. In particular,
   an `onRemove` launch cannot reuse the old instance while cleanup is pending.
3. Movement checks liveness between modules and after callbacks. Unit/missile
   loops stop on explicit termination as well as a true return. Tileset,
   finish and resume tails do not write or invoke fallbacks on a terminal object.
4. Missile contacts save target generations in a separate integer hashtable.
   Each slot's generation increments on create and is not reset on cleanup.
   Widget booleans keep their original table. Lifetime start/end and `flushAll`
   flush both per-observer child tables; native parent tables remain valid.

## Native coverage checklist — historical recipe, no rerun queued

Run the unchanged public assertions for **L01–L06, C23, C26, C38, C44** first.
Preserve **L02/L03/L99**, **C20/C22/C37/C43**, **E27/E28/E46**, and duplicate
launch/pause/resume behavior. Run **C39–C42** with the corrected baseline03
geometry prerequisites: baseline02 did not establish their initial contact.
They are continuation-guard coverage, not additional reproduced allocator bugs.
Then repeat all cases, including **P30/P31/P32/P34**, to check scheduler load
preservation. No Python source-string or mock scheduler test substitutes for
these engine assertions.

L99 already passed in the real baseline; this patch does **not** claim a
reproduced double-free. Collection swap-skip, shared-temp reentrancy and XE pool
conflicts remain unproved and are not redesigned. Point sampling, rectangle/Z
collision equations and per-visit acceleration remain unchanged. T5 retains
ownership of all trajectory/setter/vision math; that separate slice is described below.

## Local evidence

- Baseline02 RED: L01 three failures; L04 one; L05/L06/C26 three; C23 two;
  C38/C44 six. See [causal classification](../reports/baseline-analysis.md).
- Existing Python suite: 39 tests passed in 0.827s, exit0. This checks builder/log/catalog
  behavior, not the vJASS patch. No Python behavior changed or artificial core
  tests added (`tests/test_core.py` did not exist).
- Conservative source lint: zero errors, five handle-factory warnings, exit0.
  Persistent location/timer/group/rect and existing dummy/effect factories need
  lifetime review; lint is neither a parser nor a native compatibility proof.
- No compile/game/process command, original/dependency/rawcode edit, scratch,
  feature-document edit or commit was performed by this implementation worker.

**Remaining risk:** single-thread callback/scheduler reentry ownership (item4),
including callbacks creating or terminating other missiles. Native compilation
must also verify module expansion/local declarations and subclass dispatch.
No multiplayer, exhaustion or generation-counter-overflow guarantee is claimed.

## T5 coherent samples and homing

The working source initializes current/previous/next Z from the absolute origin,
including dummy placement. A single prediction helper computes uncurved XY,
lateral curve and absolute Z for the same progress. Private base XY prevents
feeding a curved point back into the linear advance. Speed, duration, arc and
curve setters refresh only prediction, never current/previous XYZ or accumulated
progress. During movement, public `travel` keeps the next-sample convention used
by the original arc calculation; duration uses the actual current remaining
planar distance. Native SquareRoot and the coincident-endpoint fallback remain.

After callbacks, homing refreshes its target and distance before advancing and
checking completion. A terminal prediction clamps to the actual endpoint so
current and next XYZ agree before `onFinish`. Deflect and bounce rebase private
progress; existing callback liveness guards remain. M11 now checks the curve's
next sample and checks current/previous promotion separately, rather than
preserving the old phase mismatch. Current full47 includes these assertions;
Python tests and pJASS alone do not establish trajectory correctness.

## S8 explicit circular revelation

`vision(radius)` now uses classic `CreateFogModifierRadius` for positive radii,
with shared-vision participation enabled and after-units override disabled.
Reveal eligibility requires an explicit owner or a live source's owner. When
both are absent, the dummy falls back to neutral passive but **no circle is
created**. An explicitly supplied neutral owner remains explicit ownership. Setter calls refresh immediately; processed movement visits detect
owner/source/position changes. Direct public field changes while frozen cannot
be intercepted: reassign vision or resume to refresh. Nonpositive radius removes
the modifier. Cleanup stops/destroys it after `onRemove` and before reset.

This is **circular map revelation**, not unit line-of-sight: no equivalent tree,
cliff or terrain occlusion, detection or explored-area erasure is promised.
Current visibility follows native fog-grid/update latency; exploration can remain.
Moving sight requires modifier recreation when inputs change and may be expensive
at scale. No performance or multiplayer certification is implied. E29 checks
radius, zero/shrink, movement, source/owner changes and cleanup with public fog
queries. Positive/zero/shrink/movement/transfers and later cleanup pass in the
historical fixed02 full run, except both owner/source-absence visibility-withdrawal
checks fail there. Those historical records are unchanged. Cycle3's ONE separated
transfer/withdrawal control instead passes original withdrawal assertions at
+.25s, with all probes false through +2.25s, alive through +1.25s. Transfer at
+.25s fails both original `vision-owner-transfer` / `vision-source-transfer` and
`diag3-raw-owner-transfer`: raw/primary/fallback P1/P2=true/true. At +.5,.75,1s
raw/primary=false/true, fallback=true/false. Readiness bounds/hiddenBoth and
positive reveal/isolation are valid. Thus this .25s oracle also fails native
control in this run, not a Missiles-specific diagnosis. It proves neither a
universal .5s deadline nor a common cause for all historical withdrawal failures.
This historical control justified L35's bounded fixture adaptation, not an
automatic widening, core edit or universal cadence. Both authorized cycle4 runs
are now complete; no further control is queued.

## Measured native widget enumeration and bounded correction

Public-native controls ran before changing collision enumeration:

| Fixture | Exact rectangle | Rectangle padded by128 |
| --- | ---: | ---: |
| Item, radius10 | 0 candidates / 0 eligible | 1 / 1 |
| Tree, radius10 | 0 / 0 | 1 / 1 |
| Three items, radius49 | 2 / 2 | 3 / 3 |
| Remaining items before fresh observer | 1 / 1 | 2 / 2 |
| Three trees, radius10 | 0 / 0 | 3 / 3 |

See `reports/RM28-native-contact-20261019-01.txt`. These demonstrate omissions
for the actual fixtures, not a reverse-engineered universal engine-grid bound.
The unchanged collision code still failed that control run (17 cases,273 records,
27 failures). The correction then pads only candidate enumeration with the existing
128 constant and rejects candidates outside the **original inclusive XY AABB**
before storing hits, testing Z or dispatching callbacks. It does not enlarge the
logical radius, convert squares to circles, or promise swept collision. C25/C36
also include expanded-only objects to assert that the narrow phase rejects them.
All prior expected hit counts remain. Final corrected gameplay and the targeted
independent recheck passed these contact tests, including expanded-only rejection.
That scoped closure does not establish full-feature acceptance.

## Cycle3 logger correction — separate from historical full47 candidate

Only maintained `src/lab/Support.j` changed (+16/-5), plus docs. SHA-256:
`564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d`.
Core remains `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6`;
maintained Environment was unchanged in cycle3 and changes only E29 in cycle4.
The logger synchronously isolates the same
cumulative snapshot in TriggerEvaluate, retaining append/counters/order and
immediate persistence, without waits/timers/deferred batches/per-record handles.
Total work is unchanged; native VM ceiling unmeasured.

Actual stress COMPLETE1/771/0/0 reader0:70originalPASS,700paddingOBS,1phaseOBS.
Independent `mvethryx-3-qxpn` compared every original case/status/name/detail/order
and confirmed identity, compiled initialization and raw normalization. Scoped
S3/S4 logger-only/S9 PASS; S8 runtime pending at verifier time, not accepted by
that verifier. Risk: item3 shared logger independently verified within scope.

Historical fixed02 map hash
`b8b1b9a1e4a072f014a75122a1c96851175c07c7198532f1d900227ee1165859`
and657PASS/124OBS/3FAIL/1SKIP remain unchanged; it does not include this logger.
[Cycle3 results](../reports/cycle3/RESULTS.md) link both actual control maps,
not full-release candidates. T8/T5/T6 finished; T7 reporting closes after metadata readback.

## Cycle4 fixture evidence — assigned independent gate complete

Current fixed03 includes verified logger56443489 and Environment
`0b1c72c23fdc2cf90ad7ebdb993b1df5804b62ef3e036e21ceab6ea2b6dbfaf2`.
Independent translated classic fog references use native-only visibility and
positive initial readiness. Actual conditions/names remain intact and run once
references settle; no actual visibility success is used to extend waiting. Public
owner/position reconciliation precedes raw mutation; motion remains1600 for exactly
two .25s runner intervals, then stops before the wait. Guard2s/watchdog160 ticks
bound waiting, not a new engine cadence. S8 is circular reveal, not unit occlusion.

Frozen negative changes only private ReferenceTransferReady to false: actual
1/47/1/1 reader1,28PASS/17OBS/1FAIL/1multiplayerSKIP. Exact FAIL detail:
`phase=8 wait=native-reference deadline=2.000 elapsed=2.000`. Abort cleanup,
Stop/Destroy, restoration and per-instance removal/idle PASS; prior expected-negative
validation exit0. Unreached rules OBS, not acceptance. Negative proof/streams
unchanged, normal full47 uninjected. See [cycle4 RESULTS](../reports/cycle4/RESULTS.md).

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

[Exact copied proof](../reports/cycle4/comparison/README.md) retains both exits,
streams, identity evidence and the only correction. Native assessment remains
unassessable/untracked, no approval/receipt. Multiplayer/editor-save/exhaustion/
arbitrary integration/universal production remain uncertified; executable-test
maps are not release/editor-save packages. Risk: item3 verified for assigned
scope; reporting unit docs/evidence only. No new engine evidence or source edits.

## Scoped reporting closure

The single foreground reporting-only readback exited0 with empty stderr:
3 JSON reports,7 Markdown reports and20 exact proof-file copies checked;
copied scripts parsed for syntax only, never executed. No redaction required.
[Readback evidence](../reports/cycle4/comparison/reporting-readback.json).
This supersedes the pre-readback T7 checkpoint above: **T1–T8 all done for scoped
work**, T6 assigned verification complete, T7 reporting complete. No action or
in-scope check pending. Native approval/production readiness remain false;
multiplayer/editor-save/exhaustion/arbitrary integration remain out of scope.
