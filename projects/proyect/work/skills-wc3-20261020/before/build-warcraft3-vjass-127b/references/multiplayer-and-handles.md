# Multiplayer, handles, groups, waits, and performance

## `GetLocalPlayer` taint model

Treat any value assigned inside a local-player branch as tainted. Follow it after the branch and reject later uses that affect units, items, abilities, orders, timers, triggers, RNG, game-state globals, or handle allocation.

Allowed operations must be individually proven cosmetic, such as narrowly scoped display or sound changes supported by the target patch. Creating synchronized infrastructure globally and changing only its local visibility is safer than creating it locally.

Inside a local branch, reject by default:

```text
CreateTimer CreateTrigger CreateGroup CreateUnit CreateItem
AddSpecialEffect Location Rect Condition Filter
Destroy* RemoveUnit SetUnitState UnitAddAbility Issue*
GetRandomInt GetRandomReal
```

Review every BJ called locally. A BJ that looks visual can create timers or other handles internally.

## Handle ownership

Classify before cleanup:

| Class | Example | Rule |
|---|---|---|
| borrowed | `GetTriggerUnit()` | Do not destroy; clear obsolete local reference |
| temporary-owned | `CreateGroup()` for one enumeration | Destroy or intentionally recycle |
| persistent-owned | scheduler timer/group | Destroy only when owner ends |
| cached/shared | cached `Condition(function F)` | Preserve while users depend on it |
| engine-managed | player, event response, game object not created here | Never destroy as a local cleanup action |

Reassignment does not destroy the former object. Remove a location before overwriting its last reference. Prefer coordinates over locations when the API allows it.

## Boolexpr lifecycle

Do not flag every `Condition(function F)` or `Filter(function F)` as a leak. JASS commonly reuses function-backed expressions. Do not destroy a boolexpr immediately after adding it to a trigger that still depends on it. Review composed expressions and explicit ownership separately.

## Groups

Assignment aliases a group; it does not copy units:

```jass
set temp = persistent
```

Consuming `temp` with `FirstOfGroup` also consumes `persistent`.

- Use `FirstOfGroup` for a temporary consumable group.
- Use `ForGroup`, a real copy, or a swap strategy when membership must remain.
- Never depend on enumeration order for gameplay semantics.
- Reuse an enumeration group in hot paths only when reentrancy/nesting is controlled.

## Waits and schedulers

`TriggerSleepAction` and `PolledWait` are imprecise flow suspension, not automatically proof of desync.

- Cinematic or deliberately loose sequence: may be acceptable.
- Movement, missile, DOT, cooldown, precise delay, MUI state: timer or shared scheduler.
- Preserve suspended state with explicit instance data rather than fragile globals.

## Performance triage

Measure or estimate the hot path before optimizing. Prioritize:

1. repeated unit/destructable enumerations;
2. collision complexity per missile per tick;
3. scheduler frequency and active instance count;
4. repeated object/handle creation;
5. only then small native-vs-BJ or callback differences.

Do not reduce clarity for a cold path without evidence.

