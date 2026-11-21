#!/usr/bin/env python3
"""v18p (15/11/2026): fin de oleada en tres tiempos (Leon).

- Al acabar la oleada, si quedan bolsas en el suelo: 8 s para recogerlas ("Recoge las bolsas" en el HUD, número en
  rojo parpadeando y un tic de reloj por segundo); lo que quede se borra y cuenta como perdido. Sin bolsas, directo.
- Luego el cuadro de resultados. El tiempo de compra empieza y el golem baja cuando el cuadro termina
  (Ronda_DescansoEmpezar, desde Punt_Tick). Antes la cuenta de 45 s y el golem empezaban al acabar la oleada.
- Tic: sonido nativo "ChatroomTimerTick" de UISounds (Sound\\Interface\\BattleNetTick.wav), un sonido global creado en
  Son_Init y reproducido a volumen 0 para calentarlo (Preload solo no basta, ver v18o); también en la precarga.
- Ronda_Fase: 0 normal, 1 bolsas, 2 resultados.
Prueba/lan: registros v18o -> v18p.  Uso: v18p.py ENTRADA.j SALIDA.j [prueba|lan]
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


BOLSA_S = 8
cambia('integer Ronda_Resta = 0\n', 'integer Ronda_Resta = 0\ninteger Ronda_Fase = 0\nsound Ronda_TicSnd = null\n')

# Sonido del tic: creado una vez y calentado a volumen 0.
cambia('    call Son_Cero("Sound\\\\Interface\\\\QuestCompleted.wav")\n',
       '    call Son_Cero("Sound\\\\Interface\\\\QuestCompleted.wav")\n'
       '    // v18p: tic de reloj nativo para la cuenta de las bolsas.\n'
       '    set Ronda_TicSnd = CreateSoundFromLabel("ChatroomTimerTick", false, false, false, 10000, 10000)\n'
       '    call SetSoundVolume(Ronda_TicSnd, 0)\n'
       '    call StartSound(Ronda_TicSnd)\n')
cambia('    call Preload("Sound\\\\Interface\\\\QuestCompleted.wav")\n',
       '    call Preload("Sound\\\\Interface\\\\QuestCompleted.wav")\n    call Preload("Sound\\\\Interface\\\\BattleNetTick.wav")\n')

# Espera de las bolsas: cuenta de 8 s con tic, después se borran las que queden y sale el cuadro.
cambia('''// Cada 0,5 s desde el final de la oleada: puntúa cuando no quedan bolsas en el suelo (a lo sumo 36 s).
function Punt_Esperar takes nothing returns nothing
    set Punt_Espera = Punt_Espera + 0.5
    if Bolsa_N > 0 and Punt_Espera < 36. and Ronda_Descanso then
        return
    endif
    call PauseTimer(Punt_Reloj)
    call Punt_Calcular()
endfunction
''', f'''// v18p: tic de reloj para todos, en cada segundo de la cuenta de las bolsas.
function Ronda_Tic takes nothing returns nothing
    if Ronda_TicSnd != null then
        call StopSound(Ronda_TicSnd, false, false)
        call SetSoundVolume(Ronda_TicSnd, 127)
        call StartSound(Ronda_TicSnd)
    endif
endfunction

// Cada 0,5 s desde el final de la oleada. v18p: si quedan bolsas, {BOLSA_S} s para recogerlas (Ronda_Resta en el HUD y un
// tic por segundo); después se borran las que queden (perdidas) y sale el cuadro de resultados.
function Punt_Esperar takes nothing returns nothing
    set Punt_Espera = Punt_Espera + 0.5
    if Ronda_Fase == 1 and Bolsa_N > 0 and Punt_Espera < {BOLSA_S}. and Ronda_Descanso then
        if ModuloInteger(R2I(Punt_Espera * 2. + 0.01), 2) == 0 then
            set Ronda_Resta = {BOLSA_S} - R2I(Punt_Espera + 0.01)
            call Ronda_Tic()
        endif
        return
    endif
    call PauseTimer(Punt_Reloj)
    loop
        exitwhen Bolsa_N <= 0
        set Punt_Perdidas = Punt_Perdidas + 1
        call Bolsa_Quitar(0)
    endloop
    set Ronda_Fase = 2
    set Ronda_Resta = 0
    call Punt_Calcular()
endfunction
''')

# Fin de la oleada: sin descanso ni golem todavía; plazo de las bolsas.
cambia('''        call TimerStart(Punt_Reloj, 0.5, true, function Punt_Esperar)
        set Ronda_Resta = Ronda_DESCANSO
        if Ronda_Numero >= Ronda_TOTAL then
            call TimerStart(CreateTimer(), 2., false, function Ronda_Victoria)
        else
            call TimerStart(Ronda_Reloj, 1., true, function Ronda_Cuenta)
            call DevTienda_Bajar()
        endif
''', f'''        // v18p: primero las bolsas ({BOLSA_S} s como mucho) y el cuadro; el descanso y el golem, al cerrarse el cuadro.
        set Ronda_Fase = 2
        set Ronda_Resta = 0
        if Bolsa_N > 0 then
            set Ronda_Fase = 1
            set Ronda_Resta = {BOLSA_S}
            loop
                exitwhen p >= Bolsa_N
                set Bolsa_T[p] = RMinBJ(Bolsa_T[p], {BOLSA_S}.)
                set p = p + 1
            endloop
            call Ronda_Tic()
        endif
        call TimerStart(Punt_Reloj, 0.5, true, function Punt_Esperar)
        if Ronda_Numero >= Ronda_TOTAL then
            call TimerStart(CreateTimer(), 2., false, function Ronda_Victoria)
        endif
''')
cambia('function Ronda_AlTerminar takes nothing returns nothing\n',
       '''// v18p: al cerrarse el cuadro de resultados (Punt_Tick, por nombre): tiempo de compra y golem.
function Ronda_DescansoEmpezar takes nothing returns nothing
    if Ronda_Fase != 2 or not Ronda_Descanso then
        return
    endif
    set Ronda_Fase = 0
    if Ronda_Numero >= Ronda_TOTAL then
        return
    endif
    set Ronda_Resta = Ronda_DESCANSO
    call TimerStart(Ronda_Reloj, 1., true, function Ronda_Cuenta)
    call DevTienda_Bajar()
endfunction

function Ronda_AlTerminar takes nothing returns nothing
''')
# El bucle de las bolsas usa p, que el bucle del oro deja en 12: se pone a 0 antes.
cambia('        set Punt_Espera = 0.\n        if Punt_Reloj == null then\n',
       '        set Punt_Espera = 0.\n        set p = 0\n        if Punt_Reloj == null then\n')
cambia('    if Punt_T >= Punt_Sale + 0.5 then\n        set Punt_T = -1.\n        call Punt_BucleFin()\n',
       '    if Punt_T >= Punt_Sale + 0.5 then\n        set Punt_T = -1.\n        call Punt_BucleFin()\n'
       '        call ExecuteFunc("Ronda_DescansoEmpezar")\n')

# HUD: título por fase; parpadeo con la cuenta de las bolsas, no durante el cuadro.
cambia('''        if Ronda_Descanso then
            set t="Tiempo de compra"
            set c=I2S(Ronda_Resta)
''', '''        if Ronda_Descanso and Ronda_Fase == 1 then
            set t="Recoge las bolsas"
            set c=I2S(Ronda_Resta)
        elseif Ronda_Descanso and Ronda_Fase == 2 then
            set t="Resultados"
            set c=""
        elseif Ronda_Descanso then
            set t="Tiempo de compra"
            set c=I2S(Ronda_Resta)
''')
cambia('        if ( Ronda_Descanso and Ronda_Resta <= 10 and ModuloInteger(',
       '        if ( Ronda_Descanso and Ronda_Fase != 2 and Ronda_Resta <= 10 and ModuloInteger(')

if modo in ('prueba', 'lan'):
    assert src.count('-v18o-' if modo == 'lan' else 'lat\\\\v18o-') == 4
    src = src.replace('-v18o-', '-v18p-') if modo == 'lan' else src.replace('lat\\\\v18o-', 'lat\\\\v18p-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18p', modo or 'normal')
