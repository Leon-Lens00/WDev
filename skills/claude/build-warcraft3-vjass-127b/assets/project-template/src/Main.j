//! import "config/ObjectIds.j"
//! import "systems/GameCore.j"

library ProjectMain initializer Init requires ObjectIds, GameCore
    private function Init takes nothing returns nothing
        // Keep project startup explicit. Add only project-owned initialization here.
    endfunction
endlibrary
