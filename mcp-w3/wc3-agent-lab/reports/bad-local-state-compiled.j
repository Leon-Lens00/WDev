globals


//JASSHelper struct globals:

endglobals


function main takes nothing returns nothing
    if GetLocalPlayer() == Player(0) then
        call CreateUnit(Player(0), 'hfoo', 0., 0., 0.)
    endif

    call ExecuteFunc("jasshelper__init552")

endfunction



//All initializer functions called in proper order:

function jasshelper__init552 takes nothing returns nothing



endfunction

