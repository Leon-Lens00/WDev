package terrainproc

import (
	"fmt"
	"os"
	"path/filepath"
	"slices"
)

type LandscapeRelation struct {
	ID       string  `json:"id"`
	Kind     string  `json:"kind"`
	From     string  `json:"from"`
	To       string  `json:"to"`
	FromPort string  `json:"from_port"`
	ToPort   string  `json:"to_port"`
	Width    float64 `json:"width"`
}
type Territory struct {
	ID       string   `json:"id"`
	Parent   string   `json:"parent"`
	Members  []string `json:"members"`
	Isolated bool     `json:"isolated"`
	Reason   string   `json:"reason"`
}
type LandscapeBrief struct {
	Format    string              `json:"format"`
	ID        string              `json:"id"`
	Intent    string              `json:"intent"`
	Counts    map[string]int      `json:"counts"`
	Seeds     []int               `json:"seeds"`
	Groups    []Territory         `json:"groups"`
	Relations []LandscapeRelation `json:"relations"`
}
type LandscapeOptions struct {
	Landforms  *LandscapeLandformOptions `json:"landforms,omitempty"`
	Materials  *MaterialOptions          `json:"materials,omitempty"`
	Library    string                    `json:"library"`
	LibrarySHA string                    `json:"library_sha256"`
	Brief      LandscapeBrief            `json:"brief"`
	Streams    map[string]int            `json:"streams"`
	Vegetation string                    `json:"vegetation"`
}
type LandscapeModule struct {
	Parent  uint32          `json:"parent_source_id,omitempty"`
	Family  string          `json:"family"`
	Name    string          `json:"name"`
	Members []uint32        `json:"members"`
	Policy  string          `json:"height_policy"`
	Shifts  [2][][2]float64 `json:"variant_shifts"`
}
type LandscapeLibrary struct {
	Format    string            `json:"format"`
	Base      string            `json:"base_library"`
	BaseSHA   string            `json:"base_sha256"`
	SourceSHA string            `json:"source_sha256"`
	Modules   []LandscapeModule `json:"modules"`
}

func CompileLandscapeBrief(base Spec, briefPath, libraryPath, out string) error {
	var b LandscapeBrief
	var l LandscapeLibrary
	if e := strictJSON(briefPath, &b); e != nil {
		return e
	}
	if e := strictJSON(libraryPath, &l); e != nil {
		return e
	}
	raw, e := os.ReadFile(libraryPath)
	if e != nil {
		return e
	}
	p, e := filepath.Abs(libraryPath)
	if e != nil {
		return e
	}
	// Specs retain the actual revision even when the editable library advances.
	p = filepath.Join(filepath.Dir(p), "library-v3-"+Hash(raw)[:16]+".json")
	if e := os.WriteFile(p, raw, 0644); e != nil {
		return e
	}
	base.Format = "wc3-scene-spec-v4"
	base.Mode = "whole-map-landscape"
	base.Landscape = &LandscapeOptions{Library: p, LibrarySHA: Hash(raw), Brief: b, Vegetation: "habitat"}
	base.Scene = &SceneOptions{Library: l.Base, LibrarySHA: l.BaseSHA, Brief: SceneBrief{Format: "wc3-scene-brief-v1", ID: b.ID, Intent: b.Intent, Silhouette: "dominant-island", Counts: b.Counts, IncludeRecovered: true, Forest: "compact", Seeds: b.Seeds, CameraRoles: []string{"temple", "circle", "lagoon", "bridge", "waterfall", "platform"}}, MaxObjects: 6500}
	if !slices.Contains(base.Trees, "ZTtc") {
		base.Trees = append(base.Trees, "ZTtc")
	}
	base.Recompose.LayoutAttempts = 128
	if e := reseedLandscape(&base, base.Seed); e != nil {
		return e
	}
	if e := base.Validate(); e != nil {
		return e
	}
	return JSON(out, base)
}
func reseedLandscape(s *Spec, seed int) error {
	s.Seed = seed
	lo := *s.Landscape
	s.Landscape = &lo
	sc := *s.Scene
	s.Scene = &sc
	lo.Streams = map[string]int{}
	for _, key := range []string{"layout", "relief", "water", "variants", "materials", "vegetation", "ornaments"} {
		lo.Streams[key] = int(sceneSeed(seed, "landscape-v1", key) % 2147483647)
	}
	s.Landscape.Streams = lo.Streams
	s.Scene.ForestSeed = lo.Streams["vegetation"]
	var l SceneLibrary
	if e := strictJSON(s.Scene.Library, &l); e != nil {
		return e
	}
	if e := resolveInstances(s, l); e != nil {
		return e
	}
	resolveLandscapeVariants(s)
	if s.Landscape.Landforms != nil {
		options := *s.Landscape.Landforms
		options.Streams = landscapeLandformStreams(seed)
		s.Landscape.Landforms = &options
		// Contextual painting is a separate random dependency from MarkovJunior.
		if s.Landscape.Materials != nil {
			materials := *s.Landscape.Materials
			materials.Seed = int(sceneSeed(seed, "landscape-landforms-v1", "contextual-materials") % 2147483647)
			s.Landscape.Materials = &materials
		}
	}
	return nil
}
func resolveLandscapeVariants(s *Spec) {
	for n := range s.Scene.Instances {
		s.Scene.Instances[n].Rotation = 0
		s.Scene.Instances[n].Variant = int(sceneSeed(s.Landscape.Streams["variants"], "module", s.Scene.Instances[n].ID) % 2)
	}
	// Both F falls use distinct authored outlet connection recipes, independent of packing.
	for n, i := range s.Scene.Instances {
		if i.Family == "waterfall" && s.Landscape.Brief.ID == "F" {
			if i.ID == "waterfall-1" {
				s.Scene.Instances[n].Variant = 0
			} else {
				s.Scene.Instances[n].Variant = 1
			}
		}
	}
}

