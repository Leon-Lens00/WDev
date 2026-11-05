#!/usr/bin/env python3
"""v14g: élites, jefes, iconos del localizador y la mejora de vida por jugador.

- Élites 'ne00'..'ne09': copia de cada tipo de oleada con sus cambios del mapa; vida y daño ×1,5, escala ×1,25 y tinte
  al 60%.
- Jefes 'nj02'..'nj0A': el tipo nuevo de cada ronda 2-10; vida 800 × (1 + 0,75 × (ronda − 1)), daño ×2,5, escala ×1,8 y
  la mejora 'Rdjv' en sus mejoras usadas.
- Iconos 'hbj2'..'hbjA': copia de 'hbi0' con el modelo UI\\HealthBarsHorizontal\\JefeIcono<r>.mdx, que es
  HealthIconTauren con el BTN nativo del jefe y plano de prioridad 3 (delante del marco de vida) y el cuadro
  centrado en el origen; escala 0,5.
- Esfera 'ubj0': copia de 'ubs0' (Ubershield del tablero de estrategia) con war3mapImported\\JefeEsfera.mdx
  (esfera_v14g.py: plana frente a la cámara y rubí).
- war3map.w3q nuevo con 'Rdjv' (base 'Rhan'): efecto rhpo, +100% por nivel, 5 niveles (6 jugadores).
Élites y jefes escalan también la selección (`ussc`) y la colisión (`ucol`, máximo 200) con su escala, partiendo de
los valores que el script registra en UnitHitShape para el tipo original; v14g.py registra los mismos en el script.
Falla si un id ya existe.

Uso: objetos_v14g.py IN_W3U ICONO_MDX SALIDA_DIR WAR3MAP_J
"""
from pathlib import Path
import json, re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

TIPOS = ['nmcf', 'nlpr', 'ntrh', 'nmtw', 'nmsn', 'nlds', 'nmmu', 'nnsw', 'ntrg', 'ntrd']
# unitui.slk: modelScale y tinte de cada tipo; nombres e iconos de *unitstrings/func.txt.
ESCALA = {'nmcf': .8, 'nlpr': .55, 'ntrh': .4, 'nmtw': 1., 'nmsn': 1.1, 'nlds': .8, 'nmmu': 2., 'nnsw': 1., 'ntrg': 1., 'ntrd': 1.2}
TINTE = {'nmcf': (255, 255, 128), 'nlds': (250, 250, 100), 'nmsn': (192, 192, 255), 'ntrh': (192, 192, 255)}
NOMBRE = {'nmcf': "Mur'gul Cliffrunner", 'nlpr': 'Makrura Prawn', 'ntrh': 'Sea Turtle Hatchling', 'nmtw': "Mur'gul Tidewarrior",
          'nmsn': "Mur'gul Snarecaster", 'nlds': 'Makrura Deepseer', 'nmmu': 'Murloc Mutant', 'nnsw': 'Naga Siren',
          'ntrg': 'Gargantuan Sea Turtle', 'ntrd': 'Dragon Turtle'}
ICONO = {'nlpr': 'BTNLobstrokkRed', 'ntrh': 'BTNSeaTurtleGreen', 'nmtw': 'BTNMurgulTideWarrior', 'nmsn': 'BTNMurgulShadowCaster',
         'nlds': 'BTNLobstrokkGreen', 'nmmu': 'BTNMurlocMutant', 'nnsw': 'BTNSeaWitch', 'ntrg': 'BTNSeaTurtleGreen',
         'ntrd': 'BTNSeaTurtleRed'}
LETRA = '23456789A'  # ronda 2..10
MEJORA = b'Rdjv'
VIDA_BASE = 800.


def formas(j):
    """Selección y colisión registradas en UnitHitShape para cada tipo de oleada."""
    return {t: (float(a), float(b)) for t, a, b in re.findall(r"call s__UnitHitShape_register\('(\w{4})' , ([\d.]+) , ([\d.]+)\)", j) if t in TIPOS}


