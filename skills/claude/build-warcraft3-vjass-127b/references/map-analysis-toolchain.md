# Map analysis and local toolchain

## Safe directory model

```text
maps/originals/   # never modified
maps/work/        # copied maps and extracted archives
maps/builds/      # generated test maps
src/              # editable modular JASS/vJASS
build/            # generated compiler inputs and verification extracts
dist/             # deliverable W3X copies
reports/          # inventories and audits
```

Never overwrite the sole `.w3x` or `.w3m`.

## Modular project build

Keep `src/Main.j` as the only source entrypoint and compose project files with JassHelper `//! import`. Imports may be nested and relative to their importing file. Do not concatenate or namespace compiled JASS with regexes.

Use `wc3project.json` to declare the immutable base map, entrypoint, toolchain, archive backend, output map, build/report paths, WCT synchronization, and optional archive files. On this CachyOS installation, use `local_launcher` pointing to FrozenThone `scripts/wc3.py`; see [entorno-local.md](entorno-local.md). This delegates JassHelper to the configured Wine runtime and archive operations to native wc3ctl. The optional `mpqeditor` direct backend remains for other configured environments. Run:

```text
python3 skills/claude/build-warcraft3-vjass-127b/scripts/build_w3x_project.py path/to/wc3project.json
```

The builder must:

1. validate the exact 1.27b toolchain;
2. extract `war3map.j` and, when enabled, `war3map.wct` from the base map;
3. generate a compiler input that imports `src/Main.j`;
4. lint sources, compile with JassHelper, and validate with pJASS;
5. copy the base W3X before mutation;
6. inject compiled `war3map.j`, the managed WCT import, and declared archive files;
7. repack on each wc3ctl save, or compact with the direct MPQEditor backend;
8. re-extract every injected member and require byte-identical SHA-256 values.

Use fresh output and build paths. A local Linux compiler import is translated to a Wine Z: path; MPQ member names and editable WCT imports retain their archive/Windows path semantics. The local launcher checks that its configured tools match the manifest; do not silently substitute another compiler.

WCT synchronization preserves existing global script text and owns only the block between `wc3project` markers. Disable it only when the output is intentionally compiled-only. A later World Editor save can overwrite an injected `war3map.j`; keep WCT synchronization enabled for an editable JNGP workflow.

## Map layers

A `.w3x` is an MPQ archive. Relevant members can include:

- `war3map.j` or `war3map.lua`;
- `war3map.w3u/.w3t/.w3a/.w3b/.w3d/.w3q/.w3h` object data;
- `war3map.w3e` terrain;
- `war3mapUnits.doo`, `war3map.doo` placements;
- `war3map.w3r`, `.w3c`, `.w3s`, `.w3i`, `.imp`, `.wts`;
- trigger files, imports, models, textures, and listfiles.

When the terrain grid grows or shrinks on the west or south side (for example, to widen the minimap), coordinates in world units stay valid. Members stored in grid cells from the south-west corner do not. In 1.27b `war3map.doo` (version 8) ends with a *special doodads* block: version 0, a count, then per entry `id, z, x, y` as int32 tile indices. These are cliff pieces such as `YCr2` (Rough cliff cave 2) and `YCg*` (cliff slides). Normal doodads use world floats. Copying an old `.doo` onto a widened `.w3e` moved a cliff cave onto flat ground, where it rendered as a box with a black opening, with no error; it was seen in Dev Mission v14j on 04/11/2026. Shift those cells by the added columns or rows, and compare the block with the one the editor saved. `war3map.wpm` and `war3map.shd` are also grids: pad them rather than copying them.

If only compiled `war3map.j` exists, original vJASS abstractions, comments, modules, textmacros, and naming may be lost. Prefer official `.j` sources or editable demo maps when studying architecture.

## Trigger and source recovery

Do not equate compiled `war3map.j` with the editor source. Check all three layers:

| File | Role | Recoverable information |
|---|---|---|
| `war3map.wtg` | Trigger Editor structure | Categories, variables, trigger names, enabled state, GUI ECA trees, and `isCustomText` metadata |
| `war3map.wct` | Editable custom trigger text | Map header script and per-trigger JASS/vJASS before JassHelper expansion |
| `war3map.j` | Executable map script | GUI-generated JASS plus the JassHelper-compiled result used by the game |

