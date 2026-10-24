package terrainproc

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"testing"
)

func biomeFixture(t *testing.T) string {
	t.Helper()
	p := os.Getenv("WC3_BIOME_RECIPE")
	if p == "" {
		t.Skip("WC3_BIOME_RECIPE required")
	}
	return p
}
func cloneBiomeProfile(p MaterialProfile) MaterialProfile {
	b, _ := json.Marshal(p)
	var q MaterialProfile
	_ = json.Unmarshal(b, &q)
	return q
}
func TestBiomeSourceForgery(t *testing.T) {
	_, _, _, p, _, _, e := loadBiome(biomeFixture(t))
	if e != nil {
		t.Fatal(e)
	}
	for _, kind := range []string{"sample", "variation", "water", "resource", "properties", "definition", "geometry"} {
		t.Run(kind, func(t *testing.T) {
			q := cloneBiomeProfile(p)
			switch kind {
			case "sample":
				q.Samples[0].Patch5[0]++
			case "variation":
				q.Samples[0].Variation = 31
			case "water":
				q.WaterOffset++
			case "resource":
				q.Resources["TerrainArt\\Water.slk"] = Hash([]byte("forged"))
			case "properties":
				q.Properties[q.Palette[0]]["buildable"] = "forged"
			case "definition":
				q.ObjectDefinitions["war3map.w3d"] = "forged"
			case "geometry":
				q.Geometry.Width++
			}
			if verifyMaterialV2(q) == nil {
				t.Fatal("forged source accepted")
			}
		})
	}
}
func TestBiomePaletteAndDefinitions(t *testing.T) {
	_, _, _, p, m, _, e := loadBiome(biomeFixture(t))
	if e != nil {
		t.Fatal(e)
	}
	original := slices.Clone(m.Terrain.GroundTilesets)
	slices.Reverse(m.Terrain.GroundTilesets)
	q := cloneBiomeProfile(p)
	if e = materialTarget(&q, m); e != nil {
		t.Fatal(e)
	}
	for i, s := range p.Samples {
		if q.Palette[q.Samples[i].Texture] != original[s.Texture] {
			t.Fatal("palette identity lost")
		}
	}
	m.Terrain.GroundTilesets[0] = "Zsan"
	if materialTarget(&p, m) == nil {
		t.Fatal("missing texture silently replaced")
	}
	m.Terrain.GroundTilesets = original
	m.Files["war3map.w3d"] = []byte("same rawcode different model")
	if materialTarget(&p, m) == nil {
		t.Fatal("object definition collision accepted")
	}
}
func TestBiomeHoldoutMargin(t *testing.T) {
	_, _, _, p, _, _, e := loadBiome(biomeFixture(t))
	if e != nil {
		t.Fatal(e)
	}
	owner := map[int]string{}
	w, h := p.Geometry.Width, p.Geometry.Height
	for _, s := range p.Samples {
		for dy := -2; dy <= 2; dy++ {
			for dx := -2; dx <= 2; dx++ {
				x, y := s.Index%w+dx, s.Index/w+dy
				if x < 0 || y < 0 || x >= w || y >= h {
					continue
				}
				j := x + y*w
				if prev := owner[j]; prev != "" && prev != s.Split {
					t.Fatalf("train/holdout patches overlap at %d", j)
				}
				owner[j] = s.Split
			}
		}
	}
}

func TestBiomeReviewedMembershipAndUnknownFamily(t *testing.T) {
	q, p, l, _, _, _, e := loadBiome(biomeFixture(t))
	if e != nil {
		t.Fatal(e)
	}
	for _, kind := range []string{"membership", "unknown-family"} {
		t.Run(kind, func(t *testing.T) {
			root := t.TempDir()
			v, profile := q, p
			if kind == "membership" {
				var library SceneLibrary
				raw, _ := json.Marshal(l)
				_ = json.Unmarshal(raw, &library)
				library.Components[0].Required = library.Components[0].Required[1:]
				path := filepath.Join(root, "library.json")
				if e := JSON(path, library); e != nil {
					t.Fatal(e)
				}
				raw, _ = os.ReadFile(path)
				profile.Library = BiomeReference{path, Hash(raw)}
			} else {
				profile.Natural = append(slices.Clone(profile.Natural), "XXXX")
			}
			path := filepath.Join(root, "profile.json")
			if e := JSON(path, profile); e != nil {
				t.Fatal(e)
			}
			raw, _ := os.ReadFile(path)
			v.Profile = BiomeReference{path, Hash(raw)}
			spec := filepath.Join(root, "recipe.json")
			if e := JSON(spec, v); e != nil {
				t.Fatal(e)
			}
			if _, _, _, _, _, _, e := loadBiome(spec); e == nil {
				t.Fatalf("accepted %s after rehashing", kind)
			}
		})
	}
}
func TestBiomeIndependentStreamsAndInspector(t *testing.T) {
	path := biomeFixture(t)
	q, _, _, _, _, _, e := loadBiome(path)
	if e != nil {
		t.Fatal(e)
	}
	seed := 62003
	root := t.TempDir()
	base := filepath.Join(root, "base")
	if e = GenerateBiome(path, base, seed); e != nil {
		t.Fatal(e)
	}
	var r BiomeRun
	if e = strictJSON(filepath.Join(base, "run.json"), &r); e != nil {
		t.Fatal(e)
	}
	a, e := Load(r.Map)
	if e != nil {
		t.Fatal(e)
	}
	for _, stream := range []string{"materials", "vegetation"} {
		t.Run(stream, func(t *testing.T) {
			v := q
			v.Streams = map[string]int{stream: biomeStream(q, seed, stream) + 1}
			spec := filepath.Join(root, stream+".json")
			if e = JSON(spec, v); e != nil {
				t.Fatal(e)
			}
			out := filepath.Join(root, stream)
			if e = GenerateBiome(spec, out, seed); e != nil {
				t.Fatal(e)
			}
			var rr BiomeRun
			_ = strictJSON(filepath.Join(out, "run.json"), &rr)
			b, e := Load(rr.Map)
			if e != nil {
				t.Fatal(e)
			}
			for i, x := range a.Terrain.Tiles {
				if !materialPhysicalEqual(x, b.Terrain.Tiles[i]) {
					t.Fatal("stream changed physical terrain")
				}
			}
			if stream == "materials" {
				if !reflect.DeepEqual(a.Doodads, b.Doodads) {
					t.Fatal("material stream moved objects")
				}
				if reflect.DeepEqual(a.Terrain, b.Terrain) {
					t.Fatal("vacuous material stream")
				}
			}
			if stream == "vegetation" && reflect.DeepEqual(a.Doodads, b.Doodads) {
				t.Fatal("vacuous vegetation stream")
			}
		})
	}
	// Independent validation cannot accept an output from a different geometry.
	q.Geometry.Origin[0] += 128
	badSpec := filepath.Join(root, "bad.json")
	_ = JSON(badSpec, q)
	if ValidateBiome(badSpec, r.Map, filepath.Join(root, "bad-validation.json")) == nil {
		t.Fatal("wrong output geometry accepted")
	}
}
