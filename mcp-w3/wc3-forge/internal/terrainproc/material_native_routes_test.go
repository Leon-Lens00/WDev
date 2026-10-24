package terrainproc

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wpm"
	"testing"
)

// A recalculated local obstacle may move an inter-scene trace inside its already
// reserved lane. A detour outside that lane, or through a rigid core, must fail.
func TestNativeAccessUsesExistingReserve(t *testing.T) {
	const w, h = 60, 40
	g := &Scene{Map: &Map{Doodads: &doodadsdoo.File{}, Pathing: &wpm.File{Width: w, Height: h}}, Spec: Spec{Edit: Rect{Min: [2]float64{0, 0}, Max: [2]float64{w * 32, h * 32}}, CollisionRadius: 32, Landscape: &LandscapeOptions{Brief: LandscapeBrief{Relations: []LandscapeRelation{{ID: "link", Kind: "access"}}}}}}
	r := Route{ID: "link", Points: [][2]float64{{8*32 + 16, 20*32 + 16}, {50*32 + 16, 20*32 + 16}}}
	for x := 8; x <= 50; x++ {
		r.Trace = append(r.Trace, [2]float64{float64(x*32 + 16), 20*32 + 16})
	}
	p := LandscapePlan{Layout: Layout{Routes: []Route{r}}}
	cells := make([]byte, w*h)
	for y := 16; y <= 24; y++ {
		cells[30+y*w] = 2
	}
	if _, e := nativeLandscapeRoutes(g, p, cells); e != nil {
		t.Fatalf("reserved access rejected: %v", e)
	}
	// The same obstacle cannot receive the access policy without a declared link.
	g.Spec.Landscape.Brief.Relations = nil
	if _, e := nativeLandscapeRoutes(g, p, cells); e == nil {
		t.Fatal("undeclared route received wider access policy")
	}
	g.Spec.Landscape.Brief.Relations = []LandscapeRelation{{ID: "link", Kind: "access"}}
	p.Placements = []Placement{{ID: "link"}}
	if _, e := nativeLandscapeRoutes(g, p, cells); e == nil {
		t.Fatal("rigid route received wider access policy")
	}
	p.Placements = nil
	for y := 12; y <= 28; y++ {
		cells[30+y*w] = 2
	}
	if _, e := nativeLandscapeRoutes(g, p, cells); e == nil {
		t.Fatal("accepted detour outside original reserved lane")
	}
	// A globally connected path is deliberately insufficient for that case.
	blocked := combinedRecompose(g, cells)
	if _, e := gridPath(g, blocked, pathCell(g, r.Points[0]), pathCell(g, r.Points[1]), g.Spec.Edit); e != nil {
		t.Fatal("test requires a globally possible but disallowed detour")
	}
}
