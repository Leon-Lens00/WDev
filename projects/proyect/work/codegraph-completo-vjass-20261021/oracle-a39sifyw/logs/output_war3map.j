globals


//JASSHelper struct globals:
constant integer si__I=1
integer si__I_F=0
integer si__I_I=0
integer array si__I_V
integer array si__I_type
trigger array st__I_onDestroy
trigger array st__I_tick
constant integer si__A=2
constant integer si__B=3
integer f__arg_this

endglobals


//Generated method caller for I.tick
function sc__I_tick takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__I_tick[si__I_type[this]])
endfunction

//Generated method executor for I.tick
function sx__I_tick takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__I_tick[si__I_type[this]])
endfunction
//Generated destructor of I
function sc__I_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__I_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__I_onDestroy[si__I_type[this]])
    set si__I_V[this]=si__I_F
    set si__I_F=this
endfunction

//Generated method caller for B.tick
function sc__B_tick takes integer this returns nothing
endfunction

//Generated allocator of B
function s__B__allocate takes nothing returns integer
 local integer kthis
 local integer this=si__I_F
    if (this!=0) then
        set si__I_F=si__I_V[this]
    else
        set si__I_I=si__I_I+1
        set this=si__I_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__I_type[this]=3
    set kthis=this

    set si__I_V[this]=-1
 return this
endfunction


//Generated method caller for A.tick
function sc__A_tick takes integer this returns nothing
endfunction

//Generated allocator of A
function s__A__allocate takes nothing returns integer
 local integer kthis
 local integer this=si__I_F
    if (this!=0) then
        set si__I_F=si__I_V[this]
    else
        set si__I_I=si__I_I+1
        set this=si__I_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__I_type[this]=2
    set kthis=this

    set si__I_V[this]=-1
 return this
endfunction


function s__A_tick takes integer this returns nothing
endfunction
function s__B_tick takes integer this returns nothing
endfunction
function Run takes integer value returns nothing
call sc__I_tick(value)
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init5762")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa__B_tick takes nothing returns boolean
local integer this=f__arg_this
   return true
endfunction
function sa__A_tick takes nothing returns boolean
local integer this=f__arg_this
   return true
endfunction

function jasshelper__init5762 takes nothing returns nothing
    set st__I_tick[3]=CreateTrigger()
    call TriggerAddCondition(st__I_tick[3],Condition( function sa__B_tick))
    call TriggerAddAction(st__I_tick[3], function sa__B_tick)
    set st__I_onDestroy[3]=null
    set st__I_tick[2]=CreateTrigger()
    call TriggerAddCondition(st__I_tick[2],Condition( function sa__A_tick))
    call TriggerAddAction(st__I_tick[2], function sa__A_tick)
    set st__I_onDestroy[2]=null



endfunction

