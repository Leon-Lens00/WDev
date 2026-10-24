//! textmacro DECL takes VALUE
function Value takes nothing returns string
return $VALUE$
endfunction
//! endtextmacro
//! runtextmacro DECL("\"hello\"")
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
