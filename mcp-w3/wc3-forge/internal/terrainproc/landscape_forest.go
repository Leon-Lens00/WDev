package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"math"
	"math/rand"
	"slices"
	"strconv"
)

func landscapeHabitats(g *Scene, p *LandscapePlan) {
	p.Habitat = make([]string, len(g.Original))
	wet := []int{}
	for i, t := range g.Map.Terrain.Tiles {
		if landscapeWet(t, g.Water) {
			wet = append(wet, i)
		}
	}
	// Explicit reading clearings are tied to access ports, before tree placement.
	for _, q := range p.Placements {
		if a, ok := q.Anchors["access"]; ok {
			p.Clearings = append(p.Clearings, Rect{[2]float64{a[0] - 384, a[1] - 384}, [2]float64{a[0] + 384, a[1] + 384}})
		}
	}
	for i, t := range g.Map.Terrain.Tiles {
		x, y := g.xy(i%193, i/193)
		h := "forest-interior"
		z := float64(t.FinalZ())
		waterdist := math.Inf(1)
		for _, j := range wet {
			if absInt(i/193-j/193) > 12 || absInt(i%193-j%193) > 12 {
				continue
			}
			xx, yy := g.xy(j%193, j/193)
			waterdist = min(waterdist, math.Hypot(x-xx, y-yy))
		}
		slope := max(math.Abs(z-g.height(x+64, y, g.Map.Terrain.Tiles)), math.Abs(z-g.height(x, y+64, g.Map.Terrain.Tiles)))
		field := math.Sin(x/1800+float64(g.Spec.Landscape.Streams["relief"]%7)) + .7*math.Cos(y/1230) + .4*math.Sin((x+y)/670)
		if field < -0.6 {
			h = "clearing"
		} else if field < .0 {
			h = "forest-edge"
		}
		if slope > 24 {
			h = "slope"
		}
		if waterdist < 512 {
			h = "coast"
		}
		for _, r := range p.Reaches {
			if lineDistance(r.Points, x, y) < 700 {
				h = "riparian"
			}
		}
		for _, r := range p.Routes {
			if lineDistance(r.Trace, x, y) < 256 {
				h = "access"
				break
			}
		}
		for _, r := range p.Clearings {
			if r.Contains(x, y) {
				h = "clearing"
			}
		}
		if p.Masks[i] == "rigid" {
			h = "structural"
		}
		if t.Boundary {
			h = "boundary"
		}
		if landscapeWet(t, g.Water) {
			h = "water"
		}
		p.Habitat[i] = h
	}
}
func absInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func landscapeDecorate(g *Scene, l SceneLibrary, p LandscapePlan, parts []doodadsdoo.Doodad, provenance []Provenance) ([]doodadsdoo.Doodad, []Provenance, map[string]ForestMetrics, error) {
	// S remains an explicit compact-cohort control on precisely this P geography.
	decorated, oldprov, _, e := decorateScenes(g, l, p.Layout, parts, provenance)
	if e != nil {
		return nil, nil, nil, e
	}
	if g.Spec.Landscape.Vegetation == "s-control" {
		metrics := map[string]ForestMetrics{}
		by := map[string][]doodadsdoo.Doodad{}
		for i, d := range decorated {
			if oldprov[i].Role == "forest" {
				xy := g.index(float64(d.Position[0]), float64(d.Position[1]))
				by[p.Habitat[xy]] = append(by[p.Habitat[xy]], d)
			}
		}
		for k, ds := range by {
			metrics[k] = forestMetrics(ds)
		}
		return decorated, oldprov, metrics, nil
	}
	result := []doodadsdoo.Doodad{}
	prov := []Provenance{}
	for i, d := range decorated {
		if oldprov[i].Role == "forest" {
			continue
		}
		if g.Spec.Landscape.Vegetation == "bare" && (oldprov[i].Role == "environment" || oldprov[i].Role == "ornament" || slices.Contains(g.Spec.Trees, d.TypeID)) {
			continue
		}
		result = append(result, d)
		prov = append(prov, oldprov[i])
	}
	if g.Spec.Landscape.Vegetation == "bare" {
		return result, prov, map[string]ForestMetrics{}, nil
	}
	source := map[uint32]doodadsdoo.Doodad{}
	for _, d := range g.Map.Doodads.Doodads {
		source[d.CreationNumber] = d
	}
	rng := rand.New(rand.NewSource(int64(g.Spec.Landscape.Streams["vegetation"])))
	trees := []doodadsdoo.Doodad{}
	by := map[string][]doodadsdoo.Doodad{}
	centers := [][2]float64{}
	for trial := 0; trial < 9000 && len(trees) < 1500; trial++ {
		dest := [2]float64{math.Round((-10880+rng.Float64()*21760)/128) * 128, math.Round((-2688+rng.Float64()*9600)/128) * 128}
		idx := g.index(dest[0], dest[1])
		if idx < 0 {
			continue
		}
		hab := p.Habitat[idx]
		cohort := l.Cohorts[0]
		separation := 560.
		density := 1.
		switch hab {
		case "forest-interior":
		case "forest-edge":
			density = .65
			separation = 630
		case "coast", "riparian":
			cohort = l.Cohorts[1]
			density = .45
			separation = 690
		case "slope":
			cohort = l.Cohorts[2]
			density = .50
			separation = 620
		default:
			continue
		}
		clear := true
		for _, c := range centers {
			if dist(c, dest) < separation {
				clear = false
				break
			}
		}
		if !clear {
			continue
		}
		anchor := source[cohort.SourceIDs[rng.Intn(len(cohort.SourceIDs))]]
		pivot := [2]float64{float64(anchor.Position[0]), float64(anchor.Position[1])}
		angle := rng.Intn(4) * 90
		before := len(trees)
		for _, id := range cohort.SourceIDs {
			src := source[id]
			pos := [2]float64{float64(src.Position[0]), float64(src.Position[1])}
			if dist(pos, pivot) > 440 || rng.Float64() > density {
				continue
			}
			xy := turnPoint(pos, pivot, dest, angle)
			a := g.Catalog.Assets[src.TypeID]
			footprint := 0.
			if a.Pathing != nil {
				footprint = math.Hypot(float64(a.Pathing.Width), float64(a.Pathing.Height)) * 16
				xy[0] = math.Round(xy[0]/64)*64 + float64(a.Pathing.Width%4)*16
				xy[1] = math.Round(xy[1]/64)*64 + float64(a.Pathing.Height%4)*16
			}
			i := g.index(xy[0], xy[1])
			if i < 0 {
				continue
			}
			target := p.Habitat[i]
			if !slices.Contains([]string{"forest-interior", "forest-edge", "coast", "riparian", "slope"}, target) || !sceneFree(g, p.Layout, xy[0], xy[1], footprint) || !sceneTreeGround(g, xy[0], xy[1]) {
				continue
			}
			minimum := cohort.MinimumSpacing
			if cohort.ThinClosePairs && id%2 == 0 {
				minimum = max(minimum, cohort.ClosePairSpacing)
			}
			ok := true
			for _, d := range trees {
				if math.Hypot(xy[0]-float64(d.Position[0]), xy[1]-float64(d.Position[1])) < minimum {
					ok = false
					break
				}
			}
			if !ok {
				continue
			}
			d := src
			d.Position = [3]float32{float32(xy[0]), float32(xy[1]), float32(g.height(xy[0], xy[1], g.Map.Terrain.Tiles))}
			d.Rotation = float32(math.Mod(float64(src.Rotation)+float64(angle)*math.Pi/180, 2*math.Pi))
			if fixed, err := strconv.ParseFloat(a.Fields["fixedrot"], 64); err == nil && fixed >= 0 {
				d.Rotation = float32(fixed * math.Pi / 180)
			}
			if a.Pathing != nil && a.Kind == "doodad" {
				d.Rotation = float32(math.Mod(math.Round(float64(d.Rotation)/(math.Pi/2))*math.Pi/2, 2*math.Pi))
			}
			d.Flags = 2
			d.CreationNumber = 20001 + uint32(len(trees))
			result = append(result, d)
			prov = append(prov, Provenance{d.CreationNumber, id, cohort.ID, target, "forest"})
			trees = append(trees, d)
			by[target] = append(by[target], d)
		}
		if len(trees) > before {
			centers = append(centers, dest)
		}
	}
	if len(result) > g.Spec.Scene.MaxObjects {
		return nil, nil, nil, fmt.Errorf("landscape decoration exceeds budget")
	}
	metrics := map[string]ForestMetrics{}
	for k, ds := range by {
		metrics[k] = forestMetrics(ds)
	}
	return result, prov, metrics, nil
}
