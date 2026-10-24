package terrainproc

import (
	"fmt"
	"path/filepath"
)

func BatchLandscapes(s Spec, out string) error {
	records := []any{}
	failed := 0
	for _, seed := range s.Landscape.Brief.Seeds {
		candidate := s
		if e := reseedLandscape(&candidate, seed); e != nil {
			return e
		}
		r, e := GenerateLandscape(candidate, filepath.Join(out, fmt.Sprint(seed)))
		row := map[string]any{"seed": seed, "report": r, "visual": "pending"}
		if e != nil {
			row["error"] = e.Error()
			failed++
		}
		records = append(records, row)
		if e := JSON(filepath.Join(out, "batch.json"), map[string]any{"format": "wc3-landscape-batch-v1", "brief": s.Landscape.Brief.ID, "cases": records, "failures": failed}); e != nil {
			return e
		}
	}
	if failed > 0 {
		return fmt.Errorf("%d landscape cases rejected; see batch.json", failed)
	}
	return nil
}
