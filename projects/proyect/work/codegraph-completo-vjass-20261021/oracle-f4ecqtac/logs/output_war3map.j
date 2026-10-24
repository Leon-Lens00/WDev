globals

endglobals
function interface Callback takes widget x returns widget
function Target takes unit x returns unit
return x
endfunction
function Run takes nothing returns nothing
local Callback cb=Callback.Target
local widget w=cb.evaluate(null)
endfunction
function main takes nothing returns nothing

//! initstructs

//! initdatastructs
endfunction
function config takes nothing returns nothing
endfunction


