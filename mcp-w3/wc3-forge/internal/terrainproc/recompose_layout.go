package terrainproc

import (
	"fmt"
	"math"
	"math/rand"
	"slices"
	"sort"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

type Placement struct {
	Elevation float64               `json:"skirt_elevation,omitempty"`
	Family    string                `json:"family,omitempty"`
	Kind      string                `json:"kind,omitempty"`
	Rotation  int                   `json:"rotation,omitempty"`
	Variant   int                   `json:"variant,omitempty"`
	ID        string                `json:"id"`
	Center    [2]float64            `json:"center"`
	Offset    [2]float64            `json:"offset"`
	Core      Rect                  `json:"core"`
	Reserve   Rect                  `json:"reserve"`
	Anchors   map[string][2]float64 `json:"anchors"`
	Radius    [2]float64            `json:"landform_radius"`
	Phase     float64               `json:"landform_phase"`
}
type Route struct {
	ID     string       `json:"id"`
	Points [][2]float64 `json:"points"`
	Trace  [][2]float64 `json:"trace"`
}
type Layout struct {
	Islets       []Placement      `json:"islets"`
	Connections  []LandConnection `json:"land_connections"`
	Format       string           `json:"format"`
	Seed         int              `json:"seed"`
	Attempt      int              `json:"attempt"`
	Placements   []Placement      `json:"placements"`
	Routes       []Route          `json:"routes"`
	Start        [2]float64       `json:"start"`
	SourceIoU    float64          `json:"source_land_iou"`
	SourceLand   int              `json:"source_land_cells"`
	OutputLand   int              `json:"output_land_cells"`
	ChangedPairs int              `json:"changed_distance_pairs"`
	Rejections   []string         `json:"rejections"`
}

type LandConnection struct {
	From   string       `json:"from"`
	To     string       `json:"to"`
	Points [][2]float64 `json:"points"`
	Width  float64      `json:"width"`
	Role   string       `json:"role"`
}

func expandRect(r Rect, n float64) Rect {
	return Rect{[2]float64{r.Min[0] - n, r.Min[1] - n}, [2]float64{r.Max[0] + n, r.Max[1] + n}}
}
func shiftedRect(r Rect, o [2]float64) Rect {
	return Rect{[2]float64{r.Min[0] + o[0], r.Min[1] + o[1]}, [2]float64{r.Max[0] + o[0], r.Max[1] + o[1]}}
}
func overlap(a, b Rect) bool {
	return a.Min[0] < b.Max[0] && a.Max[0] > b.Min[0] && a.Min[1] < b.Max[1] && a.Max[1] > b.Min[1]
}
func rectDistance(r Rect, x, y float64) float64 {
	return math.Hypot(max(r.Min[0]-x, x-r.Max[0], 0.), max(r.Min[1]-y, y-r.Max[1], 0.))
}
func dist(a, b [2]float64) float64 { return math.Hypot(a[0]-b[0], a[1]-b[1]) }

func makeLayout(s Spec, l Library, attempt int) (Layout, error) {
	r := rand.New(rand.NewSource(int64(s.Seed)*1009 + int64(attempt)*7919))
	plan := Layout{Format: "wc3-layout-v1", Seed: s.Seed, Attempt: attempt}
	slots := [][2]float64{{-7936, -1024}, {-1024, -1024}, {6656, -1024}, {-7936, 4992}, {-1024, 4992}, {6656, 4992}}
	perm := r.Perm(len(slots))
	for i, p := range l.Prefabs {
		center := slots[perm[i]]
		center[0] += float64(r.Intn(21)-10) * 128
		center[1] += float64(r.Intn(13)-6) * 128
		// Align translations (not rounded centers) so tilepoints and object phases remain exact.
		o := [2]float64{math.Round((center[0]-p.Pivot[0])/128) * 128, math.Round((center[1]-p.Pivot[1])/128) * 128}
		center = [2]float64{p.Pivot[0] + o[0], p.Pivot[1] + o[1]}
		if math.Hypot(o[0], o[1]) < s.Recompose.MinDisplacement {
			return plan, fmt.Errorf("%s too near its original location", p.ID)
		}
		q := Placement{ID: p.ID, Center: center, Offset: o, Core: shiftedRect(p.Source, o), Anchors: map[string][2]float64{}, Phase: r.Float64() * math.Pi * 2, Radius: [2]float64{2400 + r.Float64()*450, 1900 + r.Float64()*260}}
		q.Reserve = expandRect(q.Core, p.Blend+128)
		switch p.ID {
		case "temple", "platform":
			q.Radius = [2]float64{1900 + r.Float64()*600, 1550 + r.Float64()*450}
		case "lagoon":
			q.Radius = [2]float64{2950 + r.Float64()*500, 2200 + r.Float64()*350}
		case "waterfall":
			q.Radius = [2]float64{1800 + r.Float64()*500, 1650 + r.Float64()*400}
		}
		for k, a := range p.Anchors {
			q.Anchors[k] = [2]float64{a[0] + o[0], a[1] + o[1]}
		}
		bounds := expandRect(s.Edit, -640)
		if !bounds.Contains(q.Reserve.Min[0], q.Reserve.Min[1]) || !bounds.Contains(q.Reserve.Max[0], q.Reserve.Max[1]) {
			return plan, fmt.Errorf("%s support outside playable margin", p.ID)
		}
		for _, other := range plan.Placements {
			if overlap(q.Reserve, other.Reserve) {
				return plan, fmt.Errorf("reserves overlap: %s/%s", q.ID, other.ID)
			}
		}
		plan.Placements = append(plan.Placements, q)
	}
	for i, a := range plan.Placements {
		for j := i + 1; j < len(plan.Placements); j++ {
			if math.Abs(dist(a.Center, plan.Placements[j].Center)-dist(l.Prefabs[i].Pivot, l.Prefabs[j].Pivot)) >= 512 {
				plan.ChangedPairs++
			}
		}
	}
	if plan.ChangedPairs < 3 {
		return plan, fmt.Errorf("layout is too close to a rigid global transform")
	}
	// These edges describe scenic landform adjacency, not untested gameplay connectivity.
	type pair struct {
		a, b int
		d    float64
	}
	var pairs []pair
	for i, a := range plan.Placements {
		for j := i + 1; j < len(plan.Placements); j++ {
			b := plan.Placements[j]
			if a.ID == "bridge" || b.ID == "bridge" || a.ID == "waterfall" || b.ID == "waterfall" {
				continue
			}
			pairs = append(pairs, pair{i, j, dist(a.Center, b.Center)})
		}
	}
	sort.Slice(pairs, func(i, j int) bool { return pairs[i].d < pairs[j].d })
	used := map[int]bool{}
	for _, p := range pairs {
		if len(plan.Connections) == 2 {
			break
		}
		if used[p.a] && used[p.b] || p.d > 10000 {
			continue
		}
		a, b := plan.Placements[p.a], plan.Placements[p.b]
		mid := [2]float64{(a.Center[0]+b.Center[0])/2 + float64(r.Intn(9)-4)*128, (a.Center[1]+b.Center[1])/2 + float64(r.Intn(7)-3)*128}
		plan.Connections = append(plan.Connections, LandConnection{a.ID, b.ID, [][2]float64{a.Center, mid, b.Center}, 650 + r.Float64()*350, "scenic landform adjacency"})
		used[p.a] = true
		used[p.b] = true
	}
	for n := 0; n < 60 && len(plan.Islets) < 4; n++ {
		c := [2]float64{float64(r.Intn(164)-82) * 128, float64(r.Intn(72)-23) * 128}
		ok := true
		for _, p := range plan.Placements {
			if dist(c, p.Center) < math.Max(p.Radius[0], p.Radius[1])+900 {
				ok = false
			}
		}
		for _, p := range plan.Islets {
			if dist(c, p.Center) < 1500 {
				ok = false
			}
		}
		if ok {
			plan.Islets = append(plan.Islets, Placement{ID: fmt.Sprintf("islet-%d", len(plan.Islets)+1), Center: c, Radius: [2]float64{450 + r.Float64()*450, 350 + r.Float64()*350}, Phase: r.Float64() * 6.28})
		}
	}
	return plan, nil
}

func setGround(t *w3e.Tilepoint, z float64) {
	t.GroundHeight = int16(math.Round((z-(float64(t.LayerHeight)-2)*128)*4 + 8192))
}

func islandHeight(q Placement, x, y float64) float64 {
	family := q.ID
	if q.Family != "" {
		family = q.Family
	}
	cx, cy := q.Center[0], q.Center[1]
	rx, ry := q.Radius[0], q.Radius[1]
	if family == "waterfall" {
		cx += 640
	}
	dx, dy := (x-cx)/rx, (y-cy)/ry
	a := math.Atan2(dy, dx)
	edge := 1 + .10*math.Sin(3*a+q.Phase) + .065*math.Cos(5*a-q.Phase)
	rad := math.Hypot(dx, dy) / edge
	if family == "micro-skirt" {
		return -192 + (q.Elevation+192)*smooth((1.25-rad)/.8)
	}
	z := -192 + 346*smooth((1.20-rad)/.50)
	z += 105 * smooth((.86-rad)/.7) * (1 + .5*math.Sin(x/600+q.Phase)*math.Cos(y/730))
	if family == "bridge" {
		// Continue the diagonal channel beyond the preserved crossing to the sea.
		b := q.Anchors["center"]
		channel := math.Abs((x - b[0] + y - b[1]) * .7071)
		z -= 300 * (1 - smooth((channel-260)/280))
	}
	return z
}

func composeTerrain(g *Scene, l Library, plan *Layout) ([]doodadsdoo.Doodad, error) {
	w := int(g.Map.Terrain.Width)
	h := int(g.Map.Terrain.Height)
	for i := range g.Map.Terrain.Tiles {
		x, y := g.xy(i%w, i/w)
		z := -192.
		for _, q := range plan.Placements {
			z = max(z, islandHeight(q, x, y))
		}
		for _, q := range plan.Islets {
			z = max(z, islandHeight(q, x, y))
		}
		for _, edge := range plan.Connections {
			ss := Spec{Path: edge.Points}
			d := ss.PathDistance(x, y)
			if g.Spec.Scene != nil {
				width := edge.Width * (1 + .22*math.Sin(x/730+y/490) + .12*math.Cos(y/320-x/540))
				crest := 280 + 75*math.Sin(x/1100+y/770) + 25*math.Cos(y/360)
				z = max(z, -192+crest*smooth((width+450-d)/850))
			} else {
				z = max(z, -192+324*smooth((edge.Width+450-d)/650))
			}
		}
		margin := min(x-g.Spec.Edit.Min[0], g.Spec.Edit.Max[0]-x, y-g.Spec.Edit.Min[1], g.Spec.Edit.Max[1]-y)
		z = -192 + (z+192)*smooth((margin-512)/512)
		t := w3e.Tilepoint{WaterLevel: 8192, LayerHeight: 1, CliffTexture: 1, GroundTexture: 3, Flags: 4, Boundary: x < -11776 || x >= 11776 || y < -3584 || y >= 7680}
		setGround(&t, z)
		if margin < 128 {
			t.Flags |= 8
		}
		if z > g.Water+16 {
			t.Flags &^= 4
		}
		g.Map.Terrain.Tiles[i] = t
	}
	var pieces []doodadsdoo.Doodad
	for pi, p := range l.Prefabs {
		q := plan.Placements[pi]
		for y := 0; y < h; y++ {
			for x := 0; x < w; x++ {
				wx, wy := g.xy(x, y)
				d := rectDistance(q.Core, wx, wy)
				if d >= p.Blend {
					continue
				}
				si := g.index(wx-q.Offset[0], wy-q.Offset[1])
				if si < 0 {
					return nil, fmt.Errorf("composition source transition leaves donor")
				}
				i := x + y*w
				src := g.Original[si]
				t := g.Map.Terrain.Tiles[i]
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
		for _, src := range p.Pieces {
			d := adjustedPrefabPiece(g, p, src)
			d.Position[0] += float32(q.Offset[0])
			d.Position[1] += float32(q.Offset[1])
			pieces = append(pieces, d)
		}
	}
	intersection, union := 0, 0
	for y := 0; y < h-1; y++ {
		for x := 0; x < w-1; x++ {
			i := x + y*w
			a := float64(g.Original[i].FinalZ()) >= g.Water
			b := float64(g.Map.Terrain.Tiles[i].FinalZ()) >= g.Water
			if a {
				plan.SourceLand++
			}
			if b {
				plan.OutputLand++
			}
			if a && b {
				intersection++
			}
			if a || b {
				union++
			}
		}
	}
	plan.SourceIoU = float64(intersection) / float64(max(1, union))
	if plan.SourceIoU > g.Spec.Recompose.MaxSourceIoU {
		return nil, fmt.Errorf("source land IoU %.3f exceeds limit", plan.SourceIoU)
	}
	return pieces, nil
}

func sceneReserved(plan Layout, x, y float64) bool {
	for _, p := range plan.Placements {
		if expandRect(p.Core, 160).Contains(x, y) {
			return true
		}
	}
	return false
}

func recomposeSample(g *Scene, l Library) ([]int, int, int) {
	old := g.Spec.Mode
	g.Spec.Mode = "whole-map-restyle"
	s, w, h := g.sample()
	g.Spec.Mode = old
	// The annotated core is a separate library, not a source of free-tree or ruin scatter.
	for i := range s {
		x, y := g.xy(i%w, i/w)
		for _, p := range l.Prefabs {
			if p.Source.Contains(x, y) && s[i] != 4 {
				s[i] = 0
				break
			}
		}
	}
	return s, w, h
}

func recomposeDecoration(g *Scene, plan Layout, states []int, parts []doodadsdoo.Doodad) {
	// Reuse the proven full-sample weighted species placement with explicit core reservations.
	g.Rand = rand.New(rand.NewSource(int64(g.Spec.Seed)*65537 + 29))
	g.Next = 10000
	g.Anchors = parts
	g.Reservations = nil
	for _, p := range plan.Placements {
		g.Reservations = append(g.Reservations, expandRect(p.Core, 160))
	}
	for _, r := range plan.Routes {
		for _, p := range r.Trace {
			g.Reservations = append(g.Reservations, Rect{[2]float64{p[0] - 192, p[1] - 192}, [2]float64{p[0] + 192, p[1] + 192}})
		}
	}
	old := g.Spec
	g.Spec.Mode = "whole-map-restyle"
	g.Spec.Waterfall.Source = Rect{[2]float64{-100000, -100000}, [2]float64{-90000, -90000}}
	g.Spec.Path = nil
	g.decorate(states, 192, 96, parts)
	g.Spec = old
	g.Map.Doodads.Doodads = slices.Clone(g.Added)
}

// Explicit access corrections retain all objects and each object's ground-relative Z.
// Source pieces in the library remain untouched for provenance and reversibility.
func adjustedPrefabPiece(g *Scene, p Prefab, d doodadsdoo.Doodad) doodadsdoo.Doodad {
	if o, ok := p.Adjustments[d.CreationNumber]; ok {
		x, y := float64(d.Position[0]), float64(d.Position[1])
		d.Position[0] += float32(o[0])
		d.Position[1] += float32(o[1])
		d.Position[2] += float32(g.height(x+o[0], y+o[1], g.Original) - g.height(x, y, g.Original))
	}
	return d
}
