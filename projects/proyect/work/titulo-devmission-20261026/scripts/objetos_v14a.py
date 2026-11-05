#!/usr/bin/env python3
"""Objetos de v14a: botones nuevos y destructibles de textura. Parte de los archivos extraídos de v13m.

w3a: Disparo pasa a A en (3,0), Dash a (2,0); nuevas Aw00-Aw06 (armas, 3 niveles), Aw07/Aw09 (disparo rápido
apagado/encendido) y Aw08 (recarga), todas ANcl sin objetivo y con orden propia.
w3b/imp: texturas con su destructible DS.. e imports nuevos.

Uso: objetos_v14a.py DIR_ENTRADA DIR_SALIDA
"""
from pathlib import Path
import struct, sys
S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
from objetos_v12k import parse_w3a, encode_w3a
import w3b_modos
from armas_v14a import ARMAS, CATS, HOTKEYS, POS, ORDENES, TEX

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
Z = b'\0\0\0\0'


def texto(mid, level, s, data=0):
    return (mid, 3, level, data, s.encode('utf-8'), Z)


def entero(mid, level, n, data=0):
    return (mid, 0, level, data, struct.pack('<I', n), Z)


def real(mid, level, x, data=0):
    return (mid, 2, level, data, struct.pack('<f', x), Z)


def instantanea(rid, nombre, tecla, icono, x, y, orden, tips):
    """tips: lista de (título, texto) por nivel."""
    mods = [texto(b'anam', 0, nombre), entero(b'aher', 0, 0), entero(b'alev', 0, len(tips)),
            texto(b'ahky', 0, tecla), texto(b'aart', 0, icono), entero(b'abpx', 0, x), entero(b'abpy', 0, y)]
    for n, (titulo, cuerpo) in enumerate(tips, 1):
        mods += [texto(b'atp1', n, titulo), texto(b'aub1', n, cuerpo), real(b'aran', n, 0), real(b'acdn', n, 0),
                 entero(b'amcs', n, 0), real(b'acas', n, 0), real(b'Ncl1', n, 0, 1), entero(b'Ncl2', n, 0, 2),
                 entero(b'Ncl3', n, 1, 3), real(b'Ncl4', n, 0, 4), entero(b'Ncl5', n, 0, 5), texto(b'Ncl6', n, orden, 6)]
    return (b'ANcl', rid.encode(), mods)


def tocar(fila, cambios):
    mods = []
    for m in fila[2]:
        clave = (m[0], m[2])
        if clave in cambios:
            v = cambios[clave]
            m = (m[0], m[1], m[2], m[3], v.encode('utf-8') if isinstance(v, str) else struct.pack('<I', v), m[5])
        mods.append(m)
    return (fila[0], fila[1], mods)


version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
filas = tablas[1]
for i, f in enumerate(filas):
    if f[1] == b'Arp1':
        filas[i] = tocar(f, {(b'anam', 0): 'Disparo', (b'ahky', 0): 'A', (b'atp1', 1): 'Disparar (|cffffcc00A|r)',
                             (b'aub1', 1): 'Dispara el arma activa hacia el punto elegido. Con disparo rápido activo suelta seis balas al ritmo del arma.',
                             (b'abpx', 0): 3, (b'abpy', 0): 0})
    elif f[1] == b'Ard1':
        filas[i] = tocar(f, {(b'abpx', 0): 2, (b'abpy', 0): 0,
                             (b'aub1', 1): 'Avanza 450 en 0.375 s hacia el punto elegido. Cancela disparo rápido y recarga.'})
assert not {b'Aw00', b'Aw09'} & {f[1] for f in filas}

for c, cat in enumerate(CATS):
    tips = []
    for t in range(3):
        a = ARMAS[c * 3 + t]
        tips.append((f'{a[0]} T{t + 1} (|cffffcc00{HOTKEYS[c]}|r)', f'Activa esta arma. {a[14]}.'))
    filas.append(instantanea(f'Aw0{c}', cat, HOTKEYS[c], f'war3mapImported\\BTNArma{c}.blp', *POS[c], ORDENES[c], tips))
filas.append(instantanea('Aw07', 'Disparo rápido apagado', 'F',
                         'ReplaceableTextures\\CommandButtonsDisabled\\DISBTNBerserkForTrolls.blp', 0, 0, 'roar',
                         [('Activar disparo rápido (|cffffcc00F|r)', 'Cada A suelta seis balas al ritmo del arma con movimiento artificial.')]))
filas.append(instantanea('Aw09', 'Disparo rápido encendido', 'F',
                         'ReplaceableTextures\\CommandButtons\\BTNBerserkForTrolls.blp', 0, 0, 'roar',
                         [('Apagar disparo rápido (|cffffcc00F|r)', 'Vuelve al disparo de una bala, sin movimiento artificial.')]))
filas.append(instantanea('Aw08', 'Recarga', 'R', 'ReplaceableTextures\\CommandButtons\\BTNLoad.blp', 1, 0, 'stomp',
                         [('Recargar (|cffffcc00R|r)', 'Pasa balas de la reserva al cargador. El dash y cambiar de arma la cancelan.')]))
salida = encode_w3a(version, tablas)
assert parse_w3a(salida)[1][1][-1][1] == b'Aw08'
(dst / 'war3map.w3a').write_bytes(salida)

imports = [f'war3mapImported\\{n}.blp' for n in TEX]
imports += [f'war3mapImported\\BTNArma{c}.blp' for c in range(7)]
imports += ['war3mapImported\\ShopPlano.mdx', 'war3mapImported\\ConoCuchillo.blp', 'war3mapImported\\ConoCuchillo.mdx']
imports += [f'war3mapImported\\ShopHit{n}.mdx' for n in ('Cat', 'Row', 'Wide', 'Btn')]
w3b_modos.add([(rid, n) for n, rid in TEX.items()], imports,
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
