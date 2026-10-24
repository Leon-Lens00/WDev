library InventoryItem uses InventoryTable, optional InventoryBonus
    
    globals
        public constant integer SEED_START = 0
        public constant integer SEED_END   = 999
    endglobals
    
    struct InvItem
        readonly static InventoryTable InventoryTable
        
        integer id
        integer icon
        integer cost
        integer ability
        string info
        integer tempCustomId
        
        implement InvItemPlugins
        
        static if not thistype.buildDescriptionLines.exists then
            method buildDescriptionLines takes integer pid, integer startLine returns integer
                return buildDescriptionLines(GetPlayerId(GetOwningPlayer(forUnit)), 0)
            endmethod
        endif
        
        static if not thistype.buildDescription.exists then
            method buildDescription takes unit forUnit returns string
                return buildDescriptionLines(GetPlayerId(GetOwningPlayer(forUnit)), 0)
            endmethod
        endif
        
        private static method onInit takes nothing returns nothing
            set InvItem.InventoryTable = InventoryTable.create()
        endmethod
    endstruct
    
    function GetInvItem takes integer id returns InvItem
        return InvItem(InvItem.InventoryTable[id])
    endfunction
    
    function GetItemInfo takes integer id returns string
        return InvItem(InvItem.InventoryTable[id]).info
    endfunction
    
    function GetItemDescription takes integer id returns string
        return InvItem(InvItem.InventoryTable[id]).info
    endfunction
    
    function GetItemIcon takes integer id returns integer
        local integer icon = InvItem(InvItem.InventoryTable[id]).icon
        if (icon == 0) then
            return Inventory.ICON_EMPTY
        endif
        return icon
    endfunction
    
    function CreateInvItem takes integer id, integer icon, integer cost, integer abil, string info returns InvItem
        local InvItem itm = InvItem.create()
        set itm.id   = id
        set itm.icon = icon
        set itm.cost = cost
        set itm.info = info
        set itm.ability = abil
        set InvItem.InventoryTable[itm.id] = itm
        return itm
    endfunction
    
    struct InvCustomItem extends array
        static integer Counter = 1
        static InventoryTable SeedTable
        
        static method create takes nothing returns thistype
            local thistype this = Counter
            set SeedTable[this] = GetRandomInt(SEED_START, SEED_END)
            set Counter = Counter + 1
            return this
        endmethod
        
        method seed takes nothing returns integer
            return SeedTable[this]
        endmethod
        
        static method onInit takes nothing returns nothing
            set SeedTable = SeedTable.create()
        endmethod
    endstruct

endlibrary