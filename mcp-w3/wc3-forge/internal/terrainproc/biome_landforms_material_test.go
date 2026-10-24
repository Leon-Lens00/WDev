package terrainproc

import (
	"encoding/json"
	"os"
	"reflect"
	"slices"
	"strings"
	"testing"

	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

func quotaFixture() (*Map, MaterialProfile, []MaterialFeature, [][]int, [][]int, []int, []bool, []int, [][]int) {
	p := MaterialProfile{Palette: []string{"Adrt", "Adrd", "Agrs", "Arck", "Agrd", "Avin", "Adrg", "Alvd"}, TVLimit: .2}
	p.Counts = profileMatrix(p)
	p.Counts[3] = []int{4, 1, 15, 17, 26, 0, 1, 11}
	p.Features = make([]MaterialFeature, 8)
	pools := make([][]int, 8)
	for tex := 0; tex < 8; tex++ {
		s := MaterialSample{Index: tex, Context: 3, Texture: tex, Variation: tex % 4, Split: "train", Patch5: make([]int, 25), Context5: make([]int, 25)}
		for k := range s.Patch5 {
			s.Patch5[k] = tex
			s.Context5[k] = 3
		}
		p.Samples = append(p.Samples, s)
		if p.Counts[3][tex] > 0 {
			pools[3] = append(pools[3], tex)
		}
	}
	counts := profileMatrix(p)
	counts[3] = []int{2, 0, 26, 7, 26, 0, 1, 6}
	before := profileMatrix(p)
	before[3] = []int{2, 1, 13, 16, 21, 0, 1, 14}
	m := &Map{Terrain: &w3e.File{Width: 9, Height: 8, GroundTilesets: p.Palette, Tiles: make([]w3e.Tilepoint, 72)}}
	features := make([]MaterialFeature, 72)
	mutable := make([]bool, 72)
	assign := make([]int, 72)
	sizes := make([]int, 8)
	sizes[3] = 68
	vertex := 0
	for tex, n := range counts[3] {
		for k := 0; k < n; k++ {
			m.Terrain.Tiles[vertex] = w3e.Tilepoint{GroundHeight: 8192 + int16(vertex), WaterLevel: 8192, Flags: 4, LayerHeight: 2, CliffTexture: 15, GroundTexture: uint8(tex), TextureDetails: 32}
			features[vertex].Context = 3
			mutable[vertex] = true
			assign[vertex] = tex
			vertex++
		}
	}
	for i := vertex; i < len(assign); i++ {
		assign[i] = -1
		m.Terrain.Tiles[i].Boundary = true
	}
	return m, p, features, before, counts, sizes, mutable, assign, pools
}

func TestLandformMaterialQuotaMinimalAndPhysicalInvariant(t *testing.T) {
	m, p, f, b, c, n, mutable, assign, pools := quotaFixture()
	original := slices.Clone(m.Terrain.Tiles)
	changes, e := refineMaterialContexts(m, p, f, b, c, n, mutable, assign, pools)
	if e != nil {
		t.Fatal(e)
	}
	// The actual pilot's .21941 TV deficit needs exactly two one-vertex moves.
	if len(changes) != 2 {
		t.Fatalf("wanted two minimal changes, got %d", len(changes))
	}
	if materialContextFails(p, p.Counts[3], b[3], c[3]) {
		t.Fatal("unchanged calibrated gate still rejects")
	}
	for i, a := range original {
		got := m.Terrain.Tiles[i]
		if !materialPhysicalEqual(a, got) {
			t.Fatalf("physical mutation %d", i)
		}
		if !mutable[i] && a != got {
			t.Fatalf("protected mutation %d", i)
		}
	}
	m2, p2, f2, b2, c2, n2, mu2, a2, po2 := quotaFixture()
	again, e := refineMaterialContexts(m2, p2, f2, b2, c2, n2, mu2, a2, po2)
	if e != nil || !reflect.DeepEqual(changes, again) || !reflect.DeepEqual(m.Terrain.Tiles, m2.Terrain.Tiles) {
		t.Fatal("repair is not deterministic", e)
	}
}

func TestLandformMaterialQuotaLeavesAcceptedContextUntouched(t *testing.T) {
	m, p, f, b, c, n, mutable, assign, pools := quotaFixture()
	c[3] = slices.Clone(b[3])
	before := slices.Clone(m.Terrain.Tiles)
	changes, e := refineMaterialContexts(m, p, f, b, c, n, mutable, assign, pools)
	if e != nil || len(changes) != 0 || !reflect.DeepEqual(before, m.Terrain.Tiles) {
		t.Fatal("already accepted context changed", e)
	}
}

func TestLandformMaterialQuotaExplicitAndBounded(t *testing.T) {
	_, e := PaintMaterials(nil, nil, MaterialOptions{ContextualFix: "silently-unknown"})
	if e == nil || !strings.Contains(e.Error(), "unknown contextual") {
		t.Fatal("unknown option accepted", e)
	}
	legacy, _ := json.Marshal(MaterialResult{Format: "wc3-material-result-v1"})
	if strings.Contains(string(legacy), "contextual_refinements") {
		t.Fatal("legacy JSON gained an empty field")
	}
	m, p, f, b, c, n, mutable, assign, pools := quotaFixture()
	p.TVLimit = .001
	_, e = refineMaterialContexts(m, p, f, b, c, n, mutable, assign, pools)
	if e == nil {
		t.Fatal("impossible integer quota silently accepted")
	}
	m, p, f, b, c, n, mutable, assign, pools = quotaFixture()
	p.Counts[3] = []int{0, 0, 0, 0, 75, 0, 0, 0}
	c[3] = []int{0, 0, 68, 0, 0, 0, 0, 0}
	for i, ok := range mutable {
		if ok {
			m.Terrain.Tiles[i].GroundTexture = 2
			assign[i] = 2
		}
	}
	changes, e := refineMaterialContexts(m, p, f, b, c, n, mutable, assign, pools)
	if e == nil || !strings.Contains(e.Error(), "budget exhausted") || len(changes) != 17 {
		t.Fatalf("25%% budget was not enforced: changes=%d err=%v", len(changes), e)
	}
}

// Optional real map fixture for the task integration run. The root runs this
// explicitly with WC3_LANDFORM_MATERIAL_REQUEST, after serial MPQ coordination.
func TestLandformMaterialPilotFixture(t *testing.T) {
	path := os.Getenv("WC3_LANDFORM_MATERIAL_REQUEST")
	if path == "" {
		t.Skip("set WC3_LANDFORM_MATERIAL_REQUEST for real-map integration")
	}
	q, m, l, e := readMaterialRepaint(path)
	if e != nil {
		t.Fatal(e)
	}
	original := slices.Clone(m.Terrain.Tiles)
	q.Materials.ContextualFix = ""
	legacy, e := PaintMaterials(m, l.Masks, q.Materials)
	if e == nil || !strings.Contains(e.Error(), "rock-isolated") {
		t.Fatal("expected frozen pilot legacy failure", e)
	}
	for _, c := range legacy.Contexts {
		if c.Name == "rock-isolated" && (c.OutputCount != 68 || c.AfterTV < .2194 || c.AfterTV > .2195) {
			t.Fatalf("fixture differs: %+v", c)
		}
	}
	m.Terrain.Tiles = slices.Clone(original)
	q.Materials.ContextualFix = "context-quota-v1"
	result, e := PaintMaterials(m, l.Masks, q.Materials)
	if e != nil {
		t.Fatal(e)
	}
	if len(result.ContextualRefinements) != 2 {
		t.Fatalf("expected two repairs, got %d", len(result.ContextualRefinements))
	}
	for _, c := range result.Contexts {
		if c.Name == "rock-isolated" {
			t.Logf("rock-isolated source=%d output=%d TV %.12f -> %.12f after=%v; repairs=%v", c.SourceCount, c.OutputCount, legacy.Contexts[2].AfterTV, c.AfterTV, c.After, result.ContextualRefinements)
		}
	}
	for i, a := range original {
		if !materialPhysicalEqual(a, m.Terrain.Tiles[i]) {
			t.Fatalf("physical mutation at %d", i)
		}
	}
}
