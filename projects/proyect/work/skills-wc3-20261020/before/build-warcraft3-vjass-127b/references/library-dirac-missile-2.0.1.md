# Profile: Dirac Missile 2.0.1

- `name`: Missile
- `author_or_fork`: Dirac
- `version_or_commit`: 2.0.1
- `source`: https://www.hiveworkshop.com/threads/system-missile.207854/
- `target_patch`: classic design, but current published dependency graph is not reproducible as-is
- `declared_required_libraries`: CTL, AdvLoc
- `actual_additional_dependency`: historical LinkedListModule (`implement LinkedList`)
- `optional_libraries`: WorldBounds, MissileRecycler
- `verification_state`: Scanned; JassHelper compilation blocked by dependency drift

## Contract

Array structs and linked lists support one collection/scheduler per implementing missile type. It offers homing, turn, acceleration, arc, curve, bounce, deflect, unit collision, missile collision and callbacks for collide, period, finish, missile and remove.

## Dependency warning

The published header omits LinkedListModule. Adding current LinkedListModule 2.3.1 reveals a second incompatibility: Missile expects `TimerGroup32`, which is absent from CTL 1.3.0.0 currently linked by the historical CTL thread. Do not ?fix? this by inventing a class. Recover the exact old CTL snapshot or deliberately replace the scheduler API.

## Risks

- One `unitsHit` group per missile.
- Point/radius unit collision can tunnel at high speed.
- Missile-vs-missile traversal is approximately O(n?).
- Historical performance claims are unverified.

Use its trajectory math and deflect/bounce semantics as design evidence, not as a drop-in dependency.
