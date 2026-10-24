package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"math"
	"path/filepath"
	"sort"
)

type DiscoveryItem struct {
	ID        uint32            `json:"id"`
	Rawcode   string            `json:"rawcode"`
	Model     string            `json:"model"`
	XY        [2]float64        `json:"xy"`
	Z         float64           `json:"z"`
	Ground    float64           `json:"ground"`
	Water     float64           `json:"water"`
	Previous  string            `json:"previous"`
	Sector    string            `json:"sector"`
	Neighbors []uint32          `json:"neighbors"`
	Placement doodadsdoo.Doodad `json:"placement"`
	Footprint *Footprint        `json:"footprint,omitempty"`
}
type DiscoveryCandidate struct {
	ID        string   `json:"id"`
	Reason    string   `json:"reason"`
	Anchors   []uint32 `json:"anchors"`
	Neighbors []uint32 `json:"neighbors"`
	Bounds    Rect     `json:"bounds"`
	Status    string   `json:"status"`
}

// Bounded spatial queries propose anchors and neighborhoods. They deliberately
// don't infer semantic ownership from proximity or from a misleading SLK name.
func DiscoverScenes(s Spec, out string) error {
	g, e := recomposeScene(s)
	if e != nil {
		return e
	}
	l, e := extractLibrary(g)
	if e != nil {
		return e
	}
	bins := map[[2]int][]int{}
	items := []DiscoveryItem{}
	bin := func(p [2]float64) [2]int { return [2]int{int(math.Floor(p[0] / 256)), int(math.Floor(p[1] / 256))} }
	for _, d := range g.Map.Doodads.Doodads {
		xy := [2]float64{float64(d.Position[0]), float64(d.Position[1])}
		a := g.Catalog.Assets[d.TypeID]
		item := DiscoveryItem{d.CreationNumber, d.TypeID, a.Fields["file"], xy, float64(d.Position[2]), g.height(xy[0], xy[1], g.Original), g.Water, l.Ownership[d.CreationNumber], fmt.Sprintf("sector-%d-%d", min(4, max(1, int((xy[1]+4096)/3072)+1)), min(8, max(1, int((xy[0]+12288)/3072)+1))), nil, d, a.Pathing}
		bins[bin(xy)] = append(bins[bin(xy)], len(items))
		items = append(items, item)
	}
	query := func(p [2]float64, radius float64) []uint32 {
		b := bin(p)
		n := int(math.Ceil(radius / 256))
		ids := []uint32{}
		for y := b[1] - n; y <= b[1]+n; y++ {
			for x := b[0] - n; x <= b[0]+n; x++ {
				for _, i := range bins[[2]int{x, y}] {
					if dist(p, items[i].XY) <= radius {
						ids = append(ids, items[i].ID)
					}
				}
			}
		}
		sort.Slice(ids, func(i, j int) bool { return ids[i] < ids[j] })
		return ids
	}
	var candidates []DiscoveryCandidate
	for i := range items {
		d := &items[i]
		d.Neighbors = query(d.XY, 384)
		// Every unowned type gets a representative proposal, and rare props get
		// individual ones. Common vegetation remains a cohort, avoiding percolation.
		if d.Previous != "retired-with-old-layout" {
			continue
		}
		a := g.Catalog.Assets[d.Rawcode]
		if a.Count > 25 {
			first := true
			for j := 0; j < i; j++ {
				if items[j].Rawcode == d.Rawcode && items[j].Previous == d.Previous {
					first = false
					break
				}
			}
			if !first {
				continue
			}
		}
		radius := 384.
		reason := "rare anchor / model and surroundings require review"
		if d.Rawcode == "LTba" {
			radius = 220
			reason = "oriented chain candidate; inspect continuity and arc"
		}
		if a.Count > 25 {
			reason = "environmental family representative; review habitat and all source IDs"
			radius = 512
		}
		candidates = append(candidates, DiscoveryCandidate{fmt.Sprintf("%s-%d", d.Rawcode, d.ID), reason, []uint32{d.ID}, query(d.XY, radius), expandRect(Rect{d.XY, d.XY}, max(512, radius)), "pending visual review"})
	}
	views := []map[string]any{}
	for row := 0; row < 4; row++ {
		for col := 0; col < 8; col++ {
			x, y := -12288+col*3072, -4096+row*3072
			views = append(views, map[string]any{"name": fmt.Sprintf("sector-%d-%d", row+1, col+1), "bounds": map[string]any{"min": []int{x - 384, y - 384, -200}, "max": []int{x + 3456, y + 3456, 1300}}, "view": "top", "projection": "orthographic"})
		}
	}
	for name, v := range map[string]any{"inventory.json": items, "candidates.json": candidates, "sector-views.json": views, "catalog.json": g.Catalog, "source-library.json": l} {
		if e := JSON(filepath.Join(out, name), v); e != nil {
			return e
		}
	}
	return nil
}
