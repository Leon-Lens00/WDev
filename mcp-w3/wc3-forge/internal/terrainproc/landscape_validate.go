package terrainproc

import (
	"bytes"
	"fmt"
	"math"
	"path/filepath"
	"reflect"
	"slices"
)

func ValidateLandscape(s Spec, path, out string) error {
	b, e := materializeLandscape(s, filepath.Join(filepath.Dir(out), "validation-rebuild"))
	if e != nil {
		return e
	}
	var recorded LandscapePlan
	if e := strictJSON(filepath.Join(filepath.Dir(path), "layout.json"), &recorded); e != nil {
		return e
	}
	if !reflect.DeepEqual(recorded, b.Plan) {
		return fmt.Errorf("recorded landscape layout differs from the compiled spec")
	}
	return validateLandscapeAgainst(s, path, out, b)
}
func validateLandscapeAgainst(s Spec, path, out string, b landscapeBuild) error {
	m, e := Load(path)
	if e != nil {
		return e
	}
	for name, original := range b.G.Map.Files {
		expected, ok := b.Changes[name]
		if !ok {
			expected = original
		}
		if !bytes.Equal(expected, m.Files[name]) {
			return fmt.Errorf("landscape export member differs: %s", name)
		}
	}
	for name := range m.Files {
		if _, ok := b.G.Map.Files[name]; !ok && name != "(listfile)" && name != "(attributes)" {
			return fmt.Errorf("unexpected landscape member %s", name)
		}
	}
	var recorded []Provenance
	if e := strictJSON(filepath.Join(filepath.Dir(path), "placements-provenance.json"), &recorded); e != nil {
		return e
	}
	if !reflect.DeepEqual(recorded, b.Provenance) {
		return fmt.Errorf("landscape provenance differs from expanded source/module identity")
	}
	return inspectLandscapeOutput(s, path, b, out)
}

