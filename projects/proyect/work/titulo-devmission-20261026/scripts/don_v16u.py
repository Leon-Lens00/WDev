#!/usr/bin/env python3
"""v16u (13/11/2026): Freezer, Future Trunks y Naruto de D.O.N 1.8c sobre v16t-gokum, con Goku, en celdas propias.

Leon (13/11/2026): "traemos a freezer, thunks del futuro y naruto", con el método de Goku; celdas propias (Goku 2,
Freezer 3, Trunks 4, Naruto 5) con su icono; la celda 0 vuelve a ser el Tauren; sin retrato ni voz; uno de cada por
partida (Hero_Lock da error si otro jugador ya fijó esa celda; si nadie la fijó, el primero que entra se lo queda y el
resto recibe al Tauren).
- Código de D.O.N: don_heroe.py (trasplante) y don_misil.py (movimiento con Missile y GroundCollision).
- Compartido (Don_*): motor de Missile (struct 72) que ejecuta los triggers de movimiento al ritmo de D.O.N; Don_Pon
  coloca piezas sin atravesar precipicios ni árboles; atributos <P>_Stat por nivel (-gk N, compartido con Goku).
- Cuerpo: unidad del héroe con sus habilidades reales (permanentes: Naruto cambia de forma) y pasivas; controlador con
  seis botones puente (don_heroes.py). El relevo corta ráfaga y dash y ordena la habilidad real al cuerpo.
- Disparar o hacer dash corta las canalizaciones (voodoo y rainoffire) de cualquiera de los cinco.
Uso: don_v16u.py v16t-gokum/war3map.j DON_DIR OBJ_DIR SALIDA.j  (DON_DIR con <P>-glob.j y <P>-func.j ya con misiles)
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from don_heroes import HEROES, SOLO_FORMA
from objetos_v12k import parse_w3a

j = Path(sys.argv[1]).read_bytes()
don, obj = Path(sys.argv[2]), Path(sys.argv[3])
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')
NUEVOS = [h for h in HEROES if h['nuevo']]
_, atab = parse_w3a((obj / 'war3map.w3a').read_bytes())
ALEV = {r[1].decode(): struct.unpack('<i', m[4])[0] for r in atab[1] for m in r[2] if m[0] == b'alev'}


def una(antes, despues):
    global j
    antes, despues = crlf(antes.encode('latin-1')), crlf(despues.encode('latin-1'))
    assert j.count(antes) == 1, (antes[:90], j.count(antes))
    j = j.replace(antes, despues)


def todas(antes, despues, n):
    global j
    antes, despues = crlf(antes.encode('latin-1')), crlf(despues.encode('latin-1'))
    assert j.count(antes) == n, (antes[:90], j.count(antes))
    j = j.replace(antes, despues)


GLOB = """// v16u: héroes de D.O.N 1.8c en celdas propias (don_heroe.py, don_misil.py, don_v16u.py).
integer Don_MOT = 72
hashtable Don_Mot = null
trigger array Don_MotT
real array Don_MotP
real array Don_MotAcum
integer array Don_Dueno
integer array Don_BotId
integer array Don_BotObj
integer array Don_BotReal
string array Don_BotOrden
integer Don_Bots = 0
"""
for h in NUEVOS:
    GLOB += (don / f"{h['P']}-glob.j").read_text(encoding='latin-1')

COMUN = r"""// ---- v16u: héroes de Battle Stadium D.O.N 1.8c (Freezer, Future Trunks, Naruto) ----
// Coloca la pieza u en L sin atravesar precipicios ni árboles (GroundCollision, como las balas); por el aire, sin choque.
function Don_Pon takes unit u, location L returns nothing
    if u != null and GetUnitFlyHeight(u) < 150. then
        if s__GroundCollision_trace(GetUnitX(u), GetUnitY(u), GetLocationX(L), GetLocationY(L), 24., u, GetOwningPlayer(u), false) != 0 then
            call MoveLocation(L, s__GroundCollision_x, s__GroundCollision_y)
        endif
    endif
    call SetUnitPositionLoc(u, L)
