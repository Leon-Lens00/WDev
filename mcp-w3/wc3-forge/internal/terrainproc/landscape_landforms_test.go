package terrainproc

import (
	"math"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"testing"

	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

func tropicalLandformFixture() (*Scene, LandscapePlan, Library) {
	options := &LandscapeLandformOptions{Format: "wc3-landscape-landforms-v1", Strategy: "p-d-adaptable-v1", Streams: landscapeLandformStreams(52700), BodyTransition: 800, BodyWidthScale: 1, BodyHeightScale: 1, CoastJitter: 64, ChannelDepth: 96, LeftBank: 384, RightBank: 512, SupportBlend: 896, MaxCandidates: 8}
	terrain := &w3e.File{Width: 193, Height: 97, CenterOffset: [2]float32{-12288, -4096}, Tiles: make([]w3e.Tilepoint, 193*97)}
	for i := range terrain.Tiles {
		tile := w3e.Tilepoint{LayerHeight: 1, WaterLevel: 8192, Flags: 4, GroundTexture: 3, CliffTexture: 1}
		setGround(&tile, 110+float64(i%3)*8)
		terrain.Tiles[i] = tile
	}
	g := &Scene{Map: &Map{Terrain: terrain}, Original: slices.Clone(terrain.Tiles), Water: -89.6, Spec: Spec{Landscape: &LandscapeOptions{Landforms: options}}}
	p := LandscapePlan{Bodies: []LandBody{{ID: "land-main", Spine: [][2]float64{{-6000, 0}, {0, 1280}, {6500, 0}}, Width: 1850, Height: 160}}, Reaches: []LandscapeReach{{ID: "flow", Points: [][2]float64{{-5500, 2560}, {0, 2560}, {6000, 2560}}, Width: 384}}}
	return g, p, Library{}
}

func TestLandscapeLandformAdapterPreservesSourceSupport(t *testing.T) {
	g, p, lib := tropicalLandformFixture()
	from := Rect{Min: [2]float64{-256, -256}, Max: [2]float64{256, 256}}
	q := Placement{ID: "temple-1", Family: "temple", Center: [2]float64{2048, 0}, Offset: [2]float64{2048, 0}, Core: Rect{Min: [2]float64{1792, -256}, Max: [2]float64{2304, 256}}}
	p.Placements = []Placement{q}
	lib.Prefabs = []Prefab{{PrefabSpec: PrefabSpec{ID: "temple", Source: from}}}
	// A wet source tile has its own accredited surface. The adapter must retain
	// all native fields, rather than ground-snap a composition into the common sea.
	center := g.index(0, 0)
	g.Original[center].WaterLevel = 9216
	g.Original[center].TextureDetails = 11
	if err := landscapeLandformTerrain(g, &p, lib); err != nil {
		t.Fatal(err)
	}
	for y := -256.; y <= 256; y += 128 {
		for x := -256.; x <= 256; x += 128 {
			i, j := g.index(x, y), g.index(x+2048, y)
			if p.Masks[j] != "rigid" || g.Map.Terrain.Tiles[j] != g.Original[i] {
				t.Fatalf("source tile not preserved at %d", j)
			}
		}
	}
	for i, tile := range g.Map.Terrain.Tiles {
		if p.Masks[i] != "rigid" && math.Abs(float64(tile.WaterZ())+g.Water-(-89.6)) > .001 {
			t.Fatalf("adaptive water offset lost at %d", i)
		}
	}
	if p.Landforms == nil || p.Landforms.Plan.WaterLevel != -89.6 || p.Landforms.Plan.WaterOffset != -89.6 {
		t.Fatal("ambiguous absolute water/offset")
	}
}

func TestLandscapeLandformIndependentStreams(t *testing.T) {
	g, p, lib := tropicalLandformFixture()
	if err := landscapeLandformTerrain(g, &p, lib); err != nil {
		t.Fatal(err)
	}
	before := slices.Clone(g.Map.Terrain.Tiles)
	g.Spec.Landscape.Streams = map[string]int{"materials": 31, "vegetation": 32}
	g.Spec.Landscape.Materials = &MaterialOptions{Seed: 71}
	p2 := p
	if err := landscapeLandformTerrain(g, &p2, lib); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(before, g.Map.Terrain.Tiles) {
		t.Fatal("materials/vegetation affected physical terrain")
	}
	g.Spec.Landscape.Landforms.Streams["water"]++
	p3 := p
	if err := landscapeLandformTerrain(g, &p3, lib); err != nil {
		t.Fatal(err)
	}
	if reflect.DeepEqual(before, g.Map.Terrain.Tiles) {
		t.Fatal("water stream did not affect channel sections")
	}
	for _, f := range p3.Landforms.Plan.Features {
		if f.Kind == "channel" {
			for _, section := range f.Sections {
				if section.Width < 384 {
					t.Fatal("channel narrowed below historical acceptance")
				}
			}
		}
	}
}

func TestLandscapeLandformCurvesAdaptiveReachAndKeepsPorts(t *testing.T) {
	var points [][2]float64
	for x := -4096.; x <= 0; x += 128 {
		points = append(points, [2]float64{x, 2048})
	}
	for y := 1920.; y >= -2048; y -= 128 {
		points = append(points, [2]float64{0, y})
	}
	ports := []Placement{{ID: "source", Core: Rect{Min: [2]float64{-4352, 1792}, Max: [2]float64{-3584, 2304}}}, {ID: "sink", Core: Rect{Min: [2]float64{-256, -2304}, Max: [2]float64{256, -1536}}}}
	source := LandscapeReach{ID: "river", Points: points, Width: 384, OutletConnectionEnd: points[8]}
	got := landscapeNaturalReach(source, ports)
	if got.Points[0] != points[0] || got.Points[len(points)-1] != points[len(points)-1] || got.Width != source.Width {
		t.Fatal("native endpoints or minimum width changed")
	}
	for i, point := range points {
		for _, q := range ports {
			if rectDistance(q.Core, point[0], point[1]) <= source.Width && got.Points[i] != point {
				t.Fatalf("authored port axis moved at %d", i)
			}
		}
	}
	// A 90-degree routing corner must become a broad bend, not a tiny chamfer
	// that remains rectangular when the complete map is viewed from above.
	corner := got.Points[32]
	if dist(corner, points[32]) < 350 || corner[0] >= -200 || corner[1] >= 1848 {
		t.Fatalf("right-angle routing corner survived: %v", corner)
	}
	if landformSelfCrosses(got.Points, false) || !reflect.DeepEqual(source.Points, points) {
		t.Fatal("adaptive smoothing crossed itself or mutated the source graph")
	}
	for i := 1; i < len(got.Points)-1; i++ {
		a, b, c := got.Points[i-1], got.Points[i], got.Points[i+1]
		angle := math.Abs(math.Atan2(landformCross(a, b, c), (b[0]-a[0])*(c[0]-b[0])+(b[1]-a[1])*(c[1]-b[1])))
		if angle > math.Pi/9 {
			t.Fatalf("new abrupt channel bend %.1f degrees at %d", angle*180/math.Pi, i)
		}
	}
}

func TestLandscapeLandformCoastClearsBoundaryReservation(t *testing.T) {
	g, p, lib := tropicalLandformFixture()
	p.Bodies = []LandBody{{ID: "north-ridge", Spine: [][2]float64{{-5000, 6400}, {0, 6400}, {6000, 6400}}, Width: 1850, Height: 175}}
	p.Reaches = nil
	if err := landscapeLandformTerrain(g, &p, lib); err != nil {
		t.Fatal(err)
	}
	// The free coast reaches the sea before entering the 768-unit mandatory
	// border blend, rather than having that rectangle determine its outline.
	for x := -4096.; x <= 4096; x += 128 {
		if z := float64(g.Map.Terrain.Tiles[g.index(x, 6912)].FinalZ()); z >= g.Water {
			t.Fatalf("ridge still reaches border transition at x%.0f: %.2f", x, z)
		}
	}
}

func TestLandscapeLandformRejectsUnsupportedGeometry(t *testing.T) {
	g, p, lib := tropicalLandformFixture()
	g.Map.Terrain.Width = 129
	if _, err := compileLandscapeLandforms(g, p, lib); err == nil {
		t.Fatal("bounded P adapter accepted unsupported geometry")
	}
	g, p, lib = tropicalLandformFixture()
	p.Bodies[0].Spine[0] = [2]float64{-50000, 0}
	if _, err := compileLandscapeLandforms(g, p, lib); err == nil {
		t.Fatal("out of map body accepted")
	}
}

func TestLandscapeLandformRejectsMissingMaterials(t *testing.T) {
	g, _, _ := tropicalLandformFixture()
	g.Spec.Landscape.Brief.ID = "D"
	if err := validateLandscapeLandforms(g.Spec); err == nil {
		t.Fatal("new terrain accepted optional material fallback")
	}
	g.Spec.Landscape.Landforms = nil
	if err := validateLandscapeLandforms(g.Spec); err != nil {
		t.Fatal("historical recipe acquired new physical requirements")
	}
}

// These fixtures are required by the G release command, but kept opt-in for
// developers who do not possess the licensed Classic donor installation.
func TestLandscapeLandformRelocatedMaterialDonor(t *testing.T) {
	path := os.Getenv("WC3_LANDFORM_TROPICAL_SPEC")
	if path == "" {
		t.Skip("WC3_LANDFORM_TROPICAL_SPEC required for approved material relocation")
	}
	s, err := ReadSpec(path)
	if err != nil {
		t.Fatal(err)
	}
	if s.Landscape.Landforms == nil || s.Landscape.Materials == nil {
		t.Fatal("new tropical physical/material fixture required")
	}
	raw, err := os.ReadFile(s.Source)
	if err != nil {
		t.Fatal(err)
	}
	donor := filepath.Join(t.TempDir(), "relocated-donor.w3x")
	if err = os.WriteFile(donor, raw, 0644); err != nil {
		t.Fatal(err)
	}
	o := *s.Landscape.Materials
	o.SourceOverride = donor
	p, err := loadMaterialProfile(o)
	if err != nil {
		t.Fatal(err)
	}
	if p.Source != donor || p.SourceSHA != s.SourceHash {
		t.Fatal("relocated donor was not the verified source")
	}
	profile, err := os.ReadFile(o.Profile)
	if err != nil {
		t.Fatal(err)
	}
	if Hash(profile) != tropicalContextualProfileSHA {
		t.Fatal("immutable approved profile changed")
	}
	o.SourceOverride = filepath.Join(t.TempDir(), "missing-donor.w3x")
	if _, err = loadMaterialProfile(o); err == nil {
		t.Fatal("invalid override silently fell back to the original drive")
	}
}

func TestLandscapeLandformLegacyBytes(t *testing.T) {
	path, control := os.Getenv("WC3_LANDSCAPE_LEGACY_SPEC"), os.Getenv("WC3_LANDSCAPE_LEGACY_MAP")
	if path == "" || control == "" {
		t.Skip("WC3_LANDSCAPE_LEGACY_SPEC and WC3_LANDSCAPE_LEGACY_MAP required for exact P/B regression")
	}
	s, err := ReadSpec(path)
	if err != nil {
		t.Fatal(err)
	}
	if s.Landscape.Landforms != nil {
		t.Fatal("legacy regression fixture opted into new geography")
	}
	raw, err := os.ReadFile(control)
	if err != nil {
		t.Fatal(err)
	}
	const expected = "b7d630bc7a7d5c41868dc923b22a9f09a41ab9bfdb38a66d36c2aa9b86c6a66f"
	if Hash(raw) != expected {
		t.Fatal("legacy B/D control differs from frozen approved T output")
	}
	report, err := GenerateLandscape(s, t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	actual, err := os.ReadFile(report.Map)
	if err != nil {
		t.Fatal(err)
	}
	if Hash(actual) != expected {
		t.Fatalf("legacy P/B output changed: %s", Hash(actual))
	}
}
