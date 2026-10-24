package terrainproc

import (
	"encoding/json"
	"fmt"
	"math"
	"math/rand"
	"path/filepath"
	"slices"
	"strconv"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wpm"
)

func biomeWorld(q BiomeRecipe, p [2]float64) [2]float64 {
	return [2]float64{float64(q.Geometry.Origin[0]) + p[0]*float64(q.Geometry.Width-1)*128, float64(q.Geometry.Origin[1]) + p[1]*float64(q.Geometry.Height-1)*128}
}

// Whole scene translations retain the source pathing-grid phase. New placements
// obey the resolved footprint and orientation before support and route checks.
func biomeSceneCenter(q BiomeRecipe, p [2]float64) [2]float64 {
	pt := biomeWorld(q, p)
	return [2]float64{math.Round(pt[0]/128) * 128, math.Round(pt[1]/128) * 128}
}
func biomePlacementPoint(pt [2]float64, a *Asset) [2]float64 {
	if a.Pathing != nil {
		for k, n := range []int{a.Pathing.Width, a.Pathing.Height} {
			phase := float64(n%4) * 16
			pt[k] = math.Floor((pt[k]-phase)/64+.5)*64 + phase
		}
	}
	return pt
}
func biomeGroundObject(g *Scene, d doodadsdoo.Doodad, mat MaterialProfile) doodadsdoo.Doodad {
	a := g.Catalog.Assets[d.TypeID]
	pt := biomePlacementPoint([2]float64{float64(d.Position[0]), float64(d.Position[1])}, a)
	z := g.height(pt[0], pt[1], g.Map.Terrain.Tiles)
	if a.Fields["floats"] == "1" {
		i := g.index(pt[0], pt[1])
		water := float64(g.Map.Terrain.Tiles[i].WaterZ()) + mat.WaterOffset
		// Native Classic uses the nearest wet terrain vertex for floating support;
		// a plant at a dry shoreline vertex remains grounded even when the
		// interpolated surface immediately beside it falls below the water.
		if g.Map.Terrain.Tiles[i].Flags&4 != 0 && float64(g.Map.Terrain.Tiles[i].FinalZ()) < water {
			z = max(z, water)
		}
	}
	d.Position = [3]float32{float32(pt[0]), float32(pt[1]), float32(z)}
	d.Rotation = float32(math.Mod(float64(d.Rotation), 2*math.Pi))
	if fixed, e := strconv.ParseFloat(a.Fields["fixedrot"], 64); e == nil && fixed >= 0 {
		d.Rotation = float32(fixed * math.Pi / 180)
	} else if a.Pathing != nil && a.Kind == "doodad" {
		d.Rotation = float32(math.Mod(math.Round(float64(d.Rotation)/(math.Pi/2))*math.Pi/2, 2*math.Pi))
	}
	d.Flags = 2
	return d
}
func biomeEllipse(q BiomeRecipe, p [2]float64, e BiomeEllipse) float64 {
	c := biomeWorld(q, e.Center)
	return math.Hypot((p[0]-c[0])/(e.Radius[0]*float64(q.Geometry.Width-1)*128), (p[1]-c[1])/(e.Radius[1]*float64(q.Geometry.Height-1)*128))
}
func biomeSegment(p, a, b [2]float64) float64 {
	dx, dy := b[0]-a[0], b[1]-a[1]
	t := 0.
	if dx*dx+dy*dy > 0 {
		t = max(0, min(1, ((p[0]-a[0])*dx+(p[1]-a[1])*dy)/(dx*dx+dy*dy)))
	}
	return math.Hypot(p[0]-a[0]-t*dx, p[1]-a[1]-t*dy)
}
func biomeRouteDistance(q BiomeRecipe, p [2]float64) (float64, float64) {
	best, z := math.Inf(1), 0.
	for _, r := range q.Routes {
		for i := 1; i < len(r.Points); i++ {
			d := biomeSegment(p, biomeWorld(q, r.Points[i-1]), biomeWorld(q, r.Points[i])) - r.Width/2
			if d < best {
				best, z = d, r.Height
			}
		}
	}
	return best, z
}
func biomeRotation(p [2]float64, rotation int) [2]float64 {
	switch ((rotation % 360) + 360) % 360 {
	case 90:
		return [2]float64{-p[1], p[0]}
	case 180:
		return [2]float64{-p[0], -p[1]}
	case 270:
		return [2]float64{p[1], -p[0]}
	}
	return p
}
func biomeBounds(q BiomeRecipe) Rect {
	return Rect{[2]float64{float64(q.Geometry.Origin[0]), float64(q.Geometry.Origin[1])}, biomeWorld(q, [2]float64{1, 1})}
}
func biomeStream(q BiomeRecipe, seed int, name string) int {
	if s, ok := q.Streams[name]; ok {
		return s
	}
	return int(sceneSeed(seed, "biome-ellipses-v1", name) % 2147483647)
}

