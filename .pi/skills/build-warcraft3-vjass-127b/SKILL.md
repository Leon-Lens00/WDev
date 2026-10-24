---
name: build-warcraft3-vjass-127b
description: "Trigger: Warcraft III 1.27b, JASS/vJASS, JNGP, JassHelper, pJASS, W3X, Object Editor, rawcodes, multiplayer, missiles, inventories, map forensics. Audit, recover and build when authorized."
license: "Upstream unspecified; see references/provenance.md"
metadata:
  version: "local-audit-1"
---

## Activation Contract

Use for 1.27b code, objects, libraries and recovery, not strategy/lore or modern/Reforged/Lua unless retargeted. Route spatial generation to a terrain skill.

## Hard Rules

- Default to read-only audit. Do not create project files, build, run compilers or mutate archives without implementation authorization; authorization to audit is not authorization to execute.
- Preserve originals; work on copies only after authorization. Follow [build safety](references/build-safety.md) and [host/tool prerequisites](references/toolchain-requirements.md). Imported project code must not already be compiled into base `war3map.j`.
- Verify APIs against patch-proven natives, exact BJ/library source and actual tools; declarations alone cannot establish engine support. `FourCC` is not a classic built-in; a verified project-defined JASS helper is not automatically modern. Reject unsupported `Blz*`, Lua, Frame/24-player and external APIs for vanilla 1.27b.
- Never invent rawcodes, members or dependencies. Keep one `SetUnitUserData` owner; trace local-player taint, prohibit local gameplay-handle mutation/allocation and synchronized RNG; preserve ownership and cleanup invariants.
- Hashes identify bytes, not compatibility. Static scans/Python tests do not compile maps. Preserve public behavior; separate safe fixes from experiments. Require exact library snapshots and copying permission per [provenance](references/provenance.md).

## Decision Gates

| Question | Required evidence/action |
| --- | --- |
| What was requested? | Project instructions/AGENTS define intent, not runtime truth. Audit only unless implementation is authorized. |
| Does an API exist/work? | Patch-proven common/BJ source, exact library body, actual compiler output, then game test for engine semantics. |
| Is it synchronized? | Dataflow/ownership review plus two-client tests; neither docs nor lint certifies it. |
| Are prerequisites missing? | Stop execution; report unknowns and the next check, not guessed compatibility. |

## Execution Steps

1. Record question, target, authorization and hashes. Load relevant references.
2. Inspect read-only; separate correctness, synchronization, lifetime, initialization, performance and style.
3. Only when authorized, follow [tool commands](references/tool-commands.md) and prerequisites/safety gates. Keep modular imports; builder does not regenerate WTG.
4. Record scoped [test evidence](references/testing-matrices.md); separate archive round-trip, pJASS and gameplay.

## Output Contract

Return files, commands/results, hashes, scope, unknowns and next tests. Classify findings `ERROR`, `WARNING`, `PERF` or `STYLE`. Report exactly one strongest current artifact/scope status per testing definitions: **Designed**, **Scanned**, **Compiled**, **Validated**, **Tested in map**, or **Tested in multiplayer**. Never promote a map from subset tests; mark inherited claims historical/unverified here.

## References

- [Compatibility/rawcodes](references/compatibility-127b.md)
- [Synchronization/handles](references/multiplayer-and-handles.md)
- [Advanced vJASS](references/vjass-advanced.md)
- [Libraries/initialization](references/libraries-and-initialization.md)
- [AI failure patterns](references/ai-failure-patterns.md) and [lint limits](references/lint-limitations.md)
- [Missiles/profile routing](references/missile-systems.md)
- [Classic inventory/UI](references/library-inventorysys-141.md)
- [Recovery/toolchain](references/map-analysis-toolchain.md)
- [Source index](references/sources.md)
- [Project template](assets/project-template/AGENTS.md)
