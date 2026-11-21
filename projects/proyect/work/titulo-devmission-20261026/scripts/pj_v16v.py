#!/usr/bin/env python3
"""v16v (13/11/2026): comando -pj N para cambiar de personaje dentro de la partida.

Leon (13/11/2026), al probar v16u: "como pruebo los pjs, aparece la partida con el tauren como predeterminado". Desde
v16a la partida entra directa (Tut_Entrar: Title_Begin + Title_Exit) y no se ve el título, así que nadie elige celda.
-pj N (0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto) rehace la pareja del jugador en el mismo sitio:
quita cuerpo y controlador (RapidPair_destroy), fija Hero_Choice y llama a Game_Cuerpo, como la reaparición; cambia el
icono de vida y, si había oleada, el blanco y la visión de las oleadas pasan al cuerpo nuevo. Uno de cada héroe de
D.O.N por partida; sólo con el personaje vivo y sin una habilidad de D.O.N en curso (cuerpo pausado).
Uso: pj_v16v.py v16u/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes.encode('latin-1')), crlf(despues.encode('latin-1'))
    assert j.count(antes) == 1, (antes[:90], j.count(antes))
    j = j.replace(antes, despues)


PJ = """// v16v: -pj N cambia el personaje en la partida (la entrada directa no pasa por el título).
function Pj_Aviso takes player pl, string s returns nothing
    call DisplayTimedTextToPlayer(pl, 0., 0., 6., s)
endfunction

function Pj_Cambiar takes nothing returns nothing
    local player pl = GetTriggerPlayer()
    local integer p = GetPlayerId(pl)
    local string s = GetEventPlayerChatString()
    local string n = SubString(s, 4, StringLength(s))
    local integer k = S2I(n)
    local integer i = 0
    local real x
    local real y
    local unit viejo
    local integer icon = 'hbi0'
    local integer o
    if StringLength(n) != 1 or k < 0 or k > 5 or (k == 0 and n != "0") or Hero_Icon[k] == 0 then
        call Pj_Aviso(pl, "Uso: -pj N   0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto")
        return
    endif
    if p > 11 or not Game_On[p] or Game_Pair[p] == 0 or not UnitAlive(Game_Hero[p]) or IsUnitPaused(Game_Hero[p]) or s__RapidPair_down[Game_Pair[p]] then
        call Pj_Aviso(pl, "-pj: ahora no; el personaje tiene que estar vivo y sin una habilidad en curso.")
        return
    endif
    if (k == 2 and Gk_Dueno >= 0 and Gk_Dueno != p) or (k >= 3 and Don_Dueno[k] >= 0 and Don_Dueno[k] != p) then
        call Pj_Aviso(pl, "-pj: ese personaje ya lo tiene otro jugador.")
        return
    endif
    // suelta el héroe de D.O.N que tenía
    if Gk_Dueno == p then
        set Gk_Dueno = -1
    endif
    set i = 3
    loop
        exitwhen i > 5
        if Don_Dueno[i] == p then
            set Don_Dueno[i] = -1
        endif
        set i = i + 1
    endloop
    set viejo = Game_Hero[p]
    set x = GetUnitX(viejo)
    set y = GetUnitY(viejo)
    call s__RapidPair_destroy(Game_Pair[p])
    set Game_Pair[p] = 0
    if Arm_Cono[p] != null then
        call DestroyEffect(Arm_Cono[p])
        set Arm_Cono[p] = null
    endif
    if Vidas_EnPartida[p] then
        set Vidas_EnPartida[p] = false
        set Vidas_EnPie = Vidas_EnPie - 1
    endif
    set Hero_Choice[p] = k
    set Hero_Locked[p] = true
    call Game_Cuerpo(p, x, y)
    call SetUnitInvulnerable(Game_Hero[p], GetUnitAbilityLevel(viejo, 'Avul') > 0)
    // blanco y visión de la oleada en curso
    set i = 0
    loop
        exitwhen i >= DevWave__Count
        if DevWave__Targets[i] == viejo then
            set DevWave__Targets[i] = Game_Hero[p]
            set o = WAVE_DEFAULT_OWNER_MIN
            loop
                exitwhen o > WAVE_DEFAULT_OWNER_MAX
                call UnitShareVision(Game_Hero[p], Player(o), true)
                set o = o + 1
            endloop
        endif
        set i = i + 1
    endloop
    if DevWave__First == viejo then
        set DevWave__First = Game_Hero[p]
    endif
    call RemoveUnit(viejo)
    set viejo = null
    // icono de vida
    if k == 1 then
        set icon = 'hbi1'
    endif
    if GetUnitTypeId(Game_Hero[p]) == 'hGok' then
        set icon = 'hbi3'
    elseif GetUnitTypeId(Game_Hero[p]) == 'hFrz' then
        set icon = 'hbi4'
    elseif GetUnitTypeId(Game_Hero[p]) == 'hTrk' then
        set icon = 'hbi5'
    elseif GetUnitTypeId(Game_Hero[p]) == 'hNar' then
        set icon = 'hbi6'
    endif
    if HealthBars__Icons[p] != null then
        call RemoveUnit(HealthBars__Icons[p])
        set HealthBars__Icons[p] = HealthBars__Dummy(icon, p)
    endif
    set HealthBars__Heroes[p] = Game_Hero[p]
    set HealthBars__HeroPcts[p] = -1
    call Pj_Aviso(pl, "Personaje: " + Don_Nombre(p) + "  (-pj N para cambiar)")
    if GetLocalPlayer() == pl then
        call ClearSelection()
        call SelectUnit(Game_Ctrl[p], true)
    endif
endfunction

function Pj_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    loop
        exitwhen i > 11
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-pj", false)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function Pj_Cambiar)
    set t = null
endfunction

"""
una('\nfunction Ronda_Lanzar takes nothing returns nothing\n', '\n' + PJ + 'function Ronda_Lanzar takes nothing returns nothing\n')
una("""    call ExecuteFunc("Don_Init")
""", """    call ExecuteFunc("Don_Init")
    call ExecuteFunc("Pj_Init")
""")
Path(sys.argv[2]).write_bytes(j)
print('v16v: -pj N')
