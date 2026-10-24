struct Data extends array
integer amount
boolean enabled
string label
static method getFromKey takes integer key returns thistype
return thistype(key)
endmethod
endstruct
function Compute takes nothing returns integer
return 42
endfunction
function OtherCompute takes nothing returns integer
return 7
endfunction
//! loaddata "data.slk"
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction

static if DEBUG_MODE then
function DebugBranch takes nothing returns nothing
endfunction
else
function ReleaseBranch takes nothing returns nothing
endfunction
endif
