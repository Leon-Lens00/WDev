struct Other extends array
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
call Unknown().field[0].tick()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
