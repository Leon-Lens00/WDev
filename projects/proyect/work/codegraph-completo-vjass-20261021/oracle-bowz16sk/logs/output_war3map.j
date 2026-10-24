globals


//JASSHelper struct globals:
constant integer si__I=1
integer si__I_F=0
integer si__I_I=0
integer array si__I_V
integer array si__I_type
trigger array st__I_onDestroy
trigger array st__I__lessthan
constant integer si__S=2
integer f__arg_integer1
integer f__arg_this
boolean f__result_boolean

endglobals


//Generated method caller for I._lessthan
function sc__I__lessthan takes integer this,integer dummy returns boolean
    set f__arg_this=this
    set f__arg_integer1=dummy
  if (si__I_type[this]==si__I_type[dummy]) then
    call TriggerEvaluate(st__I__lessthan[si__I_type[this]])
  else
    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Warning: "+I2S(si__I_type[this])+" vs "+I2S(si__I_type[dummy]))
    return false
  endif
 return f__result_boolean
endfunction

//Generated method executor for I._lessthan
function sx__I__lessthan takes integer this,integer dummy returns nothing
    set f__arg_this=this
    set f__arg_integer1=dummy
    call TriggerExecute(st__I__lessthan[si__I_type[this]])
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

//Generated method caller for S._lessthan
function sc__S__lessthan takes integer this,integer other returns boolean
return true
endfunction

//Generated allocator of S
function s__S__allocate takes nothing returns integer
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


function s__S__lessthan takes integer this,integer other returns boolean
return true
endfunction
function Run takes integer a,integer b returns boolean
return a < 0 or s__S__lessthan(a,b)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init5510")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa__S__lessthan takes nothing returns boolean
local integer this=f__arg_this
local integer other=f__arg_integer1
set f__result_boolean= true
   return true
endfunction

function jasshelper__init5510 takes nothing returns nothing
    set st__I__lessthan[2]=CreateTrigger()
    call TriggerAddCondition(st__I__lessthan[2],Condition( function sa__S__lessthan))
    call TriggerAddAction(st__I__lessthan[2], function sa__S__lessthan)
    set st__I_onDestroy[2]=null



endfunction

