globals


//JASSHelper struct globals:
constant integer si__WrongBase=1
integer si__WrongBase_F=0
integer si__WrongBase_I=0
integer array si__WrongBase_V
constant integer si__CorrectBase=2
integer si__CorrectBase_F=0
integer si__CorrectBase_I=0
integer array si__CorrectBase_V
constant integer si__Child=3
integer array si__CorrectBase_type
trigger array st__CorrectBase_onDestroy
integer f__arg_this

endglobals


//Generated allocator of WrongBase
function s__WrongBase__allocate takes nothing returns integer
 local integer this=si__WrongBase_F
    if (this!=0) then
        set si__WrongBase_F=si__WrongBase_V[this]
    else
        set si__WrongBase_I=si__WrongBase_I+1
        set this=si__WrongBase_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__WrongBase_V[this]=-1
 return this
endfunction

//Generated destructor of WrongBase
function s__WrongBase_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__WrongBase_V[this]!=-1) then
        return
    endif
    set si__WrongBase_V[this]=si__WrongBase_F
    set si__WrongBase_F=this
endfunction

//Generated allocator of CorrectBase
function s__CorrectBase__allocate takes nothing returns integer
 local integer this=si__CorrectBase_F
    if (this!=0) then
        set si__CorrectBase_F=si__CorrectBase_V[this]
    else
        set si__CorrectBase_I=si__CorrectBase_I+1
        set this=si__CorrectBase_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__CorrectBase_type[this]=2
    set si__CorrectBase_V[this]=-1
 return this
endfunction

//Generated destructor of CorrectBase
function sc__CorrectBase_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__CorrectBase_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__CorrectBase_onDestroy[si__CorrectBase_type[this]])
    set si__CorrectBase_V[this]=si__CorrectBase_F
    set si__CorrectBase_F=this
endfunction

//Generated allocator of Child
function s__Child__allocate takes nothing returns integer
 local integer this=s__CorrectBase__allocate()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__CorrectBase_type[this]=3
    set kthis=this

 return this
endfunction


 function s__WrongBase_tick takes integer this returns nothing
 endfunction
 function s__CorrectBase_tick takes integer this returns nothing
 endfunction
function Probe takes integer c returns nothing
 call s__CorrectBase_tick(c)
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init6780")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6780 takes nothing returns nothing
    set st__CorrectBase_onDestroy[2]=null
    set st__CorrectBase_onDestroy[3]=null



endfunction

