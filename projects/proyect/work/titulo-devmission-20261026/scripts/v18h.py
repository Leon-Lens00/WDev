#!/usr/bin/env python3
"""v18h (15/11/2026), fase 4: bolsas de oro (plan devmission-mejoras-darkmoon, quinta tanda y "Bolsas de oro").

Valores míos (Leon: "el ajuste de números me lo deja a mí"), a revisar con el registro:
- Fondo de la ronda r: 150 × r por jugador (J = DevWave_Jug), extra sobre el oro de muerte y el premio de ronda.
- Bolsas: comunes 2 + J por ronda, en las muertes de comunes i × Total / (2 + J + 1) (como los eventos de élites);
  una por cada élite muerta ('ne00'..'ne09'); el jefe ('nj02'..'nj0A') suelta 3 alrededor.
- Tamaños: común c, élite 1,5 c, jefe 2,25 c cada una, con c = 150 r J / (comunes + 1,5 (r − 1) J + 6,75): el
  fondo se reparte entero si salen las élites previstas y el jefe. En la ronda 1 (sin jefe) el término 6,75 se deja
  para que c crezca con la ronda. J 1: c = 15, 27, 35, 42, 48, 52, 56, 59, 62, 65 (élite ×1,5, jefe ×2,25).
- Sólo con muerte real (no las unidades retiradas). Máximo 60 bolsas en el suelo; las que no caben no salen.
- Recogida al acercarse: un reloj de 0,10 s que sólo corre con bolsas en el suelo mira la distancia (cuadrada, sin
  handles) de cada héroe vivo a cada bolsa; a ≤ 160 la recoge el primero por número de jugador. Oro a quien la
  recoge, efecto de montón de oro y "+N" en dorado sólo en su cliente (texttag local de 2 s).
- Caducan a los 35 s; parpadean los últimos 5 s. El oro de una bolsa caducada se pierde.
Todo en código común (posición de héroes y reloj iguales en todos los clientes); sólo el texttag es local.
Prueba: registros en lat\\v18h-*.txt y lat\\v18h-bolsas.txt (bolsas y resumen de oro por ronda).
Uso: v18h.py v18g/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


def anota(s):
    return f'        call Bolsa_Anotar({s})\n' if prueba else ''


una('unit array DevTienda_Pieza\n', '''unit array DevTienda_Pieza
unit array Bolsa_U
integer array Bolsa_Oro
real array Bolsa_T
integer Bolsa_N = 0
timer Bolsa_Reloj = null
integer Bolsa_C = 0
integer Bolsa_NC = 0
integer Bolsa_SigC = 1
''' + ('''integer array Bolsa_Cuenta
string array Bolsa_L
integer Bolsa_LN = 0
timer Bolsa_LT = null
''' if prueba else ''))

registro = '''
// v18h-prueba: registro de bolsas en lat\\\\v18h-bolsas.txt (tiempo del de súper élite). Cuenta: 0 oro de muerte,
// 1 oro en bolsas creadas, 2 recogido, 3 caducado, 4 bolsas creadas, 5 recogidas, 6 caducadas.
function Bolsa_Escribir takes nothing returns nothing
    local integer i = 0
    call PreloadGenClear()
    loop
        exitwhen i >= Bolsa_LN
        call Preload(Bolsa_L[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("lat\\\\v18h-bolsas.txt")
endfunction

function Bolsa_Anotar takes string s returns nothing
    if Sup_Tiempo == null then
        set Sup_Tiempo = CreateTimer()
        call TimerStart(Sup_Tiempo, 100000., false, null)
        set Sup_LT = CreateTimer()
    endif
    if Bolsa_LT == null then
        set Bolsa_LT = CreateTimer()
    endif
    if Bolsa_LN >= 400 then
        return
    endif
    set Bolsa_L[Bolsa_LN] = R2S(TimerGetElapsed(Sup_Tiempo)) + " " + s
    set Bolsa_LN = Bolsa_LN + 1
    call TimerStart(Bolsa_LT, 2., false, function Bolsa_Escribir)
endfunction
''' if prueba else ''

bolsas = registro + '''
// v18h: bolsas de oro (fase 4). Tamaño de la ronda y bolsas comunes previstas; en Ronda_Lanzar, tras DevWave_Start.
function Bolsa_Ronda takes nothing returns nothing
    local integer r = Ronda_Numero
    local integer jug = IMaxBJ(1, DevWave_Jug)
    local real d
    set Bolsa_NC = 2 + jug
    set Bolsa_SigC = 1
    // El término del jefe (6,75) también en la ronda 1, que no tiene: así la bolsa común crece siempre con la ronda.
    set d = Bolsa_NC + 1.5 * (r - 1) * jug + 6.75
    set Bolsa_C = IMaxBJ(1, R2I(150. * r * jug / d + 0.5))
''' + ('''    set Bolsa_Cuenta[0] = 0
    set Bolsa_Cuenta[1] = 0
    set Bolsa_Cuenta[2] = 0
    set Bolsa_Cuenta[3] = 0
    set Bolsa_Cuenta[4] = 0
    set Bolsa_Cuenta[5] = 0
    set Bolsa_Cuenta[6] = 0
    call Bolsa_Anotar("r" + I2S(r) + " J " + I2S(jug) + ": comun " + I2S(Bolsa_C) + ", elite " + I2S(R2I(1.5 * Bolsa_C + 0.5)) + ", jefe " + I2S(R2I(2.25 * Bolsa_C + 0.5)) + "; comunes previstas " + I2S(Bolsa_NC) + " de " + I2S(DevWave_Total) + " muertes")
''' if prueba else '') + '''endfunction

function Bolsa_Quitar takes integer i returns nothing
    call RemoveUnit(Bolsa_U[i])
    set Bolsa_N = Bolsa_N - 1
    set Bolsa_U[i] = Bolsa_U[Bolsa_N]
    set Bolsa_Oro[i] = Bolsa_Oro[Bolsa_N]
    set Bolsa_T[i] = Bolsa_T[Bolsa_N]
    set Bolsa_U[Bolsa_N] = null
endfunction

function Bolsa_Coger takes integer i, integer p returns nothing
    local unit u = Bolsa_U[i]
    local texttag t
    call Oro_Dar(p, Bolsa_Oro[i])
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Other\\\\Transmute\\\\PileofGold.mdl", GetUnitX(u), GetUnitY(u)))
    // Sólo en el cliente de quien la recoge: un texttag no es un handle sincronizado.
    if GetLocalPlayer() == Player(p) then
        set t = CreateTextTag()
        call SetTextTagText(t, "+" + I2S(Bolsa_Oro[i]), 0.024)
        call SetTextTagPos(t, GetUnitX(u), GetUnitY(u), 60.)
        call SetTextTagColor(t, 255, 204, 0, 255)
        call SetTextTagVelocity(t, 0., 0.04)
        call SetTextTagPermanent(t, false)
        call SetTextTagLifespan(t, 2.)
        call SetTextTagFadepoint(t, 1.4)
        set t = null
    endif
''' + ('''    set Bolsa_Cuenta[2] = Bolsa_Cuenta[2] + Bolsa_Oro[i]
    set Bolsa_Cuenta[5] = Bolsa_Cuenta[5] + 1
    call Bolsa_Anotar("recogida " + I2S(Bolsa_Oro[i]) + " por j" + I2S(p) + " a los " + R2SW(35. - Bolsa_T[i], 1, 1) + " s; en el suelo " + I2S(Bolsa_N - 1))
''' if prueba else '') + '''    set u = null
endfunction

function Bolsa_Tick takes nothing returns nothing
    local integer i = 0
    local integer p
    local integer a
    local unit h
    local real dx
    local real dy
    local boolean cogida
    loop
        exitwhen i >= Bolsa_N
        set Bolsa_T[i] = Bolsa_T[i] - 0.1
        set cogida = false
        set p = 0
        loop
            exitwhen p > 11 or cogida
            set h = Game_Hero[p]
            if Game_On[p] and h != null and UnitAlive(h) and not Shop_Open[p] then
                set dx = GetUnitX(h) - GetUnitX(Bolsa_U[i])
                set dy = GetUnitY(h) - GetUnitY(Bolsa_U[i])
                if dx * dx + dy * dy <= 25600. then
                    set cogida = true
                    call Bolsa_Coger(i, p)
                endif
            endif
            set p = p + 1
        endloop
        if cogida then
            call Bolsa_Quitar(i)
        elseif Bolsa_T[i] <= 0. then
''' + ('''            set Bolsa_Cuenta[3] = Bolsa_Cuenta[3] + Bolsa_Oro[i]
            set Bolsa_Cuenta[6] = Bolsa_Cuenta[6] + 1
            call Bolsa_Anotar("caducada " + I2S(Bolsa_Oro[i]) + "; en el suelo " + I2S(Bolsa_N - 1))
''' if prueba else '') + '''            call Bolsa_Quitar(i)
        else
            // Parpadeo los últimos 5 s.
            if Bolsa_T[i] < 5. then
                set a = 255
                if ModuloInteger(R2I(Bolsa_T[i] * 4.), 2) == 1 then
                    set a = 70
                endif
                call SetUnitVertexColor(Bolsa_U[i], 255, 255, 255, a)
            endif
            set i = i + 1
        endif
    endloop
    if Bolsa_N == 0 then
        call PauseTimer(Bolsa_Reloj)
    endif
    set h = null
endfunction

// Tipo 0 común, 1 élite, 2 jefe.
function Bolsa_Soltar takes real x, real y, integer tipo returns nothing
    local integer v = Bolsa_C
    if Bolsa_N >= 60 or Bolsa_C <= 0 then
        return
    endif
    if tipo == 1 then
        set v = R2I(1.5 * Bolsa_C + 0.5)
    elseif tipo == 2 then
        set v = R2I(2.25 * Bolsa_C + 0.5)
    endif
    set Bolsa_U[Bolsa_N] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nbg0' + tipo, x, y, GetRandomReal(0., 360.))
    set Bolsa_Oro[Bolsa_N] = v
    set Bolsa_T[Bolsa_N] = 35.
    set Bolsa_N = Bolsa_N + 1
    if Bolsa_Reloj == null then
        set Bolsa_Reloj = CreateTimer()
    endif
    if Bolsa_N == 1 then
        call TimerStart(Bolsa_Reloj, 0.1, true, function Bolsa_Tick)
    endif
''' + ('''    set Bolsa_Cuenta[1] = Bolsa_Cuenta[1] + v
    set Bolsa_Cuenta[4] = Bolsa_Cuenta[4] + 1
    call Bolsa_Anotar("bolsa tipo " + I2S(tipo) + " de " + I2S(v) + " en (" + I2S(R2I(x)) + ", " + I2S(R2I(y)) + "); en el suelo " + I2S(Bolsa_N))
''' if prueba else '') + '''endfunction

// Desde DevFuego_Muere, con muerte real: comunes en sus muertes previstas, élites y jefe.
function Bolsa_Muerte takes unit u, boolean comun returns nothing
    local integer id = GetUnitTypeId(u)
    local real a
    local integer k = 0
    if comun then
        if Bolsa_SigC <= Bolsa_NC and DevWave_Muertos * (Bolsa_NC + 1) >= Bolsa_SigC * DevWave_Total then
            set Bolsa_SigC = Bolsa_SigC + 1
            call Bolsa_Soltar(GetUnitX(u), GetUnitY(u), 0)
        endif
    elseif id >= 'ne00' and id <= 'ne09' then
        call Bolsa_Soltar(GetUnitX(u), GetUnitY(u), 1)
    elseif (id >= 'nj02' and id <= 'nj09') or id == 'nj0A' then
        set a = GetRandomReal(0., 360.)
        loop
            exitwhen k > 2
            call Bolsa_Soltar(GetUnitX(u) + 140. * Cos((a + 120. * k) * bj_DEGTORAD), GetUnitY(u) + 140. * Sin((a + 120. * k) * bj_DEGTORAD), 2)
            set k = k + 1
        endloop
    endif
endfunction

function DevFuego_Muere takes nothing returns nothing'''
una('\nfunction DevFuego_Muere takes nothing returns nothing', bolsas)

# Gancho en DevFuego_Muere: muertes reales de comunes (tras sumar DevWave_Muertos) y de élites y jefes.
una('''        if g >= 700 and g < 800 then
            set DevWave_Muertos=DevWave_Muertos + 1
            loop
                exitwhen DevWave_EliteSig > DevWave_EliteE or DevWave_Muertos * ( DevWave_EliteE + 1 ) < DevWave_EliteSig * DevWave_Total
                call DevWave_Elite(DevWave_EliteSig - 1)
                set DevWave_EliteSig=DevWave_EliteSig + 1
            endloop
        endif
    endif
''', '''        if g >= 700 and g < 800 then
            set DevWave_Muertos=DevWave_Muertos + 1
            loop
                exitwhen DevWave_EliteSig > DevWave_EliteE or DevWave_Muertos * ( DevWave_EliteE + 1 ) < DevWave_EliteSig * DevWave_Total
                call DevWave_Elite(DevWave_EliteSig - 1)
                set DevWave_EliteSig=DevWave_EliteSig + 1
            endloop
            // v18h: bolsa común en su muerte prevista (sólo si murió de verdad).
            if not WaveEventIsRetired and GetWaveEventUnit() != null then
                call Bolsa_Muerte(GetWaveEventUnit(), true)
            endif
        endif
    endif
    // v18h: bolsas de élites y del jefe.
    if not WaveEventIsRetired and GetWaveEventUnit() != null then
        call Bolsa_Muerte(GetWaveEventUnit(), false)
    endif
''')

una('''    call DevWave_Start(Ronda_Numero)
    call Ronda_TemaEmpezar()
''', '''    call DevWave_Start(Ronda_Numero)
    call Bolsa_Ronda()
    call Ronda_TemaEmpezar()
''')

if prueba:
    una('''            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 10.)) * (2 + Ronda_Numero) / 3)
''', '''            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 10.)) * (2 + Ronda_Numero) / 3)
            set Bolsa_Cuenta[0] = Bolsa_Cuenta[0] + IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 10.)) * (2 + Ronda_Numero) / 3
''')
    una('''        call Ronda_TemaParar()
        set Ronda_Resta = Ronda_DESCANSO
''', '''        call Ronda_TemaParar()
        call Bolsa_Anotar("fin r" + I2S(Ronda_Numero) + ": oro de muerte " + I2S(Bolsa_Cuenta[0]) + ", premio " + I2S(40 * Ronda_Numero + 10 * Ronda_Numero * Ronda_Numero) + " por jugador; bolsas " + I2S(Bolsa_Cuenta[4]) + " con " + I2S(Bolsa_Cuenta[1]) + " (comunes salidas " + I2S(Bolsa_SigC - 1) + "/" + I2S(Bolsa_NC) + "), recogidas " + I2S(Bolsa_Cuenta[5]) + " con " + I2S(Bolsa_Cuenta[2]) + ", caducadas " + I2S(Bolsa_Cuenta[6]) + " con " + I2S(Bolsa_Cuenta[3]) + "; en el suelo " + I2S(Bolsa_N) + "; oro j0 " + I2S(GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)))
        set Ronda_Resta = Ronda_DESCANSO
''')
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18g-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18h-{n}.txt")')
    assert 'lat\\\\v18g-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18h: bolsas de oro' + (' + registro' if prueba else ''))
