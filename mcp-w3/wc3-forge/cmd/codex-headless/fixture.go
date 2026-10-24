package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/unitsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3i"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3objmod"
)

// This fixture tests file editing only. It deliberately has no gameplay script,
// stock archive, or claim of being a World Editor/game-validated map.
func writeFixture(path string) error {
	if _, err := os.Stat(path); !os.IsNotExist(err) {
		return fmt.Errorf("fixture destination already exists or is inaccessible: %s", path)
	}
	if err := os.MkdirAll(path, 0755); err != nil {
		return err
	}
	write := func(name string, data []byte, err error) error {
		if err != nil {
			return err
		}
		return os.WriteFile(filepath.Join(path, name), data, 0644)
	}
	info := &w3i.Info{
		FileVersion: w3i.FileVersionTFT, MapVersion: 1, EditorVersion: 1,
		Name: "MCP integration probe - not a playable map", Author: "Codex / wc3-forge",
		Description:      "Technical import and round-trip test. No gameplay script or native validation.",
		SuggestedPlayers: "1", Tileset: 'L', PlayableWidth: 32, PlayableHeight: 32,
		CameraLeftBottom: w3i.Vec2{X: -2048, Y: -2048}, CameraRightTop: w3i.Vec2{X: 2048, Y: 2048},
		CameraLeftTop: w3i.Vec2{X: -2048, Y: 2048}, CameraRightBottom: w3i.Vec2{X: 2048, Y: -2048},
		LoadingScreen: w3i.LoadingScreen{Number: -1}, CustomLightTileset: 'L',
		WaterColor: w3i.Color{R: 255, G: 255, B: 255, A: 255},
		Players:    []w3i.Player{{InternalNumber: 0, Type: w3i.PlayerHuman, Race: w3i.RaceSelectable, Name: "Player 1"}},
		Forces:     []w3i.Force{{PlayerMasks: 1, Name: "Force 1"}},
	}
	b, e := w3i.Encode(info)
	if err := write("war3map.w3i", b, e); err != nil {
		return err
	}
	tiles := make([]w3e.Tilepoint, 33*33)
	for i := range tiles {
		tiles[i] = w3e.Tilepoint{GroundHeight: 0x2000, LayerHeight: 2}
	}
	terrain := &w3e.File{Format: w3e.Magic, Version: 11, Tileset: 'L', GroundTilesets: []string{"Ldrt"}, CliffTilesets: []string{"CLdi"}, Width: 33, Height: 33, CenterOffset: [2]float32{-2048, -2048}, Tiles: tiles}
	b, e = w3e.Encode(terrain)
	if err := write("war3map.w3e", b, e); err != nil {
		return err
	}
	b, e = unitsdoo.Encode(&unitsdoo.File{Version: 8, SubVersion: 9})
	if err := write("war3mapUnits.doo", b, e); err != nil {
		return err
	}
	b, e = doodadsdoo.Encode(&doodadsdoo.File{Version: 8, SubVersion: 9})
	if err := write("war3map.doo", b, e); err != nil {
		return err
	}
	// Seed v2 explicitly: the editor's default fresh object table is v3.
	b, e = w3objmod.Encode(&w3objmod.File{Version: 2}, false, nil)
	return write("war3map.w3u", b, e)
}
