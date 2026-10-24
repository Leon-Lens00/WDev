# Lint evidence and limits

Run `scripts/wc3lint.py PATH [--json]` for a conservative lexical scan of a `.j` file or directory. Findings retain original source line numbers; strings, rawcode literals, `//` comments and multiline `/* ... */` comments are masked before rule matching. A same-line `wc3lint: ignore RULE -- reason` marker still suppresses that rule (or `ALL`). Review every suppression; it is not safety evidence.

## Interpreting findings

- A `GetLocalPlayer` condition taints the remainder of its `if`/`elseif`/`else` chain, including nested branches, until `endif`. Branches with a local parent remain local. This is conservative, not a proof that every flagged path executes on one client.
- Simple local assignments can taint later gameplay uses in the same function or method. Tracked taint, location lifetime, group aliases and boolexpr ownership reset at `endfunction` and `endmethod`. The scanner does not resolve variable declarations, shadowing, global ownership or interprocedural dataflow.
- An explicit `function FourCC takes ...` declaration in the same scanned file suppresses the unresolved-helper compatibility error for that name. A classic user-defined helper is not automatically a modern native. This name check does **not** prove its body, signature, return value, dependencies or engine compatibility; other lexical rules still scan its body. An unresolved `FourCC(...)` remains an error. Declarations in other files, generated sources or imports are not resolved.

## What a clean scan cannot prove

There is no full parser, type checker, call graph, import resolver, macro/textmacro expansion or JassHelper preprocessing. The scan does not validate syntax, native availability, semantic correctness, handle ownership, complete taint propagation or library initialization. Multiline expressions, indirect callbacks and generated code can evade checks; malformed strings/comments can mask later code. Findings may be false positives or miss real defects.

Report only **Scanned** after lint. Compile the actual preprocessed sources against the exact 1.27b `common.j`/`Blizzard.j` with the installed JassHelper and pJASS before claiming compilation. Validate copied-map archive contents separately, then test behavior in the target game. Multiplayer safety requires separate two-client tests and synchronization review: lint provides no multiplayer certification.
