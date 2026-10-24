struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Box extends array
method operator leaf takes nothing returns Leaf
return 0
endmethod
method operator leaf= takes Leaf value returns nothing
endmethod
endstruct
function Run takes Box box returns nothing
call box.leaf.tick()
set box.leaf = box.leaf
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
