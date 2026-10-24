struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
globals
Leaf array leaves
endglobals
function Run takes integer index returns nothing
call Leaf(index:leaves).tick()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