endfunction

function Don_PonF takes unit u, location L, real f returns nothing
    call Don_Pon(u, L)
    call SetUnitFacing(u, f)
endfunction

function Don_PonFL takes unit u, location L, location m returns nothing
    call Don_Pon(u, L)
    call SetUnitFacing(u, AngleBetweenPoints(L, m))
endfunction

// Motor: misil sin velocidad ni colisión (struct Don_MOT) que ejecuta el trigger de D.O.N a su ritmo con el reloj de
// Missile mientras siga encendido; uno por trigger.
function Don_MotTerminar takes integer m returns nothing
    if s__Missile_allocated[m] then
        if Don_MotT[m] != null then
            call RemoveSavedInteger(Don_Mot, GetHandleId(Don_MotT[m]), 0)
        endif
        set Don_MotT[m] = null
        set Don_MotAcum[m] = 0.
        call s__Missile_terminate(m)
        call Missile__StopPeriodic(Don_MOT)
    endif
endfunction

function Don_MotIterar takes nothing returns boolean
    local integer this = s__Missile_Missile__MissileStructure____first[Missile__missileList[Don_MOT]]
    local integer sig
    local trigger t
    loop
        exitwhen this == 0
        set sig = s__Missile_Missile__MissileStructure____next[this]
        set t = Don_MotT[this]
        if s__Missile_wantDestroy[this] or t == null or not IsTriggerEnabled(t) then
            call Don_MotTerminar(this)
        elseif s__Missile_allocated[this] then
            set Don_MotAcum[this] = Don_MotAcum[this] + Missile_TIMER_TIMEOUT
            loop
                exitwhen Don_MotAcum[this] < Don_MotP[this] - .0001 or not IsTriggerEnabled(t)
                set Don_MotAcum[this] = Don_MotAcum[this] - Don_MotP[this]
                if TriggerEvaluate(t) then
                    call TriggerExecute(t)
                endif
            endloop
        endif
        set this = sig
    endloop
    set t = null
    return false
endfunction

function Don_Motor takes trigger t, real periodo returns nothing
    local integer m = LoadInteger(Don_Mot, GetHandleId(t), 0)
    if m != 0 and Don_MotT[m] == t and s__Missile_allocated[m] then
        return
    endif
    set m = s__Missile_createXYZ(0., 0., 0., 1., 0., 0.)
    set s__Missile_collision[m] = 0.
    set s__Missile_speed[m] = 0.
    set Don_MotT[m] = t
    set Don_MotP[m] = periodo
    set Don_MotAcum[m] = 0.
    call SaveInteger(Don_Mot, GetHandleId(t), 0, m)
    call s__Missile_insertFront(Missile__missileList[Don_MOT], m)
    call Missile__StartPeriodic(Don_MOT)
endfunction

function Don_MotInit takes nothing returns nothing
    set Don_Mot = InitHashtable()
    set Missile__missileList[Don_MOT] = s__Missile_allocateCollection()
    set Missile__expression[Don_MOT] = Condition(function Don_MotIterar)
endfunction

"""
for h in NUEVOS:
    (s, si), (a, ai), (i, ii) = h['stats']
    COMUN += f"""// {h['nombre']}: atributos de D.O.N al nivel Gk_Nivel (fuerza, agilidad, inteligencia).
function {h['P']}_Stat takes integer k returns integer
    if k == 0 then
        return R2I({s}. + {si} * I2R(Gk_Nivel - 1))
    elseif k == 1 then
        return R2I({a}. + {ai} * I2R(Gk_Nivel - 1))
    endif
    return R2I({i}. + {ii} * I2R(Gk_Nivel - 1))
endfunction

