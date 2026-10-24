package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/slk"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/mpqchain"
	"math"
	"path/filepath"
	"reflect"
	"slices"
	"strconv"
)

// Source geometry and destination geometry are independent. The fixed Classic
// sampling steps (128/32) are format units, not dimensions of a particular map.
type MaterialGeometry struct {
	Width  int        `json:"width"`
	Height int        `json:"height"`
	Origin [2]float32 `json:"origin"`
}
type MaterialRules struct {
	Trees          []string    `json:"trees"`
	Rocks          []string    `json:"rocks"`
	Structures     []string    `json:"structures"`
	Preserve       []string    `json:"preserve_materials"`
	Grassy         string      `json:"grassy_material"`
	TreeRadius     float64     `json:"tree_radius"`
	RockRadius     float64     `json:"rock_radius"`
	ShoreRadius    float64     `json:"shore_radius"`
	ForestMin      int         `json:"forest_min_trees"`
	SlopeMin       float64     `json:"slope_min"`
	Partition      string      `json:"partition"`
	ContextAliases map[int]int `json:"context_aliases,omitempty"`
}
type BiomeMaterialConfig struct {
	Format         string              `json:"format"`
	Source         string              `json:"source"`
	SourceSHA      string              `json:"source_sha256"`
	Install        string              `json:"install"`
	Rules          MaterialRules       `json:"rules"`
	MaxGrassyPatch int                 `json:"max_grassy_patch"`
	Colors         map[string][3]uint8 `json:"colors"`
}

func profileMatrix(p MaterialProfile) [][]int {
	a := make([][]int, len(materialContexts))
	for i := range a {
		a[i] = make([]int, len(p.Palette))
	}
	return a
}
func profilePreserves(p MaterialProfile, tex int) bool {
	if p.Rules == nil {
		return tex == 4
	}
	return tex >= 0 && tex < len(p.Palette) && slices.Contains(p.Rules.Preserve, p.Palette[tex])
}
func profileProtected(p MaterialProfile, t w3e.Tilepoint, mask string) bool {
	return t.Boundary || mask == "rigid" || profilePreserves(p, int(t.GroundTexture)) || landscapeWet(t, p.WaterOffset)
}
func profileFeatures(m *Map, p MaterialProfile) []MaterialFeature {
	if p.Rules == nil {
		return materialFeatures(m, p.WaterOffset)
	}
	r := p.Rules
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	f := make([]MaterialFeature, w*h)
	wet := make([]bool, w*h)
	structures := make([]int, w*h)
	ox, oy := float64(m.Terrain.CenterOffset[0]), float64(m.Terrain.CenterOffset[1])
	for i, t := range m.Terrain.Tiles {
		wet[i] = landscapeWet(t, p.WaterOffset)
		f[i].Shore = 1536
	}
	for _, d := range m.Doodads.Doodads {
		tree, rock, scene := slices.Contains(r.Trees, d.TypeID), slices.Contains(r.Rocks, d.TypeID), slices.Contains(r.Structures, d.TypeID)
		if !tree && !rock && !scene {
			continue
		}
		x, y := (float64(d.Position[0])-ox)/128, (float64(d.Position[1])-oy)/128
		n := int(math.Ceil(max(r.TreeRadius, r.RockRadius)/128)) + 1
		for yy := max(0, int(math.Floor(y))-n); yy <= min(h-1, int(math.Ceil(y))+n); yy++ {
			for xx := max(0, int(math.Floor(x))-n); xx <= min(w-1, int(math.Ceil(x))+n); xx++ {
				ds := (float64(xx)-x)*(float64(xx)-x) + (float64(yy)-y)*(float64(yy)-y)
				i := xx + yy*w
				if tree && ds <= r.TreeRadius*r.TreeRadius/(128*128) {
					f[i].Trees++
				}
				if rock && ds <= r.RockRadius*r.RockRadius/(128*128) {
					f[i].Rocks++
				}
				if scene && ds <= r.RockRadius*r.RockRadius/(128*128) {
					structures[i]++
				}
			}
		}
	}
	for i, t := range m.Terrain.Tiles {
		x, y := i%w, i/w
		for yy := max(0, y-12); yy <= min(h-1, y+12); yy++ {
			for xx := max(0, x-12); xx <= min(w-1, x+12); xx++ {
				if wet[xx+yy*w] {
					f[i].Shore = min(f[i].Shore, math.Hypot(float64(xx-x), float64(yy-y))*128)
				}
			}
		}
		for _, j := range materialNeighbors(i, w, h) {
			f[i].Slope = max(f[i].Slope, math.Abs(float64(t.FinalZ()-m.Terrain.Tiles[j].FinalZ()))/2)
		}
		c := 7
		if structures[i] > 0 {
			c = 6
		}
		if f[i].Trees > 0 {
			c = 5
		}
		if f[i].Trees >= r.ForestMin {
			c = 4
		}
		if f[i].Rocks > 0 {
			c = 3
		}
		if f[i].Slope > r.SlopeMin {
			c = 2
		}
		if f[i].Shore <= r.ShoreRadius {
			c = 1
		}
		if profilePreserves(p, int(t.GroundTexture)) {
			c = 6
		}
		if wet[i] {
			c = 0
		}
		if alias, ok := r.ContextAliases[c]; ok {
			c = alias
		}
		f[i].Context = c
	}
	return f
}
func checkBiomeGrid(m *Map) error {
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	if w < 33 || h < 33 || w > 257 || h > 257 || len(m.Terrain.Tiles) != w*h || len(m.Terrain.GroundTilesets) < 1 || len(m.Terrain.GroundTilesets) > 16 {
		return fmt.Errorf("biome grid outside supported 32..256 cell range")
	}
	for _, t := range m.Terrain.Tiles {
		if int(t.GroundTexture) >= len(m.Terrain.GroundTilesets) {
			return fmt.Errorf("invalid ground texture")
		}
	}
	return nil
}

