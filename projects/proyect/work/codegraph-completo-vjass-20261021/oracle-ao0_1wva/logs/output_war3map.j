globals
Leaf array leaves

endglobals
struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes integer index returns nothing
call (index:leaves).tick()
endfunction

function main takes nothing returns nothing

//! initstructs

//! initdatastructs
endfunction
function config takes nothing returns nothing
endfunction


