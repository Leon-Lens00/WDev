# Isolated model inspection over MCP

The GUI now supports six read-only `model_preview_*` tools: `open`, `get_state`, `set_camera`, `set_animation`, `screenshot`, and `close`. They use a dedicated offscreen renderer and never mutate the loaded map, selection, map camera, or undo history.

## Usage

Select the intended GUI PID with `session_select`. Use `doodads_list` / `units_list` or `selection_get` to identify a placed element, then call:

```json
{"kind":"doodad","id":3130,"transform":"placed","width":768,"height":768}
```

Pass that object to `model_preview_open`. The ID must exist in the current map. An alternative is `{"model_path":"war3mapImported/PalmTree.mdl"}` with a real map/game virtual path. Disk paths and URLs are rejected.

`placed` preserves the actual variation, instance and definition scale, yaw and supported fixed tilt, but recenters the model origin. `normalized` uses unit scale and identity rotation. Positive terrain-dependent tilt is not reproduced; warnings identify it. Imported resources are resolved through the current map's asset handler. Failed candidate paths and texture errors remain in diagnostics.

Call `model_preview_set_camera` with `{"view":"top","projection":"orthographic"}` or with an exact camera pose. Angles are radians. Cardinal presets look FROM the named direction. Camera coordinates refer to the recentered model; `distance` is eye-to-target. `view` and `fit:true` frame the actual rendered silhouette after an initial bounds fit, which handles imported models with inflated extents. Explicit target/distance/ortho_height suppress silhouette refinement. Exact top and bottom views work.

`model_preview_screenshot` returns native MCP PNG image content plus metadata, not a base64 string in text. Optional width/height are 128–2048; default is the current size (initially 768 square). The background is dark, opaque, and contains no terrain/editor chrome. The inspector renders under demand; it does not open a separate UI panel.

## Animation and lifecycle

Read sequence indices/names/intervals from `model_preview_get_state`. `model_preview_set_animation` accepts sequence, time_ms (relative to sequence start), paused and loop. Opening pauses after 240 ms warmup. A seek resets the instance and sets the skeletal pose; it does not reconstruct particle history. Unpaused rendering catches up at most 1000 ms per request. Particle/global animation randomness prevents a universal pixel-identical guarantee.

Camera and animation state can be read back. Invalid inputs fail. Missing models close the inspector, preventing stale-image reuse. A map revision change invalidates the preview. Loading another map and `model_preview_close` release its WebGL context. Requests share the serialized viewport bridge and its timeout; don't send concurrent camera/capture commands.

This is one model, not automatic grouping of several doodads into a temple or waterfall. Inspect those compositions with the map viewport. Resource diagnostics and the actual PNG still need review; successful rendering is not World Editor/game compatibility certification.

## Build and verification

Both MCP implementations are supported. Regenerate the Go catalog after editing TypeScript tool declarations:

```powershell
npm --prefix mcp run gen:tools
node mcp/node_modules/tsx/dist/cli.mjs --test test/unit/model-preview.test.ts test/unit/camera-pose.test.ts
go test ./internal/forge ./internal/mcpserver
npm --prefix frontend run check
wails build -o wc3-forge-model-preview.exe
```

If this environment's Wails postbuild subprocess cannot find Get-FileHash, run the existing postbuild-copy-dlls.ps1 directly in the normal PowerShell host after verifying compilation completed; the hook copies/verifies the required DLLs.

Launch the newly built GUI with a disposable map. Run the live MCP acceptance check:

```powershell
node mcp/scripts/model-preview-smoke.mjs build/bin/wc3-forge-model-preview.exe <GUI-PID> <output-directory>
```

The check saves model PNGs from three directions, tests pause/seek, normalization, missing assets and invalid inputs, and compares archive hash, map evidence, selection, camera and history before/after. Its report initially records visually_reviewed:false. Inspect images before approving them. Rebuild the GUI and reconnect the MCP server to activate new tools; an already-running old GUI cannot serve these operations.

