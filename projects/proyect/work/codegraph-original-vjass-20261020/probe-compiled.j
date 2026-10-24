globals
//globals from CodeGraphProbe:
constant boolean LIBRARY_CodeGraphProbe=true
integer CodeGraphProbe___hits= 0
//endglobals from CodeGraphProbe


//JASSHelper struct globals:
constant integer si__CodeGraphProbe___Counter=1
integer si__CodeGraphProbe___Counter_F=0
integer si__CodeGraphProbe___Counter_I=0
integer array si__CodeGraphProbe___Counter_V

endglobals


//Generated allocator of CodeGraphProbe___Counter
function s__CodeGraphProbe___Counter__allocate takes nothing returns integer
 local integer this=si__CodeGraphProbe___Counter_F
    if (this!=0) then
        set si__CodeGraphProbe___Counter_F=si__CodeGraphProbe___Counter_V[this]
    else
        set si__CodeGraphProbe___Counter_I=si__CodeGraphProbe___Counter_I+1
        set this=si__CodeGraphProbe___Counter_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__CodeGraphProbe___Counter_V[this]=-1
 return this
endfunction

//Generated destructor of CodeGraphProbe___Counter
function s__CodeGraphProbe___Counter_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__CodeGraphProbe___Counter_V[this]!=-1) then
        return
    endif
    set si__CodeGraphProbe___Counter_V[this]=si__CodeGraphProbe___Counter_F
    set si__CodeGraphProbe___Counter_F=this
endfunction

    function CodeGraphProbe___Ping takes nothing returns nothing
        set CodeGraphProbe___hits=CodeGraphProbe___hits + 1
    endfunction
        function s__CodeGraphProbe___Counter_step takes integer this returns nothing
            set CodeGraphProbe___hits=CodeGraphProbe___hits + 1 // INLINED!!
        endfunction
        function s__CodeGraphProbe___Counter_run takes nothing returns nothing
            local integer this= s__CodeGraphProbe___Counter__allocate()
            call s__CodeGraphProbe___Counter_step(this)
            call s__CodeGraphProbe___Counter_deallocate(this)
        endfunction
    function CodeGraphProbe___Done takes nothing returns nothing
        call s__CodeGraphProbe___Counter_run()
    endfunction
    function CodeGraphProbe___Init takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.0, false, function CodeGraphProbe___Done)
    endfunction

function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init5392")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init5392 takes nothing returns nothing


call ExecuteFunc("CodeGraphProbe___Init")
//------------------------------------

endfunction

