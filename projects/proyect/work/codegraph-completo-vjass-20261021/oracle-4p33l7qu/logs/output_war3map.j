globals


//JASSHelper struct globals:

endglobals


function Count takes nothing returns integer
return 2
endfunction
function Ping takes nothing returns nothing
endfunction
function Run takes nothing returns nothing
local integer i
local group g=CreateGroup()
local unit u
//====== for i = 1 to Count ( )  ======//
set i = (1) - 1
loop
    set i = i + 1
    exitwhen i > (Count())
call Ping()
endloop // endfor
//====== for i = Count ( ) downto 1  ======//
set i = (Count()) + 1
loop
    set i = i - 1
    exitwhen i < (1)
call Ping()
endloop // endfor
//====== while Count ( ) > 0  ======//
loop
    exitwhen not(Count() > 0)
call Ping()
exitwhen true // break
endloop // endwhile
//====== for u in g  ======//
loop
    set u = FirstOfGroup(g)
    exitwhen u == null
    call GroupRemoveUnit(g, u)
call KillUnit(u)
endloop // endfor
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init1850")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init1850 takes nothing returns nothing



endfunction

