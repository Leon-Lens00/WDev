#!/usr/bin/env python3
"""v21g (22/11/2026): Goku tras la prueba de Leon de v21f-prueba.

1. R en Super Saiyan 3 (Dragon Fist): "parecia no parar su efecto y seguia el shake de la camara sin parar". Al acabar,
   DragonFist2 devuelve la copia al punto del golpe (~2275 de distancia) con Don_Pon, que traza el camino de 8 en 8 con
   9 sondeos por paso: el hilo se corta por el límite de operaciones justo después de apagar el disparador, y no llega a
   quitar la sacudida, despausar la copia ni quitar el puño (registro: copia pausada hasta k300, movió 2925 = 650 + 2275,
   puño h0A4 vivo 8 s después). Don_Pon ya no traza los saltos de más de 400 (son vueltas a un punto ya válido).
   Red de seguridad en Dcp_Tick: si una copia de la R queda pausada al terminar, se despausa y se quita la sacudida.
2. Sonido en bucle de las formas: sonaba toda la forma. Ahora suena sólo durante la carga y se corta al llegar a la forma
   (las propias ramas de llegada ya paran los tres bucles).
3. E: en 2.1a era Revert (A0CZ): vuelve a la forma normal. AGk5 deja de ser Transmisión Instantánea y llama a G2_Base.
Registros (sólo prueba): la E y el rescate de la copia.
Uso: v21g.py ENTRADA.j SALIDA.j [prueba]   (normal de v21f; prueba de v21f-prueba).
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


def log(s, sangria):
    if not prueba:
        return ''
    return sangria + 'set Cop_Log = ' + s + '\n' + sangria + 'call ExecuteFunc("Cop_Anotar")\n'


# --- 1. Don_Pon sin trazo en saltos largos ---
cambia('''function Don_Pon takes unit u, location L returns nothing
    if u != null and GetUnitFlyHeight(u) < 150. then
        if s__GroundCollision_trace(''', '''function Don_Pon takes unit u, location L returns nothing
    local real dx
    local real dy
    if u != null and GetUnitFlyHeight(u) < 150. then
        // v21g: los saltos de más de 400 no se trazan (el trazo de 8 en 8 agotaba el límite de operaciones del hilo).
        set dx = GetLocationX(L) - GetUnitX(u)
        set dy = GetLocationY(L) - GetUnitY(u)
        if dx * dx + dy * dy <= 160000. and s__GroundCollision_trace(''')

# --- 1b. Red de seguridad de la copia de la R ---
cambia('''                set Dcp_F[i] = 1
                set Dcp_S[i] = Dcp_K[i]
''', '''                set Dcp_F[i] = 1
                set Dcp_S[i] = Dcp_K[i]
                if Dcp_A[i] == 'A0BZ' and IsUnitPaused(c) and not Don_EnCurso(Dcp_A[i]) then
                    // v21g: la Ultimate acabó sin soltar la copia: se despausa y se quita la sacudida de todos.
                    call PauseUnit(c, false)
                    set j = 0
                    loop
                        exitwhen j >= 12
                        set Sacude_Mag[j] = 0.
                        set j = j + 1
                    endloop
''' + ('''                    call Dia_Anotar("c" + I2S(Dcp_Id[i]) + " rescate de la R: despausada y sin sacudida")
''' if prueba else '') + '''                endif
''')

# --- 2. Bucles de las formas sólo en la carga ---
for s in ('super_saiyan_aura', 'aura_power_fluxing', 'instinctauraloop'):
    cambia('call PlaySoundOnUnitBJ(G2S_%s,100,G2V_Caster[7150])\n' % s, '')
cambia('''call PlaySoundOnUnitBJ(G2S_SS,86.,G2V_Caster[7150])
''', '''call PlaySoundOnUnitBJ(G2S_SS,86.,G2V_Caster[7150])
// v21g: el bucle de la forma suena sólo durante la carga; la llegada a la forma lo corta.
if G2V_Int[7160]==1 then
call PlaySoundOnUnitBJ(G2S_super_saiyan_aura,100,G2V_Caster[7150])
elseif G2V_Int[7160]==2 then
call PlaySoundOnUnitBJ(G2S_aura_power_fluxing,100,G2V_Caster[7150])
elseif G2V_Int[7160]==5 then
call PlaySoundOnUnitBJ(G2S_instinctauraloop,100,G2V_Caster[7150])
endif
''')

# --- 3. E = Revert ---
cambia('''            if a == 'AGk5' then
                if t != null and t != b and UnitAlive(t) then
                    call s__RapidPair_endDash(this, false)
                    call s__RapidPair_finish(this, false)
                    set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
                    call Gk_Transmision(b, t)
                endif
            elseif''', '''            if a == 'AGk5' then
                // v21g: Revert de 2.1a: vuelve a la forma normal (G2_Revertir, más abajo).
                call ExecuteFunc("G2_Revertir")
            elseif''')
cambia('''    set Cua_Nom[41] = "Instant Transmission"
    set Cua_Des[41] = "Técnica de D.O.N.|nJunto a una unidad."
''', '''    set Cua_Nom[41] = "Revert"
    set Cua_Des[41] = "Técnica de D.O.N.|nVuelve a la forma normal."
''')
cambia('''// v21f: X de Goku.''', '''// v21g: E de Goku (Revert de 2.1a). Corta la carga si la hay y vuelve a la forma normal.
function G2_Revertir takes nothing returns nothing
    local unit b = G2V_Caster[7150]
    local player p
    if b == null then
        return
    endif
    set p = GetOwningPlayer(b)
''' + log('"goku E desde forma " + I2S(G2V_Int[7160]) + " carga " + I2S(IntegerTertiaryOp(G2V_Bool[7150], 1, 0))', '    ') + '''    if G2V_Int[7160] <= 1 and not G2V_Bool[7150] then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya está en su forma normal.")
    else
        call G2_Base()
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\\\Spells\\\\Human\\\\DispelMagic\\\\DispelMagicTarget.mdl", b, "origin"))
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Goku vuelve a su forma normal.")
    endif
    set b = null
endfunction

// v21f: X de Goku.''')
if prueba:
    cambia('lat\\\\v21f-', 'lat\\\\v21g-', src.count('lat\\\\v21f-'))
    cambia('v21f-don.txt', 'v21g-don.txt', src.count('v21f-don.txt'))
assert not prueba or ('lat\\\\v21f-' not in src and 'v21f-don.txt' not in src), 'quedan registros v21f'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21g', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
