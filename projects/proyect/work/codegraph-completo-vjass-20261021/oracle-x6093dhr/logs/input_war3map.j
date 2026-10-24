function OnRemoval takes unit u returns nothing
endfunction
function Run takes unit u returns nothing
call RemoveUnit(u)
endfunction
hook RemoveUnit OnRemoval
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
