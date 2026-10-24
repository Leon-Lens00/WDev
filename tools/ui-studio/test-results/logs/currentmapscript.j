globals
//globals from PlayerUtils:
constant boolean LIBRARY_PlayerUtils=true
        // automatically change unit colors when changing player color
constant boolean PlayerUtils__AUTO_COLOR_UNITS= true
   
        // use an array for name / color lookups (instead of function calls)
constant boolean PlayerUtils__ARRAY_LOOKUP= false
   
        // this only applies if ARRAY_LOOKUP is true
constant boolean PlayerUtils__HOOK_SAFETY= false
   
constant force FORCE_PLAYING= CreateForce()
   
string array PlayerUtils__Name
string array PlayerUtils__Hex
string array PlayerUtils__OriginalHex
playercolor array PlayerUtils__CurrentColor
//endglobals from PlayerUtils
//globals from TimerUtils:
constant boolean LIBRARY_TimerUtils=true
        //How to tweak timer utils:
        // USE_HASH_TABLE = true  (new blue)
        //  * SAFEST
        //  * SLOWEST (though hash tables are kind of fast)
        //
        // USE_HASH_TABLE = false, USE_FLEXIBLE_OFFSET = true  (orange)
        //  * kinda safe (except there is a limit in the number of timers)
        //  * ALMOST FAST
        //
        // USE_HASH_TABLE = false, USE_FLEXIBLE_OFFSET = false (red)
        //  * THE FASTEST (though is only  faster than the previous method
        //                  after using the optimizer on the map)
        //  * THE LEAST SAFE ( you may have to tweak OFSSET manually for it to
        //                     work)
        //
constant boolean TimerUtils__USE_HASH_TABLE= true
constant boolean TimerUtils__USE_FLEXIBLE_OFFSET= false

constant integer TimerUtils__OFFSET= 0x100000
integer TimerUtils__VOFFSET= TimerUtils__OFFSET
              
        //Timers to preload at map init:
constant integer TimerUtils__QUANTITY= 256
        
        //Changing this  to something big will allow you to keep recycling
        // timers even when there are already AN INCREDIBLE AMOUNT of timers in
        // the stack. But it will make things far slower so that's probably a bad idea...
constant integer TimerUtils__ARRAY_SIZE= 8190

// processed:         integer array TimerUtils__data[TimerUtils__ARRAY_SIZE]
hashtable TimerUtils__ht
// processed:         timer array TimerUtils__tT[TimerUtils__ARRAY_SIZE]
integer TimerUtils__tN= 0
constant integer TimerUtils__HELD=0x28829022
        //use a totally random number here, the more improbable someone uses it, the better.
        
boolean TimerUtils__didinit= false
//endglobals from TimerUtils
//globals from UIMath:
constant boolean LIBRARY_UIMath=true
//endglobals from UIMath
//globals from UnitDex:
constant boolean LIBRARY_UnitDex=true
        // Event types
constant integer EVENT_UNIT_INDEX= 0
constant integer EVENT_UNIT_DEINDEX= 1
        
        // System variables
trigger array UnitDex__IndexTrig
integer UnitDex__Index= 0
real UnitDex__E=- 1
boolexpr UnitDex__FilterEnter
//endglobals from UnitDex
//globals from Camera:
constant boolean LIBRARY_Camera=true
        // configuration   
        
        // location on the map where the terrain is the default level
constant real CHECK_DELTAZ_X= - 1200
constant real CHECK_DELTAZ_Y= 950
        
constant real SCREEN_WIDTH= 0.544
constant real SCREEN_HEIGHT= 0.302
        
constant real SCREEN_ASPECT_RATIO= SCREEN_WIDTH / SCREEN_HEIGHT
        
constant integer CAMERA_DUMMY_TYPE= 'e001'
constant player CAMERA_DUMMY_PLAYER= Player(bj_PLAYER_NEUTRAL_EXTRA)
        
real Camera__DeltaZ= 0
        // endconfig
        
unit array Camera_DummyUnit
location Camera_DummyLoc= Location(0, 0)
//endglobals from Camera
//globals from UserInterface:
constant boolean LIBRARY_UserInterface=true
destructable UserInterface_DummyTree= null
trigger UserInterface__Trig= CreateTrigger()
integer UserInterface__ClickedButton= 0
player UserInterface__ClickingPlayer= null
location UserInterface__DummyLoc= Location(0, 0)
//endglobals from UserInterface
//globals from UIStudioLayout:
constant boolean LIBRARY_UIStudioLayout=true
hashtable UIStudioLayout__H= InitHashtable()
//endglobals from UIStudioLayout

trigger l__library_init

//JASSHelper struct globals:
constant integer si__User=1
constant integer s__User_NULL= 15
player array s__User_handle
integer array s__User_id
integer array s__User_next
integer array s__User_prev
string array s__User_originalName
boolean array s__User_isPlaying
integer s__User_first
integer s__User_last
player s__User_Local
integer s__User_LocalId
integer s__User_AmountPlaying= 0
playercolor array s__User_Color
group s__User_ENUM_GROUP= CreateGroup()
integer array s__User_PlayingPlayer
integer array s__User_PlayingPlayerIndex
constant integer si__VECTOR3=2
integer si__VECTOR3_F=0
integer si__VECTOR3_I=0
integer array si__VECTOR3_V
integer s__VECTOR3_Zero
integer s__VECTOR3_oneX
integer s__VECTOR3_oneY
integer s__VECTOR3_oneZ
real array s__VECTOR3_x
real array s__VECTOR3_y
real array s__VECTOR3_z
constant integer si__MATRIX3=3
integer si__MATRIX3_F=0
integer si__MATRIX3_I=0
integer array si__MATRIX3_V
integer s__MATRIX3_Zero
integer s__MATRIX3_E
real array s__MATRIX3_m11
real array s__MATRIX3_m12
real array s__MATRIX3_m13
real array s__MATRIX3_m21
real array s__MATRIX3_m22
real array s__MATRIX3_m23
real array s__MATRIX3_m31
real array s__MATRIX3_m32
real array s__MATRIX3_m33
constant integer si__MATRIX4=4
integer si__MATRIX4_F=0
integer si__MATRIX4_I=0
integer array si__MATRIX4_V
integer s__MATRIX4_Zero
integer s__MATRIX4_E
real array s__MATRIX4_m11
real array s__MATRIX4_m12
real array s__MATRIX4_m13
real array s__MATRIX4_m14
real array s__MATRIX4_m21
real array s__MATRIX4_m22
real array s__MATRIX4_m23
real array s__MATRIX4_m24
real array s__MATRIX4_m31
real array s__MATRIX4_m32
real array s__MATRIX4_m33
real array s__MATRIX4_m34
real array s__MATRIX4_m41
real array s__MATRIX4_m42
real array s__MATRIX4_m43
real array s__MATRIX4_m44
constant integer si__UnitDex=5
boolean s__UnitDex_Enabled= true
integer s__UnitDex_LastIndex
boolean s__UnitDex_Initialized=false
group s__UnitDex_Group=CreateGroup()
unit array s__UnitDex_Unit
integer s__UnitDex_Count= 0
integer array s__UnitDex_List
constant integer s__UnitDex_DETECT_LEAVE_ABILITY= 'uDex'
constant boolean s__UnitDex_ALLOW_DEBUGGING= true
integer s__UnitDex_Counter= 0
constant integer si__Camera=6
integer si__Camera_F=0
integer si__Camera_I=0
integer array si__Camera_V
integer array s__Camera_eye
integer array s__Camera_at
unit array s__Camera_target
real array s__Camera_distance
real array s__Camera_yaw
real array s__Camera_pitch
real array s__Camera_roll
integer array s__Camera_axisX
integer array s__Camera_axisY
integer array s__Camera_axisZ
integer array s__Camera_view
integer array s__Camera_projection
boolean array s__Camera_change
integer array s__Camera_customValue
constant integer si__Camera__CamInit=7
integer si__Camera__CamInit_F=0
integer si__Camera__CamInit_I=0
integer array si__Camera__CamInit_V
constant integer si__UIButton=8
integer si__UIButton_F=0
integer si__UIButton_I=0
integer array si__UIButton_V
integer array s__UIButton_customValue
integer array s__UIButton_animIndex
trigger array s__UIButton_triggerL
trigger array s__UIButton_triggerR
filterfunc array s__UIButton_onLeftClick
filterfunc array s__UIButton_onRightClick
boolean array s__UIButton_disabled
unit array s__UIButton_selectUnit
boolean s__UIButton_useDelay= false
integer array s__UIButton_AllShow
integer s__UIButton_CountShow= 0
integer array s__UIButton_index
integer array s__UIButton_camera
real array s__UIButton_scale
real array s__UIButton_centerx
real array s__UIButton_centery
real array s__UIButton_minx
real array s__UIButton_maxx
real array s__UIButton_miny
real array s__UIButton_maxy
real array s__UIButton_width
real array s__UIButton_height
real array s__UIButton_z
unit array s__UIButton_picture
effect array s__UIButton_model
boolean array s__UIButton_displayed
integer array s__UIButton_texture
integer array s__UIButton_unitId
integer array s__UIButton_Unit2Button
constant integer si__UIPicture=9
integer si__UIPicture_F=0
integer si__UIPicture_I=0
integer array si__UIPicture_V
integer array s__UIPicture_customValue
integer array s__UIPicture_animIndex
integer array s__UIPicture_AllShow
integer s__UIPicture_CountShow= 0
integer array s__UIPicture_index
integer array s__UIPicture_camera
real array s__UIPicture_scale
real array s__UIPicture_centerx
real array s__UIPicture_centery
real array s__UIPicture_width
real array s__UIPicture_height
real array s__UIPicture_z
unit array s__UIPicture_picture
boolean array s__UIPicture_displayed
integer array s__UIPicture_texture
constant integer si__UIText=10
integer si__UIText_F=0
integer si__UIText_I=0
integer array si__UIText_V
integer array s__UIText_customValue
unit array s__UIText_dummy
integer array s__UIText_AllShow
integer s__UIText_CountShow= 0
integer array s__UIText_index
integer array s__UIText_camera
real array s__UIText_minx
real array s__UIText_maxy
real array s__UIText_z
texttag array s__UIText_text
boolean array s__UIText_displayed
constant integer si__Interface=11
constant integer s__Interface_DUMMY_TYPE= 'uidm'
constant integer s__Interface_WINDOW_DUMMY= 'uiwn'
constant integer s__Interface_RACE_BORDERS_START= 'D201'
constant boolean s__Interface_LEFT_CLICK_TIMER= true
constant real s__Interface_LEFT_CLICK_TIMER_RATE= 0.01
constant real s__Interface_LEFT_CLICK_DELAY= 0.6
constant integer s__Interface_DESTROYER_FORM_ID= 'Aave'
constant integer s__Interface_LOCUST_ID= 'Aloc'
constant integer s__Interface_SKIN_CHANGE_ABILITY= 'Skin'
constant integer s__Interface_GHOST_ABILITY= 'Aeth'
constant player s__Interface_PLAYER= CAMERA_DUMMY_PLAYER
integer array s__TimerUtils__data
timer array s__TimerUtils__tT
trigger st__UnitDex_Remove
trigger array st___prototype6
unit f__arg_unit1
boolean f__arg_boolean1
boolean f__result_boolean

endglobals


//Generated allocator of UIText
function s__UIText__allocate takes nothing returns integer
 local integer this=si__UIText_F
    if (this!=0) then
        set si__UIText_F=si__UIText_V[this]
    else
        set si__UIText_I=si__UIText_I+1
        set this=si__UIText_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__UIText_V[this]=-1
 return this
endfunction

//Generated destructor of UIText
function s__UIText_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__UIText_V[this]!=-1) then
        return
    endif
    set si__UIText_V[this]=si__UIText_F
    set si__UIText_F=this
endfunction

//Generated allocator of UIPicture
function s__UIPicture__allocate takes nothing returns integer
 local integer this=si__UIPicture_F
    if (this!=0) then
        set si__UIPicture_F=si__UIPicture_V[this]
    else
        set si__UIPicture_I=si__UIPicture_I+1
        set this=si__UIPicture_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__UIPicture_V[this]=-1
 return this
endfunction

//Generated destructor of UIPicture
function s__UIPicture_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__UIPicture_V[this]!=-1) then
        return
    endif
    set si__UIPicture_V[this]=si__UIPicture_F
    set si__UIPicture_F=this
endfunction

//Generated allocator of UIButton
function s__UIButton__allocate takes nothing returns integer
 local integer this=si__UIButton_F
    if (this!=0) then
        set si__UIButton_F=si__UIButton_V[this]
    else
        set si__UIButton_I=si__UIButton_I+1
        set this=si__UIButton_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__UIButton_V[this]=-1
 return this
endfunction

//Generated destructor of UIButton
function s__UIButton_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__UIButton_V[this]!=-1) then
        return
    endif
    set si__UIButton_V[this]=si__UIButton_F
    set si__UIButton_F=this
endfunction

//Generated allocator of Camera__CamInit
function s__Camera__CamInit__allocate takes nothing returns integer
 local integer this=si__Camera__CamInit_F
    if (this!=0) then
        set si__Camera__CamInit_F=si__Camera__CamInit_V[this]
    else
        set si__Camera__CamInit_I=si__Camera__CamInit_I+1
        set this=si__Camera__CamInit_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Camera__CamInit_V[this]=-1
 return this
endfunction

//Generated destructor of Camera__CamInit
function s__Camera__CamInit_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Camera__CamInit_V[this]!=-1) then
        return
    endif
    set si__Camera__CamInit_V[this]=si__Camera__CamInit_F
    set si__Camera__CamInit_F=this
endfunction

//Generated allocator of Camera
function s__Camera__allocate takes nothing returns integer
 local integer this=si__Camera_F
    if (this!=0) then
        set si__Camera_F=si__Camera_V[this]
    else
        set si__Camera_I=si__Camera_I+1
        set this=si__Camera_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Camera_V[this]=-1
 return this
endfunction

//Generated destructor of Camera
function s__Camera_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Camera_V[this]!=-1) then
        return
    endif
    set si__Camera_V[this]=si__Camera_F
    set si__Camera_F=this
endfunction

//Generated method caller for UnitDex.Remove
function sc__UnitDex_Remove takes unit u,boolean runEvents returns boolean
    set f__arg_unit1=u
    set f__arg_boolean1=runEvents
    call TriggerEvaluate(st__UnitDex_Remove)
 return f__result_boolean
endfunction

//Generated allocator of MATRIX4
function s__MATRIX4__allocate takes nothing returns integer
 local integer this=si__MATRIX4_F
    if (this!=0) then
        set si__MATRIX4_F=si__MATRIX4_V[this]
    else
        set si__MATRIX4_I=si__MATRIX4_I+1
        set this=si__MATRIX4_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__MATRIX4_V[this]=-1
 return this
endfunction

//Generated destructor of MATRIX4
function s__MATRIX4_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__MATRIX4_V[this]!=-1) then
        return
    endif
    set si__MATRIX4_V[this]=si__MATRIX4_F
    set si__MATRIX4_F=this
