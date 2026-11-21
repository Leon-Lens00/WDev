#!/usr/bin/env python3
"""v19g (19/11/2026), tras probar v19f (Leon: "solo no funcionan el reaseshuriken y disco de freezer, y adicional de
efectos del dummy de jugador que se quedan como en la de goku con ssj"):
- Destructo Disc (FzF_ki4) leía GetSpellAbilityUnit() después de TriggerSleepAction(.07), y Rasen Shuriken (NaF_Ff7 /
  NaF_Fe7, Naruto normal o Kyuubi) igual. El lanzamiento ocurre dentro de la orden del botón (Don_Relevo → Dcp_Lanzar),
  y tras la espera esa respuesta queda vacía: el disco se creaba para un jugador nulo (v16y-prueba: "DD disco … null")
  y el Shuriken no entraba en ninguna rama. Ahora el lanzador se guarda antes de esperar. Son los dos únicos sitios
  del j que leen respuestas del hechizo después de esperar.
- Al terminar de desvanecerse, la copia se oculta (ShowUnit false): así desaparecen con ella las piezas pegadas
  (cabezas y auras de Super Saiyan, espada, ojos) y los efectos que D.O.N le pega. Sigue viva como origen del daño.
Uso: v19g.py ENTRADA.j SALIDA.j [prueba]   (normal de v19f; prueba de v19f-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('''function FzF_ki4 takes nothing returns nothing
set FzV_ke='h0AU'
call TriggerSleepAction(.07)
set FzV_n8[5980]=0
set FzV_s8[5980]=GetSpellAbilityUnit()
''', '''function FzF_ki4 takes nothing returns nothing
local unit u=GetSpellAbilityUnit()
set FzV_ke='h0AU'
call TriggerSleepAction(.07)
set FzV_n8[5980]=0
set FzV_s8[5980]=u
set u=null
''')
cambia('''function NaF_Fe7 takes nothing returns boolean
return(Dcp_Tipo(GetSpellAbilityUnit())=='hNaK')
endfunction
function NaF_Ff7 takes nothing returns boolean
return(Dcp_Tipo(GetSpellAbilityUnit())=='hNar')
endfunction
''', '''function NaF_Fe7 takes nothing returns boolean
return(Dcp_Tipo(NaV_s8[5140])=='hNaK')
endfunction
function NaF_Ff7 takes nothing returns boolean
return(Dcp_Tipo(NaV_s8[5140])=='hNar')
endfunction
''')
cambia('''                set al = 0
                set Dcp_F[i] = 2
''', '''                set al = 0
                set Dcp_F[i] = 2
                call ShowUnit(c, false)
''')
if prueba:
    for viejo, nuevo in (('lat\\\\v19f-', 'lat\\\\v19g-'), ('v19f-don.txt', 'v19g-don.txt')):
        assert viejo in src
        src = src.replace(viejo, nuevo)
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19g', 'prueba' if prueba else 'normal')
