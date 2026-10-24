package terrainproc

import (
	"encoding/json"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"os"
	"path/filepath"
	"reflect"
	"testing"
)

func landscapeTestSpec(t *testing.T) Spec {
	t.Helper()
	path := os.Getenv("WC3_LANDSCAPE_SPEC")
	if path == "" {
		t.Skip("WC3_LANDSCAPE_SPEC required for physical Classic donor integration")
	}
	s, e := ReadSpec(path)
	if e != nil {
		t.Fatal(e)
	}
	return s
}
func cloneLandscapeSpec(s Spec) Spec {
	raw, _ := json.Marshal(s)
	var out Spec
	_ = json.Unmarshal(raw, &out)
	return out
}
func TestLandscapeContracts(t *testing.T) {
	original := landscapeTestSpec(t)
	cases := map[string]func(*Spec){
		"missing-parent": func(s *Spec) { s.Landscape.Brief.Groups[0].Parent = "missing-1" },
		"duplicate-territory": func(s *Spec) {
			s.Landscape.Brief.Groups[0].Members = append(s.Landscape.Brief.Groups[0].Members, s.Landscape.Brief.Groups[0].Members[0])
		},
		"unowned-instance":    func(s *Spec) { s.Landscape.Brief.Groups[0].Members = s.Landscape.Brief.Groups[0].Members[1:] },
		"reduced-count":       func(s *Spec) { s.Landscape.Brief.Counts["waterfall"]-- },
		"missing-outlet":      func(s *Spec) { s.Landscape.Brief.Relations[0].FromPort = "missing" },
		"inverted-feed":       func(s *Spec) { r := &s.Landscape.Brief.Relations[0]; r.From, r.To = r.To, r.From },
		"self-cycle":          func(s *Spec) { s.Landscape.Brief.Relations[0].To = s.Landscape.Brief.Relations[0].From },
		"no-water":            func(s *Spec) { s.Landscape.Brief.Relations = s.Landscape.Brief.Relations[1:] },
		"unproven-relation":   func(s *Spec) { s.Landscape.Brief.Relations[0].Kind = "teleport" },
		"impossible-width":    func(s *Spec) { s.Landscape.Brief.Relations[0].Width = 4096 },
		"insufficient-budget": func(s *Spec) { s.Scene.MaxObjects = 1000 },
		"missing-stream":      func(s *Spec) { delete(s.Landscape.Streams, "water") },
		"changed-library":     func(s *Spec) { s.Landscape.LibrarySHA = "invalid" },
		"wrong-version":       func(s *Spec) { s.Format = "wc3-scene-spec-v3" },
		"no-island-reason":    func(s *Spec) { s.Landscape.Brief.Groups[len(s.Landscape.Brief.Groups)-1].Reason = "" },
	}
	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			s := cloneLandscapeSpec(original)
			mutate(&s)
			if s.Validate() == nil {
				t.Fatal("invalid contract accepted")
			}
		})
	}
}
func TestLandscapePhysicalWater(t *testing.T) {
	tile := w3e.Tilepoint{LayerHeight: 1, WaterLevel: 8192, Flags: 4}
	setGround(&tile, 0)
	if landscapeWet(tile, -89.6) {
		t.Fatal("water flag alone is not visible water")
	}
	setGround(&tile, -128)
	if !landscapeWet(tile, -89.6) {
		t.Fatal("sea bed should be wet")
	}
	tile.WaterLevel = 9216
	setGround(&tile, 100)
	if !landscapeWet(tile, -89.6) {
		t.Fatal("local elevated basin ignored")
	}
	tile.Flags = 0
	if landscapeWet(tile, -89.6) {
		t.Fatal("absent surface treated as wet")
	}
}

