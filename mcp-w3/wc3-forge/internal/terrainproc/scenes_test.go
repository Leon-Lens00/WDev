package terrainproc

import (
	"encoding/json"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"testing"
)

func sceneTestSpec(t *testing.T) Spec {
	t.Helper()
	p := os.Getenv("WC3_SCENE_SPEC")
	if p == "" {
		t.Skip("WC3_SCENE_SPEC required for real donor integration")
	}
	s, e := ReadSpec(p)
	if e != nil {
		t.Fatal(e)
	}
	return s
}
func TestSceneGroupOwnership(t *testing.T) {
	groups := []PieceGroup{{ID: "root", Children: []string{"a", "b"}}, {ID: "a", Members: []uint32{1, 2}}, {ID: "b", Children: []string{"a"}, Members: []uint32{3}}}
	got, e := flattenGroups(groups, []string{"root"})
	if e != nil || !slices.Equal(got, []uint32{1, 2, 3}) {
		t.Fatal(got, e)
	}
	groups[1].Children = []string{"root"}
	if _, e := flattenGroups(groups, []string{"root"}); e == nil {
		t.Fatal("cycle accepted")
	}
	groups[1].Children = []string{"missing"}
	if _, e := flattenGroups(groups, []string{"root"}); e == nil {
		t.Fatal("dangling group accepted")
	}
	groups[1].Children = nil
	groups[1].Members = []uint32{1, 1}
	if _, e := flattenGroups(groups, []string{"root"}); e == nil {
		t.Fatal("duplicate membership accepted")
	}
}
func TestSceneQuarterTurnsAndGrid(t *testing.T) {
	pivot := [2]float64{128, 256}
	dest := [2]float64{2048, -768}
	r := Rect{[2]float64{0, 0}, [2]float64{512, 256}}
	for _, angle := range []int{0, 90, 180, 270} {
		rr := turnRect(r, pivot, dest, angle)
		if back := turnRect(rr, dest, pivot, 360-angle); back != r {
			t.Fatal("rectangular support changed", angle, back)
		}
		for _, phase := range []float64{0, 32} {
			p := [2]float64{64 + phase, 192 + phase}
			q := turnPoint(p, pivot, dest, angle)
			back := turnPoint(q, dest, pivot, 360-angle)
			if back != p {
				t.Fatal("inverse changed coordinates")
			}
			if int(q[0])%32 != 0 || int(q[1])%32 != 0 {
				t.Fatal("classic footprint phase lost")
			}
		}
	}
	if sceneSeed(5, "forest", "x") == sceneSeed(5, "layout", "x") {
		t.Fatal("streams overlap")
	}
}
func TestSceneBriefCountsAndMissingPorts(t *testing.T) {
	s := sceneTestSpec(t)
	g, e := recomposeScene(s)
	if e != nil {
		t.Fatal(e)
	}
	l, b, e := loadSceneLibrary(g)
	if e != nil {
		t.Fatal(e)
	}
	copySpec := func() Spec { raw, _ := json.Marshal(s); var v Spec; json.Unmarshal(raw, &v); return v }
	v := copySpec()
	v.Scene.Brief.Counts = map[string]int{"circle": 1, "waterfall": 2, "lagoon": 1}
	v.Scene.Brief.IncludeRecovered = false
	if e := resolveInstances(&v, l); e != nil {
		t.Fatal(e)
	}
	if len(v.Scene.Instances) != 4 {
		t.Fatal("fixed six-count regression")
	}
	v.Scene.Brief.Counts["platform"] = 2
	if e := resolveInstances(&v, l); e != nil {
		t.Fatal(e)
	}
	v.Scene.Brief.Counts["temple"] = 1
	if e := resolveInstances(&v, l); e != nil || len(v.Scene.Instances) != 7 {
		t.Fatal("seven instances failed", e)
	}
	v.Scene.Brief.Counts["missing"] = 1
	if resolveInstances(&v, l) == nil {
		t.Fatal("unknown family accepted")
	}
	v = copySpec()
	v.Scene.Brief.Counts["platform"] = 99
	if resolveInstances(&v, l) == nil {
		t.Fatal("impossible count accepted")
	}
	v = copySpec()
	v.Scene.Brief.Links = []SceneLink{{From: "circle-1", To: "temple-1", FromPort: "absent", ToPort: "center", Role: "scenic"}}
	if _, e := sceneLayout(v, l, b, 0); e == nil {
		t.Fatal("absent connection port accepted")
	}
}
func TestSceneLibraryRejectsCorruption(t *testing.T) {
	s := sceneTestSpec(t)
	g, e := recomposeScene(s)
	if e != nil {
		t.Fatal(e)
	}
	original, _, e := loadSceneLibrary(g)
	if e != nil {
		t.Fatal(e)
	}
	for name, mutate := range map[string]func(*SceneLibrary){
		"duplicate-owner":          func(l *SceneLibrary) { l.Components[1].Groups = l.Components[0].Groups },
		"missing-piece":            func(l *SceneLibrary) { l.Groups[0].Members = append(l.Groups[0].Members, 999999) },
		"missing-anchor":           func(l *SceneLibrary) { delete(l.Components[0].Anchors, "access") },
		"missing-coverage":         func(l *SceneLibrary) { delete(l.Coverage, 0) },
		"ineligible-main-rotation": func(l *SceneLibrary) { l.Components[0].Rotations = []int{90} },
		"source-support-outside":   func(l *SceneLibrary) { l.Components[0].Source.Min[0] = -50000 },
		"unreviewed":               func(l *SceneLibrary) { l.ReviewSHA = "invalid" },
		"unknown-water-policy":     func(l *SceneLibrary) { l.Recipes[0].HeightPolicy = "float-anywhere" },
	} {
		t.Run(name, func(t *testing.T) {
			raw, _ := json.Marshal(original)
			var l SceneLibrary
			json.Unmarshal(raw, &l)
			mutate(&l)
			p := filepath.Join(t.TempDir(), "library.json")
			JSON(p, l)
			raw, _ = os.ReadFile(p)
			g.Spec.Scene.Library = p
			g.Spec.Scene.LibrarySHA = Hash(raw)
			if _, _, e := loadSceneLibrary(g); e == nil {
				t.Fatal("corrupt library accepted")
			}
		})
	}
}
func TestSceneExportAndForestIsolation(t *testing.T) {
	s := sceneTestSpec(t)
	dir := t.TempDir()
	r, e := GenerateScenes(s, filepath.Join(dir, "valid"))
	if e != nil {
		t.Fatal(e)
	}
	m, e := Load(r.Map)
	if e != nil {
		t.Fatal(e)
	}
	if r.CompositionPieces < 794 || len(r.Engine.States) != 192*96 {
		t.Fatal("missing scene/WFC")
	}
	g, library, _, plan, parts, prov, e := buildSceneBase(s)
	if e != nil {
		t.Fatal(e)
	}
	macro := slices.Clone(g.Map.Terrain.Tiles)
	g.Map.Terrain = m.Terrain
	expected, oldProv, metrics, e := decorateScenes(g, library, plan, parts, prov)
	if e != nil {
		t.Fatal(e)
	}
	if metrics.Count < 30 || metrics.Quantiles[1] > 160 || metrics.Neighbors256 < 3 {
		t.Fatal("forest profile not compact", metrics)
	}
	opts := *g.Spec.Scene
	g.Spec.Scene = &opts
	g.Spec.Scene.ForestSeed++
	different, newProv, _, e := decorateScenes(g, library, plan, parts, prov)
	if e != nil {
		t.Fatal(e)
	}
	if reflect.DeepEqual(different, expected) {
		t.Fatal("forest seed ignored")
	}
	if !reflect.DeepEqual(different[:len(parts)], parts) {
		t.Fatal("forest seed changed scene pieces")
	}
	nonForest := func(ds []doodadsdoo.Doodad, p []Provenance) []doodadsdoo.Doodad {
		v := []doodadsdoo.Doodad{}
		for i, x := range p {
			if x.Role != "forest" {
				v = append(v, ds[i])
			}
		}
		return v
	}
	if !reflect.DeepEqual(nonForest(expected, oldProv), nonForest(different, newProv)) {
		t.Fatal("forest seed changed environmental objects")
	}
	for i, tile := range macro {
		if tile.GroundHeight != m.Terrain.Tiles[i].GroundHeight {
			t.Fatal("forest touched macro geometry")
		}
	}
	changes := map[string]map[string][]byte{}
	terrain := *m.Terrain
	terrain.Tiles = slices.Clone(terrain.Tiles)
	terrain.Tiles[9000].GroundHeight++
	tb, _ := w3e.Encode(&terrain)
	changes["terrain"] = map[string][]byte{"war3map.w3e": tb}
	for name, mutate := range map[string]func(*doodadsdoo.Doodad){"floating-tree": func(d *doodadsdoo.Doodad) { d.Position[2] += 20 }, "duplicate-tree": func(d *doodadsdoo.Doodad) { d.CreationNumber = m.Doodads.Doodads[0].CreationNumber }} {
		objects := *m.Doodads
		objects.Doodads = slices.Clone(objects.Doodads)
		mutate(&objects.Doodads[len(parts)])
		db, _ := doodadsdoo.Encode(&objects)
		changes[name] = map[string][]byte{"war3map.doo": db}
	}
	for name, member := range map[string]string{"pathing": "war3map.wpm", "shadow": "war3map.shd", "camera": "war3map.w3c", "start": "war3mapunits.doo", "script": "war3map.j", "import": "war3map.imp"} {
		v := slices.Clone(m.Files[member])
		v[len(v)-1] ^= 1
		changes[name] = map[string][]byte{member: v}
	}
	for name, change := range changes {
		t.Run(name, func(t *testing.T) {
			p := filepath.Join(dir, "valid", name+".w3x")
			if e := m.Write(p, change); e != nil {
				t.Fatal(e)
			}
			if ValidateScenes(s, p, filepath.Join(dir, name+".json")) == nil {
				t.Fatal("corrupt export accepted")
			}
		})
	}
	provenancePath := filepath.Join(dir, "valid", "placements-provenance.json")
	oldProv[0].SourceID++
	JSON(provenancePath, oldProv)
	if ValidateScenes(s, r.Map, filepath.Join(dir, "bad-provenance.json")) == nil {
		t.Fatal("corrupt provenance accepted")
	}
}
