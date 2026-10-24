# Inspect the Classic workshop without changing it

Use the project-local Python CLI to inspect **Warcraft III Classic 1.27b**
inputs. It needs only Python 3.10+ standard library. Its strongest evidence
status is **Scanned**: it does not compile, open MPQ archives, run tools, edit
maps, launch games or certify multiplayer correctness.

## Quick path

Run from WDev (relative input paths always resolve from WDev, not your cwd):

```sh
python3 -B tools/wc3-workshop/wc3.py doctor
python3 -B tools/wc3-workshop/wc3.py doctor --config tools/wc3-workshop/workshop.example.json
python3 -B tools/wc3-workshop/wc3.py sources tools/wc3-workshop/tests/fixtures/Smoke.j
python3 -B tools/wc3-workshop/wc3.py sources tools/wc3-workshop/tests/fixtures
```

For binary members, first **manually extract a copy** through a separately
reviewed workshop tool into a nonhidden WDev directory. Extraction is not
integrated. Substitute the paths of your extracted members:

```sh
python3 -B tools/wc3-workshop/wc3.py objects ability extracted/war3map.w3a
python3 -B tools/wc3-workshop/wc3.py imports extracted/war3map.imp
```

Every command supports `--help`; top-level `--help` lists commands. There are
no write, execute, install, extraction or output-file options.

## Use the project-local Pi tool

1. Review `.pi/extensions/wc3-workshop.ts`, then grant trust to **this project**.
2. Run `/reload` in Pi from WDev. The extension registers `wc3_workshop` through
   the host's normal project-extension discovery; no global settings or install
   is needed. The root `AGENTS.md` supplies Warcraft-specific guidance only.
3. Call the tool with one of these argument objects:

```json
{"action":"doctor"}
{"action":"doctor","config":"tools/wc3-workshop/workshop.example.json"}
{"action":"sources","path":"tools/wc3-workshop/tests/fixtures/Smoke.j"}
{"action":"objects","kind":"ability","path":"extracted/war3map.w3a"}
{"action":"imports","path":"extracted/war3map.imp"}
```

| Field | Rule |
| --- | --- |
| `action` | Required: `doctor`, `sources`, `objects`, `imports` |
| `path` | Required for every action except doctor; forbidden for doctor |
| `config` | Optional for doctor only; project-contained profile |
| `kind` | Required for objects only: `unit`, `item`, `ability`, `destructable`, `doodad`, `buff`, `upgrade` |

Unknown fields and cross-action arguments are rejected before process startup.
Path/config strings must contain 1–4096 characters and no NUL. The CLI remains
the single filesystem containment authority; the wrapper does not resolve or
read user paths itself. It uses the installed Pi API's `exec` with fixed
`/usr/bin/python3`, `-B`, the extension-relative local CLI path, explicit argv,
and WDev cwd. Paths containing spaces, quotes or shell metacharacters remain
single arguments; `--` protects positional paths, and `--config=VALUE` protects
config values. There is no shell interpolation, executable override, external
workshop command, MCP registration or startup process.

The Pi execution timeout is **10 seconds**. Caller cancellation is passed to
Pi and checked before/after execution; cancellation or a killed process never
returns success. Process termination uses Pi's installed implementation, not
an OS sandbox or a guarantee against hostile processes that ignore termination.
Only the trusted, bounded local inspector is invoked. Pi captures its output;
the CLI caps JSON at 512 KiB before printing, and the wrapper rejects combined
stdout/stderr above **64 KiB after capture**, without echoing oversized output
or writing a report. Use narrower inputs or the direct CLI for larger results.
This is not a streaming buffer limit in Pi's exec API.

The tool declares a structured output schema and preserves the CLI envelope in
`structuredContent`, `details` and JSON text content. Valid CLI rejection
(exit 2) becomes `isError: true`; successful inspection (exit 0) becomes false.
Malformed/mismatched envelopes, unexpected stderr, other exit codes, process
startup errors, cancellation and timeout throw bounded errors prefixed with
`[wc3_workshop:CODE]`. Wrapper codes are `arguments`, `protocol`, `process`,
`output`, `cancelled`, `deadline`; raw unexpected process diagnostics are not
forwarded. Read-only/idempotent/closed-world hints describe the inspector's
behavior, not independently enforced permission guarantees. Extensions execute
with Pi's OS permissions; project trust is not filesystem isolation.

## What each command establishes

