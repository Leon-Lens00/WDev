globals


//JASSHelper struct globals:
constant integer si__Ordered=1
integer si__Ordered_F=0
integer si__Ordered_I=0
integer array si__Ordered_V
integer array si__Ordered_type
trigger array st__Ordered_onDestroy
trigger array st__Ordered__lessthan
constant integer si__Value=2
integer f__arg_integer1
integer f__arg_this
boolean f__result_boolean

endglobals


//Generated method caller for Ordered._lessthan
function sc__Ordered__lessthan takes integer this,integer dummy returns boolean
    set f__arg_this=this
    set f__arg_integer1=dummy
  if (si__Ordered_type[this]==si__Ordered_type[dummy]) then
    call TriggerEvaluate(st__Ordered__lessthan[si__Ordered_type[this]])
  else
    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Warning: "+I2S(si__Ordered_type[this])+" vs "+I2S(si__Ordered_type[dummy]))
    return false
  endif
 return f__result_boolean
endfunction

//Generated method executor for Ordered._lessthan
function sx__Ordered__lessthan takes integer this,integer dummy returns nothing
    set f__arg_this=this
    set f__arg_integer1=dummy
    call TriggerExecute(st__Ordered__lessthan[si__Ordered_type[this]])
endfunction
//Generated destructor of Ordered
function sc__Ordered_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Ordered_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__Ordered_onDestroy[si__Ordered_type[this]])
    set si__Ordered_V[this]=si__Ordered_F
    set si__Ordered_F=this
endfunction

//Generated method caller for Value._lessthan
function sc__Value__lessthan takes integer this,integer other returns boolean
return false
endfunction

//Generated allocator of Value
function s__Value__allocate takes nothing returns integer
 local integer kthis
 local integer this=si__Ordered_F
    if (this!=0) then
        set si__Ordered_F=si__Ordered_V[this]
    else
        set si__Ordered_I=si__Ordered_I+1
        set this=si__Ordered_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Ordered_type[this]=2
    set kthis=this

    set si__Ordered_V[this]=-1
 return this
endfunction


function s__Value__lessthan takes integer this,integer other returns boolean
return false
endfunction
function Run takes integer a,integer b returns boolean
return s__Value__lessthan(a,b)
endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init2991")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa__Value__lessthan takes nothing returns boolean
local integer this=f__arg_this
local integer other=f__arg_integer1
set f__result_boolean= false
   return true
endfunction

function jasshelper__init2991 takes nothing returns nothing
    set st__Ordered__lessthan[2]=CreateTrigger()
    call TriggerAddCondition(st__Ordered__lessthan[2],Condition( function sa__Value__lessthan))
    call TriggerAddAction(st__Ordered__lessthan[2], function sa__Value__lessthan)
    set st__Ordered_onDestroy[2]=null



endfunction

