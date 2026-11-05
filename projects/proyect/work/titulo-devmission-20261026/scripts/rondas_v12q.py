"""Dev Mission v12q (31/10/2026): rounds, rest, healing, return of the eliminated and the round counter.

Base of 3 lives, which rounds do not refill. A round closes on the wave's finish event: everybody heals and whoever ran out of lives
comes back with none, as a new body where they died. A finish inside the defeat delay cancels that defeat, so a missile in flight can
still win the round; a fall in progress just ends normally. Nobody can die during the rest.

The counter takes the place of the day clock, one icon and two texts per player, on the same camera as the life bar.

Usage: rondas_v12q.py IN_J OUT_J
"""
from pathlib import Path
import re
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

GLOBAL_OLD = 'trigger Vidas_Salida = null\n'
GLOBAL_NEW = GLOBAL_OLD + '''constant integer Ronda_TOTAL = 10
constant integer Ronda_DESCANSO = 45
constant real Ronda_VISION = 4000.
constant real Ronda_ICONO_X = 960.
constant real Ronda_ICONO_Y = 84.
constant real Ronda_TITULO_Y = 68.
constant real Ronda_CIFRA_Y = 104.
integer Ronda_Numero = 1
integer Ronda_Resta = 0
integer Ronda_Wave = 0
boolean Ronda_Activa = false
boolean Ronda_Descanso = false
timer Ronda_Reloj = null
real array Vidas_X
real array Vidas_Y
unit array Ronda_Icono
integer array Ronda_Titulo
integer array Ronda_Cifra
string array Ronda_TituloVisto
string array Ronda_CifraVista
'''
HUD_FUNCS = '''function Ronda_Texto takes integer ui,string s,real size,real y returns nothing
    call s__UIText_setPosition(ui,( 960. - I2R(StringLength(s)) * 4.5 * size / 0.017 - 960. ) / 728. , ( 420. - y ) / 390.)
    call SetTextTagText(s__UIText_text[ui], s, size)
endfunction

// The icon is red in the rest and dark during a wave, so the red title stays readable.
function Ronda_Color takes integer p returns nothing
    local integer alpha= 0
    if GetLocalPlayer() == Player(p) then
        set alpha=255
    endif
    if Ronda_Descanso then
        call SetUnitVertexColor(Ronda_Icono[p], 225, 28, 28, alpha)
    else
        call SetUnitVertexColor(Ronda_Icono[p], 44, 44, 48, alpha)
    endif
endfunction

function Ronda_Hud takes integer p,integer cam returns nothing
    local boolean shown= HealthBars__Visible and Ronda_Activa
    local string t
    local string c
    call ShowUnit(Ronda_Icono[p], shown)
    call s__UIText_show(Ronda_Titulo[p],shown , cam)
    call s__UIText_show(Ronda_Cifra[p],shown , cam)
    if shown then
        call HealthBars__Place(Ronda_Icono[p] , cam , Ronda_ICONO_X , Ronda_ICONO_Y , 402.)
        if Ronda_Descanso then
            set t="Descanso"
            set c=I2S(Ronda_Resta)
        else
            set t="Wave " + I2S(Ronda_Numero)
            set c=I2S(s__Wave_toKillRemaining[Ronda_Wave])
        endif
        if t != Ronda_TituloVisto[p] then
            set Ronda_TituloVisto[p]=t
            call Ronda_Color(p)
            if Ronda_Descanso then
                call SetTextTagColor(s__UIText_text[Ronda_Titulo[p]], 255, 255, 255, 255)
            else
                call SetTextTagColor(s__UIText_text[Ronda_Titulo[p]], 255, 48, 48, 255)
            endif
            call Ronda_Texto(Ronda_Titulo[p] , t , 0.017 , Ronda_TITULO_Y)
        endif
        if c != Ronda_CifraVista[p] then
            set Ronda_CifraVista[p]=c
            call Ronda_Texto(Ronda_Cifra[p] , c , 0.024 , Ronda_CIFRA_Y)
        endif
    endif
endfunction

'''
HUD_ANCHOR = 'function HealthBarsUpdate takes nothing returns nothing\n'
HUD_TICK_OLD = '            set shown=HealthBars__Visible and HealthBars__Target != null and GetUnitTypeId(HealthBars__Target) != 0\n'
HUD_TICK_NEW = '            call Ronda_Hud(p , cam)\n' + HUD_TICK_OLD
BIND_OLD = '    set HealthBars__Bound[p]=true\n'
BIND_NEW = '''    set Ronda_Icono[p]=HealthBars__Dummy('hbi2' , p)
    set Ronda_Titulo[p]=s__UIText_createEx(Player(p) , 0. , 0. , 1.)
    set Ronda_Cifra[p]=s__UIText_createEx(Player(p) , 0. , 0. , 1.)
    call SetTextTagPermanent(s__UIText_text[Ronda_Titulo[p]], true)
    call SetTextTagPermanent(s__UIText_text[Ronda_Cifra[p]], true)
    call SetTextTagColor(s__UIText_text[Ronda_Cifra[p]], 255, 255, 255, 255)
''' + BIND_OLD
RETIRE_OLD = '''        set Vidas_EnPartida[p] = false
'''
RETIRE_NEW = RETIRE_OLD + '''        set Vidas_X[p] = GetUnitX(Game_Hero[p])
        set Vidas_Y[p] = GetUnitY(Game_Hero[p])
'''
DEFEAT_OLD = '''    call DestroyTimer(GetExpiredTimer())
    set Vidas_Perdida = true
'''
DEFEAT_NEW = '''    call DestroyTimer(GetExpiredTimer())
    if Ronda_Descanso then
        return
    endif
    set Vidas_Perdida = true
'''
SHIELD_OLD = '    call SetUnitInvulnerable(Game_Hero[p], false)\n    call DestroyEffect(Vidas_Escudo[p])\n'
SHIELD_NEW = '    call SetUnitInvulnerable(Game_Hero[p], Ronda_Descanso)\n    call DestroyEffect(Vidas_Escudo[p])\n'
ARRANCAR_RE = re.compile(r'function DevWave_Arrancar takes nothing returns nothing\r\n.*?endfunction\r\n', re.S)
ROUND_FUNCS = '''function Game_Volver takes integer p returns nothing
    if GetUnitTypeId(Game_Hero[p]) != 0 then
        call RemoveUnit(Game_Hero[p])
    endif
    call Game_Cuerpo(p , Vidas_X[p] , Vidas_Y[p])
    if Vidas_Actual[p] <= 0 then
        call UnitRemoveAbility(Game_Hero[p], 'Arei')
    endif
    call SetUnitInvulnerable(Game_Hero[p], true)
    call DestroyEffect(AddSpecialEffectTarget("Abilities\\\\Spells\\\\Human\\\\Resurrect\\\\ResurrectTarget.mdl", Game_Hero[p], "origin"))
    set HealthBars__Heroes[p]=Game_Hero[p]
    set HealthBars__HeroPcts[p]=- 1
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
        call SelectUnit(Game_Ctrl[p], true)
    endif
endfunction

function Ronda_Lanzar takes nothing returns nothing
    local integer p = 0
    set DevWave__First = null
    set DevWave__Count = 0
    call WaveAIClearTargets()
    loop
        exitwhen p > 11
        if Game_On[p] and Vidas_EnPartida[p] then
            call SetUnitInvulnerable(Game_Hero[p], false)
            call DevWave_AddTarget(Game_Hero[p])
        endif
        set p = p + 1
    endloop
    set Ronda_Descanso = false
    set Ronda_Activa = true
    call DevWave_Start(Ronda_Numero)
endfunction

function Ronda_Cuenta takes nothing returns nothing
    set Ronda_Resta = Ronda_Resta - 1
    if Ronda_Resta <= 0 then
        call PauseTimer(Ronda_Reloj)
        set Ronda_Numero = Ronda_Numero + 1
        call Ronda_Lanzar()
    endif
endfunction

// After the pairs' cycle, so that a death in the same instant as the finish has already left the count.
function Ronda_Reponer takes nothing returns nothing
    local integer p = 0
    call DestroyTimer(GetExpiredTimer())
    loop
        exitwhen p > 11
        if Game_On[p] and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            if not Vidas_EnPartida[p] then
                call Game_Volver(p)
            elseif UnitAlive(Game_Hero[p]) then
                call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
                call SetUnitState(Game_Ctrl[p], UNIT_STATE_MANA, GetUnitState(Game_Ctrl[p], UNIT_STATE_MAX_MANA))
                call SetUnitInvulnerable(Game_Hero[p], true)
            else
                call SetUnitInvulnerable(Game_Hero[p], true)
            endif
        endif
        set p = p + 1
    endloop
endfunction

function Ronda_Victoria takes nothing returns nothing
    local integer p = 0
    call DestroyTimer(GetExpiredTimer())
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            call CustomVictoryBJ(Player(p), true, true)
        endif
        set p = p + 1
    endloop
endfunction

function Ronda_AlTerminar takes nothing returns nothing
    if GetWaveEventWave() == Ronda_Wave then
        set Ronda_Descanso = true
        set Ronda_Resta = Ronda_DESCANSO
        if Ronda_Numero >= Ronda_TOTAL then
            call TimerStart(CreateTimer(), 2., false, function Ronda_Victoria)
        else
            call TimerStart(Ronda_Reloj, 1., true, function Ronda_Cuenta)
        endif
        call TimerStart(CreateTimer(), 0.25, false, function Ronda_Reponer)
    endif
endfunction

function DevWave_Arrancar takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    set Ronda_Reloj = CreateTimer()
    call RegisterWaveFinishEvent(function Ronda_AlTerminar)
    call Ronda_Lanzar()
endfunction

'''
ENTER_ANCHOR = 'function Game_Enter takes integer p returns nothing\n'
HERO_FROM = '    set Game_Hero[p]=CreateUnit(Player(p), id, GetLocationX(start), GetLocationY(start), 270)\n'
HERO_TO = '    set Game_Pair[p]=s__RapidPair_create(Game_Ctrl[p] , Game_Hero[p])\n'
ENTER_REST_OLD = '''    set Vidas_Actual[p] = Vidas_INICIO
    if Vidas_Orden == null then
        set Vidas_Orden = CreateTrigger()
        call TriggerAddAction(Vidas_Orden, function Vidas_AlOrdenar)
    endif
    call TriggerRegisterUnitEvent(Vidas_Orden, Game_Hero[p], EVENT_UNIT_ISSUED_ORDER)
    set Vidas_EnPartida[p] = true
    set Vidas_EnPie = Vidas_EnPie + 1
'''
ENTER_REST_NEW = '''    set Vidas_Actual[p] = Vidas_INICIO
    if Vidas_Orden == null then
        set Vidas_Orden = CreateTrigger()
        call TriggerAddAction(Vidas_Orden, function Vidas_AlOrdenar)
    endif
    call Game_Cuerpo(p , GetLocationX(start) , GetLocationY(start))
'''


