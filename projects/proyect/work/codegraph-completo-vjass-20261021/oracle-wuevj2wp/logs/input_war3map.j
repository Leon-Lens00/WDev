function Target takes nothing returns nothing
endfunction
globals
constant string PREFIX = "Tar"
endglobals
library Demo
private function PrivateTarget takes nothing returns nothing
endfunction
public function PublicTarget takes nothing returns nothing
endfunction
function Run takes nothing returns nothing
call ExecuteFunc(PREFIX+"get")
call ExecuteFunc(SCOPE_PRIVATE+"PrivateTarget")
call ExecuteFunc(SCOPE_PREFIX+"PublicTarget")
endfunction
endlibrary
function main takes nothing returns nothing
endfunction
function config takes nothing returns nothing
endfunction
