# Baseline47: classify before patching core

**Current correction status: Scanned.** The parent supplied actual 1.27b gameplay
and `COMPLETE|47|479|70|1`; reader exit1 is a valid failing run, not invalid input.
This worker did not launch, compile, control, or close anything in that session.
No core patch or corrected-game PASS is claimed. This diagnostic unit covers
T3 **S1/S3/S4**, not completion of those specs or the later T4/T5 repairs.

## Evidence remains immutable

- Original records: `RM28-baseline-20261019-02.txt`, SHA-256
  `2dfe0bd57fc9fb1297261f7be45f69898ee0d4e5012e343f35304aca3ae06a19`.
- Original parsed records: `lab-baseline-20261019-02.json`, SHA-256
  `08dc13ef3362a0172dc8b194574ce2684bf6279e759a22a56150404ab17fb73d`.
- Frozen inputs: `../build/inputs-baseline-20261019-02/`. Before edits all seven
  non-config maintained adapters matched these bytes; config alone differed.
- Both baseline and current `Missiles.j` remain identical, SHA-256
  `ff75e5cc9c4805638622ccc553db9dd1e8c19af27333f8e65257d4f706bae05d`.
- `baseline-analysis.json` maps every original FAIL by exact case/name to one
  rule. Original records/details are preserved at the above immutable locator,
  not edited, silently dropped, or converted into PASS.

## All70 FAILs accounted for

| Root rule | Classification | Original FAIL count |
|---|---|---:|
| L01 unlaunched disposal blocked by `allocated and launched` | Real core defect | 3 |
| L04 frozen termination never reaches active-only deallocation | Real core defect | 1 |
| L05/L06/C26 continue orientation after removal | Real core defect | 3 |
| M7/M45 initialize all three Z values from impact | Real core defect | 6 |
| M8/M45 setter mutates current Z / arc leaves next stale | Real core defect under requested coherent-state contract | 4 |
| M13 cached distance predates homing callback teleport | Real core defect | 1 |
| M14 ideal800 versus native distance | Invalid oracle | 1 |
| C21 no actual item geometry/state recorded | Inconclusive | 3 |
| C23 struct-ID hit identity survives target reuse | Real core defect; second FAIL cumulative | 2 |
| E29 vision setter never applies requested radius | Real core defect; native occlusion still limits probes | 2 |
| C36 assumes native destructable XY/ground equal requested0,0 | Inconclusive | 2 |
| C38/C44 write hit memory after terminate+false | Real core defect | 6 |
| C39/C40/C41/C42 no first contact, so retirement/reuse never established | Inconclusive; nine dependent FAILs each | 36 |
| **Totals** | **28 real / 1 invalid oracle / 41 inconclusive** | **70** |

“Inconclusive” does not mean harmless or PASS. In particular the original item /
destructable run does not establish the intended enumeration-continuation
regression: zero first contacts leaves the original missile live, so its
non-reused ID is expected fallout, not independently proven allocator damage.
All real-bug assertions remain RED requirements. Setter coherence and created
cleanup are desired audited contracts; the original code demonstrably does not
implement them, rather than secretly promising those semantics in comments.

## M14: native distance, not a relaxed tolerance

`Coordinates.math` computes `distance = SquareRoot(dx*dx+dy*dy)` and nudges the
impact X by .01 **only** while squared distance or native distance is zero. For
0→800 this branch cannot explain800.015. The same actual run independently logs
M45 square250000 exactly and both expected/native distance500.008, not ideal500.
Thus ideal real-number square root is not a valid .01 oracle for this engine.
At800 an IEEE single-precision ULP is2^-14 (~.000061);800 and640000 are exactly
representable. A .015 deviation is not one ordinary rounding ULP or evidence of
a .01 coordinate nudge. The native's approximate result is implicated, without
claiming a reverse-engineered SquareRoot algorithm or measured general bound.

The corrected assertion captures **before assignment**
`expectedSpeed = (origin.distance - travel) / requestedSeconds` and retains .01.
Independent checks pin origin X0, impact X800 and distance to native
`SquareRoot(800*800)`; OBS logs exposed distance, native root and travel. The
existing getter1±.001, elapsed1±.075 and exactly-one finish remain. Expected
speed is never read back from actual speed or made conditional on a result.
The next run must expose the actual800 native root to complete that direct
measurement; no reconstructed number overwrites this run's record.

## Native contact geometry: fix prerequisites, not expected hit counts

