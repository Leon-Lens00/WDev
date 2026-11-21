#!/usr/bin/env python3
"""Modelos de la presentación de jefe v17h (14/11/2026): el modelo del juego de cada jefe girado hacia la cámara de juego.

Leon (14/11/2026): "saldra el modelo del boss tambien ejecutando la animacion de ataque al aparecer en pantalla" y "por
si el modelo no se muestra bien, tenemos el modelo de referencia de la hidra" (PresHydra, mdx_rotar.py).

Mismo método que mdx_rotar.py, con la cámara de juego en lugar de la cenital del título: la cámara mira a +Y bajando
56° (ojo en (0, -1597.176, +2367.912) del punto mirado, Camera_create). Se añade un helper con un KGRT fijo en una
secuencia global nueva y los nodos raíz pasan a ser sus hijos; el modelo queda con:
- arriba del modelo (+Z) = arriba de la pantalla U = (0, 0.829, 0.559);
- frente del modelo (+X) hacia la cámara B = (0, -0.559, 0.829), girado GIRO grados hacia la izquierda de la pantalla
  (-X del mundo), en tres cuartos como el dibujo del vídeo;
- la unidad se crea con facing 0 (ejes del modelo = ejes del mundo).
Además todas las capas pasan a sin sombreado y sin niebla (banderas 0x1 y 0x20): la noche y la niebla de Storm
oscurecían el modelo; delante de la cámara debe verse con los colores de su textura.

Imprime por modelo el alto y el ancho en pantalla y la x del origen dentro de su ancho, medidos sobre los vértices de
la pose de unión (en unidades del modelo, sin escala de la unidad).
Uso (python con numpy): jefe_modelos_v17h.py DIR_MDX_BASE DIR_SALIDA GIRO
"""
from pathlib import Path
import json, math, struct, sys
import numpy as np
sys.path.insert(0, str(Path(__file__).resolve().parent))
import mdx_cizalla as mc

MODELOS = ['Lobstrokkred', 'SeaTurtleRange', 'MurgulTideWarrior', 'MurgulShadowCaster', 'Lobstrokkblue',
           'MurlocMutant', 'NagaSiren', 'GiantSeaTurtle', 'DragonSeaTurtle']

ojo = np.array([0, -1597.176, 2367.912])
F = -ojo / np.linalg.norm(ojo)          # hacia donde mira la cámara
U = np.array([0, -F[2], F[1]])          # arriba de la pantalla
B = -F                                  # hacia la cámara
R = np.cross(F, U)                      # derecha de la pantalla
assert np.allclose(R, [1, 0, 0])


def matriz(giro):
    a = math.radians(giro)
    x = math.cos(a) * B - math.sin(a) * R
    z = U
    y = np.cross(z, x)
    m = np.column_stack([x, y, z])
    assert abs(np.linalg.det(m) - 1) < 1e-9
    return m


def capas_sin_sombra(d):
    """MTLS: material (tam, prioridad, banderas, 'LAYS', n) y capas (tam, filtro, banderas, ...)."""
    o, n = 0, 0
    while o < len(d):
        tam = struct.unpack_from('<I', d, o)[0]
        assert d[o + 12:o + 16] == b'LAYS'
        k = struct.unpack_from('<I', d, o + 16)[0]
        c = o + 20
        for _ in range(k):
            lt = struct.unpack_from('<I', d, c)[0]
            fl = struct.unpack_from('<I', d, c + 8)[0]
            struct.pack_into('<I', d, c + 8, fl | 0x1 | 0x20)
            c += lt
            n += 1
        assert c == o + tam
        o += tam
    assert o == len(d)
    return n


def texturas_de_material(mtls, texs):
    """Ruta de la textura de la primera capa de cada material."""
    rutas = [texs[i + 4:i + 264].split(b'\0')[0].decode('latin-1') for i in range(0, len(texs), 268)]
    out, o = [], 0
    while o < len(mtls):
        tam = struct.unpack_from('<I', mtls, o)[0]
        t = struct.unpack_from('<I', mtls, o + 20 + 12)[0]
        out.append(rutas[t] if t < len(rutas) else '')
        o += tam
    return out


