#!/usr/bin/env python3
"""Objetos de v14zf (06/11/2026): Recargar batería (Aw0A, V) y el relleno blanco de la barra de batería.

w3a: Aw0A, canal sin objetivo en la casilla libre (3,2) del controlador, orden propia «resurrection» y sin efectos
(como v14d hace con Aw08). w3b/imp: la textura HudCarga de v15a (DS0F), que el script tiñe por encima del marco
HudBlindaje (DS0E) bajo la vida del héroe.

Uso: objetos_v14zf.py DIR_ENTRADA DIR_SALIDA (war3map.w3a, war3map.w3b y war3map.imp extraídos de v14ze)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
import w3b_modos

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
Z = b'\0\0\0\0'


def texto(mid, level, s, data=0):
    return (mid, 3, level, data, s.encode('utf-8'), Z)


def entero(mid, level, n, data=0):
    return (mid, 0, level, data, struct.pack('<I', n), Z)


def real(mid, level, x, data=0):
    return (mid, 2, level, data, struct.pack('<f', x), Z)


# Como instantanea() de objetos_v14a.py, con un nivel y los efectos vacíos de objetos_v14d.py.
mods = [texto(b'anam', 0, 'Recargar batería'), entero(b'aher', 0, 0), entero(b'alev', 0, 1), texto(b'ahky', 0, 'V'),
        texto(b'aart', 0, 'ReplaceableTextures\\CommandButtons\\BTNManaRecharge.blp'), entero(b'abpx', 0, 3),
        entero(b'abpy', 0, 2),
        texto(b'atp1', 1, 'Recargar batería (|cffffcc00V|r)'),
        texto(b'aub1', 1, 'Gasta una recarga y llena la batería de la luz. Se empieza con 3 y cada descanso da 2 más. '
                          'Con la batería por debajo del 10% la luz se va apagando.'),
        real(b'aran', 1, 0), real(b'acdn', 1, 0), entero(b'amcs', 1, 0), real(b'acas', 1, 0), real(b'Ncl1', 1, 0, 1),
        entero(b'Ncl2', 1, 0, 2), entero(b'Ncl3', 1, 1, 3), real(b'Ncl4', 1, 0, 4), entero(b'Ncl5', 1, 0, 5),
        texto(b'Ncl6', 1, 'resurrection', 6)]
mods += [(c, 3, 0, 0, b'', Z) for c in (b'aeat', b'atat', b'acat')]

version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
assert parse_w3a(encode_w3a(version, tablas)) == (version, tablas)
ids = {f[1] for f in tablas[1]}
assert b'Aw0A' not in ids and b'Aw08' in ids
for f in tablas[1]:  # la casilla (3,2) y la tecla V siguen libres entre las del controlador
    g = {(m[0], m[2]): m[4] for m in f[2]}
    if f[1] in (b'Arp1', b'Ard1', b'Aw08') or f[1][:3] == b'Aw0':
        assert g.get((b'ahky', 0)) != b'V' and (g.get((b'abpx', 0)), g.get((b'abpy', 0))) != (struct.pack('<I', 3), struct.pack('<I', 2)), f[1]
tablas[1].append((b'ANcl', b'Aw0A', mods))
salida = encode_w3a(version, tablas)
assert parse_w3a(salida)[1][1][-1][1] == b'Aw0A'
(dst / 'war3map.w3a').write_bytes(salida)
w3b_modos.add([('DS0F', 'HudCarga')], ['war3mapImported\\HudCarga.blp'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
