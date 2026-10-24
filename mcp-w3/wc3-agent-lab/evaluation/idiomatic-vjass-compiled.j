globals
//globals from IdiomProbe:
constant boolean LIBRARY_IdiomProbe=true
//endglobals from IdiomProbe


//JASSHelper struct globals:
constant integer si__ProbeData=1
integer si__ProbeData_F=0
integer si__ProbeData_I=0
integer array si__ProbeData_V
integer array s__ProbeData_value

endglobals


//Generated allocator of ProbeData
function s__ProbeData__allocate takes nothing returns integer
 local integer this=si__ProbeData_F
    if (this!=0) then
        set si__ProbeData_F=si__ProbeData_V[this]
    else
        set si__ProbeData_I=si__ProbeData_I+1
        set this=si__ProbeData_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__ProbeData_V[this]=-1
 return this
endfunction

//Generated destructor of ProbeData
function s__ProbeData_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__ProbeData_V[this]!=-1) then
        return
    endif
    set si__ProbeData_V[this]=si__ProbeData_F
    set si__ProbeData_F=this
endfunction

    function s__ProbeData_create takes nothing returns integer
        local integer this= s__ProbeData__allocate()
        set s__ProbeData_value[this]=1
        return this
    endfunction
function IdiomProbe___Init takes nothing returns nothing
    local integer data= s__ProbeData_create()
    call s__ProbeData_deallocate(data)
endfunction

function config takes nothing returns nothing
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init5762")

endfunction



//All initializer functions called in proper order:

function jasshelper__init5762 takes nothing returns nothing


call ExecuteFunc("IdiomProbe___Init")
//------------------------------------

endfunction

