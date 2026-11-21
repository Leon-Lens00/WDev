#!/usr/bin/env python3
"""v14zw (07/11/2026): el personaje elegido en la intro vuelve a ser el que entra a la partida.

Causa: v12y.py (entrada directa, «siempre el Tauren») quitó de Game_Cuerpo la rama `Hero_Choice[p] == 1 -> 'h006'`.
Cuando volvió la intro nadie la restauró: Game_Enter seguía calculando id e icono, pero el cuerpo lo crea Game_Cuerpo
con 'h005' fijo, así que quien elegía a Cairne entraba con el Tauren y el icono de Cairne en la barra. Game_Volver
(reaparición) también pasa por Game_Cuerpo, así que conserva la elección.
Entrada_Directa no toca Hero_Choice (vale 0): las pruebas sin intro siguen entrando con el Tauren.
Uso: v14zw.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, '''function Game_Cuerpo takes integer p,real x,real y returns nothing
    local integer id= 'h005'
    set Game_Hero[p]=CreateUnit(''', '''function Game_Cuerpo takes integer p,real x,real y returns nothing
    local integer id= 'h005'
    // v14zw: the hero chosen in the intro (cell 1 is Cairne); v12y had left only the Tauren.
    if Hero_Choice[p] == 1 then
        set id='h006'
    endif
    set Game_Hero[p]=CreateUnit(''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('ok', len(s))
