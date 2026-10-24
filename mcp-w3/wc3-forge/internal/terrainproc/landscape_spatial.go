package terrainproc

import (
	"fmt"
	"math"
)

func landscapeSurface(g *Scene, x, y float64) float64 {
	i := g.index(x, y)
	if i < 0 || !g.Map.Terrain.Tiles[i].HasWater() {
		return math.Inf(-1)
	}
	return float64(g.Map.Terrain.Tiles[i].WaterZ()) + g.Water
}
func staticLandscapePathing(g *Scene) []byte {
	cells := staticRecomposePathing(g)
	// Preserve the proven static rules; replace the global sea assumption with
	// the effective local W3E water surface, including dry flags.
	for i := range cells {
		p := cellPoint(g, i)
		z := g.height(p[0], p[1], g.Map.Terrain.Tiles)
		surface := landscapeSurface(g, p[0], p[1])
		if surface == g.Water {
			continue
		}
		x, y := i%int(g.Map.Pathing.Width), i/int(g.Map.Pathing.Width)
		if x < 16 || y < 16 || x >= int(g.Map.Pathing.Width)-16 || y >= int(g.Map.Pathing.Height)-16 {
			continue
		}
		f := byte(64)
		if z < surface {
			f = 8
		}
		if z < surface-64 {
			f |= 2
		}
		for _, d := range [][2]float64{{32, 0}, {-32, 0}, {0, 32}, {0, -32}} {
			if math.Abs(z-g.height(p[0]+d[0], p[1]+d[1], g.Map.Terrain.Tiles)) > 25 {
				f |= 2 | 8
			}
		}
		cells[i] = f
	}
	return cells
}
func landscapeAccess(g *Scene, p *LandscapePlan, cells []byte) error {
	combined := combinedRecompose(g, cells)
	for _, r := range g.Spec.Landscape.Brief.Relations {
		if r.Kind != "access" {
			continue
		}
		from, to := landscapePlacement(*p, r.From), landscapePlacement(*p, r.To)
		a, b := from.Anchors[r.FromPort], to.Anchors[r.ToPort]
		ai, bi := nearestFree(g, combined, a, 256), nearestFree(g, combined, b, 256)
		if ai < 0 || bi < 0 {
			return fmt.Errorf("access ports blocked %s", r.ID)
		}
		path, err := gridPath(g, combined, ai, bi, expandRect(g.Spec.Edit, -512))
		if err != nil || len(path) == 0 {
			return fmt.Errorf("inter-scene access disconnected %s", r.ID)
		}
		route := Route{ID: r.ID, Points: [][2]float64{a, b}}
		for _, i := range path {
			route.Trace = append(route.Trace, cellPoint(g, i))
		}
		p.Routes = append(p.Routes, route)
	}
	return nil
}

// Native slope quantization may shift a walkable trace. Local structure routes
// retain their 128-unit tolerance. Inter-scene access uses the 256-unit reserve
// already established by landscapeHabitats before decoration, not an arbitrary
// whole-map detour. Collision inflation and the original ports remain unchanged.
func nativeLandscapeRouteRadius(g *Scene, p LandscapePlan, id string) int {
	if landscapePlacement(p, id).ID != "" || g.Spec.Landscape == nil {
		return 4
	}
	for _, relation := range g.Spec.Landscape.Brief.Relations {
		if relation.ID == id && relation.Kind == "access" {
			return 8
		}
	}
	return 4
}

func nativeLandscapeRoutes(g *Scene, p LandscapePlan, cells []byte) ([]Route, error) {
	combined := combinedRecompose(g, cells)
	w, h := int(g.Map.Pathing.Width), int(g.Map.Pathing.Height)
	var routes []Route
	for _, r := range p.Routes {
		radius := nativeLandscapeRouteRadius(g, p, r.ID)
		corridor := make([]bool, len(cells))
		for _, xy := range r.Trace {
			i := pathCell(g, xy)
			if i < 0 {
				continue
			}
			for dy := -radius; dy <= radius; dy++ {
				for dx := -radius; dx <= radius; dx++ {
					x, y := i%w+dx, i/w+dy
					if x >= 0 && x < w && y >= 0 && y < h && dx*dx+dy*dy <= radius*radius {
						corridor[y*w+x] = true
					}
				}
			}
		}
		blocked := make([]bool, len(cells))
		for i := range blocked {
			blocked[i] = combined[i] || !corridor[i]
		}
		actual := Route{ID: r.ID, Points: r.Points}
		for n := 1; n < len(r.Points); n++ {
			a, b := nearestFree(g, blocked, r.Points[n-1], 96), nearestFree(g, blocked, r.Points[n], 96)
			if a < 0 || b < 0 {
				return nil, fmt.Errorf("native ports blocked %s", r.ID)
			}
			trace, err := gridPath(g, blocked, a, b, g.Spec.Edit)
			if err != nil || len(trace) == 0 {
				return nil, fmt.Errorf("native corridor disconnected %s", r.ID)
			}
			for _, i := range trace {
				actual.Trace = append(actual.Trace, cellPoint(g, i))
			}
		}
		if len(actual.Trace) < 2 {
			return nil, fmt.Errorf("native missing route %s", r.ID)
		}
		routes = append(routes, actual)
	}
	return routes, nil
}

func checkLandscapeRoutes(g *Scene, p LandscapePlan, cells []byte) error {
	local := p.Layout
	local.Routes = nil
	for _, r := range p.Routes {
		if landscapePlacement(p, r.ID).ID != "" {
			local.Routes = append(local.Routes, r)
		}
	}
	if e := checkLocalRoutes(g, local, cells); e != nil {
		return e
	}
	blocked := combinedRecompose(g, cells)
	for _, r := range p.Routes {
		for _, xy := range r.Trace {
			i := pathCell(g, xy)
			if i < 0 || blocked[i] {
				return fmt.Errorf("blocked exported route %s at %v", r.ID, xy)
			}
		}
		if landscapePlacement(p, r.ID).ID != "" {
			continue
		}
		if len(r.Trace) < 2 {
			return fmt.Errorf("missing access trace %s", r.ID)
		}
		if _, e := gridPath(g, blocked, pathCell(g, r.Trace[0]), pathCell(g, r.Trace[len(r.Trace)-1]), g.Spec.Edit); e != nil {
			return fmt.Errorf("inter-scene route %s: %w", r.ID, e)
		}
	}
	return nil
}
func landscapeDryComponents(g *Scene) ([]int, []int) {
	labels := make([]int, len(g.Map.Terrain.Tiles))
	sizes := []int{0}
	for i, t := range g.Map.Terrain.Tiles {
		if labels[i] != 0 || t.Boundary || landscapeWet(t, g.Water) {
			continue
		}
		id := len(sizes)
		q := []int{i}
		labels[i] = id
		for n := 0; n < len(q); n++ {
			k := q[n]
			for _, off := range []int{-1, 1, -193, 193} {
				j := k + off
				if j < 0 || j >= len(labels) || off == -1 && k%193 == 0 || off == 1 && k%193 == 192 {
					continue
				}
				t := g.Map.Terrain.Tiles[j]
				if labels[j] == 0 && !t.Boundary && !landscapeWet(t, g.Water) {
					labels[j] = id
					q = append(q, j)
				}
			}
		}
		sizes = append(sizes, len(q))
	}
	return labels, sizes
}
