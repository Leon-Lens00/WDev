package terrainproc

import (
	"encoding/json"
	"math"
	"reflect"
	"slices"
	"strings"
	"testing"

	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wpm"
)

func landformTestPlan() LandformPlan {
	return LandformPlan{Format: "wc3-landform-plan-v1", Geometry: MaterialGeometry{65, 33, [2]float32{-4096, 1280}}, WaterLevel: 64, WaterOffset: 17.5, BaseHeight: -128, Budget: DefaultLandformBudget(), Features: []LandformFeature{
		{ID: "island", Kind: "land", Points: [][2]float64{{.06, .08}, {.9, .08}, {.94, .85}, {.72, .94}, {.12, .92}}, Height: 192, Transition: 256},
		{ID: "lake", Kind: "lake", Points: [][2]float64{{.4, .35}, {.6, .33}, {.66, .51}, {.57, .69}, {.42, .65}}, Depth: 128, Transition: 160},
		{ID: "trail", Kind: "route", Points: [][2]float64{{.22, .22}, {.78, .22}}, Width: 448, Height: 170, Transition: 128},
	}, Relations: []LandformRelation{
		{ID: "closed-lake", Kind: "isolated", Feature: "lake", From: [2]float64{.5, .5}, Margin: 64, MinDepth: 32, MinArea: 100000},
		{ID: "dry-trail", Kind: "access", Feature: "trail", From: [2]float64{.25, .22}, To: [2]float64{.75, .22}, Width: 64},
	}}
}
func landformClonePlan(p LandformPlan) LandformPlan {
	raw, _ := json.Marshal(p)
	var q LandformPlan
	_ = json.Unmarshal(raw, &q)
	return q
}
func landformTestMap(t *testing.T, p LandformPlan, supports []LandformSupport) (*Map, LandformSurface) {
	t.Helper()
	r, e := RealizeLandforms(p, 9341, supports)
	if e != nil {
		t.Fatal(e)
	}
	m := &Map{Terrain: &w3e.File{Width: uint32(p.Geometry.Width), Height: uint32(p.Geometry.Height), CenterOffset: p.Geometry.Origin, Tiles: make([]w3e.Tilepoint, len(r.Heights))}, Pathing: &wpm.File{Width: (p.Geometry.Width - 1) * 4, Height: (p.Geometry.Height - 1) * 4}}
	m.Pathing.Cells = make([]byte, m.Pathing.Width*m.Pathing.Height)
	for i, z := range r.Heights {
		m.Terrain.Tiles[i] = w3e.Tilepoint{GroundHeight: int16(math.Round(z*4 + 8192)), LayerHeight: 2, WaterLevel: uint16(math.Round((p.WaterLevel-p.WaterOffset)*4 + 8192)), Flags: 4}
	}
	return m, r
}

func TestLandformContractsRejectAmbiguousInput(t *testing.T) {
	base := landformTestPlan()
	for name, mutate := range map[string]func(*LandformPlan){
		"nonfinite":         func(p *LandformPlan) { p.Features[0].Height = math.NaN() },
		"crossed-contour":   func(p *LandformPlan) { p.Features[0].Points = [][2]float64{{.1, .1}, {.9, .9}, {.9, .1}, {.1, .9}} },
		"closed-duplicate":  func(p *LandformPlan) { p.Features[0].Points = append(p.Features[0].Points, p.Features[0].Points[0]) },
		"out-of-bounds":     func(p *LandformPlan) { p.Features[0].Points[0][0] = -0.1 },
		"invalid-geometry":  func(p *LandformPlan) { p.Geometry.Width = 64 },
		"budget":            func(p *LandformPlan) { p.Budget.MaxFeatures = 1 },
		"water-overflow":    func(p *LandformPlan) { p.WaterLevel = 10000 },
		"unknown-reference": func(p *LandformPlan) { p.Relations[0].Feature = "missing" },
		"polygon-axis-sections": func(p *LandformPlan) {
			p.Features[0].Sections = []LandformSection{{At: 0, Width: 128}, {At: 1, Width: 128}}
		},
		"empty-section-end": func(p *LandformPlan) {
			p.Features[2].Sections = []LandformSection{{At: 0, Width: 128}, {At: .8, Width: 128}}
		},
		"degenerate-axis": func(p *LandformPlan) { p.Features[2].Points = [][2]float64{{.2, .2}, {.3, .2}, {.25, .2}} },
	} {
		t.Run(name, func(t *testing.T) {
			p := landformClonePlan(base)
			mutate(&p)
			if ValidateLandformPlan(p) == nil {
				t.Fatal("invalid contract accepted")
			}
		})
	}
	if e := ValidateLandformPlan(base); e != nil {
		t.Fatal(e)
	}
}

