# Rapid Fire — copied playable candidate

**Corrected source: Scanned, NOT_NATIVE_VERIFIED.** Candidate01 compiled/passed archive checks but its first native case aborted before any spell (`COMPLETE 1/3/1/0`). That composite guard did not identify which body predicate failed. Candidate02 adds precise diagnostics and revises order control; parent compilation and fresh native verification remain required. Originals and historical artifacts remain unchanged.

## Play

Open the separate `rfp-playable-20261020-01.w3x` output after building. The visible Orc Shaman starts at `(-3136,2624)`; the selected, shown controller stays off-camera at `(-5500,-5500)`.

- **Q + point:** four fireballs, 4/s, physical10 each, speed1200, fixed range1500.
- **Right-click / M + point:** move. **S:** stop movement without resetting firing.
- Recast refreshes four remaining shots and future heading, not timer phase or launched trajectories.
- **`-rf help`** repeats instructions; **`-rf reset`** respawns the pair and target dummies.

Camera follows the actor; selecting it redirects selection to the controller. Three stationary enemy dummies and two live trees provide a small practice scene. Actor/controller are not paused or hidden.

## Build and test

The parent first prepares `base/playable-01.w3x` with the copied tooling and visible Q ability overlay; record its actual SHA-256 before invoking a plan. Plans contain explicit `argv` arrays; check the actual base hash before execution:

- `build-plan-playable01.json`: `RF_StartDemo`, no battery/logger imported.
- `build-plan-test02.json`: corrected `RF_StartIntegratedTest`, all nine cases, then demo. Global deadline90 game seconds; intended nine-scene duration about59s. No application exit/closure. Plan01 and its frozen inputs/results remain historical and unchanged.

Use the copied `tools/build.py` and byte-exact `src/vendor/` libraries. See [build tooling](docs/BUILD.md) for object preparation/tool commands. Builds use external sources; retained archive WCT/WTG are not the executable source and editor-save round trips are not certified.

The test writes `Logs\RF-rfp-integrated-20261020-02.txt` using RM28. Read that exact fresh log with `projects/relativistic-classic/tools/read_logs.py`, `--run-id rfp-integrated-20261020-02` and `--not-before` set to the parent's recorded launch timestamp. `ABORT-fixture` is a FAIL, not a PASS or SKIP. Inspect the cases, not just COMPLETE. The battery measures launches, lifetimes, positions, native damage/source/HP and movement orders; parameter checks alone are not flight/mover proof. See `reports/integrated-01-correction.json` for correction evidence/exact static commands; original seed/library hashes remain in `reports/integration-preparation.json`.

Historical scoped burst/recast/aim/tree proof remains under `../reports/`; it is not a new integrated result. The aborted standalone cliff preparation is not reused as verified evidence.

## Concrete limits

- The controller's native speed is commanded0 while paired and restored from its pre-pair native getter snapshot on disposal. Revision-checked pending Move/Smart cancellation runs on the existing timer only if the current native order is still Move/Smart, never blindly stopping a later Channel. No teleport, pause, hiding or Move-button removal is used. Actual speed0/unchanged placement/casting must qualify in engine; setter presence is not native proof.
- Actor native speed is also commanded0 during a burst to prevent an outer direct actor Move from adding unchecked native translation before deferred cancellation. Script translation remains350; exhaustion/cancellation restores native350. Ordinary controller Move during an existing burst does not issue another actor Stop or cut its attack. A direct actor Move is stopped once outside dispatch and restores cast facing once.
- Script motion350 uses `SetUnitX/Y`, two <=5.469-unit substeps per .03125s and a conservative 3x3 radius32 footprint. It does not force placement, disable pathing, slide, or promise native pathfinding equivalence. Walkability, actual height change (>24), units/buildings and live destructibles can block a step. A blocked valid goal is retained for native Move at exhaustion; narrow gaps/ramps can be rejected conservatively.
- Nearby units use native footprint checks with conservative unknown64 padding (larger for buildings); destructibles use conservative128 padding. Finite sampling is not a universal arbitrary-sized-object or swept-collision guarantee. A freshly matched own active missile visual is excluded; pending recycler bodies are not mistaken for active flights. Unknown ground units are not silently ignored.
- Missile collision remains the existing library's discrete sampling. Actual ground above fixed worldZ stops flights through `onTerrain`; world exit uses actual WorldBounds through `onBoundaries`. No reliance on the legacy map-corner cliff threshold; no vendor edits or invented terrain APIs.
- Every shot restarts `attack` at300%; exhaustion immediately commands100%, including the final gesture. Native Move may cut that gesture. The HUD/test scale getter is a **command ledger**, not an engine animation getter. Visual animation/model/UI inspection remains necessary.
- One Player0 pair, no multiplayer certification. Stop is supported through the selected controller; direct actor point Move/Smart orders are captured, but arbitrary third-party AI/orders are not a general control API. Smart-on-widget remembers that widget's current position, not a following target.
- Pair death/owner change cancels burst and movement; reset is explicit. Already-launched flights retain their own actor/controller/owner snapshots, terminating if either source body becomes invalid; disposal alone does not rewrite a flight's heading or source.
- Native fixture placement and physical cliff/boundary suitability must qualify in this world. Two fixed cliff candidates and four world edges are bounded searches; unavailable fixtures produce diagnostic FAIL/ABORT for parent iteration, never fabricated success.
