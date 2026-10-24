globals
//globals from Definitions:
constant boolean LIBRARY_Definitions=true
//endglobals from Definitions
//globals from Consumers:
constant boolean LIBRARY_Consumers=true
//endglobals from Consumers


//JASSHelper struct globals:
constant integer si__S=1
integer si__S_F=0
integer si__S_I=0
integer array si__S_V
trigger array st___prototype1

endglobals


//Generated allocator of S
function s__S__allocate takes nothing returns integer
 local integer this=si__S_F
    if (this!=0) then
        set si__S_F=si__S_V[this]
    else
        set si__S_I=si__S_I+1
        set this=si__S_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__S_V[this]=-1
 return this
endfunction

//Generated destructor of S
function s__S_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__S_V[this]!=-1) then
        return
    endif
    set si__S_V[this]=si__S_F
    set si__S_F=this
endfunction
function sc___prototype1_execute takes integer i returns nothing

    call TriggerExecute(st___prototype1[i])
endfunction
function sc___prototype1_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype1[i])

endfunction

function Definitions__Captured takes nothing returns nothing
endfunction

    function s__S_onPeriod takes nothing returns nothing
    endfunction
//Implemented from module Outer:
    function s__S_launch takes nothing returns nothing
        call Definitions__Captured()
        call s__S_onPeriod()
    endfunction
    function s__S_Inner___onInit takes nothing returns nothing
        call s__S_launch()
    endfunction
    function s__S__get_value takes integer this returns integer
        return 1
    endfunction
    function s__S__set_value takes integer this,integer v returns nothing
    endfunction
    function s__S_make takes nothing returns integer
        return s__S__allocate()
    endfunction
    function s__S_start takes nothing returns nothing
        local integer s= (s__S__allocate()) // INLINED!!
        local integer n= s__S__get_value(s)
        call s__S__set_value(s,2)
        call TriggerExecute(st___prototype1[(1)]) // INLINED!!
        call s__S_onPeriod()
        call s__S_deallocate((s__S__allocate())) // INLINED!!
        call s__S_launch()
        call s__S_deallocate(s)
    endfunction

//textmacro instance: DECL("MacroRun")
function MacroRun takes nothing returns nothing
endfunction
//end of: DECL("MacroRun")
function GlobalCallback takes nothing returns nothing
endfunction
function main takes nothing returns nothing
    call s__S_start()
    call MacroRun()
    call ExecuteFunc("GlobalCallback")

    call ExecuteFunc("jasshelper__init2004")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa___prototype1_GlobalCallback takes nothing returns boolean

    return true
endfunction
function sa___prototype1_s__S_onPeriod takes nothing returns boolean

    return true
endfunction

function jasshelper__init2004 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_GlobalCallback)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_GlobalCallback))
    set st___prototype1[2]=CreateTrigger()
    call TriggerAddAction(st___prototype1[2],function sa___prototype1_s__S_onPeriod)
    call TriggerAddCondition(st___prototype1[2],Condition(function sa___prototype1_s__S_onPeriod))


call ExecuteFunc("s__S_Inner___onInit")
//------------------------------------

endfunction