| Command | Evidence | Not established |
| --- | --- | --- |
| `doctor [--config PROJECT_JSON]` | Presence of five fixed authorized directories; optional local artifact sizes/SHA-256 | Tool version, provenance, compilation or runtime compatibility |
| `sources PATH` | Lexical declarations, library dependency spelling, literal import directives, rawcodes and modern-API mentions | Complete call graph, semantic resolution, macro expansion, import traversal or syntax validation |
| `objects KIND PATH` | Stored version-2 tables and typed modifications, without metadata inference | Effective base values, WTS resolution, editor round-trip or correctness in game |
| `imports PATH` | Version-1 manifest flags and verbatim path spelling, plus unsafe-path findings | Asset existence, extraction, effective archive paths or model/texture validity |

### Doctor configuration

The example is deliberately empty: no private external configuration is copied.
The UTF-8 JSON object must contain exactly `artifacts`, an object mapping any
subset of `common`, `blizzard`, `pjass`, `jasshelper`, `provenance` to existing
**project-contained file paths**. For example, after independently staging an
authorized header copy: `{"artifacts":{"common":"extracted/common.j"}}`.
Unknown keys, duplicate keys, external paths and malformed profiles are rejected.
Omitting `--config` runs default doctor; an explicitly empty `--config ''` rejects
with exit 2, empty stderr and error `path: Expected a nonempty project path.`
Paths resolve from WDev, not the config directory. Config files are at most
16 KiB. Artifact files are bounded and hashed, never executed or parsed as
configuration. Do not point this tool at personal or secret material.

The fixed presence-only locations are the authorized FrozenThone `tools`,
`scripts`, `games/WarcraftIII-1.27b`, `editors/newgen/jasshelper/standart`, and
WarDatsPy `wc3-forge` directories. These checks neither enumerate their contents
nor hash installed game archives. Missing locations are findings in a successful
scan, not an execution approval. An invalid configured artifact rejects the
request. `compatibility_verified` and `execution_verified` remain false.

### Source navigation

Recognized declarations: library/library_once, scope, struct, module, interface,
function, method and native (with common access/static/constant/stub modifiers).
Library `requires`/`needs`/`uses` clauses preserve comma-separated lexical names,
including `optional`. Single-line `//! import [jass|vjass|zinc] "path"` directives
are reported **without opening their targets**. Paths in directives are evidence,
not user filesystem inputs. Comment and quoted-string contents cannot generate
false declarations or modern-API mentions; block comments are masked too.
Four-byte single-quoted rawcodes carry original text and hex bytes.

`Blz*` and `FourCC` identifiers outside comments/strings are advisory mentions,
not a complete native compatibility check: a project-defined helper may have that
name. Full vJASS textmacros, modules, scopes and initializer semantics require
JassHelper and manual review. Unterminated comments/quotes, quoted newlines and
non-four-byte rawcode literals reject input, but other malformed JASS can pass.
UTF-8 is attempted first, then strict CP1252. Each source and object/import
string reports its actual decoding choice; undefined CP1252 bytes are rejected.
No input is converted or rewritten. A BOM is not silently stripped.

### Object formats

| KIND | Extracted member | Extra stored columns |
| --- | --- | --- |
| `unit` | war3map.w3u | none |
| `item` | war3map.w3t | none |
| `ability` | war3map.w3a | level, data |
| `destructable` | war3map.w3b | none |
| `doodad` | war3map.w3d | variation (reported as level), data |
| `buff` | war3map.w3h | none |
| `upgrade` | war3map.w3q | level, data |

Only version 2 is accepted. `original` and `custom` tables preserve old/new IDs,
field IDs and end IDs as Latin-1 byte-preserving display text plus authoritative
hex. Stored tags `0`/`1`/`2`/`3` mean signed int32/float32 real/float32 unreal/string.
No inferred types, type coercion for writes, SLK defaults or WTS expansion occurs.
Nonfinite floats, invalid type tags, bad end IDs, negative counts, trailing bytes
and truncated members reject the entire result. The caller selects KIND; a
filename is not proof of its actual format.

Import flags `0`, `5`, `8`, `13` are preserved; other flags reject input. Manifest
strings preserve spelling (including backslashes). Empty, rooted, drive/colon,
or parent-traversing paths are `unsafe_path: true` findings. No manifest entry
is opened; `assets_checked` is always false.

## Boundary, bounds and machine interface

All user input/config/artifact paths and directory entries share one canonical
WDev-only containment check. Absolute paths inside WDev are accepted. Traversal,
hidden components, named credential/history/key locations and **all symlinks**
are rejected, including internal links and directory cycles. Directory scans
validate even non-source entries before filtering; use a narrow clean source
folder. Only regular files are read; FIFOs/devices are rejected. This protects
ordinary local inspection, not hostile concurrent parent-directory replacement
or hardlink aliases to sensitive files. Do not expose it as a multi-user service.

