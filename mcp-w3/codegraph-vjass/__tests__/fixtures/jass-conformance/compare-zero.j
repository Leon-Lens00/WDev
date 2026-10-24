interface I
method operator <
endinterface
struct S extends I
method operator < takes S other returns boolean
return true
endmethod
endstruct
function Run takes S a,S b returns boolean
return a<0 or a<b
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
