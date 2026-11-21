#!/usr/bin/env python3
"""v17a (13/11/2026): la partida vuelve a empezar con la intro completa y el tutorial.

Leon (13/11/2026): "que empieze con la intro completa y el tutorial antes de entrar a partida a jugar predeterminado".

Orden nuevo: intro (3 s de negro, modelo y canción, Intro_Begin → Intro_Show → Intro_End) → título con la selección
de personaje y la presentación (Title_Begin … Pres_Finish → Title_Exit) → tutorial (Tut_Begin) → partida.
- Title_Init vuelve a arrancar Intro_Begin (v16a lo había cambiado por Tut_Begin).
- Tut_Begin vuelve a su condición original `if not Tut_Libre()` (v16t-ivan la dejó en `if true` y nunca se veía):
  sin hueco libre para el Tauren del tutorial (8 jugadores), se salta y entra a la partida.
- Title_Exit limpia el título como siempre, pero la parte que abre la partida (tienda, cámara de juego y
  ConversationUI___Start) pasa a Title_Partida. La primera vez lanza el tutorial (Tut_TrasTitulo) en su lugar.
- Tut_Entrar (fin del tutorial): si el título ya salió, llama a Title_Partida; si no, hace lo de antes.
Uso: v17a.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes.encode('utf-8')), crlf(despues.encode('utf-8'))
    assert j.count(antes) == 1, (antes[:90], j.count(antes))
    j = j.replace(antes, despues)


# --- intro al empezar ---
una('    call TimerStart(CreateTimer(), 0.1, false, function Tut_Begin)\n',
    '    // v17a: intro completa, título y presentación; el tutorial llega desde Title_Exit.\n'
    '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n')

# --- tutorial de nuevo activo ---
una('    if true then\n        // v16t-ivan: sin tutorial (modo de armas).\n',
    '    if not Tut_Libre() then\n')

# --- Title_Exit: la apertura de la partida pasa a Title_Partida ---
una('''    call Title_Cleanup()
    call ExecuteFunc("Shop_Construir")
    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
    call ResetToGameCamera(0)
    set s = GetPlayerStartLocation(GetLocalPlayer())
    call SetCameraPosition(GetStartLocationX(s), GetStartLocationY(s))
    call TimerStart(CreateTimer(), 0.2, false, function ConversationUI___Start)
endfunction
''', '''    call Title_Cleanup()
    if Tut_TrasTitulo then
        // v17a: primero el tutorial; su final (Tut_Entrar) abre la partida con Title_Partida.
        set Tut_TrasTitulo = false
        call ExecuteFunc("Tut_DesdeTitulo")
        return
    endif
    call Title_Partida()
endfunction
''')
una('function Title_Exit takes nothing returns nothing\n', '''// v17a: apertura de la partida (antes al final de Title_Exit): tienda, cámara de juego y comienzo.
function Title_Partida takes nothing returns nothing
    local integer s
    call ExecuteFunc("Shop_Construir")
    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
    call ResetToGameCamera(0)
    set s = GetPlayerStartLocation(GetLocalPlayer())
    call SetCameraPosition(GetStartLocationX(s), GetStartLocationY(s))
    call TimerStart(CreateTimer(), 0.2, false, function ConversationUI___Start)
endfunction

function Title_Exit takes nothing returns nothing
''')

# --- fin del tutorial ---
una('''function Tut_Entrar takes nothing returns nothing
    local integer p= 0
''', '''function Tut_Entrar takes nothing returns nothing
    local integer p= 0
    // v17a: el tutorial va después del título; al terminar sólo falta abrir la partida.
    if Title_Exited then
        call DestroyTimer(GetExpiredTimer())
        call Title_Partida()
        return
    endif
''')
una('function Title_Init takes nothing returns nothing\n', '''// v17a: Title_Exit llega aquí por ExecuteFunc (va después de Tut_Begin en el j).
function Tut_DesdeTitulo takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.2, false, function Tut_Begin)
endfunction

function Title_Init takes nothing returns nothing
''')
una('real Tut_X= 8000.\n', '// v17a: el tutorial se juega una vez, entre el título y la partida.\nboolean Tut_TrasTitulo= true\nreal Tut_X= 8000.\n')
Path(sys.argv[2]).write_bytes(j)
print('v17a: intro, título, tutorial, partida')
