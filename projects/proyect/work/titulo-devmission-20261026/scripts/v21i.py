#!/usr/bin/env python3
"""v21i (22/11/2026): Kaioken de Goku adaptado (R en Super Saiyan Blue, forma 5).

En 2.1a un dummy lanza A0JF (Inner Fire) sobre Goku: buff B05J 25 s con +100/150/200/250 % de daño de ataque por
nivel, y la Kamehameha pasa a su versión Kaioken mientras dura. Aquí Goku no es héroe y el buff no entraba
(objetos_v21i.py). Leon: el daño extra "como el don que en nuestro caso aplicaria a nuestras arma actuales o activas".
Her_Dano, por el que pasa el daño de todas las armas del jugador, multiplica por 1 + Kai_Bono[p] mientras el cuerpo de
Goku de ese jugador tenga B05J. Kai_Bono se fija al lanzar con el nivel de la R (como Inf1 de A0JF).
Registros (sólo prueba): bono al lanzar y si el buff está puesto 0,5 s después.
Uso: v21i.py ENTRADA.j SALIDA.j [prueba]   (normal de v21h; prueba de v21h-prueba).
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


cambia('''real array Sacude_Mag
''', '''real array Sacude_Mag
real array Kai_Bono
''')
cambia('''    function Her_Dano takes integer p,real d returns real
        if p < 0 or p > 11 then
            return d
        endif
''', '''    function Her_Dano takes integer p,real d returns real
        if p < 0 or p > 11 then
            return d
        endif
        // v21i: Kaioken de Goku (buff B05J en su cuerpo) suma daño a las armas, como el Inner Fire de D.O.N al ataque.
        if Kai_Bono[p] > 0. and G2V_Caster[7150] != null and GetPlayerId(GetOwningPlayer(G2V_Caster[7150])) == p and GetUnitAbilityLevel(G2V_Caster[7150], 'B05J') > 0 then
            set d = d * ( 1. + Kai_Bono[p] )
        endif
''')
cambia('''call IssueTargetOrderById(bj_lastCreatedUnit,$D0062,G2V_Caster[7150])
''', '''call IssueTargetOrderById(bj_lastCreatedUnit,$D0062,G2V_Caster[7150])
// v21i: bono de Kaioken a las armas, el Inf1 de A0JF por nivel (1, 1,5, 2, 2,5).
set Kai_Bono[GetPlayerId(GetOwningPlayer(G2V_Caster[7150]))]=.5+.5*I2R(GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))
''' + ('''set Cop_Log="goku Kaioken bono "+R2S(Kai_Bono[GetPlayerId(GetOwningPlayer(G2V_Caster[7150]))])+" niv "+I2S(GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))
call ExecuteFunc("Cop_Anotar")
call TimerStart(CreateTimer(),.5,false,function G2_KaiMira)
''' if prueba else ''))
if prueba:
    cambia('''function G2F_Ultimate_Goku_GOd_Conditions takes nothing returns boolean
''', '''// v21i (prueba): comprueba si el buff de Kaioken quedó puesto en el cuerpo.
function G2_KaiMira takes nothing returns nothing
set Cop_Log="goku Kaioken buff "+I2S(GetUnitAbilityLevel(G2V_Caster[7150],'B05J'))+" cuerpo "+GetUnitName(G2V_Caster[7150])
call ExecuteFunc("Cop_Anotar")
call DestroyTimer(GetExpiredTimer())
endfunction
function G2F_Ultimate_Goku_GOd_Conditions takes nothing returns boolean
''')
    cambia('lat\\\\v21h-', 'lat\\\\v21i-', src.count('lat\\\\v21h-'))
    cambia('v21h-don.txt', 'v21i-don.txt', src.count('v21h-don.txt'))
assert not prueba or ('lat\\\\v21h-' not in src and 'v21h-don.txt' not in src), 'quedan registros v21h'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21i', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
