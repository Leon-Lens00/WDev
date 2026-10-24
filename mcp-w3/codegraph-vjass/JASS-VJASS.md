# Local JASS/vJASS integration

Based on CodeGraph 1.6.2, upstream commit
`6560052a6f856855d3f71eee838fd66ccfa4285d`. This is a local integration,
not an official upstream release. Package version remains 1.6.2; runtime
identity is `1.6.2+jass-vjass.5`, extraction version 32, database schema 12.
Rebuild older indexes and restart older MCP processes when installing it.

## Integration contract

`.j`/`.jass` use language `jass`; `.vjass` uses `vjass`. A bounded TypeScript
frontend participates in the original extraction workers, SQLite/FTS,
resolver, graph traversal, search, callers/callees, impact, CLI, MCP and watcher.
Other languages retain their existing Rust/WASM paths. No alternate graph or
external JASS parser service is required. It supplies structural context and
potential dependencies, like the other CodeGraph integrations. It is not a
compiler, runtime, proof of program correctness, or a Warcraft multiplayer test.

The language profile is the installed Classic JassHelper manual and compiler,
with JASS APIs supplied by the indexed project. Target-specific natives are
resolved from those inputs, never inferred from a different Warcraft version.
Compiler probes use the local JassHelper plus pJASS and Classic 1.27b API files.
Corpus indexing of libraries using newer APIs does not certify Classic compatibility.

## Covered source constructs

- Functions, natives, parameters, locals/globals/constants, type aliases,
  libraries/scopes and requirements, structs/interfaces/modules, fields,
  methods, operators, keys and forward keywords; case-sensitive scope and
  visibility, explicit public prefixes, inheritance, `super`, delegates,
  `this`/`thistype`, and declared receiver/return types.
- Full expression parsing with precedence, nested calls, fields, arrays,
  dynamic/sized/2D arrays, property/index/comparison operators and colon
  indexing. Parentheses preserve JassHelper's loss of struct receiver types.
  Reads/writes refer to storage declarations rather than guessed method names.
- Textmacros with quoted/escaped arguments, textmacro_once, macro-generated
  modules, macros inside modules, nested/diamond/repeated implementations,
  private module namespaces and intentionally open module method fragments.
  Module implementation is deduplicated before static-if selection, matching
  the installed compiler. library_once duplicates within a file keep the first.
- Compiler-compatible static-if conjunctions, elseif, prior method `.exists`,
  boolean constants and debug selection. Unknown build inputs preserve both
  branches as candidates. Different conditional receiver types remain unknown;
  the frontend does not pick the first branch as a concrete type.
- Function/static-method execute/evaluate/name, literal ExecuteFunc and bounded
  possible-value propagation through assignments, aliases, parameters,
  returns and arrays. Function-interface candidates use lowered JASS signatures.
  Runtime names and SCOPE_PREFIX/SCOPE_PRIVATE are distinct from graph scopes.
- Unqualified instance calls from static methods use a declared local or
  parameter `this` with a known integer-compatible receiver. A missing or
  handle-valued local does not invent an instance; globals are not used as an
  implicit receiver. Instance function references keep their existing limits.
- Hook call-site dependencies on indexed natives/API inputs, virtual/stub/interface
  implementations, struct lifecycle and subtype/base onDestroy callbacks,
  library/struct/global initialization, main/config injection and dovjassinit.
  Generated dispatch is explicitly a potential dependency, not observed execution.
- Indexed source imports, explicit scoped SLK data inputs, typed SLK cell
  expressions and initialization dependencies. Block comments may join tokens
  and physical lines; multiline strings retain real source coordinates.
  novjass, template bodies and external-tool payloads stay out of active parsing.

## Build profile

An optional `codegraph.json` configuration makes the source context explicit:

```json
{
  "jass": {
    "mode": "release",
    "completeInputs": false,
    "defines": { "FEATURE_ENABLED": true },
    "lookupPaths": ["libraries"],
    "apiFiles": ["api/common.j", "api/Blizzard.j"],
    "dataFiles": ["data/settings.slk"]
  }
}
```

All paths are relative to, and constrained by, the authorized index root and
its exclusions. These fields do not authorize indexing outside it. API files
must already be indexed. Data files must be explicitly listed; symlinks out of
root and oversized data are refused. No external command is executed.

The default mode is `conservative`: DEBUG_MODE and absent inputs are unknown.
Use `debug` or `release` only for the actual build being inspected. By default,
seeing an optional library elsewhere in the index does not prove it is compiled:
imports establish inclusion. Set `completeInputs: true` only when the indexed
source set really is the complete translation unit. Boolean defines follow
JassHelper static-if grammar, not a general C preprocessor expression language.

## Provenance, freshness and limits

Generated members anchor to the real invocation and retain template origin and
expansion chain in their docstring. Returned source is the original on-disk
invocation, not an editable expanded body. Template dependencies support impact
analysis. Injection bodies have their own complete source region; they replace
rather than augment the original main/config body.

Edges carry `jassStaticSubset`; conditional or indirect dispatch additionally
carries candidate/provenance metadata. Synthesized edges record their mechanism
and wiring site. MCP exposes these labels and per-file coverage diagnostics.
An unresolved call or absent edge is not proof that a consumer does not exist.

Changes to any indexed JASS source re-extract all in-scope JASS consumers.
Profile or declared data changes also invalidate them, including synthesized
initialization edges. The watcher catches additions, edits and removals; CLI-only
use requires sync before reusing the graph. Automatic watching exists only while
a project is open in a live MCP session; idle eviction closes it.

Static analysis has explicit boundaries, also present for upstream languages:
unknown runtime strings, arbitrary aliasing/writes, unresolved duplicate sources,
external/generated build inputs and resource limits cannot be made precise
without additional build context. Multiple cross-file library_once alternatives
are not arbitrarily ordered. Import search ambiguity remains unresolved.
Imports inside generated projections are diagnosed because imports precede
textmacros in JassHelper. Zinc and C/cJASS are separate dialects; their opaque or
conditional source is diagnosed. External tools are recorded but never run;
index their generated JASS output separately when it is an authorized input.

Projection limits: depth 24, 50,000 processed lines and 4 MiB text. Expression
limits prevent adversarial depth/node growth; value flow bounds recursion/work.
Constant values share work/depth limits, memoize dependencies and cap strings at 64 KiB. SLK bounds coordinates and cells. Exceeding a bound emits a coverage diagnostic.
This integration does not reproduce allocator bytecode, optimize code, validate
all compiler type errors, or prove runtime and synchronization behavior.

## Evidence

The project plan and pinned local artifacts are in
`/home/snz/Documentos/ChatGPT/Proyect/docs/planes/codegraph-soporte-completo-vjass.md`
and `work/codegraph-completo-vjass-20261021/`. They retain compiler fixtures,
per-case results, regression logs, three real JASS corpus snapshots, MCP probes,
agent A/B methodology and independent reviews. Consult their final status;
intermediate failed experiments are retained and are not passing evidence.
