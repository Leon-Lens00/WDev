# Tree GREEN01 candidate — Scanned, NOT GREEN

T2 partial S3/S26 only. Qualified Tree05 native RED remains `COMPLETE|2|87|3|0`, no ABORT; R06 four native10 hits/pairedHP40 passed, R07 geometry qualified but four downstream hits/HP40 and late extinction failed three unchanged assertions. [Prior results](tree-red05-results.md) remain valid history. Before editing Core, 55 input/plan/build/native/verification/README artifacts were copied to NEW [frozen-tree-red05](frozen-tree-red05/manifest.json), preserving SHA256, size and mtime. No old proof overwritten.

## Only behavior change

`RBProjectile` adds exactly:

```jass
method onDestructable takes destructable dest returns boolean
    return GetDestructableLife(dest) > 0.
endmethod
```

Exact Classic callback spelling/signature matches pinned Missiles. Enumeration supplies the destructable; positive life is the live filter (not the unit .405 threshold). No tree mutation/damage, manual termination, timer, state, new hook, collision change or actor movement. No spent branch is necessary: this callback has no external dispatch or writes; library onDest checks allocated, records the contact, invokes callback, then terminates on true. Further enumeration sees unallocated and returns. Existing onHit spends before native damage for reentrancy, and onRemove clears snapshots/spent; both are byte-identical, as are all other old functions and globals.

## Same scenario, pending parent

[GREEN plan](../build-plan-tree-green01.json) retains ten input slots, import order, entry, reader/output conventions, cases/oracles/budgets/transition, and exact TreeNativeTest SHA `86770d6b75ef7b4ead795f7fad876027372a49c498d1b01608ae95f80987f968`. Only Core and run/logger/bootstrap labels differ. Run `rf-burst-tree-green-20261020-01`; logger and bootstrap are label-only copies. R06 absent positive is the actual same-harness unit-hit regression. Reset/aim logic is structurally unchanged; this is NOT a new native five-case integration run.

Parent owns compile/pJASS/archive checks, fresh exact-profile preflight BEFORE observer/protected launch, and ONE native GREEN measurement using this same harness/assertions. Native GREEN has NOT occurred; no automatic retry, game close/kill, or worker build/runtime action. After GREEN the parent assesses Risk4 independent verification of the new callback; no approval inferred here.

## Static evidence and limits

[Preparation JSON](tree-green01-preparation.json) records the exact bounded structural command, source, stdout, stderr and exit once, including frozen-source differential and all-pin preservation. Structural checks are not compilation or gameplay. No CLI changes; no git differential (unborn tree).

Not claimed: arbitrary tree footprints, swept collision, Z collision, range verification, cliffs, bounds, moving actor, animation/visual behavior, multiplayer or full S3/product completion. Library collision remains discrete logical-origin axis box32 with candidate pad128, not tree-footprint geometry. Native dead/removed-tree cases are not added or claimed. Tree HP unchanged assertions/tolerances are untouched. Checkpoint/status/mirror not updated.
