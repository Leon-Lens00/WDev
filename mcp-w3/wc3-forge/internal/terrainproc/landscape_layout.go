package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"math"
	"math/rand"
	"slices"
)

type LandscapeReach struct {
	ID                     string       `json:"id"`
	From                   string       `json:"from"`
	To                     string       `json:"to"`
	Points                 [][2]float64 `json:"points"`
	Width                  float64      `json:"width"`
	Surface                float64      `json:"surface"`
	Length                 float64      `json:"length"`
	OutletConnectionLength float64      `json:"outlet_connection_length"`
	OutletConnectionEnd    [2]float64   `json:"outlet_connection_end"`
}
type LandBody struct {
	ID     string       `json:"id"`
	Spine  [][2]float64 `json:"spine"`
	Width  float64      `json:"width"`
	Height float64      `json:"height"`
}
type LandscapePlan struct {
	Layout
	Landforms *LandscapeLandformCompiled `json:"landforms,omitempty"`
	Bodies    []LandBody                 `json:"bodies"`
	Reaches   []LandscapeReach           `json:"reaches"`
	Ownership []string                   `json:"vertex_ownership"`
	Masks     []string                   `json:"vertex_masks"`
	Habitat   []string                   `json:"vertex_habitats"`
	Clearings []Rect                     `json:"clearings"`
}

func landscapePlacement(p LandscapePlan, id string) Placement {
	for _, q := range p.Placements {
		if q.ID == id {
			return q
		}
	}
	return Placement{}
}
func lineDistance(points [][2]float64, x, y float64) float64 {
	if len(points) == 1 {
		return dist(points[0], [2]float64{x, y})
	}
	return (Spec{Path: points}).PathDistance(x, y)
}