"""
FUNC = ''.join((don / f"{h['P']}-func.j").read_text(encoding='latin-1') for h in NUEVOS)

DESPUES = """
// Celdas 3-5: un héroe de cada por partida, para el primer jugador que entra con esa celda.
// Quien fijó la celda en el título tiene prioridad sobre quien sólo la tenía marcada al acabar el tiempo.
function Don_Ajeno takes integer p, integer k returns boolean
    local integer i = 0
    loop
        exitwhen i > 7
        if i != p and Hero_Locked[i] and Hero_Choice[i] == k and not Hero_Locked[p] then
            return true
        endif
        set i = i + 1
    endloop
    return false
endfunction

function Don_Toca takes integer p, integer k returns boolean
    if Hero_Choice[p] != k then
        return false
    endif
    if Don_Dueno[k] < 0 and not Don_Ajeno(p, k) then
        set Don_Dueno[k] = p
    endif
    return Don_Dueno[k] == p
endfunction

function Don_Id takes integer p, integer id returns integer
"""
for h in NUEVOS:
    DESPUES += f"""    if Don_Toca(p, {h['celda']}) then
        return '{h['unidad']}'
    endif
"""
DESPUES += """    return id
endfunction

function Don_EsHeroe takes unit u returns boolean
    local integer t = GetUnitTypeId(u)
    return t == 'hGok' or t == 'hFrz' or t == 'hTrk' or t == 'hNar' or t == 'hNaK'
endfunction

function Don_Nombre takes integer p returns string
    local integer t = GetUnitTypeId(Game_Hero[p])
    if t == 'hGok' then
        return "Goku"
    elseif t == 'hFrz' then
        return "Freezer"
    elseif t == 'hTrk' then
        return "Trunks"
    elseif t == 'hNar' or t == 'hNaK' then
        return "Naruto"
    endif
    return "Tauren"
endfunction

// Botones del controlador (antes de Silence_HideMove, como Arp1 y Ard1).
function Don_Botones takes integer p, integer id returns nothing
"""
arm = ''
for h in NUEVOS:
    P = h['P']
    DESPUES += f"    if id == '{h['unidad']}' then\n" + ''.join(
        f"        call UnitAddAbility(Game_Ctrl[p], 'A{P}{k + 1}')\n" for k in range(len(h['botones']))) + "    endif\n"
    arm += f"    if id == '{h['unidad']}' then\n"
    for b in h['botones']:
        if b[0] in SOLO_FORMA:
            continue
        arm += f"        call UnitAddAbility(b, '{b[0]}')\n"
        if ALEV[b[0]] > 1:
            arm += f"        call SetUnitAbilityLevel(b, '{b[0]}', {ALEV[b[0]]})\n"
        arm += f"        call UnitMakeAbilityPermanent(b, true, '{b[0]}')\n"
    for x in h['pasivas']:
        arm += f"        call UnitAddAbility(b, '{x}')\n        call UnitMakeAbilityPermanent(b, true, '{x}')\n"
    arm += ''.join(f'        {r}\n' for r in h['registro']) + '    endif\n'
DESPUES += """endfunction

// Habilidades reales y pasivas en el cuerpo, al nivel de D.O.N (también al reaparecer). Permanentes: el modo Kyuubi
// de Naruto cambia el tipo del cuerpo. La reaparición (Arei) también se conserva.
function Don_Armar takes integer p, integer id returns nothing
    local unit b = Game_Hero[p]
    call UnitMakeAbilityPermanent(b, true, 'Arei')
""" + arm + """    set b = null
endfunction

