#!/usr/bin/env python3
"""Objetos y tabla de daño de v14l (05/11/2026): armaduras propias en las ranuras de defensa del motor.

| Armadura (nuestra) | udty    | Unidades                                           |
Ahora todos los enemigos (oleada, élites y jefes) son medium; la tabla de abajo es el reparto para después (LUEGO).
| Orgánica           | none    | ntrh, nmsn y sus élites                            |
| Ágil               | small   | nmcf, nnsw y sus élites                            |
| Acorazada          | medium  | nmtw, nmmu y sus élites                            |
| Caparazón          | large   | nlpr, nlds y sus élites                            |
| Pétrea             | fort    | ntrg, ntrd y sus élites                            |
| Escudo             | divine  | ninguna aún (espera armas de Energía)              |
| Colosal            | hero    | los jefes nj02..nj0A                               |
| Jugador            | normal  | h005 Tauren y h006 Cairne (antes hero)             |

La ranura normal pasa a los personajes del jugador con la columna hero de antes (miscgame.txt), así el daño que reciben
de los enemigos no cambia; Etérea queda sin ranura. Las demás columnas son la tabla acordada con Leon. La defensa
(udef) no cambia. Las élites son objetos propios: no heredan lo que se cambia en su unidad base y llevan su udty.
Falla si falta alguna unidad.

Uso: objetos_v14l.py IN_W3U OUT_W3U IN_MISC OUT_MISC WAR3MAP_J (el de v14k, para las formas de UnitHitShape)
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode
from objetos_v14g import ESCALA, escalada, formas

BASES = {'nmcf': 'small', 'nlpr': 'large', 'ntrh': 'none', 'nmtw': 'medium', 'nmsn': 'none',
         'nlds': 'large', 'nmmu': 'medium', 'nnsw': 'small', 'ntrg': 'fort', 'ntrd': 'fort'}
LUEGO = dict(BASES, h005='normal', h006='normal')
LUEGO.update({f'ne0{k}': BASES[b] for k, b in enumerate(BASES)})
LUEGO.update({f'nj0{c}': 'hero' for c in '23456789A'})
# Decisión de Leon (05/11/2026): mientras las armas usen sólo Estándar, todos los enemigos llevan una sola armadura
# (medium, Acorazada); LUEGO guarda el reparto acordado para cuando vuelvan los demás tipos de daño.
ARMADURA = {u: ('normal' if u in ('h005', 'h006') else 'medium') for u in LUEGO}

# Balance por tamaño (Leon, 05/11/2026): con un solo tipo de daño lo que separa a los enemigos es la defensa (udef, 6 %
# por punto con DAMAGE_TYPE_NORMAL) y la velocidad (umvs; antes todos 0-6 de defensa y 270). Pequeños rápidos y sin
# defensa, medianos intermedios, grandes lentos y blindados. Élites +2 y jefes +4 de defensa sobre su tamaño, con su
# velocidad. El tamaño sale del modelo y del radio de golpe (DevWave_Slots). Personajes: sin cambios.
TALLA = {'nmcf': 0, 'nlpr': 0, 'ntrh': 0, 'nnsw': 0, 'nmtw': 1, 'nmsn': 1, 'nlds': 1, 'nmmu': 2, 'ntrg': 2, 'ntrd': 2}
DEF_TALLA, VEL_TALLA = (0, 3, 6), (320, 270, 230)
DEFENSA, VELOCIDAD = {}, {}
for k, b in enumerate(BASES):
    t = TALLA[b]
    for u, extra in ((b, 0), (f'ne0{k}', 2), (f'nj0{"123456789A"[k]}', 4)):
        if u in LUEGO:
            DEFENSA[u], VELOCIDAD[u] = DEF_TALLA[t] + extra, VEL_TALLA[t]

# Columnas del motor: small, medium, large, fort, normal, hero, divine, none
#                 = Ágil, Acorazada, Caparazón, Pétrea, Jugador, Colosal, Escudo, Orgánica.
TABLA = {
    'DamageBonusNormal': (1.00, 1.50, 1.00, 0.75, 1.00, 1.00, 0.75, 1.00),  # Impacto
    'DamageBonusPierce': (1.50, 1.00, 0.50, 0.50, 0.50, 1.00, 0.75, 1.50),  # Perforante
    'DamageBonusSiege':  (1.00, 0.75, 1.00, 1.75, 0.50, 0.75, 0.50, 1.25),  # Explosivo
    'DamageBonusMagic':  (0.50, 1.00, 1.75, 1.25, 0.50, 1.25, 0.75, 0.75),  # Antiblindaje
    'DamageBonusChaos':  (1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00),  # Verdadero
    'DamageBonusSpells': (1.00, 1.00, 1.00, 1.00, 0.70, 0.75, 1.00, 1.00),  # Habilidad
    'DamageBonusHero':   (1.00, 1.00, 0.75, 0.75, 1.00, 1.00, 2.00, 1.00),  # Energía
}

# Élites (Leon, 05/11/2026): escala × 1,8 (antes 2,1) y vida base 320 = 0,40 × 800 (antes 360; v14l.py sube el resto
# al aparecer con 0,40 de la del jefe). La selección (ussc) sigue a la escala, como en objetos_v14h.py.
ELITE, VIDA_ELITE = 1.8, 320
BASES_L = list(BASES)
w_in, w_out, m_in, m_out = sys.argv[1:5]
FORMA = formas(Path(sys.argv[5]).read_text(encoding='latin-1'))
src = Path(w_in).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'round trip differs'
hechas = set()
for tab in tables:
    for i, (base, new, mods) in enumerate(tab):
        rid = (base if new == b'\0\0\0\0' else new).decode()
        if rid in ARMADURA:
            mods = [x for x in mods if x[0] != b'udty'] + [(b'udty', 3, ARMADURA[rid].encode(), b'\0\0\0\0')]
            if rid.startswith('ne0'):
                t = BASES_L[int(rid[3])]
                mods = [x for x in mods if x[0] not in (b'usca', b'ussc', b'uhpm')] + [
                    (b'usca', 1, struct.pack('<f', ESCALA[t] * ELITE), b'\0\0\0\0'),
                    (b'ussc', 1, struct.pack('<f', escalada(FORMA[t], ELITE)[0]), b'\0\0\0\0'),
                    (b'uhpm', 0, struct.pack('<i', VIDA_ELITE), b'\0\0\0\0')]
            if rid in DEFENSA:
                mods = [x for x in mods if x[0] not in (b'udef', b'umvs')] + [
                    (b'udef', 0, struct.pack('<i', DEFENSA[rid]), b'\0\0\0\0'),
                    (b'umvs', 0, struct.pack('<i', VELOCIDAD[rid]), b'\0\0\0\0')]
            tab[i] = (base, new, mods)
            hechas.add(rid)
assert hechas == set(ARMADURA), sorted(set(ARMADURA) - hechas)
Path(w_out).write_bytes(encode(version, tables))

misc = Path(m_in).read_bytes().decode('latin-1')
assert 'DamageBonus' not in misc and misc.count('[Misc]\n') == 1
lineas = ''.join(f'{k}={",".join(f"{v:.2f}" for v in t)}\n' for k, t in TABLA.items())
Path(m_out).write_bytes(misc.replace('[Misc]\n', '[Misc]\n' + lineas).encode('latin-1'))
print('ok', len(hechas), 'unidades')