// Geography is prescribed at territorial scale first. Instances are anchored to
// that coordinate system; the seed moves a whole group, never packs islands per object.
func landscapeLayout(g *Scene, l SceneLibrary, lib Library, attempt int) (LandscapePlan, error) {
	s := g.Spec
	p := LandscapePlan{Layout: Layout{Format: "wc3-landscape-layout-v1", Seed: s.Seed, Attempt: attempt}}
	rng := rand.New(rand.NewSource(sceneSeed(s.Landscape.Streams["layout"], "attempt", fmt.Sprint(attempt))))
	shift := [2]float64{float64(rng.Intn(7)-3) * 128, float64(rng.Intn(5)-2) * 128}
	centers := map[string][2]float64{
		"circle-1": {-5504, 4096}, "temple-1": {5504, -1024}, "platform-1": {8832, 4864}, "platform-2": {-2560, 6144},
		"waterfall-1": {3072, 5376}, "waterfall-2": {5888, -1536}, "lagoon-1": {-4992, -768}, "bridge-1": {-192, 2176},
		"broken-statue-hill-1": {-9472, -1792}, "statue-east-1": {10112, 0}, "hut-islet-1": {-10112, 6016},
		"statue-cape-1": {-9472, 2432}, "huts-pair-1": {640, 6656}, "rock-pillar-1": {6272, 6784}, "monolith-1": {3840, 2176},
		"barricade-nw-1": {-2304, 4096}, "barricade-ne-1": {6528, 2688}, "barricade-sw-1": {2432, -1920}, "barricade-se-1": {-1536, -1792},
	}
	if s.Landscape.Brief.ID == "E" {
		centers["circle-1"] = [2]float64{-6656, 4608}
		centers["lagoon-1"] = [2]float64{-5632, -1280}
		centers["platform-1"] = [2]float64{7936, 4224}
		centers["platform-2"] = [2]float64{-3072, 6144}
		centers["temple-1"] = [2]float64{4480, -1024}
		centers["monolith-1"] = [2]float64{4096, 2432}
		centers["barricade-nw-1"] = [2]float64{-3456, 2816}
		centers["barricade-se-1"] = [2]float64{-3840, 896}
	}
	if s.Landscape.Brief.ID == "F" {
		centers["circle-1"] = [2]float64{-512, 4736}
		centers["lagoon-1"] = [2]float64{-5248, 1792}
		centers["waterfall-1"] = [2]float64{5760, 4992}
		centers["waterfall-2"] = [2]float64{5504, -1408}
		centers["statue-cape-1"] = [2]float64{-8064, 4736}
		centers["monolith-1"] = [2]float64{-1152, 1024}
		centers["barricade-nw-1"] = [2]float64{-3968, 5888}
		centers["huts-pair-1"] = [2]float64{3072, 1920}
		centers["barricade-ne-1"] = [2]float64{8576, 5376}
		centers["barricade-sw-1"] = [2]float64{-4224, -1408}
		centers["barricade-se-1"] = [2]float64{512, -1664}
		centers["rock-pillar-1"] = [2]float64{8832, 768}
		centers["statue-east-1"] = [2]float64{10048, -1792}
		centers["hut-islet-1"] = [2]float64{-10368, 768}
	}
	// Different land spines are part of each brief's prescribed territorial character.
	spines := [][][2]float64{{{-9600, 2304}, {-5632, 4096}, {-1280, 3840}, {4352, 2048}, {8832, 4224}}, {{-6656, -768}, {-2304, -1536}, {3456, -1024}, {6272, -1024}}, {{-2304, -1536}, {-1280, 3840}}, {{4352, 2048}, {3072, 6144}, {6656, 6528}}}
	if s.Landscape.Brief.ID == "E" {
		spines = [][][2]float64{{{-9600, 2688}, {-6656, 4608}, {-3072, 5504}, {1920, 4864}, {7936, 4224}}, {{-5632, -1280}, {-2816, 1792}, {1024, 2304}, {4480, -1024}, {6912, 1536}}, {{1920, 4864}, {6912, 1536}}}
	}
	if s.Landscape.Brief.ID == "F" {
		spines = [][][2]float64{{{-8064, 4608}, {-3840, 5632}, {-512, 4736}, {5760, 4992}, {8704, 4224}}, {{-5248, 1792}, {-1280, 1024}, {3072, 1920}, {8704, 768}}, {{-4224, -1408}, {512, -1664}, {5504, -1408}}, {{-4224, -1408}, {-3840, 5632}}, {{3072, 1920}, {5504, -1408}}}
	}
	if s.Landscape.Brief.ID != "F" {
		spines = append(spines, [][2]float64{{-5504, 4608}, {-3328, 6400}, {640, 6400}, {3072, 6400}})
	}
	if s.Landscape.Brief.ID == "F" {
		spines = append(spines, [][2]float64{{8704, 4224}, {8704, 768}, {7424, -1024}})
	}
	for n, sp := range spines {
		for k := range sp {
			sp[k][0] += shift[0]
			sp[k][1] += shift[1]
		}
		width := 1850.
		if s.Landscape.Brief.ID == "E" {
			width = 2100
		}
		if s.Landscape.Brief.ID == "F" {
			width = 1550
		}
		p.Bodies = append(p.Bodies, LandBody{fmt.Sprintf("territory-ridge-%d", n), sp, width, 130 + float64(n%3)*45})
	}
	for _, i := range s.Scene.Instances {
		f := scenePrefab(lib, i.Family)
		c := sceneComponent(l, i.Family)
		center, ok := centers[i.ID]
		if !ok {
			return p, fmt.Errorf("no territorial anchor for %s", i.ID)
		}
		// Preserve donor vertex and pathing phase; no non-grid structural translation.
		for k := 0; k < 2; k++ {
			center[k] = f.Pivot[k] + math.Round((center[k]+shift[k]-f.Pivot[k])/128)*128
		}
		q := Placement{ID: i.ID, Family: i.Family, Kind: c.Kind, Center: center, Rotation: 0, Variant: i.Variant, Anchors: map[string][2]float64{}}
		q.Offset = [2]float64{center[0] - f.Pivot[0], center[1] - f.Pivot[1]}
		q.Core = turnRect(f.Source, f.Pivot, center, 0)
		q.Reserve = expandRect(q.Core, 768)
		for name, a := range f.Anchors {
			q.Anchors[name] = [2]float64{a[0] + q.Offset[0], a[1] + q.Offset[1]}
		}
		if _, ok := q.Anchors["center"]; !ok {
			q.Anchors["center"] = center
		}
		q.Anchors["inflow"] = [2]float64{q.Core.Min[0] + 128, center[1] + 128}
		if !expandRect(s.Edit, -640).Contains(q.Core.Min[0], q.Core.Min[1]) || !expandRect(s.Edit, -640).Contains(q.Core.Max[0], q.Core.Max[1]) {
			return p, fmt.Errorf("territory out of bounds %s", i.ID)
		}
		for _, other := range p.Placements {
			if rectanglesOverlap(expandRect(q.Core, 64), other.Core) {
				return p, fmt.Errorf("rigid overlap %s/%s", q.ID, other.ID)
			}
		}
		p.Placements = append(p.Placements, q)
	}
	for _, group := range s.Landscape.Brief.Groups {
		if group.Isolated {
			q := landscapePlacement(p, group.Parent)
			p.Bodies = append(p.Bodies, LandBody{group.ID, [][2]float64{q.Center}, 1100, 90})
		}
	}
	lagoon := landscapePlacement(p, "lagoon-1")
	bridge := landscapePlacement(p, "bridge-1")
	for _, r := range s.Landscape.Brief.Relations {
		if r.Kind != "feeds" {
			continue
		}
		q := landscapePlacement(p, r.From)
		start := q.Anchors["outlet"]
		in := lagoon.Anchors["inflow"]
		reach := LandscapeReach{ID: r.ID, From: r.From, To: r.To, Width: r.Width, Surface: g.Water}
		extra := 512. + float64(q.Variant)*1024
		if bridge.ID != "" {
			off := bridge.Offset
			entry := [2]float64{-4864 + off[0], 6400 + off[1]}
			exit := [2]float64{-3712 + off[0], 4480 + off[1]}
			reach.Points = [][2]float64{start, {q.Core.Min[0] - extra, start[1]}, {entry[0], start[1]}, entry,
				{-4736 + off[0], 6272 + off[1]}, {-4544 + off[0], 6016 + off[1]}, {-4416 + off[0], 5760 + off[1]}, {-4224 + off[0], 5504 + off[1]}, {-4096 + off[0], 5248 + off[1]}, {-3904 + off[0], 4864 + off[1]}, exit,
			}
			reach.Points = append(reach.Points, landscapeLagoonApproach(lagoon, 0, -math.Pi, 768)...)
			reach.Points = append(reach.Points, in, lagoon.Center)
		} else {
			angle := -math.Pi / 2
			if q.ID == "waterfall-1" {
				angle = math.Pi / 2
			}
			endAngle := math.Copysign(math.Pi, angle)
			approach := landscapeLagoonApproach(lagoon, angle, endAngle, 384)
			reach.Points = [][2]float64{start, {q.Core.Min[0] - extra, start[1]}, {q.Core.Min[0] - extra, approach[0][1]}}
			reach.Points = append(reach.Points, approach...)
			reach.Points = append(reach.Points, in, lagoon.Center)
		}
		// The first outlet connection is the adaptable module. Measure the emitted
		// polyline to its first bend, separately from the total watershed length.
		connectionBend := reach.Points[1]
		reach.Points = roundLandscapeReach(reach.Points, p.Placements)
		reach.Points = meanderLandscapeReach(reach.Points, p.Placements, s.Landscape.Streams["water"])
		nearestBend := math.Inf(1)
		for n := 1; n < len(reach.Points); n++ {
			reach.Length += dist(reach.Points[n-1], reach.Points[n])
			if d := dist(reach.Points[n], connectionBend); d < nearestBend {
				nearestBend = d
				reach.OutletConnectionLength = reach.Length
				reach.OutletConnectionEnd = reach.Points[n]
			}
		}
		p.Reaches = append(p.Reaches, reach)
	}
	return p, nil
}

