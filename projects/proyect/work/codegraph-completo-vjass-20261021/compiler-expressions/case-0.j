struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Box extends array
method operator [] takes integer i returns Leaf
return Leaf(i)
endmethod
endstruct
struct Factory extends array
Box box
static method make takes nothing returns thistype
return 0
endmethod
endstruct
function Run takes nothing returns nothing
call Factory.make().box[0].tick()
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