| Resource | Hard bound |
| --- | --- |
| Input file / local artifact | 1 MiB |
| Source directory | 2048 entries, 64 source files, 4 MiB aggregate |
| Source output records | 4000 aggregate |
| Binary count / aggregate records | 1000 per count, 4000 aggregate |
| NUL-terminated binary string | 4096 bytes |
| Serialized JSON output | 512 KiB, checked before printing |

Limits reject, never silently truncate or return partial success. All decoders
share one bounded binary reader. The CLI opens files read-only, with no child
process, archive writer, cache, report or input mutation. Python bytecode writes
are disabled by the entrypoint; `-B` is also recommended.

Except help, stdout is exactly one JSON envelope and newline; stderr is empty.
Exit **0** means inspection succeeded (not that findings are safe); exit **2**
means rejection. Envelope keys are `schema_version` (1), `ok`, `action`, `target`,
`evidence`, `limitations`, `result`, `error`. Success uses `evidence: "Scanned"`,
`error: null`; failure uses `evidence: "Rejected"`, `result: null`, and an error
object with `code` and `message`. Unknown/missing actions have `action: null`.
Error codes: `arguments`, `path`, `limit`, `config`, `encoding`, `source`,
`version`, `binary`, `io`, `input`. Message wording is diagnostic; integrations
should branch on codes. Help is human-readable text, exit 0.

## Audit findings and safe next steps

These prior static findings are **historical audit evidence**, not claims that
this CLI has independently executed or certified those capabilities:

The original real-source smoke inspected the unrelated local
`projects/relativistic-classic/src/MapMain.j` successfully (UTF-8, four function
declarations). That historical result is not a delivered dependency: repeatable
examples and tests use the authored suite-owned `Smoke.j` fixture instead.

- Gentle's CodeGraph facade invokes an external backend that was absent from
  the observed PATH. Its presence does not establish JASS support; no index was
  initialized. Actual agent configuration belongs under
  `PI_CODING_AGENT_DIR=/home/snz/.gentle-shell/agent`, not an assumed `~/.pi`.
- wc3ctl registers seven object kinds and MPQ/import/model operations. Its
  ObjectSetCommand infers types for new fields; its TestLoad path is
  Reforged-oriented and JASS-to-Lua raises the target version. None is an
  implicit safe Classic default. PjassGate's advisory handling of undeclared
  `BlzGetUnitZ` and skipped checks cannot certify 1.27b.
- Classic provenance metadata exists but lists ItemMetaData.slk missing.
  Observed pJASS, bundled dotnet and header file presence is not execution or
  patch-provenance proof. Forge has a conservative Classic save profile and
  lexical jassgraph source; an executable graph backend was not established.
- FrozenThone's `scripts/wc3.py` compilation/vJASS bridge writes external
  caches/reports/support files and Wine/Proton profiles. Merely changing cwd
  does not contain those effects. Do not invoke it automatically.

For compilation, manually review the existing project build instructions and
`.pi/skills/build-warcraft3-vjass-127b/` safety/prerequisite references first.
Match exact headers, distribution and patch provenance, then separately obtain
compiler evidence. Editor/game launch and multiplayer tests need distinct
permission and evidence; graphical launchers have additional uninspected Steam
runtime dependencies. No global change or external workshop executable was
authorized for this integration; the Pi wrapper invokes only the local inspector.

## Check the integration

```sh
node --test tools/wc3-workshop/tests/test_extension.mjs
python3 -B -m unittest discover -s tools/wc3-workshop/tests -p 'test_*.py' -v
```

The Node harness requires an existing installed Pi (tested with Pi 1.2.0 and
Node 26.10.0). It discovers normal package search locations, plus
`PI_CODING_AGENT_DIR/npm` and the sibling Gentle `current` distribution.
If unavailable, explicitly supply the local **package directory** containing
`dist/core/extensions/loader.js`, with no version hash embedded in tests:

```sh
WC3_PI_PACKAGE_DIR=/path/to/installed/pi-coding-agent node --test tools/wc3-workshop/tests/test_extension.mjs
```

The harness uses Pi's actual loader, TypeScript aliases and exec implementation,
with child-process mocks only for deterministic dispatch/failure cases. It also
runs the real local inspector for doctor, the suite-owned `Smoke.j` fixture and
a rejected path. These tests need no unrelated `projects/` tree.
Jiti filesystem caching is disabled during tests. No auth, history, settings or
other extensions are loaded, and no dependency installation occurs. An absent
runtime is a test failure, not a skipped proof.

Public CLI tests cover seven formats, tags/columns, encoding, masking, malformed
binaries, containment, errors/help and unchanged fixture bytes. Extension tests
cover registration/schema, exact argv, all seven kind dispatches, nonzero and
malformed output, cancellation, timeout and output limits. Neither suite
establishes real-map or engine correctness. Review read/process boundaries first,
then format/evidence preservation.
