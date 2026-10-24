package terrainproc

import (
	"encoding/json"
	"fmt"
	"math"
	"path/filepath"
	"reflect"
	"slices"
)

// Opt-in physical geography; historical ellipse recipes cannot contain this.
type BiomeLandforms struct {
	Plan     BiomeReference        `json:"plan"`
	Profile  BiomeReference        `json:"profile"`
	Habitats []BiomeHabitatMinimum `json:"habitats"`
	physical LandformPlan
}
type BiomeHabitatMinimum struct {
	ID          string  `json:"id"`
	Index       int     `json:"index"`
	MinimumArea float64 `json:"minimum_eligible_area"`
}
type BiomeLandformRecord struct {
	Format       string       `json:"format"`
	Seed         int          `json:"seed"`
	PhysicalSeed int          `json:"physical_seed"`
	PlanSHA      string       `json:"plan_sha256"`
	ProfileSHA   string       `json:"profile_sha256"`
	Plan         LandformPlan `json:"resolved_plan"`
}

func loadBiomeLandforms(root string, q *BiomeRecipe, mat MaterialProfile, donor string) error {
	b := q.Landforms
	if len(q.Land)+len(q.Hills)+len(q.Water) > 0 {
		return fmt.Errorf("landforms cannot also use ellipse geography")
	}
	if e := biomeRead(root, &b.Plan, &b.physical); e != nil {
		return e
	}
	if e := biomeRead(root, &b.Profile, nil); e != nil {
		return e
	}
	raw, e := readBiomeBytes(b.Profile.Path)
	if e != nil {
		return e
	}
	var profile struct {
		Format string         `json:"format"`
		Donor  BiomeReference `json:"donor"`
	}
	if e = json.Unmarshal(raw, &profile); e != nil {
		return e
	}
	if profile.Format != "wc3-landform-profile-v1" || profile.Donor.SHA != donor {
		return fmt.Errorf("landform profile donor/format differs")
	}
	if b.physical.Geometry != q.Geometry || b.physical.WaterLevel != q.WaterLevel || math.Abs(b.physical.WaterOffset-mat.WaterOffset) > 1e-6 {
		return fmt.Errorf("landform geometry/water context differs")
	}
	if e = ValidateLandformPlan(b.physical); e != nil {
		return e
	}
	// Routes are one contract shared by physical realization and forest exclusion.
	routeIDs := map[string]bool{}
	for _, route := range q.Routes {
		routeIDs[route.ID] = true
		found := false
		for _, f := range b.physical.Features {
			if f.ID == route.ID && f.Kind == "route" {
				if !reflect.DeepEqual(f.Points, route.Points) || f.Width != route.Width || f.Height != route.Height || f.Jitter != 0 || f.Curve || len(f.Sections) != 0 {
					return fmt.Errorf("physical route differs: %s", route.ID)
				}
				found = true
			}
		}
		if !found {
			return fmt.Errorf("physical route absent: %s", route.ID)
		}
	}
	for _, f := range b.physical.Features {
		if f.Kind == "route" && !routeIDs[f.ID] {
			return fmt.Errorf("physical route has no forest/object reservation: %s", f.ID)
		}
	}
	if len(b.Habitats) != len(q.Forest) {
		return fmt.Errorf("each forest requires an area contract")
	}
	seen := map[int]bool{}
	ids := map[string]bool{}
	for _, h := range b.Habitats {
		if h.ID == "" || ids[h.ID] || seen[h.Index] || h.Index < 0 || h.Index >= len(q.Forest) || !finite(h.MinimumArea) || h.MinimumArea < 4096 {
			return fmt.Errorf("invalid forest area contract")
		}
		seen[h.Index] = true
		ids[h.ID] = true
	}
	return nil
}

// Translate the reviewed source support BEFORE excavation, including wet shore
// vertices. The later scene pass copies textures/objects only in this realizer.
func biomeLandformSupports(q BiomeRecipe, l SceneLibrary, source *Map, mat MaterialProfile) []LandformSupport {
	sg := Scene{Map: source}
	supports := []LandformSupport{}
	for _, inst := range q.Scenes {
		var c SceneComponent
		for _, v := range l.Components {
			if v.ID == inst.Component {
				c = v
				break
			}
		}
		pivot := [2]float64{(c.Source.Min[0] + c.Source.Max[0]) / 2, (c.Source.Min[1] + c.Source.Max[1]) / 2}
		center := biomeSceneCenter(q, inst.Center)
		dz := inst.Height - sg.height(pivot[0], pivot[1], source.Terrain.Tiles)
		if c.Habitat == "shore" {
			dz = q.WaterLevel - (float64(source.Terrain.Tiles[sg.index(pivot[0], pivot[1])].WaterZ()) + mat.WaterOffset)
		}
		s := LandformSupport{ID: inst.ID, Blend: c.Blend, Tolerance: .251}
		for y := 0; y < q.Geometry.Height; y++ {
			for x := 0; x < q.Geometry.Width; x++ {
				wx, wy := float64(q.Geometry.Origin[0])+float64(x)*128, float64(q.Geometry.Origin[1])+float64(y)*128
				local := biomeRotation([2]float64{wx - center[0], wy - center[1]}, -inst.Rotation)
				sp := [2]float64{pivot[0] + local[0], pivot[1] + local[1]}
				if c.Source.Contains(sp[0], sp[1]) {
					s.Vertices = append(s.Vertices, LandformVertex{Index: y*q.Geometry.Width + x, Height: sg.height(sp[0], sp[1], source.Terrain.Tiles) + dz})
				}
			}
		}
		supports = append(supports, s)
	}
	return supports
}

