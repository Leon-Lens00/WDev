#!/usr/bin/env python3
"""Ivan, Arch Sage de Twilight's Eve Final R4.13a (Donach & KryptonRazer), para probar sus habilidades en Dev Mission.

Prueba privada de Leon (12/11/2026). Copia de TeveF las filas de las 5 habilidades del Arch Sage (A04P, A04W, A04T,
A04U, A04X) y de los 9 dummies de la definitiva y de Boreas; las habilidades quedan con un solo nivel, sin marca de
héroe y con valores escalados a las oleadas de Dev Mission. Ivan es una unidad normal ('hIva', base Hblm, modelo
Kael.mdl) como los demás personajes ([[personajes-no-heroe]]).
Uso: objetos_ivan.py TEVEF.w3u TEVEF.w3a ENTRADA.w3u ENTRADA.w3a SALIDA.w3u SALIDA.w3a
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse
from objetos_v12k import encode_w3a, parse_w3a

tu, ta, u_in, a_in, u_out, a_out = sys.argv[1:7]
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')

# --- Habilidades: id TeveF -> (id nuevo, base, cambios {campo: (tipo, valor)}) ---
HAB = {
    b'A04W': (b'AIv0', {  # Boreas: el daño y el congelado los pone el script
        b'aart': S('ReplaceableTextures\\CommandButtons\\BTNBreathOfFrost.blp'),
        b'abpx': I(0), b'abpy': I(2), b'acdn': R(8.), b'amcs': I(40), b'ahdu': R(3.), b'adur': R(3.),
        b'atp1': S('Boreas (|cffffcc00Q|r)'),
        b'aub1': S('Invoca a Boreas, dios del viento del norte: 120 de daño caótico a los enemigos en 550 y los '
                   'congela 3 segundos.|n|n|cff808080Twilight\'s Eve Final: 900 por nivel.|r'),
    }),
    b'A04X': (b'AIv1', {  # Lightning Avenger: Forked Lightning nativo a 12 blancos
        b'aart': S('ReplaceableTextures\\CommandButtons\\BTNChainLightning.blp'),
        b'Ocl1': R(60.), b'Ocl2': I(12), b'acdn': R(1.5), b'amcs': I(25), b'abpx': I(1), b'abpy': I(2),
        b'atp1': S('Lightning Avenger (|cffffcc00W|r)'),
        b'aub1': S('Rayos rojos a 12 enemigos: 60 de daño a cada uno.|n|n|cff808080Twilight\'s Eve Final: 1500 '
                   'por nivel.|r'),
    }),
    b'A04T': (b'AIv2', {  # Warmth: aura de regeneración de maná sólo para Ivan
        b'Hab1': R(3.), b'abpx': I(2), b'abpy': I(2),
        b'atp1': S('Warmth'),
        b'aub1': S('Pasiva: +3 de regeneración de maná por segundo.|n|n|cff808080Twilight\'s Eve Final: 15 por '
                   'nivel.|r'),
    }),
    b'A04U': (b'AIv3', {  # Energy Shield: Mana Shield nativo, 80 % al maná
        b'aart': S('ReplaceableTextures\\CommandButtons\\BTNNeutralManaShield.blp'),
        b'auar': S('ReplaceableTextures\\CommandButtons\\BTNNeutralManaShield.blp'),
        b'Nms1': R(0.5), b'Nms2': R(0.8), b'abpx': I(3), b'abpy': I(2), b'aubx': I(3), b'auby': I(2),
        b'atp1': S('Activar Energy Shield (|cffffcc00R|r)'), b'aut1': S('Desactivar Energy Shield (|cffffcc00R|r)'),
        b'aub1': S('Absorbe el 80 % del daño recibido con maná: 0,5 de maná por punto de vida.'),
    }),
    b'A04P': (b'AIv4', {  # Twilight's Eve: Storm Bolt sin daño; la definitiva es el script
        b'aart': S('ReplaceableTextures\\CommandButtons\\BTNStarfall.blp'),
        b'arar': S('ReplaceableTextures\\CommandButtons\\BTNStarfall.blp'),
        b'abpx': I(3), b'abpy': I(1), b'amcs': I(200), b'acdn': R(30.), b'aran': R(900.),
        b'atp1': S('Twilight\'s Eve (|cffffcc00F|r)'),
        b'aub1': S('Definitiva: convierte el día en medianoche e invoca la destrucción sobre los enemigos a 700 del '
                   'blanco. Pausa a los aliados cercanos durante la secuencia.|n|n|cff808080Prueba: 30 s de '
                   'recarga, 200 de maná.|r'),
    }),
}

# --- Dummies: id TeveF -> (id nuevo, ruta nueva del modelo o None) ---
DUM = {b'h048': b'hIv0', b'h00V': b'hIv1', b'h00T': b'hIv2', b'h00S': b'hIv3', b'h00R': b'hIv4',
       b'h00W': b'hIv5', b'h00U': b'hIv6', b'h00Q': b'hIv7', b'h02A': b'hIv8'}

# 12/11/2026, Leon: la Tierra y sus explosiones 1,5 veces más grandes (2,0 -> 3,0). La altura de vuelo sube igual para
# que las explosiones sigan en el centro del planeta (modelo de z -129 a 350).
ESCALA = {
    (b'hIv4', b'usca'): 3.0,
    (b'hIv5', b'usca'): 0.6, (b'hIv5', b'umvh'): 360.,
    (b'hIv6', b'usca'): 1.65, (b'hIv6', b'umvh'): 360.,
    (b'hIv7', b'usca'): 3.3, (b'hIv7', b'umvh'): 360.,
}

# --- Ivan ---
IVAN = (b'Hblm', b'hIva', [
    (b'unam', 3, S('Ivan, Arch Sage'), Z), (b'umdl', 3, S('units\\human\\Kael\\Kael.mdl'), Z),
    (b'uico', 3, S('ReplaceableTextures\\CommandButtons\\BTNBloodMage2.blp'), Z),
    (b'uabi', 3, S('AIv0,AIv1,AIv2,AIv3,AIv4'), Z), (b'uhab', 3, b'', Z),
    (b'ustr', 0, I(1), Z), (b'uagi', 0, I(1), Z), (b'uint', 0, I(1), Z),
    (b'ustp', 2, R(0.), Z), (b'uagp', 2, R(0.), Z), (b'uinp', 2, R(0.), Z),
    (b'uhpm', 0, I(400), Z), (b'uhpr', 2, R(1.), Z), (b'umpm', 0, I(600), Z), (b'umpi', 0, I(600), Z),
    (b'umpr', 2, R(2.), Z), (b'udef', 2, R(2.), Z), (b'umvs', 0, I(300), Z),
    (b'ua1b', 0, I(24), Z), (b'ua1d', 0, I(1), Z), (b'ua1s', 0, I(6), Z), (b'ua1c', 2, R(1.5), Z),
    (b'ua1r', 0, I(600), Z), (b'ua1w', 3, S('missile'), Z), (b'ua1z', 0, I(900), Z),
    (b'ua1m', 3, S('Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl'), Z),
    (b'ugol', 0, I(0), Z), (b'ulum', 0, I(0), Z), (b'ufoo', 0, I(0), Z), (b'usid', 0, I(1400), Z),
    (b'usin', 0, I(800), Z), (b'uhot', 3, b'', Z), (b'utip', 3, S('Ivan, Arch Sage'), Z), (b'utub', 3, b'', Z),
])

_, tev_u = parse(Path(tu).read_bytes())
_, tev_a = parse_w3a(Path(ta).read_bytes())
uver, utab = parse(Path(u_in).read_bytes())
aver, atab = parse_w3a(Path(a_in).read_bytes())
assert encode(uver, utab) == Path(u_in).read_bytes()
assert encode_w3a(aver, atab) == Path(a_in).read_bytes()
usados = {r[1] for r in utab[1]} | {r[0] for r in utab[0]}
nuevos = set(DUM.values()) | {IVAN[1]}
assert not usados & nuevos, usados & nuevos
ausados = {r[1] for r in atab[1]} | {r[0] for r in atab[0]}
assert not ausados & {v[0] for v in HAB.values()}

tev_rows = {r[1]: r for r in tev_u[1]}
for old, new in DUM.items():
    base, _, mods = tev_rows[old]
    nm = []
    for mid, ty, v, end in mods:
        assert b'TRIGSTR' not in v, (old, mid)
        if (new, mid) in ESCALA:
            v = R(ESCALA[(new, mid)])
        nm.append((mid, ty, v, Z))
    utab[1].append((base, new, nm))
utab[1].append(IVAN)

tev_ab = {r[1]: r for r in tev_a[1]}
for old, (new, cambios) in HAB.items():
    base, _, mods = tev_ab[old]
    nm, vistos = [], set()
    for mid, ty, lvl, data, v, end in mods:
        if lvl > 1:
            continue
        if mid in (b'aret', b'arut', b'arhk', b'arpx', b'arpy', b'alsk', b'arlv', b'abuf'):
            continue  # aprendizaje de héroe y buffs propios de TeveF
        if mid == b'alev':
            v = I(1)
        if mid in cambios:
            v = cambios[mid]
        assert b'TRIGSTR' not in v, (old, mid)
        nm.append((mid, ty, lvl, data, v, Z)); vistos.add(mid)
    for mid, v in cambios.items():
        if mid not in vistos:
            ty = 3 if mid in (b'aart', b'arar', b'auar', b'atp1', b'aut1', b'aub1') else (0 if mid in (b'abpx', b'abpy', b'aubx', b'auby', b'amcs', b'Ocl2') else 2)
            lvl = 0 if mid in (b'aart', b'arar', b'auar', b'abpx', b'abpy', b'aubx', b'auby') else 1
            data = {b'Ocl1': 1, b'Ocl2': 2, b'Nms1': 1, b'Nms2': 2, b'Hab1': 1}.get(mid, 0)
            nm.append((mid, ty, lvl, data, v, Z))
    if b'aher' not in vistos:
        nm.append((b'aher', 0, 0, 0, I(0), Z))
    atab[1].append((base, new, nm))

# 12/11/2026, Leon (referencia Battle Stadium D.O.N): durante la definitiva todo va muy lento en lugar de pausado.
# Aura de lentitud (Tornado, Aasl) en un 'dumi' junto a Ivan: -90 % de movimiento y de ataque a todo lo vulnerable
# en 1800; Ivan queda fuera por estar invulnerable. El mínimo de MinUnitSpeed 50 evita que se queden parados.
assert b'AIv5' not in ausados
atab[1].append((b'Aasl', b'AIv5', [
    (b'anam', 3, 0, 0, S("Twilight's Eve: tiempo lento"), Z), (b'alev', 0, 0, 0, I(1), Z), (b'aher', 0, 0, 0, I(0), Z),
    (b'aare', 2, 1, 0, R(1800.), Z), (b'atar', 3, 1, 0, S('air,ground,enemy,friend,player,neutral,vuln'), Z),
    (b'Slo1', 2, 1, 1, R(-0.9), Z), (b'Slo2', 2, 1, 2, R(-0.9), Z),
]))

us = encode(uver, utab); As = encode_w3a(aver, atab)
assert encode(*parse(us)) == us and encode_w3a(*parse_w3a(As)) == As
Path(u_out).write_bytes(us); Path(a_out).write_bytes(As)
for b, n, m in atab[1][-6:]:
    print(n.decode(), b.decode(), ' '.join(f'{x[0].decode()}@{x[2]}' for x in m))
print('unidades:', ' '.join(r[1].decode() for r in utab[1][-10:]))
