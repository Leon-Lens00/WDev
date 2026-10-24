# Inspect terrain through MCP

The editor exposes its live 3D canvas as a PNG image and accepts exact camera poses. Run the GUI built from this checkout, open a map, and point the MCP client at the same executable with `--mcp`. If several editors are running, use `sessions_list` and `session_select` to select the intended PID.

These operations change only the viewport. They do not modify terrain, map camera objects, the undo stack, or the saved map.

| Tool | Purpose |
|---|---|
| `camera_get_state` | Read a serializable camera state after a rendered frame. |
| `camera_set_state` | Apply any subset of that state and wait for rendering. Pass the saved state to restore it. |
| `camera_frame` | Fit XYZ bounds, optionally choosing a directional view and projection. |
| `viewport_screenshot` | Return native MCP PNG image content and small JSON metadata. |

## Coordinates and views

`x`, `y`, `z` are the camera target in Warcraft world units. `distance` is the distance from the eye to that target. +Y is north and +Z is up. `yaw`, `pitch`, and vertical `fov` use radians. Pitch ranges from `-pi/2` to `pi/2`; both exact poles work. Yaw zero places the eye south of the target.

`projection` accepts `perspective` or `orthographic`. `ortho_height` is the vertical world span in orthographic mode. It allows accurate top-down comparisons without perspective distortion. A saved pose restores the same view when viewport dimensions are unchanged; changing window aspect changes the visible horizontal span.

For an exact north-up aerial view of a region:

```json
{
  "bounds": { "min": [-2048, -2048, 0], "max": [2048, 2048, 1000] },
  "view": "top",
  "projection": "orthographic",
  "padding": 1.15
}
```

Pass that object to `camera_frame`, then call `viewport_screenshot` with `{"max_width":1600}`. Bounds should include the heights of trees and other objects, not just the ground. Presets are `top`, `bottom`, `north`, `south`, `east`, `west`, and `isometric`; cardinal presets look **from** the named direction. For another angle, use `camera_set_state` with a custom yaw and pitch.

## What a capture contains

The image comes directly from the rendered WebGL canvas, including terrain, water, models and any active canvas overlays. HTML menus and panels are excluded. Imported models appear through the editor's existing asset resolver, provided their files and dependencies load successfully. This feature does not add model-format support.

Each request waits for map loading, terrain updates, asset promises and a completed frame. Metadata records the map, actual camera, frame counter, capture time, dimensions and model-load error counts. PNGs preserve viewport aspect and are downscaled to `max_width` (default 1600, maximum 4096), with height capped at 4096. Captures never upscale the canvas.

The GUI must be rendering; headless mode has no viewport. Requests fail on timeout, renderer failure or a map change. Animations remain live, so identical camera settings do not promise identical pixels. This is the editor renderer, not a screenshot from the Warcraft III game engine.

## Certified archive evidence (v1)

`map_status.evidence` now reports the archive SHA256 represented by the session,
load generation, monotonic revision, dirty state and in-progress save count.
Archive assets are read from the same immutable byte snapshot that was hashed on
open. Replacing a file at the same path does not silently replace that snapshot.
Successful saves update the baseline digest; failed saves invalidate certification.
Folder maps still work but cannot claim an archive digest.

For release evidence, pass `require_clean:true`, `expected_sha256` and
`expected_revision` to `viewport_screenshot`. The backend checks the session
before and after the frame, and requires evidence-v1 frontend metadata tied to
its completed map load. Old embedded frontends, dirty maps, active saves,
wrong hashes, changed revisions and stale rendered maps fail. After editing or
saving, reopen the map before requesting certified captures. Ordinary captures
remain available for inspection of unsaved edits.

The response includes `evidence`, `rendered_evidence`,
`renderer_evidence_version:1`, and `runtime` (PID and running executable SHA256).
Diagnostics include exact viewer error identities, placed-model failures,
terrain atlas health, water texture counts, geometry and origin. Known fallback
events must be classified individually, never allowed solely by an error count.

`scripts/terrain-landform-capture.py` wraps this protocol, verifies the file before
and after capture, applies and checks a camera, and restores the starting camera
when the map session is unchanged. It never opens, edits or saves a map:

```powershell
python scripts/terrain-landform-capture.py --pid 1234 --map final.w3x --sha256 <expected-hash> --build build/bin/wc3-forge-landform.exe --camera camera.json --out evidence/view.png --expect-water
```

`camera.json` is an exact camera pose or a `camera_frame` request containing
`bounds`. Optional `--geometry` checks `{width,height,center_offset}`;
`--context` retains recipe/seed provenance. `--allow-viewer-errors` is a JSON list
of exact, previously reviewed error identities. An unrecognized failure writes
`.rejected.json` and, when available, `.rejected.png`; it cannot become an
accepted capture merely because a PNG exists. Successful metadata records
`passed:true, reviewed:false`: a human/agent must still examine the actual image.

The GUI needs a Wails rebuild to embed the updated frontend and regenerate
bindings. Rebuilding only the Go CLI does not update an already running GUI.

## Reproduce validation

Build with `wails build -o wc3-forge-camera.exe`. With a disposable map open in that GUI, run from the repository root:

```powershell
node mcp/scripts/viewport-smoke.mjs build/bin/wc3-forge-camera.exe <GUI-PID> scratch/viewport-validation
node mcp/node_modules/tsx/dist/cli.mjs --test test/unit/camera-pose.test.ts
go test ./internal/forge ./internal/mcpserver
```

The live check uses the real MCP stdio protocol, captures six views, checks frame acknowledgements and invalid-input handling, and restores the starting camera in `finally`. It never saves the map. Compare the map's SHA256 before and after when validating on an existing archive.
