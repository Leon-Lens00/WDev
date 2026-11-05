"""Puente de prueba de la oleada (Dev Mission v12m, 31/10/2026). NO integrar.

Anade al puente de botones un registro de enemigos cada segundo y una mira sobre la unidad enemiga mas cercana al personaje.
Uso: puente_oleada.py IN_J OUT_J CELDA
"""
from pathlib import Path
import subprocess
import sys

S = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(S))
import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/oleada_v12m/puente_oleada.py).
integer Ole_Paso = 0
group Ole_G = null
'''
FUNCS = '''// TEMPORARY test bridge (scripts/oleada_v12m/puente_oleada.py).
// Keeps the character alive so that chasing and the return to camp can be watched; 12 units kill it in 5 s otherwise.
function Ole_Cura takes nothing returns nothing
    if Game_Hero[0] != null and GetWidgetLife(Game_Hero[0]) > 0.405 then
        call SetWidgetLife(Game_Hero[0], 90.)
    endif
endfunction

function Ole_Timer takes nothing returns nothing
    local unit h = Game_Hero[0]
    local unit c = Game_Ctrl[0]
    local unit u
    local unit near = null
    local integer o = 8
    local integer n = 0
    local integer lejos = 0
    local real d
    local real best = 999999.
    local string s = ""
    if h == null then
        return
    endif
    set Ole_Paso = Ole_Paso + 1
    if Ole_G == null then
        set Ole_G = CreateGroup()
    endif
    loop
        exitwhen o > 13
        call GroupEnumUnitsOfPlayer(Ole_G, Player(o), null)
        loop
            set u = FirstOfGroup(Ole_G)
            exitwhen u == null
            call GroupRemoveUnit(Ole_G, u)
            if GetWidgetLife(u) > 0.405 and u != Sonda_Blanco then
                set n = n + 1
                set d = SquareRoot((GetUnitX(u) - GetUnitX(h)) * (GetUnitX(u) - GetUnitX(h)) + (GetUnitY(u) - GetUnitY(h)) * (GetUnitY(u) - GetUnitY(h)))
                if d < best then
                    set best = d
                    set near = u
                endif
                if (GetUnitX(u) - GetUnitX(c)) * (GetUnitX(u) - GetUnitX(c)) + (GetUnitY(u) - GetUnitY(c)) * (GetUnitY(u) - GetUnitY(c)) < d * d then
                    set lejos = lejos + 1
                endif
            endif
        endloop
        set o = o + 1
    endloop
    set s = "ole " + I2S(Ole_Paso) + " vivos " + I2S(n) + " cerca " + I2S(R2I(best)) + " haciaCtrl " + I2S(lejos) + " vida " + I2S(R2I(GetWidgetLife(h))) + " ctrlvida " + I2S(R2I(GetWidgetLife(c)))
    if near != null then
        set s = s + " tipo " + GetUnitName(near) + " orden " + I2S(GetUnitCurrentOrder(near)) + " dueno " + I2S(GetPlayerId(GetOwningPlayer(near)))
    endif
    call Sonda_Log(s)
    if Ole_Paso == 90 then
        call DestroyTimer(GetExpiredTimer())
    endif
    set near = null
    set h = null
    set c = null
endfunction

'''

if __name__ == '__main__':
    j_in, j_out, celda = sys.argv[1:4]
    subprocess.run([sys.executable, str(S / 'puente_botones_v12k.py'), j_in, j_out, celda], check=True, cwd=S)
    s = Path(j_out).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function Puente_Juego takes nothing returns nothing\n', FUNCS + 'function Puente_Juego takes nothing returns nothing\n')
    s = base.once(s, '    call TimerStart(CreateTimer(), 1., true, function Sonda_Timer)\n',
                  '    call TimerStart(CreateTimer(), 1., true, function Sonda_Timer)\n'
                  '    call TimerStart(CreateTimer(), 1., true, function Ole_Timer)\n'
                  '    call TimerStart(CreateTimer(), 0.1, true, function Ole_Cura)\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
