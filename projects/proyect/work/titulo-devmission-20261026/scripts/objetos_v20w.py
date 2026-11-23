#!/usr/bin/env python3
"""v20w (20/11/2026): botones del controlador.
- Libro de armas 'AWlb' (Aspb, V) arriba a la izquierda con las 7 armas Aw00..Aw06; cada arma, 1 s de recarga.
- 'AwFa' (F, arma anterior) y 'AwGa' (G, arma siguiente) a su derecha; Disparar (Arp1, A) arriba a la derecha.
- Las habilidades de los personajes (los puentes de sus libros) pasan a la fila de abajo, fuera del libro.
- Dash: texto con 3 cargas cada 2 s y sin cortar la recarga.
Uso: objetos_v20w.py DIR_ENTRADA (w3a de v20s) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda s: s.encode('utf-8')

b = (src / 'war3map.w3a').read_bytes()
va, ta = parse_w3a(b)
assert encode_w3a(va, ta) == b, 'w3a: ida y vuelta distinta'
filas = {}
for n, t in enumerate(ta):
    for k, (base, rid, mods) in enumerate(t):
        filas[rid if rid != b'\0\0\0\0' else base] = (n, k)
for nuevo in (b'AWlb', b'AwFa', b'AwGa'):
    assert nuevo not in filas, nuevo


def fila(r):
    n, k = filas[r]
    return ta[n][k]


def poner(r, cambios):
    """cambios: {(mid, nivel): valor empaquetado}; cada uno debe existir y cambia una vez."""
    n, k = filas[r]
    base, rid, mods = ta[n][k]
    hechos = set()
    nuevos = []
    for mid, ty, lv, dat, v, end in mods:
        c = (mid, lv)
        if c in cambios:
            v = cambios[c]
            hechos.add(c)
        nuevos.append((mid, ty, lv, dat, v, end))
    assert hechos == set(cambios), (r, set(cambios) - hechos)
    ta[n][k] = (base, rid, nuevos)


def copiar(r, nueva, cambios):
    base, rid, mods = fila(r)
    n, _ = filas[r]
    ta[n].append((base, nueva, list(mods)))
    filas[nueva] = (n, len(ta[n]) - 1)
    poner(nueva, cambios)


# 1) Armas: 1 s de recarga en los 6 niveles.
for c in range(7):
    r = b'Aw0' + bytes([48 + c])
    poner(r, {(b'acdn', lv): R(1.0) for lv in range(1, 7)})

# 2) Libro de armas, copiado del libro de Goku.
copiar(b'ALGk', b'AWlb', {
    (b'anam', 0): S('Libro de armas'),
    (b'aart', 0): S('war3mapImported\\BTNArma2.blp'),
    (b'abpx', 0): I(0), (b'abpy', 0): I(0), (b'ahky', 0): S('V'),
    (b'atp1', 1): S('Armas (|cffffcc00V|r)'),
    (b'aub1', 1): S('Elige el arma activa entre las que tienes. Cada arma tiene 1 s de recarga. '
                    '|cffffcc00F|r: arma anterior; |cffffcc00G|r: arma siguiente.'),
    (b'spb1', 1): S('Aw01,Aw02,Aw03,Aw04,Aw05,Aw06,Aw00'),
    (b'spb3', 1): I(7), (b'spb4', 1): I(7),
})

# 3) F y G, copiados de la recarga vieja (Aw08, sin objetivo).
for nueva, tecla, x, orden, icono, nombre, texto in (
        (b'AwFa', 'F', 1, 'spiritlink', 'BTNReplay-SpeedDown', 'Arma anterior',
         'Cambia al arma anterior que tengas. Cambiar de arma corta la recarga.'),
        (b'AwGa', 'G', 2, 'unholyfrenzy', 'BTNReplay-SpeedUp', 'Arma siguiente',
         'Cambia al arma siguiente que tengas. Cambiar de arma corta la recarga.')):
    copiar(b'Aw08', nueva, {
        (b'anam', 0): S(nombre),
        (b'aart', 0): S('ReplaceableTextures\\CommandButtons\\' + icono + '.blp'),
        (b'abpx', 0): I(x), (b'abpy', 0): I(0), (b'ahky', 0): S(tecla),
        (b'atp1', 1): S(nombre + ' (|cffffcc00' + tecla + '|r)'),
        (b'aub1', 1): S(texto),
        (b'Ncl6', 1): S(orden),
    })

# 4) Disparar arriba a la derecha.
poner(b'Arp1', {(b'abpx', 0): I(3), (b'abpy', 0): I(0)})

# 5) Dash: el texto nuevo.
poner(b'Ard1', {(b'aub1', 1): S('Avanza 450 en 0.375 s hacia el punto elegido. Cancela el disparo rápido, '
                                'pero no la recarga. Sin maná: 3 cargas, que vuelven de una en una cada 2 s.')})

# 6) Puentes de las habilidades: fila de abajo (la columna sigue siendo su tecla).
libros = (b'ALGk', b'ALTb', b'ALCb', b'ALTa', b'ALFz', b'ALTr', b'ALNa')
puentes = []
for lb in libros:
    lista = [m[4] for m in fila(lb)[2] if m[0] == b'spb1' and m[2] == 1]
    assert len(lista) == 1, lb
    puentes += lista[0].decode().split(',')
assert len(puentes) == len(set(puentes)) == 27, puentes
for p in puentes:
    m = {mm[0]: mm for mm in fila(p.encode())[2] if mm[2] == 0}
    assert struct.unpack('<i', m[b'abpy'][4])[0] == 0, p
    poner(p.encode(), {(b'abpy', 0): I(2)})

(dst / 'war3map.w3a').write_bytes(encode_w3a(va, ta))
print('v20w: libro de armas AWlb, F AwFa, G AwGa, Arp1 arriba a la derecha, 27 puentes abajo, armas 1 s')
print('puentes:', ' '.join(puentes))
