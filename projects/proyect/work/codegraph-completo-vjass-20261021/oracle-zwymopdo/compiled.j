globals


//JASSHelper struct globals:
constant integer si__S=1
integer si__S_F=0
integer si__S_I=0
integer array si__S_V
integer array s__S_M__value
integer array s__S_N___value

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

//Implemented from module M:
function s__S_M__helper takes integer this returns nothing
set s__S_M__value[this]=1
endfunction
function s__S_runM takes integer this returns nothing
call s__S_M__helper(this)
endfunction
//Implemented from module N:
function s__S_N___helper takes integer this returns nothing
set s__S_N___value[this]=2
endfunction
function s__S_runN takes integer this returns nothing
call s__S_N___helper(this)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init2005")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init2005 takes nothing returns nothing



endfunction

