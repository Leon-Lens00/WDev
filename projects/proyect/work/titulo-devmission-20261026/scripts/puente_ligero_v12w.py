"""Registro ligero para partidas del usuario (Dev Mission v12w). NO integrar.

No cambia nada del juego: intro, tiempos y flujo reales. Escribe solo cuando pasa algo: pantalla, ronda, vidas, dash y final; y una muestra cada 15 s.
Con `directo` se salta intro y menús y entra con Tauren.
Uso: puente_ligero_v12w.py IN_J OUT_J [directo]
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base
import puente_general_v12t as gen

GLOBALS = '''integer Sonda_N = 0
string Lg_Antes = ""
real Lg_X = 0.
real Lg_Y = 0.
real Lg_TX = 0.
real Lg_TY = 0.
boolean Lg_Dash = false
boolean Lg_Dentro = false
integer Lg_Vidas = -1
integer Lg_Ronda = -1
integer Lg_Hits = 0
integer Lg_Muestra = 0
timer Lg_Reloj = CreateTimer()
'''
FUNCS = '''function Lg_Pantalla takes nothing returns string
    if Title_Exited then
        return "juego"
    elseif Strat_Active then
        return "tablero"
    elseif Boss_Active then
        return "boss"
    elseif Hero_Active then
        return "heroe"
    elseif Mode_Active then
        return "modo"
    elseif Title_Active then
        return "titulo"
    endif
    return "intro"
endfunction

function Lg_Directo takes nothing returns nothing
    set Title_Registered[0] = true
    set Title_Count = 1
    call Title_Begin()
    call TimerStart(CreateTimer(), 0.1, false, function Title_Exit)
endfunction

function Lg_Tick takes nothing returns nothing
    local string e = Lg_Pantalla()
    local real t = TimerGetElapsed(Lg_Reloj)
    local unit u = Game_Hero[0]
    local boolean d
    if e != Lg_Antes then
        set Lg_Antes = e
        call Sonda_Log("pantalla " + e + " t " + R2S(t))
    endif
    if Title_Exited and u != null then
        if not Lg_Dentro then
            set Lg_Dentro = true
            call Gn_Marca("ya")
        endif
        set d = s__GroundMotion_dashing[s__RapidPair_motion[Game_Pair[0]]]
        if d != Lg_Dash then
            set Lg_Dash = d
            if d then
                set Lg_X = GetUnitX(u)
                set Lg_Y = GetUnitY(u)
                call Sonda_Log("dash t " + R2S(t) + " desde " + I2S(R2I(Lg_X)) + " " + I2S(R2I(Lg_Y)) + " punto " + I2S(R2I(Lg_TX)) + " " + I2S(R2I(Lg_TY)) + " angulo " + I2S(R2I(Atan2(Lg_TY - Lg_Y, Lg_TX - Lg_X) * bj_RADTODEG)))
            else
                call Sonda_Log("fin dash t " + R2S(t) + " recorrido " + I2S(R2I(SquareRoot((GetUnitX(u) - Lg_X) * (GetUnitX(u) - Lg_X) + (GetUnitY(u) - Lg_Y) * (GetUnitY(u) - Lg_Y)))) + " angulo " + I2S(R2I(Atan2(GetUnitY(u) - Lg_Y, GetUnitX(u) - Lg_X) * bj_RADTODEG)) + " disparando " + I2S(IntegerTertiaryOp(s__RapidPair_firing[Game_Pair[0]], 1, 0)) + " mira " + I2S(R2I(Atan2(s__RapidPair_aimY[Game_Pair[0]] - GetUnitY(u), s__RapidPair_aimX[Game_Pair[0]] - GetUnitX(u)) * bj_RADTODEG)) + " al punto " + I2S(R2I(Atan2(s__RapidPair_pickY[Game_Pair[0]] - GetUnitY(u), s__RapidPair_pickX[Game_Pair[0]] - GetUnitX(u)) * bj_RADTODEG)))
            endif
        endif
        if Ronda_Numero != Lg_Ronda then
            set Lg_Ronda = Ronda_Numero
            call Sonda_Log("ronda " + I2S(Ronda_Numero) + " t " + R2S(t))
        endif
        if Vidas_Actual[0] != Lg_Vidas then
            set Lg_Vidas = Vidas_Actual[0]
            call Sonda_Log("vidas " + I2S(Lg_Vidas) + " t " + R2S(t) + " ronda " + I2S(Ronda_Numero))
        endif
        if t >= Lg_Muestra then
            set Lg_Muestra = R2I(t) + 15
            call Sonda_Log("muestra t " + R2S(t) + " ronda " + I2S(Ronda_Numero) + " descanso " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)) + " faltan " + I2S(s__Wave_toKillRemaining[Ronda_Wave]) + " tiros " + I2S(s__RapidPair_emitted) + " golpes " + I2S(s__RapidBolt_hits) + " paredes " + I2S(s__RapidBolt_walls) + " dashes " + I2S(s__RapidPair_dashes))
        endif
    endif
    set u = null
endfunction

'''

if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    inicio = 'Lg_Directo' if len(sys.argv) > 3 else 'Intro_Begin'
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'constant integer Ronda_DESCANSO = 45\n', 'constant integer Ronda_DESCANSO = 45\n' + GLOBALS)
    s = base.once(s, 'function Vidas_Derrota takes nothing returns nothing\n', gen.SONDA)
    s = base.once(s, '            call CustomDefeatBJ(Player(p), "Derrota")\n', '            call Sonda_Log("FIN derrota ronda " + I2S(Ronda_Numero))\n            call Gn_Marca("fin")\n            call CustomDefeatBJ(Player(p), "Derrota")\n')
    s = base.once(s, '            call CustomVictoryBJ(Player(p), true, true)\n', '            call Sonda_Log("FIN victoria ronda " + I2S(Ronda_Numero))\n            call Gn_Marca("fin")\n            call CustomVictoryBJ(Player(p), true, true)\n')
    s = base.once(s, '            call s__RapidPair_dash(this,GetSpellTargetX() , GetSpellTargetY())\n', '            set Lg_TX = GetSpellTargetX()\n            set Lg_TY = GetSpellTargetY()\n            call s__RapidPair_dash(this,GetSpellTargetX() , GetSpellTargetY())\n')
    s = base.once(s, '// v9c: the missile diagnostic multiboard', FUNCS + '// v9c: the missile diagnostic multiboard')
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n', '    call TimerStart(Lg_Reloj, 100000., false, null)\n    call TimerStart(CreateTimer(), 0.05, true, function Lg_Tick)\n    call TimerStart(CreateTimer(), 0.1, false, function ' + inicio + ')\n')
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
