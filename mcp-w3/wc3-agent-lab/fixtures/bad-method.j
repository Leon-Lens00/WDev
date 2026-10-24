struct Counter
    method step takes nothing returns nothing
    endmethod
endstruct
function main takes nothing returns nothing
    local Counter c = Counter.create()
    call c.teleportToSafety()
    call c.destroy()
endfunction
