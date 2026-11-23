#!/usr/bin/env python3
"""v20r (20/11/2026), fase 1 del rework de habilidades (docs/planes/devmission-rework-habilidades-v20r.md).
Libros con Q W E R: fuera Power Up (Goku, Freezer, Trunks), Finish Sign, Destructo Disc, Kage Bunshin, Garra y Rugido
del Tauren, Lanza y Marca de Cairne y las tres pasivas (siguen por script, sin casilla). Spirit Bomb pasa a la E,
Tótem del trueno a la W y Senpuu Odama y Kyuubi Chakra Blast comparten la W (se alternan por script según el Kyuubi).
Sólo cambia el w3a; recarga y maná de v20q.
Uso: objetos_v20r.py DIR_ENTRADA (w3a de v20q) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
I = lambda v: struct.pack('<i', v)
LIBROS = {
    b'ALGk': 'AGk1,AGk2,AGk5,AGk3',
    b'ALFz': 'AFz3,AFz5,AFz2,AFz4',
    b'ALTr': 'ATr4,ATr2,ATr3,ATr5',
    b'ALNa': 'ANa5,ANa2,ANa6,ANa4,ANa3',
    b'ALTb': 'ATb1,ATb2,ATb3,ATb4',
    b'ALCb': 'ACb1,ACb5,ACb3,ACb4',
}
# puente: (tecla vieja, tecla nueva, columna)
MUEVE = {b'AGk5': ('T', 'E', 2), b'ANa2': ('T', 'W', 1), b'ANa6': ('D', 'W', 1), b'ACb5': ('A', 'W', 1)}
NOTA_SENPUU = 'En modo Kyuubi la W pasa a ser Kyuubi Chakra Blast.'.encode('utf-8')

b = (src / 'war3map.w3a').read_bytes()
va, ta = parse_w3a(b)
assert encode_w3a(va, ta) == b, 'w3a: ida y vuelta distinta'
hechos = set()
for t in ta:
    for k, (base, rid, mods) in enumerate(t):
        if rid in LIBROS:
            n = LIBROS[rid].count(',') + 1
            nuevos = []
            for mid, ty, lv, dat, v, end in mods:
                if mid == b'spb1':
                    v = LIBROS[rid].encode()
                elif mid in (b'spb3', b'spb4'):
                    v = I(n)
                nuevos.append((mid, ty, lv, dat, v, end))
        elif rid in MUEVE:
            vieja, nueva, col = MUEVE[rid]
            nuevos = []
            for mid, ty, lv, dat, v, end in mods:
                if mid == b'ahky':
                    assert v == vieja.encode(), (rid, v); v = nueva.encode()
                elif mid == b'atp1':
                    viejo = f'(|cffffcc00{vieja}|r)'.encode()
                    assert v.count(viejo) == 1, (rid, v); v = v.replace(viejo, f'(|cffffcc00{nueva}|r)'.encode())
                elif mid == b'abpx':
                    v = I(col)
                elif mid == b'abpy':
                    v = I(0)
                elif mid == b'aub1' and rid == b'ANa2':
                    i = v.index(b'|n|n|cff808080')
                    v = v[:i] + b' ' + NOTA_SENPUU + v[i:]
                nuevos.append((mid, ty, lv, dat, v, end))
        else:
            continue
        t[k] = (base, rid, nuevos)
        hechos.add(rid)
assert hechos == set(LIBROS) | set(MUEVE), (set(LIBROS) | set(MUEVE)) - hechos
(dst / 'war3map.w3a').write_bytes(encode_w3a(va, ta))
print('v20r:', len(LIBROS), 'libros,', len(MUEVE), 'puentes movidos')
