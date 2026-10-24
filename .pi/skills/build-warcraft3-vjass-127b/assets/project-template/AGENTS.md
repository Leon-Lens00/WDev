# Warcraft III map rules

- Target vanilla Warcraft III 1.27b. Default to read-only audit; creating a project, building, compiling or changing archives requires implementation authorization.
- Review the skill's host/tool prerequisites, build-safety and tool-command references before execution. Use exact configured JassHelper, pJASS, `common.j` and `Blizzard.j`; establish patch provenance and record hashes/versions. Checker `ok` is structural only; `compatibility_verified=false` is not runtime certification.
- Keep editable vJASS in `src/`; centralize verified rawcodes in `src/config/ObjectIds.j`. Do not invent rawcodes or library members.
- Keep third-party code in `src/libraries/`, map systems in `src/systems/`, and abilities in `src/spells/`. Obtain exact source snapshots and copying permission; upstream license/unknown metadata must not be guessed.
- Use `src/Main.j` as the only project entrypoint; compose sources with `//! import`. Do not concatenate or paste generated JASS manually.
- Save new project `.j` sources as UTF-8 without BOM. Legacy base-map JASS/WCT can use CP1252: preserve original bytes and follow the builder's encoding policy rather than silently converting them.
- Do not use unsupported `Blz*`, Lua, Frame API or unapproved external APIs. `FourCC` is not a classic built-in, but a project-defined helper is not forbidden by name: inspect its body/dependencies and compile it against patch-proven inputs. Merely declaring a modern native does not prove engine support.
- Keep the original map unchanged. After authorization, build/test copies through the skill's builder command and reviewed manifest. Imported project code must not already be compiled into the base `war3map.j`.
- Keep the builder-managed WCT import when editor saves must remain reproducible; builder does not regenerate WTG or decompile editable triggers. Verify reopening/saving a copied map separately.
- Record exact library versions, initialization/lifetime contracts and one owner for UnitIndexer, timer recycling and damage events. Trace local-player taint; forbid local gameplay-handle allocation/mutation and synchronized RNG.
- Verify final-map prefix/archive and managed-member hashes after assembly; report archive round-trip separately from pJASS and game behavior.
- Report exactly one strongest current status for the identified artifact/hash/scope using the skill's testing definitions: Designed, Scanned, Compiled (actual JassHelper output), Validated (actual pJASS), Tested in map, or Tested in multiplayer. Static scans/Python tests do not compile maps. Historical profile claims are unverified here; subset tests do not promote the whole map.
