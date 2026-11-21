#!/usr/bin/env python3
"""v19d (19/11/2026), correcciones de Leon tras probar v19c:
- "las unidades dummy de casteo de todos deben ejecutar rapidamente la habilidad" y "el dummy que se encuentre
  rapidamente en el punto de lanzamiento": la copia aparece dentro del alcance de la técnica (tabla Dcp_Rango, sacada
  del aran de cada habilidad al nivel que usa el héroe). Si el héroe ya está a tiro, aparece a su lado; si no, a
  alcance − 50 (mínimo 60) del objetivo, en la línea héroe-objetivo. Ya no camina. Además, ucpt/ucbs 0
  (objetos_v19d.py). Burning Attack (1500) y Dragon Fist (2000) aceptaban la orden y se iban caminando: es la causa
  más probable de que no salieran (en v16y ya pasaba con el héroe).
- "el dummy de goku debe copiar su estado actual de ssj": la copia recibe las piezas que lleve el héroe (cabezas
  A069/A06A/A06B/A0JO, aura A00Y, A0G4; Trunks A07X/A03Z; Naruto A0AO; Kyuubi A0HX) al mismo nivel, y la animación
  "alternate" si Goku está en el nivel 5 de Power Up.
- "habilidades que tomen a una unidad ... que tome tambien un grupo de unidad cercanas": mientras vive la copia, cada
  daño que reciba su objetivo de la copia o de una pieza de D.O.N del jugador se repite a hasta 8 enemigos a 300 del
  objetivo (fuente la copia). Afecta a Warp Kamehameha, Death Break, Imprisonment Ball, Heat Dome, Burning Slash,
  Rasengan y Rasenrengan.
- Rasen Shuriken: las piezas que D.O.N creaba sin vida ('h01B' y 'h0DM' de la explosión; 'h064' y 'h05B' en modo
  Kyuubi) mueren solas a los 4 / 2,5 / 2 s.
- Tauren: la roca de Lanzar roca y las piedras del Bombardeo, ×3 de tamaño.
Prueba: además "don efecto jP orden" cuando la copia lanza de verdad y "eco N dano D" al quitarla.
Uso: v19d.py ENTRADA.j (de v19c) SALIDA.j [prueba]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
U = lambda s: s.encode('utf-8').decode('latin-1')
CRLF = '\r\n' in src


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


def tramo(desde, hasta, nuevo):
    """Sustituye src[desde:hasta) (hasta no incluido) por nuevo."""
    global src
    a = src.index(U(desde))
    b = src.index(U(hasta), a)
    assert src.count(U(desde)) == 1
    n = U(nuevo)
    if CRLF:
        n = n.replace('\r\n', '\n').replace('\n', '\r\n')
    src = src[:a] + n + src[b:]


cambia('integer Dcp_N = 0\n', 'integer Dcp_N = 0\n'
       'trigger array Dcp_Tr\nunit array Dcp_Ob\ninteger array Dcp_EN\nreal array Dcp_ED\n'
       'boolean Dcp_EcoOn = false\ngroup Dcp_Grupo = null\n')

RANGO = {'A00P': 2500, 'A0IA': 800, 'A0BZ': 2000, 'A01G': 99999, 'A0J1': 900, 'A0IX': 2500, 'A0IW': 1500,
         'A0IV': 900, 'A0GV': 2500, 'A086': 800, 'A05B': 1500, 'A03W': 125, 'A0AI': 900, 'A0F5': 400,
         'A0F3': 2500, 'A0HW': 1500}
rango = ''.join(f"    {'if' if k == 0 else 'elseif'} a == '{a}' then\n        return {r}.\n"
                for k, (a, r) in enumerate(RANGO.items()))
PIEZAS = ['A069', 'A06A', 'A06B', 'A0JO', 'A00Y', 'A0G4', 'A07X', 'A03Z', 'A0AO', 'A0HX']
piezas = ''.join(f"    call Dcp_Pieza(b, c, '{a}')\n" for a in PIEZAS)

DCP = r'''// v19d: alcance de cada técnica real al nivel que usa el héroe (aran del w3a); 0 = sin objetivo.
function Dcp_Rango takes integer a returns real
''' + rango + r'''    endif
    return 0.
endfunction

// v19d: la copia lleva las mismas piezas que el héroe (cabezas de Super Saiyan, auras, espada, ojos).
function Dcp_Pieza takes unit b, unit c, integer a returns nothing
    if GetUnitAbilityLevel(b, a) > 0 then
        call UnitAddAbility(c, a)
        call SetUnitAbilityLevel(c, a, GetUnitAbilityLevel(b, a))
    endif
endfunction

// v19d: el daño de la copia o de las piezas del jugador sobre el objetivo se repite a 8 enemigos a 300 de él.
function Dcp_Eco takes nothing returns nothing
    local unit s = GetEventDamageSource()
    local unit u = GetTriggerUnit()
    local real d = GetEventDamage()
    local integer i = 0
    local integer k = -1
    local integer p
    local integer n = 0
    local unit e
    loop
        exitwhen i >= Dcp_N or k >= 0
        if Dcp_Tr[i] == GetTriggeringTrigger() then
            set k = i
        endif
        set i = i + 1
    endloop
    if k < 0 or Dcp_EcoOn or d < 1. or s == null or u != Dcp_Ob[k] then
        set s = null
        set u = null
        return
    endif
    set p = Dcp_P[k]
    if s != Dcp_U[k] and (GetPlayerId(GetOwningPlayer(s)) != p or s == Game_Hero[p] or GetUnitTypeId(s) == 'dumi') then
        set s = null
        set u = null
        return
    endif
    set Dcp_EcoOn = true
    if Dcp_Grupo == null then
        set Dcp_Grupo = CreateGroup()
    endif
    call GroupEnumUnitsInRange(Dcp_Grupo, GetUnitX(u), GetUnitY(u), 300., null)
    loop
        set e = FirstOfGroup(Dcp_Grupo)
        exitwhen e == null
        call GroupRemoveUnit(Dcp_Grupo, e)
        if n < 8 and e != u and UnitAlive(e) and IsUnitEnemy(e, Player(p)) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and GetUnitAbilityLevel(e, 'Aloc') == 0 then
            call UnitDamageTarget(Dcp_U[k], e, d, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            call DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", e, "chest"))
            set Dcp_EN[k] = Dcp_EN[k] + 1
            set Dcp_ED[k] = Dcp_ED[k] + d
            set n = n + 1
        endif
    endloop
    call GroupClear(Dcp_Grupo)
    set Dcp_EcoOn = false
    set s = null
    set u = null
endfunction

function Dcp_Lanzar takes unit b, integer a, integer obj, string orden, unit t, real x, real y returns boolean
    local integer p = GetPlayerId(GetOwningPlayer(b))
    local integer tb = GetUnitTypeId(b)
    local integer tc = 'hCpG'
    local real ang = GetUnitFacing(b)
    local real hx = GetUnitX(b)
    local real hy = GetUnitY(b)
    local real px = x
    local real py = y
    local real cx = hx
    local real cy = hy
    local real r = Dcp_Rango(a)
    local real d
    local real k
    local unit c
    local boolean ok
    local integer i = Dcp_N
    if i >= 60 then
        return false
    endif
    if tb == 'hFrz' then
        set tc = 'hCpF'
    elseif tb == 'hTrk' then
        set tc = 'hCpT'
    elseif tb == 'hNar' then
        set tc = 'hCpN'
    elseif tb == 'hNaK' then
        set tc = 'hCpK'
    endif
    if obj == 1 and t != null then
        set px = GetUnitX(t)
        set py = GetUnitY(t)
    endif
    if obj != 0 then
        set ang = bj_RADTODEG * Atan2(py - hy, px - hx)
        set d = SquareRoot((px - hx) * (px - hx) + (py - hy) * (py - hy))
        if r > 0. and d > r - 25. then
            set k = RMaxBJ(60., r - 50.)
            set cx = px - k * Cos(ang * bj_DEGTORAD)
            set cy = py - k * Sin(ang * bj_DEGTORAD)
            if cx > GetRectMinX(bj_mapInitialPlayableArea) + 64. and cx < GetRectMaxX(bj_mapInitialPlayableArea) - 64. and cy > GetRectMinY(bj_mapInitialPlayableArea) + 64. and cy < GetRectMaxY(bj_mapInitialPlayableArea) - 64. then
                call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl", cx, cy))
            else
                set cx = hx
                set cy = hy
            endif
        endif
    endif
    set c = CreateUnit(GetOwningPlayer(b), tc, cx, cy, ang)
    call SetUnitVertexColor(c, 140, 210, 255, 150)
    call SetUnitPathing(c, false)
    call SetUnitX(c, cx)
    call SetUnitY(c, cy)
''' + piezas + r'''    if tb == 'hGok' and GkV_n8[$B18] == 5 then
        call AddUnitAnimationProperties(c, "alternate", true)
    endif
    call UnitAddAbility(c, a)
    call SetUnitAbilityLevel(c, a, IMaxBJ(1, GetUnitAbilityLevel(b, a)))
    call SetUnitState(c, UNIT_STATE_MANA, GetUnitState(c, UNIT_STATE_MAX_MANA))
    if obj == 0 then
        set ok = IssueImmediateOrder(c, orden)
    elseif obj == 1 then
        set ok = IssueTargetOrder(c, orden, t)
    else
        set ok = IssuePointOrder(c, orden, x, y)
    endif
    if not ok then
        call RemoveUnit(c)
        set c = null
        return false
    endif
    set Dcp_N = i + 1
    set Dcp_U[i] = c
    set Dcp_P[i] = p
    set Dcp_A[i] = a
    set Dcp_F[i] = 0
    set Dcp_K[i] = 0
    set Dcp_S[i] = 0
    set Dcp_O[i] = orden
    set Dcp_EN[i] = 0
    set Dcp_ED[i] = 0.
    set Dcp_Ob[i] = null
    set Dcp_Tr[i] = null
    if obj == 1 and t != null then
        set Dcp_Ob[i] = t
        set Dcp_Tr[i] = CreateTrigger()
        call TriggerRegisterUnitEvent(Dcp_Tr[i], t, EVENT_UNIT_DAMAGED)
        call TriggerAddAction(Dcp_Tr[i], function Dcp_Eco)
    endif
    set Cop_Log = "don copia j" + I2S(p) + " " + orden + " a " + I2S(R2I(SquareRoot((cx - hx) * (cx - hx) + (cy - hy) * (cy - hy))))
    call ExecuteFunc("Cop_Anotar")
    set c = null
    return true
endfunction

// v19d: registro de prueba cuando una copia lanza de verdad (evento de efecto).
function Dcp_Efecto takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local integer t = GetUnitTypeId(c)
    if t == 'hCpG' or t == 'hCpF' or t == 'hCpT' or t == 'hCpN' or t == 'hCpK' then
        set Cop_Log = "don efecto j" + I2S(GetPlayerId(GetOwningPlayer(c))) + " " + OrderId2String(GetUnitCurrentOrder(c))
        call ExecuteFunc("Cop_Anotar")
    endif
    set c = null
endfunction

function Dcp_EfectoInit takes nothing returns nothing
    local trigger g = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(g, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(g, function Dcp_Efecto)
    set g = null
endfunction

'''
tramo('function Dcp_Lanzar takes unit b', 'function Gk_Fuerza takes unit u returns integer', DCP)

TICK = r'''function Dcp_Tick takes nothing returns nothing
    local integer i = 0
    local integer j
    local integer al
    local unit c
    loop
        exitwhen i >= Dcp_N
        set c = Dcp_U[i]
        set Dcp_K[i] = Dcp_K[i] + 1
        if Dcp_F[i] == 0 then
            if Dcp_K[i] >= 300 or (Dcp_K[i] >= 20 and not IsUnitPaused(c) and GetUnitCurrentOrder(c) == 0 and not IsUnitHidden(c)) then
                set Dcp_F[i] = 1
                set Dcp_S[i] = Dcp_K[i]
            endif
        elseif Dcp_F[i] == 1 then
            set al = 150 - 15 * (Dcp_K[i] - Dcp_S[i])
            if al <= 0 then
                set al = 0
                set Dcp_F[i] = 2
            endif
            call SetUnitVertexColor(c, 140, 210, 255, al)
        endif
        if Dcp_F[i] == 2 and ((Dcp_K[i] >= 500 and not Don_EnCurso(Dcp_A[i])) or Dcp_K[i] >= 1200) then
            set Cop_Log = "don fin j" + I2S(Dcp_P[i]) + " " + Dcp_O[i] + " t" + I2S(Dcp_S[i]) + " eco " + I2S(Dcp_EN[i]) + " dano " + I2S(R2I(Dcp_ED[i]))
            call ExecuteFunc("Cop_Anotar")
            if Dcp_Tr[i] != null then
                call DestroyTrigger(Dcp_Tr[i])
            endif
            call RemoveUnit(c)
            set Dcp_N = Dcp_N - 1
            set j = Dcp_N
            set Dcp_U[i] = Dcp_U[j]
            set Dcp_P[i] = Dcp_P[j]
            set Dcp_A[i] = Dcp_A[j]
            set Dcp_F[i] = Dcp_F[j]
            set Dcp_K[i] = Dcp_K[j]
            set Dcp_S[i] = Dcp_S[j]
            set Dcp_O[i] = Dcp_O[j]
            set Dcp_Tr[i] = Dcp_Tr[j]
            set Dcp_Ob[i] = Dcp_Ob[j]
            set Dcp_EN[i] = Dcp_EN[j]
            set Dcp_ED[i] = Dcp_ED[j]
            set Dcp_U[j] = null
            set Dcp_Tr[j] = null
            set Dcp_Ob[j] = null
        else
            set i = i + 1
        endif
    endloop
    set c = null
endfunction

'''
tramo('function Dcp_Tick takes nothing returns nothing', '// v19b: motor de copias de Tauren y Cairne.', TICK)
cambia('''    call TimerStart(CreateTimer(), 0.05, true, function Dcp_Tick)
''', '''    call TimerStart(CreateTimer(), 0.05, true, function Dcp_Tick)
    set Dcp_Grupo = CreateGroup()
    call Dcp_EfectoInit()
''')

# --- Rasen Shuriken: piezas sin vida ---
for unidad, lugar, cuantas, vida in (("'h064'", "NaV_r8[5142],GetUnitFacing(NaV_s8[5140])", 3, '2.5'),
                                     ("'h05B'", "NaV_r8[5142],NaV_O8[5140]", 1, '2.'),
                                     ("'h01B'", "NaV_r8[5145],GetRandomReal(0,360)", 2, '4.'),
                                     ("'h0DM'", "NaV_r8[5145],GetRandomReal(0,360)", 2, '4.')):
    linea = f"call CreateNUnitsAtLoc(1,{unidad},GetOwningPlayer(NaV_s8[5140]),{lugar})\n"
    cambia(linea, linea + f"call UnitApplyTimedLifeBJ({vida},'BTLF',bj_lastCreatedUnit)\n", cuantas)

# --- Rocas del Tauren ×3 de tamaño ---
cambia('''        call Cop_Lanzar(i, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", 20, 350.)
''', '''        call Cop_Lanzar(i, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", 20, 350.)
        call SetUnitScale(Cop_U[i], 3., 3., 3.)
''')
cambia('''                call Cop_Proyectil(j, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", Cop_X[i], Cop_Y[i], a, 150.)
''', '''                call Cop_Proyectil(j, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", Cop_X[i], Cop_Y[i], a, 150.)
                call SetUnitScale(Cop_U[j], 3., 3., 3.)
''')

if prueba:
    n = src.count('lat\\\\v19c-')
    assert n > 0, n
    src = src.replace('lat\\\\v19c-', 'lat\\\\v19d-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19d', 'prueba' if prueba else 'normal')
