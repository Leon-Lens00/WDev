globals


//JASSHelper struct globals:
constant integer si__S=1
integer si__S_F=0
integer si__S_I=0
integer array si__S_V

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

function Ping takes nothing returns nothing
endfunction
//Implemented from module Begin:
function s__S_run takes nothing returns nothing
call Ping()
//Implemented from module Finish:
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init6780")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6780 takes nothing returns nothing



endfunction

