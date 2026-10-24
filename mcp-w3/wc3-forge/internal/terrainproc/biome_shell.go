package terrainproc

import (
	"encoding/binary"
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/unitsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3i"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wct"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wtg"
	"math"
	"os"
)

func readBiomeBytes(path string) ([]byte, error) { return os.ReadFile(path) }
func biomeShell(g *Scene, q BiomeRecipe, p BiomeProfile, seed int) (map[string][]byte, error) {
	m := g.Map
	c := map[string][]byte{}
	start := biomeWorld(q, q.Start)
	b := biomeBounds(q)
	i, e := w3i.Parse(m.Files["war3map.w3i"])
	if e != nil {
		return nil, e
	}
	i.FileVersion = 25
	i.MapVersion = 1
	i.EditorVersion = 6059
	i.Name = fmt.Sprintf("%s %d", q.ID, seed)
	i.Author = "Terrain demonstration; source landscape: Blizzard Entertainment"
	i.Description = "Generated Classic terrain demonstration. Source: " + p.ID + ". Geography and decoration only; no melee logic or gameplay validation."
	i.SuggestedPlayers = "Terrain preview"
	i.Flags = w3i.DecodeFlags(0x1800 | 0x4000)
	i.CameraComplements = w3i.IVec4{A: 4, B: 4, C: 4, D: 4}
	x0, y0, x1, y1 := float32(b.Min[0]+1024), float32(b.Min[1]+768), float32(b.Max[0]-1024), float32(b.Max[1]-768)
	i.CameraLeftBottom = w3i.Vec2{X: x0, Y: y0}
	i.CameraLeftTop = w3i.Vec2{X: x0, Y: y1}
	i.CameraRightTop = w3i.Vec2{X: x1, Y: y1}
	i.CameraRightBottom = w3i.Vec2{X: x1, Y: y0}
	i.PlayableWidth = int32(q.Geometry.Width - 9)
	i.PlayableHeight = int32(q.Geometry.Height - 9)
	i.Players = []w3i.Player{{InternalNumber: 0, Type: w3i.PlayerHuman, Race: w3i.RaceSelectable, FixedStartPosition: 1, Name: "Observer", StartingPosition: w3i.Vec2{X: float32(start[0]), Y: float32(start[1])}}}
	i.Forces = []w3i.Force{{PlayerMasks: 1, Name: "Terrain"}}
	i.AvailableUpgrades = nil
	i.AvailableTech = nil
	i.RandomUnitTables = nil
	i.RandomItemTables = nil
	i.LoadingScreen = w3i.LoadingScreen{Number: -1}
	i.Prologue = w3i.Prologue{}
	i.Fog = w3i.Fog{}
	i.WeatherID = 0
	i.CustomSoundEnv = ""
	i.CustomLightTileset = m.Terrain.Tileset
	i.WaterColor = w3i.Color{R: 255, G: 255, B: 255, A: 255}
	c["war3map.w3i"], e = w3i.Encode(i)
	if e != nil {
		return nil, e
	}
	u, e := unitsdoo.Parse(m.Files["war3mapunits.doo"])
	if e != nil {
		return nil, e
	}
	found := false
	for _, d := range u.Entities {
		if d.TypeID == "sloc" {
			d.Player = 0
			d.Position = [3]float32{float32(start[0]), float32(start[1]), float32(g.height(start[0], start[1], m.Terrain.Tiles))}
			d.CreationNumber = 0
			u.Entities = []unitsdoo.Entity{d}
			found = true
			break
		}
	}
	if !found {
		return nil, fmt.Errorf("source has no Classic start prototype")
	}
	c["war3mapunits.doo"], e = unitsdoo.Encode(u)
	if e != nil {
		return nil, e
	}
	triggers := &wtg.Triggers{IsPre131: true, PreMagic: true, Version: 7, TrigDefVer: 2, PreCategoryUnknown: 2}
	c["war3map.wtg"], e = wtg.Encode(triggers, nil)
	if e != nil {
		return nil, e
	}
	c["war3map.wct"], e = wct.Encode(&wct.File{IsPre131: true, Version: 1}, triggers)
	if e != nil {
		return nil, e
	}
	c["war3map.w3c"] = make([]byte, 8)
	c["war3map.w3r"] = make([]byte, 8)
	binary.LittleEndian.PutUint32(c["war3map.w3r"], 5)
	c["war3map.w3s"] = make([]byte, 8)
	binary.LittleEndian.PutUint32(c["war3map.w3s"], 1)
	c["war3map.mmp"] = make([]byte, 24)
	binary.LittleEndian.PutUint32(c["war3map.mmp"][4:], 1)
	binary.LittleEndian.PutUint32(c["war3map.mmp"][8:], 2)
	spanX, spanY := float64(q.Geometry.Width-9)*128, float64(q.Geometry.Height-9)*128
	span := max(spanX, spanY)
	px := (256-spanX/span*256)/2 + (start[0]-float64(q.Geometry.Origin[0])-512)/span*255
	py := (256-spanY/span*256)/2 + (float64(q.Geometry.Origin[1])+float64(q.Geometry.Height-1)*128-512-start[1])/span*255
	binary.LittleEndian.PutUint32(c["war3map.mmp"][12:], uint32(math.Round(px)))
	binary.LittleEndian.PutUint32(c["war3map.mmp"][16:], uint32(math.Round(py)))
	binary.LittleEndian.PutUint32(c["war3map.mmp"][20:], 0xffff0303)
	// Remove stale generated scenario cache; imported models and definitions stay.
	for _, name := range []string{"war3map.w3f", "war3map.w3v", "war3map.wai", "war3mapmisc.txt", "war3mapextra.txt", "war3map.wts", "war3mappreview.tga", "war3mapmap.b00"} {
		delete(m.Files, name)
		delete(m.Names, name)
	}
	c["war3map.j"] = []byte(fmt.Sprintf(`globals
endglobals
function main takes nothing returns nothing
    call SetCameraBounds( %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f )
    call InitBlizzard()
endfunction
function config takes nothing returns nothing
    call SetMapName( "%s" )
    call SetMapDescription( "Terrain demonstration" )
    call SetPlayers( 1 )
    call SetTeams( 1 )
    call SetGamePlacement( MAP_PLACEMENT_USE_MAP_SETTINGS )
    call DefineStartLocation( 0, %.3f, %.3f )
    call SetPlayerStartLocation( Player(0), 0 )
    call SetPlayerController( Player(0), MAP_CONTROL_USER )
    call SetPlayerRaceSelectable( Player(0), true )
    call InitGenericPlayerSlots()
endfunction
`, x0, y0, x1, y1, x0, y1, x1, y0, q.ID, start[0], start[1]))
	m.Header = make([]byte, 512)
	copy(m.Header, []byte("HM3W"))
	copy(m.Header[8:], []byte(i.Name))
	k := 9 + len(i.Name)
	binary.LittleEndian.PutUint32(m.Header[k:], i.Flags.Raw)
	binary.LittleEndian.PutUint32(m.Header[k+4:], 1)
	return c, nil
}
