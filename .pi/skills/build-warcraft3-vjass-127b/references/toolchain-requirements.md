# Toolchain prerequisites and evidence boundaries

## Gate execution on a reviewed host and distribution

- Use Python 3.10 or newer for the bundled scripts. The builder uses
  `Path.write_text(..., newline=...)`, added in Python 3.10. Prefer a maintained
  Python release; this minimum is a code requirement, not a tested host matrix.
- Use Windows-native executable paths on a Windows Python host for the ordinary
  JassHelper/pJASS/MPQEditor workflow. Replace every `C:/path/to/...` in
  `assets/project-template/wc3toolchain.example.json`; those are placeholders.
  No real installation, executable version, or support-file layout was inspected
  for this template.
- Do not treat a Linux structural PASS as permission to execute Windows `.exe`
  files directly. Linux direct `.exe` execution is unsupported without an
  explicitly reviewed wrapper/binfmt arrangement or Wine setup, including path
  translation and working-directory behavior. The scripts do not automatically
  invoke Wine or translate host paths into Windows paths. A wrapper must preserve
  arguments, output, and exit status; review it separately before execution.
- Record the actual JassHelper distribution/fork and version, download/source,
  executable hashes, and its required configuration/support files. Keep its
  distribution layout intact. Check that its command-line frontend supports
  `--scriptonly` (and `--debug`/`--nooptimize` if used). Prefer `clijasshelper.exe`;
  a filename alone does not establish its version or capabilities.
- Follow the chosen JassHelper distribution's documentation for its
  `jasshelper.conf`, compiler configuration, helper executables, libraries, and
  runtime dependencies where required. Confirm how it locates them from the
  input script's working directory, which is where `compile_vjass.py` runs it.
  Merely copying an `.exe` or passing four file paths does not check these
  dependencies. Do not invent a universal support-file list for all forks.
- Record the actual pJASS build/version, supported grammar and flags, and the
  MPQEditor version, source, executable SHA-256, and CLI support separately.
  MPQEditor is configured in the project manifest, not the toolchain config;
  `check_toolchain.py` does not fingerprint it. Its provenance/version/hash remain
  **manual evidence pending** until recorded from the selected installation.
  Do not substitute a tool name for a version or invent official hashes/licenses.

## Obtain patch-matched JASS inputs

Extract `Scripts\common.j` and `Scripts\Blizzard.j` from a known Warcraft III
**1.27b** installation's MPQ data using an archive tool. Inventory the actual
archives and honor patch overrides (including `War3Patch.mpq` over base/expansion
archives where present); record the archive, member path, installation patch
identity, extraction procedure, and resulting hashes. Do not assume the base
archive's copy is the effective patched copy. Point `common` and `blizzard` at
those extracted files. Do not silently substitute current game or compiler-bundled
copies with unknown provenance.

Use local installation/version evidence or an independently trusted patch-matched
reference to establish provenance. There is no required official-hash database in
this skill. SHA-256 identifies the bytes inspected; it does not authenticate their
origin. Absence of `Blz*` or `FourCC` declarations cannot prove a complete 1.27b
native surface or detect every wrong-patch source.

## Interpret the structural audit narrowly

Run `scripts/check_toolchain.py CONFIG [--json]` before a build. It reads only:

- a UTF-8 JSON config (optional UTF-8 BOM), with the unchanged required fields
  `target`, `jasshelper`, `pjass`, `common`, and `blizzard`;
- the literal target label `Warcraft III 1.27b`;
- each required path (relative paths resolve beside the config), file presence,
  nonzero size, and SHA-256;
- a narrow scan for uncommented, unquoted `native`/`function` declarations named
  `Blz*` or `FourCC` in the JASS inputs. Comments/strings are masked, not parsed as
  JASS. Legacy source decoding is tolerant; this is not a grammar/encoding validator.

The JSON `ok` field and exit code describe these checks only. Existing builder
fields (`ok`, `files`, `errors`, `warnings`, file `path`/`size`/`sha256`) are retained.
Every report sets `compatibility_verified: false` and warns that patch provenance,
complete API compatibility, compiler capabilities/execution, and game behavior
remain unverified. Text PASS explicitly says **structural checks only**. Missing,
empty, unreadable, malformed, or invalidly encoded config inputs fail; no executable
is launched and no input is rewritten.

## Review pJASS compatibility before interpreting success

The bundled standard call order is correct:

```text
pjass common.j Blizzard.j compiled-output.j
```

Check the selected pJASS release's grammar, defaults, and supported flags against
1.27b and the actual generated JASS. The bundled compiler supplies no automatic
legacy-patch switches. Modern pJASS documentation describes version-dependent
options such as `nomodulooperator`; do not assume they exist in an older binary or
apply a modern README's defaults to it. Do not blindly add `+oldpatch`: it also
enables returnbug behavior, which must not be enabled merely to target 1.27b.
Record any reviewed options and their rationale before adapting a workflow.

After prerequisite review, actual JassHelper compilation and pJASS validation
provide separate evidence, not game or multiplayer certification. Opening a copied
map in the matching editor, testing in Warcraft III 1.27b, and two-client sync tests
remain distinct steps. This reference and fixture-only script tests perform none
of those real-tool checks.

## Documentation sources

- [JassHelper command-line usage](https://warraft.github.io/JassHelper-manual/usage.html)
  — command-line and distribution configuration guidance; confirm the selected fork.
- [pJASS README](https://github.com/lep/pjass/blob/master/readme.md)
  — grammar/check options for that source version, not proof of an installed binary.

These are documentation references, not executable/version/license provenance or
observed compilation results.
