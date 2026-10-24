package terrainproc

import (
	"fmt"
	"math"
	"math/rand"
	"slices"
	"strconv"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
)

type ForestMetrics struct {
	Count         int        `json:"count"`
	Quantiles     [3]float64 `json:"nearest_quantiles"`
	Neighbors256  float64    `json:"neighbors256"`
	CloseFraction float64    `json:"fraction_below_165"`
	Groups        []int      `json:"connected_group_sizes_256"`
}

func forestMetrics(ds []doodadsdoo.Doodad) ForestMetrics {
	m := ForestMetrics{Count: len(ds)}
	if len(ds) < 2 {
		return m
	}
	nn := []float64{}
	visited := make([]bool, len(ds))
	for i, a := range ds {
		best := math.Inf(1)
		for j, b := range ds {
			if i == j {
				continue
			}
			d := math.Hypot(float64(a.Position[0]-b.Position[0]), float64(a.Position[1]-b.Position[1]))
			best = min(best, d)
			if d <= 256 {
				m.Neighbors256++
			}
		}
		nn = append(nn, best)
		if best < 165 {
			m.CloseFraction++
		}
	}
	slices.Sort(nn)
	for k, p := range []float64{.25, .5, .75} {
		m.Quantiles[k] = nn[int(float64(len(nn)-1)*p)]
	}
	m.Neighbors256 /= float64(len(ds))
	m.CloseFraction /= float64(len(ds))
	for i := range ds {
		if visited[i] {
			continue
		}
		queue := []int{i}
		visited[i] = true
		for n := 0; n < len(queue); n++ {
			a := ds[queue[n]]
			for j, b := range ds {
				if !visited[j] && math.Hypot(float64(a.Position[0]-b.Position[0]), float64(a.Position[1]-b.Position[1])) <= 256 {
					visited[j] = true
					queue = append(queue, j)
				}
			}
		}
		m.Groups = append(m.Groups, len(queue))
	}
	slices.Sort(m.Groups)
	return m
}

func sceneFree(g *Scene, plan Layout, x, y, footprint float64) bool {
	if !expandRect(g.Spec.Edit, -768).Contains(x, y) {
		return false
	}
	for _, q := range plan.Placements {
		if expandRect(q.Core, 96+footprint).Contains(x, y) {
			return false
		}
	}
	for _, r := range plan.Routes {
		for _, p := range r.Trace {
			if math.Hypot(x-p[0], y-p[1]) < 128+footprint {
				return false
			}
		}
	}
	return true
}
func sceneTreeGround(g *Scene, x, y float64) bool {
	i := g.index(x, y)
	if i < 0 {
		return false
	}
	z := g.height(x, y, g.Map.Terrain.Tiles)
	if z < g.Water+65 || z > 650 {
		return false
	}
	slope := max(math.Abs(z-g.height(x+64, y, g.Map.Terrain.Tiles)), math.Abs(z-g.height(x, y+64, g.Map.Terrain.Tiles)))
	if slope > 70 {
		return false
	}
	return true
}
func sceneForestHabitat(g *Scene, x, y float64) bool {
	if !sceneTreeGround(g, x, y) {
		return false
	}
	i := g.index(x, y)
	// Texture patches are a deterministic WFC-conditioned habitat. Dirt/sand
	// openings remain deliberate clearings rather than receiving every cluster.
	t := g.Map.Terrain.Tiles[i].GroundTexture
	return t == 8 || t == 5 || t == 2 && math.Sin(x/570)+math.Cos(y/410) > .45
}

