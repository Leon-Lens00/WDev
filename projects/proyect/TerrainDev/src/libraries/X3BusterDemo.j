library X3BusterDemo initializer Init requires X3Buster, RapidFireDemo, SpellEffectEvent
// Compatibility fixtures may opt into GIF; delivered W/E use the USA profile.
struct X3Demo extends array
    static integer profile = X3Buster.ORIGINAL
endstruct
private function Cast takes nothing returns nothing
    local RapidPair pair = RapidPair.fromController(GetTriggerUnit())
    local X3Buster shot
    local integer mode = 0
    local integer profile = X3Demo.profile
    if pair != 0 then
        if GetSpellAbilityId() == 'Ax3s' or GetSpellAbilityId() == 'Ax3z' then
            set mode = 1
        endif
        if GetSpellAbilityId() == 'Ax3z' then
            set profile = X3Buster.ZERO_PROJECT
        endif
        set shot = X3Buster.fireProfile(pair.actor,GetSpellTargetX(),GetSpellTargetY(),mode,profile)
        if not pair.firing then
            call SetUnitFacingTimed(pair.actor,Atan2(GetSpellTargetY()-GetUnitY(pair.actor),GetSpellTargetX()-GetUnitX(pair.actor))*bj_RADTODEG,0.)
            call SetUnitAnimation(pair.actor,"attack")
        endif
    endif
endfunction
private function Init takes nothing returns nothing
    call RegisterSpellEffectEvent('Ax3c',function Cast)
    call RegisterSpellEffectEvent('Ax3s',function Cast)
    call RegisterSpellEffectEvent('Ax3z',function Cast)
endfunction
endlibrary
