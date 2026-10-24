package terrainproc

import (
	"math"
	"os"
	"path/filepath"
	"testing"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
)

func TestWholeMapRetainsCompositionsAndRejectsTampering(t *testing.T) {
	p := os.Getenv("WC3_WHOLE_SPEC")
	if p == "" {
		t.Skip("requires whole-map template and host")
	}
	s, e := ReadSpec(p)
	if e != nil {
		t.Fatal(e)
	}
	dir := t.TempDir()
	r, e := Generate(s, filepath.Join(dir, "whole"))
	if e != nil {
		t.Fatal(e)
	}
	if e = ValidateExport(s, r.Map, filepath.Join(dir, "valid.json")); e != nil {
		t.Fatal(e)
	}
	source, e := Load(s.Source)
	if e != nil {
		t.Fatal(e)
	}
	m, e := Load(r.Map)
	if e != nil {
		t.Fatal(e)
	}
	if r.CompositionPieces != 192 || len(r.Engine.States) != 192*96 {
		t.Fatal("incomplete map or cascade")
	}
	maxSource := uint32(0)
	for _, d := range source.Doodads.Doodads {
		if d.CreationNumber > maxSource {
			maxSource = d.CreationNumber
		}
	}
	for _, d := range m.Doodads.Doodads {
		if d.CreationNumber <= maxSource {
			continue
		}
		if d.Flags > 2 {
			t.Fatal("inherited editor-only placement flag")
		}
		if d.TypeID == "ZPms" || d.TypeID == "ZPvp" {
			for _, v := range d.Position[:2] {
				if math.Mod(float64(v)+32, 64) != 0 {
					t.Fatal("2x2 plant on tree placement grid")
				}
			}
		}
		if d.TypeID == "ZPms" && math.Abs(float64(d.Rotation)-math.Pi*1.5) > .00001 {
			t.Fatal("fixed plant rotation ignored")
		}
	}
	g := &Scene{Map: source, Spec: s, Original: source.Terrain.Tiles, Water: -89.6}
	if e = g.prepareWhole(); e != nil {
		t.Fatal(e)
	}
	anchor := g.Anchors[0].CreationNumber
	for i := range m.Doodads.Doodads {
		if m.Doodads.Doodads[i].CreationNumber == anchor {
			m.Doodads.Doodads[i].Position[2] += 5
		}
	}
	data, e := doodadsdoo.Encode(m.Doodads)
	if e != nil {
		t.Fatal(e)
	}
	bad := filepath.Join(dir, "bad-anchor.w3x")
	if e = m.Write(bad, map[string][]byte{"war3map.doo": data}); e != nil {
		t.Fatal(e)
	}
	if e = ValidateExport(s, bad, filepath.Join(dir, "bad.json")); e == nil {
		t.Fatal("floating retained composition accepted")
	}
	shadow := append([]byte{}, m.Files["war3map.shd"]...)
	shadow[500] = 255
	bad = filepath.Join(dir, "old-shadow.w3x")
	if e = m.Write(bad, map[string][]byte{"war3map.shd": shadow}); e != nil {
		t.Fatal(e)
	}
	if e = ValidateExport(s, bad, filepath.Join(dir, "bad.json")); e == nil {
		t.Fatal("stale shadow accepted")
	}
	s.Edit.Max[0] -= 128
	s.Sample = s.Edit
	g.Spec = s
	if e = g.prepareWhole(); e == nil {
		t.Fatal("partial map accepted as whole map")
	}
}
