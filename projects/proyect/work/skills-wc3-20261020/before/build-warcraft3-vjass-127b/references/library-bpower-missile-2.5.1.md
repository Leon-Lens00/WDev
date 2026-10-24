# Profile: BPower Missile 2.5.1

- `name`: Missile
- `author_or_fork`: BPower
- `version_or_commit`: 2.5.1 legacy
- `source`: https://www.hiveworkshop.com/threads/missile.265370/
- `target_patch`: classic Warcraft III
- `required_libraries`: none
- `optional_libraries`: ErrorMessage; WorldBounds or BoundSentinel; MissileRecycler, Dummy or xedummy; UnitIndexer
- `verification_state`: Compiled and Validated with local JassHelper/pJASS and 1.27b natives

## Contract

One shared timer moves a unique active list. Per-struct collections dispatch compile-time callbacks through `MissileStruct`. `static if` strips unavailable optional integrations. Lifecycle uses an `allocated` guard, safe deferred `destroy`, immediate idempotent `terminate`, delayed dummy recycling and hashtable-backed hit memory.

## Strengths

- No mandatory dependencies and no `Blz*`.
- Unit, destructable and item callbacks plus terrain, period, finish and remove.
- Circular collision for small steps and swept rectangle collision for fast motion.
- Optional Z collision and configurable dummy recyclers.
- Good protection against double launch/free and operation-limit spikes.

## Important behavior

When a live `target` is assigned, movement rebases origin/impact and sets `height = 0` and `curve = 0`. Therefore BPower 2.5.1 does not preserve arc/curve while homing.

`MissilePosition extends array` has a custom allocator. A lint lifecycle warning requires inspection; it is not a proven error.

Use as the preferred structural and collision baseline for a 1.27b framework.