// Remap the source's texture ordinals into the destination palette while keeping
// sample selection order and RNG unchanged. Missing materials never get aliases.
func materialTarget(p *MaterialProfile, m *Map) error {
	if p.Rules == nil {
		return checkMaterialMap(m)
	}
	if e := checkBiomeGrid(m); e != nil {
		return e
	}
	for name, hash := range p.ObjectDefinitions {
		if Hash(m.Files[name]) != hash {
			return fmt.Errorf("object definitions differ: %s; a reviewed destination catalog is required", name)
		}
	}
	if len(p.Palette) != len(m.Terrain.GroundTilesets) {
		return fmt.Errorf("destination palette set differs")
	}
	mapping := make([]int, len(p.Palette))
	seen := map[string]bool{}
	for i, id := range p.Palette {
		mapping[i] = slices.Index(m.Terrain.GroundTilesets, id)
		if mapping[i] < 0 || seen[id] {
			return fmt.Errorf("missing or repeated destination material %s", id)
		}
		seen[id] = true
	}
	if slices.Equal(p.Palette, m.Terrain.GroundTilesets) {
		return nil
	}
	for i := range p.Samples {
		s := &p.Samples[i]
		s.Texture = mapping[s.Texture]
		for k, t := range s.Patch3 {
			if t >= 0 {
				s.Patch3[k] = mapping[t]
			}
		}
		for k, t := range s.Patch5 {
			if t >= 0 {
				s.Patch5[k] = mapping[t]
			}
		}
	}
	for _, matrix := range [][][]int{p.Counts, p.HoldoutCounts} {
		for c, row := range matrix {
			v := make([]int, len(row))
			for i, n := range row {
				v[mapping[i]] = n
			}
			matrix[c] = v
		}
	}
	p.Palette = slices.Clone(m.Terrain.GroundTilesets)
	return nil
}
func materialSplit(i, w, h int, partition string) string {
	split := func(x, y int) bool { return ((x/16)+3*(y/16))%5 == 0 }
	x, y := i%w, i/w
	held := split(x, y)
	if partition == "purged-blocks-v1" {
		for yy := max(0, y-2); yy <= min(h-1, y+2); yy++ {
			for xx := max(0, x-2); xx <= min(w-1, x+2); xx++ {
				if split(xx, yy) != held {
					return "purged"
				}
			}
		}
	}
	if held {
		return "holdout"
	}
	return "train"
}
func materialV2Samples(m *Map, p *MaterialProfile) {
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	p.Features = profileFeatures(m, *p)
	p.Samples = nil
	p.Counts = profileMatrix(*p)
	p.HoldoutCounts = profileMatrix(*p)
	for i, t := range m.Terrain.Tiles {
		if t.Boundary || p.Features[i].Context == 0 {
			continue
		}
		split := materialSplit(i, w, h, p.Rules.Partition)
		if split == "purged" {
			continue
		}
		s := MaterialSample{Index: i, Context: p.Features[i].Context, Texture: int(t.GroundTexture), Variation: int(t.TextureDetails & 31), Split: split}
		for dy := -2; dy <= 2; dy++ {
			for dx := -2; dx <= 2; dx++ {
				x, y := i%w+dx, i/w+dy
				tex, c := -1, -1
				if x >= 0 && y >= 0 && x < w && y < h {
					j := x + y*w
					tex = int(m.Terrain.Tiles[j].GroundTexture)
					c = p.Features[j].Context
				}
				s.Patch5 = append(s.Patch5, tex)
				s.Context5 = append(s.Context5, c)
				if absInt(dx) <= 1 && absInt(dy) <= 1 {
					s.Patch3 = append(s.Patch3, tex)
				}
			}
		}
		p.Samples = append(p.Samples, s)
		if split == "train" {
			p.Counts[s.Context][s.Texture]++
		} else {
			p.HoldoutCounts[s.Context][s.Texture]++
		}
	}
}
func validateMaterialRules(r *MaterialRules) error {
	if r == nil || r.TreeRadius < 32 || r.TreeRadius > 768 || r.RockRadius < 32 || r.RockRadius > 768 || r.ShoreRadius < 32 || r.ShoreRadius > 1536 || r.ForestMin < 1 || r.SlopeMin <= 0 || !slices.Contains([]string{"purged-blocks-v1", "legacy-blocks-v1"}, r.Partition) {
		return fmt.Errorf("invalid material rules")
	}
	for _, ids := range [][]string{r.Trees, r.Rocks, r.Structures, r.Preserve} {
		for _, id := range ids {
			if len(id) != 4 {
				return fmt.Errorf("invalid profile rawcode")
			}
		}
	}
	for a, b := range r.ContextAliases {
		if a < 1 || a > 7 || b < 1 || b > 7 || a == b {
			return fmt.Errorf("invalid context alias")
		}
		if _, ok := r.ContextAliases[b]; ok {
			return fmt.Errorf("chained context alias")
		}
	}
	return nil
}
func verifyMaterialV2(p MaterialProfile) error {
	if e := validateMaterialRules(p.Rules); e != nil {
		return e
	}
	if p.Geometry == nil || p.Algorithm != "context-patchmatch-v2" || p.Iterations < 1 || p.Iterations > 12 || p.Candidates < 8 || p.Candidates > 64 || p.FrequencyWeight <= 0 || p.FrequencyWeight > 10 || p.TVLimit != .20 || p.MaxGrassyPatch < 1 || !slices.Equal(p.Contexts, materialContexts) {
		return fmt.Errorf("invalid v2 profile contract")
	}
	m, e := Load(p.Source)
	if e != nil {
		return e
	}
	if e = checkBiomeGrid(m); e != nil {
		return e
	}
	if m.Hash != p.SourceSHA || Hash(m.Files["war3map.w3e"]) != p.TerrainSHA || Hash(m.Files["war3map.doo"]) != p.DoodadsSHA || !slices.Equal(p.Palette, m.Terrain.GroundTilesets) || *p.Geometry != (MaterialGeometry{int(m.Terrain.Width), int(m.Terrain.Height), m.Terrain.CenterOffset}) {
		return fmt.Errorf("v2 source provenance mismatch")
	}
	if math.IsNaN(p.WaterOffset) || math.IsInf(p.WaterOffset, 0) || math.Abs(p.WaterOffset) > 512 {
		return fmt.Errorf("invalid water offset")
	}
	for _, name := range []string{"TerrainArt\\Terrain.slk", "TerrainArt\\Water.slk"} {
		if len(p.ResourceData[name]) == 0 || Hash(p.ResourceData[name]) != p.Resources[name] {
			return fmt.Errorf("v2 resource evidence differs: %s", name)
		}
	}
	tt := slk.New()
	if e := tt.Load(p.ResourceData["TerrainArt\\Terrain.slk"]); e != nil {
		return e
	}
	for _, id := range p.Palette {
		if !reflect.DeepEqual(map[string]string(tt.Rows[id]), p.Properties[id]) {
			return fmt.Errorf("material properties differ: %s", id)
		}
	}
	wt := slk.New()
	if e := wt.Load(p.ResourceData["TerrainArt\\Water.slk"]); e != nil {
		return e
	}
	wz, e := strconv.ParseFloat(wt.Rows[string(m.Terrain.Tileset)+"Sha"].String("height"), 64)
	if e != nil || wz*128 != p.WaterOffset {
		return fmt.Errorf("water resource offset differs")
	}
	expected := p
	materialV2Samples(m, &expected)
	if !reflect.DeepEqual(p.Samples, expected.Samples) || !reflect.DeepEqual(p.Features, expected.Features) || !reflect.DeepEqual(p.Counts, expected.Counts) || !reflect.DeepEqual(p.HoldoutCounts, expected.HoldoutCounts) {
		return fmt.Errorf("v2 source samples/features differ")
	}
	for _, name := range []string{"war3map.w3b", "war3map.w3d"} {
		if p.ObjectDefinitions[name] != Hash(m.Files[name]) {
			return fmt.Errorf("v2 object definitions differ")
		}
	}
	return nil
}
func CreateBiomeMaterialProfile(config, out string) error {
	var c BiomeMaterialConfig
	if e := strictJSON(config, &c); e != nil {
		return e
	}
	if c.Format != "wc3-biome-material-config-v1" {
		return fmt.Errorf("invalid biome material config")
	}
	if e := validateMaterialRules(&c.Rules); e != nil {
		return e
	}
	if !filepath.IsAbs(c.Source) {
		c.Source = filepath.Join(filepath.Dir(config), c.Source)
	}
	source, e := filepath.Abs(c.Source)
	if e != nil {
		return e
	}
	m, e := Load(source)
	if e != nil {
		return e
	}
	if m.Hash != c.SourceSHA {
		return fmt.Errorf("biome donor hash mismatch")
	}
	if e = checkBiomeGrid(m); e != nil {
		return e
	}
	stock, e := mpqchain.Open(c.Install)
	if e != nil {
		return e
	}
	defer stock.Close()
	resolver := Resolver{Map: m, Stock: stock}
	p := MaterialProfile{Format: "wc3-material-profile-v2", Algorithm: "context-patchmatch-v2", Source: source, SourceSHA: m.Hash, TerrainSHA: Hash(m.Files["war3map.w3e"]), DoodadsSHA: Hash(m.Files["war3map.doo"]), Palette: m.Terrain.GroundTilesets, Contexts: materialContexts, Resources: map[string]string{}, Properties: map[string]map[string]string{}, Iterations: 5, Candidates: 24, FrequencyWeight: 2, TVLimit: .20, MaxGrassyPatch: c.MaxGrassyPatch, Geometry: &MaterialGeometry{int(m.Terrain.Width), int(m.Terrain.Height), m.Terrain.CenterOffset}, Rules: &c.Rules, Colors: c.Colors, ObjectDefinitions: map[string]string{}}
	terrain, e := resolver.Table("TerrainArt\\Terrain.slk")
	if e != nil {
		return e
	}
	water, e := resolver.Table("TerrainArt\\Water.slk")
	if e != nil {
		return e
	}
	for _, id := range p.Palette {
		row := terrain.Rows[id]
		if row == nil {
			return fmt.Errorf("unknown Classic tile %s", id)
		}
		p.Properties[id] = row
	}
	row := water.Rows[string(m.Terrain.Tileset)+"Sha"]
	if row == nil {
		return fmt.Errorf("missing Classic water row")
	}
	z, e := strconv.ParseFloat(row.String("height"), 64)
	if e != nil {
		return e
	}
	p.WaterOffset = z * 128
	for _, name := range []string{"TerrainArt\\Terrain.slk", "TerrainArt\\Water.slk"} {
		raw, _, err := resolver.Read(name)
		if err != nil {
			return err
		}
		p.Resources[name] = Hash(raw)
		if p.ResourceData == nil {
			p.ResourceData = map[string][]byte{}
		}
		p.ResourceData[name] = raw
	}
	for _, name := range []string{"war3map.w3b", "war3map.w3d"} {
		p.ObjectDefinitions[name] = Hash(m.Files[name])
	}
	materialV2Samples(m, &p)
	if e = verifyMaterialV2(p); e != nil {
		return e
	}
	return JSON(out, p)
}
