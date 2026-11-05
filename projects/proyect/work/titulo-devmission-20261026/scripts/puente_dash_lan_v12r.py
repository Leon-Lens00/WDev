"""Puente de prueba LAN del dash (Dev Mission v12r, 31/10/2026). NO integrar.

Dos jugadores, A Tauren y B Cairne, 1 vida, 2 rondas y 8 s de descanso. Las órdenes pasan por el evento real de habilidad del controlador.
Prueba adelante y atrás, dash en ráfaga, dash caminando, caída y muerte real a mitad de dash, dashes contra terreno y dash con el controlador nuevo.
Uso: puente_dash_lan_v12r.py IN_J OUT_J
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base
import puente_rondas_lan_v12q as lan

TICK = '''function Lan_Dato takes string s,integer p returns nothing
    local unit h = Game_Hero[p]
    local integer m = s__RapidPair_motion[Game_Pair[p]]
    call Lan_Log(s + " t " + R2S(Lan_Dt) + " J" + I2S(p) + " x " + I2S(R2I(GetUnitX(h))) + " y " + I2S(R2I(GetUnitY(h))) + " cara " + I2S(R2I(GetUnitFacing(h))) + " mana " + I2S(R2I(GetUnitState(Game_Ctrl[p], UNIT_STATE_MANA))) + " dash " + I2S(Lan_B(s__GroundMotion_dashing[m])) + " art " + I2S(Lan_B(s__GroundMotion_artificial[m])) + " meta " + I2S(Lan_B(s__GroundMotion_hasGoal[m])) + " fuego " + I2S(Lan_B(s__RapidPair_firing[Game_Pair[p]])) + " caido " + I2S(Lan_B(s__RapidPair_down[Game_Pair[p]])) + " vivo " + I2S(Lan_B(UnitAlive(h))) + " dashes " + I2S(s__RapidPair_dashes) + " muros " + I2S(s__RapidPair_dashWalls) + " toques " + I2S(s__RapidPair_dashTouches) + " tiros " + I2S(s__RapidPair_emitted) + " pares " + I2S(s__RapidPair_pairs))
    set h = null
endfunction

function Lan_Dash takes integer p,string orden returns nothing
    call Lan_Log("orden " + orden + " t " + R2S(Lan_Dt) + " J" + I2S(p) + " Ard1 " + I2S(GetUnitAbilityLevel(Game_Ctrl[p], 'Ard1')) + " Ard2 " + I2S(GetUnitAbilityLevel(Game_Ctrl[p], 'Ard2')) + " acepta " + I2S(Lan_B(IssueImmediateOrder(Game_Ctrl[p], orden))))
endfunction

function Lan_Sigue takes real d,real espera returns boolean
    if d >= espera then
        set Lan_Paso = Lan_Paso + 1
        return true
    endif
    return false
endfunction

function Lan_Tick takes nothing returns nothing
    local real d
    local string e
    if Game_Hero[1] == null then
        return
    endif
    set Lan_Dt = Lan_Dt + 0.1
    set e = Lan_Estado()
    if e != Lan_Antes then
        set Lan_Antes = e
        call Lan_Log("estado t " + R2S(Lan_Dt) + " " + e)
    endif
    if R2I(Lan_Dt / 2.) > Lan_Marca then
        set Lan_Marca = R2I(Lan_Dt / 2.)
        call Lan_Chequeo()
    endif
    if Ronda_Descanso then
        if Lan_Paso >= 21 then
            set d = Lan_Dt - Lan_Base
            if Lan_Paso == 21 and Lan_Sigue(d, 2.) then
                call Lan_Dato("descanso", 1)
                call Lan_Dash(1, "stomp")
            elseif Lan_Paso == 22 and Lan_Sigue(d, 3.) then
                call Lan_Dato("tras adelante", 1)
                call Lan_Dash(1, "thunderclap")
            elseif Lan_Paso == 23 and Lan_Sigue(d, 4.) then
                call Lan_Dato("tras atras", 1)
            endif
        else
            set Lan_Base = Lan_Dt
        endif
        return
    endif
    if not Ronda_Activa then
        set Lan_Base = Lan_Dt
        return
    endif
    set d = Lan_Dt - Lan_Base
    call Lan_Curar(0)
    call Lan_Curar(1)
    if Lan_Paso == 0 and Lan_Sigue(d, 2.) then
        call Lan_Dato("antes", 0)
        call Lan_Dato("antes", 1)
        call Lan_Dash(0, "stomp")
        call Lan_Dash(1, "stomp")
    elseif Lan_Paso == 1 and Lan_Sigue(d, 3.) then
        call Lan_Dato("tras adelante", 0)
        call Lan_Dato("tras adelante", 1)
        call Lan_Dash(0, "thunderclap")
        call Lan_Dash(1, "thunderclap")
    elseif Lan_Paso == 2 and Lan_Sigue(d, 4.) then
        call Lan_Dato("tras atras", 0)
        call Lan_Dato("tras atras", 1)
        call Lan_Log("rafaga acepta " + I2S(Lan_B(IssuePointOrder(Game_Ctrl[0], "channel", GetUnitX(Game_Hero[0]) + 500., GetUnitY(Game_Hero[0])))))
    elseif Lan_Paso == 3 and Lan_Sigue(d, 4.8) then
        call Lan_Dato("en rafaga", 0)
        call Lan_Dash(0, "stomp")
    elseif Lan_Paso == 4 and Lan_Sigue(d, 5.8) then
        call Lan_Dato("tras dash en rafaga", 0)
        call Lan_Log("camina acepta " + I2S(Lan_B(IssuePointOrder(Game_Ctrl[1], "smart", GetUnitX(Game_Hero[1]) + 900., GetUnitY(Game_Hero[1])))))
    elseif Lan_Paso == 5 and Lan_Sigue(d, 6.4) then
        call Lan_Dato("caminando", 1)
        call Lan_Dash(1, "stomp")
    elseif Lan_Paso == 6 and Lan_Sigue(d, 7.4) then
        call Lan_Dato("tras dash caminando", 1)
    elseif Lan_Paso == 7 and Lan_Sigue(d, 9.) then
        call Lan_Dash(1, "stomp")
    elseif Lan_Paso == 8 and Lan_Sigue(d, 9.2) then
        call Lan_Dato("mitad de dash", 1)
        call Lan_Golpe(1)
    elseif Lan_Paso == 9 and Lan_Sigue(d, 9.5) then
        call Lan_Dato("caido", 1)
        call Lan_Dash(1, "stomp")
    elseif Lan_Paso == 10 and Lan_Sigue(d, 11.3) then
        call Lan_Dato("de vuelta", 1)
        call Lan_Dash(1, "stomp")
    elseif Lan_Paso == 11 and Lan_Sigue(d, 12.3) then
        call Lan_Dato("dash de vuelta", 1)
    elseif Lan_Paso >= 12 and Lan_Paso <= 16 and Lan_Sigue(d, 12.5 + (Lan_Paso - 12) * 0.6) then
        call SetUnitState(Game_Ctrl[0], UNIT_STATE_MANA, 5.)
        call Lan_Dash(0, "stomp")
        call Lan_Dato("serie", 0)
    elseif Lan_Paso == 17 and Lan_Sigue(d, 16.) then
        call Lan_Dato("tras serie", 0)
        call Lan_Dash(1, "stomp")
    elseif Lan_Paso == 18 and Lan_Sigue(d, 16.2) then
        call Lan_Golpe(1)
    elseif Lan_Paso == 19 and Lan_Sigue(d, 16.7) then
        call Lan_Log("muerte real t " + R2S(Lan_Dt) + " pares " + I2S(s__RapidPair_pairs) + " " + Lan_Estado())
    elseif Lan_Paso == 20 and Lan_Sigue(d, 17.5) then
        call Lan_Limpiar()
        set Lan_Base = Lan_Dt
    endif
endfunction
'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    for old, new in (('constant integer Ronda_TOTAL = ', 'constant integer Ronda_TOTAL = 2'), ('constant integer Ronda_DESCANSO = ', 'constant integer Ronda_DESCANSO = 8'),
                     ('constant integer Vidas_INICIO = ', 'constant integer Vidas_INICIO = 1')):
        s, n = re.subn(re.escape(old) + r'\d+\r\n', new + '\r\n', s)
        assert n == 1, old
    a = lan.FUNCS.index('function Lan_Tick takes')
    b = lan.FUNCS.index('function Puente_Juego takes')
    funcs = lan.FUNCS[:a] + TICK + '\n' + lan.FUNCS[b:]
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n', funcs + 'function Title_Init takes nothing returns nothing\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + lan.GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    set Lan_Verdugo = CreateUnit(Player(15), \'hfoo\', 0., 0., 0.)\n    call ShowUnit(Lan_Verdugo, false)\n'
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Juego)\n'
                  '    call TimerStart(CreateTimer(), 0.1, true, function Lan_Tick)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
