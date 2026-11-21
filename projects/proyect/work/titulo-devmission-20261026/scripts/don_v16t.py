#!/usr/bin/env python3
"""v16t-don (12/11/2026): v16t-dbz (selección, créditos) con el código DBZ de Battle Stadium D.O.N trasplantado tal
cual (don_trasplante.py) en lugar de las recetas aproximadas de v16t-dbz1. Añade sus globales, sus funciones antes de
dbz.j y Don_Init (por ExecuteFunc, con su propio límite de operaciones) tras Dbz_Init.
Uso: don_v16t.py v16t-dbz/war3map.j GLOBALES.j FUNCIONES.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
glob = crlf(Path(sys.argv[2]).read_bytes())
func = crlf(Path(sys.argv[3]).read_bytes())


def una(antes, despues):
    global j
    assert j.count(antes) == 1, (antes, j.count(antes))
    j = j.replace(antes, despues)


una(b'boolean array Dbz_Muerto\r\nendglobals\r\n',
    b'boolean array Dbz_Muerto\r\n// DON (v16t-don): variables del trasplante de Battle Stadium D.O.N 2.1a.\r\n' + glob + b'endglobals\r\n')
una(b'\r\nfunction Dbz_Nombre takes integer k returns string\r\n',
    b'\r\n' + func + b'\r\nfunction Dbz_Nombre takes integer k returns string\r\n')
# Cada personaje para un solo jugador: las variables de hueco fijo de DON no son MUI (y Dev Mission lo pide igual).
LIBRE = (b'// v16t-don: un personaje DBZ por jugador.\r\n'
         b'function Dbz_Libre takes integer p, integer k returns boolean\r\n'
         b'    local integer q = 0\r\n'
         b'    loop\r\n'
         b'        exitwhen q > 7\r\n'
         b'        if q != p and Dbz_K[q] == k and Dbz_U[q] != null and UnitAlive(Dbz_U[q]) then\r\n'
         b'            return false\r\n'
         b'        endif\r\n'
         b'        set q = q + 1\r\n'
         b'    endloop\r\n'
         b'    return true\r\n'
         b'endfunction\r\n')
una(b'\r\nfunction Dbz_Clic takes nothing returns nothing\r\n', b'\r\n' + LIBRE + b'\r\nfunction Dbz_Clic takes nothing returns nothing\r\n')
una(b'                    elseif k >= 0 then\r\n                        call DialogDisplay(Player(p), Dbz_D[p], false)\r\n                        call Dbz_Crear(p, k)\r\n',
    b'                    elseif k >= 0 and not Dbz_Libre(p, k) then\r\n'
    b'                        call DisplayTimedTextToPlayer(Player(p), 0., 0., 5., Dbz_Nombre(k) + " ya lo tiene otro jugador.")\r\n'
    b'                        call Dbz_Pagina(p, k / 8)\r\n'
    b'                    elseif k >= 0 then\r\n                        call DialogDisplay(Player(p), Dbz_D[p], false)\r\n                        call Dbz_Crear(p, k)\r\n')
una(b'    call Dbz_Init()\r\n', b'    call Dbz_Init()\r\n    call ExecuteFunc("Don_Init")\r\n')
una('Fase 1: modelos, iconos y habilidades de base nativa. Las habilidades hechas por script en D.O.N se rehacen por tandas sobre el núcleo Missile del mapa (Goku y Vegeta primero).'.encode('utf-8'),
    'Habilidades con el código original de D.O.N trasplantado tal cual: mismos efectos, tiempos y daño (a nivel 1). Cada personaje, para un solo jugador. El movimiento pasa al núcleo Missile del mapa personaje a personaje.'.encode('utf-8'))
Path(sys.argv[4]).write_bytes(j)
print('don: globales, funciones, Don_Init, un personaje por jugador')