if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    for old, new in ((GLOBAL_OLD, GLOBAL_NEW), ('constant integer Vidas_INICIO = 10\n', 'constant integer Vidas_INICIO = 3\n'),
                     (HUD_ANCHOR, HUD_FUNCS + HUD_ANCHOR), (HUD_TICK_OLD, HUD_TICK_NEW), (BIND_OLD, BIND_NEW),
                     (RETIRE_OLD, RETIRE_NEW), (DEFEAT_OLD, DEFEAT_NEW), (SHIELD_OLD, SHIELD_NEW)):
        s = base.once(s, old, new)

    s = base.once(s, '    function DevWave_Start takes nothing returns nothing\n', '    function DevWave_Start takes integer n returns nothing\n')
    s = base.once(s, 'set w=s__Wave_create(WaveDifficultyOwnerCap() , 15 , 0.25 , 1 , 1)\n',
                  'set w=s__Wave_create(WaveDifficultyOwnerCap() , 15 , 0.25 , n , Ronda_TOTAL)\n        set Ronda_Wave=w\n')
    assert s.count("WaveAddSlotExByPlayers(w , 'hpea' , DevWave__AMOUNT ,") == 1
    s = s.replace("WaveAddSlotExByPlayers(w , 'hpea' , DevWave__AMOUNT ,", "WaveAddSlotExByPlayers(w , 'hpea' , n ,")
    s = s.replace("WaveAddSlotExByPlayers(w , 'hfoo' , DevWave__AMOUNT ,", "WaveAddSlotExByPlayers(w , 'hfoo' , n ,")
    assert len(ARRANCAR_RE.findall(s)) == 1
    s = ARRANCAR_RE.sub('', s)

    a = s.index(HERO_FROM.replace('\n', base.N))
    b = s.index(HERO_TO.replace('\n', base.N), a) + len(HERO_TO) + 1
    body = s[a:b].replace('GetLocationX(start), GetLocationY(start)', 'x, y').replace(base.N, '\n')
    s = s[:a] + s[b:]
    s = base.once(s, ENTER_REST_OLD, ENTER_REST_NEW)
    # The black mask only opened while enemies were alive, so the rest went dark around the character. The whole map would draw the black minimap box.
    s = base.once(s, '    set Game_On[p]=true\n',
                  '    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(GetLocationX(start) - Ronda_VISION, GetLocationY(start) - Ronda_VISION, GetLocationX(start) + Ronda_VISION, GetLocationY(start) + Ronda_VISION), true, true))\n    set Game_On[p]=true\n')
    cuerpo = ('function Game_Cuerpo takes integer p,real x,real y returns nothing\n    local integer id= \'h005\'\n'
              '    if Hero_Choice[p] == 1 then\n        set id=\'h006\'\n    endif\n' + body +
              '    call TriggerRegisterUnitEvent(Vidas_Orden, Game_Hero[p], EVENT_UNIT_ISSUED_ORDER)\n'
              '    set Vidas_EnPartida[p] = true\n    set Vidas_EnPie = Vidas_EnPie + 1\nendfunction\n\n')
    s = base.once(s, ENTER_ANCHOR, cuerpo + ROUND_FUNCS + ENTER_ANCHOR)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok')
