#!/usr/bin/env python3
"""v18c (15/11/2026): objetos sobre los de v18b.
- 'DSC0': destructible con war3mapImported\\SupCaja.blp (fondo propio de las tarjetas de la súper élite) y su import.
- Élites 'ne0k' y jefes 'nj0X': escala (usca) = modelScale del común × factor de tamanos_v18c.py, y selección (ussc)
  = la del común (UnitHitShape del j) × el mismo factor, como hacían objetos_v14h/v14l.
Uso: objetos_v18c.py DIR_ENTRADA (w3u, w3b, imp, j de v18b) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode
from objetos_v14g import formas
from tamanos_v18c import ESCALA, ids

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
w3b_modos.add([('DSC0', 'SupCaja')], ['war3mapImported\\SupCaja.blp'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])

forma = formas((src / 'war3map.j').read_text(encoding='latin-1'))
f32 = lambda x: struct.pack('<f', float(x))
b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
quiero = {rid: (t, f) for rid, t, f, _ in ids()}
hechos = set()
for i, (base, new, mods) in enumerate(tablas[1]):
    rid = new.decode()
    if rid in quiero:
        t, f = quiero[rid]
        assert [m for m in mods if m[0] == b'usca'], rid
        mods = [m for m in mods if m[0] not in (b'usca', b'ussc')] + [
            (b'usca', 1, f32(ESCALA[t] * f), b'\0\0\0\0'), (b'ussc', 1, f32(round(forma[t][0] * f, 3)), b'\0\0\0\0')]
        tablas[1][i] = (base, new, mods)
        hechos.add(rid)
assert hechos == set(quiero), set(quiero) - hechos
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3u:', len(hechos), 'élites y jefes reescalados')
