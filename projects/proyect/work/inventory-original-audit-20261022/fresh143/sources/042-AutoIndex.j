//TESH.scrollpos=0
//TESH.alwaysfold=0
library AutoIndex requires UnitDex

    function interface IndexFunc takes unit u returns nothing
    
    struct AutoIndex
    
        private static IndexFunc array indexfuncs
        private static integer indexfuncs_n = -1
        private static IndexFunc array deindexfuncs
        private static integer deindexfuncs_n = -1
        private static IndexFunc indexfunc
    
        static method getIndex takes unit u returns integer
            return GetUnitId(u)
        endmethod
        
        static method isUnitIndexed takes unit u returns boolean
            return u != null and UnitDex.Unit[GetUnitId(u)] == u
        endmethod
    
        static method getIndexDebug takes unit u returns integer
            if u == null then
                return 0
            elseif GetUnitTypeId(u) == 0 then
                   call BJDebugMsg("AutoIndex error: Removed or decayed unit passed to GetUnitId.")
            elseif UnitDex.Unit[GetUnitId(u)] != u and GetIssuedOrderId() != 852056 then
                call BJDebugMsg("AutoIndex error: "+GetUnitName(u)+" is a filtered unit.")
            endif
            
            return getIndex(u)
        endmethod
        
        private static method onUnitIndexed_sub takes nothing returns nothing
            call indexfunc.evaluate(GetEnumUnit())
        endmethod
        
        static method onUnitIndexed takes IndexFunc func returns nothing
            set indexfuncs_n = indexfuncs_n + 1
            set indexfuncs[indexfuncs_n] = func
            if UnitDex.Initialized then //During initialization, evaluate the indexfunc for every preplaced unit.
                set indexfunc = func
                call ForGroup(UnitDex.Group, function AutoIndex.onUnitIndexed_sub)
            endif
        endmethod
        
        static method onUnitDeindexed takes IndexFunc func returns nothing
            set deindexfuncs_n = deindexfuncs_n + 1
            set deindexfuncs[deindexfuncs_n] = func
        endmethod
    endstruct
    
    function OnUnitIndexed takes IndexFunc func returns nothing
        call AutoIndex.onUnitIndexed(func)
    endfunction

    function OnUnitDeindexed takes IndexFunc func returns nothing
        call AutoIndex.onUnitDeindexed(func)
    endfunction

endlibrary