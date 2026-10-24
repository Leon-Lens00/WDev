globals
string dispatch=""
endglobals
function Target takes nothing returns nothing
endfunction
//! inject main
set dispatch=Target.name
call ExecuteFunc(dispatch)
//! dovjassinit
//! endinject

function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
