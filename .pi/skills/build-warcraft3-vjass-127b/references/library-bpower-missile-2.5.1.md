# Profile: BPower Missile 2.5.1

Historical profile: all evidence/claims below are unverified here, not independently reproduced or current certification. No source snapshot was supplied. License/copying permission, exact compiler fork/version, dependency snapshots and complete lifecycle coverage are unknown; see [provenance gates](provenance.md) before copying.

- `name`: Missile
- `author_or_fork`: BPower
- `version_or_commit`: 2.5.1 legacy
- `source`: https://www.hiveworkshop.com/threads/missile.265370/
- `target_patch`: classic Warcraft III
- `required_libraries`: none
- `optional_libraries`: ErrorMessage; WorldBounds or BoundSentinel; MissileRecycler, Dummy or xedummy; UnitIndexer
- `historical_verification_state`: Compiled and Validated with the then-local JassHelper/pJASS and reported 1.27b natives; artifact/tool hashes not recorded in this profile

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

Consider as a structural and collision design baseline for a 1.27b framework, subject to exact-source and permission review; this is not a current drop-in compatibility recommendation.
