#!/usr/bin/env python3
"""v21f (22/11/2026): correcciones de Goku 2.1a tras la prueba de Leon de v21e.

1. R (Ultimate): "no castea nada, solo sale el dummy y desaparece". A0BZ pasa a Rain of Fire (objetos_v21f.py), la
   base con la que la copia lanzaba la R en v21d; orden rainoffire. Si la copia no acepta la orden se avisa.
2. X (Transformación): Leon pide la X de 2.1a "que hace convertirle en ssj tras un periodo de cast para probar las
   multiples habilidades del R". El puente AGk4 sube una forma con la carga de D.O.N (G2_Subir), como las muertes.
   Entra en el libro (técnica 44) como las demás; -pj la da.
3. Retrato con cabeza: Goku21_portrait.mdx (retrato_goku21.cjs), sólo recurso.
Registros (sólo prueba): resultado de la copia de la R, forma al lanzar la Ultimate y la X.
Uso: v21f.py ENTRADA.j SALIDA.j [prueba]   (normal de v21e; prueba de v21e-prueba).
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


LOG = (lambda s: '                set Cop_Log = ' + s + '\n                call ExecuteFunc("Cop_Anotar")\n') if prueba \
    else (lambda s: '')

# --- R por la copia con Rain of Fire ---
cambia('''            elseif a == 'AGk3' then
                // A0BZ de 2.1a es ACmp: orden impale.
                call Dcp_Lanzar(b, 'A0BZ', 2, "impale", null, x, y)
            endif
''', '''            elseif a == 'AGk3' then
                // v21f: A0BZ con base Rain of Fire (como en v21d); la de 2.1a (Impale) no la lanzaba la copia.
                set ok = Dcp_Lanzar(b, 'A0BZ', 2, "rainoffire", null, x, y)
''' + LOG('"goku R copia " + I2S(IntegerTertiaryOp(ok, 1, 0)) + " forma " + I2S(G2V_Int[7160])') + '''                if not ok then
                    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "La Ultimate no se pudo lanzar ahí.")
                endif
            endif
''')
cambia('''function Gk_Relevo takes nothing returns nothing
    local integer this = s__RapidPair_fromController(GetTriggerUnit())
    local integer a = GetSpellAbilityId()
    local unit t = GetSpellTargetUnit()
    local real x = GetSpellTargetX()
    local real y = GetSpellTargetY()
    local unit b
''', '''function Gk_Relevo takes nothing returns nothing
    local integer this = s__RapidPair_fromController(GetTriggerUnit())
    local integer a = GetSpellAbilityId()
    local unit t = GetSpellTargetUnit()
    local real x = GetSpellTargetX()
    local real y = GetSpellTargetY()
    local unit b
    local boolean ok
''')

# --- X: Transformación ---
cambia('''                    call Gk_Transmision(b, t)
                endif
            elseif Dcp_Ocupada''', '''                    call Gk_Transmision(b, t)
                endif
            elseif a == 'AGk4' then
                // v21f: sube una forma con la carga de D.O.N (G2_SubirX, más abajo).
                call ExecuteFunc("G2_SubirX")
            elseif Dcp_Ocupada''')
cambia('''    call UnitAddAbility(Game_Ctrl[p], 'AGk5')
    call UnitAddAbility(Game_Ctrl[p], 'AGk3')
''', '''    call UnitAddAbility(Game_Ctrl[p], 'AGk5')
    call UnitAddAbility(Game_Ctrl[p], 'AGk3')
    call UnitAddAbility(Game_Ctrl[p], 'AGk4')
''')
cambia('''    call RegisterSpellEffectEvent('AGk5', function Gk_Relevo)
''', '''    call RegisterSpellEffectEvent('AGk5', function Gk_Relevo)
    call RegisterSpellEffectEvent('AGk4', function Gk_Relevo)
''')
cambia('''    set Tec_Real[44] = 'A0G2'
    set Tec_Max[44] = 0
''', '''    set Tec_Real[44] = 'AGk4'
    set Tec_Max[44] = 1
''')
cambia('''    set Cua_Nom[44] = "Formas"
    set Cua_Des[44] = "Suben con las muertes."
''', '''    set Cua_Nom[44] = "Transformación"
    set Cua_Des[44] = "Carga y sube una forma.|nTambién suben con las muertes."
''')
cambia('''function G2_Armar takes nothing returns nothing
    set G2V_Caster[7150] = G2_PB
    call G2_Base()
endfunction
''', '''function G2_Armar takes nothing returns nothing
    set G2V_Caster[7150] = G2_PB
    call G2_Base()
endfunction

// v21f: X de Goku. Sube una forma con la carga de D.O.N; la forma dura hasta el final de la oleada, como las de las muertes.
function G2_SubirX takes nothing returns nothing
    local unit b = G2V_Caster[7150]
    local player p
    local integer n
    if b == null then
        return
    endif
    set p = GetOwningPlayer(b)
    if G2V_Bool[7150] then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya se está transformando.")
    elseif G2V_Int[7160] >= 6 then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya está en Ultra Instinto.")
    else
        call G2_Subir()
        set n = G2V_Int[7160] + 1
        if not G2V_Bool[7150] then
            set n = 0
        elseif n == 2 then
            call DisplayTimedTextToPlayer(p, 0., 0., 3., "|cffffcc00¡Super Saiyan!|r")
        elseif n == 3 then
            call DisplayTimedTextToPlayer(p, 0., 0., 3., "|cffffcc00¡Super Saiyan 3!|r")
        elseif n == 4 then
            call DisplayTimedTextToPlayer(p, 0., 0., 3., "|cffff4040¡Super Saiyan Dios!|r")
        elseif n == 5 then
            call DisplayTimedTextToPlayer(p, 0., 0., 3., "|cff40a0ff¡Super Saiyan Blue!|r")
        else
            call DisplayTimedTextToPlayer(p, 0., 0., 3., "|cffc0c0ff¡Ultra Instinto!|r")
        endif
''' + LOG('"goku X a forma " + I2S(n)').replace('                ', '        ') + '''    endif
    set b = null
endfunction
''')
if prueba:
    cambia('''function G2F_Ultimate_Goku_GOd_Actions takes nothing returns nothing
''', '''function G2F_Ultimate_Goku_GOd_Actions takes nothing returns nothing
set Cop_Log="goku Ultimate forma "+I2S(G2V_Int[7160])+" lanza "+GetUnitName(GetSpellAbilityUnit())
call ExecuteFunc("Cop_Anotar")
''')
    cambia('lat\\\\v21e-', 'lat\\\\v21f-', src.count('lat\\\\v21e-'))
    cambia('v21e-don.txt', 'v21f-don.txt', src.count('v21e-don.txt'))
assert not prueba or ('lat\\\\v21e-' not in src and 'v21e-don.txt' not in src), 'quedan registros v21e'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21f', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
