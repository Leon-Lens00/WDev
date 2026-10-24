package terrainproc

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"os"
	"path/filepath"
	"reflect"
	"testing"
)

func materialTestRequest(t *testing.T) string {
	t.Helper()
	p := os.Getenv("WC3_MATERIAL_REQUEST")
	if p == "" {
		t.Skip("WC3_MATERIAL_REQUEST required")
	}
	return p
}
func TestMaterialBitContract(t *testing.T) {
	a := w3e.Tilepoint{GroundHeight: 8500, WaterLevel: 9000, Flags: 4, TextureDetails: 224 | 17, LayerHeight: 2}
	b := a
	b.GroundTexture = 6
	b.TextureDetails = 224 | 16
	if !materialPhysicalEqual(a, b) {
		t.Fatal("authorized appearance change rejected")
	}
	for name, mutate := range map[string]func(*w3e.Tilepoint){"height": func(t *w3e.Tilepoint) { t.GroundHeight++ }, "water": func(t *w3e.Tilepoint) { t.WaterLevel++ }, "cliff-variation": func(t *w3e.Tilepoint) { t.TextureDetails ^= 32 }, "flag": func(t *w3e.Tilepoint) { t.Flags ^= 1 }, "layer": func(t *w3e.Tilepoint) { t.LayerHeight++ }} {
		t.Run(name, func(t *testing.T) {
			c := b
			mutate(&c)
			if materialPhysicalEqual(a, c) {
				t.Fatal("physical corruption accepted")
			}
		})
	}
}
func TestMaterialDeterminismAndProtectedVertices(t *testing.T) {
	req := materialTestRequest(t)
	q, a, l, e := readMaterialRepaint(req)
	if e != nil {
		t.Fatal(e)
	}
	before := append([]w3e.Tilepoint{}, a.Terrain.Tiles...)
	doo := append([]doodadsdoo.Doodad{}, a.Doodads.Doodads...)
	first, e := PaintMaterials(a, l.Masks, q.Materials)
	if e != nil {
		t.Fatal(e)
	}
	_, b, _, e := readMaterialRepaint(req)
	if e != nil {
		t.Fatal(e)
	}
	second, e := PaintMaterials(b, l.Masks, q.Materials)
	if e != nil {
		t.Fatal(e)
	}
	if !reflect.DeepEqual(a.Terrain, b.Terrain) || !reflect.DeepEqual(first, second) {
		t.Fatal("non deterministic")
	}
	if !reflect.DeepEqual(doo, a.Doodads.Doodads) {
		t.Fatal("objects changed")
	}
	n := 0
	for i, old := range before {
		if !materialPhysicalEqual(old, a.Terrain.Tiles[i]) {
			t.Fatal("physics changed")
		}
		if materialProtected(old, l.Masks[i], -89.6) {
			n++
			if old != a.Terrain.Tiles[i] {
				t.Fatal("protected surface changed")
			}
		}
	}
	if n == 0 || len(first.Changes) < 100 {
		t.Fatal("vacuous fixture")
	}
	if _, e = PaintMaterials(b, l.Masks[:5], q.Materials); e == nil {
		t.Fatal("contradictory mask accepted")
	}
}
func TestMaterialSourceProvenance(t *testing.T) {
	q, _, _, e := readMaterialRepaint(materialTestRequest(t))
	if e != nil {
		t.Fatal(e)
	}
	p, e := loadMaterialProfile(q.Materials)
	if e != nil {
		t.Fatal(e)
	}
	p.Samples[0].Patch5[0] = (p.Samples[0].Patch5[0] + 1) % 9
	path := filepath.Join(t.TempDir(), "profile.json")
	if e = JSON(path, p); e != nil {
		t.Fatal(e)
	}
	raw, _ := os.ReadFile(path)
	q.Materials.Profile = path
	q.Materials.ProfileSHA = Hash(raw)
	if _, e = loadMaterialProfile(q.Materials); e == nil {
		t.Fatal("forged neighborhood accepted even with self-consistent profile hash")
	}
}
func TestMaterialInspectorRejectsCorruption(t *testing.T) {
	req := materialTestRequest(t)
	q, _, l, e := readMaterialRepaint(req)
	if e != nil {
		t.Fatal(e)
	}
	out := t.TempDir()
	if e = RepaintMaterials(req, out); e != nil {
		t.Fatal(e)
	}
	good := filepath.Join(out, filepath.Base(q.Map[:len(q.Map)-4])+"-materials.w3x")
	for _, kind := range []string{"height", "object", "palette", "variation", "pathing", "rigid", "brick"} {
		t.Run(kind, func(t *testing.T) {
			m, e := Load(good)
			if e != nil {
				t.Fatal(e)
			}
			changes := map[string][]byte{}
			i := 0
			for materialProtected(m.Terrain.Tiles[i], l.Masks[i], -89.6) {
				i++
			}
			switch kind {
			case "height":
				m.Terrain.Tiles[i].GroundHeight++
			case "object":
				m.Doodads.Doodads[0].Position[0] += 128
				changes["war3map.doo"], e = doodadsdoo.Encode(m.Doodads)
			case "palette":
				m.Terrain.GroundTilesets[0] = "Ldrt"
			case "variation":
				m.Terrain.Tiles[i].TextureDetails = (m.Terrain.Tiles[i].TextureDetails & 224) | 31
			case "pathing":
				m.Pathing.Cells[0] ^= 2
				changes["war3map.wpm"] = encodePathing(m.Pathing.Width, m.Pathing.Height, m.Pathing.Cells)
			case "rigid":
				for j, mask := range l.Masks {
					if mask == "rigid" {
						m.Terrain.Tiles[j].GroundTexture = (m.Terrain.Tiles[j].GroundTexture + 1) % 9
						break
					}
				}
			case "brick":
				m.Terrain.Tiles[i].GroundTexture = 4
			}
			if e != nil {
				t.Fatal(e)
			}
			changes["war3map.w3e"], e = w3e.Encode(m.Terrain)
			if e != nil {
				t.Fatal(e)
			}
			bad := filepath.Join(t.TempDir(), "corrupt.w3x")
			if e = m.Write(bad, changes); e != nil {
				t.Fatal(e)
			}
			if e = ValidateMaterials(req, bad, filepath.Join(t.TempDir(), "audit.json")); e == nil {
				t.Fatal("corruption accepted")
			}
		})
	}
}
