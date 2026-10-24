library X3BusterDemo initializer Init requires X3Buster, RapidFireDemo, SpellEffectEvent
private function Cast takes nothing returns nothing
    local RapidPair pair = RapidPair.fromController(GetTriggerUnit())
    local X3Buster shot
    local integer mode = 0
    if pair != 0 then
        if GetSpellAbilityId() == 'Ax3s' then
            set mode = 1
        endif
        set shot = X3Buster.fire(pair.actor,GetSpellTargetX(),GetSpellTargetY(),mode)
        if not pair.firing then
            call SetUnitFacingTimed(pair.actor,Atan2(GetSpellTargetY()-GetUnitY(pair.actor),GetSpellTargetX()-GetUnitX(pair.actor))*bj_RADTODEG,0.)
            call SetUnitAnimation(pair.actor,"attack")
        endif
    endif
endfunction
private function Init takes nothing returns nothing
    call RegisterSpellEffectEvent('Ax3c',function Cast)
    call RegisterSpellEffectEvent('Ax3s',function Cast)
endfunction
endlibrary
