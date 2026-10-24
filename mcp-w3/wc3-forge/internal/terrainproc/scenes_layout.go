package terrainproc

import (
	"fmt"
	"math"
	"math/rand"
	"slices"
	"sort"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
)

func turnPoint(p, pivot, destination [2]float64, degrees int) [2]float64 {
	x, y := p[0]-pivot[0], p[1]-pivot[1]
	switch ((degrees % 360) + 360) % 360 {
	case 90:
		x, y = -y, x
	case 180:
		x, y = -x, -y
	case 270:
		x, y = y, -x
	}
	return [2]float64{x + destination[0], y + destination[1]}
}
func turnRect(r Rect, pivot, dest [2]float64, angle int) Rect {
	a := turnPoint(r.Min, pivot, dest, angle)
	b := turnPoint(r.Max, pivot, dest, angle)
	return Rect{[2]float64{min(a[0], b[0]), min(a[1], b[1])}, [2]float64{max(a[0], b[0]), max(a[1], b[1])}}
}
func scenePrefab(l Library, id string) Prefab {
	for _, p := range l.Prefabs {
		if p.ID == id {
			return p
		}
	}
	return Prefab{}
}
func sceneComponent(l SceneLibrary, id string) SceneComponent {
	for _, p := range l.Components {
		if p.ID == id {
			return p
		}
	}
	return SceneComponent{}
}

