# InventorySys 1.4.1: camera-based classic interface

Use this profile when studying or adapting a pre-Frame-API inventory, equipment panel, or interface made from world objects. These are observed techniques, not a drop-in multiplayer-safe framework.

## Provenance and validation boundary

- User-supplied `InventorySys v1.4.1.w3x`, 621592 bytes; SHA-256 `a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada`.
- WTS identifies **Inventory & Equipment System v1.4.1**, TriggerHappy. Embedded `UserInterface` identifies **v1.0.6**, TriggerHappy.
- Inspection on 2026-09-20 recovered 54 archive members, all 47 WCT slots (42 nonempty), WTG metadata, and compiled `war3map.j`. WCT and WTG parsing consumed their complete files.
- **Validated**, limited to static validation: original compiled map script passed pJASS against the locally fingerprinted 1.27b toolchain. Unmodified `UserInterface`, `UnitDex`, `PlayerUtils`, `Camera`, `UIMath`, and `TimerUtils` recompiled together through JassHelper and pJASS with empty `main`/`config` stubs. This is not a rebuilt full map or an in-game/multiplayer test.
- No `Blz*`, `Dz*`, `FourCC`, or `CreateTrackable` calls were found in the executable JASS. The embedded author's multiplayer claim is not independent verification.

Evidence references below use **zero-based WCT trigger indices** and source symbols, so they remain useful after files move. Keep the original archive and the recovered source when applying this profile; this document does not redistribute the implementation or assets.

## Architecture worth learning

| Technique | Observed implementation | Adaptation constraint |
|---|---|---|
| Camera-relative layout | WCT 29 `Camera.win2World` projects panel coordinates using camera eye, axes, depth, `SCREEN_WIDTH=0.544`, `SCREEN_HEIGHT=0.302`; WCT 25 positions dummy units and text | Camera must be controlled. These are custom projection constants, not Frame API coordinates. Recheck aspect ratio, terrain height, camera pitch, and map edges on the target client. |
| Reusable controls | WCT 25 `UIButton`, `UIPicture`, `UIText`; `CreateWindow` uses a model and race border | Buttons/pictures are units; text uses texttags anchored to hidden dummy units. Object data and model behavior are part of the API. |
| Dynamic icon texture | WCT 25 `ApplySkin`: add `'Skin'`, create a texture-bearing destructible, issue `"grabtree"`, remove destructible and ability | `war3map.w3a` proves `'Skin'` derives from `'Agra'`; `war3map.w3b` supplies texture paths via `btxf`. The texture argument is a destructible rawcode, not a BLP path. This procedure creates objects and issues orders. |
| Left/right interaction | WCT 25 polls `IsUnitSelected` every 0.01 s by default; alternate left path uses `EVENT_PLAYER_UNIT_SELECTED`; right path listens for `EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER` targeting a button | Right click is inferred from an order, not a native mouse event. Audit ownership, order side effects, repeat suppression, and callback reentrancy. |
| Callback context | `triggerL`, `triggerR`, `onLeftClick`, `onRightClick`, `GetTriggerButton`, `GetClickingPlayer`, `customValue` | Global event context and a reused evaluation trigger can be overwritten by nested dispatch. Keep callbacks and gameplay validation explicit. |
| Inventory data/view separation | WCT 1 `Inventory`, WCT 2 `InvItem`, WCT 8 `Equipment`, WCT 9 item rules | Defaults: 6 × 5 visible inventory cells, 5 pages (150 logical slots), 14 equipment slots. Reuse visible buttons across pages; do not create one control per stored item. |
| Tooltip layout | WCT 4 `InvTooltip` creates one texttag per line, with a 16-line default | Character-count wrapping is approximate and depends on font/resolution. Keep a bounded reusable pool and separate local text presentation from item state. |
| Native confirmation dialog | WCT 24 `YesNoDialog`: one dialog per active player, callback associated with its Yes button | A simple native dialog can handle confirmation without implementing another world-space panel. |

`ApplySkin` borrows the target unit and owns only its temporary destructible. A caller must not invoke this creation/order sequence inside a local-only branch. Do not infer safety just because the resulting texture is visual.

## Exact integration dependencies

- UI source: `UserInterface 1.0.6`, `Camera` and `UIMath` (no explicit version in their declarations), `PlayerUtils 1.2.8`, and a working unit indexer. This map enables `UnitDex 1.2.1`.
- `UIButton` maps units through `GetUnitUserData`; an optional indexer declaration does not make valid indexing optional for this implementation. Preserve one owner of unit custom values.
- This map includes the TimerUtils variant exposing `NewTimerEx`, `GetTimerData`, and `ReleaseTimer`; preserve this exact API. The no-TimerUtils callback fallback reads remaining time from the expired delay timer and must not be assumed to recover the button ID correctly.
- Inventory uses **Table 3.1** and its bundled plugin modules, not an arbitrary modern Table fork. WCT 3 wires item/equipment/tooltip modules together. Removing equipment modules may expose invalid fallback methods in WCT 2; recompile the chosen configuration.
- Bonus stack includes **BonusMod 3.3.1**, **UnitMaxState 2.1**, and associated regeneration/movement modules. The enabled WCT 42 library named `AutoIndex` is an adapter over UnitDex. The full AutoIndex in WCT 43 is disabled; do not enable both. BoundSentinel (36) and AbilityPreload (46) are also disabled; xebasic/xepreload (44/45) are enabled.
- `InventoryItem` declares optional `InventoryBonus`, while WCT 5 declares `InventoryBonuses`; do not silently equate a trigger's editor name with its library name.
- Source compilation needs JassHelper/vJASS (structs, modules, static-if, textmacros, function interfaces), followed by classic pJASS. Inspect ObjectMerger directives before compiling the bonus stack; do not execute attached setup instructions automatically.