// Botón del controlador -> habilidad real del cuerpo. Antes se cierran la ráfaga y el dash del movimiento artificial.
function Don_Relevo takes nothing returns nothing
    local integer this = s__RapidPair_fromController(GetTriggerUnit())
    local integer a = GetSpellAbilityId()
    local unit t = GetSpellTargetUnit()
    local real x = GetSpellTargetX()
    local real y = GetSpellTargetY()
    local integer n = 0
    local unit b
    loop
        exitwhen n >= Don_Bots or Don_BotId[n] == a
        set n = n + 1
    endloop
    if n < Don_Bots and this != 0 and not s__RapidPair_down[this] then
        set b = s__RapidPair_actor[this]
        if Don_BotReal[n] == 'A0HW' and GetUnitTypeId(b) != 'hNaK' then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 3., "Kyuubi Chakra Blast: sólo en modo Kyuubi.")
        elseif UnitAlive(b) and not IsUnitPaused(b) then
            call s__RapidPair_endDash(this, false)
            call s__RapidPair_finish(this, false)
            set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
            if Don_BotObj[n] == 0 then
                call IssueImmediateOrder(b, Don_BotOrden[n])
            elseif Don_BotObj[n] == 1 then
                call IssueTargetOrder(b, Don_BotOrden[n], t)
            else
                call IssuePointOrder(b, Don_BotOrden[n], x, y)
            endif
        endif
        set b = null
    endif
    set t = null
endfunction

function Don_Init takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 5
        set Don_Dueno[i] = -1
        set i = i + 1
    endloop
    call Don_MotInit()
"""
for h in NUEVOS:
    DESPUES += f"    call ExecuteFunc(\"{h['P']}_InitDON\")\n"  # un hilo por héroe: límite de operaciones
    for k, b in enumerate(h['botones']):
        DESPUES += (f"    set Don_BotId[Don_Bots] = 'A{h['P']}{k + 1}'\n    set Don_BotReal[Don_Bots] = '{b[0]}'\n"
                    f"    set Don_BotObj[Don_Bots] = {b[2]}\n    set Don_BotOrden[Don_Bots] = \"{b[1]}\"\n"
                    f"    call RegisterSpellEffectEvent('A{h['P']}{k + 1}', function Don_Relevo)\n"
                    "    set Don_Bots = Don_Bots + 1\n")
DESPUES += """endfunction
// ---- fin de v16u ----

"""

assert j.count(b'\r\nendglobals\r\n') == 1
j = j.replace(b'\r\nendglobals\r\n', b'\r\n' + crlf(GLOB.encode('latin-1')) + b'endglobals\r\n')
una('\nfunction Game_Cuerpo takes integer p,real x,real y returns nothing\n',
    '\n' + COMUN + FUNC + DESPUES + 'function Game_Cuerpo takes integer p,real x,real y returns nothing\n')
# celdas: Goku pasa de la celda 0 (vuelve el Tauren) a la 2
una("""// Celda 0 (Tauren) -> Goku, para un solo jugador humano: el código de D.O.N usa huecos fijos.
function Gk_Toca takes integer p returns boolean
    if Hero_Choice[p] != 0 then
""", """// v16u: celda 2 -> Goku (la celda 0 vuelve a ser el Tauren); un solo jugador humano: D.O.N usa huecos fijos.
function Gk_Toca takes integer p returns boolean
    local integer i = 0
    if Hero_Choice[p] != 2 then
        return false
    endif
    // v16u: quien fijó la celda tiene prioridad sobre quien sólo la tenía marcada
    loop
        exitwhen i > 7 or Hero_Locked[p]
        if i != p and Hero_Locked[i] and Hero_Choice[i] == 2 then
            return false
        endif
        set i = i + 1
    endloop
    if Hero_Choice[p] != 2 then
""")
una("""    set Hero_Icon[0] = 'DT3Q'
    set Hero_Icon[1] = 'DT2R'
""", """    set Hero_Icon[0] = 'DT3Q'
    set Hero_Icon[1] = 'DT2R'
    // v16u: héroes de D.O.N 1.8c (iconos de su ficha)
""" + ''.join(f"    set Hero_Icon[{h['celda']}] = '{h['icono_titulo']}'\n" for h in HEROES))
una("""    if Gk_Toca(p) then
        set id='hGok'
    endif
""", """    if Gk_Toca(p) then
        set id='hGok'
    endif
    set id=Don_Id(p, id)
