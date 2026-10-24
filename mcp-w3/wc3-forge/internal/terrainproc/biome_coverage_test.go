package terrainproc

import (
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

func TestBiomeCoverageContract(t *testing.T) {
	p := &BiomeCoveragePolicy{CoreMinimum: .65, EdgeMinimum: .32, EdgeWidth: 256, MaxCoreGap: 256, FragmentRadius: 320, MaxNeighbors: 14, MaxAdditions: 1400, MaxAttempts: 2400}
	q := BiomeRecipe{Realizer: "ellipses-cohorts-v1"}
	if validateCoveragePolicy(q, p) == nil {
		t.Fatal("v1 silently changes behavior")
	}
	q.Realizer = "ellipses-cohorts-v2"
	if validateCoveragePolicy(q, nil) == nil {
		t.Fatal("v2 has no acceptance policy")
	}
	if e := validateCoveragePolicy(q, p); e != nil {
		t.Fatal(e)
	}
	p.CoreMinimum = 1
	if validateCoveragePolicy(q, p) == nil {
		t.Fatal("solid-canopy policy accepted")
	}
}

func TestBiomeCoverageDetectsLocalHoles(t *testing.T) {
	q := BiomeRecipe{Forest: make([]BiomeEllipse, 2), Geometry: MaterialGeometry{Width: 65, Height: 65}}
	p := &BiomeCoveragePolicy{CoreMinimum: .65, EdgeMinimum: .32, MaxCoreGap: 256}
	s := []biomeCanopySample{}
	// Plenty of cover in one forest must not mask a missing neighboring forest.
	for i := 0; i < 100; i++ {
		s = append(s, biomeCanopySample{Zone: 0, Gap: -1})
	}
	s = append(s, biomeCanopySample{Zone: 2, Gap: 500})
	r := reportBiomeCanopy(s, q, p)
	if len(r.Failures) != 1 || !strings.Contains(r.Failures[0], "habitat 1 core") {
		t.Fatal(r)
	}
}

func TestBiomeCoveragePreservesAndValidates(t *testing.T) {
	spec := os.Getenv("WC3_FOREST_RECIPE")
	if spec == "" {
		t.Skip("WC3_FOREST_RECIPE required")
	}
	q, p, _, _, _, _, e := loadBiome(spec)
	if e != nil {
		t.Fatal(e)
	}
	root := t.TempDir()
	seed := q.Seeds[0]
	loadRun := func(spec, dir string) (BiomeRun, *Map, error) {
		e := GenerateBiome(spec, dir, seed)
		if e != nil {
			return BiomeRun{}, nil, e
		}
		var r BiomeRun
		e = strictJSON(filepath.Join(dir, "run.json"), &r)
		if e != nil {
			return r, nil, e
		}
		m, e := Load(r.Map)
		return r, m, e
	}
	r, a, e := loadRun(spec, filepath.Join(root, "new"))
	if e != nil {
		t.Fatal(e)
	}
	r2, _, e := loadRun(spec, filepath.Join(root, "repeat"))
	if e != nil || r.MapSHA != r2.MapSHA {
		t.Fatalf("nondeterministic: %v", e)
	}
	legacyProfile := p
	legacyProfile.Forest.Coverage = nil
	pp := filepath.Join(root, "legacy-profile.json")
	if e = JSON(pp, legacyProfile); e != nil {
		t.Fatal(e)
	}
	raw, _ := os.ReadFile(pp)
	legacy := q
	legacy.Realizer = "ellipses-cohorts-v1"
	legacy.Profile = BiomeReference{pp, Hash(raw)}
	lp := filepath.Join(root, "legacy.json")
	if e = JSON(lp, legacy); e != nil {
		t.Fatal(e)
	}
	lr, b, e := loadRun(lp, filepath.Join(root, "legacy"))
	if e != nil {
		t.Fatal(e)
	}
	if base := os.Getenv("WC3_FOREST_BASEMAP"); base != "" {
		baseline, e := os.ReadFile(base)
		if e != nil {
			t.Fatal(e)
		}
		if Hash(baseline) != lr.MapSHA {
			t.Fatal("legacy release is not byte-exact")
		}
	}
	if len(a.Doodads.Doodads) <= len(b.Doodads.Doodads) {
		t.Fatal("vacuous refinement")
	}
	if !reflect.DeepEqual(a.Doodads.Doodads[:len(b.Doodads.Doodads)], b.Doodads.Doodads) {
		t.Fatal("existing objects modified")
	}
	for i, x := range a.Terrain.Tiles {
		if !materialPhysicalEqual(x, b.Terrain.Tiles[i]) {
			t.Fatal("geography/water changed")
		}
	}
	for _, name := range []string{"war3mapunits.doo", "war3map.w3i", "war3map.j", "war3map.w3c", "war3map.w3r", "war3map.shd"} {
		if !reflect.DeepEqual(a.Files[name], b.Files[name]) {
			t.Fatal("protected shell changed: " + name)
		}
	}
	if ValidateBiome(spec, lr.Map, filepath.Join(root, "reject-holes.json")) == nil {
		t.Fatal("undercovered output certified")
	}
	// Explicit clearings are preserved by both the base placement and refinement.
	q.ForestClearings = []BiomeEllipse{{Center: q.Forest[0].Center, Radius: [2]float64{.018, .018}}}
	cp := filepath.Join(root, "clearing.json")
	if e = JSON(cp, q); e != nil {
		t.Fatal(e)
	}
	cr, c, e := loadRun(cp, filepath.Join(root, "clearing"))
	if e != nil {
		t.Fatal(e)
	}
	for i, d := range c.Doodads.Doodads {
		if strings.HasPrefix(cr.Placements[i].Role, "forest") && biomeEllipse(q, [2]float64{float64(d.Position[0]), float64(d.Position[1])}, q.ForestClearings[0]) <= 1 {
			t.Fatal("tree in explicit clearing")
		}
	}
	// A budget-limited output may be inspected, but cannot be delivered as passed.
	p.Forest.Coverage.MaxAdditions = 1
	p.Forest.Coverage.MaxAttempts = 1
	bp := filepath.Join(root, "budget-profile.json")
	_ = JSON(bp, p)
	raw, _ = os.ReadFile(bp)
	q.ForestClearings = nil
	q.Profile = BiomeReference{bp, Hash(raw)}
	bq := filepath.Join(root, "budget.json")
	_ = JSON(bq, q)
	if e := GenerateBiome(bq, filepath.Join(root, "budget"), seed); e == nil || !strings.Contains(e.Error(), "forest habitat") {
		t.Fatalf("budget failure not explicit: %v", e)
	}
}
