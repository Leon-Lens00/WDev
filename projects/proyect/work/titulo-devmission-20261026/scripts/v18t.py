#!/usr/bin/env python3
"""v18t-prueba (15/11/2026): comando de prueba "-punt [N]" para sacar el cuadro de resultados al momento (Leon).

Sólo en la variante de prueba (como "-pres"); el mapa normal sigue siendo v18s.
- "-punt": cuadro con resultados altos y todos los sonidos: 30 bolsas recogidas, 6 perdidas, 3 caídas, 3 estrellas.
- "-punt N": N bolsas recogidas (1..60); lo demás igual.
- No toca la ronda: sólo funciona sin otro cuadro en pantalla y fuera de la cuenta de bolsas y de la muestra
  (Ronda_Fase 0); al cerrarse no empieza el descanso (Ronda_DescansoEmpezar exige Ronda_Fase 2).
- Pisa los contadores de la ronda en curso (bolsas y caídas): usarlo para probar sonidos, no en una ronda que se mide.
Registros v18s -> v18t.  Uso: v18t.py ENTRADA.j SALIDA.j prueba
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
assert modo == 'prueba'


def cambia(viejo, nuevo, veces=1):
    global src
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('// v18p: tic de reloj para todos, en cada segundo de la cuenta de las bolsas.\n', '''// v18t-prueba: "-punt [N]" saca el cuadro de resultados con resultados altos para oír sus sonidos.
function Punt_Comando takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer n = 30
    if Punt_T >= 0. or Ronda_Fase != 0 or Cua_MuestraOn then
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 4, "-punt: ahora no (hay otro cuadro o cuenta en curso)")
        return
    endif
    if StringLength(s) > 6 then
        set n = IMaxBJ(1, IMinBJ(60, S2I(SubString(s, 6, StringLength(s)))))
    endif
    set Punt_Cogidas = n
    set Punt_Perdidas = 6
    set Punt_Soltadas = n + 6
    set Punt_Caidas = 3
    set Punt_Estrellas = 3
    set Punt_Ver = Punt_Ver + 1
    call Punt_Preparar()
    set Punt_T = 0.
    call Bolsa_Anotar("-punt: recogidas " + I2S(n) + ", perdidas 6, caidas 3, estrellas 3")
endfunction

function Punt_Registrar takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer p = 0
    loop
        exitwhen p > 11
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-punt", false)
        set p = p + 1
    endloop
    call TriggerAddAction(t, function Punt_Comando)
    set t = null
endfunction

// v18p: tic de reloj para todos, en cada segundo de la cuenta de las bolsas.
''')
cambia('''        call TriggerRegisterPlayerChatEvent(t, Player(p), "-pres", false)
        set p = p + 1
    endloop
    call TriggerAddAction(t, function JefePres_Comando)
    set t = null
''', '''        call TriggerRegisterPlayerChatEvent(t, Player(p), "-pres", false)
        set p = p + 1
    endloop
    call TriggerAddAction(t, function JefePres_Comando)
    set t = null
    call ExecuteFunc("Punt_Registrar")
''')
assert src.count('lat\\\\v18s-') == 4
src = src.replace('lat\\\\v18s-', 'lat\\\\v18t-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18t prueba')
