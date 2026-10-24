package terrainproc

import (
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strings"
)

// Test-only script. Delivery maps keep the template's editable triggers and script intact.
func Harness(s Spec, path, out string) error {
	m, e := Load(path)
	if e != nil {
		return e
	}
	script := string(m.Files["war3map.j"])
	if strings.Contains(script, "TP_Test") || !strings.Contains(script, "function main takes nothing returns nothing") {
		return fmt.Errorf("unsupported harness script")
	}
	globals := `    unit TP_TestWalker = null
    unit TP_TestWorker = null
    destructable TP_TestTree = null
    real array TP_TestX
    real array TP_TestY
    integer TP_TestIndex = 1
    integer TP_TestTicks = 0
    integer TP_TestCount = 0
    boolean TP_TestRoute = false
    boolean TP_TestHarvest = false
    real TP_TestTreeLife = 0.
`
	script = strings.Replace(script, "endglobals", globals+"endglobals", 1)
	var treeX, treeY, spawnX, spawnY float64
	best := math.Inf(1)
	for _, d := range m.Doodads.Doodads {
		x, y := float64(d.Position[0]), float64(d.Position[1])
		if d.TypeID == "B000" && s.Editable(x, y) {
			distance := s.PathDistance(x, y)
			if distance < best {
				best = distance
				treeX = x
				treeY = y
			}
		}
	}
	if math.IsInf(best, 1) {
		return fmt.Errorf("no imported test tree")
	}
	near := s.Path[0]
	for _, p := range s.Path {
		if math.Hypot(treeX-p[0], treeY-p[1]) < math.Hypot(treeX-near[0], treeY-near[1]) {
			near = p
		}
	}
	length := math.Hypot(near[0]-treeX, near[1]-treeY)
	spawnX = treeX + (near[0]-treeX)/length*180
	spawnY = treeY + (near[1]-treeY)/length*180
	code := fmt.Sprintf(`
function TP_TestFindTree takes nothing returns nothing
    local destructable d = GetEnumDestructable()
    if GetDestructableTypeId(d) == 'B000' and RAbsBJ(GetDestructableX(d)-%.5f)<1. and RAbsBJ(GetDestructableY(d)-%.5f)<1. then
        set TP_TestTree = d
    endif
    set d = null
endfunction
function TP_TestLog takes string message returns nothing
    call DisplayTimedTextToPlayer(Player(0),0.,0.,120.,message)
    call Preload(message)
endfunction
function TP_TestTick takes nothing returns nothing
    local real dx
    local real dy
    set TP_TestTicks = TP_TestTicks + 1
    if not TP_TestRoute then
        set dx = GetUnitX(TP_TestWalker)-TP_TestX[TP_TestIndex]
        set dy = GetUnitY(TP_TestWalker)-TP_TestY[TP_TestIndex]
        if dx*dx+dy*dy < 4096. then
            call TP_TestLog("WAYPOINT " + I2S(TP_TestIndex) + " reached x=" + R2S(GetUnitX(TP_TestWalker)) + " y=" + R2S(GetUnitY(TP_TestWalker)))
            set TP_TestIndex = TP_TestIndex+1
            if TP_TestIndex == TP_TestCount then
                set TP_TestRoute = true
                call TP_TestLog("ROUTE PASS")
            else
                call IssuePointOrder(TP_TestWalker,"move",TP_TestX[TP_TestIndex],TP_TestY[TP_TestIndex])
            endif
        endif
    endif
    if not TP_TestHarvest and GetDestructableLife(TP_TestTree) < TP_TestTreeLife then
        set TP_TestHarvest = true
        call TP_TestLog("HARVEST PASS imported B000 life="+R2S(GetDestructableLife(TP_TestTree)))
    endif
    if TP_TestTicks == 150 or TP_TestRoute and TP_TestHarvest then
        if not TP_TestRoute then
            call TP_TestLog("ROUTE FAIL waypoint="+I2S(TP_TestIndex)+" x="+R2S(GetUnitX(TP_TestWalker))+" y="+R2S(GetUnitY(TP_TestWalker)))
        endif
        if not TP_TestHarvest then
            call TP_TestLog("HARVEST FAIL order="+I2S(GetUnitCurrentOrder(TP_TestWorker)))
        endif
        call PreloadGenEnd("TerrainProc-12700.pld")
        call PauseTimer(GetExpiredTimer())
        call DestroyTimer(GetExpiredTimer())
        call SetCameraPosition(-1400.,2900.)
        call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,3200.,0.)
        call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK,320.,0.)
    endif
endfunction
function TP_TestStart takes nothing returns nothing
    local rect r = GetWorldBounds()
    call PreloadGenClear()
    call PreloadGenStart()
    call EnumDestructablesInRect(r,null,function TP_TestFindTree)
    call RemoveRect(r)
    set TP_TestTreeLife = GetDestructableLife(TP_TestTree)
    set TP_TestWorker = CreateUnit(Player(0),'hpea',%.5f,%.5f,0.)
    call IssueTargetOrder(TP_TestWorker,"harvest",TP_TestTree)
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY,12.)
    call SetTimeOfDayScale(0.)
    call ResetToGameCamera(0.)
    call SetCameraPosition(1200.,2400.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,3400.,0.)
`, treeX, treeY, spawnX, spawnY)
	for i, p := range s.Path {
		code += fmt.Sprintf("    set TP_TestX[%d] = %.5f\n    set TP_TestY[%d] = %.5f\n", i, p[0], i, p[1])
	}
	code += fmt.Sprintf(`    set TP_TestCount = %d
    set TP_TestWalker = CreateUnit(Player(0),'hfoo',TP_TestX[0],TP_TestY[0],90.)
    call SetUnitMoveSpeed(TP_TestWalker,300.)
    call SelectUnit(TP_TestWalker,true)
    call TP_TestLog("TERRAINPROC 12700 START tree-life="+R2S(TP_TestTreeLife))
    call IssuePointOrder(TP_TestWalker,"move",TP_TestX[1],TP_TestY[1])
    call TimerStart(CreateTimer(),0.2,true,function TP_TestTick)
    set r = null
endfunction

`, len(s.Path))
	// Derive test presentation and timeout from this scene, not the old extension.
	length = 0
	for i := 1; i < len(s.Path); i++ {
		length += math.Hypot(s.Path[i][0]-s.Path[i-1][0], s.Path[i][1]-s.Path[i-1][1])
	}
	limit := max(150, int(math.Ceil((length/250+15)/.2)))
	code = strings.ReplaceAll(code, "TP_TestTicks == 150", fmt.Sprintf("TP_TestTicks == %d", limit))
	code = strings.ReplaceAll(code, "TerrainProc-12700.pld", fmt.Sprintf("TerrainProc-%d.pld", s.Seed))
	code = strings.ReplaceAll(code, "TERRAINPROC 12700 START", fmt.Sprintf("TERRAINPROC %d START", s.Seed))
	cx := (s.Waterfall.Source.Min[0]+s.Waterfall.Source.Max[0])/2 + s.Waterfall.Offset[0]
	cy := (s.Waterfall.Source.Min[1]+s.Waterfall.Source.Max[1])/2 + s.Waterfall.Offset[1]
	code = strings.ReplaceAll(code, "SetCameraPosition(-1400.,2900.)", fmt.Sprintf("SetCameraPosition(%.5f,%.5f)", cx, cy))
	code = strings.ReplaceAll(code, "SetCameraPosition(1200.,2400.)", fmt.Sprintf("SetCameraPosition(%.5f,%.5f)", s.Path[0][0], s.Path[0][1]))
	script = strings.Replace(script, "function main takes nothing returns nothing", code+"function main takes nothing returns nothing", 1)
	script = strings.Replace(script, "call RunInitializationTriggers(  )", "call RunInitializationTriggers(  )\n    call TimerStart(CreateTimer(),1.,false,function TP_TestStart)", 1)
	if e = m.Write(out, map[string][]byte{"war3map.j": []byte(script)}); e != nil {
		return e
	}
	return os.WriteFile(filepath.Join(filepath.Dir(out), "harness.j"), []byte(script), 0644)
}