// Follow the basin's shore instead of outlining its rectangular crop. The
// authored wet inlet stays fixed; only the outside channel can bend.
func landscapeLagoonApproach(lagoon Placement, from, to, bank float64) [][2]float64 {
	rx := (lagoon.Core.Max[0]-lagoon.Core.Min[0])/2 + 896
	ry := (lagoon.Core.Max[1]-lagoon.Core.Min[1])/2 + bank
	points := [][2]float64{}
	steps := int(math.Ceil(math.Abs(to-from) * max(rx, ry) / 128))
	for n := 0; n <= steps; n++ {
		a := from + (to-from)*float64(n)/float64(steps)
		cx, sy := math.Cos(a), math.Sin(a)
		if bank < 768 {
			// With narrow north/south room, keep the curve outside the
			// preserved bank corners instead of cutting a diagonal through them.
			cx = math.Copysign(math.Sqrt(math.Abs(cx)), cx)
			sy = math.Copysign(math.Sqrt(math.Abs(sy)), sy)
		}
		points = append(points, [2]float64{lagoon.Center[0] + rx*cx, lagoon.Center[1] + ry*sy})
	}
	return points
}

func roundLandscapeReach(points [][2]float64, placements []Placement) [][2]float64 {
	if len(points) < 3 {
		return points
	}
	out := [][2]float64{points[0]}
	for n := 1; n < len(points)-1; n++ {
		a, b, c := points[n-1], points[n], points[n+1]
		protected := false
		for _, q := range placements {
			if expandRect(q.Core, 192).Contains(b[0], b[1]) {
				protected = true
				break
			}
		}
		if protected {
			out = append(out, b)
			continue
		}
		radius := min(512., min(dist(a, b), dist(b, c))*.4)
		start, end := b, b
		for k := 0; k < 2; k++ {
			start[k] = b[k] + (a[k]-b[k])*radius/max(1., dist(a, b))
			end[k] = b[k] + (c[k]-b[k])*radius/max(1., dist(b, c))
		}
		out = append(out, start)
		for j := 1; j <= 8; j++ {
			t := float64(j) / 8
			out = append(out, [2]float64{(1-t)*(1-t)*start[0] + 2*(1-t)*t*b[0] + t*t*end[0], (1-t)*(1-t)*start[1] + 2*(1-t)*t*b[1] + t*t*end[1]})
		}
	}
	return append(out, points[len(points)-1])
}