// The geometric inspector re-extracts the archive and measures the exported
// terrain/placements/pathing; generation reports and mask labels grant no pass.
func inspectLandscapeOutput(s Spec, path string, b landscapeBuild, out string) error {
	m, e := Load(path)
	if e != nil {
		return e
	}
	g := *b.G
	g.Map = m
	p := b.Plan
	failures := []string{}
	var physical any
	if p.Landforms != nil {
		inspection, err := InspectLandforms(m, p.Landforms.Plan, p.Landforms.Supports)
		physical = inspection
		if err != nil {
			failures = append(failures, "landform inspection: "+err.Error())
		}
	}
	if s.Landscape.Vegetation == "habitat" {
		m := b.Metrics["forest-interior"]
		if m.Count < 30 || m.Quantiles[1] > 160 || m.Neighbors256 < 3 {
			failures = append(failures, "interior forest cohort below accepted density profile")
		}
		for k, source := range [3]float64{math.Sqrt(8192), 128, 128} {
			if math.Abs(m.Quantiles[k]/source-1) > .25 {
				failures = append(failures, "interior forest quantile differs from source by more than 25 percent")
			}
		}
	}
	for i, t := range m.Terrain.Tiles {
		if p.Masks[i] == "rigid" {
			owner := landscapePlacement(p, p.Ownership[i])
			x, y := g.xy(i%193, i/193)
			source := g.Original[g.index(x-owner.Offset[0], y-owner.Offset[1])]
			source.Boundary = false
			source.Flags &^= 8
			if t != source {
				failures = append(failures, fmt.Sprintf("rigid support changed at vertex %d", i))
				break
			}
		}
		if p.Masks[i] != "rigid" && t.GroundTexture == 8 {
			for _, j := range []int{i - 1, i + 1, i - 193, i + 193} {
				if j < 0 || j >= len(p.Masks) || (j == i-1 || j == i+1) && j/193 != i/193 {
					continue
				}
				tex := m.Terrain.Tiles[j].GroundTexture
				if tex == 3 || tex == 5 {
					failures = append(failures, "missing material transition band")
					break
				}
			}
		}
	}
	free := map[[2]float32]bool{}
	for i, d := range m.Doodads.Doodads {
		if i >= len(b.Provenance) {
			break
		}
		pv := b.Provenance[i]
		if pv.Role != "forest" {
			continue
		}
		xy := [2]float32{d.Position[0], d.Position[1]}
		idx := g.index(float64(xy[0]), float64(xy[1]))
		if free[xy] {
			failures = append(failures, "duplicate free tree")
		}
		free[xy] = true
		if math.Abs(float64(d.Position[2])-g.height(float64(xy[0]), float64(xy[1]), m.Terrain.Tiles)) > .002 {
			failures = append(failures, "free tree has lost ground support")
		}
		if s.Landscape.Vegetation == "habitat" && (idx < 0 || !slices.Contains([]string{"forest-interior", "forest-edge", "coast", "riparian", "slope"}, p.Habitat[idx])) {
			failures = append(failures, "tree outside permitted habitat")
		}
	}
	if len(m.Doodads.Doodads) > 6500 {
		failures = append(failures, "placement budget")
	}
	if !bytes.Equal(m.Files["war3map.shd"], make([]byte, len(m.Pathing.Cells))) {
		failures = append(failures, "shadow data")
	}
	labels, sizes := landscapeDryComponents(&g)
	inter, union, sourceArea, area := 0, 0, 0, 0
	for i, t := range m.Terrain.Tiles {
		a := !t.Boundary && !landscapeWet(t, g.Water)
		src := g.Original[i]
		before := !src.Boundary && !landscapeWet(src, g.Water)
		if a {
			area++
		}
		if before {
			sourceArea++
		}
		if a && before {
			inter++
		}
		if a || before {
			union++
		}
	}
	iou := float64(inter) / float64(max(1, union))
	if iou > .7 {
		failures = append(failures, fmt.Sprintf("source IoU %.3f > .70", iou))
	}
	mainShare := float64(slices.Max(sizes)) / float64(max(1, area))
	if s.Landscape.Brief.ID == "E" && mainShare < .7 {
		failures = append(failures, "main island below 70 percent")
	}
	membership := map[string]any{}
	shared := 0
	component := func(q Placement) int {
		a := q.Anchors["center"]
		idx := g.index(a[0], a[1])
		if idx >= 0 && labels[idx] > 0 {
			return labels[idx]
		}
		best := math.Inf(1)
		id := 0
		for i, n := range labels {
			if n > 0 {
				x, y := g.xy(i%193, i/193)
				if q.Core.Contains(x, y) && dist(a, [2]float64{x, y}) < best {
					best = dist(a, [2]float64{x, y})
					id = n
				}
			}
		}
		return id
	}
	for _, group := range s.Landscape.Brief.Groups {
		parent := component(landscapePlacement(p, group.Parent))
		for _, id := range group.Members {
			q := landscapePlacement(p, id)
			c := component(q)
			same := c > 0 && c == parent
			if q.Kind == "micro" && !group.Isolated && same {
				shared++
			}
			membership[id] = map[string]any{"parent": group.Parent, "component": c, "parent_component": parent, "shared": same, "declared_isolated": group.Isolated}
		}
	}
	if shared < 8 {
		failures = append(failures, fmt.Sprintf("only %d/11 micros share parent land", shared))
	}
	relations := []any{}
	for _, r := range s.Landscape.Brief.Relations {
		a, z := landscapePlacement(p, r.From), landscapePlacement(p, r.To)
		passed := true
		switch r.Kind {
		case "same-landmass":
			passed = component(a) > 0 && component(a) == component(z)
		case "near":
			passed = dist(a.Anchors[r.FromPort], z.Anchors[r.ToPort]) <= r.Width
		case "shore-attached":
			passed = false
			v := a.Anchors[r.FromPort]
			for _, off := range [][2]float64{{r.Width, 0}, {-r.Width, 0}, {0, r.Width}, {0, -r.Width}} {
				if landscapeWaterAt(&g, v[0]+off[0], v[1]+off[1]) {
					passed = true
				}
			}
		case "crossing":
			passed = landscapeWaterAt(&g, a.Anchors["center"][0], a.Anchors["center"][1])
			for _, port := range []string{"shore_a", "shore_b"} {
				v := a.Anchors[port]
				passed = passed && !landscapeWaterAt(&g, v[0], v[1])
			}
		}
		if !passed {
			failures = append(failures, "relation failed: "+r.ID)
		}
		relations = append(relations, map[string]any{"id": r.ID, "kind": r.Kind, "passed": passed, "method": "exported W3E components/ports; access routes and hydraulic sections checked below"})
	}
	water := []any{}
	for _, r := range p.Reaches {
		sections := []any{}
		dry := 0
		minimum := math.Inf(1)
		for n := 1; n < len(r.Points); n++ {
			a, z := r.Points[n-1], r.Points[n]
			length := dist(a, z)
			count := max(1, int(math.Ceil(length/128)))
			normal := [2]float64{-(z[1] - a[1]) / max(1., length), (z[0] - a[0]) / max(1., length)}
			for k := 0; k <= count; k++ {
				t := float64(k) / float64(count)
				x, y := a[0]+t*(z[0]-a[0]), a[1]+t*(z[1]-a[1])
				idx := g.index(x, y)
				if idx < 0 {
					dry++
					continue
				}
				rigid := b.Plan.Masks[idx] == "rigid"
				width := 0.
				for d := -r.Width / 2; d <= r.Width/2; d += 32 {
					if landscapeWaterAt(&g, x+d*normal[0], y+d*normal[1]) {
						width += 32
					}
				}
				if !landscapeWaterAt(&g, x, y) {
					dry++
				}
				if !rigid {
					minimum = min(minimum, width)
					if width < r.Width-64 {
						dry++
					}
				}
				sections = append(sections, map[string]any{"xy": [2]float64{x, y}, "bed": g.height(x, y, m.Terrain.Tiles), "surface": landscapeSurface(&g, x, y), "native_visible_width": width, "rigid_source_section": rigid})
			}
		}
		// Water connectivity constrained to the declared channel and its source cores.
		start, end := landscapePlacement(p, r.From).Anchors["outlet"], landscapePlacement(p, r.To).Center
		ai, bi := g.index(start[0], start[1]), g.index(end[0], end[1])
		seen := map[int]bool{ai: true}
		queue := []int{ai}
		for n := 0; n < len(queue); n++ {
			k := queue[n]
			for _, delta := range []int{-1, 1, -193, 193} {
				j := k + delta
				if j < 0 || j >= len(labels) || delta == -1 && k%193 == 0 || delta == 1 && k%193 == 192 || seen[j] {
					continue
				}
				x, y := g.xy(j%193, j/193)
				if lineDistance(r.Points, x, y) > 640 || !landscapeWet(m.Terrain.Tiles[j], g.Water) {
					continue
				}
				seen[j] = true
				queue = append(queue, j)
			}
		}
		if !seen[bi] {
			failures = append(failures, "hydraulic connection broken: "+r.ID)
		}
		if dry > 0 {
			failures = append(failures, fmt.Sprintf("%s has %d dry/narrow adaptive sections", r.ID, dry))
		}
		water = append(water, map[string]any{"id": r.ID, "connected": seen[bi], "length": r.Length, "outlet_connection_length": r.OutletConnectionLength, "outlet_connection_end": r.OutletConnectionEnd, "minimum_adaptable_width": minimum, "bad_sections": dry, "sections": sections})
	}
	if s.Landscape.Brief.ID == "F" && len(p.Reaches) == 2 {
		a, z := p.Reaches[0].OutletConnectionLength, p.Reaches[1].OutletConnectionLength
		if math.Abs(a-z) < max(256., min(a, z)*.25) {
			failures = append(failures, "waterfall outlet connection variants too similar")
		}
	}
	if e := checkLandscapeRoutes(&g, p, m.Pathing.Cells); e != nil {
		failures = append(failures, e.Error())
	}
	for _, r := range p.Routes {
		combined := combinedRecompose(&g, m.Pathing.Cells)
		for _, xy := range r.Trace {
			idx := nearestFree(&g, combined, xy, 1)
			if idx < 0 {
				failures = append(failures, "blocked exported route "+r.ID)
				break
			}
		}
	}
	evidence := map[string]any{"format": "wc3-landscape-validation-v1", "map_sha256": m.Hash, "passed": len(failures) == 0, "failures": failures, "dry_land_iou": iou, "source_dry_vertices": sourceArea, "dry_vertices": area, "component_sizes": sizes, "main_island_share": mainShare, "shared_micros": shared, "membership": membership, "water": water, "forest": b.Metrics, "shadow": "zero", "runtime": "excluded", "visual": "pending", "native_editor": "pending"}
	evidence["relations"] = relations
	if physical != nil {
		evidence["landforms"] = physical
	}
	if e := JSON(out, evidence); e != nil {
		return e
	}
	if len(failures) > 0 {
		return fmt.Errorf("landscape inspection: %v", failures)
	}
	return nil
}
