#!/usr/bin/env python3
"""v14f: barras de vida sobre las unidades, adaptadas de WaveSys (HealthBarTextTags.j), y textos de la tienda
creados sólo mientras está abierta.

Texttags medidos en v14e, un jugador, tienda abierta: 47 en uso y 53 libres de 100. Al llenarse, CreateTextTag
devuelve otra vez el id 0 y pisa uno en uso, sin error. Los texttags no son agentes ni se sincronizan: crearlos en
un solo cliente no desincroniza (UIText.createEx ya lo hace).

- Tienda: sus 35 texttags se crean en el cliente de quien la abre y se destruyen al cerrarla.
- Barras: 24 texttags fijos para enemigos, reasignados al dañado, 1,5 s desde el último golpe; uno por héroe. Las
  101 barras se precalculan; el texto cambia sólo si cambia el porcentaje o el estado. Cada cliente oculta las de
  unidades que no ve y todas mientras tiene la tienda abierta. Héroe caído: sólo el nombre, junto al cuerpo.
- Barras nativas: EnablePreSelect(true, false), como WaveSys.

Uso: v14f.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')


class base:  # war3map.j lleva UTF-8 leído como latin-1: los textos con tildes se pasan igual.
    @staticmethod
    def once(s, a, b):
        return __import__('puente_v12').once(s, a.encode().decode('latin-1'), b.encode().decode('latin-1'))


# Tienda: textos al abrir, fuera al cerrar.
textos = '''    call Shop_Tag(137, 92, 0.026, 0, "Categorías")
    call Shop_Tag(1140, 96, 0.02, 0, "Precio")
    call Shop_Tag(950, 522, 0.017, 0, "Daño")
    call Shop_Tag(1140, 522, 0.017, 0, "Cargador")
    call Shop_Tag(950, 606, 0.017, 0, "Cadencia")
    call Shop_Tag(1140, 606, 0.017, 0, "Precisión")
    call Shop_Tag(1424, 610, 0.024, 0, "Oro")
    call Shop_Tag(250, 758, 0.024, 0, "Salir (Esc)")
    set i = 0
    loop
        exitwhen i > 19
        set Shop_T[i] = Shop_Tag(960, 400, 0.02, 0, "")
        set i = i + 1
    endloop
'''
s = base.once(s, textos, '')
s = base.once(s, '        set Shop_CatT[i] = Shop_Tag(187, 146 + 66 * i, 0.022, 0, Cat_Nombre[i])\n', '')
s = base.once(s, '// La zona está sobre terreno jugable: nada de la tienda se ve salvo en el cliente de quien la tiene abierta.\n',
              '''// Sólo en el cliente de quien abre la tienda: 35 texttags que quedan libres para el juego al cerrarla.
function Shop_Textos takes nothing returns nothing
    local integer i = 0
    if Shop_TzN > 0 then
        return
    endif
    loop
        exitwhen i > 6
        set Shop_CatT[i] = Shop_Tag(187, 146 + 66 * i, 0.022, 0, Cat_Nombre[i])
        set i = i + 1
    endloop
''' + textos + '''endfunction

function Shop_TextosFuera takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= Shop_TzN
        call DestroyTextTag(Shop_Tz[i])
        set Shop_Tz[i] = null
        set i = i + 1
    endloop
    set Shop_TzN = 0
    set i = 0
    loop
        exitwhen i > 19
        set Shop_T[i] = null
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 6
        set Shop_CatT[i] = null
        set i = i + 1
    endloop
endfunction

// La zona está sobre terreno jugable: nada de la tienda se ve salvo en el cliente de quien la tiene abierta.
''')
s = base.once(s, '''    call Shop_Camara(p)
    call Shop_Mostrar(p, true)
''', '''    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
''')
s = base.once(s, '''    set Shop_Open[p] = false
    set Shop_Abiertos = Shop_Abiertos - 1
    call Shop_Mostrar(p, false)
''', '''    set Shop_Open[p] = false
    set Shop_Abiertos = Shop_Abiertos - 1
    call Shop_Mostrar(p, false)
    if GetLocalPlayer() == Player(p) then
        call Shop_TextosFuera()
    endif
''')

# Barras de vida
s = base.once(s, 'real Title_CX=', '''hashtable Barras_HT= InitHashtable()
string array Barras_Txt
timer Barras_Reloj= null
timer Barras_RelojEnemigos= null
boolean Barras_EnemigosCorre= false
texttag array Barras_Heroe
integer array Barras_HeroeEstado
texttag array Barras_Tag
unit array Barras_Unidad
real array Barras_Fin
integer array Barras_Pct
real Barras_Ahora= 0.
real Title_CX=''')

LIB = '''// v14f: barras de vida sobre las unidades, de WaveSys (HealthBarTextTags.j). Enemigos: Barras_ENEMIGOS texttags fijos,
// cada uno para el último dañado, hasta Barras_DURA s desde su último golpe; si se llenan, el que vence antes. Héroes:
// nombre y barra; caído, sólo el nombre junto al cuerpo. Visibilidad por cliente: sólo lo que ve y nunca en la tienda.
constant function Barras_ENEMIGOS takes nothing returns integer
    return 24
endfunction

constant function Barras_DURA takes nothing returns real
    return 1.5
endfunction

function Barras_Porcentaje takes unit u returns integer
    local real m = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    local integer n
    if m <= 0.405 then
        return 0
    endif
    set n = R2I(GetWidgetLife(u) / m * 100. + 0.5)
    if n < 0 then
        return 0
    elseif n > 100 then
        return 100
    endif
    return n
endfunction

function Barras_Visible takes unit u returns boolean
    local player l = GetLocalPlayer()
    return not Shop_Open[GetPlayerId(l)] and not IsUnitHidden(u) and IsUnitVisible(u, l)
endfunction

function Barras_Nuevo takes nothing returns texttag
    local texttag t = CreateTextTag()
    call SetTextTagPermanent(t, true)
    call SetTextTagVisibility(t, false)
    call SetTextTagVelocity(t, 0., 0.)
    set bj_lastCreatedTextTag = t
    set t = null
    return bj_lastCreatedTextTag
endfunction

function Barras_Nombre takes integer p returns string
    return PlayerUtils___OriginalHex[GetHandleId(GetPlayerColor(Player(p)))] + GetPlayerName(Player(p)) + "|r"
endfunction

function Barras_Libre takes integer i returns nothing
    if Barras_Unidad[i] != null then
        call RemoveSavedInteger(Barras_HT, GetHandleId(Barras_Unidad[i]), 0)
    endif
    set Barras_Unidad[i] = null
    set Barras_Pct[i] = -1
    call SetTextTagVisibility(Barras_Tag[i], false)
endfunction

// Estado del héroe: -1 sin barra; 0..100 vivo con ese porcentaje; 101 caído.
function Barras_Heroes takes nothing returns nothing
    local integer p = 0
    local integer e
    local unit u
    loop
        exitwhen p > 11
        set u = Game_Hero[p]
        if Game_On[p] and GetUnitTypeId(u) != 0 then
            if Barras_Heroe[p] == null then
                set Barras_Heroe[p] = Barras_Nuevo()
                set Barras_HeroeEstado[p] = -1
            endif
            if GetWidgetLife(u) > 0.405 then
                set e = Barras_Porcentaje(u)
            else
                set e = 101
            endif
            if e != Barras_HeroeEstado[p] then
                set Barras_HeroeEstado[p] = e
                if e > 100 then
                    call SetTextTagText(Barras_Heroe[p], Barras_Nombre(p), 0.018)
                else
                    call SetTextTagText(Barras_Heroe[p], Barras_Nombre(p) + "\\n" + Barras_Txt[e], 0.018)
                endif
            endif
            call SetTextTagPos(Barras_Heroe[p], GetUnitX(u) - 42., GetUnitY(u), 145. + GetUnitFlyHeight(u))
            call SetTextTagVisibility(Barras_Heroe[p], Barras_Visible(u))
        elseif Barras_Heroe[p] != null and Barras_HeroeEstado[p] != -1 then
            set Barras_HeroeEstado[p] = -1
            call SetTextTagVisibility(Barras_Heroe[p], false)
        endif
        set p = p + 1
    endloop
    set u = null
endfunction

function Barras_Enemigos takes nothing returns nothing
    local integer i = 0
    local integer n
    local integer activos = 0
    local unit u
    set Barras_Ahora = Barras_Ahora + 0.05
    loop
        exitwhen i >= Barras_ENEMIGOS()
        set u = Barras_Unidad[i]
        if u != null then
            if Barras_Fin[i] <= Barras_Ahora or GetUnitTypeId(u) == 0 or GetWidgetLife(u) <= 0.405 then
                call Barras_Libre(i)
            else
                set activos = activos + 1
                set n = Barras_Porcentaje(u)
                if n != Barras_Pct[i] then
                    set Barras_Pct[i] = n
                    call SetTextTagText(Barras_Tag[i], Barras_Txt[n], 0.017)
                endif
                call SetTextTagPos(Barras_Tag[i], GetUnitX(u) - 28., GetUnitY(u), 120. + GetUnitFlyHeight(u))
                call SetTextTagVisibility(Barras_Tag[i], Barras_Visible(u))
            endif
        endif
        set i = i + 1
    endloop
    if activos == 0 then
        call PauseTimer(Barras_RelojEnemigos)
        set Barras_EnemigosCorre = false
    endif
    set u = null
endfunction

// Llamada desde cada UnitDamageTarget del jugador sobre un enemigo.
function Barras_Golpe takes unit fuente, unit u returns nothing
    local integer h
    local integer i
    local integer k
    if fuente == null or GetUnitTypeId(u) == 0 or GetWidgetLife(u) <= 0.405 then
        return
    endif
    if not IsPlayerEnemy(GetOwningPlayer(u), GetOwningPlayer(fuente)) then
        return
    endif
    set h = GetHandleId(u)
    if HaveSavedInteger(Barras_HT, h, 0) then
        set i = LoadInteger(Barras_HT, h, 0)
    else
        set i = 0
        set k = 0
        loop
            exitwhen k >= Barras_ENEMIGOS()
            if Barras_Unidad[k] == null then
                set i = k
                exitwhen true
            endif
            if Barras_Fin[k] < Barras_Fin[i] then
                set i = k
            endif
            set k = k + 1
        endloop
        call Barras_Libre(i)
        set Barras_Unidad[i] = u
        call SaveInteger(Barras_HT, h, 0, i)
    endif
    set Barras_Fin[i] = Barras_Ahora + Barras_DURA()
    if not Barras_EnemigosCorre then
        set Barras_EnemigosCorre = true
        call TimerStart(Barras_RelojEnemigos, 0.05, true, function Barras_Enemigos)
    endif
endfunction

function Barras_Init takes nothing returns nothing
    local integer n = 0
    local integer i
    local integer llenos
    local string c
    local string r
    call EnablePreSelect(true, false)
    loop
        exitwhen n > 100
        set llenos = R2I(n * 10 / 100. + 0.5)
        if llenos >= 7 then
            set c = "|cff50ff50"
        elseif llenos >= 4 then
            set c = "|cffffdc00"
        else
            set c = "|cffff5050"
        endif
        set r = c
        set i = 0
        loop
            exitwhen i >= 10
            if i == llenos then
                set r = r + "|r|cff808080"
            endif
            set r = r + "||"
            set i = i + 1
        endloop
        set Barras_Txt[n] = r + "|r |cffffffff" + I2S(n) + "%|r"
        set n = n + 1
    endloop
    set i = 0
    loop
        exitwhen i >= Barras_ENEMIGOS()
        set Barras_Tag[i] = Barras_Nuevo()
        set Barras_Pct[i] = -1
        set i = i + 1
    endloop
    set Barras_RelojEnemigos = CreateTimer()
    set Barras_Reloj = CreateTimer()
    call TimerStart(Barras_Reloj, 0.03, true, function Barras_Heroes)
endfunction

'''
s = base.once(s, '    function Arm_Impacto takes integer m,unit caster,unit target returns nothing\n', LIB + '    function Arm_Impacto takes integer m,unit caster,unit target returns nothing\n')
s = base.once(s, '''        call UnitDamageTarget(caster, target, d, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
''', '''        call UnitDamageTarget(caster, target, d, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
        call Barras_Golpe(caster, target)
''')
s = base.once(s, '''                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
''', '''                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    call Barras_Golpe(caster, u)
''')
s = base.once(s, '''                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
''', '''                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    call Barras_Golpe(a, u)
''')
s = base.once(s, '    call InitBlizzard()\n', '    call InitBlizzard()\n    call Barras_Init()\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
