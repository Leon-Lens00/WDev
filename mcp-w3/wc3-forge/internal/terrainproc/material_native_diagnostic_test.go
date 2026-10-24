package terrainproc

import (
	"math"
	"os"
	"path/filepath"
	"testing"
)

// Opt-in investigation of native route discrepancies; never grants acceptance.
func TestMaterialNativeDiagnostic(t *testing.T) {
	root := os.Getenv("WC3_MATERIAL_NATIVE_DIAGNOSTIC")
	if root == "" {
		t.Skip("native diagnostic inputs not supplied")
	}
	for _, b := range []string{"D", "E", "F"} {
		seed := map[string]string{"D": "52700", "E": "53700", "F": "54700"}[b]
		native := filepath.Join(root, "editor", b, "Tropical-"+b+"-"+seed+"-materials-editor.w3x")
		if _, e := os.Stat(native); e != nil {
			continue
		}
		s, e := ReadSpec(filepath.Join(root, "config", b+"-integrated.json"))
		if e != nil {
			t.Fatal(e)
		}
		g, e := recomposeScene(s)
		if e != nil {
			t.Fatal(e)
		}
		m, e := Load(native)
		if e != nil {
			t.Fatal(e)
		}
		g.Map.Terrain = m.Terrain
		g.Map.Doodads = m.Doodads
		var p LandscapePlan
		if e := strictJSON(filepath.Join(root, "runs", b, seed, "layout.json"), &p); e != nil {
			t.Fatal(e)
		}
		combined := combinedRecompose(g, m.Pathing.Cells)
		report := []map[string]any{}
		for _, r := range p.Routes {
			_, nerr := nativeLandscapeRoutes(g, LandscapePlan{Layout: Layout{Routes: []Route{r}}}, m.Pathing.Cells)
			item := map[string]any{"id": r.ID, "corridor_passed": nerr == nil}
			if nerr != nil {
				item["failure"] = nerr.Error()
				widths := map[int]bool{}
				for _, radius := range []int{5, 6, 8, 12, 16, 24, 32, 64, 96} {
					band := make([]bool, len(combined))
					w, h := g.Map.Pathing.Width, g.Map.Pathing.Height
					for _, xy := range r.Trace {
						i := pathCell(g, xy)
						if i < 0 {
							continue
						}
						for dy := -radius; dy <= radius; dy++ {
							for dx := -radius; dx <= radius; dx++ {
								x, y := i%w+dx, i/w+dy
								if x >= 0 && x < w && y >= 0 && y < h && dx*dx+dy*dy <= radius*radius {
									band[y*w+x] = true
								}
							}
						}
					}
					blocked := make([]bool, len(combined))
					for i := range blocked {
						blocked[i] = combined[i] || !band[i]
					}
					a, z := nearestFree(g, blocked, r.Points[0], 96), nearestFree(g, blocked, r.Points[len(r.Points)-1], 96)
					if a >= 0 && z >= 0 {
						q, e := gridPath(g, blocked, a, z, g.Spec.Edit)
						widths[radius*32] = e == nil && len(q) > 0
						if radius == 5 && e == nil {
							details := []map[string]any{}
							for _, i := range q {
								xy := cellPoint(g, i)
								dp, ds := math.Inf(1), math.Inf(1)
								for n, ref := range r.Trace {
									dp = math.Min(dp, math.Hypot(xy[0]-ref[0], xy[1]-ref[1]))
									if n > 0 {
										prev := r.Trace[n-1]
										dx, dy := ref[0]-prev[0], ref[1]-prev[1]
										u := math.Max(0, math.Min(1, ((xy[0]-prev[0])*dx+(xy[1]-prev[1])*dy)/(dx*dx+dy*dy)))
										ds = math.Min(ds, math.Hypot(xy[0]-prev[0]-u*dx, xy[1]-prev[1]-u*dy))
									}
								}
								if dp > 128 {
									details = append(details, map[string]any{"xy": xy, "point_distance": dp, "segment_distance": ds})
								}
							}
							item["narrow_detour_outside128"] = details
						}
					}
				}
				item["diagnostic_corridor_widths"] = widths
				bad := [][2]float64{}
				for _, xy := range r.Trace {
					i := pathCell(g, xy)
					if i >= 0 && combined[i] {
						bad = append(bad, xy)
					}
				}
				item["blocked_original_trace"] = bad
				a, z := nearestFree(g, combined, r.Points[0], 96), nearestFree(g, combined, r.Points[len(r.Points)-1], 96)
				if a >= 0 && z >= 0 {
					path, err := gridPath(g, combined, a, z, g.Spec.Edit)
					item["global_connected"] = err == nil && len(path) > 0
					maxDist := 0.
					points := [][2]float64{}
					for _, i := range path {
						xy := cellPoint(g, i)
						points = append(points, xy)
						d := math.Inf(1)
						for _, ref := range r.Trace {
							d = math.Min(d, math.Hypot(xy[0]-ref[0], xy[1]-ref[1]))
						}
						maxDist = math.Max(maxDist, d)
					}
					item["global_trace"] = points
					item["max_deviation"] = maxDist
				}
			}
			report = append(report, item)
		}
		if e := JSON(filepath.Join(root, "editor", b, "route-diagnostic.json"), report); e != nil {
			t.Fatal(e)
		}
	}
}