func ConfigureLandscape(s Spec, stream string, seed int, vegetation, out string) error {
	if s.Mode != "whole-map-landscape" {
		return fmt.Errorf("landscape-config requires v4")
	}
	if stream != "" {
		if _, ok := s.Landscape.Streams[stream]; !ok || seed < 0 {
			return fmt.Errorf("invalid named stream/seed")
		}
		s.Landscape.Streams[stream] = seed
		if stream == "vegetation" {
			s.Scene.ForestSeed = seed
		}
		if stream == "variants" {
			resolveLandscapeVariants(&s)
		}
	}
	if vegetation != "" {
		s.Landscape.Vegetation = vegetation
	}
	if e := s.Validate(); e != nil {
		return e
	}
	return JSON(out, s)
}
func (s Spec) validateLandscape() error {
	if s.Format != "wc3-scene-spec-v4" || s.Landscape == nil || s.Scene == nil {
		return fmt.Errorf("invalid landscape v4 header")
	}
	old := s
	old.Format = "wc3-scene-spec-v3"
	old.Mode = "whole-map-scene"
	old.Landscape = nil
	if e := old.validateScenes(); e != nil {
		return e
	}
	if s.Scene.MaxObjects != 6500 || s.Tries > 8 || s.Steps > 50000 || s.Recompose.LayoutAttempts > 128 {
		return fmt.Errorf("landscape budget outside fixed acceptance profile")
	}
	p := s.Landscape
	b := p.Brief
	if e := validateLandscapeLandforms(s); e != nil {
		return e
	}
	if b.Format != "wc3-landscape-brief-v1" || !slices.Contains([]string{"D", "E", "F"}, b.ID) || len(b.Seeds) != 4 {
		return fmt.Errorf("unsupported landscape brief/profile")
	}
	if !slices.Contains([]string{"habitat", "s-control", "bare"}, p.Vegetation) {
		return fmt.Errorf("invalid vegetation strategy")
	}
	for _, key := range []string{"layout", "relief", "water", "variants", "materials", "vegetation", "ornaments"} {
		if n, ok := p.Streams[key]; !ok || n < 0 || n > 2147483647 {
			return fmt.Errorf("missing/invalid random stream %s", key)
		}
	}
	if len(p.Streams) != 7 || s.Scene.ForestSeed != p.Streams["vegetation"] {
		return fmt.Errorf("random stream dependency mismatch")
	}
	resolved := s
	resolvedScene := *s.Scene
	resolvedScene.Instances = append([]SceneInstance{}, s.Scene.Instances...)
	resolved.Scene = &resolvedScene
	resolveLandscapeVariants(&resolved)
	for n, i := range s.Scene.Instances {
		if i.Variant != resolved.Scene.Instances[n].Variant || i.Rotation != 0 {
			return fmt.Errorf("unresolved variant stream or unsupported structural rotation")
		}
	}
	raw, e := os.ReadFile(p.Library)
	if e != nil {
		return e
	}
	if Hash(raw) != p.LibrarySHA {
		return fmt.Errorf("landscape library fingerprint mismatch")
	}
	var lib LandscapeLibrary
	if e := strictJSON(p.Library, &lib); e != nil {
		return e
	}
	if lib.Format != "wc3-composition-library-v3" || lib.Base != s.Scene.Library || lib.BaseSHA != s.Scene.LibrarySHA || lib.SourceSHA != s.SourceHash {
		return fmt.Errorf("invalid landscape library dependency")
	}
	ids := map[string]SceneInstance{}
	counts := map[string]int{}
	for _, i := range s.Scene.Instances {
		if _, ok := ids[i.ID]; ok {
			return fmt.Errorf("duplicate instance")
		}
		ids[i.ID] = i
		counts[i.Family]++
	}
	expected := map[string]int{"temple": 1, "circle": 1, "platform": 1, "lagoon": 1, "bridge": 1, "waterfall": 1}
	if b.ID == "E" {
		expected["platform"] = 2
	}
	if b.ID == "F" {
		expected["temple"] = 0
		expected["platform"] = 0
		expected["bridge"] = 0
		expected["waterfall"] = 2
	}
	for family, n := range expected {
		if b.Counts[family] != n || counts[family] != n {
			return fmt.Errorf("mandatory count changed: %s", family)
		}
	}
	owners := map[string]string{}
	groups := map[string]bool{}
	isolated := 0
	for _, g := range b.Groups {
		if g.ID == "" || groups[g.ID] || ids[g.Parent].ID == "" {
			return fmt.Errorf("invalid territory parent/identity")
		}
		groups[g.ID] = true
		if g.Isolated {
			isolated++
			if g.Reason == "" {
				return fmt.Errorf("isolated group requires artistic reason")
			}
		}
		for _, id := range g.Members {
			if ids[id].ID == "" || owners[id] != "" {
				return fmt.Errorf("invalid/duplicate territory member %s", id)
			}
			owners[id] = g.ID
		}
	}
	if isolated > 3 || len(owners) != len(ids) {
		return fmt.Errorf("territorial coverage/island budget")
	}
	var base SceneLibrary
	if e := strictJSON(s.Scene.Library, &base); e != nil {
		return e
	}
	ports := func(id, name string) bool {
		i, ok := ids[id]
		if !ok {
			return false
		}
		if name == "center" || name == "inflow" {
			return true
		}
		_, ok = sceneComponent(base, i.Family).Anchors[name]
		return ok
	}
	edges := map[string]bool{}
	feeding := map[string]string{}
	access := 0
	crossing := 0
	accessPairs := map[string]bool{}
	for _, r := range b.Relations {
		if r.ID == "" || edges[r.ID] || r.From == r.To || !ports(r.From, r.FromPort) || !ports(r.To, r.ToPort) {
			return fmt.Errorf("missing relationship instance/port or duplicate identity: %s", r.ID)
		}
		edges[r.ID] = true
		if !slices.Contains([]string{"same-landmass", "near", "access", "crossing", "feeds", "shore-attached"}, r.Kind) {
			return fmt.Errorf("unknown relation")
		}
		if r.Width < 64 || r.Width > 1024 {
			return fmt.Errorf("invalid relation width")
		}
		if (r.Kind == "access" || r.Kind == "crossing") && r.Width != 64 {
			return fmt.Errorf("this classic profile certifies 64-unit access and bridge clearance")
		}
		if r.Kind == "feeds" {
			if ids[r.From].Family != "waterfall" || ids[r.To].Family != "lagoon" || r.FromPort != "outlet" || r.ToPort != "inflow" {
				return fmt.Errorf("inverted/impossible hydraulic ports")
			}
			feeding[r.From] = r.To
		}
		if r.Kind == "access" {
			access++
			accessPairs[r.From+"/"+r.FromPort+">"+r.To+"/"+r.ToPort] = true
		}
		if r.Kind == "crossing" {
			crossing++
			if ids[r.From].Family != "bridge" || r.To != "waterfall-1" || r.FromPort != "center" || r.ToPort != "outlet" {
				return fmt.Errorf("crossing lacks bridge")
			}
		}
	}
	if len(feeding) != counts["waterfall"] || access < 1 || crossing != counts["bridge"] {
		return fmt.Errorf("missing mandatory water/access/crossing relations")
	}
	requiredAccess := []string{"circle-1/access>monolith-1/center"}
	if b.ID != "F" {
		requiredAccess = []string{"circle-1/access>bridge-1/shore_a", "bridge-1/shore_b>temple-1/access"}
	}
	if b.ID == "E" {
		requiredAccess = append(requiredAccess, "temple-1/access>platform-1/access", "temple-1/access>platform-2/access")
	}
	for _, edge := range requiredAccess {
		if !accessPairs[edge] {
			return fmt.Errorf("missing mandatory access %s", edge)
		}
	}
	for _, m := range lib.Modules {
		component := sceneComponent(base, m.Family)
		seen := map[uint32]bool{}
		if m.Policy == "parent-relative" && (!slices.Contains(component.Required, m.Parent) || slices.Contains(m.Members, m.Parent)) {
			return fmt.Errorf("invalid structural parent")
		}
		if m.Policy == "parent-relative" {
			for _, other := range lib.Modules {
				if other.Family == m.Family && slices.Contains(other.Members, m.Parent) {
					return fmt.Errorf("parent-relative profile requires a fixed rigid parent")
				}
			}
		}
		for _, id := range m.Members {
			if seen[id] || !slices.Contains(component.Required, id) {
				return fmt.Errorf("unknown/duplicate structural module member")
			}
			seen[id] = true
		}
		if len(m.Members) == 0 || !slices.Contains([]string{"ground-offset", "water-offset", "parent-relative", "absolute-rigid"}, m.Policy) {
			return fmt.Errorf("invalid module/height policy")
		}
		for _, v := range m.Shifts {
			if len(v) != len(m.Members) {
				return fmt.Errorf("module shift count")
			}
			for _, d := range v {
				if !finite(d[0]) || !finite(d[1]) || d[0]/64 != float64(int(d[0]/64)) || d[1]/64 != float64(int(d[1]/64)) {
					return fmt.Errorf("module phase invalid")
				}
			}
		}
	}
	return nil
}
