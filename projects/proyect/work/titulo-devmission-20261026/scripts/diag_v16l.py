#!/usr/bin/env python3
"""Diagnóstico del cierre de v16k/v16l (08/11/2026). Tres j:
d1: j de v16j con sólo el suelo cambiado a SueloAzur.mdx (prueba el modelo y la textura nuevos).
d2: j de v16k sin las fases 89..130 nuevas (la despedida vuelve a 89..91): prueba retrato, HUD, globales y funciones.
d3: j de v16k completo con el suelo de vuelta a TitlePlano.mdx (prueba las escenas sin el suelo nuevo).
Uso: diag_v16l.py J_V16J J_V16K DIR_SALIDA
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once
j16, j16k, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
a = j16.read_text(encoding='latin-1', newline='')
k = j16k.read_text(encoding='latin-1', newline='')
viejo = '"war3mapImported\\\\TitlePlano.mdx", Tut_X + 500., Tut_Y)'
nuevo = '"war3mapImported\\\\SueloAzur.mdx", Tut_X + 500., Tut_Y)'
d1 = once(a, viejo, nuevo)
i = k.index('    elseif Tut_Fase == 89 then\r\n')
f = k.index('    elseif Tut_Fase == 131 then\r\n')
d2 = k[:i] + k[f:]
for n in (131, 132, 133):
    d2 = d2.replace(f'Tut_Fase == {n} then', f'Tut_Fase == {n - 42} then').replace(f'"fase {n} "', f'"fase {n - 42} "')
d3 = once(k, nuevo, viejo)
for nombre, s in (('d1', d1), ('d2', d2), ('d3', d3)):
    (out / nombre).mkdir(parents=True, exist_ok=True)
    (out / nombre / 'war3map.j').write_text(s, encoding='latin-1', newline='')
print('diag ok')
