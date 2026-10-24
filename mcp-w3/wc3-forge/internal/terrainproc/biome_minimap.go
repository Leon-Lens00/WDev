package terrainproc

import (
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/blp"
	"image"
	"image/color"
	"math"
	"slices"
)

func materialMinimap(g *Scene, q MaterialRepaint) ([]byte, error) {
	if q.Format == "wc3-material-repaint-v1" || q.MinimapStyle == "tropical-v1" {
		if e := checkMaterialMap(g.Map); e != nil {
			return nil, e
		}
		return recomposeMinimap(g)
	}
	if q.MinimapStyle != "" && q.MinimapStyle != "profile-v1" {
		return nil, fmt.Errorf("unknown minimap policy")
	}
	p, e := loadMaterialProfile(q.Materials)
	if e != nil {
		return nil, e
	}
	return biomeMinimap(g.Map, p)
}

// Aspect-correct diagnostic minimap. Real ground decisions come from the W3E,
// not this palette of representative display colours.
func biomeMinimap(m *Map, p MaterialProfile) ([]byte, error) {
	if p.Rules == nil {
		return nil, fmt.Errorf("profile minimap requires v2 rules")
	}
	for _, id := range m.Terrain.GroundTilesets {
		if _, ok := p.Colors[id]; !ok {
			return nil, fmt.Errorf("missing minimap colour for %s", id)
		}
	}
	img := image.NewRGBA(image.Rect(0, 0, 256, 256))
	w, h := int(m.Terrain.Width), int(m.Terrain.Height)
	extent := float64(max(w-1, h-1))
	sx, sy := float64(w-1)/extent*256, float64(h-1)/extent*256
	px, py := (256-sx)/2, (256-sy)/2
	for y := 0; y < 256; y++ {
		for x := 0; x < 256; x++ {
			c := color.RGBA{0, 0, 0, 255}
			xx, yy := (float64(x)-px)/sx, (float64(y)-py)/sy
			if xx >= 0 && yy >= 0 && xx < 1 && yy < 1 {
				col, row := int(xx*float64(w-1)), int((1-yy)*float64(h-1))
				t := m.Terrain.Tiles[col+min(h-1, row)*w]
				v := p.Colors[m.Terrain.GroundTilesets[t.GroundTexture]]
				c = color.RGBA{v[0], v[1], v[2], 255}
				if landscapeWet(t, p.WaterOffset) {
					c = color.RGBA{42, 94, 112, 255}
				}
			}
			img.SetRGBA(x, y, c)
		}
	}
	for _, d := range m.Doodads.Doodads {
		if slices.Contains(p.Rules.Trees, d.TypeID) {
			x := int(math.Round(px + (float64(d.Position[0])-float64(m.Terrain.CenterOffset[0]))/(extent*128)*256))
			y := int(math.Round(py + sy - (float64(d.Position[1])-float64(m.Terrain.CenterOffset[1]))/(extent*128)*256))
			if image.Pt(x, y).In(img.Bounds()) {
				img.SetRGBA(x, y, color.RGBA{30, 70, 32, 255})
			}
		}
	}
	return blp.Encode(img)
}
