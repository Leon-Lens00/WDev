package terrainproc

import (
	"bytes"
	"fmt"
	"path/filepath"
	"time"
)

func Batch(s Spec, out string) error {
	if s.Mode=="whole-map-landscape"{return BatchLandscapes(s,out)}
	if s.Mode == "whole-map-scene" {
		return BatchScenes(s, out)
	}
	if s.Mode == "whole-map-recompose" {
		return BatchRecompose(s, out)
	}
	start := time.Now()
	results := []map[string]any{}
	var first Report
	for seed := 12700; seed < 12710; seed++ {
		candidate := s
		candidate.Seed = seed
		candidate.Waterfall.Offset[0] += float64((seed-12700)%3) * 128
		if (seed-12700)%3 == 1 {
			candidate.Waterfall.Offset[1] -= 128
		}
		r, e := Generate(candidate, filepath.Join(out, fmt.Sprint(seed)))
		if e != nil {
			_ = JSON(filepath.Join(out, "batch.json"), map[string]any{"results": results, "failed_seed": seed, "error": e.Error()})
			return fmt.Errorf("batch seed %d: %w", seed, e)
		}
		if seed == 12700 {
			first = r
		}
		results = append(results, map[string]any{"seed": seed, "map": r.Map, "duration_ms": r.DurationMS, "objects_added": r.Added, "status": r.Status})
		if seed < 12703 {
			repeat, e := Generate(candidate, filepath.Join(out, "determinism", fmt.Sprint(seed)))
			if e != nil {
				return e
			}
			a, e := Load(r.Map)
			if e != nil {
				return e
			}
			b, e := Load(repeat.Map)
			if e != nil {
				return e
			}
			for n, v := range a.Files {
				if !bytes.Equal(v, b.Files[n]) {
					return fmt.Errorf("nondeterministic member seed %d: %s", seed, n)
				}
			}
			if !bytes.Equal([]byte(fmt.Sprint(r.Engine.States)), []byte(fmt.Sprint(repeat.Engine.States))) {
				return fmt.Errorf("nondeterministic semantic grid")
			}
		}
	}
	bad := s
	bad.Waterfall.Offset[2] = 512
	_, e := Generate(bad, filepath.Join(out, "rejected-cascade"))
	if e == nil {
		return fmt.Errorf("incompatible water plane accepted")
	}
	rejection := e.Error()
	request := EngineRequest{Width: 4, Height: 4, Seed: 12700, SampleWidth: 2, SampleHeight: 2, Sample: []int{0, 1, 1, 0}, Fixed: []int{0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}, Steps: 1000, Tries: 2}
	_, e = RunEngine(s, request, filepath.Join(out, "rejected-wfc"))
	if e == nil {
		return fmt.Errorf("contradictory checkerboard constraints accepted")
	}
	return JSON(filepath.Join(out, "batch.json"), map[string]any{"results": results, "deterministic_seeds": []int{12700, 12701, 12702}, "incompatible_cascade": rejection, "wfc_contradiction": e.Error(), "elapsed_ms": time.Since(start).Milliseconds(), "selected": first.Map})
}
