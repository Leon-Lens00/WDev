globals


//JASSHelper struct globals:
constant integer si__Leaf=1
integer si__Row_I=0
integer si__Row_F=0
integer array s__Row
constant integer s__Row_size=5
integer array si__Row_V
integer si__Grid_I=0
integer si__Grid_F=0
integer array s__Grid
constant integer s__Grid_size=3
integer array si__Grid_V

endglobals


//Generated allocator of Grid
function s__Grid__allocate takes nothing returns integer
 local integer this=si__Grid_F
    if (this!=0) then
        set si__Grid_F=si__Grid_V[this]
    else
        set si__Grid_I=si__Grid_I+3
        set this=si__Grid_I
    endif
    if (this>8188) then
        return 0
    endif

    set si__Grid_V[this]=-1
 return this
endfunction

//Generated destructor of Grid
function s__Grid_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Grid_V[this]!=-1) then
        return
    endif
    set si__Grid_V[this]=si__Grid_F
    set si__Grid_F=this
endfunction

//Generated allocator of Row
function s__Row__allocate takes nothing returns integer
 local integer this=si__Row_F
    if (this!=0) then
        set si__Row_F=si__Row_V[this]
    else
        set si__Row_I=si__Row_I+5
        set this=si__Row_I
    endif
    if (this>8186) then
        return 0
    endif

    set si__Row_V[this]=-1
 return this
endfunction

//Generated destructor of Row
function s__Row_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Row_V[this]!=-1) then
        return
    endif
    set si__Row_V[this]=si__Row_F
    set si__Row_F=this
endfunction

function s__Leaf_tick takes integer this returns nothing
endfunction
//processed :type Row extends Leaf array[5]
//processed :type Grid extends Row array[3]
function Run takes nothing returns nothing
local integer r=s__Row__allocate()
local integer g=s__Grid__allocate()
call s__Leaf_tick(s__Row[r])
call s__Leaf_tick(s__Row[s__Grid[g]])
call s__Row_deallocate(r)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init6780")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6780 takes nothing returns nothing



endfunction

