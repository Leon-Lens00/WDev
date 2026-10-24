package terrainproc

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"hash/fnv"
	"io"
	"math"
	"math/rand"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strconv"
	"strings"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
)

// V3 is opt-in. No defaults or random streams of the two existing modes change.
type SceneOptions struct {
	Library    string          `json:"library"`
	LibrarySHA string          `json:"library_sha256"`
	Brief      SceneBrief      `json:"brief"`
	Instances  []SceneInstance `json:"instances"`
	Cameras    []string        `json:"camera_instances"`
	ForestSeed int             `json:"forest_seed"`
	MaxObjects int             `json:"max_objects"`
}
type SceneBrief struct {
	Format           string            `json:"format"`
	ID               string            `json:"id"`
	Intent           string            `json:"intent"`
	Silhouette       string            `json:"silhouette"`
	Counts           map[string]int    `json:"counts"`
	Ranges           map[string][2]int `json:"ranges,omitempty"`
	IncludeRecovered bool              `json:"include_recovered"`
	Forest           string            `json:"forest"`
	Seeds            []int             `json:"seeds"`
	CameraRoles      []string          `json:"camera_roles"`
	Links            []SceneLink       `json:"links,omitempty"`
}
type SceneLink struct {
	From     string `json:"from"`
	To       string `json:"to"`
	FromPort string `json:"from_port"`
	ToPort   string `json:"to_port"`
	Role     string `json:"role"`
}
type SceneInstance struct {
	ID       string `json:"id"`
	Family   string `json:"family"`
	Rotation int    `json:"rotation"`
	Variant  int    `json:"variant"`
}
type PieceGroup struct {
	ID       string   `json:"id"`
	Members  []uint32 `json:"members"`
	Children []string `json:"children,omitempty"`
}
type SceneComponent struct {
	PrefabSpec
	Kind     string   `json:"kind"`
	Groups   []string `json:"groups"`
	Required []uint32 `json:"required"`
	Optional []uint32 `json:"optional"`
	Habitat  string   `json:"habitat"`
	Evidence []string `json:"evidence"`
}
type EnvironmentRecipe struct {
	ID           string   `json:"id"`
	SourceIDs    []uint32 `json:"source_ids"`
	Habitat      string   `json:"habitat"`
	HeightPolicy string   `json:"height_policy"`
	Density      float64  `json:"density"`
}
type ForestCohort struct {
	MinimumSpacing    float64  `json:"minimum_spacing"`
	ClosePairSpacing  float64  `json:"close_pair_spacing"`
	ThinClosePairs    bool     `json:"thin_close_pairs"`
	AnchorNeighborMax float64  `json:"anchor_neighbor_max"`
	ID                string   `json:"id"`
	Bounds            Rect     `json:"bounds"`
	SourceIDs         []uint32 `json:"source_ids"`
	Evidence          []string `json:"evidence"`
}
type SceneLibrary struct {
	Format     string              `json:"format"`
	SourceSHA  string              `json:"source_sha256"`
	Components []SceneComponent    `json:"components"`
	Groups     []PieceGroup        `json:"groups"`
	Recipes    []EnvironmentRecipe `json:"recipes"`
	Cohorts    []ForestCohort      `json:"forest_cohorts"`
	Coverage   map[uint32]string   `json:"coverage"`
	Review     string              `json:"review"`
	ReviewSHA  string              `json:"review_sha256"`
}
type Provenance struct {
	CreationID uint32 `json:"creation_id"`
	SourceID   uint32 `json:"source_id"`
	Instance   string `json:"instance"`
	Family     string `json:"family"`
	Role       string `json:"role"`
}

