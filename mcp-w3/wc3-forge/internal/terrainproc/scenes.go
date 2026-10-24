package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"math"
	"os"
	"path/filepath"
	"time"
)

func ReseedScenes(s *Spec, seed int) error {
	if s.Mode == "whole-map-landscape" { return reseedLandscape(s,seed) }
	s.Seed = seed
	if s.Scene == nil {
		return nil
	}
	copyOptions := *s.Scene
	s.Scene = &copyOptions
	s.Scene.ForestSeed = seed
	var l SceneLibrary
	if e := strictJSON(s.Scene.Library, &l); e != nil {
		return e
	}
	return resolveInstances(s, l)
}
func BatchScenes(s Spec, out string) error {
	reports := []Report{}
	rejected := map[int]string{}
	for _, seed := range s.Scene.Brief.Seeds {
		candidate := s
		if e := ReseedScenes(&candidate, seed); e != nil {
			return e
		}
		r, e := GenerateScenes(candidate, filepath.Join(out, fmt.Sprint(seed)))
		if e != nil {
			rejected[seed] = e.Error()
			fmt.Printf("seed=%d rejected=%s\n", seed, e)
			continue
		}
		reports = append(reports, r)
		fmt.Printf("seed=%d objects=%d map=%s\n", seed, r.Added, r.Map)
	}
	if e := JSON(filepath.Join(out, "batch.json"), map[string]any{"reports": reports, "rejected": rejected, "visual_review": "pending"}); e != nil {
		return e
	}
	if len(reports) == 0 {
		return fmt.Errorf("all scene candidates failed; inspect batch.json")
	}
	return nil
}

func GenerateScenes(s Spec, out string) (Report, error) {
	started := time.Now()
	report := Report{Format: "wc3-generation-report-v3", Seed: s.Seed, Changed: map[string]string{}, ShadowMethod: "omitted by user; complete SHD cleared", Status: "Compiled", TimingsMS: map[string]int64{}}
	g, library, l, plan, parts, provenance, e := buildSceneBase(s)
	if e != nil {
		_ = JSON(filepath.Join(out, "rejected-layout.json"), plan)
		return report, e
	}
	report.TimingsMS["source_library_layout"] = time.Since(started).Milliseconds()
	sample, sw, sh := recomposeSample(g, l)
	fixed, allowed := make([]int, 192*96), make([]int, 192*96)
	for i := range fixed {
		x, y := g.xy(i%192, i/192)
		z := float64(g.Map.Terrain.Tiles[g.index(x, y)].FinalZ())
		fixed[i] = -1
		if z < g.Water+35 {
			fixed[i] = 4
		} else {
			allowed[i] = 15
		}
	}
	stage := time.Now()
	engine, e := RunEngine(s, EngineRequest{Width: 192, Height: 96, Seed: s.Seed, SampleWidth: sw, SampleHeight: sh, Sample: sample, Fixed: fixed, Allowed: allowed, Steps: s.Steps, Tries: s.Tries}, filepath.Join(out, "engine"))
	if e != nil {
		return report, e
	}
	report.Engine = engine
	report.TimingsMS["markovjunior"] = time.Since(stage).Milliseconds()
	for i, t := range g.Map.Terrain.Tiles {
		x, y := g.xy(i%193, i/193)
		if sceneReserved(plan, x, y) || t.Boundary {
			continue
		}
		z := float64(t.FinalZ())
		if z < g.Water+45 {
			t.GroundTexture = 3
		} else {
			label := engine.States[min(i%193, 191)+min(i/193, 95)*192]
			tex := uint8(2)
			if label == 1 || label == 3 {
				tex = 8
			}
			if label == 2 {
				tex = 5
			}
			slope := math.Abs(g.height(x+64, y, g.Map.Terrain.Tiles)-z) + math.Abs(g.height(x, y+64, g.Map.Terrain.Tiles)-z)
			if slope > 65 {
				tex = 5
			}
			if z < g.Water+90 {
				tex = 3
			}
			t.GroundTexture = tex
		}
		t.TextureDetails = uint8((i*17 + s.Seed) % 16)
		g.Map.Terrain.Tiles[i] = t
	}
	decorated, provenance, metrics, e := decorateScenes(g, library, plan, parts, provenance)
	if e != nil {
		return report, e
	}
	g.Added = decorated
	g.Map.Doodads.Doodads = decorated
	cells := staticRecomposePathing(g)
	if e := checkLocalRoutes(g, plan, cells); e != nil {
		return report, e
	}
	changes, e := recomposeShell(g, plan)
	if e != nil {
		return report, e
	}
	changes["war3map.w3e"], e = w3e.Encode(g.Map.Terrain)
	if e != nil {
		return report, e
	}
	changes["war3map.doo"], e = doodadsdoo.Encode(g.Map.Doodads)
	if e != nil {
		return report, e
	}
	changes["war3map.wpm"] = encodePathing(g.Map.Pathing.Width, g.Map.Pathing.Height, cells)
	changes["war3map.shd"] = make([]byte, len(cells))
	report.SourceSHA = g.Map.Hash
	report.CompositionPieces = len(parts)
	report.Added = len(g.Added)
	report.Removed = len(l.Ownership)
	report.RouteReachable = true
	report.Protected = true
	for i, t := range g.Map.Terrain.Tiles {
		if t != g.Original[i] {
			report.TerrainChanges++
		}
	}
	for n, b := range changes {
		report.Changed[n] = Hash(b)
	}
	report.Preserved = len(g.Map.Files) - len(changes)
	report.Map = filepath.Join(out, fmt.Sprintf("Tropical-Scene-%d.w3x", s.Seed))
	if e := g.Map.Write(report.Map, changes); e != nil {
		return report, e
	}
	if e := JSON(filepath.Join(out, "placements-provenance.json"), provenance); e != nil {
		return report, e
	}
	if e := ValidateScenes(s, report.Map, filepath.Join(out, "validation.json")); e != nil {
		return report, e
	}
	report.DurationMS = time.Since(started).Milliseconds()
	report.Status = "Validated"
	for name, v := range map[string]any{"spec.json": s, "library.json": library, "placements-provenance.json": provenance, "forest-metrics.json": metrics, "layout.json": plan, "report.json": report, "catalog.json": g.Catalog, "views.json": recomposeViews(plan)} {
		if e := JSON(filepath.Join(out, name), v); e != nil {
			return report, e
		}
	}
	if e := writeManifest(g, report, out, sample, sw, sh); e != nil {
		return report, e
	}
	if e := os.WriteFile(filepath.Join(out, "layout.svg"), []byte(layoutSVG(plan)), 0644); e != nil {
		return report, e
	}
	return report, nil
}
