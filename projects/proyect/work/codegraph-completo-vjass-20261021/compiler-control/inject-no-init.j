function Ping takes nothing returns nothing
endfunction
library Demo initializer Init
function Init takes nothing returns nothing
call Ping()
endfunction
endlibrary
//! inject main
call Ping()
//! endinject
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