Read-only decoded `baseline/members/war3map.w3t` version2 (all1058 bytes): I001
inherits `rat6`, overrides only `unam`, `utub`, `iico`; no custom life/pathing/
visibility override explains these misses. Recovered `war3map.j` places I001 at
-512.3,466.9. That declaration proves rawcode provenance, **not** runtime XY at
CreateItem(0,0). Same rawcode in C25 hits a radius100 rectangle, while C21's
radius10 misses. C22's LTlt hits radius100 while C36/C41/C42 radius10 miss.
These controls make placement/snapping plausible, not proven. The frozen log
contains no GetItemX/Y, GetDestructableX/Y, visibility or life measurement.

The source enumerates an axis-aligned rectangle; onItems/onDest have no rawcode,
life or visibility filter. With collideZ false, only native enumeration and hit
memory precede callbacks. A callback-type filter patch is therefore unjustified.
Maintained harness changes:

- **C21** creates the item first, centers the stationary missile at actual native
  item XY, and uses equal absolute endpoint Z=`ground(actualXY)+100`. This removes
  horizontal-request and impact-Z confounds, without moving or healing the item.
  Assert XY overlap and `missileZ-radius > itemGround+16` before Z rejection;
  retain hit, hitted, flush, rehit and all expected counts unchanged.
- **C36** centers radius10 probes on actual destructable XY, with bottom=terrain
  there and top=bottom+native occluder height. Source interval test is
  `bottom+height >= missileZ-radius AND bottom <= missileZ+radius`.
  Hence upper equality at `top+10` and lower equality at `bottom-10` must hit;
  .125 outside each must not. All four probes remain, not guessed target sizes.
- **C39–C42** test lifetime/enumeration, not a fixed radius10 contract. Around0,0,
  derive `radius=max(10, max_i(abs(actualX_i),abs(actualY_i))+1)` **before launch**.
  All three native positions then belong to the SAME rectangle, one-unit margin;
  the fresh observer uses that identical radius. No callback result participates
  in geometry selection. Return-true/terminate-false and every individual survivor
  assertion remain. No object is hidden, moved, removed early, or healed.
- Add OBS actual XY/terrain/life/rawcode for item/tree fixtures, native item
  visibility, derived rectangle center/radius and C36 bottom/top. Assert positive
  life and item visibility instead of coercing them. C25 geometry/checks are
  untouched; only native-state observations/prerequisite assertion are added.

These are causal prerequisite corrections, **not** a claim relocation was
observed in the old log. Parent's fresh snapshot/run must show the native data.
If eligible live/visible handles still receive no contact, independently count
those exact handles using public native rectangle enumeration before deciding
whether the remaining defect is engine exclusion or core state. Do not suppress
original contact failures based on a guard or derive expected counts from hits.

## C38/C44: confirmed terminal writes, not a replacement-skip proof

Their first contact, retirement and same-ID reuse succeed; each surviving
candidate then gets0 instead of1 in the fresh lifetime. C37/C43 return-true
controls pass. In source, `terminate()` flushes hit memory and resets collision0;
returning false does not exit the enclosing loop. Colocated survivors still
satisfy distance<=0, and `SaveBoolean` precedes the allocated callback guard.
Those post-terminal writes contaminate the next lifetime. Keep all six REDs.

C44 launches three targets before the observer, so the removed observer is LAST
in public collection: no surviving target is swapped into its index here. This
run does **not** prove a skipped replacement-candidate bug. C26 removes other and
self but has no surviving-candidate completeness oracle. A separate collection
mutation proof would be future scoped work, not justification to redesign core.
L99's reentry checks all passed this run; a source concern is not a demonstrated
runtime double-free. Do not manufacture its failure or weaken its assertions.

## Remaining boundaries

No reader/catalog behavior changed; no new artificial Python source-string tests.
The existing19-test CLI/catalog suite is the proportionate structural check, not
vJASS compilation or gameplay GREEN. Parent owns a new unique-ID frozen build,
compiler and actual1.27b run; corrected PASS remains unproved. Original baseline
still has70 FAIL and multiplayer SKIP. Per-visit acceleration and point/rectangle
geometry remain named limitations, not newly redesigned behavior. S1 repairs,
full S3/S4 functionality, multiplayer and exhaustion proof remain subsequent work.

## Observed checks for this unit

- `python3 -B -m unittest discover -s projects/relativistic-classic/tests -p test_lab.py`:
  exit0,19 tests passed, including existing source-case catalog consistency.
- Read-only Python JSON/hash audit:70/70 original FAIL keys assigned exactly
  once; totals28/1/41; original log/report, both cores and all eight frozen input
  hashes unchanged. No reader/catalog behavior changed, so no artificial tests.
- `git status --short`: only pre-existing untracked `.pi/`, `odd/`, `projects/`;
  no tool scratch/cache introduced. No compiler/game command or scratch used.
