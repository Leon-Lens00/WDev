package terrainproc

import (
	"bytes"
	"encoding/hex"
	"fmt"
	"math"
	"path/filepath"
	"slices"
	"strings"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/unitsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3c"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3i"
	"github.com/StephenSHorton/wc3-forge/internal/mpqchain"
)

type PrefabSpec struct {
	Adjustments map[uint32][2]float64 `json:"adjustments,omitempty"`
	ID          string                `json:"id"`
	Source      Rect                  `json:"source"`
	Blend       float64               `json:"blend"`
	Anchors     map[string][2]float64 `json:"anchors"`
	Rotations   []int                 `json:"rotations"`
}
type RecomposeSpec struct {
	Compositions    []PrefabSpec `json:"compositions"`
	Seeds           []int        `json:"seeds"`
	LayoutAttempts  int          `json:"layout_attempts"`
	MinDisplacement float64      `json:"min_displacement"`
	MaxSourceIoU    float64      `json:"max_source_iou"`
}
type Prefab struct {
	PrefabSpec
	Pivot         [2]float64          `json:"pivot"`
	Pieces        []doodadsdoo.Doodad `json:"pieces"`
	Support       []w3e.Tilepoint     `json:"support"`
	SupportWidth  int                 `json:"support_width"`
	SupportHeight int                 `json:"support_height"`
	HeightPolicy  string              `json:"height_policy"`
}
type Library struct {
	Format    string            `json:"format"`
	SourceSHA string            `json:"source_sha256"`
	Prefabs   []Prefab          `json:"compositions"`
	Ownership map[uint32]string `json:"source_ownership"`
	Retired   []uint32          `json:"retired_noncomposite_objects"`
}

func (s Spec) validateRecompose() error {
	if s.Format != "wc3-scene-spec-v2" || s.Recompose == nil || s.Source == "" || s.Install == "" || s.Host == "" || s.Dotnet == "" || s.Shadows != "omit" {
		return fmt.Errorf("invalid recompose v2 header")
	}
	if b, e := hex.DecodeString(s.SourceHash); e != nil || len(b) != 32 {
		return fmt.Errorf("invalid source fingerprint")
	}
	if s.Seed < 0 || int64(s.Seed) > 2147483647 || s.Tries < 1 || s.Tries > 64 || s.Steps < 1 || s.Steps > 100000 {
		return fmt.Errorf("invalid seed/WFC budget")
	}
	if s.Sample != s.Edit || len(s.Protected) > 0 || len(s.Recompose.Compositions) != 6 || s.PathWidth < 128 || s.CollisionRadius < 1 || s.CollisionRadius > s.PathWidth/3 {
		return fmt.Errorf("invalid full recompose contract")
	}
	if len(s.Trees) == 0 || len(s.Plants) == 0 {
		return fmt.Errorf("missing vegetation catalog")
	}
	r := s.Recompose
	seedSet := map[int]bool{}
	for _, seed := range r.Seeds {
		if seed < 0 || int64(seed) > 2147483647 || seedSet[seed] {
			return fmt.Errorf("invalid or duplicate batch seed")
		}
		seedSet[seed] = true
	}
	if r.LayoutAttempts < 1 || r.LayoutAttempts > 256 || r.MinDisplacement < 1536 || r.MaxSourceIoU <= 0 || r.MaxSourceIoU > .7 {
		return fmt.Errorf("invalid layout acceptance limits")
	}
	ids := map[string]bool{}
	for _, p := range r.Compositions {
		if ids[p.ID] || p.ID == "" {
			return fmt.Errorf("duplicate/empty composition id")
		}
		ids[p.ID] = true
		if !s.Edit.Contains(p.Source.Min[0], p.Source.Min[1]) || !s.Edit.Contains(p.Source.Max[0], p.Source.Max[1]) {
			return fmt.Errorf("composition outside donor bounds")
		}
		required := []string{"center", "access"}
		switch p.ID {
		case "temple":
			required = append(required, "interior")
		case "bridge":
			required = []string{"center", "shore_a", "deck_a", "deck_b", "shore_b"}
		case "lagoon":
			required = []string{"center", "shore"}
		case "waterfall":
			required = []string{"inlet", "outlet"}
		}
		for _, name := range required {
			if _, ok := p.Anchors[name]; !ok {
				return fmt.Errorf("missing %s anchor %s", p.ID, name)
			}
		}
		if p.Blend < 256 || p.Blend > 1024 || len(p.Rotations) == 0 {
			return fmt.Errorf("invalid composition blend/rotations")
		}
		for _, n := range p.Rotations {
			if n != 0 {
				return fmt.Errorf("this library profile currently proves translation only; rotation %d is not eligible", n)
			}
		}
		for k := 0; k < 2; k++ {
			if !finite(p.Source.Min[k]) || !finite(p.Source.Max[k]) || p.Source.Max[k] <= p.Source.Min[k] || math.Mod(p.Source.Min[k], 128) != 0 || math.Mod(p.Source.Max[k], 128) != 0 {
				return fmt.Errorf("composition source must align to terrain")
			}
		}
		for _, a := range p.Anchors {
			if !finite(a[0]) || !finite(a[1]) || !p.Source.Contains(a[0], a[1]) {
				return fmt.Errorf("invalid anchor %s", p.ID)
			}
		}
		for _, o := range p.Adjustments {
			if !finite(o[0]) || !finite(o[1]) || math.Abs(o[0]) > 256 || math.Abs(o[1]) > 256 || math.Mod(o[0], 128) != 0 || math.Mod(o[1], 128) != 0 {
				return fmt.Errorf("invalid annotated access adjustment")
			}
		}
	}
	for _, id := range []string{"circle", "temple", "platform", "lagoon", "bridge", "waterfall"} {
		if !ids[id] {
			return fmt.Errorf("missing composition %s", id)
		}
	}
	return nil
}

