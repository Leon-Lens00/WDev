library RFControls requires RFBurstPair
    globals
        private trigger selection = null
        private timer camera = null
    endglobals

    private function SelectLogical takes nothing returns boolean
        // Local UI only: no handle creation or synchronized state assignment.
        if GetTriggerUnit() == RB_GetActor() and GetLocalPlayer() == GetTriggerPlayer() then
            call ClearSelection()
            call SelectUnit(RB_GetController(),true)
        endif
        return false
    endfunction

    private function Follow takes nothing returns nothing
        local unit u = RB_GetActor()
        if GetUnitTypeId(u) != 0 and GetLocalPlayer() == GetOwningPlayer(u) then
            call PanCameraToTimed(GetUnitX(u),GetUnitY(u),.1)
        endif
        set u = null
    endfunction

    function RF_StartControls takes nothing returns nothing
        if selection == null then
            set selection = CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(selection,Player(0),EVENT_PLAYER_UNIT_SELECTED,null)
            call TriggerAddCondition(selection,Condition(function SelectLogical))
            set camera = CreateTimer()
            call TimerStart(camera,.1,true,function Follow)
        endif
        if GetLocalPlayer() == Player(0) then
            call ClearSelection()
            call SelectUnit(RB_GetController(),true)
            call PanCameraToTimed(GetUnitX(RB_GetActor()),GetUnitY(RB_GetActor()),0.)
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1650.,0.)
        endif
    endfunction
endlibrary