func sceneSeed(seed int, stage, instance string) int64 {
	h := fnv.New64a()
	var b [8]byte
	binary.LittleEndian.PutUint64(b[:], uint64(seed))
	h.Write(b[:])
	h.Write([]byte("scene-v1\x00" + stage + "\x00" + instance))
	return int64(h.Sum64() & math.MaxInt64)
}
func strictJSON(path string, dst any) error {
	b, e := os.ReadFile(path)
	if e != nil {
		return e
	}
	d := json.NewDecoder(strings.NewReader(string(b)))
	d.DisallowUnknownFields()
	if e = d.Decode(dst); e != nil {
		return e
	}
	if d.Decode(new(any)) != io.EOF {
		return fmt.Errorf("trailing JSON: %s", path)
	}
	return nil
}

func (s Spec) validateScenes() error {
	if s.Format != "wc3-scene-spec-v3" || s.Scene == nil || s.Scene.Library == "" || len(s.Scene.LibrarySHA) != 64 || s.Scene.MaxObjects < 1000 || s.Scene.MaxObjects > 6500 {
		return fmt.Errorf("invalid scene v3 header/budget")
	}
	// Reuse the proven donor, classic palette and bounded WFC contract.
	base := s
	base.Mode = "whole-map-recompose"
	base.Format = "wc3-scene-spec-v2"
	base.Scene = nil
	if e := base.validateRecompose(); e != nil {
		return e
	}
	if s.Scene.ForestSeed < 0 || len(s.Scene.Instances) == 0 || len(s.Scene.Instances) > 40 || len(s.Scene.Cameras) != 17 {
		return fmt.Errorf("invalid instances/forest seed/camera bindings")
	}
	seen := map[string]bool{}
	for _, i := range s.Scene.Instances {
		if i.ID == "" || i.Family == "" || seen[i.ID] || i.Rotation%90 != 0 || i.Rotation < 0 || i.Rotation >= 360 || i.Variant < 0 || i.Variant > 1 {
			return fmt.Errorf("invalid instance %s", i.ID)
		}
		seen[i.ID] = true
	}
	for _, id := range s.Scene.Cameras {
		if !seen[id] {
			return fmt.Errorf("camera references absent instance %s", id)
		}
	}
	if s.Scene.Brief.Forest != "compact" && s.Scene.Brief.Forest != "legacy-control" {
		return fmt.Errorf("unknown forest strategy")
	}
	return nil
}

func flattenGroups(groups []PieceGroup, roots []string) ([]uint32, error) {
	by := map[string]PieceGroup{}
	for _, g := range groups {
		if g.ID == "" {
			return nil, fmt.Errorf("empty group")
		}
		if _, ok := by[g.ID]; ok {
			return nil, fmt.Errorf("duplicate group")
		}
		by[g.ID] = g
	}
	active, done, ids := map[string]bool{}, map[string]bool{}, map[uint32]bool{}
	var visit func(string) error
	visit = func(id string) error {
		if active[id] {
			return fmt.Errorf("group cycle: %s", id)
		}
		if done[id] {
			return nil
		}
		g, ok := by[id]
		if !ok {
			return fmt.Errorf("missing group %s", id)
		}
		active[id] = true
		local := map[uint32]bool{}
		for _, n := range g.Members {
			if local[n] {
				return fmt.Errorf("duplicate piece in group %s", id)
			}
			local[n] = true
			ids[n] = true
		}
		for _, c := range g.Children {
			if e := visit(c); e != nil {
				return e
			}
		}
		delete(active, id)
		done[id] = true
		return nil
	}
	for _, id := range roots {
		if e := visit(id); e != nil {
			return nil, e
		}
	}
	result := make([]uint32, 0, len(ids))
	for id := range ids {
		result = append(result, id)
	}
	slices.Sort(result)
	return result, nil
}

