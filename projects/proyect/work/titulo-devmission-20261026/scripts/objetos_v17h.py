#!/usr/bin/env python3
"""Objetos e imports de la presentación de jefe v17h (14/11/2026).

- texturas como destructibles (w3b_modos.add), de recursos_v17h.py: DP00 JefeOscuro, DP01 JefeRafaga, DP02 JefeBarra,
  DP03 JefeAviso, DP04..DP08 JefeRayo1..5 y DPN2..DPNA JefeNombre2..10 (ronda n: 'DPN0' + n, la 10 'DPNA');
- unidades 'upj2'..'upjA', copias del dummy de interfaz 'uidm' con sólo el modelo cambiado:
  war3mapImported\\PresJefe{n}.mdx, el modelo del jefe de la ronda n girado a la cámara de juego (jefe_modelos_v17h.py),
  como 'ubt8' con la hidra del título (objetos_v9w.py); las texturas del modelo son las del juego;
- imports: los 18 BLP y los 9 MDX. Falla si un id o una ruta ya existe.

Uso: objetos_v17h.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

RONDAS = '23456789A'
TEXTURES = ([('DP00', 'JefeOscuro'), ('DP01', 'JefeRafaga'), ('DP02', 'JefeBarra'), ('DP03', 'JefeAviso')]
            + [(f'DP0{4 + k}', f'JefeRayo{k + 1}') for k in range(5)]
            + [(f'DPN{c}', f'JefeNombre{k + 2}') for k, c in enumerate(RONDAS)])
UNITS = {f'upj{c}': f'war3mapImported\\PresJefe{k + 2}.mdx' for k, c in enumerate(RONDAS)}
IMPORTS = [f'war3mapImported\\{n}.blp' for _, n in TEXTURES] + list(UNITS.values())

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, IMPORTS, sys.argv)
    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src
    used = {new for t in tables for _, new, _ in t}
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    assert any(mid == b'umdl' for mid, _, _, _ in mods)
    for rid, model in UNITS.items():
        assert rid.encode() not in used, rid
        tables[1].append((base, rid.encode(), [(mid, ty, model.encode() if mid == b'umdl' else v, end)
                                               for mid, ty, v, end in mods]))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print(json.dumps({'units': list(UNITS), 'imports': len(IMPORTS)}))
