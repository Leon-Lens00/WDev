globals


//JASSHelper struct globals:
constant integer si__Other=1
constant integer si__S=2

endglobals


    function s__Other_tick takes integer this returns nothing
    endfunction
    function s__S__staticgetindex takes integer index returns integer
        return (index)
    endfunction
    function s__S_tick takes integer this returns nothing
    endfunction
function main takes nothing returns nothing
    call s__Other_tick(((0))) // INLINED!!

    call ExecuteFunc("jasshelper__init2991")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init2991 takes nothing returns nothing



endfunction

