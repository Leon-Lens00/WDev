package terrainproc

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"path/filepath"
	"slices"
	"testing"
)

// These failures must be diagnosed geometrically, without the deterministic
// byte comparison. Reports and the companion provenance are left untouched.
func TestLandscapeIndependentInspector(t *testing.T) {
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
	m, e := Load(good)
	if e != nil {
		t.Fatal(e)
	}
	for _, name := range []string{"dam", "core", "material", "tree-ground", "tree-habitat", "tree-duplicate"} {
		t.Run(name, func(t *testing.T) {
			changes := map[string][]byte{}
			terrain := *m.Terrain
			terrain.Tiles = slices.Clone(terrain.Tiles)
			switch name {
			case "core":
				for i, k := range b.Plan.Masks {
					if k == "rigid" {
						terrain.Tiles[i].GroundHeight += 64
						break
					}
				}
			case "dam":
				for _, xy := range b.Plan.Reaches[0].Points {
					idx := b.G.index(xy[0], xy[1])
					if b.Plan.Masks[idx] == "water-adaptable" {
						for i := range terrain.Tiles {
							x, y := b.G.xy(i%193, i/193)
							if dist(xy, [2]float64{x, y}) < 600 {
								setGround(&terrain.Tiles[i], 300)
							}
						}
						break
					}
				}
			case "material":
				for i, k := range b.Plan.Masks {
					if k != "rigid" && i%193 < 192 && b.Plan.Masks[i+1] != "rigid" {
						terrain.Tiles[i].GroundTexture = 8
						terrain.Tiles[i+1].GroundTexture = 3
						break
					}
				}
			default:
				ds := *m.Doodads
				ds.Doodads = slices.Clone(ds.Doodads)
				first := -1
				for i, p := range b.Provenance {
					if p.Role == "forest" {
						if first < 0 {
							first = i
							if name == "tree-ground" {
								ds.Doodads[i].Position[2] += 64
								break
							}
							if name == "tree-habitat" {
								for j, h := range b.Plan.Habitat {
									if h == "access" {
										x, y := b.G.xy(j%193, j/193)
										ds.Doodads[i].Position = [3]float32{float32(x), float32(y), float32(b.G.height(x, y, m.Terrain.Tiles))}
										break
									}
								}
								break
							}
						} else {
							ds.Doodads[i].Position = ds.Doodads[first].Position
							break
						}
					}
				}
				changes["war3map.doo"], e = doodadsdoo.Encode(&ds)
			}
			if len(changes) == 0 {
				changes["war3map.w3e"], e = w3e.Encode(&terrain)
			}
			if e != nil {
				t.Fatal(e)
			}
			path := filepath.Join(dir, name+".w3x")
			if e = m.Write(path, changes); e != nil {
				t.Fatal(e)
			}
			if inspectLandscapeOutput(s, path, b, filepath.Join(dir, name+".json")) == nil {
				t.Fatal("independent geometry accepted", name)
			}
		})
	}
}
