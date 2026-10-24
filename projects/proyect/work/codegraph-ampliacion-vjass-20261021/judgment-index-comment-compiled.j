globals


//JASSHelper struct globals:
constant integer si__Other=1
constant integer si__S=2

endglobals


    function s__Other_tick takes integer this returns nothing
    endfunction
    function s__S__getindex takes integer this,integer index returns integer
        return (index)
    endfunction
    function s__S_tick takes integer this returns nothing
    endfunction
function main takes nothing returns nothing
    local integer scalar= 0
    call s__Other_tick(s__S__getindex(scalar,0))

    call ExecuteFunc("jasshelper__init6780")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6780 takes nothing returns nothing



endfunction

