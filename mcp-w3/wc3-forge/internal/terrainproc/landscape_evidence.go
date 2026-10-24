package terrainproc

import (
	"path/filepath"
	"slices"
)

func landscapeEvidence(b landscapeBuild, mapPath, out string) error {
	m, e := Load(mapPath)
	if e != nil {
		return e
	}
	s := b.G.Spec
	var library LandscapeLibrary
	if e = strictJSON(s.Landscape.Library, &library); e != nil {
		return e
	}
	records := []any{}
	counts := map[string]int{}
	habitats := map[string]int{}
	dry := []bool{}
	heights := []float32{}
	textures := []int{}
	for i, t := range m.Terrain.Tiles {
		counts[b.Plan.Masks[i]]++
		habitats[b.Plan.Habitat[i]]++
		dry = append(dry, !t.Boundary && !landscapeWet(t, b.G.Water))
		heights = append(heights, t.FinalZ())
		textures = append(textures, int(t.GroundTexture))
	}
	for i, pv := range b.Provenance {
		if pv.Role == "forest" || pv.Role == "environment" {
			continue
		}
		q := landscapePlacement(b.Plan, pv.Instance)
		f := scenePrefab(b.Source, q.Family)
		for _, src := range f.Pieces {
			if src.CreationNumber != pv.SourceID {
				continue
			}
			d := m.Doodads.Doodads[i]
			adjusted := adjustedPrefabPiece(b.G, f, src)
			policy, module, parent := "absolute-rigid", "rigid-core", uint32(0)
			for _, mod := range library.Modules {
				if mod.Family == q.Family && slices.Contains(mod.Members, pv.SourceID) {
					policy, module, parent = mod.Policy, mod.Name, mod.Parent
				}
			}
			oldGround := b.G.height(float64(adjusted.Position[0]), float64(adjusted.Position[1]), b.G.Original)
			newGround := b.G.height(float64(d.Position[0]), float64(d.Position[1]), m.Terrain.Tiles)
			records = append(records, map[string]any{"creation_id": pv.CreationID, "source_id": pv.SourceID, "instance": pv.Instance, "role": pv.Role, "module": module, "variant": q.Variant, "height_policy": policy, "parent_source_id": parent, "rawcode": d.TypeID, "source_position": src.Position, "adjusted_source_position": adjusted.Position, "position": d.Position, "rotation": d.Rotation, "scale": d.Scale, "source_ground": oldGround, "destination_ground": newGround, "source_ground_offset": float64(adjusted.Position[2]) - oldGround, "destination_ground_offset": float64(d.Position[2]) - newGround})
		}
	}
	members := map[string]string{}
	for n, v := range m.Files {
		members[n] = Hash(v)
	}
	for name, v := range map[string]any{"height-and-module-evidence.json": map[string]any{"map_sha256": m.Hash, "library_sha256": s.Landscape.LibrarySHA, "pieces": records, "connections": b.Plan.Reaches}, "physical-layers.json": map[string]any{"map_sha256": m.Hash, "vertex_resolution": 128, "water_slk_offset": b.G.Water, "dry": dry, "ground_heights": heights, "ground_textures": textures, "palette": m.Terrain.GroundTilesets, "mask_counts": counts, "habitat_counts": habitats}, "members.json": map[string]any{"map_sha256": m.Hash, "members": members}, "placements.json": m.Doodads.Doodads} {
		if e := JSON(filepath.Join(out, name), v); e != nil {
			return e
		}
	}
	return nil
}
