# Profile: Chopinski Relativistic Missiles 2.8

- `name`: Missiles
- `author_or_fork`: Chopinski
- `version_or_commit`: 2.8
- `source`: https://www.hiveworkshop.com/threads/relativistic-missiles-vjass-lua-gui.325964/
- `target_patch`: variant-dependent; `030-Missiles.j` is the recovered classic unit backend
- `compiler`: vJASS/JassHelper
- `verification_state`: `030-Missiles.j` **Tested in map** on Warcraft III 1.27b; multiplayer remains untested
- `classic_source_sha256`: `AB341DB4E26697C13839BA54B5DCB3BCDF66526769734294E4AD66BF11C1117B`
- `missile_utils_sha256`: `A78B098B6F8782F6EA8E08C82AA0AEB7A45993D7225FE23D971B4F9457214923`

## Recovered variants

1. `030-Missiles.j`: classic dummy-unit backend. Requires WorldBounds and TimerUtils, optionally DummyRecycler; contains no `Blz*`. Import a valid dummy object and model and set the verified rawcode.
2. `031-Missiles.j`: effect backend for patch 1.31+. Requires MissileEffect and modern special-effect/unit APIs.
3. `032-Missiles.j`: modern unit backend. Uses `BlzGroupGetSize`, `BlzGetUnitCollisionSize`, `BlzSetUnitFacingEx`, and unit real fields.
4. `028-MissileUtils.j`: optional missile-group layer. Requires the exact Missiles API plus Alloc.

For 1.27b, start from the fingerprinted `030-Missiles.j`; do not modernize or mix it with `031`/`032` by replacing individual natives.

When DummyRecycler 1.25 sees Bribe/NewTable 3.1.0.1, its optional Table branch may fail because
the typed `unit` view has no `remove` method. Either keep Table absent so the verified hashtable
fallback is selected, or apply and recompile the narrow compatibility patch
`table.handle.remove(key)`; record the resulting local hash.

## Strengths

- Homing + arc + curve, acceleration, deflect and target deflection.
- Events for hit, missile, destructable, item, cliff, terrain, tileset, period, finish, boundaries, pause, resume and remove.
- Shared 40 Hz scheduler and `SWEET_SPOT` budget with time dilation.
- Explicit public properties, readonly runtime state, reusable dummy backend, and optional `MissileGroup` queries.
- Event specialization through `MissileEvents` and small callback modules; examples exercise the API as executable documentation.

`OnOrient` is an internal movement module, not a public event.

## Verified classic behavior

The 1.27b harness exercised event callbacks, crossing missiles, 50 simultaneous launches, arc/curve variation, vertical projectiles with `collideZ`, homing, `deflect`, radial launch, and MissileGroup pause/resume. This proves functional breadth in one client, not stress safety or synchronization.

## Risks in the classic backend

- Point/radius collision and increased dilation can cause tunneling.
- Missile-vs-missile scans the active collection for each missile and is quadratic in the worst case.
- The classic collision-size helper returns a fixed `64.`; this is an approximation, not the target unit's object-data collision.
- Static callback context such as `temp` makes nested destructable/item callbacks non-reentrant.
- Initial `z`, `prevZ`, and `nextZ` use the impact height instead of the origin height.
- A created but never launched instance has no public cleanup path.
- Legacy `vision` changes owner but not the requested sight radius.
- Time dilation scales displacement but not acceleration or callback frequency, making behavior load-dependent.
- Hit memory is keyed by struct index and is safe only while every launched terminal path reaches the centralized hashtable flush.

Preserve its public behavior where correct. For a new production core, prefer an explicit lifecycle, swept collision, elapsed-time updates, generation-safe hit memory, and per-instance/reentrant callback context. Keep GUI and ability bindings as separate adapters.
