globals
string dispatch=""


//JASSHelper struct globals:
trigger array st___prototype1

endglobals

function sc___prototype1_execute takes integer i returns nothing

    call TriggerExecute(st___prototype1[i])
endfunction
function sc___prototype1_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype1[i])

endfunction

function Target takes nothing returns nothing
endfunction

function main takes nothing returns nothing
set dispatch="Target"
call ExecuteFunc(dispatch)


    call ExecuteFunc("jasshelper__init5510")


endfunction //injected main function (! inject command)??
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:
function sa___prototype1_Target takes nothing returns boolean

    return true
endfunction

function jasshelper__init5510 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_Target)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_Target))



endfunction

