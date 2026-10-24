interface Ordered
method operator <
endinterface
struct Value extends Ordered
method operator < takes Value other returns boolean
return false
endmethod
endstruct
function Run takes Value a, Value b returns boolean
return a < b
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
