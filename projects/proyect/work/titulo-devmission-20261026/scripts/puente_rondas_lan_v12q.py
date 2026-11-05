"""Puente de prueba LAN de las rondas (Dev Mission v12q, 31/10/2026). NO integrar.

Dos jugadores, A Tauren y B Cairne, 1 vida cada uno, 2 rondas y 8 s de descanso. Los golpes salen de timers iguales en ambos clientes.
Ronda 1: B cae, vuelve y muere de verdad; se limpia la oleada con A en pie, y B debe volver con el descanso.
Ronda 2: A cae y muere de verdad sin que haya derrota, porque B sigue en pie; luego muere B y debe haber derrota para los dos.
Cada 2 s se escribe un chequeo que debe coincidir en ambos clientes.
Uso: puente_rondas_lan_v12q.py IN_J OUT_J
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_rondas_lan_v12q.py).
integer Lan_N = 0
integer Lan_Paso = 0
integer Lan_Marca = 0
real Lan_Dt = 0.
real Lan_Base = 0.
string Lan_Antes = ""
unit Lan_Verdugo = null
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_rondas_lan_v12q.py).
function Lan_Log takes string s returns nothing
    set Lan_N = Lan_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\\\\\\\j" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Lan_N) + ".txt")
endfunction

function Lan_B takes boolean b returns integer
    if b then
        return 1
    endif
    return 0
endfunction

function Lan_Estado takes nothing returns string
    return "ronda " + I2S(Ronda_Numero) + " descanso " + I2S(Lan_B(Ronda_Descanso)) + " enpie " + I2S(Vidas_EnPie) + " vidas " + I2S(Vidas_Actual[0]) + "/" + I2S(Vidas_Actual[1]) + " partida " + I2S(Lan_B(Vidas_EnPartida[0])) + "/" + I2S(Lan_B(Vidas_EnPartida[1])) + " perdida " + I2S(Lan_B(Vidas_Perdida))
endfunction

function Lan_Golpe takes integer p returns nothing
    call Lan_Log("golpe t " + R2S(Lan_Dt) + " jugador " + I2S(p))
    call UnitDamageTarget(Lan_Verdugo, Game_Hero[p], 100000., true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
endfunction

function Lan_Curar takes integer p returns nothing
    if UnitAlive(Game_Hero[p]) then
        call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
    endif
endfunction

function Lan_Filtro takes nothing returns boolean
    return UnitAlive(GetFilterUnit())
endfunction

function Lan_Limpiar takes nothing returns nothing
    local integer o = 8
    local group g = CreateGroup()
    local unit u
    loop
        exitwhen o > 13
        call GroupEnumUnitsOfPlayer(g, Player(o), Condition(function Lan_Filtro))
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            call KillUnit(u)
        endloop
        set o = o + 1
    endloop
    call DestroyGroup(g)
    set g = null
endfunction

function Lan_Chequeo takes nothing returns nothing
    local unit a = Game_Hero[0]
    local unit b = Game_Hero[1]
    local integer t = R2I(GetUnitX(a) + GetUnitY(a) * 3 + GetUnitX(b) * 5 + GetUnitY(b) * 7 + GetWidgetLife(a) * 11 + GetWidgetLife(b) * 13) + s__Wave_toKillRemaining[Ronda_Wave] * 17
    local integer p = GetPlayerId(GetLocalPlayer())
    call Lan_Log("chequeo " + I2S(Lan_Marca) + " suma " + I2S(t) + " " + Lan_Estado() + " | yo J" + I2S(p + 1) + " sel " + I2S(Lan_B(IsUnitSelected(Game_Ctrl[p], GetLocalPlayer()))) + " titulo " + Ronda_TituloVisto[p] + " cifra " + Ronda_CifraVista[p])
    set a = null
    set b = null
endfunction

function Lan_Tick takes nothing returns nothing
    local real d
    local string e
    if Game_Hero[1] == null then
        return
    endif
    set Lan_Dt = Lan_Dt + 0.25
    set e = Lan_Estado()
    if e != Lan_Antes then
        set Lan_Antes = e
        call Lan_Log("estado t " + R2S(Lan_Dt) + " " + e)
    endif
    if R2I(Lan_Dt / 2.) > Lan_Marca then
        set Lan_Marca = R2I(Lan_Dt / 2.)
        call Lan_Chequeo()
    endif
    if Ronda_Descanso or not Ronda_Activa then
        set Lan_Base = Lan_Dt
        return
    endif
    set d = Lan_Dt - Lan_Base
    call Lan_Curar(0)
    call Lan_Curar(1)
    if Lan_Paso == 0 and d >= 4. then
        set Lan_Paso = 1
        call Lan_Golpe(1)
    elseif Lan_Paso == 1 and d >= 9. then
        set Lan_Paso = 2
        call Lan_Golpe(1)
    elseif Lan_Paso == 2 and d >= 13. then
        set Lan_Paso = 3
        call Lan_Log("limpia con A en pie t " + R2S(Lan_Dt))
        call Lan_Limpiar()
    elseif Lan_Paso == 3 and Ronda_Numero == 2 and d >= 3. then
        set Lan_Paso = 4
        call Lan_Golpe(0)
    elseif Lan_Paso == 4 and d >= 8. then
        set Lan_Paso = 5
        call Lan_Golpe(0)
    elseif Lan_Paso == 5 and d >= 14. then
        set Lan_Paso = 6
        call Lan_Golpe(1)
    endif
endfunction

function Puente_Juego takes nothing returns nothing
    call Title_Exit()
    set Hero_Choice[0] = 0
    set Hero_Choice[1] = 1
    call Title_Black(255, 0, 0.2)
    call DestroyTimer(GetExpiredTimer())
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    for old, new in (('constant integer Ronda_TOTAL = ', 'constant integer Ronda_TOTAL = 2'), ('constant integer Ronda_DESCANSO = ', 'constant integer Ronda_DESCANSO = 8'),
                     ('constant integer Vidas_INICIO = ', 'constant integer Vidas_INICIO = 1')):
        s, n = re.subn(re.escape(old) + r'\d+\r\n', new + '\r\n', s)
        assert n == 1, old
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n', FUNCS + 'function Title_Init takes nothing returns nothing\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    set Lan_Verdugo = CreateUnit(Player(15), \'hfoo\', 0., 0., 0.)\n    call ShowUnit(Lan_Verdugo, false)\n'
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Juego)\n'
                  '    call TimerStart(CreateTimer(), 0.25, true, function Lan_Tick)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
