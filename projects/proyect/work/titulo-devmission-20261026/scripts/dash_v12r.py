"""Dev Mission v12r (31/10/2026): the dash of Missile (GroundCollision 1.2.0, GroundMotion 1.1.0, RapidFire 1.9.1).

The map's script is compiled, so this is the delivered diff by hand, on top of the 'down' pair of v12n. The dash steps at the head of
the tick loop, before the branches of death and 'down'. Only the actor moves; the controller casts and pays.

Usage: dash_v12r.py IN_J OUT_J
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

COLLISION_OLD = "                    if u != source and s__GroundCollision_alive(u) and IsUnitEnemy(u, owner) and not IsUnitType(u, UNIT_TYPE_FLYING) and GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst' and GetUnitTypeId(u) != 'rfct' then\n"
COLLISION_NEW = '                    if s__GroundCollision_isTarget(u , source , owner) then\n'
IS_TARGET_ANCHOR = '    function s__GroundCollision_touches takes unit u,real px,real py,real radius returns boolean\n'
IS_TARGET = """    // Valid ground enemy of owner: excludes the source, flyers, dummies and proxies.
    function s__GroundCollision_isTarget takes unit u,unit source,player owner returns boolean
        return u != source and s__GroundCollision_alive(u) and IsUnitEnemy(u, owner) and not IsUnitType(u, UNIT_TYPE_FLYING) and GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst' and GetUnitTypeId(u) != 'rfct'
    endfunction