func TestLandformRepeatabilityOrderAndResolvedProvenance(t *testing.T) {
	p := landformTestPlan()
	p.Features[0].Jitter = 64
	p.Features[2].Curve = true
	p.Features[2].Points = [][2]float64{{.2, .22}, {.4, .24}, {.55, .2}, {.8, .22}}
	a, e := RealizeLandforms(p, 123, nil)
	if e != nil {
		t.Fatal(e)
	}
	b, e := RealizeLandforms(p, 123, nil)
	if e != nil {
		t.Fatal(e)
	}
	if !reflect.DeepEqual(a, b) {
		t.Fatal("same seed differs")
	}
	q := landformClonePlan(p)
	slices.Reverse(q.Features)
	c, e := RealizeLandforms(q, 123, nil)
	if e != nil {
		t.Fatal(e)
	}
	if !reflect.DeepEqual(a, c) {
		t.Fatal("input list order changes stable ID realization")
	}
	rp, e := ResolveLandformPlan(p, 123)
	if e != nil || !reflect.DeepEqual(a.Plan, rp) {
		t.Fatal("resolved provenance mismatch", e)
	}
	d, e := RealizeLandforms(p, 124, nil)
	if e != nil {
		t.Fatal(e)
	}
	if reflect.DeepEqual(a.Heights, d.Heights) {
		t.Fatal("jitter seed had no physical effect")
	}
	for _, f := range a.Plan.Features {
		if f.Curve || f.Jitter != 0 {
			t.Fatal("unresolved feature")
		}
	}
	if p.Features[0].Jitter != 64 || len(p.Features[2].Points) != 4 {
		t.Fatal("mutated input recipe")
	}
}

func TestLandformActualEncodedLakeWaterAndAccess(t *testing.T) {
	p := landformTestPlan()
	m, r := landformTestMap(t, p, nil)
	report, e := InspectLandforms(m, r.Plan, nil)
	if e != nil {
		t.Fatal(e)
	}
	if !report.Passed || report.WetCells == 0 || len(report.Relations) != 2 || !report.Relations[0].Passed || !report.Relations[1].Passed {
		t.Fatal("incomplete physical inspection")
	}
	pt := landformWorld(p.Geometry, [2]float64{.5, .5})
	water, ok := LandformWaterSurfaceAt(m.Terrain, p.WaterOffset, pt[0], pt[1])
	if !ok || water != 64 {
		t.Fatalf("offset/cota confused: %v %v", water, ok)
	}
	last := landformXY(p.Geometry, len(m.Terrain.Tiles)-1)
	got, ok := LandformGroundAt(m.Terrain, last[0], last[1])
	if !ok || got != float64(m.Terrain.Tiles[len(m.Terrain.Tiles)-1].FinalZ()) {
		t.Fatal("final boundary vertex not sampled")
	}
}

func TestLandformIndependentInspectorRejectsCorruptions(t *testing.T) {
	p := landformTestPlan()
	for name, mutate := range map[string]func(*Map){
		"dry-lake-with-water-flags": func(m *Map) {
			for i := range m.Terrain.Tiles {
				m.Terrain.Tiles[i].GroundHeight = int16((p.WaterLevel+200)*4 + 8192)
			}
		},
		"missing-water-flags": func(m *Map) {
			for i := range m.Terrain.Tiles {
				m.Terrain.Tiles[i].Flags &^= 4
			}
		},
		"wrong-water-plane": func(m *Map) { m.Terrain.Tiles[200].WaterLevel += 32 },
		"shallow-lake-leak": func(m *Map) {
			w := p.Geometry.Width
			for y := 15; y <= 17; y++ {
				for x := 0; x <= w/2; x++ {
					m.Terrain.Tiles[x+y*w].GroundHeight = int16((p.WaterLevel-2)*4 + 8192)
				}
			}
		},
		"pathing-wall": func(m *Map) {
			for y := 0; y < m.Pathing.Height; y++ {
				m.Pathing.Cells[m.Pathing.Width/2+y*m.Pathing.Width] |= 2
			}
		},
		"missing-pathing": func(m *Map) { m.Pathing = nil },
	} {
		t.Run(name, func(t *testing.T) {
			m, r := landformTestMap(t, p, nil)
			mutate(m)
			report, e := InspectLandforms(m, r.Plan, nil)
			if e == nil || report.Passed {
				t.Fatal("physical corruption accepted")
			}
		})
	}
}

