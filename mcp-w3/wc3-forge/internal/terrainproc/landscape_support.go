package terrainproc

import "math"

type landscapeSupport struct {
	Owner    Placement
	Vertices [][2]float64
}

// Preserve authored relief beneath every piece and around meaningful central
// landforms. Empty donor water at rectangular crop corners is not a rigid core.
func landscapeSupports(g *Scene, p LandscapePlan, lib Library) []landscapeSupport {
	out := []landscapeSupport{}
	for _, q := range p.Placements {
		f := scenePrefab(lib, q.Family)
		support := landscapeSupport{Owner: q}
		rx, ry := (f.Source.Max[0]-f.Source.Min[0])*.42, (f.Source.Max[1]-f.Source.Min[1])*.42
		for y := f.Source.Min[1]; y <= f.Source.Max[1]; y += 128 {
			for x := f.Source.Min[0]; x <= f.Source.Max[0]; x += 128 {
				idx := g.index(x, y)
				if idx < 0 {
					continue
				}
				central := math.Pow((x-f.Pivot[0])/max(rx, 128), 2)+math.Pow((y-f.Pivot[1])/max(ry, 128), 2) <= 1
				keep := central && (!landscapeWet(g.Original[idx], g.Water) || q.Family == "lagoon" || q.Family == "bridge")
				if q.Family == "circle" || q.Family == "temple" || q.Family == "platform" || q.Family == "bridge" {
					keep = true
				}
				// Preserve the authored lagoon and its immediate bank, without
				// extruding the dry corners of the rectangular extraction into sea.
				if q.Family == "lagoon" {
					for dy := -128.; dy <= 128; dy += 128 {
						for dx := -128.; dx <= 128; dx += 128 {
							j := g.index(x+dx, y+dy)
							if j >= 0 && f.Source.Contains(x+dx, y+dy) && landscapeWet(g.Original[j], g.Water) {
								keep = true
							}
						}
					}
				}
				for _, d := range f.Pieces {
					if math.Abs(x-float64(d.Position[0])) <= 160 && math.Abs(y-float64(d.Position[1])) <= 160 {
						keep = true
						break
					}
				}
				for _, a := range f.Anchors {
					if dist(a, [2]float64{x, y}) <= 256 {
						keep = true
					}
				}
				// The proven stream underneath a bridge is a rigid hydraulic support.
				if q.Family == "bridge" && central {
					keep = true
				}
				if keep {
					support.Vertices = append(support.Vertices, [2]float64{x + q.Offset[0], y + q.Offset[1]})
				}
			}
		}
		out = append(out, support)
	}
	return out
}

func nearestLandscapeSupport(supports []landscapeSupport, x, y float64) (Placement, [2]float64, float64) {
	best := math.Inf(1)
	var owner Placement
	var point [2]float64
	for _, s := range supports {
		if rectDistance(s.Owner.Core, x, y) > 896 {
			continue
		}
		for _, xy := range s.Vertices {
			d := math.Hypot(x-xy[0], y-xy[1])
			if d < best {
				best = d
				owner = s.Owner
				point = xy
			}
		}
	}
	return owner, point, best
}

// A nearest vertex alone extrudes its height into a Voronoi wedge. Average a
// narrow neighbourhood along the support boundary only outside the rigid mask.
func landscapeSupportHeight(g *Scene, supports []landscapeSupport, owner Placement, x, y, best float64) float64 {
	value, total := 0., 0.
	for _, support := range supports {
		if support.Owner.ID != owner.ID {
			continue
		}
		for _, xy := range support.Vertices {
			d := math.Hypot(x-xy[0], y-xy[1])
			if d > best+256 {
				continue
			}
			w := math.Exp(-(d - best) / 80)
			i := g.index(xy[0]-owner.Offset[0], xy[1]-owner.Offset[1])
			value += w * float64(g.Original[i].FinalZ())
			total += w
		}
	}
	return value / total
}
