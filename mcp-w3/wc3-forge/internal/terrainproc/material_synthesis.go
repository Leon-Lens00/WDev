package terrainproc

import (
	"fmt"
	"math"
	"math/rand"
	"slices"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

type MaterialChange struct {
	Vertex          int    `json:"vertex"`
	Context         string `json:"context"`
	Before          int    `json:"before_texture"`
	After           int    `json:"after_texture"`
	BeforeVariation int    `json:"before_variation"`
	AfterVariation  int    `json:"after_variation"`
	SourceVertex    int    `json:"source_vertex"`
}
type MaterialContextMetrics struct {
	Name        string  `json:"name"`
	SourceCount int     `json:"source_count"`
	OutputCount int     `json:"output_count"`
	Source      []int   `json:"source"`
	Before      []int   `json:"before"`
	After       []int   `json:"after"`
	BeforeTV    float64 `json:"before_tv"`
	AfterTV     float64 `json:"after_tv"`
	HoldoutTV   float64 `json:"holdout_tv"`
}
type MaterialResult struct {
	ContextualRefinements []MaterialQuotaChange    `json:"contextual_refinements,omitempty"`
	Format                string                   `json:"format"`
	ProfileSHA            string                   `json:"profile_sha256"`
	Seed                  int                      `json:"seed"`
	InputTerrainSHA       string                   `json:"input_terrain_sha256"`
	InputDoodadsSHA       string                   `json:"input_doodads_sha256"`
	OutputTerrainSHA      string                   `json:"output_terrain_sha256"`
	Contexts              []MaterialContextMetrics `json:"contexts"`
	Features              []MaterialFeature        `json:"features"`
	Changes               []MaterialChange         `json:"changes"`
	Assignments           []int                    `json:"source_assignments"`
	IterationChanges      []int                    `json:"iteration_changes"`
	LargestGrassyPatch    int                      `json:"largest_grassy_patch"`
	ProtectedVertices     int                      `json:"protected_vertices"`
}

func sumMaterial(a []int) int {
	n := 0
	for _, v := range a {
		n += v
	}
	return n
}
func materialTV(a, b []int) float64 {
	na, nb := sumMaterial(a), sumMaterial(b)
	if na == 0 || nb == 0 {
		return 0
	}
	v := 0.
	for i := range a {
		v += math.Abs(float64(a[i])/float64(na) - float64(b[i])/float64(nb))
	}
	return v / 2
}
func materialProtected(t w3e.Tilepoint, mask string, water float64) bool {
	return t.Boundary || mask == "rigid" || t.GroundTexture == 4 || landscapeWet(t, water)
}

// PaintMaterials changes appearance only, after all placements have been resolved.
// Source-neighborhood matches retain local patterns; context frequencies prevent
// a common label from becoming a universal replacement for the donor palette.
func PaintMaterials(m *Map, masks []string, o MaterialOptions) (MaterialResult, error) {
	var result MaterialResult
	if o.ContextualFix != "" && o.ContextualFix != "context-quota-v1" {
		return result, fmt.Errorf("unknown contextual material fix %q", o.ContextualFix)
	}
	p, e := loadMaterialProfile(o)
	if e != nil {
		return result, e
	}
	if e = materialTarget(&p, m); e != nil {
		return result, e
	}
	if len(masks) != len(m.Terrain.Tiles) || !slices.Equal(p.Palette, m.Terrain.GroundTilesets) {
		return result, fmt.Errorf("material map/profile/mask mismatch")
	}
	before := slices.Clone(m.Terrain.Tiles)
	raw, e := w3e.Encode(m.Terrain)
	if e != nil {
		return result, e
	}
	doo, e := doodadsdoo.Encode(m.Doodads)
	if e != nil {
		return result, e
	}
	result = MaterialResult{Format: "wc3-material-result-v1", ProfileSHA: o.ProfileSHA, Seed: o.Seed, InputTerrainSHA: Hash(raw), InputDoodadsSHA: Hash(doo), Features: profileFeatures(m, p)}
	features := result.Features
	pools := make([][]int, 8)
	at := map[int]int{}
	for i, s := range p.Samples {
		if s.Split == "train" && !profilePreserves(p, s.Texture) {
			pools[s.Context] = append(pools[s.Context], i)
			at[s.Index] = i
		}
	}
	// Brick is preserve-only: natural infill must never introduce architecture.
	for c := range p.Counts {
		for tex := range p.Palette {
			if profilePreserves(p, tex) {
				p.Counts[c][tex] = 0
				p.HoldoutCounts[c][tex] = 0
			}
		}
	}
	counts, beforeCounts := profileMatrix(p), profileMatrix(p)
	sizes := make([]int, 8)
	mutable := make([]bool, len(before))
	assign := make([]int, len(before))
	for i, t := range before {
		assign[i] = -1
		if profileProtected(p, t, masks[i]) {
			result.ProtectedVertices++
			continue
		}
		c := features[i].Context
		if c == 0 || len(pools[c]) == 0 {
			return result, fmt.Errorf("no compatible source samples for %s", materialContexts[c])
		}
		mutable[i] = true
		sizes[c]++
		counts[c][t.GroundTexture]++
		beforeCounts[c][t.GroundTexture]++
	}
	expected := make([][]float64, 8)
	for c := range expected {
		expected[c] = make([]float64, len(p.Palette))
		n := sumMaterial(p.Counts[c])
		for t := range expected[c] {
			if n > 0 {
				expected[c][t] = float64(sizes[c]) * float64(p.Counts[c][t]) / float64(n)
			}
		}
	}
	rng := rand.New(rand.NewSource(int64(o.Seed)))
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	sw := 193
	if p.Geometry != nil {
		sw = p.Geometry.Width
	}
	for pass := 0; pass < p.Iterations; pass++ {
		changes := 0
		for step := 0; step < len(before); step++ {
			i := step
			if pass%2 == 1 {
				i = len(before) - 1 - step
			}
			if !mutable[i] {
				continue
			}
			c := features[i].Context
			old := m.Terrain.Tiles[i].GroundTexture
			counts[c][old]--
			candidates := make([]int, 0, p.Candidates+8)
			if assign[i] >= 0 {
				candidates = append(candidates, assign[i])
			}
			for _, j := range materialNeighbors(i, w, h) {
				if assign[j] >= 0 {
					src := p.Samples[assign[j]].Index + (i%w - j%w) + (i/w-j/w)*sw
					if s, ok := at[src]; ok && p.Samples[s].Context == c && absInt(src%sw-p.Samples[assign[j]].Index%sw) <= 1 {
						candidates = append(candidates, s)
					}
				}
			}
			pool := pools[c]
			for n := 0; n < p.Candidates; n++ {
				candidates = append(candidates, pool[rng.Intn(len(pool))])
			}
			best, bestScore := -1, math.Inf(1)
			for _, si := range candidates {
				s := p.Samples[si]
				// Zero-probability material contexts are never synthesized.
				if expected[c][s.Texture] == 0 {
					continue
				}
				score := p.FrequencyWeight * math.Log((float64(counts[c][s.Texture])+1)/(expected[c][s.Texture]+1))
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
							score += 1
							continue
						}
						weight := .14
						if absInt(dx) <= 1 && absInt(dy) <= 1 {
							weight = .55
						}
						if sc != features[j].Context {
							score += weight * .3
						}
						if s.Patch5[k] != int(m.Terrain.Tiles[j].GroundTexture) {
							score += weight
						}
					}
				}
				// Match the local physical/vegetation density within the context.
				sf := p.Features[s.Index]
				score += .025*math.Abs(float64(sf.Trees-features[i].Trees)) + .01*math.Min(64, math.Abs(sf.Slope-features[i].Slope))
				if score < bestScore {
					best, bestScore = si, score
				}
			}
			if best < 0 {
				return result, fmt.Errorf("material synthesis contradiction at vertex %d", i)
			}
			s := p.Samples[best]
			t := &m.Terrain.Tiles[i]
			t.GroundTexture = uint8(s.Texture)
			t.TextureDetails = (t.TextureDetails & 224) | uint8(s.Variation)
			assign[i] = best
			counts[c][s.Texture]++
			if old != t.GroundTexture {
				changes++
			}
		}
		result.IterationChanges = append(result.IterationChanges, changes)
	}
	if o.ContextualFix == "context-quota-v1" {
		result.ContextualRefinements, e = refineMaterialContexts(m, p, features, beforeCounts, counts, sizes, mutable, assign, pools)
		if e != nil {
			return result, e
		}
	}
	result.Assignments = make([]int, len(assign))
	for i, si := range assign {
		result.Assignments[i] = -1
		if si < 0 {
			continue
		}
		s := p.Samples[si]
		result.Assignments[i] = s.Index
		t := m.Terrain.Tiles[i]
		if t != before[i] {
			result.Changes = append(result.Changes, MaterialChange{i, materialContexts[features[i].Context], int(before[i].GroundTexture), int(t.GroundTexture), int(before[i].TextureDetails & 31), int(t.TextureDetails & 31), s.Index})
		}
	}
	for c := 1; c < 8; c++ {
		result.Contexts = append(result.Contexts, MaterialContextMetrics{materialContexts[c], sumMaterial(p.Counts[c]), sizes[c], p.Counts[c], beforeCounts[c], counts[c], materialTV(p.Counts[c], beforeCounts[c]), materialTV(p.Counts[c], counts[c]), materialTV(p.HoldoutCounts[c], counts[c])})
	}
	grassy := 2
	if p.Rules != nil {
		grassy = slices.Index(p.Palette, p.Rules.Grassy)
	}
	if grassy >= 0 {
		result.LargestGrassyPatch = largestMaterialPatch(m, uint8(grassy), p.WaterOffset)
	}
	raw, e = w3e.Encode(m.Terrain)
	if e != nil {
		return result, e
	}
	result.OutputTerrainSHA = Hash(raw)
	for _, c := range result.Contexts {
		if c.SourceCount >= 64 && c.OutputCount >= 64 && (c.AfterTV > p.TVLimit || (c.BeforeTV > p.TVLimit && c.AfterTV > c.BeforeTV*.5)) {
			return result, fmt.Errorf("material context criteria failed: %s", c.Name)
		}
	}
	if result.LargestGrassyPatch > p.MaxGrassyPatch {
		return result, fmt.Errorf("material grassy patch exceeds limit")
	}
	return result, nil
}
func largestMaterialPatch(m *Map, texture uint8, water float64) int {
	seen := make([]bool, len(m.Terrain.Tiles))
	largest := 0
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	for i, t := range m.Terrain.Tiles {
		if seen[i] || t.GroundTexture != texture || landscapeWet(t, water) {
			continue
		}
		seen[i] = true
		q := []int{i}
		for head := 0; head < len(q); head++ {
			for _, j := range materialNeighbors(q[head], w, h) {
				if !seen[j] && m.Terrain.Tiles[j].GroundTexture == texture && !landscapeWet(m.Terrain.Tiles[j], water) {
					seen[j] = true
					q = append(q, j)
				}
			}
		}
		largest = max(largest, len(q))
	}
	return largest
}
