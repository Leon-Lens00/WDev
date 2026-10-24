globals


//JASSHelper struct globals:
constant integer si__S=1
integer si__S_F=0
integer si__S_I=0
integer array si__S_V
trigger st__S_feature
integer f__arg_this

endglobals


//Generated method caller for S.feature
function sc__S_feature takes integer this returns nothing
endfunction

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

function s__S_feature takes integer this returns nothing
endfunction





function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init544")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa__S_feature takes nothing returns boolean
local integer this=f__arg_this
   return true
endfunction

function jasshelper__init544 takes nothing returns nothing
    set st__S_feature=CreateTrigger()
    call TriggerAddCondition(st__S_feature,Condition( function sa__S_feature))



endfunction

