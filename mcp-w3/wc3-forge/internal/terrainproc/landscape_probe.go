package terrainproc

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"path/filepath"
)

// ExportLandscapeFixture is deliberately an unvalidated diagnostic map. It
// preserves failed geometry so an experiment is inspectable rather than lost.
func ExportLandscapeFixture(s Spec, out string) error {
	g, e := recomposeScene(s)
	if e != nil {
		return e
	}
	l, lib, e := loadSceneLibrary(g)
	if e != nil {
		return e
	}
	p, e := landscapeLayout(g, l, lib, 0)
	if e != nil {
		return e
	}
	landscapeTerrain(g, &p, lib)
	parts, prov, e := landscapeParts(g, l, lib, p)
	if e != nil {
		return e
	}
	g.Map.Doodads.Doodads = parts
	g.Added = parts
	cells := staticLandscapePathing(g)
	routeErr := createLocalRoutes(g, &p.Layout, cells)
	accessErr := landscapeAccess(g, &p, cells)
	blocked := combinedRecompose(g, cells)
	labels := make([]int, len(blocked))
	sizes := []int{0}
	for i, b := range blocked {
		if b || labels[i] != 0 {
			continue
		}
		id := len(sizes)
		queue := []int{i}
		labels[i] = id
		for n := 0; n < len(queue); n++ {
			k := queue[n]
			for _, delta := range []int{-1, 1, -g.Map.Pathing.Width, g.Map.Pathing.Width} {
				j := k + delta
				if j < 0 || j >= len(labels) || blocked[j] || labels[j] > 0 || delta == -1 && k%g.Map.Pathing.Width == 0 || delta == 1 && k%g.Map.Pathing.Width == g.Map.Pathing.Width-1 {
					continue
				}
				labels[j] = id
				queue = append(queue, j)
			}
		}
		sizes = append(sizes, len(queue))
	}
	ports := map[string]any{}
	for _, q := range p.Placements {
		for name, a := range q.Anchors {
			i := nearestFree(g, blocked, a, 256)
			if i >= 0 {
				ports[q.ID+"/"+name] = map[string]any{"component": labels[i], "size": sizes[labels[i]], "xy": cellPoint(g, i)}
			}
		}
	}
	_ = JSON(filepath.Join(out, "connectivity.json"), map[string]any{"ports": ports, "sizes": sizes, "blocked": blocked, "width": g.Map.Pathing.Width, "height": g.Map.Pathing.Height})
	changes, e := recomposeShell(g, p.Layout)
	if e != nil {
		return e
	}
	changes["war3map.w3e"], e = w3e.Encode(g.Map.Terrain)
	if e != nil {
		return e
	}
	changes["war3map.doo"], e = doodadsdoo.Encode(g.Map.Doodads)
	if e != nil {
		return e
	}
	changes["war3map.wpm"] = encodePathing(g.Map.Pathing.Width, g.Map.Pathing.Height, cells)
	changes["war3map.shd"] = make([]byte, len(cells))
	if e := g.Map.Write(filepath.Join(out, "DIAGNOSTIC-NOT-ACCEPTED.w3x"), changes); e != nil {
		return e
	}
	_ = JSON(filepath.Join(out, "layout.json"), p)
	_ = JSON(filepath.Join(out, "spec.json"), s)
	_ = JSON(filepath.Join(out, "placements-provenance.json"), prov)
	_ = JSON(filepath.Join(out, "views.json"), recomposeViews(p.Layout))
	errText := func(e error) string {
		if e == nil {
			return ""
		}
		return e.Error()
	}
	return JSON(filepath.Join(out, "errors.json"), map[string]string{"local": errText(routeErr), "access": errText(accessErr), "status": "diagnostic only"})
}

// ProbeLandscape records physical source heights rather than inferring them from
// screenshots or the water flag. This is also the baseline for local experiments.
func ProbeLandscape(s Spec, out string) error {
	g, e := recomposeScene(s)
	if e != nil {
		return e
	}
	_, l, e := loadSceneLibrary(g)
	if e != nil {
		return e
	}
	comps := []any{}
	for _, p := range l.Prefabs {
		samples := []any{}
		for y := p.Source.Min[1]; y <= p.Source.Max[1]; y += 128 {
			for x := p.Source.Min[0]; x <= p.Source.Max[0]; x += 128 {
				t := g.Original[g.index(x, y)]
				samples = append(samples, map[string]any{"xy": [2]float64{x, y}, "ground": t.FinalZ(), "surface": float64(t.WaterZ()) + g.Water, "wet": landscapeWet(t, g.Water), "texture": t.GroundTexture})
			}
		}
		ports := map[string]any{}
		for k, a := range p.Anchors {
			t := g.Original[g.index(a[0], a[1])]
			ports[k] = map[string]any{"xy": a, "ground": g.height(a[0], a[1], g.Original), "surface": float64(t.WaterZ()) + g.Water, "wet": landscapeWet(t, g.Water)}
		}
		comps = append(comps, map[string]any{"id": p.ID, "ports": ports, "samples": samples, "pieces": p.Pieces})
	}
	if e := JSON(filepath.Join(out, "source-physical.json"), map[string]any{"water_slk_offset": g.Water, "components": comps, "palette": g.Map.Terrain.GroundTilesets}); e != nil {
		return e
	}
	return JSON(filepath.Join(out, "source-assets.json"), g.Catalog)
}
func landscapeWet(t w3e.Tilepoint, offset float64) bool {
	return t.HasWater() && float64(t.WaterZ())+offset > float64(t.FinalZ())
}
