package terrainproc

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"math"
	"path/filepath"
	"reflect"
	"regexp"
	"slices"
	"strconv"

	"github.com/StephenSHorton/wc3-forge/internal/formats/w3i"
)

// AuditRecomposeEditor compares a real native save with its exact generated input.
// It does not grant visual approval or simulate a Warcraft run.
func AuditRecomposeEditor(s Spec, source, saved, out string) error {
	a, e := Load(source)
	if e != nil {
		return e
	}
	b, e := Load(saved)
	if e != nil {
		return e
	}
	var g *Scene
	var plan Layout
	var landscape LandscapePlan
	if s.Mode == "whole-map-landscape" {
		// Native pathing must use a graph certified against this exact generated
		// archive and spec, never a user-edited companion trace.
		if e := ValidateLandscape(s, source, filepath.Join(filepath.Dir(out), filepath.Base(out)+".generated-validation.json")); e != nil {
			return e
		}
		g, e = recomposeScene(s)
		if e == nil {
			e = strictJSON(filepath.Join(filepath.Dir(source), "layout.json"), &landscape)
		}
		if e == nil && (landscape.Format != "wc3-landscape-layout-v1" || landscape.Seed != s.Seed || len(landscape.Placements) != len(s.Scene.Instances)) {
			e = fmt.Errorf("native audit layout/spec mismatch")
		}
		plan = landscape.Layout
	} else if s.Mode == "whole-map-scene" {
		g, _, _, plan, _, _, e = buildSceneBase(s)
	} else {
		g, _, plan, _, e = buildRecomposeBase(s)
	}
	if e != nil {
		return e
	}
	failures := []string{}
	var nativeLandforms *LandformInspection
	if s.Mode == "whole-map-landscape" && landscape.Landforms != nil {
		physical, err := InspectLandforms(b, landscape.Landforms.Plan, landscape.Landforms.Supports)
		nativeLandforms = &physical
		if err != nil {
			failures = append(failures, "native landforms: "+err.Error())
		}
	}
	if !reflect.DeepEqual(a.Terrain, b.Terrain) {
		failures = append(failures, "terrain changed")
	}
	if !sameEditorGeometry(a.Doodads, b.Doodads) {
		failures = append(failures, "object geometry changed")
	}
	maxZ := 0.
	for i, d := range a.Doodads.Doodads {
		if i < len(b.Doodads.Doodads) {
			maxZ = math.Max(maxZ, math.Abs(float64(d.Position[2]-b.Doodads.Doodads[i].Position[2])))
		}
	}
	normalized := map[string]bool{"(listfile)": true, "(attributes)": true, "war3map.doo": true, "war3map.wpm": true, "war3map.w3i": true, "war3map.j": true, "war3map.wts": true, "war3mapmap.blp": true}
	normalized["war3map.mmp"] = true
	ma, mb := a.Files["war3map.mmp"], b.Files["war3map.mmp"]
	markerDelta := [2]int{}
	if len(ma) != 24 || len(mb) != 24 || !bytes.Equal(ma[:12], mb[:12]) || !bytes.Equal(ma[20:], mb[20:]) {
		failures = append(failures, "minimap marker identity changed")
	} else {
		for i := 0; i < 2; i++ {
			markerDelta[i] = int(binary.LittleEndian.Uint32(mb[12+i*4:])) - int(binary.LittleEndian.Uint32(ma[12+i*4:]))
			if markerDelta[i] < -1 || markerDelta[i] > 1 {
				failures = append(failures, "minimap marker moved beyond measured rounding")
			}
		}
	}
	changed := map[string]any{}
	for n, v := range a.Files {
		if !bytes.Equal(v, b.Files[n]) {
			changed[n] = map[string]string{"before": Hash(v), "after": Hash(b.Files[n])}
			if !normalized[n] {
				failures = append(failures, "unexpected changed member: "+n)
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
	// The editor increments MapVersion. All editable spatial metadata must survive.
	av, bv := reflect.ValueOf(ai).Elem(), reflect.ValueOf(bi).Elem()
	for i := 0; i < av.NumField(); i++ {
		name := av.Type().Field(i).Name
		if name == "MapVersion" {
			continue
		}
		if !reflect.DeepEqual(av.Field(i).Interface(), bv.Field(i).Interface()) {
			failures = append(failures, "map info changed: "+name)
		}
	}
	// Compare all JASS calls as normalized tokens, permitting decimal formatting,
	// comments and reordered global declarations, but no removed/reordered calls.
	calls := func(raw []byte) []string {
		r := regexp.MustCompile(`(?m)^\s*call\s+[^\r\n]+`)
		ns := regexp.MustCompile(`-?\d+\.\d+`)
		ws := regexp.MustCompile(`\s+`)
		v := r.FindAllString(string(raw), -1)
		for i, line := range v {
			line = ns.ReplaceAllStringFunc(line, func(n string) string { x, _ := strconv.ParseFloat(n, 64); return strconv.FormatFloat(x, 'f', -1, 64) })
			v[i] = ws.ReplaceAllString(line, "")
		}
		return v
	}
	if !slices.Equal(calls(a.Files["war3map.j"]), calls(b.Files["war3map.j"])) {
		failures = append(failures, "compiled calls changed")
	}
	stripComments := regexp.MustCompile(`(?m)^//[^\r\n]*\r?\n`)
	if !bytes.Equal(stripComments.ReplaceAll(a.Files["war3map.wts"], nil), stripComments.ReplaceAll(b.Files["war3map.wts"], nil)) {
		failures = append(failures, "string contents changed")
	}
	g.Map.Terrain = b.Terrain
	g.Map.Doodads = b.Doodads
	var routeErr error
	var nativeRoutes []Route
	if s.Mode == "whole-map-landscape" {
		nativeRoutes, routeErr = nativeLandscapeRoutes(g, landscape, b.Pathing.Cells)
	} else {
		routeErr = checkLocalRoutes(g, plan, b.Pathing.Cells)
	}
	if e := routeErr; e != nil {
		failures = append(failures, "native "+e.Error())
	}
	deep, opened := 0, 0
	for n, f := range b.Pathing.Cells {
		p := cellPoint(g, n)
		z := g.height(p[0], p[1], b.Terrain.Tiles)
		deepTile := true
		x0 := math.Floor((p[0]+12288)/128)*128 - 12288
		y0 := math.Floor((p[1]+4096)/128)*128 - 4096
		for _, d := range [][2]float64{{0, 0}, {128, 0}, {0, 128}, {128, 128}} {
			if g.height(x0+d[0], y0+d[1], b.Terrain.Tiles) >= g.Water-80 {
				deepTile = false
			}
		}
		if z < g.Water-80 && deepTile && !sceneReserved(plan, p[0], p[1]) {
			deep++
			if f&2 == 0 {
				opened++
			}
		}
	}
	if deep == 0 || opened > 0 {
		failures = append(failures, fmt.Sprintf("native deep sea opened: %d/%d", opened, deep))
	}
	transitions := map[string]int{}
	for i, f := range a.Pathing.Cells {
		transitions[fmt.Sprintf("%d->%d", f, b.Pathing.Cells[i])]++
	}
	report := map[string]any{"format": "wc3-native-recompose-audit-v1", "source_sha256": a.Hash, "saved_sha256": b.Hash, "same_terrain": reflect.DeepEqual(a.Terrain, b.Terrain), "same_object_geometry": sameEditorGeometry(a.Doodads, b.Doodads), "max_object_z_roundoff": maxZ, "changed_members": changed, "wpm_transitions": transitions, "deep_sea_cells": deep, "deep_sea_opened": opened, "failures": failures, "passed": len(failures) == 0, "game": "excluded by user", "shadows": "excluded; SHD must remain identical and clear"}
	report["minimap_marker_pixel_delta"] = markerDelta
	if s.Mode == "whole-map-landscape" {
		if nativeLandforms != nil {
			report["native_landforms"] = nativeLandforms
		}
		report["native_routes"] = nativeRoutes
		limits := map[string]int{}
		for _, r := range landscape.Routes {
			limits[r.ID] = nativeLandscapeRouteRadius(g, landscape, r.ID) * 32
		}
		report["route_corridor_tolerance_by_id"] = limits
		report["route_corridor_policy"] = "local structure 128; explicit inter-scene access 256, matching the pre-decoration habitat reserve"
		report["collision_radius"] = 32
	}
	if e := JSON(out, report); e != nil {
		return e
	}
	if len(failures) > 0 {
		return fmt.Errorf("native audit: %v", failures)
	}
	return nil
}
