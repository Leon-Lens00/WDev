globals
Leaf array values[3][4]

endglobals
struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Owner
Leaf array items[3][4]
endstruct
function Run takes Owner o returns nothing
call values[0][0].tick()
call o.items[0][0].tick()
endfunction
function main takes nothing returns nothing

//! initstructs

//! initdatastructs
endfunction
function config takes nothing returns nothing
endfunction


