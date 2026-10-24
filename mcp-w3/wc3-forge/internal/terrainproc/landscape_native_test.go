package terrainproc

import (
	"os"
	"path/filepath"
	"testing"
)

// Optional real-editor regression, never launches the game or synthesizes a save.
func TestLandscapeNativeRoutes(t *testing.T) {
	native := os.Getenv("WC3_LANDSCAPE_NATIVE")
	if native == "" {
		t.Skip("real native save required")
	}
	s := landscapeTestSpec(t)
	g, _, _, p, _, _, e := buildLandscapeBase(s)
	if e != nil {
		t.Fatal(e)
	}
	m, e := Load(native)
	if e != nil {
		t.Fatal(e)
	}
	g.Map.Terrain = m.Terrain
	g.Map.Doodads = m.Doodads
	blocked := combinedRecompose(g, m.Pathing.Cells)
	diagnostics := []any{}
	for _, r := range p.Routes {
		bad := [][2]float64{}
		for _, xy := range r.Trace {
			if blocked[pathCell(g, xy)] {
				bad = append(bad, xy)
			}
		}
		actual := [][2]float64{}
		var failure string
		for n := 1; n < len(r.Points); n++ {
			a, b := nearestFree(g, blocked, r.Points[n-1], 256), nearestFree(g, blocked, r.Points[n], 256)
			path, err := gridPath(g, blocked, a, b, g.Spec.Edit)
			if err != nil {
				failure = err.Error()
			}
			for _, i := range path {
				actual = append(actual, cellPoint(g, i))
			}
		}
		diagnostics = append(diagnostics, map[string]any{"id": r.ID, "bad": bad, "native_unrestricted_trace": actual, "error": failure, "generated": r.Trace})
	}
	if out := os.Getenv("WC3_LANDSCAPE_DIAGNOSTICS"); out != "" {
		_ = JSON(filepath.Join(out, "native-routes-diagnostic.json"), diagnostics)
		_ = JSON(filepath.Join(out, "native-blocked.json"), map[string]any{"blocked": blocked, "generated": combinedRecompose(g, staticLandscapePathing(g)), "width": g.Map.Pathing.Width, "height": g.Map.Pathing.Height, "cells": m.Pathing.Cells, "static": staticLandscapePathing(g)})
	}
	if _, e := nativeLandscapeRoutes(g, p, m.Pathing.Cells); e != nil {
		t.Fatal(e)
	}
}
