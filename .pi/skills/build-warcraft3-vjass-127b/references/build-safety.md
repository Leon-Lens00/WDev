# Builder and compiler safety

## Before building

- Use a separate base map whose `war3map.j` does **not** already contain the imported project's generated code. The builder prepends an entrypoint import to that script; it cannot recognize or deduplicate previously compiled libraries.
- Keep the declared source tree separate from build/extraction directories and published artifacts. If the manifest directory is the implicit source root, keep original `.j` files outside the build directory. That legacy layout remains accepted; generated build files are not treated as original sources.
- The builder does not regenerate WTG or WCT trigger sources from compiled JASS. It only inserts/replaces its managed import block in the WCT global script. Do not rebuild GUI triggers expecting compiled project code to become editable triggers.

## Path safeguards

Before creating directories or writing/deleting artifacts, the builder rejects collisions among the manifest, base map, source `.j` files/entrypoint, literal imported files, archive inputs, toolchain config, MPQEditor, compiler binaries, `common.j`, `Blizzard.j`, output, report, and internal artifacts. It also rejects overlapping extraction/build paths, redirected build-tree symlinks, existing hardlink aliases to inputs, and case-insensitive duplicate archive targets. Archive member validation remains shared by extraction and injection.

Compiler `--output` and `--log` must not overlap each other or any input/tool/dependency. `--dry-run` only prints its command plan: it does not create directories or logs. Normal invocations retain `--debug` and `--no-optimize` support.

Literal `//! import "path"` directives (including jass/vjass/zinc language qualifiers) are followed relative to their containing file, with cycle detection. This is **not** a JassHelper preprocessor or search-path parser. Computed/preprocessed imports and tool-specific lookup rules require manual inspection. Filesystem checks are preflight protection, not a sandbox against concurrent path replacement or malicious external tools.

## Publication and verification

- Compile to a temporary sibling of the requested output; publish only after successful JassHelper output and pJASS validation. Preserve an existing destination on either failure.
- Inject into a working MPQ, then assemble a temporary final W3X beside its destination. Preserve and check the exact HM3W prefix and raw archive bytes after assembly.
- Re-extract managed members from that assembled map (or a raw archive derived from it for MPQEditor), compare SHA-256 hashes, and only then replace the destination. Failed injection, assembly, or member verification leaves the previous destination intact. Build diagnostics/intermediates may remain after failure; map and report publication are not a single transaction.
- Toolchain `ok` means structural checks passed, **not** proof of an authentic 1.27b toolchain. No extra certification fields are assumed.

## Encoding and evidence limits

Decode legacy map JASS and WCT text using the inventory policy: UTF-8 first, then CP1252 fallback. Strip a leading BOM from the legacy base JASS before composing compiler input. Require new project `.j` files to be UTF-8 without BOM. WCT managed-block insertion operates on bytes, preserving unrelated script bytes, comment bytes, and trailing trigger data; encode the new block in the existing script's encoding. A path not representable in a CP1252 WCT must be changed or deliberately migrated outside this operation.

Synthetic regression tests establish validation, failure preservation, command planning, encoding, and simulated round-trip behavior only. Hash equality proves managed-member byte preservation, not MPQ-wide semantic correctness, patch compatibility, editable-trigger consistency, gameplay, or synchronization. Real JassHelper/pJASS/MPQEditor execution, reopening a copied map in World Editor, 1.27b gameplay, and two-client synchronization testing remain separate evidence requirements.
