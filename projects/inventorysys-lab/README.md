# InventorySys 1.4.1 evaluation lab

T1 preserves the supplied map and supplies the guarded builder. T2 adds a bounded
14-case plain-JASS public-API adapter, persistent logs and a strict reader for
Warcraft III 1.27b. T3 completed actual pJASS, packaging and own-game evaluation.
No fixes to the original system were made.

**Current status: Tested in map** — single-client, bounded 14-case scope only.
COMPLETE records 16 PASS / 2 FAIL / 6 OBS / 4 SKIP (166 records); the public reader
exits 1. This is evaluated test delivery, not all-green system approval.
See [final evidence and limitations](reports/FINAL.md),
[machine-readable status](reports/final-status.json) and
[independent verification](reports/independent-verification.md).

A **separate manual recorder map** is delivered: [InventorySys-Manual-20261019-01.w3x](maps/InventorySys-Manual-20261019-01.w3x).
Its strongest current status is **Validated**, not Tested in map; actual runtime
writing remains unverified. It starts the original demo, not automatic fixtures.
See the [10–15 minute human instructions and exact launch command](docs/manual-testing.md),
[manual delivery evidence](reports/manual/FINAL.md) and
[session/freshness record](reports/manual/delivery.json).
T4 is awaiting_user. The user launches and operates it, then confirms completion;
protocol tests do not prove gameplay or log persistence.

Start with [evaluation coverage, evidence grammar and manual actions](docs/evaluation.md).
Case 9's combined pickup oracle is inconclusive; case 14 observed retained custom-ID
instance metadata after setItem(0). Neither proves a baseline contract violation.
Both FAILs remain; restart the copied map before manual evaluation. The adapter
never repairs private baseline state.

- Original SHA-256: `a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada`
- Original size: 621592 bytes; original HM3W prefix: 512 bytes.
- `baseline/original.w3x`: byte-identical local reference; never edit or overwrite.
- `baseline/members/`: named generated script, WCT/WTG/WTS, object/environment members.
- `baseline/wct/`: exact custom-text bytes without their WCT length/terminator framing;
  all 47 slots, including empty slots, are indexed in `reports/recovery.json`.
- Original credits/comments remain intact. Local user-authorized evaluation only;
  no redistribution permission or license grant is inferred.

## Commands

Run from the repository root. The workshop Python already provides mpyq; do not
install dependencies. Every command uses `-B` to avoid repository bytecode caches.

### Recover once (already performed in T1)

This creates a **new** baseline directory and recovery report. Repeating it against
this project intentionally fails without replacing anything.

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/build.py recover --map '/home/snz/Documentos/WarDatsPy/Inventory  Equipment System v1.4.1/InventorySys v1.4.1.w3x' --project projects/inventorysys-lab --expected-sha256 a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada
```

### Assembly only (no compiler/game)

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/build.py assemble --base projects/inventorysys-lab/baseline/original.w3x --globals projects/inventorysys-lab/src/globals.j --functions projects/inventorysys-lab/src/functions.j --entry IL_Start --run-id inv-001 --output-dir /tmp/wdev-inventorysys-lab/NEW_ASSEMBLY_CHILD
```

Use a fresh child under the authorized temp root. This writes
`NEW_ASSEMBLY_CHILD/inv-001/assembled.j` and `assembly.json`, without external tools.
Use another run ID for every attempt: IDs are 1–80 ASCII letters/digits/underscore/
hyphen, beginning with a letter or digit. Existing run directories are never reused.

### Build (parent-owned; actual T3 evidence retained)

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/build.py build --base projects/inventorysys-lab/baseline/original.w3x --globals projects/inventorysys-lab/src/globals.j --functions projects/inventorysys-lab/src/functions.j --entry IL_Start --run-id inv-002 --output-dir projects/inventorysys-lab/reports/runs --wc3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3-taller.py
```

The command names the real wrapper file: `Taller-WC3/wc3` is a symlink and is
intentionally rejected by the input guard. The workshop wrapper runs
`wc3 pjass ASSEMBLED`, using its installed Classic
common.j/Blizzard.j, then `wc3 wc3ctl file set INPUT_COPY war3map.j ASSEMBLED --out
NEW_COPY --json`. T3 recorded [actual tool/native provenance](reports/toolchain-provenance.json).
No JassHelper or WCT imports are used: the original libraries are already compiled.
The final map is `reports/runs/inv-002/inv-002.w3x`; `build.json` records its hash,
input/member hashes and scope. Each tool has an immutable `command-N.json` containing
argv, exit code, exact stdout/stderr (UTF-8 surrogate-escaped for arbitrary bytes).
`commands.json` aggregates completed tool attempts; launch errors/timeouts are recorded
with a null exit code. Tools have a 120-second timeout and are never retried.

Failures retain diagnostics/intermediates but never publish a successful build report
or final map after a tool or verification failure. No map is staged in a game directory.
Publication of the map and report is not a filesystem transaction. The guard is not
a sandbox against concurrent hostile filesystem replacement or malicious tools.

### Tooling tests and help

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B -m unittest discover -s projects/inventorysys-lab/tests -v
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/build.py --help
```

