package terrainproc

import (
	"encoding/json"
	"slices"
	"strings"
	"testing"
)

func biomeNativeLandformFixture(t *testing.T) (BiomeRecipe, *Map, *Map, MaterialProfile) {
	t.Helper()
	plan := landformTestPlan()
	q := BiomeRecipe{Geometry: plan.Geometry, WaterLevel: plan.WaterLevel, Seeds: []int{9341}, Streams: map[string]int{"landform-physical-v1": 9341}, Landforms: &BiomeLandforms{
		Plan: BiomeReference{SHA: strings.Repeat("a", 64)}, Profile: BiomeReference{SHA: strings.Repeat("b", 64)}, physical: plan,
	}}
	generated, surface := landformTestMap(t, plan, nil)
	generated.Hash = "generated-map-identity"
	record := BiomeLandformRecord{Format: "wc3-biome-landforms-v1", Seed: 9341, PhysicalSeed: 9341, PlanSHA: q.Landforms.Plan.SHA, ProfileSHA: q.Landforms.Profile.SHA, Plan: surface.Plan}
	raw, e := json.Marshal(record)
	if e != nil {
		t.Fatal(e)
	}
	generated.Files = map[string][]byte{biomeLandformMember: raw}
	native, _ := landformTestMap(t, plan, nil)
	native.Hash = "native-map-identity"
	native.Files = map[string][]byte{}
	return q, generated, native, MaterialProfile{WaterOffset: plan.WaterOffset}
}

func TestBiomeNativeLandformsAllowMissingNativeRecordOnly(t *testing.T) {
	q, generated, native, mat := biomeNativeLandformFixture(t)
	before := slices.Clone(native.Terrain.Tiles)
	inspection, e := inspectBiomeNativeLandforms(q, SceneLibrary{}, &Map{}, mat, generated, native)
	if e != nil || !inspection.Passed {
		t.Fatal("native terrain without custom metadata must pass", e)
	}
	if inspection.MapSHA != native.Hash || inspection.Provenance.NativeMapSHA != native.Hash || inspection.Provenance.GeneratedMapSHA != generated.Hash || !inspection.Provenance.GeneratedRecordVerified || inspection.Provenance.NativeRecordRetained || inspection.Provenance.RecordSHA != Hash(generated.Files[biomeLandformMember]) {
		t.Fatal("ambiguous native audit provenance", inspection.Provenance)
	}
	if _, exists := native.Files[biomeLandformMember]; exists || !slices.Equal(before, native.Terrain.Tiles) {
		t.Fatal("read-only audit modified native map")
	}
	if !biomeEditorLandformRemoval(q, generated, native, biomeLandformMember) || biomeEditorLandformRemoval(q, generated, native, "war3map.doo") {
		t.Fatal("native removal exception has wrong scope")
	}
	// Standalone generated-map validation remains strict even though the native
	// audit can use a separately verified archive as its provenance source.
	if _, e := inspectBiomeLandforms(q, SceneLibrary{}, &Map{}, mat, native); e == nil {
		t.Fatal("standalone physical validation accepted absent provenance")
	}
	native.Files[biomeLandformMember] = slices.Clone(generated.Files[biomeLandformMember])
	inspection, e = inspectBiomeNativeLandforms(q, SceneLibrary{}, &Map{}, mat, generated, native)
	if e != nil || !inspection.Provenance.NativeRecordRetained || biomeEditorLandformRemoval(q, generated, native, biomeLandformMember) {
		t.Fatal("identical retained record mishandled", e)
	}
}

func TestBiomeNativeLandformsRejectCorruptionWithExternalRecord(t *testing.T) {
	for _, kind := range []string{"native-water", "native-pathing", "native-lake-ground", "native-support", "generated-record", "generated-water", "native-record"} {
		t.Run(kind, func(t *testing.T) {
			q, generated, native, mat := biomeNativeLandformFixture(t)
			library, donor := SceneLibrary{}, &Map{}
			switch kind {
			case "native-water":
				native.Terrain.Tiles[0].WaterLevel += 32
			case "native-pathing":
				for i := range native.Pathing.Cells {
					native.Pathing.Cells[i] |= 2
				}
			case "native-lake-ground":
				for i := range native.Terrain.Tiles {
					native.Terrain.Tiles[i].GroundHeight = 8992
				}
			case "native-support":
				donor, _ = landformTestMap(t, q.Landforms.physical, nil)
				x, y := float64(q.Geometry.Origin[0]), float64(q.Geometry.Origin[1])
				library.Components = []SceneComponent{{PrefabSpec: PrefabSpec{ID: "pad", Source: Rect{Min: [2]float64{x + 12*128, y + 20*128}, Max: [2]float64{x + 14*128, y + 22*128}}, Blend: 128}}}
				q.Scenes = []BiomeInstance{{ID: "protected-pad", Component: "pad", Center: [2]float64{.25, .75}, Height: 192}}
				supports := biomeLandformSupports(q, library, donor, mat)
				withSupport, _ := landformTestMap(t, q.Landforms.physical, supports)
				generated.Terrain = withSupport.Terrain
				withSupport, _ = landformTestMap(t, q.Landforms.physical, supports)
				native.Terrain = withSupport.Terrain
				if _, e := inspectBiomeNativeLandforms(q, library, donor, mat, generated, native); e != nil {
					t.Fatal("valid protected support fixture", e)
				}
				native.Terrain.Tiles[supports[0].Vertices[0].Index].GroundHeight += 8
			case "generated-record":
				var record BiomeLandformRecord
				if e := json.Unmarshal(generated.Files[biomeLandformMember], &record); e != nil {
					t.Fatal(e)
				}
				record.PhysicalSeed++
				generated.Files[biomeLandformMember], _ = json.Marshal(record)
			case "generated-water":
				generated.Terrain.Tiles[0].WaterLevel += 32
			case "native-record":
				native.Files[biomeLandformMember] = []byte("{}")
			}
			if _, e := inspectBiomeNativeLandforms(q, library, donor, mat, generated, native); e == nil {
				t.Fatal("corruption hidden by external provenance", kind)
			}
		})
	}
}