func loadSceneLibrary(g *Scene) (SceneLibrary, Library, error) {
	var l SceneLibrary
	empty := Library{}
	if e := strictJSON(g.Spec.Scene.Library, &l); e != nil {
		return l, empty, e
	}
	raw, _ := os.ReadFile(g.Spec.Scene.Library)
	if Hash(raw) != g.Spec.Scene.LibrarySHA || l.Format != "wc3-composition-library-v2" || l.SourceSHA != g.Map.Hash {
		return l, empty, fmt.Errorf("library fingerprint/version mismatch")
	}
	review, e := os.ReadFile(l.Review)
	if e != nil || Hash(review) != l.ReviewSHA {
		return l, empty, fmt.Errorf("missing/changed library review")
	}
	var evidence struct {
		Complete        bool `json:"complete"`
		ReviewedSectors int  `json:"reviewed_sectors"`
	}
	if json.Unmarshal(review, &evidence) != nil || !evidence.Complete || evidence.ReviewedSectors != 32 {
		return l, empty, fmt.Errorf("library review incomplete")
	}
	byID := map[uint32]doodadsdoo.Doodad{}
	for _, d := range g.Map.Doodads.Doodads {
		byID[d.CreationNumber] = d
	}
	built := Library{Format: l.Format, SourceSHA: l.SourceSHA, Ownership: map[uint32]string{}}
	names := map[string]bool{}
	claim := func(id uint32, owner string) error {
		if _, ok := byID[id]; !ok {
			return fmt.Errorf("missing source object %d", id)
		}
		if old := built.Ownership[id]; old != "" {
			return fmt.Errorf("source %d owned twice: %s/%s", id, old, owner)
		}
		if l.Coverage[id] != owner {
			return fmt.Errorf("coverage mismatch %d", id)
		}
		built.Ownership[id] = owner
		return nil
	}
	for _, c := range l.Components {
		if names[c.ID] || c.ID == "" || len(c.Evidence) == 0 || len(c.Required) == 0 || (c.Kind != "main" && c.Kind != "micro") {
			return l, empty, fmt.Errorf("invalid component %s", c.ID)
		}
		names[c.ID] = true
		for _, path := range c.Evidence {
			if _, e := os.Stat(path); e != nil {
				return l, empty, fmt.Errorf("missing visual evidence %s", path)
			}
		}
		for name, a := range c.Anchors {
			if !finite(a[0]) || !finite(a[1]) || !c.Source.Contains(a[0], a[1]) {
				return l, empty, fmt.Errorf("invalid anchor %s/%s", c.ID, name)
			}
		}
		if c.Kind == "main" {
			for _, old := range g.Spec.Recompose.Compositions {
				if old.ID == c.ID {
					for name := range old.Anchors {
						if _, ok := c.Anchors[name]; !ok {
							return l, empty, fmt.Errorf("missing anchor %s/%s", c.ID, name)
						}
					}
				}
			}
		}
		for k := 0; k < 2; k++ {
			if c.Source.Min[k] >= c.Source.Max[k] || math.Mod(c.Source.Min[k], 128) != 0 || math.Mod(c.Source.Max[k], 128) != 0 {
				return l, empty, fmt.Errorf("unaligned support %s", c.ID)
			}
		}
		if c.Blend < 128 || c.Blend > 1024 || len(c.Rotations) == 0 {
			return l, empty, fmt.Errorf("invalid blend/rotation %s", c.ID)
		}
		ids, e := flattenGroups(l.Groups, c.Groups)
		if e != nil {
			return l, empty, e
		}
		p := Prefab{PrefabSpec: c.PrefabSpec, Pivot: [2]float64{math.Floor((c.Source.Min[0]+c.Source.Max[0])/256) * 128, math.Floor((c.Source.Min[1]+c.Source.Max[1])/256) * 128}, HeightPolicy: "rigid annotated support; zero Z translation"}
		// Original major pivots are preserved, including their 64-unit phase.
		if c.Kind == "main" {
			p.Pivot = [2]float64{(c.Source.Min[0] + c.Source.Max[0]) / 2, (c.Source.Min[1] + c.Source.Max[1]) / 2}
		}
		for _, id := range ids {
			if e := claim(id, c.ID); e != nil {
				return l, empty, e
			}
			d := byID[id]
			if !c.Source.Contains(float64(d.Position[0]), float64(d.Position[1])) {
				return l, empty, fmt.Errorf("piece outside support: %d", id)
			}
			if slices.Contains(c.Required, id) == slices.Contains(c.Optional, id) {
				return l, empty, fmt.Errorf("ambiguous/missing role: %d", id)
			}
			p.Pieces = append(p.Pieces, d)
		}
		for _, id := range append(slices.Clone(c.Required), c.Optional...) {
			if !slices.Contains(ids, id) {
				return l, empty, fmt.Errorf("role references missing member %d", id)
			}
		}
		for _, angle := range c.Rotations {
			if angle%90 != 0 || angle < 0 || angle >= 360 {
				return l, empty, fmt.Errorf("invalid rotation")
			}
			if angle != 0 && c.Kind == "main" {
				return l, empty, fmt.Errorf("main rotation unproven")
			}
			if angle != 0 {
				for _, d := range p.Pieces {
					a := g.Catalog.Assets[d.TypeID]
					if fixed, e := strconv.ParseFloat(a.Fields["fixedrot"], 64); e == nil && fixed >= 0 {
						return l, empty, fmt.Errorf("fixed orientation resource cannot rotate: %s", d.TypeID)
					}
					if strings.HasPrefix(d.TypeID, "ZTr") {
						return l, empty, fmt.Errorf("directional stairs require substitution annotation")
					}
				}
			}
		}
		p.SupportWidth = int((c.Source.Max[0]-c.Source.Min[0])/128) + 1
		p.SupportHeight = int((c.Source.Max[1]-c.Source.Min[1])/128) + 1
		for y := c.Source.Min[1]; y <= c.Source.Max[1]; y += 128 {
			for x := c.Source.Min[0]; x <= c.Source.Max[0]; x += 128 {
				i := g.index(x, y)
				if i < 0 {
					return l, empty, fmt.Errorf("source support out of bounds")
				}
				p.Support = append(p.Support, g.Original[i])
			}
		}
		built.Prefabs = append(built.Prefabs, p)
	}
	for _, r := range l.Recipes {
		if names[r.ID] || r.ID == "" || r.Density <= 0 || len(r.SourceIDs) == 0 {
			return l, empty, fmt.Errorf("invalid recipe %s", r.ID)
		}
		names[r.ID] = true
		if !slices.Contains([]string{"forest", "land", "rocky", "shore", "shallow-water"}, r.Habitat) || !slices.Contains([]string{"water-offset", "ground-offset"}, r.HeightPolicy) {
			return l, empty, fmt.Errorf("invalid habitat/height policy %s", r.ID)
		}
		for _, id := range r.SourceIDs {
			if e := claim(id, r.ID); e != nil {
				return l, empty, e
			}
		}
	}
	if len(built.Ownership) != len(byID) || len(l.Coverage) != len(byID) {
		return l, empty, fmt.Errorf("incomplete source coverage")
	}
	for _, c := range l.Cohorts {
		if len(c.SourceIDs) < 3 || len(c.Evidence) == 0 {
			return l, empty, fmt.Errorf("unreviewed forest cohort")
		}
		for _, id := range c.SourceIDs {
			if !slices.Contains(g.Spec.Trees, byID[id].TypeID) {
				return l, empty, fmt.Errorf("non-tree in cohort")
			}
		}
	}
	return l, built, nil
}

