package terrainproc

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"strings"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

type MaterialRepaint struct {
	Context      string `json:"context,omitempty"`
	ContextSHA   string `json:"context_sha256,omitempty"`
	MinimapStyle string `json:"minimap_style,omitempty"`

	Format     string          `json:"format"`
	Map        string          `json:"map"`
	MapSHA     string          `json:"map_sha256"`
	DoodadsSHA string          `json:"doodads_sha256"`
	Layout     string          `json:"layout"`
	LayoutSHA  string          `json:"layout_sha256"`
	Materials  MaterialOptions `json:"materials"`
}

func readMaterialRepaint(path string) (MaterialRepaint, *Map, LandscapePlan, error) {
	var q MaterialRepaint
	var l LandscapePlan
	if e := strictJSON(path, &q); e != nil {
		return q, nil, l, e
	}
	if (q.Format != "wc3-material-repaint-v1" && q.Format != "wc3-material-repaint-v2") || len(q.MapSHA) != 64 || (len(q.LayoutSHA) != 64 && len(q.ContextSHA) != 64) || len(q.DoodadsSHA) != 64 {
		return q, nil, l, fmt.Errorf("invalid material repaint request")
	}
	root, _ := filepath.Abs(filepath.Dir(path))
	for _, p := range []*string{&q.Map, &q.Layout, &q.Materials.Profile} {
		if !filepath.IsAbs(*p) {
			*p = filepath.Join(root, *p)
		}
	}
	m, e := Load(q.Map)
	if e != nil {
		return q, nil, l, e
	}
	if m.Hash != q.MapSHA || Hash(m.Files["war3map.doo"]) != q.DoodadsSHA {
		return q, nil, l, fmt.Errorf("base map/objects hash mismatch")
	}
	if q.Context != "" {
		if q.Format != "wc3-material-repaint-v2" {
			return q, nil, l, fmt.Errorf("context requires v2")
		}
		if !filepath.IsAbs(q.Context) {
			q.Context = filepath.Join(root, q.Context)
		}
		raw, err := os.ReadFile(q.Context)
		if err != nil {
			return q, nil, l, err
		}
		if Hash(raw) != q.ContextSHA {
			return q, nil, l, fmt.Errorf("context hash differs")
		}
		var c TerrainContext
		if err = strictJSON(q.Context, &c); err != nil {
			return q, nil, l, err
		}
		if c.Format != "wc3-terrain-context-v1" || c.MapSHA != m.Hash || c.ProfileSHA != q.Materials.ProfileSHA || c.Geometry != (MaterialGeometry{int(m.Terrain.Width), int(m.Terrain.Height), m.Terrain.CenterOffset}) || len(c.Masks) != len(m.Terrain.Tiles) {
			return q, nil, l, fmt.Errorf("context provenance/dimensions differ")
		}
		for _, mask := range c.Masks {
			if mask != "natural" && mask != "rigid" {
				return q, nil, l, fmt.Errorf("unknown context mask")
			}
		}
		l.Masks = c.Masks
		return q, m, l, nil
	}
	raw, e := os.ReadFile(q.Layout)
	if e != nil {
		return q, nil, l, e
	}
	if Hash(raw) != q.LayoutSHA {
		return q, nil, l, fmt.Errorf("layout hash mismatch")
	}
	if e = strictJSON(q.Layout, &l); e != nil {
		return q, nil, l, e
	}
	if len(l.Masks) != len(m.Terrain.Tiles) {
		return q, nil, l, fmt.Errorf("layout dimensions mismatch")
	}
	return q, m, l, nil
}
func RepaintMaterials(request, out string) error {
	q, m, l, e := readMaterialRepaint(request)
	if e != nil {
		return e
	}
	result, e := PaintMaterials(m, l.Masks, q.Materials)
	if e != nil {
		// Preserve diagnostics on rejection; a failed synthesis never emits a map.
		if diagnosticErr := JSON(filepath.Join(out, "materials-failed.json"), map[string]any{"error": e.Error(), "result": result}); diagnosticErr != nil {
			return fmt.Errorf("%w (diagnostic write failed: %v)", e, diagnosticErr)
		}
		return e
	}
	raw, e := w3e.Encode(m.Terrain)
	if e != nil {
		return e
	}
	g := Scene{Map: m, Water: -89.6}
	mini, e := materialMinimap(&g, q)
	if e != nil {
		return e
	}
	mp := filepath.Join(out, strings.TrimSuffix(filepath.Base(q.Map), filepath.Ext(q.Map))+"-materials.w3x")
	if e = m.Write(mp, map[string][]byte{"war3map.w3e": raw, "war3mapmap.blp": mini}); e != nil {
		return e
	}
	if e = JSON(filepath.Join(out, "materials.json"), result); e != nil {
		return e
	}
	if e = JSON(filepath.Join(out, "request.json"), q); e != nil {
		return e
	}
	if e = JSON(filepath.Join(out, "layout.json"), l); e != nil {
		return e
	}
	return ValidateMaterials(request, mp, filepath.Join(out, "validation.json"))
}

type MaterialValidation struct {
	Format             string                   `json:"format"`
	Passed             bool                     `json:"passed"`
	MapSHA             string                   `json:"map_sha256"`
	BaseSHA            string                   `json:"base_sha256"`
	ProfileSHA         string                   `json:"profile_sha256"`
	ChangedMembers     []string                 `json:"changed_members"`
	ChangedVertices    int                      `json:"changed_vertices"`
	Contexts           []MaterialContextMetrics `json:"contexts"`
	LargestGrassyPatch int                      `json:"largest_grassy_patch"`
	Failures           []string                 `json:"failures"`
}