endfunction

//Generated allocator of MATRIX3
function s__MATRIX3__allocate takes nothing returns integer
 local integer this=si__MATRIX3_F
    if (this!=0) then
        set si__MATRIX3_F=si__MATRIX3_V[this]
    else
        set si__MATRIX3_I=si__MATRIX3_I+1
        set this=si__MATRIX3_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__MATRIX3_V[this]=-1
 return this
endfunction

//Generated destructor of MATRIX3
function s__MATRIX3_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__MATRIX3_V[this]!=-1) then
        return
    endif
    set si__MATRIX3_V[this]=si__MATRIX3_F
    set si__MATRIX3_F=this
endfunction

//Generated allocator of VECTOR3
function s__VECTOR3__allocate takes nothing returns integer
 local integer this=si__VECTOR3_F
    if (this!=0) then
        set si__VECTOR3_F=si__VECTOR3_V[this]
    else
        set si__VECTOR3_I=si__VECTOR3_I+1
        set this=si__VECTOR3_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__VECTOR3_V[this]=-1
 return this
endfunction

//Generated destructor of VECTOR3
function s__VECTOR3_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__VECTOR3_V[this]!=-1) then
        return
    endif
    set si__VECTOR3_V[this]=si__VECTOR3_F
    set si__VECTOR3_F=this
endfunction
function sc___prototype6_execute takes integer i returns nothing

    call TriggerExecute(st___prototype6[i])
endfunction
function sc___prototype6_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype6[i])

endfunction

//library PlayerUtils:




     
       

   




   
        // similar to Player(#)
        function s__User_fromIndex takes integer i returns integer
            return (i)
        endfunction
   
        // similar to GetLocalPlayer
        function s__User_fromLocal takes nothing returns integer
            return (s__User_LocalId)
        endfunction
   
        // access active players array
        function s__User_fromPlaying takes integer index returns integer
            return s__User_PlayingPlayer[index]
        endfunction
   
        function s__User__staticgetindex takes player p returns integer
            return (GetPlayerId(p))
        endfunction
   
        function s__User_toPlayer takes integer this returns player
            return s__User_handle[this]
        endfunction
     
        function s__User__get_name takes integer this returns string



                return GetPlayerName(s__User_handle[this])

        endfunction
   
        function s__User__set_name takes integer this,string newName returns nothing
            call SetPlayerName(s__User_handle[this], newName)





        endfunction
   
        function s__User__get_color takes integer this returns playercolor



                return GetPlayerColor(s__User_handle[this])

        endfunction
   
        function s__User__get_hex takes integer this returns string
            return PlayerUtils__OriginalHex[GetHandleId((GetPlayerColor(s__User_handle[(this)])))] // INLINED!!
        endfunction
   
        function s__User__set_color takes integer this,playercolor c returns nothing
            call SetPlayerColor(s__User_handle[this], c)
       








        endfunction
   
        function s__User__get_defaultColor takes integer this returns playercolor
            return s__User_Color[this]
        endfunction
   
        function s__User__get_nameColored takes integer this returns string
            return (PlayerUtils__OriginalHex[GetHandleId((GetPlayerColor(s__User_handle[((this))])))]) + (GetPlayerName(s__User_handle[(this)])) + "|r" // INLINED!!
        endfunction
   
        function s__User_colorUnits takes integer this,playercolor c returns nothing
            local unit u
       
            call GroupEnumUnitsOfPlayer(s__User_ENUM_GROUP, s__User_handle[this], null)
       
            loop
                set u=FirstOfGroup(s__User_ENUM_GROUP)
                exitwhen u == null
                call SetUnitColor(u, c)
                call GroupRemoveUnit(s__User_ENUM_GROUP, u)
            endloop
        endfunction
   
        function s__User_onLeave takes nothing returns boolean
            local integer p= (GetPlayerId((GetTriggerPlayer()))) // INLINED!!
            local integer i= s__User_PlayingPlayerIndex[s__User_id[p]]
       
            // clean up
            call ForceRemovePlayer(FORCE_PLAYING, (s__User_handle[(p)])) // INLINED!!
       
            // recycle index
            set s__User_AmountPlaying=s__User_AmountPlaying - 1
            set s__User_PlayingPlayerIndex[i]=s__User_PlayingPlayerIndex[s__User_AmountPlaying]
            set s__User_PlayingPlayer[i]=s__User_PlayingPlayer[s__User_AmountPlaying]
           
            if ( s__User_AmountPlaying == 1 ) then
                set s__User_next[s__User_prev[p]]=s__User_NULL
                set s__User_prev[s__User_next[p]]=s__User_NULL
            else
                set s__User_next[s__User_prev[p]]=s__User_next[p]
                set s__User_prev[s__User_next[p]]=s__User_prev[p]
            endif

            set s__User_last=s__User_PlayingPlayer[s__User_AmountPlaying]
           
            set s__User_isPlaying[p]=false
       
            return false
        endfunction
   
//Implemented from module PlayerUtils__PlayerUtilsInit:
        function s__User_PlayerUtils__PlayerUtilsInit__onInit takes nothing returns nothing
            local trigger t= CreateTrigger()
            local integer i= 0
            local integer p
       
            set s__User_Local=GetLocalPlayer()
            set s__User_LocalId=GetPlayerId(s__User_Local)
       
            set PlayerUtils__OriginalHex[0]="|cffff0303"
            set PlayerUtils__OriginalHex[1]="|cff0042ff"
            set PlayerUtils__OriginalHex[2]="|cff1ce6b9"
            set PlayerUtils__OriginalHex[3]="|cff540081"
            set PlayerUtils__OriginalHex[4]="|cfffffc01"
            set PlayerUtils__OriginalHex[5]="|cfffe8a0e"
            set PlayerUtils__OriginalHex[6]="|cff20c000"
            set PlayerUtils__OriginalHex[7]="|cffe55bb0"
            set PlayerUtils__OriginalHex[8]="|cff959697"
            set PlayerUtils__OriginalHex[9]="|cff7ebff1"
            set PlayerUtils__OriginalHex[10]="|cff106246"
            set PlayerUtils__OriginalHex[11]="|cff4e2a04"
         
            set s__User_first=s__User_NULL

            loop
                exitwhen i == 12

                set p=(i)
                set s__User_handle[p]=Player(i)
                set s__User_id[p]=i
           
                set s__User_Color[i]=GetPlayerColor(s__User_handle[p])
                set PlayerUtils__CurrentColor[i]=s__User_Color[i]
             
                if ( GetPlayerController(s__User_handle[p]) == MAP_CONTROL_USER and GetPlayerSlotState(s__User_handle[p]) == PLAYER_SLOT_STATE_PLAYING ) then

                    set s__User_PlayingPlayer[s__User_AmountPlaying]=p
                    set s__User_PlayingPlayerIndex[i]=s__User_AmountPlaying
                   
                   set s__User_last=i
                   
                    if ( s__User_first == s__User_NULL ) then
                        set s__User_first=i
                        set s__User_next[(i)]=s__User_NULL
                        set s__User_prev[(i)]=s__User_NULL
                    else
                        set s__User_prev[(i)]=s__User_id[s__User_PlayingPlayer[s__User_AmountPlaying - 1]]
                        set s__User_next[s__User_PlayingPlayer[s__User_AmountPlaying - 1]]=(i)
                        set s__User_next[(i)]=s__User_NULL
                    endif

                    set s__User_isPlaying[p]=true
               
                    call TriggerRegisterPlayerEvent(t, s__User_handle[p], EVENT_PLAYER_LEAVE)
                    call ForceAddPlayer(FORCE_PLAYING, s__User_handle[p])
               
                    set PlayerUtils__Hex[p]=PlayerUtils__OriginalHex[GetHandleId(s__User_Color[i])]
               
                    set s__User_AmountPlaying=s__User_AmountPlaying + 1

                endif
           
                set PlayerUtils__Name[p]=GetPlayerName(s__User_handle[p])
                set s__User_originalName[p]=PlayerUtils__Name[p]
           
                set i=i + 1
            endloop
       
            call TriggerAddCondition(t, Filter(function s__User_onLeave))
        endfunction
   


    //===========================================================================

























//library PlayerUtils ends
//library TimerUtils:
//*********************************************************************
//* TimerUtils (red+blue+orange flavors for 1.24b+) 2.0
//* ----------
//*
//*  To implement it , create a custom text trigger called TimerUtils
//* and paste the contents of this script there.
//*
//*  To copy from a map to another, copy the trigger holding this
//* library to your map.
//*
//* (requires vJass)   More scripts: htt://www.wc3c.net
//*
//* For your timer needs:
//*  * Attaching
//*  * Recycling (with double-free protection)
//*
//* set t=NewTimer()      : Get a timer (alternative to CreateTimer)
//* set t=NewTimerEx(x)   : Get a timer (alternative to CreateTimer), call
//*                            Initialize timer data as x, instead of 0.
//*
//* ReleaseTimer(t)       : Relese a timer (alt to DestroyTimer)
//* SetTimerData(t,2)     : Attach value 2 to timer
//* GetTimerData(t)       : Get the timer's value.
//*                         You can assume a timer's value is 0
//*                         after NewTimer.
//*
//* Multi-flavor:
//*    Set USE_HASH_TABLE to true if you don't want to complicate your life.
//*
//* If you like speed and giberish try learning about the other flavors.
//*
//********************************************************************

//================================================================

    //==================================================================================================
    
    

    //It is dependent on jasshelper's recent inlining optimization in order to perform correctly.
    function SetTimerData takes timer t,integer value returns nothing

            // new blue
            call SaveInteger(TimerUtils__ht, 0, GetHandleId(t), value)
            

















    endfunction

    function GetTimerData takes timer t returns integer

            // new blue
            return LoadInteger(TimerUtils__ht, 0, GetHandleId(t))
            

















    endfunction

    //==========================================================================================

    //==========================================================================================
    // I needed to decide between duplicating code ignoring the "Once and only once" rule
    // and using the ugly textmacros. I guess textmacros won.
    //

    function NewTimerEx takes integer value returns timer
        if ( TimerUtils__tN == 0 ) then
            if ( not TimerUtils__didinit ) then
                //This extra if shouldn't represent a major performance drawback
                //because QUANTITY rule is not supposed to be broken every day. 
                call TriggerEvaluate(st___prototype6[(1)]) // INLINED!!
                set TimerUtils__tN=TimerUtils__tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
                set s__TimerUtils__tT[0]= CreateTimer()















            endif
        else
            set TimerUtils__tN=TimerUtils__tN - 1
        endif
        call SaveInteger(TimerUtils__ht, 0, GetHandleId((s__TimerUtils__tT[TimerUtils__tN] )), ( value)) // INLINED!!
     return s__TimerUtils__tT[TimerUtils__tN]
    endfunction
    
    function NewTimer takes nothing returns timer
        return NewTimerEx(0)
    endfunction


    //==========================================================================================
    function ReleaseTimer takes timer t returns nothing
        if ( t == null ) then
            return
        endif
        if ( TimerUtils__tN == TimerUtils__ARRAY_SIZE ) then
            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( (LoadInteger(TimerUtils__ht, 0, GetHandleId((t)))) == TimerUtils__HELD ) then // INLINED!!
                return
            endif
            call SaveInteger(TimerUtils__ht, 0, GetHandleId((t )), ( TimerUtils__HELD)) // INLINED!!
            set s__TimerUtils__tT[TimerUtils__tN]= t
            set TimerUtils__tN=TimerUtils__tN + 1
        endif
    endfunction

    function TimerUtils__init takes nothing returns nothing
     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils__didinit ) then
            return
        else
            set TimerUtils__didinit=true
        endif
     

            set TimerUtils__ht=InitHashtable()
            loop
                exitwhen ( i == TimerUtils__QUANTITY )
                set s__TimerUtils__tT[i]= CreateTimer()
                call SaveInteger(TimerUtils__ht, 0, GetHandleId((s__TimerUtils__tT[i] )), ( TimerUtils__HELD)) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils__tN=TimerUtils__QUANTITY










































    endfunction