func TestLandscapeLagoonWetCoreSurvivesRoundedShore(t *testing.T) {
	s := landscapeTestSpec(t)
	g, _, lib, p, _, _, err := buildLandscapeBase(s)
	if err != nil {
		t.Fatal(err)
	}
	q := landscapePlacement(p, "lagoon-1")
	f := scenePrefab(lib, "lagoon")
	wet, released := 0, 0
	for y := f.Source.Min[1]; y <= f.Source.Max[1]; y += 128 {
		for x := f.Source.Min[0]; x <= f.Source.Max[0]; x += 128 {
			a, b := g.index(x, y), g.index(x+q.Offset[0], y+q.Offset[1])
			if landscapeWet(g.Original[a], g.Water) {
				wet++
				if p.Masks[b] != "rigid" || g.Original[a].FinalZ() != g.Map.Terrain.Tiles[b].FinalZ() || g.Original[a].WaterZ() != g.Map.Terrain.Tiles[b].WaterZ() {
					t.Fatal("rounding modified authored lagoon bathymetry")
				}
			} else if p.Masks[b] != "rigid" {
				released++
			}
		}
	}
	if wet == 0 || released == 0 {
		t.Fatal("lagoon must retain real wet core and release empty dry crop corners")
	}
}
func TestLandscapeSeedIsolation(t *testing.T) {
	s := landscapeTestSpec(t)
	g, l, lib, p, parts, prov, e := buildLandscapeBase(s)
	if e != nil {
		t.Fatal(e)
	}
	full, e := materializeLandscape(s, t.TempDir())
	if e != nil {
		t.Fatal(e)
	}
	g.Map.Terrain = full.G.Map.Terrain
	p = full.Plan
	macro := append([]w3e.Tilepoint{}, g.Map.Terrain.Tiles...)
	initial, ip, _, e := landscapeDecorate(g, l, p, parts, prov)
	if e != nil {
		t.Fatal(e)
	}
	g.Spec = cloneLandscapeSpec(s)
	g.Spec.Landscape.Streams["vegetation"]++
	g.Spec.Scene.ForestSeed++
	changed, cp, _, e := landscapeDecorate(g, l, p, parts, prov)
	if e != nil {
		t.Fatal(e)
	}
	if reflect.DeepEqual(initial, changed) {
		t.Fatal("vegetation stream ignored")
	}
	structural := func(ds any, ps []Provenance) []any {
		raw, _ := json.Marshal(ds)
		var all []any
		_ = json.Unmarshal(raw, &all)
		v := []any{}
		for i, x := range ps {
			if x.Role != "forest" {
				v = append(v, all[i])
			}
		}
		return v
	}
	if !reflect.DeepEqual(structural(initial, ip), structural(changed, cp)) || !reflect.DeepEqual(macro, g.Map.Terrain.Tiles) {
		t.Fatal("vegetation changed a non-vegetation dependency")
	}
	g.Spec = cloneLandscapeSpec(s)
	g.Spec.Landscape.Streams["ornaments"]++
	ornaments, op, e := landscapeParts(g, l, lib, p)
	if e != nil {
		t.Fatal(e)
	}
	if reflect.DeepEqual(parts, ornaments) {
		t.Fatal("ornament stream ignored")
	}
	for i, d := range parts {
		if op[i].Role == "essential" && !reflect.DeepEqual(d, ornaments[i]) {
			t.Fatal("ornament changed structural core")
		}
	}
	if !reflect.DeepEqual(macro, g.Map.Terrain.Tiles) {
		t.Fatal("ornament modified terrain")
	}
}
func TestLandscapeModuleRejections(t *testing.T) {
	s := landscapeTestSpec(t)
	var lib LandscapeLibrary
	if e := strictJSON(s.Landscape.Library, &lib); e != nil {
		t.Fatal(e)
	}
	for name, mutate := range map[string]func(*LandscapeLibrary){"lost-member": func(l *LandscapeLibrary) { l.Modules[0].Members[0] = 999999 }, "phase": func(l *LandscapeLibrary) { l.Modules[0].Shifts[1][0][0] = 17 }, "unsupported-height": func(l *LandscapeLibrary) { l.Modules[0].Policy = "ground-snap-everything" }} {
		t.Run(name, func(t *testing.T) {
			raw, _ := json.Marshal(lib)
			var changed LandscapeLibrary
			_ = json.Unmarshal(raw, &changed)
			mutate(&changed)
			p := filepath.Join(t.TempDir(), "library.json")
			if e := JSON(p, changed); e != nil {
				t.Fatal(e)
			}
			raw, _ = os.ReadFile(p)
			candidate := cloneLandscapeSpec(s)
			candidate.Landscape.Library = p
			candidate.Landscape.LibrarySHA = Hash(raw)
			if candidate.Validate() == nil {
				t.Fatal("unproven module accepted")
			}
		})
	}
}
