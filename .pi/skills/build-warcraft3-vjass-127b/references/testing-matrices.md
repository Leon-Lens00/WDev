# Testing matrices and evidence

## Status definitions: one artifact, one scope

Report exactly one strongest **current** status, with artifact path and SHA-256, target patch, scope tested, commands/exit codes/log evidence, tool hashes/versions and remaining checks. These are evidence labels, not an automatic ladder: a higher label never certifies untested code, packaging, lifecycle or synchronization. Do not promote an entire map from a library fixture or a historical profile.

| Status | Required observed evidence |
| --- | --- |
| Designed | Proposed design/source and explicit assumptions only; no scan/compiler/game success implied. |
| Scanned | Actual static scan/inspection of the identified bytes and recorded findings/limitations; no compilation implied. |
| Compiled | Actual successful JassHelper execution producing the identified generated JASS from recorded sources and native inputs; help, dry-run and Python tests do not qualify. |
| Validated | Actual successful pJASS check of the identified generated JASS with recorded common.j/Blizzard.j and options; does not imply source was recompiled here or a map archive was rebuilt. |
| Tested in map | Actual execution of the identified copied map on Warcraft III 1.27b; record scenarios, client/version, results and duration. Only those scenarios are covered. |
| Tested in multiplayer | Actual tests of that map with at least two 1.27b clients plus synchronization review; record clients, scenarios, duration and observed agreement. Not universal desync certification. |

Report archive round-trip as a **separate** result: final map hash, original hash before/after, prefix preservation and re-extracted managed-member hashes. It is not a substitute for pJASS, editor reopening or gameplay. A builder's `verification_state: Validated` summarizes its pJASS stage; inspect its command log and archive evidence rather than treating the string as independent certification.

Historical claims must say **historical, not independently reproduced/currently verified here** and name their original scope; see [provenance](provenance.md). Static documentation review and synthetic Python test suites do not establish any compiled-map status.

## Skill activation matrix

| Prompt shape | Expected |
|---|---|
| Audit or compile a JASS/vJASS system for Warcraft III 1.27b | Activate |
| Recover editable triggers or source from a `.w3x`, WTG, WCT, or `war3map.j` | Activate |
| Review multiplayer safety, handles, rawcodes, libraries, or missiles for classic JASS | Activate |
| Write Lua or Frame API code for Reforged or a modern patch | Do not activate unless the user changes the target |
| Discuss Warcraft III strategy, lore, installation, or unrelated gameplay | Do not activate |

## Compiler matrix

- After implementation authorization, review [tool prerequisites](toolchain-requirements.md) and [commands](tool-commands.md); run `check_toolchain.py` and save target/fingerprints. Its `ok` is structural only and `compatibility_verified=false`.
- Scan source.
- Run the exact JassHelper with exact `common.j`/`Blizzard.j`.
- Confirm successful exit and actual generated output; record its SHA-256, not just filename.
- Run exact pJASS on `common.j`, `Blizzard.j`, and generated JASS.
- Save commands, versions/hashes, exit codes, and first causal error.

## W3X build matrix

- review [build safety](build-safety.md), including base script not already containing imported compiled code;
- base map hash remains unchanged;
- output path differs from the original;
- compiled `war3map.j` re-extracts byte-identically;
- managed WCT block preserves unrelated global header code;
- every declared archive file re-extracts byte-identically;
- rebuilding from the same inputs produces equivalent managed members;
- World Editor save preserves the import workflow when WCT synchronization is enabled;
- missing WCT, unsupported WCT versions, compiler failures, and MPQ round-trip mismatches fail closed.

## Spell/MUI matrix

- same caster launches overlapping instances;
- several players launch simultaneously;
- caster or target dies/is removed;
- ability is interrupted;
- hundreds of repetitions;
- index is recycled;
- all termination paths clean once.

## Wave/AI matrix

- one and maximum players;
- empty wave and maximum active units;
- units killed/removed outside the expected path;
- boss thresholds and simultaneous deaths;
- player leaves;
- long match and timer/scheduler idle behavior.

## UI/local-player matrix

- host and second client;
- repeated show/hide and cinematic operations;
- continue gameplay after local visual changes;
- verify no local allocation, RNG consumption, or gameplay mutation;
- inspect BJs used inside local branches.

## Library audit matrix

- compiler fork and version;
- required and optional dependencies;
- preplaced objects and generated rawcodes;
- `onInit` order and runtime readiness;
- double release and self-destroying callbacks;
- UnitIndexer ownership and index reuse;
- long-running handle/reference cleanup;
- coexistence with the chosen damage, timer, table, and missile stack.

## Evidence report

Include:

```text
Strongest current status (one):
Artifact path and SHA-256:
Scope and scenarios covered:
Historical evidence (unverified here):
Target:
Toolchain:
Files examined:
Commands run:
Static findings:
Compiler result:
pJASS result:
Final archive round-trip result (separate):
Editor reopen/save result:
In-map result:
Multiplayer result:
Known limitations:
Next test:
```