func recomposeScene(s Spec) (*Scene, error) {
	if e := s.Validate(); e != nil {
		return nil, e
	}
	m, e := Load(s.Source)
	if e != nil {
		return nil, e
	}
	if !strings.EqualFold(m.Hash, s.SourceHash) {
		return nil, fmt.Errorf("source fingerprint mismatch")
	}
	if m.Terrain.Width != 193 || m.Terrain.Height != 97 || s.Edit != (Rect{[2]float64{-12288, -4096}, [2]float64{12288, 8192}}) {
		return nil, fmt.Errorf("recompose profile requires the complete 192x96 donor")
	}
	if !slices.Equal(m.Terrain.GroundTilesets, []string{"Zdrt", "Zdtr", "Zdrg", "Zsan", "Zbkl", "Arck", "Agrd", "Alvd", "Avin"}) {
		return nil, fmt.Errorf("incompatible tropical palette")
	}
	if len(m.Doodads.SpecialDoodads) != 0 {
		return nil, fmt.Errorf("profile requires explicit special-doodad transform annotations")
	}
	cat, e := CatalogMap(m, s.Install)
	if e != nil {
		return nil, e
	}
	for id, a := range cat.Assets {
		if len(a.Errors) > 0 {
			return nil, fmt.Errorf("asset %s: %v", id, a.Errors)
		}
	}
	stock, e := mpqchain.Open(s.Install)
	if e != nil {
		return nil, e
	}
	defer stock.Close()
	r := Resolver{m, stock}
	water, e := r.Table("TerrainArt\\Water.slk")
	if e != nil {
		return nil, e
	}
	row := water.Rows[string(m.Terrain.Tileset)+"Sha"]
	if row == nil {
		return nil, fmt.Errorf("missing water metadata")
	}
	g := &Scene{Map: m, Spec: s, Catalog: cat, Original: slices.Clone(m.Terrain.Tiles), Water: row.Number("height") * 128}
	return g, nil
}

