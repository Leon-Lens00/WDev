package terrainproc

import (
	"encoding/binary"
	"fmt"
	"image"
	"image/color"
	"math"
	"regexp"
	"strings"

	"github.com/StephenSHorton/wc3-forge/internal/blp"
	"github.com/StephenSHorton/wc3-forge/internal/formats/unitsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3c"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3i"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3r"
)

func rewriteOne(script, pattern, replacement string) (string, error) {
	r := regexp.MustCompile(pattern)
	if len(r.FindAllStringIndex(script, -1)) != 1 {
		return "", fmt.Errorf("expected one script section: %s", pattern)
	}
	return r.ReplaceAllStringFunc(script, func(string) string { return replacement }), nil
}

func recomposeShell(g *Scene, plan Layout) (map[string][]byte, error) {
	m := g.Map
	changes := map[string][]byte{}
	i, e := w3i.Parse(m.Files["war3map.w3i"])
	if e != nil {
		return nil, e
	}
	i.CameraComplements = w3i.IVec4{A: 4, B: 4, C: 4, D: 4}
	x0, y0, x1, y1 := float32(-11776), float32(-3584), float32(11776), float32(7680)
	i.CameraLeftBottom = w3i.Vec2{X: x0 + 512, Y: y0 + 256}
	i.CameraLeftTop = w3i.Vec2{X: x0 + 512, Y: y1 - 256}
	i.CameraRightTop = w3i.Vec2{X: x1 - 512, Y: y1 - 256}
	i.CameraRightBottom = w3i.Vec2{X: x1 - 512, Y: y0 + 256}
	i.PlayableWidth = 184
	i.PlayableHeight = 88
	if len(i.Players) != 1 {
		return nil, fmt.Errorf("tropical shell requires one decorative player")
	}
	i.Players[0].StartingPosition = w3i.Vec2{X: float32(plan.Start[0]), Y: float32(plan.Start[1])}
	changes["war3map.w3i"], e = w3i.Encode(i)
	if e != nil {
		return nil, e
	}
	u, e := unitsdoo.Parse(m.Files["war3mapunits.doo"])
	if e != nil {
		return nil, e
	}
	if len(u.Entities) != 1 || u.Entities[0].TypeID != "sloc" {
		return nil, fmt.Errorf("unannotated source units")
	}
	u.Entities[0].Position = [3]float32{float32(plan.Start[0]), float32(plan.Start[1]), float32(g.height(plan.Start[0], plan.Start[1], m.Terrain.Tiles))}
	changes["war3mapunits.doo"], e = unitsdoo.Encode(u)
	if e != nil {
		return nil, e
	}
	c, e := w3c.Parse(m.Files["war3map.w3c"])
	if e != nil {
		return nil, e
	}
	if len(c.Cameras) != 17 {
		return nil, fmt.Errorf("expected 17 source cameras")
	}
	script := string(m.Files["war3map.j"])
	for n := range c.Cameras {
		cam := &c.Cameras[n]
		q := plan.Placements[n%len(plan.Placements)]
		if g.Spec.Scene != nil {
			id := g.Spec.Scene.Cameras[n]
			found := false
			for _, p := range plan.Placements {
				if p.ID == id {
					q = p
					found = true
					break
				}
			}
			if !found {
				return nil, fmt.Errorf("camera binding missing: %s", id)
			}
		}
		cam.TargetX = float32(q.Center[0])
		cam.TargetY = float32(q.Center[1])
		cam.Distance = 2800
		cam.ZOffset = 160
		if q.ID == "circle" || q.Family == "circle" {
			cam.ZOffset = 80
			cam.Distance = 2000
		}
		// The classic W3C angles are stored in degrees, as evidenced by this template's JASS.
		cam.Rotation = float32(45 + (n/6)*120)
		cam.AngleOfAttack = 315
		cam.FarZ = 10000
		name := fmt.Sprintf("gg_cam_Camera_%03d", n+1)
		for field, v := range map[string]float32{"ZOFFSET": cam.ZOffset, "ROTATION": cam.Rotation, "ANGLE_OF_ATTACK": cam.AngleOfAttack, "TARGET_DISTANCE": cam.Distance, "FARZ": cam.FarZ} {
			pattern := `(?m)^    call CameraSetupSetField\( ` + name + `, CAMERA_FIELD_` + field + `, [^\r\n]+`
			script, e = rewriteOne(script, pattern, fmt.Sprintf("    call CameraSetupSetField( %s, CAMERA_FIELD_%s, %.3f, 0.0 )", name, field, v))
			if e != nil {
				return nil, e
			}
		}
		script, e = rewriteOne(script, `(?m)^    call CameraSetupSetDestPosition\( `+name+`, [^\r\n]+`, fmt.Sprintf("    call CameraSetupSetDestPosition( %s, %.3f, %.3f, 0.0 )", name, cam.TargetX, cam.TargetY))
		if e != nil {
			return nil, e
		}
	}
	changes["war3map.w3c"], e = w3c.Encode(c)
	if e != nil {
		return nil, e
	}
	if raw, ok := m.Files["war3map.w3r"]; ok {
		r, e := w3r.Parse(raw)
		if e != nil {
			return nil, e
		}
		if len(r.Regions) != 0 {
			return nil, fmt.Errorf("source regions require explicit spatial annotation")
		}
	}
	script, e = rewriteOne(script, `(?m)^    call DefineStartLocation\( 0, [^\r\n]+`, fmt.Sprintf("    call DefineStartLocation( 0, %.3f, %.3f )", plan.Start[0], plan.Start[1]))
	if e != nil {
		return nil, e
	}
	script, e = rewriteOne(script, `(?m)^    call SetCameraBounds\( [^\r\n]+`, fmt.Sprintf("    call SetCameraBounds( %.1f + GetCameraMargin(CAMERA_MARGIN_LEFT), %.1f + GetCameraMargin(CAMERA_MARGIN_BOTTOM), %.1f - GetCameraMargin(CAMERA_MARGIN_RIGHT), %.1f - GetCameraMargin(CAMERA_MARGIN_TOP), %.1f + GetCameraMargin(CAMERA_MARGIN_LEFT), %.1f - GetCameraMargin(CAMERA_MARGIN_TOP), %.1f - GetCameraMargin(CAMERA_MARGIN_RIGHT), %.1f + GetCameraMargin(CAMERA_MARGIN_BOTTOM) )", x0, y0, x1, y1, x0, y1, x1, y0))
	if e != nil {
		return nil, e
	}
	// GUI triggers reference the existing named cameras. Their editable sources stay unchanged;
	// World Editor regenerates CreateCameras/config/main from W3C, Units.doo and W3I.
	changes["war3map.j"] = []byte(script)
	changes["war3mapmap.blp"], e = recomposeMinimap(g)
	if e != nil {
		return nil, e
	}
	mmp := append([]byte{}, m.Files["war3map.mmp"]...)
	if len(mmp) != 24 || binary.LittleEndian.Uint32(mmp[4:]) != 1 || binary.LittleEndian.Uint32(mmp[8:]) != 2 {
		return nil, fmt.Errorf("unannotated minimap icons")
	}
	px, py := minimapPoint(plan.Start[0], plan.Start[1])
	binary.LittleEndian.PutUint32(mmp[12:], uint32(math.Round(px)))
	binary.LittleEndian.PutUint32(mmp[16:], uint32(math.Round(py)))
	changes["war3map.mmp"] = mmp
	return changes, nil
}

