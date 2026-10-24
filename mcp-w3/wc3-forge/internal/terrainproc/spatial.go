package terrainproc

import (
	"fmt"
	"math"
	"slices"
)

func (g *Scene) spatial() ([]byte, []byte, bool, error) {
	return g.spatialLayers(true)
}

// Validation uses the WPM actually stored in the exported archive.
func (g *Scene) spatialLayers(rebuild bool) ([]byte, []byte, bool, error) {
	m := g.Map
	p := m.Pathing
	cells := append([]byte{}, p.Cells...)
	shadows := append([]byte{}, m.Files["war3map.shd"]...)
	if len(shadows) != len(cells) {
		return nil, nil, false, fmt.Errorf("shadow dimensions must match terrain")
	}
	ox, oy := float64(m.Terrain.CenterOffset[0]), float64(m.Terrain.CenterOffset[1])
	at := func(x, y float64) (int, int) { return int(math.Floor((x - ox) / 32)), int(math.Floor((y - oy) / 32)) }
	for row := 0; row < p.Height; row++ {
		for col := 0; col < p.Width; col++ {
			x, y := ox+float64(col)*32+16, oy+float64(row)*32+16
			if !rebuild || !g.Spec.Editable(x, y) {
				continue
			}
			i := col + row*p.Width
			z := g.height(x, y, m.Terrain.Tiles)
			slope := 0.
			for _, v := range [][2]float64{{32, 0}, {-32, 0}, {0, 32}, {0, -32}} {
				slope = max(slope, math.Abs(g.height(x+v[0], y+v[1], m.Terrain.Tiles)-z))
			}
			cells[i] = 0
			if z < g.Water {
				cells[i] |= 8 | 64
				if z < g.Water-52 {
					cells[i] |= 2
				}
			}
			if slope > 25 {
				cells[i] |= 2 | 8
			}
			ti := g.index(x, y)
			if ti >= 0 && m.Terrain.Tiles[ti].Boundary {
				cells[i] |= 2 | 8
			}
			shadows[i] = 0
			if g.Spec.Shadows == "omit" {
				continue
			}
			for step := 1; step <= 24; step++ {
				dist := float64(step) * 64
				if g.height(x-dist*.707, y+dist*.707, m.Terrain.Tiles) > z+dist*.8 {
					shadows[i] = 255
					break
				}
			}
		}
	}
	combined := append([]byte{}, cells...)
	for _, d := range m.Doodads.Doodads {
		a := g.Catalog.Assets[d.TypeID]
		if a == nil {
			continue
		}
		x, y := float64(d.Position[0]), float64(d.Position[1])
		angle := float64(d.Rotation)
		cs, sn := math.Cos(angle), math.Sin(angle)
		if a.Pathing != nil {
			fp := a.Pathing
			for fy := 0; fy < fp.Height; fy++ {
				for fx := 0; fx < fp.Width; fx++ {
					flag := fp.Cells[fx+fy*fp.Width]
					if flag == 0 {
						continue
					}
					dx, dy := (float64(fx)+.5-float64(fp.Width)/2)*32, (float64(fy)+.5-float64(fp.Height)/2)*32
					cx, cy := at(x+dx*cs-dy*sn, y+dx*sn+dy*cs)
					if cx >= 0 && cy >= 0 && cx < p.Width && cy < p.Height {
						combined[cx+cy*p.Width] |= flag
					}
				}
			}
		}
		// Provisional canopy/rock shadow mask. Engine/editor baking is a separate recorded gate.
		if g.Spec.Shadows == "omit" {
			continue
		}
		tree := slices.Contains(g.Spec.Trees, d.TypeID)
		rock := slices.Contains(g.Spec.Rocks, d.TypeID)
		if !tree && !rock {
			continue
		}
		radius := 80.
		if tree {
			radius = 140 * float64(d.Scale[0])
		}
		sx, sy := x+radius*.7, y-radius*.7
		cx, cy := at(sx, sy)
		n := int(math.Ceil(radius / 32))
		for yy := cy - n; yy <= cy+n; yy++ {
			for xx := cx - n; xx <= cx+n; xx++ {
				if xx < 0 || yy < 0 || xx >= p.Width || yy >= p.Height {
					continue
				}
				wx, wy := ox+float64(xx)*32+16, oy+float64(yy)*32+16
				if g.Spec.Editable(wx, wy) && math.Hypot(wx-sx, wy-sy) < radius {
					shadows[xx+yy*p.Width] = 255
				}
			}
		}
	}
	blocked := make([]bool, len(cells))
	r := int(math.Ceil(g.Spec.CollisionRadius / 32))
	for y := 0; y < p.Height; y++ {
		for x := 0; x < p.Width; x++ {
			if combined[x+y*p.Width]&2 == 0 {
				continue
			}
			for dy := -r; dy <= r; dy++ {
				for dx := -r; dx <= r; dx++ {
					xx, yy := x+dx, y+dy
					if xx >= 0 && yy >= 0 && xx < p.Width && yy < p.Height {
						blocked[xx+yy*p.Width] = true
					}
				}
			}
		}
	}
	indices := make([]int, len(g.Spec.Path))
	for i, v := range g.Spec.Path {
		x, y := at(v[0], v[1])
		if x < 0 || y < 0 || x >= p.Width || y >= p.Height {
			return nil, nil, false, fmt.Errorf("route endpoint outside map")
		}
		indices[i] = x + y*p.Width
		if blocked[indices[i]] {
			return nil, nil, false, fmt.Errorf("route waypoint %d (%v) blocked", i, v)
		}
	}
	seen := make([]bool, len(cells))
	queue := []int{indices[0]}
	seen[indices[0]] = true
	for head := 0; head < len(queue); head++ {
		i := queue[head]
		x, y := i%p.Width, i/p.Width
		for _, delta := range [][2]int{{1, 0}, {-1, 0}, {0, 1}, {0, -1}} {
			xx, yy := x+delta[0], y+delta[1]
			if xx < 0 || yy < 0 || xx >= p.Width || yy >= p.Height {
				continue
			}
			j := xx + yy*p.Width
			if !seen[j] && !blocked[j] {
				seen[j] = true
				queue = append(queue, j)
			}
		}
	}
	for _, i := range indices {
		if !seen[i] {
			return encodePathing(p.Width, p.Height, cells), shadows, false, nil
		}
	}
	return encodePathing(p.Width, p.Height, cells), shadows, true, nil
}
