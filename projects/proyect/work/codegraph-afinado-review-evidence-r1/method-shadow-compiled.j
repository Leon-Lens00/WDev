globals


//JASSHelper struct globals:
constant integer si__Counter=1
integer si__Counter_F=0
integer si__Counter_I=0
integer array si__Counter_V

endglobals


//Generated allocator of Counter
function s__Counter__allocate takes nothing returns integer
 local integer this=si__Counter_F
    if (this!=0) then
        set si__Counter_F=si__Counter_V[this]
    else
        set si__Counter_I=si__Counter_I+1
        set this=si__Counter_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Counter_V[this]=-1
 return this
endfunction

//Generated destructor of Counter
function s__Counter_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Counter_V[this]!=-1) then
        return
    endif
    set si__Counter_V[this]=si__Counter_F
    set si__Counter_F=this
endfunction

function Ping takes nothing returns nothing
endfunction
 function s__Counter_Ping takes nothing returns nothing
 endfunction
 function s__Counter_Run takes nothing returns nothing
 call s__Counter_Ping()
 endfunction
function main takes nothing returns nothing
 call s__Counter_Ping() // INLINED!!

    call ExecuteFunc("jasshelper__init2737")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init2737 takes nothing returns nothing



endfunction

