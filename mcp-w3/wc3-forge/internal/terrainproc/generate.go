package terrainproc

import (
	"encoding/binary"
	"fmt"
	"math"
	"math/rand"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"time"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/mpqchain"
)

type Report struct {
	Format            string            `json:"format"`
	Seed              int               `json:"seed"`
	Map               string            `json:"map"`
	SourceSHA         string            `json:"source_sha256"`
	Changed           map[string]string `json:"changed_members"`
	Preserved         int               `json:"preserved_members"`
	TerrainChanges    int               `json:"changed_vertices"`
	Added             int               `json:"added_objects"`
	Removed           int               `json:"removed_objects"`
	CompositionPieces int               `json:"composition_pieces"`
	RouteReachable    bool              `json:"route_reachable"`
	Protected         bool              `json:"protected_unchanged"`
	Engine            EngineResult      `json:"engine"`
	DurationMS        int64             `json:"duration_ms"`
	TimingsMS         map[string]int64  `json:"timings_ms,omitempty"`
	ShadowMethod      string            `json:"shadow_method"`
	Status            string            `json:"status"`
}
type Scene struct {
	Reservations []Rect
	Map          *Map
	Spec         Spec
	Catalog      *Catalog
	Original     []w3e.Tilepoint
	Added        []doodadsdoo.Doodad
	Anchors      []doodadsdoo.Doodad
	Water        float64
	Rand         *rand.Rand
	Next         uint32
}