type BiomePlacement struct {
	Provenance
	Policy string  `json:"height_policy"`
	Offset float64 `json:"source_height_offset"`
}
type BiomeRun struct {
	Landforms  *BiomeLandformRecord `json:"landforms,omitempty"`
	Habitats   map[string]any       `json:"habitat_area,omitempty"`
	Coverage   *BiomeCoverageRun    `json:"coverage,omitempty"`
	Format     string               `json:"format"`
	Recipe     string               `json:"recipe"`
	Seed       int                  `json:"seed"`
	Streams    map[string]int       `json:"streams"`
	Map        string               `json:"map"`
	MapSHA     string               `json:"map_sha256"`
	Before     string               `json:"before_materials"`
	Placements []BiomePlacement     `json:"placements"`
	Forest     ForestMetrics        `json:"forest"`
	Attempts   int                  `json:"vegetation_attempts"`
}

// GenerateBiome uses the same Classic IO, catalogue, source-library records,
// footprint navigation and context PatchMatch as the established terrain route.
// Its bounded territorial realizer is data-driven and has no biome rawcodes.
func GenerateBiome(recipe, out string, seed int) error {
	recipe, _ = filepath.Abs(recipe)
	out, _ = filepath.Abs(out)
	q, p, l, mat, m, cat, e := loadBiome(recipe)
	if e != nil {
		return e
	}
	if seed < 0 {
		if len(q.Seeds) == 0 {
			return fmt.Errorf("missing seed")
		}
		seed = q.Seeds[0]
	}
	source, e := Load(p.Source.Path)
	if e != nil {
		return e
	}
	sg := Scene{Map: source, Water: mat.WaterOffset}
	run := BiomeRun{Format: "wc3-biome-run-v1", Recipe: recipe, Seed: seed, Streams: map[string]int{}}
	for _, name := range []string{"territory", "variants", "vegetation", "materials", "ornaments"} {
		run.Streams[name] = biomeStream(q, seed, name)
	}
	rng := rand.New(rand.NewSource(int64(run.Streams["territory"])))
	phase := rng.Float64() * 6.28
	w, h := q.Geometry.Width, q.Geometry.Height
	m.Terrain.Width = uint32(w)
	m.Terrain.Height = uint32(h)
	m.Terrain.CenterOffset = q.Geometry.Origin
	m.Terrain.Tiles = make([]w3e.Tilepoint, w*h)
	m.Pathing = &wpm.File{Width: (w - 1) * 4, Height: (h - 1) * 4, Cells: make([]byte, (w-1)*(h-1)*16)}
	g := Scene{Map: m, Catalog: cat, Water: q.WaterLevel, Spec: Spec{Edit: biomeBounds(q), CollisionRadius: q.CollisionRadius}}
	masks := make([]string, w*h)
	setHeight := func(i int, z float64) { m.Terrain.Tiles[i].GroundHeight = int16(math.Round(z*4 + 8192)) }
	var physical *LandformSurface
	if q.Landforms != nil {
		physical, run.Landforms, e = realizeBiomeLandforms(q, l, source, mat, seed)
		if e != nil {
			return e
		}
		run.Streams["landform-physical"] = run.Landforms.PhysicalSeed
	}
	for i := range m.Terrain.Tiles {
		x, y := g.xy(i%w, i/w)
		pt := [2]float64{x, y}
		z := q.WaterLevel - 230
		if physical == nil {
			for _, a := range q.Land {
				r := biomeEllipse(q, pt, a)
				edge := r + .025*math.Sin(x/430+phase)*math.Cos(y/590-phase)
				z = max(z, q.WaterLevel+a.Height*max(-1, min(1, (1-edge)*5)))
			}
			for _, a := range q.Hills {
				r := biomeEllipse(q, pt, a)
				if r < 1 {
					z += a.Height * math.Pow(1-r*r, 2)
				}
			}
			z += 13*math.Sin(x/670+phase)*math.Cos(y/490) + 6*math.Sin((x+y)/170)
			for _, a := range q.Water {
				r := biomeEllipse(q, pt, a) + .075*math.Sin(x/820+phase)*math.Cos(y/630)
				if r < 1.25 {
					waterZ := q.WaterLevel - a.Height*max(-1, min(1, (1-r)*4))
					z = min(z, waterZ)
				}
			}
			rd, rz := biomeRouteDistance(q, pt)
			if rd < 256 {
				blend := max(0, min(1, 1-rd/256))
				z = z*(1-blend) + rz*blend
			}
		} else {
			z = physical.Heights[i]
		}
		t := w3e.Tilepoint{WaterLevel: uint16(math.Round((q.WaterLevel-mat.WaterOffset)*4 + 8192)), Flags: 4, LayerHeight: 2, CliffTexture: 15, GroundTexture: 0, TextureDetails: 0}
		if i%w < 4 || i/w < 4 || i%w >= w-4 || i/w >= h-4 {
			t.Boundary = true
			t.Flags |= 8
			z = q.WaterLevel - 230
		}
		m.Terrain.Tiles[i] = t
		setHeight(i, z)
		masks[i] = "natural"
	}
	byID := map[uint32]doodadsdoo.Doodad{}
	for _, d := range source.Doodads.Doodads {
		byID[d.CreationNumber] = d
	}
	m.Doodads.Doodads = nil
	m.Doodads.SpecialDoodads = nil
	next := uint32(1)
	add := func(d doodadsdoo.Doodad, id uint32, instance, role, policy string, offset float64) {
		d.CreationNumber = next
		next++
		m.Doodads.Doodads = append(m.Doodads.Doodads, d)
		run.Placements = append(run.Placements, BiomePlacement{Provenance{d.CreationNumber, id, instance, d.TypeID, role}, policy, offset})
	}
	sceneAreas := []Rect{}
	for _, inst := range q.Scenes {
		var c SceneComponent
		for _, cc := range l.Components {
			if cc.ID == inst.Component {
				c = cc
				break
			}
		}
		if !slices.Contains(c.Rotations, inst.Rotation) {
			return fmt.Errorf("unsupported scene rotation")
		}
		pivot := [2]float64{(c.Source.Min[0] + c.Source.Max[0]) / 2, (c.Source.Min[1] + c.Source.Max[1]) / 2}
		center := biomeSceneCenter(q, inst.Center)
		dz := inst.Height - sg.height(pivot[0], pivot[1], source.Terrain.Tiles)
		if c.Habitat == "shore" {
			dz = q.WaterLevel - (float64(source.Terrain.Tiles[sg.index(pivot[0], pivot[1])].WaterZ()) + mat.WaterOffset)
		}
		sx, sy := (c.Source.Max[0]-c.Source.Min[0])/2, (c.Source.Max[1]-c.Source.Min[1])/2
		if inst.Rotation%180 != 0 {
			sx, sy = sy, sx
		}
		area := Rect{[2]float64{center[0] - sx, center[1] - sy}, [2]float64{center[0] + sx, center[1] + sy}}
		if !expandRect(g.Spec.Edit, -512).Contains(area.Min[0]-c.Blend, area.Min[1]-c.Blend) || !expandRect(g.Spec.Edit, -512).Contains(area.Max[0]+c.Blend, area.Max[1]+c.Blend) {
			return fmt.Errorf("scene %s outside safe bounds", inst.ID)
		}
		for _, a := range sceneAreas {
			if area.Min[0] < a.Max[0] && area.Max[0] > a.Min[0] && area.Min[1] < a.Max[1] && area.Max[1] > a.Min[1] {
				return fmt.Errorf("overlapping scenes")
			}
		}
		sceneAreas = append(sceneAreas, expandRect(area, 128))
		for i := range m.Terrain.Tiles {
			x, y := g.xy(i%w, i/w)
			local := biomeRotation([2]float64{x - center[0], y - center[1]}, -inst.Rotation)
			sp := [2]float64{pivot[0] + local[0], pivot[1] + local[1]}
			dd := max(c.Source.Min[0]-sp[0], sp[0]-c.Source.Max[0], c.Source.Min[1]-sp[1], sp[1]-c.Source.Max[1])
			if dd > c.Blend {
				continue
			}
			blend := max(0, min(1, 1-dd/c.Blend))
			z := sg.height(max(c.Source.Min[0], min(c.Source.Max[0], sp[0])), max(c.Source.Min[1], min(c.Source.Max[1], sp[1])), source.Terrain.Tiles) + dz
			if physical == nil {
				setHeight(i, float64(m.Terrain.Tiles[i].FinalZ())*(1-blend)+z*blend)
			}
			if dd <= 0 {
				si := sg.index(sp[0], sp[1])
				m.Terrain.Tiles[i].GroundTexture = source.Terrain.Tiles[si].GroundTexture
				m.Terrain.Tiles[i].TextureDetails = source.Terrain.Tiles[si].TextureDetails & 31
				masks[i] = "rigid"
			}
		}
		for _, id := range c.Required {
			d := byID[id]
			delta := biomeRotation([2]float64{float64(d.Position[0]) - pivot[0], float64(d.Position[1]) - pivot[1]}, inst.Rotation)
			d.Position = [3]float32{float32(center[0] + delta[0]), float32(center[1] + delta[1]), float32(float64(d.Position[2]) + dz)}
			d.Rotation += float32(float64(inst.Rotation) * math.Pi / 180)
			add(d, id, inst.ID, "composition", "rigid-translation", dz)
		}
	}
	if physical != nil {
		run.Habitats = biomeHabitatAreas(q, p, l, &g)
		if e = JSON(filepath.Join(out, "habitat-area.json"), run.Habitats); e != nil {
			return e
		}
		// Inspect the quantized physical surface before spending decoration budget.
		m.Pathing.Cells = staticRecomposePathing(&g)
		inspection, err := InspectLandforms(m, run.Landforms.Plan, biomeLandformSupports(q, l, source, mat))
		inspection.MapSHA = "" // In-memory pre-export check has no archive identity yet.
		if e = writeBiomePhysical(out, run.Landforms, &inspection); e != nil {
			return e
		}
		if err != nil {
			return err
		}
	}
	// Compact source cohorts are translated and quarter-turned. Cross-cohort
	// spacing and exclusions prevent seams from obstructing the declared routes.
	vrng := rand.New(rand.NewSource(int64(run.Streams["vegetation"])))
	variants := rand.New(rand.NewSource(int64(run.Streams["variants"])))
	occupied := map[[2]int][][2]float64{}
	bin := func(pt [2]float64) [2]int { return [2]int{int(math.Floor(pt[0] / 256)), int(math.Floor(pt[1] / 256))} }
	remember := func(pt [2]float64) { b := bin(pt); occupied[b] = append(occupied[b], pt) }
	for _, d := range m.Doodads.Doodads {
		remember([2]float64{float64(d.Position[0]), float64(d.Position[1])})
	}
	free := func(pt [2]float64, space float64) bool {
		b := bin(pt)
		for yy := b[1] - 2; yy <= b[1]+2; yy++ {
			for xx := b[0] - 2; xx <= b[0]+2; xx++ {
				for _, a := range occupied[[2]int{xx, yy}] {
					if dist(pt, a) < space {
						return false
					}
				}
			}
		}
		return true
	}
	eligible := func(pt [2]float64) bool {
		for _, a := range q.ForestClearings {
			if biomeEllipse(q, pt, a) <= 1 {
				return false
			}
		}
		if !expandRect(g.Spec.Edit, -768).Contains(pt[0], pt[1]) {
			return false
		}
		for _, a := range sceneAreas {
			if a.Contains(pt[0], pt[1]) {
				return false
			}
		}
		rd, _ := biomeRouteDistance(q, pt)
		if rd < 192 {
			return false
		}
		z := g.height(pt[0], pt[1], m.Terrain.Tiles)
		if z < q.WaterLevel+16 {
			return false
		}
		for _, d := range [][2]float64{{128, 0}, {0, 128}, {-128, 0}, {0, -128}} {
			if math.Abs(g.height(pt[0]+d[0], pt[1]+d[1], m.Terrain.Tiles)-z) > p.Forest.MaxSlope {
				return false
			}
		}
		for _, a := range q.Forest {
			if biomeEllipse(q, pt, a) < 1+.05*math.Sin(pt[0]/350)*math.Cos(pt[1]/310) {
				return true
			}
		}
		return false
	}
	cohortAreas := []Rect{}
	for attempt := 0; attempt < q.MaxAttempts; attempt++ {
		run.Attempts++
		co := l.Cohorts[variants.Intn(len(l.Cohorts))]
		pivot := [2]float64{(co.Bounds.Min[0] + co.Bounds.Max[0]) / 2, (co.Bounds.Min[1] + co.Bounds.Max[1]) / 2}
		anchor := biomeWorld(q, [2]float64{vrng.Float64(), vrng.Float64()})
		anchor = [2]float64{math.Round(anchor[0]/128) * 128, math.Round(anchor[1]/128) * 128}
		if !eligible(anchor) {
			continue
		}
		// A cohort is a spatial sample, not a stamp used repeatedly to fill all
		// its own gaps. Reserve its interior so later samples preserve the donor's
		// voids and do not saturate the entire habitat into a solid tree wall.
		half := [2]float64{(co.Bounds.Max[0] - co.Bounds.Min[0]) * .42, (co.Bounds.Max[1] - co.Bounds.Min[1]) * .42}
		claimed := Rect{[2]float64{anchor[0] - half[0], anchor[1] - half[1]}, [2]float64{anchor[0] + half[0], anchor[1] + half[1]}}
		overlap := false
		for _, a := range cohortAreas {
			if claimed.Min[0] < a.Max[0] && claimed.Max[0] > a.Min[0] && claimed.Min[1] < a.Max[1] && claimed.Max[1] > a.Min[1] {
				overlap = true
				break
			}
		}
		if overlap {
			continue
		}
		beforeCohort := len(m.Doodads.Doodads)
		rot := vrng.Intn(4) * 90
		for _, id := range co.SourceIDs {
			d := byID[id]
			delta := biomeRotation([2]float64{float64(d.Position[0]) - pivot[0], float64(d.Position[1]) - pivot[1]}, rot)
			pt := [2]float64{anchor[0] + delta[0], anchor[1] + delta[1]}
			if !eligible(pt) || !free(pt, p.Forest.Spacing) {
				continue
			}
			offset := float64(d.Position[2]) - sg.height(float64(d.Position[0]), float64(d.Position[1]), source.Terrain.Tiles)
			d.Position = [3]float32{float32(pt[0]), float32(pt[1]), float32(g.height(pt[0], pt[1], m.Terrain.Tiles) + offset)}
			d.Rotation += float32(rot) * math.Pi / 180
			// Preserve observed scale/variation; variant stream only chooses the source.
			add(d, id, fmt.Sprintf("%s-%d", co.ID, attempt), "forest", "ground-offset", offset)
			remember(pt)
			if len(m.Doodads.Doodads) >= q.MaxObjects {
				return fmt.Errorf("object budget exhausted")
			}
		}
		if len(m.Doodads.Doodads) > beforeCohort {
			cohortAreas = append(cohortAreas, claimed)
		}
	}
	// Local adornments are sampled by observed family and support relationship.
	orng := rand.New(rand.NewSource(int64(run.Streams["ornaments"])))
	protos := []doodadsdoo.Doodad{}
	for _, d := range source.Doodads.Doodads {
		if slices.Contains(p.Natural, d.TypeID) && !slices.Contains(mat.Rules.Trees, d.TypeID) {
			protos = append(protos, d)
		}
	}
	for n := 0; n < q.MaxAttempts/2 && len(protos) > 0; n++ {
		d := protos[orng.Intn(len(protos))]
		id := d.CreationNumber
		pt := biomeWorld(q, [2]float64{orng.Float64(), orng.Float64()})
		pt = biomePlacementPoint(pt, cat.Assets[d.TypeID])
		if !expandRect(g.Spec.Edit, -768).Contains(pt[0], pt[1]) {
			continue
		}
		rd, _ := biomeRouteDistance(q, pt)
		if rd < 160 {
			continue
		}
		skip := false
		for _, a := range sceneAreas {
			if a.Contains(pt[0], pt[1]) {
				skip = true
			}
		}
		if skip || !free(pt, 180) {
			continue
		}
		sourceZ := sg.height(float64(d.Position[0]), float64(d.Position[1]), source.Terrain.Tiles)
		z := g.height(pt[0], pt[1], m.Terrain.Tiles)
		sourceWater := float64(source.Terrain.Tiles[sg.index(float64(d.Position[0]), float64(d.Position[1]))].WaterZ()) + mat.WaterOffset
		sourceWet := sourceZ < sourceWater
		wet := z < q.WaterLevel
		if sourceWet != wet || math.Abs((sourceZ-sourceWater)-(z-q.WaterLevel)) > 64 {
			continue
		}
		if !slices.Contains(mat.Rules.Rocks, d.TypeID) && !wet && !eligible(pt) {
			continue
		}
		offset := float64(d.Position[2]) - sourceZ
		policy := "ground-offset"
		newz := z + offset
		if sourceWet {
			policy = "water-offset"
			offset = float64(d.Position[2]) - sourceWater
			newz = q.WaterLevel + offset
		}
		d.Position = [3]float32{float32(pt[0]), float32(pt[1]), float32(newz)}
		add(d, id, "habitat-detail", "environment", policy, offset)
		remember(pt)
		if len(m.Doodads.Doodads) >= q.MaxObjects {
			return fmt.Errorf("object budget exhausted")
		}
	}
	if p.Forest.Coverage != nil {
		run.Streams["forest-coverage"] = biomeStream(q, seed, "forest-coverage-v1")
		run.Coverage, e = refineBiomeForest(q, p, l, mat, &g, byID, run.Streams["forest-coverage"], add)
		if e != nil {
			return e
		}
	}
	for i, d := range m.Doodads.Doodads {
		m.Doodads.Doodads[i] = biomeGroundObject(&g, d, mat)
		run.Placements[i].Policy = "classic-resolved-support-v1"
		run.Placements[i].Offset = 0
	}
	trees := []doodadsdoo.Doodad{}
	for _, d := range m.Doodads.Doodads {
		if slices.Contains(mat.Rules.Trees, d.TypeID) {
			trees = append(trees, d)
		}
	}
	run.Forest = forestMetrics(trees)
	// Initial dry appearance is a donor sample, then contextual synthesis applies.
	features := profileFeatures(m, mat)
	pools := make([][]MaterialSample, 8)
	for _, s := range mat.Samples {
		if s.Split == "train" {
			pools[s.Context] = append(pools[s.Context], s)
		}
	}
	for i := range m.Terrain.Tiles {
		if masks[i] == "rigid" {
			continue
		}
		pool := pools[features[i].Context]
		if len(pool) > 0 {
			s := pool[rng.Intn(len(pool))]
			m.Terrain.Tiles[i].GroundTexture = uint8(s.Texture)
			m.Terrain.Tiles[i].TextureDetails = uint8(s.Variation)
		}
	}
	m.Pathing.Cells = staticRecomposePathing(&g)
	changes, e := biomeShell(&g, q, p, seed)
	if e != nil {
		return e
	}
	if run.Landforms != nil {
		changes["war3map.landforms.json"], e = json.Marshal(run.Landforms)
		if e != nil {
			return e
		}
	}
	before := filepath.Join(out, q.ID+"-base.w3x")
	run.Before = before
	terrain, e := w3e.Encode(m.Terrain)
	if e != nil {
		return e
	}
	doo, e := doodadsdoo.Encode(m.Doodads)
	if e != nil {
		return e
	}
	changes["war3map.w3e"] = terrain
	changes["war3map.doo"] = doo
	changes["war3map.wpm"] = encodePathing(m.Pathing.Width, m.Pathing.Height, m.Pathing.Cells)
	changes["war3map.shd"] = make([]byte, len(m.Pathing.Cells))
	changes["war3mapmap.blp"], e = biomeMinimap(m, mat)
	if e != nil {
		return e
	}
	if e = m.Write(before, changes); e != nil {
		return e
	}
	bm, e := Load(before)
	if e != nil {
		return e
	}
	contextPath := filepath.Join(out, "context.json")
	context := TerrainContext{Format: "wc3-terrain-context-v1", MapSHA: bm.Hash, Geometry: q.Geometry, ProfileSHA: p.Materials.SHA, Masks: masks, Reasons: map[int]string{}}
	if e = JSON(contextPath, context); e != nil {
		return e
	}
	contextRaw, e := readBiomeBytes(contextPath)
	if e != nil {
		return e
	}
	request := MaterialRepaint{Format: "wc3-material-repaint-v2", Map: before, MapSHA: bm.Hash, DoodadsSHA: Hash(doo), Context: contextPath, ContextSHA: Hash(contextRaw), Materials: MaterialOptions{Profile: p.Materials.Path, ProfileSHA: p.Materials.SHA, Seed: run.Streams["materials"]}}
	if q.Landforms != nil {
		request.Materials.ContextualFix = "context-quota-v1"
	}
	requestPath := filepath.Join(out, "repaint.json")
	if e = JSON(requestPath, request); e != nil {
		return e
	}
	repaintErr := RepaintMaterials(requestPath, filepath.Join(out, "paint"))
	run.Map = filepath.Join(out, "paint", q.ID+"-base-materials.w3x")
	raw, e := readBiomeBytes(run.Map)
	if e != nil {
		if repaintErr != nil {
			return repaintErr
		}
		return e
	}
	run.MapSHA = Hash(raw)
	if e = JSON(filepath.Join(out, "run.json"), run); e != nil {
		return e
	}
	if e = JSON(filepath.Join(out, "recipe.json"), q); e != nil {
		return e
	}
	if repaintErr != nil {
		return repaintErr
	}
	return ValidateBiome(recipe, run.Map, filepath.Join(out, "validation.json"))
}