""")
una("""    if id == 'hGok' then
        call Gk_Botones(p)
    endif
""", """    if id == 'hGok' then
        call Gk_Botones(p)
    endif
    call Don_Botones(p, id)
""")
una("""    if id == 'hGok' then
        call Gk_Armar(p)
    endif
""", """    if id == 'hGok' then
        call Gk_Armar(p)
    endif
    call Don_Armar(p, id)
""")
una("""    if GetUnitTypeId(Game_Hero[p]) == 'hGok' then
        set icon='hbi3'
    endif
""", """    if GetUnitTypeId(Game_Hero[p]) == 'hGok' then
        set icon='hbi3'
    endif
""" + ''.join(f"""    if GetUnitTypeId(Game_Hero[p]) == '{h['unidad']}' then
        set icon='{h['vida']}'
    endif
""" for h in NUEVOS))
una("""        call s__UnitHitShape_register('hGok' , 1.6 , 48.) // v16t-goku: como h005
""", """        call s__UnitHitShape_register('hGok' , 1.6 , 48.) // v16t-goku: como h005
""" + ''.join(f"        call s__UnitHitShape_register('{u}' , 1.6 , 48.) // v16u: como h005\n"
              for u in ['hFrz', 'hTrk', 'hNar', 'hNaK']))
todas("""        // v16t-goku: disparar o hacer dash corta la carga del SSJ o de la Spirit Bomb.
        if s__RapidPair_actor[this] == Gk_Cuerpo and (GetUnitCurrentOrder(Gk_Cuerpo) == Gk_OrdenSSJ or GetUnitCurrentOrder(Gk_Cuerpo) == Gk_OrdenBomba) then
            call IssueImmediateOrderById(Gk_Cuerpo, 851972)
        endif
""", """        // v16u: disparar o hacer dash corta las canalizaciones (voodoo, rainoffire) de los héroes de D.O.N.
        if (s__RapidPair_actor[this] == Gk_Cuerpo or GetUnitTypeId(s__RapidPair_actor[this]) == 'hFrz' or GetUnitTypeId(s__RapidPair_actor[this]) == 'hTrk' or GetUnitTypeId(s__RapidPair_actor[this]) == 'hNar' or GetUnitTypeId(s__RapidPair_actor[this]) == 'hNaK') and (GetUnitCurrentOrder(s__RapidPair_actor[this]) == Gk_OrdenSSJ or GetUnitCurrentOrder(s__RapidPair_actor[this]) == Gk_OrdenBomba) then
            call IssueImmediateOrderById(s__RapidPair_actor[this], 851972)
        endif
""", 2)
una("""    if k < 0 or Hero_Icon[k] == 0 then
        call UI_Error(p)
        return
    endif
    set Hero_Locked[p] = true
""", """    if k < 0 or Hero_Icon[k] == 0 then
        call UI_Error(p)
        return
    endif
    // v16u: los héroes de D.O.N (celdas 2-5) son uno de cada por partida.
    if k >= 2 and k <= 5 then
        loop
            exitwhen i > 7
            if i != p and Hero_Locked[i] and Hero_Choice[i] == k then
                call UI_Error(p)
                return
            endif
            set i = i + 1
        endloop
        set i = 0
    endif
    set Hero_Locked[p] = true
""")
una("""    else
        call Shop_Hablar(p, "Tauren", Shop_Frase[GetRandomInt(0, 5)])
""", """    else
        call Shop_Hablar(p, Don_Nombre(p), Shop_Frase[GetRandomInt(0, 5)])
""")
una("""    call ExecuteFunc("Gk_Init")
""", """    call ExecuteFunc("Gk_Init")
    call ExecuteFunc("Don_Init")
""")
Path(sys.argv[4]).write_bytes(j)
print('v16u: Freezer, Trunks y Naruto; celdas 2-5; motor Missile; relevo; un héroe de cada')
