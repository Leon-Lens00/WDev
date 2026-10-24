//! textmacro DECL takes NAME
function $NAME$ takes nothing returns nothing
endfunction
//! endtextmacro
//! runtextmacro DECL("MacroRun")
function GlobalCallback takes nothing returns nothing
endfunction
library Definitions
private function Captured takes nothing returns nothing
endfunction
module Inner
    static method launch takes nothing returns nothing
        call Captured()
        call thistype.onPeriod()
    endmethod
    private static method onInit takes nothing returns nothing
        call thistype.launch()
    endmethod
endmodule
module Outer
    implement Inner
endmodule
endlibrary
library Consumers requires Definitions
struct S
    static method onPeriod takes nothing returns nothing
    endmethod
    implement Outer
    static if not thistype.onPeriod.exists then
        static method onPeriod takes nothing returns nothing
        endmethod
    endif
    method operator value takes nothing returns integer
        return 1
    endmethod
    method operator value= takes integer v returns nothing
    endmethod
    static method make takes nothing returns thistype
        return thistype.allocate()
    endmethod
    static method start takes nothing returns nothing
        local thistype s = make()
        local integer n = s.value
        set s.value = 2
        call GlobalCallback.execute()
        call thistype.onPeriod.evaluate()
        call thistype.make().destroy()
        call launch()
        call s.destroy()
    endmethod
endstruct
endlibrary
function main takes nothing returns nothing
    call S.start()
    call MacroRun()
    call ExecuteFunc("GlobalCallback")
endfunction
function config takes nothing returns nothing
endfunction
