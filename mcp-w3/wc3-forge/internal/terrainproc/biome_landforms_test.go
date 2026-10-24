package terrainproc

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

func TestBiomeLandformRoutesShareDecorationContract(t *testing.T) {
	for _, kind := range []string{"matched", "undeclared", "sections", "absent"} {
		t.Run(kind, func(t *testing.T) {
			plan := landformTestPlan()
			base := plan.Features[2]
			q := BiomeRecipe{Geometry: plan.Geometry, WaterLevel: plan.WaterLevel, Routes: []BiomeRoute{{ID: base.ID, Points: base.Points, Width: base.Width, Height: base.Height}}, Landforms: &BiomeLandforms{}}
			switch kind {
			case "undeclared":
				extra := base
				extra.ID = "unreserved-trail"
				plan.Features = append(plan.Features, extra)
			case "sections":
				plan.Features[2].Sections = []LandformSection{{At: 0, Width: 64, Height: 170}, {At: 1, Width: 128, Height: 70}}
			case "absent":
				plan.Features = plan.Features[:2]
				plan.Relations = plan.Relations[:1]
			}
			root := t.TempDir()
			write := func(name string, v any) BiomeReference {
				t.Helper()
				raw, e := json.Marshal(v)
				if e != nil {
					t.Fatal(e)
				}
				if e = os.WriteFile(filepath.Join(root, name), raw, 0600); e != nil {
					t.Fatal(e)
				}
				return BiomeReference{Path: name, SHA: Hash(raw)}
			}
			donor := strings.Repeat("a", 64)
			q.Landforms.Plan = write("plan.json", plan)
			q.Landforms.Profile = write("profile.json", map[string]any{"format": "wc3-landform-profile-v1", "donor": BiomeReference{SHA: donor}})
			e := loadBiomeLandforms(root, &q, MaterialProfile{WaterOffset: plan.WaterOffset}, donor)
			if kind == "matched" && e != nil {
				t.Fatal(e)
			}
			if kind != "matched" && e == nil {
				t.Fatal("physical route escaped shared decoration contract")
			}
		})
	}
}

func TestBiomeLandformEncodedProvenanceAndPhysicalInspection(t *testing.T) {
	plan := landformTestPlan()
	q := BiomeRecipe{Geometry: plan.Geometry, WaterLevel: plan.WaterLevel, Seeds: []int{9341}, Streams: map[string]int{"landform-physical-v1": 9341}, Landforms: &BiomeLandforms{
		Plan: BiomeReference{SHA: strings.Repeat("a", 64)}, Profile: BiomeReference{SHA: strings.Repeat("b", 64)}, physical: plan,
	}}
	for _, kind := range []string{"valid", "missing", "stale-resolved", "stale-plan-hash", "unknown-seed", "wrong-physical-seed", "physical-corruption"} {
		t.Run(kind, func(t *testing.T) {
			m, surface := landformTestMap(t, plan, nil)
			r := BiomeLandformRecord{Format: "wc3-biome-landforms-v1", Seed: 9341, PhysicalSeed: 9341, PlanSHA: q.Landforms.Plan.SHA, ProfileSHA: q.Landforms.Profile.SHA, Plan: surface.Plan}
			switch kind {
			case "stale-resolved":
				r.Plan.Features[0].Height++
			case "stale-plan-hash":
				r.PlanSHA = strings.Repeat("c", 64)
			case "unknown-seed":
				r.Seed++
			case "wrong-physical-seed":
				r.PhysicalSeed++
			case "physical-corruption":
				m.Terrain.Tiles[0].WaterLevel += 32
			}
			raw, e := json.Marshal(r)
			if e != nil {
				t.Fatal(e)
			}
			m.Files = map[string][]byte{"war3map.landforms.json": raw}
			if kind == "missing" {
				delete(m.Files, "war3map.landforms.json")
			}
			inspection, e := inspectBiomeLandforms(q, SceneLibrary{}, &Map{}, MaterialProfile{WaterOffset: plan.WaterOffset}, m)
			if kind == "valid" && (e != nil || inspection == nil || !inspection.Passed) {
				t.Fatal("valid encoded provenance rejected", e)
			}
			if kind != "valid" && e == nil {
				t.Fatal("metadata/physical corruption accepted", kind)
			}
		})
	}
}

