function interface Callback takes nothing returns nothing
function One takes nothing returns nothing
endfunction
function Two takes nothing returns nothing
endfunction
function Invoke takes Callback cb returns nothing
local Callback alias = cb
call alias.evaluate()
endfunction
function Run takes boolean chooseTwo returns nothing
local Callback cb = Callback.One
if chooseTwo then
set cb = Callback.Two
endif
call Invoke(cb)
endfunction

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