//library TimerUtils ends
//library UIMath:

    function UIMath_R2I_N takes real r returns integer
        local integer i= R2I(r)
        if ( r < I2R(i) + 0.5 ) then
            return i
        else
            return i + 1
        endif
    endfunction

        
        function s__VECTOR3_New_0 takes nothing returns integer
            local integer this= s__VECTOR3__allocate()
            set s__VECTOR3_x[this]=0
            set s__VECTOR3_y[this]=0
            set s__VECTOR3_z[this]=0
            return this
        endfunction
        
        function s__VECTOR3_New_1 takes real x,real y,real z returns integer
            local integer this= s__VECTOR3__allocate()
            set s__VECTOR3_x[this]=x
            set s__VECTOR3_y[this]=y
            set s__VECTOR3_z[this]=z
            return this
        endfunction
        
        function s__VECTOR3_New_2 takes integer v returns integer
            local integer this= s__VECTOR3__allocate()
            set s__VECTOR3_x[this]=s__VECTOR3_x[v]
            set s__VECTOR3_y[this]=s__VECTOR3_y[v]
            set s__VECTOR3_z[this]=s__VECTOR3_z[v]
            return this
        endfunction
        
        function s__VECTOR3_SetValues takes integer this,real x,real y,real z returns integer
            set s__VECTOR3_x[this]=x
            set s__VECTOR3_y[this]=y
            set s__VECTOR3_z[this]=z
            return this
        endfunction
        
        function s__VECTOR3_Length takes integer this returns real
            return SquareRoot(s__VECTOR3_x[this] * s__VECTOR3_x[this] + s__VECTOR3_y[this] * s__VECTOR3_y[this] + s__VECTOR3_z[this] * s__VECTOR3_z[this])
        endfunction
        
        function s__VECTOR3_LengthSq takes integer this returns real
            return s__VECTOR3_x[this] * s__VECTOR3_x[this] + s__VECTOR3_y[this] * s__VECTOR3_y[this] + s__VECTOR3_z[this] * s__VECTOR3_z[this]
        endfunction
        
        function s__VECTOR3_ToString takes integer this returns string
            return "Vector3 id " + I2S(this) + "\nx = " + R2S(s__VECTOR3_x[this]) + "   y = " + R2S(s__VECTOR3_y[this]) + "   z = " + R2S(s__VECTOR3_z[this])
        endfunction
        

    function Vec3Add takes integer Output,integer v1,integer v2 returns integer
        set s__VECTOR3_x[Output]=s__VECTOR3_x[v1] + s__VECTOR3_x[v2]
        set s__VECTOR3_y[Output]=s__VECTOR3_y[v1] + s__VECTOR3_y[v2]
        set s__VECTOR3_z[Output]=s__VECTOR3_z[v1] + s__VECTOR3_z[v2]
        return Output
    endfunction

    function Vec3Subtract takes integer Output,integer v1,integer v2 returns integer
        set s__VECTOR3_x[Output]=s__VECTOR3_x[v1] - s__VECTOR3_x[v2]
        set s__VECTOR3_y[Output]=s__VECTOR3_y[v1] - s__VECTOR3_y[v2]
        set s__VECTOR3_z[Output]=s__VECTOR3_z[v1] - s__VECTOR3_z[v2]
        return Output
    endfunction
        
    function Vec3Scale takes integer Output,integer v,real r returns integer
        set s__VECTOR3_x[Output]=s__VECTOR3_x[v] * r
        set s__VECTOR3_y[Output]=s__VECTOR3_y[v] * r
        set s__VECTOR3_z[Output]=s__VECTOR3_z[v] * r
        return Output
    endfunction
        
    function Vec3Division takes integer Output,integer v,real r returns integer
        set s__VECTOR3_x[Output]=s__VECTOR3_x[v] / r
        set s__VECTOR3_y[Output]=s__VECTOR3_y[v] / r
        set s__VECTOR3_z[Output]=s__VECTOR3_z[v] / r
        return Output
    endfunction

    function Vec3Length takes integer v returns real
        return SquareRoot(s__VECTOR3_x[v] * s__VECTOR3_x[v] + s__VECTOR3_y[v] * s__VECTOR3_y[v] + s__VECTOR3_z[v] * s__VECTOR3_z[v])
    endfunction

    function Vec3LengthSq takes integer v returns real
        return s__VECTOR3_x[v] * s__VECTOR3_x[v] + s__VECTOR3_y[v] * s__VECTOR3_y[v] + s__VECTOR3_z[v] * s__VECTOR3_z[v]
    endfunction

    function Vec3Normalize takes integer Output,integer v returns integer
        local real len= SquareRoot(s__VECTOR3_x[v] * s__VECTOR3_x[v] + s__VECTOR3_y[v] * s__VECTOR3_y[v] + s__VECTOR3_z[v] * s__VECTOR3_z[v])
        set s__VECTOR3_x[Output]=s__VECTOR3_x[v] / len
        set s__VECTOR3_y[Output]=s__VECTOR3_y[v] / len
        set s__VECTOR3_z[Output]=s__VECTOR3_z[v] / len
        return Output
    endfunction

    function Vec3Dot takes integer v1,integer v2 returns real
        return s__VECTOR3_x[v1] * s__VECTOR3_x[v2] + s__VECTOR3_y[v1] * s__VECTOR3_y[v2] + s__VECTOR3_z[v1] * s__VECTOR3_z[v2]
    endfunction

    function Vec3Cross takes integer Output,integer v1,integer v2 returns integer
        local real y= s__VECTOR3_z[v1] * s__VECTOR3_x[v2] - s__VECTOR3_x[v1] * s__VECTOR3_z[v2]
        local real z= s__VECTOR3_x[v1] * s__VECTOR3_y[v2] - s__VECTOR3_y[v1] * s__VECTOR3_x[v2]
        set s__VECTOR3_x[Output]=s__VECTOR3_y[v1] * s__VECTOR3_z[v2] - s__VECTOR3_z[v1] * s__VECTOR3_y[v2]
        set s__VECTOR3_y[Output]=y
        set s__VECTOR3_z[Output]=z
        return Output
    endfunction

    function Vec3Transform_1 takes integer Output,integer v,integer m returns integer
        local real y= s__VECTOR3_x[v] * s__MATRIX3_m12[m] + s__VECTOR3_y[v] * s__MATRIX3_m22[m] + s__VECTOR3_z[v] * s__MATRIX3_m32[m]
        local real z= s__VECTOR3_x[v] * s__MATRIX3_m13[m] + s__VECTOR3_y[v] * s__MATRIX3_m23[m] + s__VECTOR3_z[v] * s__MATRIX3_m33[m]
        set s__VECTOR3_x[Output]=s__VECTOR3_x[v] * s__MATRIX3_m11[m] + s__VECTOR3_y[v] * s__MATRIX3_m21[m] + s__VECTOR3_z[v] * s__MATRIX3_m31[m]
        set s__VECTOR3_y[Output]=y
        set s__VECTOR3_z[Output]=z
        return Output
    endfunction

    function Vec3Transform_2 takes integer Output,integer v,integer m returns integer
        local real y= s__VECTOR3_x[v] * s__MATRIX4_m12[m] + s__VECTOR3_y[v] * s__MATRIX4_m22[m] + s__VECTOR3_z[v] * s__MATRIX4_m32[m] + s__MATRIX4_m42[m]
        local real z= s__VECTOR3_x[v] * s__MATRIX4_m13[m] + s__VECTOR3_y[v] * s__MATRIX4_m23[m] + s__VECTOR3_z[v] * s__MATRIX4_m33[m] + s__MATRIX4_m43[m]
        local real w= s__VECTOR3_x[v] * s__MATRIX4_m14[m] + s__VECTOR3_y[v] * s__MATRIX4_m24[m] + s__VECTOR3_z[v] * s__MATRIX4_m34[m] + s__MATRIX4_m44[m]
        set s__VECTOR3_x[Output]=( s__VECTOR3_x[v] * s__MATRIX4_m11[m] + s__VECTOR3_y[v] * s__MATRIX4_m21[m] + s__VECTOR3_z[v] * s__MATRIX4_m31[m] + s__MATRIX4_m41[m] ) / w
        set s__VECTOR3_y[Output]=y / w
        set s__VECTOR3_z[Output]=z / w
        return Output
    endfunction


        
        function s__MATRIX3_New_0 takes nothing returns integer
            local integer this= s__MATRIX3__allocate()
            set s__MATRIX3_m11[this]=0
            set s__MATRIX3_m12[this]=0
            set s__MATRIX3_m13[this]=0
            set s__MATRIX3_m21[this]=0
            set s__MATRIX3_m22[this]=0
            set s__MATRIX3_m23[this]=0
            set s__MATRIX3_m31[this]=0
            set s__MATRIX3_m32[this]=0
            set s__MATRIX3_m33[this]=0
            return this
        endfunction
        
        function s__MATRIX3_New_1 takes real r11,real r12,real r13,real r21,real r22,real r23,real r31,real r32,real r33 returns integer
            local integer this= s__MATRIX3__allocate()
            set s__MATRIX3_m11[this]=r11
            set s__MATRIX3_m12[this]=r12
            set s__MATRIX3_m13[this]=r13
            set s__MATRIX3_m21[this]=r21
            set s__MATRIX3_m22[this]=r22
            set s__MATRIX3_m23[this]=r23
            set s__MATRIX3_m31[this]=r31
            set s__MATRIX3_m32[this]=r32
            set s__MATRIX3_m33[this]=r33
            return this
        endfunction
        
        function s__MATRIX3_New_2 takes integer m returns integer
            local integer this= s__MATRIX3__allocate()
            set s__MATRIX3_m11[this]=s__MATRIX3_m11[m]
            set s__MATRIX3_m12[this]=s__MATRIX3_m12[m]
            set s__MATRIX3_m13[this]=s__MATRIX3_m13[m]
            set s__MATRIX3_m21[this]=s__MATRIX3_m21[m]
            set s__MATRIX3_m22[this]=s__MATRIX3_m22[m]
            set s__MATRIX3_m23[this]=s__MATRIX3_m23[m]
            set s__MATRIX3_m31[this]=s__MATRIX3_m31[m]
            set s__MATRIX3_m32[this]=s__MATRIX3_m32[m]
            set s__MATRIX3_m33[this]=s__MATRIX3_m33[m]
            return this
        endfunction
        
        function s__MATRIX3_SetValues takes integer this,real r11,real r12,real r13,real r21,real r22,real r23,real r31,real r32,real r33 returns integer
            set s__MATRIX3_m11[this]=r11
            set s__MATRIX3_m12[this]=r12
            set s__MATRIX3_m13[this]=r13
            set s__MATRIX3_m21[this]=r21
            set s__MATRIX3_m22[this]=r22
            set s__MATRIX3_m23[this]=r23
            set s__MATRIX3_m31[this]=r31
            set s__MATRIX3_m32[this]=r32
            set s__MATRIX3_m33[this]=r33
            return this
        endfunction
     
        function s__MATRIX3_ToString takes integer this returns string
            return "Matrux3 id " + I2S(this) + "\n" + R2S(s__MATRIX3_m11[this]) + "  " + R2S(s__MATRIX3_m12[this]) + "  " + R2S(s__MATRIX3_m13[this]) + "\n" + R2S(s__MATRIX3_m21[this]) + "  " + R2S(s__MATRIX3_m22[this]) + "  " + R2S(s__MATRIX3_m23[this]) + "\n" + R2S(s__MATRIX3_m31[this]) + "  " + R2S(s__MATRIX3_m32[this]) + "  " + R2S(s__MATRIX3_m33[this])
        endfunction
        

    function Matrix3Multiply takes integer Output,integer M1,integer M2 returns integer
        return s__MATRIX3_SetValues(Output,s__MATRIX3_m11[M1] * s__MATRIX3_m11[M2] + s__MATRIX3_m21[M1] * s__MATRIX3_m12[M2] + s__MATRIX3_m31[M1] * s__MATRIX3_m13[M2] , s__MATRIX3_m12[M1] * s__MATRIX3_m11[M2] + s__MATRIX3_m22[M1] * s__MATRIX3_m12[M2] + s__MATRIX3_m32[M1] * s__MATRIX3_m13[M2] , s__MATRIX3_m13[M1] * s__MATRIX3_m11[M2] + s__MATRIX3_m23[M1] * s__MATRIX3_m12[M2] + s__MATRIX3_m33[M1] * s__MATRIX3_m13[M2] , s__MATRIX3_m11[M1] * s__MATRIX3_m21[M2] + s__MATRIX3_m21[M1] * s__MATRIX3_m22[M2] + s__MATRIX3_m31[M1] * s__MATRIX3_m23[M2] , s__MATRIX3_m12[M1] * s__MATRIX3_m21[M2] + s__MATRIX3_m22[M1] * s__MATRIX3_m22[M2] + s__MATRIX3_m32[M1] * s__MATRIX3_m23[M2] , s__MATRIX3_m13[M1] * s__MATRIX3_m21[M2] + s__MATRIX3_m23[M1] * s__MATRIX3_m22[M2] + s__MATRIX3_m33[M1] * s__MATRIX3_m23[M2] , s__MATRIX3_m11[M1] * s__MATRIX3_m31[M2] + s__MATRIX3_m21[M1] * s__MATRIX3_m32[M2] + s__MATRIX3_m31[M1] * s__MATRIX3_m33[M2] , s__MATRIX3_m12[M1] * s__MATRIX3_m31[M2] + s__MATRIX3_m22[M1] * s__MATRIX3_m32[M2] + s__MATRIX3_m32[M1] * s__MATRIX3_m33[M2] , s__MATRIX3_m13[M1] * s__MATRIX3_m31[M2] + s__MATRIX3_m23[M1] * s__MATRIX3_m32[M2] + s__MATRIX3_m33[M1] * s__MATRIX3_m33[M2])
    endfunction

    function Matrix3Scaling takes integer Output,real x,real y,real z returns integer
        return s__MATRIX3_SetValues(Output,x , 0 , 0 , 0 , y , 0 , 0 , 0 , z)
    endfunction

    function Matrix3RotationX takes integer Output,real a returns integer
        return s__MATRIX3_SetValues(Output,1 , 0 , 0 , 0 , Cos(a) , - Sin(a) , 0 , Sin(a) , Cos(a))
    endfunction

    function Matrix3RotationY takes integer Output,real a returns integer
        return s__MATRIX3_SetValues(Output,Cos(a) , 0 , Sin(a) , 0 , 1 , 0 , - Sin(a) , 0 , Cos(a))
    endfunction

    function Matrix3RotationZ takes integer Output,real a returns integer
        return s__MATRIX3_SetValues(Output,Cos(a) , - Sin(a) , 0 , Sin(a) , Cos(a) , 0 , 0 , 0 , 1)
    endfunction

    function Matrix3RotationAxis takes integer Output,integer v,real a returns integer
        local real cosa= Cos(a)
        local real sina= Sin(a)
        return s__MATRIX3_SetValues(Output,cosa + ( 1 - cosa ) * s__VECTOR3_x[v] * s__VECTOR3_x[v] , ( 1 - cosa ) * s__VECTOR3_x[v] * s__VECTOR3_y[v] - sina * s__VECTOR3_z[v] , ( 1 - cosa ) * s__VECTOR3_x[v] * s__VECTOR3_z[v] + sina * s__VECTOR3_y[v] , ( 1 - cosa ) * s__VECTOR3_y[v] * s__VECTOR3_x[v] + sina * s__VECTOR3_z[v] , cosa + ( 1 - cosa ) * s__VECTOR3_y[v] * s__VECTOR3_y[v] , ( 1 - cosa ) * s__VECTOR3_y[v] * s__VECTOR3_z[v] - sina * s__VECTOR3_x[v] , ( 1 - cosa ) * s__VECTOR3_z[v] * s__VECTOR3_x[v] - sina * s__VECTOR3_y[v] , ( 1 - cosa ) * s__VECTOR3_z[v] * s__VECTOR3_y[v] + sina * s__VECTOR3_x[v] , cosa + ( 1 - cosa ) * s__VECTOR3_z[v] * s__VECTOR3_z[v])
    endfunction

    function Matrix3RotationYawPitchRoll takes integer Output,real Yaw,real Pitch,real Roll returns integer
        local real cosa= Cos(Yaw)
        local real sina= Sin(Yaw)
        local real cosb= Cos(Pitch)
        local real sinb= Sin(Pitch)
        local real cosy= Cos(Roll)
        local real siny= Sin(Roll)
        return s__MATRIX3_SetValues(Output,cosa * cosb , cosa * sinb * siny - sina * cosy , cosa * sinb * cosy + sina * siny , sina * cosb , sina * sinb * siny + cosa * cosy , sina * sinb * cosy - cosa * siny , - sinb , cosb * siny , cosb * cosy)
    endfunction

        
        function s__MATRIX4_New_0 takes nothing returns integer
            local integer this= s__MATRIX4__allocate()
            set s__MATRIX4_m11[this]=0
            set s__MATRIX4_m12[this]=0
            set s__MATRIX4_m13[this]=0
            set s__MATRIX4_m14[this]=0
            set s__MATRIX4_m21[this]=0
            set s__MATRIX4_m22[this]=0
            set s__MATRIX4_m23[this]=0
            set s__MATRIX4_m24[this]=0
            set s__MATRIX4_m31[this]=0
            set s__MATRIX4_m32[this]=0
            set s__MATRIX4_m33[this]=0
            set s__MATRIX4_m34[this]=0
            set s__MATRIX4_m41[this]=0
            set s__MATRIX4_m42[this]=0
            set s__MATRIX4_m43[this]=0
            set s__MATRIX4_m44[this]=0
            return this
        endfunction
        
        function s__MATRIX4_New_1 takes real r11,real r12,real r13,real r14,real r21,real r22,real r23,real r24,real r31,real r32,real r33,real r34,real r41,real r42,real r43,real r44 returns integer
            local integer this= s__MATRIX4__allocate()
            set s__MATRIX4_m11[this]=r11
            set s__MATRIX4_m12[this]=r12
            set s__MATRIX4_m13[this]=r13
            set s__MATRIX4_m14[this]=r14
            set s__MATRIX4_m21[this]=r21
            set s__MATRIX4_m22[this]=r22
            set s__MATRIX4_m23[this]=r23
            set s__MATRIX4_m24[this]=r24
            set s__MATRIX4_m31[this]=r31
            set s__MATRIX4_m32[this]=r32
            set s__MATRIX4_m33[this]=r33
            set s__MATRIX4_m34[this]=r34
            set s__MATRIX4_m41[this]=r41
            set s__MATRIX4_m42[this]=r42
            set s__MATRIX4_m43[this]=r43
            set s__MATRIX4_m44[this]=r44
            return this
        endfunction
        
        function s__MATRIX4_New_2 takes integer m returns integer
            local integer this= s__MATRIX4__allocate()
            set s__MATRIX4_m11[this]=s__MATRIX4_m11[m]
            set s__MATRIX4_m12[this]=s__MATRIX4_m12[m]
            set s__MATRIX4_m13[this]=s__MATRIX4_m13[m]
            set s__MATRIX4_m14[this]=s__MATRIX4_m14[m]
            set s__MATRIX4_m21[this]=s__MATRIX4_m21[m]
            set s__MATRIX4_m22[this]=s__MATRIX4_m22[m]
            set s__MATRIX4_m23[this]=s__MATRIX4_m23[m]
            set s__MATRIX4_m24[this]=s__MATRIX4_m24[m]
            set s__MATRIX4_m31[this]=s__MATRIX4_m31[m]
            set s__MATRIX4_m32[this]=s__MATRIX4_m32[m]
            set s__MATRIX4_m33[this]=s__MATRIX4_m33[m]
            set s__MATRIX4_m34[this]=s__MATRIX4_m34[m]
            set s__MATRIX4_m41[this]=s__MATRIX4_m41[m]
            set s__MATRIX4_m42[this]=s__MATRIX4_m42[m]
            set s__MATRIX4_m43[this]=s__MATRIX4_m43[m]
            set s__MATRIX4_m44[this]=s__MATRIX4_m44[m]
            return this
        endfunction
        
        function s__MATRIX4_New_3 takes integer m returns integer
            local integer this= s__MATRIX4__allocate()
            set s__MATRIX4_m11[this]=s__MATRIX3_m11[m]
            set s__MATRIX4_m12[this]=s__MATRIX3_m12[m]
            set s__MATRIX4_m13[this]=s__MATRIX3_m13[m]
            set s__MATRIX4_m14[this]=0
            set s__MATRIX4_m21[this]=s__MATRIX3_m21[m]
            set s__MATRIX4_m22[this]=s__MATRIX3_m22[m]
            set s__MATRIX4_m23[this]=s__MATRIX3_m23[m]
            set s__MATRIX4_m24[this]=0
            set s__MATRIX4_m31[this]=s__MATRIX3_m31[m]
            set s__MATRIX4_m32[this]=s__MATRIX3_m32[m]
            set s__MATRIX4_m33[this]=s__MATRIX3_m33[m]
            set s__MATRIX4_m34[this]=0
            set s__MATRIX4_m41[this]=0
            set s__MATRIX4_m42[this]=0
            set s__MATRIX4_m43[this]=0
            set s__MATRIX4_m44[this]=1
            return this
        endfunction
        
        function s__MATRIX4_SetValues takes integer this,real r11,real r12,real r13,real r14,real r21,real r22,real r23,real r24,real r31,real r32,real r33,real r34,real r41,real r42,real r43,real r44 returns integer
            set s__MATRIX4_m11[this]=r11
            set s__MATRIX4_m12[this]=r12
            set s__MATRIX4_m13[this]=r13
            set s__MATRIX4_m14[this]=r14
            set s__MATRIX4_m21[this]=r21
            set s__MATRIX4_m22[this]=r22
            set s__MATRIX4_m23[this]=r23
            set s__MATRIX4_m24[this]=r24
            set s__MATRIX4_m31[this]=r31
            set s__MATRIX4_m32[this]=r32
            set s__MATRIX4_m33[this]=r33
            set s__MATRIX4_m34[this]=r34
            set s__MATRIX4_m41[this]=r41
            set s__MATRIX4_m42[this]=r42
            set s__MATRIX4_m43[this]=r43
            set s__MATRIX4_m44[this]=r44
            return this
        endfunction
     
        function s__MATRIX4_ToString takes integer this returns string
            return "Matrux4 id " + I2S(this) + "\n" + R2S(s__MATRIX4_m11[this]) + "  " + R2S(s__MATRIX4_m12[this]) + "  " + R2S(s__MATRIX4_m13[this]) + "  " + R2S(s__MATRIX4_m14[this]) + "\n" + R2S(s__MATRIX4_m21[this]) + "  " + R2S(s__MATRIX4_m22[this]) + "  " + R2S(s__MATRIX4_m23[this]) + "  " + R2S(s__MATRIX4_m24[this]) + "\n" + R2S(s__MATRIX4_m31[this]) + "  " + R2S(s__MATRIX4_m32[this]) + "  " + R2S(s__MATRIX4_m33[this]) + "  " + R2S(s__MATRIX4_m34[this]) + "\n" + R2S(s__MATRIX4_m41[this]) + "  " + R2S(s__MATRIX4_m42[this]) + "  " + R2S(s__MATRIX4_m43[this]) + "  " + R2S(s__MATRIX4_m44[this])
        endfunction
        

    function Matrix4Multiply takes integer Output,integer M1,integer M2 returns integer
        return s__MATRIX4_SetValues(Output,s__MATRIX4_m11[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m11[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m11[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m11[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m44[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m44[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m44[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m44[M2])
    endfunction

    function UIMath__Init takes nothing returns nothing
       set s__VECTOR3_Zero=s__VECTOR3_New_0()
       set s__VECTOR3_oneX=s__VECTOR3_New_1(1 , 0 , 0)
       set s__VECTOR3_oneY=s__VECTOR3_New_1(0 , 1 , 0)
       set s__VECTOR3_oneZ=s__VECTOR3_New_1(0 , 0 , 1)
       set s__MATRIX3_Zero=s__MATRIX3_New_0()
       set s__MATRIX3_E=s__MATRIX3_New_1(1 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 1)
       set s__MATRIX4_Zero=s__MATRIX4_New_0()
       set s__MATRIX4_E=s__MATRIX4_New_1(1 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 1)
    endfunction


//library UIMath ends
//library UnitDex:

    ///! external ObjectMerger w3a Adef uDex anam "Detect Leave" ansf "(UnitDex)" aart "" acat "" arac 0 
  

    
    
    function GetUnitId takes unit whichUnit returns integer
        return GetUnitUserData(whichUnit)
    endfunction
    
    function GetUnitById takes integer index returns unit
        return s__UnitDex_Unit[index]
    endfunction
    
    function GetIndexedUnit takes nothing returns unit
        return s__UnitDex_Unit[s__UnitDex_LastIndex]
    endfunction
    
    function GetIndexedUnitId takes nothing returns integer
        return s__UnitDex_LastIndex
    endfunction
    
    function IsUnitIndexed takes unit u returns boolean
        return ( (s__UnitDex_Unit[((GetUnitUserData((u))))]) != null ) // INLINED!!
    endfunction
    
    function UnitDexEnable takes boolean flag returns nothing
        set s__UnitDex_Enabled=flag
    endfunction
    
    function IsIndexingEnabled takes nothing returns boolean
        return s__UnitDex_Enabled
    endfunction
    
    function RegisterUnitIndexEvent takes boolexpr func,integer eventtype returns triggercondition
        return TriggerAddCondition(UnitDex__IndexTrig[eventtype], func)
    endfunction
    
    function RemoveUnitIndexEvent takes triggercondition c,integer eventtype returns nothing
        call TriggerRemoveCondition(UnitDex__IndexTrig[eventtype], c)
    endfunction
    
    function TriggerRegisterUnitIndexEvent takes trigger t,integer eventtype returns nothing
        call TriggerRegisterVariableEvent(t, "UnitDex__E", EQUAL, eventtype)
    endfunction
    
    function OnUnitIndex takes code func returns triggercondition
        return TriggerAddCondition(UnitDex__IndexTrig[EVENT_UNIT_INDEX], Filter(func))
    endfunction

    function OnUnitDeindex takes code func returns triggercondition
        return TriggerAddCondition(UnitDex__IndexTrig[EVENT_UNIT_DEINDEX], Filter(func))
    endfunction
    
    function UnitDexRemove takes unit u,boolean runEvents returns boolean
        return sc__UnitDex_Remove(u , runEvents)
    endfunction
    
    
    
    
        
        
//Implemented from module UnitDex__UnitDexConfig:
    
        // The raw code of the leave detection ability.
        
        // Allow debug messages (debug mode must also be on)
        
        // Uncomment the lines below to define a filter for units being indexed
        
        
        
        
        
//Implemented from module UnitDex__UnitDexCore:
    
        function s__UnitDex_Remove takes unit u,boolean runEvents returns boolean
            local integer i
            
            if ( ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) ) then // INLINED!!
                set i=(GetUnitUserData((u))) // INLINED!!
                set s__UnitDex_List[i]=UnitDex__Index
                set UnitDex__Index=i
                
                call GroupRemoveUnit(s__UnitDex_Group, u)
                call SetUnitUserData(u, 0)
            
                if ( runEvents ) then
                    set s__UnitDex_LastIndex=i
                    set UnitDex__E=EVENT_UNIT_DEINDEX
                    call TriggerEvaluate(UnitDex__IndexTrig[EVENT_UNIT_DEINDEX])
                    set UnitDex__E=- 1
                endif
                
                set s__UnitDex_Unit[i]=null
                set s__UnitDex_Count=s__UnitDex_Count - 1
                
                return true
            endif
            
            return false
        endfunction
        
        function s__UnitDex_UnitDex__UnitDexCore__onGameStart takes nothing returns nothing
            local integer i= 0

                local group ENUM_GROUP= CreateGroup()

            
            // Index preplaced units
            loop
                call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(i), UnitDex__FilterEnter)
                
                set i=i + 1
                
                exitwhen i == bj_MAX_PLAYER_SLOTS
            endloop
            

                call DestroyGroup(ENUM_GROUP)
                set ENUM_GROUP=null

            
            // run init triggers
            set i=1
            loop
                exitwhen i > s__UnitDex_Counter
                
                set s__UnitDex_LastIndex=i
                
                call TriggerEvaluate(UnitDex__IndexTrig[EVENT_UNIT_INDEX])
                set UnitDex__E=EVENT_UNIT_INDEX
                set UnitDex__E=- 1
                
                set i=i + 1
            endloop

            set s__UnitDex_LastIndex=s__UnitDex_Counter
            set s__UnitDex_Initialized=true
            set UnitDex__FilterEnter=null
            
            call DestroyTimer(GetExpiredTimer())
        endfunction
        
        function s__UnitDex_UnitDex__UnitDexCore__onEnter takes nothing returns boolean
            local unit u= GetFilterUnit()
            local integer i= (GetUnitUserData((u))) // INLINED!!
            local integer t= UnitDex__Index
            
            if ( i == 0 and s__UnitDex_Enabled ) then
                
                // If a filter was defined pass the unit through it.






                
                // Handle debugging







                
                // Add to group of indexed units
                call GroupAddUnit(s__UnitDex_Group, u)
                
                // Give unit the leave detection ability
                call UnitAddAbility(u, s__UnitDex_DETECT_LEAVE_ABILITY)
                call UnitMakeAbilityPermanent(u, true, s__UnitDex_DETECT_LEAVE_ABILITY)
                
                // Allocate index
                if ( UnitDex__Index != 0 ) then
                    set UnitDex__Index=s__UnitDex_List[t]
                else
                    set s__UnitDex_Counter=s__UnitDex_Counter + 1
                    set t=s__UnitDex_Counter
                endif
                
                set s__UnitDex_List[t]=- 1
                set s__UnitDex_LastIndex=t
                set s__UnitDex_Unit[t]=u
                set s__UnitDex_Count=s__UnitDex_Count + 1
                
                // Store the index
                call SetUnitUserData(u, t)
                
                if ( s__UnitDex_Initialized ) then
                    // Execute custom events registered with RegisterUnitIndexEvent
                    call TriggerEvaluate(UnitDex__IndexTrig[EVENT_UNIT_INDEX])
                    
                    // Handle TriggerRegisterUnitIndexEvent
                    set UnitDex__E=EVENT_UNIT_INDEX

                    // Reset so the event can occur again
                    set UnitDex__E=- 1
                endif
            endif
            
            set u=null
            
            return false
        endfunction

        function s__UnitDex_UnitDex__UnitDexCore__onLeave takes nothing returns boolean
            local unit u
            local integer i
            
            // Check if order is undefend.
            if ( s__UnitDex_Enabled and GetIssuedOrderId() == 852056 ) then
                
                set u=GetTriggerUnit()
                
                // If unit was killed (not removed) then don't continue
                if ( GetUnitAbilityLevel(u, s__UnitDex_DETECT_LEAVE_ABILITY) != 0 ) then
                    set u=null
                    return false
                endif
                
                set i=(GetUnitUserData((u))) // INLINED!!

                // If unit has been indexed then deindex it
                if ( i > 0 and i <= s__UnitDex_Counter and u == (s__UnitDex_Unit[(i)]) ) then // INLINED!!
                    
                    // Recycle the index
                    set s__UnitDex_List[i]=UnitDex__Index
                    set UnitDex__Index=i
                    set s__UnitDex_LastIndex=i
                    
                    // Remove to group of indexed units
                    call GroupRemoveUnit(s__UnitDex_Group, u)
                
                    // Execute custom events without any associated triggers
                    call TriggerEvaluate(UnitDex__IndexTrig[EVENT_UNIT_DEINDEX])
                    
                    // Handle TriggerRegisterUnitIndexEvent
                    set UnitDex__E=EVENT_UNIT_DEINDEX
                    
                    // Remove entry
                    call SetUnitUserData(u, 0)
                    set s__UnitDex_Unit[i]=null
                    
                    // Decrement unit count
                    set s__UnitDex_Count=s__UnitDex_Count - 1
               
                    // Reset so the event can occur again
                    set UnitDex__E=- 1
                endif
                
                set u=null
            endif
            
            return false
        endfunction
        
        function s__UnitDex_UnitDex__UnitDexCore__onInit takes nothing returns nothing
            local trigger t= CreateTrigger()
            local integer i= 0
            local player p
            local unit u
            

                local region reg= CreateRegion()
                local rect world= GetWorldBounds()

            
            set UnitDex__FilterEnter=Filter(function s__UnitDex_UnitDex__UnitDexCore__onEnter)
            
            // Begin to index units when they enter the map



                call RegionAddRect(reg, world)
                call TriggerRegisterEnterRegion(CreateTrigger(), reg, UnitDex__FilterEnter)
                call RemoveRect(world)
                set world=null

            
            call TriggerAddCondition(t, Filter(function s__UnitDex_UnitDex__UnitDexCore__onLeave))
            
            set UnitDex__IndexTrig[EVENT_UNIT_INDEX]=CreateTrigger()
            set UnitDex__IndexTrig[EVENT_UNIT_DEINDEX]=CreateTrigger()
            
            loop
                set p=Player(i)
                
                // Detect "undefend"
                call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                
                // Hide the detect ability from players
                call SetPlayerAbilityAvailable(p, s__UnitDex_DETECT_LEAVE_ABILITY, false)
                
                set i=i + 1
                exitwhen i == bj_MAX_PLAYER_SLOTS
            endloop
            
            call TimerStart(CreateTimer(), 0, false, function s__UnitDex_UnitDex__UnitDexCore__onGameStart)
        endfunction
    
    
    
     
    

//library UnitDex ends
//library Camera:


    function GetTerrainZ takes real x,real y returns real
        call MoveLocation(Camera_DummyLoc, x, y)
        return GetLocationZ(Camera_DummyLoc)
    endfunction
    
    function GetCameraDeltaZ takes nothing returns real
        return Camera__DeltaZ
    endfunction
    
    function Camera__Matrix4Perspective1 takes integer Output,real fovy,real Aspect,real zn,real zf returns integer
        return s__MATRIX4_SetValues(Output,2 * zn / fovy , 0 , 0 , 0 , 0 , 2 * zn / Aspect , 0 , 0 , 0 , 0 , zf / ( zf - zn ) , 1 , 0 , 0 , zn * zf / ( zn - zf ) , 0)
    endfunction

    function Camera__Matrix4Perspective2 takes integer Output,real n,real f,real r,real l,real t,real b returns integer
        return s__MATRIX4_SetValues(Output,2 * n / ( r - l ) , 0 , ( r + l ) / ( r - l ) , 0 , 0 , 2 * n / ( t - b ) , ( t + b ) / ( t - b ) , 0 , 0 , 0 , - ( f + n ) / ( f - n ) , - 2 * f * n / ( f - n ) , 0 , 0 , - 1 , 0)
    endfunction

    function Camera__Matrix4Look takes integer Output,integer PosCamera,integer AxisX,integer AxisY,integer AxisZ returns integer
        return s__MATRIX4_SetValues(Output,s__VECTOR3_x[AxisX] , s__VECTOR3_x[AxisY] , s__VECTOR3_x[AxisZ] , 0 , s__VECTOR3_y[AxisX] , s__VECTOR3_y[AxisY] , s__VECTOR3_y[AxisZ] , 0 , s__VECTOR3_z[AxisX] , s__VECTOR3_z[AxisY] , s__VECTOR3_z[AxisZ] , 0 , - Vec3Dot(AxisX , PosCamera) , - Vec3Dot(AxisY , PosCamera) , - Vec3Dot(AxisZ , PosCamera) , 1)
    endfunction

        
        function s__Camera_win2World takes integer this,real X,real Y,real Range returns integer
            local integer Output= s__VECTOR3__allocate()
            set s__VECTOR3_x[Output]=s__VECTOR3_x[s__Camera_eye[this]] + s__VECTOR3_x[s__Camera_axisZ[this]] * Range + X * s__VECTOR3_x[s__Camera_axisX[this]] * SCREEN_WIDTH * Range + Y * s__VECTOR3_x[s__Camera_axisY[this]] * SCREEN_HEIGHT * Range
            set s__VECTOR3_y[Output]=s__VECTOR3_y[s__Camera_eye[this]] + s__VECTOR3_y[s__Camera_axisZ[this]] * Range + X * s__VECTOR3_y[s__Camera_axisX[this]] * SCREEN_WIDTH * Range + Y * s__VECTOR3_y[s__Camera_axisY[this]] * SCREEN_HEIGHT * Range
            set s__VECTOR3_z[Output]=s__VECTOR3_z[s__Camera_eye[this]] + s__VECTOR3_z[s__Camera_axisZ[this]] * Range + X * s__VECTOR3_z[s__Camera_axisX[this]] * SCREEN_WIDTH * Range + Y * s__VECTOR3_z[s__Camera_axisY[this]] * SCREEN_HEIGHT * Range
            return Output
        endfunction

        function s__Camera_world2Win takes integer this,real X,real Y,real Z returns integer
            local integer Pos= s__VECTOR3_New_1(X , Y , Z)
            local boolean b
            call Vec3Transform_2(Pos , Pos , s__Camera_view[this])
            set b=s__VECTOR3_z[Pos] < 0
            call Vec3Transform_2(Pos , Pos , s__Camera_projection[this])
            if b then
                set s__VECTOR3_z[Pos]=- s__VECTOR3_z[Pos]
            endif
            return Pos
        endfunction
        
        function s__Camera_updateDistanceYawPitch takes integer this returns nothing
            local real dx= s__VECTOR3_x[s__Camera_at[this]] - s__VECTOR3_x[s__Camera_eye[this]]
            local real dy= s__VECTOR3_y[s__Camera_at[this]] - s__VECTOR3_y[s__Camera_eye[this]]
            local real dz= s__VECTOR3_z[s__Camera_at[this]] - s__VECTOR3_z[s__Camera_eye[this]]
            local real len2d
            set s__Camera_distance[this]=SquareRoot(dx * dx + dy * dy + dz * dz)
            set s__Camera_yaw[this]=Atan2(dy, dx)
            set len2d=SquareRoot(dx * dx + dy * dy)
            set s__Camera_pitch[this]=Atan2(dz, len2d)
        endfunction
        
        function s__Camera_updateAxisMatrix takes integer this returns nothing
            local integer mat
            call Vec3Normalize(s__Camera_axisZ[this] , Vec3Subtract(s__Camera_axisZ[this] , s__Camera_at[this] , s__Camera_eye[this]))
            set mat=Matrix3RotationAxis(s__MATRIX3__allocate() , s__Camera_axisZ[this] , - s__Camera_roll[this])
            call Vec3Normalize(s__Camera_axisX[this] , Vec3Cross(s__Camera_axisX[this] , s__Camera_axisZ[this] , s__VECTOR3_oneZ))
            call Vec3Transform_1(s__Camera_axisY[this] , Vec3Cross(s__Camera_axisY[this] , s__Camera_axisX[this] , s__Camera_axisZ[this]) , mat)
            call Vec3Transform_1(s__Camera_axisX[this] , s__Camera_axisX[this] , mat)
            call Camera__Matrix4Look(s__Camera_view[this] , s__Camera_eye[this] , s__Camera_axisX[this] , s__Camera_axisY[this] , s__Camera_axisZ[this])
            call s__MATRIX3_deallocate(mat)
        endfunction

        function s__Camera_applyCameraForPlayer takes integer this,player p,boolean ignoreChange returns boolean
            if GetLocalPlayer() == p then
                call SetCameraField(CAMERA_FIELD_ROTATION, s__Camera_yaw[this] * bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, s__Camera_pitch[this] * bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_ROLL, s__Camera_roll[this] * bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, s__Camera_distance[this], 0)
                call SetCameraTargetController(Camera_DummyUnit[GetPlayerId(p)], s__VECTOR3_x[s__Camera_at[this]], s__VECTOR3_y[s__Camera_at[this]], false)
                call SetCameraField(CAMERA_FIELD_ZOFFSET, s__VECTOR3_z[s__Camera_at[this]] - Camera__DeltaZ, 0)
            endif
            if s__Camera_change[this] or ignoreChange then
                set s__Camera_change[this]=false
                return true
            endif
            return false
        endfunction

        function s__Camera_setPosition takes integer this,real x,real y,real z returns nothing
            local real dx= x - s__VECTOR3_x[s__Camera_at[this]]
            local real dy= y - s__VECTOR3_y[s__Camera_at[this]]
            local real dz= z - s__VECTOR3_z[s__Camera_at[this]]
            set s__VECTOR3_x[s__Camera_eye[this]]=s__VECTOR3_x[s__Camera_eye[this]] + dx
            set s__VECTOR3_y[s__Camera_eye[this]]=s__VECTOR3_y[s__Camera_eye[this]] + dy
            set s__VECTOR3_z[s__Camera_eye[this]]=s__VECTOR3_z[s__Camera_eye[this]] + dz
            set s__VECTOR3_x[s__Camera_at[this]]=x
            set s__VECTOR3_y[s__Camera_at[this]]=y
            set s__VECTOR3_z[s__Camera_at[this]]=z
            set s__Camera_change[this]=true
        endfunction
        
        function s__Camera_setEyeAndAt takes integer this,real ex,real ey,real ez,real tx,real ty,real tz returns nothing
            set s__VECTOR3_x[s__Camera_eye[this]]=ex
            set s__VECTOR3_y[s__Camera_eye[this]]=ey
            set s__VECTOR3_z[s__Camera_eye[this]]=ez
            set s__VECTOR3_x[s__Camera_at[this]]=tx
            set s__VECTOR3_y[s__Camera_at[this]]=ty
            set s__VECTOR3_z[s__Camera_at[this]]=tz
            call s__Camera_updateDistanceYawPitch(this)
            call s__Camera_updateAxisMatrix(this)
            set s__Camera_change[this]=true
        endfunction
        
        function s__Camera_setYawPitchRoll takes integer this,real yaw,real pitch,real roll,boolean EyeLock returns nothing
            local real Z= s__Camera_distance[this] * Sin(pitch)
            local real XY= s__Camera_distance[this] * Cos(pitch)
            local real X= XY * Cos(yaw)
            local real Y= XY * Sin(yaw)
            set s__Camera_yaw[this]=yaw
            set s__Camera_pitch[this]=pitch
            set s__Camera_roll[this]=roll
            if EyeLock then
                set s__VECTOR3_x[s__Camera_at[this]]=s__VECTOR3_x[s__Camera_eye[this]] + X
                set s__VECTOR3_y[s__Camera_at[this]]=s__VECTOR3_y[s__Camera_eye[this]] + Y
                set s__VECTOR3_z[s__Camera_at[this]]=s__VECTOR3_z[s__Camera_eye[this]] + Z
            else
                set s__VECTOR3_x[s__Camera_eye[this]]=s__VECTOR3_x[s__Camera_at[this]] - X
                set s__VECTOR3_y[s__Camera_eye[this]]=s__VECTOR3_y[s__Camera_at[this]] - Y
                set s__VECTOR3_z[s__Camera_eye[this]]=s__VECTOR3_z[s__Camera_at[this]] - Z
            endif
            call s__Camera_updateAxisMatrix(this)
            set s__Camera_change[this]=true
        endfunction
        
        function s__Camera_create takes nothing returns integer
            local integer this= s__Camera__allocate()
            
            set s__Camera_customValue[this]=0
            set s__Camera_change[this]=true
            set s__Camera_eye[this]=s__VECTOR3_New_1(0.0 , - 922.668 , Camera__DeltaZ + 1367.912)
            set s__Camera_at[this]=s__VECTOR3_New_1(0 , 0 , Camera__DeltaZ)
            set s__Camera_distance[this]=0
            set s__Camera_yaw[this]=0
            set s__Camera_pitch[this]=0
            set s__Camera_roll[this]=0
            set s__Camera_axisX[this]=s__VECTOR3__allocate()
            set s__Camera_axisY[this]=s__VECTOR3__allocate()
            set s__Camera_axisZ[this]=s__VECTOR3__allocate()
            set s__Camera_view[this]=s__MATRIX4__allocate()
            set s__Camera_projection[this]=Camera__Matrix4Perspective2(s__MATRIX4__allocate() , 0.5 , 10000 , - SCREEN_WIDTH / 2 , SCREEN_WIDTH / 2 , - SCREEN_HEIGHT / 2 , SCREEN_HEIGHT / 2)
            call s__Camera_updateDistanceYawPitch(this)
            call s__Camera_updateAxisMatrix(this)
            
            return this
        endfunction
        
        function s__Camera_destroy takes integer this returns nothing
            call s__VECTOR3_deallocate(s__Camera_eye[this])
            call s__VECTOR3_deallocate(s__Camera_at[this])
            call s__VECTOR3_deallocate(s__Camera_axisX[this])
            call s__VECTOR3_deallocate(s__Camera_axisY[this])
            call s__VECTOR3_deallocate(s__Camera_axisZ[this])
            call s__MATRIX4_deallocate(s__Camera_view[this])
            call s__MATRIX4_deallocate(s__Camera_projection[this])
            call s__Camera_destroy(this)
        endfunction
        

    
//Implemented from module Camera__CamInitModule:
        function s__Camera__CamInit_Camera__CamInitModule__onInit takes nothing returns nothing
            local integer i= 0
            local integer user
            
            loop
                exitwhen i == s__User_AmountPlaying
                
                set user=(s__User_PlayingPlayer[(i)]) // INLINED!!
                
                set Camera_DummyUnit[s__User_id[user]]=CreateUnit(CAMERA_DUMMY_PLAYER, CAMERA_DUMMY_TYPE, 0, 0, 0)
                call ShowUnit(Camera_DummyUnit[s__User_id[user]], false)
                call PauseUnit(Camera_DummyUnit[s__User_id[user]], true)
                
                set i=i + 1
            endloop
            
            // init delta z
            call SetCameraPosition(CHECK_DELTAZ_X, CHECK_DELTAZ_Y)
            set Camera__DeltaZ=GetCameraTargetPositionZ() - 6
        endfunction
    

//library Camera ends
//library UserInterface:


    // configuration
    // end configuration


    function GetTriggerButton takes nothing returns integer
        return UserInterface__ClickedButton
    endfunction
    
    function GetClickingPlayer takes nothing returns player
        return UserInterface__ClickingPlayer
    endfunction

    function UserInterface_Eval takes filterfunc func returns boolean
        call TriggerClearConditions(UserInterface__Trig)
        call TriggerAddCondition(UserInterface__Trig, func)
        return TriggerEvaluate(UserInterface__Trig)
    endfunction

    function UserInterface_GetTerrainZ takes real x,real y returns real
        call MoveLocation(UserInterface__DummyLoc, x, y)
        return GetLocationZ(UserInterface__DummyLoc)
    endfunction
    
    // adjusts 
    function UserInterface_FindModelAnimIndex takes real w,real h,real z returns integer
        local real W= w * SCREEN_WIDTH * z
        local real H= h * SCREEN_HEIGHT * z
        local real anim
        if ( H < W ) then
            set anim=10 * ( W / H - 1 )
            return UIMath_R2I_N(anim)
        else
            set anim=10 * ( H / W - 1 )
            if anim >= 0.5 then
                return 100 + UIMath_R2I_N(anim)
            endif
        endif
        return 0
    endfunction

    function UserInterface_FindModelSize takes real w,real h,real z returns real
        local real W= w * SCREEN_WIDTH * z
        local real H= h * SCREEN_HEIGHT * z
        if ( H < W ) then
            return 0.5 * H
        endif
        return 0.5 * W
    endfunction

    function UserInterface__LocalReal takes player p,real forPlayer,real default returns real
        if ( s__User_Local == p ) then
            return forPlayer
        endif
        return default
    endfunction
    
    function UserInterface_ApplySkin takes unit u,integer texture returns boolean
        local boolean out= false
        
        if ( texture != 0 ) then
            
            call UnitAddAbility(u, s__Interface_SKIN_CHANGE_ABILITY)
            set UserInterface_DummyTree=CreateDestructable(texture, GetUnitX(u), GetUnitY(u), 0, 0, 1)
            set out=IssueTargetOrder(u, "grabtree", UserInterface_DummyTree)
            call RemoveDestructable(UserInterface_DummyTree)
            set UserInterface_DummyTree=null
            call UnitRemoveAbility(u, s__Interface_SKIN_CHANGE_ABILITY)
        endif
        
        return out
    endfunction




        
        
        
        
        function s__UIButton_create takes real minx,real maxy,real W,real H,real z,integer texture returns integer
            local integer this= s__UIButton__allocate()

            set s__UIButton_texture[this]=texture
            set s__UIButton_customValue[this]=0
            set s__UIButton_camera[this]=0
            set s__UIButton_width[this]=W
            set s__UIButton_height[this]=H
            set s__UIButton_minx[this]=minx
            set s__UIButton_maxx[this]=minx + W
            set s__UIButton_maxy[this]=maxy
            set s__UIButton_miny[this]=maxy - H
            set s__UIButton_z[this]=100.2 + z
            set s__UIButton_centerx[this]=minx + W / 2.0
            set s__UIButton_centery[this]=maxy - H / 2.0
            set s__UIButton_displayed[this]=false
            set s__UIButton_scale[this]=UserInterface_FindModelSize(W , H , s__UIButton_z[this])
            set s__UIButton_triggerL[this]=null
            set s__UIButton_triggerR[this]=null
            set s__UIButton_onLeftClick[this]=null
            set s__UIButton_onRightClick[this]=null
            set s__UIButton_selectUnit[this]=null
            set s__UIButton_picture[this]=CreateUnit(s__Interface_PLAYER, s__Interface_DUMMY_TYPE, 0, 0, 0)
            
            // apply texture
            call UserInterface_ApplySkin(s__UIButton_picture[this] , texture)
            
            set s__UIButton_animIndex[this]=UserInterface_FindModelAnimIndex(W , H , s__UIButton_z[this])
            call SetUnitAnimationByIndex(s__UIButton_picture[this], s__UIButton_animIndex[this])
            call UnitAddAbility(s__UIButton_picture[this], s__Interface_DESTROYER_FORM_ID)
            call UnitRemoveAbility(s__UIButton_picture[this], s__Interface_DESTROYER_FORM_ID)
            call UnitAddAbility(s__UIButton_picture[this], s__Interface_SKIN_CHANGE_ABILITY)
            call UnitAddAbility(s__UIButton_picture[this], s__Interface_GHOST_ABILITY)
            
            set s__UIButton_unitId[this]=GetUnitUserData(s__UIButton_picture[this])
            set s__UIButton_Unit2Button[s__UIButton_unitId[this]]=this
            
            call SetUnitScale(s__UIButton_picture[this], 0, 0, 0)
            
            return this
        endfunction
        
        function s__UIButton_destroy takes integer this returns nothing
            call RemoveUnit(s__UIButton_picture[this])
            
            if s__UIButton_displayed[this] then
                set s__UIButton_AllShow[s__UIButton_index[this]]=s__UIButton_AllShow[s__UIButton_CountShow]
                set s__UIButton_index[s__UIButton_AllShow[s__UIButton_index[this]]]=s__UIButton_index[this]
                set s__UIButton_CountShow=s__UIButton_CountShow - 1
            endif
        endfunction

        function s__UIButton_update takes integer this returns nothing
            local integer Pos
            
            if ( s__UIButton_displayed[this] ) then
                set Pos=s__Camera_win2World(s__UIButton_camera[this],s__UIButton_centerx[this] , s__UIButton_centery[this] , s__UIButton_z[this])
                call SetUnitX(s__UIButton_picture[this], s__VECTOR3_x[Pos])
                call SetUnitY(s__UIButton_picture[this], s__VECTOR3_y[Pos])
                call SetUnitFlyHeight(s__UIButton_picture[this], s__VECTOR3_z[Pos] - UserInterface_GetTerrainZ(s__VECTOR3_x[Pos] , s__VECTOR3_y[Pos]), 0)
                call s__VECTOR3_deallocate(Pos)
            endif
        endfunction
        
        function s__UIButton_show takes integer this,boolean flag,integer Cam returns nothing
            if Cam != - 1 then
                set s__UIButton_camera[this]=Cam
            endif
            
            if flag != s__UIButton_displayed[this] then
                if flag then
                    set s__UIButton_AllShow[s__UIButton_CountShow]=this
                    set s__UIButton_index[this]=s__UIButton_CountShow
                    set s__UIButton_CountShow=s__UIButton_CountShow + 1
                    call s__UIButton_update(this)
                    call SetUnitAnimationByIndex(s__UIButton_picture[this], s__UIButton_animIndex[this])
                    
                    call SetUnitScale(s__UIButton_picture[this], s__UIButton_scale[this], 0, 0)
                else
                    set s__UIButton_CountShow=s__UIButton_CountShow - 1
                    set s__UIButton_AllShow[s__UIButton_index[this]]=s__UIButton_AllShow[s__UIButton_CountShow]
                    set s__UIButton_index[s__UIButton_AllShow[s__UIButton_index[this]]]=s__UIButton_index[this]
                    
                    call SetUnitX(s__UIButton_picture[this], 0)
                    call SetUnitY(s__UIButton_picture[this], 0)
                    
                    call SetUnitScale(s__UIButton_picture[this], 0, 0, 0)
                endif
            endif
            
            set s__UIButton_displayed[this]=flag
        endfunction
        
        function s__UIButton_showPlayer takes integer this,player p,boolean flag,integer cam returns nothing
            call s__UIButton_show(this,flag , cam)
            
            if ( flag ) then
                call SetUnitScale(s__UIButton_picture[this], UserInterface__LocalReal(p , s__UIButton_scale[this] , 0), 0, 0)
            endif
        endfunction

        function s__UIButton_isClicked takes integer this,real x,real y returns boolean
            return s__UIButton_minx[this] < x and x < s__UIButton_maxx[this] and s__UIButton_miny[this] < y and y < s__UIButton_maxy[this]
        endfunction
        
        function s__UIButton_clickL takes integer this returns nothing
            set UserInterface__ClickedButton=this

            if ( s__UIButton_triggerL[this] != null and TriggerEvaluate(s__UIButton_triggerL[this]) ) then
                call TriggerExecute(s__UIButton_triggerL[this])
            endif

            if ( s__UIButton_onLeftClick[this] != null ) then
                 call UserInterface_Eval(s__UIButton_onLeftClick[this])
            endif
        endfunction
        
        function s__UIButton_clickR takes integer this returns nothing
            set UserInterface__ClickedButton=this

            if ( s__UIButton_triggerR[this] != null and TriggerEvaluate(s__UIButton_triggerR[this]) ) then
                call TriggerExecute(s__UIButton_triggerR[this])
            endif
            
            if ( s__UIButton_onRightClick[this] != null ) then
                 call UserInterface_Eval(s__UIButton_onRightClick[this])
            endif
        endfunction
        
        function s__UIButton_setPosition takes integer this,real minx,real maxy returns nothing
            set s__UIButton_minx[this]=minx
            set s__UIButton_maxx[this]=minx + s__UIButton_width[this]
            set s__UIButton_maxy[this]=maxy
            set s__UIButton_miny[this]=maxy - s__UIButton_height[this]
            set s__UIButton_centerx[this]=minx + s__UIButton_width[this] / 2.0
            set s__UIButton_centery[this]=maxy - s__UIButton_height[this] / 2.0
            
            if s__UIButton_displayed[this] then
                call s__UIButton_update(this)
            endif
        endfunction
        
        function s__UIButton_setTexture takes integer this,integer texture returns nothing
            call SetUnitX(s__UIButton_picture[this], 0)
            call SetUnitY(s__UIButton_picture[this], 0)
            call UserInterface_ApplySkin(s__UIButton_picture[this] , texture)
            
            if s__UIButton_displayed[this] then
                call s__UIButton_update(this)
            endif
            
            set s__UIButton_texture[this]=texture
        endfunction
        
        function s__UIButton_updateAll takes nothing returns nothing
            local integer i= s__UIButton_CountShow
            loop
                exitwhen i < 0
                call s__UIButton_update(s__UIButton_AllShow[i])
                set i=i - 1
            endloop
        endfunction
        
        function s__UIButton_click takes unit u,boolean isLeft returns boolean
            local integer b
            
            if GetUnitTypeId(u) == s__Interface_DUMMY_TYPE then
                set b=s__UIButton_Unit2Button[GetUnitUserData(u)]

                if b > 0 and s__UIButton_displayed[b] then
                    call SelectUnit(u, false)

                    if isLeft then
                        call s__UIButton_clickL(b)
                    else
                        call s__UIButton_clickR(b)
                    endif
                    
                    return true
                endif
            endif
            
            return false
        endfunction
        
        function s__UIButton_clickEx takes real x,real y,boolean isLeft returns boolean
            local integer i= s__UIButton_CountShow
            
            loop
                exitwhen i < 0

                if s__UIButton_isClicked(s__UIButton_AllShow[i],x , y) then
                    if isLeft then
                        call s__UIButton_clickL(s__UIButton_AllShow[i])
                    else
                        call s__UIButton_clickR(s__UIButton_AllShow[i])
                    endif
                    
                    return true
                endif
                
                set i=i - 1
            endloop
            
            return false
        endfunction
        
        function s__UIButton_enableButtonCallback takes nothing returns nothing
            local timer t= GetExpiredTimer()


                local integer btn= ((LoadInteger(TimerUtils__ht, 0, GetHandleId((t))))) // INLINED!!




            set s__UIButton_disabled[btn]=false
            set t=null
        endfunction

        function s__UIButton_clickPeriodicSelect takes player p,boolean isLeft returns boolean
            local integer i= s__UIButton_CountShow
            local timer t
            
            loop
                exitwhen i < 0

                if ( IsUnitSelected(s__UIButton_picture[s__UIButton_AllShow[i]], p) ) then
                    
                    if ( not s__UIButton_disabled[s__UIButton_AllShow[i]] ) then

                        if isLeft then
                            call s__UIButton_clickL(s__UIButton_AllShow[i])
                        else
                            call s__UIButton_clickR(s__UIButton_AllShow[i])
                        endif

                        
                        if ( s__UIButton_useDelay ) then // static if doesn't work..
                            set s__UIButton_disabled[s__UIButton_AllShow[i]]=true


                                call TimerStart(NewTimerEx(s__UIButton_AllShow[i]), s__Interface_LEFT_CLICK_DELAY, false, function s__UIButton_enableButtonCallback)







                        endif
                        
                        return true
                    endif

                    call SelectUnit(s__UIButton_picture[s__UIButton_AllShow[i]], false)

                    if ( s__UIButton_selectUnit[s__UIButton_AllShow[i]] != null and s__User_Local == p ) then
                        call SelectUnit(s__UIButton_selectUnit[s__UIButton_AllShow[i]], true)
                    endif

                endif
                
                set i=i - 1
            endloop
            
            return false
        endfunction


        
        
        

        function s__UIPicture_create takes real minx,real maxy,real w,real h,real z,integer texture returns integer
            local integer this= s__UIPicture__allocate()

            set s__UIPicture_texture[this]=texture
            set s__UIPicture_customValue[this]=0
            set s__UIPicture_camera[this]=0
            set s__UIPicture_width[this]=w
            set s__UIPicture_height[this]=h
            set s__UIPicture_centerx[this]=minx + w / 2.0
            set s__UIPicture_centery[this]=maxy - h / 2.0
            set s__UIPicture_z[this]=100.2 + z
            set s__UIPicture_displayed[this]=false
            set s__UIPicture_picture[this]=CreateUnit(s__Interface_PLAYER, s__Interface_DUMMY_TYPE, 0, 0, 0)
            set s__UIPicture_animIndex[this]=UserInterface_FindModelAnimIndex(w , h , s__UIPicture_z[this])
            set s__UIPicture_scale[this]=UserInterface_FindModelSize(w , h , s__UIPicture_z[this])
            
            call UserInterface_ApplySkin(s__UIPicture_picture[this] , texture)
            
            call SetUnitAnimationByIndex(s__UIPicture_picture[this], s__UIPicture_animIndex[this])
            
            call UnitAddAbility(s__UIPicture_picture[this], s__Interface_DESTROYER_FORM_ID)
            call UnitRemoveAbility(s__UIPicture_picture[this], s__Interface_DESTROYER_FORM_ID)
            call UnitAddAbility(s__UIPicture_picture[this], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(s__UIPicture_picture[this], s__Interface_LOCUST_ID)
            
            // hide unit
            call SetUnitScale(s__UIPicture_picture[this], 0, 0, 0)
            
            return this
        endfunction
        
        function s__UIPicture_createEx takes real minx,real maxy,real z,real scale,integer unitId,real modelWidth,real modelHeight,integer texture returns integer
            local integer this= s__UIPicture__allocate()

            set s__UIPicture_customValue[this]=0
            set s__UIPicture_camera[this]=0
            set s__UIPicture_z[this]=100.2 + z
            set s__UIPicture_width[this]=( modelWidth * scale ) / ( SCREEN_WIDTH * s__UIPicture_z[this] )
            set s__UIPicture_height[this]=( modelHeight * scale ) / ( SCREEN_HEIGHT * s__UIPicture_z[this] )
            set s__UIPicture_scale[this]=scale
            set s__UIPicture_centerx[this]=minx + s__UIPicture_width[this] / 2.0
            set s__UIPicture_centery[this]=maxy - s__UIPicture_height[this] / 2.0
            set s__UIPicture_displayed[this]=false
            set s__UIPicture_picture[this]=CreateUnit(s__Interface_PLAYER, unitId, 0, 0, 270)
            
            call UserInterface_ApplySkin(s__UIPicture_picture[this] , texture)
            
            call UnitAddAbility(s__UIPicture_picture[this], s__Interface_DESTROYER_FORM_ID)
            call UnitRemoveAbility(s__UIPicture_picture[this], s__Interface_DESTROYER_FORM_ID)
            call UnitAddAbility(s__UIPicture_picture[this], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(s__UIPicture_picture[this], s__Interface_LOCUST_ID)
            
            // hide unit
            call SetUnitScale(s__UIPicture_picture[this], 0, 0, 0)
            
            return this
        endfunction
        
        function s__UIPicture_destroy takes integer this returns nothing
            call RemoveUnit(s__UIPicture_picture[this])
            
            if s__UIPicture_displayed[this] then
                set s__UIPicture_AllShow[s__UIPicture_index[this]]=s__UIPicture_AllShow[s__UIPicture_CountShow]
                set s__UIPicture_index[s__UIPicture_AllShow[s__UIPicture_index[this]]]=s__UIPicture_index[this]
                set s__UIPicture_CountShow=s__UIPicture_CountShow - 1
            endif
        endfunction

        function s__UIPicture_update takes integer this returns nothing
            local integer Pos

            if ( s__UIPicture_displayed[this] ) then
                set Pos=s__Camera_win2World(s__UIPicture_camera[this],s__UIPicture_centerx[this] , s__UIPicture_centery[this] , s__UIPicture_z[this])
                call SetUnitX(s__UIPicture_picture[this], s__VECTOR3_x[Pos])
                call SetUnitY(s__UIPicture_picture[this], s__VECTOR3_y[Pos])
                call SetUnitFlyHeight(s__UIPicture_picture[this], s__VECTOR3_z[Pos] - UserInterface_GetTerrainZ(s__VECTOR3_x[Pos] , s__VECTOR3_y[Pos]), 0)
                call s__VECTOR3_deallocate(Pos)
            endif
        endfunction
        
        function s__UIPicture_show takes integer this,boolean show,integer Cam returns nothing
            if Cam != - 1 then
                set s__UIPicture_camera[this]=Cam
            endif

            if show != s__UIPicture_displayed[this] then
                if show then
                    set s__UIPicture_AllShow[s__UIPicture_CountShow]=this
                    set s__UIPicture_index[this]=s__UIPicture_CountShow
                    set s__UIPicture_CountShow=s__UIPicture_CountShow + 1
                    call s__UIPicture_update(this)
                    call SetUnitAnimationByIndex(s__UIPicture_picture[this], s__UIPicture_animIndex[this])
                    call SetUnitScale(s__UIPicture_picture[this], s__UIPicture_scale[this], 0, 0)
                else
                    set s__UIPicture_CountShow=s__UIPicture_CountShow - 1
                    set s__UIPicture_AllShow[s__UIPicture_index[this]]=s__UIPicture_AllShow[s__UIPicture_CountShow]
                    set s__UIPicture_index[s__UIPicture_AllShow[s__UIPicture_index[this]]]=s__UIPicture_index[this]
                    call SetUnitX(s__UIPicture_picture[this], 0)
                    call SetUnitY(s__UIPicture_picture[this], 0)
                    call SetUnitScale(s__UIPicture_picture[this], 0, 0, 0)
                endif
            endif
            
            set s__UIPicture_displayed[this]=show
        endfunction
        
        function s__UIPicture_showPlayer takes integer this,player p,boolean flag,integer cam returns nothing
            call s__UIPicture_show(this,flag , cam)
            
            if ( flag ) then
                call SetUnitScale(s__UIPicture_picture[this], UserInterface__LocalReal(p , s__UIPicture_scale[this] , 0), 0, 0)
            endif
        endfunction
        
        function s__UIPicture_setPosition takes integer this,real minx,real maxy returns nothing
            set s__UIPicture_centerx[this]=minx + s__UIPicture_width[this] / 2.0
            set s__UIPicture_centery[this]=maxy - s__UIPicture_height[this] / 2.0
            if s__UIPicture_displayed[this] then
                call s__UIPicture_update(this)
            endif
        endfunction
        
        function s__UIPicture_setTexture takes integer this,integer texture returns nothing
            call SetUnitX(s__UIPicture_picture[this], 0)
            call SetUnitY(s__UIPicture_picture[this], 0)
            call UserInterface_ApplySkin(s__UIPicture_picture[this] , texture)
            
            if s__UIPicture_displayed[this] then
                call s__UIPicture_update(this)
            endif
            
            set s__UIPicture_texture[this]=texture
        endfunction
        
        function s__UIPicture_updateAll takes nothing returns nothing
            local integer i= s__UIPicture_CountShow

            loop
                exitwhen i < 0
                call s__UIPicture_update(s__UIPicture_AllShow[i])
                set i=i - 1
            endloop
        endfunction


        
        
        function s__UIText_create takes real minx,real maxy,real z returns integer
            local integer this= s__UIText__allocate()
            
            set s__UIText_customValue[this]=0
            set s__UIText_camera[this]=0
            set s__UIText_minx[this]=minx
            set s__UIText_maxy[this]=maxy
            set s__UIText_z[this]=100 + z
            set s__UIText_displayed[this]=false
            set s__UIText_text[this]=CreateTextTag()
            set s__UIText_dummy[this]=CreateUnit(s__Interface_PLAYER, s__Interface_DUMMY_TYPE, 0, 0, 0)

            call SetUnitScale(s__UIText_dummy[this], 0, 0, 0)

            call UnitAddAbility(s__UIText_dummy[this], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(s__UIText_dummy[this], s__Interface_LOCUST_ID)
            
            call SetTextTagVisibility(s__UIText_text[this], false)
            call SetTextTagPosUnit(s__UIText_text[this], s__UIText_dummy[this], 0)
            
            return this
        endfunction
        
        function s__UIText_createEx takes player p,real minx,real maxy,real z returns integer
            local integer this= s__UIText__allocate()
            
            set s__UIText_customValue[this]=0
            set s__UIText_camera[this]=0
            set s__UIText_minx[this]=minx
            set s__UIText_maxy[this]=maxy
            set s__UIText_z[this]=100 + z
            set s__UIText_displayed[this]=false
            set s__UIText_dummy[this]=CreateUnit(s__Interface_PLAYER, s__Interface_DUMMY_TYPE, 0, 0, 0)

            if ( s__User_Local == p ) then
                set s__UIText_text[this]=CreateTextTag()
            endif
            
            call SetUnitScale(s__UIText_dummy[this], 0, 0, 0)

            call UnitAddAbility(s__UIText_dummy[this], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(s__UIText_dummy[this], s__Interface_LOCUST_ID)
            
            call SetTextTagVisibility(s__UIText_text[this], false)
            call SetTextTagPosUnit(s__UIText_text[this], s__UIText_dummy[this], 0)
            
            return this
        endfunction
        
        function s__UIText_destroy takes integer this returns nothing
            call DestroyTextTag(s__UIText_text[this])
            
            if s__UIText_displayed[this] then
                set s__UIText_AllShow[s__UIText_index[this]]=s__UIText_AllShow[s__UIText_CountShow]
                set s__UIText_index[s__UIText_AllShow[s__UIText_index[this]]]=s__UIText_index[this]
                set s__UIText_CountShow=s__UIText_CountShow - 1
            endif
        endfunction
        
        function s__UIText_update takes integer this returns nothing
            local integer Pos= s__Camera_win2World(s__UIText_camera[this],s__UIText_minx[this] , s__UIText_maxy[this] , s__UIText_z[this])
            call SetUnitX(s__UIText_dummy[this], s__VECTOR3_x[Pos])
            call SetUnitY(s__UIText_dummy[this], s__VECTOR3_y[Pos])
            call SetTextTagPosUnit(s__UIText_text[this], s__UIText_dummy[this], ( s__VECTOR3_z[Pos] - UserInterface_GetTerrainZ(s__VECTOR3_x[Pos] , s__VECTOR3_y[Pos]) ) - 14.8)
            call s__VECTOR3_deallocate(Pos)
        endfunction
        
        function s__UIText_setPosition takes integer this,real minx,real maxy returns nothing
            set s__UIText_minx[this]=minx
            set s__UIText_maxy[this]=maxy
            
            if s__UIText_displayed[this] then
                call s__UIText_update(this)
            endif
        endfunction
        
        function s__UIText_show takes integer this,boolean show,integer Cam returns nothing
            if Cam != - 1 then
                set s__UIText_camera[this]=Cam
            endif
            
            call SetTextTagVisibility(s__UIText_text[this], show)
            
            if show != s__UIText_displayed[this] then
                if show then
                    set s__UIText_AllShow[s__UIText_CountShow]=this
                    set s__UIText_index[this]=s__UIText_CountShow
                    set s__UIText_CountShow=s__UIText_CountShow + 1
                    call s__UIText_update(this)
                else
                    set s__UIText_CountShow=s__UIText_CountShow - 1
                    set s__UIText_AllShow[s__UIText_index[this]]=s__UIText_AllShow[s__UIText_CountShow]
                    set s__UIText_index[s__UIText_AllShow[s__UIText_index[this]]]=s__UIText_index[this]
                endif
            endif
            
            set s__UIText_displayed[this]=show
        endfunction
        
        function s__UIText_updateAll takes nothing returns nothing
            local integer i= s__UIText_CountShow
            loop
                exitwhen i < 0
                call s__UIText_update(s__UIText_AllShow[i])
                set i=i - 1
            endloop
        endfunction


        
//Implemented from module UserInterface__InterfaceConfig:
    
        // dummy unit with pitch angle animations
        
        // model used in CreateWindow function
        
        // destructable ID of the human border texture. the
        // rest of the races should have consecutive ids.
        
        // run a timer to check for unit selections.
        // faster but more cpu intensive.

            // really low timer intervals remove the flicker
            // effect, most of the time.

            // in multiplayer, IsUnitSelected is synchronous
            // so it doesn't instantly return false when you use
            // SelectUnit(u, false). So we must disable the button
            // for the clicking player for a brief period or else
            // the event will be spammed.
        
        // ability id's
        
        // ability used to change dummy unit textures
        
        // removes pathing and possibly other things from the unit.
        // similar to locust, but allows clicking.

        // dummy player
        
       function s__Interface_getRaceBorders takes race r returns integer
            return s__Interface_RACE_BORDERS_START + ( GetHandleId(r) - 1 )
        endfunction
        
        function s__Interface_updateAll takes boolean but,boolean pic,boolean tex returns nothing
            if but then
                call s__UIButton_updateAll()
            endif
            if pic then
                call s__UIPicture_updateAll()
            endif
            if tex then
                call s__UIText_updateAll()
            endif
        endfunction


    function CreateWindow takes real x,real y,real size,real width,real height,race playerRace returns integer
        return s__UIPicture_createEx(x , y , 2 , size , s__Interface_WINDOW_DUMMY , width , height , (s__Interface_RACE_BORDERS_START + ( GetHandleId((playerRace)) - 1 ))) // INLINED!!
    endfunction
    
    function UserInterface__InterfaceClickR takes nothing returns nothing
        local unit clicker= GetTriggerUnit()
        local unit btnUnit= GetOrderTargetUnit()
        
        set UserInterface__ClickingPlayer=GetOwningPlayer(clicker)
        
        if ( s__UIButton_click(btnUnit , false) ) then
            call PauseUnit(clicker, true)
            call IssueImmediateOrderById(clicker, 851973)
            call PauseUnit(clicker, false)
        endif
        
        set clicker=null
    endfunction
    
    function UserInterface__InterfaceClickL takes nothing returns nothing
        set UserInterface__ClickingPlayer=GetTriggerPlayer()
        call s__UIButton_click(GetTriggerUnit() , true)
    endfunction

    function UserInterface__InterfaceClickL_Timer takes nothing returns nothing
        local integer i= 0
        local integer c= s__UIButton_CountShow
        local integer user= s__User_first
        
        loop
            exitwhen user == s__User_NULL
  
            set UserInterface__ClickingPlayer=s__User_handle[user]
            
            call s__UIButton_clickPeriodicSelect(s__User_handle[user] , true)

            set user=s__User_next[user]
        endloop
    endfunction
    
    function UserInterface__Init takes nothing returns nothing
         local trigger t= CreateTrigger()
         local trigger t2= CreateTrigger()
         local integer i= 0
         local integer user= s__User_first
        
         loop
            exitwhen user == s__User_NULL
            
            call TriggerRegisterPlayerUnitEvent(t, s__User_handle[user], EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null)
            



            
            set user=s__User_next[user]
        endloop

        call TriggerAddAction(t, function UserInterface__InterfaceClickR)
        

            call TimerStart(CreateTimer(), s__Interface_LEFT_CLICK_TIMER_RATE, true, function UserInterface__InterfaceClickL_Timer)




        set s__UIButton_useDelay=s__Interface_LEFT_CLICK_TIMER
    endfunction
    

//library UserInterface ends
//library UIStudioLayout:
function UIStudioX takes string id returns real
    return LoadReal(UIStudioLayout__H, StringHash(id), 0)
endfunction
function UIStudioY takes string id returns real
    return LoadReal(UIStudioLayout__H, StringHash(id), 1)
endfunction
function UIStudioWidth takes string id returns real
    return LoadReal(UIStudioLayout__H, StringHash(id), 2)
endfunction
function UIStudioHeight takes string id returns real
    return LoadReal(UIStudioLayout__H, StringHash(id), 3)
endfunction
function UIStudioVisible takes string id returns boolean
    return LoadBoolean(UIStudioLayout__H, StringHash(id), 10)
endfunction
function UIStudioAction takes string id,boolean rightClick returns string
    if rightClick then
        return LoadStr(UIStudioLayout__H, StringHash(id), 12)
    endif
    return LoadStr(UIStudioLayout__H, StringHash(id), 11)
endfunction
function UIStudioButton takes string id,integer texture returns integer
    local integer k= StringHash(id)
    local integer b
    if texture == - 1 then
        set texture=LoadInteger(UIStudioLayout__H, k, 5)
    endif
    set b=s__UIButton_create(LoadReal(UIStudioLayout__H, k, 0) , LoadReal(UIStudioLayout__H, k, 1) , LoadReal(UIStudioLayout__H, k, 2) , LoadReal(UIStudioLayout__H, k, 3) , LoadReal(UIStudioLayout__H, k, 4) , texture)
    call SetUnitVertexColor(s__UIButton_picture[b], LoadInteger(UIStudioLayout__H, k, 20), LoadInteger(UIStudioLayout__H, k, 21), LoadInteger(UIStudioLayout__H, k, 22), LoadInteger(UIStudioLayout__H, k, 23))
    return b
endfunction
function UIStudioPicture takes string id,integer texture returns integer
    local integer k= StringHash(id)
    local integer pic
    if texture == - 1 then
        set texture=LoadInteger(UIStudioLayout__H, k, 5)
    endif
    if LoadInteger(UIStudioLayout__H, k, 13) != 0 then
        set pic=s__UIPicture_createEx(LoadReal(UIStudioLayout__H, k, 16) , LoadReal(UIStudioLayout__H, k, 17) , LoadReal(UIStudioLayout__H, k, 4) , LoadReal(UIStudioLayout__H, k, 14) , LoadInteger(UIStudioLayout__H, k, 13) , LoadReal(UIStudioLayout__H, k, 18) , LoadReal(UIStudioLayout__H, k, 19) , texture)
    else
        set pic=s__UIPicture_create(LoadReal(UIStudioLayout__H, k, 0) , LoadReal(UIStudioLayout__H, k, 1) , LoadReal(UIStudioLayout__H, k, 2) , LoadReal(UIStudioLayout__H, k, 3) , LoadReal(UIStudioLayout__H, k, 4) , texture)
    endif
    call SetUnitVertexColor(s__UIPicture_picture[pic], LoadInteger(UIStudioLayout__H, k, 20), LoadInteger(UIStudioLayout__H, k, 21), LoadInteger(UIStudioLayout__H, k, 22), LoadInteger(UIStudioLayout__H, k, 23))
    return pic
endfunction
function UIStudioText takes string id,player p returns integer
    local integer k= StringHash(id)
    local integer t= s__UIText_createEx(p , LoadReal(UIStudioLayout__H, k, 0) , LoadReal(UIStudioLayout__H, k, 1) , LoadReal(UIStudioLayout__H, k, 4))
    call SetTextTagText(s__UIText_text[t], LoadStr(UIStudioLayout__H, k, 6), LoadReal(UIStudioLayout__H, k, 7) * 0.0023)
    call SetTextTagColor(s__UIText_text[t], LoadInteger(UIStudioLayout__H, k, 20), LoadInteger(UIStudioLayout__H, k, 21), LoadInteger(UIStudioLayout__H, k, 22), LoadInteger(UIStudioLayout__H, k, 23))
    return t
endfunction
function UIStudioLayout__Init takes nothing returns nothing
    local integer k
    set k=StringHash("equipment.background")
    call SaveReal(UIStudioLayout__H, k, 0, 0.48980)
    call SaveReal(UIStudioLayout__H, k, 1, 0.96073)
    call SaveReal(UIStudioLayout__H, k, 2, 0.51841)
    call SaveReal(UIStudioLayout__H, k, 3, 1.14537)
    call SaveReal(UIStudioLayout__H, k, 4, 11.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'D201')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    call SaveInteger(UIStudioLayout__H, k, 13, 'ewin')
    call SaveReal(UIStudioLayout__H, k, 14, 0.28000)
    call SaveReal(UIStudioLayout__H, k, 16, 0.42500)
    call SaveReal(UIStudioLayout__H, k, 17, 0.93000)
    call SaveReal(UIStudioLayout__H, k, 18, 140.00000)
    call SaveReal(UIStudioLayout__H, k, 19, 130.00000)
    set k=StringHash("inventory.background")
    call SaveReal(UIStudioLayout__H, k, 0, 0.52388)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.17369)
    call SaveReal(UIStudioLayout__H, k, 2, 0.45931)
    call SaveReal(UIStudioLayout__H, k, 3, 0.69586)
    call SaveReal(UIStudioLayout__H, k, 4, 2.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'D201')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    call SaveInteger(UIStudioLayout__H, k, 13, 'bwn2')
    call SaveReal(UIStudioLayout__H, k, 14, 0.22800)
    call SaveReal(UIStudioLayout__H, k, 16, 0.61000)
    call SaveReal(UIStudioLayout__H, k, 17, - 0.30000)
    call SaveReal(UIStudioLayout__H, k, 18, 70.00000)
    call SaveReal(UIStudioLayout__H, k, 19, 60.00000)
    set k=StringHash("tooltip.background")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.90020)
    call SaveReal(UIStudioLayout__H, k, 1, 0.25056)
    call SaveReal(UIStudioLayout__H, k, 2, 0.62012)
    call SaveReal(UIStudioLayout__H, k, 3, 0.69901)
    call SaveReal(UIStudioLayout__H, k, 4, 0.20000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B014')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    call SaveInteger(UIStudioLayout__H, k, 13, 'ttip')
    call SaveReal(UIStudioLayout__H, k, 14, 0.10000)
    call SaveReal(UIStudioLayout__H, k, 16, - 0.70000)
    call SaveReal(UIStudioLayout__H, k, 17, - 0.00000)
    call SaveReal(UIStudioLayout__H, k, 18, 120.00000)
    call SaveReal(UIStudioLayout__H, k, 19, 60.00000)
    set k=StringHash("equipment.slot.0")
    call SaveReal(UIStudioLayout__H, k, 0, 0.53000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.86500)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.1")
    call SaveReal(UIStudioLayout__H, k, 0, 0.53000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.70288)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B004')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.2")
    call SaveReal(UIStudioLayout__H, k, 0, 0.53000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.54076)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B006')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.3")
    call SaveReal(UIStudioLayout__H, k, 0, 0.53000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.37864)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B007')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.4")
    call SaveReal(UIStudioLayout__H, k, 0, 0.53000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.21652)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B008')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.5")
    call SaveReal(UIStudioLayout__H, k, 0, 0.53000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.05440)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'D05W')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.6")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.86500)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B009')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.7")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.70288)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00A')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.8")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.54076)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00C')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.9")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.37864)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00D')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.10")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.21652)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00E')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.11")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.05440)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00F')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.12")
    call SaveReal(UIStudioLayout__H, k, 0, 0.66500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.05440)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B005')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.slot.13")
    call SaveReal(UIStudioLayout__H, k, 0, 0.75000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.05440)
    call SaveReal(UIStudioLayout__H, k, 2, 0.09000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.16212)
    call SaveReal(UIStudioLayout__H, k, 4, 10.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00B')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.hero")
    call SaveReal(UIStudioLayout__H, k, 0, 0.66500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.67000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.20000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.58000)
    call SaveReal(UIStudioLayout__H, k, 4, 5.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 0)
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("equipment.title")
    call SaveReal(UIStudioLayout__H, k, 0, 0.52500)
    call SaveReal(UIStudioLayout__H, k, 1, 0.90000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.35000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.06000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "Nombre del héroe")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 247)
    call SaveInteger(UIStudioLayout__H, k, 21, 220)
    call SaveInteger(UIStudioLayout__H, k, 22, 152)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.0")
    call SaveReal(UIStudioLayout__H, k, 0, 0.56150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.22800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.1")
    call SaveReal(UIStudioLayout__H, k, 0, 0.62650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.22800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.2")
    call SaveReal(UIStudioLayout__H, k, 0, 0.69150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.22800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.3")
    call SaveReal(UIStudioLayout__H, k, 0, 0.75650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.22800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.4")
    call SaveReal(UIStudioLayout__H, k, 0, 0.82150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.22800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.5")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.22800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.6")
    call SaveReal(UIStudioLayout__H, k, 0, 0.56150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.34509)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.7")
    call SaveReal(UIStudioLayout__H, k, 0, 0.62650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.34509)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.8")
    call SaveReal(UIStudioLayout__H, k, 0, 0.69150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.34509)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.9")
    call SaveReal(UIStudioLayout__H, k, 0, 0.75650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.34509)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.10")
    call SaveReal(UIStudioLayout__H, k, 0, 0.82150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.34509)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.11")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.34509)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.12")
    call SaveReal(UIStudioLayout__H, k, 0, 0.56150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.46217)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.13")
    call SaveReal(UIStudioLayout__H, k, 0, 0.62650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.46217)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.14")
    call SaveReal(UIStudioLayout__H, k, 0, 0.69150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.46217)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.15")
    call SaveReal(UIStudioLayout__H, k, 0, 0.75650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.46217)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.16")
    call SaveReal(UIStudioLayout__H, k, 0, 0.82150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.46217)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.17")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.46217)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.18")
    call SaveReal(UIStudioLayout__H, k, 0, 0.56150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.57926)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.19")
    call SaveReal(UIStudioLayout__H, k, 0, 0.62650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.57926)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.20")
    call SaveReal(UIStudioLayout__H, k, 0, 0.69150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.57926)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.21")
    call SaveReal(UIStudioLayout__H, k, 0, 0.75650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.57926)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.22")
    call SaveReal(UIStudioLayout__H, k, 0, 0.82150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.57926)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.23")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.57926)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.24")
    call SaveReal(UIStudioLayout__H, k, 0, 0.56150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.69634)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.25")
    call SaveReal(UIStudioLayout__H, k, 0, 0.62650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.69634)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.26")
    call SaveReal(UIStudioLayout__H, k, 0, 0.69150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.69634)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.27")
    call SaveReal(UIStudioLayout__H, k, 0, 0.75650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.69634)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.28")
    call SaveReal(UIStudioLayout__H, k, 0, 0.82150)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.69634)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.slot.29")
    call SaveReal(UIStudioLayout__H, k, 0, 0.88650)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.69634)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'dbnk')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "select")
    call SaveStr(UIStudioLayout__H, k, 12, "equip")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.pageUp")
    call SaveReal(UIStudioLayout__H, k, 0, 0.46000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.22800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00U')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "previous")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.pageDown")
    call SaveReal(UIStudioLayout__H, k, 0, 0.46000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.69634)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00T')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "next")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.sell")
    call SaveReal(UIStudioLayout__H, k, 0, 0.46000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.52800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B011')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "sell")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.drop")
    call SaveReal(UIStudioLayout__H, k, 0, 0.46000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.37800)
    call SaveReal(UIStudioLayout__H, k, 2, 0.06500)
    call SaveReal(UIStudioLayout__H, k, 3, 0.11709)
    call SaveReal(UIStudioLayout__H, k, 4, 0.50000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00N')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "drop")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("inventory.page")
    call SaveReal(UIStudioLayout__H, k, 0, 0.91000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.20000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.11000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05500)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "1/5")
    call SaveReal(UIStudioLayout__H, k, 7, 10.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.icon")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.88000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.28000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.07000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.12609)
    call SaveReal(UIStudioLayout__H, k, 4, 0.10000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00G')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.title")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.10000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.07000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "Corona de reyes +5")
    call SaveReal(UIStudioLayout__H, k, 7, 10.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 247)
    call SaveInteger(UIStudioLayout__H, k, 21, 220)
    call SaveInteger(UIStudioLayout__H, k, 22, 152)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.gold")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.02200)
    call SaveReal(UIStudioLayout__H, k, 2, 0.03000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05404)
    call SaveReal(UIStudioLayout__H, k, 4, 0.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B00H')
    call SaveStr(UIStudioLayout__H, k, 6, "Texto")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.cost")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.81000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.02200)
    call SaveReal(UIStudioLayout__H, k, 2, 0.30000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.06000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "1000")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 247)
    call SaveInteger(UIStudioLayout__H, k, 21, 220)
    call SaveInteger(UIStudioLayout__H, k, 22, 152)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.0")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.05000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "+5 Fuerza")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.1")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.10000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "+5 Agilidad")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.2")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.15000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "+5 Inteligencia")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.3")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.20000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "Requiere nivel 3")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.4")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.25000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "Ranuras: 1")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.5")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.30000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.6")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.35000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.7")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.40000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.8")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.45000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.9")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.50000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.10")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.55000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.11")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.60000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.12")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.65000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.13")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.70000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.14")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.75000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
    set k=StringHash("tooltip.line.15")
    call SaveReal(UIStudioLayout__H, k, 0, - 0.85000)
    call SaveReal(UIStudioLayout__H, k, 1, - 0.80000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.52000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.05000)
    call SaveReal(UIStudioLayout__H, k, 4, 1.00000)
    call SaveInteger(UIStudioLayout__H, k, 5, 'B003')
    call SaveStr(UIStudioLayout__H, k, 6, "")
    call SaveReal(UIStudioLayout__H, k, 7, 7.50000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 255)
    call SaveInteger(UIStudioLayout__H, k, 22, 255)
    call SaveInteger(UIStudioLayout__H, k, 23, 255)
