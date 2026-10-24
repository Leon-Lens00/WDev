package terrainproc

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

type EngineRequest struct {
	Width        int
	Height       int
	Seed         int
	SampleWidth  int
	SampleHeight int
	Sample       []int
	Fixed        []int
	Steps        int
	Tries        int
	Allowed      []int `json:",omitempty"`
}
type EngineResult struct {
	Format      string `json:"format"`
	Revision    string `json:"revision"`
	Seed        int    `json:"seed"`
	Width       int    `json:"width"`
	Height      int    `json:"height"`
	Steps       int    `json:"steps"`
	States      []int  `json:"states"`
	Diagnostics string `json:"diagnostics"`
}

func RunEngine(s Spec, r EngineRequest, out string) (EngineResult, error) {
	var result EngineResult
	out, _ = filepath.Abs(out)
	if e := os.MkdirAll(out, 0755); e != nil {
		return result, e
	}
	req := filepath.Join(out, "request.json")
	res := filepath.Join(out, "result.json")
	if e := JSON(req, r); e != nil {
		return result, e
	}
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()
	cmd := exec.CommandContext(ctx, s.Dotnet, s.Host, req, res)
	cmd.Dir = out
	b, e := cmd.CombinedOutput()
	_ = os.WriteFile(filepath.Join(out, "process.log"), b, 0644)
	if e != nil {
		return result, fmt.Errorf("MarkovJunior: %w: %s", e, b)
	}
	b, e = os.ReadFile(res)
	if e != nil {
		return result, e
	}
	if e = json.Unmarshal(b, &result); e != nil {
		return result, e
	}
	if result.Format != "wc3-mj-result-v1" || result.Revision != "42aaf24bcf54ae164fba49c0a59348297904a676+sample-bounds-v1" || result.Seed != r.Seed || len(result.States) != r.Width*r.Height || result.Width != r.Width || result.Height != r.Height {
		return result, fmt.Errorf("invalid engine output")
	}
	labels := map[int]bool{}
	for _, v := range r.Sample {
		labels[v] = true
	}
	for i, v := range result.States {
		if !labels[v] || len(r.Fixed) > i && r.Fixed[i] >= 0 && r.Fixed[i] != v {
			return result, fmt.Errorf("invalid engine label at %d", i)
		}
		if len(r.Allowed) > i && r.Allowed[i] != 0 && (v < 0 || v > 15 || r.Allowed[i]&(1<<v) == 0) {
			return result, fmt.Errorf("engine label outside allowed domain at %d", i)
		}
	}
	return result, nil
}
