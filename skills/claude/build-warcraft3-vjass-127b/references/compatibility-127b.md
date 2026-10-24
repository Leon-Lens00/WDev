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

Absence from memory is not evidence. Search the exact local natives and BJs.

## Default forbidden surface

For a vanilla 1.27b target, reject until locally proven:

- natives beginning with `Blz`;
- `FourCC` (use rawcode literals such as `'A001'`);
- Lua and `war3map.lua` workflows;
- Frame API and Reforged-only UI;
- 24-player constants/functions and later player-slot assumptions;
- modern sync natives;
- DzAPI, UjAPI, Memory Hack, SharpCraft-only, WEX-only, or platform-specific functions;
- syntax accepted only by a different JassHelper fork.

Do not attempt a fake translation when the classic engine has no equivalent. State the limitation and design a classic alternative, such as multiboards, trackables, dummy units, lightning, images, or standard effects.

## Native and BJ verification

For an uncertain call:

1. Search `common.j` for a native declaration.
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

