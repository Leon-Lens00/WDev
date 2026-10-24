package terrainproc

import (
	"encoding/json"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"os"
	"path/filepath"
	"reflect"
	"testing"
)

func recomposeTestSpec(t *testing.T) Spec {
	t.Helper()
	p := os.Getenv("WC3_RECOMPOSE_SPEC")
	if p == "" {
		t.Skip("WC3_RECOMPOSE_SPEC required for real-map integration")
	}
	s, e := ReadSpec(p)
	if e != nil {
		t.Fatal(e)
	}
	return s
}

func TestRecomposeLibraryAndTranslation(t *testing.T) {
	s := recomposeTestSpec(t)
	g, l, plan, parts, e := buildRecomposeBase(s)
	if e != nil {
		t.Fatal(e)
	}
	if len(l.Prefabs) != 6 || len(parts) != 794 || len(l.Ownership) != 3203 || plan.SourceIoU > .7 || plan.ChangedPairs < 3 {
		t.Fatal("incomplete library or unchanged geography")
	}
	at := 0
	for i, p := range l.Prefabs {
		q := plan.Placements[i]
		if dist(q.Center, p.Pivot) < 1536 {
			t.Fatal("unmoved scene")
		}
		for j := 0; j < i; j++ {
			if overlap(q.Reserve, plan.Placements[j].Reserve) {
				t.Fatal("overlapping reserves")
			}
		}
		for _, piece := range p.Pieces {
			want := adjustedPrefabPiece(g, p, piece)
			want.Position[0] += float32(q.Offset[0])
			want.Position[1] += float32(q.Offset[1])
			if !reflect.DeepEqual(want, parts[at]) {
				t.Fatal("rigid composition lost")
			}
			at++
		}
		for y := 0; y < p.SupportHeight; y++ {
			for x := 0; x < p.SupportWidth; x++ {
				want := p.Support[x+y*p.SupportWidth]
				want.Boundary = false
				want.Flags &^= 8
				idx := g.index(q.Core.Min[0]+float64(x)*128, q.Core.Min[1]+float64(y)*128)
				if g.Map.Terrain.Tiles[idx] != want {
					t.Fatal("support not retained")
				}
			}
		}
	}
	_, _, again, _, e := buildRecomposeBase(s)
	if e != nil || !reflect.DeepEqual(plan, again) {
		t.Fatal("layout is not deterministic", e)
	}
}

func TestRecomposeSourceRoutes(t *testing.T) {
	s := recomposeTestSpec(t)
	g, e := recomposeScene(s)
	if e != nil {
		t.Fatal(e)
	}
	b := combinedRecompose(g, staticRecomposePathing(g))
	for _, pair := range [][2][2]float64{{{9056, -96}, {9056, -416}}, {{-4384, 5280}, {-4064, 5600}}} {
		a := nearestFree(g, b, pair[0], 256)
		z := nearestFree(g, b, pair[1], 256)
		path, e := gridPath(g, b, a, z, s.Edit)
		if e != nil || len(path) < 8 {
			t.Fatal("local courtyard/deck route lost", pair, e)
		}
	}
}

func TestRecomposeRejectsInvalidContracts(t *testing.T) {
	s := recomposeTestSpec(t)
	for name, mutate := range map[string]func(*Spec){"outside_donor": func(v *Spec) { v.Recompose.Compositions[0].Source.Min[0] = -20096 }, "missing_anchor": func(v *Spec) { delete(v.Recompose.Compositions[0].Anchors, "access") }, "duplicate_seed": func(v *Spec) { v.Recompose.Seeds[1] = v.Recompose.Seeds[0] }, "rotation": func(v *Spec) { v.Recompose.Compositions[0].Rotations = []int{90} }, "missing_scene": func(v *Spec) { v.Recompose.Compositions = v.Recompose.Compositions[:5] }, "duplicate": func(v *Spec) { v.Recompose.Compositions[1].ID = "circle" }, "off_grid": func(v *Spec) { v.Recompose.Compositions[0].Source.Min[0]++ }, "stale_source": func(v *Spec) { v.SourceHash = "bad" }, "shadow": func(v *Spec) { v.Shadows = "bake" }} {
		t.Run(name, func(t *testing.T) {
			raw, _ := json.Marshal(s)
			var v Spec
			_ = json.Unmarshal(raw, &v)
			mutate(&v)
			if v.Validate() == nil {
				t.Fatal("bad contract accepted")
			}
		})
	}
}

func TestRecomposeExportRejectsCorruption(t *testing.T) {
	s := recomposeTestSpec(t)
	dir := t.TempDir()
	r, e := Generate(s, filepath.Join(dir, "valid"))
	if e != nil {
		t.Fatal(e)
	}
	m, e := Load(r.Map)
	if e != nil {
		t.Fatal(e)
	}
	if r.CompositionPieces != 794 || len(r.Engine.States) != 192*96 {
		t.Fatal("missing composition/WFC output")
	}
	changes := map[string]map[string][]byte{}
	terrain := *m.Terrain
	terrain.Tiles = append([]w3e.Tilepoint{}, m.Terrain.Tiles...)
	terrain.Tiles[9000].GroundHeight++
	tb, _ := w3e.Encode(&terrain)
	changes["terrain"] = map[string][]byte{"war3map.w3e": tb}
	objects := *m.Doodads
	objects.Doodads = append([]doodadsdoo.Doodad{}, m.Doodads.Doodads...)
	objects.Doodads[0].Position[2] += 5
	db, _ := doodadsdoo.Encode(&objects)
	changes["floating_scene"] = map[string][]byte{"war3map.doo": db}
	objects.Doodads[1].CreationNumber = objects.Doodads[0].CreationNumber
	db, _ = doodadsdoo.Encode(&objects)
	changes["duplicate_id"] = map[string][]byte{"war3map.doo": db}
	for name, member := range map[string]string{"pathing": "war3map.wpm", "shadow": "war3map.shd", "camera": "war3map.w3c", "start": "war3mapunits.doo", "script": "war3map.j", "import": "war3map.imp"} {
		v := append([]byte{}, m.Files[member]...)
		v[len(v)-1] ^= 1
		changes[name] = map[string][]byte{member: v}
	}
	for name, change := range changes {
		t.Run(name, func(t *testing.T) {
			path := filepath.Join(dir, name+".w3x")
			if e := m.Write(path, change); e != nil {
				t.Fatal(e)
			}
			if e := ValidateRecompose(s, path, filepath.Join(dir, name+".json")); e == nil {
				t.Fatal("corrupt exported archive accepted")
			}
		})
	}
}
