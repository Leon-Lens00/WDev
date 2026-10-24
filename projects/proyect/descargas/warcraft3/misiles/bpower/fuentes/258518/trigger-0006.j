//TESH.scrollpos=69
//TESH.alwaysfold=0
    private module HydraStructure 
    
        private static thistype collectionCount = 0
        private static thistype nodeCount = 0
        debug private boolean isNode
        debug private boolean isCollection
        readonly integer size 
        
        private thistype _list
        method operator list takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,    "List", "list", "thistype", this, "Attempted To Read Null Node.")
                debug call ThrowError(not isNode,   "List", "list", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _list
        endmethod
        
        private thistype _next
        method operator next takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,    "List", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
                debug call ThrowError(not isNode,   "List", "next", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _next
        endmethod
        
        private thistype _prev
        method operator prev takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,    "List", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
                debug call ThrowError(not isNode,   "List", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _prev
        endmethod
        
        private thistype _first
        method operator first takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,        "List", "first", "thistype", this, "Attempted To Read Null List.")
                debug call ThrowError(not isCollection, "List", "first", "thistype", this, "Attempted To Read Invalid List.")
            endif
            return _first
        endmethod
        
        private thistype _last
        method operator last takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,        "List", "last", "thistype", this, "Attempted To Read Null List.")
                debug call ThrowError(not isCollection, "List", "last", "thistype", this, "Attempted To Read Invalid List.")
            endif
            return _last
        endmethod
        
        private static method allocateCollection takes nothing returns thistype
            local thistype this = thistype(0)._first
            
            if (0 == this) then
                static if LIBRARY_ErrorMessage then
                    debug call ThrowError(collectionCount == 8191, "List", "allocateCollection", "thistype", 0, "Overflow.")
                endif
               
                set this = collectionCount + 1
                set collectionCount = this
            else
                set thistype(0)._first = _first
            endif
            
            return this
        endmethod
        
        private static method allocateNode takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                
                static if LIBRARY_ErrorMessage then
                    debug call ThrowError(nodeCount == 8191, "List", "allocateNode", "thistype", 0, "Overflow.")
                endif
               
                set this = nodeCount + 1
                set nodeCount = this
            else
                set thistype(0)._next = _next
            endif
            
            return this
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = allocateCollection()
            
            debug set isCollection = true
            
            set _first = 0
            set size   = 0
            return this
        endmethod
        method enqueue takes nothing returns thistype
            local thistype node = allocateNode()
            
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,        "List", "enqueue", "thistype", this, "Attempted To Enqueue On To Null List.")
                debug call ThrowError(not isCollection, "List", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid List.")
            endif
            
            debug set node.isNode = true
            
            set node._list = this
        
            if (_first == 0) then
                set _first = node
                set _last = node
                set node._prev = 0
            else
                set _last._next = node
                set node._prev = _last
                set _last = node
            endif
            
            set node._next = 0
            set size       = size + 1
            return node
        endmethod
        method remove takes nothing returns nothing
            local thistype node = this
            set this = node._list
            
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(node == 0,        "List", "remove", "thistype", this, "Attempted To Remove Null Node.")
                debug call ThrowError(not node.isNode,  "List", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
            endif
            
            debug set node.isNode = false
            
            set node._list = 0
        
            if (0 == node._prev) then
                set _first = node._next
            else
                set node._prev._next = node._next
            endif
            if (0 == node._next) then
                set _last = node._prev
            else
                set node._next._prev = node._prev
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
            set size = size - 1
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = _first
           
           static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,            "List", "clear", "thistype", this, "Attempted To Clear Null List.")
                debug call ThrowError(not isCollection,     "List", "clear", "thistype", this, "Attempted To Clear Invalid List.")
           endif
           
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node._next
                endloop
            endif
            
            if (_first == 0) then
                return
            endif
            
            set _last._next = thistype(0)._next
            set thistype(0)._next = _first
            
            set _first = 0
            set _last = 0
        endmethod
        method destroy takes nothing returns nothing
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,            "List", "destroy", "thistype", this, "Attempted To Destroy Null List.")
                debug call ThrowError(not isCollection,     "List", "destroy", "thistype", this, "Attempted To Destroy Invalid List.")
            endif
            
            static if DEBUG_MODE then
                debug call clear()
                
                debug set isCollection = false
            else
                if (_first != 0) then
                    set _last._next = thistype(0)._next
                    set thistype(0)._next = _first
                    
                    set _last = 0
                endif
            endif
            
            set _first = thistype(0)._first
            set thistype(0)._first = this
            set size   = 0
        endmethod
    endmodule