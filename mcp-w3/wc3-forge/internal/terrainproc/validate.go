package terrainproc

import (
	"bytes"
	"fmt"
	"reflect"
	"strings"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

// ValidateExport checks the actual archive, including protection and stored pathing.
// Native shadows and visual acceptance have separate evidence gates.
func ValidateExport(s Spec, path, out string) error {
	if s.Mode == "whole-map-landscape" { return ValidateLandscape(s,path,out) }
	if s.Mode == "whole-map-scene" {
		return ValidateScenes(s, path, out)
	}
	if s.Mode == "whole-map-recompose" {
		return ValidateRecompose(s, path, out)
	}
	if e := s.Validate(); e != nil {
		return e
	}
	a, e := Load(s.Source)
	if e != nil {
		return e
	}
	b, e := Load(path)
	if e != nil {
		return e
	}
	if !strings.EqualFold(a.Hash, s.SourceHash) {
		return fmt.Errorf("source fingerprint mismatch")
	}
	aa, bb := *a.Terrain, *b.Terrain
	aa.Tiles, bb.Tiles = nil, nil
	if !reflect.DeepEqual(aa, bb) {
		return fmt.Errorf("terrain dimensions or metadata changed")
	}
	allowed := map[string]bool{"war3map.w3e": true, "war3map.doo": true, "war3map.wpm": true, "war3map.shd": true, "war3mapmap.blp": true}
	changes := map[string]string{}
	for n, v := range a.Files {
		if !bytes.Equal(v, b.Files[n]) {
			if !allowed[n] {
				return fmt.Errorf("unrelated member changed: %s", n)
			}
			changes[n] = Hash(b.Files[n])
		}
	}
	for n := range b.Files {
		if n == "(listfile)" || n == "(attributes)" {
			continue
		}
		if _, ok := a.Files[n]; !ok {
			return fmt.Errorf("unexpected member %s", n)
		}
	}
	g := &Scene{Map: b, Spec: s, Water: -89.6}
	if g.whole() {
		donor := &Scene{Map: a, Spec: s, Water: -89.6, Original: append([]w3e.Tilepoint{}, a.Terrain.Tiles...)}
		if e = donor.prepareWhole(); e != nil {
			return e
		}
		objects := map[uint32]doodadsdoo.Doodad{}
		for _, d := range b.Doodads.Doodads {
			objects[d.CreationNumber] = d
		}
		for _, d := range donor.Anchors {
			if !reflect.DeepEqual(d, objects[d.CreationNumber]) {
				return fmt.Errorf("retained composition object %d changed", d.CreationNumber)
			}
		}
		for i, t := range a.Terrain.Tiles {
			x, y := donor.xy(i%int(a.Terrain.Width), i/int(a.Terrain.Width))
			if (donor.anchorWeight(x, y) == 0 || t.Boundary || float64(t.FinalZ()) < donor.Water+30) && t != b.Terrain.Tiles[i] {
				return fmt.Errorf("whole-map shore or composition support changed at %d", i)
			}
		}
	}
	for i, t := range a.Terrain.Tiles {
		x, y := g.xy(i%int(a.Terrain.Width), i/int(a.Terrain.Width))
		if !s.Editable(x, y) && t != b.Terrain.Tiles[i] {
			return fmt.Errorf("protected vertex %d changed", i)
		}
	}
	if len(a.Pathing.Cells) != len(b.Pathing.Cells) || len(a.Files["war3map.shd"]) != len(b.Files["war3map.shd"]) {
		return fmt.Errorf("spatial layer dimensions changed")
	}
	for i, v := range a.Pathing.Cells {
		x := float64(a.Terrain.CenterOffset[0]) + float64(i%a.Pathing.Width)*32 + 16
		y := float64(a.Terrain.CenterOffset[1]) + float64(i/a.Pathing.Width)*32 + 16
		if !s.Editable(x, y) && (v != b.Pathing.Cells[i] || a.Files["war3map.shd"][i] != b.Files["war3map.shd"][i]) {
			return fmt.Errorf("protected spatial cell %d changed", i)
		}
		if s.Shadows == "omit" && s.Editable(x, y) && b.Files["war3map.shd"][i] != 0 {
			return fmt.Errorf("excluded shadow cell %d is not cleared", i)
		}
	}
	outside := func(m *Map) map[uint32]doodadsdoo.Doodad {
		r := map[uint32]doodadsdoo.Doodad{}
		for _, d := range m.Doodads.Doodads {
			if !s.Editable(float64(d.Position[0]), float64(d.Position[1])) {
				r[d.CreationNumber] = d
			}
		}
		return r
	}
	if !reflect.DeepEqual(outside(a), outside(b)) {
		return fmt.Errorf("protected objects changed")
	}
	da, db := *a.Doodads, *b.Doodads
	da.Doodads, db.Doodads = nil, nil
	if !reflect.DeepEqual(da, db) {
		return fmt.Errorf("doodad metadata or terrain doodads changed")
	}
	seen := map[uint32]bool{}
	for _, d := range b.Doodads.Doodads {
		if seen[d.CreationNumber] {
			return fmt.Errorf("duplicate creation number %d", d.CreationNumber)
		}
		seen[d.CreationNumber] = true
	}
	cat, e := CatalogMap(b, s.Install)
	if e != nil {
		return e
	}
	for id, v := range cat.Assets {
		if len(v.Errors) > 0 {
			return fmt.Errorf("asset %s: %v", id, v.Errors)
		}
	}
	g.Catalog = cat
	_, _, reachable, e := g.spatialLayers(false)
	if e != nil {
		return e
	}
	if !reachable {
		return fmt.Errorf("stored WPM and object footprints disconnect route")
	}
	members := map[string]string{}
	for n, v := range b.Files {
		members[n] = Hash(v)
	}
	shadow := "see bake.json"
	if s.Shadows == "omit" {
		shadow = "excluded by user; edited SHD cleared"
	}
	return JSON(out, map[string]any{"format": "wc3-export-validation-v1", "status": "Validated", "map": path, "map_sha256": b.Hash, "source_sha256": a.Hash, "mode": s.Mode, "protected_unchanged": true, "route_reachable": true, "asset_errors": 0, "changed_members": changes, "members": members, "visual_acceptance": "see visual-review.md", "native_shadows": shadow})
}
