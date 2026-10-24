# Testing matrices and evidence

## Skill activation matrix

| Prompt shape | Expected |
|---|---|
| Audit or compile a JASS/vJASS system for Warcraft III 1.27b | Activate |
| Recover editable triggers or source from a `.w3x`, WTG, WCT, or `war3map.j` | Activate |
| Review multiplayer safety, handles, rawcodes, libraries, or missiles for classic JASS | Activate |
| Write Lua or Frame API code for Reforged or a modern patch | Do not activate unless the user changes the target |
| Discuss Warcraft III strategy, lore, installation, or unrelated gameplay | Do not activate |

## Compiler matrix

- Run `check_toolchain.py` and save the target plus SHA-256 fingerprints.
- Scan source.
- Run the exact JassHelper with exact `common.j`/`Blizzard.j`.
- Confirm output exists.
- Run exact pJASS on `common.j`, `Blizzard.j`, and generated JASS.
- Save commands, versions/hashes, exit codes, and first causal error.

## W3X build matrix

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
Target:
Toolchain:
Files examined:
Commands run:
Static findings:
Compiler result:
pJASS result:
In-map result:
Multiplayer result:
Known limitations:
Next test:
```
