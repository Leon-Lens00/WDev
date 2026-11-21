#!/usr/bin/env python3
"""v16m (08/11/2026): Tut_Guion partido en dos. v16k/v16l cerraban el juego antes de la pantalla de carga
(informes/errores/2026-11-08-025000-devmission-v16k-cierre.md); el diagnóstico d0 (mapa v16j con el j de v16k) también
cae, así que es el script. v16i/v16j tenían 91 elseif seguidos en Tut_Guion y v16k 133: el juego compila cada elseif
como un if anidado en el else anterior. Las fases 89.. pasan a Tut_Guion2 (definida antes), con su propio
incremento al final; Tut_Guion la llama desde la fase 89.
Uso: v16m.py ENTRADA.j SALIDA.j (el j de v16k o de v16k-prueba)
"""
from pathlib import Path
import sys

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
N = '\r\n'
cab = 'function Tut_Guion takes nothing returns nothing' + N
i = s.index(cab)
assert s.count(cab) == 1
pre = '    if Tut_EsperaTexto or Tut_T < Tut_Sig then' + N + '        return' + N + '    endif' + N
assert s[i + len(cab):].startswith(pre)
a = s.index('    elseif Tut_Fase == 89 then' + N, i)
fin = '    endif' + N + '    set Tut_Fase = Tut_Fase + 1' + N + 'endfunction' + N
b = s.index(fin, a)
assert s.count('    elseif Tut_Fase == 89 then' + N) == 1
cola = s[a:b]                                     # "    elseif Tut_Fase == 89 then ... (hasta antes del endif)"
cola = '    if' + cola[len('    elseif'):]
g2 = ('// v16m: fases 89.. del tutorial; aparte para no alargar la cadena de elseif de Tut_Guion.' + N +
      'function Tut_Guion2 takes nothing returns nothing' + N + cola + fin + N)
cuerpo = s[i:a] + fin
cuerpo = cuerpo.replace(cab + pre, cab + pre + '    if Tut_Fase >= 89 then' + N + '        call Tut_Guion2()' + N +
                        '        return' + N + '    endif' + N, 1)
s = s[:i] + g2 + cuerpo + s[b + len(fin):]
for f in ('Tut_Guion', 'Tut_Guion2'):
    k = s.index('function ' + f + ' takes')
    e = s.index('endfunction', k)
    print(f, 'elseif', s[k:e].count('elseif'))
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
