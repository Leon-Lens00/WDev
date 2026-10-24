# Missile systems for a 1.27b target

## Architecture

Separate:

```text
instance state
visual representation
shared scheduler
trajectory
terrain/height
collision
events/callbacks
termination and recycling
```

For 1.27b, default to a dummy unit with Locust moved by classic unit natives. Do not assume modern special-effect position/orientation natives.

## Historical systems to study

- Vexorian `xemissile`/`xe`: classic ecosystem, compact scheduler and dummy patterns. See `library-xemissile-0.9.md`.
- Dirac Missile 2.0.1: trajectory mathematics, curves, homing, and historical scheduler tradeoffs. Its currently linked dependencies do not reproduce the old `TimerGroup32` environment. See `library-dirac-missile-2.0.1.md`.
- BPower Missile 2.5.1: rich classic API, callbacks, swept collision and optional integrations; it compiles and validates against the local 1.27b toolchain. See `library-bpower-missile-2.5.1.md`.
- Chopinski Missiles 1.0: the recovered classic unit backend validates on 1.27b, while the effect backend uses modern `Blz*`. See `library-chopinski-missiles-1.0.md`.
- Chopinski Relativistic Missiles 2.8: recovered `030-Missiles.j` is the classic vJASS dummy-unit backend and is tested in-map on 1.27b; `031`/`032` use modern APIs. Use it as the richest event/trajectory reference, not as a blind copy. See `library-chopinski-relativistic-missiles-2.8.md`.

Use their code and licenses as evidence. Do not combine implementations by copy-paste. Extract concepts, document provenance, then design a clean 1.27b API.

Current design direction: use BPower's shared scheduler, lifecycle and swept collision; Vexorian's classic dummy backend; Dirac/Chopinski trajectory math; and Relativistic's event catalog. Keep any GUI bridge separate and make callback context reentrant.

## Reusable implementation patterns

- Use one shared scheduler and pause it when no missile is active; never allocate one timer per missile without measured justification.
- Model specialized missiles through event hooks or strategy functions. Define whether each callback observes, mutates, or terminates the missile.
- Keep visual representation behind a backend boundary so a classic dummy unit can replace a modern special effect without changing trajectory code.
- Expose readonly runtime state and explicit configuration fields; document units for speed, acceleration, angle, height, period, and collision radius.
- Make examples executable specifications: one focused example per capability plus a combined stress harness.
- Separate optional adapters such as GUI, spell events, damage engines, and missile groups from the core dependency graph.

## Professional code contract

- State lifecycle invariants next to the implementation: who owns the dummy, timer membership, hit memory, effects, groups, and struct index.
- Route every terminal condition through one idempotent cleanup path; prove that it runs exactly once.
- Allow cleanup before launch or forbid unlaunched ownership through an atomic create-and-launch API.
- Never store active callback context in one global/static temporary when callbacks may launch, destroy, enumerate, or recurse.
- Treat callback return values as API: document `true`/`false` semantics consistently and test nested termination.
- Name approximations honestly. A fixed collision size is a fallback, not an exact unit collision value.
- Prefer elapsed-time movement and swept segments over tick-count behavior when load shedding or variable periods are possible.
- Preserve provenance and exact library fingerprints; do not merge similarly named forks by copy-paste.

## Lifecycle

Use an explicit state machine:

```text
CREATED -> LAUNCHED -> ACTIVE
ACTIVE -> HIT / ARRIVE / TARGET_LOST / OUT_OF_BOUNDS / CANCEL
terminal event -> TERMINATING -> RECYCLED
```

All terminal events must converge on one cleanup path that removes the instance from the scheduler, releases collision memory, clears callbacks/effects, recycles the dummy, and releases the index exactly once.

## Trajectory and target cases

Define behavior for:

- line, homing, parabola/arc, lateral curve, orbit, bounce, reflection;
- target death, removal, invulnerability, teleport, and leaving bounds;
- absolute versus terrain-relative height;
- speed units and period independence;
- destination overshoot and arrival tolerance;
- facing limitations of dummy units.

## Collision

Collision usually dominates movement cost. Estimate:

```text
active missiles * ticks per second * enumeration cost
```

Specify unit, destructable, terrain, boundary, and missile collision separately. For piercing missiles, track already-hit units with an index/table/group whose cleanup and index-reuse behavior are proven.

## Comparison dimensions

Compare each candidate on patch/compiler compatibility, required objects, dependencies, scheduler idle behavior, trajectory combinations, collision modes, callbacks, reentrancy, dummy recycling, cleanup, UnitIndexer/Damage Engine integration, and multiplayer tests.

## Required stress tests

- 0, 1, and hundreds of active missiles;
- many launches in one tick;
- target removed during flight;
- callbacks destroying/canceling instances;
- piercing and repeated contact;
- terrain transitions and map bounds;
- long matches and recycled indices;
- at least two clients for any local visual behavior.

For each test, record peak active missiles, duration, terminal reason counts, unreleased instances, dummy count before/after, and whether results match across clients.