def escalada(forma, f):
    return round(forma[0] * f, 3), min(200., round(forma[1] * f, 1))


def prioridad(mdx, plano):
    """Plano de prioridad de cada material. El HUD no usa prueba de profundidad: el orden lo da este plano (marco de
    vida 1-2), así que el icono del jefe necesita uno mayor para no quedar debajo."""
    i = 4
    while i < len(mdx):
        tag, n = mdx[i:i + 4], struct.unpack('<I', mdx[i + 4:i + 8])[0]
        if tag == b'MTLS':
            o, out = i + 8, bytearray(mdx)
            while o < i + 8 + n:
                out[o + 4:o + 8] = struct.pack('<i', plano)
                o += struct.unpack('<I', mdx[o:o + 4])[0]
            return bytes(out)
        i += 8 + n
    raise ValueError('sin MTLS')


def centrado(mdx):
    """El cuadro del icono centrado en el origen (su hueso billboard gira ahí): así la esfera 'ubj0', también
    billboard y centrada, coincide con él colocada en el mismo punto, en cualquier lugar de la pantalla."""
    b = bytearray(mdx)
    p = b.index(b'VRTX')
    n = struct.unpack_from('<I', b, p + 4)[0]
    v = [struct.unpack_from('<3f', b, p + 8 + 12 * i) for i in range(n)]
    cy, cz = (min(y for _, y, _ in v) + max(y for _, y, _ in v)) / 2, (min(z for *_, z in v) + max(z for *_, z in v)) / 2
    for i, (x, y, z) in enumerate(v):
        struct.pack_into('<3f', b, p + 8 + 12 * i, x, y - cy, z - cz)

    def caja(o):  # radio, mínimo y máximo de una extensión
        for k in (o + 4, o + 16):
            x, y, z = struct.unpack_from('<3f', b, k)
            struct.pack_into('<3f', b, k, x, y - cy, z - cz)
    caja(b.index(b'MODL') + 8 + 340)
    s = b.index(b'SEQS')
    for k in range(struct.unpack_from('<I', b, s + 4)[0] // 132):
        caja(s + 8 + 132 * k + 104)
    m = b.index(b'MATS', p)
    q = m + 8 + 4 * struct.unpack_from('<I', b, m + 4)[0] + 12
    caja(q)
    for k in range(struct.unpack_from('<I', b, q + 28)[0]):
        caja(q + 32 + 28 * k)
    return bytes(b)


def i32(n): return struct.pack('<i', int(n))
def f32(x): return struct.pack('<f', float(x))


def copia(mods, cambios):
    """Mods del tipo en la tabla original con los cambios aplicados; los campos nuevos se añaden al final."""
    out, vistos = [], set()
    for mid, ty, v, _ in mods:
        if mid in cambios:
            ty, v = cambios[mid]; vistos.add(mid)
        out.append((mid, ty, v, b'\0\0\0\0'))
    out += [(mid, ty, v, b'\0\0\0\0') for mid, (ty, v) in cambios.items() if mid not in vistos]
    return out


def entero(mods, mid):
    return next(struct.unpack('<i', v)[0] for m, ty, v, _ in mods if m == mid)


if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    icono_mdx = Path(sys.argv[2]).read_bytes()
    out = Path(sys.argv[3])
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    usados = {r[1] for t in tables for r in t} | {r[0] for r in tables[0]}
    orig = {base.decode(): mods for base, _, mods in tables[0]}
    forma = formas(Path(sys.argv[4]).read_text(encoding='latin-1'))
    assert sorted(forma) == sorted(TIPOS), sorted(forma)
    nuevos = []

    for k, t in enumerate(TIPOS):
        m = orig[t]
        r, g, b = TINTE.get(t, (255, 255, 255))
        nuevos.append((t.encode(), f'ne0{k}'.encode(), copia(m, {
            b'uhpm': (0, i32(round(entero(m, b'uhpm') * 1.5))), b'ua1b': (0, i32(round(entero(m, b'ua1b') * 1.5))),
            b'ua1s': (0, i32(max(1, round(entero(m, b'ua1s') * 1.5)))), b'usca': (1, f32(ESCALA[t] * 1.25)),
            b'uclr': (0, i32(r * .6)), b'uclg': (0, i32(g * .6)), b'uclb': (0, i32(b * .6)),
            b'ussc': (1, f32(escalada(forma[t], 1.25)[0])), b'ucol': (2, f32(escalada(forma[t], 1.25)[1])),
            b'unam': (3, ('Élite: ' + NOMBRE[t]).encode())})))

    hbi0 = next(mods for base, new, mods in tables[1] if new == b'hbi0')
    hbi0_base = next(base for base, new, _ in tables[1] if new == b'hbi0')
    modelos = {}
    for ronda in range(2, 11):
        t, c = TIPOS[ronda - 1], LETRA[ronda - 2]
        m = orig[t]
        nuevos.append((t.encode(), f'nj0{c}'.encode(), copia(m, {
            b'uhpm': (0, i32(round(VIDA_BASE * (1 + .75 * (ronda - 1))))), b'ua1b': (0, i32(round(entero(m, b'ua1b') * 2.5))),
            b'ua1s': (0, i32(max(1, round(entero(m, b'ua1s') * 2.5)))), b'usca': (1, f32(ESCALA[t] * 1.8)),
            b'ussc': (1, f32(escalada(forma[t], 1.8)[0])), b'ucol': (2, f32(escalada(forma[t], 1.8)[1])),
            b'upgr': (3, MEJORA), b'unam': (3, ('Jefe: ' + NOMBRE[t]).encode())})))
        modelo = f'UI\\HealthBarsHorizontal\\JefeIcono{c}.mdx'
        nuevos.append((hbi0_base, f'hbj{c}'.encode(), copia(hbi0, {
            b'umdl': (3, modelo.encode()), b'unam': (3, f'Boss icon {t}'.encode()), b'usca': (1, f32(.5))})))
        viejo = b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'
        nuevo = f'ReplaceableTextures\\CommandButtons\\{ICONO[t]}.blp'.encode()
        i = icono_mdx.index(viejo)
        assert icono_mdx[i + len(viejo):i + 260] == bytes(260 - len(viejo)), 'texture field not zero padded'
        modelos[f'JefeIcono{c}.mdx'] = centrado(prioridad(icono_mdx[:i] + nuevo.ljust(260, b'\0') + icono_mdx[i + 260:], 3))

    ubs0_base, _, ubs0 = next(r for r in tables[1] if r[1] == b'ubs0')
    nuevos.append((ubs0_base, b'ubj0', copia(ubs0, {b'umdl': (3, b'war3mapImported\\JefeEsfera.mdx')})))

    for base, new, _ in nuevos:
        assert new not in usados, new
    tables[1] += nuevos
    (out / 'war3map.w3u').write_bytes(encode(version, tables))
    for nombre, datos in modelos.items():
        (out / nombre).write_bytes(datos)

    # w3q con niveles: id, tipo, nivel, dato, valor, fin; como en devmission-v096/war3map.w3q.
    def campo(mid, ty, v):
        return mid + struct.pack('<III', ty, 0, 0) + (v + b'\0' if ty == 3 else v) + b'\0\0\0\0'
    campos = [campo(b'glvl', 0, i32(5)), campo(b'gef1', 3, b'rhpo'), campo(b'gba1', 2, f32(1.)), campo(b'gmo1', 2, f32(1.)),
              campo(b'gnam', 3, 'Vida de jefe por jugador'.encode())]
    w3q = struct.pack('<II', 2, 0) + struct.pack('<I', 1) + b'Rhan' + MEJORA + struct.pack('<I', len(campos)) + b''.join(campos)
    (out / 'war3map.w3q').write_bytes(w3q)
    print(json.dumps({'unidades': [n.decode() for _, n, _ in nuevos], 'modelos': sorted(modelos), 'w3q': len(w3q)}))
