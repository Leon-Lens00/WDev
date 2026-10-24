package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/unitsdoo"
	"math"
	"path/filepath"
	"slices"
)

// Contexts extracted from foreign maps conservatively preserve structures,
// unknown doodads and every unit support. Reviewed natural families may repaint.
type TerrainContext struct {
	Format     string           `json:"format"`
	MapSHA     string           `json:"map_sha256"`
	Geometry   MaterialGeometry `json:"geometry"`
	ProfileSHA string           `json:"profile_sha256"`
	Masks      []string         `json:"masks"`
	Reasons    map[int]string   `json:"reasons"`
}
type ContextRequest struct {
	Format           string          `json:"format"`
	Map              string          `json:"map"`
	MapSHA           string          `json:"map_sha256"`
	Materials        MaterialOptions `json:"materials"`
	Natural          []string        `json:"reviewed_natural_families"`
	ProtectionRadius float64         `json:"protection_radius"`
}

func ExtractBiomeContext(request, out string) error {
	var q ContextRequest
	if e := strictJSON(request, &q); e != nil {
		return e
	}
	if q.Format != "wc3-context-request-v1" || q.ProtectionRadius < 256 || q.ProtectionRadius > 2048 {
		return fmt.Errorf("invalid context extraction request")
	}
	root := filepath.Dir(request)
	for _, v := range []*string{&q.Map, &q.Materials.Profile} {
		if !filepath.IsAbs(*v) {
			*v = filepath.Join(root, *v)
		}
	}
	m, e := Load(q.Map)
	if e != nil {
		return e
	}
	if m.Hash != q.MapSHA {
		return fmt.Errorf("context source differs")
	}
	p, e := loadMaterialProfile(q.Materials)
	if e != nil {
		return e
	}
	if e = materialTarget(&p, m); e != nil {
		return e
	}
	known := map[string]bool{}
	donor, err := Load(p.Source)
	if err != nil {
		return err
	}
	for _, d := range donor.Doodads.Doodads {
		known[d.TypeID] = true
	}
	for _, id := range q.Natural {
		if !known[id] || slices.Contains(p.Rules.Structures, id) {
			return fmt.Errorf("unreviewed natural family %s", id)
		}
	}
	c := TerrainContext{Format: "wc3-terrain-context-v1", MapSHA: m.Hash, Geometry: MaterialGeometry{int(m.Terrain.Width), int(m.Terrain.Height), m.Terrain.CenterOffset}, ProfileSHA: q.Materials.ProfileSHA, Masks: make([]string, len(m.Terrain.Tiles)), Reasons: map[int]string{}}
	g := Scene{Map: m}
	protect := func(x, y float64, reason string) {
		for i := range c.Masks {
			xx, yy := g.xy(i%int(m.Terrain.Width), i/int(m.Terrain.Width))
			if math.Hypot(x-xx, y-yy) <= q.ProtectionRadius {
				c.Masks[i] = "rigid"
				c.Reasons[i] = reason
			}
		}
	}
	for i, t := range m.Terrain.Tiles {
		c.Masks[i] = "natural"
		if t.Boundary || landscapeWet(t, p.WaterOffset) || profilePreserves(p, int(t.GroundTexture)) {
			c.Masks[i] = "rigid"
			c.Reasons[i] = "boundary, water or preserve-only material"
		}
	}
	for _, d := range m.Doodads.Doodads {
		if !slices.Contains(q.Natural, d.TypeID) || slices.Contains(p.Rules.Structures, d.TypeID) {
			protect(float64(d.Position[0]), float64(d.Position[1]), "object support: "+d.TypeID)
		}
	}
	u, e := unitsdoo.Parse(m.Files["war3mapunits.doo"])
	if e != nil {
		return fmt.Errorf("cannot protect unit supports: %w", e)
	}
	for _, d := range u.Entities {
		protect(float64(d.Position[0]), float64(d.Position[1]), "unit support: "+d.TypeID)
	}
	return JSON(out, c)
}
