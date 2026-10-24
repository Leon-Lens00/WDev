package terrainproc

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/unitsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3i"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wtg"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wts"
	"math"
	"path/filepath"
	"reflect"
	"regexp"
	"slices"
)

// AuditBiomeEditor reports real native normalizations; no UI or game is simulated.
func AuditBiomeEditor(recipe, source, saved, out string) error {
	q, _, library, mat, donor, cat, e := loadBiome(recipe)
	if e != nil {
		return e
	}
	if e := ValidateBiome(recipe, source, out+".generated.json"); e != nil {
		return e
	}
	a, e := Load(source)
	if e != nil {
		return e
	}
	b, e := Load(saved)
	if e != nil {
		return e
	}
	var physicalProvenance *BiomeNativeLandformProvenance
	if q.Landforms != nil {
		inspection, err := inspectBiomeNativeLandforms(q, library, donor, mat, a, b)
		physicalProvenance = &inspection.Provenance
		if e := JSON(out+".landforms.json", inspection); e != nil {
			return e
		}
		if err != nil {
			return fmt.Errorf("native physical inspection: %w", err)
		}
	}
	changes := map[string]any{}
	for n, v := range a.Files {
		if !bytes.Equal(v, b.Files[n]) {
			changes[n] = map[string]any{"before": Hash(v), "after": Hash(b.Files[n]), "lengths": []int{len(v), len(b.Files[n])}}
		}
	}
	for n, v := range b.Files {
		if _, ok := a.Files[n]; !ok {
			changes[n] = map[string]any{"added": Hash(v)}
		}
	}
	diffs := func(a, b any) map[string]any {
		d := map[string]any{}
		av, bv := reflect.ValueOf(a), reflect.ValueOf(b)
		if av.Kind() == reflect.Pointer {
			av = av.Elem()
			bv = bv.Elem()
		}
		for i := 0; i < av.NumField(); i++ {
			if av.Type().Field(i).IsExported() && !reflect.DeepEqual(av.Field(i).Interface(), bv.Field(i).Interface()) {
				d[av.Type().Field(i).Name] = []any{av.Field(i).Interface(), bv.Field(i).Interface()}
			}
		}
		return d
	}
	tileDiff := map[string]int{}
	tileExamples := map[string]any{}
	if len(a.Terrain.Tiles) != len(b.Terrain.Tiles) {
		return fmt.Errorf("native grid changed")
	}
	for i, t := range a.Terrain.Tiles {
		for k, v := range diffs(t, b.Terrain.Tiles[i]) {
			tileDiff[k]++
			if _, ok := tileExamples[k]; !ok {
				tileExamples[k] = v
			}
		}
	}
	ai, e := w3i.Parse(a.Files["war3map.w3i"])
	if e != nil {
		return e
	}
	bi, e := w3i.Parse(b.Files["war3map.w3i"])
	if e != nil {
		return e
	}
	au, e := unitsdoo.Parse(a.Files["war3mapunits.doo"])
	if e != nil {
		return e
	}
	bu, e := unitsdoo.Parse(b.Files["war3mapunits.doo"])
	if e != nil {
		return e
	}
	dd := map[string]int{}
	examples := map[string]any{}
	byID := map[uint32]int{}
	for i, d := range b.Doodads.Doodads {
		byID[d.CreationNumber] = i
	}
	for _, d := range a.Doodads.Doodads {
		j, ok := byID[d.CreationNumber]
		if !ok {
			return fmt.Errorf("lost doodad")
		}
		for k, v := range diffs(d, b.Doodads.Doodads[j]) {
			dd[k]++
			if _, ok := examples[k]; !ok {
				examples[k] = v
			}
		}
	}
	transitions := map[string]int{}
	if a.Pathing.Width != b.Pathing.Width || a.Pathing.Height != b.Pathing.Height || len(a.Pathing.Cells) != len(b.Pathing.Cells) {
		return fmt.Errorf("native pathing dimensions changed")
	}
	for i, f := range a.Pathing.Cells {
		transitions[fmt.Sprintf("%d->%d", f, b.Pathing.Cells[i])]++
	}
	failures := []string{}
	fail := func(s string) {
		if !slices.Contains(failures, s) {
			failures = append(failures, s)
		}
	}
	allowed := []string{"(listfile)", "(attributes)", "war3map.doo", "war3mapunits.doo", "war3map.w3e", "war3map.w3i", "war3map.w3s", "war3map.wtg", "war3map.j", "war3map.wts", "war3map.mmp", "war3mapmap.blp", "war3map.wpm"}
	for n := range changes {
		if biomeEditorLandformRemoval(q, a, b, n) {
			continue
		}
		if !slices.Contains(allowed, n) {
			fail("unexpected member: " + n)
		}
	}
	aa, bb := *a.Terrain, *b.Terrain
	aa.Tiles = nil
	bb.Tiles = nil
	if !reflect.DeepEqual(aa, bb) {
		fail("terrain header changed")
	}
	for i, t := range a.Terrain.Tiles {
		v := b.Terrain.Tiles[i]
		if t.Boundary != v.Boundary {
			x, y := i%q.Geometry.Width, i/q.Geometry.Width
			if t.Boundary || !v.Boundary || (x != q.Geometry.Width-5 && y != q.Geometry.Height-5) {
				fail("boundary changed outside native trailing margin")
			}
			v.Boundary = t.Boundary
		}
		if t != v {
			fail("terrain physical/appearance change")
		}
	}
	maxZ, maxAngle := 0., 0.
	if len(a.Doodads.Doodads) != len(b.Doodads.Doodads) || len(byID) != len(b.Doodads.Doodads) || !reflect.DeepEqual(a.Doodads.SpecialDoodads, b.Doodads.SpecialDoodads) {
		fail("doodad inventory changed")
	}
	for _, d := range a.Doodads.Doodads {
		v := b.Doodads.Doodads[byID[d.CreationNumber]]
		maxZ = max(maxZ, math.Abs(float64(d.Position[2]-v.Position[2])))
		maxAngle = max(maxAngle, math.Abs(float64(d.Rotation-v.Rotation)))
		if d.Position[0] != v.Position[0] || d.Position[1] != v.Position[1] || math.Abs(float64(d.Position[2]-v.Position[2])) > .002 || math.Abs(float64(d.Rotation-v.Rotation)) > .000002 {
			fail("native moved object after canonical placement")
		}
		v.Position = d.Position
		v.Rotation = d.Rotation
		if len(diffs(d, v)) > 0 {
			fail("doodad semantic fields changed")
		}
	}
	if len(au.Entities) != len(bu.Entities) {
		fail("unit inventory changed")
	} else {
		for i, d := range au.Entities {
			if len(diffs(d, bu.Entities[i])) > 0 {
				fail("start entity changed")
			}
		}
	}
	infoChanges := diffs(ai, bi)
	stringsTable, err := wts.Parse(b.Files["war3map.wts"])
	if err != nil {
		return err
	}
	for i := range bi.Players {
		bi.Players[i].Name = stringsTable.Resolve(bi.Players[i].Name)
	}
	for i := range bi.Forces {
		bi.Forces[i].Name = stringsTable.Resolve(bi.Forces[i].Name)
	}
	if bi.Flags.Raw != ai.Flags.Raw|0x400 {
		fail("unexpected map flags")
	}
	bi.Flags = ai.Flags
	if bi.MapVersion != ai.MapVersion+1 {
		fail("unexpected native save version")
	}
	bi.MapVersion = ai.MapVersion
	if len(diffs(ai, bi)) > 0 {
		fail("spatial/player metadata changed")
	}
	tr, err := wtg.Parse(b.Files["war3map.wtg"], map[string]int{})
	if err != nil {
		return err
	}
	if len(tr.Triggers) > 0 || len(tr.Variables) > 0 {
		fail("native triggers appeared")
	}
	if raw := b.Files["war3map.w3s"]; len(raw) > 0 && !bytes.Equal(raw, a.Files["war3map.w3s"]) {
		fail("sound definitions changed")
	}
	ma, mb := a.Files["war3map.mmp"], b.Files["war3map.mmp"]
	if len(ma) != 24 || len(mb) != 24 || !bytes.Equal(ma[:12], mb[:12]) || !bytes.Equal(ma[20:], mb[20:]) {
		fail("minimap marker identity changed")
	} else {
		for _, k := range []int{12, 16} {
			delta := int(binary.LittleEndian.Uint32(ma[k:])) - int(binary.LittleEndian.Uint32(mb[k:]))
			if delta < -1 || delta > 1 {
				fail("minimap marker moved")
			}
		}
	}
	callNames := []string{"SetCameraBounds", "SetDayNightModels", "NewSoundEnvironment", "SetAmbientDaySound", "SetAmbientNightSound", "SetMapMusic", "InitBlizzard", "InitGlobals", "SetMapName", "SetMapDescription", "SetPlayers", "SetTeams", "SetGamePlacement", "DefineStartLocation", "SetPlayerStartLocation", "ForcePlayerStartLocation", "SetPlayerColor", "SetPlayerRacePreference", "SetPlayerRaceSelectable", "SetPlayerController", "SetPlayerTeam", "InitCustomPlayerSlots", "SetPlayerSlotAvailable", "InitGenericPlayerSlots"}
	for _, call := range regexp.MustCompile(`(?m)^\s*call\s+(\w+)`).FindAllStringSubmatch(string(b.Files["war3map.j"]), -1) {
		if !slices.Contains(callNames, call[1]) {
			fail("unexpected native script call: " + call[1])
		}
	}
	g := Scene{Map: b, Catalog: cat, Water: q.WaterLevel, Spec: Spec{Edit: biomeBounds(q), CollisionRadius: q.CollisionRadius}}
	blocked := combinedRecompose(&g, b.Pathing.Cells)
	routes := map[string]int{}
	for _, r := range q.Routes {
		allowed := slices.Clone(blocked)
		for i := range allowed {
			pt := cellPoint(&g, i)
			d := math.Inf(1)
			for j := 1; j < len(r.Points); j++ {
				d = min(d, biomeSegment(pt, biomeWorld(q, r.Points[j-1]), biomeWorld(q, r.Points[j])))
			}
			if d > r.Width/2 {
				allowed[i] = true
			}
		}
		trace, err := gridPath(&g, allowed, pathCell(&g, biomeWorld(q, r.Points[0])), pathCell(&g, biomeWorld(q, r.Points[len(r.Points)-1])), g.Spec.Edit)
		if err != nil {
			fail("native route " + r.ID + ": " + err.Error())
		} else {
			routes[r.ID] = len(trace)
		}
	}
	regions := map[string]map[string]int{}
	deep, deepOpen, flight, rockBuildable := 0, 0, 0, 0
	for i, f := range b.Pathing.Cells {
		x, y := i%b.Pathing.Width, i/b.Pathing.Width
		cx, cy := x/4, y/4
		w := q.Geometry.Width
		corner := []int{cx + cy*w, cx + 1 + cy*w, cx + (cy+1)*w, cx + 1 + (cy+1)*w}
		lo, hi := math.Inf(1), math.Inf(-1)
		allNonbuild := true
		for _, j := range corner {
			t := b.Terrain.Tiles[j]
			z := float64(t.FinalZ())
			lo = min(lo, z)
			hi = max(hi, z)
			if mat.Properties[b.Terrain.GroundTilesets[t.GroundTexture]]["buildable"] != "0" {
				allNonbuild = false
			}
		}
		region := "dry"
		margin := x < 16 || y < 16 || x >= b.Pathing.Width-16 || y >= b.Pathing.Height-16
		if margin {
			region = "boundary"
		} else if hi < q.WaterLevel-80 {
			region = "deep-water"
			deep++
			if f&2 == 0 {
				deepOpen++
			}
		} else if lo < q.WaterLevel+8 {
			region = "shore"
		} else if hi-lo > 64 {
			region = "slope"
		}
		if !margin && f&4 != 0 {
			flight++
		}
		if !margin && allNonbuild && f&8 == 0 {
			rockBuildable++
		}
		if regions[region] == nil {
			regions[region] = map[string]int{}
		}
		regions[region][fmt.Sprintf("%d->%d", a.Pathing.Cells[i], f)]++
	}
	if deep == 0 || deepOpen > 0 {
		fail("deep water unexpectedly walkable")
	}
	if flight > 0 {
		fail("unexpected native flight blocker")
	}
	if rockBuildable > 0 {
		fail("nonbuildable material became buildable")
	}
	e = JSON(out, map[string]any{"format": "wc3-native-biome-audit-v1", "source_sha256": a.Hash, "saved_sha256": b.Hash, "physical_provenance": physicalProvenance, "changed_members": changes, "terrain_fields": tileDiff, "terrain_examples": tileExamples, "doodad_fields": dd, "doodad_examples": examples, "max_z_roundoff": maxZ, "max_angle_roundoff": maxAngle, "w3i": infoChanges, "units": []any{au, bu}, "wpm_transitions": transitions, "wpm_regions": regions, "deep_water_cells": deep, "deep_water_open": deepOpen, "unexpected_flight_cells": flight, "nonbuildable_material_open": rockBuildable, "native_routes": routes, "collision_radius": q.CollisionRadius, "failures": failures, "passed": len(failures) == 0, "game_tests": false, "shadows": "excluded; layer preserved identical and zero"})
	if e != nil {
		return e
	}
	for _, m := range []*Map{a, b} {
		JSON(filepath.Join(filepath.Dir(out), filepath.Base(m.Path)+".objects.json"), m.Doodads)
		JSON(filepath.Join(filepath.Dir(out), filepath.Base(m.Path)+".pathing.json"), m.Pathing)
		JSON(filepath.Join(filepath.Dir(out), filepath.Base(m.Path)+".script.json"), string(m.Files["war3map.j"]))
		if e := JSON(filepath.Join(filepath.Dir(out), filepath.Base(m.Path)+".terrain.json"), m.Terrain); e != nil {
			return e
		}
	}
	if len(failures) > 0 {
		return fmt.Errorf("native biome audit: %v", failures)
	}
	return nil
}