func (g *Scene) xy(c, r int) (float64, float64) {
	return float64(g.Map.Terrain.CenterOffset[0]) + float64(c)*128, float64(g.Map.Terrain.CenterOffset[1]) + float64(r)*128
}
func (g *Scene) index(x, y float64) int {
	c := int(math.Round((x - float64(g.Map.Terrain.CenterOffset[0])) / 128))
	r := int(math.Round((y - float64(g.Map.Terrain.CenterOffset[1])) / 128))
	if c < 0 || r < 0 || c >= int(g.Map.Terrain.Width) || r >= int(g.Map.Terrain.Height) {
		return -1
	}
	return c + r*int(g.Map.Terrain.Width)
}
func (g *Scene) height(x, y float64, tiles []w3e.Tilepoint) float64 {
	w, h := int(g.Map.Terrain.Width), int(g.Map.Terrain.Height)
	fx := (x - float64(g.Map.Terrain.CenterOffset[0])) / 128
	fy := (y - float64(g.Map.Terrain.CenterOffset[1])) / 128
	cx, cy := int(math.Floor(fx)), int(math.Floor(fy))
	tx, ty := fx-float64(cx), fy-float64(cy)
	if cx < 0 || cy < 0 || cx+1 >= w || cy+1 >= h {
		return -1000
	}
	z := func(x, y int) float64 { return float64(tiles[x+y*w].FinalZ()) }
	return (z(cx, cy)*(1-tx)+z(cx+1, cy)*tx)*(1-ty) + (z(cx, cy+1)*(1-tx)+z(cx+1, cy+1)*tx)*ty
}
func smooth(x float64) float64 { x = max(0., min(1., x)); return x * x * (3 - 2*x) }
func (g *Scene) silhouette(x, y float64) float64 {
	r := g.Spec.Edit
	cx, cy := (r.Min[0]+r.Max[0])/2, (r.Min[1]+r.Max[1])/2
	rx, ry := (r.Max[0]-r.Min[0])/2-384, (r.Max[1]-r.Min[1])/2-128
	a := math.Atan2((y-cy)/ry, (x-cx)/rx)
	edge := 1 + 0.065*math.Sin(a*3+float64(g.Spec.Seed%13)) + .035*math.Cos(a*5)
	return math.Hypot((x-cx)/rx, (y-cy)/ry) / edge
}
func (g *Scene) sample() ([]int, int, int) {
	s := g.Spec.Sample
	w, h := int((s.Max[0]-s.Min[0])/128), int((s.Max[1]-s.Min[1])/128)
	states := make([]int, w*h)
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			wx, wy := s.Min[0]+float64(x)*128, s.Min[1]+float64(y)*128
			i := g.index(wx, wy)
			t := g.Original[i]
			label := 0
			if t.GroundTexture == 2 || t.GroundTexture == 6 || t.GroundTexture == 8 {
				label = 1
			}
			if t.GroundTexture == 4 || t.GroundTexture == 5 {
				label = 2
			}
			if g.whole() && float64(t.FinalZ()) < g.Water+55 {
				label = 4 // Sea is distinct from an open clearing in the full sample.
			}
			states[x+y*w] = label
		}
	}
	for _, d := range g.Map.Doodads.Doodads {
		if !slices.Contains(g.Spec.Trees, d.TypeID) {
			continue
		}
		x := int((float64(d.Position[0]) - s.Min[0]) / 128)
		y := int((float64(d.Position[1]) - s.Min[1]) / 128)
		if x >= 0 && y >= 0 && x < w && y < h {
			if !g.whole() || states[x+y*w] != 4 {
				states[x+y*w] = 3
			}
		}
	}
	return states, w, h
}
func (g *Scene) terrain(states []int, w, h int) {
	if g.whole() {
		g.wholeTerrain(states, w, h)
		return
	}
	s := g.Spec
	for y := 0; y <= h; y++ {
		for x := 0; x <= w; x++ {
			wx, wy := s.Edit.Min[0]+float64(x)*128, s.Edit.Min[1]+float64(y)*128
			if !s.Editable(wx, wy) {
				continue
			}
			i := g.index(wx, wy)
			old := g.Original[i]
			t := old
			edge := min(wx-s.Edit.Min[0], s.Edit.Max[0]-wx, wy-s.Edit.Min[1], s.Edit.Max[1]-wy)
			blend := smooth(edge / 384)
			rad := g.silhouette(wx, wy)
			// Keep the donor sea floor: changing its depth paints a visible rectangular water band.
			z := float64(old.FinalZ()) + 475*smooth((1.1-rad)/.85)
			z += 36 * math.Sin(wx/680+float64(s.Seed%11)) * math.Cos(wy/870) * smooth((1-rad)*3)
			dist := s.PathDistance(wx, wy)
			if dist < s.PathWidth {
				z = max(z, 80)*(1-smooth((s.PathWidth-dist)/s.PathWidth)) + max(110., z-35)*smooth((s.PathWidth-dist)/s.PathWidth)
			}
			z = float64(old.FinalZ())*(1-blend) + z*blend
			t.GroundHeight = int16(math.Round((z-(float64(t.LayerHeight)-2)*128)*4 + 8192))
			label := states[min(x, w-1)+min(y, h-1)*w]
			tex := uint8(3)
			if z > g.Water+45 {
				switch label {
				case 1, 3:
					tex = 8
				case 2:
					tex = 5
				default:
					tex = 2
				}
			}
			if dist < s.PathWidth*.45 && z > g.Water+30 {
				tex = 3
			}
			if blend > .45 && rad < 1.1 {
				t.GroundTexture = tex
				t.TextureDetails = (t.TextureDetails & 0xe0) | uint8(g.Rand.Intn(16))
			}
			if z < g.Water+16 {
				t.Flags |= 4
				t.WaterLevel = 8192
			} else {
				t.Flags &^= 4
			}
			if blend == 0 || rad >= 1.1 && dist >= s.PathWidth {
				t = old
			}
			g.Map.Terrain.Tiles[i] = t
		}
	}
}
func (g *Scene) composition() ([]doodadsdoo.Doodad, error) {
	if g.whole() {
		return nil, nil // The authored cascade is retained in place, with its support.
	}
	c := g.Spec.Waterfall
	target := Rect{[2]float64{c.Source.Min[0] + c.Offset[0], c.Source.Min[1] + c.Offset[1]}, [2]float64{c.Source.Max[0] + c.Offset[0], c.Source.Max[1] + c.Offset[1]}}
	for x := target.Min[0] - c.Blend; x <= target.Max[0]+c.Blend; x += 128 {
		for y := target.Min[1] - c.Blend; y <= target.Max[1]+c.Blend; y += 128 {
			if !g.Spec.Editable(x, y) || g.index(x-c.Offset[0], y-c.Offset[1]) < 0 {
				return nil, fmt.Errorf("cascade terrain support exceeds editable region")
			}
		}
	}
	if c.Offset[2] != 0 {
		return nil, fmt.Errorf("waterfall outlet must remain on the original water plane; vertical translation rejected")
	}
	// Terrain support travels with the composition; the outer band joins the surrounding landform.
	for i, t := range g.Map.Terrain.Tiles {
		wx, wy := g.xy(i%int(g.Map.Terrain.Width), i/int(g.Map.Terrain.Width))
		if !g.Spec.Editable(wx, wy) {
			continue
		}
		dx := max(target.Min[0]-wx, wx-target.Max[0], 0.)
		dy := max(target.Min[1]-wy, wy-target.Max[1], 0.)
		d := math.Hypot(dx, dy)
		if d >= c.Blend {
			continue
		}
		si := g.index(wx-c.Offset[0], wy-c.Offset[1])
		if si < 0 {
			return nil, fmt.Errorf("cascade source leaves map")
		}
		src := g.Original[si]
		weight := 1 - smooth(d/c.Blend)
		z := float64(t.FinalZ())*(1-weight) + (float64(src.FinalZ())+c.Offset[2])*weight
		if d == 0 {
			t = src
		}
		t.GroundHeight = int16(math.Round((z-(float64(t.LayerHeight)-2)*128)*4 + 8192))
		if z < g.Water+16 {
			t.Flags |= 4
		} else {
			t.Flags &^= 4
		}
		g.Map.Terrain.Tiles[i] = t
	}
	var parts []doodadsdoo.Doodad
	for _, source := range g.Map.Doodads.Doodads {
		if !c.Source.Contains(float64(source.Position[0]), float64(source.Position[1])) {
			continue
		}
		d := source
		a := g.Catalog.Assets[d.TypeID]
		if a == nil || len(a.Errors) > 0 {
			return nil, fmt.Errorf("composition asset %s is unresolved: %v", d.TypeID, a)
		}
		d.Position[0] += float32(c.Offset[0])
		d.Position[1] += float32(c.Offset[1])
		d.Position[2] += float32(c.Offset[2])
		g.Next++
		d.CreationNumber = g.Next
		parts = append(parts, d)
	}
	if len(parts) == 0 {
		return nil, fmt.Errorf("empty composition")
	}
	return parts, nil
}
func (g *Scene) decorate(states []int, w, h int, parts []doodadsdoo.Doodad) {
	pools := map[string][]doodadsdoo.Doodad{}
	for _, d := range g.Map.Doodads.Doodads {
		if g.Spec.Sample.Contains(float64(d.Position[0]), float64(d.Position[1])) {
			pools[d.TypeID] = append(pools[d.TypeID], d)
		}
	}
	c := g.Spec.Waterfall
	reserve := Rect{[2]float64{c.Source.Min[0] + c.Offset[0] - 128, c.Source.Min[1] + c.Offset[1] - 128}, [2]float64{c.Source.Max[0] + c.Offset[0] + 128, c.Source.Max[1] + c.Offset[1] + 128}}
	g.Added = append(g.Added, parts...)
	var trees [][2]float64
	place := func(ids []string, x, y float64, tree bool) {
		id := ids[g.Rand.Intn(len(ids))]
		if g.whole() {
			// Imported species follow their observed frequency across all islands.
			// Uniform rawcode sampling greatly overrepresented the rare broad tree.
			total := 0
			for _, candidate := range ids {
				total += len(pools[candidate])
			}
			if total == 0 {
				return
			}
			pick := g.Rand.Intn(total)
			for _, candidate := range ids {
				pick -= len(pools[candidate])
				if pick < 0 {
					id = candidate
					break
				}
			}
		}
		pool := pools[id]
		if len(pool) == 0 {
			return
		}
		a := g.Catalog.Assets[id]
		if a == nil || len(a.Errors) > 0 {
			return
		}
		d := pool[g.Rand.Intn(len(pool))]
		// Classic World Editor snaps pathing destructibles to the 64-unit placement grid.
		// Apply it before grounding and route clearance so save/open does not relocate trees.
		if a.Pathing != nil {
			x = math.Round(x/64) * 64
			y = math.Round(y/64) * 64
			if g.whole() {
				// 2x2 footprints use the intervening 32-unit centers; 4x4
				// trees use multiples of 64. Verified by native editor saves.
				x += float64(a.Pathing.Width%4) * 16
				y += float64(a.Pathing.Height%4) * 16
			}
		}
		if !g.Spec.Editable(x, y) || reserve.Contains(x, y) {
			return
		}
		for _, r := range g.Reservations {
			if r.Contains(x, y) {
				return
			}
		}
		if g.whole() && !g.anchorClearance(x, y) {
			return
		}
		edge := min(x-g.Spec.Edit.Min[0], g.Spec.Edit.Max[0]-x, y-g.Spec.Edit.Min[1], g.Spec.Edit.Max[1]-y)
		if edge < 192 {
			return
		}
		clearance := g.Spec.PathWidth/2 + 96.
		if a.Pathing != nil {
			clearance += math.Hypot(float64(a.Pathing.Width), float64(a.Pathing.Height)) * 16
		}
		if g.Spec.PathDistance(x, y) < clearance {
			return
		}
		z := g.height(x, y, g.Map.Terrain.Tiles)
		if z < g.Water+55 {
			return
		}
		dz := math.Max(math.Abs(z-g.height(x+64, y, g.Map.Terrain.Tiles)), math.Abs(z-g.height(x, y+64, g.Map.Terrain.Tiles)))
		if dz > 55 {
			return
		}
		if tree {
			for _, p := range trees {
				if math.Hypot(x-p[0], y-p[1]) < 165 {
					return
				}
			}
			trees = append(trees, [2]float64{x, y})
		}
		d.Position = [3]float32{float32(x), float32(y), float32(z)}
		d.Rotation = float32(g.Rand.Float64() * math.Pi * 2)
		if g.whole() {
			if angle, err := strconv.ParseFloat(a.Fields["fixedrot"], 64); err == nil && angle >= 0 {
				d.Rotation = float32(angle * math.Pi / 180)
			}
			if d.Flags > 2 {
				d.Flags = 2 // Do not inherit an editor-only donor placement flag.
			}
		}
		g.Next++
		d.CreationNumber = g.Next
		g.Added = append(g.Added, d)
	}
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			wx := g.Spec.Edit.Min[0] + (float64(x)+g.Rand.Float64())*128
			wy := g.Spec.Edit.Min[1] + (float64(y)+g.Rand.Float64())*128
			label := states[x+y*w]
			if label == 3 || label == 1 && g.Rand.Float64() < .45 {
				place(g.Spec.Trees, wx, wy, true)
				for k := 0; k < 3; k++ {
					angle := g.Rand.Float64() * 2 * math.Pi
					xx, yy := wx+210*math.Cos(angle), wy+210*math.Sin(angle)
					place(g.Spec.Trees, xx, yy, true)
					place(g.Spec.Plants, xx+45, yy+30, false)
				}
				if g.Rand.Float64() < .7 {
					place(g.Spec.Plants, wx+70, wy-70, false)
				}
			} else if label == 1 && g.Rand.Float64() < .65 {
				place(g.Spec.Plants, wx, wy, false)
			} else if label == 2 && g.Rand.Float64() < .22 && len(g.Spec.Rocks) > 0 {
				place(g.Spec.Rocks, wx, wy, false)
			}
		}
	}
}
func Generate(s Spec, out string) (Report, error) {
	if s.Mode == "whole-map-landscape" { return GenerateLandscape(s,out) }
	if s.Mode == "whole-map-scene" {
		return GenerateScenes(s, out)
	}
	if s.Mode == "whole-map-recompose" {
		return GenerateRecompose(s, out)
	}
	started := time.Now()
	report := Report{Format: "wc3-generation-report-v1", Seed: s.Seed, Changed: map[string]string{}, ShadowMethod: "terrain raycast + conservative object canopy projection (editor bake pending)", Status: "Compiled"}
	if s.Shadows == "omit" {
		report.ShadowMethod = "cleared in edited area; shadows excluded by user"
	}
	report.TimingsMS = map[string]int64{}
	stage := started
	mark := func(name string) { report.TimingsMS[name] = time.Since(stage).Milliseconds(); stage = time.Now() }
	if e := s.Validate(); e != nil {
		return report, e
	}
	m, e := Load(s.Source)
	if e != nil {
		return report, e
	}
	report.SourceSHA = m.Hash
	if !strings.EqualFold(m.Hash, s.SourceHash) {
		return report, fmt.Errorf("source fingerprint mismatch")
	}
	if !slices.Equal(m.Terrain.GroundTilesets, []string{"Zdrt", "Zdtr", "Zdrg", "Zsan", "Zbkl", "Arck", "Agrd", "Alvd", "Avin"}) {
		return report, fmt.Errorf("tropical-v1 requires its recorded material palette")
	}
	cat, e := CatalogMap(m, s.Install)
	if e != nil {
		return report, e
	}
	for _, id := range append(append(append([]string{}, s.Trees...), s.Plants...), s.Rocks...) {
		a := cat.Assets[id]
		if a == nil {
			return report, fmt.Errorf("unknown catalog id %s", id)
		}
		if len(a.Errors) > 0 {
			return report, fmt.Errorf("asset %s: %v", id, a.Errors)
		}
	}
	stock, e := mpqchain.Open(s.Install)
	if e != nil {
		return report, e
	}
	resolver := Resolver{m, stock}
	water, e := resolver.Table("TerrainArt\\Water.slk")
	stock.Close()
	if e != nil {
		return report, e
	}
	waterRow, ok := water.Rows[string(m.Terrain.Tileset)+"Sha"]
	if !ok {
		return report, fmt.Errorf("missing tileset water metadata")
	}
	g := &Scene{Map: m, Spec: s, Catalog: cat, Original: append([]w3e.Tilepoint{}, m.Terrain.Tiles...), Rand: rand.New(rand.NewSource(int64(s.Seed))), Water: waterRow.Number("height") * 128}
	for _, r := range []Rect{s.Edit, s.Sample, s.Waterfall.Source} {
		if g.index(r.Min[0], r.Min[1]) < 0 || g.index(r.Max[0], r.Max[1]) < 0 {
			return report, fmt.Errorf("region outside map")
		}
	}
	for _, d := range m.Doodads.Doodads {
		g.Next = max(g.Next, d.CreationNumber)
	}
	if e = g.prepareWhole(); e != nil {
		return report, e
	}
	sample, sw, sh := g.sample()
	w, h := int((s.Edit.Max[0]-s.Edit.Min[0])/128), int((s.Edit.Max[1]-s.Edit.Min[1])/128)
	fixed := make([]int, w*h)
	var allowed []int
	if g.whole() {
		allowed = make([]int, w*h)
	}
	for i := range fixed {
		fixed[i] = -1
		x, y := s.Edit.Min[0]+float64(i%w)*128, s.Edit.Min[1]+float64(i/w)*128
		outside := g.silhouette(x, y) > 1.05
		if g.whole() {
			outside = float64(g.Original[g.index(x, y)].FinalZ()) < g.Water+55
		}
		if outside || s.PathDistance(x, y) < s.PathWidth*.55 {
			fixed[i] = 0
		}
		if g.whole() {
			if outside {
				fixed[i] = 4
			} else {
				allowed[i] = 15 // Land may use 0..3; never the sea label 4.
			}
		}
	}
	steps := s.Steps
	if steps == 0 {
		steps = 20000
	}
	mark("read_catalog_sample")
	engine, e := RunEngine(s, EngineRequest{w, h, s.Seed, sw, sh, sample, fixed, steps, s.Tries, allowed}, filepath.Join(out, "engine"))
	if e != nil {
		return report, e
	}
	report.Engine = engine
	mark("markovjunior")
	if e := JSON(filepath.Join(out, "spec.json"), s); e != nil {
		return report, e
	}
	if e := JSON(filepath.Join(out, "catalog.json"), cat); e != nil {
		return report, e
	}
	g.terrain(engine.States, w, h)
	parts, e := g.composition()
	if e != nil {
		return report, e
	}
	report.CompositionPieces = len(parts)
	if g.whole() {
		for _, d := range g.Anchors {
			if s.Waterfall.Source.Contains(float64(d.Position[0]), float64(d.Position[1])) {
				report.CompositionPieces++
			}
		}
	}
	g.decorate(engine.States, w, h, parts)
	kept := make([]doodadsdoo.Doodad, 0, len(m.Doodads.Doodads)+len(g.Added))
	script := string(m.Files["war3map.j"])
	for _, d := range m.Doodads.Doodads {
		if g.replaceObject(d) {
			name := fmt.Sprintf("gg_dest_%s_%04d", d.TypeID, d.CreationNumber)
			if strings.Contains(script, name) {
				return report, fmt.Errorf("editable object referenced by script: %s", name)
			}
			report.Removed++
		} else {
			kept = append(kept, d)
		}
	}
	kept = append(kept, g.Added...)
	m.Doodads.Doodads = kept
	report.Added = len(g.Added)
	mark("terrain_composition_decoration")
	pathing, shadows, reachable, e := g.spatial()
	if e != nil {
		return report, e
	}
	report.RouteReachable = reachable
	mark("pathing_and_provisional_shadows")
	if !reachable {
		return report, fmt.Errorf("route fails collision-aware connectivity")
	}
	report.Protected = true
	for i, t := range m.Terrain.Tiles {
		if t != g.Original[i] {
			x, y := g.xy(i%int(m.Terrain.Width), i/int(m.Terrain.Width))
			if !s.Editable(x, y) {
				return report, fmt.Errorf("protected terrain changed")
			}
			report.TerrainChanges++
		}
	}
	terrain, e := w3e.Encode(m.Terrain)
	if e != nil {
		return report, e
	}
	doo, e := doodadsdoo.Encode(m.Doodads)
	if e != nil {
		return report, e
	}
	changes := map[string][]byte{"war3map.w3e": terrain, "war3map.doo": doo, "war3map.wpm": pathing, "war3map.shd": shadows}
	for n, b := range changes {
		report.Changed[n] = Hash(b)
	}
	report.Preserved = len(m.Files) - len(changes)
	report.Map = filepath.Join(out, fmt.Sprintf("Tropical-Generated-%d.w3x", s.Seed))
	if e = m.Write(report.Map, changes); e != nil {
		return report, e
	}
	if _, e = Load(report.Map); e != nil {
		return report, fmt.Errorf("generated map validation: %w", e)
	}
	report.DurationMS = time.Since(started).Milliseconds()
	mark("encode_export_reextract")
	report.Status = "Validated"
	if e := JSON(filepath.Join(out, "report.json"), report); e != nil {
		return report, e
	}
	if g.whole() {
		for _, d := range g.Anchors {
			if s.Waterfall.Source.Contains(float64(d.Position[0]), float64(d.Position[1])) {
				parts = append(parts, d)
			}
		}
	}
	if e := JSON(filepath.Join(out, "composition.json"), g.compositionMetadata(parts)); e != nil {
		return report, e
	}
	_ = JSON(filepath.Join(out, "placements-added.json"), g.Added)
	if e := writeManifest(g, report, out, sample, sw, sh); e != nil {
		return report, e
	}
	return report, nil
}

func encodePathing(w, h int, cells []byte) []byte {
	b := make([]byte, 16+len(cells))
	copy(b, "MP3W")
	binary.LittleEndian.PutUint32(b[8:], uint32(w))
	binary.LittleEndian.PutUint32(b[12:], uint32(h))
	copy(b[16:], cells)
	return b
}
