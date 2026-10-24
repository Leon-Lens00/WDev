globals


//JASSHelper struct globals:
constant integer si__Base=1
integer si__Base_F=0
integer si__Base_I=0
integer array si__Base_V
constant integer si__Child=2
integer array si__Base_type
trigger array st__Base_onDestroy
trigger st__Base_create
integer f__arg_integer1
integer f__arg_this
integer f__result_integer

endglobals


//Generated method caller for Base.create
function sc__Base_create takes integer n returns integer
    set f__arg_integer1=n
    call TriggerEvaluate(st__Base_create)
 return f__result_integer
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

//Generated allocator of Child
function s__Child__allocate takes integer n returns integer
 local integer this=sc__Base_create(n)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Base_type[this]=2
    set kthis=this

 return this
endfunction


function s__Base_create takes integer n returns integer
return s__Base__allocate()
endfunction
function Run takes nothing returns nothing
local integer c=s__Child__allocate(1)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init2737")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa__Base_create takes nothing returns boolean
local integer n=f__arg_integer1
set f__result_integer= s__Base__allocate()
   return true
endfunction

function jasshelper__init2737 takes nothing returns nothing
    set st__Base_create=CreateTrigger()
    call TriggerAddCondition(st__Base_create,Condition( function sa__Base_create))
    set st__Base_onDestroy[1]=null
    set st__Base_onDestroy[2]=null



endfunction

