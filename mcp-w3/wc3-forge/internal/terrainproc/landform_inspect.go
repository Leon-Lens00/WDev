package terrainproc

import (
	"fmt"
	"math"

	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

type LandformRelationResult struct {
	ID           string  `json:"id"`
	Kind         string  `json:"kind"`
	Passed       bool    `json:"passed"`
	Samples      int     `json:"samples"`
	Area         float64 `json:"area,omitempty"`
	MinimumDepth float64 `json:"minimum_depth,omitempty"`
	Reason       string  `json:"reason,omitempty"`
}
type LandformFeatureResult struct {
	ID            string                  `json:"id"`
	Kind          string                  `json:"kind"`
	WetVertices   int                     `json:"wet_vertices"`
	DryVertices   int                     `json:"dry_vertices"`
	MinimumHeight float64                 `json:"minimum_height"`
	MaximumHeight float64                 `json:"maximum_height"`
	MaximumDepth  float64                 `json:"maximum_depth"`
	Sections      []LandformSectionResult `json:"sections,omitempty"`
}
type LandformSectionResult struct {
	At              float64    `json:"at"`
	Point           [2]float64 `json:"point"`
	Ground          float64    `json:"ground"`
	Surface         float64    `json:"surface"`
	HasWater        bool       `json:"has_water"`
	Depth           float64    `json:"depth"`
	WetWidth        float64    `json:"wet_width"`
	RequiredWidth   float64    `json:"required_width"`
	LeftBankHeight  float64    `json:"left_bank_height"`
	RightBankHeight float64    `json:"right_bank_height"`
	Rigid           bool       `json:"rigid"`
}
type LandformInspection struct {
	Format          string                   `json:"format"`
	MapSHA          string                   `json:"map_sha256"`
	Passed          bool                     `json:"passed"`
	Geometry        MaterialGeometry         `json:"geometry"`
	SampleStep      int                      `json:"sample_step"`
	WetCells        int                      `json:"wet_cells"`
	Features        []LandformFeatureResult  `json:"features"`
	Relations       []LandformRelationResult `json:"relations"`
	SupportVertices int                      `json:"support_vertices"`
	Failures        []string                 `json:"failures"`
}

// LandformGroundAt reads encoded FinalZ values. It is deliberately independent
// of the primitive realization and handles the final row/column explicitly.
func LandformGroundAt(t *w3e.File, x, y float64) (float64, bool) {
	if t == nil || t.Width < 2 || t.Height < 2 || len(t.Tiles) != int(t.Width*t.Height) {
		return 0, false
	}
	fx, fy := (x-float64(t.CenterOffset[0]))/128, (y-float64(t.CenterOffset[1]))/128
	w, h := int(t.Width), int(t.Height)
	if !finite(fx) || !finite(fy) || fx < 0 || fy < 0 || fx > float64(w-1) || fy > float64(h-1) {
		return 0, false
	}
	cx, cy := min(w-2, int(math.Floor(fx))), min(h-2, int(math.Floor(fy)))
	u, v := fx-float64(cx), fy-float64(cy)
	z := func(x, y int) float64 { return float64(t.Tiles[x+y*w].FinalZ()) }
	return (z(cx, cy)*(1-u)+z(cx+1, cy)*u)*(1-v) + (z(cx, cy+1)*(1-u)+z(cx+1, cy+1)*u)*v, true
}

// LandformWaterSurfaceAt separates the SLK offset from any global design cota.
// No water flag means no supporting surface; flags alone never establish wetness.
func LandformWaterSurfaceAt(t *w3e.File, offset, x, y float64) (float64, bool) {
	if _, ok := LandformGroundAt(t, x, y); !ok || !finite(offset) {
		return 0, false
	}
	cx := int(math.Round((x - float64(t.CenterOffset[0])) / 128))
	cy := int(math.Round((y - float64(t.CenterOffset[1])) / 128))
	tile := t.Tiles[cx+cy*int(t.Width)]
	if !tile.HasWater() {
		return 0, false
	}
	return float64(tile.WaterZ()) + offset, true
}

// InspectLandforms reads a decoded final W3X. It never calls the realization or
// trusts stored masks to infer wetness, connectivity, support or pathing.
func InspectLandforms(m *Map, p LandformPlan, supports []LandformSupport) (LandformInspection, error) {
	r := LandformInspection{Format: "wc3-landform-inspection-v1", SampleStep: 32, Failures: []string{}}
	if e := ValidateLandformPlan(p); e != nil {
		return r, e
	}
	if e := validateLandformSupports(p, supports); e != nil {
		return r, e
	}
	for _, f := range p.Features {
		if f.Jitter != 0 || f.Curve {
			return r, fmt.Errorf("landform inspector requires the resolved plan")
		}
	}
	if m == nil || m.Terrain == nil {
		return r, fmt.Errorf("landform inspector: missing terrain")
	}
	r.MapSHA = m.Hash
	r.Geometry = MaterialGeometry{int(m.Terrain.Width), int(m.Terrain.Height), m.Terrain.CenterOffset}
	if r.Geometry != p.Geometry || len(m.Terrain.Tiles) != p.Geometry.Width*p.Geometry.Height {
		return r, fmt.Errorf("landform inspector: physical geometry differs")
	}
	fail := func(s string) { r.Failures = append(r.Failures, s) }
	rigid := map[int]bool{}
	for _, s := range supports {
		worst := 0.
		for _, v := range s.Vertices {
			rigid[v.Index] = true
			r.SupportVertices++
			worst = max(worst, math.Abs(float64(m.Terrain.Tiles[v.Index].FinalZ())-v.Height))
		}
		if worst > max(.126, s.Tolerance) {
			fail(fmt.Sprintf("support %s: height changed by %.3f", s.ID, worst))
		}
	}
	for i, t := range m.Terrain.Tiles {
		if !rigid[i] && t.HasWater() && math.Abs(float64(t.WaterZ())+p.WaterOffset-p.WaterLevel) > .251 {
			fail(fmt.Sprintf("water surface differs at vertex %d", i))
			break
		}
	}
	w, h := (p.Geometry.Width-1)*4, (p.Geometry.Height-1)*4
	n := w * h
	if n > landformBudget(p).MaxSamples {
		return r, fmt.Errorf("landform inspector: raster budget %d exceeds %d", n, landformBudget(p).MaxSamples)
	}
	wet, walk := make([]bool, n), make([]bool, n)
	depth := make([]float64, n)
	point := func(i int) [2]float64 {
		return [2]float64{float64(p.Geometry.Origin[0]) + float64(i%w)*32 + 16, float64(p.Geometry.Origin[1]) + float64(i/w)*32 + 16}
	}
	hasPathing := m.Pathing != nil && m.Pathing.Width == w && m.Pathing.Height == h && len(m.Pathing.Cells) == n
	for i := range wet {
		pt := point(i)
		z, _ := LandformGroundAt(m.Terrain, pt[0], pt[1])
		water, hasWater := LandformWaterSurfaceAt(m.Terrain, p.WaterOffset, pt[0], pt[1])
		depth[i] = water - z
		wet[i] = hasWater && depth[i] > .25
		if wet[i] {
			r.WetCells++
		}
		walk[i] = !wet[i] && i%w >= 16 && i%w < w-16 && i/w >= 16 && i/w < h-16
		if hasPathing && m.Pathing.Cells[i]&2 != 0 {
			walk[i] = false
		}
		for _, d := range [][2]float64{{32, 0}, {-32, 0}, {0, 32}, {0, -32}} {
			zz, ok := LandformGroundAt(m.Terrain, pt[0]+d[0], pt[1]+d[1])
			if !ok || math.Abs(z-zz) > 25 {
				walk[i] = false
			}
		}
	}
	compiled := map[string]landformCompiled{}
	for _, f := range p.Features {
		c := compileLandform(p.Geometry, f)
		compiled[f.ID] = c
		metric := LandformFeatureResult{ID: f.ID, Kind: f.Kind, MinimumHeight: math.Inf(1), MaximumHeight: math.Inf(-1)}
		for i, t := range m.Terrain.Tiles {
			pt := landformXY(p.Geometry, i)
			inside := false
			if landformPolygon(f) {
				inside = landformInPolygon(pt, c.Points)
			} else {
				d, _, s := c.axis(pt)
				inside = d <= s.Width/2
			}
			if !inside {
				continue
			}
			z := float64(t.FinalZ())
			metric.MinimumHeight = min(metric.MinimumHeight, z)
			metric.MaximumHeight = max(metric.MaximumHeight, z)
			dd := float64(t.WaterZ()) + p.WaterOffset - z
			if t.HasWater() && dd > .25 {
				metric.WetVertices++
				metric.MaximumDepth = max(metric.MaximumDepth, dd)
			} else {
				metric.DryVertices++
			}
		}
		if metric.WetVertices+metric.DryVertices == 0 {
			metric.MinimumHeight = 0
			metric.MaximumHeight = 0
			fail("feature below exported resolution: " + f.ID)
		}
		if (f.Kind == "lake" || f.Kind == "channel") && metric.WetVertices == 0 {
			fail("water feature is physically dry: " + f.ID)
		}
		if !landformPolygon(f) {
			badSections := 0
			for k := 0; k <= int(math.Ceil(c.Length/128)); k++ {
				station := min(c.Length, float64(k)*128)
				segment := 1
				for segment < len(c.Lengths)-1 && c.Lengths[segment] < station {
					segment++
				}
				a, b := c.Points[segment-1], c.Points[segment]
				length := dist(a, b)
				u := max(0, min(1, (station-c.Lengths[segment-1])/length))
				pt := [2]float64{a[0] + (b[0]-a[0])*u, a[1] + (b[1]-a[1])*u}
				normal := [2]float64{-(b[1] - a[1]) / length, (b[0] - a[0]) / length}
				section := landformSection(f, station/c.Length)
				v := LandformSectionResult{At: station / c.Length, Point: pt, RequiredWidth: section.Width}
				v.Ground, _ = LandformGroundAt(m.Terrain, pt[0], pt[1])
				v.Surface, v.HasWater = LandformWaterSurfaceAt(m.Terrain, p.WaterOffset, pt[0], pt[1])
				if v.HasWater {
					v.Depth = v.Surface - v.Ground
				}
				vx := int(math.Round((pt[0] - float64(p.Geometry.Origin[0])) / 128))
				vy := int(math.Round((pt[1] - float64(p.Geometry.Origin[1])) / 128))
				v.Rigid = rigid[vx+vy*p.Geometry.Width]
				for d := -section.Width/2 + 16; d < section.Width/2; d += 32 {
					xx, yy := pt[0]+d*normal[0], pt[1]+d*normal[1]
					z, ok := LandformGroundAt(m.Terrain, xx, yy)
					water, wet := LandformWaterSurfaceAt(m.Terrain, p.WaterOffset, xx, yy)
					if ok && wet && z < water-.25 {
						v.WetWidth += min(32, section.Width/2-d+16)
					}
				}
				v.LeftBankHeight, _ = LandformGroundAt(m.Terrain, pt[0]+(section.Width/2+section.LeftBank)*normal[0], pt[1]+(section.Width/2+section.LeftBank)*normal[1])
				v.RightBankHeight, _ = LandformGroundAt(m.Terrain, pt[0]-(section.Width/2+section.RightBank)*normal[0], pt[1]-(section.Width/2+section.RightBank)*normal[1])
				if f.Kind == "channel" && (!v.HasWater || v.Depth <= .25 || !v.Rigid && v.WetWidth < max(32, section.Width-64)) {
					badSections++
				}
				metric.Sections = append(metric.Sections, v)
			}
			if badSections > 0 {
				fail(fmt.Sprintf("channel %s: %d physically dry/narrow sections", f.ID, badSections))
			}
		}
		r.Features = append(r.Features, metric)
	}
	cell := func(pt [2]float64) int {
		a := landformWorld(p.Geometry, pt)
		x, y := int(math.Floor((a[0]-float64(p.Geometry.Origin[0]))/32)), int(math.Floor((a[1]-float64(p.Geometry.Origin[1]))/32))
		if x < 0 || y < 0 || x >= w || y >= h {
			return -1
		}
		return x + y*w
	}
	for _, relation := range p.Relations {
		v := LandformRelationResult{ID: relation.ID, Kind: relation.Kind, Passed: true, MinimumDepth: math.Inf(1)}
		if relation.Kind == "support" {
			for _, s := range supports {
				if s.ID == relation.Support {
					for _, pt := range s.Vertices {
						v.Samples++
						if math.Abs(float64(m.Terrain.Tiles[pt.Index].FinalZ())-pt.Height) > max(.126, s.Tolerance) {
							v.Passed = false
							v.Reason = "support height differs"
						}
					}
				}
			}
		} else {
			c := compiled[relation.Feature]
			a, b := cell(relation.From), cell(relation.To)
			allowed := make([]bool, n)
			for i := range allowed {
				if relation.Kind == "access" {
					allowed[i] = walk[i]
				} else if relation.Kind == "isolated" {
					// Even a shallow leak joins the lake physically. A depth filter
					// here could conceal the very escape this relation must find.
					allowed[i] = wet[i]
				} else {
					allowed[i] = wet[i] && depth[i]+.001 >= relation.MinDepth
				}
				if !allowed[i] || relation.Kind == "isolated" {
					continue
				}
				pt := point(i)
				if landformPolygon(c.Feature) {
					allowed[i] = landformSignedDistance(pt, c.Points) >= -relation.Margin
				} else {
					d, _, s := c.axis(pt)
					allowed[i] = d <= s.Width/2+relation.Margin
				}
			}
			if relation.Kind == "access" && !hasPathing {
				v.Passed = false
				v.Reason = "missing or mismatched WPM"
			}
			if relation.Kind != "isolated" && relation.Width > 32 {
				wide := landformClearance(allowed, w, h, relation.Width/2)
				if relation.Kind == "connect" {
					// The authored section under a bridge/outlet may have its own
					// measured width. Keep its wet center/connectivity mandatory,
					// but do not impose the adaptive-channel width inside it.
					for i, ok := range allowed {
						if !ok {
							continue
						}
						pt := point(i)
						vx := int(math.Round((pt[0] - float64(p.Geometry.Origin[0])) / 128))
						vy := int(math.Round((pt[1] - float64(p.Geometry.Origin[1])) / 128))
						if rigid[vx+vy*p.Geometry.Width] {
							wide[i] = true
						}
					}
				}
				allowed = wide
			}
			if a < 0 || a >= n || !allowed[a] {
				v.Passed = false
				v.Reason = "declared physical start port unavailable"
			} else {
				seen, queue := landformFlood(allowed, w, h, a)
				v.Samples = len(queue)
				v.Area = float64(len(queue)) * 1024
				if relation.Kind == "isolated" {
					if depth[a] < relation.MinDepth {
						v.Passed = false
						v.Reason = "lake seed depth below declared minimum"
					}
					for _, i := range queue {
						v.MinimumDepth = min(v.MinimumDepth, depth[i])
						pt := point(i)
						if i%w == 0 || i%w == w-1 || i/w == 0 || i/w == h-1 || landformSignedDistance(pt, c.Points) < -max(32, relation.Margin) {
							v.Passed = false
							v.Reason = "isolated lake escapes its declared envelope or joins exterior water"
							break
						}
					}
					if relation.MinArea > 0 && v.Area < relation.MinArea || relation.MaxArea > 0 && v.Area > relation.MaxArea {
						v.Passed = false
						v.Reason = "isolated lake area outside bounds"
					}
				} else if b < 0 || b >= n || !seen[b] {
					v.Passed = false
					v.Reason = "declared physical end port disconnected"
				}
			}
		}
		if math.IsInf(v.MinimumDepth, 1) {
			v.MinimumDepth = 0
		}
		if !v.Passed {
			fail("relation " + v.ID + ": " + v.Reason)
		}
		r.Relations = append(r.Relations, v)
	}
	r.Passed = len(r.Failures) == 0
	if !r.Passed {
		return r, fmt.Errorf("landform inspection: %v", r.Failures)
	}
	return r, nil
}

func landformFlood(allowed []bool, w, h, start int) ([]bool, []int) {
	seen := make([]bool, len(allowed))
	if start < 0 || start >= len(allowed) || !allowed[start] {
		return seen, nil
	}
	queue := []int{start}
	seen[start] = true
	for n := 0; n < len(queue); n++ {
		i := queue[n]
		for _, j := range []int{i - 1, i + 1, i - w, i + w} {
			if j < 0 || j >= len(allowed) || j == i-1 && i%w == 0 || j == i+1 && i%w == w-1 || seen[j] || !allowed[j] {
				continue
			}
			seen[j] = true
			queue = append(queue, j)
		}
	}
	return seen, queue
}
func landformClearance(allowed []bool, w, h int, radius float64) []bool {
	out := append([]bool{}, allowed...)
	r := int(math.Ceil(radius / 32))
	r2 := radius * radius
	for i, ok := range allowed {
		if !ok {
			continue
		}
		x, y := i%w, i/w
		for dy := -r; dy <= r && out[i]; dy++ {
			for dx := -r; dx <= r; dx++ {
				if float64(dx*dx+dy*dy)*1024 > r2 {
					continue
				}
				xx, yy := x+dx, y+dy
				if xx < 0 || yy < 0 || xx >= w || yy >= h || !allowed[xx+yy*w] {
					out[i] = false
					break
				}
			}
		}
	}
	return out
}
