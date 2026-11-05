"""Puente del test general (Dev Mission v12t, 31/10/2026). NO integrar.

Sin intro, con el jugador 0 registrado y sus elecciones por los mismos manejadores que un clic. Respeta tiempos, 10 rondas y 3 vidas (VIDAS
las cambia). Registra pantallas, elecciones del bot, el estado de la partida y el final. ya.txt y fin.txt avisan a la prueba.
Uso: puente_general_v12t.py IN_J OUT_J CELDA [VIDAS]
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base
import puente_bot_v12s as bot

SONDA = '''// TEMPORARY test bridge (scripts/puente_general_v12t.py).
function Sonda_Log takes string s returns nothing
    set Sonda_N = Sonda_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\\\\\\\j1-" + I2S(Sonda_N) + ".txt")
endfunction

function Gn_Marca takes string nombre returns nothing
    call PreloadGenClear()
    call Preload(nombre)
    call PreloadGenEnd("lat\\\\\\\\" + nombre + ".txt")
endfunction

function Vidas_Derrota takes nothing returns nothing
'''
FUNCS = bot.FUNCS.replace('function Rev_Timer takes nothing returns nothing\n', '') + '''function Gn_Pantalla takes nothing returns string
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
    endif
    return "titulo"
endfunction

function Gn_Humano takes nothing returns nothing
    local string e = Gn_Pantalla()
    if e != Gn_Antes then
        set Gn_Antes = e
        call Sonda_Log("pantalla " + e + " t " + R2S(TimerGetElapsed(Gn_Reloj)))
    endif
    if Bot_P >= 0 and not Title_Exited then
        set e = "bot p " + I2S(Bot_P) + " nombre " + GetPlayerName(Player(Bot_P)) + " modo " + I2S(Mode_Choice[Bot_P]) + " heroe " + I2S(Hero_Choice[Bot_P]) + " listo " + I2S(IntegerTertiaryOp(Hero_Locked[Bot_P], 1, 0)) + " boss " + I2S(Boss_Choice[Bot_P]) + " voto " + I2S(IntegerTertiaryOp(Boss_Picked[Bot_P], 1, 0)) + " vista " + I2S(Strat_View[Bot_P])
        if e != Gn_Bot then
            set Gn_Bot = e
            call Sonda_Log("eleccion t " + R2S(TimerGetElapsed(Gn_Reloj)) + " " + e)
        endif
    endif
    if Title_Exited then
        if Game_Hero[0] != null and not Gn_Ya then
            set Gn_Ya = true
            call Gn_Marca("ya")
            call Sonda_Log("cuerpos J0 " + GetUnitName(Game_Hero[0]) + " bot " + GetUnitName(Game_Hero[Bot_P]) + " Pbot " + I2S(Bot_P) + " nombre " + GetPlayerName(Player(Bot_P)))
        endif
    elseif Mode_Ready and Mode_Choice[0] != 2 then
        call Mode_OnHit(0, 12)
    elseif Hero_Ready and not Hero_Locked[0] and not Boss_Active then
        if Hero_Choice[0] < 0 then
            call Hero_OnHit(0, 100 + Gn_CELDA)
        else
            call Hero_OnHit(0, 140)
        endif
    elseif Boss_Ready and not Boss_Picked[0] and not Strat_Active then
        if Boss_Choice[0] < 0 then
            call Boss_OnHit(0, 200)
        else
            call Boss_OnHit(0, 240)
        endif
    endif
endfunction

function Puente_V12 takes nothing returns nothing
    set Title_Registered[0] = true
    set Title_Count = 1
    set Title_Left = 5
    call Title_Begin()
endfunction

'''
GLOBALS = '''string Bt_Antes = ""
integer Bt_Flechas = 0
real Bt_Prox = 0.
real Bt_Reloj = 0.
trigger Bt_Tecla = null
trigger Bt_Mundo = null
location Bt_Punto = null
group Bt_Todo = CreateGroup()
real Bt_ProxCenso = 0.
integer Sonda_N = 0
string Gn_Antes = ""
string Gn_Bot = ""
boolean Gn_Ya = false
timer Gn_Reloj = CreateTimer()
'''
ARRANQUE = bot.ARRANQUE.replace('function Bt_Reg)', 'function Bt_Reg)') + '''    call TimerStart(Gn_Reloj, 100000., false, null)
    call TimerStart(CreateTimer(), 0.25, true, function Gn_Humano)
'''

if __name__ == '__main__':
    j_in, j_out, celda = sys.argv[1:4]
    vidas = sys.argv[4] if len(sys.argv) > 4 else '3'
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s, n = re.subn(r'constant integer Vidas_INICIO = \d+\r\n', f'constant integer Vidas_INICIO = {vidas}\\r\\n', s)
    assert n == 1
    s = base.once(s, 'constant integer Ronda_DESCANSO = 45\n', f'constant integer Ronda_DESCANSO = 45\nconstant integer Gn_CELDA = {celda}\n' + GLOBALS)
    s = base.once(s, 'function Vidas_Derrota takes nothing returns nothing\n', SONDA)
    s = base.once(s, '            call CustomDefeatBJ(Player(p), "Derrota")\n', '            call Sonda_Log("FIN derrota ronda " + I2S(Ronda_Numero) + " jugador " + I2S(p))\n            call Gn_Marca("fin")\n            call CustomDefeatBJ(Player(p), "Derrota")\n')
    s = base.once(s, '            call CustomVictoryBJ(Player(p), true, true)\n', '            call Sonda_Log("FIN victoria ronda " + I2S(Ronda_Numero) + " jugador " + I2S(p))\n            call Gn_Marca("fin")\n            call CustomVictoryBJ(Player(p), true, true)\n')
    s = base.once(s, '// v9c: the missile diagnostic multiboard', FUNCS + '// v9c: the missile diagnostic multiboard')
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n', ARRANQUE + '    call TimerStart(CreateTimer(), 0.1, false, function Puente_V12)\n')
    s = base.once(s, '    set Title_Active = true\n', '    set Title_Active = true\n    set Title_Registered[0] = true\n    set Title_Count = 1\n')
    # Sin bot, las sondas leen al jugador 0.
    s = s.replace('    local integer b = Bot_P\r\n', '    local integer b = IMaxBJ(Bot_P, 0)\r\n')
    s = s.replace('GetUnitName(Game_Hero[Bot_P])', 'GetUnitName(Game_Hero[IMaxBJ(Bot_P, 0)])')
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
