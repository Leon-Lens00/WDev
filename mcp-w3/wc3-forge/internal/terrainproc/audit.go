package terrainproc

import (
	"bytes"
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"math"
	"path/filepath"
	"reflect"
)

func Audit(source, target, out string) error {
	a, e := Load(source)
	if e != nil {
		return e
	}
	b, e := Load(target)
	if e != nil {
		return e
	}
	changes := map[string]any{}
	for n, v := range a.Files {
		if !bytes.Equal(v, b.Files[n]) {
			changes[n] = map[string]any{"before": Hash(v), "after": Hash(b.Files[n]), "bytes_before": len(v), "bytes_after": len(b.Files[n])}
		}
	}
	for n, v := range b.Files {
		if _, ok := a.Files[n]; !ok {
			changes[n] = map[string]any{"added": Hash(v)}
		}
	}
	return JSON(out, map[string]any{"source_sha256": a.Hash, "target_sha256": b.Hash, "changes": changes, "same_terrain": reflect.DeepEqual(a.Terrain, b.Terrain), "same_doodads": reflect.DeepEqual(a.Doodads, b.Doodads), "same_editor_geometry": sameEditorGeometry(a.Doodads, b.Doodads)})
}
func Bake(s Spec, generated, editor, out string) error {
	a, e := Load(generated)
	if e != nil {
		return e
	}
	b, e := Load(editor)
	if e != nil {
		return e
	}
	if !bytes.Equal(a.Files["war3map.w3e"], b.Files["war3map.w3e"]) || !sameEditorGeometry(a.Doodads, b.Doodads) {
		return fmt.Errorf("editor geometry differs; audit normalization before baking")
	}
	shd := append([]byte{}, a.Files["war3map.shd"]...)
	native := b.Files["war3map.shd"]
	if len(shd) != len(native) || len(shd) != len(a.Pathing.Cells) {
		return fmt.Errorf("invalid editor shadow layer")
	}
	changed := 0
	for i := range shd {
		x := float64(a.Terrain.CenterOffset[0]) + float64(i%a.Pathing.Width)*32 + 16
		y := float64(a.Terrain.CenterOffset[1]) + float64(i/a.Pathing.Width)*32 + 16
		if s.Editable(x, y) {
			if shd[i] != native[i] {
				changed++
			}
			shd[i] = native[i]
		}
	}
	if changed == 0 {
		return fmt.Errorf("no new shadow evidence: editor bake not detected")
	}
	updates := map[string][]byte{"war3map.shd": shd}
	if v := b.Files["war3mapmap.blp"]; len(v) > 0 {
		updates["war3mapmap.blp"] = v
	}
	if e = a.Write(out, updates); e != nil {
		return e
	}
	result, e := Load(out)
	if e != nil {
		return e
	}
	return JSON(filepath.Join(filepath.Dir(out), "bake.json"), map[string]any{"format": "wc3-editor-bake-v1", "input_sha256": a.Hash, "editor_copy_sha256": b.Hash, "output_sha256": result.Hash, "shadow_cells_updated": changed, "method": "World Editor 1.27b Calculate shadows and save; merge within editable region", "outside_edit_preserved": true})
}

// Classic editor recalculates Z with tiny float roundoff and may reorder records.
// Only that measured normalization is accepted; the generated DOO itself is preserved.
func sameEditorGeometry(a, b *doodadsdoo.File) bool {
	if len(a.Doodads) != len(b.Doodads) {
		return false
	}
	byID := map[uint32]doodadsdoo.Doodad{}
	for _, d := range b.Doodads {
		if _, exists := byID[d.CreationNumber]; exists {
			return false
		}
		byID[d.CreationNumber] = d
	}
	for _, d := range a.Doodads {
		q, ok := byID[d.CreationNumber]
		if !ok || math.Abs(float64(d.Position[2]-q.Position[2])) > .002 {
			return false
		}
		q.Position[2] = d.Position[2]
		if !reflect.DeepEqual(d, q) {
			return false
		}
	}
	aa, bb := *a, *b
	aa.Doodads = nil
	bb.Doodads = nil
	return reflect.DeepEqual(aa, bb)
}
