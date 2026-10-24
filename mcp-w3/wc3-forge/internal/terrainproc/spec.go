package terrainproc

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"os"
	"path/filepath"
	"strings"
)

type Rect struct {
	Min [2]float64 `json:"min"`
	Max [2]float64 `json:"max"`
}

func (r Rect) Contains(x, y float64) bool {
	return x >= r.Min[0] && x <= r.Max[0] && y >= r.Min[1] && y <= r.Max[1]
}

type Composition struct {
	Source Rect       `json:"source"`
	Offset [3]float64 `json:"offset"`
	Blend  float64    `json:"blend"`
}
type Spec struct {
	Landscape       *LandscapeOptions `json:"landscape,omitempty"`
	Scene           *SceneOptions     `json:"scene,omitempty"`
	Recompose       *RecomposeSpec    `json:"recompose,omitempty"`
	Format          string            `json:"format"`
	Mode            string            `json:"mode,omitempty"`
	Shadows         string            `json:"shadows,omitempty"`
	Source          string            `json:"source"`
	SourceHash      string            `json:"source_sha256"`
	Install         string            `json:"install"`
	Dotnet          string            `json:"dotnet"`
	Host            string            `json:"host"`
	Seed            int               `json:"seed"`
	Sample          Rect              `json:"sample"`
	Edit            Rect              `json:"edit"`
	Protected       []Rect            `json:"protected"`
	Path            [][2]float64      `json:"path"`
	PathWidth       float64           `json:"path_width"`
	CollisionRadius float64           `json:"collision_radius"`
	Trees           []string          `json:"trees"`
	Plants          []string          `json:"plants"`
	Rocks           []string          `json:"rocks"`
	Waterfall       Composition       `json:"waterfall"`
	Tries           int               `json:"wfc_tries"`
	Steps           int               `json:"wfc_steps,omitempty"`
}

