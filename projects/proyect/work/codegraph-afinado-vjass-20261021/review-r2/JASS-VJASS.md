# Local JASS/vJASS extension

This checkout is CodeGraph **v1.6.2**, upstream commit
`6560052a6f856855d3f71eee838fd66ccfa4285d`, with a local Classic Warcraft source
extractor and resolver. It is not an official upstream release. Package version
stays 1.6.2; the MCP/daemon identity is `1.6.2+jass-vjass.2` so a vanilla or older
local daemon cannot silently serve this revision. Extraction version is 29;
rebuild indexes from extraction version 28 to remove stale scopes and edges.

## What is integrated

`.j` and `.jass` detect as `jass`; `.vjass` detects as `vjass`. Both dialect IDs
use the same standalone TypeScript structural parser, inside the original
extraction pipeline, worker pool, SQLite/FTS index, resolver and incremental sync.
There is no subprocess bridge to jassgraph and no Go dependency. The original
`codegraph_explore`, graph traversal, callers, callees, impact, search, CLI and
watcher are retained. Other languages retain the original Rust/WASM paths.

The extractor records functions/natives, parameters, locals/globals/constants,
type aliases, libraries/scopes, structs, interfaces, modules, fields and methods.
References include textual calls, explicit `function Name` callbacks, initializer
calls, library requirements, declaration types and struct inheritance.
Inactive `//! novjass` documentation is excluded before lexical analysis, and
JassHelper multiline strings are masked without losing following coordinates.
Local initializer calls belong to their enclosing function/method. Unqualified
struct methods resolve in their owning type before same-named global functions.
Inheritance headers exclude comments; ambiguous conditional members remain
unresolved instead of falling through to a global homonym. Ordinary declared
`execute`/`evaluate` methods resolve on known receivers; indirect helpers remain
outside the supported subset. Secondary symbol/file MCP reads retain the same
JASS coverage notes and diagnostics as exploration.

Resolution is case-sensitive and restricted to JASS/vJASS declarations. It uses
lexical scopes, private visibility, explicit public prefixes (`Library_Name`),
declared local/parameter/field types, `this`, `thistype`, and explicit inheritance.
Ambiguous functions and unknown method receivers remain unresolved; there is no
fallback to a unique method elsewhere in the project. Resolved edges carry
`metadata.jassStaticSubset` and a conservative provenance marker.

## Language coverage limits

This is **partial static language support**, not full JassHelper semantics:

- No expansion of textmacros, `//! import`, module `implement`, hooks, delegates,
  keys or Zinc. Template definitions and Zinc regions are excluded from JASS
  extraction, with diagnostics; their generated functions are not invented.
- Static-if/debug conditions are not evaluated; both extracted paths are
  potential paths. No full variable-use/data-flow analysis or inferred types.
- `ExecuteFunc`, function-interface `.execute/.evaluate`, arbitrary factory/index
  receiver chains, generated `allocate/destroy` methods and operator access
  dispatch are not resolved. Operator bodies remain separately searchable.
- Headers are line-based; multiline headers and malformed blocks/literals report
  errors. Source coordinates are UTF-16 columns and one-based lines, consistent
  with CodeGraph. Inputs are read through CodeGraph's existing UTF-8 source path.
- Omitted textmacro/Zinc/novjass contents are not lexed as standalone JASS;
  arbitrary fragments inside them do not manufacture parse errors or symbols.
- Edges represent statically supported dependencies, not a proof that a path runs
  or that an unrepresented path cannot exist. `complete` is an index-operation
  state, not completeness of the JASS/vJASS language or Classic compatibility.

MCP responses containing these sources include a coverage note and up to six
relevant extraction diagnostics, with an omitted count. JassHelper followed by
pJASS with the actual Classic APIs remains authoritative for compilation; game
and multiplayer behavior require their own tests.

## Local operation

The Linux launcher is `/home/snz/.local/bin/codegraph`. It runs the Node 24.16.0
runtime shipped in the verified upstream linux-x64 package, isolated under
`/home/snz/.local/share/codegraph-vjass/runtime/`; it does not change CachyOS's
system Node 26. Upstream's Linux kernel binary is retained for its supported
languages. The launcher disables telemetry and update checks; avoid `upgrade`,
which would replace local language changes with an upstream build.

```bash
codegraph init /absolute/source/project --yes
codegraph query Ping --path /absolute/source/project --json
codegraph explore 'Init Ping' --path /absolute/source/project
codegraph sync /absolute/source/project
```

Create an index only in the project selected for the task; this writes a
`.codegraph/` index. Sources and map archives are not rewritten. Old indexes
should be rebuilt with `codegraph index /absolute/source/project`.
MCP registration uses the original `serve --mcp`; default upstream tool discovery
exposes `codegraph_explore`. The other original tools remain in the CLI/API and
can be explicitly enabled with `CODEGRAPH_MCP_TOOLS=explore,search,node,callers,callees,impact,files,status`.

## Evidence and reproducibility

`__tests__/jass-vjass.test.ts` exercises the real extractor and SQLite pipeline,
including private/public scopes, callback references, declared method receivers,
ambiguity, persistent reopen and incremental/fresh-rebuild edge-set convergence.
`scripts/probe-jass.mjs ROOT...` runs three static flow probes per selected root,
then reconstructs the indexes and checks counts and unchanged source hashes.

Local evidence:
`/home/snz/Documentos/ChatGPT/Proyect/work/codegraph-original-vjass-20261020/`.
It includes the Classic fixture's JassHelper/pJASS result, exact Python graph
comparison with upstream, and an independent MCP SDK connection/watch test.

The upstream small/medium/large **real-repository agent A/B performance gate**
has not been run: the Claude/Sonnet runtime required by that harness is not present
in this session. The three local source sets (fixture, common.j, common.j+Blizzard.j)
are correctness/scale probes, not three independent real repositories. Do not
claim full language coverage, upstream acceptance, agent token savings, or a
general performance improvement from these checks.

Revision 2 evidence:
`/home/snz/Documentos/ChatGPT/Proyect/work/codegraph-afinado-vjass-20261021/`.
It includes failing-before/passing-after regressions, JassHelper/pJASS fixtures,
1054 passing tests across nine suites, copied real TerrainDev/inventory/UI
sources and three RapidFire flow probes, plus a Python graph comparison with
the pinned upstream package. Zero parse errors does not remove coverage warnings
or establish complete language support. Already-running MCP processes must be
reloaded to use the new in-memory code; rebuilding an index alone is insufficient.