endfunction

//library UIStudioLayout ends
// BEGIN IMPORT OF ../../analysis/inventorysys-1.4.1/source/25_UserInterface.j
// END IMPORT OF ../../analysis/inventorysys-1.4.1/source/25_UserInterface.j
// BEGIN IMPORT OF ../../analysis/inventorysys-1.4.1/source/27_UnitDex.j
// END IMPORT OF ../../analysis/inventorysys-1.4.1/source/27_UnitDex.j
// BEGIN IMPORT OF ../../analysis/inventorysys-1.4.1/source/28_PlayerUtils.j
// END IMPORT OF ../../analysis/inventorysys-1.4.1/source/28_PlayerUtils.j
// BEGIN IMPORT OF ../../analysis/inventorysys-1.4.1/source/29_Camera.j
// END IMPORT OF ../../analysis/inventorysys-1.4.1/source/29_Camera.j
// BEGIN IMPORT OF ../../analysis/inventorysys-1.4.1/source/30_UIMath.j
// END IMPORT OF ../../analysis/inventorysys-1.4.1/source/30_UIMath.j
// BEGIN IMPORT OF ../../analysis/inventorysys-1.4.1/source/32_TimerUtils.j
// END IMPORT OF ../../analysis/inventorysys-1.4.1/source/32_TimerUtils.j
// BEGIN IMPORT OF UIStudioLayout.j
// UI Studio | Warcraft III 1.27b | InventorySys 1.4.1
// Import this library alongside UserInterface. Call factories synchronously.
// Factories create controls; existing inventory callbacks must be retained.
// Example: UIStudioButton("inventory.slot.0", runtimeTexture).
// Pass -1 to use the designed texture; pass 0 for no texture.
// Dynamic show()/tooltip code must use UIStudioX/Y to retain edited positions.
// Model heroes are metadata only; keep Equipment.charModel and its attachment.

