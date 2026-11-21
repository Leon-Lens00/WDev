#!/usr/bin/env python3
"""v14m: habilidades del Prawn ('nlpr', élite 'ne01', jefe 'nj02') en tres niveles (05/11/2026).

Pedido de Leon: normales con una versión menor de lo de la élite y el jefe, y otro conjunto de refuerzos para sí mismos
y los aliados de alrededor. Primera familia: el Prawn (ronda 2).

| Nivel  | Embestida (aviso, distancia, daño a ronda 2)        | Caparazón (defensa con 'AId3'/'AId5', velocidad 'AIsx')   |
| Normal | 1 de cada 3; a ≤ 450, aviso 0,4 s, 300, 8; 15-25 s   | Endurecer: bajo 50 % de vida, +3 defensa 5 s, una vez     |
| Élite  | contra su jugador a ≤ 650, aviso 1 s, 600, 18; 10-14 s | cada 14 s cerca de un jugador: +3 a sí y aliados en 400, 6 s |
| Jefe   | 3 seguidas, una por jugador, aviso 1 s, 800, 30; 12 s | cada 18 s: +5 defensa y +15 % ataque en 700, 8 s          |

El daño crece un 10 % por ronda desde la 2 (Hab_Escala). La embestida pausa la unidad, marca el camino con polvo y la
desliza con SetUnitX/Y cada 0,03 s; para en lo que no es caminable (IsTerrainWalkable: precipicios, árboles, piezas) y
golpea una vez a cada personaje a ≤ 110. Los refuerzos no se acumulan (el nuevo sustituye al anterior, salvo uno más
débil sobre el del jefe). Todo corre en código común a todos los clientes (RNG sincronizado), sin GetLocalPlayer.
El jefe aplaza la llamada de refuerzos si está embistiendo.

Uso: v14m.py ENTRADA.j SALIDA.j [registro]   (registro: Hab_Log escribe con Preload en lat\\v14m-hab-N.txt, sólo pruebas)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base


def once(s, old, new):
    # El script está en UTF-8 y se lee como latin-1: los acentos de lo insertado también.
    return base.once(s, old.encode('utf-8').decode('latin-1'), new.encode('utf-8').decode('latin-1'))


registro = sys.argv[3:] == ['registro']
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'hashtable DevFuego_HT= InitHashtable()\n', '''hashtable DevFuego_HT= InitHashtable()
// v14m: habilidades por unidad (Hab_*, claves en Hab_Alta) y su tiempo propio en pasos de 0,25 s.
hashtable Hab_HT= InitHashtable()
group Hab_Pr= CreateGroup()
group Hab_Mov= CreateGroup()
group Hab_Ref= CreateGroup()
group Hab_Fin= CreateGroup()
group Hab_G= CreateGroup()
real Hab_T= 0.
integer Hab_N= - 1
integer Hab_Reg= 0
''')

if registro:
    log = r'''// Sólo prueba (v14m.py registro): una línea por archivo, hasta 600.
function Hab_Log takes string s returns nothing
    if Hab_Reg >= 600 then
        return
    endif
    set Hab_Reg = Hab_Reg + 1
    call PreloadGenClear()
    call Preload("t " + R2S(Hab_T) + " " + s)
    call PreloadGenEnd("lat\\v14m-hab-" + I2S(Hab_Reg) + ".txt")
endfunction
'''
else:
    log = ''

codigo = log + r'''// Prueba de defensa al reforzar (sólo la prueba v14m-habil le da cuerpo).
function Hab_Medir takes unit u returns nothing
endfunction

// 0 normal, 1 élite, 2 jefe; - 1 si la unidad no tiene estas habilidades.
function Hab_Nivel takes integer id returns integer
    if id == 'nlpr' then
        return 0
    elseif id == 'ne01' then
        return 1
    elseif id == 'nj02' then
        return 2
    endif
    return - 1
endfunction

function Hab_Escala takes nothing returns real
    return 1. + 0.10 * IMaxBJ(0, Ronda_Numero - 2)
endfunction

function Hab_Ocupado takes unit u returns boolean
    return LoadInteger(Hab_HT, GetHandleId(u), 1) != 0
endfunction

function Hab_Bit takes integer m, integer p returns boolean
    return ModuloInteger(m / R2I(Pow(2., p) + 0.5), 2) == 1
endfunction

// Unidad de oleada viva (dueños 8..13), sin estructuras ni piezas con Locust.
function Hab_Aliado takes unit u returns boolean
    local integer o = GetPlayerId(GetOwningPlayer(u))
    return o >= WAVE_DEFAULT_OWNER_MIN and o <= WAVE_DEFAULT_OWNER_MAX and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and GetUnitAbilityLevel(u, 'Aloc') == 0
endfunction

// Personaje vivo más cercano a u entre minimo y r, prefiriendo los jugadores fuera de la máscara m; su jugador queda
// en Hab_N (- 1 si no hay ninguno).
function Hab_Blanco takes unit u, real r, real minimo, integer m returns unit
    local integer p
    local integer vuelta = 0
    local real dx
    local real dy
    local real d
    local real mejor
    local unit b = null
    set Hab_N = - 1
    loop
        exitwhen vuelta > 1 or b != null
        set mejor = r * r
        set p = 0
        loop
            exitwhen p > 11
            if DevWave_Vale(p) and Game_Hero[p] != null and UnitAlive(Game_Hero[p]) and (vuelta == 1 or not Hab_Bit(m, p)) then
                set dx = GetUnitX(Game_Hero[p]) - GetUnitX(u)
                set dy = GetUnitY(Game_Hero[p]) - GetUnitY(u)
                set d = dx * dx + dy * dy
                if d <= mejor and d >= minimo * minimo then
                    set mejor = d
                    set b = Game_Hero[p]
                    set Hab_N = p
                endif
            endif
            set p = p + 1
        endloop
        set vuelta = vuelta + 1
    endloop
    return b
endfunction

function Hab_Quitar takes unit u returns nothing
    local integer h = GetHandleId(u)
    if LoadInteger(Hab_HT, h, 11) != 0 then
        call UnitRemoveAbility(u, LoadInteger(Hab_HT, h, 11))
    endif
    if LoadInteger(Hab_HT, h, 12) != 0 then
        call UnitRemoveAbility(u, LoadInteger(Hab_HT, h, 12))
    endif
    if HaveSavedHandle(Hab_HT, h, 13) then
        call DestroyEffect(LoadEffectHandle(Hab_HT, h, 13))
        call RemoveSavedHandle(Hab_HT, h, 13)
    endif
    call SaveReal(Hab_HT, h, 10, 0.)
    call SaveInteger(Hab_HT, h, 11, 0)
    call SaveInteger(Hab_HT, h, 12, 0)
    call GroupRemoveUnit(Hab_Ref, u)
endfunction

// Caparazón: defensa a (+ ataque b si no es 0) durante dur s. No se acumula; uno de +3 no pisa al del jefe (+5).
function Hab_Reforzar takes unit u, integer a, integer b, real dur returns boolean
    local integer h = GetHandleId(u)
    if LoadReal(Hab_HT, h, 10) > Hab_T then
        if a == 'AId3' and LoadInteger(Hab_HT, h, 11) == 'AId5' then
            return false
        endif
        call Hab_Quitar(u)
    endif
    call UnitAddAbility(u, a)
    if b != 0 then
        call UnitAddAbility(u, b)
    endif
    call SaveInteger(Hab_HT, h, 11, a)
    call SaveInteger(Hab_HT, h, 12, b)
    call SaveReal(Hab_HT, h, 10, Hab_T + dur)
    call SaveEffectHandle(Hab_HT, h, 13, AddSpecialEffectTarget("Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl", u, "overhead"))
    call GroupAddUnit(Hab_Ref, u)
    call Hab_Medir(u)
    return true
endfunction

// Pulso de caparazón de élite y jefe: refuerza a u y a las unidades de oleada a ≤ r.
function Hab_Pulso takes unit u, integer n, real r, integer a, integer b, real dur returns nothing
    local unit v
    local integer c = 0
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl", GetUnitX(u), GetUnitY(u)))
    call GroupEnumUnitsInRange(Hab_G, GetUnitX(u), GetUnitY(u), r, null)
    loop
        set v = FirstOfGroup(Hab_G)
        exitwhen v == null
        call GroupRemoveUnit(Hab_G, v)
        if Hab_Aliado(v) and Hab_Reforzar(v, a, b, dur) then
            set c = c + 1
        endif
    endloop
    call Hab_Log("pulso " + I2S(n) + " unidades " + I2S(c))
endfunction

// Aviso de la embestida hacia b: dirección fija desde ahora (se puede esquivar), polvo a lo largo del camino.
function Hab_Avisar takes unit u, unit b returns nothing
    local integer h = GetHandleId(u)
    local integer n = LoadInteger(Hab_HT, h, 0)
    local real a = Atan2(GetUnitY(b) - GetUnitY(u), GetUnitX(b) - GetUnitX(u))
    local real largo = 300.
    local real aviso = 0.4
    local real dur = 0.3
    local real dano = 8.
    local real l = 150.
    if n == 1 then
        set largo = 600.
        set aviso = 1.
        set dur = 0.5
        set dano = 18.
    elseif n == 2 then
        set largo = 800.
        set aviso = 1.
        set dur = 0.6
        set dano = 30.
    endif
    call SaveInteger(Hab_HT, h, 1, 1)
    call SaveInteger(Hab_HT, h, 2, R2I(aviso / 0.03 + 0.5))
    call SaveInteger(Hab_HT, h, 18, R2I(dur / 0.03 + 0.5))
    call SaveReal(Hab_HT, h, 3, Cos(a))
    call SaveReal(Hab_HT, h, 4, Sin(a))
    call SaveReal(Hab_HT, h, 5, dano * Hab_Escala())
    call SaveReal(Hab_HT, h, 8, largo / R2I(dur / 0.03 + 0.5))
    call SaveInteger(Hab_HT, h, 9, 0)
    call SaveInteger(Hab_HT, h, 19, 0)
    call SaveUnitHandle(Hab_HT, h, 20, b)
    call IssueImmediateOrder(u, "stop")
    call SetUnitFacing(u, a * bj_RADTODEG)
    call SetUnitAnimation(u, "attack")
    call QueueUnitAnimation(u, "stand")
    call PauseUnit(u, true)
    if n > 0 then
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", u, "origin"))
    endif
    loop
        exitwhen l > largo
        call DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl", GetUnitX(u) + l * Cos(a), GetUnitY(u) + l * Sin(a)))
        set l = l + 150.
    endloop
    call GroupAddUnit(Hab_Mov, u)
    call Hab_Log("aviso " + I2S(n) + " p " + I2S(Hab_N))
endfunction

function Hab_Terminar takes unit u returns nothing
    local integer h = GetHandleId(u)
    local integer n = LoadInteger(Hab_HT, h, 0)
    local unit b = LoadUnitHandle(Hab_HT, h, 20)
    call SaveInteger(Hab_HT, h, 1, 0)
    call PauseUnit(u, false)
    call SetUnitAnimation(u, "stand")
    if n == 0 then
        call SaveReal(Hab_HT, h, 7, Hab_T + GetRandomReal(15., 25.))
    elseif n == 1 then
        call SaveReal(Hab_HT, h, 7, Hab_T + GetRandomReal(10., 14.))
    else
        call SaveInteger(Hab_HT, h, 6, LoadInteger(Hab_HT, h, 6) - 1)
        if LoadInteger(Hab_HT, h, 6) > 0 then
            call SaveReal(Hab_HT, h, 7, Hab_T + 0.25)
        else
            call SaveReal(Hab_HT, h, 7, Hab_T + 12.)
        endif
    endif
    if b != null and UnitAlive(b) then
        call IssueTargetOrder(u, "attack", b)
    endif
    call GroupAddUnit(Hab_Fin, u)
    call Hab_Log("fin " + I2S(n) + " golpes " + I2S(LoadInteger(Hab_HT, h, 19)))
    set b = null
endfunction

// Cada 0,03 s: cuenta atrás del aviso y deslizamiento de la embestida.
function Hab_Mover takes nothing returns nothing
    local unit u = GetEnumUnit()
    local integer h = GetHandleId(u)
    local integer t = LoadInteger(Hab_HT, h, 2) - 1
    local integer m
    local integer p
    local real x
    local real y
    local real v
    local real d
    if not UnitAlive(u) then
        call GroupAddUnit(Hab_Fin, u)
        set u = null
        return
    endif
    call SaveInteger(Hab_HT, h, 2, t)
    if LoadInteger(Hab_HT, h, 1) == 1 then
        if t <= 0 then
            call SaveInteger(Hab_HT, h, 1, 2)
            call SaveInteger(Hab_HT, h, 2, LoadInteger(Hab_HT, h, 18))
            call SetUnitAnimation(u, "walk")
        endif
        set u = null
        return
    endif
    set x = GetUnitX(u) + LoadReal(Hab_HT, h, 8) * LoadReal(Hab_HT, h, 3)
    set y = GetUnitY(u) + LoadReal(Hab_HT, h, 8) * LoadReal(Hab_HT, h, 4)
    if t < 0 or not IsTerrainWalkable(x, y) then
        call Hab_Terminar(u)
        set u = null
        return
    endif
    call SetUnitX(u, x)
    call SetUnitY(u, y)
    if ModuloInteger(t, 4) == 0 then
        call DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl", x, y))
    endif
    set m = LoadInteger(Hab_HT, h, 9)
    set p = 0
    loop
        exitwhen p > 11
        if Game_Hero[p] != null and UnitAlive(Game_Hero[p]) and not Hab_Bit(m, p) and IsUnitInRangeXY(Game_Hero[p], x, y, 110.) then
            set m = m + R2I(Pow(2., p) + 0.5)
            set d = LoadReal(Hab_HT, h, 5)
            set v = GetWidgetLife(Game_Hero[p])
            call UnitDamageTarget(u, Game_Hero[p], d, false, false, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, null)
            call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl", Game_Hero[p], "chest"))
            call SaveInteger(Hab_HT, h, 19, LoadInteger(Hab_HT, h, 19) + 1)
            call Hab_Log("golpe " + I2S(LoadInteger(Hab_HT, h, 0)) + " p " + I2S(p) + " dano " + I2S(R2I((v - GetWidgetLife(Game_Hero[p])) * 100. + 0.5)) + " esperado " + I2S(R2I(d * 100. + 0.5)))
        endif
        set p = p + 1
    endloop
    call SaveInteger(Hab_HT, h, 9, m)
    set u = null
endfunction

function Hab_Paso takes nothing returns nothing
    local unit u
    call ForGroup(Hab_Mov, function Hab_Mover)
    loop
        set u = FirstOfGroup(Hab_Fin)
        exitwhen u == null
        call GroupRemoveUnit(Hab_Fin, u)
        call GroupRemoveUnit(Hab_Mov, u)
    endloop
endfunction

// Cada 0,25 s, por cada Prawn: caparazón y, si está libre, embestida.
function Hab_Pensar1 takes nothing returns nothing
    local unit u = GetEnumUnit()
    local integer h = GetHandleId(u)
    local integer n = LoadInteger(Hab_HT, h, 0)
    local unit b = null
    local integer p
    if not UnitAlive(u) then
        call GroupAddUnit(Hab_Fin, u)
        set u = null
        return
    endif
    if n == 0 then
        if not LoadBoolean(Hab_HT, h, 15) and GetWidgetLife(u) < 0.5 * GetUnitState(u, UNIT_STATE_MAX_LIFE) then
            call SaveBoolean(Hab_HT, h, 15, true)
            call Hab_Reforzar(u, 'AId3', 0, 5.)
            call Hab_Log("endurecer")
        endif
    elseif Hab_T >= LoadReal(Hab_HT, h, 17) and LoadInteger(Hab_HT, h, 1) == 0 and Hab_Blanco(u, 900., 0., 0) != null then
        if n == 1 then
            call Hab_Pulso(u, n, 400., 'AId3', 0, 6.)
            call SaveReal(Hab_HT, h, 17, Hab_T + 14.)
        else
            call Hab_Pulso(u, n, 700., 'AId5', 'AIsx', 8.)
            call SaveReal(Hab_HT, h, 17, Hab_T + 18.)
        endif
    endif
    if LoadInteger(Hab_HT, h, 1) == 0 and Hab_T >= LoadReal(Hab_HT, h, 7) and LoadBoolean(Hab_HT, h, 14) and not IsUnitPaused(u) then
        if n == 2 then
            if LoadInteger(Hab_HT, h, 6) <= 0 then
                set b = Hab_Blanco(u, 900., 150., 0)
                if b != null then
                    call SaveInteger(Hab_HT, h, 6, 3)
                    call SaveInteger(Hab_HT, h, 16, 0)
                endif
            else
                set b = Hab_Blanco(u, 1100., 0., LoadInteger(Hab_HT, h, 16))
                if b == null then
                    call SaveInteger(Hab_HT, h, 6, 0)
                    call SaveReal(Hab_HT, h, 7, Hab_T + 12.)
                endif
            endif
            if b != null then
                call SaveInteger(Hab_HT, h, 16, LoadInteger(Hab_HT, h, 16) + R2I(Pow(2., Hab_N) + 0.5))
            endif
        elseif n == 1 then
            set p = - 1
            if HaveSavedInteger(DevWave_HT, h, 1) then
                set p = LoadInteger(DevWave_HT, h, 1)
            endif
            if p >= 0 and DevWave_Vale(p) and UnitAlive(Game_Hero[p]) and IsUnitInRange(u, Game_Hero[p], 650.) and not IsUnitInRange(u, Game_Hero[p], 150.) then
                set b = Game_Hero[p]
                set Hab_N = p
            else
                set b = Hab_Blanco(u, 650., 150., 0)
            endif
        else
            set b = Hab_Blanco(u, 450., 150., 0)
        endif
        if b != null then
            call Hab_Avisar(u, b)
        endif
    endif
    set u = null
    set b = null
endfunction

// Fin de los refuerzos vencidos (también en unidades que no son Prawn).
function Hab_Vencer takes nothing returns nothing
    local unit u = GetEnumUnit()
    if not UnitAlive(u) or LoadReal(Hab_HT, GetHandleId(u), 10) <= Hab_T then
        call GroupAddUnit(Hab_G, u)
    endif
    set u = null
endfunction

function Hab_Pensar takes nothing returns nothing
    local unit u
    set Hab_T = Hab_T + 0.25
    call ForGroup(Hab_Pr, function Hab_Pensar1)
    loop
        set u = FirstOfGroup(Hab_Fin)
        exitwhen u == null
        call GroupRemoveUnit(Hab_Fin, u)
        call GroupRemoveUnit(Hab_Pr, u)
        call GroupRemoveUnit(Hab_Mov, u)
    endloop
    call GroupClear(Hab_G)
    call ForGroup(Hab_Ref, function Hab_Vencer)
    loop
        set u = FirstOfGroup(Hab_G)
        exitwhen u == null
        call GroupRemoveUnit(Hab_G, u)
        call Hab_Quitar(u)
    endloop
endfunction

// Alta de un Prawn. Claves: 0 nivel, 1 fase (0 libre, 1 aviso, 2 embestida), 2 pasos, 3-4 dirección, 5 daño,
// 6 embestidas que le quedan al jefe, 7 lista desde, 8 avance por paso, 9 personajes golpeados, 10 fin del refuerzo,
// 11-12 sus habilidades, 13 su efecto, 14 embiste, 15 ya se endureció, 16 jugadores ya embestidos, 17 pulso desde,
// 18 pasos de embestida, 19 golpes, 20 blanco.
function Hab_Alta takes unit u returns nothing
    local integer n = Hab_Nivel(GetUnitTypeId(u))
    local integer h = GetHandleId(u)
    if n < 0 then
        return
    endif
    call FlushChildHashtable(Hab_HT, h)
    call SaveInteger(Hab_HT, h, 0, n)
    call SaveBoolean(Hab_HT, h, 14, n > 0 or GetRandomInt(1, 3) == 1)
    call SaveReal(Hab_HT, h, 7, Hab_T + GetRandomReal(2., 5.))
    call SaveReal(Hab_HT, h, 17, Hab_T + GetRandomReal(3., 6.))
    call GroupAddUnit(Hab_Pr, u)
endfunction

function Hab_Aparece takes nothing returns nothing
    call Hab_Alta(GetWaveEventUnit())
endfunction

function Hab_Muere takes nothing returns nothing
    local unit u = GetWaveEventUnit()
    if LoadReal(Hab_HT, GetHandleId(u), 10) > 0. then
        call Hab_Quitar(u)
    endif
    call GroupRemoveUnit(Hab_Pr, u)
    call GroupRemoveUnit(Hab_Mov, u)
    call FlushChildHashtable(Hab_HT, GetHandleId(u))
    set u = null
endfunction

function Hab_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.25, true, function Hab_Pensar)
    call TimerStart(CreateTimer(), 0.03, true, function Hab_Paso)
endfunction

'''
if not registro:
    # En la entrega no hay registro: se quitan las llamadas (las cadenas con R2S/I2S quedarían en la tabla de cadenas).
    codigo = '\n'.join(l for l in codigo.split('\n') if 'call Hab_Log(' not in l)
    assert 'Hab_Log' not in codigo
s = once(s, 'function DevJefe_Limpiar takes nothing returns nothing\n', codigo + 'function DevJefe_Limpiar takes nothing returns nothing\n')
# El jefe no llama refuerzos a mitad de una embestida: lo intenta de nuevo en 1 s.
s = once(s, '''    if not DevJefe_Vivo() or Ronda_Wave == 0 or not s__Wave_isOperational(Ronda_Wave) then
        return
    endif
    set id=GetUnitTypeId(DevJefe)''', '''    if not DevJefe_Vivo() or Ronda_Wave == 0 or not s__Wave_isOperational(Ronda_Wave) then
        return
    endif
    if Hab_Ocupado(DevJefe) then
        call TimerStart(DevJefe_Reloj, 1., false, function DevJefe_Llamar)
        return
    endif
    set id=GetUnitTypeId(DevJefe)''')
s = once(s, '    call RegisterWaveDeathEvent(function DevFuego_Muere)\n', '''    call RegisterWaveDeathEvent(function DevFuego_Muere)
    call RegisterWaveSpawnEvent(function Hab_Aparece)
    call RegisterWaveDeathEvent(function Hab_Muere)
    call Hab_Iniciar()
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
