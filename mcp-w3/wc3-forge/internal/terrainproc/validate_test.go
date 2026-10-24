package terrainproc

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"os"
	"path/filepath"
	"testing"
)

func TestExportRejectsProtectedTerrainAndBlockedStoredRoute(t *testing.T) {
	p := os.Getenv("WC3_TERRAIN_SPEC")
	if p == "" {
		t.Skip("requires local template and host")
	}
	s, e := ReadSpec(p)
	if e != nil {
		t.Fatal(e)
	}
	dir := t.TempDir()
	r, e := Generate(s, filepath.Join(dir, "generated"))
	if e != nil {
		t.Fatal(e)
	}
	if e = ValidateExport(s, r.Map, filepath.Join(dir, "valid.json")); e != nil {
		t.Fatal(e)
	}
	m, e := Load(r.Map)
	if e != nil {
		t.Fatal(e)
	}
	m.Terrain.Tiles[0].GroundHeight++
	terrain, e := w3e.Encode(m.Terrain)
	if e != nil {
		t.Fatal(e)
	}
	broken := filepath.Join(dir, "protected.w3x")
	if e = m.Write(broken, map[string][]byte{"war3map.w3e": terrain}); e != nil {
		t.Fatal(e)
	}
	if e = ValidateExport(s, broken, filepath.Join(dir, "bad.json")); e == nil {
		t.Fatal("protected terrain mutation accepted")
	}
	cells := append([]byte{}, m.Pathing.Cells...)
	x := int((s.Path[0][0] - float64(m.Terrain.CenterOffset[0])) / 32)
	y := int((s.Path[0][1] - float64(m.Terrain.CenterOffset[1])) / 32)
	cells[x+y*m.Pathing.Width] |= 2
	broken = filepath.Join(dir, "blocked.w3x")
	if e = m.Write(broken, map[string][]byte{"war3map.wpm": encodePathing(m.Pathing.Width, m.Pathing.Height, cells)}); e != nil {
		t.Fatal(e)
	}
	if e = ValidateExport(s, broken, filepath.Join(dir, "bad.json")); e == nil {
		t.Fatal("blocked stored route accepted")
	}
}