World Editor rebuilds the Trigger Editor from WTG/WCT; it does not decompile `war3map.j`. For a custom-text trigger, correlate its WTG entry with the WCT block at the same trigger index. Treat empty WCT entries as valid because GUI triggers normally store their logic in WTG.

Recover disabled WCT blocks for inspection, but exclude them when reproducing the active build. A map can contain an enabled compatibility adapter and a disabled full library with the same name (InventorySys 1.4.1 includes both forms of AutoIndex). A dependency regex can also mistake inline comments for library names or lose the distinction between required and optional dependencies; verify the actual declaration and WTG flags before assembling imports.

Apply this recovery decision:

```text
WCT contains full source
  -> analyze original vJASS and compare it with compiled war3map.j
WCT contains //! import "Library.j"
  -> locate the external file; the directive does not prove its source is embedded
WTG exists but WCT entry is empty
  -> decode the GUI ECA tree or analyze its generated JASS
WTG/WCT absent
  -> report compiled-JASS-only recovery; do not claim reconstructed structs/modules
```

An optimizer or map protection step may remove WTG/WCT. Never bypass deliberate protection without authorization.

## Extraction

Use a reviewed MPQ tool or library. Extract to a new directory. Preserve archive hash and extraction log. Protected or malformed maps may require a different listfile or may not be legally/technically appropriate to reverse engineer; do not bypass protection without authorization.

Some classic W3X files begin with an `HM3W` metadata header and place the actual `MPQ\x1A`
archive at an aligned later offset such as 512 bytes. If an MPQ tool silently extracts nothing,
detect the signature instead of treating the map as empty. Operate on a staged raw MPQ copy,
preserve the prefix byte-for-byte, rebuild the copied W3X, and verify both the prefix and managed
members after packaging.

## WC3MapTranslator boundary

`@voces/wc3maptranslator` translates individual extracted `war3map*` binary files to/from JSON; it does not itself open the MPQ archive. Pin and audit the exact package and transitive dependencies. Prefer read-only binary-to-JSON use until round-trip tests pass on disposable copies.

## WC3Data boundary

The public-source `d07RiV/wc3data` project is a valuable reference for browser-based archive/object/script/model/map viewing. Its root exposes DataGen, browser code, and WASM build instructions but has no repository-wide license. However, the `src/mdx` parser and viewer subtree includes its own MIT license. That subtree may be evaluated for reuse with its copyright and license preserved; treat the surrounding React application and DataGen pipeline as research-only until their licensing is clarified.

For a local 1.27b toolchain, keep WC3MapTranslator and the WC3Data viewer complementary instead of forcing one through the other at first:

- WC3MapTranslator converts extracted `war3map.w3e`, placements, map info, and object files into JSON for searching, reports, correlations, and audits.
- The WC3Data `src/mdx` viewer reads the binary terrain and placement files for faithful WebGL visualization.
- Both outputs should be cross-checked against the same read-only map copy.

Terrain rendering also needs the matching game data and assets (`Terrain.slk`, `CliffTypes.slk`, `Water.slk`, BLP textures, MDX cliff/doodad/unit models). Prefer a local cache generated from the exact authorized Warcraft III 1.27b installation rather than relying on a current remote API. A parser alone does not prove that complete terrain rendering is available.

Keep the executable viewer outside this skill. The skill may invoke a reviewed local `wc3-tools` installation and interpret its reports, but must not assume absolute paths, copy personal configuration, or bundle caches and large vendored renderers. The current local workflow can render terrain, height, water, and cliffs and can list placed units/doodads; exact 3D unit/doodad models additionally require the matching classic object database.

Library-specific findings do not belong in this general toolchain reference. Store exact versions, APIs, dependencies, and issues in separate library profiles such as `library-bpower-missile.md` after inspecting their source.

## Analysis sequence

1. Hash the source map.
2. Copy it to `maps/work`.
3. Extract MPQ members.
4. Run `map_inventory.py` over the extracted tree; inspect decoded WCT source blocks.
5. Correlate WTG metadata, WCT source indices, and compiled `war3map.j`.
6. Translate supported binary files to JSON.
7. Correlate rawcodes across object data, placements, and script.
8. Identify libraries, generated names, dependencies, objects, and imports.
9. Compile original sources separately when available.
10. Render terrain only after verifying exact local 1.27b assets.
11. Generate a report with evidence, recovery level, and limitations.
