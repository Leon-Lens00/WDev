package terrainproc

import (
	"fmt"
	"math"
	"slices"
)

// LandformPlan is a physical recipe. XY coordinates are normalized to Geometry;
// elevations, widths and tolerances are absolute Warcraft world units. WaterLevel
// is the visible surface, whereas WaterOffset is the tileset's Water.slk offset.
type LandformPlan struct {
	Format      string             `json:"format"`
	Geometry    MaterialGeometry   `json:"geometry"`
	WaterLevel  float64            `json:"water_level"`
	WaterOffset float64            `json:"water_offset"`
	BaseHeight  float64            `json:"base_height"`
	Features    []LandformFeature  `json:"features"`
	Relations   []LandformRelation `json:"relations"`
	Budget      LandformBudget     `json:"budget"`
	Streams     map[string]int     `json:"streams,omitempty"`
	Finish      string             `json:"finish,omitempty"`
}

// Points are a simple polygon for land/lake and an open polyline otherwise.
// Height is an absolute crest/floor/route elevation, never a height increment.
// Channel Width is the full bed width; Transition/LeftBank/RightBank are the
// additional bank widths. Curve rounds polyline corners with bounded sampling.
// Priority orders features within the land/relief or water/route phases;
// immutable supports always take precedence over either phase.
type LandformFeature struct {
	ID         string            `json:"id"`
	Kind       string            `json:"kind"`
	Points     [][2]float64      `json:"points"`
	Width      float64           `json:"width,omitempty"`
	Height     float64           `json:"height,omitempty"`
	Depth      float64           `json:"depth,omitempty"`
	Transition float64           `json:"transition"`
	LeftBank   float64           `json:"left_bank,omitempty"`
	RightBank  float64           `json:"right_bank,omitempty"`
	Sections   []LandformSection `json:"sections,omitempty"`
	Priority   int               `json:"priority,omitempty"`
	Jitter     float64           `json:"jitter,omitempty"`
	Curve      bool              `json:"curve,omitempty"`
}

// Sections are complete cross sections at fractions of total axis length.
// They must include stations 0 and 1. Zero Left/RightBank inherits Transition.
type LandformSection struct {
	At        float64 `json:"at"`
	Width     float64 `json:"width"`
	Height    float64 `json:"height"`
	Depth     float64 `json:"depth"`
	LeftBank  float64 `json:"left_bank,omitempty"`
	RightBank float64 `json:"right_bank,omitempty"`
}

type LandformBudget struct {
	MaxFeatures int `json:"max_features"`
	MaxPoints   int `json:"max_points"`
	MaxSamples  int `json:"max_samples"`
}

// Relations inspect physical data, not a height-function prediction. Feature
// identifies the declared envelope/corridor. From/To are normalized physical
// ports; isolated uses From as its wet seed. Support names a support for kind
// support. Width is the required clearance. Margin permits a declared shore
// tolerance around an isolated lake, in world units, not an unlimited flood.
type LandformRelation struct {
	ID       string     `json:"id"`
	Kind     string     `json:"kind"`
	Feature  string     `json:"feature,omitempty"`
	From     [2]float64 `json:"from"`
	To       [2]float64 `json:"to"`
	Width    float64    `json:"width,omitempty"`
	MinDepth float64    `json:"min_depth,omitempty"`
	MinArea  float64    `json:"min_area,omitempty"`
	MaxArea  float64    `json:"max_area,omitempty"`
	Margin   float64    `json:"margin,omitempty"`
	Support  string     `json:"support,omitempty"`
}

type LandformVertex struct {
	Index  int     `json:"index"`
	Height float64 `json:"height"`
}
type LandformSupport struct {
	ID        string           `json:"id"`
	Vertices  []LandformVertex `json:"vertices"`
	Blend     float64          `json:"blend"`
	Tolerance float64          `json:"tolerance"`
}
type LandformSurface struct {
	Plan      LandformPlan `json:"plan"`
	Heights   []float64    `json:"heights"`
	Ownership []string     `json:"ownership"`
	Masks     []string     `json:"masks"`
}

func DefaultLandformBudget() LandformBudget { return LandformBudget{64, 8192, 2000000} }
func landformBudget(p LandformPlan) LandformBudget {
	b := p.Budget
	d := DefaultLandformBudget()
	if b.MaxFeatures == 0 {
		b.MaxFeatures = d.MaxFeatures
	}
	if b.MaxPoints == 0 {
		b.MaxPoints = d.MaxPoints
	}
	if b.MaxSamples == 0 {
		b.MaxSamples = d.MaxSamples
	}
	return b
}
func landformInside(p [2]float64) bool {
	return finite(p[0]) && finite(p[1]) && p[0] >= 0 && p[0] <= 1 && p[1] >= 0 && p[1] <= 1
}
func landformPolygon(f LandformFeature) bool { return f.Kind == "land" || f.Kind == "lake" }
func landformHeightValid(z float64) bool     { return finite(z) && z >= -2048 && z <= 4096 }

