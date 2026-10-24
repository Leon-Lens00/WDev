//! textmacro INNER
function Ping takes nothing returns nothing
endfunction
//! endtextmacro
//! textmacro OUTER
//! runtextmacro INNER()
//! endtextmacro
//! runtextmacro OUTER()
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