func minimapPoint(x, y float64) (float64, float64) {
	return (x + 11776) / 23552 * 255, (256-11264./23552*256)/2 + (7680-y)/23552*255
}

func recomposeMinimap(g *Scene) ([]byte, error) {
	img := image.NewRGBA(image.Rect(0, 0, 256, 256))
	palette := []color.RGBA{{115, 107, 72, 255}, {130, 117, 78, 255}, {89, 106, 60, 255}, {171, 157, 100, 255}, {143, 135, 92, 255}, {107, 118, 111, 255}, {62, 97, 55, 255}, {92, 110, 65, 255}, {54, 99, 42, 255}}
	for py := 0; py < 256; py++ {
		for px := 0; px < 256; px++ {
			pad := (256 - 11264./23552*256) / 2
			if float64(py) < pad || float64(py) > 256-pad {
				img.SetRGBA(px, py, color.RGBA{0, 0, 0, 255})
				continue
			}
			x := -11776 + float64(px)/255*23552
			y := 7680 - (float64(py)-pad)/255*23552
			i := g.index(x, y)
			t := g.Map.Terrain.Tiles[i]
			z := float64(t.FinalZ())
			c := palette[int(t.GroundTexture)%len(palette)]
			if z < g.Water {
				c = color.RGBA{38, 104, 114, 255}
				if z > g.Water-60 {
					c = color.RGBA{66, 126, 126, 255}
				}
			} else {
				f := min(1.25, .8+z/1500)
				c.R = uint8(math.Min(255, float64(c.R)*f))
				c.G = uint8(math.Min(255, float64(c.G)*f))
				c.B = uint8(math.Min(255, float64(c.B)*f))
			}
			img.SetRGBA(px, py, c)
		}
	}
	for _, d := range g.Map.Doodads.Doodads {
		if strings.HasPrefix(d.TypeID, "B00") {
			x, y := minimapPoint(float64(d.Position[0]), float64(d.Position[1]))
			px, py := int(x), int(y)
			if image.Pt(px, py).In(img.Bounds()) {
				img.SetRGBA(px, py, color.RGBA{34, 80, 30, 255})
			}
		}
	}
	return blp.Encode(img)
}
