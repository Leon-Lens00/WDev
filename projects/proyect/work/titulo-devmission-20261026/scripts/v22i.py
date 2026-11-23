#!/usr/bin/env python3
"""v22i (23/11/2026): la probabilidad de Afterimage sube con su tier: 10 % en T1 hasta 25 % en T6.

Leon tras v22h: "ese 25 podria ser al tier maximo, tier 1 que sea menor".
- Afterimage (técnica 104, Tec_Max 6): de 25 % fijo a 10 + 3 × (tier - 1): T1 10, T2 13, T3 16, T4 19, T5 22, T6 25.
  La espera de 4 s tras saltar y el resto de condiciones no cambian.
Registro (sólo prueba): "vegito afterimage E copia N tier T prob P".
Uso: v22i.py ENTRADA.j SALIDA.j [prueba]   (normal de v22h; prueba de v22h-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia("    local boolean ok = false\n    if b != null and GetTriggerUnit() == b and a != null and not Vt_AfterCd",
       "    local boolean ok = false\n    local integer t\n    if b != null and GetTriggerUnit() == b and a != null and not Vt_AfterCd")
cambia("            if GetRandomInt(1, 100) <= 25 and not Dcp_Ocupada(p, 'A03F') then\n",
       "            // v22i: 10 % en T1 hasta 25 % en T6.\n"
       "            set t = IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 200 + 104]))\n"
       "            if GetRandomInt(1, 100) <= 10 + 3 * (t - 1) and not Dcp_Ocupada(p, 'A03F') then\n")
if prueba:
    cambia('            set Cop_Log = "vegito afterimage E copia " + I2S(IntegerTertiaryOp(ok, 1, 0))\n',
           '            set Cop_Log = "vegito afterimage E copia " + I2S(IntegerTertiaryOp(ok, 1, 0)) + " tier " + I2S(t) + " prob " + I2S(10 + 3 * (t - 1))\n')
    assert 'function Cop_Anotar' in src, 'Cop_Anotar en prueba'
    cambia('lat\\\\v22h-', 'lat\\\\v22i-', src.count('lat\\\\v22h-'))
    cambia('v22h-don.txt', 'v22i-don.txt', src.count('v22h-don.txt'))
    assert 'lat\\\\v22h-' not in src and 'v22h-don.txt' not in src, 'quedan registros v22h'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22i', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