// This inspector compares re-extracted archives; synthesis logs grant no pass.
func ValidateMaterials(request, output, out string) error {
	q, base, l, e := readMaterialRepaint(request)
	if e != nil {
		return e
	}
	p, e := loadMaterialProfile(q.Materials)
	if e != nil {
		return e
	}
	actual, e := Load(output)
	if e != nil {
		return e
	}
	if e = materialTarget(&p, base); e != nil {
		return e
	}
	for c := range p.Counts {
		for tex := range p.Palette {
			if profilePreserves(p, tex) {
				p.Counts[c][tex] = 0
				p.HoldoutCounts[c][tex] = 0
			}
		}
	}
	v := MaterialValidation{Format: "wc3-material-validation-v1", MapSHA: actual.Hash, BaseSHA: base.Hash, ProfileSHA: q.Materials.ProfileSHA, Failures: []string{}}
	fail := func(s string) { v.Failures = append(v.Failures, s) }
	if !bytes.Equal(base.Header, actual.Header) {
		fail("map wrapper/header changed")
	}
	for n, a := range base.Files {
		if n == "(listfile)" || n == "(attributes)" {
			continue
		}
		b, ok := actual.Files[n]
		if !ok {
			fail("missing archive member " + n)
			continue
		}
		if !bytes.Equal(a, b) {
			v.ChangedMembers = append(v.ChangedMembers, n)
			if n != "war3map.w3e" && n != "war3mapmap.blp" {
				fail("forbidden changed member " + n)
			}
		}
	}
	for n := range actual.Files {
		if _, ok := base.Files[n]; !ok && n != "(listfile)" && n != "(attributes)" {
			fail("unexpected member " + n)
		}
	}
	slices.Sort(v.ChangedMembers)
	aHeader, bHeader := *base.Terrain, *actual.Terrain
	aHeader.Tiles = nil
	bHeader.Tiles = nil
	if !reflect.DeepEqual(aHeader, bHeader) {
		fail("terrain header/palette changed")
	}
	if len(actual.Terrain.Tiles) != len(base.Terrain.Tiles) {
		fail("terrain dimensions changed")
		_ = JSON(out, v)
		return fmt.Errorf("material validation failed: %v", v.Failures)
	}
	features := profileFeatures(base, p)
	before, after := profileMatrix(p), profileMatrix(p)
	allowed := map[[2]int]bool{}
	for _, s := range p.Samples {
		allowed[[2]int{s.Texture, s.Variation}] = true
	}
	for i, a := range base.Terrain.Tiles {
		b := actual.Terrain.Tiles[i]
		if !materialPhysicalEqual(a, b) {
			fail(fmt.Sprintf("physical terrain changed at %d", i))
			break
		}
		if profileProtected(p, a, l.Masks[i]) {
			if a != b {
				fail(fmt.Sprintf("protected vertex changed at %d", i))
			}
			continue
		}
		if !allowed[[2]int{int(b.GroundTexture), int(b.TextureDetails & 31)}] {
			fail(fmt.Sprintf("unobserved material variation at %d", i))
		}
		c := features[i].Context
		if profilePreserves(p, int(b.GroundTexture)) {
			fail(fmt.Sprintf("new architectural floor at %d", i))
		}
		if int(b.GroundTexture) >= len(p.Palette) {
			fail("invalid texture index")
			continue
		}
		before[c][a.GroundTexture]++
		after[c][b.GroundTexture]++
		if a != b {
			v.ChangedVertices++
		}
	}
	for c := 1; c < 8; c++ {
		metric := MaterialContextMetrics{materialContexts[c], sumMaterial(p.Counts[c]), sumMaterial(after[c]), p.Counts[c], before[c], after[c], materialTV(p.Counts[c], before[c]), materialTV(p.Counts[c], after[c]), materialTV(p.HoldoutCounts[c], after[c])}
		v.Contexts = append(v.Contexts, metric)
		if metric.SourceCount >= 64 && metric.OutputCount >= 64 && (metric.AfterTV > p.TVLimit || (metric.BeforeTV > p.TVLimit && metric.AfterTV > metric.BeforeTV*.5)) {
			fail("context mix outside calibrated criteria: " + metric.Name)
		}
	}
	grassy := 2
	if p.Rules != nil {
		grassy = slices.Index(p.Palette, p.Rules.Grassy)
	}
	if grassy >= 0 {
		v.LargestGrassyPatch = largestMaterialPatch(actual, uint8(grassy), p.WaterOffset)
	}
	if v.LargestGrassyPatch > p.MaxGrassyPatch {
		fail("oversized dry grassy-dirt patch")
	}
	if q.Format == "wc3-material-repaint-v1" && !bytes.Equal(actual.Files["war3map.shd"], make([]byte, len(actual.Pathing.Cells))) {
		fail("nonzero shadows")
	}
	v.Passed = len(v.Failures) == 0
	if e = JSON(out, v); e != nil {
		return e
	}
	if !v.Passed {
		return fmt.Errorf("material validation failed: %v", v.Failures)
	}
	return nil
}

// Bare maps are diagnostic only. Their complete terrain is byte-identical.
func MaterialDiagnostic(source, out string) error {
	m, e := Load(source)
	if e != nil {
		return e
	}
	m.Doodads.Doodads = []doodadsdoo.Doodad{}
	raw, e := doodadsdoo.Encode(m.Doodads)
	if e != nil {
		return e
	}
	return m.Write(out, map[string][]byte{"war3map.doo": raw})
}
