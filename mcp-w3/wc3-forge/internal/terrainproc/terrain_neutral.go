package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"strconv"
	"strings"
)

// NeutralTerrain is a diagnostic derivative, never a deliverable map. It edits
// only texture indices/details and explicitly omitted doodad records. The exact
// physical W3E bytes and WPM are verified after repacking.
func NeutralTerrain(source, out, keepIDs string) error {
	m, e := Load(source)
	if e != nil {
		return e
	}
	keep := map[uint32]bool{}
	if keepIDs != "" {
		for _, v := range strings.Split(keepIDs, ",") {
			id, err := strconv.ParseUint(v, 10, 32)
			if err != nil {
				return err
			}
			keep[uint32(id)] = true
		}
	}
	for i := range m.Terrain.Tiles {
		m.Terrain.Tiles[i].GroundTexture = 0
		m.Terrain.Tiles[i].TextureDetails = 0
	}
	physical, e := w3e.Encode(m.Terrain)
	if e != nil {
		return e
	}
	records := m.Doodads.Doodads[:0]
	for _, d := range m.Doodads.Doodads {
		if keep[d.CreationNumber] {
			records = append(records, d)
		}
	}
	if len(records) != len(keep) {
		return fmt.Errorf("neutral: retained creation ID absent")
	}
	m.Doodads.Doodads = records
	doo, e := doodadsdoo.Encode(m.Doodads)
	if e != nil {
		return e
	}
	if e = m.Write(out, map[string][]byte{"war3map.w3e": physical, "war3map.doo": doo}); e != nil {
		return e
	}
	result, e := Load(out)
	if e != nil {
		return e
	}
	if Hash(result.Files["war3map.w3e"]) != Hash(physical) || Hash(result.Files["war3map.wpm"]) != Hash(m.Files["war3map.wpm"]) {
		return fmt.Errorf("neutral: physical repack differs")
	}
	return JSON(out+".json", map[string]any{"format": "wc3-neutral-diagnostic-v1", "source": source, "source_sha256": m.Hash, "diagnostic_sha256": result.Hash, "physical_w3e_sha256": Hash(physical), "physical_comparison": "W3E serialized with texture index/detail both zero; every other field unchanged", "wpm_sha256": Hash(result.Files["war3map.wpm"]), "retained_creation_ids": keep, "not_a_final_map": true, "shadows_excluded": true})
}
