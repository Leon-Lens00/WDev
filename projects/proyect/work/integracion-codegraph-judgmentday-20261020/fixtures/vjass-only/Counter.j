library CounterLib
struct Counter
 integer value
 method step takes nothing returns nothing
  set .value = .value + 1
 endmethod
endstruct
endlibrary
