globals


//JASSHelper struct globals:
constant integer si__S=1

endglobals


// NO_DEBUG:     debug integer feature

        function s__S_fallback takes nothing returns nothing
        endfunction

function main takes nothing returns nothing
    call s__S_fallback()

    call ExecuteFunc("jasshelper__init6659")

endfunction
function config takes nothing returns nothing
endfunction



//All initializer functions called in proper order:

function jasshelper__init6659 takes nothing returns nothing



endfunction

