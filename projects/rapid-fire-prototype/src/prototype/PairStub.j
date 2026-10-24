library RFBurstPair requires Missiles
    // RED-only public single-pair API. No emitter, damage, animation or mover.
    // Caller owns units and observer. Dispose releases only this module's hook.
    globals
        private unit actor = null
        private unit controller = null
        private trigger castHook = null
        private trigger observer = null
        private Missiles shot = 0
        private unit shotSource = null
        private real shotX = 0.
        private real shotY = 0.
    endglobals

    // Future GREEN contract: after a real launch, populate these public views and
    // TriggerEvaluate(observer) synchronously ONCE per emission. Views are valid
    // during that callback; observers must not retain a recycled Missiles ID.
    function RB_GetShotMissile takes nothing returns Missiles
        return shot
    endfunction

    function RB_GetShotSource takes nothing returns unit
        return shotSource
    endfunction

    function RB_GetShotX takes nothing returns real
        return shotX
    endfunction

    function RB_GetShotY takes nothing returns real
        return shotY
    endfunction

    private function OnCast takes nothing returns boolean
        // Deliberately no positive behavior: a valid native event reaches this
        // boundary but causes NO shot pulse, missile, damage or unit mutation.
        return false
    endfunction

    function RB_Dispose takes nothing returns nothing
        if castHook != null then
            call DestroyTrigger(castHook)
        endif
        set castHook = null
        set observer = null
        set actor = null
        set controller = null
        set shot = 0
        set shotSource = null
        set shotX = 0.
        set shotY = 0.
    endfunction

    function RB_InitializePair takes unit visible, unit logical, trigger shotObserver returns boolean
        if castHook != null or visible == null or logical == null or visible == logical or shotObserver == null then
            return false
        endif
        if GetUnitTypeId(visible) != 'o000' or GetUnitTypeId(logical) != 'o001' or GetUnitAbilityLevel(logical,'A00G') != 1 then
            return false
        endif
        set actor = visible
        set controller = logical
        set observer = shotObserver
        set castHook = CreateTrigger()
        call TriggerRegisterUnitEvent(castHook,controller,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(castHook,Condition(function OnCast))
        return true
    endfunction
endlibrary
