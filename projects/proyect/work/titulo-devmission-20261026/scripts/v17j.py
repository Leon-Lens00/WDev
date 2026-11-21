#!/usr/bin/env python3
"""v17j (14/11/2026): ajustes de la presentación del jefe tras la prueba de v17i y el vídeo de referencia.

Leon tras probar v17i: "el video de base original se aprecia bien el rayo? ... parpadea o continua aun mas tiempo";
"las rafagas ... algo mas anchas, y hay una grande al centro que va a la par con el nombre"; WARNING del vídeo; nombre
con la fuente y los colores del HUD (texturas en recursos_v17j.py); "eso y las fallas que llegaste a apreciar".
- Rayo con el ritmo del vídeo (30 cuadros por s): tajo 0,10 s, grieta fina 0,10 s, rayo 0,13 s, chispas 0,07 s, nada
  0,10 s (el parpadeo), otro rayo 0,10 s y chispas que se apagan 0,20 s (antes seguido de 0,70 a 1,32).
- La franja del nombre va con el nombre (entra y sale con él) y brilla más; la textura es una banda ancha.
- El marco y la barra de vida (HeroBars/EnemyBars) quedaban por delante del fondo aunque están detrás: se oscurecen con
  el color de vértice, sólo en el cliente de su dueño (ya eran visibles sólo para él), como los textos.
- Animación de hechizo sólo para la Naga (ronda 8): el Mur'gul Snarecaster y el Makrura Deepseer se salían por arriba.
- Salidas de 0,30 s (antes 0,15 s) y fin a 3,35 s (antes 3,20 s): el jefe y el nombre salen de pantalla antes de apagarse.
Uso: v17j.py v17i/war3map.j SALIDA.j (y v17i-prueba/war3map.j para la de prueba)
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


# --- barras de vida oscurecidas con los textos ---
una('''        set i = i + 1
    endloop
    set t = null
endfunction
''', '''        set i = i + 1
    endloop
    set t = null
    // v17j: el marco y la barra de vida se dibujan delante del fondo aunque estén detrás: se oscurecen con el color de
    // vértice hacia el del fondo, sólo en el cliente de su dueño (sólo él las ve, HealthBars__Dummy).
    set i = 0
    loop
        exitwhen i > 11
        if GetLocalPlayer() == Player(i) then
            if HealthBars__HeroBars[i] != null then
                call SetUnitVertexColor(HealthBars__HeroBars[i], R2I(255. * (1. - JefeTx_F) + 11. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 16. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 34. * JefeTx_F), 255)
            endif
            if HealthBars__EnemyBars[i] != null then
                call SetUnitVertexColor(HealthBars__EnemyBars[i], R2I(255. * (1. - JefeTx_F) + 11. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 16. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 34. * JefeTx_F), 255)
            endif
        endif
        set i = i + 1
    endloop
endfunction
''')

# --- fin a 3,35 s ---
una('    call TimerStart(JefePres_Reloj, 3.20, false, function JefePres_Fin)\n',
    '    call TimerStart(JefePres_Reloj, 3.35, false, function JefePres_Fin)\n')
una('    call JefeTx_Aplicar(R2I(8. * RMinBJ(RMinBJ(1., t / 0.15), RMaxBJ(0., RMinBJ(1., (3.18 - t) / 0.15))) + 0.5))\n',
    '    call JefeTx_Aplicar(R2I(8. * RMinBJ(RMinBJ(1., t / 0.15), RMaxBJ(0., RMinBJ(1., (3.33 - t) / 0.15))) + 0.5))\n')
una('    set fin = RMaxBJ(0., RMinBJ(1., (3.18 - t) / 0.15))\n', '    set fin = RMaxBJ(0., RMinBJ(1., (3.33 - t) / 0.15))\n')

# --- hechizo sólo para la Naga ---
una('        if JefePres_N == 5 or JefePres_N == 6 or JefePres_N == 8 then\n', '        if JefePres_N == 8 then\n')

# --- franja con el nombre, nombre y jefe con salida de 0,30 s ---
una('''    // Franja del nombre, suave.
    call HealthBars__Place(JefePres_Pieza[b + 1], cam, 550., 418., 222.)
    call JefePres_Alfa(p, JefePres_Pieza[b + 1], R2I(150. * RMinBJ(1., RMaxBJ(0., (t - 0.13) / 0.35)) * fin), true)
''', '')
una('''    // Nombre: entra desde la izquierda, deriva a la derecha y sale por la izquierda.
    if t < 3.03 then
        set x = -560. + 1074. * JefePres_Frena((t - 0.50) / 0.15) + 25. * RMaxBJ(0., t - 0.65)
    else
        set x = 573.5 - 1133.5 * JefePres_Acelera((t - 3.03) / 0.15)
    endif
    call HealthBars__Place(JefePres_Pieza[b + 3], cam, x, 418., 200.)
    set a = 0
    if t >= 0.50 and t < 3.18 then
        set a = 255
    endif
    call JefePres_Alfa(p, JefePres_Pieza[b + 3], a, false)
''', '''    // Nombre: entra desde la izquierda, deriva a la derecha y sale por la izquierda; la franja va con él, detrás.
    if t < 2.98 then
        set x = -560. + 1074. * JefePres_Frena((t - 0.50) / 0.15) + 25. * RMaxBJ(0., t - 0.65)
    else
        set x = 572.25 - 1132.25 * JefePres_Acelera((t - 2.98) / 0.30)
    endif
    call HealthBars__Place(JefePres_Pieza[b + 3], cam, x, 418., 200.)
    call HealthBars__Place(JefePres_Pieza[b + 1], cam, x - 22., 418., 222.)
    set a = 0
    if t >= 0.50 and t < 3.28 then
        set a = 255
    endif
    call JefePres_Alfa(p, JefePres_Pieza[b + 3], a, false)
    call JefePres_Alfa(p, JefePres_Pieza[b + 1], R2I(0.85 * a), true)
''')
una('''    if t < 3.03 then
        set x = 2260. - 780. * JefePres_Frena((t - 0.50) / 0.15) - 48. * RMaxBJ(0., t - 0.65)
    else
        set x = 1365.76 + 894.24 * JefePres_Acelera((t - 3.03) / 0.15)
    endif
''', '''    if t < 2.98 then
        set x = 2260. - 780. * JefePres_Frena((t - 0.50) / 0.15) - 48. * RMaxBJ(0., t - 0.65)
    else
        set x = 1368.16 + 891.84 * JefePres_Acelera((t - 2.98) / 0.30)
    endif
''')

# --- rayo con el ritmo del vídeo ---
una('''    // Rayo cuadro a cuadro: tajo, tres trazos y chispas que se apagan.
    if t >= 0.70 and t < 1.32 then
        if t < 0.80 then
            set r = 1
        elseif t < 0.90 then
            set r = 2
        elseif t < 1.03 then
            set r = 3
        elseif t < 1.20 then
            set r = 4
        else
            set r = 5
        endif
    endif
    set a = 255
    if r == 5 then
        set a = R2I(255. * (1.32 - t) / 0.12)
    endif
''', '''    // Rayo cuadro a cuadro, con el ritmo del vídeo: tajo, grieta, rayo, chispas, nada (parpadeo), otro rayo y chispas
    // que se apagan.
    set a = 255
    if t >= 0.70 and t < 0.80 then
        set r = 1
    elseif t >= 0.80 and t < 0.90 then
        set r = 2
    elseif t >= 0.90 and t < 1.033 then
        set r = 3
    elseif t >= 1.033 and t < 1.10 then
        set r = 5
    elseif t >= 1.20 and t < 1.30 then
        set r = 4
    elseif t >= 1.30 and t < 1.50 then
        set r = 5
        set a = R2I(255. * (1.50 - t) / 0.20)
    endif
''')

una('// v17h: presentación del jefe de ronda (scripts/v17h.py); v17i (scripts/v17i.py): delante del HUD, jefe centrado,\n',
    '// v17h: presentación del jefe de ronda (scripts/v17h.py); v17j (scripts/v17j.py): rayo con parpadeo, franja con el\n'
    '// nombre, barras oscurecidas, salidas de 0,30 s; v17i (scripts/v17i.py): delante del HUD, jefe centrado,\n')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17j: rayo, franja, barras y salidas')
