#!/usr/bin/env python3
"""v20f-prueba (20/11/2026): calibración del modelo del cuadro MVP, a petición de Leon. Sólo variante de prueba.
- Sin oleadas: Ronda_Lanzar ya no llama a DevWave_Start (la oleada empieza sin enemigos y no termina).
- Comandos (cada uno escribe los valores actuales en pantalla):
  -mvp            muestra / quita el cuadro MVP con el modelo de tu personaje, fijo
  -giro N         giro del modelo (v20e: 110)
  -escala N       escala (v20e: 0.22)
  -mvpx N, -mvpy N  sitio de los pies en la pantalla (v20e: 1330, 320); el de menos puntos va 232 más abajo
  -anim NOMBRE    reproduce esa animación (attack, death, stand, spell...) y vuelve a stand
  Los valores también se usan en el cuadro real.
Uso: v20f.py ENTRADA.j SALIDA.j prueba   (de v20e-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
assert len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


for k, v in (('ESCALA', '0.22'), ('X', '1330.'), ('RANGO', '360.'), ('GIRO', '110.')):
    cambia('constant real MVP_MOD_%s = %s\n' % (k, v), 'real MVP_MOD_%s = %s\n' % (k, v))
cambia('effect array Mvp_Luz\n', '''effect array Mvp_Luz
// v20f-prueba: calibración del modelo (comandos -mvp, -giro, -escala, -mvpx, -mvpy, -anim).
unit array MvpCal_U
effect array MvpCal_Luz
real MvpCal_PY = 320.
''')
cambia('MVP_MOD_X, 320.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, MvpCal_PY + dy, MVP_MOD_RANGO')
cambia('MVP_MOD_X, 552.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, MvpCal_PY + 232. + dy, MVP_MOD_RANGO')
cambia('''    call DevWave_Start(Ronda_Numero)
''', '''    // v20f-prueba: sin oleadas para calibrar el modelo del cuadro MVP.
''')
cambia('''function HealthBarsUpdate takes nothing returns nothing
''', '''// v20f-prueba: modelo fijo del cuadro MVP para calibrar.
function MvpCal_Quitar takes integer p returns nothing
    if MvpCal_Luz[p] != null then
        call DestroyEffect(MvpCal_Luz[p])
        set MvpCal_Luz[p] = null
    endif
    if MvpCal_U[p] != null then
        call RemoveUnit(MvpCal_U[p])
        set MvpCal_U[p] = null
    endif
endfunction

function MvpCal_Poner takes integer p returns nothing
    local string luz = ""
    call MvpCal_Quitar(p)
    set MvpCal_U[p] = Mvp_Modelo(p, Game_Hero[p])
    if GetLocalPlayer() == Player(p) then
        set luz = "war3mapImported\\\\MvpLuz.mdx"
    endif
    if MvpCal_U[p] != null then
        set MvpCal_Luz[p] = AddSpecialEffectTarget(luz, MvpCal_U[p], "origin")
    endif
endfunction

function MvpCal_Hud takes integer p, integer cam returns nothing
    if MvpCal_U[p] == null then
        return
    endif
    call HealthBars__Place(Punt_Lado[p], cam, 1265.0, 380.0, 412.)
    call Hud_Ver(Punt_Lado[p], true)
    call HealthBars__Place(MvpCal_U[p], cam, MVP_MOD_X, MvpCal_PY, MVP_MOD_RANGO)
    call Hud_Ver(MvpCal_U[p], true)
endfunction

function MvpCal_Comando takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer p = GetPlayerId(GetTriggerPlayer())
    local integer n = StringLength(s)
    if s == "-mvp" then
        if MvpCal_U[p] != null then
            call MvpCal_Quitar(p)
        else
            call MvpCal_Poner(p)
        endif
    elseif SubString(s, 0, 6) == "-giro " then
        set MVP_MOD_GIRO = S2R(SubString(s, 6, n))
        if MvpCal_U[p] != null then
            call MvpCal_Poner(p)
        endif
    elseif SubString(s, 0, 8) == "-escala " then
        set MVP_MOD_ESCALA = S2R(SubString(s, 8, n))
        if MvpCal_U[p] != null then
            call SetUnitScale(MvpCal_U[p], MVP_MOD_ESCALA, MVP_MOD_ESCALA, MVP_MOD_ESCALA)
        endif
    elseif SubString(s, 0, 6) == "-mvpx " then
        set MVP_MOD_X = S2R(SubString(s, 6, n))
    elseif SubString(s, 0, 6) == "-mvpy " then
        set MvpCal_PY = S2R(SubString(s, 6, n))
    elseif SubString(s, 0, 6) == "-anim " and MvpCal_U[p] != null then
        call SetUnitTimeScale(MvpCal_U[p], 1.)
        call SetUnitAnimation(MvpCal_U[p], SubString(s, 6, n))
        call QueueUnitAnimation(MvpCal_U[p], "stand")
    endif
    call DisplayTimedTextToPlayer(Player(p), 0, 0, 30, "MVP: giro " + R2S(MVP_MOD_GIRO) + "   escala " + R2S(MVP_MOD_ESCALA) + "   x " + R2S(MVP_MOD_X) + "   y " + R2S(MvpCal_PY))
endfunction

function MvpCal_Registrar takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer p = 0
    loop
        exitwhen p > 11
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-mvp", false)
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-giro ", false)
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-escala ", false)
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-anim ", false)
        set p = p + 1
    endloop
    call TriggerAddAction(t, function MvpCal_Comando)
    set t = null
endfunction

function HealthBarsUpdate takes nothing returns nothing
''')
cambia('            call Punt_Hud(p , cam)\n', '            call Punt_Hud(p , cam)\n            call MvpCal_Hud(p , cam)\n')
cambia('    call ExecuteFunc("Punt_Registrar")\n', '    call ExecuteFunc("Punt_Registrar")\n    call ExecuteFunc("MvpCal_Registrar")\n')
cambia('"Diagnóstico D.O.N: empieza en la oleada 6; usa cada técnica y escribe -reg para guardar lat\\\\v20e-don.txt."',
       '"Calibración del MVP (sin oleadas): -mvp muestra el cuadro; -giro N, -escala N, -mvpx N, -mvpy N, -anim attack."')
for viejo, nuevo in (('lat\\\\v20e-', 'lat\\\\v20f-'), ('v20e-don.txt', 'v20f-don.txt')):
    assert viejo in src, viejo
    src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20f prueba')
