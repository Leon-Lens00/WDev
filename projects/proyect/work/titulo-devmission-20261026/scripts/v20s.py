#!/usr/bin/env python3
"""v20s (20/11/2026), fase 2 del rework de habilidades (docs/planes/devmission-rework-habilidades-v20r.md).
Las transformaciones se ganan matando durante la wave y se quitan al terminarla.
- Puntos por jugador y wave (Frm_Pts): normal 1, élite 5 (ne00-ne09), jefe 15. Cuota: max(10, DevWave_Total /
  DevWave_Jug).
- Goku: SSJ al 20 %, SSJ2 al 40 %, SSJ3 al 60 %, SSJ4 al 85 %. Sube un nivel por muerte con el código de D.O.N
  (GkF_B77, el mismo morph, sonido y piezas) lanzado con ExecuteFunc para que su DisableTrigger(GetTriggeringTrigger())
  no apague otro disparador.
- Trunks: Power Up (SSJ) al 25 %, SSJ2 al 50 % (TrF_gi4) y Finish Sign al 75 % (Roar del propio héroe).
- Freezer: Power Up al 30 % (Berserk del propio héroe).
- La forma ya no se acaba a los 50 s (GkF_B97, TrF_gk4): sólo al morir o al terminar la wave (Frm_Fin). Tras morir
  se recupera, un nivel por muerte, si los puntos de la wave lo permiten.
Uso: v20s.py ENTRADA.j SALIDA.j [prueba]   (normal de v20r; prueba de v20r-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


nota = (lambda s: f'    call Dia_Anotar({s})\n') if prueba else (lambda s: '')
cambia('integer DevWave_Total= 0\n', '''integer DevWave_Total= 0
// v20s: transformaciones por muertes de la wave (puntos por jugador) y corte al terminarla.
integer array Frm_Pts
boolean Frm_Corte= false
''')
cambia('''function GkF_B97 takes nothing returns boolean
return(GkV_n8[$B1B]>=50)
endfunction''', '''function GkF_B97 takes nothing returns boolean
return Frm_Corte
endfunction''')
cambia('''function TrF_gk4 takes nothing returns boolean
return(TrV_n8[5633]>=50)
endfunction''', '''function TrF_gk4 takes nothing returns boolean
return Frm_Corte
endfunction''')
cambia('''        set Mvp_Jefe[q] = 0
''', '''        set Mvp_Jefe[q] = 0
        set Frm_Pts[q] = 0
''')
cambia('''// Élites y golpe final al jefe (desde Oro_Muerte, con el jugador que mata).
function Mvp_Muerte takes integer k, unit u returns nothing''', f'''// v20s: ¿llegan los puntos de k al pct % de la cuota de la wave?
function Frm_Llega takes integer k, integer pct returns boolean
    return Frm_Pts[k] * 100 >= pct * IMaxBJ(10, DevWave_Total / IMaxBJ(1, DevWave_Jug))
endfunction

function Frm_Aviso takes integer k, string s returns nothing
    call DisplayTimedTextToPlayer(Player(k), 0., 0., 4., "|cffffcc00" + s + "|r")
endfunction

// v20s: suma la muerte de u al jugador k y le da la forma que corresponda (un nivel por muerte).
function Frm_Matar takes integer k, unit u returns nothing
    local unit h
    local integer t
    local integer id = GetUnitTypeId(u)
    local integer n = 1
    if k < 0 or k > 7 or not Ronda_Activa or Ronda_Descanso then
        return
    endif
    if id >= 'ne00' and id <= 'ne09' then
        set Frm_Pts[k] = Frm_Pts[k] + 5
    elseif (DevJefe != null and u == DevJefe) or (id >= 'nj00' and id <= 'nj0A') then
        set Frm_Pts[k] = Frm_Pts[k] + 15
    else
        set Frm_Pts[k] = Frm_Pts[k] + 1
    endif
    set h = Game_Hero[k]
    if h == null or not UnitAlive(h) then
        set h = null
        return
    endif
    set t = GetUnitTypeId(h)
    if t == 'hGok' and h == GkV_s8[$B18] and not GkV_o8[$B18] then
        if Frm_Llega(k, 85) then
            set n = 5
        elseif Frm_Llega(k, 60) then
            set n = 4
        elseif Frm_Llega(k, 40) then
            set n = 3
        elseif Frm_Llega(k, 20) then
            set n = 2
        endif
        if GkV_n8[$B18] < n then
            set GkV_o8[$B18] = true
            set GkV_n8[$B1F] = 1
            call ExecuteFunc("GkF_B77")
            if GkV_n8[$B18] == 2 then
                call Frm_Aviso(k, "¡Super Saiyan!")
            elseif GkV_n8[$B18] == 3 then
                call Frm_Aviso(k, "¡Super Saiyan 2!")
            elseif GkV_n8[$B18] == 4 then
                call Frm_Aviso(k, "¡Super Saiyan 3!")
            elseif GkV_n8[$B18] == 5 then
                call Frm_Aviso(k, "¡Super Saiyan 4!")
            endif
{nota('"forma goku " + I2S(GkV_n8[$B18]) + " pts " + I2S(Frm_Pts[k]) + "/" + I2S(DevWave_Total)')}        endif
    elseif t == 'hTrk' and h == TrV_s8[$CEE] and not TrV_o8[5630] then
        if Frm_Llega(k, 50) then
            set n = 3
        elseif Frm_Llega(k, 25) then
            set n = 2
        endif
        if TrV_n8[5630] < n then
            set TrV_o8[5630] = true
            set TrV_n8[5637] = 1
            call ExecuteFunc("TrF_gi4")
            if TrV_n8[5630] == 2 then
                call Frm_Aviso(k, "¡Super Saiyan!")
            elseif TrV_n8[5630] == 3 then
                call Frm_Aviso(k, "¡Super Saiyan 2!")
            endif
{nota('"forma trunks " + I2S(TrV_n8[5630]) + " pts " + I2S(Frm_Pts[k])')}        elseif Frm_Llega(k, 75) and GetUnitAbilityLevel(h, 'B03N') == 0 and GetUnitAbilityLevel(h, 'A0I5') > 0 then
            if IssueImmediateOrder(h, "roar") then
                call Frm_Aviso(k, "¡Finish Sign!")
            endif
{nota('"finish sign " + I2S(GetUnitAbilityLevel(h, \'B03N\')) + " pts " + I2S(Frm_Pts[k])')}        endif
    elseif t == 'hFrz' and Frm_Llega(k, 30) and GetUnitAbilityLevel(h, 'B04B') == 0 and GetUnitAbilityLevel(h, 'A0IZ') > 0 then
        if IssueImmediateOrder(h, "berserk") then
            call Frm_Aviso(k, "¡Power Up!")
        endif
{nota('"power up freezer pts " + I2S(Frm_Pts[k])')}    endif
    set h = null
endfunction

// v20s: al terminar la wave, todos vuelven a su forma base.
function Frm_Fin takes nothing returns nothing
    local integer p = 0
    local unit h
    set Frm_Corte = true
    if GkV_s8[$B18] != null then
        call ExecuteFunc("GkF_Bf7")
        call DisableTrigger(GkV_ba)
    endif
    if TrV_s8[$CEE] != null then
        call ExecuteFunc("TrF_go4")
        call DisableTrigger(TrV_ft)
    endif
    set Frm_Corte = false
    loop
        exitwhen p > 7
        set h = Game_Hero[p]
        if h != null then
            call UnitRemoveAbility(h, 'B04B')
            call UnitRemoveAbility(h, 'B03N')
        endif
        set Frm_Pts[p] = 0
        set p = p + 1
    endloop
{nota('"fin de wave: formas base"')}    set h = null
endfunction

// Élites y golpe final al jefe (desde Oro_Muerte, con el jugador que mata).
function Mvp_Muerte takes integer k, unit u returns nothing''')
cambia('''    local integer id = GetUnitTypeId(u)
    if id >= 'ne00' and id <= 'ne09' then
        set Mvp_Elites[k] = Mvp_Elites[k] + 1''', '''    local integer id = GetUnitTypeId(u)
    call Frm_Matar(k, u)
    if id >= 'ne00' and id <= 'ne09' then
        set Mvp_Elites[k] = Mvp_Elites[k] + 1''')
cambia('''    if GetWaveEventWave() == Ronda_Wave then
''', '''    if GetWaveEventWave() == Ronda_Wave then
        call Frm_Fin()
''')
if prueba:
    for viejo, nuevo in (('lat\\\\v20r-', 'lat\\\\v20s-'), ('v20r-don.txt', 'v20s-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20s', 'prueba' if prueba else 'normal')
