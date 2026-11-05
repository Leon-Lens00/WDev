# AI-generated JASS/vJASS failure patterns

Check generated or unfamiliar code for:

| Rule | Failure |
|---|---|
| `FOREIGN-ARRAY-SYNTAX` | `real[] x`, `[1, 2]`, or foreign initializer syntax |
| `INVALID-METHOD-SIGNATURE` | Java/C#-style method signatures instead of `takes`/`returns` |
| `MIXED-JASS-VJASS` | structs supplied to a plain World Editor/JASS pipeline |
| `PATCH-NATIVE-MIX` | `Blz*`, Frame API, Lua, or later natives in a 1.27b target |
| `INVENTED-NATIVE` | plausible but absent function or BJ |
| `LIBRARY-API-MIX` | members from another version/fork |
| `WRONG-EVENT-SEMANTICS` | attack declaration confused with damage/impact, order with effect, etc. |
| `UNRESOLVED-RAWCODE` | invented or placeholder object ID treated as real |
| `GLOBAL-MUI-STATE` | overlapping instances overwrite one global state |
| `LOCAL-TAINT` | local-only data later affects synchronized state |
| `OBJECT-FIELD-KIND` | w3u field written with a kind that differs from the metadata (e.g. `usca`/`ussc` as unreal): editor and game read 0; see object-data-127b.md |
| `UNVERIFIED-COMPILATION` | “compatible” claimed without JassHelper and pJASS evidence |

When the compiler reports many errors, find the first causal error. Check unmatched block terminators, failed textmacro expansion, missing imports, visibility, and exact library names before editing the line where later fallout appears.

Do not “repair” unknown functions by inventing similarly named wrappers. Search exact source and explain missing capability when necessary.

