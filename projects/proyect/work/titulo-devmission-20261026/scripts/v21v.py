#!/usr/bin/env python3
"""v21v (22/11/2026): transformaciones de Goku y Trunks por tiempo, X de Trunks y bonos por forma.

Leon: "la duración sería por tiempo, también aplicaríamos con Goku"; la velocidad de ataque de D.O.N pasa a cadencia de
las armas; "con transformaciones las habilidades podrían ganar un plus de daño ... aplicaría a todas".
1. X de Trunks (Power Up, técnica 56): carta de un nivel como la X de Goku. Carga de D.O.N de 1 s (G2F_Saian_Trunks,
   25 pasos de 0,04) y sube una forma: base -> SSJ -> SSJ2. El puente lo lanza el controlador, así que Tr_SubirX deja
   pasar la condición de D.O.N (Tr_XOk) en lugar de mandar al cuerpo A0H5 (Big Bad Voodoo, 10 s canalizando). Al
   acabar la carga se quitan la pieza h0G1 y las dos auras (D.O.N no las quitaba).
2. Duración: cada forma de Goku y de Trunks dura Frm_DURA (50 s, como Trunks en 2.1a) desde que se alcanza; al subir
   de forma el tiempo vuelve a empezar; al acabar vuelve a la base (G2_Base, G2F_Saian_Trunks3 con Frm_Corte). Lo vigila
   Frm_Reloj desde el reloj del libro (Tec_Vigila, 0,25 s). El final de la oleada ya no corta las formas.
   Las muertes dan cada forma una vez por oleada (Frm_Dado): sin eso, tras volver a la base la siguiente muerte la daba
   otra vez.
3. Cadencia: los disparos de las armas van Frm_CAD (25 %) más rápidos por forma sobre la base (Trunks SSJ +25 %, SSJ2
   +50 %; Goku hasta +125 % en Ultra Instinto). Ráfagas de 1,5 s con más tiros. Recarga y cargador igual.
4. Daño: toda técnica con tier (Gk_TDano) hace Frm_DANO (20 %) más por forma sobre la base (Trunks hasta +40 %, Goku
   hasta +100 %). Freezer y Naruto sin cambio.
Uso: v21v.py ENTRADA.j SALIDA.j [prueba]   (normal de v21u; prueba de v21u-prueba).
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


LOG = (lambda s: f'    call Dia_Anotar({s})\n') if prueba else (lambda s: '')

# --- globales ---
cambia('real array Fz_Bono\n', '''real array Fz_Bono
// v21v: formas por tiempo y bonos por forma.
constant real Frm_DURA= 50.
constant real Frm_CAD= .25
constant real Frm_DANO= .20
integer Frm_GkNiv= 1
real Frm_GkFin= 0.
integer Frm_TrNiv= 1
real Frm_TrFin= 0.
integer array Frm_Dado
boolean Tr_XOk= false
''')

# --- nivel de forma y cadencia de las armas ---
cambia('    function Arm_Rafaga takes integer w returns integer\n', '''    // v21v: formas sobre la base del héroe de p (Goku 0-5, Trunks 0-2; los demás 0).
    function Frm_Nivel takes integer p returns integer
        local unit h= Game_Hero[p]
        local integer n= 0
        if h != null then
            if h == G2V_Caster[7150] and GetUnitTypeId(h) == 'hGok' then
                set n=G2V_Int[7160] - 1
            elseif h == G2V_Caster[$CEE] and GetUnitTypeId(h) == 'hTrk' then
                set n=G2V_Int[5630] - 1
            endif
        endif
        set h=null
        return IMaxBJ(0, n)
    endfunction

    // v21v: intervalo del arma w para p, Frm_CAD más rápido por forma.
    function Arm_IntJ takes integer p,integer w returns real
        return Arm_Int[w] / ( 1. + Frm_CAD * I2R(Frm_Nivel(p)) )
    endfunction

    function Arm_RafagaJ takes integer p,integer w returns integer
        return IMaxBJ(1, R2I(1.5 / Arm_IntJ(p, w) + 0.01))
    endfunction

    function Arm_Rafaga takes integer w returns integer
''')
cambia('        return Arm_Int[Arm_W(p)]\n', '        return Arm_IntJ(p, Arm_W(p))\n')
cambia('set Arm_Listo[p * 7 + c]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Int[w]',
       'set Arm_Listo[p * 7 + c]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_IntJ(p, w)')
cambia('set s__RapidPair_nextShot[this]=time + Arm_Int[Arm_W(p)]', 'set s__RapidPair_nextShot[this]=time + Arm_IntJ(p, Arm_W(p))')
cambia('Arm_Rafaga(Arm_W(p))', 'Arm_RafagaJ(p, Arm_W(p))', 4)

# --- daño de técnicas por forma ---
cambia('''        set t = IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 100 + x]))
    endif
    return total * Tec_Curva[t]
endfunction
''', '''        set t = IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 100 + x]))
        // v21v: Frm_DANO más por forma sobre la base (Goku y Trunks).
        return total * Tec_Curva[t] * (1. + Frm_DANO * I2R(Frm_Nivel(p)))
    endif
    return total * Tec_Curva[t]
endfunction
''')

# --- X de Trunks ---
cambia('return(GetSpellAbilityUnit()==G2V_Caster[$CEE])and(G2V_Bool[5630]==false)and(G2V_Int[5630]<3)',
       'return(Tr_XOk or GetSpellAbilityUnit()==G2V_Caster[$CEE])and(G2V_Bool[5630]==false)and(G2V_Int[5630]<3)')
cambia("    call RegisterSpellEffectEvent('ATr1', function Don_Relevo)\n",
       "    // v21v: X de Trunks directa al cuerpo (Tr_SubirX).\n    call RegisterSpellEffectEvent('ATr1', function Tr_SubirX)\n")
cambia('function Tec_Vigila takes nothing returns nothing\n    local integer p = 0\n    local integer t\n', '''// v21v: al acabar la carga de la X de Trunks se quitan la pieza y las auras que D.O.N dejaba puestas.
function Tr_XFin takes nothing returns nothing
    local unit b = G2V_Caster[$CEE]
    call DestroyEffect(G2V_Effect[5630])
    call DestroyEffect(G2V_Effect[5631])
    set G2V_Effect[5630] = null
    set G2V_Effect[5631] = null
    if G2V_Caster[5630] != null then
        call RemoveUnit(G2V_Caster[5630])
        set G2V_Caster[5630] = null
    endif
    if b != null and UnitAlive(b) and not G2V_Bool[5630] then
        if G2V_Int[5630] == 2 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "|cffffcc00¡Super Saiyan!|r")
        elseif G2V_Int[5630] == 3 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "|cffffcc00¡Super Saiyan 2!|r")
        endif
    endif
''' + LOG('"x trunks forma " + I2S(G2V_Int[5630])') + '''    call DestroyTimer(GetExpiredTimer())
    set b = null
endfunction

// v21v: X de Trunks (Power Up de 2.1a): carga de 1 s y una forma más, hasta SSJ2. La lanza el controlador.
function Tr_SubirX takes nothing returns nothing
    local integer this = s__RapidPair_fromController(GetTriggerUnit())
    local unit b = G2V_Caster[$CEE]
    local player p = GetTriggerPlayer()
    if b == null or this == 0 or s__RapidPair_actor[this] != b or not UnitAlive(b) then
        set b = null
        return
    endif
    if G2V_Int[5630] < 1 then
        set G2V_Int[5630] = 1
    endif
    if G2V_Bool[5630] then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya se está transformando.")
    elseif G2V_Int[5630] >= 3 then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya está en Super Saiyan 2.")
    else
''' + LOG('"x trunks carga desde " + I2S(G2V_Int[5630])').replace('    call', '        call') + '''        set Tr_XOk = true
        call G2F_Saian_Trunks_Actions()
        set Tr_XOk = false
        call TimerStart(CreateTimer(), 1.2, false, function Tr_XFin)
    endif
    set b = null
endfunction

// v21v: las formas de Goku y Trunks duran Frm_DURA desde que se alcanzan; luego vuelven a la base.
function Frm_Reloj takes nothing returns nothing
    local real now = TimerGetElapsed(s__RapidPair_clock)
    local unit b = G2V_Caster[7150]
    if b != null then
        if G2V_Int[7160] != Frm_GkNiv then
            set Frm_GkNiv = G2V_Int[7160]
            set Frm_GkFin = now + Frm_DURA
''' + LOG('"forma goku " + I2S(Frm_GkNiv) + " hasta " + R2S(Frm_GkFin)').replace('    call', '            call') + '''        elseif Frm_GkNiv > 1 and not G2V_Bool[7150] and now >= Frm_GkFin then
            call G2_Base()
            set Frm_GkNiv = 1
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "Goku vuelve a su forma normal.")
''' + LOG('"forma goku fin"').replace('    call', '            call') + '''        endif
    endif
    set b = G2V_Caster[$CEE]
    if b != null then
        if IMaxBJ(1, G2V_Int[5630]) != Frm_TrNiv then
            set Frm_TrNiv = IMaxBJ(1, G2V_Int[5630])
            set Frm_TrFin = now + Frm_DURA
''' + LOG('"forma trunks " + I2S(Frm_TrNiv) + " hasta " + R2S(Frm_TrFin)').replace('    call', '            call') + '''        elseif Frm_TrNiv > 1 and not G2V_Bool[5630] and now >= Frm_TrFin then
            set Frm_Corte = true
            call G2F_Saian_Trunks3_Actions()
            set Frm_Corte = false
            call DisableTrigger(G2T_Saian_Trunks3)
            set Frm_TrNiv = 1
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "Trunks vuelve a su forma normal.")
''' + LOG('"forma trunks fin"').replace('    call', '            call') + '''        endif
    endif
    set b = null
endfunction

function Tec_Vigila takes nothing returns nothing
    local integer p = 0
    local integer t
    call Frm_Reloj()
''')

# --- muertes: cada forma una vez por oleada; la oleada ya no corta las formas ---
cambia('''        if G2V_Int[7160] < n then
            call G2_Subir()
            if G2V_Bool[7150] then
                set n = G2V_Int[7160] + 1
''', '''        if G2V_Int[7160] < n and n > Frm_Dado[k] then
            call G2_Subir()
            if G2V_Bool[7150] then
                set n = G2V_Int[7160] + 1
                set Frm_Dado[k] = n
''')
cambia('''        if G2V_Int[5630] < n then
            set G2V_Bool[5630] = true
            set G2V_Int[5637] = 1
            call ExecuteFunc("G2F_Saian_Trunks2_Actions")
''', '''        if G2V_Int[5630] < n and n > Frm_Dado[k] then
            set G2V_Bool[5630] = true
            set G2V_Int[5637] = 1
            call ExecuteFunc("G2F_Saian_Trunks2_Actions")
            set Frm_Dado[k] = G2V_Int[5630]
''')
cambia('''    if G2V_Caster[7150] != null then
        call G2_Base()
    endif
    if G2V_Caster[$CEE] != null then
        call ExecuteFunc("G2F_Saian_Trunks3_Actions")
        call DisableTrigger(G2T_Saian_Trunks3)
    endif
''', '    // v21v: las formas de Goku y Trunks duran Frm_DURA (Frm_Reloj); la oleada ya no las corta.\n')
cambia('        set Frm_Pts[p] = 0\n', '        set Frm_Pts[p] = 0\n        set Frm_Dado[p] = 0\n')

# --- libro ---
cambia('    set Tec_Max[56] = 0\n', '    set Tec_Max[56] = 1\n')
cambia('    set Cua_Nom[56] = "Power Up"\n    set Cua_Des[56] = "Técnica de D.O.N."\n',
       '    set Cua_Nom[56] = "Power Up"\n    set Cua_Des[56] = "Carga y sube una forma (50 s).|nTambién suben con las muertes."\n')
cambia('"Carga y sube una forma.|nTambién suben con las muertes."', '"Carga y sube una forma (50 s).|nTambién suben con las muertes."')

if prueba:
    cambia('lat\\\\v21u-', 'lat\\\\v21v-', src.count('lat\\\\v21u-'))
    cambia('v21u-don.txt', 'v21v-don.txt', src.count('v21u-don.txt'))
    assert 'lat\\\\v21u-' not in src and 'v21u-don.txt' not in src, 'quedan registros v21u'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21v', 'prueba' if prueba else 'normal')
