#!/usr/bin/env python3
"""v21k (22/11/2026): la Q (Kamehameha) ya no cruza árboles ni pendientes tras unos ticks.

Leon, con vídeo de v21j-prueba: "la Q aun traspasa". v21j paraba la cabeza en el choque, pero el punto de cada tick se
sigue calculando desde el origen (origen + 55 x tick). Con la cabeza quieta, la distancia hasta ese punto crece 55 por
tick; al pasar de 400 Don_Pon deja de trazar (regla de v21g) y la cabeza salta al otro lado del árbol, y el rayo sigue.
Ahora, si la cabeza choca, el tick no avanza (G2V_Int[7150] vuelve atrás): el punto siguiente queda a menos de 55 del
choque, se traza otra vez y la técnica se queda ahí hasta su tiempo, como en D.O.N. La Super Kamehameha y la Genkidama
ya calculan cada paso desde la cabeza y no cambian.
Registros (sólo prueba): primer choque de la Q y total de ticks parada.
Uso: v21k.py ENTRADA.j SALIDA.j [prueba]   (normal de v21j; prueba de v21j-prueba).
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


cambia('''boolean Don_Choco = false
''', '''boolean Don_Choco = false
integer Kam_Parada = 0
''')
cambia('''set G2V_Int[7150]=0
set G2V_Int[7151]=0
set G2V_Damage[7150]=''', '''set G2V_Int[7150]=0
set G2V_Int[7151]=0
set Kam_Parada=0
set G2V_Damage[7150]=''')
cambia('''call Don_Pon(G2V_Caster[7155],G2V_Point[7155])
if not Don_Choco then
''', '''call Don_Pon(G2V_Caster[7155],G2V_Point[7155])
if Don_Choco then
// v21k: la cabeza chocó: el tick no avanza para que el próximo punto siga junto al choque y se vuelva a trazar.
set G2V_Int[7150]=(G2V_Int[7150]-1)
set Kam_Parada=Kam_Parada+1
''' + ('''if Kam_Parada==1 then
set Cop_Log="goku Q choca en paso "+I2S(G2V_Int[7150]+1)
call ExecuteFunc("Cop_Anotar")
endif
''' if prueba else '') + '''endif
if not Don_Choco then
''')
if prueba:
    cambia('''call DisableTrigger(GetTriggeringTrigger())
call PlaySoundOnUnitBJ(G2S_wallhit2,65.,G2V_Caster[7155])
''', '''call DisableTrigger(GetTriggeringTrigger())
set Cop_Log="goku Q termina paso "+I2S(G2V_Int[7150])+" parada "+I2S(Kam_Parada)
call ExecuteFunc("Cop_Anotar")
call PlaySoundOnUnitBJ(G2S_wallhit2,65.,G2V_Caster[7155])
''')
    cambia('lat\\\\v21j-', 'lat\\\\v21k-', src.count('lat\\\\v21j-'))
    cambia('v21j-don.txt', 'v21k-don.txt', src.count('v21j-don.txt'))
assert not prueba or ('lat\\\\v21j-' not in src and 'v21j-don.txt' not in src), 'quedan registros v21j'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21k', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
