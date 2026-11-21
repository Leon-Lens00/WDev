#!/usr/bin/env python3
"""v16t-dbz1 (12/11/2026): v16t-dbz más la tanda 1 de habilidades DBZ (Goku y Vegeta) sobre el núcleo Missile.
Añade los globales de dbz_t1.j, sus funciones antes de las de dbz.j, el reinicio de forma en Dbz_Crear y DbzT_Init
tras Dbz_Init; actualiza el texto de la misión de prueba.
Uso: dbz_t1.py v16t-dbz/war3map.j scripts/dbz_t1.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
cuerpo = Path(sys.argv[2]).read_bytes().replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')

GLOBALES = b'\r\n'.join([
    b'// DBZ tanda 1 (v16t-dbz1): habilidades de Goku y Vegeta sobre Missile.',
    b'constant integer DBZT_SID = 200',
    b'hashtable DbzT_H = null',
    b'group DbzT_G = null',
    b'integer array DbzT_SegN',
    b'string array DbzT_SegModelo',
    b'real array DbzT_SegEscala',
    b'integer array DbzT_Paso',
    b'real array DbzT_Explosion',
    b'unit array DbzT_Jinete',
    b'integer array DbzT_Forma',
    b'effect array DbzT_CabezaFx',
    b'effect array DbzT_AuraFx',
    b'endglobals',
]) + b'\r\n'


def una(antes, despues):
    global j
    assert j.count(antes) == 1, (antes, j.count(antes))
    j = j.replace(antes, despues)


una(b'boolean array Dbz_Muerto\r\nendglobals\r\n', b'boolean array Dbz_Muerto\r\n' + GLOBALES)
una(b'\r\nfunction Dbz_Nombre takes integer k returns string\r\n',
    b'\r\n' + cuerpo + b'\r\nfunction Dbz_Nombre takes integer k returns string\r\n')
una(b'    set Dbz_K[p] = k\r\n', b'    set Dbz_K[p] = k\r\n    call DbzT_Reiniciar(p)\r\n')
una(b'    call Dbz_Init()\r\n', b'    call Dbz_Init()\r\n    call DbzT_Init()\r\n')
una(b'Las habilidades hechas por script en D.O.N se rehacen por tandas sobre el n\xc3\xbacleo Missile del mapa (Goku y Vegeta primero).',
    b'Las habilidades hechas por script en D.O.N se rehacen por tandas sobre el n\xc3\xbacleo Missile del mapa. Tanda 1 lista: Goku y Vegeta (Power Up sube de forma, +25 % de da\xc3\xb1o por forma).')
Path(sys.argv[3]).write_bytes(j)
print('dbz_t1: globales, funciones, reinicio de forma, DbzT_Init')
