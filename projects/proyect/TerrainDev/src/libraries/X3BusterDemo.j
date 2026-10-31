library X3BusterDemo initializer Init requires X3Buster, X3Charge, RapidFireDemo, SpellEffectEvent
// Compatibility fixtures may opt into GIF; delivered W/E use the USA profile.
struct X3Demo extends array
    static integer profile = X3Buster.ORIGINAL
endstruct
private function Face takes RapidPair pair, boolean turn returns nothing
    if not pair.firing then
        if turn then
            call SetUnitFacingTimed(pair.actor,Atan2(GetSpellTargetY()-GetUnitY(pair.actor),GetSpellTargetX()-GetUnitX(pair.actor))*bj_RADTODEG,0.)
        endif
        call SetUnitAnimation(pair.actor,"attack")
    endif
endfunction
// W charges USA and R charges Zero Project (X3Charge toggle); E stays discrete.
private function Cast takes nothing returns nothing
    local RapidPair pair = RapidPair.fromController(GetTriggerUnit())
    local integer id = GetSpellAbilityId()
    local integer profile = X3Demo.profile
    local integer result
    if pair != 0 then
        if id == 'Ax3s' then
            call X3Buster.fireProfile(pair.actor,GetSpellTargetX(),GetSpellTargetY(),1,profile)
            call Face(pair,true)
        else
            if id == 'Ax3z' then
                set profile = X3Buster.ZERO_PROJECT
            endif
            set result = X3Charge.press(pair,profile,GetSpellTargetX(),GetSpellTargetY())
            if result == X3Charge.FIRED then
                call Face(pair,true)
            elseif result == X3Charge.SECOND then
                // The second pulse keeps the launch origin and direction.
                call Face(pair,false)
            endif
        endif
    endif
endfunction
private function Init takes nothing returns nothing
    call RegisterSpellEffectEvent('Ax3c',function Cast)
    call RegisterSpellEffectEvent('Ax3s',function Cast)
    call RegisterSpellEffectEvent('Ax3z',function Cast)
endfunction
endlibrary
