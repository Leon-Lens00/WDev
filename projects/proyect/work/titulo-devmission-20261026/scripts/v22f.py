#!/usr/bin/env python3
"""v22f (23/11/2026): la E de Vegito golpea durante el recorrido; Afterimage la lanza una copia como una E.

Leon tras v22e: "durante el recorrido podria tambien realizar danio ... tiene un pasiva activa ahora que hace que se
de teleport hacia el enemigo que lo esta por golpea y le de un hit, a cambio de que sea el mismo personaje lo puede
hacer con una copia? y a cambio de pegarle le lanzara una E, bajariamos su probabilidad".
- E (Spirit Sword): en 2.1a sólo hay un golpe al final (300 alrededor del blanco), y el arrastre (16 pasos de 45 y
  40 de 12) aleja al blanco de su grupo: casi siempre daña a uno. Ahora, en cada paso de los dos arrastres
  (spiritsword2 y spiritsword3), Vt_ERecorrido golpea a 200 del blanco con la mitad del daño, una vez a cada enemigo
  (Fz_Area con Vt_EGrupo; el blanco va en el grupo desde el inicio: recibe el golpe final). El golpe final pasa de 300
  a 550 de radio (Leon: "subele el radio a la E tambien, 550").
- Afterimage: ya no mueve al héroe. Al recibir un ataque a 300 o menos, con un 25 % (antes siempre) y 4 s de espera
  tras saltar, una copia lanza la E (A03F) al atacante (Dcp_Lanzar, como el botón). Esa E usa el tier y la base de
  Afterimage (técnica 104, 1500) en lugar de los de la E (101, 2500), también en el recorrido. No salta si la E ya está
  en curso (la de la copia o la del jugador: la E es una sola en D.O.N).
Registro (sólo prueba): "vegito afterimage E copia N" (1 lanzada, 0 no aceptada); daño del recorrido en
"vegito dano E" (o "P" si la lanzó Afterimage).
Uso: v22f.py ENTRADA.j SALIDA.j [prueba]   (normal de v22e; prueba de v22e-prueba).
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


# 1) Globales.
cambia('boolean Vt_AfterCd=false\n', '''boolean Vt_AfterCd=false
// v22f: E de Vegito: golpeados en el recorrido, copia de Afterimage y técnica/base/registro de la E en curso.
group Vt_EGrupo=null
boolean Vt_EDeAfter=false
integer Vt_EK=101
real Vt_EB=2500.
integer Vt_ES=25
''')
assert src.index('function Fz_Area ') < src.index('function G2F_spiritsword_Conditions')
assert src.index('function Dcp_Lanzar ') < src.index('function Vt_AfterAtaque ')

# 2) Golpe del recorrido.
cambia('function G2F_spiritsword_Conditions takes nothing returns boolean\n', '''// v22f: cada paso del arrastre de la E golpea a 200 del blanco con la mitad del daño, una vez a cada enemigo.
function Vt_ERecorrido takes nothing returns nothing
    if G2V_Caster[$B4] != null and Vt_EGrupo != null then
        call Fz_Area(G2V_Caster[$B4], Vt_EX, Vt_EY, 200., 0.5 * Gk_TDano(G2V_Caster[$B4], Vt_EK, Vt_EB), Vt_EGrupo, Vt_ES, Vt_EK)
    endif
endfunction
function G2F_spiritsword_Conditions takes nothing returns boolean
''')

# 3) Al empezar la E: grupo nuevo con el blanco; técnica de la E o de Afterimage según quién la lance.
cambia('''set G2V_Caster[$B4]=GetSpellAbilityUnit()
set G2V_Caster[$B5]=GetSpellTargetUnit()
''', '''set G2V_Caster[$B4]=GetSpellAbilityUnit()
set G2V_Caster[$B5]=GetSpellTargetUnit()
// v22f: la E de la copia de Afterimage usa la técnica 104 (1500); la del botón, la 101 (2500).
if Vt_EGrupo==null then
set Vt_EGrupo=CreateGroup()
endif
call GroupClear(Vt_EGrupo)
call GroupAddUnit(Vt_EGrupo,G2V_Caster[$B5])
if Vt_EDeAfter and GetUnitTypeId(G2V_Caster[$B4])=='hCpW' then
set Vt_EK=104
set Vt_EB=1500.
set Vt_ES=27
else
set Vt_EK=101
set Vt_EB=2500.
set Vt_ES=25
endif
''')

# 4) Recorrido en los dos arrastres (Vt_EX/EY ya es el punto del blanco en ese paso).
cambia('if(G2F_spiritsword2_Func005C())then\n', '// v22f: golpe del recorrido.\ncall Vt_ERecorrido()\nif(G2F_spiritsword2_Func005C())then\n')
cambia('if(G2F_spiritsword3_Func011C())then\n', '// v22f: golpe del recorrido.\ncall Vt_ERecorrido()\nif(G2F_spiritsword3_Func011C())then\n')

# 5) Golpe final con la técnica de quien la lanzó.
cambia('set G2V_Damage2[$B4]=R2I(Gk_TDano(G2V_Caster[$B4],101,2500.))',
       'set G2V_Damage2[$B4]=R2I(Gk_TDano(G2V_Caster[$B4],Vt_EK,Vt_EB))')
if prueba:
    cambia('call Gk_Suma(25,101,G2V_Caster[$B4],GetEnumUnit(),I2R(G2V_Damage2[$B4]))',
           'call Gk_Suma(Vt_ES,Vt_EK,G2V_Caster[$B4],GetEnumUnit(),I2R(G2V_Damage2[$B4]))')
# Leon (23/11): "subele el radio a la E tambien, 550": golpe final de 300 a 550.
cambia('set G2V_Group[$B4]=GetUnitsInRangeOfLocMatching(300.,G2V_Point[$B7],Condition(function G2F_spiritsword3_Func011Func009002003))',
       'set G2V_Group[$B4]=GetUnitsInRangeOfLocMatching(550.,G2V_Point[$B7],Condition(function G2F_spiritsword3_Func011Func009002003))')

# 6) Afterimage: una copia lanza la E al atacante, con un 25 %.
i = src.index('function Vt_AfterAtaque ')
j = src.index('\nendfunction\n', i)
cuerpo = src[i:j]
a = cuerpo.index('            set Vt_AfterCd = true\n')
b = cuerpo.index('            call G2F_Afterimage_Actions()\n') + len('            call G2F_Afterimage_Actions()\n')
reg = ('            set Cop_Log = "vegito afterimage E copia " + I2S(IntegerTertiaryOp(ok, 1, 0))\n'
       '            call ExecuteFunc("Cop_Anotar")\n') if prueba else ''
nuevo = U('''            // v22f: ya no mueve al héroe: con un 25 % una copia lanza la E al atacante (si la E no está en curso).
            if GetRandomInt(1, 100) <= 25 and G2V_Caster[$B4] == null and not Dcp_Ocupada(p, 'A03F') then
                set Vt_AfterCd = true
                call TimerStart(CreateTimer(), 4., false, function Vt_AfterListo)
                // El evento de la E salta dentro de la orden: la marca va antes y se quita después.
                set Vt_EDeAfter = true
                set ok = Dcp_Lanzar(b, 'A03F', 1, "entanglingroots", a, 0., 0.)
                set Vt_EDeAfter = false
''' + reg + '''            endif
''')
cuerpo = cuerpo[:a] + nuevo + cuerpo[b:]
cuerpo = cuerpo.replace('    local integer p\n', '    local integer p\n    local boolean ok = false\n', 1)
assert 'local boolean ok' in cuerpo and 'G2F_Afterimage_Actions' not in cuerpo
src = src[:i] + cuerpo + src[j:]

if prueba:
    assert 'function Cop_Anotar' in src, 'Cop_Anotar en prueba'
    cambia('lat\\\\v22e-', 'lat\\\\v22f-', src.count('lat\\\\v22e-'))
    cambia('v22e-don.txt', 'v22f-don.txt', src.count('v22e-don.txt'))
    assert 'lat\\\\v22e-' not in src and 'v22e-don.txt' not in src, 'quedan registros v22e'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22f', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
