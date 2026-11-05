#!/usr/bin/env python3
"""Objetos de v14d: habilidades canal sin efectos y sin disparo rápido aparte; enemigos de rango con ataque a punto.

Canal trae efecto en el lanzador, el objetivo y el punto; aquí se dejan vacíos. Los cuatro de rango pasan a artillería:
el proyectil cae donde estaba el objetivo, lento y sin seguirlo, así que se puede esquivar.

Uso: objetos_v14d.py DIR_ENTRADA DIR_SALIDA (war3map.w3a y war3map.w3u)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
Z = b'\0\0\0\0'
VACIOS = {b'Arp1', b'Ard1', b'Aw08'} | {f'Aw0{c}'.encode() for c in range(7)}

version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
filas, n = [], 0
for f in tablas[1]:
    if f[1] in (b'Aw07', b'Aw09'):
        continue
    if f[1] in VACIOS:
        n += 1
        mods = [m for m in f[2] if m[0] not in (b'aeat', b'atat', b'acat')]
        mods += [(c, 3, 0, 0, b'', Z) for c in (b'aeat', b'atat', b'acat')]
        if f[1] == b'Arp1':
            cuerpo = 'Suelta seis disparos del arma activa a su ritmo, en movimiento, hacia el punto elegido.'
            mods = [(m[0], m[1], m[2], m[3], cuerpo.encode('utf-8'), m[5]) if m[0] == b'aub1' else m for m in mods]
        f = (f[0], f[1], mods)
    filas.append(f)
assert n == 10 and len(filas) == len(tablas[1]) - 2
tablas[1][:] = filas
salida = encode_w3a(version, tablas)
assert salida.count('Un disparo, sin dispersión'.encode()) == 1
salida = salida.replace('Un disparo, sin dispersión'.encode(), 'Sin dispersión'.encode())
(dst / 'war3map.w3a').write_bytes(salida)


def leer(b):
    p, salida = 4, []
    for _ in range(2):
        filas = []
        k = struct.unpack_from('<I', b, p)[0]
        p += 4
        for _ in range(k):
            ids = b[p:p + 8]
            m = struct.unpack_from('<I', b, p + 8)[0]
            p += 12
            mods = []
            for _ in range(m):
                c, t = b[p:p + 4], struct.unpack_from('<I', b, p + 4)[0]
                p += 8
                fin = b.index(b'\0', p) + 1 if t == 3 else p + 4
                mods.append((c, t, b[p:fin]))
                p = fin + 4
            filas.append((ids, mods))
        salida.append(filas)
    assert p == len(b)
    return b[:4], salida


def escribir(cabeza, partes):
    b = cabeza
    for filas in partes:
        b += struct.pack('<I', len(filas))
        for ids, mods in filas:
            b += ids + struct.pack('<I', len(mods))
            for c, t, v in mods:
                b += c + struct.pack('<I', t) + v + Z
    return b


def e(n):
    return struct.pack('<I', n)


def r(x):
    return struct.pack('<f', x)


def t(x):
    return x.encode() + b'\0'


# Cae a 600 por segundo: menos de un segundo a 500-600 de distancia, tiempo justo para apartarse.
PUNTO = [(b'ua1w', 3, t('artillery')), (b'ua1z', 0, e(600)), (b'uma1', 2, r(0.35)), (b'umh1', 0, e(0)),
         (b'ua1f', 0, e(60)), (b'ua1h', 0, e(100)), (b'ua1q', 0, e(140)), (b'uhd1', 2, r(0.5)), (b'uqd1', 2, r(0.25)),
         (b'ua1p', 3, t('ground,enemy')), (b'ua1g', 3, t('ground,structure,debris,item,ward'))]
RANGO = (b'ntrh', b'nmsn', b'nlds', b'nnsw')
cabeza, partes = leer((src / 'war3map.w3u').read_bytes())
nuevos = {m[0] for m in PUNTO}
hechos = 0
for parte in partes:
    for i, f in enumerate(parte):
        if f[0][4:8] in RANGO or (f[0][:4] in RANGO and f[0][4:8] == Z):
            print('rango', f[0], len(f[1]))
            parte[i] = (f[0], [m for m in f[1] if m[0] not in nuevos] + PUNTO)
            hechos += 1
assert hechos >= 4, hechos
(dst / 'war3map.w3u').write_bytes(escribir(cabeza, partes))
