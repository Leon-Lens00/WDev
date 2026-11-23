#!/usr/bin/env python3
"""v20w (20/11/2026): libro de armas, recarga automática, dash 3 cargas, pulls comprados y economía fija
(plan docs/planes/devmission-armas-libro-economia-v20w.md).
Leon:
- Cuchillo con mucho más daño (arma de riesgo, cuerpo a cuerpo) y mejoras aún mayores.
- Las armas van en un libro arriba a la izquierda (V); F y G a su derecha pasan al arma anterior/siguiente que se tenga;
  Disparar (A) arriba a la derecha. Cada arma del libro, 1 s de recarga (objetos_v20w.py).
- Las habilidades del personaje van sueltas en la fila de abajo, sin libro (objetos_v20w.py + Don/Gk_Botones).
- Recarga automática (al vaciar el cargador); cambiar de arma corta la recarga y la nueva se recarga sola si lo
  necesita; se quita el botón de recarga. El dash ya no corta la recarga; 3 cargas de base, cada una vuelve en 2 s.
- Pulls sin elegir: se acumulan (Armas y héroe; héroe hasta 7 pasos, Armas hasta 8 elecciones).
- Bajo los cuadros de la pantalla de inicio, comprar pulls por rareza: bajo, medio y alto (mezcla de héroe y armas).
- Economía fija: 1-3 de oro por enemigo, bolsas más pequeñas, oro fijo al ganar la wave.
Uso: v20w.py ENTRADA.j SALIDA.j [prueba]   (normal de v20v; prueba de v20v-prueba)
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


# --- globales
cambia('integer array ArmC_Total\n', '''integer array ArmC_Total
// v20w: paso del héroe desde el que quedan cartas sin elegir (Cua_Sortear); botones de compra de pulls.
integer array HerS_Desde
unit array Cua_CompBt
texttag array Cua_TCompra
''')

# --- 1) cuchillo: ~2x el DPS de la SMG en T1 hasta ~3x en T6
for w, viejo, nuevo in ((30, 38, 112), (31, 38, 125), (32, 41, 141), (33, 45, 158), (34, 50, 181), (35, 56, 203)):
    cambia('    set Arm_Dano[%d] = %d.\n' % (w, viejo), '    set Arm_Dano[%d] = %d.\n' % (w, nuevo))

# --- 2) libro de armas, F y G
cambia('''    function Arm_Botones takes integer p returns nothing
        local unit u= Game_Ctrl[p]
        local integer c= 0
''', '''    // v20w: las armas van en el libro 'AWlb' (V); sólo se ven las que se tienen, con su tier de nivel.
    function Arm_Libro takes integer p returns nothing
        local unit u= Game_Ctrl[p]
        local integer c= 0
        if u == null then
            return
        endif
        if GetUnitAbilityLevel(u, 'AWlb') == 0 then
            call UnitAddAbility(u, 'AWlb')
        endif
        loop
            exitwhen c > 6
            call SetPlayerAbilityAvailable(Player(p), 'Aw00' + c, Arm_Tier[p * 7 + c] > 0)
            if Arm_Tier[p * 7 + c] > 0 then
                call SetUnitAbilityLevel(u, 'Aw00' + c, Arm_Tier[p * 7 + c])
            endif
            set c=c + 1
        endloop
        set u=null
    endfunction

    function Arm_Botones takes integer p returns nothing
        local unit u= Game_Ctrl[p]
        local integer c= 0
''')
cambia('''        call UnitAddAbility(u, 'Aw08')
        loop
            exitwhen c > 6
            if Arm_Tier[p * 7 + c] > 0 then
                call UnitAddAbility(u, 'Aw00' + c)
                call SetUnitAbilityLevel(u, 'Aw00' + c, Arm_Tier[p * 7 + c])
            endif
            set c=c + 1
        endloop
        set u=null
    endfunction
''', '''        // v20w: sin botón de recarga (es automática); F y G cambian de arma.
        call UnitAddAbility(u, 'AwFa')
        call UnitAddAbility(u, 'AwGa')
        call Arm_Libro(p)
        set u=null
    endfunction
''')
cambia('''    function Arm_Latido takes nothing returns nothing
''', '''    // v20w: F (d = -1) y G (d = 1): arma anterior o siguiente que se tenga, en el orden del libro (1 2 3 4 5 6 0).
    function Arm_Ciclar takes integer p,integer d returns nothing
        local integer i= ModuloInteger(Arm_Cat[p] + 6, 7)
        local integer n= 0
        local integer c
        loop
            exitwhen n >= 6
            set i=ModuloInteger(i + d + 7, 7)
            set c=ModuloInteger(i + 1, 7)
            if Arm_Tier[p * 7 + c] > 0 then
                call Arm_Elegir(p , c)
                return
            endif
            set n=n + 1
        endloop
        call Arm_Error(p)
    endfunction

    function Arm_BotonF takes nothing returns nothing
        call Arm_Ciclar(GetPlayerId(GetOwningPlayer(GetTriggerUnit())) , -1)
    endfunction

    function Arm_BotonG takes nothing returns nothing
        call Arm_Ciclar(GetPlayerId(GetOwningPlayer(GetTriggerUnit())) , 1)
    endfunction

    function Arm_Latido takes nothing returns nothing
''')
cambia("        call RegisterSpellEffectEvent('Aw08' , function Arm_BotonRecarga)\n",
       "        call RegisterSpellEffectEvent('AwFa' , function Arm_BotonF)\n"
       "        call RegisterSpellEffectEvent('AwGa' , function Arm_BotonG)\n")
# ArmC_Subir y la tienda vieja: el tier primero y luego el libro.
cambia('''    if t == 1 then
        call UnitAddAbility(Game_Ctrl[p], 'Aw00' + e)
    endif
    call SetUnitAbilityLevel(Game_Ctrl[p], 'Aw00' + e, t)
    set Arm_Tier[i] = t
''', '''    set Arm_Tier[i] = t
    call Arm_Libro(p)
''')
cambia('''    if t == 1 then
        call UnitAddAbility(Game_Ctrl[p], 'Aw00' + c)
    endif
    call SetUnitAbilityLevel(Game_Ctrl[p], 'Aw00' + c, t)
    set Arm_Tier[i] = t
''', '''    set Arm_Tier[i] = t
    call Arm_Libro(p)
''')

# --- 3) recarga automática al vaciar el cargador; el dash ya no la corta
cambia('''                set Arm_Clip[i]=Arm_Clip[i] + n
                set Arm_Rva[i]=Arm_Rva[i] - n
            endif
''', '''                set Arm_Clip[i]=Arm_Clip[i] + n
                set Arm_Rva[i]=Arm_Rva[i] - n
            endif
            // v20w: recarga automática con el cargador vacío (también al cambiar a un arma vacía).
            set i=p * 7 + Arm_Cat[p]
            if Arm_Fin[p] <= 0. and Game_Pair[p] != 0 and Arm_Cat[p] != 5 and Arm_Tier[i] > 0 and Arm_Clip[i] <= 0 and Arm_Rva[i] > 0 then
                call s__RapidPair_finish(Game_Pair[p],true)
                set Arm_Fin[p]=time + Arm_Rec[Arm_W(p)] * ( 1. - Arm_Agil[i] )
            endif
''')
cambia('''        // The dash replaces the burst and its artificial walk, and cancels a reload.
        call s__RapidPair_finish(this,false)
        set Arm_Fin[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))]=0.
''', '''        // The dash replaces the burst and its artificial walk. v20w: it no longer cancels a reload.
        call s__RapidPair_finish(this,false)
''')

# --- 4) dash: 3 cargas, cada una vuelve en 2 s
cambia('''function Dash_Max takes integer p returns integer
    return 2 + Dash_Extra[p]
endfunction

function Dash_Recarga takes integer p returns real
    return RMaxBJ(3.5, 6. * (1. - Dash_RecRed[p]))
endfunction
''', '''function Dash_Max takes integer p returns integer
    return 3 + Dash_Extra[p]
endfunction

// v20w: 2 s por carga (las cartas de Enfriamiento la bajan hasta 1 s).
function Dash_Recarga takes integer p returns real
    return RMaxBJ(1., 2. * (1. - Dash_RecRed[p]))
endfunction
''')

# --- 5) habilidades del personaje sueltas en la fila de abajo (sin libro)
cambia('''function Gk_Botones takes integer p returns nothing
    call UnitAddAbility(Game_Ctrl[p], 'ALGk')
endfunction
''', '''function Gk_Botones takes integer p returns nothing
    // v20w: sin libro; los puentes van en la fila de abajo (objetos_v20w.py).
    call UnitAddAbility(Game_Ctrl[p], 'AGk1')
    call UnitAddAbility(Game_Ctrl[p], 'AGk2')
    call UnitAddAbility(Game_Ctrl[p], 'AGk5')
    call UnitAddAbility(Game_Ctrl[p], 'AGk3')
endfunction
''')


def anadir(ids, sangria='        '):
    return ''.join("%scall UnitAddAbility(Game_Ctrl[p], '%s')\n" % (sangria, r) for r in ids)


cambia('''function Don_Botones takes integer p, integer id returns nothing
    if id == 'h005' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTb')
    elseif id == 'h006' then
        call UnitAddAbility(Game_Ctrl[p], 'ALCb')
    elseif id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTa')
    endif
    if id == 'hFrz' then
        call UnitAddAbility(Game_Ctrl[p], 'ALFz')
    endif
    if id == 'hTrk' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTr')
    endif
    if id == 'hNar' then
        call UnitAddAbility(Game_Ctrl[p], 'ALNa')
    endif
endfunction
''', '''function Don_Botones takes integer p, integer id returns nothing
    // v20w: sin libro; los puentes de cada personaje van sueltos en la fila de abajo (objetos_v20w.py).
    if id == 'h005' then
''' + anadir(('ATb1', 'ATb2', 'ATb3', 'ATb4')) + '''    elseif id == 'h006' then
''' + anadir(('ACb1', 'ACb5', 'ACb3', 'ACb4')) + '''    elseif id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' then
''' + anadir(('ATa1', 'ATa2')) + '''    endif
    if id == 'hFrz' then
''' + anadir(('AFz3', 'AFz5', 'AFz2', 'AFz4')) + '''    endif
    if id == 'hTrk' then
''' + anadir(('ATr4', 'ATr2', 'ATr3', 'ATr5')) + '''    endif
    if id == 'hNar' then
''' + anadir(('ANa5', 'ANa2', 'ANa6', 'ANa4', 'ANa3')) + '''    endif
endfunction
''')

# --- 6) economía fija
cambia('''            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 10.)) * (2 + Ronda_Numero) / 3)
''', '''            // v20w: economía fija, de 1 a 3 de oro por enemigo (el comentario de arriba ya no vale).
            call Oro_Dar(k, GetRandomInt(1, 3))
''')
cambia('    set Bolsa_C = IMaxBJ(1, R2I(150. * r * jug / d + 0.5))\n',
       '    // v20w: economía fija: bolsa común de 10 (élite 20, jefe 3 de 20).\n    set Bolsa_C = 10\n')
cambia('''    if tipo == 1 then
        set v = R2I(1.5 * Bolsa_C + 0.5)
    elseif tipo == 2 then
        set v = R2I(2.25 * Bolsa_C + 0.5)
    endif
''', '''    if tipo == 1 or tipo == 2 then
        set v = 20
    endif
''')
cambia('                call Oro_Dar(p, 40 * Ronda_Numero + 10 * Ronda_Numero * Ronda_Numero)\n',
       '                // v20w: oro fijo al ganar la wave.\n                call Oro_Dar(p, 100)\n')
cambia('        return "Te devuelve el " + I2S(v) + " % de lo|nque gastes en armas."\n',
       '        return "Te devuelve el " + I2S(v) + " % de lo|nque gastes en pulls."\n')

# --- 7) pasos del héroe: nombres de los pulls comprados y de los guardados
cambia('''    if k < 2 then
        return "Mejora del héroe (" + I2S(k + 1) + "/2)"
    elseif Her_ExTipo[p * 8 + k - 2] == 1 then
''', '''    if k < 2 then
        return "Mejora del héroe (" + I2S(k + 1) + "/2)"
    elseif Her_ExTipo[p * 8 + k - 2] == 3 then
        return "Pull comprado · bajo"
    elseif Her_ExTipo[p * 8 + k - 2] == 4 then
        return "Pull comprado · medio"
    elseif Her_ExTipo[p * 8 + k - 2] == 5 then
        return "Pull comprado · alto"
    elseif Her_ExTipo[p * 8 + k - 2] == 6 then
        return "Mejora del héroe (guardada)"
    elseif Her_ExTipo[p * 8 + k - 2] == 1 then
''')

# Cua_Sortear: desde qué paso quedan cartas sin elegir.
cambia('''        if Game_On[p] then
            set Cua_Paso[p] = 0
            call Cua_Pintar(p)
''', '''        if Game_On[p] then
            set HerS_Desde[p] = IMaxBJ(0, Cua_Paso[p] - 3)
            set Cua_Paso[p] = 0
            call Cua_Pintar(p)
''')

# Her_Sortear: Armas acumuladas; pasos del héroe guardados, luego first blood, MVP y rachas, hasta 7 pasos.
cambia('''function Her_Sortear takes nothing returns nothing
    local integer p = 0
    local boolean g
    local integer e
    local integer q
''', '''function Her_Sortear takes nothing returns nothing
    local integer p = 0
    local boolean g
    local integer e
    local integer q
    local integer j
    local integer h
    local integer m
    local integer array lc
    local integer array lq
    local integer array lt
    local integer array lx
    local integer array ln
''')
cambia('''            // v20v: 2 elecciones de Armas por oleada (1 la primera vez); las que no se eligen se pierden.
            if not Her_Ok then
                set ArmC_Total[p] = 1
            else
                set ArmC_Total[p] = 2
            endif
            set ArmC_Quedan[p] = ArmC_Total[p]
            call ArmC_Cartas(p)
            set g = Her_SinOro[p] >= 3
''', '''            // v20w: 2 elecciones de Armas por oleada (1 la primera vez); las que no se eligen se acumulan, hasta 8.
            if not Her_Ok then
                set ArmC_Quedan[p] = 1
            else
                set ArmC_Quedan[p] = IMinBJ(8, ArmC_Quedan[p] + 2)
            endif
            set ArmC_Total[p] = ArmC_Quedan[p]
            call ArmC_Cartas(p)
            // v20w: los pasos del héroe sin elegir (desde HerS_Desde) se guardan con sus cartas.
            set m = 0
            if Her_Ok then
                set j = HerS_Desde[p]
                loop
                    exitwhen j >= 2 + Her_Extra[p] or m >= 5
                    set h = 0
                    loop
                        exitwhen h > 3
                        set lc[m * 4 + h] = Cua_HCand[p * 40 + j * 5 + h]
                        set lq[m * 4 + h] = Her_Cal[p * 40 + j * 5 + h]
                        set lt[m * 4 + h] = Her_Tipo[p * 40 + j * 5 + h]
                        set h = h + 1
                    endloop
                    if j < 2 then
                        set lx[m] = 6
                        set ln[m] = -1
                    else
                        set lx[m] = Her_ExTipo[p * 8 + j - 2]
                        set ln[m] = Her_ExMin[p * 8 + j - 2]
                    endif
                    set m = m + 1
                    set j = j + 1
                endloop
            endif
            set g = Her_SinOro[p] >= 3
''')
cambia('''            set Her_Extra[p] = 0
            set Her_ExFB[p] = Her_FB[p]
            if Her_FB[p] then
                set Her_ExMin[p * 8] = 2
                set Her_ExTipo[p * 8] = 1
                call Her_CartasExtra(p, p * 40 + 10, 2)
                set Her_Extra[p] = 1
            endif
            // v20a: MVP de la oleada (con 2 o más jugadores): pull extra T3 o T4.
            if Her_MVP[p] then
''', '''            set Her_Extra[p] = 0
            set Her_ExFB[p] = Her_FB[p]
            // v20w: primero los guardados, tal cual; en total, como mucho 7 pasos (2 + 5 extra).
            set j = 0
            loop
                exitwhen j >= m or Her_Extra[p] >= 5
                set h = 0
                loop
                    exitwhen h > 3
                    set Cua_HCand[p * 40 + (2 + Her_Extra[p]) * 5 + h] = lc[j * 4 + h]
                    set Her_Cal[p * 40 + (2 + Her_Extra[p]) * 5 + h] = lq[j * 4 + h]
                    set Her_Tipo[p * 40 + (2 + Her_Extra[p]) * 5 + h] = lt[j * 4 + h]
                    set h = h + 1
                endloop
                set Her_ExTipo[p * 8 + Her_Extra[p]] = lx[j]
                set Her_ExMin[p * 8 + Her_Extra[p]] = ln[j]
                set Her_Extra[p] = Her_Extra[p] + 1
                set j = j + 1
            endloop
            if Her_FB[p] and Her_Extra[p] < 5 then
                set Her_ExMin[p * 8 + Her_Extra[p]] = 2
                set Her_ExTipo[p * 8 + Her_Extra[p]] = 1
                call Her_CartasExtra(p, p * 40 + (2 + Her_Extra[p]) * 5, 2)
                set Her_Extra[p] = Her_Extra[p] + 1
            endif
            // v20a: MVP de la oleada (con 2 o más jugadores): pull extra T3 o T4.
            if Her_MVP[p] and Her_Extra[p] < 5 then
''')
cambia('''                set Her_Extra[p] = Her_Extra[p] + 1
                set Her_MVP[p] = false
            endif
''', '''                set Her_Extra[p] = Her_Extra[p] + 1
            endif
            set Her_MVP[p] = false
''')
cambia('''            loop
                exitwhen e <= 0
                set Her_ExMin[p * 8 + Her_Extra[p]] = q
''', '''            loop
                exitwhen e <= 0 or Her_Extra[p] >= 5
                set Her_ExMin[p * 8 + Her_Extra[p]] = q
''')
cambia('''            set Her_PullLog = Her_PullLog + "; j" + I2S(p) + " extra " + I2S(Her_Extra[p]) + " fb "''',
       '''            set Her_PullLog = Her_PullLog + "; j" + I2S(p) + " guardados " + I2S(m) + " armas " + I2S(ArmC_Quedan[p]) + " extra " + I2S(Her_Extra[p]) + " fb "''')

# --- 8) efecto común de las cartas de Armas (también en los pulls comprados del héroe)
cambia('''// v20v: aplica la carta c de Armas de p (código común, desde el clic sincronizado) y reparte la siguiente mano.
''', '''// v20w: efecto de la carta x (categoría e, calidad q) de Armas, también desde un pull del héroe.
function ArmC_Efecto takes integer p, integer x, integer e, integer q returns nothing
    if x == 86 or x == 87 then
        call ArmC_Subir(p, e)
    elseif x == 88 then
        set Vidas_Actual[p] = Vidas_Actual[p] + 1
        if GetUnitAbilityLevel(Game_Hero[p], 'Arei') == 0 then
            call UnitAddAbility(Game_Hero[p], 'Arei')
        endif
    else
        set Her_TipoSel = e
        call Her_Aplicar(p, x, q)
        call Pan_Registrar(p, x, q)
    endif
endfunction

// v20v: aplica la carta c de Armas de p (código común, desde el clic sincronizado) y reparte la siguiente mano.
''')
cambia('''    if x == 86 or x == 87 then
        call ArmC_Subir(p, e)
    elseif x == 88 then
        set Vidas_Actual[p] = Vidas_Actual[p] + 1
        if GetUnitAbilityLevel(Game_Hero[p], 'Arei') == 0 then
            call UnitAddAbility(Game_Hero[p], 'Arei')
        endif
    else
        set Her_TipoSel = e
        call Her_Aplicar(p, x, Her_Cal[k])
        call Pan_Registrar(p, x, Her_Cal[k])
    endif
    if StringLength(Cua_Resumen[p]) > 0 then
''', '''    call ArmC_Efecto(p, x, e, Her_Cal[k])
    if StringLength(Cua_Resumen[p]) > 0 then
''')

# --- 9) pulls comprados: precio, mano, compra y refresco
cambia('''// v18y: quinta carta del paso del héroe: cambia las 4 cartas (cuesta 1 de suerte).
function Her_Refrescar takes integer p returns nothing
''', '''// v20w: calidad de una carta de un pull comprado de rareza r (0 bajo, 1 medio, 2 alto); 0..4 = T1..T5.
function HerC_Cal takes integer r returns integer
    local integer d = GetRandomInt(1, 100)
    if r == 0 then
        if d <= 55 then
            return 0
        elseif d <= 90 then
            return 1
        endif
        return 2
    elseif r == 1 then
        if d <= 10 then
            return 0
        elseif d <= 45 then
            return 1
        endif
        return 2
    endif
    if d <= 20 then
        return 2
    elseif d <= 90 then
        return 3
    endif
    return 4
endfunction

// v20w: mano de un pull comprado en k: cartas del héroe y 2 de armas (Filo, Golpe de suerte, Calibre, Cargador ágil;
// en medio y alto, Subir tier de un arma que tiene si se puede). Las técnicas se quedan como salieron.
function HerC_Mano takes integer p, integer k, integer r returns nothing
    local integer array lx
    local integer array lt
    local integer array u
    local integer n = 0
    local integer nu = 0
    local integer i = 0
    local integer s = 3
    local integer j
    local integer c = 0
    local integer t
    local integer puestas = 0
    call Her_CartasExtra(p, k, 0)
    loop
        exitwhen i > 3
        if Cua_HCand[k + i] < 40 or Cua_HCand[k + i] >= 78 then
            set Her_Cal[k + i] = HerC_Cal(r)
        endif
        set i = i + 1
    endloop
    loop
        exitwhen c > 6
        set t = Arm_Tier[p * 7 + c]
        if t > 0 and t < 6 and Ronda_Pasadas() >= Arm_Req(t + 1) then
            set u[nu] = c
            set nu = nu + 1
        endif
        set c = c + 1
    endloop
    set lx[0] = 20
    set lt[0] = -1
    set lx[1] = 23
    set lt[1] = -1
    set n = 2
    set t = Arm_TipoAzar(p, 83)
    if t >= 0 then
        set lx[n] = 83
        set lt[n] = t
        set n = n + 1
    endif
    set t = Arm_TipoAzar(p, 84)
    if t >= 0 then
        set lx[n] = 84
        set lt[n] = t
        set n = n + 1
    endif
    loop
        exitwhen s < 1 or puestas >= 2
        if Cua_HCand[k + s] < 40 or Cua_HCand[k + s] >= 78 then
            if puestas == 0 and r >= 1 and nu > 0 then
                set c = u[GetRandomInt(0, nu - 1)]
                set Cua_HCand[k + s] = 86
                set Her_Tipo[k + s] = c
                set Her_Cal[k + s] = Arm_Tier[p * 7 + c]
                if Arm_Tier[p * 7 + c] >= 5 then
                    set Her_Cal[k + s] = 6
                endif
            else
                set j = GetRandomInt(0, n - 1)
                set Cua_HCand[k + s] = lx[j]
                set Her_Tipo[k + s] = lt[j]
                set Her_Cal[k + s] = HerC_Cal(r)
                set n = n - 1
                set lx[j] = lx[n]
                set lt[j] = lt[n]
            endif
            set puestas = puestas + 1
        endif
        set s = s - 1
    endloop
endfunction

// v20w: compra de un pull de rareza r desde la pantalla de inicio (código común, desde el clic sincronizado).
function HerC_Comprar takes integer p, integer r returns nothing
    local integer n = 2 + Her_Extra[p]
    local integer v = HerC_Precio(r)
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    if not Her_Ok or n >= 7 or oro < v then
        call UI_Error(p)
        return
    endif
    call UI_Click(p)
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - v)
    call Oro_Dar(p, R2I(v * Her_Reembolso[p]))
    set Her_ExTipo[p * 8 + n - 2] = 3 + r
    set Her_ExMin[p * 8 + n - 2] = r
    call HerC_Mano(p, p * 40 + n * 5, r)
    set Her_Extra[p] = Her_Extra[p] + 1
    set Cop_Log = "pull compra j" + I2S(p) + " rareza " + I2S(r) + " precio " + I2S(v) + " pasos " + I2S(2 + Her_Extra[p]) + " paso " + I2S(Cua_Paso[p]) + " cartas " + I2S(Cua_HCand[p * 40 + n * 5]) + " " + I2S(Cua_HCand[p * 40 + n * 5 + 1]) + " " + I2S(Cua_HCand[p * 40 + n * 5 + 2]) + " " + I2S(Cua_HCand[p * 40 + n * 5 + 3])
    call ExecuteFunc("Cop_Anotar")
    call Cua_Pintar(p)
    call Cua_Ver(p)
endfunction

// v18y: quinta carta del paso del héroe: cambia las 4 cartas (cuesta 1 de suerte).
function Her_Refrescar takes integer p returns nothing
''')
cambia('''    if Cua_Paso[p] >= 5 then
        call Her_CartasExtra(p, Her_K(p, 0), Her_ExMin[p * 8 + Cua_Paso[p] - 5])
''', '''    if Cua_Paso[p] >= 5 and Her_ExTipo[p * 8 + Cua_Paso[p] - 5] >= 3 and Her_ExTipo[p * 8 + Cua_Paso[p] - 5] <= 5 then
        call HerC_Mano(p, Her_K(p, 0), Her_ExTipo[p * 8 + Cua_Paso[p] - 5] - 3)
    elseif Cua_Paso[p] >= 5 and Her_ExTipo[p * 8 + Cua_Paso[p] - 5] != 6 then
        call Her_CartasExtra(p, Her_K(p, 0), Her_ExMin[p * 8 + Cua_Paso[p] - 5])
''')

# Cua_Hacer: las cartas de armas de un pull del héroe usan el efecto de Armas (en -prueba sigue Her_Anotar detrás).
cambia('''    local integer x = Cua_Item(p, c / 2)
    local integer q = 0
    if Cua_Modo[p] == 3 then
        call ArmC_Hacer(p, c / 2)
        return
    endif
    set Cua_Elegido[p * 12 + Cua_Paso[p]] = x
    if Cua_Paso[p] >= 3 then
        set Her_TipoSel = Her_Tipo[Her_K(p, c / 2)]
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
        call Pan_Registrar(p, x, Her_Cal[Her_K(p, c / 2)])
''', '''    local integer x = Cua_Item(p, c / 2)
    local integer q = 0
    local integer k
    if Cua_Modo[p] == 3 then
        call ArmC_Hacer(p, c / 2)
        return
    endif
    set Cua_Elegido[p * 12 + Cua_Paso[p]] = x
    if Cua_Paso[p] >= 3 then
        // v20w: Subir tier que ya no se puede (se subió en Armas) o Arma nueva que ya se tiene pasan a Filo.
        set k = Her_K(p, c / 2)
        if (x == 86 and (Arm_Tier[p * 7 + Her_Tipo[k]] >= 6 or Ronda_Pasadas() < Arm_Req(Arm_Tier[p * 7 + Her_Tipo[k]] + 1))) or (x == 87 and Arm_Tier[p * 7 + Her_Tipo[k]] > 0) then
            set x = 20
            set Her_Cal[k] = IMinBJ(4, Her_Cal[k])
            set Cua_Elegido[p * 12 + Cua_Paso[p]] = x
        endif
        if x >= 86 and x <= 88 then
            call ArmC_Efecto(p, x, Her_Tipo[k], Her_Cal[k])
        else
            set Her_TipoSel = Her_Tipo[k]
            call Her_Aplicar(p, x, Her_Cal[k])
            call Pan_Registrar(p, x, Her_Cal[k])
        endif
''')

# Cua_Pintar: foto de la categoría también en los pulls del héroe.
cambia('''        if Cua_Modo[p] == 3 and (Cua_Item(p, c) == 86 or Cua_Item(p, c) == 87) then
            set tex = Cat_Tex[IMaxBJ(0, IMinBJ(6, Her_Tipo[p * 40 + 35 + c]))]
''', '''        if Cua_EsCarta(p) and c < 4 and (Cua_Item(p, c) == 86 or Cua_Item(p, c) == 87) then
            set tex = Cat_Tex[IMaxBJ(0, IMinBJ(6, Her_Tipo[IntegerTertiaryOp(Cua_Modo[p] == 3, p * 40 + 35 + c, p * 40 + (Cua_Paso[p] - 3) * 5 + c)]))]
''')

# --- 10) botones de compra en la pantalla de inicio
cambia('''// v18m: descripción de cada cuadro de la pantalla de inicio, con lo que falta por elegir.
''', '''// v20w: precio y texto del botón de compra del pull de rareza r.
function HerC_Precio takes integer r returns integer
    if r == 0 then
        return 50
    elseif r == 1 then
        return 120
    endif
    return 350
endfunction

function HerC_Texto takes integer r returns string
    if r == 0 then
        return "|cffd8d8d8Pull bajo|r · |cffffcc00" + I2S(HerC_Precio(r)) + "|r"
    elseif r == 1 then
        return "|cff5aa0ffPull medio|r · |cffffcc00" + I2S(HerC_Precio(r)) + "|r"
    endif
    return "|cffc070ffPull alto|r · |cffffcc00" + I2S(HerC_Precio(r)) + "|r"
endfunction

// v18m: descripción de cada cuadro de la pantalla de inicio, con lo que falta por elegir.
''')
cambia('''    call Pan_Ver(p, ver and inicio)
    if Cua_TCab == null or not ver then
''', '''    call Pan_Ver(p, ver and inicio)
    // v20w: botones de compra de pulls, sólo en la pantalla de inicio; grises sin oro o con 7 pasos.
    set c = 0
    loop
        exitwhen c > 2
        set a = 0
        set ic = 255
        if ver and inicio and Her_Ok then
            set a = 255
            if 2 + Her_Extra[p] >= 7 or GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) < HerC_Precio(c) then
                set ic = 110
            endif
        endif
        call SetUnitVertexColor(Cua_CompBt[c], ic, ic, ic, a)
        if Cua_TCompra[c] != null then
            if a > 0 then
                call Cua_Centro(p, Cua_TCompra[c], HerC_Texto(c), Cua_PX(2 + 2 * c), 785, 0.02)
            endif
            call SetTextTagVisibility(Cua_TCompra[c], a > 0)
        endif
        set c = c + 1
    endloop
    if Cua_TCab == null or not ver then
''')
cambia('''    loop
        exitwhen i > 4
        set Cua_TN[i] = Cua_Tag()
        set Cua_TD[i] = Cua_Tag()
        set i = i + 1
    endloop
endfunction
''', '''    loop
        exitwhen i > 4
        set Cua_TN[i] = Cua_Tag()
        set Cua_TD[i] = Cua_Tag()
        set i = i + 1
    endloop
    // v20w: textos de los 3 botones de compra de pulls.
    set i = 0
    loop
        exitwhen i > 2
        set Cua_TCompra[i] = Cua_Tag()
        set i = i + 1
    endloop
endfunction
''')
cambia('''        set Cua_TN[i] = null
        set Cua_TD[i] = null
        set i = i + 1
    endloop
endfunction
''', '''        set Cua_TN[i] = null
        set Cua_TD[i] = null
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 2
        call DestroyTextTag(Cua_TCompra[i])
        set Cua_TCompra[i] = null
        set i = i + 1
    endloop
endfunction
''')
cambia('''    // v18g: pie de la ventana en textura.
    // v19r: sin el pie''', '''    // v20w: 3 botones de compra de pulls bajo los cuadros de la pantalla de inicio (trackables 50-52).
    set s = 0
    loop
        exitwhen s > 2
        set Cua_CompBt[s] = Cua_Pic(Cua_PX(2 + 2 * s), 785, 170, 50, 399, 'DS0A')
        set p = 0
        loop
            exitwhen p > 11
            if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
                call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(2 + 2 * s), 785, 50 + s)
            endif
            set p = p + 1
        endloop
        set s = s + 1
    endloop
    // v18g: pie de la ventana en textura.
    // v19r: sin el pie''')
cambia('''    if k >= 40 then
        if Cua_Open[p] then
            call Cua_Clic(p, k - 40)
        endif
        return
    endif
''', '''    // v20w: compra de pulls (bajo, medio, alto) en la pantalla de inicio.
    if k >= 50 and k <= 52 then
        if Cua_Open[p] and Cua_Modo[p] == 0 and Cua_Fla[p] == 0 then
            call HerC_Comprar(p, k - 50)
        endif
        return
    endif
    if k >= 40 then
        if Cua_Open[p] then
            call Cua_Clic(p, k - 40)
        endif
        return
    endif
''')

if prueba:
    for viejo, nuevo in (('lat\\\\v20v-', 'lat\\\\v20w-'), ('v20v-don.txt', 'v20w-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20w', 'prueba' if prueba else 'normal')
