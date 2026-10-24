package terrainproc

import (
	"fmt"
	"math"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"strconv"

	"github.com/StephenSHorton/wc3-forge/internal/formats/slk"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/mpqchain"
)

var materialContexts = []string{"water", "coast", "rock-slope", "rock-isolated", "forest-interior", "forest-edge", "scene", "clearing"}
var materialTrees = []string{"B000", "B001", "B002", "B003", "B004", "ZTtc"}
var materialRocks = []string{"ZRrk", "ZRsp", "ARrk", "ZRrs", "ZRbd", "ZRbs", "BRrp"}
var materialStructures = []string{"ZTnc", "ZOob", "ZOst", "ZOss", "ZSas", "ZSrb", "ZOfo", "ZOls", "D00B", "D009"}

type MaterialFeature struct {
	Context int     `json:"context"`
	Trees   int     `json:"trees_256"`
	Rocks   int     `json:"rocks_192"`
	Slope   float64 `json:"slope_64"`
	Shore   float64 `json:"shore_distance"`
}
type MaterialSample struct {
	Index     int    `json:"source_vertex"`
	Context   int    `json:"context"`
	Texture   int    `json:"texture"`
	Variation int    `json:"variation"`
	Patch3    []int  `json:"patch3"`
	Patch5    []int  `json:"patch5"`
	Context5  []int  `json:"context5"`
	Split     string `json:"split"`
}
type MaterialProfile struct {
	ResourceData      map[string][]byte   `json:"resource_data,omitempty"`
	Geometry          *MaterialGeometry   `json:"geometry,omitempty"`
	Rules             *MaterialRules      `json:"rules,omitempty"`
	Colors            map[string][3]uint8 `json:"colors,omitempty"`
	ObjectDefinitions map[string]string   `json:"object_definitions,omitempty"`

	Format          string                       `json:"format"`
	Algorithm       string                       `json:"algorithm"`
	Source          string                       `json:"source"`
	SourceSHA       string                       `json:"source_sha256"`
	TerrainSHA      string                       `json:"terrain_sha256"`
	DoodadsSHA      string                       `json:"doodads_sha256"`
	Palette         []string                     `json:"palette"`
	Contexts        []string                     `json:"contexts"`
	WaterOffset     float64                      `json:"water_slk_offset"`
	Resources       map[string]string            `json:"resource_hashes"`
	Properties      map[string]map[string]string `json:"terrain_properties"`
	Samples         []MaterialSample             `json:"samples"`
	Features        []MaterialFeature            `json:"features"`
	Counts          [][]int                      `json:"training_counts"`
	HoldoutCounts   [][]int                      `json:"holdout_counts"`
	Iterations      int                          `json:"iterations"`
	Candidates      int                          `json:"random_candidates"`
	FrequencyWeight float64                      `json:"frequency_weight"`
	TVLimit         float64                      `json:"tv_limit"`
	MaxGrassyPatch  int                          `json:"max_grassy_patch"`
}
type MaterialOptions struct {
	Profile    string `json:"profile"`
	ProfileSHA string `json:"profile_sha256"`
	Seed       int    `json:"seed"`
	// Relocates the verified donor without rewriting the immutable profile.
	// SourceSHA and all sampled layers are still checked by verifyMaterialV2.
	SourceOverride string `json:"source_override,omitempty"`
	ContextualFix  string `json:"contextual_fix,omitempty"`
}

