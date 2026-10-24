struct Other extends array
    method tick takes nothing returns nothing
    endmethod
endstruct
struct S extends array
    method operator [] takes integer index returns Other
        return Other(index)
    endmethod
    method tick takes nothing returns nothing
    endmethod
endstruct
function main takes nothing returns nothing
    local S scalar = 0 // array
    call scalar[0].tick()
endfunction
function config takes nothing returns nothing
endfunction
