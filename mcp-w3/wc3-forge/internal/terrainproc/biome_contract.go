package terrainproc

import (
	"encoding/json"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"reflect"
	"slices"
)

type BiomeReference struct {
	Path string `json:"path"`
	SHA  string `json:"sha256"`
}
type BiomeProfile struct {
	Format    string           `json:"format"`
	ID        string           `json:"id"`
	Target    string           `json:"target"`
	Source    BiomeReference   `json:"source"`
	Materials BiomeReference   `json:"materials"`
	Catalog   BiomeReference   `json:"catalog"`
	Library   BiomeReference   `json:"library"`
	Install   string           `json:"install"`
	Natural   []string         `json:"natural_families"`
	Forest    BiomeForestRules `json:"forest"`
}
type BiomeForestRules struct {
	Coverage       *BiomeCoveragePolicy `json:"coverage,omitempty"`
	Spacing        float64              `json:"minimum_spacing"`
	MaxSlope       float64              `json:"maximum_slope"`
	CanopyRadius   float64              `json:"canopy_radius_proxy"`
	MedianRange    [2]float64           `json:"median_range"`
	NeighborsRange [2]float64           `json:"neighbors256_range"`
}
type BiomeEllipse struct {
	Center [2]float64 `json:"center"`
	Radius [2]float64 `json:"radius"`
	Height float64    `json:"height"`
}
type BiomeRoute struct {
	ID     string       `json:"id"`
	Points [][2]float64 `json:"points"`
	Width  float64      `json:"width"`
	Height float64      `json:"height"`
}
type BiomeInstance struct {
	ID        string     `json:"id"`
	Component string     `json:"component"`
	Center    [2]float64 `json:"center"`
	Rotation  int        `json:"rotation"`
	Height    float64    `json:"height"`
}
type BiomeRecipe struct {
	Landforms       *BiomeLandforms  `json:"landforms,omitempty"`
	Format          string           `json:"format"`
	ID              string           `json:"id"`
	Realizer        string           `json:"realizer"`
	Profile         BiomeReference   `json:"profile"`
	Geometry        MaterialGeometry `json:"geometry"`
	Seeds           []int            `json:"seeds"`
	Streams         map[string]int   `json:"streams,omitempty"`
	Land            []BiomeEllipse   `json:"land"`
	Hills           []BiomeEllipse   `json:"hills"`
	Water           []BiomeEllipse   `json:"water"`
	Routes          []BiomeRoute     `json:"routes"`
	Forest          []BiomeEllipse   `json:"forest"`
	ForestClearings []BiomeEllipse   `json:"forest_clearings,omitempty"`
	Scenes          []BiomeInstance  `json:"scenes"`
	Start           [2]float64       `json:"start"`
	WaterLevel      float64          `json:"water_level"`
	CollisionRadius float64          `json:"collision_radius"`
	MaxObjects      int              `json:"max_objects"`
	MaxAttempts     int              `json:"max_attempts"`
}

