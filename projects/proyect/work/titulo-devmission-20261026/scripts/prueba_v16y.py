#!/usr/bin/env python3
"""Sólo prueba, v16y-prueba (13/11/2026): registro de las habilidades de D.O.N en CustomMapData/lat/v16y-1.txt.

Leon: "no se ejecutan, agrega tu modo registro para que veas que pasa al terminar el mapa". Burning Attack (A05B) y
Destructo Disc (A0IY) no salen y la lectura del código no encontró la causa. Se registra, con hora de partida:
- cada botón puente (Don_Relevo): habilidad real, tipo, vida, pausa, caída, en curso, orden y si el cuerpo la aceptó;
- órdenes (salvo move/smart) y eventos de hechizo del cuerpo de Freezer, Trunks y Naruto;
- niveles de las habilidades reales al armar el cuerpo;
- inicio de Burning Attack y Destructo Disc, motores (Don_Motor/Don_MotTerminar) y condiciones falsas del motor;
- cada 0,2 s, mientras sus motores están encendidos, la pieza de Burning Attack y el primer disco.
El archivo se reescribe cada 2 s si hay notas nuevas (tope 1500 líneas). No va en el mapa normal.
Uso: prueba_v16y.py v16y/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes.encode('utf-8')), crlf(despues.encode('utf-8'))
    assert j.count(antes) == 1, (antes[:90], j.count(antes))
    j = j.replace(antes, despues)


GLOB = """string array Reg_L
integer Reg_N = 0
boolean Reg_Sucio = false
timer Reg_Reloj = null
integer Reg_EvalNo = 0
endglobals
"""

FUNCS = r"""// v16y-prueba: registro de habilidades de D.O.N (lat\v16y-1.txt)
function Reg takes string s returns nothing
    if Reg_N < 1500 then
        set Reg_L[Reg_N] = R2SW(TimerGetElapsed(Reg_Reloj), 1, 2) + " " + s
        set Reg_N = Reg_N + 1
        set Reg_Sucio = true
    endif
endfunction

function Reg_Id takes integer i returns string
    local string c = "0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz"
    local string s = ""
    local integer k = 0
    local integer d
    if i < 16777216 then
        return I2S(i)
    endif
    loop
        exitwhen k == 4
        set d = ModuloInteger(i, 256)
        if d >= 48 and d <= 122 then
            set s = SubString(c, d - 48, d - 47) + s
        else
            set s = "?" + s
        endif
        set i = i / 256
        set k = k + 1
    endloop
    return s
endfunction

function Reg_B takes boolean b returns string
    if b then
        return "1"
    endif
    return "0"
endfunction

function Reg_U takes unit u returns string
    if u == null then
        return "null"
    endif
    return Reg_Id(GetUnitTypeId(u)) + "(" + I2S(R2I(GetUnitX(u))) + "," + I2S(R2I(GetUnitY(u))) + " vida=" + I2S(R2I(GetWidgetLife(u))) + " viva=" + Reg_B(UnitAlive(u)) + " alt=" + I2S(R2I(GetUnitFlyHeight(u))) + ")"
endfunction

function Reg_Trig takes trigger t returns string
    if t == TrV_BB then
        return "TrBB"
    elseif t == FzV_is then
        return "FzIs"
    elseif t == TrV_Mu then
        return "TrMu"
    elseif t == NaV_kB then
        return "NakB"
    elseif t == NaV_mB then
        return "NamB"
    endif
    return "h" + I2S(GetHandleId(t))
endfunction