func sceneLayout(s Spec, l SceneLibrary, built Library, attempt int) (Layout, error) {
	plan := Layout{Format: "wc3-layout-v2", Seed: s.Seed, Attempt: attempt}
	rng := rand.New(rand.NewSource(sceneSeed(s.Seed, "layout", fmt.Sprint(attempt))))
	order := slices.Clone(s.Scene.Instances)
	sort.SliceStable(order, func(i, j int) bool {
		a, b := scenePrefab(built, order[i].Family), scenePrefab(built, order[j].Family)
		ak, bk := sceneComponent(l, a.ID).Kind, sceneComponent(l, b.ID).Kind
		if ak != bk {
			return ak == "main"
		}
		return (a.Source.Max[0]-a.Source.Min[0]+2*a.Blend)*(a.Source.Max[1]-a.Source.Min[1]+2*a.Blend) > (b.Source.Max[0]-b.Source.Min[0]+2*b.Blend)*(b.Source.Max[1]-b.Source.Min[1]+2*b.Blend)
	})
	bounds := expandRect(s.Edit, -640)
	for _, instance := range order {
		p := scenePrefab(built, instance.Family)
		c := sceneComponent(l, instance.Family)
		if p.ID == "" || !slices.Contains(p.Rotations, instance.Rotation) {
			return plan, fmt.Errorf("unknown/ineligible instance %s", instance.ID)
		}
		placed := false
		for trial := 0; trial < 600; trial++ {
			center := [2]float64{-10880 + rng.Float64()*21760, -2688 + rng.Float64()*9472}
			if c.Kind == "micro" && trial < 450 {
				parent := plan.Placements[rng.Intn(len(plan.Placements))]
				if parent.Kind != "main" {
					continue
				}
				a := rng.Float64() * 2 * math.Pi
				d := 1800 + rng.Float64()*2200
				center = [2]float64{parent.Center[0] + math.Cos(a)*d, parent.Center[1] + math.Sin(a)*d}
			}
			offset := [2]float64{math.Round((center[0]-p.Pivot[0])/128) * 128, math.Round((center[1]-p.Pivot[1])/128) * 128}
			center = [2]float64{p.Pivot[0] + offset[0], p.Pivot[1] + offset[1]}
			if dist(center, p.Pivot) < s.Recompose.MinDisplacement {
				continue
			}
			q := Placement{ID: instance.ID, Family: p.ID, Kind: c.Kind, Rotation: instance.Rotation, Variant: instance.Variant, Center: center, Offset: offset, Core: turnRect(p.Source, p.Pivot, center, instance.Rotation), Anchors: map[string][2]float64{}, Phase: rng.Float64() * 2 * math.Pi, Radius: [2]float64{2100 + rng.Float64()*550, 1650 + rng.Float64()*450}}
			if p.ID == "lagoon" {
				q.Radius = [2]float64{2800 + rng.Float64()*350, 2100 + rng.Float64()*300}
			}
			if p.ID == "waterfall" {
				q.Radius = [2]float64{1850 + rng.Float64()*250, 1600 + rng.Float64()*200}
			}
			if c.Kind == "micro" {
				q.Radius = [2]float64{0, 0}
			}
			if c.Kind == "main" && (!bounds.Contains(center[0]-q.Radius[0], center[1]-q.Radius[1]) || !bounds.Contains(center[0]+q.Radius[0], center[1]+q.Radius[1])) {
				continue
			}
			q.Reserve = expandRect(q.Core, p.Blend+64)
			if !bounds.Contains(q.Reserve.Min[0], q.Reserve.Min[1]) || !bounds.Contains(q.Reserve.Max[0], q.Reserve.Max[1]) {
				continue
			}
			conflict := false
			for _, other := range plan.Placements {
				if overlap(q.Reserve, other.Reserve) {
					conflict = true
					break
				}
			}
			if conflict {
				continue
			}
			for key, a := range p.Anchors {
				q.Anchors[key] = turnPoint(a, p.Pivot, center, q.Rotation)
			}
			plan.Placements = append(plan.Placements, q)
			placed = true
			break
		}
		if !placed {
			return plan, fmt.Errorf("packing exhausted for %s", instance.ID)
		}
	}
	for i, a := range plan.Placements {
		if a.Kind != "main" {
			continue
		}
		for _, b := range plan.Placements[i+1:] {
			if b.Kind == "main" && a.Family != b.Family && math.Abs(dist(a.Center, b.Center)-dist(scenePrefab(built, a.Family).Pivot, scenePrefab(built, b.Family).Pivot)) >= 512 {
				plan.ChangedPairs++
			}
		}
	}
	if len(order) > 3 && plan.ChangedPairs < 3 {
		return plan, fmt.Errorf("insufficient changed main distances")
	}
	// Connect flexible instances, never their array positions. Dominant-island
	// briefs connect every ordinary landmark; crossings retain their channels.
	eligible := []Placement{}
	for _, q := range plan.Placements {
		if q.Kind == "main" && q.Family != "bridge" && q.Family != "waterfall" {
			eligible = append(eligible, q)
		}
	}
	if s.Scene.Brief.Silhouette != "scattered" && len(eligible) > 1 {
		connected := map[string]bool{eligible[0].ID: true}
		limit := 2
		if s.Scene.Brief.Silhouette == "dominant-island" {
			limit = len(eligible) - 1
		}
		for len(plan.Connections) < limit && len(connected) < len(eligible) {
			best := math.Inf(1)
			var a, b Placement
			for _, x := range eligible {
				if !connected[x.ID] {
					continue
				}
				for _, y := range eligible {
					if connected[y.ID] {
						continue
					}
					if d := dist(x.Center, y.Center); d < best {
						best = d
						a = x
						b = y
					}
				}
			}
			if s.Scene.Brief.Silhouette == "archipelago" && best > 6000 {
				break
			}
			mid := [2]float64{(a.Center[0]+b.Center[0])/2 + float64(rng.Intn(13)-6)*128, (a.Center[1]+b.Center[1])/2 + float64(rng.Intn(13)-6)*128}
			width := 600.
			if s.Scene.Brief.Silhouette == "dominant-island" {
				width = 1000
			}
			plan.Connections = append(plan.Connections, LandConnection{a.ID, b.ID, [][2]float64{a.Center, mid, b.Center}, width, "scenic"})
			connected[b.ID] = true
		}
	}
	// Small motifs belong to the nearest land mass when close enough. These
	// organic skirts lie outside their exact supports and retain coastal shelves.
	for _, a := range plan.Placements {
		if a.Kind != "micro" {
			continue
		}
		best := math.Inf(1)
		var parent Placement
		for _, b := range plan.Placements {
			if b.Kind == "main" && b.Family != "waterfall" && b.Family != "bridge" {
				d := dist(a.Center, b.Center)
				if d < best {
					best = d
					parent = b
				}
			}
		}
		if best < 4800 {
			mid := [2]float64{(a.Center[0]+parent.Center[0])/2 + 256*math.Sin(a.Phase), (a.Center[1]+parent.Center[1])/2 + 256*math.Cos(a.Phase)}
			plan.Connections = append(plan.Connections, LandConnection{a.ID, parent.ID, [][2]float64{a.Center, mid, parent.Center}, 520, "scenic-micro"})
		}
	}
	for _, link := range s.Scene.Brief.Links {
		var a, b Placement
		for _, q := range plan.Placements {
			if q.ID == link.From {
				a = q
			}
			if q.ID == link.To {
				b = q
			}
		}
		pa, oa := a.Anchors[link.FromPort]
		pb, ob := b.Anchors[link.ToPort]
		if !oa || !ob {
			return plan, fmt.Errorf("link port does not exist")
		}
		plan.Connections = append(plan.Connections, LandConnection{a.ID, b.ID, [][2]float64{pa, pb}, 600, link.Role})
	}
	for n := 0; n < 80 && len(plan.Islets) < 3; n++ {
		c := [2]float64{float64(rng.Intn(160)-80) * 128, float64(rng.Intn(68)-20) * 128}
		ok := true
		for _, q := range plan.Placements {
			if rectDistance(q.Reserve, c[0], c[1]) < 800 {
				ok = false
			}
		}
		for _, q := range plan.Islets {
			if dist(c, q.Center) < 1800 {
				ok = false
			}
		}
		if ok {
			plan.Islets = append(plan.Islets, Placement{ID: fmt.Sprintf("islet-%d", len(plan.Islets)+1), Center: c, Radius: [2]float64{400 + rng.Float64()*400, 350 + rng.Float64()*250}, Phase: rng.Float64() * 6.28})
		}
	}
	return plan, nil
}

