package terrainproc

import (
	"os"
	"path/filepath"
	"testing"
)

func TestRealEngineSamplesOutsideOutputExtent(t *testing.T) {
	p := os.Getenv("WC3_TERRAIN_SPEC")
	if p == "" {
		t.Skip("requires built host")
	}
	s, e := ReadSpec(p)
	if e != nil {
		t.Fatal(e)
	}
	// The only nonzero input is beyond the output extent. An output-sized
	// training loop misses it entirely and cannot satisfy the fixed label.
	sample := make([]int, 8*8)
	sample[6+6*8] = 1
	fixed := make([]int, 4*4)
	for i := range fixed {
		fixed[i] = -1
	}
	fixed[0] = 1
	r, e := RunEngine(s, EngineRequest{4, 4, 12700, 8, 8, sample, fixed, 20000, 8, nil}, filepath.Join(t.TempDir(), "engine"))
	if e != nil {
		t.Fatal(e)
	}
	if r.States[0] != 1 {
		t.Fatal("bottom-right sample pattern was lost")
	}
}

func TestRealEngineAllowedDomain(t *testing.T) {
	p := os.Getenv("WC3_TERRAIN_SPEC")
	if p == "" {
		t.Skip("requires built host")
	}
	s, e := ReadSpec(p)
	if e != nil {
		t.Fatal(e)
	}
	sample := make([]int, 8*8)
	for y := 4; y < 8; y++ {
		for x := 4; x < 8; x++ {
			sample[x+y*8] = 1
		}
	}
	allowed := make([]int, 16)
	for i := range allowed {
		allowed[i] = 2
	}
	req := EngineRequest{Width: 4, Height: 4, Seed: 12700, SampleWidth: 8, SampleHeight: 8, Sample: sample, Allowed: allowed, Steps: 20000, Tries: 8}
	r, e := RunEngine(s, req, filepath.Join(t.TempDir(), "domain"))
	if e != nil {
		t.Fatal(e)
	}
	for _, v := range r.States {
		if v != 1 {
			t.Fatal("disallowed sea/open label leaked into land")
		}
	}
	req.Fixed = make([]int, 16) // Label zero contradicts the allowed land domain.
	if _, e = RunEngine(s, req, filepath.Join(t.TempDir(), "conflict")); e == nil {
		t.Fatal("conflicting domain accepted")
	}
}
