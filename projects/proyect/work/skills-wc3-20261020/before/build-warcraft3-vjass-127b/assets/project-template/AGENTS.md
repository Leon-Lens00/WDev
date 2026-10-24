# Warcraft III map rules

- Target vanilla Warcraft III 1.27b.
- Use the exact configured JassHelper, pJASS, `common.j`, and `Blizzard.j`.
- Validate `wc3toolchain.json` and record its SHA-256 fingerprints before compilation.
- Keep editable vJASS in `src/`; centralize rawcodes in `src/config/ObjectIds.j`.
- Keep third-party code in `src/libraries/`, map systems in `src/systems/`, and abilities in `src/spells/`.
- Use `src/Main.j` as the only project entrypoint; compose sources with `//! import`.
- Save every `.j` source as UTF-8 without BOM; classic JassHelper reads a BOM as source text.
- Do not use `Blz*`, `FourCC`, Lua, Frame API, or unapproved external APIs.
- Do not invent rawcodes or library members.
- Keep the only original map unchanged; build and test copies.
- Build through `build_w3x_project.py wc3project.json`; do not concatenate or paste generated JASS manually.
- Keep the builder-managed WCT import when World Editor saves must remain reproducible.
- Record exact library versions and one owner for UnitIndexer, timer recycling, and damage events.
- Report verification as designed, scanned, compiled, validated, tested in map, or tested in multiplayer.
