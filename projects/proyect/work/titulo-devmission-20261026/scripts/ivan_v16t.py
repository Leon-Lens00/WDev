#!/usr/bin/env python3
"""v16t-ivan (12/11/2026): v16t más Ivan, Arch Sage de Twilight's Eve Final, para que Leon pruebe sus habilidades.
Añade los globales de ivan.j, sus funciones antes de main, Ivan_Init al final de main, y deja libre la cámara de
quien está dentro de la definitiva (ConversationUI___FollowCamera no la aplica mientras Ivan_Cine[p]).
Uso: ivan_v16t.py v16t/war3map.j scripts/ivan.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
cuerpo = Path(sys.argv[2]).read_bytes().replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')

GLOBALES = b'\r\n'.join([
    b'// Ivan (v16t-ivan): prueba de Twilight\'s Eve Final.',
    b'unit array Ivan_U',
    b'boolean array Ivan_Cine',
    b'player Ivan_Owner = null',
    b'unit Ivan_Caster = null',
    b'force Ivan_F = null',
    b'constant real Ivan_PX = -9000.',
    b'constant real Ivan_PY = 9300.',
    b'constant real IVAN_DANO_BOREAS = 120.',
    b'constant real IVAN_DANO_DEFINITIVA = 100000.',
    b'endglobals',
]) + b'\r\n'


def una(antes, despues):
    global j
    assert j.count(antes) == 1, (antes, j.count(antes))
    j = j.replace(antes, despues)


una(b'string array Shop_Frase\r\nendglobals\r\n', b'string array Shop_Frase\r\n' + GLOBALES)
una(b'            if Shop_Open[p] then\r\n                call Shop_Camara(p)\r\n',
    b'            if Ivan_Cine[p] then\r\n                // La definitiva de Ivan mueve esta camara.\r\n'
    b'            elseif Shop_Open[p] then\r\n                call Shop_Camara(p)\r\n')
una(b'\r\nfunction main takes nothing returns nothing\r\n', b'\r\n' + cuerpo + b'\r\nfunction main takes nothing returns nothing\r\n')
una(b'    call TrackTest_Init()\r\n', b'    call TrackTest_Init()\r\n    call Ivan_Init()\r\n')
# 12/11/2026, Leon: el tutorial pertenece al modo de armas y queda desactivado aquí. Tut_Begin toma siempre su salida
# de "8 huecos ocupados": Tut_Entrar, que mete a todos los jugadores directamente en la partida.
una(b'    if not Tut_Libre() then\r\n        call RemoveLocation(l)\r\n',
    b'    if true then\r\n        // v16t-ivan: sin tutorial (modo de armas).\r\n        call RemoveLocation(l)\r\n')
Path(sys.argv[3]).write_bytes(j)
print('ivan: globales, camara, funciones, Ivan_Init')