// END IMPORT OF UIStudioLayout.j
function main takes nothing returns nothing

call ExecuteFunc("jasshelper__initstructs18019250")
call ExecuteFunc("TimerUtils__init")
call ExecuteFunc("UIMath__Init")
call ExecuteFunc("UserInterface__Init")
call ExecuteFunc("UIStudioLayout__Init")

endfunction
function config takes nothing returns nothing
endfunction



//Struct method generated initializers/callers:

//Functions for BigArrays:
function sa__UnitDex_Remove takes nothing returns boolean
    set f__result_boolean=s__UnitDex_Remove(f__arg_unit1,f__arg_boolean1)
   return true
endfunction
function sa___prototype6_TimerUtils__init takes nothing returns boolean

     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils__didinit ) then
    return true
        else
            set TimerUtils__didinit=true
        endif
            set TimerUtils__ht=InitHashtable()
            loop
                exitwhen ( i == TimerUtils__QUANTITY )
                set s__TimerUtils__tT[i]= CreateTimer()
                call SaveInteger(TimerUtils__ht, 0, GetHandleId((s__TimerUtils__tT[i] )), ( TimerUtils__HELD)) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils__tN=TimerUtils__QUANTITY
    return true
endfunction

function jasshelper__initstructs18019250 takes nothing returns nothing
    set st__UnitDex_Remove=CreateTrigger()
    call TriggerAddCondition(st__UnitDex_Remove,Condition( function sa__UnitDex_Remove))
    set st___prototype6[1]=CreateTrigger()
    call TriggerAddAction(st___prototype6[1],function sa___prototype6_TimerUtils__init)
    call TriggerAddCondition(st___prototype6[1],Condition(function sa___prototype6_TimerUtils__init))

call ExecuteFunc("s__User_PlayerUtils__PlayerUtilsInit__onInit")




call ExecuteFunc("s__UnitDex_UnitDex__UnitDexCore__onInit")


call ExecuteFunc("s__Camera__CamInit_Camera__CamInitModule__onInit")





endfunction

