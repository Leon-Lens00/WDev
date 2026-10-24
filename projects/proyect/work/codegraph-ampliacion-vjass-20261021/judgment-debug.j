struct S extends array
    debug integer feature
    static if not thistype.feature.exists then
        static method fallback takes nothing returns nothing
        endmethod
    endif
endstruct
function main takes nothing returns nothing
    call S.fallback()
endfunction
function config takes nothing returns nothing
endfunction
