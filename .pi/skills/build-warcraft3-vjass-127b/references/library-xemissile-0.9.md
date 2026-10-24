# Profile: Vexorian xe 0.9 / xemissile

Historical profile: all evidence/claims below are unverified here, not independently reproduced or current certification. No source snapshot was supplied. License/copying permission, exact compiler fork/version, dependency snapshots and complete lifecycle coverage are unknown; see [provenance gates](provenance.md) before copying.

- `name`: xemissile
- `author_or_fork`: Vexorian
- `version_or_commit`: xe 0.9
- `source`: https://www.hiveworkshop.com/threads/xe-0-9.331571/
- `target_patch`: classic Warcraft III; generated demo JASS passes local 1.27b pJASS
- `required_libraries`: xefx, xebasic; practically uses the xe dummy/effect stack
- `historical_verification_state`: editable WCT recovered; generated map JASS validated, source not independently recompiled; source/tool hashes not recorded in this profile

## Contract

`xemissile` is a movement layer, not a general collision engine. It uses one shared timer, a compact active array, `xefx` as visual delegate, arrival callback `onHit`, and optional `loopControl`. `xehomingmissile` retargets a unit every tick. Call `terminate()`, not an immediate inherited destroy, so cleanup occurs safely inside the scheduler.

## Strengths

- No `Blz*`; classic dummy/effect representation.
- Small and easy to audit.
- Shared timer pauses while empty.
- Arc, point targeting, homing, pitch/yaw and speed changes.

## Limits and integration rules

- No widget, terrain, destructable, item or missile collision.
- `onHit` means destination reached, not a detected combat hit.
- No native piercing/impact memory.
- Do not import all of xe only for one simple missile unless the map already uses xe.

Use as a reference for visual backend, active-array compaction and deferred termination. Do not claim it replaces BPower-style swept collision.
