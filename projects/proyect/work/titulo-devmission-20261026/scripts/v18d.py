#!/usr/bin/env python3
"""v18d (15/11/2026): sobre v18c. Leon: las mejoras de la súper élite son para todas las élites.

- Cada tirada sortea un juego de mejoras (vida y daño ×m, 2 estadísticas, 2 pasivas) que se aplica a todas las
  élites vivas ('ne00'..'ne09') cuando la tirada termina (2,55 s, lo que tardan las tarjetas en salir, entrar y
  fijarse) y a cada élite que salga mientras dure (DevFuego_Aparece). Todas reciben lo mismo.
- Al acabar su tiempo (20-30 s) se retiran de todas las élites y las tarjetas salen; empieza la tirada siguiente y,
  al fijarse, se ponen las nuevas.
- Pausa: si no hay élites vivas ni pueden salir más (eventos de élites agotados y ninguna en cola), no se tira; la
  primera élite que aparezca reanuda el ciclo.
- Ya no se cambia una común por élite (v18c): las mejoras no van a una unidad. Se quita Sup_Convertir.
- Lo que cada élite recibió (vida, daño, mejora puesta) se guarda en Sup_HT para quitarlo igual; al morir sólo se
  borra su marca.
Prueba: registros en lat\\v18d-*.txt: tirada, aplicadas a N, nueva élite, retiradas de N, pausa y reanudación.
Uso: v18d.py v18c/war3map.j SALIDA.j [prueba]
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


def tramo(desde, hasta, nuevo):
    """Sustituye desde `desde` (incluido) hasta `hasta` (excluido), ambos únicos."""
    global j
    a, b = crlf(u8(desde)), crlf(u8(hasta))
    assert j.count(a) == 1 and j.count(b) == 1, (desde[:60], hasta[:60])
    i, k = j.index(a), j.index(b)
    assert i < k
    j = j[:i] + crlf(u8(nuevo)) + j[k:]


def log(s, sangria='    '):
    return f'{sangria}call Sup_Anotar({s})\n' if prueba else ''


una('unit Sup_CU = null\n', '''hashtable Sup_HT = InitHashtable()
integer Sup_Act = -1
boolean Sup_Pausa = false
''')

tramo('function Sup_Muere takes nothing returns nothing', '// v17v: añade y quita', '''// v18d: al morir una élite con mejoras sólo se borra su marca (las mejoras se van con ella).
function Sup_Muere takes nothing returns nothing
    local integer h = GetHandleId(GetTriggerUnit())
    if HaveSavedInteger(Sup_HT, h, 3) then
        call DestroyEffect(LoadEffectHandle(Sup_HT, h, 0))
        call FlushChildHashtable(Sup_HT, h)
    endif
endfunction

''')

ronda = '''function Sup_Ronda takes nothing returns nothing
    local integer p = 0
    call Sup_Init()
    if Sup_Reloj == null then
        set Sup_Reloj = CreateTimer()
    endif
    set Sup_Pausa = false
    call TimerStart(Sup_Reloj, 6., false, function Sup_Tick)
    loop
        exitwhen p > 11
        if StringLength(Cua_Resumen[p]) > 0 then
            call DisplayTimedTextToPlayer(Player(p), 0, 0, 8, "Elegido para esta oleada (aún sin efecto): " + Cua_Resumen[p])
            set Cua_Resumen[p] = ""
        endif
        set p = p + 1
    endloop
endfunction
'''

nuevo = '''// v18d: da a la élite u las mejoras vigentes (Sup_Act) y guarda en Sup_HT lo que recibió: 0 marca, 1 vida máxima
// sumada, 2 daño sumado, 3 juego de mejoras. Conserva la proporción de vida. Código común.
function Sup_Dar takes unit u returns nothing
    local integer i = Sup_Act
    local integer h = GetHandleId(u)
    local integer k = 0
    local integer t
    local integer v
    local integer dano
    local real hp
    local real vida
    if i < 0 or HaveSavedInteger(Sup_HT, h, 3) or not UnitAlive(u) then
        return
    endif
    set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    set vida = GetWidgetLife(u)
    set v = R2I(hp * (Sup_M[i] - 1.) + 0.5)
    call BM_VidaMax(u, v)
    call SetWidgetLife(u, vida * GetUnitState(u, UNIT_STATE_MAX_LIFE) / hp)
    call SaveInteger(Sup_HT, h, 1, v)
    set dano = R2I(Sup_Base(GetUnitTypeId(u)) * (Sup_M[i] - 1.) + 0.5)
    loop
        exitwhen k > 1
        set t = Sup_St[i * 2 + k]
        set v = Sup_Val[i * 2 + k]
        if t == 0 then
            set dano = dano + v
        elseif t == 2 or t == 4 then
            call UnitAddAbility(u, Sup_StHab[t] + v / 5 - 1)
        elseif t == 6 then
            call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) + v)
        else
            call BM_Add(u, Sup_StHab[t], v)
        endif
        set k = k + 1
    endloop
    call BM_Add(u, 1, dano)
    call SaveInteger(Sup_HT, h, 2, dano)
    call UnitAddAbility(u, Sup_PaId[Sup_Pa[i * 2]])
    call UnitAddAbility(u, Sup_PaId[Sup_Pa[i * 2 + 1]])
    call UnitAddAbility(u, 'SpM0')
    call SaveEffectHandle(Sup_HT, h, 0, AddSpecialEffectTarget("Abilities\\\\Spells\\\\Undead\\\\UnholyFrenzy\\\\UnholyFrenzyTarget.mdl", u, "overhead"))
    call SaveInteger(Sup_HT, h, 3, i)
endfunction

// v18d: quita a u exactamente lo que le dio Sup_Dar (conserva la proporción de vida).
function Sup_Quitar takes unit u returns nothing
    local integer h = GetHandleId(u)
    local integer i
    local integer k = 0
    local integer t
    local integer v
    local real hp
    local real vida
    if not HaveSavedInteger(Sup_HT, h, 3) then
        return
    endif
    set i = LoadInteger(Sup_HT, h, 3)
    set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    set vida = GetWidgetLife(u)
    call BM_VidaMax(u, - LoadInteger(Sup_HT, h, 1))
    call SetWidgetLife(u, RMaxBJ(1., vida * GetUnitState(u, UNIT_STATE_MAX_LIFE) / hp))
    loop
        exitwhen k > 1
        set t = Sup_St[i * 2 + k]
        set v = Sup_Val[i * 2 + k]
        if t == 2 or t == 4 then
            call UnitRemoveAbility(u, Sup_StHab[t] + v / 5 - 1)
        elseif t == 6 then
            call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) - v)
        elseif t != 0 then
            call BM_Add(u, Sup_StHab[t], - v)
        endif
        set k = k + 1
    endloop
    call BM_Add(u, 1, - LoadInteger(Sup_HT, h, 2))
    call UnitRemoveAbility(u, Sup_PaId[Sup_Pa[i * 2]])
    call UnitRemoveAbility(u, Sup_PaId[Sup_Pa[i * 2 + 1]])
    call UnitRemoveAbility(u, 'SpM0')
    call DestroyEffect(LoadEffectHandle(Sup_HT, h, 0))
    call FlushChildHashtable(Sup_HT, h)
endfunction

// v18d: recorre las élites vivas de las oleadas: modo 0 sólo cuenta, 1 da las mejoras, 2 las quita. Devuelve cuántas.
function Sup_Todas takes integer modo returns integer
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local integer n = 0
    local integer id
    local unit u
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Sup_G, Player(o), null)
        loop
            set u = FirstOfGroup(Sup_G)
            exitwhen u == null
            call GroupRemoveUnit(Sup_G, u)
            set id = GetUnitTypeId(u)
            if id >= 'ne00' and id <= 'ne09' and UnitAlive(u) then
                set n = n + 1
                if modo == 1 then
                    call Sup_Dar(u)
                elseif modo == 2 then
                    call Sup_Quitar(u)
                endif
            endif
        endloop
        set o = o + 1
    endloop
    return n
endfunction

// v18d: ¿hay élites vivas o pueden salir más en esta oleada (eventos pendientes o élites en cola)?
function Sup_Posible takes nothing returns boolean
    return Sup_Todas(0) > 0 or DevWave_EliteSig <= DevWave_EliteE or DevWave_ColaI < DevWave_ColaF
endfunction

// v18d: sortea un juego de mejoras (sin unidad) y los 12 cambios de la tirada. Código común.
function Sup_Crear takes nothing returns nothing
    local integer r = IMaxBJ(1, Ronda_Numero)
    local integer i = Sup_N
    local integer k = 0
    local integer t
    local integer v
    local integer b
    set Sup_N = ModuloInteger(Sup_N + 1, Sup_MAX)
    set Sup_M[i] = RMinBJ(2.25, 1.25 + 0.05 * (r - 1))
    // 2 mejoras de estadística distintas.
    set Sup_St[i * 2] = GetRandomInt(0, 6)
    set t = GetRandomInt(0, 5)
    if t >= Sup_St[i * 2] then
        set t = t + 1
    endif
    set Sup_St[i * 2 + 1] = t
    loop
        exitwhen k > 1
        set t = Sup_St[i * 2 + k]
        set v = IMaxBJ(1, Sup_Valor(t, r))
        if t == 0 then
            set v = IMinBJ(200, v)
        elseif t == 2 or t == 4 then
            // Evasión y robo de vida: una habilidad de un nivel por tramo de 5 % (5-50), redondeado.
            set v = 5 * IMinBJ(10, IMaxBJ(1, (v + 2) / 5))
        elseif t != 6 then
            set v = IMinBJ(127, v)
        endif
        set Sup_Val[i * 2 + k] = v
        set k = k + 1
    endloop
    // 2 pasivas distintas; los dos orbes (5 y 6) no van juntos.
    set Sup_Pa[i * 2] = GetRandomInt(0, 6)
    loop
        set t = GetRandomInt(0, 6)
        exitwhen t != Sup_Pa[i * 2] and not (t >= 5 and Sup_Pa[i * 2] >= 5)
    endloop
    set Sup_Pa[i * 2 + 1] = t
    // Los 12 cambios de la tirada, iguales para todos los jugadores (Sup_Barajar).
    set b = 0
    loop
        exitwhen b > 11
        set t = GetRandomInt(0, 6)
        set Sup_RT[i * 48 + b * 4] = t
        set k = GetRandomInt(0, 5)
        if k >= t then
            set k = k + 1
        endif
        set Sup_RT[i * 48 + b * 4 + 1] = k
        set k = 0
        loop
            exitwhen k > 1
            set t = Sup_RT[i * 48 + b * 4 + k]
            if t == 2 or t == 4 then
                set Sup_RV[i * 48 + b * 4 + k] = 5 * GetRandomInt(1, 10)
            else
                set Sup_RV[i * 48 + b * 4 + k] = GetRandomInt(1, 60)
            endif
            set k = k + 1
        endloop
        set t = GetRandomInt(0, 6)
        set Sup_RT[i * 48 + b * 4 + 2] = t
        set k = GetRandomInt(0, 5)
        if k >= t then
            set k = k + 1
        endif
        set Sup_RT[i * 48 + b * 4 + 3] = k
        set b = b + 1
    endloop
    set Sup_Vista = i
    call Sup_Pintar()
''' + log('"r" + I2S(r) + " tirada " + I2S(i) + " x" + R2SW(Sup_M[i], 1, 2) + " | " + I2S(Sup_Val[i * 2]) + Sup_StNom[Sup_St[i * 2]] + " | " + I2S(Sup_Val[i * 2 + 1]) + Sup_StNom[Sup_St[i * 2 + 1]] + " | " + Sup_PaNom[Sup_Pa[i * 2]] + " | " + Sup_PaNom[Sup_Pa[i * 2 + 1]]') + '''endfunction

// v18d: final del tiempo de unas mejoras; llama a Sup_Tick por nombre porque va después.
function Sup_Fin takes nothing returns nothing
    call ExecuteFunc("Sup_Tick")
endfunction

// v18d: la tirada se ha fijado: las mejoras pasan a todas las élites vivas y a las que salgan; duran 20-30 s.
function Sup_Aplicar takes nothing returns nothing
    local integer n
    if not Ronda_Activa or Ronda_Descanso then
        return
    endif
    set Sup_Act = Sup_Vista
    set n = Sup_Todas(1)
''' + log('"aplicadas " + I2S(Sup_Act) + " a " + I2S(n) + " elites"') + '''    call TimerStart(Sup_Reloj, GetRandomReal(20., 30.), false, function Sup_Fin)
endfunction

// v18d: fin del tiempo de las mejoras (o primera vez en la oleada): se retiran de todas, las tarjetas salen y, si
// puede haber élites, empieza otra tirada; si no, pausa hasta que aparezca una élite (DevFuego_Aparece).
function Sup_Tick takes nothing returns nothing
    local integer n
    if not Ronda_Activa or Ronda_Descanso then
        return
    endif
    if Sup_Act >= 0 then
        set Sup_Act = -1
        set n = Sup_Todas(2)
''' + log('"retiradas de " + I2S(n) + " elites"', '        ') + '''        set Sup_Vista = -1
        call Sup_Pintar()
    endif
    if not Sup_Posible() then
        set Sup_Pausa = true
''' + log('"pausa: sin elites vivas ni por salir"', '        ') + '''        return
    endif
    call Sup_Crear()
    call TimerStart(Sup_Reloj, 2.55, false, function Sup_Aplicar)
endfunction

// Al lanzar cada oleada (Ronda_Lanzar): primera tirada a los 6 s; resumen de lo elegido en los cuadros.
''' + ronda + '''
// Al acabar la oleada: sin temporizador, sin mejoras y sin tarjetas.
function Sup_Parar takes nothing returns nothing
    if Sup_Reloj != null then
        call PauseTimer(Sup_Reloj)
    endif
    set Sup_Act = -1
    set Sup_Pausa = false
    call Sup_Todas(2)
''' + log('"fin de oleada r" + I2S(Ronda_Numero)') + '''    if Sup_Vista >= 0 then
        set Sup_Vista = -1
        call Sup_Pintar()
    endif
endfunction

'''
tramo('function Sup_Vale takes unit u returns boolean', "// Fondos ('DSC0' desde v18c", nuevo)
# Ya no se cambia una común por élite.
tramo('// v18c: cambia la común Sup_CU', 'function DevWave_IA takes nothing returns nothing', '')

# Cada élite que aparece recibe las mejoras vigentes; si estaba en pausa, reanuda.
una('''        call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE))
    endif
    call SaveEffectHandle(DevFuego_HT''', '''        call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE))
        // v18d: mejoras de élite vigentes para la que sale; si estaban en pausa, vuelve la tirada.
        if Sup_Act >= 0 then
            call Sup_Dar(u)
''' + log('"nueva elite " + UnitId2String(id) + " recibe " + I2S(Sup_Act)', '            ') + '''        elseif Sup_Pausa and Ronda_Activa and not Ronda_Descanso then
            set Sup_Pausa = false
''' + log('"reanuda: sale " + UnitId2String(id)', '            ') + '''            call TimerStart(Sup_Reloj, 0.5, false, function Sup_Tick)
        endif
    endif
    call SaveEffectHandle(DevFuego_HT''')

una('call Sup_Texto(Sup_TT[p * 5], "Súper élite: vida y daño ×"', 'call Sup_Texto(Sup_TT[p * 5], "Élites: vida y daño ×"')

if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18c-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18d-{n}.txt")')
    assert 'lat\\\\v18c-' not in j
for s in ('Sup_Convertir', 'Sup_CU', 'Sup_Vale', 'Sup_U[', 'Sup_Fx['):
    assert s not in j, s
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18d: mejoras para todas las élites, retiro y pausa' + (' + registro' if prueba else ''))
