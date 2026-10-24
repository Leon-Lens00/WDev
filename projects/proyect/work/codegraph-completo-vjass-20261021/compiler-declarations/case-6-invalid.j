scope Demo
private keyword Later
private key SLOT
private function Run takes Later value returns nothing
call value.tick()
endfunction
private struct Later extends array
method tick takes nothing returns nothing
endmethod
endstruct
endscope

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
