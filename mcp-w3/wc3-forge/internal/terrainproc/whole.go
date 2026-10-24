package terrainproc

import (
	"fmt"
	"math"
	"slices"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
)

// Whole-map restyle keeps the donor's archipelago and authored landmarks.
// WFC learns from every tile; it does not infer new islands or bridges from pixels.
func (g *Scene) whole() bool { return g.Spec.Mode == "whole-map-restyle" }

func (g *Scene) scatterAsset(id string) bool {
	return slices.Contains(g.Spec.Trees, id) || slices.Contains(g.Spec.Plants, id) || slices.Contains(g.Spec.Rocks, id)
}

func (g *Scene) replaceObject(d doodadsdoo.Doodad) bool {
	x, y := float64(d.Position[0]), float64(d.Position[1])
	if !g.Spec.Editable(x, y) {
		return false
	}
	if !g.whole() {
		return true
	}
	// Keep authored structures, water effects and shoreline plantings together
	// with their original support. The cascade is a composition, not loose scatter.
	return g.scatterAsset(d.TypeID) && !g.Spec.Waterfall.Source.Contains(x, y) && g.height(x, y, g.Original) > g.Water+55
}

func (g *Scene) prepareWhole() error {
	if !g.whole() {
		return nil
	}
	ox, oy := g.xy(0, 0)
	mx, my := g.xy(int(g.Map.Terrain.Width)-1, int(g.Map.Terrain.Height)-1)
	if g.Spec.Edit != (Rect{[2]float64{ox, oy}, [2]float64{mx, my}}) {
		return fmt.Errorf("whole-map restyle must cover the complete terrain bounds")
	}
	for _, d := range g.Map.Doodads.Doodads {
		if !g.replaceObject(d) {
			g.Anchors = append(g.Anchors, d)
		}
	}
	return nil
}

// Smoothly pin the surface around retained objects. This preserves their Z,
// offsets and composition instead of re-grounding water effects or bridges.
func (g *Scene) anchorWeight(x, y float64) float64 {
	r := g.Spec.Waterfall.Source
	d := math.Hypot(max(r.Min[0]-x, x-r.Max[0], 0.), max(r.Min[1]-y, y-r.Max[1], 0.))
	weight := smooth(d / g.Spec.Waterfall.Blend)
	for _, a := range g.Anchors {
		d = math.Hypot(x-float64(a.Position[0]), y-float64(a.Position[1]))
		weight = min(weight, smooth((d-192)/256))
		if weight == 0 {
			break
		}
	}
	return weight
}

func (g *Scene) anchorClearance(x, y float64) bool {
	for _, d := range g.Anchors {
		radius := 128.
		if a := g.Catalog.Assets[d.TypeID]; a != nil && a.Pathing != nil {
			radius += math.Hypot(float64(a.Pathing.Width), float64(a.Pathing.Height)) * 16
		}
		if math.Hypot(x-float64(d.Position[0]), y-float64(d.Position[1])) < radius {
			return false
		}
	}
	return true
}

func (g *Scene) wholeTerrain(states []int, w, h int) {
	for y := 0; y <= h; y++ {
		for x := 0; x <= w; x++ {
			wx, wy := g.xy(x, y)
			i := x + y*int(g.Map.Terrain.Width)
			t := g.Original[i]
			z := float64(t.FinalZ())
			// Sea floor, shoreline, boundary and composition supports remain coherent.
			if t.Boundary || z < g.Water+30 {
				continue
			}
			weight := g.anchorWeight(wx, wy)
			if weight == 0 {
				continue
			}
			edge := min(x, y, w-x, h-y)
			weight *= smooth(float64(edge)/3) * smooth((z-g.Water-30)/100)
			delta := (28*math.Sin(wx/830+float64(g.Spec.Seed%11))*math.Cos(wy/710) + 16*math.Sin((wx+wy)/460)) * weight
			t.GroundHeight += int16(math.Round(delta * 4))
			label := states[min(x, w-1)+min(y, h-1)*w]
			dist := g.Spec.PathDistance(wx, wy)
			tex := uint8(2)
			switch label {
			case 1, 3:
				tex = 8
			case 2:
				tex = 5
			}
			// Exposed rock follows the existing hills; beaches remain sandy.
			slope := math.Abs(g.height(wx+64, wy, g.Original)-z) + math.Abs(g.height(wx, wy+64, g.Original)-z)
			if slope > 75 && t.GroundTexture == 5 {
				tex = 5
			}
			if z < g.Water+95 || dist < g.Spec.PathWidth*.45 {
				tex = 3
			}
			if weight > .3 {
				t.GroundTexture = tex
				t.TextureDetails = (t.TextureDetails & 0xe0) | uint8(g.Rand.Intn(16))
			}
			g.Map.Terrain.Tiles[i] = t
		}
	}
}
