struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
globals
Leaf array values[3][4]
endglobals
struct Owner
static Leaf array items[3][4]
endstruct
function Run takes Owner o returns nothing
call values[0][0].tick()
call Owner.items[0][0].tick()
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