def vertices(d, tex_mat):
    """Vértices de los geosets, sin los de vísceras (gutz) ni estelas de agua, que sólo salen al morir o nadar."""
    out, o = [], 0
    while o < len(d):
        tam = struct.unpack_from('<I', d, o)[0]
        assert d[o + 4:o + 8] == b'VRTX'
        k = struct.unpack_from('<I', d, o + 8)[0]
        g = bytes(d[o:o + tam])
        i = g.index(b'MATS')
        n = struct.unpack_from('<I', g, i + 4)[0]
        mat = struct.unpack_from('<I', g, i + 8 + 4 * n)[0]
        ruta = tex_mat[mat].lower()
        if 'gutz' not in ruta and 'wake' not in ruta:
            out.append(np.frombuffer(g[12:12 + 12 * k], '<f4').reshape(-1, 3))
        o += tam
    return np.concatenate(out)


def girar(src, m):
    cs = mc.chunks(src)
    tags = [t for t, _ in cs]
    pivots = next(d for t, d in cs if t == b'PIVT')
    heads = [(t, d, o) for t, d in cs if t in mc.NODES for o in mc.node_offsets(t, d)]
    ids = [struct.unpack_from('<I', d, o + 84)[0] for _, d, o in heads]
    assert ids == list(range(len(ids))) and len(pivots) == 12 * len(ids)
    # el helper va detrás de huesos, luces y helpers (los ids siguen el orden de los bloques)
    previos = [k for k, (t, _, _) in enumerate(heads) if t in (b'BONE', b'LITE', b'HELP')]
    h = max(previos) + 1 if previos else 0
    shift = lambda i: i + 1 if i != mc.NONE and i >= h else i
    roots = 0
    for t, d, o in heads:
        oid, par = struct.unpack_from('<II', d, o + 84)
        roots += par == mc.NONE
        struct.pack_into('<II', d, o + 84, shift(oid), h if par == mc.NONE else shift(par))
    pivots[12 * h:12 * h] = struct.pack('<3f', 0, 0, 0)
    if b'GLBS' not in tags:
        cs.insert(tags.index(b'SEQS') + 1, [b'GLBS', bytearray()])
        tags = [t for t, _ in cs]
    glbs = next(d for t, d in cs if t == b'GLBS')
    gs = len(glbs) // 4
    glbs += struct.pack('<I', 1000)
    if b'HELP' not in tags:
        tras = max(i for i, t in enumerate(tags) if t in (b'GEOA', b'GEOS', b'BONE', b'LITE'))
        cs.insert(tras + 1, [b'HELP', bytearray()])
    q = mc.quat(m)
    assert np.allclose(mc.rotmat(q), m, atol=1e-6)
    next(d for t, d in cs if t == b'HELP').extend(mc.helper('GiroCamara', h, mc.NONE, (b'KGRT', q), gs))
    capas = capas_sin_sombra(next(d for t, d in cs if t == b'MTLS'))
    tex_mat = texturas_de_material(next(d for t, d in cs if t == b'MTLS'), next(d for t, d in cs if t == b'TEXS'))
    v = vertices(next(d for t, d in cs if t == b'GEOS'), tex_mat)
    out = b'MDLX' + b''.join(t + struct.pack('<I', len(d)) + bytes(d) for t, d in cs)
    return out, v, roots, capas


if __name__ == '__main__':
    ent, sal, giro = Path(sys.argv[1]), Path(sys.argv[2]), float(sys.argv[3])
    sal.mkdir(parents=True, exist_ok=True)
    m = matriz(giro)
    datos = {}
    for k, nombre in enumerate(MODELOS):
        out, v, roots, capas = girar((ent / f'{nombre}.mdx').read_bytes(), m)
        w = v @ m.T                       # vértices en el mundo con la unidad a facing 0
        sx, sy = w @ R, w @ U             # derecha y arriba de la pantalla
        datos[nombre] = {'alto': round(float(sy.max() - sy.min()), 1), 'abajo': round(float(sy.min()), 1),
                         'izq': round(float(sx.min()), 1), 'der': round(float(sx.max()), 1),
                         'raices': roots, 'capas': capas}
        (sal / f'PresJefe{k + 2}.mdx').write_bytes(out)
    print(json.dumps(datos))