func biomeRead(root string, ref *BiomeReference, v any) error {
	if !filepath.IsAbs(ref.Path) {
		ref.Path = filepath.Join(root, ref.Path)
	}
	raw, e := os.ReadFile(ref.Path)
	if e != nil {
		return e
	}
	if len(ref.SHA) != 64 || Hash(raw) != ref.SHA {
		return fmt.Errorf("biome reference hash differs: %s", ref.Path)
	}
	if v != nil {
		return strictJSON(ref.Path, v)
	}
	return nil
}
func loadBiome(recipe string) (BiomeRecipe, BiomeProfile, SceneLibrary, MaterialProfile, *Map, *Catalog, error) {
	var q BiomeRecipe
	var p BiomeProfile
	var l SceneLibrary
	var mat MaterialProfile
	var cat Catalog
	fail := func(e error) (BiomeRecipe, BiomeProfile, SceneLibrary, MaterialProfile, *Map, *Catalog, error) {
		return q, p, l, mat, nil, nil, e
	}
	if e := strictJSON(recipe, &q); e != nil {
		return fail(e)
	}
	if q.Format != "wc3-territory-recipe-v1" || (q.Realizer != "ellipses-cohorts-v1" && q.Realizer != "ellipses-cohorts-v2" && q.Realizer != "landforms-cohorts-v1") || q.ID == "" {
		return fail(fmt.Errorf("unsupported territorial recipe/realizer"))
	}
	if (q.Realizer == "landforms-cohorts-v1") != (q.Landforms != nil) {
		return fail(fmt.Errorf("landforms require their explicit realizer"))
	}
	if e := biomeRead(filepath.Dir(recipe), &q.Profile, &p); e != nil {
		return fail(e)
	}
	if p.Format != "wc3-biome-profile-v1" || p.Target != "classic-1.27b" || p.ID == "" {
		return fail(fmt.Errorf("unsupported biome profile"))
	}
	root := filepath.Dir(q.Profile.Path)
	for _, ref := range []*BiomeReference{&p.Source, &p.Materials, &p.Catalog, &p.Library} {
		if e := biomeRead(root, ref, nil); e != nil {
			return fail(e)
		}
	}
	if !filepath.IsAbs(p.Install) {
		p.Install = filepath.Join(root, p.Install)
	}
	var e error
	mat, e = loadMaterialProfile(MaterialOptions{Profile: p.Materials.Path, ProfileSHA: p.Materials.SHA, Seed: 1})
	if e != nil {
		return fail(e)
	}
	m, e := Load(p.Source.Path)
	if e != nil {
		return fail(e)
	}
	if m.Hash != mat.SourceSHA {
		return fail(fmt.Errorf("biome/material donors differ"))
	}
	if q.Landforms != nil {
		if e := loadBiomeLandforms(filepath.Dir(recipe), &q, mat, m.Hash); e != nil {
			return fail(e)
		}
	}
	if e = strictJSON(p.Library.Path, &l); e != nil {
		return fail(e)
	}
	if e = strictJSON(p.Catalog.Path, &cat); e != nil {
		return fail(e)
	}
	if l.Format != "wc3-scene-library-v2" || l.SourceSHA != m.Hash || cat.MapHash != m.Hash {
		return fail(fmt.Errorf("biome catalogue/library source differs"))
	}
	review := BiomeReference{l.Review, l.ReviewSHA}
	if e = biomeRead(filepath.Dir(p.Library.Path), &review, nil); e != nil {
		return fail(e)
	}
	reviewRaw, err := os.ReadFile(review.Path)
	if err != nil {
		return fail(err)
	}
	var approval struct {
		Members map[string][]uint32 `json:"approved_members"`
		Cohorts map[string][]uint32 `json:"approved_cohorts"`
	}
	if err = json.Unmarshal(reviewRaw, &approval); err != nil {
		return fail(err)
	}
	for _, c := range l.Components {
		if !slices.Equal(approval.Members[c.ID], c.Required) {
			return fail(fmt.Errorf("membership differs from visual approval: %s", c.ID))
		}
	}
	for _, c := range l.Cohorts {
		if !slices.Equal(approval.Cohorts[c.ID], c.SourceIDs) {
			return fail(fmt.Errorf("cohort differs from visual approval: %s", c.ID))
		}
	}
	// Re-resolve local resources. A matching rawcode alone grants no identity.
	actual, e := CatalogMap(m, p.Install)
	if e != nil {
		return fail(e)
	}
	if !reflect.DeepEqual(actual, &cat) {
		return fail(fmt.Errorf("resolved object catalog differs from approved catalog"))
	}
	ids := map[uint32]string{}
	for _, d := range m.Doodads.Doodads {
		ids[d.CreationNumber] = d.TypeID
	}
	if len(l.Coverage) != len(ids) {
		return fail(fmt.Errorf("incomplete source object accounting"))
	}
	for id := range ids {
		if l.Coverage[id] == "" {
			return fail(fmt.Errorf("unaccounted source object %d", id))
		}
	}
	seen := map[string]bool{}
	for _, c := range l.Components {
		if c.ID == "" || seen[c.ID] || len(c.Required) == 0 || len(c.Optional) != 0 || len(c.Evidence) == 0 || c.Blend < 128 || c.Blend > 1024 || len(c.Anchors) == 0 {
			return fail(fmt.Errorf("invalid reviewed component %s", c.ID))
		}
		seen[c.ID] = true
		for _, id := range c.Required {
			if ids[id] == "" || l.Coverage[id] != "composition:"+c.ID {
				return fail(fmt.Errorf("composition membership/provenance differs %s:%d", c.ID, id))
			}
		}
	}
	for _, co := range l.Cohorts {
		if len(co.SourceIDs) < 8 || len(co.Evidence) == 0 {
			return fail(fmt.Errorf("invalid forest cohort"))
		}
		for _, id := range co.SourceIDs {
			if !slices.Contains(mat.Rules.Trees, ids[id]) || l.Coverage[id] == "pending-review" {
				return fail(fmt.Errorf("unreviewed forest member"))
			}
		}
	}
	for _, id := range p.Natural {
		if cat.Assets[id] == nil || len(cat.Assets[id].Errors) > 0 {
			return fail(fmt.Errorf("unresolved natural family %s", id))
		}
	}
	if q.Geometry.Width < 33 || q.Geometry.Height < 33 || q.Geometry.Width > 257 || q.Geometry.Height > 257 || (q.Geometry.Width-1)%32 != 0 || (q.Geometry.Height-1)%32 != 0 || (len(q.Land) == 0 && q.Landforms == nil) || len(q.Routes) == 0 || len(q.Forest) == 0 || len(l.Cohorts) == 0 || q.MaxObjects < 1 || q.MaxObjects > 10000 || q.MaxAttempts < 1 || q.MaxAttempts > 20000 || q.CollisionRadius < 16 || q.CollisionRadius > 64 {
		return fail(fmt.Errorf("invalid geometry/budget"))
	}
	if p.Forest.Spacing < 64 || p.Forest.Spacing > 256 || p.Forest.MaxSlope < 1 || p.Forest.CanopyRadius < 32 {
		return fail(fmt.Errorf("invalid forest rules"))
	}
	if e := validateCoveragePolicy(q, p.Forest.Coverage); e != nil {
		return fail(e)
	}
	inside := func(x [2]float64) bool { return x[0] >= 0 && x[0] <= 1 && x[1] >= 0 && x[1] <= 1 }
	for _, arr := range [][]BiomeEllipse{q.Land, q.Hills, q.Water, q.Forest, q.ForestClearings} {
		for _, v := range arr {
			if !inside(v.Center) || v.Radius[0] <= 0 || v.Radius[1] <= 0 || v.Radius[0] > 1 || v.Radius[1] > 1 || math.Abs(v.Height) > 1000 {
				return fail(fmt.Errorf("invalid territory ellipse"))
			}
		}
	}
	for _, r := range q.Routes {
		if len(r.Points) < 2 || r.Width < 256 || r.Width > 1024 || math.Abs(r.Height) > 1000 {
			return fail(fmt.Errorf("invalid route"))
		}
		for _, pt := range r.Points {
			if !inside(pt) {
				return fail(fmt.Errorf("route outside grid"))
			}
		}
	}
	for _, s := range q.Scenes {
		if !seen[s.Component] || !inside(s.Center) || s.Rotation%90 != 0 {
			return fail(fmt.Errorf("unknown scene or transform"))
		}
	}
	if !inside(q.Start) || q.WaterLevel < -512 || q.WaterLevel > 512 {
		return fail(fmt.Errorf("invalid start/water"))
	}
	for _, seed := range q.Seeds {
		if seed < 0 || seed > 2147483647 {
			return fail(fmt.Errorf("invalid seed"))
		}
	}
	return q, p, l, mat, m, &cat, nil
}
