package terrainproc

import (
	"bytes"
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/unitsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3c"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3i"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3r"
	"math"
	"reflect"
	"slices"
)

type BiomeValidation struct {
	Landforms   *LandformInspection  `json:"landforms,omitempty"`
	Habitats    map[string]any       `json:"habitat_area,omitempty"`
	Coverage    *BiomeCoverageReport `json:"coverage,omitempty"`
	Format      string               `json:"format"`
	Passed      bool                 `json:"passed"`
	MapSHA      string               `json:"map_sha256"`
	Geometry    MaterialGeometry     `json:"geometry"`
	Forest      ForestMetrics        `json:"forest"`
	Routes      map[string]int       `json:"route_cells"`
	ObjectCount int                  `json:"objects"`
	Failures    []string             `json:"failures"`
}

func ValidateBiome(recipe, path, out string) error {
	q, p, l, mat, source, cat, e := loadBiome(recipe)
	if e != nil {
		return e
	}
	m, e := Load(path)
	if e != nil {
		return e
	}
	v := BiomeValidation{Format: "wc3-biome-validation-v1", MapSHA: m.Hash, Geometry: MaterialGeometry{int(m.Terrain.Width), int(m.Terrain.Height), m.Terrain.CenterOffset}, Routes: map[string]int{}, Failures: []string{}}
	fail := func(s string) { v.Failures = append(v.Failures, s) }
	if v.Geometry != q.Geometry {
		fail("geometry differs from recipe")
	}
	if !slices.Equal(m.Terrain.GroundTilesets, source.Terrain.GroundTilesets) {
		fail("palette differs")
	}
	if !bytes.Equal(m.Files["war3map.shd"], make([]byte, len(m.Pathing.Cells))) {
		fail("nonzero or mismatched shadow member")
	}
	g := Scene{Map: m, Catalog: cat, Water: q.WaterLevel, Spec: Spec{Edit: biomeBounds(q), CollisionRadius: q.CollisionRadius}}
	if q.Landforms != nil && v.Geometry == q.Geometry {
		v.Landforms, e = inspectBiomeLandforms(q, l, source, mat, m)
		if e != nil {
			fail(e.Error())
		}
		v.Habitats = biomeHabitatAreas(q, p, l, &g)
	}
	for i, t := range m.Terrain.Tiles {
		if int(t.GroundTexture) >= len(mat.Palette) || math.Abs(float64(t.WaterZ())+mat.WaterOffset-q.WaterLevel) > .251 {
			fail(fmt.Sprintf("invalid texture/water %d", i))
			break
		}
	}
	info, e := w3i.Parse(m.Files["war3map.w3i"])
	if e != nil {
		return e
	}
	if info.PlayableWidth != int32(q.Geometry.Width-9) || info.PlayableHeight != int32(q.Geometry.Height-9) || len(info.Players) != 1 {
		fail("W3I geometry/player mismatch")
	}
	u, e := unitsdoo.Parse(m.Files["war3mapunits.doo"])
	if e != nil {
		return e
	}
	start := biomeWorld(q, q.Start)
	if len(u.Entities) != 1 || u.Entities[0].TypeID != "sloc" || math.Hypot(float64(u.Entities[0].Position[0])-start[0], float64(u.Entities[0].Position[1])-start[1]) > .1 {
		fail("unexpected source units or start")
	}
	cams, e := w3c.Parse(m.Files["war3map.w3c"])
	if e != nil {
		return e
	}
	if len(cams.Cameras) > 0 {
		fail("stale cameras")
	}
	regs, e := w3r.Parse(m.Files["war3map.w3r"])
	if e != nil {
		return e
	}
	if len(regs.Regions) > 0 {
		fail("stale regions")
	}
	approved := map[string]bool{}
	for _, id := range p.Natural {
		approved[id] = true
	}
	byID := map[uint32]doodadsdoo.Doodad{}
	for _, d := range source.Doodads.Doodads {
		byID[d.CreationNumber] = d
	}
	for _, c := range l.Components {
		for _, id := range c.Required {
			approved[byID[id].TypeID] = true
		}
	}
	trees := []doodadsdoo.Doodad{}
	seen := map[uint32]bool{}
	for _, d := range m.Doodads.Doodads {
		if seen[d.CreationNumber] {
			fail("duplicate creation ID")
		}
		seen[d.CreationNumber] = true
		if !approved[d.TypeID] {
			fail("unapproved placed family " + d.TypeID)
			continue
		}
		a := cat.Assets[d.TypeID]
		if _, ok := a.Models[d.Variation]; !ok {
			fail("unresolved placed variation")
		}
		if !expandRect(g.Spec.Edit, -384).Contains(float64(d.Position[0]), float64(d.Position[1])) {
			fail("object outside bounds")
		}
		if slices.Contains(mat.Rules.Trees, d.TypeID) {
			trees = append(trees, d)
		}
	}
	// Reconstruct every rigid member independently of placement logs.
	sg := Scene{Map: source}
	memberIndex := 0
	for _, inst := range q.Scenes {
		var c SceneComponent
		for _, cc := range l.Components {
			if cc.ID == inst.Component {
				c = cc
				break
			}
		}
		pivot := [2]float64{(c.Source.Min[0] + c.Source.Max[0]) / 2, (c.Source.Min[1] + c.Source.Max[1]) / 2}
		center := biomeSceneCenter(q, inst.Center)
		dz := inst.Height - sg.height(pivot[0], pivot[1], source.Terrain.Tiles)
		if c.Habitat == "shore" {
			dz = q.WaterLevel - (float64(source.Terrain.Tiles[sg.index(pivot[0], pivot[1])].WaterZ()) + mat.WaterOffset)
		}
		for _, id := range c.Required {
			expected := byID[id]
			delta := biomeRotation([2]float64{float64(expected.Position[0]) - pivot[0], float64(expected.Position[1]) - pivot[1]}, inst.Rotation)
			expected.Position = [3]float32{float32(center[0] + delta[0]), float32(center[1] + delta[1]), float32(float64(expected.Position[2]) + dz)}
			expected.Rotation += float32(float64(inst.Rotation) * math.Pi / 180)
			expected = biomeGroundObject(&g, expected, mat)
			if memberIndex >= len(m.Doodads.Doodads) {
				fail("missing rigid member")
				break
			}
			actual := m.Doodads.Doodads[memberIndex]
			memberIndex++
			if expected.TypeID != actual.TypeID || expected.Position != actual.Position || expected.Rotation != actual.Rotation || expected.Variation != actual.Variation || !reflect.DeepEqual(expected.Scale, actual.Scale) {
				fail("rigid member transform differs: " + inst.ID)
			}
		}
	}
	v.ObjectCount = len(m.Doodads.Doodads)
	if v.ObjectCount > q.MaxObjects {
		fail("object budget")
	}
	v.Forest = forestMetrics(trees)
	if p.Forest.Coverage != nil && v.Geometry == q.Geometry {
		r := measureBiomeCoverage(q, p, l, mat, &g)
		v.Coverage = &r
		for _, s := range r.Failures {
			fail(s)
		}
		for _, d := range m.Doodads.Doodads[memberIndex:] {
			if slices.Contains(mat.Rules.Trees, d.TypeID) && !biomeForestEligible(q, p, l, &g, [2]float64{float64(d.Position[0]), float64(d.Position[1])}) {
				fail("forest tree outside eligible habitat")
				break
			}
		}
	}
	if v.Forest.Count < 64 || v.Forest.Quantiles[1] < p.Forest.MedianRange[0] || v.Forest.Quantiles[1] > p.Forest.MedianRange[1] || v.Forest.Neighbors256 < p.Forest.NeighborsRange[0] || v.Forest.Neighbors256 > p.Forest.NeighborsRange[1] {
		fail("forest distribution outside calibrated range")
	}
	blocked := combinedRecompose(&g, m.Pathing.Cells)
	for _, r := range q.Routes {
		// Route checks are confined to the declared corridor, with the configured
		// agent radius applied. No whole-map detour can certify a broken corridor.
		allowed := slices.Clone(blocked)
		for i := range allowed {
			pt := cellPoint(&g, i)
			d := math.Inf(1)
			for j := 1; j < len(r.Points); j++ {
				d = min(d, biomeSegment(pt, biomeWorld(q, r.Points[j-1]), biomeWorld(q, r.Points[j])))
			}
			if d > r.Width/2 {
				allowed[i] = true
			}
		}
		a, b := pathCell(&g, biomeWorld(q, r.Points[0])), pathCell(&g, biomeWorld(q, r.Points[len(r.Points)-1]))
		trace, err := gridPath(&g, allowed, a, b, g.Spec.Edit)
		if err != nil {
			fail("route " + r.ID + ": " + err.Error())
		} else {
			v.Routes[r.ID] = len(trace)
		}
	}
	v.Passed = len(v.Failures) == 0
	if e = JSON(out, v); e != nil {
		return e
	}
	if !v.Passed {
		return fmt.Errorf("biome validation failed: %v", v.Failures)
	}
	return nil
}
