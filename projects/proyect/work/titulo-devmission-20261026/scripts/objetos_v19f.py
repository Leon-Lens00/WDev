#!/usr/bin/env python3
"""v19f (19/11/2026): Dragon Fist (A0BZ, base ACmp Impale) y Burning Attack (A05B, base AOsh Shockwave) no empezaban
nunca. Registro v19e-prueba: 3 copias de Dragon Fist y 4 de Burning Attack aceptaron la orden sin CHANNEL ni EFFECT;
las otras 14 técnicas sí sacaron EFFECT. Las dos traen distancia de onda 10 (Uim1) y 0 (Osh3) desde D.O.N.
Cambio: las dos pasan a base ANrf con los datos de Death Ball (A0IW), que lanza al momento en el mismo registro:
Hbz1-6 a 0 (1 y 3 enteros), acas 0, adur/ahdu 0,01. Se conservan nombre, icono, textos, teclas, aani, alcance por nivel y niveles.
Los disparadores de D.O.N sólo leen GetSpellAbilityId y GetSpellTargetLoc, así que no cambian. Orden: rainoffire.
Uso: objetos_v19f.py DIR_ENTRADA (w3a de v19d) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
R = lambda v: struct.pack('<f', v)
I = lambda v: struct.pack('<i', v)
Z = b'\0\0\0\0'
QUITAR = {b'Uim1', b'Uim2', b'Uim3', b'Uim4', b'Osh1', b'Osh2', b'Osh3', b'Osh4', b'aare', b'atar', b'amat',
          b'amsp', b'abuf', b'acas', b'adur', b'ahdu'}

b = (src / 'war3map.w3a').read_bytes()
va, ta = parse_w3a(b)
assert encode_w3a(va, ta) == b
hechos = {}
for t in ta:
    for k, (base, rid, mods) in enumerate(t):
        if rid in (b'A05B', b'A0BZ'):
            assert base == {b'A05B': b'AOsh', b'A0BZ': b'ACmp'}[rid], (rid, base)
            alev = [struct.unpack('<i', m[4])[0] for m in mods if m[0] == b'alev'][0]
            niveles = max(4, alev)
            nuevos = [m for m in mods if m[0] not in QUITAR]
            for n in range(1, niveles + 1):
                for c in (2, 4, 5, 6):
                    nuevos.append((b'Hbz%d' % c, 2, n, c, R(0.), Z))
                nuevos.append((b'Hbz1', 0, n, 1, I(0), Z))
                nuevos.append((b'Hbz3', 0, n, 3, I(0), Z))
                nuevos.append((b'acas', 2, n, 0, R(0.), Z))
                nuevos.append((b'adur', 2, n, 0, R(0.01), Z))
                nuevos.append((b'ahdu', 2, n, 0, R(0.01), Z))
                nuevos.append((b'aare', 2, n, 0, R(250.), Z))
            t[k] = (b'ANrf', rid, nuevos)
            hechos[rid] = alev
assert set(hechos) == {b'A05B', b'A0BZ'}, hechos
(dst / 'war3map.w3a').write_bytes(encode_w3a(va, ta))
print('w3a v19f: A05B y A0BZ con base ANrf', hechos)
