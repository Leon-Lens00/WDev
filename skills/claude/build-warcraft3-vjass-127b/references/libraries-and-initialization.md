# Library integration and auditing

## One profile per exact library implementation

Record:

```text
name:
author_or_fork:
version_or_commit:
source:
license:
target_patch:
jasshelper_requirement:
required_libraries:
optional_libraries:
public_api:
events_and_callbacks:
initialization_contract:
handle_ownership:
unit_userdata_owner:
known_conflicts:
verification_state:
```

Do not create a separate skill for each small library. Store exact library profiles as references and list the chosen stack in the map's `AGENTS.md`.

## Dependency rules

- Match names and case exactly.
- Distinguish hard `requires`, `optional`, generated textmacro types, imports, object data, and runtime service dependencies.
- Reject duplicate timer recyclers, UnitIndexers, damage engines, or other single-owner infrastructure unless coexistence is explicitly designed.
- Do not mix APIs from another fork with the installed source.
- Detect cycles; resolve through interface separation, a shared lower-level library, event inversion, or a justified forward declaration inside one domain.

## Initialization review

Build three graphs:

1. compile/preprocess order;
2. initialization order;
3. runtime readiness and event order.

For every `onInit` or initializer, list external state it reads. Verify that state is initialized at the relevant priority, not merely that its library name appears in `requires`.

## API and lifetime review

- Mark who creates, mutates, recycles, and releases every timer, group, trigger, effect, dummy, table, and index.
- Ensure all termination paths converge on one idempotent cleanup path.
- Test double release and callbacks that destroy their own instance.
- Preserve public semantics before optimizing internals.
- Separate a proven defect from a safer API design or experimental rewrite.

## UnitIndexer contract

Choose one owner of `SetUnitUserData`. Other systems may read `GetUnitUserData` and store data by that index, but must not overwrite it. Audit preplaced units, morphs, resurrection, removal, deindexing, index reuse, and cleanup.

## Audit report

Return sections:

```text
COMPATIBILITY
CORRECTNESS
MULTIPLAYER
LIFETIME
INITIALIZATION
PERFORMANCE
API
SAFE FIXES
EXPERIMENTAL IDEAS
VERIFICATION
```

