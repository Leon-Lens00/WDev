package terrainproc

import (
	"fmt"
	"math"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"time"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

func buildRecomposeBase(s Spec) (*Scene, Library, Layout, []doodadsdoo.Doodad, error) {
	g, e := recomposeScene(s)
	if e != nil {
		return nil, Library{}, Layout{}, nil, e
	}
	l, e := extractLibrary(g)
	if e != nil {
		return nil, l, Layout{}, nil, e
	}
	donors := g.Map.Doodads.Doodads
	var rejected []string
	for attempt := 0; attempt < s.Recompose.LayoutAttempts; attempt++ {
		plan, e := makeLayout(s, l, attempt)
		if e != nil {
			rejected = append(rejected, e.Error())
			continue
		}
		parts, e := composeTerrain(g, l, &plan)
		if e != nil {
			rejected = append(rejected, e.Error())
			continue
		}
		g.Map.Doodads.Doodads = parts
		cells := staticRecomposePathing(g)
		e = createLocalRoutes(g, &plan, cells)
		g.Map.Doodads.Doodads = donors
		if e != nil {
			rejected = append(rejected, e.Error())
			continue
		}
		plan.Rejections = rejected
		return g, l, plan, parts, nil
	}
	return nil, l, Layout{Rejections: rejected}, nil, fmt.Errorf("layout search exhausted: %v", rejected)
}

func GenerateRecompose(s Spec, out string) (Report, error) {
	started := time.Now()
	report := Report{Format: "wc3-generation-report-v2", Seed: s.Seed, Changed: map[string]string{}, ShadowMethod: "omitted by user; complete SHD cleared", Status: "Compiled", TimingsMS: map[string]int64{}}
	g, l, plan, parts, e := buildRecomposeBase(s)
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
	recomposeDecoration(g, plan, engine.States, parts)
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
	report.Map = filepath.Join(out, fmt.Sprintf("Tropical-Recomposed-%d.w3x", s.Seed))
	if e := g.Map.Write(report.Map, changes); e != nil {
		return report, e
	}
	if e := ValidateRecompose(s, report.Map, filepath.Join(out, "validation.json")); e != nil {
		return report, e
	}
	report.DurationMS = time.Since(started).Milliseconds()
	report.Status = "Validated"
	for name, v := range map[string]any{"spec.json": s, "library.json": l, "layout.json": plan, "report.json": report, "catalog.json": g.Catalog, "views.json": recomposeViews(plan)} {
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

func checkLocalRoutes(g *Scene, plan Layout, cells []byte) error {
	b := combinedRecompose(g, cells)
	for _, r := range plan.Routes {
		var core Rect
		for _, q := range plan.Placements {
			if q.ID == r.ID {
				core = q.Core
			}
		}
		for i := 1; i < len(r.Points); i++ {
			_, e := gridPath(g, b, pathCell(g, r.Points[i-1]), pathCell(g, r.Points[i]), expandRect(core, 256))
			if e != nil {
				return fmt.Errorf("export route %s: %w", r.ID, e)
			}
		}
	}
	if i := pathCell(g, plan.Start); i < 0 || b[i] {
		return fmt.Errorf("start is blocked")
	}
	return nil
}

func recomposeViews(plan Layout) []map[string]any {
	box := map[string]any{"min": []float64{-12288, -4096, -260}, "max": []float64{12288, 8192, 1600}}
	v := []map[string]any{{"name": "top", "bounds": box, "view": "top", "projection": "orthographic"}, {"name": "perspective", "bounds": box, "projection": "perspective", "yaw": .5, "pitch": 1.0}, {"name": "opposite", "bounds": box, "projection": "perspective", "yaw": 3.7, "pitch": 1.0}}
	for _, p := range plan.Placements {
		r := expandRect(p.Core, 256)
		b := map[string]any{"min": []float64{r.Min[0], r.Min[1], -200}, "max": []float64{r.Max[0], r.Max[1], 1100}}
		v = append(v, map[string]any{"name": p.ID, "bounds": b, "projection": "perspective", "yaw": .6, "pitch": 1.0})
		if p.ID == "waterfall" || p.ID == "bridge" || p.Family == "waterfall" || p.Family == "bridge" {
			v = append(v, map[string]any{"name": p.ID + "-side", "bounds": b, "projection": "orthographic", "yaw": 1.5708, "pitch": .35})
		}
	}
	return v
}

func layoutSVG(p Layout) string {
	var b strings.Builder
	b.WriteString(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="-12288 -8192 24576 12288"><rect x="-12288" y="-8192" width="24576" height="12288" fill="#164e63"/>`)
	for _, q := range p.Placements {
		fmt.Fprintf(&b, `<ellipse cx="%g" cy="%g" rx="%g" ry="%g" fill="#3f7854"/><rect x="%g" y="%g" width="%g" height="%g" fill="#bead74" stroke="#fff" stroke-width="25"/><text x="%g" y="%g" fill="white" font-size="260" text-anchor="middle">%s</text>`, q.Center[0], -q.Center[1], q.Radius[0], q.Radius[1], q.Core.Min[0], -q.Core.Max[1], q.Core.Max[0]-q.Core.Min[0], q.Core.Max[1]-q.Core.Min[1], q.Center[0], -q.Center[1], q.ID)
	}
	b.WriteString(`</svg>`)
	return b.String()
}

func BatchRecompose(s Spec, out string) error {
	if len(s.Recompose.Seeds) != 10 {
		return fmt.Errorf("recompose acceptance batch requires ten explicit seeds")
	}
	var reports []Report
	rejected := map[int]string{}
	for _, seed := range s.Recompose.Seeds {
		candidate := s
		candidate.Seed = seed
		r, e := GenerateRecompose(candidate, filepath.Join(out, fmt.Sprint(seed)))
		if e != nil {
			if strings.HasPrefix(e.Error(), "layout search exhausted:") {
				rejected[seed] = e.Error()
				fmt.Printf("seed=%d rejected=layout-budget\n", seed)
				continue
			}
			_ = JSON(filepath.Join(out, "batch.json"), map[string]any{"reports": reports, "failed_seed": seed, "error": e.Error()})
			return e
		}
		reports = append(reports, r)
		fmt.Printf("seed=%d map=%s objects=%d\n", seed, r.Map, r.Added)
	}
	if e := JSON(filepath.Join(out, "batch.json"), map[string]any{"reports": reports, "seeds": slices.Clone(s.Recompose.Seeds), "rejected": rejected, "visual_acceptance": "pending review; batch is structural validation only"}); e != nil {
		return e
	}
	if len(reports) < 3 {
		return fmt.Errorf("only %d candidates passed; need at least three", len(reports))
	}
	return nil
}
