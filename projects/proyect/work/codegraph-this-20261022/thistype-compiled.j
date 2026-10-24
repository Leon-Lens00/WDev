globals


//JASSHelper struct globals:
constant integer si__Pair=1
integer si__Pair_F=0
integer si__Pair_I=0
integer array si__Pair_V

endglobals


//Generated allocator of Pair
function s__Pair__allocate takes nothing returns integer
 local integer this=si__Pair_F
    if (this!=0) then
        set si__Pair_F=si__Pair_V[this]
    else
        set si__Pair_I=si__Pair_I+1
        set this=si__Pair_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Pair_V[this]=-1
 return this
endfunction

//Generated destructor of Pair
function s__Pair_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Pair_V[this]!=-1) then
        return
    endif
    set si__Pair_V[this]=si__Pair_F
    set si__Pair_F=this
endfunction

function s__Pair_cast takes integer this,real x returns nothing
endfunction
function s__Pair_spell takes nothing returns nothing
local integer this= 1
call s__Pair_cast(this,1.)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init6659")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6659 takes nothing returns nothing



endfunction