func decorateScenes(g *Scene, l SceneLibrary, plan Layout, parts []doodadsdoo.Doodad, provenance []Provenance) ([]doodadsdoo.Doodad, []Provenance, ForestMetrics, error) {
	source := map[uint32]doodadsdoo.Doodad{}
	for _, d := range g.Map.Doodads.Doodads {
		source[d.CreationNumber] = d
	}
	result := slices.Clone(parts)
	prov := slices.Clone(provenance)
	nextTree, nextEnvironment := uint32(20000), uint32(30000)
	freeTrees := []doodadsdoo.Doodad{}
	occupied := map[[2]int]bool{}
	environmentOccupied := map[[2]int]bool{}
	for _, d := range parts {
		occupied[[2]int{int(math.Round(float64(d.Position[0]) * 4)), int(math.Round(float64(d.Position[1]) * 4))}] = true
	}
	place := func(src doodadsdoo.Doodad, x, y, angle float64, role, recipe, policy string, waterOffset, groundOffset float64) bool {
		a := g.Catalog.Assets[src.TypeID]
		if a == nil {
			return false
		}
		footprint := 0.
		if a.Pathing != nil {
			footprint = math.Hypot(float64(a.Pathing.Width), float64(a.Pathing.Height)) * 16
			x = math.Round(x/64)*64 + float64(a.Pathing.Width%4)*16
			y = math.Round(y/64)*64 + float64(a.Pathing.Height%4)*16
		}
		if !sceneFree(g, plan, x, y, footprint) {
			return false
		}
		key := [2]int{int(math.Round(x * 4)), int(math.Round(y * 4))}
		used := occupied
		if role == "environment" {
			used = environmentOccupied
		}
		if used[key] {
			return false
		}
		z := g.height(x, y, g.Map.Terrain.Tiles)
		if role == "environment" && (src.TypeID == "ZRbd" || src.TypeID == "ZRbs" || src.TypeID == "AOla") {
			for _, delta := range [][2]float64{{96, 0}, {-96, 0}, {0, 96}, {0, -96}} {
				if math.Abs(z-g.height(x+delta[0], y+delta[1], g.Map.Terrain.Tiles)) > 22 {
					return false
				}
			}
		}
		if role == "forest" {
			if !sceneTreeGround(g, x, y) || g.Spec.Scene.Brief.Forest == "legacy-control" && !sceneForestHabitat(g, x, y) {
				return false
			}
			minDist := 64.
			for _, c := range l.Cohorts {
				if c.ID == recipe {
					minDist = max(64, c.MinimumSpacing)
					if c.ThinClosePairs && src.CreationNumber%2 == 0 {
						minDist = max(minDist, c.ClosePairSpacing)
					}
				}
			}
			if g.Spec.Scene.Brief.Forest == "legacy-control" {
				minDist = 165
			}
			for _, d := range freeTrees {
				if math.Hypot(x-float64(d.Position[0]), y-float64(d.Position[1])) < minDist {
					return false
				}
			}
		}
		d := src
		d.Position = [3]float32{float32(x), float32(y), float32(z + groundOffset)}
		if policy == "water-offset" {
			d.Position[2] = float32(g.Water + waterOffset)
		}
		d.Rotation = float32(math.Mod(float64(src.Rotation)+angle+2*math.Pi, 2*math.Pi))
		if fixed, err := strconv.ParseFloat(a.Fields["fixedrot"], 64); err == nil && fixed >= 0 {
			d.Rotation = float32(fixed * math.Pi / 180)
		}
		if a.Pathing != nil && a.Kind == "doodad" {
			d.Rotation = float32(math.Mod(math.Round(float64(d.Rotation)/(math.Pi/2))*math.Pi/2, math.Pi*2))
		}
		d.Flags = 2
		if policy == "water-offset" || math.Abs(groundOffset) > .002 {
			d.Flags |= 4
		}
		next := uint32(0)
		if role == "forest" {
			nextTree++
			next = nextTree
		} else {
			nextEnvironment++
			next = nextEnvironment
		}
		d.CreationNumber = next
		result = append(result, d)
		prov = append(prov, Provenance{next, src.CreationNumber, recipe, recipe, role})
		used[key] = true
		if role == "forest" {
			freeTrees = append(freeTrees, d)
		}
		return true
	}
	rng := rand.New(rand.NewSource(sceneSeed(g.Spec.Scene.ForestSeed, "forest", "groups")))
	centers := [][2]float64{}
	land := 0
	for _, t := range g.Map.Terrain.Tiles {
		if float64(t.FinalZ()) > g.Water+65 {
			land++
		}
	}
	target := min(1600, max(200, land/7))
	if g.Spec.Scene.Brief.Forest == "legacy-control" {
		pool := []doodadsdoo.Doodad{}
		for _, c := range l.Cohorts {
			for _, id := range c.SourceIDs {
				pool = append(pool, source[id])
			}
		}
		for trial := 0; trial < target*40 && len(freeTrees) < target; trial++ {
			d := pool[rng.Intn(len(pool))]
			x := -11008 + rng.Float64()*22016
			y := -2816 + rng.Float64()*9728
			place(d, x, y, rng.Float64()*2*math.Pi, "forest", "control-scatter", "ground-offset", 0, 0)
		}
	} else {
		for trial := 0; trial < 5000 && len(freeTrees) < target; trial++ {
			cohort := l.Cohorts[rng.Intn(len(l.Cohorts))]
			anchor := source[cohort.SourceIDs[rng.Intn(len(cohort.SourceIDs))]]
			if cohort.AnchorNeighborMax > 0 {
				paired := []uint32{}
				for _, id := range cohort.SourceIDs {
					a := source[id]
					for _, other := range cohort.SourceIDs {
						b := source[other]
						if id != other && math.Hypot(float64(a.Position[0]-b.Position[0]), float64(a.Position[1]-b.Position[1])) <= cohort.AnchorNeighborMax {
							paired = append(paired, id)
							break
						}
					}
				}
				if len(paired) > 0 {
					anchor = source[paired[rng.Intn(len(paired))]]
				}
			}
			dest := [2]float64{math.Round((-11008+rng.Float64()*22016)/128) * 128, math.Round((-2816+rng.Float64()*9728)/128) * 128}
			if !sceneForestHabitat(g, dest[0], dest[1]) || !sceneFree(g, plan, dest[0], dest[1], 96) {
				continue
			}
			clear := true
			for _, c := range centers {
				if dist(c, dest) < 610 {
					clear = false
					break
				}
			}
			if !clear {
				continue
			}
			angle := rng.Intn(4) * 90
			pivot := [2]float64{float64(anchor.Position[0]), float64(anchor.Position[1])}
			before := len(freeTrees)
			for _, id := range cohort.SourceIDs {
				d := source[id]
				xy := [2]float64{float64(d.Position[0]), float64(d.Position[1])}
				if dist(xy, pivot) > 360 {
					continue
				}
				p := turnPoint(xy, pivot, dest, angle)
				place(d, p[0], p[1], float64(angle)*math.Pi/180, "forest", cohort.ID, "ground-offset", 0, 0)
			}
			if len(freeTrees) > before {
				centers = append(centers, dest)
			}
		}
	}
	// Environment has its own streams, so control/experimental forests keep the
	// same terrain, architecture and environmental placement proposals.
	for _, recipe := range l.Recipes {
		if recipe.Habitat == "forest" {
			continue
		}
		random := rand.New(rand.NewSource(sceneSeed(g.Spec.Seed, "environment", recipe.ID)))
		count := min(500, max(2, int(float64(len(recipe.SourceIDs))*float64(land)/5500*recipe.Density)))
		placed := 0
		for trial := 0; trial < count*100 && placed < count; trial++ {
			src := source[recipe.SourceIDs[random.Intn(len(recipe.SourceIDs))]]
			x := -11264 + random.Float64()*22528
			y := -3072 + random.Float64()*10240
			z := g.height(x, y, g.Map.Terrain.Tiles)
			i := g.index(x, y)
			if i < 0 {
				continue
			}
			switch recipe.Habitat {
			case "shallow-water":
				if z < g.Water-85 || z > g.Water-8 {
					continue
				}
			case "shore":
				if z < g.Water-20 || z > g.Water+75 {
					continue
				}
			case "rocky":
				if z < g.Water+15 || (src.TypeID != "ZRbd" && src.TypeID != "ZRbs" && g.Map.Terrain.Tiles[i].GroundTexture != 5) {
					continue
				}
			default:
				if z < g.Water+40 || !sceneForestHabitat(g, x, y) {
					continue
				}
			}
			sx, sy := float64(src.Position[0]), float64(src.Position[1])
			offset := float64(src.Position[2]) - g.height(sx, sy, g.Original)
			if place(src, x, y, random.Float64()*2*math.Pi, "environment", recipe.ID, recipe.HeightPolicy, float64(src.Position[2])-g.Water, offset) {
				placed++
			}
		}
		if placed == 0 {
			return nil, nil, ForestMetrics{}, fmt.Errorf("no habitat for recipe %s", recipe.ID)
		}
	}
	if len(result) > g.Spec.Scene.MaxObjects {
		return nil, nil, ForestMetrics{}, fmt.Errorf("object budget exceeded: %d", len(result))
	}
	return result, prov, forestMetrics(freeTrees), nil
}
