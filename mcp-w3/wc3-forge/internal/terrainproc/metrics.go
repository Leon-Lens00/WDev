package terrainproc

import (
	"fmt"
	"os"
	"path/filepath"
)

func patternMetrics(states []int, w, h int) map[string]any {
	counts := map[int]int{}
	pairs := map[string]int{}
	blocks := map[string]int{}
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			v := states[x+y*w]
			counts[v]++
			if x+1 < w {
				pairs[fmt.Sprintf("x:%d:%d", v, states[x+1+y*w])]++
			}
			if y+1 < h {
				pairs[fmt.Sprintf("y:%d:%d", v, states[x+(y+1)*w])]++
			}
			if x+1 < w && y+1 < h {
				blocks[fmt.Sprintf("%d,%d/%d,%d", v, states[x+1+y*w], states[x+(y+1)*w], states[x+1+(y+1)*w])]++
			}
		}
	}
	return map[string]any{"labels": counts, "adjacencies": pairs, "patterns_2x2": blocks}
}
func writeManifest(g *Scene, r Report, out string, sample []int, sw, sh int) error {
	m, e := Load(r.Map)
	if e != nil {
		return e
	}
	files := map[string]string{}
	for n, b := range m.Files {
		files[n] = Hash(b)
	}
	imports := map[string]string{}
	for _, a := range g.Catalog.Assets {
		for _, model := range a.Models {
			if model.Source == "map" {
				imports[model.Path] = model.SHA256
			}
			for _, t := range model.Textures {
				if t.Source == "map" {
					imports[t.Path] = t.SHA256
				}
			}
		}
	}
	shadow := "pending World Editor"
	if g.Spec.Shadows == "omit" {
		shadow = "excluded by user; edited SHD cleared"
	}
	if e = JSON(filepath.Join(out, "manifest.json"), map[string]any{"format": "wc3-run-manifest-v1", "seed": r.Seed, "mode": g.Spec.Mode, "sample_dimensions": []int{sw, sh}, "retained_objects": len(m.Doodads.Doodads) - r.Added, "target": "Warcraft III Classic 1.27b", "source_sha256": r.SourceSHA, "map_sha256": m.Hash, "members": files, "imports": imports, "markovjunior_revision": r.Engine.Revision, "shadow_bake": shadow, "sample": patternMetrics(sample, sw, sh), "output": patternMetrics(r.Engine.States, r.Engine.Width, r.Engine.Height)}); e != nil {
		return e
	}
	if _, e = os.Stat(filepath.Join(out, "visual-review.md")); os.IsNotExist(e) {
		return os.WriteFile(filepath.Join(out, "visual-review.md"), []byte("# Visual review\n\nPending capture and human/agent inspection. Structural validation is not visual acceptance.\n"), 0644)
	}
	return nil
}