"""
MOTION_GLOBALS_OLD = 'real array s__GroundMotion_goalY\n'
MOTION_GLOBALS_NEW = MOTION_GLOBALS_OLD + '''boolean array s__GroundMotion_dashing
real array s__GroundMotion_dashAngle
real array s__GroundMotion_dashLeft
real array s__GroundMotion_dashSpeed
'''
PAIR_GLOBALS_OLD = 'constant real s__RapidPair_INTERVAL= 0.25\n'
PAIR_GLOBALS_NEW = PAIR_GLOBALS_OLD + '''constant real s__RapidPair_DASH_DISTANCE= 450.
constant real s__RapidPair_DASH_TIME= 0.5
constant real s__RapidPair_DASH_ANIMATION_SCALE= 2.5
constant real s__RapidPair_DASH_VISUAL_SCALE= 1.
integer s__RapidPair_dashes= 0
integer s__RapidPair_dashWalls= 0
integer s__RapidPair_dashTouches= 0
group s__RapidPair_dashEnum= CreateGroup()
unit array s__RapidPair_dashCarrier
effect array s__RapidPair_dashEffect
group array s__RapidPair_dashTouched
'''
MOTION_CREATE_OLD = '''        set s__GroundMotion_hasGoal[this]=false
        set s__GroundMotion_speed[this]=350.
'''
MOTION_CREATE_NEW = '''        set s__GroundMotion_hasGoal[this]=false
        set s__GroundMotion_dashing[this]=false
        set s__GroundMotion_speed[this]=350.
'''
ENTER_OLD = '''            set s__GroundMotion_instantTransitions=s__GroundMotion_instantTransitions + 1
        endif
    endfunction

'''
ENTER_NEW = '''            set s__GroundMotion_instantTransitions=s__GroundMotion_instantTransitions + 1
        else
            // Not travelling: a goal left from an arrived walk must not be resumed.
            set s__GroundMotion_hasGoal[this]=false
        endif
    endfunction

    // Forced straight displacement while artificial. It has priority over the walking
    // goal, which is kept, and ignores units; ground and obstacles end it.
    function s__GroundMotion_dash takes integer this,real angle,real distance,real duration returns nothing
        set s__GroundMotion_dashing[this]=true
        set s__GroundMotion_blocked[this]=false
        set s__GroundMotion_dashAngle[this]=angle
        set s__GroundMotion_dashLeft[this]=distance
        set s__GroundMotion_dashSpeed[this]=distance / duration
    endfunction

    function s__GroundMotion_stopDash takes integer this returns nothing
        set s__GroundMotion_dashing[this]=false
    endfunction

    function s__GroundMotion_dashStep takes integer this,real dt returns nothing
        local real ax= GetUnitX(s__GroundMotion_body[this])
        local real ay= GetUnitY(s__GroundMotion_body[this])
        local real advance= RMinBJ(s__GroundMotion_dashSpeed[this] * dt, s__GroundMotion_dashLeft[this])
        set s__GroundMotion_blocked[this]=s__GroundCollision_trace(ax , ay , ax + Cos(s__GroundMotion_dashAngle[this]) * advance , ay + Sin(s__GroundMotion_dashAngle[this]) * advance , s__GroundMotion_radius[this] , s__GroundMotion_body[this] , GetOwningPlayer(s__GroundMotion_body[this]) , false) != 0
        call SetUnitX(s__GroundMotion_body[this], s__GroundCollision_x)
        call SetUnitY(s__GroundMotion_body[this], s__GroundCollision_y)
        set s__GroundMotion_xySteps=s__GroundMotion_xySteps + 1
        set s__GroundMotion_dashLeft[this]=s__GroundMotion_dashLeft[this] - advance
        if s__GroundMotion_blocked[this] or s__GroundMotion_dashLeft[this] <= 0.001 then
            set s__GroundMotion_dashing[this]=false
        endif
    endfunction

'''
STEP_OLD = '''        if not s__GroundMotion_artificial[this] or not s__GroundMotion_hasGoal[this] or not s__GroundCollision_alive(s__GroundMotion_body[this]) then
            return
        endif
'''
STEP_NEW = '''        if not s__GroundMotion_artificial[this] or not s__GroundCollision_alive(s__GroundMotion_body[this]) then
            return
        endif
        if s__GroundMotion_dashing[this] then
            call s__GroundMotion_dashStep(this,dt)
            return
        endif
        if not s__GroundMotion_hasGoal[this] then
            return
        endif
'''
LEAVE_OLD = '''            set s__GroundMotion_artificial[this]=false
            set s__GroundMotion_blocked[this]=false
            call SetUnitPathing(s__GroundMotion_body[this], true)
'''
LEAVE_NEW = '''            set s__GroundMotion_artificial[this]=false
            set s__GroundMotion_blocked[this]=false
            set s__GroundMotion_dashing[this]=false
            call SetUnitPathing(s__GroundMotion_body[this], true)
'''
MODEL_ANCHOR = '    function s__RapidBolt_shootFamily takes unit caster,real px,real py,playercolor color,integer f returns integer\n'
MODEL = '''    // Valiant Charge of the dash, same hue rule as Windwalk (assets/valiant-colores).
    function s__RapidBolt_dashModelOf takes playercolor value,integer f returns string
        if f == s__RapidBolt_SHOTS or f == s__RapidBolt_SHOTS_II then
            return "ValiantCharge\\\\Valiant Charge " + s__RapidBolt_originalColor(value) + ".mdx"
        endif
        return "ValiantCharge\\\\Valiant Charge " + s__RapidBolt_firebrandColor(value) + ".mdx"
    endfunction

'''
FINISH_OLD = '''            call s__GroundMotion_leave(s__RapidPair_motion[this],resume)
            call s__RapidPair_hideWalk(this)
        endif
    endfunction
'''
FINISH_NEW = '''            // A dash in course keeps the artificial mode and closes it itself.
            if not s__GroundMotion_dashing[s__RapidPair_motion[this]] then
                call s__GroundMotion_leave(s__RapidPair_motion[this],resume)
                call s__RapidPair_hideWalk(this)
            endif
        endif
    endfunction
    // Future dash damage goes here: called once per dash for each enemy touched.
    function s__RapidPair_onDashTouch takes integer this,unit target returns nothing
        set s__RapidPair_dashTouches=s__RapidPair_dashTouches + 1
    endfunction
    function s__RapidPair_sweepDash takes integer this returns nothing
        local real x= GetUnitX(s__RapidPair_actor[this])
        local real y= GetUnitY(s__RapidPair_actor[this])
        local player owner= GetOwningPlayer(s__RapidPair_actor[this])
        local unit u
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(s__RapidPair_dashEnum, x, y, s__GroundMotion_radius[s__RapidPair_motion[this]] + 256., null)
        loop
            set u=FirstOfGroup(s__RapidPair_dashEnum)
            exitwhen u == null
            call GroupRemoveUnit(s__RapidPair_dashEnum, u)
            if s__GroundCollision_isTarget(u , s__RapidPair_actor[this] , owner) and not IsUnitInGroup(u, s__RapidPair_dashTouched[this]) and s__GroundCollision_touches(u , x , y , s__GroundMotion_radius[s__RapidPair_motion[this]]) then
                call GroupAddUnit(s__RapidPair_dashTouched[this], u)
                call s__RapidPair_onDashTouch(this,u)
            endif
        endloop
        set s__GroundCollision_shaped=false
        set owner=null
    endfunction
    // The death flash stays where the dash ended; the recycler keeps the carrier
    // long enough for it to play.
    function s__RapidPair_hideDash takes integer this returns nothing
        if s__RapidPair_dashEffect[this] != null then
            call DestroyEffect(s__RapidPair_dashEffect[this])
            call RecycleMissile(s__RapidPair_dashCarrier[this])
            set s__RapidPair_dashEffect[this]=null
            set s__RapidPair_dashCarrier[this]=null
        endif
    endfunction
    function s__RapidPair_endDash takes integer this,boolean resume returns nothing
        if s__RapidPair_dashEffect[this] != null then
            call s__RapidPair_hideDash(this)
            call s__GroundMotion_stopDash(s__RapidPair_motion[this])
            if not s__RapidPair_firing[this] then
                if GetUnitTypeId(s__RapidPair_actor[this]) != 0 then
                    call SetUnitTimeScale(s__RapidPair_actor[this], 1.)
                endif
                if s__GroundCollision_alive(s__RapidPair_actor[this]) then
                    call ResetUnitAnimation(s__RapidPair_actor[this])
                endif
                call s__GroundMotion_leave(s__RapidPair_motion[this],resume)
                call s__RapidPair_hideWalk(this)
            endif
        endif
    endfunction
    // Direct dash, no target: never touches orders, burst or facing. The effect rides
    // its own dummy turned to the travel direction, so it points back on a back dash.
    // A dash in course is replaced, so a press never spends mana for nothing.
    function s__RapidPair_dash takes integer this,boolean backward returns nothing
        local real x= GetUnitX(s__RapidPair_actor[this])
        local real y= GetUnitY(s__RapidPair_actor[this])
        local real angle= GetUnitFacing(s__RapidPair_actor[this]) * bj_DEGTORAD
        if not s__GroundCollision_alive(s__RapidPair_actor[this]) then
            return
        endif
        if s__RapidPair_firing[this] then
            set angle=Atan2(s__RapidPair_aimY[this] - y, s__RapidPair_aimX[this] - x)
        endif
        if backward then
            set angle=angle + bj_PI
        endif
        call s__RapidPair_hideDash(this)
        set s__RapidPair_dashes=s__RapidPair_dashes + 1
        call GroupClear(s__RapidPair_dashTouched[this])
        call s__GroundMotion_enter(s__RapidPair_motion[this])
        call s__GroundMotion_dash(s__RapidPair_motion[this],angle,s__RapidPair_DASH_DISTANCE,s__RapidPair_DASH_TIME)
        call s__RapidPair_showWalk(this)
        if not s__RapidPair_firing[this] then
            call SetUnitTimeScale(s__RapidPair_actor[this], s__RapidPair_DASH_ANIMATION_SCALE)
        endif
        call SetUnitAnimation(s__RapidPair_actor[this], "attack")
        set s__RapidPair_dashCarrier[this]=GetRecycledMissile(x , y , 0. , angle * bj_RADTODEG)
        call SetUnitScale(s__RapidPair_dashCarrier[this], s__RapidPair_DASH_VISUAL_SCALE, s__RapidPair_DASH_VISUAL_SCALE, s__RapidPair_DASH_VISUAL_SCALE)
        set s__RapidPair_dashEffect[this]=AddSpecialEffectTarget(s__RapidBolt_dashModelOf(s__RapidPair_color(this) , s__RapidPair_family[this]), s__RapidPair_dashCarrier[this], "origin")
    endfunction
    function s__RapidPair_stepDash takes integer this returns nothing
        local real x= GetUnitX(s__RapidPair_actor[this])
        local real y= GetUnitY(s__RapidPair_actor[this])
        // A body can count as dead and keep its pair (Reincarnation in Dev Mission):
        // the dash ends here, in the tick, whoever handles the fall.
        if not s__GroundCollision_alive(s__RapidPair_actor[this]) then
            call s__RapidPair_endDash(this,false)
            return
        endif
        call s__GroundMotion_step(s__RapidPair_motion[this],1. / 32.)
        // The aim travels with the actor: facing and burst direction stay the same.
        set s__RapidPair_aimX[this]=s__RapidPair_aimX[this] + GetUnitX(s__RapidPair_actor[this]) - x
        set s__RapidPair_aimY[this]=s__RapidPair_aimY[this] + GetUnitY(s__RapidPair_actor[this]) - y
        call SetUnitX(s__RapidPair_dashCarrier[this], GetUnitX(s__RapidPair_actor[this]))
        call SetUnitY(s__RapidPair_dashCarrier[this], GetUnitY(s__RapidPair_actor[this]))
        call s__RapidPair_sweepDash(this)
        if not s__GroundMotion_dashing[s__RapidPair_motion[this]] then
            if s__GroundMotion_blocked[s__RapidPair_motion[this]] then
                set s__RapidPair_dashWalls=s__RapidPair_dashWalls + 1
            endif
            call s__RapidPair_endDash(this,true)
        endif
    endfunction
'''
CREATE_OLD = '''        set s__RapidPair_aimY[this]=GetUnitY(visible)
        set s__RapidPair_reset[this]=NewTimerEx(this)
'''
CREATE_NEW = '''        set s__RapidPair_aimY[this]=GetUnitY(visible)
        set s__RapidPair_dashTouched[this]=CreateGroup()
        set s__RapidPair_reset[this]=NewTimerEx(this)
'''
DESTROY_OLD = '''        call s__RapidPair_finish(this,false)
        call s__GroundMotion_destroy(s__RapidPair_motion[this])
'''
DESTROY_NEW = '''        call s__RapidPair_endDash(this,false)
        call s__RapidPair_finish(this,false)
        call s__GroundMotion_destroy(s__RapidPair_motion[this])
        call DestroyGroup(s__RapidPair_dashTouched[this])
        set s__RapidPair_dashTouched[this]=null
'''
TICK_OLD = '''            set following=s__RapidPair_next[this]
            if GetUnitTypeId(s__RapidPair_actor[this]) == 0 or not s__GroundCollision_alive(s__RapidPair_controller[this]) then
'''
TICK_NEW = '''            set following=s__RapidPair_next[this]
            if s__GroundMotion_dashing[s__RapidPair_motion[this]] then
                call s__RapidPair_stepDash(this)
            endif
            if GetUnitTypeId(s__RapidPair_actor[this]) == 0 or not s__GroundCollision_alive(s__RapidPair_controller[this]) then
'''
BURST_OLD = '''                if s__RapidPair_firing[this] then
                    call s__GroundMotion_step(s__RapidPair_motion[this],1. / 32.)
'''
BURST_NEW = '''                if s__RapidPair_firing[this] then
                    if not s__GroundMotion_dashing[s__RapidPair_motion[this]] then
                        call s__GroundMotion_step(s__RapidPair_motion[this],1. / 32.)
                    endif
'''
SPELL_ANCHOR = '    function s__RapidPair_selected takes nothing returns nothing\n'
SPELL = '''    function s__RapidPair_dashSpell takes nothing returns nothing
        local integer this= s__RapidPair_fromController(GetTriggerUnit())
        if this != 0 then
            call s__RapidPair_dash(this,GetSpellAbilityId() == 'Ard2')
        endif
    endfunction
'''
REGISTER_OLD = "        call RegisterSpellEffectEvent('Arp3' , function s__RapidPair_spell)\n"
REGISTER_NEW = REGISTER_OLD + """        call RegisterSpellEffectEvent('Ard1' , function s__RapidPair_dashSpell)
        call RegisterSpellEffectEvent('Ard2' , function s__RapidPair_dashSpell)