Fixture-writing tests respect supplied TMPDIR, with `/tmp/wdev-inventorysys-lab/`
as the fallback. For isolated runs, first create a fresh child under that authorized
root and set HOME/TMPDIR/XDG_CACHE_HOME to its home/tmp/cache subdirectories.
All fixtures then remain inside that child and clean up automatically.
The read-only `test_actual_run.py` instead uses retained project-relative artifacts
and requires workshop Python's mpyq. Tests do not consult git history. The packaging correction preserves assembly and
recovery behavior; its identity-bound guard is documented below.

## Adapter contract

`--globals` supplies **declarations only**, without globals/endglobals wrappers.
`--functions` supplies UTF-8, BOM-free plain JASS function definitions, including
exactly one `function IL_Start takes nothing returns nothing` (or the supplied entry).
Optional paired `--early-functions`/`--hooks` flags add the separately documented
manual insertion path on `assemble`/`build` only; absent flags retain the automatic
route and report shape. Its entry is `ILM_Init`; recording still requires an explicit
`-im start <label>`. `read_manual_logs.py --help` describes the independent reader
and exact `-im status`, `-im mark`, `-im save`, `-im stop` forms.

No imports, libraries, scopes or duplicate library compilation. Use an inventory-lab
prefix such as `IL_` for every new identifier. `@RUN_ID@` substitution applies only to
adapter bytes, never to original map bytes. Public Python entry points are
`main(argv, archive_factory=..., runner=...)`, `assemble(original, globals_source,
functions, entry, run_id)`, `read_map`, `wct_blocks`, `recover`, and `build`.

The assembler requires unique globals/endglobals and main anchors, with the original
main ending in `call InitCustomTriggers()` followed only by newlines. It inserts:

1. Adapter declarations immediately before original `endglobals`.
2. Adapter functions immediately before original `function main`.
3. Exactly one startup call immediately before main's `endfunction`, **after** original
   `StartGame___Init`, all generated system/demo initializers, `InitGlobals`, and
   `InitCustomTriggers`. IL_Start schedules readiness/scenarios after a 2-second
   delay rather than replacing or manually invoking the original initializers.

All other original script bytes, including CRLF and comments, remain unchanged.
Missing/duplicate anchors, malformed run IDs, aliases, symlink paths, hardlinked inputs,
existing destinations and overlapping input/output roots are rejected before writes.
No shared helpers or files in the missile project are modified; digest/write-new/guard/
map-slice/tool-capture patterns were adapted, not its runtime or reconstruction strategy.

## Archive and evidence limits

The loader uses `MPQArchive(BytesIO(map_bytes[offset:]), listfile=False)`. Recovery
extracts only named members, never every asset or the encrypted listfile. Raw
non-script live MPQ blocks are hashed without decompression. Build verification binds
raw payloads to hash-table identities, preserving unknown mappings and orphan payloads,
not merely a multiset or named manifest. Only the evidenced neutral `(listfile)` rewrite
and new neutral `(attributes)` entry are permitted housekeeping exceptions; their
encrypted contents are not claimed equivalent. All other mutations, recompression or
unproved FIX_KEY relocation remain rejected. See [diagnosis and precise policy](docs/archive-preservation.md).

Packaging preserves the original prefix, re-extracts the final assembled map, and
checks generated JASS plus every recovered named member, including original WCT/WTG,
WTS and object bytes. Input hashes/bytes are checked again before publication. These
checks do **not** certify all asset semantics or full MPQ integrity. Retained WCT/WTG
are not synchronized to the adapter: this is an executable test map, **not editor-save
certified**. Static/synthetic tests do not establish pJASS, gameplay or multiplayer
success. T4's [independent shared-startup/evidence verification](reports/independent-verification.md)
completed; its sole stale-documentation blocker is addressed by this bounded correction.
