package terrainproc

import (
	"bytes"
	"fmt"
	"path/filepath"
	"reflect"
	"slices"
)

func ValidateScenes(s Spec, path, out string) error {
	g, library, lib, plan, parts, provenance, e := buildSceneBase(s)
	if e != nil {
		return e
	}
	b, e := Load(path)
	if e != nil {
		return e
	}
	allowed := map[string]bool{"war3map.w3e": true, "war3map.doo": true, "war3map.wpm": true, "war3map.shd": true, "war3map.w3i": true, "war3mapunits.doo": true, "war3map.w3c": true, "war3map.j": true, "war3mapmap.blp": true}
	allowed["war3map.mmp"] = true
	for n := range b.Files {
		if _, ok := g.Map.Files[n]; !ok && n != "(listfile)" && n != "(attributes)" {
			return fmt.Errorf("unexpected archive member %s", n)
		}
	}
	for n, v := range g.Map.Files {
		if !allowed[n] && !bytes.Equal(v, b.Files[n]) {
			return fmt.Errorf("unrelated archive member changed: %s", n)
		}
	}
	if len(b.Terrain.Tiles) != len(g.Map.Terrain.Tiles) || b.Terrain.CenterOffset != g.Map.Terrain.CenterOffset || !slices.Equal(b.Terrain.GroundTilesets, g.Map.Terrain.GroundTilesets) {
		return fmt.Errorf("terrain dimensions/palette changed")
	}
	for i, t := range b.Terrain.Tiles {
		expected := g.Map.Terrain.Tiles[i]
		x, y := g.xy(i%193, i/193)
		if t.GroundHeight != expected.GroundHeight || t.WaterLevel != expected.WaterLevel || t.LayerHeight != expected.LayerHeight || t.Flags != expected.Flags || t.Boundary != expected.Boundary {
			return fmt.Errorf("new macro/support terrain changed at %d", i)
		}
		for _, q := range plan.Placements {
			if q.Core.Contains(x, y) && t != expected {
				return fmt.Errorf("composition support changed: %s", q.ID)
			}
		}
	}
	g.Map.Terrain = b.Terrain
	expected, provenance, metrics, e := decorateScenes(g, library, plan, parts, provenance)
	if e != nil {
		return e
	}
	if !reflect.DeepEqual(expected, b.Doodads.Doodads) {
		return fmt.Errorf("scene objects differ from deterministic recipe (missing, duplicate, transformed or unsupported piece)")
	}
	var recorded []Provenance
	if e := strictJSON(filepath.Join(filepath.Dir(path), "placements-provenance.json"), &recorded); e != nil {
		return e
	}
	if !reflect.DeepEqual(recorded, provenance) {
		return fmt.Errorf("placement provenance does not match actual expanded objects")
	}
	added := len(expected) - len(parts)
	if len(b.Doodads.SpecialDoodads) != 0 {
		return fmt.Errorf("unexpected special doodads")
	}
	g.Map.Terrain = b.Terrain
	g.Map.Doodads = b.Doodads
	expectedPath := staticRecomposePathing(g)
	if !bytes.Equal(expectedPath, b.Pathing.Cells) {
		return fmt.Errorf("exported WPM does not match generated terrain")
	}
	if len(b.Files["war3map.shd"]) != len(expectedPath) || !bytes.Equal(b.Files["war3map.shd"], make([]byte, len(expectedPath))) {
		return fmt.Errorf("residual shadows")
	}
	if e := checkLocalRoutes(g, plan, b.Pathing.Cells); e != nil {
		return e
	}
	shell, e := recomposeShell(g, plan)
	if e != nil {
		return e
	}
	for n, v := range shell {
		if !bytes.Equal(v, b.Files[n]) {
			return fmt.Errorf("spatial shell mismatch: %s", n)
		}
	}
	return JSON(out, map[string]any{"format": "wc3-scene-validation-v1", "status": "Validated", "map": path, "map_sha256": b.Hash, "source_sha256": lib.SourceSHA, "source_land_iou": plan.SourceIoU, "changed_distance_pairs": plan.ChangedPairs, "compositions": len(plan.Placements), "composition_pieces": len(parts), "new_decoration": added, "forest": metrics, "provenance_count": len(provenance), "routes": plan.Routes, "start": plan.Start, "asset_errors": 0, "imports_unchanged": true, "editor": "requires separate native audit", "game": "excluded by user", "shadows": "excluded by user; SHD cleared"})
}