func ValidateLandformPlan(p LandformPlan) error {
	w, h := p.Geometry.Width, p.Geometry.Height
	if p.Format != "wc3-landform-plan-v1" || w < 33 || h < 33 || w > 257 || h > 257 || (w-1)%32 != 0 || (h-1)%32 != 0 || !finite(float64(p.Geometry.Origin[0])) || !finite(float64(p.Geometry.Origin[1])) {
		return fmt.Errorf("landform: invalid format/geometry")
	}
	if !landformHeightValid(p.BaseHeight) || !finite(p.WaterOffset) || math.Abs(p.WaterOffset) > 1024 || !finite(p.WaterLevel) || math.Abs(p.WaterLevel) > 1024 || p.BaseHeight >= p.WaterLevel || p.WaterLevel-p.WaterOffset < -2048 || p.WaterLevel-p.WaterOffset > 2047.75 {
		return fmt.Errorf("landform: invalid base/water encoding")
	}
	if p.Finish != "" && p.Finish != "off" {
		return fmt.Errorf("landform: finish must be off in v1")
	}
	for name, seed := range p.Streams {
		if !slices.Contains([]string{"forms", "relief", "water", "finish"}, name) || seed < 0 || seed > 2147483647 {
			return fmt.Errorf("landform: invalid stream %s", name)
		}
	}
	b := landformBudget(p)
	if b.MaxFeatures < 1 || b.MaxFeatures > 256 || b.MaxPoints < 3 || b.MaxPoints > 32768 || b.MaxSamples < 1024 || b.MaxSamples > 4000000 || len(p.Features) == 0 || len(p.Features) > b.MaxFeatures {
		return fmt.Errorf("landform: feature/sample budget")
	}
	ids := map[string]LandformFeature{}
	npoints := 0
	for _, f := range p.Features {
		if f.ID == "" || ids[f.ID].ID != "" || !slices.Contains([]string{"land", "lake", "ridge", "valley", "channel", "route"}, f.Kind) {
			return fmt.Errorf("landform: invalid/duplicate feature %q", f.ID)
		}
		ids[f.ID] = f
		minimum := 2
		if landformPolygon(f) {
			minimum = 3
		}
		if len(f.Points) < minimum {
			return fmt.Errorf("landform %s: too few points", f.ID)
		}
		npoints += len(f.Points)
		if npoints > b.MaxPoints {
			return fmt.Errorf("landform: point budget")
		}
		if !finite(f.Transition) || f.Transition < 32 || f.Transition > 4096 || !finite(f.Jitter) || f.Jitter < 0 || f.Jitter > 256 || !landformHeightValid(f.Height) || !finite(f.Depth) || f.Depth < 0 || f.Depth > 2048 || !finite(f.Width) || f.Width < 0 || f.Width > 16384 || f.Priority < -100 || f.Priority > 100 {
			return fmt.Errorf("landform %s: invalid section/range", f.ID)
		}
		if (f.Kind == "lake" || f.Kind == "channel") && f.Depth < 1 {
			return fmt.Errorf("landform %s: water requires depth", f.ID)
		}
		if f.Kind == "route" && f.Jitter != 0 {
			return fmt.Errorf("landform %s: reserved routes cannot jitter", f.ID)
		}
		if !landformPolygon(f) && f.Width < 64 {
			return fmt.Errorf("landform %s: axis below minimum width", f.ID)
		}
		for _, v := range []float64{f.LeftBank, f.RightBank} {
			if !finite(v) || v < 0 || v > 4096 {
				return fmt.Errorf("landform %s: invalid bank", f.ID)
			}
		}
		if landformPolygon(f) && (f.Curve || len(f.Sections) > 0) {
			return fmt.Errorf("landform %s: polygon curves/axis sections unsupported", f.ID)
		}
		for i, pt := range f.Points {
			if !landformInside(pt) {
				return fmt.Errorf("landform %s: point outside geometry", f.ID)
			}
			for j := 0; j < i; j++ {
				if dist(pt, f.Points[j]) < 1e-9 {
					return fmt.Errorf("landform %s: duplicate point", f.ID)
				}
			}
		}
		if landformSelfCrosses(f.Points, landformPolygon(f)) {
			return fmt.Errorf("landform %s: self intersection", f.ID)
		}
		if landformPolygon(f) && math.Abs(landformArea(f.Points)) < 1e-6 {
			return fmt.Errorf("landform %s: degenerate polygon", f.ID)
		}
		if len(f.Sections) > 0 {
			if len(f.Sections) < 2 || f.Sections[0].At != 0 || f.Sections[len(f.Sections)-1].At != 1 {
				return fmt.Errorf("landform %s: sections must span [0,1]", f.ID)
			}
			for i, s := range f.Sections {
				if !finite(s.At) || s.At < 0 || s.At > 1 || i > 0 && s.At <= f.Sections[i-1].At || !finite(s.Width) || s.Width < 64 || s.Width > 16384 || !landformHeightValid(s.Height) || !finite(s.Depth) || s.Depth < 0 || s.Depth > 2048 || !finite(s.LeftBank) || s.LeftBank < 0 || s.LeftBank > 4096 || !finite(s.RightBank) || s.RightBank < 0 || s.RightBank > 4096 {
					return fmt.Errorf("landform %s: invalid sections", f.ID)
				}
				if f.Kind == "channel" && s.Depth < 1 {
					return fmt.Errorf("landform %s: section has no depth", f.ID)
				}
			}
		}
	}
	relations := map[string]bool{}
	for _, r := range p.Relations {
		if r.ID == "" || relations[r.ID] || !slices.Contains([]string{"connect", "isolated", "access", "support"}, r.Kind) {
			return fmt.Errorf("landform: invalid/duplicate relation %s", r.ID)
		}
		relations[r.ID] = true
		if r.Kind == "support" {
			if r.Support == "" {
				return fmt.Errorf("landform %s: missing support", r.ID)
			}
			continue
		}
		f, ok := ids[r.Feature]
		if !ok || !landformInside(r.From) || !landformInside(r.To) {
			return fmt.Errorf("landform %s: missing feature/port", r.ID)
		}
		if r.Kind == "isolated" && f.Kind != "lake" || r.Kind == "connect" && (f.Kind != "channel" && f.Kind != "lake") || r.Kind == "access" && f.Kind != "route" {
			return fmt.Errorf("landform %s: incompatible relation/feature", r.ID)
		}
		for _, v := range []float64{r.Width, r.MinDepth, r.MinArea, r.MaxArea, r.Margin} {
			if !finite(v) || v < 0 {
				return fmt.Errorf("landform %s: invalid metric", r.ID)
			}
		}
		if r.Width > 2048 || r.Margin > 2048 || r.MinDepth > 2048 || r.MaxArea > 0 && r.MaxArea < r.MinArea {
			return fmt.Errorf("landform %s: invalid constraint", r.ID)
		}
	}
	return nil
}

