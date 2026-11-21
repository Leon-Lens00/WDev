#!/usr/bin/env python3
"""v18q (15/11/2026): correcciones de la prueba de v18p (Leon, grabación 20261115_182516).

- Tic audible: en v18p el tic era un sonido global que se paraba y volvía a lanzar; en la grabación apenas se oía
  (correlación 0,1-0,42). Ahora se crea en cada uso desde la etiqueta "ChatroomTimerTick", a volumen 127, como
  QuestCompleted (que sí se oye); al empezar se calienta a volumen 0 por etiqueta y por ruta (Son_Cero).
- Tiempo de compra: tic en cada segundo de los 10 últimos (Ronda_Cuenta).
- Muestra de la Mutación Evo (8 s antes de la oleada): en v18p no se veía porque la cámara que sigue al héroe sólo se
  detiene con Shop_Open; la muestra sólo abría Cua_Open y la cámara volvía al mundo. Ahora la muestra abre la tienda
  (Shop_Open) como al pulsar ESC junto al golem, con Esc desactivado, y la cierra al acabar.
- Cuenta de la muestra: Ronda_Fase 3, Ronda_Resta 8..1 con un reloj de 1 s, tic cada segundo; el reloj de la escena
  ("Oleada en N") parpadea en rojo como el de la tienda (Cua_Reloj parpadea ahora con Ronda_Resta <= 10).
- Cuadro de resultados: el HUD muestra los segundos que le quedan (sin parpadeo ni tic).
Prueba/lan: registros v18p -> v18q.  Uso: v18q.py ENTRADA.j SALIDA.j [prueba|lan]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


MUESTRA_S = 8
cambia('string Cua_RelojVisto = ""\n', 'string Cua_RelojVisto = ""\nboolean Cua_RelojRojo = false\n')

# 1. Tic creado en cada uso; calentado por etiqueta y por ruta.
cambia('''    set Ronda_TicSnd = CreateSoundFromLabel("ChatroomTimerTick", false, false, false, 10000, 10000)
    call SetSoundVolume(Ronda_TicSnd, 0)
    call StartSound(Ronda_TicSnd)
''', '''    // v18q: el tic se crea en cada uso; aquí sólo se calienta (etiqueta y ruta) a volumen 0.
    set Ronda_TicSnd = CreateSoundFromLabel("ChatroomTimerTick", false, false, false, 10000, 10000)
    call SetSoundVolume(Ronda_TicSnd, 0)
    call StartSound(Ronda_TicSnd)
    call KillSoundWhenDone(Ronda_TicSnd)
    set Ronda_TicSnd = null
    call Son_Cero("Sound\\\\Interface\\\\BattleNetTick.wav")
''')
cambia('''    if Ronda_TicSnd != null then
        call StopSound(Ronda_TicSnd, false, false)
        call SetSoundVolume(Ronda_TicSnd, 127)
        call StartSound(Ronda_TicSnd)
    endif
''', '''    // v18q: un sonido nuevo por tic, como QuestCompleted (el global reutilizado de v18p apenas se oía).
    local sound s = CreateSoundFromLabel("ChatroomTimerTick", false, false, false, 10000, 10000)
    call SetSoundVolume(s, 127)
    call StartSound(s)
    call KillSoundWhenDone(s)
    set s = null
''')

# 2. Tic en los 10 últimos segundos del tiempo de compra.
cambia('''function Ronda_Cuenta takes nothing returns nothing
    set Ronda_Resta = Ronda_Resta - 1
''', '''function Ronda_Cuenta takes nothing returns nothing
    set Ronda_Resta = Ronda_Resta - 1
    if Ronda_Resta > 0 and Ronda_Resta <= 10 then
        call Ronda_Tic()
    endif
''')

# 3. Muestra: abre la tienda (Shop_Open) para que la cámara no vuelva al héroe; cuenta de 8 s con tic.
cambia('''    set Cua_MuestraOn = false
    loop
        exitwhen p > 11
        if Cua_Open[p] then
            set Cua_Open[p] = false
''', '''    set Cua_MuestraOn = false
    set Ronda_Fase = 0
    set Ronda_Resta = 0
    loop
        exitwhen p > 11
        // v18q: la muestra abre la tienda (Shop_Open); se cierra aquí como en Shop_Cerrar.
        if Shop_Open[p] then
            set Shop_Open[p] = false
            set Shop_Abiertos = Shop_Abiertos - 1
        endif
        if Cua_Open[p] then
            set Cua_Open[p] = false
''')
cambia('''function Cua_MuestraEmpezar takes nothing returns nothing
    local integer p = 0
    call Cua_Recuento()
    set Cua_MuestraOn = true
    loop
        exitwhen p > 11
        if Game_On[p] then
            set Cua_Open[p] = true
''', f'''// v18q: cada segundo de la muestra: tic y cuenta en Ronda_Resta; a 0, la oleada.
function Cua_MuestraCuenta takes nothing returns nothing
    set Ronda_Resta = Ronda_Resta - 1
    if Ronda_Resta > 0 then
        call Ronda_Tic()
        return
    endif
    call PauseTimer(Cua_MuestraReloj)
    call Cua_MuestraFin()
endfunction

function Cua_MuestraEmpezar takes nothing returns nothing
    local integer p = 0
    call Cua_Recuento()
    set Cua_MuestraOn = true
    set Ronda_Fase = 3
    set Ronda_Resta = {MUESTRA_S}
    loop
        exitwhen p > 11
        if Game_On[p] then
            // v18q: con Shop_Open la cámara del héroe se detiene y el HUD del mundo se oculta, como en la tienda.
            if not Shop_Open[p] then
                set Shop_Open[p] = true
                set Shop_Abiertos = Shop_Abiertos + 1
            endif
            set Cua_Open[p] = true
''')
cambia(f'''    call TimerStart(Cua_MuestraReloj, 8., false, function Cua_MuestraFin)
''', '''    call Ronda_Tic()
    call TimerStart(Cua_MuestraReloj, 1., true, function Cua_MuestraCuenta)
''')
# Esc no hace nada durante la muestra.
cambia('''function Shop_Volver takes integer p returns nothing
''', '''function Shop_Volver takes integer p returns nothing
    if Cua_MuestraOn then
        return
    endif
''')

# 4. Reloj de la escena: "Oleada en N" con Ronda_Resta y parpadeo rojo como el de la tienda.
cambia('''    if Cua_Modo[p] == 2 and Cua_MuestraReloj != null then
        set t = "Oleada en " + I2S(R2I(TimerGetRemaining(Cua_MuestraReloj) + 0.999))
    endif
    if t != Cua_RelojVisto then
        set Cua_RelojVisto = t
        call Cua_Izq(p, Cua_RelojT, t, 1650, 70, 0.022)
        if Ronda_Resta <= 10 then
            call SetTextTagColor(Cua_RelojT, 255, 48, 48, 255)
        else
            call SetTextTagColor(Cua_RelojT, 235, 240, 245, 255)
        endif
    endif
''', '''    if Cua_Modo[p] == 2 then
        set t = "Oleada en " + I2S(Ronda_Resta)
    endif
    set rojo = Ronda_Resta <= 10 and ModuloInteger(R2I(TimerGetElapsed(s__RapidPair_clock) * 4.), 2) == 0
    if t != Cua_RelojVisto or rojo != Cua_RelojRojo then
        if t != Cua_RelojVisto then
            set Cua_RelojVisto = t
            call Cua_Izq(p, Cua_RelojT, t, 1650, 70, 0.022)
        endif
        set Cua_RelojRojo = rojo
        if rojo then
            call SetTextTagColor(Cua_RelojT, 255, 48, 48, 255)
        else
            call SetTextTagColor(Cua_RelojT, 235, 240, 245, 255)
        endif
    endif
''')
cambia('''function Cua_Reloj takes nothing returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    local string t
''', '''function Cua_Reloj takes nothing returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    local string t
    local boolean rojo
''')

# 5. HUD del cuadro de resultados: segundos que le quedan.
cambia('''        elseif Ronda_Descanso and Ronda_Fase == 2 then
            set t="Resultados"
            set c=""
''', '''        elseif Ronda_Descanso and Ronda_Fase == 2 then
            set t="Resultados"
            set c=""
            if Punt_T >= 0. then
                set c=I2S(IMaxBJ(1, R2I(Punt_Sale + 0.5 - Punt_T + 0.999)))
            endif
''')

if modo in ('prueba', 'lan'):
    viejo = '-v18p-' if modo == 'lan' else 'lat\\\\v18p-'
    assert src.count(viejo) == 4, src.count(viejo)
    src = src.replace(viejo, viejo.replace('v18p', 'v18q'))
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18q', modo or 'normal')