func TestLandformChannelSectionsAndPhysicalCut(t *testing.T) {
	p := landformTestPlan()
	p.Features = p.Features[:1]
	p.Features = append(p.Features, LandformFeature{ID: "river", Kind: "channel", Points: [][2]float64{{.12, .5}, {.38, .55}, {.64, .44}, {.87, .5}}, Width: 384, Depth: 100, Transition: 192, Curve: true, Sections: []LandformSection{{At: 0, Width: 384, Depth: 90, LeftBank: 128, RightBank: 384}, {At: .5, Width: 640, Depth: 160, LeftBank: 384, RightBank: 128}, {At: 1, Width: 448, Depth: 110, LeftBank: 192, RightBank: 512}}})
	p.Relations = []LandformRelation{{ID: "river-joined", Kind: "connect", Feature: "river", From: [2]float64{.16, .51}, To: [2]float64{.84, .49}, Width: 64, MinDepth: 1, Margin: 64}}
	m, r := landformTestMap(t, p, nil)
	if _, e := InspectLandforms(m, r.Plan, nil); e != nil {
		t.Fatal(e)
	}
	for i := range m.Terrain.Tiles {
		if i%p.Geometry.Width == p.Geometry.Width/2 {
			m.Terrain.Tiles[i].GroundHeight = int16((p.WaterLevel+200)*4 + 8192)
		}
	}
	report, e := InspectLandforms(m, r.Plan, nil)
	if e == nil || !strings.Contains(strings.Join(report.Failures, " "), "disconnected") {
		t.Fatal("channel cut accepted", e)
	}
	c := compileLandform(p.Geometry, p.Features[1])
	a := landformSection(c.Feature, .25)
	b := landformSection(c.Feature, .75)
	if a.Width != 512 || a.LeftBank != 256 || b.Width != 544 || b.RightBank != 320 {
		t.Fatal("section interpolation", a, b)
	}
}

func TestLandformSupportsPreservedAndConflictsRejected(t *testing.T) {
	p := landformTestPlan()
	idx := 32 + 16*p.Geometry.Width
	supports := []LandformSupport{{ID: "wet-shore", Vertices: []LandformVertex{{idx, 20}}, Blend: 384, Tolerance: .125}}
	p.Relations = append(p.Relations, LandformRelation{ID: "source-support", Kind: "support", Support: "wet-shore"})
	m, r := landformTestMap(t, p, supports)
	if r.Heights[idx] != 20 || r.Masks[idx] != "rigid" {
		t.Fatal("wet authored support lost")
	}
	if _, e := InspectLandforms(m, r.Plan, supports); e != nil {
		t.Fatal(e)
	}
	m.Terrain.Tiles[idx].GroundHeight += 8
	if _, e := InspectLandforms(m, r.Plan, supports); e == nil {
		t.Fatal("support movement accepted")
	}
	conflict := append(supports, LandformSupport{ID: "collision", Vertices: []LandformVertex{{idx, 200}}, Blend: 128})
	if _, e := RealizeLandforms(p, 3, conflict); e == nil {
		t.Fatal("incompatible source supports accepted")
	}
	supports[0].Vertices[0].Height = 200
	m, r = landformTestMap(t, p, supports)
	if _, e := InspectLandforms(m, r.Plan, supports); e == nil {
		t.Fatal("dry support hiding declared lake port accepted")
	}
}

func TestLandformRectangularDimensionsBudgetAndOrigin(t *testing.T) {
	for _, geometry := range []MaterialGeometry{{129, 129, [2]float32{-7680, -8704}}, {161, 97, [2]float32{-11008, -5120}}, {193, 97, [2]float32{-12288, -4096}}} {
		p := landformTestPlan()
		p.Geometry = geometry
		m, r := landformTestMap(t, p, nil)
		if _, e := InspectLandforms(m, r.Plan, nil); e != nil {
			t.Fatal(geometry, e)
		}
		bad := r.Plan
		bad.Budget.MaxSamples = 1024
		if _, e := InspectLandforms(m, bad, nil); e == nil {
			t.Fatal("inspection budget ignored")
		}
		bad = r.Plan
		bad.Geometry.Origin[0] += 128
		if _, e := InspectLandforms(m, bad, nil); e == nil {
			t.Fatal("wrong origin accepted")
		}
	}
}

