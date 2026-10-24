package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"math"
	"path/filepath"
	"time"
)

type landscapeBuild struct {
	G          *Scene
	Library    SceneLibrary
	Source     Library
	Plan       LandscapePlan
	Parts      []doodadsdoo.Doodad
	Provenance []Provenance
	Metrics    map[string]ForestMetrics
	Engine     EngineResult
	Changes    map[string][]byte
}

func materializeLandscape(s Spec, out string) (landscapeBuild, error) {
	b := landscapeBuild{}
	g, l, lib, p, parts, prov, e := buildLandscapeBase(s)
	if e != nil {
		_ = JSON(filepath.Join(out, "rejected-layout.json"), p)
		return b, e
	}
	b.G = g
	b.Library = l
	b.Source = lib
	b.Parts = parts
	landscapeHabitats(g, &p)
	sample, sw, sh := recomposeSample(g, lib)
	fixed, allowed := make([]int, 192*96), make([]int, 192*96)
	for i := range fixed {
		idx := i%192 + i/192*193
		fixed[i] = -1
		if landscapeWet(g.Map.Terrain.Tiles[idx], g.Water) {
			fixed[i] = 4
		} else {
			allowed[i] = 15
			switch p.Habitat[idx] {
			case "forest-interior":
				allowed[i] = 11
			case "forest-edge":
				allowed[i] = 3
			case "slope":
				allowed[i] = 5
			case "access", "coast", "riparian":
				allowed[i] = 1
			}
		}
	}
	engine, e := RunEngine(s, EngineRequest{Width: 192, Height: 96, Seed: s.Landscape.Streams["materials"], SampleWidth: sw, SampleHeight: sh, Sample: sample, Fixed: fixed, Allowed: allowed, Steps: s.Steps, Tries: s.Tries}, filepath.Join(out, "engine"))
	if e != nil {
		return b, e
	}
	b.Engine = engine
	for i, t := range g.Map.Terrain.Tiles {
		if p.Masks[i] == "rigid" || t.Boundary {
			continue
		}
		x, y := g.xy(i%193, i/193)
		z := float64(t.FinalZ())
		tex := uint8(2)
		label := engine.States[min(i%193, 191)+min(i/193, 95)*192]
		if label == 1 || label == 3 {
			tex = 8
		}
		if label == 2 {
			tex = 5
		}
		switch p.Habitat[i] {
		case "water", "coast", "riparian", "access":
			tex = 3
		case "forest-interior":
			if label == 0 {
				tex = 2
			} else {
				tex = 8
			}
		case "slope":
			tex = 5
		case "forest-edge":
			if tex == 5 {
				tex = 2
			}
		}
		if z < landscapeSurface(g, x, y)+65 {
			tex = 3
		}
		t.GroundTexture = tex
		t.TextureDetails = uint8((i*17 + s.Landscape.Streams["materials"]) % 16)
		g.Map.Terrain.Tiles[i] = t
	}
	landscapeMaterialBands(g, p)
	decorated, prov, metrics, e := landscapeDecorate(g, l, p, parts, prov)
	if e != nil {
		return b, e
	}
	g.Added = decorated
	g.Map.Doodads.Doodads = decorated
	cells := staticLandscapePathing(g)
	if e := checkLandscapeRoutes(g, p, cells); e != nil {
		return b, e
	}
	if s.Landscape.Materials != nil {
		materialOptions := *s.Landscape.Materials
		if s.Landscape.Landforms != nil {
			materialOptions.SourceOverride = s.Source
		}
		materialResult, err := PaintMaterials(g.Map, p.Masks, materialOptions)
		if err != nil {
			return b, err
		}
		if err = JSON(filepath.Join(out, "materials.json"), materialResult); err != nil {
			return b, err
		}
	}
	changes, e := recomposeShell(g, p.Layout)
	if e != nil {
		return b, e
	}
	changes["war3map.w3e"], e = w3e.Encode(g.Map.Terrain)
	if e != nil {
		return b, e
	}
	changes["war3map.doo"], e = doodadsdoo.Encode(g.Map.Doodads)
	if e != nil {
		return b, e
	}
	changes["war3map.wpm"] = encodePathing(g.Map.Pathing.Width, g.Map.Pathing.Height, cells)
	changes["war3map.shd"] = make([]byte, len(cells))
	b.Plan = p
	b.Provenance = prov
	b.Metrics = metrics
	b.Changes = changes
	return b, nil
}
func GenerateLandscape(s Spec, out string) (Report, error) {
	start := time.Now()
	r := Report{Format: "wc3-generation-report-v4", Seed: s.Seed, Changed: map[string]string{}, ShadowMethod: "omitted; zero SHD", Status: "Compiled"}
	b, e := materializeLandscape(s, out)
	if e != nil {
		return r, e
	}
	g := b.G
	r.Map = filepath.Join(out, fmt.Sprintf("Tropical-%s-%d.w3x", s.Landscape.Brief.ID, s.Seed))
	r.SourceSHA = g.Map.Hash
	r.Added = len(g.Added)
	r.CompositionPieces = len(b.Parts)
	r.Removed = len(b.Source.Ownership)
	r.Engine = b.Engine
	for n, v := range b.Changes {
		r.Changed[n] = Hash(v)
	}
	r.Preserved = len(g.Map.Files) - len(b.Changes)
	for i, t := range g.Map.Terrain.Tiles {
		if t != g.Original[i] {
			r.TerrainChanges++
		}
	}
	if e := g.Map.Write(r.Map, b.Changes); e != nil {
		return r, e
	}
	if e := landscapeEvidence(b, r.Map, out); e != nil {
		return r, e
	}
	if b.Plan.Landforms != nil {
		if e := JSON(filepath.Join(out, "landforms.json"), b.Plan.Landforms); e != nil {
			return r, e
		}
	}
	for name, data := range map[string]any{"spec.json": s, "layout.json": b.Plan, "placements-provenance.json": b.Provenance, "forest-metrics.json": b.Metrics, "catalog.json": g.Catalog, "views.json": recomposeViews(b.Plan.Layout), "report.json": r} {
		if e := JSON(filepath.Join(out, name), data); e != nil {
			return r, e
		}
	}
	if e := inspectLandscapeOutput(s, r.Map, b, filepath.Join(out, "validation.json")); e != nil {
		return r, e
	}
	r.DurationMS = time.Since(start).Milliseconds()
	r.RouteReachable = true
	r.Protected = true
	r.Status = "Compiled; geometric checks passed; visual/editor pending"
	if e := JSON(filepath.Join(out, "report.json"), r); e != nil {
		return r, e
	}
	return r, nil
}
func landscapeWaterAt(g *Scene, x, y float64) bool {
	return g.height(x, y, g.Map.Terrain.Tiles) < landscapeSurface(g, x, y)-.25
}
func landscapeLength(points [][2]float64) float64 {
	d := 0.
	for n := 1; n < len(points); n++ {
		d += math.Hypot(points[n][0]-points[n-1][0], points[n][1]-points[n-1][1])
	}
	return d
}
