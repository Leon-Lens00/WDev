#!/usr/bin/env python3
"""v18z (15/11/2026): fase 10, primera parte: curaciones al morir la élite (Dark Moon; Leon: "curaciones al morir la
élite, después").

- Cada élite ('ne00'-'ne09') que muere de verdad suelta 4 runas a 120 de su cuerpo: 2 de vida ('rhe2') y 2 de maná
  ('rma2'). Se recogen como las bolsas, al pasar a 160 con el héroe vivo y fuera de la tienda; quien tiene la vida (o
  el maná) llena no la gasta y la deja a los demás. Vida: +25 % de la máxima del héroe; maná: +25 % del máximo del
  controlador. Duran 30 s y parpadean los 5 últimos; como mucho 40 en el suelo.
- Las runas son objetos nativos (sin datos de objeto nuevos): nadie tiene orden de recogerlas; las coge el código.
- Precarga de las dos runas y de sus dos efectos.
Prueba y lan: cada runa recogida se anota. Lan: además, al acabar cada oleada, mutaciones activas y una suma por
jugador de lo elegido en las cartas (suerte, refrescos, Filo, crítico, botín, evasión), para comparar los dos clientes.
Uso: v18z.py ENTRADA.j SALIDA.j [prueba|lan]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
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


cambia('integer Bolsa_N = 0\n', 'integer Bolsa_N = 0\n'
       'item array Cur_It\ninteger array Cur_Tipo\nreal array Cur_T\ninteger Cur_N = 0\ntimer Cur_Reloj = null\n'
       'string Cur_Log = ""\n')

CUR = r'''// v18z, fase 10: curaciones al morir la élite. Runas nativas de vida ('rhe2', tipo 0) y maná ('rma2', tipo 1).
function Cur_Quitar takes integer i returns nothing
    call RemoveItem(Cur_It[i])
    set Cur_N = Cur_N - 1
    set Cur_It[i] = Cur_It[Cur_N]
    set Cur_Tipo[i] = Cur_Tipo[Cur_N]
    set Cur_T[i] = Cur_T[Cur_N]
    set Cur_It[Cur_N] = null
endfunction

// true si el héroe de p la aprovecha (no la gasta con la vida o el maná llenos).
function Cur_Coger takes integer i, integer p returns boolean
    local unit h = Game_Hero[p]
    local unit c = Game_Ctrl[p]
    local real m
    if Cur_Tipo[i] == 0 then
        set m = GetUnitState(h, UNIT_STATE_MAX_LIFE)
        if GetWidgetLife(h) >= m - 0.5 then
            set h = null
            set c = null
            return false
        endif
        call SetWidgetLife(h, RMinBJ(m, GetWidgetLife(h) + 0.25 * m))
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl", h, "origin"))
    else
        if c == null then
            set h = null
            return false
        endif
        set m = GetUnitState(c, UNIT_STATE_MAX_MANA)
        if m <= 0. or GetUnitState(c, UNIT_STATE_MANA) >= m - 0.5 then
            set h = null
            set c = null
            return false
        endif
        call SetUnitState(c, UNIT_STATE_MANA, RMinBJ(m, GetUnitState(c, UNIT_STATE_MANA) + 0.25 * m))
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl", h, "origin"))
    endif
    set Cur_Log = "runa " + I2S(Cur_Tipo[i]) + " jugador " + I2S(p)
    set h = null
    set c = null
    return true
endfunction

function Cur_Tick takes nothing returns nothing
    local integer i = 0
    local integer p
    local unit h
    local real dx
    local real dy
    local boolean cogida
    loop
        exitwhen i >= Cur_N
        set Cur_T[i] = Cur_T[i] - 0.1
        set cogida = false
        set p = 0
        loop
            exitwhen p > 11 or cogida
            set h = Game_Hero[p]
            if Game_On[p] and h != null and UnitAlive(h) and not Shop_Open[p] then
                set dx = GetUnitX(h) - GetItemX(Cur_It[i])
                set dy = GetUnitY(h) - GetItemY(Cur_It[i])
                if dx * dx + dy * dy <= 25600. then
                    set cogida = Cur_Coger(i, p)
                    if cogida then
                        call ExecuteFunc("Cur_Anotar")
                    endif
                endif
            endif
            set p = p + 1
        endloop
        if cogida or Cur_T[i] <= 0. then
            call Cur_Quitar(i)
        else
            // Parpadeo los últimos 5 s.
            if Cur_T[i] < 5. then
                call SetItemVisible(Cur_It[i], ModuloInteger(R2I(Cur_T[i] * 4.), 2) == 0)
            endif
            set i = i + 1
        endif
    endloop
    if Cur_N == 0 then
        call PauseTimer(Cur_Reloj)
    endif
    set h = null
endfunction

function Cur_Soltar takes real x, real y, integer tipo returns nothing
    if Cur_N >= 40 then
        return
    endif
    if tipo == 0 then
        set Cur_It[Cur_N] = CreateItem('rhe2', x, y)
    else
        set Cur_It[Cur_N] = CreateItem('rma2', x, y)
    endif
    call SetItemInvulnerable(Cur_It[Cur_N], true)
    set Cur_Tipo[Cur_N] = tipo
    set Cur_T[Cur_N] = 30.
    set Cur_N = Cur_N + 1
    if Cur_Reloj == null then
        set Cur_Reloj = CreateTimer()
    endif
    if Cur_N == 1 then
        call TimerStart(Cur_Reloj, 0.1, true, function Cur_Tick)
    endif
endfunction

// Evento de muerte de oleada: sólo élites con muerte real.
function Cur_Muere takes nothing returns nothing
    local unit u = GetWaveEventUnit()
    local integer id = GetUnitTypeId(u)
    local real a
    local integer k = 0
    if WaveEventIsRetired or u == null or id < 'ne00' or id > 'ne09' then
        set u = null
        return
    endif
    set a = GetRandomReal(0., 360.)
    loop
        exitwhen k > 3
        call Cur_Soltar(GetUnitX(u) + 120. * Cos((a + 90. * k) * bj_DEGTORAD), GetUnitY(u) + 120. * Sin((a + 90. * k) * bj_DEGTORAD), ModuloInteger(k, 2))
        set k = k + 1
    endloop
    set u = null
endfunction

'''
if modo not in ('prueba', 'lan'):
    CUR += '''// Sin registro en la versión normal.
function Cur_Anotar takes nothing returns nothing
endfunction

'''
cambia('function DevFuego_Muere takes nothing returns nothing\n', CUR + 'function DevFuego_Muere takes nothing returns nothing\n')
cambia('    call RegisterWaveDeathEvent(function Mut_Muere)\n',
       '    call RegisterWaveDeathEvent(function Mut_Muere)\n    call RegisterWaveDeathEvent(function Cur_Muere)\n')
cambia('''    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\Bloodlust\\\\BloodlustTarget.mdl", -12000., 9000.))
''', '''    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\Bloodlust\\\\BloodlustTarget.mdl", -12000., 9000.))
    // v18z: runas de las curaciones y sus efectos.
    call RemoveItem(CreateItem('rhe2', -12000., 9000.))
    call RemoveItem(CreateItem('rma2', -12000., 9000.))
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Items\\\\AIhe\\\\AIheTarget.mdl", -12000., 9000.))
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Items\\\\AIma\\\\AImaTarget.mdl", -12000., 9000.))
''')

if modo in ('prueba', 'lan'):
    ANOTA = '''// v18z-prueba: cada runa recogida.
function Cur_Anotar takes nothing returns nothing
    call Bolsa_Anotar(Cur_Log)
endfunction

'''
    cambia('function DevFuego_Muere takes nothing returns nothing\n', ANOTA + 'function DevFuego_Muere takes nothing returns nothing\n')

if modo == 'lan':
    # Registro de mutaciones (como v18x-prueba) y suma de las cartas por jugador al acabar cada oleada y en cada elección.
    cambia('function DevFuego_Muere takes nothing returns nothing\n', '''// v18z-lan: mutaciones activas, unidades que recibió cada una y estado de las cartas de cada jugador.
function Mut_Anotar takes nothing returns nothing
    local integer i = 0
    local integer p = 0
    local string s = "ronda " + I2S(Ronda_Numero) + " mutaciones:"
    loop
        exitwhen i > 17
        if Cua_Activa[i] > 0 or Mut_Cuenta[i] > 0 then
            set s = s + " " + I2S(i) + "x" + I2S(Cua_Activa[i]) + "=" + I2S(Mut_Cuenta[i])
        endif
        set Mut_Cuenta[i] = 0
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)
    loop
        exitwhen p > 11
        if Game_On[p] then
            call Bolsa_Anotar("cartas j" + I2S(p) + " suerte " + I2S(Her_Suerte[p]) + " refrescos " + I2S(Her_Refrescos[p]) + " filo " + I2S(R2I(Her_Filo[p] * 100. + 0.5)) + " crit " + I2S(R2I(Her_Crit[p] * 100. + 0.5)) + " botin " + I2S(R2I(Her_Botin[p] * 100. + 0.5)) + " evasion " + I2S(Her_Evasion[p]) + " vidamax " + I2S(R2I(GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))) + " vel " + I2S(R2I(GetUnitMoveSpeed(Game_Hero[p]))))
        endif
        set p = p + 1
    endloop
endfunction

function Her_Anotar takes nothing returns nothing
    call Bolsa_Anotar(Her_Log)
endfunction

function DevFuego_Muere takes nothing returns nothing
''')
    cambia('''    if Cua_Paso[p] >= 3 then
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
    endif
''', '''    if Cua_Paso[p] >= 3 then
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
        call ExecuteFunc("Her_Anotar")
    endif
''')
    cambia('''function Ronda_AlTerminar takes nothing returns nothing
    local integer p = 0
    if GetWaveEventWave() == Ronda_Wave then
''', '''function Ronda_AlTerminar takes nothing returns nothing
    local integer p = 0
    if GetWaveEventWave() == Ronda_Wave then
        call ExecuteFunc("Mut_Anotar")
''')
    assert src.count('-v18s-') == 4, src.count('-v18s-')
    src = src.replace('-v18s-', '-v18z-')
elif modo == 'prueba':
    assert src.count('lat\\\\v18y-') == 4, src.count('lat\\\\v18y-')
    src = src.replace('lat\\\\v18y-', 'lat\\\\v18z-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18z', modo or 'normal')