Verified assets/objects include `'uidm'` → `UI\dummy.mdl`, `'e001'` → `war3mapImported\dummy.mdl` (archive has its MDX), `'bwn2'` → race window model, and `'ttip'` → tooltip model. `'Skin'` supplies the texture-changing ability. `'D201'` through `'D204'` encode Human/Orc/Undead/Night Elf borders; `'B00S'` points to `UI\Nothing.blp`. These are map-specific IDs: remap consistently and copy the required object fields/imports. The generic `CreateWindow` configuration references `'uiwn'`, which was not present in the decoded W3U; verify or supply that object before using the helper independently.

## Findings to preserve, not copy

| Class | Evidence | Consequence / adaptation |
|---|---|---|
| ERROR | WCT 29 `Camera.destroy` ends in `this.destroy()`; original compiled JASS also calls `s__Camera_destroy(this)` recursively | Destruction does not terminate normally. End in the allocator's deallocation operation after releasing owned vectors/matrices. No claim that the demo invokes this path. |
| ERROR | WCT 25 `enableButtonCallback` clears `disabled` but never calls `ReleaseTimer` or destroys the fallback timer | Each delayed click consumes an unreleased timer. Pair acquisition/release; also handle a button destroyed before its timer expires. |
| ERROR | WCT 25 control `destroy` methods copy `AllShow[CountShow]` before decrementing; active indices are `0..CountShow-1`. Traversal methods also start at `CountShow` | Removal/traversal can use an unused or stale slot. Preserve swap-removal with decrement-before-copy and iterate only the active range. |
| ERROR | WCT 25 custom destructors omit struct deallocation; `UIText.destroy` destroys its texttag but leaves its created dummy unit | Repeated creation/destruction leaks instances and, for text, units. Clear lookup entries, cancel dependent timers, and release each owned resource exactly once. |
| WARNING | WCT 1/8 `onDisplay` choose an inventory/equipment through `User.LocalId`, then update camera structs, vector allocation pools, and dummy coordinates | Local data reaches unit transforms and shared-looking allocator state even outside an explicit `GetLocalPlayer` branch. Trace all later consumers; no multiplayer safety certification from this sample. |
| WARNING | WCT 1 `localInt` selects a player-dependent destructible rawcode, passed to WCT 25 `setTexture` → `ApplySkin` → creation and `grabtree` order | Divergent object types/targets need a separate synchronization review. Moving the local branch into a helper does not remove the taint. |
| PERF | WCT 25 selection polling and WCT 1 UI refresh are configured at 0.01 s; polling visits players × visible buttons | Treat 100 Hz as demo configuration, not a universal requirement. Measure with multiple open panels and compare the built-in selection-event path. |

`UIText.createEx` creates its texttag only for the requested local player. Review texttag behavior as its own presentation category; do not use it as precedent for locally creating units, effects, timers, or destructibles. Prefer synchronized control lifecycles with narrowly scoped, verified local presentation. Existing multiplayer hard rules still apply.

For conversation layout and measured texttag wrapping/clipping, consult [texttags-dialogos-127b.md](texttags-dialogos-127b.md). Its separate 2026-10-22 Classic 1.27b experiment does not extend this original inventory profile's validation boundary or certify the proposed multi-fragment renderer.

Before production use, test simultaneous panels on two 1.27b clients; repeat open/close/page/equip/sell/drop; destroy controls with pending clicks; vary resolution, camera position, and terrain height; measure timer/unit/instance growth. These are targeted next checks, not tests already performed.

## Billboarded picture dummies away from X 0 (Dev Mission v14e, 02/11/2026)

Observed in Classic 1.27b with a top-down camera (AoA 270, rotation 180). Single-player map test, not multiplayer.

- **Symptom.** A picture dummy draws nothing once it sits more than about 600 units from X 0, at any Y. The dummy is one quad in the YZ plane, normal +X, under a root marked `Billboarded`. Texttags, trackables and normal units at the same place still draw.
- **Cause.** The billboard orientation depends on the dummy's absolute position. Far from the origin it turns the quad edge-on under the camera.
- **Ruled out, each without effect:** fog/mask (the unit was visible and unmasked), fly height, the skin swap (all succeeded), owner vision, the background plane, `ShowUnit` refresh, and `TwoSided`.
- **Fix that worked.** Use a static quad without `Billboarded`:
  - lay the quad in the XY plane facing +Z: vertices (1,-1,0), (1,1,0), (-1,1,0), (-1,-1,0), with the same TVertices order;
  - set normals to (0,0,1) and the extents to ±1 in X and Y;
  - move the aspect-scaling keys from {1, width, height} to {width, height, 1};
  - create the unit with facing 270.
- **Keep the billboarded type** where it is needed, such as in-game HUD icons under the angled game camera. Give the static model its own unit type; Dev Mission uses `'uids'` beside `'uidb'`.
- **Scripts:** `Proyect/work/titulo-devmission-20261026/scripts/modelo_plano.py` and `w3u_tienda.py`.
- **Related limit.** Trackables cannot be destroyed in 1.27b. A second screen with trackables must sit away from the first one's spot, which is what first moved a panel out of X 0.
