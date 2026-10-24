# Warcraft III 1.27b compatibility

## Compatibility gate

Before implementing, record:

```text
game_patch:
jasshelper_path_and_version:
pjass_path_and_version:
common_j_sha256:
blizzard_j_sha256:
external_apis_allowed:
```

Absence from memory is not evidence. Search exact patch-proven natives and BJs. Use evidence by question: project instructions establish intent, source establishes definitions, actual compiler/pJASS results establish their respective checks, and game/two-client tests establish observed engine/sync behavior. No AGENTS-over-runtime universal hierarchy applies. See [toolchain prerequisites](toolchain-requirements.md) and [status definitions](testing-matrices.md).

## Default forbidden surface

For a vanilla 1.27b target, reject until locally proven:

- natives beginning with `Blz`;
- unresolved `FourCC` calls: it is not a classic built-in. A project-defined JASS helper named `FourCC` may be valid after inspecting its body, signature, dependencies and compilation; the name alone does not make it modern. Prefer verified rawcode literals, never copy example IDs as real objects;
- Lua and `war3map.lua` workflows;
- Frame API and Reforged-only UI;
- 24-player constants/functions and later player-slot assumptions;
- modern sync natives;
- DzAPI, UjAPI, Memory Hack, SharpCraft-only, WEX-only, or platform-specific functions;
- syntax accepted only by a different JassHelper fork.

Do not attempt a fake translation when the classic engine has no equivalent. State the limitation and design a classic alternative, such as multiboards, trackables, dummy units, lightning, images, or standard effects.

## Native and BJ verification

For an uncertain call:

1. Establish that `common.j` comes from the effective patched 1.27b installation, then search for the native declaration. Merely declaring a modern native does not make it available in the engine.
2. Search `Blizzard.j` for a BJ definition.
3. Inspect any BJ called inside `GetLocalPlayer` for allocations and gameplay effects.
4. Compile a minimal fixture with the exact JassHelper.
5. Test a map copy when engine semantics matter.

## Rawcodes

- Centralize object IDs in one configuration file.
- Keep four-character case exact.
- Confirm each custom rawcode from object data or the editor.
- Never infer IDs from examples.
- Treat a changed rawcode as an API change across code and object data.

## JASS and vJASS order

Plain generated JASS requires callable functions to be declared in a valid order. JassHelper can transform vJASS constructs, but imports, textmacros, callbacks, and generated names can still expose late-declaration failures. Prefer helpers before callers when no vJASS mechanism specifically requires another order.

