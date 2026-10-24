globals


//JASSHelper struct globals:
constant integer si__Base=1
integer si__Base_F=0
integer si__Base_I=0
integer array si__Base_V
constant integer si__Child=2
integer array si__Base_type
trigger array st__Base_onDestroy
integer f__arg_this

endglobals


//Generated method caller for Base.onDestroy
function sc__Base_onDestroy takes integer this returns nothing
endfunction

//Generated allocator of Base
function s__Base__allocate takes nothing returns integer
 local integer this=si__Base_F
    if (this!=0) then
        set si__Base_F=si__Base_V[this]
    else
        set si__Base_I=si__Base_I+1
        set this=si__Base_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Base_type[this]=1
    set si__Base_V[this]=-1
 return this
endfunction

//Generated destructor of Base
function sc__Base_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Base_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__Base_onDestroy[si__Base_type[this]])
    set si__Base_V[this]=si__Base_F
    set si__Base_F=this
endfunction

//Generated method caller for Child.onDestroy
function sc__Child_onDestroy takes integer this returns nothing
endfunction

//Generated allocator of Child
function s__Child__allocate takes nothing returns integer
 local integer this=s__Base__allocate()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Base_type[this]=2
    set kthis=this

 return this
endfunction


function s__Base_onDestroy takes integer this returns nothing
endfunction
function s__Child_onDestroy takes integer this returns nothing
endfunction
function Run takes nothing returns nothing
local integer b=s__Child__allocate()
call sc__Base_deallocate(b)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init2991")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa__Base_onDestroy takes nothing returns boolean
local integer this=f__arg_this
   return true
endfunction
function sa__Child_onDestroy takes nothing returns boolean
local integer this=f__arg_this
    set f__arg_this=this
   return true
endfunction

function jasshelper__init2991 takes nothing returns nothing
    set st__Base_onDestroy[1]=CreateTrigger()
    call TriggerAddCondition(st__Base_onDestroy[1],Condition( function sa__Base_onDestroy))
    set st__Base_onDestroy[2]=CreateTrigger()
    call TriggerAddCondition(st__Base_onDestroy[2],Condition( function sa__Child_onDestroy))
    call TriggerAddCondition(st__Base_onDestroy[2],Condition( function sa__Base_onDestroy))



endfunction