func composeScenes(g *Scene, l SceneLibrary, built Library, plan *Layout) ([]doodadsdoo.Doodad, []Provenance, error) {
	major := Library{Ownership: built.Ownership}
	mp := *plan
	mp.Placements = nil
	for _, q := range plan.Placements {
		if q.Kind == "main" {
			major.Prefabs = append(major.Prefabs, scenePrefab(built, q.Family))
			mp.Placements = append(mp.Placements, q)
		} else {
			// A soft, irregular skirt hides rectangular capture bounds; exact
			// heights/materials within the authored core remain untouched.
			p := q
			p.Radius = [2]float64{(q.Core.Max[0]-q.Core.Min[0])/2 + 700, (q.Core.Max[1]-q.Core.Min[1])/2 + 700}
			heights := []float64{}
			for _, t := range scenePrefab(built, q.Family).Support {
				heights = append(heights, float64(t.FinalZ()))
			}
			slices.Sort(heights)
			p.Elevation = max(50, heights[len(heights)/2])
			p.Family = "micro-skirt"
			mp.Islets = append(mp.Islets, p)
		}
	}
	if _, e := composeTerrain(g, major, &mp); e != nil {
		return nil, nil, e
	}
	for _, q := range plan.Placements {
		if q.Kind != "micro" {
			continue
		}
		p := scenePrefab(built, q.Family)
		for i, t := range g.Map.Terrain.Tiles {
			x, y := g.xy(i%193, i/193)
			d := rectDistance(q.Core, x, y)
			if d >= p.Blend {
				continue
			}
			srcxy := turnPoint([2]float64{x, y}, q.Center, p.Pivot, 360-q.Rotation)
			si := g.index(srcxy[0], srcxy[1])
			if si < 0 {
				continue
			}
			src := g.Original[si]
			weight := 1 - smooth(d/p.Blend)
			z := float64(t.FinalZ())*(1-weight) + float64(src.FinalZ())*weight
			if d == 0 {
				t = src
				t.Boundary = false
				t.Flags &^= 8
			} else if weight > .55 {
				t.GroundTexture = src.GroundTexture
				t.TextureDetails = src.TextureDetails
			}
			setGround(&t, z)
			if d > 0 {
				if z < g.Water+16 {
					t.Flags |= 4
				} else {
					t.Flags &^= 4
				}
			}
			g.Map.Terrain.Tiles[i] = t
		}
	}
	pieces := []doodadsdoo.Doodad{}
	provenance := []Provenance{}
	next := uint32(10000)
	for _, q := range plan.Placements {
		p := scenePrefab(built, q.Family)
		c := sceneComponent(l, q.Family)
		rng := rand.New(rand.NewSource(sceneSeed(g.Spec.Seed, "ornaments", q.ID)))
		for _, src := range p.Pieces {
			role := "essential"
			if slices.Contains(c.Optional, src.CreationNumber) {
				role = "ornament"
				if q.Variant == 1 && rng.Float64() < .23 {
					continue
				}
			}
			d := adjustedPrefabPiece(g, p, src)
			xy := turnPoint([2]float64{float64(d.Position[0]), float64(d.Position[1])}, p.Pivot, q.Center, q.Rotation)
			d.Position[0] = float32(xy[0])
			d.Position[1] = float32(xy[1])
			if q.Rotation != 0 {
				angle := math.Mod(float64(d.Rotation)+float64(q.Rotation)*math.Pi/180, 2*math.Pi)
				quarter := math.Round(angle/(math.Pi/2)) * math.Pi / 2
				if math.Abs(angle-quarter) < .00001 {
					angle = math.Mod(quarter, 2*math.Pi)
				}
				d.Rotation = float32(angle)
			}
			// Bit 4 preserves authored custom height on native editor save.
			// Rigid compositions must retain it (bridges and waterfalls depend on it).
			d.Flags &^= 1 // Editor-only donor placement bit; keep custom-height bit 4.
			next++
			d.CreationNumber = next
			pieces = append(pieces, d)
			provenance = append(provenance, Provenance{next, src.CreationNumber, q.ID, q.Family, role})
		}
	}
	inter, union := 0, 0
	plan.SourceLand = 0
	plan.OutputLand = 0
	for y := 0; y < 96; y++ {
		for x := 0; x < 192; x++ {
			i := x + y*193
			a, b := float64(g.Original[i].FinalZ()) >= g.Water, float64(g.Map.Terrain.Tiles[i].FinalZ()) >= g.Water
			if a {
				plan.SourceLand++
			}
			if b {
				plan.OutputLand++
			}
			if a && b {
				inter++
			}
			if a || b {
				union++
			}
		}
	}
	plan.SourceIoU = float64(inter) / float64(max(1, union))
	if plan.SourceIoU > g.Spec.Recompose.MaxSourceIoU {
		return nil, nil, fmt.Errorf("source IoU %.3f exceeds budget", plan.SourceIoU)
	}
	return pieces, provenance, nil
}