func meanderLandscapeReach(points [][2]float64, placements []Placement, seed int) [][2]float64 {
	out := [][2]float64{points[0]}
	for n := 1; n < len(points); n++ {
		a, b := points[n-1], points[n]
		length := dist(a, b)
		count := max(1, int(math.Ceil(length/128)))
		for j := 1; j <= count; j++ {
			t := float64(j) / float64(count)
			xy := [2]float64{a[0] + t*(b[0]-a[0]), a[1] + t*(b[1]-a[1])}
			if length > 1024 {
				amp := float64(96+seed%97) * math.Sin(t*math.Pi*2) * math.Sin(t*math.Pi)
				candidate := [2]float64{xy[0] - (b[1]-a[1])/length*amp, xy[1] + (b[0]-a[0])/length*amp}
				safe := true
				for _, q := range placements {
					if expandRect(q.Core, 256).Contains(candidate[0], candidate[1]) {
						safe = false
						break
					}
				}
				if safe {
					xy = candidate
				}
			}
			out = append(out, xy)
		}
	}
	return out
}
func rectanglesOverlap(a, b Rect) bool {
	return a.Min[0] < b.Max[0] && a.Max[0] > b.Min[0] && a.Min[1] < b.Max[1] && a.Max[1] > b.Min[1]
}

