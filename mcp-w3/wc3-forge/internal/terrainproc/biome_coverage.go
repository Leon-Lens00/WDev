package terrainproc

import (
	"fmt"
	"math"
	"math/rand"
	"slices"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
)

// Coverage is an explicit v2 contract. v1 recipes retain their original streams
// and bytes. Radii measure projected canopy proxies, not rendered leaf pixels.
type BiomeCoveragePolicy struct {
	CoreMinimum    float64 `json:"core_minimum"`
	EdgeMinimum    float64 `json:"edge_minimum"`
	EdgeWidth      float64 `json:"edge_width"`
	MaxCoreGap     float64 `json:"maximum_core_gap_radius"`
	FragmentRadius float64 `json:"fragment_radius"`
	MaxNeighbors   int     `json:"maximum_neighbors256"`
	MaxAdditions   int     `json:"maximum_additions"`
	MaxAttempts    int     `json:"maximum_attempts"`
}
type BiomeCoverageZone struct {
	Habitat    int     `json:"habitat"`
	Band       string  `json:"band"`
	Samples    int     `json:"samples"`
	Covered    int     `json:"covered"`
	Fraction   float64 `json:"canopy_fraction"`
	LargestGap float64 `json:"largest_gap_radius"`
}
type BiomeCoverageReport struct {
	Step     int                 `json:"sample_step"`
	Zones    []BiomeCoverageZone `json:"zones"`
	Failures []string            `json:"failures"`
}
type BiomeCoverageRun struct {
	Before   BiomeCoverageReport `json:"before"`
	After    BiomeCoverageReport `json:"after"`
	Added    int                 `json:"added_trees"`
	Attempts int                 `json:"attempts"`
	Rejected map[string]int      `json:"rejected"`
}
type biomeCanopySample struct {
	Point [2]float64
	Zone  int
	Gap   float64
}

func validateCoveragePolicy(q BiomeRecipe, p *BiomeCoveragePolicy) error {
	if q.Realizer == "ellipses-cohorts-v1" {
		if p != nil || len(q.ForestClearings) > 0 {
			return fmt.Errorf("coverage/clearings require ellipses-cohorts-v2")
		}
		return nil
	}
	if q.Realizer != "ellipses-cohorts-v2" && q.Realizer != "landforms-cohorts-v1" {
		return fmt.Errorf("unknown coverage realizer")
	}
	if p == nil {
		return fmt.Errorf("v2 requires forest coverage policy")
	}
	finite := func(x float64) bool { return !math.IsNaN(x) && !math.IsInf(x, 0) }
	for _, x := range []float64{p.CoreMinimum, p.EdgeMinimum, p.EdgeWidth, p.MaxCoreGap, p.FragmentRadius} {
		if !finite(x) {
			return fmt.Errorf("nonfinite coverage policy")
		}
	}
	if p.CoreMinimum < .25 || p.CoreMinimum > .85 || p.EdgeMinimum < .1 || p.EdgeMinimum > p.CoreMinimum || p.EdgeWidth < 64 || p.EdgeWidth > 512 || p.MaxCoreGap < 64 || p.MaxCoreGap > 512 || p.FragmentRadius < 128 || p.FragmentRadius > 512 || p.MaxNeighbors < 3 || p.MaxNeighbors > 24 || p.MaxAdditions < 1 || p.MaxAdditions > 5000 || p.MaxAttempts < 1 || p.MaxAttempts > 10000 {
		return fmt.Errorf("invalid forest coverage policy")
	}
	return nil
}

