package terrainproc

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"math"
	"path/filepath"
	"slices"
	"testing"
)

func TestLandscapeHeightPolicies(t *testing.T) {
	for name, want := range map[string]float64{"absolute-rigid": 75, "ground-offset": 175, "water-offset": 275, "parent-relative": 375} {
		got, e := landscapeHeight(name, 75, 40, 140, 50, 250, 100, 400)
		if e != nil || got != want {
			t.Fatal(name, got, e)
		}
	}
	if _, e := landscapeHeight("water-offset", 1, 0, 0, math.Inf(-1), 0, 0, 0); e == nil {
		t.Fatal("absent water reference accepted")
	}
}

func TestLandscapeRealArchiveCorruption(t *testing.T) {
	s := landscapeTestSpec(t)
	dir := t.TempDir()
	b, e := materializeLandscape(s, dir)
	if e != nil {
		t.Fatal(e)
	}
	good := filepath.Join(dir, "good.w3x")
	if e = b.G.Map.Write(good, b.Changes); e != nil {
		t.Fatal(e)
	}
	if e = JSON(filepath.Join(dir, "placements-provenance.json"), b.Provenance); e != nil {
		t.Fatal(e)
	}
	if e = validateLandscapeAgainst(s, good, filepath.Join(dir, "validation.json"), b); e != nil {
		t.Fatal(e)
	}
	m, e := Load(good)
	if e != nil {
		t.Fatal(e)
	}
	changes := map[string]map[string][]byte{}
	for name, member := range map[string]string{"static-path": "war3map.wpm", "shadow": "war3map.shd", "camera": "war3map.w3c", "start": "war3mapunits.doo", "script": "war3map.j", "import-table": "war3map.imp"} {
		v := slices.Clone(m.Files[member])
		v[len(v)-1] ^= 1
		changes[name] = map[string][]byte{member: v}
	}
	for name, mutate := range map[string]func(*doodadsdoo.File){
		"lost-module":  func(d *doodadsdoo.File) { d.Doodads = d.Doodads[1:] },
		"duplicate":    func(d *doodadsdoo.File) { d.Doodads = append(d.Doodads, d.Doodads[0]) },
		"wrong-height": func(d *doodadsdoo.File) { d.Doodads[0].Position[2] += 128 },
		"broken-phase": func(d *doodadsdoo.File) { d.Doodads[0].Position[0] += 17 },
		"reversed-water-effect": func(d *doodadsdoo.File) {
			for i := range d.Doodads {
				if d.Doodads[i].TypeID == "LWw0" {
					d.Doodads[i].Rotation += 1
					break
				}
			}
		},
		"floating-free-tree": func(d *doodadsdoo.File) {
			for i, p := range b.Provenance {
				if p.Role == "forest" {
					d.Doodads[i].Position[2] += 32
					break
				}
			}
		},
	} {
		d := *m.Doodads
		d.Doodads = slices.Clone(d.Doodads)
		mutate(&d)
		raw, _ := doodadsdoo.Encode(&d)
		changes[name] = map[string][]byte{"war3map.doo": raw}
	}
	for name, mutate := range map[string]func(*w3e.File){
		"rigid-core": func(d *w3e.File) {
			for i, k := range b.Plan.Masks {
				if k == "rigid" {
					d.Tiles[i].GroundHeight++
					break
				}
			}
		},
		"channel-dam": func(d *w3e.File) {
			r := b.Plan.Reaches[0]
			xy := r.Points[len(r.Points)/2]
			for i := range d.Tiles {
				x, y := b.G.xy(i%193, i/193)
				if math.Abs(x-xy[0]) < 512 && math.Abs(y-xy[1]) < 512 {
					setGround(&d.Tiles[i], 300)
				}
			}
		},
		"palette-order": func(d *w3e.File) {
			d.GroundTilesets = slices.Clone(d.GroundTilesets)
			d.GroundTilesets[0], d.GroundTilesets[3] = d.GroundTilesets[3], d.GroundTilesets[0]
		},
	} {
		d := *m.Terrain
		d.Tiles = slices.Clone(d.Tiles)
		mutate(&d)
		raw, _ := w3e.Encode(&d)
		changes[name] = map[string][]byte{"war3map.w3e": raw}
	}
	for n, v := range m.Files {
		if len(v) > 4 && string(v[:4]) == "MDLX" {
			raw := slices.Clone(v)
			raw[len(raw)-1] ^= 1
			changes["imported-model"] = map[string][]byte{n: raw}
			break
		}
	}
	for name, change := range changes {
		t.Run(name, func(t *testing.T) {
			bad := filepath.Join(dir, name+".w3x")
			if e := m.Write(bad, change); e != nil {
				t.Fatal(e)
			}
			if validateLandscapeAgainst(s, bad, filepath.Join(dir, name+".json"), b) == nil {
				t.Fatal("real corrupt archive accepted")
			}
		})
	}
	badProv := slices.Clone(b.Provenance)
	badProv[0].SourceID++
	_ = JSON(filepath.Join(dir, "placements-provenance.json"), badProv)
	if validateLandscapeAgainst(s, good, filepath.Join(dir, "bad-prov.json"), b) == nil {
		t.Fatal("false provenance accepted")
	}
}
