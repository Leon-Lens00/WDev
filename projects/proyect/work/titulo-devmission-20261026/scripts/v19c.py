#!/usr/bin/env python3
"""v19c (19/11/2026), a petición de Leon:
- "que sus habilidades los lanze el dummy como con el tauren": Goku, Freezer, Trunks y Naruto lanzan sus técnicas
  reales de D.O.N desde una copia ('hCpG', 'hCpF', 'hCpT', 'hCpN', 'hCpK' en modo Kyuubi; objetos_v19c.py) que
  aparece junto al héroe mirando al objetivo, recibe la habilidad al nivel del héroe y la lanza con sus animaciones.
  El héroe sigue libre: ya no se le corta el movimiento ni la ráfaga. Siguen en el héroe las que cambian al propio
  héroe: Power Up de Goku, Freezer y Trunks, Kyuubi Mode y Kage Bunshin.
  Copia ocupada (pausada, con orden o escondida; mínimo 1 s, máximo 15 s): no se lanza otra técnica de ese jugador
  salvo Destructo Disc (D.O.N admite varios). Después se desvanece en 0,5 s y sigue invisible hasta los 25 s (los
  disparos de D.O.N la usan como origen del daño); se quita a los 25 s si su técnica ya no está en curso (máximo 60 s).
  Rasenrengan comprueba el tipo del lanzador: Dcp_Tipo traduce la copia al tipo de su héroe.
- Rocas del Tauren con área ×3: Lanzar roca 180 → 540 por bote y piedra del Bombardeo 150 → 450, con anillo de polvo.
- Embestida (Q): animación de ataque en bucle durante la carga; quien toca recibe 300 una vez y va pegado delante
  de la copia (ya no se aparta); el golpe final sigue igual (500 a 260, a todos).
- -pj N ya existe (0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto); sin cambios.
Prueba: "don copia jP orden" al lanzar y "don fin jP orden t" al quitarla (lat\\v19c-bolsas.txt).
Uso: v19c.py ENTRADA.j (de v19b) SALIDA.j [prueba]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1, latin=False):
    # latin: el texto viejo está en latin-1 en el j (comentarios antiguos); el nuevo siempre se pasa a UTF-8.
    global src
    viejo, nuevo = (viejo if latin else U(viejo)), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('integer Emp_N = 0\n', 'integer Emp_N = 0\n'
       'unit array Dcp_U\ninteger array Dcp_P\ninteger array Dcp_A\ninteger array Dcp_F\ninteger array Dcp_K\n'
       'integer array Dcp_S\nstring array Dcp_O\ninteger Dcp_N = 0\n'
       'real Arr_X = 0.\nreal Arr_Y = 0.\nreal Arr_A = 0.\n')

# --- Rocas ×3 ---
cambia('''        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 180., Cop_D[i]))
''', '''        call Cop_Anillo(Cop_X[i], Cop_Y[i], 270., 6)
        call Cop_Anillo(Cop_X[i], Cop_Y[i], 500., 10)
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 540., Cop_D[i]))
''')
cambia('''        set Bom_Golpes[p] = Bom_Golpes[p] + Cop_Area(p, null, 0., Cop_X[i], Cop_Y[i], 150., Cop_D[i])
''', '''        call Cop_Anillo(Cop_X[i], Cop_Y[i], 300., 6)
        set Bom_Golpes[p] = Bom_Golpes[p] + Cop_Area(p, null, 0., Cop_X[i], Cop_Y[i], 450., Cop_D[i])
''')
cambia('// 3 Lanzar roca: arco al punto (D a 180)', '// 3 Lanzar roca: arco al punto (D a 540, v19c)')
cambia('// 7 piedra del Bombardeo: 180 a 150 al caer.', '// 7 piedra del Bombardeo: 180 a 450 al caer (v19c).')

# --- Embestida: ataque en bucle y arrastre ---
cambia('''// 1 Embestida: amago 7 pasos, carga 33 por paso (300 a 140, una vez, aparta 180), golpe al paso 12 (500 a 260).
function Cop_T1 takes integer i returns nothing
    local real s
    if Cop_Fase[i] == 0 then
        if Cop_K[i] >= 7 then
            set Cop_Fase[i] = 1
            set Cop_K[i] = 0
            call SetUnitTimeScale(Cop_U[i], 2.5)
            call SetUnitAnimation(Cop_U[i], "walk")
        endif
''', '''// v19c: polvo en círculo para que se vea el área de las rocas.
function Cop_Anillo takes real x, real y, real r, integer n returns nothing
    local integer k = 0
    local real a
    loop
        exitwhen k >= n
        set a = 2. * bj_PI * I2R(k) / I2R(n)
        call DestroyEffect(AddSpecialEffect("Objects\\\\Spawnmodels\\\\Undead\\\\ImpaleTargetDust\\\\ImpaleTargetDust.mdl", x + r * Cos(a), y + r * Sin(a)))
        set k = k + 1
    endloop
endfunction

// v19c: quien toca la Embestida va 90 por delante de la copia, a no más de 70 de su línea.
function Cop_Arrastrar takes nothing returns nothing
    local unit u = GetEnumUnit()
    local real dx
    local real dy
    local real l
    local real x
    local real y
    if GetWidgetLife(u) > 0.405 then
        set dx = GetUnitX(u) - Arr_X
        set dy = GetUnitY(u) - Arr_Y
        set l = Cos(Arr_A) * dy - Sin(Arr_A) * dx
        if l > 70. then
            set l = 70.
        elseif l < -70. then
            set l = -70.
        endif
        set x = Arr_X + 90. * Cos(Arr_A) - l * Sin(Arr_A)
        set y = Arr_Y + 90. * Sin(Arr_A) + l * Cos(Arr_A)
        if Cop_Dentro(x, y) and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
            call SetUnitX(u, x)
            call SetUnitY(u, y)
        endif
    endif
    set u = null
endfunction

// 1 Embestida (v19c): amago 7 pasos, carga 33 por paso atacando (300 a 140, una vez, y se lo lleva por delante),
// golpe al paso 12 (500 a 260, a todos).
function Cop_T1 takes integer i returns nothing
    local real s
    if Cop_Fase[i] == 0 then
        if Cop_K[i] >= 7 then
            set Cop_Fase[i] = 1
            set Cop_K[i] = 0
            call SetUnitTimeScale(Cop_U[i], 1.5)
            call SetUnitAnimation(Cop_U[i], "attack")
        endif
''')
cambia('''            set Cop_Rest[i] = Cop_Rest[i] - s
            call Cop_Opc()
            set Cop_oEmp = 180.
            set Cop_oLat = true
            call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 140., 300.))
''', '''            set Cop_Rest[i] = Cop_Rest[i] - s
            if ModuloInteger(Cop_K[i], 27) == 0 then
                call SetUnitAnimation(Cop_U[i], "attack")
            endif
            call Cop_Opc()
            call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 140., 300.))
            set Arr_X = Cop_X[i]
            set Arr_Y = Cop_Y[i]
            set Arr_A = Cop_A[i]
            call ForGroup(Cop_G[i], function Cop_Arrastrar)
''')

# --- Copias de D.O.N: lanzamiento (antes del código de D.O.N y de Gk_Relevo) ---
DCP1 = r'''// v19c: copias de D.O.N. La copia del héroe b recibe la habilidad real a al nivel del héroe y la lanza
// (obj 0 inmediata, 1 a la unidad t, 2 al punto x, y). Leon (19/11/2026): "que sus habilidades los lanze el dummy".
function Dcp_Tipo takes unit u returns integer
    local integer t = GetUnitTypeId(u)
    if t == 'hCpG' then
        return 'hGok'
    elseif t == 'hCpF' then
        return 'hFrz'
    elseif t == 'hCpT' then
        return 'hTrk'
    elseif t == 'hCpN' then
        return 'hNar'
    elseif t == 'hCpK' then
        return 'hNaK'
    endif
    return t
endfunction

// Siguen en el héroe las técnicas que lo cambian a él: Power Up (Freezer, Trunks), Kyuubi Mode y Kage Bunshin.
function Dcp_EnHeroe takes integer a returns boolean
    return a == 'A0IZ' or a == 'A0H5' or a == 'A00U' or a == 'A00T'
endfunction

function Dcp_Ocupada takes integer p returns boolean
    local integer i = 0
    loop
        exitwhen i >= Dcp_N
        if Dcp_P[i] == p and Dcp_F[i] == 0 and Dcp_A[i] != 'A0IY' then
            return true
        endif
        set i = i + 1
    endloop
    return false
endfunction

function Dcp_Lanzar takes unit b, integer a, integer obj, string orden, unit t, real x, real y returns boolean
    local integer p = GetPlayerId(GetOwningPlayer(b))
    local integer tb = GetUnitTypeId(b)
    local integer tc = 'hCpG'
    local real ang = GetUnitFacing(b)
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
        set ang = bj_RADTODEG * Atan2(GetUnitY(t) - GetUnitY(b), GetUnitX(t) - GetUnitX(b))
    elseif obj == 2 then
        set ang = bj_RADTODEG * Atan2(y - GetUnitY(b), x - GetUnitX(b))
    endif
    set c = CreateUnit(GetOwningPlayer(b), tc, GetUnitX(b), GetUnitY(b), ang)
    call SetUnitVertexColor(c, 140, 210, 255, 150)
    call SetUnitPathing(c, false)
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
    set Cop_Log = "don copia j" + I2S(p) + " " + orden
    call ExecuteFunc("Cop_Anotar")
    set c = null
    return true
endfunction

'''
cambia('function Gk_Fuerza takes unit u returns integer\n', DCP1 + 'function Gk_Fuerza takes unit u returns integer\n')

# Rasenrengan mira el tipo del lanzador (dos copias del bloque en D.O.N).
cambia("return(GetUnitTypeId(GetSpellAbilityUnit())=='hNaK')\n", "return(Dcp_Tipo(GetSpellAbilityUnit())=='hNaK')\n", 2)
cambia("return(GetUnitTypeId(GetSpellAbilityUnit())=='hNar')\n", "return(Dcp_Tipo(GetSpellAbilityUnit())=='hNar')\n", 2)

# --- Goku ---
cambia('''        if b == Gk_Cuerpo and UnitAlive(b) and not IsUnitPaused(b) then
            call s__RapidPair_endDash(this, false)
            call s__RapidPair_finish(this, false)
            set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
            if a == 'AGk1' then
                // A00P es Serpent Ward (AOsw): su orden es ward (corrección del 13/11; shockwave no la lanzaba).
                call IssuePointOrder(b, "ward", x, y)
            elseif a == 'AGk2' then
                call IssueTargetOrder(b, "thunderbolt", t)
            elseif a == 'AGk3' then
                call IssuePointOrder(b, "impale", x, y)
            elseif a == 'AGk4' then
                call IssueImmediateOrder(b, "voodoo")
            else
                call IssuePointOrder(b, "rainoffire", x, y)
            endif
        endif
'''.replace('correcci\u00f3n', 'correcci\xf3n'), '''        if b == Gk_Cuerpo and UnitAlive(b) and not IsUnitPaused(b) then
            // v19c: Power Up sigue en el héroe; el resto lo lanza una copia y el héroe sigue libre.
            if a == 'AGk4' then
                call s__RapidPair_endDash(this, false)
                call s__RapidPair_finish(this, false)
                set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
                call IssueImmediateOrder(b, "voodoo")
            elseif Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b))) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Ahora no: la copia sigue con otra técnica.")
            elseif a == 'AGk1' then
                // A00P es Serpent Ward (AOsw): su orden es ward (corrección del 13/11; shockwave no la lanzaba).
                call Dcp_Lanzar(b, 'A00P', 2, "ward", null, x, y)
            elseif a == 'AGk2' then
                call Dcp_Lanzar(b, 'A0IA', 1, "thunderbolt", t, x, y)
            elseif a == 'AGk3' then
                call Dcp_Lanzar(b, 'A0BZ', 2, "impale", null, x, y)
            else
                call Dcp_Lanzar(b, 'A01G', 2, "rainoffire", null, x, y)
            endif
        endif
''', latin=True)

# --- Freezer, Trunks, Naruto ---
cambia('''        elseif UnitAlive(b) then
            call s__RapidPair_endDash(this, false)
            call s__RapidPair_finish(this, false)
            set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
            if Don_BotObj[n] == 0 then
''', '''        elseif UnitAlive(b) and not Dcp_EnHeroe(Don_BotReal[n]) then
            // v19c: la lanza una copia; el héroe sigue libre.
            if Don_BotReal[n] != 'A0IY' and Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b))) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Ahora no: la copia sigue con otra técnica.")
            elseif not Dcp_Lanzar(b, Don_BotReal[n], Don_BotObj[n], Don_BotOrden[n], t, x, y) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 4., "La copia no aceptó la orden " + Don_BotOrden[n] + ".")
            endif
        elseif UnitAlive(b) then
            call s__RapidPair_endDash(this, false)
            call s__RapidPair_finish(this, false)
            set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
            if Don_BotObj[n] == 0 then
''')

# --- Reloj de las copias (tras Don_EnCurso) ---
DCP2 = r'''// v19c: vida de las copias de D.O.N, cada 0,05 s. Ocupada mientras está pausada, con orden o escondida
// (mínimo 1 s, máximo 15 s); luego se desvanece en 0,5 s y sigue invisible hasta los 25 s (máximo 60 s si su
// técnica sigue en curso), porque los disparos de D.O.N la usan como origen del daño.
function Dcp_Tick takes nothing returns nothing
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
            set Cop_Log = "don fin j" + I2S(Dcp_P[i]) + " " + Dcp_O[i] + " t" + I2S(Dcp_S[i])
            call ExecuteFunc("Cop_Anotar")
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
            set Dcp_U[j] = null
        else
            set i = i + 1
        endif
    endloop
    set c = null
endfunction

'''
cambia('// v19b: motor de copias de Tauren y Cairne.', DCP2 + '// v19b: motor de copias de Tauren y Cairne.')
cambia('''    set Cop_Marcados = CreateGroup()
    call TimerStart(CreateTimer(), 0.25, true, function Gua_Tick)
''', '''    set Cop_Marcados = CreateGroup()
    call TimerStart(CreateTimer(), 0.25, true, function Gua_Tick)
    call TimerStart(CreateTimer(), 0.05, true, function Dcp_Tick)
''')

# --- Precarga de las copias ---
cambia("    call RemoveUnit(CreateUnit(Player(15), 'hCp2', -12000., 9000., 0.))\n",
       "    call RemoveUnit(CreateUnit(Player(15), 'hCp2', -12000., 9000., 0.))\n"
       "    // v19c: copias de los personajes de D.O.N.\n"
       + ''.join(f"    call RemoveUnit(CreateUnit(Player(15), '{t}', -12000., 9000., 0.))\n"
                 for t in ('hCpG', 'hCpF', 'hCpT', 'hCpN', 'hCpK')))

if prueba:
    n = src.count('lat\\\\v19b-')
    assert n > 0, n
    src = src.replace('lat\\\\v19b-', 'lat\\\\v19c-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19c', 'prueba' if prueba else 'normal')