func ReadSpec(path string) (Spec, error) {
	var s Spec
	b, e := os.ReadFile(path)
	if e != nil {
		return s, e
	}
	dec := json.NewDecoder(strings.NewReader(string(b)))
	dec.DisallowUnknownFields()
	if e = dec.Decode(&s); e != nil {
		return s, e
	}
	var trailing any
	if e = dec.Decode(&trailing); e != io.EOF {
		return s, fmt.Errorf("scene must contain exactly one JSON object")
	}
	root, _ := filepath.Abs(filepath.Dir(path))
	for _, p := range []*string{&s.Source, &s.Install, &s.Dotnet, &s.Host} {
		if !filepath.IsAbs(*p) {
			*p = filepath.Clean(filepath.Join(root, *p))
		}
	}
	if s.Scene != nil && !filepath.IsAbs(s.Scene.Library) {
		s.Scene.Library = filepath.Clean(filepath.Join(root, s.Scene.Library))
	}
	if s.Landscape != nil {
		if !filepath.IsAbs(s.Landscape.Library) {
			s.Landscape.Library = filepath.Clean(filepath.Join(root, s.Landscape.Library))
		}
		if s.Landscape.Materials != nil && !filepath.IsAbs(s.Landscape.Materials.Profile) {
			s.Landscape.Materials.Profile = filepath.Clean(filepath.Join(root, s.Landscape.Materials.Profile))
		}
		if s.Landscape.Materials != nil && s.Landscape.Materials.SourceOverride != "" && !filepath.IsAbs(s.Landscape.Materials.SourceOverride) {
			s.Landscape.Materials.SourceOverride = filepath.Clean(filepath.Join(root, s.Landscape.Materials.SourceOverride))
		}
		if s.Landscape.Landforms != nil && !filepath.IsAbs(s.Landscape.Landforms.Profile) {
			s.Landscape.Landforms.Profile = filepath.Clean(filepath.Join(root, s.Landscape.Landforms.Profile))
		}
	}
	return s, s.Validate()
}
func (s Spec) Validate() error {
	if s.Mode == "whole-map-landscape" {
		return s.validateLandscape()
	}
	if s.Mode == "whole-map-scene" {
		return s.validateScenes()
	}
	if s.Mode == "whole-map-recompose" {
		return s.validateRecompose()
	}
	if s.Mode != "" && s.Mode != "whole-map-restyle" {
		return fmt.Errorf("unsupported terrain mode %q", s.Mode)
	}
	if s.Shadows != "" && s.Shadows != "omit" {
		return fmt.Errorf("unsupported shadow policy %q", s.Shadows)
	}
	if s.Mode == "whole-map-restyle" && (s.Sample != s.Edit || len(s.Protected) != 0 || s.Waterfall.Offset != [3]float64{}) {
		return fmt.Errorf("whole-map restyle requires identical full sample/edit, no protected rectangles and an in-place waterfall")
	}
	if s.Format != "wc3-scene-spec-v1" || s.Source == "" || s.Host == "" || s.Install == "" || len(s.SourceHash) != 64 {
		return fmt.Errorf("invalid scene spec/header")
	}
	if _, e := hex.DecodeString(s.SourceHash); e != nil {
		return fmt.Errorf("source hash is not hexadecimal")
	}
	if s.Seed < 0 || int64(s.Seed) > 2147483647 || s.Dotnet == "" {
		return fmt.Errorf("invalid seed/runtime")
	}
	for _, r := range append([]Rect{s.Edit, s.Sample, s.Waterfall.Source}, s.Protected...) {
		for i := 0; i < 2; i++ {
			if !finite(r.Min[i]) || !finite(r.Max[i]) || r.Max[i] <= r.Min[i] || math.Mod(r.Min[i], 128) != 0 || math.Mod(r.Max[i], 128) != 0 {
				return fmt.Errorf("rectangles must use ordered, finite 128-unit coordinates")
			}
		}
	}
	if s.PathWidth < 128 || s.PathWidth > 1024 || s.CollisionRadius < 1 || s.CollisionRadius > s.PathWidth/3 || len(s.Path) < 2 || s.Tries < 1 || s.Tries > 64 {
		return fmt.Errorf("invalid path or WFC budget")
	}
	for _, p := range s.Path {
		if !finite(p[0]) || !finite(p[1]) || !s.Edit.Contains(p[0], p[1]) {
			return fmt.Errorf("route point outside editable rectangle")
		}
	}
	if len(s.Trees) == 0 || len(s.Plants) == 0 {
		return fmt.Errorf("tree and plant catalogs required")
	}
	if s.Steps < 0 || s.Steps > 100000 {
		return fmt.Errorf("invalid WFC step budget")
	}
	for _, ids := range [][]string{s.Trees, s.Plants, s.Rocks} {
		for _, id := range ids {
			if len(id) != 4 {
				return fmt.Errorf("rawcodes must have four bytes")
			}
		}
	}
	if (s.Edit.Max[0]-s.Edit.Min[0])/128 > 256 || (s.Edit.Max[1]-s.Edit.Min[1])/128 > 256 {
		return fmt.Errorf("edit exceeds 256-cell engine limit")
	}
	for _, v := range s.Waterfall.Offset {
		if !finite(v) {
			return fmt.Errorf("invalid composition offset")
		}
	}
	if math.Mod(s.Waterfall.Offset[0], 128) != 0 || math.Mod(s.Waterfall.Offset[1], 128) != 0 || s.Waterfall.Blend < 128 || s.Waterfall.Blend > 1024 {
		return fmt.Errorf("composition must align to terrain; invalid blend")
	}
	return nil
}
func finite(n float64) bool { return !math.IsNaN(n) && !math.IsInf(n, 0) }
func (s Spec) Editable(x, y float64) bool {
	if !s.Edit.Contains(x, y) {
		return false
	}
	for _, r := range s.Protected {
		if r.Contains(x, y) {
			return false
		}
	}
	return true
}
func (s Spec) PathDistance(x, y float64) float64 {
	best := math.Inf(1)
	for i := 1; i < len(s.Path); i++ {
		a, b := s.Path[i-1], s.Path[i]
		dx, dy := b[0]-a[0], b[1]-a[1]
		l := dx*dx + dy*dy
		t := 0.
		if l > 0 {
			t = max(0., min(1., ((x-a[0])*dx+(y-a[1])*dy)/l))
		}
		best = min(best, math.Hypot(x-a[0]-t*dx, y-a[1]-t*dy))
	}
	return best
}