func realizeBiomeLandforms(q BiomeRecipe, l SceneLibrary, source *Map, mat MaterialProfile, seed int) (*LandformSurface, *BiomeLandformRecord, error) {
	ps := biomeStream(q, seed, "landform-physical-v1")
	s, e := RealizeLandforms(q.Landforms.physical, ps, biomeLandformSupports(q, l, source, mat))
	if e != nil {
		return nil, nil, e
	}
	r := &BiomeLandformRecord{Format: "wc3-biome-landforms-v1", Seed: seed, PhysicalSeed: ps, PlanSHA: q.Landforms.Plan.SHA, ProfileSHA: q.Landforms.Profile.SHA, Plan: s.Plan}
	return &s, r, nil
}

func inspectBiomeLandforms(q BiomeRecipe, l SceneLibrary, source *Map, mat MaterialProfile, m *Map) (*LandformInspection, error) {
	var r BiomeLandformRecord
	if e := json.Unmarshal(m.Files["war3map.landforms.json"], &r); e != nil {
		return nil, fmt.Errorf("physical provenance absent: %w", e)
	}
	if r.Format != "wc3-biome-landforms-v1" || r.PlanSHA != q.Landforms.Plan.SHA || r.ProfileSHA != q.Landforms.Profile.SHA || !slices.Contains(q.Seeds, r.Seed) || r.PhysicalSeed != biomeStream(q, r.Seed, "landform-physical-v1") {
		return nil, fmt.Errorf("physical provenance differs")
	}
	resolved, e := ResolveLandformPlan(q.Landforms.physical, r.PhysicalSeed)
	if e != nil {
		return nil, e
	}
	if !reflect.DeepEqual(resolved, r.Plan) {
		return nil, fmt.Errorf("resolved physical plan differs")
	}
	inspection, e := InspectLandforms(m, r.Plan, biomeLandformSupports(q, l, source, mat))
	return &inspection, e
}

// Reports lost forest area separately from density, retaining explicit causes.
func biomeHabitatAreas(q BiomeRecipe, p BiomeProfile, l SceneLibrary, g *Scene) map[string]any {
	result := map[string]any{}
	if q.Landforms == nil {
		return result
	}
	counts := make([]map[string]int, len(q.Forest))
	for i := range counts {
		counts[i] = map[string]int{}
	}
	b := biomeBounds(q)
	for y := b.Min[1] + 32; y < b.Max[1]; y += 64 {
		for x := b.Min[0] + 32; x < b.Max[0]; x += 64 {
			pt := [2]float64{x, y}
			owner := -1
			best := math.Inf(1)
			for i, a := range q.Forest {
				if d := biomeEllipse(q, pt, a); d < best {
					owner = i
					best = d
				}
			}
			if owner < 0 || best >= 1+.05*math.Sin(x/350)*math.Cos(y/310) {
				continue
			}
			reason := "reservation"
			if biomeForestEligible(q, p, l, g, pt) {
				reason = "eligible"
			} else if g.height(x, y, g.Map.Terrain.Tiles) < q.WaterLevel+16 {
				reason = "water"
			} else {
				z := g.height(x, y, g.Map.Terrain.Tiles)
				for _, d := range [][2]float64{{128, 0}, {0, 128}, {-128, 0}, {0, -128}} {
					if math.Abs(g.height(x+d[0], y+d[1], g.Map.Terrain.Tiles)-z) > p.Forest.MaxSlope {
						reason = "slope"
					}
				}
			}
			counts[owner][reason]++
		}
	}
	for _, h := range q.Landforms.Habitats {
		areas := map[string]int{}
		for k, n := range counts[h.Index] {
			areas[k] = n * 4096
		}
		result[h.ID] = map[string]any{"area_by_cause": areas, "minimum_eligible_area": h.MinimumArea}
	}
	return result
}

func writeBiomePhysical(out string, r *BiomeLandformRecord, inspection *LandformInspection) error {
	if e := JSON(filepath.Join(out, "landforms.json"), r); e != nil {
		return e
	}
	return JSON(filepath.Join(out, "physical-inspection.json"), inspection)
}
