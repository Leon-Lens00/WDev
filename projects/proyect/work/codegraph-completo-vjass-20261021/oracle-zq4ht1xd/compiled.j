globals
//globals from L:
constant boolean LIBRARY_L=true
//endglobals from L


//JASSHelper struct globals:
constant integer si__L___Data=1
integer array s__L___Data_wrong
constant integer si__Data=2
integer array s__Data_amount
boolean array s__Data_enabled
string array s__Data_label

endglobals



function s__Data_getFromKey takes integer key returns integer
return (key)
endfunction
function Compute takes nothing returns integer
return 42
endfunction
function OtherCompute takes nothing returns integer
return 7
endfunction
function main takes nothing returns nothing

    call ExecuteFunc("jasshelper__init2036")

call ExecuteFunc("jasshelper__0initdatastructs2036")
endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init2036 takes nothing returns nothing



endfunction

function jasshelper__0initdatastructs2036 takes nothing returns nothing
 local integer s

//Loaded from: Z:\home\snz\Documentos\ChatGPT\Proyect\work\codegraph-completo-vjass-20261021\compiler-scope\data.slk
    set s=s__Data_getFromKey(5)
    set s__Data_amount[s]=Compute()
    set s__Data_enabled[s]=true
    set s__Data_label[s]="OtherCompute()"

endfunction