func extractLibrary(g *Scene) (Library, error) {
	l := Library{Format: "wc3-composition-library-v1", SourceSHA: g.Map.Hash, Ownership: map[uint32]string{}}
	for _, d := range g.Spec.Recompose.Compositions {
		p := Prefab{PrefabSpec: d, Pivot: [2]float64{(d.Source.Min[0] + d.Source.Max[0]) / 2, (d.Source.Min[1] + d.Source.Max[1]) / 2}, HeightPolicy: "rigid original Z; exact translated core; generated transition"}
		p.SupportWidth = int((d.Source.Max[0]-d.Source.Min[0])/128) + 1
		p.SupportHeight = int((d.Source.Max[1]-d.Source.Min[1])/128) + 1
		for y := d.Source.Min[1]; y <= d.Source.Max[1]; y += 128 {
			for x := d.Source.Min[0]; x <= d.Source.Max[0]; x += 128 {
				i := g.index(x, y)
				if i < 0 {
					return l, fmt.Errorf("support outside donor")
				}
				p.Support = append(p.Support, g.Original[i])
			}
		}
		for _, o := range g.Map.Doodads.Doodads {
			if !d.Source.Contains(float64(o.Position[0]), float64(o.Position[1])) {
				continue
			}
			if old, ok := l.Ownership[o.CreationNumber]; ok {
				return l, fmt.Errorf("piece %d belongs to both %s and %s", o.CreationNumber, old, p.ID)
			}
			l.Ownership[o.CreationNumber] = p.ID
			p.Pieces = append(p.Pieces, o)
		}
		if len(p.Pieces) == 0 {
			return l, fmt.Errorf("empty composition %s", p.ID)
		}
		for id, offset := range p.Adjustments {
			found := false
			for _, piece := range p.Pieces {
				if piece.CreationNumber == id {
					found = true
					if !slices.Contains([]string{"ZRrs", "ZRrk", "ZRbs", "B001"}, piece.TypeID) || !p.Source.Contains(float64(piece.Position[0])+offset[0], float64(piece.Position[1])+offset[1]) {
						return l, fmt.Errorf("access adjustment moves architecture or leaves core: %d", id)
					}
				}
			}
			if !found {
				return l, fmt.Errorf("access adjustment references missing piece %d", id)
			}
		}
		l.Prefabs = append(l.Prefabs, p)
	}
	for _, d := range g.Map.Doodads.Doodads {
		if _, ok := l.Ownership[d.CreationNumber]; ok {
			continue
		}
		if slices.Contains(g.Spec.Trees, d.TypeID) || slices.Contains(g.Spec.Plants, d.TypeID) || slices.Contains(g.Spec.Rocks, d.TypeID) {
			l.Ownership[d.CreationNumber] = "decoration-donor"
		} else {
			l.Ownership[d.CreationNumber] = "retired-with-old-layout"
			l.Retired = append(l.Retired, d.CreationNumber)
		}
		if strings.Contains(string(g.Map.Files["war3map.j"]), fmt.Sprintf("gg_dest_%s_%04d", d.TypeID, d.CreationNumber)) {
			return l, fmt.Errorf("unmapped script object reference")
		}
	}
	return l, nil
}

func InspectRecompose(s Spec, out string) error {
	g, e := recomposeScene(s)
	if e != nil {
		return e
	}
	l, e := extractLibrary(g)
	if e != nil {
		return e
	}
	rounds := map[string]bool{}
	c, e := w3c.Parse(g.Map.Files["war3map.w3c"])
	if e != nil {
		return e
	}
	cb, e := w3c.Encode(c)
	if e != nil {
		return e
	}
	rounds["w3c"] = bytes.Equal(cb, g.Map.Files["war3map.w3c"])
	i, e := w3i.Parse(g.Map.Files["war3map.w3i"])
	if e != nil {
		return e
	}
	ib, e := w3i.Encode(i)
	if e != nil {
		return e
	}
	rounds["w3i"] = bytes.Equal(ib, g.Map.Files["war3map.w3i"])
	u, e := unitsdoo.Parse(g.Map.Files["war3mapunits.doo"])
	if e != nil {
		return e
	}
	ub, e := unitsdoo.Encode(u)
	if e != nil {
		return e
	}
	rounds["unitsdoo"] = bytes.Equal(ub, g.Map.Files["war3mapunits.doo"])
	for n, ok := range rounds {
		if !ok {
			return fmt.Errorf("%s no-op roundtrip differs", n)
		}
	}
	for name, v := range map[string]any{"library.json": l, "catalog.json": g.Catalog, "cameras.json": c, "map-info.json": i, "units.json": u, "roundtrip.json": rounds} {
		if e := JSON(filepath.Join(out, name), v); e != nil {
			return e
		}
	}
	return nil
}
