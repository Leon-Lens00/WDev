package terrainproc

import (
	"fmt"
	"math"
)

// MaterialQuotaChange records an optional, bounded repair of a context mix.
// This never changes the calibrated profile or the independent validation gate.
type MaterialQuotaChange struct {
	Vertex       int     `json:"vertex"`
	Context      string  `json:"context"`
	Before       int     `json:"before_texture"`
	After        int     `json:"after_texture"`
	SourceVertex int     `json:"source_vertex"`
	BeforeTV     float64 `json:"before_tv"`
	AfterTV      float64 `json:"after_tv"`
}

func materialContextFails(p MaterialProfile, source, before, after []int) bool {
	a, b := materialTV(source, after), materialTV(source, before)
	return a > p.TVLimit || (b > p.TVLimit && a > b*.5)
}

// refineMaterialContexts repairs only rejected contexts by moving one excess
// label to one underrepresented label at a time. Every replacement comes from
// an observed training sample in that same context. It picks the least damaging
// local patch change, with stable vertex/source order as a deterministic tie.
// At most min(256, ceil(25% of a context's mutable vertices)) may change; an exhausted
// budget is an error, not a license to relax the profile's acceptance criteria.
func refineMaterialContexts(m *Map, p MaterialProfile, features []MaterialFeature, beforeCounts, counts [][]int, sizes []int, mutable []bool, assign []int, pools [][]int) ([]MaterialQuotaChange, error) {
	var changes []MaterialQuotaChange
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	score := func(i, si int) float64 {
		s := p.Samples[si]
		total := 0.
		for dy := -2; dy <= 2; dy++ {
			for dx := -2; dx <= 2; dx++ {
				if dx == 0 && dy == 0 {
					continue
				}
				x, y := i%w+dx, i/w+dy
				if x < 0 || y < 0 || x >= w || y >= h {
					continue
				}
				j := x + y*w
				k := (dy+2)*5 + dx + 2
				sc := s.Context5[k]
				if sc < 0 {
					total++
					continue
				}
				weight := .14
				if absInt(dx) <= 1 && absInt(dy) <= 1 {
					weight = .55
				}
				if sc != features[j].Context {
					total += weight * .3
				}
				if s.Patch5[k] != int(m.Terrain.Tiles[j].GroundTexture) {
					total += weight
				}
			}
		}
		sf := p.Features[s.Index]
		return total + .025*math.Abs(float64(sf.Trees-features[i].Trees)) + .01*math.Min(64, math.Abs(sf.Slope-features[i].Slope))
	}
	for c := 1; c < len(counts); c++ {
		n := sumMaterial(p.Counts[c])
		if n < 64 || sizes[c] < 64 {
			continue
		}
		budget := min(256, (sizes[c]+3)/4)
		// Bounded candidates: eight evenly spaced observed samples per texture.
		byTexture := make([][]int, len(p.Palette))
		for _, si := range pools[c] {
			byTexture[p.Samples[si].Texture] = append(byTexture[p.Samples[si].Texture], si)
		}
		var repairPool []int
		for _, samples := range byTexture {
			for k := 0; k < min(8, len(samples)); k++ {
				repairPool = append(repairPool, samples[k*len(samples)/min(8, len(samples))])
			}
		}
		for step := 0; materialContextFails(p, p.Counts[c], beforeCounts[c], counts[c]); step++ {
			if step >= budget {
				return changes, fmt.Errorf("material context quota repair budget exhausted: %s", materialContexts[c])
			}
			previousTV := materialTV(p.Counts[c], counts[c])
			bestI, bestSI := -1, -1
			bestCost := math.Inf(1)
			bestImprovement := 0.
			vertices := 0
			for i, ok := range mutable {
				if !ok || features[i].Context != c {
					continue
				}
				old := int(m.Terrain.Tiles[i].GroundTexture)
				expectedOld := float64(sizes[c]) * float64(p.Counts[c][old]) / float64(n)
				if float64(counts[c][old]) <= expectedOld {
					continue
				}
				vertices++
				if vertices > 256 {
					break
				}
				oldScore := 0.
				if assign[i] >= 0 {
					oldScore = score(i, assign[i])
				}
				for _, si := range repairPool {
					sample := p.Samples[si]
					target := sample.Texture
					expectedTarget := float64(sizes[c]) * float64(p.Counts[c][target]) / float64(n)
					if target == old || float64(counts[c][target]) >= expectedTarget {
						continue
					}
					counts[c][old]--
					counts[c][target]++
					improvement := previousTV - materialTV(p.Counts[c], counts[c])
					counts[c][old]++
					counts[c][target]--
					if improvement <= 1e-12 {
						continue
					}
					cost := score(i, si) - oldScore
					if improvement > bestImprovement+1e-12 || (math.Abs(improvement-bestImprovement) <= 1e-12 && cost < bestCost) {
						bestI, bestSI, bestCost = i, si, cost
						bestImprovement = improvement
					}
				}
			}
			if bestI < 0 {
				return changes, fmt.Errorf("material context quota contradiction: %s", materialContexts[c])
			}
			t := &m.Terrain.Tiles[bestI]
			old := int(t.GroundTexture)
			s := p.Samples[bestSI]
			t.GroundTexture = uint8(s.Texture)
			t.TextureDetails = (t.TextureDetails & 224) | uint8(s.Variation)
			counts[c][old]--
			counts[c][s.Texture]++
			assign[bestI] = bestSI
			changes = append(changes, MaterialQuotaChange{bestI, materialContexts[c], old, s.Texture, s.Index, previousTV, materialTV(p.Counts[c], counts[c])})
		}
	}
	return changes, nil
}