func checkMaterialMap(m *Map) error {
	if m.Terrain.Width != 193 || m.Terrain.Height != 97 || m.Terrain.CenterOffset != [2]float32{-12288, -4096} || !slices.Equal(m.Terrain.GroundTilesets, []string{"Zdrt", "Zdtr", "Zdrg", "Zsan", "Zbkl", "Arck", "Agrd", "Alvd", "Avin"}) {
		return fmt.Errorf("material profile requires the classic tropical palette and 193x97 grid")
	}
	return nil
}
func materialFeatures(m *Map, offset float64) []MaterialFeature {
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	f := make([]MaterialFeature, w*h)
	wet := make([]bool, w*h)
	structure := make([]int, w*h)
	for i, t := range m.Terrain.Tiles {
		wet[i] = landscapeWet(t, offset)
		f[i].Shore = 1536
	}
	for _, d := range m.Doodads.Doodads {
		tree, rock, scene := slices.Contains(materialTrees, d.TypeID), slices.Contains(materialRocks, d.TypeID), slices.Contains(materialStructures, d.TypeID)
		if !tree && !rock && !scene {
			continue
		}
		x, y := (float64(d.Position[0])+12288)/128, (float64(d.Position[1])+4096)/128
		for yy := max(0, int(math.Floor(y))-3); yy <= min(h-1, int(math.Ceil(y))+3); yy++ {
			for xx := max(0, int(math.Floor(x))-3); xx <= min(w-1, int(math.Ceil(x))+3); xx++ {
				ds := (float64(xx)-x)*(float64(xx)-x) + (float64(yy)-y)*(float64(yy)-y)
				i := xx + yy*w
				if tree && ds <= 4 {
					f[i].Trees++
				}
				if rock && ds <= 2.25 {
					f[i].Rocks++
				}
				if scene && ds <= 2.25 {
					structure[i]++
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
		if structure[i] > 0 {
			c = 6
		}
		if f[i].Trees > 0 {
			c = 5
		}
		if f[i].Trees >= 3 {
			c = 4
		}
		if f[i].Rocks > 0 {
			c = 3
		}
		if f[i].Slope > 24 {
			c = 2
		}
		if f[i].Shore <= 256 {
			c = 1
		}
		// Authored brick floors are architectural evidence, even under rocks.
		if t.GroundTexture == 4 {
			c = 6
		}
		if wet[i] {
			c = 0
		}
		f[i].Context = c
	}
	return f
}
func materialNeighbors(i, w, h int) []int {
	n := []int{}
	if i%w > 0 {
		n = append(n, i-1)
	}
	if i%w < w-1 {
		n = append(n, i+1)
	}
	if i >= w {
		n = append(n, i-w)
	}
	if i < (h-1)*w {
		n = append(n, i+w)
	}
	return n
}
func materialMatrix() [][]int {
	v := make([][]int, len(materialContexts))
	for i := range v {
		v[i] = make([]int, 9)
	}
	return v
}

func CreateMaterialProfile(source, install, out string) error {
	source, e := filepath.Abs(source)
	if e != nil {
		return e
	}
	m, e := Load(source)
	if e != nil {
		return e
	}
	if e = checkMaterialMap(m); e != nil {
		return e
	}
	stock, e := mpqchain.Open(install)
	if e != nil {
		return e
	}
	defer stock.Close()
	resolver := Resolver{Map: m, Stock: stock}
	p := MaterialProfile{Format: "wc3-material-profile-v1", Algorithm: "context-patchmatch-v1", Source: source, SourceSHA: m.Hash, TerrainSHA: Hash(m.Files["war3map.w3e"]), DoodadsSHA: Hash(m.Files["war3map.doo"]), Palette: m.Terrain.GroundTilesets, Contexts: materialContexts, Resources: map[string]string{}, Properties: map[string]map[string]string{}, Counts: materialMatrix(), HoldoutCounts: materialMatrix(), Iterations: 5, Candidates: 24, FrequencyWeight: 2.0, TVLimit: .20, MaxGrassyPatch: 112}
	for _, path := range []string{"TerrainArt\\Terrain.slk", "TerrainArt\\Water.slk"} {
		raw, _, err := resolver.Read(path)
		if err != nil {
			return err
		}
		p.Resources[path] = Hash(raw)
		rows, err := slk.Parse(raw)
		if err != nil {
			return err
		}
		for _, row := range rows[1:] {
			if len(row) == 0 {
				continue
			}
			fields := map[string]string{}
			for j, val := range row {
				if j < len(rows[0]) {
					fields[rows[0][j]] = val
				}
			}
			if path == "TerrainArt\\Terrain.slk" && slices.Contains(p.Palette, row[0]) {
				p.Properties[row[0]] = fields
			}
			if path == "TerrainArt\\Water.slk" && row[0] == string(m.Terrain.Tileset)+"Sha" {
				z, err := strconv.ParseFloat(fields["height"], 64)
				if err != nil {
					return err
				}
				p.WaterOffset = z * 128
			}
		}
	}
	if math.Abs(p.WaterOffset+89.6) > .001 || len(p.Properties) != 9 {
		return fmt.Errorf("classic material/water table does not match expected resources")
	}
	p.Features = materialFeatures(m, p.WaterOffset)
	w, h := 193, 97
	for i, t := range m.Terrain.Tiles {
		if t.Boundary || p.Features[i].Context == 0 {
			continue
		}
		s := MaterialSample{Index: i, Context: p.Features[i].Context, Texture: int(t.GroundTexture), Variation: int(t.TextureDetails & 31), Split: "train"}
		// Spatially separated 16x16 regions, not alternating correlated vertices.
		if ((i%w)/16+3*((i/w)/16))%5 == 0 {
			s.Split = "holdout"
		}
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
		if s.Split == "train" {
			p.Counts[s.Context][s.Texture]++
		} else {
			p.HoldoutCounts[s.Context][s.Texture]++
		}
	}
	return JSON(out, p)
}
func loadMaterialProfile(o MaterialOptions) (MaterialProfile, error) {
	var p MaterialProfile
	raw, e := os.ReadFile(o.Profile)
	if e != nil {
		return p, e
	}
	if o.Seed < 0 || len(o.ProfileSHA) != 64 || Hash(raw) != o.ProfileSHA {
		return p, fmt.Errorf("invalid material profile hash/seed")
	}
	if e = strictJSON(o.Profile, &p); e != nil {
		return p, e
	}
	if p.Format == "wc3-material-profile-v2" {
		if o.SourceOverride != "" {
			p.Source = o.SourceOverride
		}
		return p, verifyMaterialV2(p)
	}
	if o.SourceOverride != "" {
		return p, fmt.Errorf("source override requires a v2 material profile")
	}
	if p.Format != "wc3-material-profile-v1" || p.Algorithm != "context-patchmatch-v1" || p.Iterations < 1 || p.Iterations > 12 || p.Candidates < 8 || p.Candidates > 64 || p.FrequencyWeight <= 0 || p.FrequencyWeight > 10 || p.TVLimit != .20 || p.MaxGrassyPatch != 112 || !slices.Equal(p.Contexts, materialContexts) || len(p.Palette) != 9 || len(p.Features) != 193*97 {
		return p, fmt.Errorf("invalid material profile contract")
	}
	actual, held := materialMatrix(), materialMatrix()
	seen := map[int]bool{}
	for _, s := range p.Samples {
		if s.Index < 0 || s.Index >= 193*97 || seen[s.Index] || s.Context < 1 || s.Context >= 8 || s.Texture < 0 || s.Texture >= 9 || s.Variation < 0 || s.Variation > 31 || len(s.Patch3) != 9 || len(s.Patch5) != 25 || len(s.Context5) != 25 || s.Patch5[12] != s.Texture || p.Features[s.Index].Context != s.Context {
			return p, fmt.Errorf("invalid source material sample")
		}
		seen[s.Index] = true
		if s.Split == "train" {
			actual[s.Context][s.Texture]++
		} else if s.Split == "holdout" {
			held[s.Context][s.Texture]++
		} else {
			return p, fmt.Errorf("unknown sample split")
		}
	}
	if len(p.Counts) != 8 || len(p.HoldoutCounts) != 8 {
		return p, fmt.Errorf("invalid context frequency dimensions")
	}
	for i := range actual {
		if !slices.Equal(actual[i], p.Counts[i]) || !slices.Equal(held[i], p.HoldoutCounts[i]) {
			return p, fmt.Errorf("source counts differ from samples")
		}
	}
	if e = verifyMaterialSource(p); e != nil {
		return p, e
	}
	return p, nil
}

func verifyMaterialSource(p MaterialProfile) error {
	m, e := Load(p.Source)
	if e != nil {
		return e
	}
	if e = checkMaterialMap(m); e != nil {
		return e
	}
	if m.Hash != p.SourceSHA || Hash(m.Files["war3map.w3e"]) != p.TerrainSHA || Hash(m.Files["war3map.doo"]) != p.DoodadsSHA || !slices.Equal(p.Palette, m.Terrain.GroundTilesets) || math.Abs(p.WaterOffset+89.6) > .001 {
		return fmt.Errorf("material source provenance mismatch")
	}
	features := materialFeatures(m, p.WaterOffset)
	if !reflect.DeepEqual(features, p.Features) {
		return fmt.Errorf("material source features differ")
	}
	eligible := 0
	for i, t := range m.Terrain.Tiles {
		if !t.Boundary && features[i].Context != 0 {
			eligible++
		}
	}
	if eligible != len(p.Samples) {
		return fmt.Errorf("source sample coverage incomplete")
	}
	for _, s := range p.Samples {
		t := m.Terrain.Tiles[s.Index]
		split := "train"
		if ((s.Index%193)/16+3*((s.Index/193)/16))%5 == 0 {
			split = "holdout"
		}
		if t.Boundary || int(t.GroundTexture) != s.Texture || int(t.TextureDetails&31) != s.Variation || s.Split != split {
			return fmt.Errorf("source sample differs at %d", s.Index)
		}
		k3 := 0
		for dy := -2; dy <= 2; dy++ {
			for dx := -2; dx <= 2; dx++ {
				x, y := s.Index%193+dx, s.Index/193+dy
				tex, c := -1, -1
				if x >= 0 && x < 193 && y >= 0 && y < 97 {
					j := x + y*193
					tex = int(m.Terrain.Tiles[j].GroundTexture)
					c = features[j].Context
				}
				k := (dy+2)*5 + dx + 2
				if s.Patch5[k] != tex || s.Context5[k] != c {
					return fmt.Errorf("source neighborhood differs at %d", s.Index)
				}
				if absInt(dx) <= 1 && absInt(dy) <= 1 {
					if s.Patch3[k3] != tex {
						return fmt.Errorf("source patch3 differs")
					}
					k3++
				}
			}
		}
	}
	return nil
}

func materialPhysicalEqual(a, b w3e.Tilepoint) bool {
	a.GroundTexture = b.GroundTexture
	a.TextureDetails = (a.TextureDetails & 224) | (b.TextureDetails & 31)
	return a == b
}
