#!/usr/bin/env python3
"""v16t-dbz (12/11/2026): v16t-ivan más los personajes DBZ de Battle Stadium D.O.N 2.1a para la prueba de Leon.
Añade los globales de dbz.j, sus funciones antes de main, Dbz_Init tras Ivan_Init, y hace que
ConversationUI___FollowCamera siga al personaje DBZ del jugador cuando lo tiene.
Uso: dbz_v16t.py v16t-ivan/war3map.j scripts/dbz.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
cuerpo = Path(sys.argv[2]).read_bytes().replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')

GLOBALES = b'\r\n'.join([
    b'// DBZ (v16t-dbz): personajes de Battle Stadium D.O.N 2.1a.',
    b'unit array Dbz_U',
    b'integer array Dbz_K',
    b'dialog array Dbz_D',
    b'button array Dbz_Btn',
    b'integer array Dbz_BtnK',
    b'boolean array Dbz_Visto',
    b'boolean array Dbz_Muerto',
    b'endglobals',
]) + b'\r\n'


def una(antes, despues):
    global j
    assert j.count(antes) == 1, (antes, j.count(antes))
    j = j.replace(antes, despues)


una(b'constant real IVAN_DANO_DEFINITIVA = 100000.\r\nendglobals\r\n',
    b'constant real IVAN_DANO_DEFINITIVA = 100000.\r\n' + GLOBALES)
una(b'            set u=Game_Hero[p]\r\n            if GetUnitTypeId(u) != 0 then\r\n                set x=GetUnitX(u)\r\n',
    b'            set u=Game_Hero[p]\r\n            if Dbz_U[p] != null and UnitAlive(Dbz_U[p]) then\r\n'
    b'                // v16t-dbz: la camara sigue al personaje DBZ.\r\n                set u=Dbz_U[p]\r\n            endif\r\n'
    b'            if GetUnitTypeId(u) != 0 then\r\n                set x=GetUnitX(u)\r\n')
una(b'\r\nfunction main takes nothing returns nothing\r\n', b'\r\n' + cuerpo + b'\r\nfunction main takes nothing returns nothing\r\n')
una(b'    call Ivan_Init()\r\n', b'    call Ivan_Init()\r\n    call Dbz_Init()\r\n')
Path(sys.argv[3]).write_bytes(j)
print('dbz: globales, camara, funciones, Dbz_Init')
