---
name: build-warcraft3-vjass-127b
description: "Trigger: Warcraft III 1.27b, JASS/vJASS, JNGP, JassHelper, pJASS, W3X, Object Editor, custom units, classic interfaces and inventories, multiplayer, missiles, rawcodes, map forensics. Build, audit, compile, and recover classic maps and code. Use the dedicated terrain skill for complete spatial generation. Exclude Reforged, Lua, and modern patches unless the target changes."
---

# Warcraft III vJASS 1.27b

Treat Warcraft III 1.27b, the installed JassHelper, and the map's exact libraries as a closed compatibility target. Verify; do not recall APIs from newer patches.

## Evidence order

Resolve conflicts in this order: map source and `AGENTS.md`; installed `common.j`/`Blizzard.j`; installed JassHelper; exact bundled library source; pJASS; copied-map test on 1.27b; two-client test for synchronization; patch-matched reproducible community evidence.

Do not claim a function, member, callback, rawcode, or dependency exists without evidence from the relevant layer.

## Workflow

1. Validate and fingerprint `wc3toolchain.json` with `scripts/check_toolchain.py`.
2. Preserve the only `.w3x`; keep editable code modular under `src/` with one `Main.j` entrypoint.
3. Load only task-relevant references.
4. Separate correctness, synchronization, lifetime, performance, and style.
5. Build with `scripts/build_w3x_project.py`: lint, compile, validate, inject into a copied W3X, and verify MPQ round trips.
6. Report the strongest verification state reached and remaining tests.

## Reference routing

- Patch/API/rawcodes: `references/compatibility-127b.md`
- Multiplayer/handles/groups/waits: `references/multiplayer-and-handles.md`
- Advanced vJASS: `references/vjass-advanced.md`
- Libraries/initialization: `references/libraries-and-initialization.md`
- AI failure patterns: `references/ai-failure-patterns.md`
- Missiles: `references/missile-systems.md`; load the matching `references/library-*.md` profile for an exact implementation
- Map recovery/toolchain: `references/map-analysis-toolchain.md`
- Classic camera-based interfaces, clickable dummy units, dynamic icons, inventory/equipment: `references/library-inventorysys-141.md` (observed techniques and defects; not multiplayer certification)
- Validation: `references/testing-matrices.md`
- Local Linux game/editor test execution and safe session closure: `/home/snz/.codex/skills/probar-warcraft3-classic-linux/SKILL.md`
- Provenance: `references/sources.md`

## Hard rules

- Reject `Blz*`, `FourCC`, Lua, Frame API, 24-player APIs, and external patch APIs for vanilla 1.27b unless the exact local natives prove availability or the user explicitly changes the target.
- Use rawcodes such as `'hfoo'`; never invent object IDs.
- Treat every `GetLocalPlayer` branch as tainted until all writes and later data flows are proven cosmetic and local-safe.
- Do not create, destroy, recycle, mutate gameplay handles, or consume synchronized RNG in a local-only branch.
- Keep one authorized owner of `SetUnitUserData` when using a UnitIndexer.
- Record the exact version, source, dependencies, lifecycle, and compiler requirements of every external library; do not mix forks.
- Preserve public behavior when auditing legacy libraries. Propose safe fixes separately from experimental refactors.

## Output contract

Classify findings as `ERROR`, `WARNING`, `PERF`, or `STYLE`; do not present an optimization or preference as a correctness bug.

Report exactly one strongest status: **Designed**, **Scanned**, **Compiled**, **Validated**, **Tested in map**, or **Tested in multiplayer**. Do not collapse these states into "works perfectly."

## Bundled tools

- `scripts/check_toolchain.py CONFIG [--json]`: verify the 1.27b target, required files, classic native surface, absolute paths, sizes, and SHA-256 fingerprints.
- `scripts/wc3lint.py PATH [--json]`: conservative static scan for legacy compatibility and known failure patterns.
- `scripts/compile_vjass.py --jasshelper EXE --pjass EXE --common FILE --blizzard FILE --input FILE --output FILE [--debug] [--no-optimize] [--dry-run] [--log FILE]`: JassHelper `--scriptonly` followed by pJASS.
- `scripts/build_w3x_project.py MANIFEST`: build modular `.j` sources, update the managed WCT import, inject compiled/archive files with MPQEditor, compact, re-extract, and hash-verify.
- `scripts/map_inventory.py EXTRACTED_DIR`: inventory extracted files, decode editable WCT trigger text, and detect vJASS constructs without modifying the map.
- `assets/project-template/`: modular source tree, map directories, toolchain/project manifests, and project rules.
