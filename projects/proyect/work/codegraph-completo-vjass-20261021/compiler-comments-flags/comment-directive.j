/* prefix
comment */ //! textmacro M
function Generated takes nothing returns nothing
endfunction
//! endtextmacro
//! runtextmacro M()
/* comment
closed */ static if false then
function Hidden takes nothing returns nothing
endfunction
endif
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
