package terrainproc

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"strings"
)

func (g *Scene) compositionMetadata(parts []doodadsdoo.Doodad) map[string]any {
	c := g.Spec.Waterfall
	origin := [3]float64{c.Source.Min[0] + c.Offset[0], c.Source.Min[1] + c.Offset[1], c.Offset[2]}
	var inlet, outlet *doodadsdoo.Doodad
	local := []map[string]any{}
	for i := range parts {
		d := &parts[i]
		role := "surroundings"
		a := g.Catalog.Assets[d.TypeID]
		if strings.Contains(strings.ToLower(a.Fields["file"]), "waterfall") {
			role = "water"
			if inlet == nil || d.Position[2] > inlet.Position[2] {
				inlet = d
			}
			if outlet == nil || d.Position[0] < outlet.Position[0] {
				outlet = d
			}
		}
		local = append(local, map[string]any{"rawcode": d.TypeID, "role": role, "local_position": [3]float64{float64(d.Position[0]) - origin[0], float64(d.Position[1]) - origin[1], float64(d.Position[2]) - origin[2]}, "rotation": d.Rotation, "scale": d.Scale, "height_policy": "anchor offset with translated terrain support"})
	}
	anchors := map[string]any{"frame_origin": origin}
	if inlet != nil {
		anchors["inlet"] = inlet.Position
	}
	if outlet != nil {
		anchors["outlet"] = outlet.Position
	}
	return map[string]any{"format": "wc3-composition-v1", "source_bounds": c.Source, "offset": c.Offset, "blend": c.Blend, "anchors": anchors, "local_pieces": local, "pieces": parts, "height_policy": "relative to translated terrain support; preserve authored offsets", "water_surface": g.Water, "constraint": "outlet water plane preserved; Z translation rejected"}
}