func TestLandformSubgridChannelRejectedAfterQuantization(t *testing.T) {
	p := landformTestPlan()
	p.Features = p.Features[:1]
	// Its bed and bank fall between the two neighboring 128-unit vertex rows.
	// The continuous curve is valid, but no wet channel survives export.
	y := (16.*128 + 64) / (float64(p.Geometry.Height-1) * 128)
	p.Features = append(p.Features, LandformFeature{ID: "subgrid", Kind: "channel", Points: [][2]float64{{.3, y}, {.7, y}}, Width: 64, Depth: 64, Transition: 32})
	p.Relations = []LandformRelation{{ID: "subgrid-connection", Kind: "connect", Feature: "subgrid", From: [2]float64{.35, y}, To: [2]float64{.65, y}, Width: 32}}
	m, r := landformTestMap(t, p, nil)
	inspection, e := InspectLandforms(m, r.Plan, nil)
	if e == nil || inspection.Passed {
		t.Fatal("subgrid connection certified from its mathematical curve")
	}
}

func TestLandformIndependentPhysicalStreamsAndDisabledFinish(t *testing.T) {
	p := landformTestPlan()
	p.Features[0].Jitter = 32
	p.Features[1].Jitter = 32
	p.Features = append(p.Features,
		LandformFeature{ID: "crest", Kind: "ridge", Points: [][2]float64{{.2, .8}, {.45, .82}, {.7, .8}}, Height: 300, Width: 256, Transition: 256, Jitter: 32},
		LandformFeature{ID: "depression", Kind: "valley", Points: [][2]float64{{.2, .3}, {.22, .5}, {.24, .7}}, Height: 130, Width: 128, Transition: 128, Jitter: 32},
		LandformFeature{ID: "flow", Kind: "channel", Points: [][2]float64{{.8, .3}, {.82, .5}, {.8, .7}}, Depth: 96, Width: 192, Transition: 128, Jitter: 32},
	)
	a, e := RealizeLandforms(p, 731, nil)
	if e != nil {
		t.Fatal(e)
	}
	if len(a.Plan.Streams) != 4 || a.Plan.Finish != "off" {
		t.Fatal("unresolved streams/finish", a.Plan.Streams, a.Plan.Finish)
	}
	byID := func(plan LandformPlan) map[string]LandformFeature {
		result := map[string]LandformFeature{}
		for _, f := range plan.Features {
			result[f.ID] = f
		}
		return result
	}
	base := byID(a.Plan)
	for _, stream := range []string{"forms", "relief", "water", "finish"} {
		t.Run(stream, func(t *testing.T) {
			q := landformClonePlan(p)
			q.Streams = map[string]int{stream: a.Plan.Streams[stream] + 1}
			b, e := RealizeLandforms(q, 731, nil)
			if e != nil {
				t.Fatal(e)
			}
			changed := 0
			for id, f := range byID(b.Plan) {
				category := "forms"
				switch f.Kind {
				case "ridge", "valley":
					category = "relief"
				case "lake", "channel":
					category = "water"
				case "route":
					category = "fixed"
				}
				same := reflect.DeepEqual(f.Points, base[id].Points)
				if category == stream {
					if same {
						t.Fatalf("stream %s did not affect %s", stream, id)
					}
					changed++
				} else if !same {
					t.Fatalf("stream %s leaked into %s", stream, id)
				}
			}
			if stream == "finish" {
				if changed != 0 || !reflect.DeepEqual(a.Heights, b.Heights) || !reflect.DeepEqual(a.Masks, b.Masks) || !reflect.DeepEqual(a.Ownership, b.Ownership) {
					t.Fatal("disabled finish changed physical output")
				}
			} else if changed == 0 || reflect.DeepEqual(a.Heights, b.Heights) {
				t.Fatal("vacuous physical stream")
			}
		})
	}
	q := landformClonePlan(p)
	q.Streams = map[string]int{"unexpected": 1}
	if ValidateLandformPlan(q) == nil {
		t.Fatal("unknown stream accepted")
	}
	q = landformClonePlan(p)
	q.Streams = map[string]int{"water": -1}
	if ValidateLandformPlan(q) == nil {
		t.Fatal("negative stream accepted")
	}
	q = landformClonePlan(p)
	q.Finish = "erosion"
	if ValidateLandformPlan(q) == nil {
		t.Fatal("unimplemented finish accepted")
	}
	q = landformClonePlan(p)
	q.Features[2].Jitter = 1
	if ValidateLandformPlan(q) == nil {
		t.Fatal("reserved route jitter accepted")
	}
}
