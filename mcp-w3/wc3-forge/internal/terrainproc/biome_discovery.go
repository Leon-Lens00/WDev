package terrainproc

import (
	"fmt"
	"math"
	"path/filepath"
	"slices"
	"sort"
)

// DiscoverBiome reuses the scene discovery records and catalogue. All proposals
// remain pending; this operation cannot certify a composition or a screenshot.
func DiscoverBiome(config, out string) error {
	var c BiomeMaterialConfig
	if e := strictJSON(config, &c); e != nil {
		return e
	}
	if !filepath.IsAbs(c.Source) {
		c.Source = filepath.Join(filepath.Dir(config), c.Source)
	}
	m, e := Load(c.Source)
	if e != nil {
		return e
	}
	if m.Hash != c.SourceSHA {
		return fmt.Errorf("donor hash mismatch")
	}
	cat, e := CatalogMap(m, c.Install)
	if e != nil {
		return e
	}
	g := Scene{Map: m}
	items := []DiscoveryItem{}
	candidates := []DiscoveryCandidate{}
	views := []map[string]any{}
	coverage := map[uint32]string{}
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	ox, oy := float64(m.Terrain.CenterOffset[0]), float64(m.Terrain.CenterOffset[1])
	sx, sy := float64(w-1)*128, float64(h-1)*128
	bins := map[[2]int][]int{}
	bin := func(x, y float64) [2]int { return [2]int{int(math.Floor(x / 256)), int(math.Floor(y / 256))} }
	for _, d := range m.Doodads.Doodads {
		a := cat.Assets[d.TypeID]
		if a == nil {
			return fmt.Errorf("missing catalog %s", d.TypeID)
		}
		xy := [2]float64{float64(d.Position[0]), float64(d.Position[1])}
		item := DiscoveryItem{ID: d.CreationNumber, Rawcode: d.TypeID, Model: a.Fields["file"], XY: xy, Z: float64(d.Position[2]), Ground: g.height(xy[0], xy[1], m.Terrain.Tiles), Previous: "pending-review", Sector: fmt.Sprintf("sector-%d-%d", min(3, max(0, int((xy[1]-oy)/sy*4)))+1, min(3, max(0, int((xy[0]-ox)/sx*4)))+1), Placement: d, Footprint: a.Pathing}
		bins[bin(xy[0], xy[1])] = append(bins[bin(xy[0], xy[1])], len(items))
		items = append(items, item)
		coverage[d.CreationNumber] = "pending-review"
	}
	query := func(p [2]float64, radius float64) []uint32 {
		ids := []uint32{}
		b := bin(p[0], p[1])
		n := int(math.Ceil(radius / 256))
		for y := b[1] - n; y <= b[1]+n; y++ {
			for x := b[0] - n; x <= b[0]+n; x++ {
				for _, i := range bins[[2]int{x, y}] {
					if dist(items[i].XY, p) <= radius {
						ids = append(ids, items[i].ID)
					}
				}
			}
		}
		slices.Sort(ids)
		return ids
	}
	byType := map[string][]int{}
	for i := range items {
		items[i].Neighbors = query(items[i].XY, 384)
		byType[items[i].Rawcode] = append(byType[items[i].Rawcode], i)
	}
	ids := []string{}
	for id := range byType {
		ids = append(ids, id)
	}
	sort.Strings(ids)
	for _, id := range ids {
		indices := byType[id]
		anchor := indices[len(indices)/2]
		if slices.Contains(c.Rules.Trees, id) {
			for _, i := range indices {
				if len(items[i].Neighbors) > len(items[anchor].Neighbors) {
					anchor = i
				}
			}
		}
		a := items[anchor]
		radius := 768.
		name := "family-" + id
		views = append(views, map[string]any{"name": name, "bounds": map[string]any{"min": []float64{a.XY[0] - radius, a.XY[1] - radius, a.Z - 200}, "max": []float64{a.XY[0] + radius, a.XY[1] + radius, a.Z + 900}}, "projection": "orthographic", "yaw": .6, "pitch": 1.0})
		for n, i := range indices {
			if len(indices) > 25 && i != anchor {
				continue
			}
			a := items[i]
			reason := "rare individual; review surroundings and incomplete crops"
			if len(indices) > 25 {
				reason = "family representative; other members accounted separately"
			}
			candidates = append(candidates, DiscoveryCandidate{ID: fmt.Sprintf("%s-%d", id, n), Reason: reason, Anchors: []uint32{a.ID}, Neighbors: query(a.XY, 384), Bounds: expandRect(Rect{a.XY, a.XY}, 768), Status: "pending visual review"})
		}
	}
	sectors := []map[string]any{}
	for y := 0; y < 4; y++ {
		for x := 0; x < 4; x++ {
			sectors = append(sectors, map[string]any{"name": fmt.Sprintf("sector-%d-%d", y+1, x+1), "bounds": map[string]any{"min": []float64{ox + float64(x)*sx/4 - 256, oy + float64(y)*sy/4 - 256, -300}, "max": []float64{ox + float64(x+1)*sx/4 + 256, oy + float64(y+1)*sy/4 + 256, 1300}}, "view": "top", "projection": "orthographic"})
		}
	}
	for name, v := range map[string]any{"inventory.json": items, "catalog.json": cat, "candidates.json": candidates, "family-views.json": views, "sector-views.json": sectors, "coverage-pending.json": coverage} {
		if e := JSON(filepath.Join(out, name), v); e != nil {
			return e
		}
	}
	return nil
}