// These tests run the real habitat sampling against synthetic physical W3E;
// they need no MPQ donor or fixture and cannot be silently skipped.
func biomeLandformAreaFixture() (BiomeRecipe, BiomeProfile, *Scene) {
	geometry := MaterialGeometry{Width: 65, Height: 65, Origin: [2]float32{-4096, -4096}}
	q := BiomeRecipe{Realizer: "landforms-cohorts-v1", Geometry: geometry, WaterLevel: 0, Forest: []BiomeEllipse{
		{Center: [2]float64{.3, .5}, Radius: [2]float64{.16, .2}},
		{Center: [2]float64{.7, .5}, Radius: [2]float64{.16, .2}},
	}, Landforms: &BiomeLandforms{Habitats: []BiomeHabitatMinimum{{ID: "west", Index: 0, MinimumArea: 2000000}, {ID: "east", Index: 1, MinimumArea: 2000000}}}}
	p := BiomeProfile{Forest: BiomeForestRules{MaxSlope: 400, Coverage: &BiomeCoveragePolicy{CoreMinimum: .65, EdgeMinimum: .32, EdgeWidth: 64, MaxCoreGap: 256}}}
	m := &Map{Terrain: &w3e.File{Width: 65, Height: 65, CenterOffset: geometry.Origin, Tiles: make([]w3e.Tilepoint, 65*65)}}
	for i := range m.Terrain.Tiles {
		m.Terrain.Tiles[i] = w3e.Tilepoint{GroundHeight: 8792, LayerHeight: 2, WaterLevel: 8192, Flags: 4}
	}
	return q, p, &Scene{Map: m, Spec: Spec{Edit: biomeBounds(q)}}
}

func denseBiomeCanopy(q BiomeRecipe, p BiomeProfile, g *Scene) ([]biomeCanopySample, BiomeCoverageReport) {
	samples := biomeCanopyGrid(q, p, SceneLibrary{}, g)
	// Give the remaining habitat perfect canopy. This deliberately isolates
	// conservation of area from the separate forest-density checks.
	for i := range samples {
		samples[i].Gap = -1
	}
	return samples, reportBiomeCanopy(samples, q, p.Forest.Coverage)
}

func TestBiomeLandformHabitatZeroAreaCannotHideBehindNeighbor(t *testing.T) {
	q, p, g := biomeLandformAreaFixture()
	_, baseline := denseBiomeCanopy(q, p, g)
	if len(baseline.Failures) > 0 {
		t.Fatal("invalid synthetic baseline", baseline.Failures)
	}
	for i := range g.Map.Terrain.Tiles {
		if i%65 < 32 {
			g.Map.Terrain.Tiles[i].GroundHeight = 7792
		}
	}
	_, report := denseBiomeCanopy(q, p, g)
	if report.Zones[0].Samples+report.Zones[1].Samples != 0 || report.Zones[2].Samples+report.Zones[3].Samples == 0 {
		t.Fatal("fixture does not isolate vanished west forest")
	}
	if !strings.Contains(strings.Join(report.Failures, " "), "forest habitat west: eligible area 0 below") {
		t.Fatal("empty forest escaped area validation", report.Failures)
	}
	areas := biomeHabitatAreas(q, p, SceneLibrary{}, g)
	west := areas["west"].(map[string]any)["area_by_cause"].(map[string]int)
	if west["water"] == 0 || west["eligible"] != 0 {
		t.Fatal("loss cause not reported", west)
	}
}

func TestBiomeLandformPerfectDensityStillRejectsInsufficientArea(t *testing.T) {
	q, p, g := biomeLandformAreaFixture()
	for i := range g.Map.Terrain.Tiles {
		x := float64(i%65) / 64
		if x < .5 && (x < .285 || x > .315) {
			g.Map.Terrain.Tiles[i].GroundHeight = 7792
		}
	}
	_, report := denseBiomeCanopy(q, p, g)
	remaining := report.Zones[0].Samples + report.Zones[1].Samples
	if remaining == 0 || float64(remaining*4096) >= q.Landforms.Habitats[0].MinimumArea {
		t.Fatal("fixture does not retain a small dense forest", remaining)
	}
	for _, z := range report.Zones {
		if z.Samples > 0 && z.Fraction != 1 {
			t.Fatal("canopy must be perfect for this test", z)
		}
	}
	if len(report.Failures) != 1 || !strings.Contains(report.Failures[0], "forest habitat west: eligible area") {
		t.Fatal("density hid missing area", report.Failures)
	}
	// Historical recipes have no area contract and retain their old result.
	legacy := q
	legacy.Realizer = "ellipses-cohorts-v2"
	legacy.Landforms = nil
	_, old := denseBiomeCanopy(legacy, p, g)
	if len(old.Failures) > 0 {
		t.Fatal("legacy behavior changed", old.Failures)
	}
}
