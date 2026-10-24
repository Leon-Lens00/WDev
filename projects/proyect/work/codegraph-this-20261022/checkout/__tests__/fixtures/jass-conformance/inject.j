function Original takes nothing returns nothing
endfunction
library Demo initializer Init
function Ping takes nothing returns nothing
endfunction
function Init takes nothing returns nothing
call Ping()
endfunction
endlibrary
//! inject main
call Ping()
//! dovjassinit
//! endinject
function main takes nothing returns nothing
call Original()
endfunction
function config takes nothing returns nothing
endfunction