"""
BODY_OLD = "    call UnitAddAbility(Game_Ctrl[p], 'Arp3')\n"
BODY_NEW = BODY_OLD + """    call UnitAddAbility(Game_Ctrl[p], 'Ard1')
    call UnitAddAbility(Game_Ctrl[p], 'Ard2')
"""

if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    for old, new in ((COLLISION_OLD, COLLISION_NEW), (IS_TARGET_ANCHOR, IS_TARGET + IS_TARGET_ANCHOR), (MOTION_GLOBALS_OLD, MOTION_GLOBALS_NEW),
                     (PAIR_GLOBALS_OLD, PAIR_GLOBALS_NEW), (MOTION_CREATE_OLD, MOTION_CREATE_NEW), (ENTER_OLD, ENTER_NEW), (STEP_OLD, STEP_NEW),
                     (LEAVE_OLD, LEAVE_NEW), (MODEL_ANCHOR, MODEL + MODEL_ANCHOR), (FINISH_OLD, FINISH_NEW), (CREATE_OLD, CREATE_NEW),
                     (DESTROY_OLD, DESTROY_NEW), (TICK_OLD, TICK_NEW), (BURST_OLD, BURST_NEW), (SPELL_ANCHOR, SPELL + SPELL_ANCHOR),
                     (REGISTER_OLD, REGISTER_NEW), (BODY_OLD, BODY_NEW)):
        s = base.once(s, old, new)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok')
