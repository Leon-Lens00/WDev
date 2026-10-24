package terrainproc

import (
	"fmt"
	"math"
)

// staticRecomposePathing models water/terrain only. Walkable bridge/platform meshes
// are overlaid separately and never permanently baked as a change to the sea floor.
func staticRecomposePathing(g *Scene) []byte {
	p := g.Map.Pathing
	cells := make([]byte, len(p.Cells))
	for y := 0; y < p.Height; y++ {
		for x := 0; x < p.Width; x++ {
			wx, wy := g.Spec.Edit.Min[0]+float64(x)*32+16, g.Spec.Edit.Min[1]+float64(y)*32+16
			z := g.height(wx, wy, g.Map.Terrain.Tiles)
			f := byte(64)
			if z < g.Water {
				f = 8
				if z < g.Water-64 {
					f |= 2
				}
			}
			for _, d := range [][2]float64{{32, 0}, {-32, 0}, {0, 32}, {0, -32}} {
				if math.Abs(g.height(wx+d[0], wy+d[1], g.Map.Terrain.Tiles)-z) > 25 {
					f |= 2 | 8
				}
			}
			if x < 16 || y < 16 || x >= p.Width-16 || y >= p.Height-16 {
				f |= 2 | 4 | 8 | 128
			}
			cells[x+y*p.Width] = f
		}
	}
	return cells
}

func combinedRecompose(g *Scene, cells []byte) []bool {
	p := g.Map.Pathing
	v := append([]byte{}, cells...)
	// First open only the explicitly walkable pixels of verified walkable meshes.
	// Then union every object's blocking cells so overlap order cannot erase blockers.
	for pass := 0; pass < 2; pass++ {
		for _, d := range g.Map.Doodads.Doodads {
			a := g.Catalog.Assets[d.TypeID]
			if a == nil || a.Pathing == nil {
				continue
			}
			fp := a.Pathing
			cs, sn := math.Cos(float64(d.Rotation)), math.Sin(float64(d.Rotation))
			for y := 0; y < fp.Height; y++ {
				for x := 0; x < fp.Width; x++ {
					f := fp.Cells[x+y*fp.Width]
					// Decoded TGA rows are top-to-bottom; world Y grows upward.
					dx, dy := (float64(x)+.5-float64(fp.Width)/2)*32, (float64(fp.Height)/2-float64(y)-.5)*32
					cx := int(math.Floor((float64(d.Position[0]) + dx*cs - dy*sn - g.Spec.Edit.Min[0]) / 32))
					cy := int(math.Floor((float64(d.Position[1]) + dx*sn + dy*cs - g.Spec.Edit.Min[1]) / 32))
					if cx < 0 || cy < 0 || cx >= p.Width || cy >= p.Height {
						continue
					}
					i := cx + cy*p.Width
					if pass == 0 && a.Fields["walkable"] == "1" && f&8 != 0 && f&2 == 0 {
						v[i] &^= 2
					}
					if pass == 1 {
						v[i] |= f
					}
				}
			}
		}
	}
	b := make([]bool, len(v))
	r := int(math.Ceil(g.Spec.CollisionRadius / 32))
	for y := 0; y < p.Height; y++ {
		for x := 0; x < p.Width; x++ {
			if v[x+y*p.Width]&2 == 0 {
				continue
			}
			for yy := max(0, y-r); yy <= min(p.Height-1, y+r); yy++ {
				for xx := max(0, x-r); xx <= min(p.Width-1, x+r); xx++ {
					b[xx+yy*p.Width] = true
				}
			}
		}
	}
	return b
}

func pathCell(g *Scene, p [2]float64) int {
	x := int(math.Floor((p[0] - g.Spec.Edit.Min[0]) / 32))
	y := int(math.Floor((p[1] - g.Spec.Edit.Min[1]) / 32))
	if x < 0 || y < 0 || x >= g.Map.Pathing.Width || y >= g.Map.Pathing.Height {
		return -1
	}
	return x + y*g.Map.Pathing.Width
}
func cellPoint(g *Scene, i int) [2]float64 {
	return [2]float64{g.Spec.Edit.Min[0] + float64(i%g.Map.Pathing.Width)*32 + 16, g.Spec.Edit.Min[1] + float64(i/g.Map.Pathing.Width)*32 + 16}
}
func nearestFree(g *Scene, b []bool, p [2]float64, radius float64) int {
	best := -1
	d := radius
	for i, blocked := range b {
		if blocked {
			continue
		}
		q := cellPoint(g, i)
		dd := dist(p, q)
		if dd < d {
			d = dd
			best = i
		}
	}
	return best
}

func gridPath(g *Scene, b []bool, start, goal int, limit Rect) ([]int, error) {
	if start < 0 || goal < 0 || b[start] || b[goal] {
		return nil, fmt.Errorf("blocked route anchor")
	}
	w, h := g.Map.Pathing.Width, g.Map.Pathing.Height
	prev := make([]int, len(b))
	for i := range prev {
		prev[i] = -1
	}
	prev[start] = start
	queue := []int{start}
	for head := 0; head < len(queue); head++ {
		i := queue[head]
		if i == goal {
			break
		}
		x, y := i%w, i/w
		for _, d := range [][2]int{{1, 0}, {-1, 0}, {0, 1}, {0, -1}} {
			xx, yy := x+d[0], y+d[1]
			if xx < 0 || yy < 0 || xx >= w || yy >= h {
				continue
			}
			j := xx + yy*w
			p := cellPoint(g, j)
			if prev[j] >= 0 || b[j] || !limit.Contains(p[0], p[1]) {
				continue
			}
			prev[j] = i
			queue = append(queue, j)
		}
	}
	if prev[goal] < 0 {
		return nil, fmt.Errorf("route is disconnected")
	}
	path := []int{goal}
	for path[len(path)-1] != start {
		path = append(path, prev[path[len(path)-1]])
	}
	return path, nil
}

func createLocalRoutes(g *Scene, plan *Layout, cells []byte) error {
	b := combinedRecompose(g, cells)
	for _, q := range plan.Placements {
		family := q.ID
		if q.Family != "" {
			family = q.Family
		}
		if q.Kind == "micro" || family == "waterfall" || family == "lagoon" {
			continue
		}
		anchors := [][2]float64{q.Anchors["access"], q.Anchors["center"]}
		if family == "temple" {
			anchors[1] = q.Anchors["interior"]
		}
		if family == "bridge" {
			anchors = [][2]float64{q.Anchors["shore_a"], q.Anchors["deck_a"], q.Anchors["deck_b"], q.Anchors["shore_b"]}
		}
		points := make([][2]float64, len(anchors))
		var trace [][2]float64
		for i, a := range anchors {
			cell := nearestFree(g, b, a, 256)
			if cell < 0 {
				return fmt.Errorf("%s blocked anchor %d", q.ID, i)
			}
			points[i] = cellPoint(g, cell)
		}
		for i := 1; i < len(points); i++ {
			path, e := gridPath(g, b, pathCell(g, points[i-1]), pathCell(g, points[i]), expandRect(q.Core, 256))
			if e != nil {
				return fmt.Errorf("%s segment %d: %w", q.ID, i, e)
			}
			if len(path) < 8 {
				return fmt.Errorf("%s route too short", q.ID)
			}
			for _, v := range path {
				trace = append(trace, cellPoint(g, v))
			}
		}
		plan.Routes = append(plan.Routes, Route{ID: q.ID, Points: points, Trace: trace})
		if family == "platform" || (g.Spec.Scene != nil && plan.Start == [2]float64{}) {
			plan.Start = points[0]
		}
	}
	return nil
}
