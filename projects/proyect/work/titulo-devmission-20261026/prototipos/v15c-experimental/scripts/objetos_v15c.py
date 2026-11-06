#!/usr/bin/env python3
"""Objetos de v15c (05/11/2026): texturas de la tienda del prototipo (DS17..DS1R) y textos de las 4 armas.

Las texturas son las de Proyect/work/tienda-mejoras-20261105/texturas (generar.py), importadas como
war3mapImported\\Tm<nombre>.blp; v15c.py usa los mismos ids. Las armas ya no tienen 3 tiers con nombre: su modelo
(7 por arma) y sus mejoras se compran en la tienda, así que el texto del botón no nombra el modelo.

Uso: objetos_v15c.py DIR_ENTRADA DIR_SALIDA (war3map.w3a, war3map.w3b y war3map.imp de v15a)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
import w3b_modos

TEX = [('DS17', 'NodeOn'), ('DS18', 'NodeOff'), ('DS19', 'ModelOn'), ('DS1A', 'ModelOff'), ('DS1B', 'NodeGlow'),
       ('DS1C', 'Mejora-velocidad'), ('DS1D', 'Mejora-dano'), ('DS1E', 'Mejora-alcance'), ('DS1F', 'Mejora-precision'),
       ('DS1G', 'Mejora-cadencia'), ('DS1I', 'Mejora-recarga'), ('DS1J', 'Mejora-perforacion'),
       ('DS1K', 'Mejora-perdigones'), ('DS1L', 'Flecha'), ('DS1M', 'Marca'), ('DS1N', 'Candado'),
       ('DS1O', 'Modelo-pistola'), ('DS1P', 'Modelo-subfusil'), ('DS1Q', 'Modelo-escopeta'),
       ('DS1R', 'Modelo-francotirador')]

if __name__ == '__main__':
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    dst.mkdir(exist_ok=True)
    ARMAS = {b'Aw00': ('Pistola', 'Q', 'la pistola'), b'Aw01': ('Subfusil', 'W', 'el subfusil'),
             b'Aw02': ('Escopeta', 'E', 'la escopeta'), b'Aw03': ('Francotirador', 'R', 'el francotirador')}
    TEXTOS = {}
    for rid, (nombre, tecla, art) in ARMAS.items():
        cambios = {}
        for t in (1, 2, 3):
            cambios[(b'atp1', t)] = f'{nombre} (|cffffcc00{tecla}|r)'
            cambios[(b'aub1', t)] = f'Activa {art}. Su modelo (7, uno por tier) y sus mejoras se compran en la tienda.'
        TEXTOS[rid] = cambios
    version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
    hechos = set()
    for i, f in enumerate(tablas[1]):
        if f[1] not in TEXTOS:
            continue
        cambios, vistos, mods = TEXTOS[f[1]], set(), []
        for m in f[2]:
            clave = (m[0], m[2])
            if clave in cambios:
                assert m[1] == 3, clave
                m = (m[0], m[1], m[2], m[3], cambios[clave].encode('utf-8'), m[5])
                vistos.add(clave)
            mods.append(m)
        assert vistos == set(cambios), (f[1], set(cambios) - vistos)
        tablas[1][i] = (f[0], f[1], mods)
        hechos.add(f[1])
    assert hechos == set(TEXTOS), set(TEXTOS) - hechos
    (dst / 'war3map.w3a').write_bytes(encode_w3a(version, tablas))
    w3b_modos.add([(r, 'Tm' + n) for r, n in TEX], [f'war3mapImported\\Tm{n}.blp' for _, n in TEX],
                  ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
