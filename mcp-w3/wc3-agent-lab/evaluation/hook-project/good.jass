library Probe initializer Init
struct Counter
    integer value
    method step takes nothing returns nothing
        set this.value = this.value + 1
    endmethod
endstruct
private function Init takes nothing returns nothing
    local Counter c = Counter.create()
    call c.step()
    call c.destroy()
endfunction
endlibrary
function config takes nothing returns nothing
endfunction
function main takes nothing returns nothing
endfunction
