# Controls and observable behavior

| Input | Result |
| --- | --- |
| Q, then terrain point | Immediate first fireball when idle; four remaining shots total |
| Q again during a burst | Refresh count to four, update future heading; retain the quarter-second timer phase |
| Right-click terrain / M + point | Remember world destination; native Move when idle, script350 during burst |
| Right-click widget | Smart relays its current position as a destination, not an attack/follow command |
| S | Clear movement goal and stop actor; firing count/phase stays unchanged |
| Select visible Shaman | Local selection redirects to off-camera controller |
| `-rf help` | Show instructions |
| `-rf reset` | Dispose old pair, respawn actor/controller and three targets |

The shown/selectable controller remains physically off-camera, never `ShowUnit(false)` and never paused. Its pre-pair native movement speed is saved, then speed0 is commanded while paired. Move/Smart relay the actor goal without moving the controller. The existing timer cancels pending walks only when both the order revision and actual current Move/Smart still match; a later Q/Channel is not blindly stopped. Disposal restores the saved speed before callbacks can initialize another pair. Native zero-speed behavior still requires the corrected run's strict placement/casting checks. Q is a native point-target Channel button; no custom frames or fabricated spell callbacks.

On a cast, the visible actor stops native Move once, faces the cast heading, and restarts attack for every shot. Native actor speed is held0 during the burst (script speed remains350), then restored350 on exhaustion/cancellation. This prevents a direct actor Move's outer order dispatch from adding unchecked native translation before its one deferred Stop. Ordinary controller movement during a burst does not add an actor Stop; direct actor takeover restores cast facing once after cancellation. Script steps do not issue Move/Stop, turn, or restart animations. Recasting changes heading for subsequent shots; actor movement does not continuously aim toward the old clicked point. Already-launched flights retain their headings.

Arrival ends script motion. A blocked step stays put and preserves its destination. Burst exhaustion commands100% animation speed and resumes native Move to a remaining destination, otherwise stays stopped. This may normalize/cut the last attack gesture; it does not guarantee a complete stock attack animation. All shots remain at4/s and attack restart300%.

The status text shows remaining shots, total shots and movement state; animation scale is commanded state only. Camera and selection calls are local UI; synchronized gameplay state and handle allocation never occur inside local-player branches.

Only the separate test-map entry runs the automated battery. Both maps remain open after their work; neither closes applications. Controls and appearance still require parent in-game inspection on the newly compiled copy. Run02 keeps all nine cases and the original controller anchor tolerance1; before any body-guard ABORT it records the exact first failed predicate plus both units' type/life/owner/pause/hidden/XY, anchor/delta, current orders and native movement speeds. Run01's composite ABORT alone does not prove controller drift or an ownership failure.
