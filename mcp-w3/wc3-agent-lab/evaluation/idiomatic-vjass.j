library IdiomProbe initializer Init
struct ProbeData
    integer value
    static method create takes nothing returns thistype
        local thistype this = thistype.allocate()
        set .value = 1
        return this
    endmethod
endstruct
private function Init takes nothing returns nothing
    local ProbeData data = ProbeData.create()
    call data.destroy()
endfunction
endlibrary
function config takes nothing returns nothing
endfunction
function main takes nothing returns nothing
endfunction
