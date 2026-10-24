package main

import (
	"reflect"
	"testing"
)

func TestCliffAliasUsesMapPaletteSlot(t *testing.T) {
	palettes := []string{"TerrainArt\\Ruins\\Ruins_Dirt", "TerrainArt\\Ruins\\Ruins_Brick"}
	for _, ext := range []string{".tga", ".dds", ".blp"} {
		got := cliffAliasCandidates("replaceabletextures/cliff/cliff1"+ext, palettes)
		want := []string{"terrainart/ruins/ruins_brick.blp", "terrainart/ruins/ruins_brick.dds"}
		if !reflect.DeepEqual(got, want) {
			t.Fatalf("%s: %v", ext, got)
		}
	}
	for _, name := range []string{"replaceabletextures/cliff/cliff2.dds", "custom/cliff0.dds", "replaceabletextures/cliff/cliff0.mdx"} {
		if len(cliffAliasCandidates(name, palettes)) > 0 {
			t.Fatalf("unrelated asset remapped: %s", name)
		}
	}
	if len(cliffAliasCandidates("replaceabletextures/cliff/cliff1.dds", palettes[:1])) > 0 {
		t.Fatal("missing palette slot must not silently use slot zero")
	}
}