func biomeForestEligible(q BiomeRecipe, p BiomeProfile, l SceneLibrary, g *Scene, pt [2]float64) bool {
	if !expandRect(biomeBounds(q), -768).Contains(pt[0], pt[1]) {
		return false
	}
	for _, a := range q.ForestClearings {
		if biomeEllipse(q, pt, a) <= 1 {
			return false
		}
	}
	for _, inst := range q.Scenes {
		for _, c := range l.Components {
			if c.ID != inst.Component {
				continue
			}
			center := biomeSceneCenter(q, inst.Center)
			sx, sy := (c.Source.Max[0]-c.Source.Min[0])/2, (c.Source.Max[1]-c.Source.Min[1])/2
			if inst.Rotation%180 != 0 {
				sx, sy = sy, sx
			}
			if math.Abs(pt[0]-center[0]) <= sx+128 && math.Abs(pt[1]-center[1]) <= sy+128 {
				return false
			}
		}
	}
	if rd, _ := biomeRouteDistance(q, pt); rd < 192 {
		return false
	}
	z := g.height(pt[0], pt[1], g.Map.Terrain.Tiles)
	if z < q.WaterLevel+16 {
		return false
	}
	for _, d := range [][2]float64{{128, 0}, {0, 128}, {-128, 0}, {0, -128}} {
		if math.Abs(g.height(pt[0]+d[0], pt[1]+d[1], g.Map.Terrain.Tiles)-z) > p.Forest.MaxSlope {
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

func biomeCanopyGrid(q BiomeRecipe, p BiomeProfile, l SceneLibrary, g *Scene) []biomeCanopySample {
	b := biomeBounds(q)
	result := []biomeCanopySample{}
	for y := b.Min[1] + 32; y < b.Max[1]; y += 64 {
		for x := b.Min[0] + 32; x < b.Max[0]; x += 64 {
			pt := [2]float64{x, y}
			if !biomeForestEligible(q, p, l, g, pt) {
				continue
			}
			owner, best := 0, math.Inf(1)
			for i, a := range q.Forest {
				if d := biomeEllipse(q, pt, a); d < best {
					best, owner = d, i
				}
			}
			core := true
			for a := 0.; a < 8; a++ {
				angle := a * math.Pi / 4
				check := [2]float64{x + p.Forest.Coverage.EdgeWidth*math.Cos(angle), y + p.Forest.Coverage.EdgeWidth*math.Sin(angle)}
				if !biomeForestEligible(q, p, l, g, check) {
					core = false
					break
				}
			}
			zone := owner * 2
			if !core {
				zone++
			}
			result = append(result, biomeCanopySample{pt, zone, math.Inf(1)})
		}
	}
	return result
}

func updateBiomeCanopy(samples []biomeCanopySample, d doodadsdoo.Doodad, radius float64) {
	pt := [2]float64{float64(d.Position[0]), float64(d.Position[1])}
	// Use the smaller horizontal scale so anisotropic imported trees do not
	// silently overstate coverage. Profiles calibrate radius per biome.
	r := radius * math.Min(float64(d.Scale[0]), float64(d.Scale[1]))
	for i := range samples {
		samples[i].Gap = min(samples[i].Gap, dist(samples[i].Point, pt)-r)
	}
}
func reportBiomeCanopy(samples []biomeCanopySample, q BiomeRecipe, p *BiomeCoveragePolicy) BiomeCoverageReport {
	r := BiomeCoverageReport{Step: 64, Zones: make([]BiomeCoverageZone, len(q.Forest)*2), Failures: []string{}}
	for i := range r.Zones {
		r.Zones[i].Habitat = i / 2
		r.Zones[i].Band = "core"
		if i%2 == 1 {
			r.Zones[i].Band = "edge"
		}
	}
	for _, s := range samples {
		z := &r.Zones[s.Zone]
		z.Samples++
		if s.Gap <= 0 {
			z.Covered++
		}
		z.LargestGap = max(z.LargestGap, s.Gap)
	}
	for i := range r.Zones {
		z := &r.Zones[i]
		if z.Samples == 0 {
			continue
		}
		z.Fraction = float64(z.Covered) / float64(z.Samples)
		// Keep empty-forest diagnostics JSON encodable.
		if math.IsInf(z.LargestGap, 1) {
			z.LargestGap = math.Hypot(float64(q.Geometry.Width*128), float64(q.Geometry.Height*128))
		}
		minimum := p.CoreMinimum
		if i%2 == 1 {
			minimum = p.EdgeMinimum
		}
		if z.Fraction < minimum || (i%2 == 0 && z.LargestGap > p.MaxCoreGap) {
			r.Failures = append(r.Failures, fmt.Sprintf("forest habitat %d %s: coverage %.3f gap %.1f", z.Habitat, z.Band, z.Fraction, z.LargestGap))
		}
	}
	if len(samples) == 0 {
		r.Failures = append(r.Failures, "no eligible forest habitat")
	}
	if q.Landforms != nil {
		for _, h := range q.Landforms.Habitats {
			area := float64(r.Zones[h.Index*2].Samples+r.Zones[h.Index*2+1].Samples) * 64 * 64
			if area < h.MinimumArea || area == 0 {
				r.Failures = append(r.Failures, fmt.Sprintf("forest habitat %s: eligible area %.0f below %.0f", h.ID, area, h.MinimumArea))
			}
		}
	}
	return r
}
func measureBiomeCoverage(q BiomeRecipe, p BiomeProfile, l SceneLibrary, mat MaterialProfile, g *Scene) BiomeCoverageReport {
	s := biomeCanopyGrid(q, p, l, g)
	for _, d := range g.Map.Doodads.Doodads {
		if slices.Contains(mat.Rules.Trees, d.TypeID) {
			updateBiomeCanopy(s, d, p.Forest.CanopyRadius)
		}
	}
	return reportBiomeCanopy(s, q, p.Forest.Coverage)
}

func refineBiomeForest(q BiomeRecipe, p BiomeProfile, l SceneLibrary, mat MaterialProfile, g *Scene, source map[uint32]doodadsdoo.Doodad, seed int, add func(doodadsdoo.Doodad, uint32, string, string, string, float64)) (*BiomeCoverageRun, error) {
	policy := p.Forest.Coverage
	samples := biomeCanopyGrid(q, p, l, g)
	for _, d := range g.Map.Doodads.Doodads {
		if slices.Contains(mat.Rules.Trees, d.TypeID) {
			updateBiomeCanopy(samples, d, p.Forest.CanopyRadius)
		}
	}
	r := &BiomeCoverageRun{Before: reportBiomeCanopy(samples, q, policy), Rejected: map[string]int{}}
	rng := rand.New(rand.NewSource(int64(seed)))
	blocked := map[int]bool{}
	for r.Attempts < policy.MaxAttempts && r.Added < policy.MaxAdditions {
		status := reportBiomeCanopy(samples, q, policy)
		if len(status.Failures) == 0 {
			break
		}
		index, best := -1, -1.
		for i, s := range samples {
			if blocked[i] {
				continue
			}
			z := status.Zones[s.Zone]
			minimum := policy.CoreMinimum
			if s.Zone%2 == 1 {
				minimum = policy.EdgeMinimum
			}
			if z.Fraction >= minimum && (s.Zone%2 == 1 || z.LargestGap <= policy.MaxCoreGap) {
				continue
			}
			if s.Gap > best {
				index, best = i, s.Gap
			}
		}
		if index < 0 {
			break
		}
		anchor := samples[index].Point
		co := l.Cohorts[rng.Intn(len(l.Cohorts))]
		root := source[co.SourceIDs[rng.Intn(len(co.SourceIDs))]]
		rootXY := [2]float64{float64(root.Position[0]), float64(root.Position[1])}
		rot := rng.Intn(4) * 90
		type member struct {
			d        doodadsdoo.Doodad
			id       uint32
			distance float64
		}
		members := []member{}
		for _, id := range co.SourceIDs {
			d := source[id]
			xy := [2]float64{float64(d.Position[0]), float64(d.Position[1])}
			if delta := dist(xy, rootXY); delta <= policy.FragmentRadius {
				members = append(members, member{d, id, delta})
			}
		}
		slices.SortStableFunc(members, func(a, b member) int {
			if a.distance < b.distance {
				return -1
			}
			if a.distance > b.distance {
				return 1
			}
			return 0
		})
		accepted := []member{}
		for _, v := range members {
			if len(accepted) >= 8 || r.Added+len(accepted) >= policy.MaxAdditions || len(g.Map.Doodads.Doodads)+len(accepted) >= q.MaxObjects {
				break
			}
			delta := biomeRotation([2]float64{float64(v.d.Position[0]) - rootXY[0], float64(v.d.Position[1]) - rootXY[1]}, rot)
			v.d.Position[0], v.d.Position[1] = float32(anchor[0]+delta[0]), float32(anchor[1]+delta[1])
			v.d.Rotation += float32(rot) * math.Pi / 180
			v.d = biomeGroundObject(g, v.d, mat)
			pt := [2]float64{float64(v.d.Position[0]), float64(v.d.Position[1])}
			if !biomeForestEligible(q, p, l, g, pt) {
				r.Rejected["habitat"]++
				continue
			}
			near, free := 0, true
			check := func(d doodadsdoo.Doodad) {
				distance := dist(pt, [2]float64{float64(d.Position[0]), float64(d.Position[1])})
				if distance < p.Forest.Spacing {
					free = false
				}
				if distance < 256 && slices.Contains(mat.Rules.Trees, d.TypeID) {
					near++
				}
			}
			for _, d := range g.Map.Doodads.Doodads {
				check(d)
			}
			for _, d := range accepted {
				check(d.d)
			}
			if !free {
				r.Rejected["spacing"]++
				continue
			}
			if near >= policy.MaxNeighbors {
				r.Rejected["density"]++
				continue
			}
			accepted = append(accepted, v)
		}
		r.Attempts++
		if len(accepted) < 3 {
			r.Rejected["fragment_too_small"]++
			if r.Attempts%3 == 0 {
				blocked[index] = true
			}
			continue
		}
		for _, v := range accepted {
			add(v.d, v.id, fmt.Sprintf("coverage-%s-%d", co.ID, r.Attempts), "forest-refinement", "classic-resolved-support-v1", 0)
			updateBiomeCanopy(samples, v.d, p.Forest.CanopyRadius)
			r.Added++
		}
	}
	r.After = reportBiomeCanopy(samples, q, policy)
	// Always retain an actionable diagnostic even when a constrained recipe fails.
	return r, nil
}