func buildSceneBase(s Spec) (*Scene, SceneLibrary, Library, Layout, []doodadsdoo.Doodad, []Provenance, error) {
	g, e := recomposeScene(s)
	if e != nil {
		return nil, SceneLibrary{}, Library{}, Layout{}, nil, nil, e
	}
	l, b, e := loadSceneLibrary(g)
	if e != nil {
		return nil, l, b, Layout{}, nil, nil, e
	}
	donors := g.Map.Doodads.Doodads
	reject := []string{}
	for attempt := 0; attempt < s.Recompose.LayoutAttempts; attempt++ {
		plan, e := sceneLayout(s, l, b, attempt)
		if e != nil {
			reject = append(reject, e.Error())
			continue
		}
		pieces, prov, e := composeScenes(g, l, b, &plan)
		if e != nil {
			reject = append(reject, e.Error())
			continue
		}
		g.Map.Doodads.Doodads = pieces
		cells := staticRecomposePathing(g)
		e = createLocalRoutes(g, &plan, cells)
		g.Map.Doodads.Doodads = donors
		if e != nil {
			reject = append(reject, e.Error())
			continue
		}
		if plan.Start == [2]float64{} {
			return nil, l, b, plan, nil, nil, fmt.Errorf("brief has no walking/start anchor")
		}
		plan.Rejections = reject
		return g, l, b, plan, pieces, prov, nil
	}
	return nil, l, b, Layout{Rejections: reject}, nil, nil, fmt.Errorf("layout search exhausted: %v", reject)
}