func landscapeTerrain(g *Scene, p *LandscapePlan, lib Library) {
	p.Ownership = make([]string, len(g.Original))
	p.Masks = make([]string, len(g.Original))
	for i := range g.Original {
		x, y := g.xy(i%193, i/193)
		z := -210.
		owner := "ocean"
		for _, b := range p.Bodies {
			d := lineDistance(b.Spine, x, y)
			edge := b.Width * (1 + .075*math.Sin(x/831+float64(g.Spec.Landscape.Streams["relief"]%17)) + .05*math.Sin(y/547))
			h := -210 + (b.Height+210)*smooth((edge-d)/800)
			if h > z {
				z = h
				owner = b.ID
			}
		}
		z += 24 * math.Sin(x/1100) * math.Cos(y/770) * smooth((z+85)/160)
		edge := min(x+11776, 11776-x, y+3584-192*(1+math.Sin(x/1430)), 7680-y-192*(1+math.Sin(x/1180)))
		z = -210 + (z+210)*smooth(edge/896)
		t := w3e.Tilepoint{WaterLevel: 8192, LayerHeight: 1, CliffTexture: 1, GroundTexture: 3, Flags: 4, Boundary: x < -11776 || x >= 11776 || y < -3584 || y >= 7680}
		if t.Boundary {
			z = -210
		}
		setGround(&t, z)
		g.Map.Terrain.Tiles[i] = t
		p.Ownership[i] = owner
		p.Masks[i] = "territorial"
	}
	supports := landscapeSupports(g, *p, lib)
	// Blend from nonrectangular authored supports. Nearest-support ownership is
	// deterministic; only outer bands may overlap, never their preserved vertices.
	for i, t := range g.Map.Terrain.Tiles {
		x, y := g.xy(i%193, i/193)
		own, point, best := nearestLandscapeSupport(supports, x, y)
		if best > 896 || t.Boundary {
			continue
		}
		sx, sy := point[0]-own.Offset[0], point[1]-own.Offset[1]
		src := g.Original[g.index(sx, sy)]
		weight := 1 - smooth(best/896)
		z := float64(t.FinalZ())
		if best == 0 {
			t = src
			t.Boundary = false
			t.Flags &^= 8
			p.Masks[i] = "rigid"
		} else {
			z = z*(1-weight) + landscapeSupportHeight(g, supports, own, x, y, best)*weight
			p.Masks[i] = "transition"
			if weight > .65 {
				t.GroundTexture = src.GroundTexture
			}
			setGround(&t, z)
		}
		g.Map.Terrain.Tiles[i] = t
		p.Ownership[i] = own.ID
	}
	// Carve only adaptable territory. Rigid water portions must connect through
	// their real source bathymetry and are checked independently after export.
	for i, t := range g.Map.Terrain.Tiles {
		if p.Masks[i] == "rigid" || t.Boundary {
			continue
		}
		x, y := g.xy(i%193, i/193)
		d := math.Inf(1)
		width := 384.
		for _, r := range p.Reaches {
			n := lineDistance(r.Points, x, y)
			if n < d {
				d = n
				width = r.Width
			}
		}
		if d < width/2+384 {
			z := float64(t.FinalZ())
			bed := g.Water - 96.
			weight := 1 - smooth((d-width/2)/384)
			setGround(&t, z*(1-weight)+bed*weight)
			t.Flags |= 4
			t.WaterLevel = 8192
			t.GroundTexture = 3
			p.Masks[i] = "water-adaptable"
			p.Ownership[i] = "watershed"
			g.Map.Terrain.Tiles[i] = t
		}
	}
}

