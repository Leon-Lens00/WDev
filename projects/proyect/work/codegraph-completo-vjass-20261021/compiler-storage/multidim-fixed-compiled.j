globals
// processed: Leaf array values[3][4]


//JASSHelper struct globals:
constant integer si__Leaf=2
constant integer si__Owner=3
integer si__Owner_F=0
integer si__Owner_I=0
integer array si__Owner_V
integer array s__values
integer array s__s__Owner_items

endglobals


//Generated allocator of Owner
function s__Owner__allocate takes nothing returns integer
 local integer this=si__Owner_F
    if (this!=0) then
        set si__Owner_F=si__Owner_V[this]
    else
        set si__Owner_I=si__Owner_I+1
        set this=si__Owner_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Owner_V[this]=-1
 return this
endfunction

//Generated destructor of Owner
function s__Owner_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Owner_V[this]!=-1) then
        return
    endif
    set si__Owner_V[this]=si__Owner_F
    set si__Owner_F=this
endfunction

function s__Leaf_tick takes integer this returns nothing
endfunction
function Run takes integer o returns nothing
call s__Leaf_tick(s__values[(0)*(4)+0])
call s__Leaf_tick(s__s__Owner_items[(0)*(4)+0])
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init1149")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

//Functions for BigArrays:

function jasshelper__init1149 takes nothing returns nothing



endfunction

