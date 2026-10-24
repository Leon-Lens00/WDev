function Count takes nothing returns integer
return 2
endfunction
function Ping takes nothing returns nothing
endfunction
function Run takes nothing returns nothing
local integer i
local group g=CreateGroup()
local unit u
for i = 1 to Count()
call Ping()
endfor
for i = Count() downto 1
call Ping()
endfor
while Count()>0
call Ping()
break
endwhile
for u in g
call KillUnit(u)
endfor
endfunction
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