func CompileSceneBrief(base Spec, briefPath, libraryPath, out string) error {
	var b SceneBrief
	var l SceneLibrary
	if e := strictJSON(briefPath, &b); e != nil {
		return e
	}
	if e := strictJSON(libraryPath, &l); e != nil {
		return e
	}
	if b.Format != "wc3-scene-brief-v1" || b.ID == "" || len(b.Seeds) == 0 || len(b.CameraRoles) == 0 || (b.Silhouette != "archipelago" && b.Silhouette != "dominant-island" && b.Silhouette != "scattered") {
		return fmt.Errorf("invalid brief")
	}
	libPath, e := filepath.Abs(libraryPath)
	if e != nil {
		return e
	}
	raw, e := os.ReadFile(libPath)
	if e != nil {
		return e
	}
	base.Scene = &SceneOptions{Library: libPath, LibrarySHA: Hash(raw), Brief: b, ForestSeed: base.Seed, MaxObjects: 6500}
	base.Format = "wc3-scene-spec-v3"
	base.Mode = "whole-map-scene"
	base.Recompose.LayoutAttempts = 128
	base.Trees = append(base.Trees, "ZTtc")
	if e := resolveInstances(&base, l); e != nil {
		return e
	}
	if e := base.Validate(); e != nil {
		return e
	}
	return JSON(out, base)
}
func resolveInstances(s *Spec, l SceneLibrary) error {
	b := s.Scene.Brief
	known := map[string]SceneComponent{}
	for _, c := range l.Components {
		known[c.ID] = c
	}
	for id, n := range b.Counts {
		if _, ok := known[id]; !ok || n < 0 || n > 8 {
			return fmt.Errorf("unknown/impossible count %s", id)
		}
	}
	counts := map[string]int{}
	for id, n := range b.Counts {
		counts[id] = n
	}
	for id, r := range b.Ranges {
		if _, ok := known[id]; !ok || r[0] < 0 || r[1] < r[0] || r[1] > 8 {
			return fmt.Errorf("invalid range %s", id)
		}
		if _, ok := b.Counts[id]; ok {
			return fmt.Errorf("both count and range: %s", id)
		}
		rng := rand.New(rand.NewSource(sceneSeed(s.Seed, "counts", id)))
		counts[id] = r[0] + rng.Intn(r[1]-r[0]+1)
	}
	if b.IncludeRecovered {
		for _, c := range l.Components {
			if c.Kind == "micro" {
				counts[c.ID] = max(1, counts[c.ID])
			}
		}
	}
	s.Scene.Instances = nil
	s.Scene.Cameras = nil
	ids := make([]string, 0, len(counts))
	for id := range counts {
		ids = append(ids, id)
	}
	sort.Strings(ids)
	for _, id := range ids {
		c := known[id]
		for n := 0; n < counts[id]; n++ {
			name := fmt.Sprintf("%s-%d", id, n+1)
			rng := rand.New(rand.NewSource(sceneSeed(s.Seed, "variants", name)))
			s.Scene.Instances = append(s.Scene.Instances, SceneInstance{name, id, c.Rotations[rng.Intn(len(c.Rotations))], rng.Intn(2)})
		}
	}
	mains := []SceneInstance{}
	for _, i := range s.Scene.Instances {
		if known[i.Family].Kind == "main" {
			mains = append(mains, i)
		}
	}
	if len(mains) < 1 || len(mains) > 12 || len(s.Scene.Instances) > 40 {
		return fmt.Errorf("brief exceeds scene packing budget")
	}
	for n := 0; n < 17; n++ {
		role := b.CameraRoles[n%len(b.CameraRoles)]
		target := ""
		for _, i := range mains {
			if i.Family == role {
				target = i.ID
				break
			}
		}
		if target == "" {
			target = mains[n%len(mains)].ID
		}
		s.Scene.Cameras = append(s.Scene.Cameras, target)
	}
	valid := map[string]bool{}
	for _, i := range s.Scene.Instances {
		valid[i.ID] = true
	}
	for _, edge := range b.Links {
		if !valid[edge.From] || !valid[edge.To] || edge.From == edge.To {
			return fmt.Errorf("link to absent instance")
		}
		if edge.Role != "scenic" {
			return fmt.Errorf("unsupported inter-island route role; local walking ports are validated separately")
		}
	}
	return nil
}
