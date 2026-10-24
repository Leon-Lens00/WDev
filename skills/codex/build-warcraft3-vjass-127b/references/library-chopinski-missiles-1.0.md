# Profile: Chopinski Missiles 1.0

- `name`: Missiles
- `author_or_fork`: Chopinski
- `version_or_commit`: 1.0, two WCT backends in the supplied map
- `source`: https://www.hiveworkshop.com/threads/missiles.325867/
- `target_patch`: unit backend compatible with 1.27b; effect backend modern
- `required_libraries`: none in the core; optional WorldBounds
- `verification_state`: unit backend Compiled and Validated; effect backend rejected for 1.27b

## Contract

A normal `Missiles` struct extends a defaulted event interface. One shared timer processes an active array. The unit backend attaches effects to a dummy and supports hit, destructable, item, missile, period, finish, terrain and remove events. It combines homing with arc and curve and exposes bounce/deflect.

## Variant boundary

The recovered WCT contains:

- classic unit backend: no `Blz*`, validates on 1.27b;
- special-effect backend: uses `BlzSetSpecialEffect*`, incompatible with 1.27b.

Do not classify the entire resource from the map's currently compiled `war3map.j`; inspect the exact enabled source block.

## Risks

- Widget collision samples the current point/radius, so fast missiles can tunnel.
- Missile-vs-missile is a global nested traversal.
- Hashtable impact memory must be flushed on every termination path.

Use its direct API and combined-trajectory behavior, but replace collision with a swept method.