func landscapeParts(g *Scene, l SceneLibrary, lib Library, p LandscapePlan) ([]doodadsdoo.Doodad, []Provenance, error) {
	var library LandscapeLibrary
	if e := strictJSON(g.Spec.Landscape.Library, &library); e != nil {
		return nil, nil, e
	}
	parts := []doodadsdoo.Doodad{}
	prov := []Provenance{}
	next := uint32(10000)
	for _, q := range p.Placements {
		f := scenePrefab(lib, q.Family)
		c := sceneComponent(l, q.Family)
		ornaments := rand.New(rand.NewSource(sceneSeed(g.Spec.Landscape.Streams["ornaments"], "orientation", q.ID)))
		for _, src := range f.Pieces {
			d := adjustedPrefabPiece(g, f, src)
			policy := "absolute-rigid"
			parentID := uint32(0)
			delta := [2]float64{}
			for _, m := range library.Modules {
				if m.Family != q.Family {
					continue
				}
				for k, id := range m.Members {
					if src.CreationNumber == id {
						delta = m.Shifts[q.Variant][k]
						policy = m.Policy
						parentID = m.Parent
					}
				}
			}
			sx, sy := float64(d.Position[0]), float64(d.Position[1])
			x, y := sx+q.Offset[0]+delta[0], sy+q.Offset[1]+delta[1]
			d.Position[0] = float32(x)
			d.Position[1] = float32(y)
			oldParent, newParent := 0., 0.
			if parentID != 0 {
				for _, pd := range f.Pieces {
					if pd.CreationNumber == parentID {
						oldParent = float64(pd.Position[2])
						newParent = oldParent
					}
				}
			}
			oldTile := g.Original[g.index(sx, sy)]
			oldWater := float64(oldTile.WaterZ()) + g.Water
			newTile := g.Map.Terrain.Tiles[g.index(x, y)]
			newWater := float64(newTile.WaterZ()) + g.Water
			z, err := landscapeHeight(policy, float64(d.Position[2]), g.height(sx, sy, g.Original), g.height(x, y, g.Map.Terrain.Tiles), oldWater, newWater, oldParent, newParent)
			if err != nil {
				return nil, nil, err
			}
			d.Position[2] = float32(z)
			d.Flags &^= 1
			if delta != [2]float64{} {
				d.Flags |= 4
			}
			next++
			d.CreationNumber = next
			role := "essential"
			if slices.Contains(c.Optional, src.CreationNumber) {
				role = "ornament"
				if g.Catalog.Assets[src.TypeID].Pathing == nil {
					d.Rotation = float32(math.Mod(float64(d.Rotation)+float64(ornaments.Intn(4))*math.Pi/2, 2*math.Pi))
				}
			}
			parts = append(parts, d)
			prov = append(prov, Provenance{next, src.CreationNumber, q.ID, q.Family, role})
		}
	}
	return parts, prov, nil
}

func buildLandscapeBase(s Spec) (*Scene, SceneLibrary, Library, LandscapePlan, []doodadsdoo.Doodad, []Provenance, error) {
	g, e := recomposeScene(s)
	if e != nil {
		return nil, SceneLibrary{}, Library{}, LandscapePlan{}, nil, nil, e
	}
	l, lib, e := loadSceneLibrary(g)
	if e != nil {
		return nil, l, lib, LandscapePlan{}, nil, nil, e
	}
	source := slices.Clone(g.Map.Doodads.Doodads)
	rejections := []string{}
	attempts := s.Recompose.LayoutAttempts
	if s.Landscape.Landforms != nil {
		attempts = min(attempts, s.Landscape.Landforms.MaxCandidates)
	}
	for attempt := 0; attempt < attempts; attempt++ {
		p, e := landscapeLayout(g, l, lib, attempt)
		if e != nil {
			rejections = append(rejections, e.Error())
			continue
		}
		if s.Landscape.Landforms == nil {
			landscapeTerrain(g, &p, lib)
		} else if e := landscapeLandformTerrain(g, &p, lib); e != nil {
			rejections = append(rejections, e.Error())
			continue
		}
		parts, prov, e := landscapeParts(g, l, lib, p)
		if e != nil {
			return nil, l, lib, p, nil, nil, e
		}
		g.Map.Doodads.Doodads = parts
		cells := staticLandscapePathing(g)
		e = createLocalRoutes(g, &p.Layout, cells)
		if e == nil {
			e = landscapeAccess(g, &p, cells)
		}
		g.Map.Doodads.Doodads = source
		if e != nil {
			rejections = append(rejections, e.Error())
			continue
		}
		p.Rejections = rejections
		return g, l, lib, p, parts, prov, nil
	}
	return nil, l, lib, LandscapePlan{Layout: Layout{Rejections: rejections}}, nil, nil, fmt.Errorf("landscape attempts exhausted: %v", rejections)
}
