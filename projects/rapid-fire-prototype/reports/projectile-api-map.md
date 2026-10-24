# Projectile API map — Scanned, not native tree proof

Parent-forwarded read-only explorer **mvg78egg-1m-zyih** findings. No explorer artifacts/commands/index/web/native tests; no bookkeeping re-exploration or source edits.

## Pinned current state
`projects/rapid-fire-prototype/src/prototype/PairCore.j`, SHA `770fd2f5bda5b84e8cdcec1b27074a6d8d572787aaa41ceb201fe137dfaffcc3`: actual collision32/launchheight80/speed1200/range1500/`collideZ=false`. Implemented callbacks:onHit/onPeriod/onRemove; missing:onDestructable/onCliff/onTerrain/onBoundaries. Range finish terminates by default; missing obstacle/boundary callbacks **do not**. Do not assume automatic obstacle termination.

Pinned immutable `projects/relativistic-classic/src/Missiles.j` SHA `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6`; explorer references:
- `projects/relativistic-classic/src/Missiles.j:45–58`: callback API declarations.
- `projects/relativistic-classic/src/Missiles.j:261–269` and `:660–701`: destructible collision path. Exact signature `onDestructable(destructable dest) -> boolean`; callback existence activates enumeration, rectangle pad128 plus logical-origin±collision **AXIS box**, not footprint/swept geometry. No native life filter; hit memory is set before callback; true terminates. Later implementation needs its own live filter and must not damage the tree.

Other source-derived limits:cliff only upward plus height threshold; terrain strict GroundZ>z; boundaries WorldBounds, not playable bounds. Public flight observation requires fresh reacquisition from collection[0..count] for live/source/XY. Generation is private; never dereference a saved recycled ID. Dummy delay2s is **not flight lifetime**. These are attributed static findings, not native collision/cleanup proof.

## Next ONE authorized unit — native tree RED preparation
Use **UNCHANGED Core770**, prior five-case regressions plus tree-absent positive control and live-owned-tree case. Qualify actual positions/corridor and calibrated enemy well behind the tree. Live-tree oracle:four launches, early source-flight extinction, no downstream native HP damage, tree HP unchanged. Use fresh public collection observations, not dummy disappearance or saved IDs.

Current missing callback is expected to fly through; this is **not observed RED yet**. Invalid placement/corridor/calibration must abort fixture qualification rather than manufacture a behavior RED. No new source/test prepared and no callback fix until real qualified native RED.

Partial S3 only; range/speed/cliff/bounds/moving S14/mover/animation/UI remain separate future units. Prior Aim55PASS/68OBS, independent PASS and parent spot0 retained. Launcher41 EXIT0 is not closure/profile-free proof; future native run needs fresh exact-profile preflight before observer and protected guard. T2 treeREDprep/T3 integration/T4 future/T5 pending; Specs unchanged/no task done/native authority/production approval. Exact whole checkpoint L50 mirrored to Engram57/wdev/topicodd/rapid-fire-prototype/tasks before source worker.