function Reg_Volcar takes nothing returns nothing
    local integer i = 0
    if not Reg_Sucio then
        return
    endif
    set Reg_Sucio = false
    call PreloadGenClear()
    call PreloadGenStart()
    loop
        exitwhen i >= Reg_N
        call Preload(Reg_L[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("lat\\v16y-1.txt")
endfunction

function Reg_EsCuerpo takes unit u returns boolean
    local integer t = GetUnitTypeId(u)
    return t == 'hTrk' or t == 'hFrz' or t == 'hNar' or t == 'hNaK'
endfunction

function Reg_Orden takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local string o = OrderId2String(GetIssuedOrderId())
    if Reg_EsCuerpo(u) and o != "move" and o != "smart" then
        if o == null then
            set o = I2S(GetIssuedOrderId())
        endif
        call Reg("orden " + Reg_Id(GetUnitTypeId(u)) + " " + o + " blanco=" + Reg_U(GetOrderTargetUnit()) + " x=" + I2S(R2I(GetOrderPointX())) + " y=" + I2S(R2I(GetOrderPointY())) + " pausa=" + Reg_B(IsUnitPaused(u)))
    endif
    set u = null
endfunction

function Reg_Hechizo takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local eventid e = GetTriggerEventId()
    local string n = "?"
    if Reg_EsCuerpo(u) then
        if e == EVENT_PLAYER_UNIT_SPELL_CHANNEL then
            set n = "CHANNEL"
        elseif e == EVENT_PLAYER_UNIT_SPELL_CAST then
            set n = "CAST"
        elseif e == EVENT_PLAYER_UNIT_SPELL_EFFECT then
            set n = "EFFECT"
        elseif e == EVENT_PLAYER_UNIT_SPELL_ENDCAST then
            set n = "ENDCAST"
        elseif e == EVENT_PLAYER_UNIT_SPELL_FINISH then
            set n = "FINISH"
        endif
        call Reg("hechizo " + n + " " + Reg_Id(GetSpellAbilityId()) + " nivel=" + I2S(GetUnitAbilityLevel(u, GetSpellAbilityId())) + " cuerpo=" + Reg_U(u) + " orden=" + OrderId2String(GetUnitCurrentOrder(u)))
    endif
    set u = null
    set e = null
endfunction

function Reg_Muestra takes nothing returns nothing
    if IsTriggerEnabled(TrV_BB) then
        call Reg("BB n8C8=" + I2S(TrV_n8[$C8]) + " paso=" + I2S(TrV_n8[$C9]) + " pieza=" + Reg_U(TrV_s8[$C9]) + " Trunks=" + Reg_U(TrV_s8[$C8]))
    endif
    if IsTriggerEnabled(FzV_is) then
        call Reg("is Ag=" + I2S(FzV_Ag) + " wg=" + I2S(FzV_wg) + " disco1=" + Reg_U(FzV_xg[1]))
    endif
endfunction

function Reg_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    set Reg_Reloj = CreateTimer()
    call TimerStart(Reg_Reloj, 100000., false, null)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    call TriggerAddAction(t, function Reg_Orden)
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_FINISH)
    call TriggerAddAction(t, function Reg_Hechizo)
    call TimerStart(CreateTimer(), 0.2, true, function Reg_Muestra)
    call TimerStart(CreateTimer(), 2., true, function Reg_Volcar)
    call Reg("v16y-prueba: registro de habilidades")
    set t = null
endfunction

function Don_MotTerminar takes integer m returns nothing
"""

una("endglobals\n", GLOB)
una("function Don_MotTerminar takes integer m returns nothing\n", FUNCS)
# motores
una("""    if s__Missile_allocated[m] then
        if Don_MotT[m] != null then
            call RemoveSavedInteger""", """    if s__Missile_allocated[m] then
        call Reg("motor fin " + Reg_Trig(Don_MotT[m]) + " encendido=" + Reg_B(Don_MotT[m] != null and IsTriggerEnabled(Don_MotT[m])))
        if Don_MotT[m] != null then
            call RemoveSavedInteger""")
una("""                if TriggerEvaluate(t) then
                    call TriggerExecute(t)
                endif
""", """                if TriggerEvaluate(t) then
                    call TriggerExecute(t)
                elseif Reg_EvalNo < 40 then
                    set Reg_EvalNo = Reg_EvalNo + 1
                    call Reg("motor condición falsa " + Reg_Trig(t))
                endif
""")
una("""    local integer m = LoadInteger(Don_Mot, GetHandleId(t), 0)
    if m != 0 and Don_MotT[m] == t and s__Missile_allocated[m] then
        return
""", """    local integer m = LoadInteger(Don_Mot, GetHandleId(t), 0)
    call Reg("motor pedido " + Reg_Trig(t) + " periodo=" + R2S(periodo) + " yaActivo=" + Reg_B(m != 0 and Don_MotT[m] == t and s__Missile_allocated[m]))
    if m != 0 and Don_MotT[m] == t and s__Missile_allocated[m] then
        return
""")
# habilidades
una("function TrF_l97 takes nothing returns nothing\n",
    "function TrF_l97 takes nothing returns nothing\ncall Reg(\"BA inicio cuerpo=\" + Reg_U(GetSpellAbilityUnit()) + \" punto=\" + I2S(R2I(GetSpellTargetX())) + \",\" + I2S(R2I(GetSpellTargetY())))\n")
una("set TrV_Se[$C8]=((100*GetUnitAbilityLevelSwapped('A05B',TrV_s8[$C8]))+(2*Tr_Stat(1)))\n",
    "set TrV_Se[$C8]=((100*GetUnitAbilityLevelSwapped('A05B',TrV_s8[$C8]))+(2*Tr_Stat(1)))\ncall Reg(\"BA motor pieza=\" + Reg_U(TrV_s8[$C9]) + \" pausa=\" + Reg_B(IsUnitPaused(TrV_s8[$C8])) + \" dano=\" + I2S(TrV_Se[$C8]))\n")
una("function FzF_ki4 takes nothing returns nothing\n",
    "function FzF_ki4 takes nothing returns nothing\ncall Reg(\"DD inicio cuerpo=\" + Reg_U(GetSpellAbilityUnit()) + \" mira=\" + I2S(R2I(GetUnitFacing(GetSpellAbilityUnit()))) + \" Ag=\" + I2S(FzV_Ag) + \" motor=\" + Reg_B(IsTriggerEnabled(FzV_is)))\n")
una("set FzV_xg[FzV_wg]=bj_lastCreatedUnit\n",
    "set FzV_xg[FzV_wg]=bj_lastCreatedUnit\ncall Reg(\"DD disco wg=\" + I2S(FzV_wg) + \" Ag=\" + I2S(FzV_Ag) + \" \" + Reg_U(bj_lastCreatedUnit) + \" motor=\" + Reg_B(IsTriggerEnabled(FzV_is)))\n")
# relevo
una("""        exitwhen n >= Don_Bots or Don_BotId[n] == a
        set n = n + 1
    endloop
""", """        exitwhen n >= Don_Bots or Don_BotId[n] == a
        set n = n + 1
    endloop
    if n < Don_Bots then
        call Reg("relevo " + Reg_Id(a) + " real=" + Reg_Id(Don_BotReal[n]) + " orden=" + Don_BotOrden[n] + " obj=" + I2S(Don_BotObj[n]) + " par=" + I2S(this) + " cuerpo=" + Reg_U(s__RapidPair_actor[this]) + " pausa=" + Reg_B(IsUnitPaused(s__RapidPair_actor[this])) + " caido=" + Reg_B(this != 0 and s__RapidPair_down[this]) + " enCurso=" + Reg_B(Don_EnCurso(Don_BotReal[n])) + " nivel=" + I2S(GetUnitAbilityLevel(s__RapidPair_actor[this], Don_BotReal[n])) + " x=" + I2S(R2I(x)) + " y=" + I2S(R2I(y)))
    endif
""")
una("""            if not ok then
                call DisplayTimedTextToPlayer""", """            call Reg("relevo aceptada=" + Reg_B(ok) + " ordenActual=" + OrderId2String(GetUnitCurrentOrder(b)))
            if not ok then
                call DisplayTimedTextToPlayer""")
# armar
una("""        set NaV_s8[5790]=b
    endif
    set b = null
endfunction
""", """        set NaV_s8[5790]=b
    endif
    call Reg("armar " + Reg_U(b) + " A05B=" + I2S(GetUnitAbilityLevel(b, 'A05B')) + " A0IY=" + I2S(GetUnitAbilityLevel(b, 'A0IY')) + " A0F3=" + I2S(GetUnitAbilityLevel(b, 'A0F3')) + " mana=" + I2S(R2I(GetUnitState(b, UNIT_STATE_MANA))))
    set b = null
endfunction
""")
una("""    call ExecuteFunc("Pj_Init")
""", """    call ExecuteFunc("Pj_Init")
    call ExecuteFunc("Reg_Init")
""")
Path(sys.argv[2]).write_bytes(j)
print('v16y-prueba: registro')
