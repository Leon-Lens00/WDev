# Warcraft III work in WDev

This project-specific guidance supplements the active agent instructions; it does
not replace their safety, authorization or workflow rules.

- Default Warcraft target: **Warcraft III Classic 1.27b**, not Reforged or Lua.
  For Warcraft work, load `skills/claude/build-warcraft3-vjass-127b/SKILL.md` and its
  relevant references before changing code or assessing compatibility.
- Prefer the read-only `wc3_workshop` Pi tool, or
  `python3 -B tools/wc3-workshop/wc3.py --help`. See
  `docs/warcraft3-workshop.md` for schema, commands, bounds and audit findings.
- Sources are lexical evidence only. Object/import inspection requires already
  extracted project-contained members; it does not open or rewrite MPQ maps.
  Preserve rawcodes, stored tags/levels, encodings and original maps.
- Report static inspection as **Scanned**, never as compilation, editor, game or
  multiplayer verification. File presence and hashes do not prove patch
  provenance. Review `Blz*`, Lua, modern Frame/24-player APIs and project helpers
  against patch-matched evidence instead of assuming modern compatibility.
- Existing workshop launchers may write external caches, profiles and reports.
  Do not invoke them implicitly. Compilation, extraction, editor/game launch,
  map modification and global Gentle changes require separate authorization.
- Activate `.pi/extensions/wc3-workshop.ts` only after trusting this project,
  then use `/reload`; do not add global settings, packages or automatic servers.
