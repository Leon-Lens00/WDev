#!/usr/bin/env python3
"""v19t (19/11/2026), fase 1 del plan devmission-v20-mutaciones-rachas-mvp.md:
- Sonido nativo Sound\\Interface\\ArrangedTeamInvitation.wav (War3x.mpq, 2914 ms) al mostrar el resultado de la
  votación de Mutación Evo (Cua_MuestraEmpezar), para todos (Leon: "haras sonar un sonido cuando se muestra el resultado
  de la votacion").
- Linterna ilimitada (Leon: "la luz de linterna sera ilimitada ahora"): la batería sólo gasta con Bat_Limitada[p], que
  de momento nadie activa (lo hará la maldita "Pacto de sombras" en v19x). Sin batería limitada no se ven la barra ni el
  texto "Batería…" y el controlador no recibe la habilidad de recargar ('Aw0A', G).
- Baraja de mejoras del enemigo (Sup_Hud: "Élites: …" y las 4 pasivas) 265 px más abajo, junto al minimapa: título de
  py 296 a 561, filas de 345 + 62 k a 610 + 62 k (la última, a 796, termina en ~825).
Uso: v19t.py ENTRADA.j SALIDA.j [prueba]   (normal de v19s; prueba de v19s-prueba)
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


# --- sonido del resultado de la votación ---
cambia('''function Cua_MuestraEmpezar takes nothing returns nothing
    local integer p = 0
    call Cua_Recuento()
''', '''function Cua_MuestraEmpezar takes nothing returns nothing
    local integer p = 0
    local sound snd
    call Cua_Recuento()
    // v19t: sonido nativo al mostrar el resultado de la votación (para todos; se libera al acabar).
    set snd = CreateSound("Sound\\\\Interface\\\\ArrangedTeamInvitation.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(snd, 2914)
    call SetSoundChannel(snd, 0)
    call SetSoundVolume(snd, 110)
    call StartSound(snd)
    call KillSoundWhenDone(snd)
    set snd = null
''')

# --- linterna ilimitada ---
cambia('real array Bat_T\n', 'real array Bat_T\n// v19t: la batería sólo se gasta y se ve con Bat_Limitada (Pacto de sombras, v19x).\nboolean array Bat_Limitada\n')
cambia('''        if Bat_T[p] > 0. and Ronda_Activa and not Ronda_Descanso and GetUnitTypeId(Game_Hero[p]) != 0 and not Shop_Open[p] then''',
       '''        if Bat_Limitada[p] and Bat_T[p] > 0. and Ronda_Activa and not Ronda_Descanso and GetUnitTypeId(Game_Hero[p]) != 0 and not Shop_Open[p] then''')
cambia('''    call Hud_Ver(Bat_Barra[p], shown and Bat_T[p] > 0.)
    call s__UIText_show(Bat_UI[p], shown, cam)''', '''    call Hud_Ver(Bat_Barra[p], shown and Bat_Limitada[p] and Bat_T[p] > 0.)
    call s__UIText_show(Bat_UI[p], shown and Bat_Limitada[p], cam)''')
cambia('''    call Arm_Botones(p)
    call UnitAddAbility(Game_Ctrl[p], 'Aw0A')
''', '''    call Arm_Botones(p)
    if Bat_Limitada[p] then
        call UnitAddAbility(Game_Ctrl[p], 'Aw0A')
    endif
''')

# --- baraja del enemigo junto al minimapa ---
cambia('''        call s__UIText_setPosition(Sup_TT[p * 5], (30. + dx - 960.) / 728., (420. - 296.) / 390.)''',
       '''        call s__UIText_setPosition(Sup_TT[p * 5], (30. + dx - 960.) / 728., (420. - 561.) / 390.)''')
cambia('''        set y = 345. + 62. * k
        set u = Sup_Ico[p * 4 + k]''', '''        // v19t: junto al minimapa (antes 345 + 62 k, debajo del icono del arma).
        set y = 610. + 62. * k
        set u = Sup_Ico[p * 4 + k]''')

if prueba:
    for viejo, nuevo in (('lat\\\\v19s-', 'lat\\\\v19t-'), ('v19s-don.txt', 'v19t-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19t', 'prueba' if prueba else 'normal')