func validateLandformSupports(p LandformPlan, supports []LandformSupport) error {
	if len(supports) > landformBudget(p).MaxFeatures {
		return fmt.Errorf("landform: support budget")
	}
	ids := map[string]bool{}
	points := map[int]float64{}
	total := 0
	for _, s := range supports {
		if s.ID == "" || ids[s.ID] || len(s.Vertices) == 0 || !finite(s.Blend) || s.Blend < 0 || s.Blend > 4096 || !finite(s.Tolerance) || s.Tolerance < 0 || s.Tolerance > 8 {
			return fmt.Errorf("landform: invalid support %s", s.ID)
		}
		ids[s.ID] = true
		total += len(s.Vertices)
		if total > p.Geometry.Width*p.Geometry.Height*4 {
			return fmt.Errorf("landform: support vertex budget")
		}
		local := map[int]bool{}
		for _, v := range s.Vertices {
			if v.Index < 0 || v.Index >= p.Geometry.Width*p.Geometry.Height || !landformHeightValid(v.Height) {
				return fmt.Errorf("landform %s: invalid support vertex", s.ID)
			}
			if local[v.Index] {
				return fmt.Errorf("landform %s: duplicate support vertex", s.ID)
			}
			local[v.Index] = true
			if z, ok := points[v.Index]; ok && math.Abs(z-v.Height) > .125 {
				return fmt.Errorf("landform: conflicting supports at vertex %d", v.Index)
			}
			points[v.Index] = v.Height
		}
	}
	for _, r := range p.Relations {
		if r.Kind == "support" && !ids[r.Support] {
			return fmt.Errorf("landform %s: unknown support %s", r.ID, r.Support)
		}
	}
	return nil
}
