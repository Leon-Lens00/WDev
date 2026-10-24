# Identity-bound archive preservation correction

## Observed cause

The parent's first real preflight, `inv-baseline-20261019-01`, validated all 10777
assembled JASS lines with Classic pJASS (exit 0). wc3ctl also returned 0. Packaging
then correctly withheld the final map/report because the initial raw multiset guard
could not distinguish housekeeping changes from asset mutation. No game ran.

Read-only diagnosis of those retained bytes found:

| Identity | Original | Injected | Interpretation |
| --- | --- | --- | --- |
| `war3map.j`, neutral | block 5, 457945 decoded bytes | block 0, 477308 decoded bytes | Expected script replacement; decoded bytes match retained assembled.j |
| `(listfile)`, neutral | block 53, 330 archived bytes, 920 decoded-size metadata | block 53, 328 archived bytes, 867 decoded-size metadata | Encrypted housekeeping rewrite |
| `(attributes)`, neutral | absent | block 54, 461 archived bytes, 668 decoded-size metadata | Encrypted housekeeping addition |
| Other 52 identities | present | same identity-bound raw bytes, flags and sizes | No asset recompression, rekeying or mutation observed |

The hash table expanded from 64 to 128 slots. Block-table indices/offsets changed;
comparing indices or filenames from an incomplete manifest would not prove mapping
preservation. All 17 recovered non-script named members also decode byte-identically.
No preserved non-housekeeping member has encryption/FIX_KEY flags in this fixture.

Full hashes, exact changed-entry identities, metadata and protected-file hashes are
in `../reports/archive-diagnosis.json`. The existing failed run and baseline remain
unchanged. mpyq cannot decrypt either housekeeping entry; this correction does **not**
claim their decoded contents are equivalent, readable, or semantically certified.

## Narrow policy

`verify_archive_preservation(original, modified, archive_factory)` reads only the
existing bytes. `archive_snapshot` associates every live MPQ hash identity
`(hash_a, hash_b, locale, platform)` with its raw SHA-256, archived/decoded sizes,
flags and, for FIX_KEY, offset context. Both format version and sector-size shift
must remain unchanged. Duplicate identities and references to non-live blocks fail
with `invalid MPQ identity mapping`.

The only exceptions are:

1. The exact neutral `war3map.j` identity: its decoded bytes must match the assembled
   script through the existing build member check.
2. An **existing** neutral `(listfile)` may be rewritten, with both sides retaining
   the observed `0x80030200` flags and positive sizes.
3. An **absent** neutral `(attributes)` may be added with those same observed flags
   and positive sizes. An existing attributes entry receives no mutation exception.

No identity may disappear. No other identity may appear, including localized variants
of housekeeping names. Every other identity must keep its exact raw payload,
flags/sizes and FIX_KEY context; even a same-payload identity swap is checked through
the identity mapping. Unreferenced live block payloads must also remain unchanged.
Their sorted fingerprint list is compared separately, not silently discarded.

The existing `opaque raw MPQ payload changed` rejection remains unchanged. There is
no permissive switch and no fallback decompressor. Unknown recompression/rekeying is
still rejected, even if a named manifest looks correct. Build reports now include
`archive_preservation` with the preserved identity count and exact allowed changes;
`opaque_payloads` records the final archive's non-script raw payload fingerprints.
No new CLI option or assembly/startup behavior was introduced.

## Verification and limits

The regression replays the **existing** injected bytes through the public builder
with a fake runner; it runs no compiler/injector. Before correction it reproduced the
exact packaging rejection. After correction it passes and verifies the final bytes.
A second replay flips a byte in a real unnamed, non-housekeeping asset and must reject
without publishing a map/report, while preserving baseline and failed-run bytes.
Synthetic cases additionally reject identity swaps, unknown additions/removals,
localized housekeeping, existing attributes mutation, changed sector size, orphan
blocks and relocation of FIX_KEY ciphertext without proved rekeying.

Tests use fresh children under `/tmp/wdev-inventorysys-lab/` and clean them. This is
archive-byte evidence, not full asset semantics, editor-save, gameplay or multiplayer
certification. Parent owns the single corrected real build with a new run ID and
all later game checks; no archive tools were replaced or installed.
