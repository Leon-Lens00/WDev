globals
//globals from DummyCaster:
constant boolean LIBRARY_DummyCaster=true
constant integer UNITS_DUMMY_CASTER= 'dcst'
   
    
constant player DummyCaster___PLAYER_OWNER= Player(15)
unit DummyCaster___u
//endglobals from DummyCaster
//globals from EquipHeroModels:
constant boolean LIBRARY_EquipHeroModels=true
integer EquipHeroModels___HeroModels
string array EquipHeroModels___Path
integer EquipHeroModels___Models= 0
//endglobals from EquipHeroModels
//globals from EquipmentSockets:
constant boolean LIBRARY_EquipmentSockets=true
//endglobals from EquipmentSockets
//globals from ErrorMessage:
constant boolean LIBRARY_ErrorMessage=true
//endglobals from ErrorMessage
//globals from InventoryPlugins:
constant boolean LIBRARY_InventoryPlugins=true
//endglobals from InventoryPlugins
//globals from InventoryTable:
constant boolean LIBRARY_InventoryTable=true
constant integer InventoryTable___MAX_INSTANCES=8100
        //Feel free to change max instances if necessary, it will only affect allocation
        //speed which shouldn't matter that much.

    //=========================================================
hashtable InventoryTable___ht= InitHashtable()
//endglobals from InventoryTable
//globals from InventoryTooltip:
constant boolean LIBRARY_InventoryTooltip=true
//endglobals from InventoryTooltip
//globals from IsDestructableTree:
constant boolean LIBRARY_IsDestructableTree=true
constant integer IsDestructableTree__HARVESTER_UNIT_ID= 'hpea'
constant integer IsDestructableTree__HARVEST_ABILITY= 'Ahrl'
constant integer IsDestructableTree__HARVEST_ORDER_ID= 0xD0032
constant player IsDestructableTree__NEUTRAL_PLAYER= Player(PLAYER_NEUTRAL_PASSIVE)
unit IsDestructableTree__harvester= null
//endglobals from IsDestructableTree
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
//globals from RegisterPlayerUnitEvent:
constant boolean LIBRARY_RegisterPlayerUnitEvent=true
trigger array RegisterPlayerUnitEvent__t
//endglobals from RegisterPlayerUnitEvent
//globals from SimError:
constant boolean LIBRARY_SimError=true
sound SimError__error
//endglobals from SimError
//globals from Table:
constant boolean LIBRARY_Table=true
integer Table___less= 0
integer Table___more= 8190
    //Configure it if you use more than 8190 "key" variables in your map (this will never happen though).
   
hashtable Table___ht= InitHashtable()
constant integer Table___sizeK=22
constant integer Table___listK=127
//endglobals from Table
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
//globals from WorldBounds:
constant boolean LIBRARY_WorldBounds=true
//endglobals from WorldBounds
//globals from xebasic:
constant boolean LIBRARY_xebasic=true
constant integer XE_DUMMY_UNITID= 'e001'
constant integer XE_HEIGHT_ENABLER= 'Amrf'
constant integer XE_TREE_RECOGNITION= 'Aeat'
constant real XE_ANIMATION_PERIOD=  0.025
constant real XE_MAX_COLLISION_SIZE=  197.0
//endglobals from xebasic
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
        
real Camera___DeltaZ= 0
        // endconfig
        
unit array Camera_DummyUnit
location Camera_DummyLoc= Location(0, 0)
//endglobals from Camera
//globals from InventoryItem:
constant boolean LIBRARY_InventoryItem=true
constant integer InventoryItem_SEED_START= 0
constant integer InventoryItem_SEED_END= 999
//endglobals from InventoryItem
//globals from MissileDiagnostics:
constant boolean LIBRARY_MissileDiagnostics=true
//endglobals from MissileDiagnostics
//globals from SpellEffectEvent:
constant boolean LIBRARY_SpellEffectEvent=true
//endglobals from SpellEffectEvent
//globals from UnitDex:
constant boolean LIBRARY_UnitDex=true
        // Event types
constant integer EVENT_UNIT_INDEX= 0
constant integer EVENT_UNIT_DEINDEX= 1
        
        // System variables
trigger array UnitDex___IndexTrig
integer UnitDex___Index= 0
real UnitDex___E=- 1
boolexpr UnitDex___FilterEnter
//endglobals from UnitDex
//globals from xepreload:
constant boolean LIBRARY_xepreload=true
unit xepreload__dum=null
constant boolean xepreload__ALLOW_DEBUGGING=true
//endglobals from xepreload
//globals from AutoIndex:
constant boolean LIBRARY_AutoIndex=true
//endglobals from AutoIndex
//globals from BonusMod:
constant boolean LIBRARY_BonusMod=true
constant boolean BonusMod___PRELOAD_ABILITIES= true
boolean BonusMod_Init
integer BONUS_ARMOR
integer BONUS_DAMAGE
integer BONUS_SIGHT_RANGE
integer BONUS_LIFE_REGEN
integer BONUS_STRENGTH
integer BONUS_AGILITY
integer BONUS_INTELLIGENCE
integer BONUS_ATTACK_SPEED
integer BONUS_MANA_REGEN_PERCENT
integer array BonusMod___powersOf2
integer BonusMod___powersOf2Count= 0
//endglobals from BonusMod
//globals from MissileRecycler:
constant boolean LIBRARY_MissileRecycler=true
        //-------------------------------------------------------------------
        // You must configure the dummy unit with the one created from the
        // ObjectMerger statement above.
        //
constant integer MissileRecycler___DUMMY_ID= 'dumi'
player MissileRecycler___OWNER= Player(bj_PLAYER_NEUTRAL_EXTRA)

constant integer MissileRecycler___ANG_N= 8
constant integer MissileRecycler___ANG_STORAGE_MAX= 12

constant real MissileRecycler___DEATH_TIME= 2.
        //the unit to complete its "death" animation in this timeframe. Must
        //be higher than 0.74 seconds to allow the unit time to turn. This
        //number should not be lower than the maximum death-animation time of
        //your missile-units' effect attachments, just to be safe.
constant integer MissileRecycler___ANG_VAL= 360 / MissileRecycler___ANG_N
constant integer MissileRecycler___ANG_MID= MissileRecycler___ANG_VAL / 2

        //Misc vars
unit array MissileRecycler___stack
real array MissileRecycler___timeStamp
integer array MissileRecycler___queueNext
integer array MissileRecycler___queueLast
integer MissileRecycler___recycle= 0
timer MissileRecycler___gameTime= CreateTimer()
integer array MissileRecycler___queueStack
integer MissileRecycler___queueStackN= 0
//endglobals from MissileRecycler
//globals from UnitMaxState:
constant boolean LIBRARY_UnitMaxState=true
constant integer UnitMaxState___RAWCODE_LIFE= 'ZxLa'
constant integer UnitMaxState___RAWCODE_MANA= 'ZxMa'
        
constant integer UnitMaxState_ABILITY_COUNT= 3
constant boolean UnitMaxState___PRELOAD_ABILITIES= false
    
integer array UnitMaxState___POWERS_OF_2
//endglobals from UnitMaxState
//globals from UserInterface:
constant boolean LIBRARY_UserInterface=true
destructable UserInterface_DummyTree= null
trigger UserInterface__Trig= CreateTrigger()
integer UserInterface__ClickedButton= 0
player UserInterface__ClickingPlayer= null
location UserInterface__DummyLoc= Location(0, 0)
//endglobals from UserInterface
//globals from InventoryBonuses:
constant boolean LIBRARY_InventoryBonuses=true
//endglobals from InventoryBonuses
//globals from InventoryCore:
constant boolean LIBRARY_InventoryCore=true
//endglobals from InventoryCore
//globals from Missile:
constant boolean LIBRARY_Missile=true
    
        
constant real Missile_TIMER_TIMEOUT= 1. / 32.
        
         
constant player Missile_NEUTRAL_PASSIVE= Player(15)
        
        
constant integer Missile_DUMMY_UNIT_ID= 'dumi'
    
        
constant real Missile_MAXIMUM_COLLISION_SIZE= 197.
        
        
constant integer Missile_COLLISION_TYPE_CIRCLE= 0
constant integer Missile_COLLISION_TYPE_RECTANGLE= 1
    
        
constant real Missile_COLLISION_ACCURACY_FACTOR= 1.
    
// Optional toogles:
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//      Set booleans listed below to "true" and the compiler will write 
//      the feature into your map. Otherwise this code is completly ignored.                                        
//          • Yay, I want that           --> "true"
//          • Naah that's useless for me --> "false"
        
        
constant boolean Missile_USE_COLLISION_Z_FILTER= true
        
        
constant boolean Missile_WRITE_DELAYED_MISSILE_RECYCLING= true
        
        
constant real Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME= 2.

        
constant boolean Missile_USE_DESTRUCTABLE_FILTER= true
constant boolean Missile_USE_ITEM_FILTER= true
        // Core constant handle variables of Missile.
constant trigger Missile__CORE= CreateTrigger()
constant trigger Missile__MOVE= CreateTrigger()
constant timer Missile__TMR= CreateTimer()
constant location Missile__LOC= Location(0., 0.)
constant rect Missile__RECT= Rect(0., 0., 0., 0.)
constant group Missile__GROUP= CreateGroup()
constant hashtable Missile__HASH= InitHashtable()
        // For starting and stopping the timer.
integer Missile__active= 0
        // Arrays for data structure.
integer array Missile__instances
integer array Missile__missileList
boolexpr array Missile__expression
triggercondition array Missile__condition
integer array Missile__remove
boolean array Missile__destroying
boolean array Missile__recycling
integer array Missile__nextNode
integer array Missile__prevNode
        // Internal widget filter functions.
boolexpr Missile__destFilter
boolexpr Missile__itemFilter
boolexpr Missile__unitFilter
//endglobals from Missile
//globals from MovementBonus:
constant boolean LIBRARY_MovementBonus=true
constant integer MAX_UNIT_MOVEMENT= 400
constant integer MIN_UNIT_MOVEMENT= 150
constant integer MAX_BUILDING_MOVEMENT= 400
constant integer MIN_BUILDING_MOVEMENT= 25
integer BONUS_MOVEMENT_SPEED
//endglobals from MovementBonus
//globals from RegenBonuses:
constant boolean LIBRARY_RegenBonuses=true
real RegenBonuses__REGEN_PERIOD= 0.32
integer BONUS_MANA_REGEN
integer BONUS_LIFE_REGEN_PERCENT
timer RegenBonuses__regenTimer= CreateTimer()
//endglobals from RegenBonuses
//globals from UIStudioLayout:
constant boolean LIBRARY_UIStudioLayout=true
hashtable UIStudioLayout__H= InitHashtable()
//endglobals from UIStudioLayout
//globals from UnitMaxStateBonuses:
constant boolean LIBRARY_UnitMaxStateBonuses=true
integer BONUS_LIFE
integer BONUS_MANA
//endglobals from UnitMaxStateBonuses
//globals from YesNoDialog:
constant boolean LIBRARY_YesNoDialog=true
dialog array Dialog
button array YesNoDialog___YesBtn
filterfunc array YesNoDialog___YesCallback
player YesNoPlayer
//endglobals from YesNoDialog
//globals from EquipmentItem:
constant boolean LIBRARY_EquipmentItem=true
string array EquipmentItem_BonusString
//endglobals from EquipmentItem
//globals from EquipItemParser:
constant boolean LIBRARY_EquipItemParser=true
string EquipItemParser_TypeSlot
//endglobals from EquipItemParser
//globals from EquipmentCore:
constant boolean LIBRARY_EquipmentCore=true
filterfunc EquipmentCore_FuncLClickSlot= null
filterfunc EquipmentCore_FuncRClickSlot= null
integer array EquipmentCore_PlayerLastSlot
//endglobals from EquipmentCore
filterfunc InvFuncLClickSlot= null
filterfunc InvFuncRClickSlot= null
integer array InvPlayerLastSlot
integer array InvPlayerLastButton
boolean array InvButtonDisabled
player InvEventPlayer= null
integer InvEventItem= 0
integer InvEventSlot= 0
constant integer INVENTORY_KEY_START= 10000
integer array SellItem___SellItem
integer array SellItem___SellSlot
integer array SellItem___SellInv
integer array DropItem__DropItem
integer array DropItem__DropSlot
integer array DropItem__DropInv
integer array SocketItem___SockItem
integer array SocketItem___SockSlot
integer array SocketItem___SockInv
integer array SocketItem___SockLast
        
integer SocketLast
integer SocketSlot
integer SocketInv
integer array PlayerCamera
unit array PlayerHero
    // Generated
rect gg_rct_Region_001= null
rect gg_rct_Region_000= null
rect gg_rct_Region_002= null
rect gg_rct_Region_003= null
rect gg_rct_Region_004= null
rect gg_rct_Region_005= null
rect gg_rct_Region_006= null
rect gg_rct_Region_007= null
rect gg_rct_Region_008= null
rect gg_rct_Region_008_Copy= null
rect gg_rct_Region_010= null
rect gg_rct_Region_003_Copy= null
sound gg_snd_WaterWaterFallLoop1= null
sound gg_snd_FreakyForest4= null
trigger gg_trg_Melee_Initialization= null
trigger gg_trg_TurtleNet= null
unit gg_unit_ntrd_0023= null


//JASSHelper struct globals:



//JASSHelper struct globals:
constant integer si__DummyCaster=1
constant integer si__HeroModelData=2
integer si__HeroModelData_F=0
integer si__HeroModelData_I=0
integer array si__HeroModelData_V
string array s__HeroModelData_path
real array s__HeroModelData_scale
constant integer si__InventoryTable___GTable=3
integer si__InventoryTable___GTable_F=0
integer si__InventoryTable___GTable_I=0
integer array si__InventoryTable___GTable_V
constant integer si__InventoryTable=4
constant integer si__StringTable=5
constant integer si__HandleTable=6
constant integer si__IsDestructableTree__I=7
constant integer si__User=8
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
constant integer si__Table___dex=9
constant integer si__Table___handles=10
constant integer si__Table___agents=11
constant integer si__Table___reals=12
constant integer si__Table___booleans=13
constant integer si__Table___strings=14
constant integer si__Table___players=15
constant integer si__Table___widgets=16
constant integer si__Table___destructables=17
constant integer si__Table___items=18
constant integer si__Table___units=19
constant integer si__Table___abilitys=20
constant integer si__Table___timers=21
constant integer si__Table___triggers=22
constant integer si__Table___triggerconditions=23
constant integer si__Table___triggeractions=24
constant integer si__Table___events=25
constant integer si__Table___forces=26
constant integer si__Table___groups=27
constant integer si__Table___locations=28
constant integer si__Table___rects=29
constant integer si__Table___boolexprs=30
constant integer si__Table___sounds=31
constant integer si__Table___effects=32
constant integer si__Table___unitpools=33
constant integer si__Table___itempools=34
constant integer si__Table___quests=35
constant integer si__Table___questitems=36
constant integer si__Table___defeatconditions=37
constant integer si__Table___timerdialogs=38
constant integer si__Table___leaderboards=39
constant integer si__Table___multiboards=40
constant integer si__Table___multiboarditems=41
constant integer si__Table___trackables=42
constant integer si__Table___dialogs=43
constant integer si__Table___buttons=44
constant integer si__Table___texttags=45
constant integer si__Table___lightnings=46
constant integer si__Table___images=47
constant integer si__Table___ubersplats=48
constant integer si__Table___regions=49
constant integer si__Table___fogstates=50
constant integer si__Table___fogmodifiers=51
constant integer si__Table___hashtables=52
constant integer si__Table=53
constant integer si__TableArray=54
integer s__TableArray_tempTable
integer s__TableArray_tempEnd
constant integer si__VECTOR3=55
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
constant integer si__MATRIX3=56
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
constant integer si__MATRIX4=57
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
constant integer si__WorldBounds=58
integer s__WorldBounds_maxX
integer s__WorldBounds_maxY
integer s__WorldBounds_minX
integer s__WorldBounds_minY
integer s__WorldBounds_centerX
integer s__WorldBounds_centerY
rect s__WorldBounds_world
region s__WorldBounds_worldRegion
constant integer si__Camera=59
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
constant integer si__Camera___CamInit=60
integer si__Camera___CamInit_F=0
integer si__Camera___CamInit_I=0
integer array si__Camera___CamInit_V
constant integer si__InvItem=61
integer si__InvItem_F=0
integer si__InvItem_I=0
integer array si__InvItem_V
integer s__InvItem_InventoryTable
integer array s__InvItem_id
integer array s__InvItem_icon
integer array s__InvItem_cost
integer array s__InvItem_ability
string array s__InvItem_info
integer array s__InvItem_tempCustomId
constant integer s__InvItem_MAX_BONUSES= 1000
trigger s__InvItem_onEquip= null
trigger s__InvItem_onUnequip= null
trigger s__InvItem_equipEval= CreateTrigger()
unit s__InvItem_eventUnit= null
integer array s__InvItem_slot
integer array s__InvItem_slotAlt
integer array s__InvItem_equipAbility
integer array s__InvItem_reqLevel
integer array s__InvItem_reqUnitType
integer array s__InvItem_reqAbility
string array s__InvItem_class
boolexpr array s__InvItem_equipCondition
string array s__InvItem_equipConditionStr
string array s__InvItem_equipConditionStrPrefix
integer array s__InvItem_bonuses
constant integer s__InvItem_KeyBonusType=652
constant integer s__InvItem_KeyBonusAmount=3277
constant integer s__InvItem_KeyBonusMin=18
constant integer s__InvItem_KeyBonusMax=107
constant integer s__InvItem_KeyBonusRand=552
integer s__InvItem_KEY_BONUS_TYPE= INVENTORY_KEY_START + s__InvItem_KeyBonusType
integer s__InvItem_KEY_BONUS_AMOUNT= INVENTORY_KEY_START + s__InvItem_KeyBonusAmount
integer s__InvItem_KEY_BONUS_MIN= INVENTORY_KEY_START + s__InvItem_KeyBonusMin
integer s__InvItem_KEY_BONUS_MAX= INVENTORY_KEY_START + s__InvItem_KeyBonusMax
integer s__InvItem_KEY_BONUS_RND= INVENTORY_KEY_START + s__InvItem_KeyBonusRand
integer array s__InvItem_maxSockets
boolean array s__InvItem_isSocket
hashtable s__InvItem_SocketTable= InitHashtable()
constant integer s__InvItem_InvItemSocket___KEY_SOCKETS=2777
constant integer s__InvItem_InvItemSocket___KEY_SOCKETS_ID=5710
constant integer s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT=3991
constant integer si__InvCustomItem=62
integer s__InvCustomItem_Counter= 1
integer s__InvCustomItem_SeedTable
constant integer si__MissileStats=63
integer s__MissileStats_active= 0
integer s__MissileStats_peakActive= 0
integer s__MissileStats_created= 0
integer s__MissileStats_retired= 0
integer s__MissileStats_oldestSeconds= 0
integer s__MissileStats_tracked= 0
integer s__MissileStats_peakTracked= 0
integer s__MissileStats_borrowed= 0
integer s__MissileStats_pooled= 0
integer s__MissileStats_deferred= 0
integer s__MissileStats_pending= 0
integer s__MissileStats_overdue= 0
integer s__MissileStats_preloadTotal= 0
integer s__MissileStats_newTotal= 0
integer s__MissileStats_reusedTotal= 0
integer s__MissileStats_adoptedTotal= 0
integer s__MissileStats_disposed= 0
integer s__MissileStats_lost= 0
integer s__MissileStats_invalid= 0
integer s__MissileStats_omitted= 0
integer s__MissileStats_errors= 0
integer s__MissileStats_inconsistent= 0
integer s__MissileStats_alarms= 0
integer s__MissileStats_capacity= 0
integer s__MissileStats_checks= 0
integer s__MissileStats_renders= 0
multiboard s__MissileStats_board= null
constant integer s__MissileStats_LIMIT= 8190
constant real s__MissileStats_GRACE= 1.25
constant integer s__MissileStats_OLD_AGE= 30
integer s__MissileStats_index
timer s__MissileStats_clock= CreateTimer()
timer s__MissileStats_watcher= CreateTimer()
timer s__MissileStats_painter= CreateTimer()
boolean s__MissileStats_queued= false
boolean s__MissileStats_initialized= false
unit array s__MissileStats_units
integer array s__MissileStats_state
real array s__MissileStats_deadline
boolean array s__MissileStats_warned
integer array s__MissileStats_nodeSlot
integer array s__MissileStats_nodes
real array s__MissileStats_born
boolean array s__MissileStats_hidden
string array s__MissileStats_cell
string s__MissileStats_title= ""
constant integer si__SpellEffectEvent___S=64
integer s__SpellEffectEvent___S_tb
constant integer si__UnitDex=65
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
constant integer si__xepreload__Init=66
constant integer si__AutoIndex=67
integer si__AutoIndex_F=0
integer si__AutoIndex_I=0
integer array si__AutoIndex_V
integer array s__AutoIndex_indexfuncs
integer s__AutoIndex_indexfuncs_n= - 1
integer array s__AutoIndex_deindexfuncs
integer s__AutoIndex_deindexfuncs_n= - 1
integer s__AutoIndex_indexfunc
constant integer si__BonusMod___BonusInterface=68
integer si__BonusMod___BonusInterface_F=0
integer si__BonusMod___BonusInterface_I=0
integer array si__BonusMod___BonusInterface_V
integer array si__BonusMod___BonusInterface_type
trigger array st__BonusMod___BonusInterface_onDestroy
integer array s__BonusMod___BonusInterface_minBonus
integer array s__BonusMod___BonusInterface_maxBonus
trigger array st__BonusMod___BonusInterface_destroy
constant integer si__Bonus=69
boolean array s__Bonus_BonusMod___isBonusObject
constant integer si__BonusMod___AbilityBonus=70
integer array s__BonusMod___AbilityBonus_count
integer array s__BonusMod___AbilityBonus_rawcode
integer array s__BonusMod___AbilityBonus_negativeRawcode
integer array s__BonusMod___AbilityBonus_minBonus
integer array s__BonusMod___AbilityBonus_maxBonus
boolean array s__BonusMod___AbilityBonus_heroesOnly
constant integer si__BonusModStruct=71
constant integer si__UnitMaxState___Data=72
integer si__UnitMaxState___Data_F=0
integer si__UnitMaxState___Data_I=0
integer array si__UnitMaxState___Data_V
constant integer si__UIButton=73
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
timer array s__UIButton_clickTimer
integer array s__UIButton_unitId
integer array s__UIButton_Unit2Button
constant integer si__UIPicture=74
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
constant integer si__UIText=75
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
constant integer si__Interface=76
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
constant integer si__Inventory=77
integer si__Inventory_F=0
integer si__Inventory_I=0
integer array si__Inventory_V
real s__Inventory_X= 0.61
real s__Inventory_Y= - 0.3
real s__Inventory_SCALE= 0.228
real s__Inventory_TOOLTIP_X= - 0.7
real s__Inventory_TOOLTIP_Y= 0.0
integer s__Inventory_MAX_PAGES= 5
constant integer s__Inventory_BUTTON_ROWS= 6
constant integer s__Inventory_BUTTON_COLS= 5
constant real s__Inventory_UI_REFRESH_RATE= 0.01
constant boolean s__Inventory_SHOW_ERRORS= true
constant real s__Inventory_SLOT_WIDTH= 0.065
constant real s__Inventory_SLOT_HEIGHT= 0.065 * SCREEN_ASPECT_RATIO
constant real s__Inventory_SLOT_SPACING= 1.00
constant real s__Inventory_SLOT_OFFSET_X= - 0.0485
constant real s__Inventory_SLOT_OFFSET_Y= 0.072
constant integer s__Inventory_ICON_EMPTY= 'dbnk'
constant integer s__Inventory_ICON_TRANSPARENT= 'B00S'
constant integer s__Inventory_ICON_PAGEUP= 'B00U'
constant integer s__Inventory_ICON_PAGEDOWN= 'B00T'
constant integer s__Inventory_ICON_SELL= 'B011'
constant integer s__Inventory_ICON_DROP= 'B00N'
constant integer s__Inventory_RACE_BORDERS_START= 'D201'
constant integer s__Inventory_BACKGROUND= 'bwn2'
constant integer s__Inventory_MAX_SLOTS= s__Inventory_BUTTON_ROWS * s__Inventory_BUTTON_COLS
constant integer s__Inventory_MAX_ITEMS= s__Inventory_MAX_SLOTS * s__Inventory_MAX_PAGES
hashtable s__Inventory_Hashtable= InitHashtable()
trigger s__Inventory_ExecL= CreateTrigger()
trigger s__Inventory_ExecR= CreateTrigger()
integer s__Inventory_DisplayCount= 0
timer s__Inventory_UpdateTimer= CreateTimer()
integer array s__Inventory_PlayerCurrent
integer array s__Inventory_buttons
integer array s__Inventory_itemCount
integer array s__Inventory_next
integer array s__Inventory_prev
integer array s__Inventory_pid
integer array s__Inventory_user
unit array s__Inventory_owner
integer array s__Inventory_background
integer array s__Inventory_pageNum
integer array s__Inventory_btnPageUp
integer array s__Inventory_btnPageDown
integer array s__Inventory_btnSell
integer array s__Inventory_btnDrop
integer array s__Inventory_selector
integer array s__Inventory_camera
integer array s__Inventory_countTable
integer array s__Inventory_currentPage
boolean array s__Inventory_displayed
integer array s__Inventory_freeSlot
trigger s__Inventory_onSell
trigger s__Inventory_onDrop
constant integer s__Inventory_KEY_ITEMS=3588
constant integer s__Inventory_KEY_ITEM_ID=1573
constant integer s__Inventory_KeyUnit=7882
constant integer s__Inventory_KEY_UNIT= INVENTORY_KEY_START + s__Inventory_KeyUnit
constant integer s__Inventory_KeyItemCount=6659
constant integer s__Inventory_KEY_ITEM_COUNT= INVENTORY_KEY_START + s__Inventory_KeyItemCount
constant integer s__Inventory_TOOLTIP_LINE_LENGTH= 32
constant integer s__Inventory_TOOLTIP_LINES_MAX= 16
constant integer s__Inventory_TOOLTIP_TEXTURE= 'B014'
constant real s__Inventory_TOOLTIP_LINE_SPACING= .05
constant real s__Inventory_TOOLTIP_FONT_SIZE= 7.5
constant integer s__Inventory_ICON_TOOLTIP_GOLD= 'B00H'
constant integer s__Inventory_TOOLTIP_BACKGROUND= 'ttip'
integer array s__Inventory_RightSideStart
integer array s__Inventory_infoBoxTitle
integer array s__Inventory_infoBoxCost
integer array s__Inventory_infoBoxDesc
integer array s__Inventory_infoBox
integer array s__Inventory_infoIcon
integer array s__Inventory_costIcon
constant integer si__Missile__RecycleBin=79
constant timer s__Missile__RecycleBin_t= CreateTimer()
integer s__Missile__RecycleBin_max= 0
unit array s__Missile__RecycleBin_dummy
real array s__Missile__RecycleBin_time
constant integer si__MissilePosition=80
integer array s__MissilePosition_recycler
integer s__MissilePosition_alloc= 0
real array s__MissilePosition_x
real array s__MissilePosition_y
real array s__MissilePosition_z
real array s__MissilePosition_angle
real array s__MissilePosition_distance
real array s__MissilePosition_square
real array s__MissilePosition_slope
real array s__MissilePosition_alpha
integer array s__MissilePosition_ref
constant integer si__Missile=81
integer s__Missile_Missile__MissileStructure__collectionCount= 0
integer s__Missile_Missile__MissileStructure__nodeCount= 0
integer array s__Missile_Missile__MissileStructure___list
integer array s__Missile_Missile__MissileStructure___next
integer array s__Missile_Missile__MissileStructure___prev
integer array s__Missile_Missile__MissileStructure___first
integer array s__Missile_Missile__MissileStructure___last
constant string s__Missile_ORIGIN= "origin"
constant real s__Missile_HIT_BOX= ( 2. / 3. )
real array s__Missile_posX
real array s__Missile_posY
real array s__Missile_dist
boolean array s__Missile_allocated
unit array s__Missile_dummy
integer array s__Missile_origin
integer array s__Missile_impact
real array s__Missile_terrainZ
real array s__Missile_x
real array s__Missile_y
real array s__Missile_z
real array s__Missile_angle
real array s__Missile_prevX
real array s__Missile_prevY
real array s__Missile_prevZ
integer array s__Missile_collisionType
unit array s__Missile_source
unit array s__Missile_target
real array s__Missile_distance
player array s__Missile_owner
real array s__Missile_speed
real array s__Missile_acceleration
real array s__Missile_damage
integer array s__Missile_data
boolean array s__Missile_recycle
real array s__Missile_turn
real array s__Missile_collision
effect array s__Missile_sfx
string array s__Missile_path
real array s__Missile_open
real array s__Missile_height
real array s__Missile_scaling
boolean array s__Missile_wantDestroy
integer s__Missile_temp= 0
integer array s__Missile_stackSize
boolean s__Missile_circle= true
constant integer si__MovementBonus__BonusValue=82
integer si__MovementBonus__BonusValue_F=0
integer si__MovementBonus__BonusValue_I=0
integer array si__MovementBonus__BonusValue_V
integer array s__MovementBonus__BonusValue_speed
unit array s__MovementBonus__BonusValue_owner
integer array s__MovementBonus__BonusValue_owners
integer array s__MovementBonus__BonusValue_all
integer s__MovementBonus__BonusValue_count= 0
integer array s__MovementBonus__BonusValue_index
constant integer si__MovementBonus__MovementBonus=83
integer array s__MovementBonus__MovementBonus_minBonus
integer array s__MovementBonus__MovementBonus_maxBonus
constant integer si__RegenBonuses__BonusValues=84
integer si__RegenBonuses__BonusValues_F=0
integer si__RegenBonuses__BonusValues_I=0
integer array si__RegenBonuses__BonusValues_V
integer array s__RegenBonuses__BonusValues_manaRegen
integer array s__RegenBonuses__BonusValues_lifeRegen
unit array s__RegenBonuses__BonusValues_owner
integer array s__RegenBonuses__BonusValues_owners
integer array s__RegenBonuses__BonusValues_all
integer s__RegenBonuses__BonusValues_count= 0
integer array s__RegenBonuses__BonusValues_index
constant integer si__RegenBonuses__RegenBonus_life=85
integer array s__RegenBonuses__RegenBonus_life_minBonus
integer array s__RegenBonuses__RegenBonus_life_maxBonus
constant integer si__RegenBonuses__RegenBonus_mana=86
integer array s__RegenBonuses__RegenBonus_mana_minBonus
integer array s__RegenBonuses__RegenBonus_mana_maxBonus
constant integer si__UnitMaxStateBonuses___BonusValues=87
integer si__UnitMaxStateBonuses___BonusValues_F=0
integer si__UnitMaxStateBonuses___BonusValues_I=0
integer array si__UnitMaxStateBonuses___BonusValues_V
integer array s__UnitMaxStateBonuses___BonusValues_mana
integer array s__UnitMaxStateBonuses___BonusValues_life
unit array s__UnitMaxStateBonuses___BonusValues_owner
integer array s__UnitMaxStateBonuses___BonusValues_owners
constant integer si__UnitMaxStateBonuses___MaxStateBonus_life=88
integer array s__UnitMaxStateBonuses___MaxStateBonus_life_minBonus
integer array s__UnitMaxStateBonuses___MaxStateBonus_life_maxBonus
constant integer si__UnitMaxStateBonuses___MaxStateBonus_mana=89
integer array s__UnitMaxStateBonuses___MaxStateBonus_mana_minBonus
integer array s__UnitMaxStateBonuses___MaxStateBonus_mana_maxBonus
constant integer si__UnitMaxStateBonuses___Data=90
integer si__UnitMaxStateBonuses___Data_F=0
integer si__UnitMaxStateBonuses___Data_I=0
integer array si__UnitMaxStateBonuses___Data_V
constant integer si__YesNoDialog=91
constant integer si__Equipment=92
integer si__Equipment_F=0
integer si__Equipment_I=0
integer array si__Equipment_V
constant real s__Equipment_X= 0.425
constant real s__Equipment_Y= .93
constant real s__Equipment_WINDOW_SIZE= 0.28
constant real s__Equipment_SLOT_OFFSET_Y= 0.065
constant real s__Equipment_SLOT_OFFSET_ROWRIGHT_X= 0.460
constant real s__Equipment_SLOT_OFFSET_ROWLEFT_X= 0.105
constant real s__Equipment_HERO_NAME_Y= 0.9
constant real s__Equipment_CHARMODEL_OFFSET_X= s__Equipment_X + 0.32
constant real s__Equipment_CHARMODEL_OFFSET_Y= 0.200
constant integer s__Equipment_MAX_SLOTS= 14
constant real s__Equipment_SLOT_WIDTH= 0.090
constant real s__Equipment_SLOT_HEIGHT= 0.090 * SCREEN_ASPECT_RATIO
constant integer s__Equipment_MODEL_DUMMY= 'e000'
constant integer s__Equipment_WINDOW_DUMMY= 'ewin'
boolean s__Equipment_Initialized= false
integer s__Equipment_DisplayCount= 0
hashtable s__Equipment_Hashtable
timer s__Equipment_UpdateTimer
unit array s__Equipment_PlayerCurrentUnit
integer array s__Equipment_UnitsIndex
integer array s___Equipment_item
constant integer s___Equipment_item_size=14
integer array s__Equipment_item
integer array s___Equipment_itemId
constant integer s___Equipment_itemId_size=14
integer array s__Equipment_itemId
integer array s__Equipment_selector
integer array s__Equipment_title
trigger s__Equipment_onSocket
integer array s__Equipment_charModel
integer array s__Equipment_camera
unit array s__Equipment_unit
player array s__Equipment_player
integer array s__Equipment_user
boolean array s__Equipment_displayed
integer array s__Equipment_next
integer array s__Equipment_prev
integer array s__TimerUtils__data
timer array s__TimerUtils__tT
integer array s__s__Inventory_ItemInfoTags
integer array s__s__Equipment_buttons
integer array s__s__Equipment_slotButton
integer array s__s__Equipment_pictures
trigger array st__Bonus_setBonus
trigger array st__Bonus_getBonus
trigger array st__Bonus_removeBonus
trigger array st__Bonus_isValidBonus
integer array si__InventoryTable___GTable_type
trigger array st__InventoryTable___GTable_onDestroy
trigger st__InventoryTable__getindex
trigger st__InventoryTable__setindex
trigger st__InvItem__get_sockets
trigger st__InvItem_socketId
trigger st__InvItem_getSocket
trigger st__InvCustomItem_seed
trigger st__UnitDex_Remove
trigger st__Bonus_create
trigger st__BonusMod___AbilityBonus_create
trigger st__BonusModStruct_addBonus
trigger st__UIButton_show
trigger st__UIPicture_show
trigger st__UIText_show
trigger st__Inventory_setTooltipLine
trigger st__Inventory_setTooltipSlot
trigger st__Inventory_clearLines
trigger st__MovementBonus__BonusValue_onDestroy
trigger st__RegenBonuses__BonusValues_onDestroy
trigger st__UnitMaxStateBonuses___BonusValues_onDestroy
trigger array st___prototype3
trigger array st___prototype43
trigger array st___prototype46
trigger array st___prototype47
integer f__result_integer
trigger array st___prototype48
trigger array st___prototype76
integer f__arg_integer1
integer f__arg_integer2
integer f__arg_integer3
unit f__arg_unit1
boolean f__arg_boolean1
string f__arg_string1
integer f__arg_this
boolean f__result_boolean

endglobals
    native UnitAlive takes unit id returns boolean


//Generated allocator of Equipment
function s__Equipment__allocate takes nothing returns integer
 local integer this=si__Equipment_F
    if (this!=0) then
        set si__Equipment_F=si__Equipment_V[this]
    else
        set si__Equipment_I=si__Equipment_I+1
        set this=si__Equipment_I
    endif
    if (this>584) then
        return 0
    endif
    set s__Equipment_item[this]=(this-1)*14
    set s__Equipment_itemId[this]=(this-1)*14
    set si__Equipment_V[this]=-1
 return this
endfunction

//Generated destructor of Equipment
function s__Equipment_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Equipment_V[this]!=-1) then
        return
    endif
    set si__Equipment_V[this]=si__Equipment_F
    set si__Equipment_F=this
endfunction

//Generated allocator of UnitMaxStateBonuses___Data
function s__UnitMaxStateBonuses___Data__allocate takes nothing returns integer
 local integer this=si__UnitMaxStateBonuses___Data_F
    if (this!=0) then
        set si__UnitMaxStateBonuses___Data_F=si__UnitMaxStateBonuses___Data_V[this]
    else
        set si__UnitMaxStateBonuses___Data_I=si__UnitMaxStateBonuses___Data_I+1
        set this=si__UnitMaxStateBonuses___Data_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__UnitMaxStateBonuses___Data_V[this]=-1
 return this
endfunction

//Generated destructor of UnitMaxStateBonuses___Data
function s__UnitMaxStateBonuses___Data_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__UnitMaxStateBonuses___Data_V[this]!=-1) then
        return
    endif
    set si__UnitMaxStateBonuses___Data_V[this]=si__UnitMaxStateBonuses___Data_F
    set si__UnitMaxStateBonuses___Data_F=this
endfunction

//Generated allocator of HeroModelData
function s__HeroModelData__allocate takes nothing returns integer
 local integer this=si__HeroModelData_F
    if (this!=0) then
        set si__HeroModelData_F=si__HeroModelData_V[this]
    else
        set si__HeroModelData_I=si__HeroModelData_I+1
        set this=si__HeroModelData_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__HeroModelData_V[this]=-1
 return this
endfunction

//Generated destructor of HeroModelData
function s__HeroModelData_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__HeroModelData_V[this]!=-1) then
        return
    endif
    set si__HeroModelData_V[this]=si__HeroModelData_F
    set si__HeroModelData_F=this
endfunction

//Generated method caller for InventoryTable___GTable.onDestroy
function sc__InventoryTable___GTable_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__InventoryTable___GTable_onDestroy[3])
endfunction

//Generated allocator of InventoryTable___GTable
function s__InventoryTable___GTable__allocate takes nothing returns integer
 local integer this=si__InventoryTable___GTable_F
    if (this!=0) then
        set si__InventoryTable___GTable_F=si__InventoryTable___GTable_V[this]
    else
        set si__InventoryTable___GTable_I=si__InventoryTable___GTable_I+1
        set this=si__InventoryTable___GTable_I
    endif
    if (this>8100) then
        return 0
    endif

    set si__InventoryTable___GTable_type[this]=3
    set si__InventoryTable___GTable_V[this]=-1
 return this
endfunction

//Generated destructor of InventoryTable___GTable
function sc__InventoryTable___GTable_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__InventoryTable___GTable_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__InventoryTable___GTable_onDestroy[si__InventoryTable___GTable_type[this]])
    set si__InventoryTable___GTable_V[this]=si__InventoryTable___GTable_F
    set si__InventoryTable___GTable_F=this
endfunction

//Generated method caller for UnitMaxStateBonuses___BonusValues.onDestroy
function sc__UnitMaxStateBonuses___BonusValues_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__UnitMaxStateBonuses___BonusValues_onDestroy)
endfunction

//Generated allocator of UnitMaxStateBonuses___BonusValues
function s__UnitMaxStateBonuses___BonusValues__allocate takes nothing returns integer
 local integer this=si__UnitMaxStateBonuses___BonusValues_F
    if (this!=0) then
        set si__UnitMaxStateBonuses___BonusValues_F=si__UnitMaxStateBonuses___BonusValues_V[this]
    else
        set si__UnitMaxStateBonuses___BonusValues_I=si__UnitMaxStateBonuses___BonusValues_I+1
        set this=si__UnitMaxStateBonuses___BonusValues_I
    endif
    if (this>8190) then
        return 0
    endif

   set s__UnitMaxStateBonuses___BonusValues_mana[this]= 0
   set s__UnitMaxStateBonuses___BonusValues_life[this]= 0
    set si__UnitMaxStateBonuses___BonusValues_V[this]=-1
 return this
endfunction

//Generated destructor of UnitMaxStateBonuses___BonusValues
function sc__UnitMaxStateBonuses___BonusValues_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__UnitMaxStateBonuses___BonusValues_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__UnitMaxStateBonuses___BonusValues_onDestroy)
    set si__UnitMaxStateBonuses___BonusValues_V[this]=si__UnitMaxStateBonuses___BonusValues_F
    set si__UnitMaxStateBonuses___BonusValues_F=this
endfunction

//Generated method caller for InventoryTable._getindex
function sc__InventoryTable__getindex takes integer this,integer key returns integer
    set f__arg_this=this
    set f__arg_integer1=key
    call TriggerEvaluate(st__InventoryTable__getindex)
 return f__result_integer
endfunction

//Generated method caller for InventoryTable._setindex
function sc__InventoryTable__setindex takes integer this,integer key,integer value returns nothing
    set f__arg_this=this
    set f__arg_integer1=key
    set f__arg_integer2=value
    call TriggerEvaluate(st__InventoryTable__setindex)
endfunction

//Generated allocator of InventoryTable
function s__InventoryTable__allocate takes nothing returns integer
 local integer this=s__InventoryTable___GTable__allocate()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__InventoryTable___GTable_type[this]=4
    set kthis=this

 return this
endfunction


//Generated allocator of StringTable
function s__StringTable__allocate takes nothing returns integer
 local integer this=s__InventoryTable___GTable__allocate()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__InventoryTable___GTable_type[this]=5
    set kthis=this

 return this
endfunction


//Generated method caller for RegenBonuses__BonusValues.onDestroy
function sc__RegenBonuses__BonusValues_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__RegenBonuses__BonusValues_onDestroy)
endfunction

//Generated allocator of RegenBonuses__BonusValues
function s__RegenBonuses__BonusValues__allocate takes nothing returns integer
 local integer this=si__RegenBonuses__BonusValues_F
    if (this!=0) then
        set si__RegenBonuses__BonusValues_F=si__RegenBonuses__BonusValues_V[this]
    else
        set si__RegenBonuses__BonusValues_I=si__RegenBonuses__BonusValues_I+1
        set this=si__RegenBonuses__BonusValues_I
    endif
    if (this>8190) then
        return 0
    endif

   set s__RegenBonuses__BonusValues_manaRegen[this]= 0
   set s__RegenBonuses__BonusValues_lifeRegen[this]= 0
    set si__RegenBonuses__BonusValues_V[this]=-1
 return this
endfunction

//Generated destructor of RegenBonuses__BonusValues
function sc__RegenBonuses__BonusValues_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__RegenBonuses__BonusValues_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__RegenBonuses__BonusValues_onDestroy)
    set si__RegenBonuses__BonusValues_V[this]=si__RegenBonuses__BonusValues_F
    set si__RegenBonuses__BonusValues_F=this
endfunction

//Generated allocator of HandleTable
function s__HandleTable__allocate takes nothing returns integer
 local integer this=s__InventoryTable___GTable__allocate()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__InventoryTable___GTable_type[this]=6
    set kthis=this

 return this
endfunction


//Generated method caller for MovementBonus__BonusValue.onDestroy
function sc__MovementBonus__BonusValue_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__MovementBonus__BonusValue_onDestroy)
endfunction

//Generated allocator of MovementBonus__BonusValue
function s__MovementBonus__BonusValue__allocate takes nothing returns integer
 local integer this=si__MovementBonus__BonusValue_F
    if (this!=0) then
        set si__MovementBonus__BonusValue_F=si__MovementBonus__BonusValue_V[this]
    else
        set si__MovementBonus__BonusValue_I=si__MovementBonus__BonusValue_I+1
        set this=si__MovementBonus__BonusValue_I
    endif
    if (this>8190) then
        return 0
    endif

   set s__MovementBonus__BonusValue_speed[this]= 0
    set si__MovementBonus__BonusValue_V[this]=-1
 return this
endfunction

//Generated destructor of MovementBonus__BonusValue
function sc__MovementBonus__BonusValue_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__MovementBonus__BonusValue_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__MovementBonus__BonusValue_onDestroy)
    set si__MovementBonus__BonusValue_V[this]=si__MovementBonus__BonusValue_F
    set si__MovementBonus__BonusValue_F=this
endfunction

//Generated method caller for Inventory.setTooltipLine
function sc__Inventory_setTooltipLine takes integer pid,integer line,string str returns nothing
    set f__arg_integer1=pid
    set f__arg_integer2=line
    set f__arg_string1=str
    call TriggerEvaluate(st__Inventory_setTooltipLine)
endfunction

//Generated method caller for Inventory.setTooltipSlot
function sc__Inventory_setTooltipSlot takes integer pid,integer line,string str returns nothing
    set f__arg_integer1=pid
    set f__arg_integer2=line
    set f__arg_string1=str
    call TriggerEvaluate(st__Inventory_setTooltipSlot)
endfunction

//Generated method caller for Inventory.clearLines
function sc__Inventory_clearLines takes integer pid returns nothing
    set f__arg_integer1=pid
    call TriggerEvaluate(st__Inventory_clearLines)
endfunction

//Generated allocator of Inventory
function s__Inventory__allocate takes nothing returns integer
 local integer this=si__Inventory_F
    if (this!=0) then
        set si__Inventory_F=si__Inventory_V[this]
    else
        set si__Inventory_I=si__Inventory_I+1
        set this=si__Inventory_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Inventory_V[this]=-1
 return this
endfunction

//Generated destructor of Inventory
function s__Inventory_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Inventory_V[this]!=-1) then
        return
    endif
    set si__Inventory_V[this]=si__Inventory_F
    set si__Inventory_F=this
endfunction

//Generated method caller for UIText.show
function sc__UIText_show takes integer this,boolean show,integer Cam returns nothing
    set f__arg_this=this
    set f__arg_boolean1=show
    set f__arg_integer1=Cam
    call TriggerEvaluate(st__UIText_show)
endfunction

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

//Generated method caller for UIPicture.show
function sc__UIPicture_show takes integer this,boolean show,integer Cam returns nothing
    set f__arg_this=this
    set f__arg_boolean1=show
    set f__arg_integer1=Cam
    call TriggerEvaluate(st__UIPicture_show)
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

//Generated method caller for UIButton.show
function sc__UIButton_show takes integer this,boolean flag,integer Cam returns nothing
    set f__arg_this=this
    set f__arg_boolean1=flag
    set f__arg_integer1=Cam
    call TriggerEvaluate(st__UIButton_show)
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

//Generated allocator of UnitMaxState___Data
function s__UnitMaxState___Data__allocate takes nothing returns integer
 local integer this=si__UnitMaxState___Data_F
    if (this!=0) then
        set si__UnitMaxState___Data_F=si__UnitMaxState___Data_V[this]
    else
        set si__UnitMaxState___Data_I=si__UnitMaxState___Data_I+1
        set this=si__UnitMaxState___Data_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__UnitMaxState___Data_V[this]=-1
 return this
endfunction

//Generated destructor of UnitMaxState___Data
function s__UnitMaxState___Data_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__UnitMaxState___Data_V[this]!=-1) then
        return
    endif
    set si__UnitMaxState___Data_V[this]=si__UnitMaxState___Data_F
    set si__UnitMaxState___Data_F=this
endfunction

//Generated method caller for BonusModStruct.addBonus
function sc__BonusModStruct_addBonus takes unit u,integer bonus,integer amount returns integer
    set f__arg_unit1=u
    set f__arg_integer1=bonus
    set f__arg_integer2=amount
    call TriggerEvaluate(st__BonusModStruct_addBonus)
 return f__result_integer
endfunction

//Generated method caller for BonusMod___BonusInterface.destroy
function sc__BonusMod___BonusInterface_destroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__BonusMod___BonusInterface_destroy[si__BonusMod___BonusInterface_type[this]])
endfunction

//Generated method executor for BonusMod___BonusInterface.destroy
function sx__BonusMod___BonusInterface_destroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__BonusMod___BonusInterface_destroy[si__BonusMod___BonusInterface_type[this]])
endfunction
//Generated destructor of BonusMod___BonusInterface
function sc__BonusMod___BonusInterface_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__BonusMod___BonusInterface_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__BonusMod___BonusInterface_onDestroy[si__BonusMod___BonusInterface_type[this]])
    set si__BonusMod___BonusInterface_V[this]=si__BonusMod___BonusInterface_F
    set si__BonusMod___BonusInterface_F=this
endfunction

//Generated allocator of AutoIndex
function s__AutoIndex__allocate takes nothing returns integer
 local integer this=si__AutoIndex_F
    if (this!=0) then
        set si__AutoIndex_F=si__AutoIndex_V[this]
    else
        set si__AutoIndex_I=si__AutoIndex_I+1
        set this=si__AutoIndex_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__AutoIndex_V[this]=-1
 return this
endfunction

//Generated destructor of AutoIndex
function s__AutoIndex_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__AutoIndex_V[this]!=-1) then
        return
    endif
    set si__AutoIndex_V[this]=si__AutoIndex_F
    set si__AutoIndex_F=this
endfunction

//Generated method caller for UnitDex.Remove
function sc__UnitDex_Remove takes unit u,boolean runEvents returns boolean
    set f__arg_unit1=u
    set f__arg_boolean1=runEvents
    call TriggerEvaluate(st__UnitDex_Remove)
 return f__result_boolean
endfunction

//Generated method caller for InvCustomItem.seed
function sc__InvCustomItem_seed takes integer this returns integer
    set f__arg_this=this
    call TriggerEvaluate(st__InvCustomItem_seed)
 return f__result_integer
endfunction

//Generated method caller for InvItem._get_sockets
function sc__InvItem__get_sockets takes integer this returns integer
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)
endfunction

//Generated method caller for InvItem.socketId
function sc__InvItem_socketId takes integer this,integer index returns integer
    set f__arg_this=this
    set f__arg_integer1=index
    call TriggerEvaluate(st__InvItem_socketId)
 return f__result_integer
endfunction

//Generated method caller for InvItem.getSocket
function sc__InvItem_getSocket takes integer this,integer index returns integer
    set f__arg_this=this
    set f__arg_integer1=index
    call TriggerEvaluate(st__InvItem_getSocket)
 return f__result_integer
endfunction

//Generated allocator of InvItem
function s__InvItem__allocate takes nothing returns integer
 local integer this=si__InvItem_F
    if (this!=0) then
        set si__InvItem_F=si__InvItem_V[this]
    else
        set si__InvItem_I=si__InvItem_I+1
        set this=si__InvItem_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__InvItem_V[this]=-1
 return this
endfunction

//Generated destructor of InvItem
function s__InvItem_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__InvItem_V[this]!=-1) then
        return
    endif
    set si__InvItem_V[this]=si__InvItem_F
    set si__InvItem_F=this
endfunction

//Generated allocator of Camera___CamInit
function s__Camera___CamInit__allocate takes nothing returns integer
 local integer this=si__Camera___CamInit_F
    if (this!=0) then
        set si__Camera___CamInit_F=si__Camera___CamInit_V[this]
    else
        set si__Camera___CamInit_I=si__Camera___CamInit_I+1
        set this=si__Camera___CamInit_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Camera___CamInit_V[this]=-1
 return this
endfunction

//Generated destructor of Camera___CamInit
function s__Camera___CamInit_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Camera___CamInit_V[this]!=-1) then
        return
    endif
    set si__Camera___CamInit_V[this]=si__Camera___CamInit_F
    set si__Camera___CamInit_F=this
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

//Generated method caller for Bonus.create
function sc__Bonus_create takes nothing returns integer
    call TriggerEvaluate(st__Bonus_create)
 return f__result_integer
endfunction

//Generated method caller for Bonus.setBonus
function sc__Bonus_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[si__BonusMod___BonusInterface_type[this]])
 return f__result_integer
endfunction

//Generated method caller for Bonus.getBonus
function sc__Bonus_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[si__BonusMod___BonusInterface_type[this]])
 return f__result_integer
endfunction

//Generated method caller for Bonus.removeBonus
function sc__Bonus_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[si__BonusMod___BonusInterface_type[this]])
endfunction

//Generated method caller for Bonus.isValidBonus
function sc__Bonus_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[si__BonusMod___BonusInterface_type[this]])
 return f__result_boolean
endfunction

//Generated allocator of Bonus
function s__Bonus__allocate takes nothing returns integer
 local integer kthis
 local integer this=si__BonusMod___BonusInterface_F
    if (this!=0) then
        set si__BonusMod___BonusInterface_F=si__BonusMod___BonusInterface_V[this]
    else
        set si__BonusMod___BonusInterface_I=si__BonusMod___BonusInterface_I+1
        set this=si__BonusMod___BonusInterface_I
    endif
    if (this>8190) then
        return 0
    endif

   set s__BonusMod___BonusInterface_minBonus[this]= 0
   set s__BonusMod___BonusInterface_maxBonus[this]= 0
    set si__BonusMod___BonusInterface_type[this]=69
    set kthis=this

   set s__Bonus_BonusMod___isBonusObject[this]= false
    set si__BonusMod___BonusInterface_V[this]=-1
 return this
endfunction


//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.setBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[89])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.getBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[89])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.removeBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[89])
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.isValidBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[89])
 return f__result_boolean
endfunction

//Generated allocator of UnitMaxStateBonuses___MaxStateBonus_mana
function s__UnitMaxStateBonuses___MaxStateBonus_mana__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=89
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]= - 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=  2147483647
 return this
endfunction


//Generated method caller for BonusMod___AbilityBonus.create
function sc__BonusMod___AbilityBonus_create takes integer rawcode,integer count,integer negativeRawcode,boolean heroesOnly returns integer
    set f__arg_integer1=rawcode
    set f__arg_integer2=count
    set f__arg_integer3=negativeRawcode
    set f__arg_boolean1=heroesOnly
    call TriggerEvaluate(st__BonusMod___AbilityBonus_create)
 return f__result_integer
endfunction

//Generated method caller for BonusMod___AbilityBonus.setBonus
function sc__BonusMod___AbilityBonus_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[70])
 return f__result_integer
endfunction

//Generated method caller for BonusMod___AbilityBonus.getBonus
function sc__BonusMod___AbilityBonus_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[70])
 return f__result_integer
endfunction

//Generated method caller for BonusMod___AbilityBonus.removeBonus
function sc__BonusMod___AbilityBonus_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[70])
endfunction

//Generated method caller for BonusMod___AbilityBonus.isValidBonus
function sc__BonusMod___AbilityBonus_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[70])
 return f__result_boolean
endfunction

//Generated allocator of BonusMod___AbilityBonus
function s__BonusMod___AbilityBonus__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=70
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]= 0
   set s__BonusMod___BonusInterface_maxBonus[this]= 0
 return this
endfunction


//Generated method caller for MovementBonus__MovementBonus.setBonus
function sc__MovementBonus__MovementBonus_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[83])
 return f__result_integer
endfunction

//Generated method caller for MovementBonus__MovementBonus.getBonus
function sc__MovementBonus__MovementBonus_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[83])
 return f__result_integer
endfunction

//Generated method caller for MovementBonus__MovementBonus.removeBonus
function sc__MovementBonus__MovementBonus_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[83])
endfunction

//Generated method caller for MovementBonus__MovementBonus.isValidBonus
function sc__MovementBonus__MovementBonus_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[83])
 return f__result_boolean
endfunction

//Generated allocator of MovementBonus__MovementBonus
function s__MovementBonus__MovementBonus__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=83
    set kthis=this

 return this
endfunction


//Generated method caller for RegenBonuses__RegenBonus_life.setBonus
function sc__RegenBonuses__RegenBonus_life_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[85])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses__RegenBonus_life.getBonus
function sc__RegenBonuses__RegenBonus_life_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[85])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses__RegenBonus_life.removeBonus
function sc__RegenBonuses__RegenBonus_life_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[85])
endfunction

//Generated method caller for RegenBonuses__RegenBonus_life.isValidBonus
function sc__RegenBonuses__RegenBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[85])
 return f__result_boolean
endfunction

//Generated allocator of RegenBonuses__RegenBonus_life
function s__RegenBonuses__RegenBonus_life__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=85
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]= - 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=  2147483647
 return this
endfunction


//Generated method caller for RegenBonuses__RegenBonus_mana.setBonus
function sc__RegenBonuses__RegenBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[86])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses__RegenBonus_mana.getBonus
function sc__RegenBonuses__RegenBonus_mana_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[86])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses__RegenBonus_mana.removeBonus
function sc__RegenBonuses__RegenBonus_mana_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[86])
endfunction

//Generated method caller for RegenBonuses__RegenBonus_mana.isValidBonus
function sc__RegenBonuses__RegenBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[86])
 return f__result_boolean
endfunction

//Generated allocator of RegenBonuses__RegenBonus_mana
function s__RegenBonuses__RegenBonus_mana__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=86
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]= - 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=  2147483647
 return this
endfunction


//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.setBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[88])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.getBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[88])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.removeBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[88])
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.isValidBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[88])
 return f__result_boolean
endfunction

//Generated allocator of UnitMaxStateBonuses___MaxStateBonus_life
function s__UnitMaxStateBonuses___MaxStateBonus_life__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=88
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]= - 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=  2147483647
 return this
endfunction

function sc___prototype3_execute takes integer i returns nothing

    call TriggerExecute(st___prototype3[i])
endfunction
function sc___prototype3_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype3[i])

endfunction
function sc___prototype43_execute takes integer i,unit a1 returns nothing
    set f__arg_unit1=a1

    call TriggerExecute(st___prototype43[i])
endfunction
function sc___prototype43_evaluate takes integer i,unit a1 returns nothing
    set f__arg_unit1=a1

    call TriggerEvaluate(st___prototype43[i])

endfunction
function sc___prototype46_execute takes integer i,unit a1,integer a2 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerExecute(st___prototype46[i])
endfunction
function sc___prototype46_evaluate takes integer i,unit a1,integer a2 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerEvaluate(st___prototype46[i])

endfunction
function sc___prototype47_execute takes integer i,unit a1,integer a2,integer a3 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2
    set f__arg_integer2=a3

    call TriggerExecute(st___prototype47[i])
endfunction
function sc___prototype47_evaluate takes integer i,unit a1,integer a2,integer a3 returns integer
    set f__arg_unit1=a1
    set f__arg_integer1=a2
    set f__arg_integer2=a3

    call TriggerEvaluate(st___prototype47[i])
 return f__result_integer
endfunction
function sc___prototype48_execute takes integer i,unit a1,integer a2 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerExecute(st___prototype48[i])
endfunction
function sc___prototype48_evaluate takes integer i,unit a1,integer a2 returns integer
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerEvaluate(st___prototype48[i])
 return f__result_integer
endfunction
function sc___prototype76_execute takes integer i,integer a1,string a2 returns nothing
    set f__arg_integer1=a1
    set f__arg_string1=a2

    call TriggerExecute(st___prototype76[i])
endfunction
function sc___prototype76_evaluate takes integer i,integer a1,string a2 returns integer
    set f__arg_integer1=a1
    set f__arg_string1=a2

    call TriggerEvaluate(st___prototype76[i])
 return f__result_integer
endfunction


//Implemented from module DummyCaster___N:
        function s__DummyCaster_DummyCaster___N__onInit takes nothing returns nothing





                set DummyCaster___u=CreateUnit(DummyCaster___PLAYER_OWNER, UNITS_DUMMY_CASTER, 0, 0, 0)

            call SetUnitPosition(DummyCaster___u, 32256, 32256)
        endfunction
        function s__DummyCaster_prep takes integer a,player p,integer l returns nothing
            call UnitAddAbility(DummyCaster___u, a)
            if ( 1 < l ) then
                call SetUnitAbilityLevel(DummyCaster___u, a, l)
            endif
            if ( null != p ) then
                call SetUnitOwner(DummyCaster___u, p, false)
            endif
        endfunction
        function s__DummyCaster_finish takes integer a returns nothing
            call SetUnitOwner(DummyCaster___u, DummyCaster___PLAYER_OWNER, false)
            call UnitRemoveAbility(DummyCaster___u, a)
        endfunction
        function s__DummyCaster_cast takes integer this,player p,integer level,integer order,real x,real y returns boolean
            local boolean b
            call SetUnitX(DummyCaster___u, x)
            call SetUnitY(DummyCaster___u, y)
            call s__DummyCaster_prep(this , p , level)
            set b=IssueImmediateOrderById(DummyCaster___u, order)
            call s__DummyCaster_finish(this)
            call SetUnitPosition(DummyCaster___u, 32256, 32256)
            return b
        endfunction
        function s__DummyCaster_castTarget takes integer this,player p,integer level,integer order,widget t returns boolean
            local boolean b
            call s__DummyCaster_prep(this , p , level)
            set b=IssueTargetOrderById(DummyCaster___u, order, t)
            call s__DummyCaster_finish(this)
            return b
        endfunction
        function s__DummyCaster_castPoint takes integer this,player p,integer level,integer order,real x,real y returns boolean
            local boolean b
            call s__DummyCaster_prep(this , p , level)
            set b=IssuePointOrderById(DummyCaster___u, order, x, y)
            call s__DummyCaster_finish(this)
            return b
        endfunction

    
    
    
    function EquipSetHeroModel takes integer utype,real scale,string path returns nothing
        local integer data= s__HeroModelData__allocate()
        set s__HeroModelData_path[data]=path
        set s__HeroModelData_scale[data]=scale
        call sc__InventoryTable__setindex(EquipHeroModels___HeroModels,utype, data)
    endfunction
    
    function EquipGetHeroModel takes integer id returns integer
        return sc__InventoryTable__getindex(EquipHeroModels___HeroModels,id)
    endfunction
    
    function EquipHeroModels___Init takes nothing returns nothing
        set EquipHeroModels___HeroModels=s__InventoryTable__allocate()
        
        //
        // configuration
        //
        call EquipSetHeroModel('Hpal' , 0.10 , "units\\human\\HeroPaladin\\HeroPaladin.mdl")
        call EquipSetHeroModel('hfoo' , 0.08 , "units\\human\\Footman\\Footman.mdl")
        call EquipSetHeroModel('Ulic' , 0.08 , "units\\undead\\HeroLich\\HeroLich.mdl")
        call EquipSetHeroModel('Obla' , 0.08 , "units\\orc\\HeroBladeMaster\\HeroBladeMaster.mdl")
        call EquipSetHeroModel('Edem' , 0.08 , "units\\nightelf\\HeroDemonHunter\\HeroDemonHunter.mdl")
        //
        // end config
        //
    endfunction

































































    // add plugins here
    


//***************************************************************
//* InventoryTable object 3.1
//* ------------
//*
//*   set t=InventoryTable.create() - instanceates a new table object
//*   call t.destroy()     - destroys it
//*   t[1234567]           - Get value for key 1234567
//*                          (zero if not assigned previously)
//*   set t[12341]=32      - Assigning it.
//*   call t.flush(12341)  - Flushes the stored value, so it
//*                          doesn't use any more memory
//*   t.exists(32)         - Was key 32 assigned? Notice
//*                          that flush() unassigns values.
//*   call t.reset()       - Flushes the whole contents of the
//*                          InventoryTable.
//*
//*   call t.destroy()     - Does reset() and also recycles the id.
//*
//*   If you use HandleTable instead of InventoryTable, it is the same
//* but it uses handles as keys, the same with StringTable.
//*
//*  You can use InventoryTable on structs' onInit  if the struct is
//* placed in a library that requires InventoryTable or outside a library.
//*
//*  You can also do 2D array syntax if you want to touch
//* mission keys directly, however, since this is shared space
//* you may want to prefix your mission keys accordingly:
//*
//*  set InventoryTable["thisstring"][ 7 ] = 2
//*  set InventoryTable["thisstring"][ 5 ] = InventoryTable["thisstring"][7]
//*
//***************************************************************

//=============================================================


        function s__InventoryTable___GTable_reset takes integer this returns nothing
            call FlushChildHashtable(InventoryTable___ht, (this))
        endfunction

        function s__InventoryTable___GTable_onDestroy takes integer this returns nothing
            call FlushChildHashtable(InventoryTable___ht, ((this))) // INLINED!!
        endfunction


    //Hey: Don't instanciate other people's textmacros that you are not supposed to, thanks.

//textmacro instance: Table__make("InventoryTable","integer","key" )

        function s__InventoryTable__getindex takes integer this,integer key returns integer
            return LoadInteger(InventoryTable___ht, (this), key)
        endfunction

        function s__InventoryTable__setindex takes integer this,integer key,integer value returns nothing
            call SaveInteger(InventoryTable___ht, (this), key, value)
        endfunction

        function s__InventoryTable_flush takes integer this,integer key returns nothing
            call RemoveSavedInteger(InventoryTable___ht, (this), key)
        endfunction

        function s__InventoryTable_exists takes integer this,integer key returns boolean
            return HaveSavedInteger(InventoryTable___ht, (this), key)
        endfunction

        function s__InventoryTable_flush2D takes string firstkey returns nothing
            call FlushChildHashtable(InventoryTable___ht, (((- StringHash(firstkey))))) // INLINED!!
        endfunction

        function s__InventoryTable__staticgetindex takes string firstkey returns integer
            return (- StringHash(firstkey))
        endfunction

//end of: Table__make("InventoryTable","integer","key" )
//textmacro instance: Table__make("StringTable","string", "StringHash(key)" )

        function s__StringTable__getindex takes integer this,string key returns integer
            return LoadInteger(InventoryTable___ht, (this), StringHash(key))
        endfunction

        function s__StringTable__setindex takes integer this,string key,integer value returns nothing
            call SaveInteger(InventoryTable___ht, (this), StringHash(key), value)
        endfunction

        function s__StringTable_flush takes integer this,string key returns nothing
            call RemoveSavedInteger(InventoryTable___ht, (this), StringHash(key))
        endfunction

        function s__StringTable_exists takes integer this,string key returns boolean
            return HaveSavedInteger(InventoryTable___ht, (this), StringHash(key))
        endfunction

        function s__StringTable_flush2D takes string firstkey returns nothing
            call FlushChildHashtable(InventoryTable___ht, (((- StringHash(firstkey))))) // INLINED!!
        endfunction

        function s__StringTable__staticgetindex takes string firstkey returns integer
            return (- StringHash(firstkey))
        endfunction

//end of: Table__make("StringTable","string", "StringHash(key)" )
//textmacro instance: Table__make("HandleTable","handle","GetHandleId(key)" )

        function s__HandleTable__getindex takes integer this,handle key returns integer
            return LoadInteger(InventoryTable___ht, (this), GetHandleId(key))
        endfunction

        function s__HandleTable__setindex takes integer this,handle key,integer value returns nothing
            call SaveInteger(InventoryTable___ht, (this), GetHandleId(key), value)
        endfunction

        function s__HandleTable_flush takes integer this,handle key returns nothing
            call RemoveSavedInteger(InventoryTable___ht, (this), GetHandleId(key))
        endfunction

        function s__HandleTable_exists takes integer this,handle key returns boolean
            return HaveSavedInteger(InventoryTable___ht, (this), GetHandleId(key))
        endfunction

        function s__HandleTable_flush2D takes string firstkey returns nothing
            call FlushChildHashtable(InventoryTable___ht, (((- StringHash(firstkey))))) // INLINED!!
        endfunction

        function s__HandleTable__staticgetindex takes string firstkey returns integer
            return (- StringHash(firstkey))
        endfunction

//end of: Table__make("HandleTable","handle","GetHandleId(key)" )



    
    

    function IsDestructableTree takes destructable d returns boolean
        //*  851973 is the order id for stunned, it will interrupt the preceding harvest order.
        return ( IssueTargetOrderById(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ORDER_ID, d) ) and ( IssueImmediateOrderById(IsDestructableTree__harvester, 851973) )
    endfunction
    function IsDestructableDead takes destructable d returns boolean
        return ( GetWidgetLife(d) <= 0.405 )
    endfunction
    function IsDestructableAlive takes destructable d returns boolean
        return ( GetWidgetLife(d) > .405 )
    endfunction
    function IsTreeAlive takes destructable tree returns boolean
        return (GetWidgetLife((tree)) > .405) and (( IssueTargetOrderById(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ORDER_ID, (tree)) ) and ( IssueImmediateOrderById(IsDestructableTree__harvester, 851973) )) // INLINED!!
    endfunction
    function KillTree takes destructable tree returns boolean
        if ( IsTreeAlive(tree) ) then
            call KillDestructable(tree)
            return true
        endif
        return false
    endfunction
    function IsDestructableTree__Init takes nothing returns nothing



        set IsDestructableTree__harvester=CreateUnit(IsDestructableTree__NEUTRAL_PLAYER, IsDestructableTree__HARVESTER_UNIT_ID, 0, 0, 0)



        call UnitAddAbility(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ABILITY)
        call UnitAddAbility(IsDestructableTree__harvester, 'Aloc')
        call ShowUnit(IsDestructableTree__harvester, false)
    endfunction
    //*  Seriously?
//Implemented from module IsDestructableTree__Inits:
        function s__IsDestructableTree__I_IsDestructableTree__Inits__onInit takes nothing returns nothing
            call IsDestructableTree__Init()
        endfunction
    





     
       

   




   
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
        function s__User_PlayerUtils__PlayerUtilsInit___onInit takes nothing returns nothing
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

























   
    function RegisterPlayerUnitEvent takes playerunitevent p,code c returns nothing
        local integer i= GetHandleId(p)
        local integer k= 15
        if RegisterPlayerUnitEvent__t[i] == null then
            set RegisterPlayerUnitEvent__t[i]=CreateTrigger()
            loop
                call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent__t[i], Player(k), p, null)
                exitwhen k == 0
                set k=k - 1
            endloop
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent__t[i], Filter(c))
    endfunction
   
    function RegisterPlayerUnitEventForPlayer takes playerunitevent p,code c,player pl returns nothing
        local integer i= 16 * GetHandleId(p) + GetPlayerId(pl)
        if RegisterPlayerUnitEvent__t[i] == null then
            set RegisterPlayerUnitEvent__t[i]=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent__t[i], pl, p, null)
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent__t[i], Filter(c))
    endfunction
   
    function GetPlayerUnitEventTrigger takes playerunitevent p returns trigger
        return RegisterPlayerUnitEvent__t[GetHandleId(p)]
    endfunction

//**************************************************************************************************
//*
//*  SimError
//*
//*     Mimic an interface error message
//*       call SimError(ForPlayer, msg)
//*         ForPlayer : The player to show the error
//*         msg       : The error
//*    
//*     To implement this function, copy this trigger and paste it in your map.
//* Unless of course you are actually reading the library from wc3c's scripts section, then just
//* paste the contents into some custom text trigger in your map.
//*
//**************************************************************************************************

//==================================================================================================
    //====================================================================================================

    function SimError takes player ForPlayer,string msg returns nothing
        set msg="\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffcc00" + msg + "|r"
        if ( GetLocalPlayer() == ForPlayer ) then
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(ForPlayer, 0.52, 0.96, 2.00, msg)
            call StartSound(SimError__error)
        endif
    endfunction

    function SimError__init takes nothing returns nothing
         set SimError__error=CreateSoundFromLabel("InterfaceError", false, false, false, 10, 10)
         //call StartSound( error ) //apparently the bug in which you play a sound for the first time
                                    //and it doesn't work is not there anymore in patch 1.22
    endfunction


   
   
    function s__Table___dex__get_size takes nothing returns integer
        return Table___sizeK
    endfunction
    function s__Table___dex__get_list takes nothing returns integer
        return Table___listK
    endfunction
   
    function s__Table___handles_has takes integer this,integer key returns boolean
        return HaveSavedHandle(Table___ht, this, key)
    endfunction
    function s__Table___handles_remove takes integer this,integer key returns nothing
        call RemoveSavedHandle(Table___ht, this, key)
    endfunction
   
    function s__Table___agents__setindex takes integer this,integer key,agent value returns nothing
        call SaveAgentHandle(Table___ht, this, key, value)
    endfunction
   
   
   
//Run these textmacros to include the entire hashtable API as wrappers.
//Don't be intimidated by the number of macros - Vexorian's map optimizer is
//supposed to kill functions which inline (all of these functions inline).
//textmacro instance: NEW_ARRAY_BASIC("Real", "Real", "real")
    function s__Table___reals__getindex takes integer this,integer key returns real
        return LoadReal(Table___ht, this, key)
    endfunction
    function s__Table___reals__setindex takes integer this,integer key,real value returns nothing
        call SaveReal(Table___ht, this, key, value)
    endfunction
    function s__Table___reals_has takes integer this,integer key returns boolean
        return HaveSavedReal(Table___ht, this, key)
    endfunction
    function s__Table___reals_remove takes integer this,integer key returns nothing
        call RemoveSavedReal(Table___ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("Real", "Real", "real")
//textmacro instance: NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
    function s__Table___booleans__getindex takes integer this,integer key returns boolean
        return LoadBoolean(Table___ht, this, key)
    endfunction
    function s__Table___booleans__setindex takes integer this,integer key,boolean value returns nothing
        call SaveBoolean(Table___ht, this, key, value)
    endfunction
    function s__Table___booleans_has takes integer this,integer key returns boolean
        return HaveSavedBoolean(Table___ht, this, key)
    endfunction
    function s__Table___booleans_remove takes integer this,integer key returns nothing
        call RemoveSavedBoolean(Table___ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
//textmacro instance: NEW_ARRAY_BASIC("String", "Str", "string")
    function s__Table___strings__getindex takes integer this,integer key returns string
        return LoadStr(Table___ht, this, key)
    endfunction
    function s__Table___strings__setindex takes integer this,integer key,string value returns nothing
        call SaveStr(Table___ht, this, key, value)
    endfunction
    function s__Table___strings_has takes integer this,integer key returns boolean
        return HaveSavedString(Table___ht, this, key)
    endfunction
    function s__Table___strings_remove takes integer this,integer key returns nothing
        call RemoveSavedString(Table___ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("String", "Str", "string")
   
//textmacro instance: NEW_ARRAY("Player", "player")
    function s__Table___players__getindex takes integer this,integer key returns player
        return LoadPlayerHandle(Table___ht, this, key)
    endfunction
    function s__Table___players__setindex takes integer this,integer key,player value returns nothing
        call SavePlayerHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Player", "player")
//textmacro instance: NEW_ARRAY("Widget", "widget")
    function s__Table___widgets__getindex takes integer this,integer key returns widget
        return LoadWidgetHandle(Table___ht, this, key)
    endfunction
    function s__Table___widgets__setindex takes integer this,integer key,widget value returns nothing
        call SaveWidgetHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Widget", "widget")
//textmacro instance: NEW_ARRAY("Destructable", "destructable")
    function s__Table___destructables__getindex takes integer this,integer key returns destructable
        return LoadDestructableHandle(Table___ht, this, key)
    endfunction
    function s__Table___destructables__setindex takes integer this,integer key,destructable value returns nothing
        call SaveDestructableHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Destructable", "destructable")
//textmacro instance: NEW_ARRAY("Item", "item")
    function s__Table___items__getindex takes integer this,integer key returns item
        return LoadItemHandle(Table___ht, this, key)
    endfunction
    function s__Table___items__setindex takes integer this,integer key,item value returns nothing
        call SaveItemHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Item", "item")
//textmacro instance: NEW_ARRAY("Unit", "unit")
    function s__Table___units__getindex takes integer this,integer key returns unit
        return LoadUnitHandle(Table___ht, this, key)
    endfunction
    function s__Table___units__setindex takes integer this,integer key,unit value returns nothing
        call SaveUnitHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Unit", "unit")
//textmacro instance: NEW_ARRAY("Ability", "ability")
    function s__Table___abilitys__getindex takes integer this,integer key returns ability
        return LoadAbilityHandle(Table___ht, this, key)
    endfunction
    function s__Table___abilitys__setindex takes integer this,integer key,ability value returns nothing
        call SaveAbilityHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Ability", "ability")
//textmacro instance: NEW_ARRAY("Timer", "timer")
    function s__Table___timers__getindex takes integer this,integer key returns timer
        return LoadTimerHandle(Table___ht, this, key)
    endfunction
    function s__Table___timers__setindex takes integer this,integer key,timer value returns nothing
        call SaveTimerHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Timer", "timer")
//textmacro instance: NEW_ARRAY("Trigger", "trigger")
    function s__Table___triggers__getindex takes integer this,integer key returns trigger
        return LoadTriggerHandle(Table___ht, this, key)
    endfunction
    function s__Table___triggers__setindex takes integer this,integer key,trigger value returns nothing
        call SaveTriggerHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Trigger", "trigger")
//textmacro instance: NEW_ARRAY("TriggerCondition", "triggercondition")
    function s__Table___triggerconditions__getindex takes integer this,integer key returns triggercondition
        return LoadTriggerConditionHandle(Table___ht, this, key)
    endfunction
    function s__Table___triggerconditions__setindex takes integer this,integer key,triggercondition value returns nothing
        call SaveTriggerConditionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerCondition", "triggercondition")
//textmacro instance: NEW_ARRAY("TriggerAction", "triggeraction")
    function s__Table___triggeractions__getindex takes integer this,integer key returns triggeraction
        return LoadTriggerActionHandle(Table___ht, this, key)
    endfunction
    function s__Table___triggeractions__setindex takes integer this,integer key,triggeraction value returns nothing
        call SaveTriggerActionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerAction", "triggeraction")
//textmacro instance: NEW_ARRAY("TriggerEvent", "event")
    function s__Table___events__getindex takes integer this,integer key returns event
        return LoadTriggerEventHandle(Table___ht, this, key)
    endfunction
    function s__Table___events__setindex takes integer this,integer key,event value returns nothing
        call SaveTriggerEventHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerEvent", "event")
//textmacro instance: NEW_ARRAY("Force", "force")
    function s__Table___forces__getindex takes integer this,integer key returns force
        return LoadForceHandle(Table___ht, this, key)
    endfunction
    function s__Table___forces__setindex takes integer this,integer key,force value returns nothing
        call SaveForceHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Force", "force")
//textmacro instance: NEW_ARRAY("Group", "group")
    function s__Table___groups__getindex takes integer this,integer key returns group
        return LoadGroupHandle(Table___ht, this, key)
    endfunction
    function s__Table___groups__setindex takes integer this,integer key,group value returns nothing
        call SaveGroupHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Group", "group")
//textmacro instance: NEW_ARRAY("Location", "location")
    function s__Table___locations__getindex takes integer this,integer key returns location
        return LoadLocationHandle(Table___ht, this, key)
    endfunction
    function s__Table___locations__setindex takes integer this,integer key,location value returns nothing
        call SaveLocationHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Location", "location")
//textmacro instance: NEW_ARRAY("Rect", "rect")
    function s__Table___rects__getindex takes integer this,integer key returns rect
        return LoadRectHandle(Table___ht, this, key)
    endfunction
    function s__Table___rects__setindex takes integer this,integer key,rect value returns nothing
        call SaveRectHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Rect", "rect")
//textmacro instance: NEW_ARRAY("BooleanExpr", "boolexpr")
    function s__Table___boolexprs__getindex takes integer this,integer key returns boolexpr
        return LoadBooleanExprHandle(Table___ht, this, key)
    endfunction
    function s__Table___boolexprs__setindex takes integer this,integer key,boolexpr value returns nothing
        call SaveBooleanExprHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("BooleanExpr", "boolexpr")
//textmacro instance: NEW_ARRAY("Sound", "sound")
    function s__Table___sounds__getindex takes integer this,integer key returns sound
        return LoadSoundHandle(Table___ht, this, key)
    endfunction
    function s__Table___sounds__setindex takes integer this,integer key,sound value returns nothing
        call SaveSoundHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Sound", "sound")
//textmacro instance: NEW_ARRAY("Effect", "effect")
    function s__Table___effects__getindex takes integer this,integer key returns effect
        return LoadEffectHandle(Table___ht, this, key)
    endfunction
    function s__Table___effects__setindex takes integer this,integer key,effect value returns nothing
        call SaveEffectHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Effect", "effect")
//textmacro instance: NEW_ARRAY("UnitPool", "unitpool")
    function s__Table___unitpools__getindex takes integer this,integer key returns unitpool
        return LoadUnitPoolHandle(Table___ht, this, key)
    endfunction
    function s__Table___unitpools__setindex takes integer this,integer key,unitpool value returns nothing
        call SaveUnitPoolHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("UnitPool", "unitpool")
//textmacro instance: NEW_ARRAY("ItemPool", "itempool")
    function s__Table___itempools__getindex takes integer this,integer key returns itempool
        return LoadItemPoolHandle(Table___ht, this, key)
    endfunction
    function s__Table___itempools__setindex takes integer this,integer key,itempool value returns nothing
        call SaveItemPoolHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("ItemPool", "itempool")
//textmacro instance: NEW_ARRAY("Quest", "quest")
    function s__Table___quests__getindex takes integer this,integer key returns quest
        return LoadQuestHandle(Table___ht, this, key)
    endfunction
    function s__Table___quests__setindex takes integer this,integer key,quest value returns nothing
        call SaveQuestHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Quest", "quest")
//textmacro instance: NEW_ARRAY("QuestItem", "questitem")
    function s__Table___questitems__getindex takes integer this,integer key returns questitem
        return LoadQuestItemHandle(Table___ht, this, key)
    endfunction
    function s__Table___questitems__setindex takes integer this,integer key,questitem value returns nothing
        call SaveQuestItemHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("QuestItem", "questitem")
//textmacro instance: NEW_ARRAY("DefeatCondition", "defeatcondition")
    function s__Table___defeatconditions__getindex takes integer this,integer key returns defeatcondition
        return LoadDefeatConditionHandle(Table___ht, this, key)
    endfunction
    function s__Table___defeatconditions__setindex takes integer this,integer key,defeatcondition value returns nothing
        call SaveDefeatConditionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("DefeatCondition", "defeatcondition")
//textmacro instance: NEW_ARRAY("TimerDialog", "timerdialog")
    function s__Table___timerdialogs__getindex takes integer this,integer key returns timerdialog
        return LoadTimerDialogHandle(Table___ht, this, key)
    endfunction
    function s__Table___timerdialogs__setindex takes integer this,integer key,timerdialog value returns nothing
        call SaveTimerDialogHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TimerDialog", "timerdialog")
//textmacro instance: NEW_ARRAY("Leaderboard", "leaderboard")
    function s__Table___leaderboards__getindex takes integer this,integer key returns leaderboard
        return LoadLeaderboardHandle(Table___ht, this, key)
    endfunction
    function s__Table___leaderboards__setindex takes integer this,integer key,leaderboard value returns nothing
        call SaveLeaderboardHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Leaderboard", "leaderboard")
//textmacro instance: NEW_ARRAY("Multiboard", "multiboard")
    function s__Table___multiboards__getindex takes integer this,integer key returns multiboard
        return LoadMultiboardHandle(Table___ht, this, key)
    endfunction
    function s__Table___multiboards__setindex takes integer this,integer key,multiboard value returns nothing
        call SaveMultiboardHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Multiboard", "multiboard")
//textmacro instance: NEW_ARRAY("MultiboardItem", "multiboarditem")
    function s__Table___multiboarditems__getindex takes integer this,integer key returns multiboarditem
        return LoadMultiboardItemHandle(Table___ht, this, key)
    endfunction
    function s__Table___multiboarditems__setindex takes integer this,integer key,multiboarditem value returns nothing
        call SaveMultiboardItemHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("MultiboardItem", "multiboarditem")
//textmacro instance: NEW_ARRAY("Trackable", "trackable")
    function s__Table___trackables__getindex takes integer this,integer key returns trackable
        return LoadTrackableHandle(Table___ht, this, key)
    endfunction
    function s__Table___trackables__setindex takes integer this,integer key,trackable value returns nothing
        call SaveTrackableHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Trackable", "trackable")
//textmacro instance: NEW_ARRAY("Dialog", "dialog")
    function s__Table___dialogs__getindex takes integer this,integer key returns dialog
        return LoadDialogHandle(Table___ht, this, key)
    endfunction
    function s__Table___dialogs__setindex takes integer this,integer key,dialog value returns nothing
        call SaveDialogHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Dialog", "dialog")
//textmacro instance: NEW_ARRAY("Button", "button")
    function s__Table___buttons__getindex takes integer this,integer key returns button
        return LoadButtonHandle(Table___ht, this, key)
    endfunction
    function s__Table___buttons__setindex takes integer this,integer key,button value returns nothing
        call SaveButtonHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Button", "button")
//textmacro instance: NEW_ARRAY("TextTag", "texttag")
    function s__Table___texttags__getindex takes integer this,integer key returns texttag
        return LoadTextTagHandle(Table___ht, this, key)
    endfunction
    function s__Table___texttags__setindex takes integer this,integer key,texttag value returns nothing
        call SaveTextTagHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TextTag", "texttag")
//textmacro instance: NEW_ARRAY("Lightning", "lightning")
    function s__Table___lightnings__getindex takes integer this,integer key returns lightning
        return LoadLightningHandle(Table___ht, this, key)
    endfunction
    function s__Table___lightnings__setindex takes integer this,integer key,lightning value returns nothing
        call SaveLightningHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Lightning", "lightning")
//textmacro instance: NEW_ARRAY("Image", "image")
    function s__Table___images__getindex takes integer this,integer key returns image
        return LoadImageHandle(Table___ht, this, key)
    endfunction
    function s__Table___images__setindex takes integer this,integer key,image value returns nothing
        call SaveImageHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Image", "image")
//textmacro instance: NEW_ARRAY("Ubersplat", "ubersplat")
    function s__Table___ubersplats__getindex takes integer this,integer key returns ubersplat
        return LoadUbersplatHandle(Table___ht, this, key)
    endfunction
    function s__Table___ubersplats__setindex takes integer this,integer key,ubersplat value returns nothing
        call SaveUbersplatHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Ubersplat", "ubersplat")
//textmacro instance: NEW_ARRAY("Region", "region")
    function s__Table___regions__getindex takes integer this,integer key returns region
        return LoadRegionHandle(Table___ht, this, key)
    endfunction
    function s__Table___regions__setindex takes integer this,integer key,region value returns nothing
        call SaveRegionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Region", "region")
//textmacro instance: NEW_ARRAY("FogState", "fogstate")
    function s__Table___fogstates__getindex takes integer this,integer key returns fogstate
        return LoadFogStateHandle(Table___ht, this, key)
    endfunction
    function s__Table___fogstates__setindex takes integer this,integer key,fogstate value returns nothing
        call SaveFogStateHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("FogState", "fogstate")
//textmacro instance: NEW_ARRAY("FogModifier", "fogmodifier")
    function s__Table___fogmodifiers__getindex takes integer this,integer key returns fogmodifier
        return LoadFogModifierHandle(Table___ht, this, key)
    endfunction
    function s__Table___fogmodifiers__setindex takes integer this,integer key,fogmodifier value returns nothing
        call SaveFogModifierHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("FogModifier", "fogmodifier")
//textmacro instance: NEW_ARRAY("Hashtable", "hashtable")
    function s__Table___hashtables__getindex takes integer this,integer key returns hashtable
        return LoadHashtableHandle(Table___ht, this, key)
    endfunction
    function s__Table___hashtables__setindex takes integer this,integer key,hashtable value returns nothing
        call SaveHashtableHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Hashtable", "hashtable")
   
   
    // Implement modules for intuitive syntax (tb.handle; tb.unit; etc.)
//Implemented from module Table___realm:
    function s__Table__get_real takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___booleanm:
    function s__Table__get_boolean takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___stringm:
    function s__Table__get_string takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___playerm:
    function s__Table__get_player takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___widgetm:
    function s__Table__get_widget takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___destructablem:
    function s__Table__get_destructable takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___itemm:
    function s__Table__get_item takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___unitm:
    function s__Table__get_unit takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___abilitym:
    function s__Table__get_ability takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___timerm:
    function s__Table__get_timer takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___triggerm:
    function s__Table__get_trigger takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___triggerconditionm:
    function s__Table__get_triggercondition takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___triggeractionm:
    function s__Table__get_triggeraction takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___eventm:
    function s__Table__get_event takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___forcem:
    function s__Table__get_force takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___groupm:
    function s__Table__get_group takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___locationm:
    function s__Table__get_location takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___rectm:
    function s__Table__get_rect takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___boolexprm:
    function s__Table__get_boolexpr takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___soundm:
    function s__Table__get_sound takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___effectm:
    function s__Table__get_effect takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___unitpoolm:
    function s__Table__get_unitpool takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___itempoolm:
    function s__Table__get_itempool takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___questm:
    function s__Table__get_quest takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___questitemm:
    function s__Table__get_questitem takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___defeatconditionm:
    function s__Table__get_defeatcondition takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___timerdialogm:
    function s__Table__get_timerdialog takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___leaderboardm:
    function s__Table__get_leaderboard takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___multiboardm:
    function s__Table__get_multiboard takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___multiboarditemm:
    function s__Table__get_multiboarditem takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___trackablem:
    function s__Table__get_trackable takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___dialogm:
    function s__Table__get_dialog takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___buttonm:
    function s__Table__get_button takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___texttagm:
    function s__Table__get_texttag takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___lightningm:
    function s__Table__get_lightning takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___imagem:
    function s__Table__get_image takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___ubersplatm:
    function s__Table__get_ubersplat takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___regionm:
    function s__Table__get_region takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___fogstatem:
    function s__Table__get_fogstate takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___fogmodifierm:
    function s__Table__get_fogmodifier takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___hashtablem:
    function s__Table__get_hashtable takes integer this returns integer
        return this
    endfunction
   
    function s__Table__get_handle takes integer this returns integer
        return this
    endfunction
   
    function s__Table__get_agent takes integer this returns integer
        return this
    endfunction
   
    //set this = tb[GetSpellAbilityId()]
    function s__Table__getindex takes integer this,integer key returns integer
        return LoadInteger(Table___ht, this, key)
    endfunction
   
    //set tb[389034] = 8192
    function s__Table__setindex takes integer this,integer key,integer tb returns nothing
        call SaveInteger(Table___ht, this, key, tb)
    endfunction
   
    //set b = tb.has(2493223)
    function s__Table_has takes integer this,integer key returns boolean
        return HaveSavedInteger(Table___ht, this, key)
    endfunction
   
    //call tb.remove(294080)
    function s__Table_remove takes integer this,integer key returns nothing
        call RemoveSavedInteger(Table___ht, this, key)
    endfunction
   
    //Remove all data from a Table instance
    function s__Table_flush takes integer this returns nothing
        call FlushChildHashtable(Table___ht, this)
    endfunction
   
    //local Table tb = Table.create()
    function s__Table_create takes nothing returns integer
        local integer this= (LoadInteger(Table___ht, ((Table___listK)), (0))) // INLINED!!
       
        if this == 0 then
            set this=Table___more + 1
            set Table___more=this
        else
            call SaveInteger(Table___ht, ((Table___listK)), (0), ( (LoadInteger(Table___ht, ((Table___listK)), (this))))) // INLINED!!
            call RemoveSavedInteger(Table___ht, ((Table___listK)), (this)) //Clear hashed memory // INLINED!!
        endif
       
// NO_DEBUG:         debug set Table___dex.list[this] = -1
        return this
    endfunction
   
    // Removes all data from a Table instance and recycles its index.
    //
    //     call tb.destroy()
    //
    function s__Table_destroy takes integer this returns nothing
// NO_DEBUG:         debug if Table___dex.list[this] != -1 then
// NO_DEBUG:             debug call BJDebugMsg("Table Error: Tried to double-free instance: " + I2S(this))
// NO_DEBUG:             debug return
// NO_DEBUG:         debug endif
       
        call FlushChildHashtable(Table___ht, (this)) // INLINED!!
       
        call SaveInteger(Table___ht, ((Table___listK)), (this), ( (LoadInteger(Table___ht, ((Table___listK)), (0))))) // INLINED!!
        call SaveInteger(Table___ht, ((Table___listK)), (0), ( this)) // INLINED!!
    endfunction
   
//ignored textmacro command: TABLE_BC_METHODS()
   
//ignored textmacro command: TABLE_BC_STRUCTS()
   
   
    //Returns a new TableArray to do your bidding. Simply use:
    //
    //    local TableArray ta = TableArray[array_size]
    //
    function s__TableArray__staticgetindex takes integer array_size returns integer
        local integer tb= (LoadInteger(Table___ht, ((Table___sizeK)), (array_size))) // INLINED!!
        local integer this= (LoadInteger(Table___ht, (tb), (0))) // INLINED!!
       
// NO_DEBUG:         debug if array_size <= 0 then
// NO_DEBUG:             debug call BJDebugMsg("TypeError: Invalid specified TableArray size: " + I2S(array_size))
// NO_DEBUG:             debug return 0
// NO_DEBUG:         debug endif
       
        if this == 0 then
            set this=Table___less - array_size
            set Table___less=this
        else
            call SaveInteger(Table___ht, (tb), (0), ( (LoadInteger(Table___ht, (tb), (this))))) //Set the last destroyed to the last-last destroyed // INLINED!!
            call RemoveSavedInteger(Table___ht, (tb), (this)) //Clear hashed memory // INLINED!!
        endif
       
        call SaveInteger(Table___ht, ((Table___sizeK)), (this), ( array_size)) //This remembers the array size // INLINED!!
        return this
    endfunction
   
    //Returns the size of the TableArray
    function s__TableArray__get_size takes integer this returns integer
        return (LoadInteger(Table___ht, ((Table___sizeK)), (this))) // INLINED!!
    endfunction
   
    //This magic method enables two-dimensional[array][syntax] for Tables,
    //similar to the two-dimensional utility provided by hashtables them-
    //selves.
    //
    //ta[integer a].unit[integer b] = unit u
    //ta[integer a][integer c] = integer d
    //
    //Inline-friendly when not running in debug mode
    //
    function s__TableArray__getindex takes integer this,integer key returns integer










        return this + key
    endfunction
   
    //Destroys a TableArray without flushing it; I assume you call .flush()
    //if you want it flushed too. This is a public method so that you don't
    //have to loop through all TableArray indices to flush them if you don't
    //need to (ie. if you were flushing all child-keys as you used them).
    //
    function s__TableArray_destroy takes integer this returns nothing
        local integer tb= (LoadInteger(Table___ht, ((Table___sizeK)), ((LoadInteger(Table___ht, ((Table___sizeK)), ((this))))))) // INLINED!!
       
// NO_DEBUG:         debug if this.size == 0 then
// NO_DEBUG:             debug call BJDebugMsg("TypeError: Tried to destroy an invalid TableArray: " + I2S(this))
// NO_DEBUG:             debug return
// NO_DEBUG:         debug endif
       
        if tb == 0 then
            //Create a Table to index recycled instances with their array size
            set tb=s__Table_create()
            call SaveInteger(Table___ht, ((Table___sizeK)), ((LoadInteger(Table___ht, ((Table___sizeK)), ((this))))), ( tb)) // INLINED!!
        endif
       
        call RemoveSavedInteger(Table___ht, ((Table___sizeK)), (this)) //Clear the array size from hash memory // INLINED!!
       
        call SaveInteger(Table___ht, (tb), (this), ( (LoadInteger(Table___ht, (tb), (0))))) // INLINED!!
        call SaveInteger(Table___ht, (tb), (0), ( this)) // INLINED!!
    endfunction
   
   
    //Avoids hitting the op limit
    function s__TableArray_clean takes nothing returns nothing
        local integer tb= s__TableArray_tempTable
        local integer end= tb + 0x1000
        if end < s__TableArray_tempEnd then
            set s__TableArray_tempTable=end
            call ForForce(bj_FORCE_PLAYER[0], function s__TableArray_clean)
        else
            set end=s__TableArray_tempEnd
        endif
        loop
            call FlushChildHashtable(Table___ht, (tb)) // INLINED!!
            set tb=tb + 1
            exitwhen tb == end
        endloop
    endfunction
   
    //Flushes the TableArray and also destroys it. Doesn't get any more
    //similar to the FlushParentHashtable native than this.
    //
    function s__TableArray_flush takes integer this returns nothing
// NO_DEBUG:         debug if this.size == 0 then
// NO_DEBUG:             debug call BJDebugMsg("TypeError: Tried to flush an invalid TableArray instance: " + I2S(this))
// NO_DEBUG:             debug return
// NO_DEBUG:         debug endif
        set s__TableArray_tempTable=this
        set s__TableArray_tempEnd=this + (LoadInteger(Table___ht, ((Table___sizeK)), ((this)))) // INLINED!!
        call ForForce(bj_FORCE_PLAYER[0], function s__TableArray_clean)
        call s__TableArray_destroy(this)
    endfunction
   
   

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
                call TriggerEvaluate(st___prototype3[(1)]) // INLINED!!
                set TimerUtils__tN=TimerUtils__tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
// NO_DEBUG:                 debug call BJDebugMsg("NewTimer: Warning, Exceeding TimerUtils_QUANTITY, make sure all timers are getting recycled correctly")
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
// NO_DEBUG:             debug call BJDebugMsg("Warning: attempt to release a null timer")
            return
        endif
        if ( TimerUtils__tN == TimerUtils__ARRAY_SIZE ) then
// NO_DEBUG:             debug call BJDebugMsg("Warning: Timer stack is full, destroying timer!!")
// NO_DEBUG: 
            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( (LoadInteger(TimerUtils__ht, 0, GetHandleId((t)))) == TimerUtils__HELD ) then // INLINED!!
// NO_DEBUG:                 debug call BJDebugMsg("Warning: ReleaseTimer: Double free!")
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


	
		
		
		
		
//Implemented from module WorldBounds__WorldBoundInit:
  function s__WorldBounds_WorldBounds__WorldBoundInit___onInit takes nothing returns nothing
			set s__WorldBounds_world=GetWorldBounds()
			
			set s__WorldBounds_maxX=R2I(GetRectMaxX(s__WorldBounds_world))
			set s__WorldBounds_maxY=R2I(GetRectMaxY(s__WorldBounds_world))
			set s__WorldBounds_minX=R2I(GetRectMinX(s__WorldBounds_world))
			set s__WorldBounds_minY=R2I(GetRectMinY(s__WorldBounds_world))
			
			set s__WorldBounds_centerX=R2I(( s__WorldBounds_maxX + s__WorldBounds_minX ) / 2)
			set s__WorldBounds_centerY=R2I(( s__WorldBounds_minY + s__WorldBounds_maxY ) / 2)
			
			set s__WorldBounds_worldRegion=CreateRegion()
			
			call RegionAddRect(s__WorldBounds_worldRegion, s__WorldBounds_world)
  endfunction

//**************************************************************************
//
// xebasic 0.4
// =======
// XE_DUMMY_UNITID : Rawcode of the dummy unit in your map. It should
//                   use the dummy.mdx model, so remember to import it as
//                   well, just use copy&paste to copy the dummy from the
//                   xe map to yours, then change the rawcode.
//
// XE_HEIGHT_ENABLER: Medivh's raven form ability, you may need to change
//                    this rawcode to another spell that morphs into a flier
//                    in case you modified medivh's spell in your map.
//
// XE_TREE_RECOGNITION: The ancients' Eat tree ability, same as with medivh
//                      raven form, you might have to change it.
//
// XE_ANIMATION_PERIOD: The global period of animation used by whatever
//                      timer that depends on it, if you put a low value
//                      the movement will look good but it may hurt your
//                      performance, if instead you use a high value it
//                      will not lag but will be fast.
//
// XE_MAX_COLLISION_SIZE: The maximum unit collision size in your map, if
//                        you got a unit bigger than 197.0 it would be
//                        a good idea to update this constant, since some
//                        enums will not find it. Likewise, if none of
//                        your units can go bellow X and X is much smaller
//                        than 197.0, it would be a good idea to update
//                        as well, since it will improve the performance
//                        those enums.
//
// Notice you probably don't have to update this library, unless I specify
// there are new constants which would be unlikely. 
//
//**************************************************************************

//===========================================================================




    function GetTerrainZ takes real x,real y returns real
        call MoveLocation(Camera_DummyLoc, x, y)
        return GetLocationZ(Camera_DummyLoc)
    endfunction
    
    function GetCameraDeltaZ takes nothing returns real
        return Camera___DeltaZ
    endfunction
    
    function Camera___Matrix4Perspective1 takes integer Output,real fovy,real Aspect,real zn,real zf returns integer
        return s__MATRIX4_SetValues(Output,2 * zn / fovy , 0 , 0 , 0 , 0 , 2 * zn / Aspect , 0 , 0 , 0 , 0 , zf / ( zf - zn ) , 1 , 0 , 0 , zn * zf / ( zn - zf ) , 0)
    endfunction

    function Camera___Matrix4Perspective2 takes integer Output,real n,real f,real r,real l,real t,real b returns integer
        return s__MATRIX4_SetValues(Output,2 * n / ( r - l ) , 0 , ( r + l ) / ( r - l ) , 0 , 0 , 2 * n / ( t - b ) , ( t + b ) / ( t - b ) , 0 , 0 , 0 , - ( f + n ) / ( f - n ) , - 2 * f * n / ( f - n ) , 0 , 0 , - 1 , 0)
    endfunction

    function Camera___Matrix4Look takes integer Output,integer PosCamera,integer AxisX,integer AxisY,integer AxisZ returns integer
        return s__MATRIX4_SetValues(Output,s__VECTOR3_x[AxisX] , s__VECTOR3_x[AxisY] , s__VECTOR3_x[AxisZ] , 0 , s__VECTOR3_y[AxisX] , s__VECTOR3_y[AxisY] , s__VECTOR3_y[AxisZ] , 0 , s__VECTOR3_z[AxisX] , s__VECTOR3_z[AxisY] , s__VECTOR3_z[AxisZ] , 0 , - Vec3Dot(AxisX , PosCamera) , - Vec3Dot(AxisY , PosCamera) , - Vec3Dot(AxisZ , PosCamera) , 1)
    endfunction

        
        function s__Camera_win2World takes integer this,real X,real Y,real Range returns integer
            local integer Output= s__VECTOR3__allocate()
            set s__VECTOR3_x[Output]=GetCameraEyePositionX() + s__VECTOR3_x[s__Camera_axisZ[this]] * Range + X * s__VECTOR3_x[s__Camera_axisX[this]] * SCREEN_WIDTH * Range + Y * s__VECTOR3_x[s__Camera_axisY[this]] * SCREEN_HEIGHT * Range
            set s__VECTOR3_y[Output]=GetCameraEyePositionY() + s__VECTOR3_y[s__Camera_axisZ[this]] * Range + X * s__VECTOR3_y[s__Camera_axisX[this]] * SCREEN_WIDTH * Range + Y * s__VECTOR3_y[s__Camera_axisY[this]] * SCREEN_HEIGHT * Range
            set s__VECTOR3_z[Output]=GetCameraEyePositionZ() + s__VECTOR3_z[s__Camera_axisZ[this]] * Range + X * s__VECTOR3_z[s__Camera_axisX[this]] * SCREEN_WIDTH * Range + Y * s__VECTOR3_z[s__Camera_axisY[this]] * SCREEN_HEIGHT * Range
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
            call Camera___Matrix4Look(s__Camera_view[this] , s__Camera_eye[this] , s__Camera_axisX[this] , s__Camera_axisY[this] , s__Camera_axisZ[this])
            call s__MATRIX3_deallocate(mat)
        endfunction

        function s__Camera_applyCameraForPlayer takes integer this,player p,boolean ignoreChange returns boolean
            if GetLocalPlayer() == p then
                call SetCameraField(CAMERA_FIELD_ROTATION, s__Camera_yaw[this] * bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, s__Camera_pitch[this] * bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_ROLL, s__Camera_roll[this] * bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, s__Camera_distance[this], 0)
                call SetCameraTargetController(Camera_DummyUnit[GetPlayerId(p)], s__VECTOR3_x[s__Camera_at[this]], s__VECTOR3_y[s__Camera_at[this]], false)
                call SetCameraField(CAMERA_FIELD_ZOFFSET, s__VECTOR3_z[s__Camera_at[this]] - Camera___DeltaZ, 0)
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
            set s__Camera_eye[this]=s__VECTOR3_New_1(0.0 , - 922.668 , Camera___DeltaZ + 1367.912)
            set s__Camera_at[this]=s__VECTOR3_New_1(0 , 0 , Camera___DeltaZ)
            set s__Camera_distance[this]=0
            set s__Camera_yaw[this]=0
            set s__Camera_pitch[this]=0
            set s__Camera_roll[this]=0
            set s__Camera_axisX[this]=s__VECTOR3__allocate()
            set s__Camera_axisY[this]=s__VECTOR3__allocate()
            set s__Camera_axisZ[this]=s__VECTOR3__allocate()
            set s__Camera_view[this]=s__MATRIX4__allocate()
            set s__Camera_projection[this]=Camera___Matrix4Perspective2(s__MATRIX4__allocate() , 0.5 , 10000 , - SCREEN_WIDTH / 2 , SCREEN_WIDTH / 2 , - SCREEN_HEIGHT / 2 , SCREEN_HEIGHT / 2)
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
            call s__Camera_deallocate(this)
        endfunction
        

    
//Implemented from module Camera___CamInitModule:
        function s__Camera___CamInit_Camera___CamInitModule__onInit takes nothing returns nothing
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
            set Camera___DeltaZ=GetCameraTargetPositionZ() - 6
        endfunction
    

    
    
        
        
//Implemented from module InvItemPlugins:
        //
        // Tooltip building 
        //
        
        function s__InvItem_InvItemTooltip___getStringLine takes string str,integer line returns string
            local integer i= 0
            local integer l= StringLength(str)
            local string o= ""
            local integer c= 0
            loop
                exitwhen i > l
                if ( SubString(str, i, i + 1) == "\n" ) then
                    set c=c + 1
                        
                    if ( c == line ) then
                        return o
                    else
                        set o=""
                    endif
                endif

                set o=o + SubString(str, i, i + 1)
                set i=i + 1
            endloop
            return ""
        endfunction
        
        function s__InvItem_lTrim takes integer this,string s returns string
            local integer i= 0
            loop
                exitwhen SubString(s, i, i + 1) != " "
                set s=SubString(s, 1, 9999)
                set i=i + 1
            endloop
            return s
        endfunction
        
        function s__InvItem_buildDescriptionLines takes integer this,integer pid,integer startLine returns integer
            local integer i= 0
            local integer l= StringLength(s__InvItem_info[this])
            local integer c= 0
            local integer j= 0
            local integer safeSpot= 0
            local string line= ""
            local string safe= ""
            local string char
        
            if ( StringLength(s__InvItem_lTrim(this,s__InvItem_info[this])) <= 0 ) then
                return startLine - 1
            endif
            
            loop
                exitwhen i > l
                
                set char=SubString(s__InvItem_info[this], i, i + 1)

                if ( char == "\n" or c >= s__Inventory_TOOLTIP_LINE_LENGTH ) then
                    if ( char != " " and char != "\n" ) then
                        set line=safe
                        
                        set i=safeSpot
                    endif
                    
                    call sc__Inventory_setTooltipLine(pid , startLine + j , s__InvItem_lTrim(this,line))
    
                    set line=""
                    
                    if ( char != "\n" ) then
                        set i=i - 1
                    endif
                    
                    set char=""
                    
                    set c=0
                    set j=j + 1
                endif
                
                if ( char == " " ) then
                    set safe=line
                    set safeSpot=i
                endif
                
                set line=line + char
                
                set c=c + 1
                set i=i + 1
            endloop
            
            if ( j == 0 ) then
                call sc__Inventory_setTooltipLine(pid , startLine , s__InvItem_lTrim(this,line))
            elseif ( line != "" ) then
                call sc__Inventory_setTooltipLine(pid , startLine + j , s__InvItem_lTrim(this,line))
            endif
            
            return ( startLine + j ) + 1
        endfunction
        //
        // configuration
        //
        
        
        //
        // end config
        //
        
         
        

            
            
            
            function s__InvItem_addBonusRange takes integer this,integer bonusType,integer base,integer min,integer max returns nothing
                call SaveInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( this * s__InvItem_MAX_BONUSES ) + s__InvItem_bonuses[this], bonusType)
                call SaveInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_AMOUNT, ( this * s__InvItem_MAX_BONUSES ) + s__InvItem_bonuses[this], base)
                call SaveInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MIN, ( this * s__InvItem_MAX_BONUSES ) + s__InvItem_bonuses[this], min)
                call SaveInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MAX, ( this * s__InvItem_MAX_BONUSES ) + s__InvItem_bonuses[this], max)
                set s__InvItem_bonuses[this]=s__InvItem_bonuses[this] + 1
            endfunction
            
            function s__InvItem_addBonus takes integer this,integer bonusType,integer amount returns nothing
                call SaveInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( this * s__InvItem_MAX_BONUSES ) + s__InvItem_bonuses[this], bonusType)
                call SaveInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_AMOUNT, ( this * s__InvItem_MAX_BONUSES ) + s__InvItem_bonuses[this], amount)
                set s__InvItem_bonuses[this]=s__InvItem_bonuses[this] + 1
            endfunction
            
            function s__InvItem_getBonus takes integer this,integer index returns integer
                return LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( this * s__InvItem_MAX_BONUSES ) + index)
            endfunction
            
            function s__InvItem_getBonusAmount takes integer this,integer index returns integer
                return LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_AMOUNT, ( this * s__InvItem_MAX_BONUSES ) + index)
            endfunction
            
            function s__InvItem_getBonusMin takes integer this,integer index returns integer
                return LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MIN, ( this * s__InvItem_MAX_BONUSES ) + index)
            endfunction
            
            function s__InvItem_getBonusMax takes integer this,integer index returns integer
                return LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MAX, ( this * s__InvItem_MAX_BONUSES ) + index)
            endfunction
            
            function s__InvItem_Bonus2S takes integer b returns string
                return EquipmentItem_BonusString[b]
            endfunction
            
            function s__InvItem_getBonusTotal takes integer this,integer index returns integer
                local integer total= (LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_AMOUNT, ( (this) * s__InvItem_MAX_BONUSES ) + (index))) // INLINED!!
                set bj_cineModeSavedSeed=GetRandomInt(0, 1000000)
                call SetRandomSeed(sc__InvCustomItem_seed((s__InvItem_tempCustomId[this])))
                set total=total + ( GetRandomInt((LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MIN, ( (this) * s__InvItem_MAX_BONUSES ) + (index))), (LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MAX, ( (this) * s__InvItem_MAX_BONUSES ) + (index)))) ) // INLINED!!
                call SetRandomSeed(bj_cineModeSavedSeed)
                return total
            endfunction
            
            function s__InvItem_addBonusesMultiplier takes integer this,unit u,integer m returns nothing
                local integer i= 0
                local integer n= 0
                local integer total
                local integer itm
                
                loop
                    exitwhen i >= s__InvItem_bonuses[this]
                    
                    call sc__BonusModStruct_addBonus(u , (LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( (this) * s__InvItem_MAX_BONUSES ) + (i))) , s__InvItem_getBonusTotal(this,i) * m) // INLINED!!
                    
                    set i=i + 1
                endloop

                set i=0
                
                loop
                    exitwhen i >= (LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(this)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)) // INLINED!!
                    
                    set itm=sc__InvItem_getSocket(this,i)
                    set s__InvItem_tempCustomId[itm]=sc__InvItem_socketId(this,i)
                    
                    set n=0
                    
                    loop
                        exitwhen n == s__InvItem_bonuses[itm]
                        
                        call sc__BonusModStruct_addBonus(u , (LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( (itm) * s__InvItem_MAX_BONUSES ) + (n))) , s__InvItem_getBonusTotal(itm,n) * m) // INLINED!!
                        
                        set n=n + 1
                    endloop
                    
                    set i=i + 1
                endloop
            endfunction
            
            function s__InvItem_applyBonuses takes integer this,unit u returns nothing
                call s__InvItem_addBonusesMultiplier(this,u , 1)
            endfunction
            
            function s__InvItem_removeBonuses takes integer this,unit u returns nothing
                call s__InvItem_addBonusesMultiplier(this,u , - 1)
            endfunction

        
        function s__InvItem_GearSlotName takes integer slot returns string
            if ( slot == 1 ) then
                return "Head"
            elseif ( slot == 2 ) then
                return "Shoulder"
            elseif ( slot == 8 ) then
                return "Earring"
            elseif ( slot == 3 ) then
                return "Chest"
            elseif ( slot == 4 ) then
                return "Belt"
            elseif ( slot == 5 ) then
                return "Pants"
            elseif ( slot == 6 or slot == 12 ) then
                return "Ring"
            elseif ( slot == 7 ) then
                return "Amulet"
            elseif ( slot == 9 ) then
                return "Gloves"
            elseif ( slot == 10 ) then
                return "Bracers"
            elseif ( slot == 11 ) then
                return "Boots"
            elseif ( slot == 13 ) then
                return "Weapon"
            elseif ( slot == 14 ) then
                return "Offhand"
            endif
            
            return ""
        endfunction

        function s__InvItem_buildDescription takes integer this,unit forUnit returns string
            local integer i= 0
            local integer n= 0
            local string out= ""
            local string bonusName
            local integer lines= 0
            local integer pid= GetPlayerId(GetOwningPlayer(forUnit))
            local integer total
            local integer itm
            
            call TriggerExecute(st___prototype3[(2)]) // INLINED!!
            
            call sc__Inventory_clearLines(pid)
            
            // slot type
            set out=s__InvItem_GearSlotName(s__InvItem_slot[this])
            
            if ( out != "" ) then
                set out="|cffffcc00Slot:|r " + out

                call sc__Inventory_setTooltipSlot(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+s__Inventory_TOOLTIP_LINES_MAX],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
            endif
            
            // item description
            set lines=s__InvItem_buildDescriptionLines(this,pid , 0)
            
            if ( lines != 0 ) then
                set lines=lines + 1
            endif
            
            // item ability
            if ( s__InvItem_ability[this] > 0 ) then
                set out="|cfffedaac" + GetObjectName(s__InvItem_ability[this]) + "|r (Does not stack)\n"
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // equip ability
            if ( s__InvItem_equipAbility[this] > 0 ) then
                set out="|cfffedaac" + GetObjectName(s__InvItem_equipAbility[this]) + "|r\n"
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // equip bonuses

                loop
                    exitwhen i >= s__InvItem_bonuses[this]
                    
                    set bonusName=(EquipmentItem_BonusString[((LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( (this) * s__InvItem_MAX_BONUSES ) + (i))))]) // INLINED!!
  
                    if ( bonusName != null and bonusName != "" ) then
                        
                        set total=s__InvItem_getBonusTotal(this,i)
                        
                        if ( total > 0 ) then
                            set out="|cfffedaac+" + I2S(total) + " to " + bonusName + "|r"
                            
                            call sc__Inventory_setTooltipLine(pid , lines , out)
                            call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                            set lines=lines + 1
                        endif

                    endif
                    
                    set i=i + 1
                endloop

            
            set s__Inventory_RightSideStart[pid]=lines
            
            // level requirement
            if ( s__InvItem_reqLevel[this] > 0 ) then
                if ( GetHeroLevel(forUnit) < s__InvItem_reqLevel[this] and GetUnitLevel(forUnit) < s__InvItem_reqLevel[this] ) then
                    set out="|cffffcc00Level Req:|r |cffff0000" + I2S(s__InvItem_reqLevel[this]) + "|r"
                else
                    set out="|cffffcc00Level Req:|r " + I2S(s__InvItem_reqLevel[this])
                endif
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // unit type requirement
            if ( s__InvItem_reqUnitType[this] > 0 ) then
                if ( GetUnitTypeId(forUnit) != s__InvItem_reqUnitType[this] ) then
                    set out="|cffffcc00Usable:|r |cffff0000" + GetObjectName(s__InvItem_reqUnitType[this]) + "|r"
                else
                    set out="|cffffcc00Usable:|r |cff2eb82e" + GetObjectName(s__InvItem_reqUnitType[this]) + "|r"
                endif
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // ability requirement
            if ( s__InvItem_reqAbility[this] > 0 ) then
                if ( GetUnitAbilityLevel(forUnit, s__InvItem_reqAbility[this]) < 0 ) then
                    set out="|cffff0000Requires:|r |cffff0000" + GetObjectName(s__InvItem_reqAbility[this]) + "|r"
                else
                    set out="|cffffcc00Requires:|r " + GetObjectName(s__InvItem_reqAbility[this])
                endif
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // custom
            if ( s__InvItem_equipCondition[this] != null and s__InvItem_equipConditionStr[this] != null and s__InvItem_equipConditionStr[this] != "" ) then
                call TriggerClearConditions(s__InvItem_equipEval)
                call TriggerAddCondition(s__InvItem_equipEval, s__InvItem_equipCondition[this])
                set s__InvItem_eventUnit=forUnit
                if ( not TriggerEvaluate(s__InvItem_equipEval) ) then
                    set out="|cffffcc00" + s__InvItem_equipConditionStrPrefix[this] + ":|r " + s__InvItem_equipConditionStr[this]
                else
                    set out="|cffffcc00" + s__InvItem_equipConditionStrPrefix[this] + ":|r " + s__InvItem_equipConditionStr[this]
                endif
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // sockets
            set i=0
            
            if ( s__InvItem_maxSockets[this] > 0 ) then
                if ( s__Inventory_RightSideStart[pid] != lines ) then
                    call sc__Inventory_setTooltipLine(pid , lines , "")
                    call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                    set lines=lines + 1
                endif
                call sc__Inventory_setTooltipLine(pid , lines , "Sockets: " + I2S((LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(this)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100))) + "/" + I2S(s__InvItem_maxSockets[this])) // INLINED!!
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                set lines=lines + 1
            endif
            
            loop
                exitwhen i >= s__InvItem_maxSockets[this]
                
                set itm=sc__InvItem_getSocket(this,i)
                
                if ( itm > 0 ) then
                
                    set s__InvItem_tempCustomId[itm]=sc__InvItem_socketId(this,i)
                    
                    set n=0
                    
                    loop
                        exitwhen n >= s__InvItem_bonuses[itm]
                    
                        set bonusName=(EquipmentItem_BonusString[((LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( (itm) * s__InvItem_MAX_BONUSES ) + (n))))]) // INLINED!!
   
                        if ( bonusName != null and bonusName != "" ) then
                            
                            set total=s__InvItem_getBonusTotal(itm,n)
                            
                            if ( total > 0 ) then
                                set out="|cff5566bb+" + I2S(total) + " to " + bonusName + "|r\n"
                                
                                call sc__Inventory_setTooltipLine(pid , lines , out)
                                call sc__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+lines],true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                                
                                set lines=lines + 1
                            endif
                        endif
                        
                        set n=n + 1
                    endloop
                endif
                
                set i=i + 1
            endloop

            return out
        endfunction
        
        
        
        function s__InvItem__get_sockets takes integer this returns integer
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)
        endfunction
        
        function s__InvItem__set_sockets takes integer this,integer val returns nothing
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100, val)
        endfunction
        
        function s__InvItem_socketId takes integer this,integer index returns integer
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket___KEY_SOCKETS_ID * 100 ) + index)
        endfunction
        
        
        function s__InvItem_addSocket takes integer this,integer socket returns boolean
            if s__InvItem_isSocket[this] then
                return false
            endif
            
            if ( (LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(this)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)) >= s__InvItem_maxSockets[this] ) then // INLINED!!
                return false
            endif
            
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket___KEY_SOCKETS * 100 ) + (LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(this)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)), socket) // INLINED!!
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket___KEY_SOCKETS_ID * 100 ) + (LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(this)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)), s__InvItem_tempCustomId[socket]) // INLINED!!
            
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(this)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100, ((LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(this)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)) + 1)) // INLINED!!
            
            return true
        endfunction
        
        function s__InvItem_getSocket takes integer this,integer index returns integer
            if s__InvItem_isSocket[this] then
                return 0
            endif
            
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket___KEY_SOCKETS * 100 ) + index)
        endfunction
        
        





        





        
        function s__InvItem_onInit takes nothing returns nothing
            set s__InvItem_InventoryTable=s__InventoryTable__allocate()
        endfunction
    
    function GetInvItem takes integer id returns integer
        return ((LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), (id)))) // INLINED!!
    endfunction
    
    function GetItemInfo takes integer id returns string
        return s__InvItem_info[((LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), (id))))] // INLINED!!
    endfunction
    
    function GetItemDescription takes integer id returns string
        return s__InvItem_info[((LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), (id))))] // INLINED!!
    endfunction
    
    function GetItemIcon takes integer id returns integer
        local integer icon= s__InvItem_icon[((LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), (id))))] // INLINED!!
        if ( icon == 0 ) then
            return s__Inventory_ICON_EMPTY
        endif
        return icon
    endfunction
    
    function CreateInvItem takes integer id,integer icon,integer cost,integer abil,string info returns integer
        local integer itm= s__InvItem__allocate()
        set s__InvItem_id[itm]=id
        set s__InvItem_icon[itm]=icon
        set s__InvItem_cost[itm]=cost
        set s__InvItem_info[itm]=info
        set s__InvItem_ability[itm]=abil
        call SaveInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), (s__InvItem_id[itm]), ( itm)) // INLINED!!
        return itm
    endfunction
    
        
        function s__InvCustomItem_create takes nothing returns integer
            local integer this= s__InvCustomItem_Counter
            call SaveInteger(InventoryTable___ht, ((s__InvCustomItem_SeedTable)), (this), ( GetRandomInt(InventoryItem_SEED_START, InventoryItem_SEED_END))) // INLINED!!
            set s__InvCustomItem_Counter=s__InvCustomItem_Counter + 1
            return this
        endfunction
        
        function s__InvCustomItem_seed takes integer this returns integer
            return (LoadInteger(InventoryTable___ht, ((s__InvCustomItem_SeedTable)), (this))) // INLINED!!
        endfunction
        
        function s__InvCustomItem_onInit takes nothing returns nothing
            set s__InvCustomItem_SeedTable=s__InventoryTable__allocate()
        endfunction



    // Public read-only snapshot. Death/timeout observations have <=1s latency.

    // 1 reserve; 2 borrowed; 3 waiting for fx; 4 timed-life disposal.

    function s__MissileStats_value takes integer row,string text returns nothing
        local multiboarditem mbi
        if s__MissileStats_cell[row] != text then
            set s__MissileStats_cell[row]=text
            set mbi=MultiboardGetItem(s__MissileStats_board, row, 1)
            call MultiboardSetItemValue(mbi, text)
            call MultiboardReleaseItem(mbi)
            set mbi=null
        endif
    endfunction

    function s__MissileStats_label takes integer row,string text returns nothing
        local multiboarditem mbi= MultiboardGetItem(s__MissileStats_board, row, 0)
        call MultiboardSetItemValue(mbi, text)
        call MultiboardSetItemWidth(mbi, 0.17)
        call MultiboardReleaseItem(mbi)
        set mbi=MultiboardGetItem(s__MissileStats_board, row, 1)
        call MultiboardSetItemWidth(mbi, 0.12)
        call MultiboardReleaseItem(mbi)
        set mbi=null
    endfunction

    function s__MissileStats_warning takes integer n returns string
        if n > 0 then
            return "|cffff5555" + I2S(n) + "|r"
        endif
        return I2S(n)
    endfunction

    function s__MissileStats_draw takes nothing returns nothing
        local string nextTitle
        set s__MissileStats_queued=false
        if s__MissileStats_board == null then
            set s__MissileStats_board=CreateMultiboard()
            call MultiboardSetRowCount(s__MissileStats_board, 19)
            call MultiboardSetColumnCount(s__MissileStats_board, 2)
            call MultiboardSetItemsStyle(s__MissileStats_board, true, false)
            call s__MissileStats_label(0 , "Instancias / pico")
            call s__MissileStats_label(1 , "Creadas / retiradas")
            call s__MissileStats_label(2 , "Instancia mas antigua")
            call s__MissileStats_label(3 , "Dummies vivos / pico")
            call s__MissileStats_label(4 , "Dummies prestados")
            call s__MissileStats_label(5 , "Reserva / capacidad")
            call s__MissileStats_label(6 , "Esperando efectos")
            call s__MissileStats_label(7 , "Descarte pendiente")
            call s__MissileStats_label(8 , "Esperas vencidas")
            call s__MissileStats_label(9 , "Precreados / nuevos")
            call s__MissileStats_label(10 , "Reutilizaciones")
            call s__MissileStats_label(11 , "Descartes expirados")
            call s__MissileStats_label(12 , "Perdidas inesperadas")
            call s__MissileStats_label(13 , "Reciclajes invalidos")
            call s__MissileStats_label(14 , "Externos / omitidos")
            call s__MissileStats_label(15 , "Inconsistencias / errores")
            call s__MissileStats_label(16 , "Alarmas historicas")
            call s__MissileStats_label(17 , "Revisiones de vida")
            call s__MissileStats_label(18 , "Ver / ocultar")
            call MultiboardDisplay(s__MissileStats_board, true)
            call MultiboardMinimize(s__MissileStats_board, false)
        endif
        if s__MissileStats_overdue > 0 or s__MissileStats_lost > 0 or s__MissileStats_invalid > 0 or s__MissileStats_omitted > 0 or s__MissileStats_errors > 0 or s__MissileStats_inconsistent > 0 then
            set nextTitle="|cffff5555Misiles: ALERTA|r"
        elseif s__MissileStats_alarms > 0 then
            set nextTitle="|cffffcc44Misiles: revisar historial|r"
        elseif s__MissileStats_oldestSeconds >= s__MissileStats_OLD_AGE then
            set nextTitle="|cffffcc44Misiles: revisar edad|r"
        elseif s__MissileStats_active > 0 or s__MissileStats_deferred > 0 or s__MissileStats_pending > 0 then
            set nextTitle="|cff66ccffMisiles: actividad|r"
        else
            set nextTitle="|cff66ff88Misiles: OK|r"
        endif
        if nextTitle != s__MissileStats_title then
            set s__MissileStats_title=nextTitle
            call MultiboardSetTitleText(s__MissileStats_board, s__MissileStats_title)
        endif
        call s__MissileStats_value(0 , I2S(s__MissileStats_active) + " / " + I2S(s__MissileStats_peakActive))
        call s__MissileStats_value(1 , I2S(s__MissileStats_created) + " / " + I2S(s__MissileStats_retired))
        call s__MissileStats_value(2 , I2S(s__MissileStats_oldestSeconds) + " s (aviso 30)")
        call s__MissileStats_value(3 , I2S(s__MissileStats_tracked) + " / " + I2S(s__MissileStats_peakTracked))
        call s__MissileStats_value(4 , I2S(s__MissileStats_borrowed))
        call s__MissileStats_value(5 , I2S(s__MissileStats_pooled) + " / " + I2S(s__MissileStats_capacity))
        call s__MissileStats_value(6 , I2S(s__MissileStats_deferred))
        call s__MissileStats_value(7 , I2S(s__MissileStats_pending))
        call s__MissileStats_value(8 , s__MissileStats_warning(s__MissileStats_overdue))
        call s__MissileStats_value(9 , I2S(s__MissileStats_preloadTotal) + " / " + I2S(s__MissileStats_newTotal))
        call s__MissileStats_value(10 , I2S(s__MissileStats_reusedTotal))
        call s__MissileStats_value(11 , I2S(s__MissileStats_disposed))
        call s__MissileStats_value(12 , s__MissileStats_warning(s__MissileStats_lost))
        call s__MissileStats_value(13 , s__MissileStats_warning(s__MissileStats_invalid))
        call s__MissileStats_value(14 , I2S(s__MissileStats_adoptedTotal) + " / " + s__MissileStats_warning(s__MissileStats_omitted))
        call s__MissileStats_value(15 , s__MissileStats_warning(s__MissileStats_inconsistent) + " / " + s__MissileStats_warning(s__MissileStats_errors))
        call s__MissileStats_value(16 , I2S(s__MissileStats_alarms))
        call s__MissileStats_value(17 , I2S(s__MissileStats_checks) + " (cada 1 s)")
        call s__MissileStats_value(18 , "-misiles")
        set s__MissileStats_renders=s__MissileStats_renders + 1
    endfunction

    function s__MissileStats_touch takes nothing returns nothing
        if s__MissileStats_initialized and not s__MissileStats_queued then
            set s__MissileStats_queued=true
            // Coalesce all hooks in this execution; no drawing in physics loops.
            call TimerStart(s__MissileStats_painter, 0., false, function s__MissileStats_draw)
        endif
    endfunction

    function s__MissileStats_error takes nothing returns nothing
        set s__MissileStats_errors=s__MissileStats_errors + 1
        set s__MissileStats_alarms=s__MissileStats_alarms + 1
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_changeState takes integer slot,integer nextState returns nothing
        if s__MissileStats_state[slot] == 1 then
            set s__MissileStats_pooled=s__MissileStats_pooled - 1
        elseif s__MissileStats_state[slot] == 2 then
            set s__MissileStats_borrowed=s__MissileStats_borrowed - 1
        elseif s__MissileStats_state[slot] == 3 then
            set s__MissileStats_deferred=s__MissileStats_deferred - 1
        elseif s__MissileStats_state[slot] == 4 then
            set s__MissileStats_pending=s__MissileStats_pending - 1
        endif
        set s__MissileStats_state[slot]=nextState
        set s__MissileStats_warned[slot]=false
        if nextState == 1 then
            set s__MissileStats_pooled=s__MissileStats_pooled + 1
        elseif nextState == 2 then
            set s__MissileStats_borrowed=s__MissileStats_borrowed + 1
        elseif nextState == 3 then
            set s__MissileStats_deferred=s__MissileStats_deferred + 1
        elseif nextState == 4 then
            set s__MissileStats_pending=s__MissileStats_pending + 1
        endif
    endfunction

    function s__MissileStats_track takes unit u returns integer
        local integer slot
        if u == null then
            call s__MissileStats_error()
            return 0
        endif
        set slot=(LoadInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
        if slot != 0 then
            return slot
        endif
        if s__MissileStats_tracked == s__MissileStats_LIMIT then
            set s__MissileStats_omitted=s__MissileStats_omitted + 1
            set s__MissileStats_alarms=s__MissileStats_alarms + 1
            call s__MissileStats_touch()
            return 0
        endif
        set s__MissileStats_tracked=s__MissileStats_tracked + 1
        set slot=s__MissileStats_tracked
        set s__MissileStats_units[slot]=u
        set s__MissileStats_state[slot]=0
        set s__MissileStats_deadline[slot]=0.
        set s__MissileStats_warned[slot]=false
        call SaveInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)), ( slot)) // INLINED!!
        if s__MissileStats_tracked > s__MissileStats_peakTracked then
            set s__MissileStats_peakTracked=s__MissileStats_tracked
        endif
        return slot
    endfunction

    // Called exactly once by the recycler initializer, then once per preload.
    function s__MissileStats_configure takes integer slots returns nothing
        set s__MissileStats_capacity=slots
        call s__MissileStats_touch()
    endfunction
    function s__MissileStats_preload takes unit u returns nothing
        local integer slot= s__MissileStats_track(u)
        set s__MissileStats_preloadTotal=s__MissileStats_preloadTotal + 1
        if slot != 0 then
            call s__MissileStats_changeState(slot , 1)
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_acquire takes unit u,boolean reused returns nothing
        local integer slot= s__MissileStats_track(u)
        if reused then
            set s__MissileStats_reusedTotal=s__MissileStats_reusedTotal + 1
        else
            set s__MissileStats_newTotal=s__MissileStats_newTotal + 1
        endif
        if slot != 0 then
            call s__MissileStats_changeState(slot , 2)
            set s__MissileStats_deadline[slot]=0.
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_returned takes unit u,boolean stored,real duration returns nothing
        local integer slot= (LoadInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
        if slot == 0 then
            set s__MissileStats_adoptedTotal=s__MissileStats_adoptedTotal + 1
            set slot=s__MissileStats_track(u)
        endif
        if slot != 0 then
            if stored then
                call s__MissileStats_changeState(slot , 1)
            else
                call s__MissileStats_changeState(slot , 4)
            endif
            set s__MissileStats_deadline[slot]=TimerGetElapsed(s__MissileStats_clock) + duration
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_delay takes unit u,real duration returns nothing
        local integer slot= (LoadInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
        if slot != 0 then
            call s__MissileStats_changeState(slot , 3)
            set s__MissileStats_deadline[slot]=TimerGetElapsed(s__MissileStats_clock) + duration
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_invalidReturn takes nothing returns nothing
        set s__MissileStats_invalid=s__MissileStats_invalid + 1
        set s__MissileStats_alarms=s__MissileStats_alarms + 1
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_allocated takes integer node returns nothing
        // Classic arrays also support the core's last valid node ID, 8191.
        // LIMIT applies only to the separate unit-handle tracking table.
        if node < 1 or node > 8191 then
            set s__MissileStats_omitted=s__MissileStats_omitted + 1
            call s__MissileStats_error()
            return
        endif
        if s__MissileStats_nodeSlot[node] != 0 then
            call s__MissileStats_error()
            return
        endif
        set s__MissileStats_active=s__MissileStats_active + 1
        set s__MissileStats_created=s__MissileStats_created + 1
        set s__MissileStats_nodes[s__MissileStats_active]=node
        set s__MissileStats_nodeSlot[node]=s__MissileStats_active
        set s__MissileStats_born[node]=TimerGetElapsed(s__MissileStats_clock)
        if s__MissileStats_active > s__MissileStats_peakActive then
            set s__MissileStats_peakActive=s__MissileStats_active
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_released takes integer node returns nothing
        local integer slot= s__MissileStats_nodeSlot[node]
        if slot == 0 then
            call s__MissileStats_error()
            return
        endif
        set s__MissileStats_nodes[slot]=s__MissileStats_nodes[s__MissileStats_active]
        set s__MissileStats_nodeSlot[s__MissileStats_nodes[slot]]=slot
        set s__MissileStats_nodeSlot[node]=0
        set s__MissileStats_nodes[s__MissileStats_active]=0
        set s__MissileStats_active=s__MissileStats_active - 1
        set s__MissileStats_retired=s__MissileStats_retired + 1
        call s__MissileStats_touch()
    endfunction

    // Public for fixtures; the live observer also calls it once per second.
    function s__MissileStats_inspect takes nothing returns nothing
        local integer i= 1
        local integer age
        local integer bad= 0
        local real now= TimerGetElapsed(s__MissileStats_clock)
        set s__MissileStats_oldestSeconds=0
        set s__MissileStats_overdue=0
        set s__MissileStats_inconsistent=0
        loop
            exitwhen i > s__MissileStats_active
            set age=R2I(now - s__MissileStats_born[s__MissileStats_nodes[i]])
            if age > s__MissileStats_oldestSeconds then
                set s__MissileStats_oldestSeconds=age
            endif
            set i=i + 1
        endloop
        set i=1
        loop
            exitwhen i > s__MissileStats_tracked
            if GetUnitTypeId(s__MissileStats_units[i]) == 0 or GetWidgetLife(s__MissileStats_units[i]) <= 0.405 then
                if s__MissileStats_state[i] == 4 then
                    set s__MissileStats_disposed=s__MissileStats_disposed + 1
                else
                    set s__MissileStats_lost=s__MissileStats_lost + 1
                    set s__MissileStats_alarms=s__MissileStats_alarms + 1
                endif
                call RemoveSavedInteger(Table___ht, (s__MissileStats_index), (GetHandleId(s__MissileStats_units[i]))) // INLINED!!
                call s__MissileStats_changeState(i , 0)
                if i != s__MissileStats_tracked then
                    set s__MissileStats_units[i]=s__MissileStats_units[s__MissileStats_tracked]
                    set s__MissileStats_state[i]=s__MissileStats_state[s__MissileStats_tracked]
                    set s__MissileStats_deadline[i]=s__MissileStats_deadline[s__MissileStats_tracked]
                    set s__MissileStats_warned[i]=s__MissileStats_warned[s__MissileStats_tracked]
                    call SaveInteger(Table___ht, (s__MissileStats_index), (GetHandleId(s__MissileStats_units[i])), ( i)) // INLINED!!
                endif
                set s__MissileStats_units[s__MissileStats_tracked]=null
                set s__MissileStats_state[s__MissileStats_tracked]=0
                set s__MissileStats_deadline[s__MissileStats_tracked]=0.
                set s__MissileStats_warned[s__MissileStats_tracked]=false
                set s__MissileStats_tracked=s__MissileStats_tracked - 1
            else
                set bad=0
                if ( s__MissileStats_state[i] == 3 or s__MissileStats_state[i] == 4 ) and now > s__MissileStats_deadline[i] + s__MissileStats_GRACE then
                    set s__MissileStats_overdue=s__MissileStats_overdue + 1
                    set bad=1
                endif
                if s__MissileStats_state[i] == 1 and GetUnitUserData(s__MissileStats_units[i]) != - 1 then
                    set s__MissileStats_inconsistent=s__MissileStats_inconsistent + 1
                    set bad=1
                endif
                if bad == 1 and not s__MissileStats_warned[i] then
                    set s__MissileStats_warned[i]=true
                    set s__MissileStats_alarms=s__MissileStats_alarms + 1
                endif
                set i=i + 1
            endif
        endloop
        if s__MissileStats_active != s__MissileStats_created - s__MissileStats_retired or s__MissileStats_tracked != s__MissileStats_pooled + s__MissileStats_borrowed + s__MissileStats_deferred + s__MissileStats_pending then
            set s__MissileStats_inconsistent=s__MissileStats_inconsistent + 1
        endif
        set s__MissileStats_checks=s__MissileStats_checks + 1
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_watch takes nothing returns nothing
        call s__MissileStats_inspect()
    endfunction

    function s__MissileStats_toggle takes nothing returns nothing
        local integer id= GetPlayerId(GetTriggerPlayer())
        set s__MissileStats_hidden[id]=not s__MissileStats_hidden[id]
        if GetLocalPlayer() == GetTriggerPlayer() then
            // Visual only: no handle creation, game-state writes or RNG here.
            call MultiboardDisplay(s__MissileStats_board, not s__MissileStats_hidden[id])
        endif
    endfunction

    function s__MissileStats_initialize takes nothing returns nothing
        local trigger command= CreateTrigger()
        local integer i= 0
        set s__MissileStats_index=s__Table_create()
        call TimerStart(s__MissileStats_clock, 1000000., false, null)
        call TimerStart(s__MissileStats_watcher, 1., true, function s__MissileStats_watch)
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(command, Player(i), "-misiles", true)
            set i=i + 1
        endloop
        call TriggerAddAction(command, function s__MissileStats_toggle)
        set command=null
        set s__MissileStats_initialized=true
        call s__MissileStats_touch()
    endfunction

function MissileDiagnostics__Init takes nothing returns nothing
    call s__MissileStats_initialize()
endfunction

 
//============================================================================
 
//============================================================================
//Implemented from module SpellEffectEvent___M:
   




   
    function s__SpellEffectEvent___S_onCast takes nothing returns nothing

            call TriggerEvaluate((LoadTriggerHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (GetSpellAbilityId())))) // INLINED!!



    endfunction
 
    function s__SpellEffectEvent___S_SpellEffectEvent___M___onInit takes nothing returns nothing

            set s__SpellEffectEvent___S_tb=s__Table_create()

        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT , function s__SpellEffectEvent___S_onCast)
    endfunction
 
//============================================================================
function RegisterSpellEffectEvent takes integer abil,code onCast returns nothing

        if not (HaveSavedHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (abil))) then // INLINED!!
            call SaveTriggerHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (abil), ( CreateTrigger())) // INLINED!!
        endif
        call TriggerAddCondition((LoadTriggerHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (abil))), Filter(onCast)) // INLINED!!






endfunction
 


    /// external ObjectMerger w3a Adef uDex anam "Detect Leave" ansf "(UnitDex)" aart "" acat "" arac 0 
  

    
    
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
        return TriggerAddCondition(UnitDex___IndexTrig[eventtype], func)
    endfunction
    
    function RemoveUnitIndexEvent takes triggercondition c,integer eventtype returns nothing
        call TriggerRemoveCondition(UnitDex___IndexTrig[eventtype], c)
    endfunction
    
    function TriggerRegisterUnitIndexEvent takes trigger t,integer eventtype returns nothing
        call TriggerRegisterVariableEvent(t, "UnitDex___E", EQUAL, eventtype)
    endfunction
    
    function OnUnitIndex takes code func returns triggercondition
        return TriggerAddCondition(UnitDex___IndexTrig[EVENT_UNIT_INDEX], Filter(func))
    endfunction

    function OnUnitDeindex takes code func returns triggercondition
        return TriggerAddCondition(UnitDex___IndexTrig[EVENT_UNIT_DEINDEX], Filter(func))
    endfunction
    
    function UnitDexRemove takes unit u,boolean runEvents returns boolean
        return sc__UnitDex_Remove(u , runEvents)
    endfunction
    
    
    
    
        
        
//Implemented from module UnitDex___UnitDexConfig:
    
        // The raw code of the leave detection ability.
        
        // Allow debug messages (debug mode must also be on)
        
        // Uncomment the lines below to define a filter for units being indexed
        
        function s__UnitDex_onFilter takes unit u returns boolean
            return GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst'
        endfunction
        
        
        
//Implemented from module UnitDex___UnitDexCore:
    
        function s__UnitDex_Remove takes unit u,boolean runEvents returns boolean
            local integer i
            
            if ( ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) ) then // INLINED!!
                set i=(GetUnitUserData((u))) // INLINED!!
                set s__UnitDex_List[i]=UnitDex___Index
                set UnitDex___Index=i
                
                call GroupRemoveUnit(s__UnitDex_Group, u)
                call SetUnitUserData(u, 0)
            
                if ( runEvents ) then
                    set s__UnitDex_LastIndex=i
                    set UnitDex___E=EVENT_UNIT_DEINDEX
                    call TriggerEvaluate(UnitDex___IndexTrig[EVENT_UNIT_DEINDEX])
                    set UnitDex___E=- 1
                endif
                
                set s__UnitDex_Unit[i]=null
                set s__UnitDex_Count=s__UnitDex_Count - 1
                
                return true
            endif
            
            return false
        endfunction
        
        function s__UnitDex_UnitDex___UnitDexCore___onGameStart takes nothing returns nothing
            local integer i= 0

                local group ENUM_GROUP= CreateGroup()

            
            // Index preplaced units
            loop
                call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(i), UnitDex___FilterEnter)
                
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
                
                call TriggerEvaluate(UnitDex___IndexTrig[EVENT_UNIT_INDEX])
                set UnitDex___E=EVENT_UNIT_INDEX
                set UnitDex___E=- 1
                
                set i=i + 1
            endloop

            set s__UnitDex_LastIndex=s__UnitDex_Counter
            set s__UnitDex_Initialized=true
            set UnitDex___FilterEnter=null
            
            call DestroyTimer(GetExpiredTimer())
        endfunction
        
        function s__UnitDex_UnitDex___UnitDexCore___onEnter takes nothing returns boolean
            local unit u= GetFilterUnit()
            local integer i= (GetUnitUserData((u))) // INLINED!!
            local integer t= UnitDex___Index
            
            if ( i == 0 and s__UnitDex_Enabled ) then
                
                // If a filter was defined pass the unit through it.

                    if ( not s__UnitDex_onFilter(u) ) then
                        set u=null
                        return false // check failed
                    endif

                
                // Handle debugging







                
                // Add to group of indexed units
                call GroupAddUnit(s__UnitDex_Group, u)
                
                // Give unit the leave detection ability
                call UnitAddAbility(u, s__UnitDex_DETECT_LEAVE_ABILITY)
                call UnitMakeAbilityPermanent(u, true, s__UnitDex_DETECT_LEAVE_ABILITY)
                
                // Allocate index
                if ( UnitDex___Index != 0 ) then
                    set UnitDex___Index=s__UnitDex_List[t]
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
                    call TriggerEvaluate(UnitDex___IndexTrig[EVENT_UNIT_INDEX])
                    
                    // Handle TriggerRegisterUnitIndexEvent
                    set UnitDex___E=EVENT_UNIT_INDEX

                    // Reset so the event can occur again
                    set UnitDex___E=- 1
                endif
            endif
            
            set u=null
            
            return false
        endfunction

        function s__UnitDex_UnitDex___UnitDexCore___onLeave takes nothing returns boolean
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
                    set s__UnitDex_List[i]=UnitDex___Index
                    set UnitDex___Index=i
                    set s__UnitDex_LastIndex=i
                    
                    // Remove to group of indexed units
                    call GroupRemoveUnit(s__UnitDex_Group, u)
                
                    // Execute custom events without any associated triggers
                    call TriggerEvaluate(UnitDex___IndexTrig[EVENT_UNIT_DEINDEX])
                    
                    // Handle TriggerRegisterUnitIndexEvent
                    set UnitDex___E=EVENT_UNIT_DEINDEX
                    
                    // Remove entry
                    call SetUnitUserData(u, 0)
                    set s__UnitDex_Unit[i]=null
                    
                    // Decrement unit count
                    set s__UnitDex_Count=s__UnitDex_Count - 1
               
                    // Reset so the event can occur again
                    set UnitDex___E=- 1
                endif
                
                set u=null
            endif
            
            return false
        endfunction
        
        function s__UnitDex_UnitDex___UnitDexCore___onInit takes nothing returns nothing
            local trigger t= CreateTrigger()
            local integer i= 0
            local player p
            local unit u
            




            
            set UnitDex___FilterEnter=Filter(function s__UnitDex_UnitDex___UnitDexCore___onEnter)
            
            // Begin to index units when they enter the map

                call TriggerRegisterEnterRegion(CreateTrigger(), s__WorldBounds_worldRegion, UnitDex___FilterEnter)






            
            call TriggerAddCondition(t, Filter(function s__UnitDex_UnitDex___UnitDexCore___onLeave))
            
            set UnitDex___IndexTrig[EVENT_UNIT_INDEX]=CreateTrigger()
            set UnitDex___IndexTrig[EVENT_UNIT_DEINDEX]=CreateTrigger()
            
            loop
                set p=Player(i)
                
                // Detect "undefend"
                call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                
                // Hide the detect ability from players
                call SetPlayerAbilityAvailable(p, s__UnitDex_DETECT_LEAVE_ABILITY, false)
                
                set i=i + 1
                exitwhen i == bj_MAX_PLAYER_SLOTS
            endloop
            
            call TimerStart(CreateTimer(), 0, false, function s__UnitDex_UnitDex___UnitDexCore___onGameStart)
        endfunction
    
    
    
     
    

//************************************************************************
// xepreload 0.7 // modified by triggerhappy, module initialiazer
// ---------
// Ah, the joy of preloading abilities, it is such a necessary evil...
// Notice you are not supposed to use this system in places outside map init
//
// This one does the preloading and tries to minimize the hit on loading time
// for example, it only needs one single native call per ability preloaded.
//
//************************************************************************

//===========================================================================================================

    //inline friendly (when debug mode is off..)
    function XE_PreloadAbility takes integer abilid returns nothing
        call UnitAddAbility(xepreload__dum, abilid)







    endfunction
    // ................................................................................

    //================================================================================
    // Convert a integer id value into a 4-letter id code.
    // * Taken from cheats.j so I don't have to code it again.
    // * Used only on debug so making a whole library for it seemed silly
    // * Private so people don't begin using xepreload just to call this function....
    // * It will not work correctly if you paste this code in the custom script section
    //   due to the infamous % bug. Then again, if you do that then you probably 
    // deserve it....
    //
    function xepreload__DebugIdInteger2IdString takes integer value returns string
     local string charMap= ".................................!.#$%&'()*+,-./0123456789:;<=>.@ABCDEFGHIJKLMNOPQRSTUVWXYZ[.]^_`abcdefghijklmnopqrstuvwxyz{|}~................................................................................................................................."
     local string result= ""
     local integer remainingValue= value
     local integer charValue
     local integer byteno

     set byteno=0
     loop
         set charValue=ModuloInteger(remainingValue, 256)
         set remainingValue=remainingValue / 256
         set result=SubString(charMap, charValue, charValue + 1) + result
 
         set byteno=byteno + 1
         exitwhen byteno == 4
     endloop
     return result
    endfunction

    //--------------------------------
    function xepreload__kill takes nothing returns nothing
        call RemoveUnit(xepreload__dum)
        set xepreload__dum=null

            call ReleaseTimer(GetExpiredTimer())



    endfunction


//Implemented from module xepreload__PreloadInit:
        function s__xepreload__Init_xepreload__PreloadInit__onInit takes nothing returns nothing
            local timer t
            set xepreload__dum=CreateUnit(Player(15), XE_DUMMY_UNITID, 0, 0, 0)
            if ( xepreload__dum == null ) then
// NO_DEBUG:                 debug call BJDebugMsg("xePreload : XE_DUMMY_UNITID ("+xepreload__DebugIdInteger2IdString.evaluate(XE_DUMMY_UNITID)+") not added correctly to the map.")
            endif

                set t=(NewTimerEx(0)) // INLINED!!



            call TimerStart(t, 0.0, false, function xepreload__kill)
            set t=null
        endfunction
    


//processed:     function interface IndexFunc takes unit u returns nothing
    
    
    
        function s__AutoIndex_getIndex takes unit u returns integer
            return (GetUnitUserData((u))) // INLINED!!
        endfunction
        
        function s__AutoIndex_isUnitIndexed takes unit u returns boolean
            return u != null and s__UnitDex_Unit[(GetUnitUserData((u)))] == u // INLINED!!
        endfunction
    
        function s__AutoIndex_getIndexDebug takes unit u returns integer
            if u == null then
                return 0
            elseif GetUnitTypeId(u) == 0 then
                   call BJDebugMsg("AutoIndex error: Removed or decayed unit passed to GetUnitId.")
            elseif s__UnitDex_Unit[(GetUnitUserData((u)))] != u and GetIssuedOrderId() != 852056 then // INLINED!!
                call BJDebugMsg("AutoIndex error: " + GetUnitName(u) + " is a filtered unit.")
            endif
            
            return (GetUnitUserData(((u)))) // INLINED!!
        endfunction
        
        function s__AutoIndex_onUnitIndexed_sub takes nothing returns nothing
            call sc___prototype43_evaluate(s__AutoIndex_indexfunc,GetEnumUnit())
        endfunction
        
        function s__AutoIndex_onUnitIndexed takes integer func returns nothing
            set s__AutoIndex_indexfuncs_n=s__AutoIndex_indexfuncs_n + 1
            set s__AutoIndex_indexfuncs[s__AutoIndex_indexfuncs_n]=func
            if s__UnitDex_Initialized then //During initialization, evaluate the indexfunc for every preplaced unit.
                set s__AutoIndex_indexfunc=func
                call ForGroup(s__UnitDex_Group, function s__AutoIndex_onUnitIndexed_sub)
            endif
        endfunction
        
        function s__AutoIndex_onUnitDeindexed takes integer func returns nothing
            set s__AutoIndex_deindexfuncs_n=s__AutoIndex_deindexfuncs_n + 1
            set s__AutoIndex_deindexfuncs[s__AutoIndex_deindexfuncs_n]=func
        endfunction
    
    function OnUnitIndexed takes integer func returns nothing
        call s__AutoIndex_onUnitIndexed(func)
    endfunction

    function OnUnitDeindexed takes integer func returns nothing
        call s__AutoIndex_onUnitDeindexed(func)
    endfunction



// modified by triggerhappy, module initializer

////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ BonusMod - v3.3.1
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@    Based on the work of:
//@        weaaddar
//@-----------------------------------------------------------------------------
//@ If you use this system, please at least credit weaaddar. Without him, this
//@ system would not exist. I would be happy if you credited me as well.
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library is written in vJass and thus requires JASS Helper in order to
//@ function correctly. This library also uses the ObjectMerger created by
//@ PitzerMike. The ObjectMerger must be configured as an external tool for
//@ JASS Helper.
//@ 
//@ All of these things are present in the NewGen world editor.
//@ 
//@=============================================================================
//@ Introduction:
//@-----------------------------------------------------------------------------
//@ BonusMod is a system for applying reversible bonuses to certain stats, such
//@ as attack speed or mana regen, for specific units. Most of the bonuses
//@ provided by BonusMod show green or red numbers in the command card, exactly
//@ like the bonuses provided by items.
//@
//@ BonusMod has two kinds of bonuses:
//@   1. Ability based bonuses
//@   2. Code based bonuses
//@ 
//@ All of the bonuses in the configuration section for the basic BonusMod
//@ library are ability-based bonuses. Code-based bonuses are provided by
//@ additional libraries.
//@ 
//@ Ability based bonuses have a limit to how much of a bonus they can apply.
//@ The actual limit depends on the number of abilities that type of bonus uses.
//@ See the "Default bonuses" section of this readme for the default limits
//@ of the bonuses that come with BonusMod. For changing the limits of the
//@ default bonuses, or for adding new types of bonuses, see the below
//@ configuration section.
//@ 
//@ Code based bonuses may or may not have a limit to how much of a bonus they
//@ can apply. The limits for code based bonuses depend entirely on how the
//@ bonus is implemented. See their documentation for more information.
//@
//@=============================================================================
//@ Adding BonusMod to your map:
//@-----------------------------------------------------------------------------
//@ First, you must place the BonusMod library in a custom-text trigger in your
//@ map.
//@
//@ You must then save your map with ability generation enabled. After you save
//@ your map with ability generation enabled, you must close your map in the
//@ editor, and reopen it. You can then disable ability generation.
//@ See the configuration section for information on how to enable and disable
//@ ability generation.
//@
//@=============================================================================
//@ Default bonuses:
//@-----------------------------------------------------------------------------
//@ 
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@      | Bonus Type constants:       | Minimum bonus: | Maximum bonus: |
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@      | BONUS_SIGHT_RANGE           |   -2048        |   +2047        |
//@      | BONUS_ATTACK_SPEED          |   -512         |   +511         |
//@      | BONUS_ARMOR                 |   -1024        |   +1023        |
//@      | BONUS_MANA_REGEN_PERCENT    |   -512%        |   +511%        |
//@      | BONUS_LIFE_REGEN            |   -256         |   +255         |
//@      | BONUS_DAMAGE                |   -1024        |   +1023        |
//@      | BONUS_STRENGTH              |   -256         |   +255         |
//@      | BONUS_AGILITY               |   -256         |   +255         |
//@      | BONUS_INTELLIGENCE          |   -256         |   +255         |
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@
//@      Notes:
//@         - The bonuses for stength, agility, and intelligence can only be
//@           applied to heroes. Attempting to add them to normal units will
//@           fail to work completely.
//@         - Using a negative BONUS_STRENGTH bonus can give a unit negative
//@           maximum life. Don't do that. It really messes stuff up.
//@         - Using a negative BONUS_INTELLIGENCE bonus can remove a hero's
//@           mana. This is not a big issue, as mana will return when the
//@           bonus is removed.
//@         - The maximum effective sight range for a unit is 1800.
//@         - There is a maximum attack speed. I have no idea what it is.
//@ 
//@ See the configuration section for information on how to change the range of
//@ bonuses, as well as how to add new ability-based bonuses, and remove unused
//@ ones.
//@ 
//@=============================================================================
//@ Public API / Function list:
//@-----------------------------------------------------------------------------
//@ Note that BonusMod will only output error messages if JASS Helper is set to
//@ compile in debug mode.
//@
//@ Bonus constants such as BONUS_DAMAGE have .min and .max properties which
//@ are the minimum and maximum bonus that type of bonus can apply. Note that
//@ for code based bonuses, these constants may not reflect the minimum or
//@ maximum bonus for a specific unit. Use the IsBonusValid() function to check
//@ if the given bonus value is okay for a given unit.
//@
//@ function SetUnitBonus
//@ takes unit u, Bonus bonusType, integer amount
//@ returns integer
//@ 
//@     This function sets the bonus of the type bonusType for the given unit to
//@     the given amount. The returned integer is the unit's actual current
//@     bonus, after it has been changed. If the given amount is above the
//@     maximum possible bonus for this type, then the maximum possible bonus
//@     is applied to the unit. The same is true if the given value is below
//@     the minimum possible bonus.
//@
//@ function GetUnitBonus
//@ takes unit u, Bonus bonusType
//@ returns integer
//@
//@     Returns the given unit's current bonus of bonusType. A value of 0 means
//@     that the given unit does not have a bonus of the given type.
//@ 
//@ function AddUnitBonus
//@ takes unit u, Bonus bonusType, integer amount
//@ returns integer
//@ 
//@     Increases the unit's bonus by the given amount. You can use a negitive
//@     amount to subtract from the unit's current bonus. Note that the same
//@     rules SetUnitBonus has apply for going over/under the maximum bonus.
//@     The returned value is the unit's actual new bonus.
//@ 
//@ function RemoveUnitBonus
//@ takes unit u, Bonus bonusType
//@ returns nothing
//@ 
//@     Sets the bonus of the type bonusType to 0 for the given unit. This
//@     function is faster then using SetUnitBonus(u, bonusType, 0).
//@
//@ function IsBonusValid
//@ takes unit u, Bonus abstractBonus, integer value
//@ returns boolean
//@
//@     Returns true if the given value is a valid bonus value for the given
//@     unit. This will also return false if the given bonus type is a hero-
//@     only bonus type, and the given unit is not a hero.
//@ 
//@=============================================================================
//@ Writing code-based bonuses:
//@-----------------------------------------------------------------------------
//@ This section of the readme tells you how to create your own bonus types
//@ that apply their bonuses using vJass code instead of abilities. You do not
//@ need to read or understand this to use BonusMod as-is.
//@
//@ Creating a new bonus type is simple. Extend the Bonus struct, implement the
//@ methods provided within it, and create a single instance of your struct
//@ within a variable named BONUS_YOUR_BONUS_TYPES_NAME of the type Bonus.
//@ 
//@ The methods you must implement are:
//@
//@ method setBonus takes unit u, integer amount returns integer
//@     This method sets the given unit's current bonus to amount, returning
//@     the actual bonus that was applied. If the given amount is higher then
//@     the maximum amount your bonus type can apply to a unit, you must apply
//@     the maximum possible bonus, and return that amount. The same holds true
//@     for the minimum bonus.
//@
//@ method getBonus takes unit u returns integer
//@     This method returns the current bonus the given unit has.
//@
//@ method removeBonus takes unit u returns nothing
//@     This method sets the current bonus of the given unit to 0.
//@
//@ method isValueInRange takes integer value returns boolean
//@     This method returns true if the given integer is a valid bonus amount
//@     for this bonus type, and false otherwise.
//@
//@ Note that it is your responsibility to do any clean up in the event a unit
//@ dies or is removed with an active bonus on it. There is no guarantee that
//@ removeBonus() will be called before a unit dies or is removed.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// If the following constant is set to true, the abilities used by this library
// will be preloaded at map initialization. This will slightly increase loading
// time, but will prevent a slight to medium lag spike the first time a bonus
// of a type is applied.
// 
// Note that your map must contain either the xepreload library, or the
// AbilityPreload library for preloading to work.
// 
// It is highly recommended that you do not set this to false.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// The BonusMod_BeginBonuses macro takes a single boolean type parameter.
// If set to true, bonus abilities will be created (or recreated) on save.
// If set to false, abilities will not be generated.
// 
// If you modify any of the bonus declaration macros, or add new ones, you must
// regenerate abilities.
// 
// Note that if you remove a bonus, the abilities it had created will not be
// automatically removed. This is also true of reducing the number of abilities
// a bonus uses.
// 
// After you generate abilities, you must close your map and reopen it in the
// editor. You can then disable ability generation until the next time you
// modify the bonus types.
//------------------------------------------------------------------------------
//textmacro instance: BonusMod_BeginBonuses("false")
    function BonusMod___Setup takes nothing returns nothing
        set BonusMod_Init=true
    // The following is a lua script for the ObjectMerger, used to generate abilities
    //*
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
    // */
//end of: BonusMod_BeginBonuses("false")
    //--------------------------------------------------------------------------
    // Below are where bonus types are defined.
    // 
    // The first parameter is the name of the bonus type. A constant will be
    // generated for each bonus type, that will take the form: BONUS_NAME
    // 
    // The second parameter is the maximum power of 2 the bonus type can add
    // to a unit. For example, 8 abilities gives a range of -256 to +255.
    // 
    // The third parameter is the base ability. The base ability must give the
    // desired effect when the given field is changed.
    // 
    // The fourth parameter is the rawcode prefix of the bonuses generated
    // abilities. The prefix must be 3 characters long. Your map must not
    // already contain bonuses which start with the given prefix.
    // 
    // The fifth parameter is the object field to modify for each generated
    // ability.
    // 
    // The sixth parameter must be true of the bonus should only work on hero
    // units, and false otherwise.
    // 
    // The final parameter is the icon that will be displayed in the object
    // editor. This has no effect on anything ingame.
    //--------------------------------------------------------------------------
    
    //                                    |     NAME     |ABILITY|SOURCE |PREFIX|FIELD  | HERO   |  ICON
    //                                    |              | COUNT |ABILITY|      |       |  ONLY  |
//textmacro instance: BonusMod_DeclareBonus("ARMOR",        "10",  "AId1", "(A)", "Idef", "false", "BTNHumanArmorUpOne.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_ARMOR=sc__BonusMod___AbilityBonus_create('(A)a' , 10 , '(A)-' , false)
//end of: BonusMod_DeclareBonus("ARMOR",        "10",  "AId1", "(A)", "Idef", "false", "BTNHumanArmorUpOne.blp")
//textmacro instance: BonusMod_DeclareBonus("DAMAGE",       "10",  "AItg", "(B)", "Iatt", "false", "BTNSteelMelee.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_DAMAGE=sc__BonusMod___AbilityBonus_create('(B)a' , 10 , '(B)-' , false)
//end of: BonusMod_DeclareBonus("DAMAGE",       "10",  "AItg", "(B)", "Iatt", "false", "BTNSteelMelee.blp")
//textmacro instance: BonusMod_DeclareBonus("SIGHT_RANGE",  "11",  "AIsi", "(C)", "Isib", "false", "BTNTelescope.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_SIGHT_RANGE=sc__BonusMod___AbilityBonus_create('(C)a' , 11 , '(C)-' , false)
//end of: BonusMod_DeclareBonus("SIGHT_RANGE",  "11",  "AIsi", "(C)", "Isib", "false", "BTNTelescope.blp")
//textmacro instance: BonusMod_DeclareBonus("LIFE_REGEN",   "8",   "Arel", "(E)", "Ihpr", "false", "BTNRingSkull.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_LIFE_REGEN=sc__BonusMod___AbilityBonus_create('(E)a' , 8 , '(E)-' , false)
//end of: BonusMod_DeclareBonus("LIFE_REGEN",   "8",   "Arel", "(E)", "Ihpr", "false", "BTNRingSkull.blp")
//textmacro instance: BonusMod_DeclareBonus("STRENGTH",     "8",   "AIa1", "(F)", "Istr", "true" , "BTNGoldRing.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_STRENGTH=sc__BonusMod___AbilityBonus_create('(F)a' , 8 , '(F)-' , true)
//end of: BonusMod_DeclareBonus("STRENGTH",     "8",   "AIa1", "(F)", "Istr", "true" , "BTNGoldRing.blp")
//textmacro instance: BonusMod_DeclareBonus("AGILITY",      "8",   "AIa1", "(G)", "Iagi", "true" , "BTNGoldRing.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_AGILITY=sc__BonusMod___AbilityBonus_create('(G)a' , 8 , '(G)-' , true)
//end of: BonusMod_DeclareBonus("AGILITY",      "8",   "AIa1", "(G)", "Iagi", "true" , "BTNGoldRing.blp")
//textmacro instance: BonusMod_DeclareBonus("INTELLIGENCE", "8",   "AIa1", "(H)", "Iint", "true" , "BTNGoldRing.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_INTELLIGENCE=sc__BonusMod___AbilityBonus_create('(H)a' , 8 , '(H)-' , true)
//end of: BonusMod_DeclareBonus("INTELLIGENCE", "8",   "AIa1", "(H)", "Iint", "true" , "BTNGoldRing.blp")
    
    //                                           |     NAME          |ABILITY|SOURCE |PREFIX|FIELD  |HERO   |  ICON
    //                                           |                   | COUNT |ABILITY|      |       | ONLY  |
//textmacro instance: BonusMod_DeclarePercentBonus("ATTACK_SPEED",       "9", "AIsx",  "(I)", "Isx1", "false", "BTNGlove.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_ATTACK_SPEED=sc__BonusMod___AbilityBonus_create('(I)a' , 9 , '(I)-' , false)
//end of: BonusMod_DeclarePercentBonus("ATTACK_SPEED",       "9", "AIsx",  "(I)", "Isx1", "false", "BTNGlove.blp")
//textmacro instance: BonusMod_DeclarePercentBonus("MANA_REGEN_PERCENT", "9", "AIrm",  "(D)", "Imrp", "false", "BTNSobiMask.blp")
// Object generation omitted; bundled Classic objects imported.
    set BONUS_MANA_REGEN_PERCENT=sc__BonusMod___AbilityBonus_create('(D)a' , 9 , '(D)-' , false)
//end of: BonusMod_DeclarePercentBonus("MANA_REGEN_PERCENT", "9", "AIrm",  "(D)", "Imrp", "false", "BTNSobiMask.blp")
    
//textmacro instance: BonusMod_EndBonuses()
    //*
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
    // */
    
    endfunction
//end of: BonusMod_EndBonuses()

//==============================================================================
// End of configuration
//==============================================================================





// ===
//  Precomputed integer powers of 2
// ===


// ===
//  Utility functions
// ===

function BonusMod___ErrorMsg takes string func,string s returns nothing
    call BJDebugMsg("|cffFF0000BonusMod Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

function BonusMod___LoadAbility takes integer abilityId returns nothing


            call UnitAddAbility(xepreload__dum, (abilityId)) // INLINED!!






endfunction

// ===
//  Bonus Types
// ===



    
    function s__Bonus_create takes nothing returns integer
        local integer this= s__Bonus__allocate()
        
        set s__Bonus_BonusMod___isBonusObject[this]=true
        
        return this
    endfunction
    
    function s__Bonus_setBonus takes integer this,unit u,integer amount returns integer
// NO_DEBUG:         debug call BonusMod___ErrorMsg("Bonus.setBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endfunction
    
    function s__Bonus_getBonus takes integer this,unit u returns integer
// NO_DEBUG:         debug call BonusMod___ErrorMsg("Bonus.getBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endfunction
    
    function s__Bonus_removeBonus takes integer this,unit u returns nothing
        call sc__Bonus_setBonus(this,u , 0)
    endfunction
    
    function s__Bonus_isValidBonus takes integer this,unit u,integer value returns boolean
        return true
    endfunction
    
    function s__Bonus__get_min takes integer this returns integer
        return s__BonusMod___BonusInterface_minBonus[this]
    endfunction
    
    function s__Bonus__get_max takes integer this returns integer
        return s__BonusMod___BonusInterface_maxBonus[this]
    endfunction

    
    
    
    
    function s__BonusMod___AbilityBonus_create takes integer rawcode,integer count,integer negativeRawcode,boolean heroesOnly returns integer
        local integer bonus= s__BonusMod___AbilityBonus__allocate()
        local integer i
// NO_DEBUG:         debug local boolean error = false
        
        // Error messages













        
        // Grow powers of 2
        if BonusMod___powersOf2Count < count then
            set i=BonusMod___powersOf2Count
            loop
                exitwhen i > count
                
                set BonusMod___powersOf2[i]=2 * BonusMod___powersOf2[i - 1]

                set i=i + 1
            endloop
            set BonusMod___powersOf2Count=count
        endif
        
        // Preload this bonus' abilities

            set i=0
            loop
                exitwhen i == count
                
                call UnitAddAbility(xepreload__dum, ((rawcode + i))) // INLINED!!
                
                set i=i + 1
            endloop
            
            if negativeRawcode != 0 then
                call UnitAddAbility(xepreload__dum, ((negativeRawcode))) // INLINED!!
            endif

        
        // Set up this bonus object
        set s__BonusMod___AbilityBonus_count[bonus]=count
        set s__BonusMod___AbilityBonus_negativeRawcode[bonus]=negativeRawcode
        set s__BonusMod___AbilityBonus_rawcode[bonus]=rawcode
        set s__BonusMod___AbilityBonus_heroesOnly[bonus]=heroesOnly
        
        // Calculate the minimum and maximum bonuses
        if negativeRawcode != 0 then
            set s__BonusMod___BonusInterface_minBonus[bonus]=- BonusMod___powersOf2[count]
        else
            set s__BonusMod___BonusInterface_minBonus[bonus]=0
        endif
        set s__BonusMod___BonusInterface_maxBonus[bonus]=BonusMod___powersOf2[count] - 1
        
        // Return the bonus object
        return bonus
    endfunction
    
    // Interface methods:
    
    function s__BonusMod___AbilityBonus_setBonus takes integer this,unit u,integer amount returns integer
        return sc___prototype47_evaluate(1,u , this , amount)
    endfunction
    
    function s__BonusMod___AbilityBonus_getBonus takes integer this,unit u returns integer
        return sc___prototype48_evaluate(1,u , this)
    endfunction
    
    function s__BonusMod___AbilityBonus_removeBonus takes integer this,unit u returns nothing
        call sc___prototype46_evaluate(1,u , this)
    endfunction
    
    function s__BonusMod___AbilityBonus_isValidBonus takes integer this,unit u,integer value returns boolean
        return ( value >= s__BonusMod___BonusInterface_minBonus[this] ) and ( value <= s__BonusMod___BonusInterface_maxBonus[this] )
    endfunction

// ===
//  Public API
// ===

function IsBonusValid takes unit u,integer abstractBonus,integer value returns boolean
    local integer bonus= (abstractBonus)
    





    
    if (s__BonusMod___BonusInterface_minBonus[(abstractBonus)]) > value or (s__BonusMod___BonusInterface_maxBonus[(abstractBonus)]) < value then // INLINED!!
        return false
    endif
    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        return sc__Bonus_isValidBonus(abstractBonus,u , value)
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
        return false
    endif
    
    return ( value >= s__BonusMod___BonusInterface_minBonus[bonus] ) and ( value <= s__BonusMod___BonusInterface_maxBonus[bonus] )
endfunction

function RemoveUnitBonus takes unit u,integer abstractBonus returns nothing
    local integer i= 0
    local integer bonus= (abstractBonus)






    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        call sc__Bonus_removeBonus(abstractBonus,u)
        return
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
// NO_DEBUG:         debug call BonusMod___ErrorMsg("RemoveUnitBonus()", "Trying to remove a hero-only bonus from a non-hero unit")
        return
    endif
    
    call UnitRemoveAbility(u, s__BonusMod___AbilityBonus_negativeRawcode[bonus])
    
    loop
        exitwhen i == s__BonusMod___AbilityBonus_count[bonus]
        
        call UnitRemoveAbility(u, s__BonusMod___AbilityBonus_rawcode[bonus] + i)

        set i=i + 1
    endloop
endfunction

function SetUnitBonus takes unit u,integer abstractBonus,integer amount returns integer
    local integer i
    local integer output= 0
    local integer bonus= (abstractBonus)
    local boolean applyMinBonus= false
    





    
    if amount == 0 then
        call RemoveUnitBonus(u , bonus)
        return 0
    endif
    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        return sc__Bonus_setBonus(abstractBonus,u , amount)
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
// NO_DEBUG:         debug call BonusMod___ErrorMsg("SetUnitBonus()", "Trying to set a hero-only bonus on a non-hero unit")
        return 0
    endif
    
    if amount < s__BonusMod___BonusInterface_minBonus[bonus] then
// NO_DEBUG:         debug call BonusMod___ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to below its min value")
        set amount=s__BonusMod___BonusInterface_minBonus[bonus]
    elseif amount > s__BonusMod___BonusInterface_maxBonus[bonus] then
// NO_DEBUG:         debug call BonusMod___ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to above its max value")
        set amount=s__BonusMod___BonusInterface_maxBonus[bonus]
    endif
    
    if amount < 0 then
        set amount=- ( s__BonusMod___BonusInterface_minBonus[bonus] - amount )
        set applyMinBonus=true
    endif
    
    call UnitRemoveAbility(u, s__BonusMod___AbilityBonus_negativeRawcode[bonus])
    
    set i=s__BonusMod___AbilityBonus_count[bonus] - 1
    loop
        exitwhen i < 0
        if amount >= BonusMod___powersOf2[i] then
            
            call UnitAddAbility(u, s__BonusMod___AbilityBonus_rawcode[bonus] + i)
            call UnitMakeAbilityPermanent(u, true, s__BonusMod___AbilityBonus_rawcode[bonus] + i)
            





            
            set amount=amount - BonusMod___powersOf2[i]
            set output=output + BonusMod___powersOf2[i]
        else
            
            call UnitRemoveAbility(u, s__BonusMod___AbilityBonus_rawcode[bonus] + i)





        endif

        set i=i - 1
    endloop
    
    if applyMinBonus then
        call UnitAddAbility(u, s__BonusMod___AbilityBonus_negativeRawcode[bonus])
        call UnitMakeAbilityPermanent(u, true, s__BonusMod___AbilityBonus_negativeRawcode[bonus])
    else
        call UnitRemoveAbility(u, s__BonusMod___AbilityBonus_negativeRawcode[bonus])
    endif
    
    return output
endfunction

function GetUnitBonus takes unit u,integer abstractBonus returns integer
    local integer i= 0
    local integer amount= 0
    local integer bonus= (abstractBonus)






    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        return sc__Bonus_getBonus(abstractBonus,u)
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
// NO_DEBUG:         debug call BonusMod___ErrorMsg("GetUnitBonus()", "Trying to get a hero-only bonus from a non-hero unit")
        return 0
    endif
    
    if GetUnitAbilityLevel(u, s__BonusMod___AbilityBonus_negativeRawcode[bonus]) > 0 then
        set amount=s__BonusMod___BonusInterface_minBonus[bonus]
    endif

    loop
        exitwhen i == s__BonusMod___AbilityBonus_count[bonus]
        
        if GetUnitAbilityLevel(u, s__BonusMod___AbilityBonus_rawcode[bonus] + i) > 0 then
            set amount=amount + BonusMod___powersOf2[i]
        endif

        set i=i + 1
    endloop

    return amount
endfunction

function AddUnitBonus takes unit u,integer bonus,integer amount returns integer
    return SetUnitBonus(u , bonus , GetUnitBonus(u , bonus) + amount)
endfunction

// ===
//  Initialization
// ===

//Implemented from module BonusMod___BonusModInitModule:

    function s__BonusModStruct_BonusMod___BonusModInitModule___onInit takes nothing returns nothing
        local integer i
        
        // Set up powers of 2
        set BonusMod___powersOf2[0]=1
        set BonusMod___powersOf2Count=1
        



        
        // Setup bonuses
        call BonusMod___Setup()
    endfunction

    
    function s__BonusModStruct_addBonus takes unit u,integer bonus,integer amount returns integer
        return SetUnitBonus(u , bonus , GetUnitBonus(u , bonus) + amount)
    endfunction


    //=======================================================================
    // Save the map, then delete the exclaimation mark in the following line.
    // Make sure that you don't have an object in your map with the rawcode
    // 'dumi' and also configure the model path (war3mapImported\dummy.mdl)
    // to the dummy.mdx model created by Vexorian.
    // ObjectMerger disabled: dumi is supplied by the TerrainDev object-data build.

    //Thanks to Vexorian that Optimizer 5.0 no longer kills natives



    function MissileRecycler___ToggleIndexer takes boolean flag returns nothing





            set s__UnitDex_Enabled=flag

    endfunction









    //=======================================================================
    // Get a recycled dummy missile unit. If there are no recycled dummies
    // that are already facing the angle you need, it creates a new dummy for
    // you.
    //
    function GetRecycledMissile takes real x,real y,real z,real facing returns unit
        local integer i= ModuloInteger(R2I(facing), 360) / MissileRecycler___ANG_VAL
        local integer this= MissileRecycler___queueNext[i]
        local unit u
        if this != 0 and TimerGetElapsed(MissileRecycler___gameTime) >= MissileRecycler___timeStamp[this] then
            //Dequeue this
            set MissileRecycler___queueNext[i]=MissileRecycler___queueNext[this]
            if MissileRecycler___queueNext[i] == 0 then
                set MissileRecycler___queueLast[i]=i
            endif
            //Recycle this index
            set MissileRecycler___queueLast[this]=MissileRecycler___recycle
            set MissileRecycler___recycle=this
            //Add queue index to available stack
            set MissileRecycler___queueStack[MissileRecycler___queueStackN]=i
            set MissileRecycler___queueStackN=MissileRecycler___queueStackN + 1
            //Old unit will return as new
            set u=MissileRecycler___stack[this]
            call SetUnitFacing(u, facing)
            call SetUnitUserData(u, 0)
            //Reset the dummy's properties.
            call SetUnitVertexColor(u, 255, 255, 255, 255)
            call SetUnitAnimationByIndex(u, 90)
            call SetUnitScale(u, 1, 0, 0)

                call s__MissileStats_acquire(u , true)

            //call PauseUnit(u, false) -- you can disable "resets" that you don't need to worry about.
// NO_DEBUG:             debug call MissileRecycler___Print("Recycling")
        else
// NO_DEBUG:             debug call MissileRecycler___Print("Creating new")
            set s__UnitDex_Enabled=(false) // INLINED!!
            set u=CreateUnit(MissileRecycler___OWNER, MissileRecycler___DUMMY_ID, x, y, facing)
            set s__UnitDex_Enabled=(true) // INLINED!!
            call PauseUnit(u, true)

                call s__MissileStats_acquire(u , false)

        endif
        call SetUnitX(u, x)
        call SetUnitY(u, y)
        call SetUnitFlyHeight(u, z, 0)
        set bj_lastCreatedUnit=u
        set u=null
        return bj_lastCreatedUnit
    endfunction

    //=======================================================================
    // You should recycle the dummy missile unit when its job is done.
    //
    function RecycleMissile takes unit u returns nothing
        local integer i
        local integer this= MissileRecycler___recycle
        if GetUnitTypeId(u) == MissileRecycler___DUMMY_ID and UnitAlive(u) and GetUnitUserData(u) != - 1 then
            if MissileRecycler___queueStackN == 0 then
// NO_DEBUG:                 debug call MissileRecycler___Print("Stack is full - removing surplus unit")

                    call s__MissileStats_returned(u , false , MissileRecycler___DEATH_TIME)

                // TerrainDev / Classic 1.27b: paused units freeze timed life.
                // Only surplus units leave the paused pool before disposal.
                call PauseUnit(u, false)
                call UnitApplyTimedLife(u, 'BTLF', MissileRecycler___DEATH_TIME)
                return
            endif
            //Recycle this
            set MissileRecycler___recycle=MissileRecycler___queueLast[this]
            //Index the dummy unit to an available facing angle.
            //Get the last vacant angle index.
            set MissileRecycler___queueStackN=MissileRecycler___queueStackN - 1
            set i=MissileRecycler___queueStack[MissileRecycler___queueStackN]
            //Enqueue this
            set MissileRecycler___queueNext[MissileRecycler___queueLast[i]]=this
            set MissileRecycler___queueLast[i]=this
            set MissileRecycler___queueNext[this]=0
            //Allow a time barrier for the effect to destroy/turn to complete.
            set MissileRecycler___timeStamp[this]=TimerGetElapsed(MissileRecycler___gameTime) + MissileRecycler___DEATH_TIME
            set MissileRecycler___stack[this]=u
            call SetUnitFacing(u, i * MissileRecycler___ANG_VAL + MissileRecycler___ANG_MID)
            call SetUnitOwner(u, MissileRecycler___OWNER, false)
            //Prevent double-free of this unit.
            call SetUnitUserData(u, - 1)

                call s__MissileStats_returned(u , true , MissileRecycler___DEATH_TIME)

        else

                call s__MissileStats_invalidReturn()

// NO_DEBUG:             debug call BJDebugMsg("[MissileRecycler] Error: Attempt to recycle invalid unit.")
        endif
    endfunction

    //=======================================================================
    // I didn't need this function after all
    //
    function RecycleMissileDelayed takes unit u,real r returns nothing
        call RecycleMissile(u)
    endfunction

    //=======================================================================
    // Map the dummy units to their facing angles (map below is if ANG_N is
    // 4 and ANG_STORAGE_MAX is 3).
    //
    // angle[0] (0)   -  [4] [5] [6]
    // angle[1] (90)  -  [7] [8] [9]
    // angle[2] (180) - [10][11][12]
    // angle[3] (270) - [13][14][15]
    //
    function MissileRecycler___Init takes nothing returns nothing
        local integer end
        local integer i= MissileRecycler___ANG_N
        local integer n= i
        local integer angle
        local real x= GetRectMaxX(bj_mapInitialPlayableArea)
        local real y= GetRectMaxY(bj_mapInitialPlayableArea)
        local unit u

            call s__MissileStats_configure(MissileRecycler___ANG_N * MissileRecycler___ANG_STORAGE_MAX)

        set s__UnitDex_Enabled=(false) // INLINED!!
        loop
            set i=i - 1
            set MissileRecycler___queueNext[i]=n
            set angle=i * MissileRecycler___ANG_VAL + MissileRecycler___ANG_MID
            set end=n + MissileRecycler___ANG_STORAGE_MAX
            set MissileRecycler___queueLast[i]=end - 1
            loop
                set MissileRecycler___queueNext[n]=n + 1
                set u=CreateUnit(MissileRecycler___OWNER, MissileRecycler___DUMMY_ID, x, y, angle)
                set MissileRecycler___stack[n]=u
                call PauseUnit(u, true)
                call SetUnitUserData(u, - 1)

                    call s__MissileStats_preload(u)

                set n=n + 1
                exitwhen n == end
            endloop
            set MissileRecycler___queueNext[n - 1]=0
            exitwhen i == 0
        endloop
        set s__UnitDex_Enabled=(true) // INLINED!!
        call TimerStart(MissileRecycler___gameTime, 1000000., false, null)
        set u=null
    endfunction

    function MissileRecycler___PreInit takes nothing returns nothing



            call MissileRecycler___Init()

    endfunction


//==============================================================================
// UnitMaxState v2.1
//==============================================================================
// Credits:
//------------------------------------------------------------------------------
// Written By:
//     Earth-Fury
// 
// Original System By:
//     Blade.dk
// 
// Intermittent Version By:
//     Deaod
//
// With Thanks To:
//     - weaaddar for BonusMod and thus inspiration
//     - PitzerMike for the ObjectMerger
//     - Vexorian for vJass and Jass Helper
//     - PipeDream for Grimoire
//     - SFilip for TESH
//     - MindWorX for maintaining NewGen
//------------------------------------------------------------------------------
// If you use this library in your map, please at least give credit to Blade.dk.
// Without him, this library would not exist.
//==============================================================================
// Introduction:
//------------------------------------------------------------------------------
// UnitMaxState is a library which allows you to modify a unit's maximum life,
// or maximum mana. To achieve this, the library abuses a bug with the AIlf and
// AImz abilities, which is too complex to explain here.
// 
// I do believe it was indeed Blade.dk who initially found this bug. If not,
// it's still his system I stole and rewrote. Further, let me thank Deaod for
// writing up his version of this system, which inspired both the reality of
// this rewrite, and the method abilities are handled within it.
// 
//==============================================================================
// Requirements:
//------------------------------------------------------------------------------
// UnitMaxState is written in vJass and requires the NewGen editor, or
// Jass Helper with PitzerMike's Object Merger configured for it.
// 
// UnitMaxState requires the latest version of Jass Helper.
// 
// Preloading of abilities requires either AbilityPreload or xepreload. Neither
// are required for the library to function; however, having one or the other
// will remove the slight delay the first time a unit's max state is changed.
// 
//==============================================================================
// Using UnitMaxState:
//------------------------------------------------------------------------------
// UnitMaxState comes with two useful functions:
// 
// nothing SetUnitMaxState(unit <target>, unitstate <state>, real <value>)
//     Changes <target>'s unitstate <state> to be equal to <value>.
//
// nothing AddUnitMaxState(unit <target>, unitstate <state>, real <value>)
//     Adds <value> to <target>'s <state> unitstate. Note that you can use
//     negative values with this function.
//
// Both of these functions accept unitstate's other than UNIT_STATE_MAX_LIFE and
// UNIT_STATE_MAX_MANA. There is a small performance penalty in using these over
// direct usage of SetUnitState.
// 
// You must not use life/mana boosting upgrades in combination with this system.
// 
// Attempting to set a unit's maximum life below 1, or mana below 0 will do
// nothing. A debug message will be output if the script is compiled in
// debug mode.
//==============================================================================



//==============================================================================
// Configuration:
//------------------------------------------------------------------------------
// The below textmacro call is an all-in-one configuration line.
//------------------------------------------------------------------------------
// The first parameter is a boolean.
// 
// If true, the abilities used by this system will be created on save. This adds
// a slight delay to saving your map. You only ever have to create the abilities
// the first time this library is added to your map, or if you modify any of
// the other configuration options.
// 
// Note that to make the ability creation permanent, you must save with ability
// creation enabled, close your map, and reopen it in the editor. You can then
// disable ability creation, as the abilities will be permanently in your map.
//------------------------------------------------------------------------------
// The second parameter is an integer.
// 
// This is the number of abilities this system will use for adding/removing
// life/mana. Note that this system uses four sets of abilities, so the actual
// number of abilities generated and used will be the value you pass here,
// multiplied by 4.
// 
// The higher this number, the faster large bonuses will be added. This number
// should never have to go above 13. Between 3 and 5 will work fine for most
// maps.
//------------------------------------------------------------------------------
// The fourth and fifth parameters are 3 character prefixes for rawcodes.
//
// The first one is for the life-modifying abilities, while the second is for
// the mana-modifying abilities.
// 
// Please, make sure your map has no abilities whose rawcodes begin with either
// of these prefixes before saving! Otherwise, those abilities will be
// overwritten. You can change these to any 3 character combination, if your
// map does already contain abilities whose rawcodes begin with these prefixes.
//------------------------------------------------------------------------------

//textmacro instance: UnitMaxState_Configuration("false", "3", "ZxL", "ZxM")
    //*
    // externalblock extension=lua ObjectMerger $FILENAME$
    // endexternalblock
    // */
    
//end of: UnitMaxState_Configuration("false", "3", "ZxL", "ZxM")

//------------------------------------------------------------------------------
// End of configuration
//------------------------------------------------------------------------------


function UnitMaxState___ErrorMsg takes string s returns nothing
// NO_DEBUG:     debug call BJDebugMsg("SetUnitMaxState: " + s)
endfunction

function SetUnitMaxState takes unit target,unitstate state,real targetValue returns nothing
    local integer difference
    local integer rawcode
    
    local integer abilityId
    local integer abilityLevel
    
    local integer currentAbility
    
    if state == UNIT_STATE_MAX_LIFE then
        set rawcode=UnitMaxState___RAWCODE_LIFE
        
        if targetValue < 1 then
            call UnitMaxState___ErrorMsg("You can not set a unit's max life to below 1")
            return
        endif
    elseif state == UNIT_STATE_MAX_MANA then
        set rawcode=UnitMaxState___RAWCODE_MANA
        
        if targetValue < 0 then
            call UnitMaxState___ErrorMsg("You can not set a unit's max mana to below 0")
            return
        endif
    else
        call SetUnitState(target, state, targetValue)
        return
    endif
    
    set difference=R2I(targetValue) - R2I(GetUnitState(target, state))
    
    if difference < 0 then
        set difference=- difference
        set rawcode=rawcode + UnitMaxState_ABILITY_COUNT
    endif
    
    set abilityId=UnitMaxState_ABILITY_COUNT - 1
    set abilityLevel=4
    set currentAbility=rawcode + abilityId
    loop
        exitwhen difference == 0
        
        if difference >= UnitMaxState___POWERS_OF_2[abilityId * 3 + ( abilityLevel - 2 )] then
            call UnitAddAbility(target, currentAbility)
            call SetUnitAbilityLevel(target, currentAbility, abilityLevel)
            call UnitRemoveAbility(target, currentAbility)
            
            set difference=difference - UnitMaxState___POWERS_OF_2[abilityId * 3 + ( abilityLevel - 2 )]
        else
            set abilityLevel=abilityLevel - 1
            if abilityLevel <= 1 then
                set abilityId=abilityId - 1
                set abilityLevel=4
                set currentAbility=rawcode + abilityId
            endif
        endif
    endloop
endfunction

function AddUnitMaxState takes unit target,unitstate state,real additionalValue returns nothing
    call SetUnitMaxState(target , state , GetUnitState(target, state) + additionalValue)
endfunction




//Implemented from module UnitMaxState___UnitStatInit:
function s__UnitMaxState___Data_UnitMaxState___UnitStatInit__onInit takes nothing returns nothing
    local integer i
    local integer k
    
    set i=1
    set UnitMaxState___POWERS_OF_2[0]=1
    loop
        exitwhen i == UnitMaxState_ABILITY_COUNT * 2 * 2 * 3 + 1
        
        set UnitMaxState___POWERS_OF_2[i]=UnitMaxState___POWERS_OF_2[i - 1] * 2
        set i=i + 1
    endloop
    
































endfunction




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

            set s__UIButton_clickTimer[this]=null
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
            call sc__UIButton_show(this,false , - 1)
            set s__UIButton_Unit2Button[s__UIButton_unitId[this]]=0
            if s__UIButton_clickTimer[this] != null then
                call PauseTimer(s__UIButton_clickTimer[this])
                call ReleaseTimer(s__UIButton_clickTimer[this])
                set s__UIButton_clickTimer[this]=null
            endif
            call RemoveUnit(s__UIButton_picture[this])
            set s__UIButton_picture[this]=null
            set s__UIButton_selectUnit[this]=null
            call s__UIButton_deallocate(this)
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
            local integer i= s__UIButton_CountShow - 1
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
            local integer i= s__UIButton_CountShow - 1
            
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




            if s__UIButton_clickTimer[btn] == t then
                set s__UIButton_disabled[btn]=false
                set s__UIButton_clickTimer[btn]=null
            endif

                call ReleaseTimer(t)



            set t=null
        endfunction

        function s__UIButton_clickPeriodicSelect takes player p,boolean isLeft returns boolean
            local integer i= s__UIButton_CountShow - 1
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


                                set s__UIButton_clickTimer[s__UIButton_AllShow[i]]=NewTimerEx(s__UIButton_AllShow[i])
                                call TimerStart(s__UIButton_clickTimer[s__UIButton_AllShow[i]], s__Interface_LEFT_CLICK_DELAY, false, function s__UIButton_enableButtonCallback)







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
            call sc__UIPicture_show(this,false , - 1)
            call RemoveUnit(s__UIPicture_picture[this])
            set s__UIPicture_picture[this]=null
            call s__UIPicture_deallocate(this)
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
            local integer i= s__UIPicture_CountShow - 1

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
            call sc__UIText_show(this,false , - 1)
            call DestroyTextTag(s__UIText_text[this])
            call RemoveUnit(s__UIText_dummy[this])
            set s__UIText_text[this]=null
            set s__UIText_dummy[this]=null
            call s__UIText_deallocate(this)
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
            local integer i= s__UIText_CountShow - 1
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
    


    
        //
        // configuration
        //
        
        // location of inventory
        
        // size of the background wwindow
        
        // location of the tooltip information
        
        // max # of pages the inventory can have 
        
        // how many slots are on each row/column
        
        // how fast the UI updates
        
        // show errors

        // icon size
        
        // icon offsets (from X,Y)
        
        // raw id's
        
        
        
        //
        // don't edit below here unless you know what you're doing
        //
        
        
        
        
        
        
        
        
    
        function s__Inventory_localInt takes integer pid,integer value,integer other returns integer
            if ( s__User_Local != s__User_handle[(pid)] ) then
                set value=other
            endif
            return value
        endfunction
        
        function s__Inventory_err takes player p,string s returns nothing


                    call SimError(p , s)




        endfunction
        
        function s__Inventory__staticgetindex takes unit u returns integer
            return (LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(u)))
        endfunction
        
        function s__Inventory__staticsetindex takes unit u,integer value returns nothing
            call SaveInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(u), value)
        endfunction
 
        function s__Inventory_getButton takes integer this,integer index returns integer
            return s__Inventory_buttons[( s__Inventory_pid[this] * s__Inventory_MAX_SLOTS ) + index]
        endfunction
        
        function s__Inventory_setButton takes integer this,integer index,integer value returns nothing
            set s__Inventory_buttons[( s__Inventory_pid[this] * s__Inventory_MAX_SLOTS ) + index]=value
        endfunction
        
        function s__Inventory_getItem takes integer this,integer index returns integer
            return LoadInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + index)
        endfunction
        
        function s__Inventory_itemsOfType takes integer this,integer id returns integer
            return (LoadInteger(InventoryTable___ht, ((s__Inventory_countTable[this])), (id))) // INLINED!!
        endfunction
        
        function s__Inventory_addLeftClickHook takes code func returns nothing
            call TriggerAddAction(s__Inventory_ExecL, func)
        endfunction
        
        function s__Inventory_addRightClickHook takes code func returns nothing
            call TriggerAddAction(s__Inventory_ExecR, func)
        endfunction
        
        function s__Inventory_getItemId takes integer this,integer index returns integer
            return LoadInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + index)
        endfunction
        
        function s__Inventory_setItem takes integer this,integer index,integer itm returns nothing
            local integer btn
            local integer slot= index
            local integer id= s__InvItem_id[itm]
            local integer icon= GetItemIcon(id)
            local integer oldItem
            
            if ( s__Inventory_currentPage[this] > 0 ) then
                set slot=index - ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[this] )
            endif
            
            set btn=(s__Inventory_buttons[( s__Inventory_pid[(this)] * s__Inventory_MAX_SLOTS ) + (slot)]) // INLINED!!

            set oldItem=(LoadInteger(s__Inventory_Hashtable, (this), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (index))) // INLINED!!
            
            call SaveInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + index, itm)
            
            if ( s__InvItem_tempCustomId[itm] > 0 ) then
                call SaveInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + index, s__InvItem_tempCustomId[itm])
            endif
            
            set s__InvItem_tempCustomId[itm]=0
            
            if ( id == 0 and HaveSavedInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + index) ) then
                set id=s__InvItem_id[oldItem]
                
                set s__Inventory_itemCount[this]=s__Inventory_itemCount[this] - 1
                call SaveInteger(InventoryTable___ht, ((s__Inventory_countTable[this])), (id), ( (LoadInteger(InventoryTable___ht, ((s__Inventory_countTable[this])), (id))) - 1)) // INLINED!!
                
                call RemoveSavedInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + index)
                
                // remove ability
                if ( s__InvItem_ability[oldItem] > 0 and (LoadInteger(InventoryTable___ht, ((s__Inventory_countTable[(this)])), ((id)))) <= 0 ) then // INLINED!!
                    call UnitRemoveAbility(s__Inventory_owner[this], s__InvItem_ability[oldItem])
                endif
            elseif ( id > 0 ) then
                set s__Inventory_itemCount[this]=s__Inventory_itemCount[this] + 1
                call SaveInteger(InventoryTable___ht, ((s__Inventory_countTable[this])), (id), ( (LoadInteger(InventoryTable___ht, ((s__Inventory_countTable[this])), (id))) + 1)) // INLINED!!
                
                // add ability
                if ( s__InvItem_ability[itm] > 0 and (LoadInteger(InventoryTable___ht, ((s__Inventory_countTable[(this)])), ((id)))) == 1 ) then // INLINED!!
                    call UnitAddAbility(s__Inventory_owner[this], s__InvItem_ability[itm])
                endif
            endif
            
            call s__UIButton_setTexture(btn,s__Inventory_localInt(s__Inventory_pid[this] , icon , s__Inventory_ICON_TRANSPARENT))
            call s__UIButton_showPlayer(btn,s__User_handle[s__Inventory_user[this]] , s__Inventory_displayed[this] , s__Inventory_camera[this])
        endfunction
        
        function s__Inventory_findFreeSlot takes integer this,integer page returns integer
            local integer i= 0
            loop
                exitwhen i == s__Inventory_MAX_SLOTS
                if ( (LoadInteger(s__Inventory_Hashtable, (this), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (( s__Inventory_MAX_SLOTS * page ) + i))) == 0 ) then // INLINED!!
                    return i
                endif
                set i=i + 1
            endloop
            return - 1
        endfunction

        function s__Inventory_createButtons takes integer this returns nothing
            local integer row= 0
            local integer col= 0
            local integer btn= 0
            local integer i= 0

            if ( s__Inventory_btnPageUp[s__Inventory_pid[this]] == 0 ) then
                set s__Inventory_btnPageUp[s__Inventory_pid[this]]=s__UIButton_create(s__Inventory_X - 0.15 , ( s__Inventory_Y + s__Inventory_SLOT_OFFSET_Y ) - ( col * ( s__Inventory_SLOT_HEIGHT * s__Inventory_SLOT_SPACING ) ) , s__Inventory_SLOT_WIDTH , s__Inventory_SLOT_HEIGHT , 0.5 , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_PAGEUP , s__Inventory_ICON_TRANSPARENT))
                set s__Inventory_btnPageDown[s__Inventory_pid[this]]=s__UIButton_create(s__Inventory_X - 0.15 , ( s__Inventory_Y + s__Inventory_SLOT_OFFSET_Y ) - ( ( s__Inventory_BUTTON_COLS - 1 ) * ( s__Inventory_SLOT_HEIGHT * s__Inventory_SLOT_SPACING ) ) , s__Inventory_SLOT_WIDTH , s__Inventory_SLOT_HEIGHT , 0.5 , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_PAGEDOWN , s__Inventory_ICON_TRANSPARENT))
                set s__Inventory_btnSell[s__Inventory_pid[this]]=s__UIButton_create(s__Inventory_X - 0.15 , ( s__Inventory_Y + s__Inventory_SLOT_OFFSET_Y ) - .300 , s__Inventory_SLOT_WIDTH , s__Inventory_SLOT_HEIGHT , 0.5 , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_SELL , s__Inventory_ICON_TRANSPARENT))
                set s__Inventory_btnDrop[s__Inventory_pid[this]]=s__UIButton_create(s__Inventory_X - 0.15 , ( s__Inventory_Y + s__Inventory_SLOT_OFFSET_Y ) - .150 , s__Inventory_SLOT_WIDTH , s__Inventory_SLOT_HEIGHT , 0.5 , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_DROP , s__Inventory_ICON_TRANSPARENT))
                
                set s__UIButton_onLeftClick[s__Inventory_btnPageUp[s__Inventory_pid[this]]]=InvFuncLClickSlot
                set s__UIButton_onLeftClick[s__Inventory_btnPageDown[s__Inventory_pid[this]]]=InvFuncLClickSlot
                set s__UIButton_onLeftClick[s__Inventory_btnSell[s__Inventory_pid[this]]]=InvFuncLClickSlot
                set s__UIButton_onLeftClick[s__Inventory_btnDrop[s__Inventory_pid[this]]]=InvFuncLClickSlot
                
                set s__UIButton_selectUnit[s__Inventory_btnPageUp[s__Inventory_pid[this]]]=s__Inventory_owner[this]
                set s__UIButton_selectUnit[s__Inventory_btnPageDown[s__Inventory_pid[this]]]=s__Inventory_owner[this]
                set s__UIButton_selectUnit[s__Inventory_btnSell[s__Inventory_pid[this]]]=s__Inventory_owner[this]
                set s__UIButton_selectUnit[s__Inventory_btnDrop[s__Inventory_pid[this]]]=s__Inventory_owner[this]
                
                set s__Inventory_selector[s__Inventory_pid[this]]=s__UIPicture_createEx(s__Inventory_X - 0.15 , ( s__Inventory_Y + s__Inventory_SLOT_OFFSET_Y ) - .250 , 0 , .55 , 'e000' , 1 , 1 , 0)
                set s__UIPicture_animIndex[s__Inventory_selector[s__Inventory_pid[this]]]=56
                call s__UIPicture_show(s__Inventory_selector[s__User_id[s__Inventory_user[this]]],false , s__Inventory_camera[this])
                
                call AddSpecialEffectTarget("UI\\TRSHerolevel.mdx", s__UIPicture_picture[s__Inventory_selector[s__Inventory_pid[this]]], "origin")
            endif
            
            loop
                exitwhen col == s__Inventory_BUTTON_COLS
                
                set row=0
                
                loop
                    exitwhen row == s__Inventory_BUTTON_ROWS
                    
                    if ( (s__Inventory_buttons[( s__Inventory_pid[(this)] * s__Inventory_MAX_SLOTS ) + (i)]) == 0 ) then // INLINED!!
                    
                        set btn=s__UIButton_create(( s__Inventory_X + s__Inventory_SLOT_OFFSET_X ) + ( row * ( s__Inventory_SLOT_WIDTH * s__Inventory_SLOT_SPACING ) ) , ( s__Inventory_Y + s__Inventory_SLOT_OFFSET_Y ) - ( col * ( s__Inventory_SLOT_HEIGHT * s__Inventory_SLOT_SPACING ) ) , s__Inventory_SLOT_WIDTH , s__Inventory_SLOT_HEIGHT , 0.5 , GetItemIcon(s__InvItem_id[(LoadInteger(s__Inventory_Hashtable, (this), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (i)))])) // INLINED!!
                        
                        set s__UIButton_customValue[btn]=i
                        
                        set s__UIButton_selectUnit[btn]=s__Inventory_owner[this]
                        
                        set s__UIButton_onLeftClick[btn]=InvFuncLClickSlot
                        set s__UIButton_onRightClick[btn]=InvFuncRClickSlot
                        
                        set s__Inventory_buttons[( s__Inventory_pid[(this)] * s__Inventory_MAX_SLOTS ) + (i )]=( btn) // INLINED!!

                        //call SetUnitVertexColor(.background[this.pid].picture, 255, 255, 255, thistype.localInt(this.pid, 255, 0))
                    endif
                    set i=i + 1
                    
                    set row=row + 1
                endloop
                
                set col=col + 1
            endloop
        endfunction
        
//Implemented from module InvPlugins:
        //
        // configuration
        //
        
        // about the length of tooltip line.
        // line lengths are resolution and char-width 
        // dependent for textags, so a new text tag
        // is created per-line.
        
        //
        // end config
        //
        
        
        
        function s__Inventory_setTooltipTitle takes integer this,string title returns nothing
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[this]]], title, 10 * 0.0023)
        endfunction
        
        function s__Inventory_setTooltipInfo takes integer this,string desc returns nothing
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[this]]], desc, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
        endfunction
        
        function s__Inventory_setTooltipCost takes integer this,string value returns nothing
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxCost[s__Inventory_pid[this]]], value, 8 * 0.0023)
        endfunction
        
        function s__Inventory_setTooltipIcon takes integer this,integer id returns nothing
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[this]],id)
        endfunction
        
        function s__Inventory_setTooltipLine takes integer pid,integer line,string str returns nothing
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[(pid)*(16)+line]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
        endfunction
        
        function s__Inventory_setTooltipSlot takes integer pid,integer line,string str returns nothing
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[(pid)*(16)+s__Inventory_TOOLTIP_LINES_MAX - 1]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
        endfunction
        
        function s__Inventory_showLines takes integer this,integer pid,boolean flag,integer cam returns nothing
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                if ( not flag ) then
                    call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[(pid)*(16)+i]], "", s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
                endif
                call s__UIText_show(s__s__Inventory_ItemInfoTags[(pid)*(16)+i],flag , cam)
                set i=i + 1
            endloop
        endfunction
        
        function s__Inventory_clearLines takes integer pid returns nothing
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[(pid)*(16)+i]], "", s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
                set i=i + 1
            endloop
        endfunction
        
        function s__Inventory_updateLines takes integer pid returns nothing
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                call s__UIText_update(s__s__Inventory_ItemInfoTags[(pid)*(16)+i])
                set i=i + 1
            endloop
        endfunction
        
        function s__Inventory_createTooltip takes integer this,integer raceId returns nothing
            local boolean showLocally= ( s__User_Local == s__User_handle[(s__Inventory_pid[this])] )
            local integer i= 0
        
            //if (showLocally) then
                if ( s__Inventory_infoBoxTitle[s__Inventory_pid[this]] == null ) then
                    set s__Inventory_infoBoxTitle[s__Inventory_pid[this]]=s__UIText_createEx((s__User_handle[(s__Inventory_user[this])]) , s__Inventory_TOOLTIP_X - 0.1 , s__Inventory_TOOLTIP_Y + .22 , 1) // INLINED!!
                    
                    set s__Inventory_infoBoxDesc[s__Inventory_pid[this]]=s__UIText_createEx((s__User_handle[(s__Inventory_user[this])]) , s__Inventory_TOOLTIP_X - 0.1 , s__Inventory_TOOLTIP_Y + .25 , 1) // INLINED!!
                endif
                
                if ( s__Inventory_infoBoxCost[s__Inventory_pid[this]] == null ) then
                    set s__Inventory_infoBoxCost[s__Inventory_pid[this]]=s__UIText_createEx((s__User_handle[(s__Inventory_user[this])]) , s__Inventory_TOOLTIP_X - ( 0.065 - 0. ) , s__Inventory_TOOLTIP_Y + .15 , 1) // INLINED!!
                endif
                
                
                // description lines
                if ( s__s__Inventory_ItemInfoTags[(s__Inventory_pid[this])*(16)+0] == 0 ) then
                    loop
                        exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                        
                        if ( i == s__Inventory_TOOLTIP_LINES_MAX - 1 ) then
                            set s__s__Inventory_ItemInfoTags[(s__Inventory_pid[this])*(16)+i]= s__UIText_createEx((s__User_handle[(s__Inventory_user[this])]) , s__Inventory_TOOLTIP_X + 0.05 , s__Inventory_TOOLTIP_Y + .16 , 1) // INLINED!!
                        else
                            set s__s__Inventory_ItemInfoTags[(s__Inventory_pid[this])*(16)+i]= s__UIText_createEx((s__User_handle[(s__Inventory_user[this])]) , s__Inventory_TOOLTIP_X - 0.18 , s__Inventory_TOOLTIP_Y - ( - .05 + ( s__Inventory_TOOLTIP_LINE_SPACING * i ) ) , 1) // INLINED!!
                        endif
                        
                        set i=i + 1
                    endloop
                endif
            //endif
            
            if ( s__Inventory_infoIcon[s__Inventory_pid[this]] == 0 ) then
                set s__Inventory_infoIcon[s__Inventory_pid[this]]=s__UIPicture_create(s__Inventory_TOOLTIP_X - 0.18 , s__Inventory_TOOLTIP_Y + .28 , 0.07 , 0.07 * SCREEN_ASPECT_RATIO , 0.1 , 0)
                set s__Inventory_costIcon[s__Inventory_pid[this]]=s__UIPicture_create(s__Inventory_TOOLTIP_X - 0.1 , s__Inventory_TOOLTIP_Y + .215 , 0.03 , 0.03 * SCREEN_ASPECT_RATIO , 0 , 0)
                set s__Inventory_infoBox[s__Inventory_pid[this]]=s__UIPicture_createEx(s__Inventory_TOOLTIP_X , s__Inventory_TOOLTIP_Y , 0.20 , 0.10 , s__Inventory_TOOLTIP_BACKGROUND , 120. , 60. , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_TOOLTIP_TEXTURE , s__Inventory_ICON_TRANSPARENT))
            endif
            
            call s__UIPicture_setTexture(s__Inventory_costIcon[s__Inventory_pid[this]],s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_TOOLTIP_GOLD , s__Inventory_ICON_TRANSPARENT))
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[this]],s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_TOOLTIP_GOLD , s__Inventory_ICON_TRANSPARENT))
            
            call SetUnitVertexColor(s__UIPicture_picture[s__Inventory_infoBox[s__Inventory_pid[this]]], 255, 255, 255, s__Inventory_localInt(s__Inventory_pid[this] , 255 , 0))
        endfunction
        
        function s__Inventory_showTooltip takes integer this,boolean flag returns nothing
            local integer i= 0
            
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                if ( i < s__Inventory_RightSideStart[s__Inventory_pid[this]] ) then
                    call s__UIText_setPosition(s__s__Inventory_ItemInfoTags[(s__Inventory_pid[this])*(16)+i],s__Inventory_TOOLTIP_X - 0.15 , ( s__Inventory_TOOLTIP_Y - 0.05 ) - ( ( s__Inventory_TOOLTIP_LINE_SPACING * i ) ))
                else
                    call s__UIText_setPosition(s__s__Inventory_ItemInfoTags[(s__Inventory_pid[this])*(16)+i],s__Inventory_TOOLTIP_X + 0.175 , ( s__Inventory_TOOLTIP_Y - 0.05 ) - ( ( s__Inventory_TOOLTIP_LINE_SPACING * ( i - s__Inventory_RightSideStart[s__Inventory_pid[this]] ) ) ))
                endif
                set i=i + 1
            endloop
                    
            call s__UIText_setPosition(s__s__Inventory_ItemInfoTags[(s__Inventory_pid[this])*(16)+s__Inventory_TOOLTIP_LINES_MAX - 1],s__Inventory_TOOLTIP_X + 0.175 , s__Inventory_TOOLTIP_Y + 0.05)
            
            call s__UIPicture_setPosition(s__Inventory_infoBox[s__Inventory_pid[this]],s__Inventory_TOOLTIP_X , s__Inventory_TOOLTIP_Y)
            call s__UIText_setPosition(s__Inventory_infoBoxTitle[s__Inventory_pid[this]],s__Inventory_TOOLTIP_X - 0.15 , s__Inventory_TOOLTIP_Y + 0.1)
            call s__UIText_setPosition(s__Inventory_infoBoxCost[s__Inventory_pid[this]],s__Inventory_TOOLTIP_X - 0.11 , s__Inventory_TOOLTIP_Y + 0.022)
            call s__UIPicture_setPosition(s__Inventory_costIcon[s__Inventory_pid[this]],s__Inventory_TOOLTIP_X - 0.15 , s__Inventory_TOOLTIP_Y + 0.1)

            call s__UIPicture_show(s__Inventory_infoBox[s__Inventory_pid[this]],flag , s__Inventory_camera[this])
            //call .infoIcon[this.pid].show(flag, this.camera)
            call s__UIText_show(s__Inventory_infoBoxTitle[s__Inventory_pid[this]],flag , s__Inventory_camera[this])
            call s__Inventory_showLines(this,s__Inventory_pid[this] , flag , s__Inventory_camera[this])
            call s__UIText_show(s__Inventory_infoBoxCost[s__Inventory_pid[this]],flag , s__Inventory_camera[this])
            call s__UIPicture_show(s__Inventory_costIcon[s__Inventory_pid[this]],flag , s__Inventory_camera[this])
        endfunction
        
        function s__Inventory_updateTooltip takes integer this returns nothing
            local integer i= 0
            
            call s__UIPicture_update(s__Inventory_infoBox[s__Inventory_pid[this]])
            call s__UIPicture_update(s__Inventory_infoIcon[s__Inventory_pid[this]])
            call s__UIText_update(s__Inventory_infoBoxTitle[s__Inventory_pid[this]])
            call s__Inventory_updateLines(s__Inventory_pid[this])
            call s__UIText_update(s__Inventory_infoBoxCost[s__Inventory_pid[this]])
            call s__UIPicture_update(s__Inventory_costIcon[s__Inventory_pid[this]])
        endfunction
        
        
        function s__Inventory_create takes unit owner returns integer
            local integer this= s__Inventory__allocate()
            local boolean showLocally
            local integer raceId
            local integer i= 0
            
            set s__Inventory_itemCount[this]=0
            set s__Inventory_owner[this]=owner
            set s__Inventory_freeSlot[this]=0
            set s__Inventory_pid[this]=GetPlayerId(GetOwningPlayer(s__Inventory_owner[this]))
            set s__Inventory_user[this]=(s__Inventory_pid[this])
            set s__Inventory_countTable[this]=s__InventoryTable__allocate()
            
            set raceId=GetHandleId(GetPlayerRace(s__User_handle[(s__Inventory_pid[this])])) - 1
            
            set showLocally=( s__User_Local == s__User_handle[(s__Inventory_pid[this])] )
            
            call s__Inventory_createButtons(this)
            

                call s__Inventory_createTooltip(this , raceId)

            
            if ( s__Inventory_pageNum[s__Inventory_pid[this]] == 0 ) then
                set s__Inventory_pageNum[s__Inventory_pid[this]]=s__UIText_createEx((s__User_handle[(s__Inventory_user[this])]) , s__Inventory_X + 0.300 , s__Inventory_Y + .10 , 1) // INLINED!!
            endif
            
            call SaveInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId((s__Inventory_owner[this])), ( this)) // INLINED!!
            
            if ( s__Inventory_background[s__Inventory_pid[this]] == 0 ) then
                set s__Inventory_background[s__Inventory_pid[this]]=s__UIPicture_createEx(s__Inventory_X , s__Inventory_Y , 2 , s__Inventory_SCALE , s__Inventory_BACKGROUND , 70. , 60 , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_RACE_BORDERS_START + raceId , s__Inventory_ICON_TRANSPARENT))
            endif

            set s__Inventory_prev[s__Inventory_next[(0)]]=this
            set s__Inventory_next[this]=s__Inventory_next[(0)]
            set s__Inventory_next[(0)]=this

            set s__Inventory_prev[this]=0

            return this
        endfunction
        
        function s__Inventory_addItem takes integer this,integer itm returns boolean
            local integer slot
            
            if ( itm <= 0 or s__InvItem_id[itm] <= 0 ) then
                return false
            endif
            
            set slot=s__Inventory_findFreeSlot(this,s__Inventory_currentPage[this])
            
            if ( slot == - 1 ) then
                call SimError((s__User_handle[(s__Inventory_pid[this])] ) , ( "There are no free slots on this inventory page.")) // INLINED!!
                return false
            endif
            
            if ( s__InvItem_icon[itm] == s__Inventory_ICON_EMPTY ) then
                return false
            endif
            
            call s__Inventory_setItem(this,( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[this] ) + slot , itm)
            
            return true
        endfunction
        
        function s__Inventory_destroy takes integer this returns nothing
            set s__Inventory_prev[s__Inventory_next[this]]=s__Inventory_prev[this]
            set s__Inventory_next[s__Inventory_prev[this]]=s__Inventory_next[this]

            call s__Inventory_deallocate(this)
        endfunction
        
        function s__Inventory_onDisplay takes nothing returns nothing
            local integer inv
            local real x
            local real y
            local real z
            
            local integer user= (s__User_LocalId)
            
            set inv=s__Inventory_PlayerCurrent[s__User_id[user]]
            
            if ( inv == 0 or not s__Inventory_displayed[inv] ) then
                return
            endif
            
            set x=GetUnitX(s__Inventory_owner[inv])
            set y=GetUnitY(s__Inventory_owner[inv])
            set z=GetTerrainZ(x , y) + GetUnitDefaultFlyHeight(s__Inventory_owner[inv])
            
            call s__Camera_setPosition(s__Inventory_camera[inv],x , y , z)
            
            if s__Camera_applyCameraForPlayer(s__Inventory_camera[inv],s__User_handle[user] , false) then
                call s__Interface_updateAll(true , true , true)
            endif

        endfunction
        
        function s__Inventory_show takes integer this,boolean flag,integer cam returns nothing
            local integer i
            local integer equip
            local real timeout
            
            if this == 0 or ( not flag and not s__Inventory_displayed[this] ) then
                return
            endif

            if ( s__Inventory_currentPage[this] >= s__Inventory_MAX_PAGES ) then
                set s__Inventory_currentPage[this]=0
            elseif ( s__Inventory_currentPage[this] < 0 ) then
                set s__Inventory_currentPage[this]=s__Inventory_MAX_PAGES - 1
            endif
            
            if ( flag ) then
                if ( not s__Inventory_displayed[this] ) then
                    set s__Inventory_DisplayCount=s__Inventory_DisplayCount + 1
                endif
                
                if ( s__Inventory_PlayerCurrent[s__Inventory_pid[this]] > 0 and s__Inventory_PlayerCurrent[s__Inventory_pid[this]] != this ) then
                    call s__Inventory_show(s__Inventory_PlayerCurrent[s__Inventory_pid[this]],false , cam)
                endif
                
                set s__Inventory_PlayerCurrent[s__Inventory_pid[this]]=this

                call PauseTimer(s__Inventory_UpdateTimer)
                call TimerStart(s__Inventory_UpdateTimer, s__Inventory_UI_REFRESH_RATE, true, function s__Inventory_onDisplay)
            else
                set s__Inventory_DisplayCount=s__Inventory_DisplayCount - 1
                
                if ( s__Inventory_DisplayCount == 0 ) then
                    call PauseTimer(s__Inventory_UpdateTimer)
                else
                    call TimerStart(s__Inventory_UpdateTimer, s__Inventory_UI_REFRESH_RATE, true, function s__Inventory_onDisplay)
                endif
                
                if ( s__User_LocalId == s__Inventory_pid[this] ) then
                    call ResetToGameCamera(0)
                endif
                
                set s__Inventory_PlayerCurrent[s__Inventory_pid[this]]=0
            endif
            
            set s__Inventory_displayed[this]=flag
            set s__Inventory_camera[this]=cam
            
            call s__UIButton_show(s__Inventory_btnPageUp[s__Inventory_pid[this]],flag , cam)
            call s__UIButton_show(s__Inventory_btnSell[s__Inventory_pid[this]],flag , cam)
            call s__UIButton_show(s__Inventory_btnDrop[s__Inventory_pid[this]],flag , cam)
            //call this.selector[this.pid].show(flag, cam)
            call s__UIButton_show(s__Inventory_btnPageDown[s__Inventory_pid[this]],flag , cam)
            call s__UIPicture_show(s__Inventory_background[s__Inventory_pid[this]],flag , cam)


                if ( not flag ) then
                    call s__Inventory_showTooltip(this , flag)
                endif

            
            call SetTextTagText(s__UIText_text[s__Inventory_pageNum[s__Inventory_pid[this]]], I2S(s__Inventory_currentPage[this] + 1) + "/" + I2S(s__Inventory_MAX_PAGES), 10 * 0.0023)
            
            call s__UIText_show(s__Inventory_pageNum[s__Inventory_pid[this]],flag , cam)
            
            set i=0
            
            loop
                exitwhen i == s__Inventory_MAX_SLOTS
                
                call s__UIButton_setTexture((s__Inventory_buttons[( s__Inventory_pid[(this)] * s__Inventory_MAX_SLOTS ) + (i)]),s__Inventory_localInt(s__Inventory_pid[this] , GetItemIcon(s__InvItem_id[(LoadInteger(s__Inventory_Hashtable, (this), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[this] ) + i)))]) , s__Inventory_ICON_TRANSPARENT)) // INLINED!!

                call s__UIButton_showPlayer((s__Inventory_buttons[( s__Inventory_pid[(this)] * s__Inventory_MAX_SLOTS ) + (i)]),s__User_handle[s__Inventory_user[this]] , flag , s__Inventory_camera[this]) // INLINED!!
                
                call s__UIButton_showPlayer((s__Inventory_buttons[( s__Inventory_pid[(this)] * s__Inventory_MAX_SLOTS ) + (i)]),s__User_handle[s__Inventory_user[this]] , flag , s__Inventory_camera[this]) // INLINED!!
                
                
                set i=i + 1
            endloop

        endfunction
        
        
    
    function InventoryCore_GracePeriod takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer but= ((LoadInteger(TimerUtils__ht, 0, GetHandleId((t))))) // INLINED!!
        
        set InvButtonDisabled[but]=false
        
        call ReleaseTimer(t)
    endfunction
    
    function DisableButtonIfUsingTimer takes integer but,real time returns nothing




    endfunction
    
    function InventoryCore___LClickItemSlot takes nothing returns boolean
        local integer but= (UserInterface__ClickedButton) // INLINED!!
        local player p= (UserInterface__ClickingPlayer) // INLINED!!
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        local integer slot=  s__UIButton_customValue[but]
        local integer itemId= 0
        local integer icon= 0
        local integer last= InvPlayerLastSlot[s__Inventory_pid[inv]] - 1
        local integer lastItemId
        local integer lastItem
        local integer lastButton= InvPlayerLastButton[s__Inventory_pid[inv]]

        if ( s__User_Local == p ) then
            call SelectUnit(s__UIButton_picture[but], false)
            call SelectUnit(s__Inventory_owner[inv], true)
        endif
        
        if ( InvButtonDisabled[but] ) then
            return false
        endif
        
        // sell item
        if ( but == s__Inventory_btnSell[s__Inventory_pid[inv]] ) then
            set last=InvPlayerLastSlot[s__Inventory_pid[inv]] - 1
            
            if ( last < 0 ) then
                return false
            endif
            
           if ( p != s__User_handle[(s__Inventory_pid[inv])] ) then
                return false
            endif
            
            // run onSell event
            set InvEventPlayer=s__User_handle[(s__Inventory_pid[inv])]
            set InvEventItem=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last))) // INLINED!!
            set InvEventSlot=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
            
            if ( s__Inventory_onSell != null and TriggerEvaluate(s__Inventory_onSell) ) then
                call TriggerExecute(s__Inventory_onSell)
            endif
            
            call DisableButtonIfUsingTimer(but , 2)
            
            return false
        elseif ( but == s__Inventory_btnDrop[s__Inventory_pid[inv]] ) then
            set last=InvPlayerLastSlot[s__Inventory_pid[inv]] - 1
            
            if ( last < 0 ) then
                return false
            endif
            
           if ( p != s__User_handle[(s__Inventory_pid[inv])] ) then
                return false
            endif
            
            // run onSell event
            set InvEventPlayer=s__User_handle[(s__Inventory_pid[inv])]
            set InvEventItem=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last))) // INLINED!!
            set InvEventSlot=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
            
            if ( s__Inventory_onDrop != null and TriggerEvaluate(s__Inventory_onDrop) ) then
                call TriggerExecute(s__Inventory_onDrop)
                return false
            endif
            
            call DisableButtonIfUsingTimer(but , 2)
        elseif ( but == s__Inventory_btnPageDown[s__Inventory_pid[inv]] ) then
           if ( p != s__User_handle[(s__Inventory_pid[inv])] ) then
                return false
            endif
        
            set s__Inventory_currentPage[inv]=s__Inventory_currentPage[inv] + 1
            call s__Inventory_show(inv,true , s__Inventory_camera[inv])
            call DisableButtonIfUsingTimer(but , .6)
            return false
        elseif ( but == s__Inventory_btnPageUp[s__Inventory_pid[inv]] ) then
           if ( p != s__User_handle[(s__Inventory_pid[inv])] ) then
                return false
            endif
            
            set s__Inventory_currentPage[inv]=s__Inventory_currentPage[inv] - 1
            call s__Inventory_show(inv,true , s__Inventory_camera[inv])
            call DisableButtonIfUsingTimer(but , .6)
            return false
        else
            call s__UIPicture_show(s__Inventory_selector[s__Inventory_pid[inv]],true , s__Inventory_camera[inv])
            call s__UIPicture_setPosition(s__Inventory_selector[pid],s__UIButton_centerx[but] - 0.004 , s__UIButton_centery[but] + 0.0262)
            call s__UIPicture_showPlayer(s__Inventory_selector[pid],Player(pid) , true , s__Inventory_camera[inv])
        endif

        if ( p != s__User_handle[(s__Inventory_pid[inv])] ) then
            return false
        endif
        
        if ( last + 1 != slot ) then
            call s__Inventory_showLines(inv,s__Inventory_pid[inv] , false , s__Inventory_camera[inv])
        endif
        
        call TriggerExecute(s__Inventory_ExecL)
        
        // get item in slot
        set itemId=s__InvItem_id[(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot)))] // INLINED!!
        
         // check for switch
        if ( last + 1 != 0 ) then

            call SetUnitVertexColor(s__UIButton_picture[lastButton], 255, 255, 255, 255)
            call SetUnitVertexColor(s__UIButton_picture[but], 255, 255, 255, 255)
            
            set InvPlayerLastSlot[s__Inventory_pid[inv]]=0
            set InvPlayerLastButton[s__Inventory_pid[inv]]=but
                
            if ( itemId == 0 ) then
                set last=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
                
                set lastItem=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (last))) // INLINED!!
            
                set lastItemId=s__InvItem_id[lastItem]
                
                set s__InvItem_tempCustomId[lastItem]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (last))) // INLINED!!
            
                call s__Inventory_setItem(inv,( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot , lastItem)
                call s__Inventory_setItem(inv,last , 0)
                
                call DisableButtonIfUsingTimer(but , 2)
            elseif ( s__InvItem_isSocket[(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last)))] ) then // INLINED!!
                
                set last=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
                
                set lastItem=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (last))) // INLINED!!
                set s__InvItem_tempCustomId[lastItem]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (last))) // INLINED!!
                set slot=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot
                
                if ( s__Equipment_onSocket != null ) then
                    if ( (LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[(lastItem)], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)) <= s__InvItem_maxSockets[lastItem] ) then // INLINED!!
                        set SocketInv=inv
                        set SocketLast=last
                        set SocketSlot=slot
                        
                        if ( not s__InvItem_isSocket[(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot)))] and s__Equipment_onSocket != null and TriggerEvaluate(s__Equipment_onSocket) ) then // INLINED!!
                            call TriggerExecute(s__Equipment_onSocket)
                            return false
                        endif
                    endif
                else
                    set s__InvItem_tempCustomId[(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot)))]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (slot))) // INLINED!!
                    
                    if ( s__InvItem_addSocket((LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot))),lastItem) ) then // INLINED!!
                        call s__Inventory_setItem(inv,last , 0)
                    endif
                endif
    
            endif
        else //if (itemId != 0) then
            set InvPlayerLastSlot[s__Inventory_pid[inv]]=0
            set InvPlayerLastButton[s__Inventory_pid[inv]]=but
        endif
        
        if ( itemId == 0 or InvPlayerLastSlot[s__Inventory_pid[inv]] != 0 ) then
        else
            set InvPlayerLastSlot[s__Inventory_pid[inv]]=slot + 1
        endif
        
        if ( but != lastButton ) then
            call SetUnitVertexColor(s__UIButton_picture[lastButton], 255, 255, 255, 255)
            call SetUnitVertexColor(s__UIButton_picture[but], 175, 175, 175, 255)
        endif
        
        if ( itemId > 0 ) then
            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[(inv)]]], (GetObjectName(itemId)), 10 * 0.0023) // INLINED!!
            

                set s__InvItem_tempCustomId[(LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), ((itemId))))]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot))) // INLINED!!

                call s__InvItem_buildDescription((LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), ((itemId)))),s__Inventory_owner[inv]) // INLINED!!



            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxCost[s__Inventory_pid[(inv)]]], ("|cffffcc00" + I2S(s__InvItem_cost[(LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), ((itemId))))]) + "|r"), 8 * 0.0023) // INLINED!!
            
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[(inv)]],(s__Inventory_localInt(s__Inventory_pid[inv] , GetItemIcon(itemId) , s__Inventory_ICON_TRANSPARENT))) // INLINED!!
        endif
        
        set s__Inventory_TOOLTIP_X=s__UIButton_minx[but] - 0.4
        set s__Inventory_TOOLTIP_Y=s__UIButton_maxy[but] + 0.4
        
        call s__Inventory_showTooltip(inv , itemId > 0)
        
        return false
    endfunction

    function InventoryCore___RClickItemSlot takes nothing returns boolean
        local integer but= (UserInterface__ClickedButton) // INLINED!!
        local player p= (UserInterface__ClickingPlayer) // INLINED!!
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        
        local integer slot=  s__UIButton_customValue[but]
        local integer itemId
 
        if ( p != s__User_handle[(s__Inventory_pid[inv])] ) then
            return false
        endif
        
        call TriggerExecute(s__Inventory_ExecR)
        
        set slot=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot

        set itemId=s__InvItem_id[(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot)))] // INLINED!!

        if ( itemId == 0 ) then
            return false
        endif
        
        call s__Inventory_showTooltip(inv , false)
        
        
        
        return false
    endfunction
    
    function InventoryCore___Init takes nothing returns nothing
        set InvFuncLClickSlot=Filter(function InventoryCore___LClickItemSlot)
        set InvFuncRClickSlot=Filter(function InventoryCore___RClickItemSlot)
    endfunction
    


    
    function GetUnitBodySize takes unit whichUnit returns real
        return 100. // Other example: return LoadReal(hash, GetHandleId(whichUnit), KEY_UNIT_BODY_SIZE)
    endfunction

    
    function GetDestructableHeight takes destructable d returns real
        return GetDestructableOccluderHeight(d) // Other example: return 100.
    endfunction

    
    function GetItemHeight takes item i returns real
        return 16.
    endfunction
    
    
    function Missile__ToogleUnitIndexer takes boolean enable returns boolean
        local boolean prev= true
        // set UnitIndexer.enabled = enable
        return prev
    endfunction
    


// Hello and welcome to Missile.
// I wrote a guideline for every piece of code inside Missile, so you 
// can easily understand how the it gets compiled and evaluated.
//
// Let's go!
        
    
    function Missile_GetLocZ takes real x,real y returns real
        call MoveLocation(Missile__LOC, x, y)
        return GetLocationZ(Missile__LOC)
    endfunction
    
    // For WRITE_DELAYED_MISSILE_RECYCLING = true Missile will hold back
    // dummies for DELAYED_MISSILE_DEATH_ANIMATION_TIME before they are recylced. ( Code placed in a static if )
    //
//textmacro instance: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")


     
            function s__Missile__RecycleBin_onPeriodic takes nothing returns nothing
                local integer dex= 0
                loop
                    exitwhen dex == s__Missile__RecycleBin_max
                    set s__Missile__RecycleBin_time[dex]=s__Missile__RecycleBin_time[dex] - 1
                    if 0 >= s__Missile__RecycleBin_time[dex] then
                    

                            call RecycleMissile(s__Missile__RecycleBin_dummy[dex])
                    









                    
                        set s__Missile__RecycleBin_dummy[dex]=null
                        set s__Missile__RecycleBin_max=s__Missile__RecycleBin_max - 1
                        set s__Missile__RecycleBin_dummy[dex]=s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]
                        set s__Missile__RecycleBin_time[dex]=s__Missile__RecycleBin_time[s__Missile__RecycleBin_max]
                        set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]=null
                        set dex=dex - 1
                    
                        if 0 == s__Missile__RecycleBin_max then
                            call PauseTimer(s__Missile__RecycleBin_t)
                        endif
                    
                    endif
                    set dex=dex + 1
                endloop
            endfunction
    
            function s__Missile__RecycleBin_recycle takes unit toRecycle returns nothing
                if 0 == s__Missile__RecycleBin_max then
                    call TimerStart(s__Missile__RecycleBin_t, 1., true, function s__Missile__RecycleBin_onPeriodic)
                endif
                set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]=toRecycle
                set s__Missile__RecycleBin_time[s__Missile__RecycleBin_max]=Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME + TimerGetRemaining(s__Missile__RecycleBin_t)

                    // The existing bin advances in whole seconds; allow its next tick.
                    call s__MissileStats_delay(toRecycle , Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME + 1.)

                set s__Missile__RecycleBin_max=s__Missile__RecycleBin_max + 1
            endfunction
    

//end of: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
    
    // The code of WRITE_MISSILE_POSITION_CODE boxes a missiles position and does the required trigonometry.
    //
//textmacro instance: WRITE_MISSILE_POSITION_CODE()
            
            // Readonly members you can access.
            
            // Creates an origin - impact link.
            
            function s__MissilePosition_math takes integer a,integer b returns nothing
                local real dx
                local real dy
                loop
                    set dx=s__MissilePosition_x[b] - s__MissilePosition_x[a]
                    set dy=s__MissilePosition_y[b] - s__MissilePosition_y[a]
                    set dx=dx * dx + dy * dy
                    set dy=SquareRoot(dx)
                    exitwhen dx != 0. and dy != 0.
                    set s__MissilePosition_x[b]=s__MissilePosition_x[b] + .01
                    set s__MissilePosition_z[b]=s__MissilePosition_z[b] - Missile_GetLocZ(s__MissilePosition_x[b] - .01 , s__MissilePosition_y[b]) + Missile_GetLocZ(s__MissilePosition_x[b] , s__MissilePosition_y[b])
                endloop
                
                set s__MissilePosition_square[a]=dx
                set s__MissilePosition_distance[a]=dy
                set s__MissilePosition_angle[a]=Atan2(s__MissilePosition_y[b] - s__MissilePosition_y[a], s__MissilePosition_x[b] - s__MissilePosition_x[a])
                set s__MissilePosition_slope[a]=( s__MissilePosition_z[b] - s__MissilePosition_z[a] ) / dy
                set s__MissilePosition_alpha[a]=Atan(s__MissilePosition_slope[a]) * bj_RADTODEG
                // Set b.
                if s__MissilePosition_ref[b] == a then
                    set s__MissilePosition_angle[b]=s__MissilePosition_angle[a] + bj_PI
                    set s__MissilePosition_distance[b]=dy
                    set s__MissilePosition_slope[b]=- s__MissilePosition_slope[a]
                    set s__MissilePosition_alpha[b]=- s__MissilePosition_alpha[a]
                    set s__MissilePosition_square[b]=dx
                endif
            endfunction
            
            function s__MissilePosition_link takes integer a,integer b returns nothing
                set s__MissilePosition_ref[a]=b
                set s__MissilePosition_ref[b]=a
                call s__MissilePosition_math(a , b)
            endfunction
    
            function s__MissilePosition_move takes integer this,real toX,real toY,real toZ returns nothing
                set s__MissilePosition_x[this]=toX
                set s__MissilePosition_y[this]=toY
                set s__MissilePosition_z[this]=toZ + Missile_GetLocZ(toX , toY)
                if s__MissilePosition_ref[this] != this then
                    call s__MissilePosition_math(this , s__MissilePosition_ref[this])
                endif
            endfunction
    
            function s__MissilePosition_destroy takes integer this returns nothing
                set s__MissilePosition_recycler[this]=s__MissilePosition_recycler[0]
                set s__MissilePosition_recycler[0]=this
            endfunction
    
            function s__MissilePosition_create takes real x,real y,real z returns integer
                local integer this= s__MissilePosition_recycler[0]
                 if 0 == this then
                    set s__MissilePosition_alloc=s__MissilePosition_alloc + 1
                    set this=s__MissilePosition_alloc
                else
                    set s__MissilePosition_recycler[0]=s__MissilePosition_recycler[this]
                endif
                set s__MissilePosition_ref[this]=this
                call s__MissilePosition_move(this,x , y , z)
                return this
            endfunction
    
//end of: WRITE_MISSILE_POSITION_CODE()
    
    // Missiles structure works like a linked list with the folling methods:
    // allocateCollection(), allocateNode(), insertFront(node) and remove()
    //
//Implemented from module Missile__MissileStructure:
        

// NO_DEBUG:             debug private boolean isNode
// NO_DEBUG:             debug private boolean isCollection

        
        function s__Missile__get_list takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "list", "thistype", this, "Attempted To Read Null Node.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "list", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile__MissileStructure___list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "next", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile__MissileStructure___next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "prev", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile__MissileStructure___prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,        "MissileStructure", "first", "thistype", this, "Attempted To Read Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "MissileStructure", "first", "thistype", this, "Attempted To Read Invalid List.")

            return s__Missile_Missile__MissileStructure___first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,        "MissileStructure", "last", "thistype", this, "Attempted To Read Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "MissileStructure", "last", "thistype", this, "Attempted To Read Invalid List.")

            return s__Missile_Missile__MissileStructure___last[this]
        endfunction
        
        function s__Missile_allocateCollection takes nothing returns integer
            local integer this= s__Missile_Missile__MissileStructure___first[(0)]
            
            if ( 0 == this ) then

// NO_DEBUG:                     debug call ThrowError(collectionCount == 8191, "MissileStructure", "allocateCollection", "thistype", 0, "Overflow.")

                
                set this=s__Missile_Missile__MissileStructure__collectionCount + 1
                set s__Missile_Missile__MissileStructure__collectionCount=this
            else
                set s__Missile_Missile__MissileStructure___first[(0)]=s__Missile_Missile__MissileStructure___first[this]
            endif
            

// NO_DEBUG:                 debug set isCollection = true

            
            set s__Missile_Missile__MissileStructure___first[this]=0
            
            return this
        endfunction
        
        function s__Missile_allocateNode takes nothing returns integer
            local integer this= s__Missile_Missile__MissileStructure___next[(0)]
            
            if ( 0 == this ) then

// NO_DEBUG:                     debug call ThrowError(nodeCount == 8191, "MissileStructure", "allocateNode", "thistype", 0, "Overflow.")

                
                set this=s__Missile_Missile__MissileStructure__nodeCount + 1
                set s__Missile_Missile__MissileStructure__nodeCount=this
            else
                set s__Missile_Missile__MissileStructure___next[(0)]=s__Missile_Missile__MissileStructure___next[this]
            endif
            
            set s__Missile_allocated[this]=true
            
            return this
        endfunction
        
        function s__Missile_insertFront takes integer this,integer node returns integer
            
            // Extra static unique list for missile motion.
            set Missile__nextNode[node]=0
            set Missile__prevNode[node]=Missile__prevNode[0]
            set Missile__nextNode[Missile__prevNode[0]]=node
            set Missile__prevNode[0]=node
            

// NO_DEBUG:                 debug call ThrowError(this == 0,        "List", "push", "thistype", this, "Attempted To Push On To Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "List", "push", "thistype", this, "Attempted To Push On To Invalid List.")
// NO_DEBUG:                 debug set node.isNode = true

            
            set s__Missile_Missile__MissileStructure___list[node]=this
        
            if ( s__Missile_Missile__MissileStructure___first[this] == 0 ) then
                set s__Missile_Missile__MissileStructure___first[this]=node
                set s__Missile_Missile__MissileStructure___last[this]=node
                set s__Missile_Missile__MissileStructure___next[node]=0
            else
                set s__Missile_Missile__MissileStructure___prev[s__Missile_Missile__MissileStructure___first[this]]=node
                set s__Missile_Missile__MissileStructure___next[node]=s__Missile_Missile__MissileStructure___first[this]
                set s__Missile_Missile__MissileStructure___first[this]=node
            endif
            
            set s__Missile_Missile__MissileStructure___prev[node]=0
            
            return node
        endfunction
      
        function s__Missile_Missile__remove takes integer this returns nothing
            local integer node= this
            set this=s__Missile_Missile__MissileStructure___list[node]
            

// NO_DEBUG:                 debug call ThrowError(node == 0,        "MissileStructure", "remove", "thistype", this, "Attempted To Remove Null Node.")
// NO_DEBUG:                 debug call ThrowError(not node.isNode,  "MissileStructure", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
// NO_DEBUG:                 debug set node.isNode = false

            
            set s__Missile_Missile__MissileStructure___list[node]=0
        
            if ( 0 == s__Missile_Missile__MissileStructure___prev[node] ) then
                set s__Missile_Missile__MissileStructure___first[this]=s__Missile_Missile__MissileStructure___next[node]
            else
                set s__Missile_Missile__MissileStructure___next[s__Missile_Missile__MissileStructure___prev[node]]=s__Missile_Missile__MissileStructure___next[node]
            endif
            if ( 0 == s__Missile_Missile__MissileStructure___next[node] ) then
                set s__Missile_Missile__MissileStructure___last[this]=s__Missile_Missile__MissileStructure___prev[node]
            else
                set s__Missile_Missile__MissileStructure___prev[s__Missile_Missile__MissileStructure___next[node]]=s__Missile_Missile__MissileStructure___prev[node]
            endif
            
            set s__Missile_Missile__MissileStructure___next[node]=s__Missile_Missile__MissileStructure___next[(0)]
            set s__Missile_Missile__MissileStructure___next[(0)]=node
            
            set s__Missile_allocated[node]=false
            
            // Static unique list for missile motion.
            set Missile__nextNode[Missile__prevNode[node]]=Missile__nextNode[node]
            set Missile__prevNode[Missile__nextNode[node]]=Missile__prevNode[node]
        endfunction

        // Constants:
        // ==========
        //
        // Attach point name for effects created by model=. 
        
        // Set a ficitional hit box in range of 0 to 1,
        // while 0 is the toe and 1 the head of a unit.
        
        // DEBUG_MODE only members:
        // ========================
        //
        // Checks for double launching. Throws an error message. 
// NO_DEBUG:         debug boolean launched 
// NO_DEBUG: 
        // Private members:
        // ================
        //        
        // The position of a missile using curve= does not
        // match the position used by Missile's trigonometry.
        // Therefore we need this member two times.
        // Readable x / y / z for your needs and posX / posY for cool mathematics.
        
        // Readonly members:
        // =================
        //
        // Prevents a double free case.
        
        // The dummy unit.
        
        // Position members for your needs.
        
        // Collision detection type. ( Evaluated new in each loop )
        
        // Members you can set:
        // ====================
        //

        // Setting collision z is deprecated since Missile v2.5. 
        function s__Missile__set_collisionZ takes integer this,real value returns nothing
        endfunction
        function s__Missile__get_collisionZ takes integer this returns real
            return s__Missile_collision[this]
        endfunction
        
        // Operator overloading:
        // =====================
        //
        // Special effect on the missile dummy. For multiple effect attaching, access unit "dummy" directly.
        function s__Missile__set_model takes integer this,string file returns nothing
            if s__Missile_sfx[this] != null then
                call DestroyEffect(s__Missile_sfx[this])
                set s__Missile_sfx[this]=null
            endif
                                    // null and ""
            if StringLength(file) > 0 then
                set s__Missile_sfx[this]=AddSpecialEffectTarget(file, s__Missile_dummy[this], s__Missile_ORIGIN)
                set s__Missile_path[this]=file
            else
                set s__Missile_path[this]=null
            endif
        endfunction
        function s__Missile__get_model takes integer this returns string
            return s__Missile_path[this]
        endfunction
       
       // Enables curved movement for your missile. 
       // Remember that the result of Tan(PI/2) is infinity.
        function s__Missile__set_curve takes integer this,real value returns nothing
            set s__Missile_open[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]]
        endfunction
        function s__Missile__get_curve takes integer this returns real
            return Atan(s__Missile_open[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        // Enables arcing movement for your missile.
        function s__Missile__set_arc takes integer this,real value returns nothing
            set s__Missile_height[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]] / 4
        endfunction
        function s__Missile__get_arc takes integer this returns real
            return Atan(4 * s__Missile_height[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        function s__Missile__set_scale takes integer this,real value returns nothing
            call SetUnitScale(s__Missile_dummy[this], value, 0., 0.)
            set s__Missile_scaling[this]=value
        endfunction
        function s__Missile__get_scale takes integer this returns real
            return s__Missile_scaling[this]
        endfunction
        
        // Methods:
        // ========
        //
        function s__Missile_bounce takes integer this returns nothing
            call s__MissilePosition_move(s__Missile_origin[this],s__Missile_x[this] , s__Missile_y[this] , s__Missile_z[this])
            set s__Missile_dist[this]=0.
        endfunction
       
        function s__Missile_deflect takes integer this,real tx,real ty returns nothing
            local real a= 2. * Atan2(ty - s__Missile_y[this], tx - s__Missile_x[this]) + bj_PI - s__Missile_angle[this]
            call s__MissilePosition_move(s__Missile_impact[this],s__Missile_x[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_dist[this] ) * Cos(a) , s__Missile_y[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_dist[this] ) * Sin(a) , s__MissilePosition_z[s__Missile_impact[this]])
            call s__Missile_bounce(this)
        endfunction
        
        function s__Missile_deflectEx takes integer this,real tx,real ty,real tz returns nothing
            call s__MissilePosition_move(s__Missile_impact[this],s__MissilePosition_x[s__Missile_impact[this]] , s__MissilePosition_y[s__Missile_impact[this]] , tz)
            call s__Missile_deflect(this,tx , ty)
        endfunction
    
        function s__Missile_flightTime2Speed takes integer this,real duration returns nothing
            set s__Missile_speed[this]=RMaxBJ(0.00000001, ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_dist[this] ) * Missile_TIMER_TIMEOUT / RMaxBJ(0.00000001, duration))
        endfunction
        
        function s__Missile_setMovementSpeed takes integer this,real value returns nothing
            set s__Missile_speed[this]=value * Missile_TIMER_TIMEOUT
        endfunction
    
        function s__Missile_destroy takes integer this returns nothing
            set s__Missile_wantDestroy[this]=true
        endfunction

        // Instantly destroys a missile.
        function s__Missile_terminate takes integer this returns nothing
            if s__Missile_allocated[this] then

                    call s__MissileStats_released(this)

                call s__Missile_Missile__remove(this)
                call s__MissilePosition_destroy(s__Missile_impact[this])
                call s__MissilePosition_destroy(s__Missile_origin[this])
            
                call DestroyEffect(s__Missile_sfx[this])
                call FlushChildHashtable(Missile__HASH, this)
                if GetUnitTypeId(s__Missile_dummy[this]) == Missile_DUMMY_UNIT_ID then
                    // MissileRecycler > Dummy > xe.

                        call RecycleMissile(s__Missile_dummy[this])







                endif
                set s__Missile_sfx[this]=null
                set s__Missile_source[this]=null
                set s__Missile_target[this]=null
                set s__Missile_dummy[this]=null
                set s__Missile_owner[this]=null
            endif
        endfunction
        
        // Runs in createEx.
    
        // Launches a dummy of your choice.
        function s__Missile_createEx takes unit missileDummy,real impactX,real impactY,real impactZ returns integer
            local integer this= s__Missile_allocateNode()
            local real originX= GetUnitX(missileDummy)
            local real originY= GetUnitY(missileDummy)
            local real originZ= GetUnitFlyHeight(missileDummy)
            //
//textmacro instance: MISSILE_RESET_ALL_MEMBERS()
            set s__Missile_path[this]=null
            set s__Missile_speed[this]=0.
            set s__Missile_acceleration[this]=0.
            set s__Missile_distance[this]=0.
            set s__Missile_dist[this]=0
            set s__Missile_dist[this]=0.
            set s__Missile_height[this]=0.
            set s__Missile_turn[this]=0.
            set s__Missile_open[this]=0.
            set s__Missile_collision[this]=0.
            set s__Missile_collisionType[this]=0
            set s__Missile_stackSize[this]=0
            set s__Missile_scaling[this]=1.
            set s__Missile_wantDestroy[this]=false
            set s__Missile_recycle[this]=false
//end of: MISSILE_RESET_ALL_MEMBERS()
            //
            set s__Missile_origin[this]=s__MissilePosition_create(originX , originY , originZ)
            set s__Missile_impact[this]=s__MissilePosition_create(impactX , impactY , impactZ)
            call s__MissilePosition_link(s__Missile_origin[this] , s__Missile_impact[this])
                        
            set s__Missile_posX[this]=originX
            set s__Missile_posY[this]=originY
            set s__Missile_x[this]=originX
            set s__Missile_y[this]=originY
            set s__Missile_z[this]=originZ
            set s__Missile_angle[this]=s__MissilePosition_angle[s__Missile_origin[this]]
            set s__Missile_dummy[this]=missileDummy
            
            call SetUnitFlyHeight(missileDummy, originZ, 0.)
            call SaveUnitHandle(Missile__HASH, this, GetHandleId(missileDummy), missileDummy)
            //

// NO_DEBUG:                 debug call ThrowWarning(GetUnitTypeId(missileDummy) == 0, "Missile", "createEx", "missileDummy", this, "Invalid missile dummy unit ( null )!")

// NO_DEBUG:             debug set launched = false

                call s__MissileStats_allocated(this)

            return this
        endfunction
    
        // Freaky static if ensures these libraries really don't exist.













    
        // MissileRecylcer > Dummy > xe > Missile.
    
        // Wrapper to createEx.
        function s__Missile_create takes real x,real y,real z,real angle,real distance,real impactZ returns integer
            local real impactX= x + distance * Cos(angle)
            local real impactY= y + distance * Sin(angle)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()

                return s__Missile_createEx(GetRecycledMissile(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
        













//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
        
        // Wrapper to createEx.
        function s__Missile_createXYZ takes real x,real y,real z,real impactX,real impactY,real impactZ returns integer
            local real angle= Atan2(impactY - y, impactX - x)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()

                return s__Missile_createEx(GetRecycledMissile(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
        













//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
    
        // Missile motion takes place every Missile_TIMER_TIMEOUT
        // before accessing each active struct.
        function s__Missile_move takes nothing returns boolean
            local integer loops= 0
            local integer limit= 150
            local integer this= s__Missile_temp
            
            local integer p
            local real a
            local real d
            local unit u
            local real newX
            local real newY
            local real vel
            local real point
            local real pitch
            loop
                exitwhen 0 == this or loops == limit
                set p=s__Missile_origin[this]
                
                // Save previous, respectively current missile position.
                set s__Missile_prevX[this]=s__Missile_x[this]
                set s__Missile_prevY[this]=s__Missile_y[this]
                set s__Missile_prevZ[this]=s__Missile_z[this]
                
                // Evaluate the collision type.
                set vel=s__Missile_speed[this]
                set s__Missile_speed[this]=vel + s__Missile_acceleration[this]
                if vel < s__Missile_collision[this] * Missile_COLLISION_ACCURACY_FACTOR then
                    set s__Missile_collisionType[this]=Missile_COLLISION_TYPE_CIRCLE
                else
                    set s__Missile_collisionType[this]=Missile_COLLISION_TYPE_RECTANGLE
                endif
                
                // Update missile guidance to its intended target.
                set u=s__Missile_target[this]
                if u != null then
                    if 0 == GetUnitTypeId(u) then
                        set s__Missile_target[this]=null
                    else
                        call s__MissilePosition_move(s__Missile_origin[this],s__Missile_x[this] , s__Missile_y[this] , s__Missile_z[this])
                        call s__MissilePosition_move(s__Missile_impact[this],GetUnitX(u) , GetUnitY(u) , GetUnitFlyHeight(u) + GetUnitBodySize(u) * s__Missile_HIT_BOX)
                        set s__Missile_dist[this]=0
                        set s__Missile_height[this]=0
                        call s__Missile__set_curve(this,0)
                    endif
                endif
                set a=s__MissilePosition_angle[p]
                
                // Update the missile facing angle depending on the turn ratio.
                if 0. != s__Missile_turn[this] and Cos(s__Missile_angle[this] - a) < Cos(s__Missile_turn[this]) then
                    if 0. > Sin(a - s__Missile_angle[this]) then
                        set s__Missile_angle[this]=s__Missile_angle[this] - s__Missile_turn[this]
                    else
                        set s__Missile_angle[this]=s__Missile_angle[this] + s__Missile_turn[this]
                    endif
                else
                    set s__Missile_angle[this]=a
                endif
                
                // Update the missile position on the parabola.
                set d=s__MissilePosition_distance[p] // origin - impact distance.
                
                set s__Missile_recycle[this]=s__Missile_dist[this] + vel >= d
                if s__Missile_recycle[this] then // Maximum distance reached. 
                    set point=d
                    set s__Missile_distance[this]=s__Missile_distance[this] + d - s__Missile_dist[this]
                else
                    set s__Missile_distance[this]=s__Missile_distance[this] + vel
                    set point=s__Missile_dist[this] + vel
                endif
                set s__Missile_dist[this]=point
                
                set newX=s__Missile_posX[this] + vel * Cos(s__Missile_angle[this])
                set newY=s__Missile_posY[this] + vel * Sin(s__Missile_angle[this])
                set s__Missile_posX[this]=newX
                set s__Missile_posY[this]=newY
                
                // Update point(x/y) if a curving trajectory is defined.
                set u=s__Missile_dummy[this]
                if 0. != s__Missile_open[this] and s__Missile_target[this] == null then
                    set vel=4 * s__Missile_open[this] * point * ( d - point ) / s__MissilePosition_square[p]
                    set a=s__Missile_angle[this] + bj_PI / 2
                    set newX=newX + vel * Cos(a)
                    set newY=newY + vel * Sin(a)
                    set a=s__Missile_angle[this] + Atan(- ( ( 4 * s__Missile_open[this] ) * ( 2 * point - d ) ) / s__MissilePosition_square[p])
                else
                    set a=s__Missile_angle[this]
                endif
                set s__Missile_x[this]=newX
                set s__Missile_y[this]=newY
                
                // Update pos z if an arc or height is set.
                call MoveLocation(Missile__LOC, newX, newY)
                set s__Missile_terrainZ[this]=GetLocationZ(Missile__LOC)
                set pitch=s__MissilePosition_alpha[p]
                if 0. == s__Missile_height[this] and 0. == pitch then
                    set s__Missile_z[this]=s__MissilePosition_z[p] - s__Missile_terrainZ[this]
                else
                    set s__Missile_z[this]=s__MissilePosition_z[p] - s__Missile_terrainZ[this] + s__MissilePosition_slope[p] * point
                    if 0. != s__Missile_height[this] and s__Missile_target[this] == null then
                        set s__Missile_z[this]=s__Missile_z[this] + ( 4 * s__Missile_height[this] * point * ( d - point ) / s__MissilePosition_square[p] )
                        set pitch=pitch - Atan(( ( 4 * s__Missile_height[this] ) * ( 2 * point - d ) ) / s__MissilePosition_square[p]) * bj_RADTODEG
                    endif
                endif
                // Update the pitch angle of the dummy unit. 
                if GetUnitTypeId(u) == Missile_DUMMY_UNIT_ID then
                    call SetUnitAnimationByIndex(u, R2I(pitch + 90.5))
                endif
                
                // Move the missile dummy via native.
                call SetUnitFlyHeight(u, s__Missile_z[this], 0.)
                call SetUnitFacing(u, a * bj_RADTODEG)
                
                // WorldBounds > BoundSentinel.






                    if newX < s__WorldBounds_maxX and newX > s__WorldBounds_minX and newY < s__WorldBounds_maxY and newY > s__WorldBounds_minY then
                        call SetUnitX(u, newX)
                        call SetUnitY(u, newY)
                    endif




                
                set loops=loops + 1
                set this=Missile__nextNode[this]
            endloop
            
            set u=null
            set s__Missile_temp=this
            return this == 0
        endfunction
            
        // Widget collision API:
        // =====================
        //
        // Runs automatically on widget collision.
        function s__Missile_hitWidget takes integer this,widget w returns nothing
            if w != null then
                call SaveWidgetHandle(Missile__HASH, this, GetHandleId(w), w)
            endif
        endfunction
        
        // All widget which have been hit return true.
        function s__Missile_hasHitWidget takes integer this,widget w returns boolean
            return HaveSavedHandle(Missile__HASH, this, GetHandleId(w))
        endfunction
        
        // Removes a widget from the missile's memory of hit widgets. ( This widget can be hit again )
        function s__Missile_removeHitWidget takes integer this,widget w returns nothing
            if w != null then
                call RemoveSavedHandle(Missile__HASH, this, GetHandleId(w))
            endif
        endfunction
        
        // Flushes a missile's memory for collision. ( All widgets can be hit again )
        function s__Missile_flushHitWidgets takes integer this returns nothing
            call FlushChildHashtable(Missile__HASH, this)
            call s__Missile_hitWidget(this,s__Missile_dummy[this])
        endfunction
        
        // Tells missile to call removeHitWidget(w) after "seconds" time.
        // Does not apply to widgets, which are already hit by this missile.
        function s__Missile_enableHitAfter takes integer this,widget w,real seconds returns nothing
            local integer id= GetHandleId(w)
            if w != null then
                if not HaveSavedInteger(Missile__HASH, this, id) then
                    call SaveInteger(Missile__HASH, this, id, s__Missile_stackSize[this])
                    call SaveInteger(Missile__HASH, this, s__Missile_stackSize[this], id)
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] + 1
                endif
                call SaveReal(Missile__HASH, this, id, seconds) // Set time.
            endif
        endfunction
        
        function s__Missile_updateStack takes integer this returns nothing
            local integer dex= 0
            local integer id
            local real time
            loop
                exitwhen dex == s__Missile_stackSize[this]
                set id=LoadInteger(Missile__HASH, this, dex)
                set time=LoadReal(Missile__HASH, this, id) - Missile_TIMER_TIMEOUT
                if time <= 0. or not HaveSavedHandle(Missile__HASH, this, id) then
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] - 1
                    set id=LoadInteger(Missile__HASH, this, s__Missile_stackSize[this])
                    call SaveInteger(Missile__HASH, this, dex, id)
                    call SaveInteger(Missile__HASH, this, id, dex)
                    // Enables hit.
                    call RemoveSavedHandle(Missile__HASH, this, id)
                    // Remove data from stack.
                    call RemoveSavedReal(Missile__HASH, this, id)
                    call RemoveSavedInteger(Missile__HASH, this, id)
                    call RemoveSavedInteger(Missile__HASH, this, s__Missile_stackSize[this])
                else
                    call SaveReal(Missile__HASH, this, id, time)
                    set dex=dex + 1
                endif
            endloop
        endfunction
    
        // Widget collision code:
        // ======================
        //
        //
        // 1.) Rectangle collision for fast moving missiles with small collision radius.
        //        
        // Runs for destructables and items in a rectangle.
        // Checks if widget w is in collision range of a missile.
        // Is not precise in z - axis collision.
        function s__Missile_isWidgetInRectangle takes integer this,widget w,real wz,real distance returns boolean
            local real wx= GetWidgetX(w)
            local real wy= GetWidgetY(w)
            local real dz= Missile_GetLocZ(wx , wy) - s__Missile_terrainZ[this]
            local real dx= s__Missile_x[this] - s__Missile_prevX[this]
            local real dy= s__Missile_y[this] - s__Missile_prevY[this]
            local real s= ( dx * ( wx - s__Missile_prevX[this] ) + dy * ( wy - s__Missile_prevY[this] ) ) / ( dx * dx + dy * dy )
            
            if s < 0. then
                set s=0.
            elseif s > 1 then
                set s=1.
            endif
            set dx=( s__Missile_prevX[this] + s * dx ) - wx
            set dy=( s__Missile_prevY[this] + s * dy ) - wy

            return dx * dx + dy * dy <= distance * distance and dz + wz >= s__Missile_z[this] - distance and dz <= s__Missile_z[this] + distance
        endfunction        
        //
        // 2.) Circular collision detection for all other missiles.
        //
        // Returns true for widgets in a xyz collision range. 
        function s__Missile_isWidgetInRange takes integer this,widget w,real wz,real distance returns boolean
            local real wx= GetWidgetX(w)
            local real wy= GetWidgetY(w)
            local real dz= Missile_GetLocZ(wx , wy) - s__Missile_terrainZ[this]
            //     collision in plane x and y,            collision in z axis.
            return IsUnitInRangeXY(s__Missile_dummy[this], wx, wy, distance) and dz + wz >= s__Missile_z[this] - distance and dz <= s__Missile_z[this] + distance
        endfunction        
        //
        //  3.) Action functions inside the widget enumeration thread.
        //
        // Runs for every enumerated destructable.
        //  • Directly filters out already hit destructables.
        //  • Distance formula based on the Pythagorean theorem.
        //                         
        function s__Missile_filterDests takes nothing returns boolean
            local destructable d= GetFilterDestructable()
            local boolean b= false
            if not HaveSavedHandle(Missile__HASH, s__Missile_temp, GetHandleId(d)) then
                if s__Missile_circle then
                    set b=s__Missile_isWidgetInRange(s__Missile_temp,d , (GetDestructableOccluderHeight((d))) , s__Missile_collision[s__Missile_temp]) // INLINED!!
                else
                    set b=s__Missile_isWidgetInRectangle(s__Missile_temp,d , (GetDestructableOccluderHeight((d))) , s__Missile_collision[s__Missile_temp]) // INLINED!!
                endif
            endif
            set d=null
            return b
        endfunction
        //
        // Runs for every enumerated item.
        //  • Directly filters out already hit items.
        //  • Distance formula based on the Pythagorean theorem.
        //  • Items have a fix collision size of 16.
        // 
        function s__Missile_filterItems takes nothing returns boolean
            local item i= GetFilterItem()
            local boolean b= false
            if not HaveSavedHandle(Missile__HASH, s__Missile_temp, GetHandleId(i)) then
                if s__Missile_circle then // Item in missile collision size or item pathing in missile range.
                    set b=s__Missile_isWidgetInRange(s__Missile_temp,i , GetItemHeight(i) , RMaxBJ(s__Missile_collision[s__Missile_temp], 16.))
                else
                    set b=s__Missile_isWidgetInRectangle(s__Missile_temp,i , GetItemHeight(i) , RMaxBJ(s__Missile_collision[s__Missile_temp], 16.))
                endif
            endif
            set i=null
            return b
        endfunction
        //
        //  4.) Filter function for rectangle unit collision.
        //
        // Runs for every enumerated units.
        //  • Filters out units which are not in collision range in plane x / y.
        //  • Inlined and therefore a bit faster than item and destructable collision.
        //
        function s__Missile_filterUnits takes nothing returns boolean
            local integer this= s__Missile_temp
            local unit u= GetFilterUnit()
            local real dx
            local real dy
            local real s
            local boolean is= false
            
            if not HaveSavedHandle(Missile__HASH, this, GetHandleId(u)) then
                set dx=s__Missile_x[this] - s__Missile_prevX[this]
                set dy=s__Missile_y[this] - s__Missile_prevY[this]
                set s=( dx * ( GetUnitX(u) - s__Missile_prevX[this] ) + dy * ( GetUnitY(u) - s__Missile_prevY[this] ) ) / ( dx * dx + dy * dy )
                if s < 0. then
                    set s=0.
                elseif s > 1. then
                    set s=1.
                endif
                set is=IsUnitInRangeXY(u, s__Missile_prevX[this] + s * dx, s__Missile_prevY[this] + s * dy, s__Missile_collision[this])
            endif
            
            set u=null
            return is
        endfunction
        //
        // 5.) Proper rect preparation.
        //
        // For rectangle.
        function s__Missile_prepareRectRectangle takes integer this returns nothing
            local real x1= s__Missile_prevX[this]
            local real y1= s__Missile_prevY[this]
            local real x2= s__Missile_x[this]
            local real y2= s__Missile_y[this]
            local real d= s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE
            // What is min, what is max ...
            if x1 < x2 then
                if y1 < y2 then
                    call SetRect(Missile__RECT, x1 - d, y1 - d, x2 + d, y2 + d)
                else
                    call SetRect(Missile__RECT, x1 - d, y2 - d, x2 + d, y1 + d)
                endif
            elseif y1 < y2 then
                call SetRect(Missile__RECT, x2 - d, y1 - d, x1 + d, y2 + d)
            else
                call SetRect(Missile__RECT, x2 - d, y2 - d, x1 + d, y1 + d)
            endif
        endfunction
        //
        // For circular.
        function s__Missile_prepareRectCircle takes integer this returns nothing
            local real d= s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE
            call SetRect(Missile__RECT, s__Missile_x[this] - d, s__Missile_y[this] - d, s__Missile_x[this] + d, s__Missile_y[this] + d)
        endfunction
        //
        // 5.) API for the MissileStruct iteration.
        //
        function s__Missile_groupEnumUnitsRectangle takes integer this returns nothing
            call s__Missile_prepareRectRectangle(this)
            set s__Missile_temp=this
            call GroupEnumUnitsInRect(Missile__GROUP, Missile__RECT, Missile__unitFilter)
        endfunction
        //
        // Prepares destructable enumeration, then runs enumDests.
        function s__Missile_checkDestCollision takes integer this,code func returns nothing
            set s__Missile_circle=s__Missile_collisionType[this] == Missile_COLLISION_TYPE_CIRCLE
            if s__Missile_circle then
                call s__Missile_prepareRectCircle(this)
            else
                call s__Missile_prepareRectRectangle(this)
            endif
            //
            set s__Missile_temp=this
            call EnumDestructablesInRect(Missile__RECT, Missile__destFilter, func)
        endfunction
        //
        // Prepares item enumeration, then runs enumItems.
        function s__Missile_checkItemCollision takes integer this,code func returns nothing
            set s__Missile_circle=s__Missile_collisionType[this] == Missile_COLLISION_TYPE_CIRCLE
            if s__Missile_circle then
                call s__Missile_prepareRectCircle(this)
            else
                call s__Missile_prepareRectRectangle(this)
            endif
            //
            set s__Missile_temp=this
            call EnumItemsInRect(Missile__RECT, Missile__itemFilter, func)
        endfunction


    function s__Missile_nullBefore takes integer this returns nothing
        set s__Missile_dummy[this]=null
    endfunction


// Does not check for 'Aloc' and 'Amrf' as they could be customized.
        function s__Missile_onInit takes nothing returns nothing

// NO_DEBUG:                 debug local boolean prev = Missile__ToogleUnitIndexer(false)
// NO_DEBUG:                 debug local unit dummy = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0., 0., 0.)
// NO_DEBUG:                 debug call Missile__ToogleUnitIndexer(prev)
                //
// NO_DEBUG:                 debug call ThrowError((GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "type id",    0, "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
// NO_DEBUG:                 debug call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),            "Missile", "DEBUG_MISSILE", "collision",  0, "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
// NO_DEBUG:                 debug call RemoveUnit(dummy)
// NO_DEBUG:                 debug set dummy = null

            //
            set Missile__unitFilter=Filter(function s__Missile_filterUnits)
            set Missile__destFilter=Filter(function s__Missile_filterDests)
            set Missile__itemFilter=Filter(function s__Missile_filterItems)
            call TriggerAddCondition(Missile__MOVE, Condition(function s__Missile_move))
        endfunction
        
    // You made it to the end of Missile, but we are not finished.
    // Do you remember about the data structure, the delayed recycler
    // and of course our interface module "MissileStruct"
    //
    // This comes now!
    
    // Debug code taken from List ( full credits to Nestharus )

    // Boolean expressions per struct:
    // ===============================
    //     
    // Condition function for the core trigger evaluation. ( Runs for all struct using module MissileStruct )
    function Missile__MissileCreateExpression takes integer structId,code func returns nothing
        set Missile__expression[structId]=Condition(func)
    endfunction
    
    // Creates a collection for a struct. ( Runs for all struct using module MissileStruct )
    function Missile__MissileCreateCollection takes integer structId returns nothing
        set Missile__missileList[structId]=s__Missile_allocateCollection()
    endfunction
    
    // Core:
    // =====
    //
    // Fires every Missile_TIMER_TIMEOUT.
    function Missile__Fire takes nothing returns nothing
        local integer i= Missile__remove[0]
        set Missile__remove[0]=0
        loop
            exitwhen 0 == i
            if Missile__recycling[i] then
                call TriggerRemoveCondition(Missile__CORE, Missile__condition[i])
                set Missile__condition[i]=null
                set Missile__active=Missile__active - 1
            endif
            set Missile__destroying[i]=false
            set Missile__recycling[i]=false
            set i=Missile__remove[i]
        endloop
        
        if 0 == Missile__active then
            call PauseTimer(Missile__TMR)
        else
            // Move all launched missiles.
            set s__Missile_temp=Missile__nextNode[0]
            set i=0
            loop
                exitwhen TriggerEvaluate(Missile__MOVE)
                exitwhen i == 60 // Moved over 8910 missiles, something buggy happened.
                set i=i + 1 // This case is impossible, hence never happens. But if I'm wrong, which also never happens 
            endloop // then the map 100% crashes. i == 66 will prevent the game crash and Missile will start to 
                                // to debug itself over the next iterations.
        
            // Access all structs using module MissileStruct. 





                call TriggerEvaluate(Missile__CORE)

        endif
    endfunction
    
    // Conditionally starts the timer.
    function Missile__StartPeriodic takes integer structId returns nothing
        if 0 == Missile__instances[structId] or Missile__destroying[structId] then
            if Missile__destroying[structId] then
                set Missile__recycling[structId]=false
            else
                if 0 == Missile__active then
                    call TimerStart(Missile__TMR, Missile_TIMER_TIMEOUT, true, function Missile__Fire)
                endif
                set Missile__active=Missile__active + 1
                set Missile__condition[structId]=TriggerAddCondition(Missile__CORE, Missile__expression[structId])
            endif
        endif
        set Missile__instances[structId]=Missile__instances[structId] + 1
    endfunction
    
    // Conditionally stops the timer in the next callback.
    function Missile__StopPeriodic takes integer structId returns nothing
        set Missile__instances[structId]=Missile__instances[structId] - 1
        if 0 == Missile__instances[structId] and Missile__condition[structId] != null then
            if not Missile__destroying[structId] and not Missile__recycling[structId] then
                set Missile__destroying[structId]=true
                set Missile__recycling[structId]=true
                set Missile__remove[structId]=Missile__remove[0]
                set Missile__remove[0]=structId
            endif
        endif
    endfunction
    
    // Modules:
    // ========
    //
    // You want to place module MissileLaunch at the very top of your struct.
    
    
    // Allows you to inject missile in certain stages of the motion process.
    
    
    // Missile position:
    // =================
    //
    // Simple trigonometry.
    
    // Delayed dummy recycling:
    // ========================
    //
    // Ensures proper fx death animations.
    
// The end!

////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ MovementBonus for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, and the AutoIndex library.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides one new bonus type:
//@
//@   - BONUS_MOVEMENT_SPEED
//@         Modifies a unit's movement speed. 
//@ 
//@ A unit's movement speed can never go below or above the values configured
//@ in the gameplay constants for a map.
//@ 
//@ You should not modify a unit's movement speed any way other than via
//@ BonusMod. Doing so will cause issues.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// The following constants must be equal to the equivalent gameplay constants.
// By default, these are set to the default vlues for the gameplay constants.
//------------------------------------------------------------------------------

//==============================================================================
// End of configuration
//==============================================================================

function MovementBonus__ErrorMsg takes string func,string s returns nothing
    call BJDebugMsg("|cffFF0000MovementBonus Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

    
    
    
    
    function s__MovementBonus__BonusValue_create takes unit u returns integer
        local integer this= s__MovementBonus__BonusValue__allocate()
        
        set s__MovementBonus__BonusValue_owner[this]=u
        
        set s__MovementBonus__BonusValue_owners[(GetUnitUserData((u)))]=this // INLINED!!
        
        set s__MovementBonus__BonusValue_all[s__MovementBonus__BonusValue_count]=this
        set s__MovementBonus__BonusValue_index[this]=s__MovementBonus__BonusValue_count
        set s__MovementBonus__BonusValue_count=s__MovementBonus__BonusValue_count + 1
        
        return this
    endfunction
    
    function s__MovementBonus__BonusValue_onDestroy takes integer this returns nothing
        set s__MovementBonus__BonusValue_owners[(GetUnitUserData((s__MovementBonus__BonusValue_owner[this])))]=(0) // INLINED!!
        
        set s__MovementBonus__BonusValue_all[s__MovementBonus__BonusValue_index[this]]=s__MovementBonus__BonusValue_all[s__MovementBonus__BonusValue_count]
        set s__MovementBonus__BonusValue_count=s__MovementBonus__BonusValue_count - 1
        
        set s__MovementBonus__BonusValue_owner[this]=null
    endfunction

//Generated destructor of MovementBonus__BonusValue
function s__MovementBonus__BonusValue_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__MovementBonus__BonusValue_V[this]!=-1) then
        return
    endif
    call s__MovementBonus__BonusValue_onDestroy(this)
    set si__MovementBonus__BonusValue_V[this]=si__MovementBonus__BonusValue_F
    set si__MovementBonus__BonusValue_F=this
endfunction
    
    function s__MovementBonus__BonusValue_getInstance takes unit u returns integer
        if s__MovementBonus__BonusValue_owners[(GetUnitUserData((u)))] == 0 then // INLINED!!
            return s__MovementBonus__BonusValue_create(u)
        else
            return s__MovementBonus__BonusValue_owners[(GetUnitUserData((u)))] // INLINED!!
        endif
    endfunction
    
    function s__MovementBonus__BonusValue__staticgetindex takes unit u returns integer
        return s__MovementBonus__BonusValue_owners[(GetUnitUserData((u)))] // INLINED!!
    endfunction
    
    function s__MovementBonus__BonusValue__staticsetindex takes unit u,integer i returns nothing
        set s__MovementBonus__BonusValue_owners[(GetUnitUserData((u)))]=i // INLINED!!
    endfunction

    
    function s__MovementBonus__MovementBonus_create takes integer min,integer max returns integer
        local integer this= s__MovementBonus__MovementBonus__allocate()
        
        set s__BonusMod___BonusInterface_minBonus[this]=min
        set s__BonusMod___BonusInterface_maxBonus[this]=max
        
        return this
    endfunction
    
    function s__MovementBonus__MovementBonus_setBonus takes integer this,unit u,integer amount returns integer
        local integer value
        local integer min
        local integer max
        
        local integer actualSpeed
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call MovementBonus__ErrorMsg("MovementBonus.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set value=s__MovementBonus__BonusValue_getInstance(u)
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min=MIN_BUILDING_MOVEMENT
            set max=MAX_BUILDING_MOVEMENT
        else
            set min=MIN_UNIT_MOVEMENT
            set max=MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed=R2I(GetUnitMoveSpeed(u)) - s__MovementBonus__BonusValue_speed[value]
        
        if actualSpeed + amount < min then
// NO_DEBUG:             debug call MovementBonus__ErrorMsg("MovementBonus.setBonus()", "Attempting to set a unit's speed below it's minimum")
            set amount=- actualSpeed + min
        elseif actualSpeed + amount > max then
// NO_DEBUG:             debug call MovementBonus__ErrorMsg("MovementBonus.setBonus()", "Ateempting to set a unit's speed above it's maximum")
            set amount=max - actualSpeed
        endif
        
        call SetUnitMoveSpeed(u, actualSpeed + amount)
        set s__MovementBonus__BonusValue_speed[value]=amount
        
        return amount
    endfunction
    
    function s__MovementBonus__MovementBonus_getBonus takes integer this,unit u returns integer
        local integer value
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call MovementBonus__ErrorMsg("MovementBonus.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set value=(s__MovementBonus__BonusValue_owners[(GetUnitUserData(((u))))]) // INLINED!!
        
        if value == 0 then
            return 0
        endif
        
        return s__MovementBonus__BonusValue_speed[value]
    endfunction
    
    function s__MovementBonus__MovementBonus_removeBonus takes integer this,unit u returns nothing
        call s__MovementBonus__MovementBonus_setBonus(this,u , 0)
    endfunction
    
    function s__MovementBonus__MovementBonus_isValidBonus takes integer this,unit u,integer value returns boolean
        local integer min
        local integer max
        
        local integer currentBonus
        local integer actualSpeed
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
            return false
        endif
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min=MIN_BUILDING_MOVEMENT
            set max=MAX_BUILDING_MOVEMENT
        else
            set min=MIN_UNIT_MOVEMENT
            set max=MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed=R2I(GetUnitMoveSpeed(u)) - s__MovementBonus__MovementBonus_getBonus(this,u)
        
        if actualSpeed + value < min then
            return false
        elseif actualSpeed + value > max then
            return false
        else
            return true
        endif
    endfunction

function MovementBonus__OnLeaveMap takes unit u returns nothing
    if (s__MovementBonus__BonusValue_owners[(GetUnitUserData(((u))))]) != 0 then // INLINED!!
        call s__MovementBonus__BonusValue_deallocate((s__MovementBonus__BonusValue_owners[(GetUnitUserData(((u))))])) // INLINED!!
    endif
endfunction

function MovementBonus__OnInit takes nothing returns nothing
    local integer min
    local integer max
    
    call s__AutoIndex_onUnitDeindexed(((1))) // INLINED!!
    
    if MAX_UNIT_MOVEMENT > MAX_BUILDING_MOVEMENT then
        set max=MAX_UNIT_MOVEMENT
    else
        set max=MAX_BUILDING_MOVEMENT
    endif
    
    if MIN_UNIT_MOVEMENT < MIN_BUILDING_MOVEMENT then
        set min=MIN_UNIT_MOVEMENT
    else
        set min=MIN_BUILDING_MOVEMENT
    endif
    
    set BONUS_MOVEMENT_SPEED=s__MovementBonus__MovementBonus_create(min , max)
endfunction

////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ RegenBonuses for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, and the AutoIndex library.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides two new bonus types:
//@
//@   - BONUS_MANA_REGEN
//@         Regenerates an absolute amount of mana every second
//@
//@   - BONUS_LIFE_REGEN_PERCENT
//@         Regenerates a percent of a unit's maximum life every second
//@ 
//@ Any value is a valid bonus. There are no limits.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// The following constant determines how often the life and mana bonuses are
// applied to units. Note that this will not effect the values of the bonuses.
// The values of the bonuses will always be mana per second/percentage of life
// per second. This constant simply determines how often the values are updated.
//------------------------------------------------------------------------------

//==============================================================================
// End of configuration
//==============================================================================


function RegenBonuses__ErrorMsg takes string func,string s returns nothing
    call BJDebugMsg("|cffFF0000RegenBonuses Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction



function RegenBonuses__DoRegen takes nothing returns nothing
    local integer i
    local integer values
    
    // Loop over all active bonuses
    set i=0
    loop
        exitwhen i == s__RegenBonuses__BonusValues_count
        
        set values=s__RegenBonuses__BonusValues_all[i]
        
        if GetWidgetLife(s__RegenBonuses__BonusValues_owner[values]) > 0.0 then
            if s__RegenBonuses__BonusValues_manaRegen[values] > 0 then
                // Do mana regen:
                call SetUnitState(s__RegenBonuses__BonusValues_owner[values], UNIT_STATE_MANA, GetUnitState(s__RegenBonuses__BonusValues_owner[values], UNIT_STATE_MANA) + ( s__RegenBonuses__BonusValues_manaRegen[values] * RegenBonuses__REGEN_PERIOD ))
            endif
            
            if s__RegenBonuses__BonusValues_lifeRegen[values] > 0 then
                // Do life regen:
                call SetUnitState(s__RegenBonuses__BonusValues_owner[values], UNIT_STATE_LIFE, GetUnitState(s__RegenBonuses__BonusValues_owner[values], UNIT_STATE_LIFE) + ( GetUnitState(s__RegenBonuses__BonusValues_owner[values], UNIT_STATE_MAX_LIFE) * ( s__RegenBonuses__BonusValues_lifeRegen[values] / 100.0 ) ) * RegenBonuses__REGEN_PERIOD)
            endif
        endif
        
        set i=i + 1
    endloop
endfunction

    
    
    
    
    function s__RegenBonuses__BonusValues_create takes unit u returns integer
        local integer this= s__RegenBonuses__BonusValues__allocate()
        
        set s__RegenBonuses__BonusValues_owner[this]=u
        
        set s__RegenBonuses__BonusValues_owners[(GetUnitUserData((u)))]=this // INLINED!!
        
        if s__RegenBonuses__BonusValues_count == 0 then
            call TimerStart(RegenBonuses__regenTimer, RegenBonuses__REGEN_PERIOD, true, function RegenBonuses__DoRegen)
        endif
        
        set s__RegenBonuses__BonusValues_all[s__RegenBonuses__BonusValues_count]=this
        set s__RegenBonuses__BonusValues_index[this]=s__RegenBonuses__BonusValues_count
        set s__RegenBonuses__BonusValues_count=s__RegenBonuses__BonusValues_count + 1
        
        return this
    endfunction
    
    function s__RegenBonuses__BonusValues_onDestroy takes integer this returns nothing
        set s__RegenBonuses__BonusValues_owners[(GetUnitUserData((s__RegenBonuses__BonusValues_owner[this])))]=(0) // INLINED!!
        
        set s__RegenBonuses__BonusValues_all[s__RegenBonuses__BonusValues_index[this]]=s__RegenBonuses__BonusValues_all[s__RegenBonuses__BonusValues_count]
        set s__RegenBonuses__BonusValues_count=s__RegenBonuses__BonusValues_count - 1
        
        if s__RegenBonuses__BonusValues_count == 0 then
            call PauseTimer(RegenBonuses__regenTimer)
        endif
        
        set s__RegenBonuses__BonusValues_owner[this]=null
    endfunction

//Generated destructor of RegenBonuses__BonusValues
function s__RegenBonuses__BonusValues_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__RegenBonuses__BonusValues_V[this]!=-1) then
        return
    endif
    call s__RegenBonuses__BonusValues_onDestroy(this)
    set si__RegenBonuses__BonusValues_V[this]=si__RegenBonuses__BonusValues_F
    set si__RegenBonuses__BonusValues_F=this
endfunction
    
    function s__RegenBonuses__BonusValues_getInstance takes unit u returns integer
        if s__RegenBonuses__BonusValues_owners[(GetUnitUserData((u)))] == 0 then // INLINED!!
            return s__RegenBonuses__BonusValues_create(u)
        else
            return s__RegenBonuses__BonusValues_owners[(GetUnitUserData((u)))] // INLINED!!
        endif
    endfunction
    
    function s__RegenBonuses__BonusValues__staticgetindex takes unit u returns integer
        return s__RegenBonuses__BonusValues_owners[(GetUnitUserData((u)))] // INLINED!!
    endfunction
    
    function s__RegenBonuses__BonusValues__staticsetindex takes unit u,integer i returns nothing
        set s__RegenBonuses__BonusValues_owners[(GetUnitUserData((u)))]=i // INLINED!!
    endfunction


//textmacro instance: RegenBonuses_RegenBonusDefine("life")
    
    function s__RegenBonuses__RegenBonus_life_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call RegenBonuses__ErrorMsg("RegenBonus_life.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=s__RegenBonuses__BonusValues_getInstance(u)
        set s__RegenBonuses__BonusValues_lifeRegen[values]=amount
        
        return amount
    endfunction
    
    function s__RegenBonuses__RegenBonus_life_getBonus takes integer this,unit u returns integer
        local integer values
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call RegenBonuses__ErrorMsg("RegenBonus_life.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=(s__RegenBonuses__BonusValues_owners[(GetUnitUserData(((u))))]) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        return s__RegenBonuses__BonusValues_lifeRegen[values]
    endfunction
    
    function s__RegenBonuses__RegenBonus_life_removeBonus takes integer this,unit u returns nothing
        call s__RegenBonuses__RegenBonus_life_setBonus(this,u , 0)
    endfunction
    
    function s__RegenBonuses__RegenBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
        return ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) // INLINED!!
    endfunction
//end of: RegenBonuses_RegenBonusDefine("life")
//textmacro instance: RegenBonuses_RegenBonusDefine("mana")
    
    function s__RegenBonuses__RegenBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call RegenBonuses__ErrorMsg("RegenBonus_mana.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=s__RegenBonuses__BonusValues_getInstance(u)
        set s__RegenBonuses__BonusValues_manaRegen[values]=amount
        
        return amount
    endfunction
    
    function s__RegenBonuses__RegenBonus_mana_getBonus takes integer this,unit u returns integer
        local integer values
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call RegenBonuses__ErrorMsg("RegenBonus_mana.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=(s__RegenBonuses__BonusValues_owners[(GetUnitUserData(((u))))]) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        return s__RegenBonuses__BonusValues_manaRegen[values]
    endfunction
    
    function s__RegenBonuses__RegenBonus_mana_removeBonus takes integer this,unit u returns nothing
        call s__RegenBonuses__RegenBonus_mana_setBonus(this,u , 0)
    endfunction
    
    function s__RegenBonuses__RegenBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
        return ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) // INLINED!!
    endfunction
//end of: RegenBonuses_RegenBonusDefine("mana")

function RegenBonuses__OnLeaveMap takes unit u returns nothing
    if (s__RegenBonuses__BonusValues_owners[(GetUnitUserData(((u))))]) != 0 then // INLINED!!
        call s__RegenBonuses__BonusValues_deallocate((s__RegenBonuses__BonusValues_owners[(GetUnitUserData(((u))))])) // INLINED!!
    endif
endfunction

function RegenBonuses__OnInit takes nothing returns nothing
    call s__AutoIndex_onUnitDeindexed(((2))) // INLINED!!
    
    set BONUS_MANA_REGEN=s__RegenBonuses__RegenBonus_mana__allocate()
    set BONUS_LIFE_REGEN_PERCENT=s__RegenBonuses__RegenBonus_life__allocate()
endfunction

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
    call SaveReal(UIStudioLayout__H, k, 0, 0.64000)
    call SaveReal(UIStudioLayout__H, k, 1, 0.57000)
    call SaveReal(UIStudioLayout__H, k, 2, 0.20000)
    call SaveReal(UIStudioLayout__H, k, 3, 0.37000)
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
    call SaveStr(UIStudioLayout__H, k, 6, "Nombre del jugador")
    call SaveReal(UIStudioLayout__H, k, 7, 8.00000)
    call SaveBoolean(UIStudioLayout__H, k, 10, true)
    call SaveStr(UIStudioLayout__H, k, 11, "none")
    call SaveStr(UIStudioLayout__H, k, 12, "none")
    call SaveInteger(UIStudioLayout__H, k, 20, 255)
    call SaveInteger(UIStudioLayout__H, k, 21, 3)
    call SaveInteger(UIStudioLayout__H, k, 22, 3)
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
    call SaveBoolean(UIStudioLayout__H, k, 10, false)
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
    call SaveReal(UIStudioLayout__H, k, 1, 0.10000)
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

////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ UnitMaxStateBonuses for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, the UnitMaxState library by
//@ Earth-Fury, and the AutoIndex library by grim001.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides two new bonus types:
//@
//@   - BONUS_LIFE
//@   - BONUS_MANA
//@ 
//@ These bonuses, of course, raise a unit's maximum life and mana.
//@ 
//@ Note that if you simply wish to permanently increase or decrease the maximum
//@ life or mana of a unit, you are likely best off using UnitMaxState directly.
//@
//@ The minimum life and mana bonuses are 1 more than -(unit's max state).
//@ That is to say, these bonuses can not fully remove a unit's life or mana.
//@
//@ There is no maximum bonus.
//@
//@ There is nothing to configure.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////


function UnitMaxStateBonuses___ErrorMsg takes string func,string s returns nothing
    call BJDebugMsg("|cffFF0000UnitMaxStateBonus Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

    
    
    
    function s__UnitMaxStateBonuses___BonusValues_create takes unit u returns integer
        local integer this= s__UnitMaxStateBonuses___BonusValues__allocate()
        
        set s__UnitMaxStateBonuses___BonusValues_owner[this]=u
        
        set s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData((u)))]=this // INLINED!!
        
        return this
    endfunction
    
    function s__UnitMaxStateBonuses___BonusValues_onDestroy takes integer this returns nothing
        set s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData((s__UnitMaxStateBonuses___BonusValues_owner[this])))]=(0) // INLINED!!
        set s__UnitMaxStateBonuses___BonusValues_owner[this]=null
    endfunction

//Generated destructor of UnitMaxStateBonuses___BonusValues
function s__UnitMaxStateBonuses___BonusValues_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__UnitMaxStateBonuses___BonusValues_V[this]!=-1) then
        return
    endif
    call s__UnitMaxStateBonuses___BonusValues_onDestroy(this)
    set si__UnitMaxStateBonuses___BonusValues_V[this]=si__UnitMaxStateBonuses___BonusValues_F
    set si__UnitMaxStateBonuses___BonusValues_F=this
endfunction
    
    function s__UnitMaxStateBonuses___BonusValues_getInstance takes unit u returns integer
        if s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData((u)))] == 0 then // INLINED!!
            return s__UnitMaxStateBonuses___BonusValues_create(u)
        else
            return s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData((u)))] // INLINED!!
        endif
    endfunction
    
    function s__UnitMaxStateBonuses___BonusValues__staticgetindex takes unit u returns integer
        return s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData((u)))] // INLINED!!
    endfunction
    
    function s__UnitMaxStateBonuses___BonusValues__staticsetindex takes unit u,integer i returns nothing
        set s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData((u)))]=i // INLINED!!
    endfunction


//textmacro instance: UnitMaxStateBonus_DefineBonus("life", "LIFE", "1")
    
    function s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        local integer actual
        local integer new
        local real factor
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call UnitMaxStateBonuses___ErrorMsg("MaxStateBonus_life.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=s__UnitMaxStateBonuses___BonusValues_getInstance(u)
        
        set actual=R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)) - s__UnitMaxStateBonuses___BonusValues_life[values]
        set new=actual + amount
        
        set factor=GetUnitState(u, UNIT_STATE_LIFE) / GetUnitState(u, UNIT_STATE_MAX_LIFE)
        
        if new < 1 then
            if actual < 1 then
                set s__UnitMaxStateBonuses___BonusValues_life[values]=0
            else
                set s__UnitMaxStateBonuses___BonusValues_life[values]=- actual + 1
            endif
            
            call SetUnitState(u, UNIT_STATE_LIFE, 1)
            call SetUnitMaxState(u , UNIT_STATE_MAX_LIFE , 1)
            return s__UnitMaxStateBonuses___BonusValues_life[values]
        else
            set s__UnitMaxStateBonuses___BonusValues_life[values]=amount
            
            call SetUnitMaxState(u , UNIT_STATE_MAX_LIFE , new)
            call SetUnitState(u, UNIT_STATE_LIFE, new * factor)
            
            return s__UnitMaxStateBonuses___BonusValues_life[values]
        endif
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_life_getBonus takes integer this,unit u returns integer
        local integer values
        local integer actual
        local integer new
        local real factor
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call UnitMaxStateBonuses___ErrorMsg("MaxStateBonus_life.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=(s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData(((u))))]) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        set s__UnitMaxStateBonuses___BonusValues_life[values]=R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)) - ( R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)) - s__UnitMaxStateBonuses___BonusValues_life[values] )
        
        return s__UnitMaxStateBonuses___BonusValues_life[values]
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus takes integer this,unit u returns nothing
        call s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus(this,u , 0)
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
        local integer currentBonus
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
            return false
        endif
        
        set currentBonus=s__UnitMaxStateBonuses___MaxStateBonus_life_getBonus(this,u)
        
        return R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)) - currentBonus + value >= 1
    endfunction
//end of: UnitMaxStateBonus_DefineBonus("life", "LIFE", "1")
//textmacro instance: UnitMaxStateBonus_DefineBonus("mana", "MANA", "1")
    
    function s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        local integer actual
        local integer new
        local real factor
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call UnitMaxStateBonuses___ErrorMsg("MaxStateBonus_mana.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=s__UnitMaxStateBonuses___BonusValues_getInstance(u)
        
        set actual=R2I(GetUnitState(u, UNIT_STATE_MAX_MANA)) - s__UnitMaxStateBonuses___BonusValues_mana[values]
        set new=actual + amount
        
        set factor=GetUnitState(u, UNIT_STATE_MANA) / GetUnitState(u, UNIT_STATE_MAX_MANA)
        
        if new < 1 then
            if actual < 1 then
                set s__UnitMaxStateBonuses___BonusValues_mana[values]=0
            else
                set s__UnitMaxStateBonuses___BonusValues_mana[values]=- actual + 1
            endif
            
            call SetUnitState(u, UNIT_STATE_MANA, 1)
            call SetUnitMaxState(u , UNIT_STATE_MAX_MANA , 1)
            return s__UnitMaxStateBonuses___BonusValues_mana[values]
        else
            set s__UnitMaxStateBonuses___BonusValues_mana[values]=amount
            
            call SetUnitMaxState(u , UNIT_STATE_MAX_MANA , new)
            call SetUnitState(u, UNIT_STATE_MANA, new * factor)
            
            return s__UnitMaxStateBonuses___BonusValues_mana[values]
        endif
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus takes integer this,unit u returns integer
        local integer values
        local integer actual
        local integer new
        local real factor
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
// NO_DEBUG:             debug call UnitMaxStateBonuses___ErrorMsg("MaxStateBonus_mana.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values=(s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData(((u))))]) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        set s__UnitMaxStateBonuses___BonusValues_mana[values]=R2I(GetUnitState(u, UNIT_STATE_MAX_MANA)) - ( R2I(GetUnitState(u, UNIT_STATE_MAX_MANA)) - s__UnitMaxStateBonuses___BonusValues_mana[values] )
        
        return s__UnitMaxStateBonuses___BonusValues_mana[values]
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus takes integer this,unit u returns nothing
        call s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus(this,u , 0)
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
        local integer currentBonus
        
        if not ((s__UnitDex_Unit[((GetUnitUserData(((u)))))]) != null) then // INLINED!!
            return false
        endif
        
        set currentBonus=s__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus(this,u)
        
        return R2I(GetUnitState(u, UNIT_STATE_MAX_MANA)) - currentBonus + value >= 1
    endfunction
//end of: UnitMaxStateBonus_DefineBonus("mana", "MANA", "1")

function UnitMaxStateBonuses___OnLeaveMap takes unit u returns nothing
    if (s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData(((u))))]) != 0 then // INLINED!!
        call s__UnitMaxStateBonuses___BonusValues_deallocate((s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData(((u))))])) // INLINED!!
    endif
endfunction


//Implemented from module UnitMaxStateBonuses___StateInit:
function s__UnitMaxStateBonuses___Data_UnitMaxStateBonuses___StateInit___onInit takes nothing returns nothing
    set BONUS_LIFE=s__UnitMaxStateBonuses___MaxStateBonus_life__allocate()
    set BONUS_MANA=s__UnitMaxStateBonuses___MaxStateBonus_mana__allocate()
    
    call s__AutoIndex_onUnitDeindexed(((3))) // INLINED!!
endfunction





    
    function YesNoDialog___OnClick takes nothing returns nothing
        local integer user= s__User_first
        local button btn= GetClickedButton()

        loop
            exitwhen user == s__User_NULL
            
            if ( YesNoDialog___YesCallback[s__User_id[user]] != null and YesNoDialog___YesBtn[s__User_id[user]] == btn ) then
                set YesNoPlayer=(s__User_handle[(user)]) // INLINED!!
                call UserInterface_Eval(YesNoDialog___YesCallback[s__User_id[user]])
            endif
            
            set user=s__User_next[user]
        endloop
    endfunction
    
    
//Implemented from module YesNoDialog___INITS:
        function s__YesNoDialog_YesNoDialog___INITS__onInit takes nothing returns nothing
            local integer user= s__User_first
            local trigger t= CreateTrigger()
            
            loop
                exitwhen user == s__User_NULL
                
                set YesNoDialog___YesCallback[s__User_id[user]]=null
                set Dialog[s__User_id[user]]=DialogCreate()
                set YesNoDialog___YesBtn[s__User_id[user]]=DialogAddButton(Dialog[s__User_id[user]], "Yes", 89)
                call DialogAddButton(Dialog[s__User_id[user]], "No", 0)
                call TriggerRegisterDialogEvent(t, Dialog[s__User_id[user]])
                set user=s__User_next[user]
            endloop
            
            call TriggerAddAction(t, function YesNoDialog___OnClick)
        endfunction
    
    function ShowYesNoDialog takes string title,integer user,filterfunc callback returns nothing
        set YesNoDialog___YesCallback[s__User_id[user]]=callback
        call DialogSetMessage(Dialog[s__User_id[user]], title)
        call DialogDisplay((s__User_handle[(user)]), Dialog[s__User_id[user]], true) // INLINED!!
    endfunction
    

    

    function EquipmentItem_Init takes nothing returns nothing
        set EquipmentItem_BonusString[BONUS_DAMAGE]="Damage"
        set EquipmentItem_BonusString[BONUS_ARMOR]="Armor"
        set EquipmentItem_BonusString[BONUS_STRENGTH]="Strength"
        set EquipmentItem_BonusString[BONUS_AGILITY]="Agility"
        set EquipmentItem_BonusString[BONUS_INTELLIGENCE]="Intelligence"
        set EquipmentItem_BonusString[BONUS_ATTACK_SPEED]="Attack Speed"
        set EquipmentItem_BonusString[BONUS_SIGHT_RANGE]="Visibility"
        set EquipmentItem_BonusString[BONUS_LIFE_REGEN]="Life Regen"
        set EquipmentItem_BonusString[BONUS_MANA_REGEN_PERCENT]="% Mana Regen"
        set EquipmentItem_BonusString[BONUS_MOVEMENT_SPEED]="Movement Speed"
        set EquipmentItem_BonusString[BONUS_LIFE]="Life"
        set EquipmentItem_BonusString[BONUS_MANA]="Mana"
    endfunction
    
    
    function SetEquipItemStats takes integer slot,integer s2,integer ab,integer lvl,integer utype,integer rab,integer dmg,integer def,integer str,integer agi,integer it,integer as,integer sight,integer lreg,integer mreg,integer itm returns integer
        set s__InvItem_slot[itm]=slot
        set s__InvItem_slotAlt[itm]=s2
        set s__InvItem_reqUnitType[itm]=utype
        set s__InvItem_equipAbility[itm]=ab
        set s__InvItem_reqLevel[itm]=lvl
        set s__InvItem_reqUnitType[itm]=utype
        set s__InvItem_reqAbility[itm]=rab
        
        if ( dmg != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_DAMAGE , dmg)
        endif
        
        if ( def != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_ARMOR , def)
        endif
        
        if ( str != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_STRENGTH , str)
        endif
        
        if ( agi != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_AGILITY , agi)
        endif
        
        if ( it != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_INTELLIGENCE , it)
        endif

        if ( as != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_ATTACK_SPEED , as)
        endif
        
        if ( sight != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_SIGHT_RANGE , sight)
        endif
        
        if ( lreg != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_LIFE_REGEN , lreg)
        endif
        
        if ( mreg != 0 ) then
            call s__InvItem_addBonus(itm,BONUS_MANA_REGEN_PERCENT , lreg)
        endif
        
        return itm
    endfunction

    

    
    //
    // configuration
    //
    function EquipItemParser_ParseTypeToSlot takes integer itm,string t returns nothing
        if ( t == "weapon" ) then
            set s__InvItem_slot[itm]=13
        elseif ( t == "shield" ) then
            set s__InvItem_slot[itm]=14
        elseif ( t == "armor" ) then
            set s__InvItem_slot[itm]=3
        elseif ( t == "boots" ) then
            set s__InvItem_slot[itm]=11
        elseif ( t == "bracers" ) then
            set s__InvItem_slot[itm]=10
        elseif ( t == "gloves" ) then
            set s__InvItem_slot[itm]=9
        elseif ( t == "belt" ) then
            set s__InvItem_slot[itm]=4
        elseif ( t == "helm" ) then
            set s__InvItem_slot[itm]=1
        elseif ( t == "pauldron" ) then
            set s__InvItem_slot[itm]=2
            set s__InvItem_slotAlt[itm]=9
        elseif ( t == "amulet" ) then
            set s__InvItem_slot[itm]=7
        elseif ( t == "pants" ) then
            set s__InvItem_slot[itm]=5
        elseif ( t == "ring" ) then
            set s__InvItem_slot[itm]=6
            set s__InvItem_slotAlt[itm]=12
        elseif ( t == "shield" ) then
            set s__InvItem_slot[itm]=14
        elseif ( t == "socket" or t == "gem" ) then
            set s__InvItem_isSocket[itm]=true
        endif
    endfunction

    function EquipItemParser_ParseClass takes integer itm,string c returns nothing
        if ( c == "1h" ) then
            set s__InvItem_slotAlt[itm]=14
        endif
    endfunction
    
    function EquipItemParser_ParseBonusParam takes integer itm,string param,string value,string min,string max returns nothing
        if ( param == "dmg" ) then
            call s__InvItem_addBonusRange(itm,BONUS_DAMAGE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "def" ) then
            call s__InvItem_addBonusRange(itm,BONUS_ARMOR , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "str" ) then
            call s__InvItem_addBonusRange(itm,BONUS_STRENGTH , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "agi" ) then
            call s__InvItem_addBonusRange(itm,BONUS_AGILITY , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "int" ) then
            call s__InvItem_addBonusRange(itm,BONUS_INTELLIGENCE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "ias" ) then
            call s__InvItem_addBonusRange(itm,BONUS_ATTACK_SPEED , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "hp" or param == "life" ) then
            call s__InvItem_addBonusRange(itm,BONUS_LIFE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "mp" or param == "mana" ) then
            call s__InvItem_addBonusRange(itm,BONUS_MANA , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "manareg" ) then
            call s__InvItem_addBonusRange(itm,BONUS_MANA_REGEN , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "sight" ) then
            call s__InvItem_addBonusRange(itm,BONUS_SIGHT_RANGE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "ms" or param == "move" ) then
            call s__InvItem_addBonusRange(itm,BONUS_MOVEMENT_SPEED , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "lifereg" ) then
            call s__InvItem_addBonusRange(itm,BONUS_LIFE_REGEN , S2I(value) , S2I(min) , S2I(max))
        endif
    endfunction
    //
    // end
    //
    
    // String2Rawcode:
    function EquipItemParser_Char2Id takes string c returns integer
        local integer i= 0
        local string abc= "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        local string t

        loop
            set t=SubString(abc, i, i + 1)
            exitwhen t == null or t == c
            set i=i + 1
        endloop
        if i < 10 then
            return i + 48
        elseif i < 36 then
            return i + 65 - 10
        endif
        return i + 97 - 36
    endfunction

    function EquipItemParser_String2Id takes string s returns integer
        return ( ( EquipItemParser_Char2Id(SubString(s, 0, 1)) * 256 + EquipItemParser_Char2Id(SubString(s, 1, 2)) ) * 256 + EquipItemParser_Char2Id(SubString(s, 2, 3)) ) * 256 + EquipItemParser_Char2Id(SubString(s, 3, 4))
    endfunction

    function EquipItemParser_Id2Char takes integer i returns string
        local string abc= "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

        if i >= 97 then
            return SubString(abc, i - 97 + 36, i - 96 + 36)
        elseif i >= 65 then
            return SubString(abc, i - 65 + 10, i - 64 + 10)
        endif
        return SubString(abc, i - 48, i - 47)
    endfunction

    function EquipItemParser_Id2String takes integer id returns string
        local integer t= id / 256
        local string r= EquipItemParser_Id2Char(id - 256 * t)
        set id=t / 256
        set r=EquipItemParser_Id2Char(t - 256 * id) + r
        set t=id / 256
        return EquipItemParser_Id2Char(t) + EquipItemParser_Id2Char(id - 256 * t) + r
    endfunction
    // end
    
    function EquipItemParser_ParseRawCodeStr takes string value returns integer
        local integer l= StringLength(value)
        
        if ( l == 4 or l == 1 or l == 3 or l == 6 ) then
            
            if ( SubString(value, 0, 1) == "'" ) then
                set value=SubString(value, 1, 9999)
                set l=l - 1
            endif
        
            if ( SubString(value, l - 1, l) == "'" ) then
                set value=SubString(value, 0, l - 1)
            endif
            
            return EquipItemParser_String2Id(value)
        endif
        
        return S2I(value)
    endfunction
    
    function EquipItemParser__ParseParam takes integer itm,string param,string value returns nothing
        if ( param == "lvl" ) then
            set s__InvItem_reqLevel[itm]=S2I(value)
        elseif ( param == "class" ) then
            call EquipItemParser_ParseClass(itm , value)
        elseif ( param == "icon" ) then
            set s__InvItem_icon[itm]=EquipItemParser_ParseRawCodeStr(value)
        elseif ( param == "utype" ) then
            set s__InvItem_reqUnitType[itm]=EquipItemParser_ParseRawCodeStr(value)
        elseif ( param == "abil" ) then
            set s__InvItem_reqAbility[itm]=EquipItemParser_ParseRawCodeStr(value)
        elseif ( param == "cost" ) then
            set s__InvItem_cost[itm]=S2I(value)
        elseif ( param == "type" ) then
            call EquipItemParser_ParseTypeToSlot(itm , value)
        elseif ( param == "maxsock" ) then
            set s__InvItem_maxSockets[itm]=S2I(value)
        endif
    endfunction
    
    
    function InitEquipItem takes integer itemId,string data returns integer
        local integer itm= s__InvItem__allocate()
        local integer len= StringLength(data)
        local integer i= 0
        local string desc= ""
        local string param= ""
        local string array value
        local integer curVal= 0
        
        local string s= ""
        local integer step= 0

        set s__InvItem_id[itm]=itemId
        call SaveInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), (s__InvItem_id[itm]), ( itm)) // INLINED!!

        loop
            exitwhen i >= len
            
            set s=SubString(data, i, i + 1)
            
            if ( step > 0 and s == " " ) then
                // do nothing
            elseif ( step == 0 ) then
                
                if ( s == "^" ) then
                    set step=1
                else
                    set desc=desc + s
                endif
            
            elseif ( step == 1 ) then
            
                if ( s == "^" ) then
                    set step=3
                    set param=""
                elseif ( s == "=" ) then
                    set step=2
                else
                    set param=param + s
                endif
                
            elseif ( step == 2 ) then
            
                if ( s == ";" ) then
                    call EquipItemParser__ParseParam(itm , StringCase(param, false) , value[0])
                    
                    set param=""
                    set value[0]=""
                    set step=1
                else
                    set value[0]=value[0] + s
                endif
                
            elseif ( step == 3 ) then
            
                if ( s == "=" ) then
                    set step=4
                else
                    set param=param + s
                endif
                
            elseif ( step == 4 ) then
            
                if ( s == ";" ) then
                    set curVal=curVal + 1
                    
                    if ( curVal >= 3 ) then
                        if ( value[0] == "" ) then
                            set value[0]="0"
                        elseif ( value[1] == "" ) then
                            set value[0]="0"
                      elseif ( value[2] == "" ) then
                            set value[0]="0"
                        endif
                        
                        call EquipItemParser_ParseBonusParam(itm , param , value[0] , value[1] , value[2])
                        
                        set step=3
                        set curVal=0
                        set value[0]=""
                        set value[1]=""
                        set value[2]=""
                        set param=""
                    endif
                    
                else
                    set value[curVal]=value[curVal] + s
                endif
                
            endif
                        
            set i=i + 1
        endloop
        
        set s__InvItem_info[itm]=desc
        
        return itm
    endfunction
    

    
    
     function EquipmentCore_HERO_WINDOW_NAME takes unit u returns string
        return s__User__get_nameColored((GetPlayerId((GetOwningPlayer(u))))) // INLINED!!
        // return GetHeroProperName(u)
    endfunction
    
        //
        // configuration
        //
        
        
        
        
        
        
        //
        // end config
        //
        
        
        
    
        
        
        function s__Equipment__staticgetindex takes unit u returns integer
            return s__Equipment_UnitsIndex[GetUnitUserData(u)]
        endfunction
 
        function s__Equipment_getButton takes integer this,integer index returns integer
            return s__s__Equipment_buttons[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + index]
        endfunction
        
        function s__Equipment_setButton takes integer this,integer index,integer value returns nothing
            set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + index]= value
        endfunction
        
        function s__Equipment_create takes unit u returns integer
            local integer this= s__Equipment__allocate()
            local real x1= s__Equipment_X + s__Equipment_SLOT_OFFSET_ROWLEFT_X
            local real x2= s__Equipment_X + s__Equipment_SLOT_OFFSET_ROWRIGHT_X
            local real y1= s__Equipment_Y - s__Equipment_SLOT_OFFSET_Y
            local integer i= 0

            set s__Equipment_unit[this]=u
            set s__Equipment_player[this]=GetOwningPlayer(u)
            set s__Equipment_user[this]=(GetPlayerId((s__Equipment_player[this]))) // INLINED!!
            
            set s__Equipment_UnitsIndex[GetUnitUserData(u)]=this

            //
            // GEAR SLOTS
            //
            
            if ( (s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (0)]) == 0 ) then // INLINED!!
            
                set s__Equipment_selector[s__User_id[s__Equipment_user[this]]]=s__UIPicture_createEx(s__Equipment_X - 0.15 , ( s__Equipment_Y + s__Equipment_SLOT_OFFSET_Y ) - .250 , 0 , .70 , 'e000' , 1 , 1 , 0)
                set s__UIPicture_animIndex[s__Equipment_selector[s__User_id[s__Equipment_user[this]]]]=56
                call s__UIPicture_show(s__Equipment_selector[s__User_id[s__Equipment_user[this]]],false , s__Equipment_camera[this])

                call AddSpecialEffectTarget("UI\\TRSHerolevel.mdx", s__UIPicture_picture[s__Equipment_selector[s__User_id[s__Equipment_user[this]]]], "origin")
                
                // middle
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (12 )]= ( s__UIButton_create(x1 + ( s__Equipment_SLOT_WIDTH * 1.5 ) , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B005')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (13 )]= ( s__UIButton_create(x2 - ( s__Equipment_SLOT_WIDTH * 1.5 ) , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00B')) // INLINED!!
                
                // left side
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (0 )]= ( s__UIButton_create(x1 , y1 , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B003')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (1 )]= ( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 1 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B004')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (2 )]= ( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 2 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B006')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (3 )]= ( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 3 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B007')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (4 )]= ( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 4 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B008')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (5 )]= ( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'D05W')) // INLINED!!
                
                // right side
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (6 )]= ( s__UIButton_create(x2 , y1 , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B009')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (7 )]= ( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 1 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00A')) // INLINED!!
            
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (8 )]= ( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 2 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00C')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (9 )]= ( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 3 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00D')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (10 )]= ( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 4 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00E')) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (11 )]= ( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00F')) // INLINED!!
                            
                loop
                    exitwhen i == 14
                    set s__UIButton_customValue[(s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)])]=i // INLINED!!
                    
                     set s__UIButton_selectUnit[(s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)])]=s__Equipment_unit[this] // INLINED!!
                     
                    set s__UIButton_onLeftClick[(s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)])]=EquipmentCore_FuncLClickSlot // INLINED!!
                    set s__UIButton_onRightClick[(s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)])]=EquipmentCore_FuncRClickSlot // INLINED!!
                    
                    set s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i]= s__UIPicture_create(s__UIButton_minx[(s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)])] + ( s__Equipment_SLOT_WIDTH / 6.3 ) , s__UIButton_maxy[(s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)])] - 0.022 , s__Equipment_SLOT_WIDTH * .7 , s__Equipment_SLOT_HEIGHT * .7 , 9 , s__Inventory_ICON_EMPTY) // INLINED!!
                    set s__UIPicture_customValue[s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i]]=i

                    set i=i + 1
                endloop
                
                set s__s__Equipment_pictures[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + 0]= s__UIPicture_createEx(s__Equipment_X , s__Equipment_Y , 11 , s__Equipment_WINDOW_SIZE , s__Equipment_WINDOW_DUMMY , 140. , 130. , s__Inventory_localInt(s__User_id[s__Equipment_user[this]] , s__Inventory_RACE_BORDERS_START + ( GetHandleId(GetPlayerRace(s__Equipment_player[this])) - 1 ) , s__Inventory_ICON_TRANSPARENT))
                
            endif
            
            // unit model
            set i=(sc__InventoryTable__getindex(EquipHeroModels___HeroModels,(GetUnitTypeId(s__Equipment_unit[this])))) // INLINED!!
            
            set s__Equipment_charModel[this]=s__UIPicture_createEx(s__Equipment_CHARMODEL_OFFSET_X , s__Equipment_CHARMODEL_OFFSET_Y , 5 , s__HeroModelData_scale[(i)] , s__Equipment_MODEL_DUMMY , 1 , 1 , 0)
            set s__UIPicture_animIndex[s__Equipment_charModel[this]]=140
            call SetUnitColor(s__UIPicture_picture[s__Equipment_charModel[this]], (GetPlayerColor(s__User_handle[(s__Equipment_user[this])]))) // INLINED!!

            call AddSpecialEffectTarget(s__HeroModelData_path[(i)], s__UIPicture_picture[s__Equipment_charModel[this]], "origin")

            set s__Equipment_title[s__User_id[s__Equipment_user[this]]]=s__UIText_createEx((s__User_handle[(s__Equipment_user[this])]) , s__Equipment_X / 1.4 , 0.1 , 1) // INLINED!!

            set s__Equipment_prev[s__Equipment_next[(0)]]=this
            set s__Equipment_next[this]=s__Equipment_next[(0)]
            set s__Equipment_next[(0)]=this

            set s__Equipment_prev[this]=0

            return this
        endfunction

        function s__Equipment_equip takes integer this,integer itm,integer equipSlot returns boolean
            local integer slot= s__InvItem_slot[itm] - 1
            
            if ( slot < 0 ) then
                return false
            endif
            
            if ( s___Equipment_item[s__Equipment_item[this]+equipSlot] != 0 ) then
                return false
            endif
            
            if ( s__InvItem_slotAlt[itm] - 1 > 0 ) then
                if ( equipSlot != slot and equipSlot != s__InvItem_slotAlt[itm] - 1 ) then
                    call SimError((s__Equipment_player[this] ) , ( "The item doesn't belong in that slot.")) // INLINED!!
                    return false
                endif
            else
                if ( equipSlot != slot ) then
                    call SimError((s__Equipment_player[this] ) , ( "The item doesn't belong in that slot.")) // INLINED!!
                    return false
                endif
            endif
            
            if ( s__InvItem_reqUnitType[itm] > 0 and GetUnitTypeId(s__Equipment_unit[this]) != s__InvItem_reqUnitType[itm] ) then
                call SimError((s__Equipment_player[this] ) , ( "Your unit type cannot equip this item.")) // INLINED!!
                return false
            endif
            
            if ( s__InvItem_reqAbility[itm] > 0 and GetUnitAbilityLevel(s__Equipment_unit[this], s__InvItem_reqAbility[itm]) < 0 ) then
                call SimError((s__Equipment_player[this] ) , ( "Failed requirements.")) // INLINED!!
                return false
            endif
            
            if ( GetHeroLevel(s__Equipment_unit[this]) < s__InvItem_reqLevel[itm] and GetUnitLevel(s__Equipment_unit[this]) < s__InvItem_reqLevel[itm] ) then
                call SimError((s__Equipment_player[this] ) , ( "Your level is too low to equip that item.")) // INLINED!!
                return false
            endif
            
            if ( s__InvItem_equipCondition[itm] != null ) then
                call TriggerClearConditions(s__InvItem_equipEval)
                call TriggerAddCondition(s__InvItem_equipEval, s__InvItem_equipCondition[itm])
                set s__InvItem_eventUnit=s__Equipment_unit[this]
                if ( not TriggerEvaluate(s__InvItem_equipEval) ) then
                    return false
                endif
            endif

            set slot=equipSlot
            
            if ( s___Equipment_item[s__Equipment_item[this]+slot] != 0 ) then
                return false
            endif
            
            if ( s__InvItem_equipAbility[itm] > 0 ) then
                call UnitAddAbility(s__Equipment_unit[this], s__InvItem_equipAbility[itm])
            endif
            
            set s___Equipment_item[s__Equipment_item[this]+slot]=itm
            set s___Equipment_itemId[s__Equipment_itemId[this]+slot]=s__InvItem_tempCustomId[itm]
            
            call s__UIPicture_setTexture(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot],s__Inventory_localInt(s__User_id[s__Equipment_user[this]] , s__InvItem_icon[itm] , s__Inventory_ICON_TRANSPARENT))
            call s__UIPicture_show(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot],true , s__Equipment_camera[this])

            set InvEventPlayer=s__Equipment_player[this]
            set InvEventItem=itm
            set InvEventSlot=equipSlot
            
            if ( s__InvItem_onEquip != null and TriggerEvaluate(s__InvItem_onEquip) ) then
                call TriggerExecute(s__InvItem_onEquip)
            endif
                    
            // add bonuses
            call s__InvItem_addBonusesMultiplier((itm),(s__Equipment_unit[this]) , 1) // INLINED!!
            
            set s__InvItem_tempCustomId[itm]=0
            
            return true
        endfunction
        
        function s__Equipment_unequip takes integer this,integer itm,integer slot returns boolean
            local integer i2
            local integer i= 0
            local integer cid= s__InvItem_tempCustomId[itm]
            
            if ( slot != s__InvItem_slot[itm] - 1 and slot != s__InvItem_slotAlt[itm] - 1 ) then
                return false
            endif
            
            if ( s__InvItem_equipAbility[itm] > 0 ) then
                call UnitRemoveAbility(s__Equipment_unit[this], s__InvItem_equipAbility[itm])
            endif
            
            // run unequip event
            set InvEventPlayer=s__Equipment_player[this]
            set InvEventItem=s___Equipment_item[s__Equipment_item[this]+slot]
            set InvEventSlot=slot
                
            if ( s__InvItem_onUnequip != null and TriggerEvaluate(s__InvItem_onUnequip) ) then
                call TriggerExecute(s__InvItem_onUnequip)
            endif
            
            set s___Equipment_item[s__Equipment_item[this]+slot]=0

            call s__UIPicture_setTexture(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot],s__Inventory_ICON_EMPTY)
            call s__UIPicture_show(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot],false , s__Equipment_camera[this])
            
            // remove bonuses
            call s__InvItem_addBonusesMultiplier((itm),(s__Equipment_unit[this]) , - 1) // INLINED!!

            return true
        endfunction
        
        function s__Equipment_destroy takes integer this returns nothing
            set s__Equipment_prev[s__Equipment_next[this]]=s__Equipment_prev[this]
            set s__Equipment_next[s__Equipment_prev[this]]=s__Equipment_next[this]
            
            call s__UIPicture_destroy(s__Equipment_charModel[this])
            
            call s__Equipment_deallocate(this)
        endfunction

        function s__Equipment_onDisplay takes nothing returns nothing
            local integer user= (s__User_LocalId)
            local integer equipment= (s__Equipment_UnitsIndex[GetUnitUserData((s__Equipment_PlayerCurrentUnit[s__User_id[user]]))]) // INLINED!!
            local real x
            local real y
            local real z
            
            if ( equipment == 0 or not s__Equipment_displayed[equipment] or s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[equipment]]] > 0 or s__User_Local != s__User_handle[user] ) then
                return
            endif
            
            set x=GetUnitX(s__Equipment_unit[equipment])
            set y=GetUnitY(s__Equipment_unit[equipment])
            set z=GetTerrainZ(x , y) + GetUnitDefaultFlyHeight(s__Equipment_unit[equipment])
            
            call s__Camera_setPosition(s__Equipment_camera[equipment],x , y , z)
            
            if s__Camera_applyCameraForPlayer(s__Equipment_camera[equipment],s__User_handle[user] , false) then
                call s__Interface_updateAll(true , true , true)
            endif
        endfunction
        
        function s__Equipment_show takes integer this,boolean flag,integer cam returns nothing
            local integer i= 0
            local integer equip= 0
            local integer len
            local real timeout
            
            if this == 0 or ( not flag and not s__Equipment_displayed[this] ) then
                return
            endif
            if flag and not s__Equipment_displayed[this] then
                set s__Equipment_DisplayCount=s__Equipment_DisplayCount + 1
            endif
            set s__Equipment_displayed[this]=flag
            set s__Equipment_camera[this]=cam
            
            if ( flag ) then
                if ( s__Equipment_DisplayCount >= 1 ) then
                    call PauseTimer(s__Equipment_UpdateTimer)
                    
                    call TimerStart(s__Equipment_UpdateTimer, s__Inventory_UI_REFRESH_RATE, true, function s__Equipment_onDisplay)
                endif
                
                if ( s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]] != null ) then
                    set equip=(s__Equipment_UnitsIndex[GetUnitUserData((s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]]))]) // INLINED!!
                endif
                
                if ( s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]] != null and s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]] != s__Equipment_unit[this] and equip != this ) then
                    call s__Equipment_show(equip,false , s__Equipment_camera[this])
                endif
                
                set s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]]=s__Equipment_unit[this]
                
                if ( s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[this]]] > 0 and s__Inventory_owner[s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[this]]]] != s__Equipment_unit[this] ) then
                    call s__Inventory_show(s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[this]]],false , s__Equipment_camera[this])
                endif

            else
                set s__Equipment_DisplayCount=s__Equipment_DisplayCount - 1
                set s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]]=null
                
                if ( s__Equipment_DisplayCount == 0 ) then
                    call PauseTimer(s__Equipment_UpdateTimer)
                else
                    call PauseTimer(s__Equipment_UpdateTimer)
                    call TimerStart(s__Equipment_UpdateTimer, s__Inventory_UI_REFRESH_RATE, true, function s__Equipment_onDisplay)
                endif
                if ( s__User_Local == s__Equipment_player[this] ) then
                    call ResetToGameCamera(0)
                endif
            endif
            
            call s__UIPicture_showPlayer(s__Equipment_charModel[this],(s__User_handle[(s__Equipment_user[this])]) , flag , s__Equipment_camera[this]) // INLINED!!
            //call this.selector[this.user.id].show(flag, cam)
            
            call SetUnitColor(s__UIPicture_picture[s__Equipment_charModel[this]], (GetPlayerColor(s__User_handle[(s__Equipment_user[this])]))) // INLINED!!

            // todo: make one line / recode
            set len=StringLength((GetPlayerName(s__User_handle[(s__Equipment_user[this])]))) // INLINED!!
            
            call s__UIText_setPosition(s__Equipment_title[s__User_id[s__Equipment_user[this]]],s__Equipment_X + 0.10 , s__Equipment_HERO_NAME_Y)

            call SetTextTagText(s__UIText_text[s__Equipment_title[s__User_id[s__Equipment_user[this]]]], (s__User__get_nameColored((GetPlayerId((GetOwningPlayer((s__Equipment_unit[this]))))))), 8 * 0.0023) // INLINED!!
            
            call s__UIText_show(s__Equipment_title[s__User_id[s__Equipment_user[this]]],flag , s__Equipment_camera[this])
            
            set i=0
            
            loop
                exitwhen i == s__Equipment_MAX_SLOTS
                
                if ( (s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)]) != 0 ) then // INLINED!!
                    call s__UIButton_showPlayer((s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(this)]] * s__Equipment_MAX_SLOTS ) + (i)]),s__User_handle[s__Equipment_user[this]] , flag , s__Equipment_camera[this]) // INLINED!!
                endif
                
                if ( s__s__Equipment_pictures[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i] != 0 ) then
                    call s__UIPicture_showPlayer(s__s__Equipment_pictures[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i],s__User_handle[s__Equipment_user[this]] , flag , s__Equipment_camera[this])
                endif
                
                if ( s___Equipment_item[s__Equipment_item[this]+i] > 0 ) then
                    call s__UIPicture_showPlayer(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i],s__User_handle[s__Equipment_user[this]] , flag , s__Equipment_camera[this])
                endif
                
                set i=i + 1
            endloop
        endfunction
        
        function s__Equipment_onInit takes nothing returns nothing
            set s__Equipment_Hashtable=InitHashtable()
            set s__Equipment_UpdateTimer=CreateTimer()
            set s__Equipment_Initialized=true
        endfunction
        
    
    function EquipmentCore__OnInventoryItemClick takes nothing returns nothing
        local integer but= (UserInterface__ClickedButton) // INLINED!!
        local player p= (UserInterface__ClickingPlayer) // INLINED!!
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        local integer slot=  s__UIButton_customValue[but]
        local integer itemId= 0
        local integer last= InvPlayerLastSlot[s__Inventory_pid[inv]] - 1
        local integer lastItemId
        local integer lastButton= InvPlayerLastButton[s__Inventory_pid[inv]]
        local integer gear= (s__Equipment_UnitsIndex[GetUnitUserData((s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]]))]) // INLINED!!
        local integer gearSlot
        local integer itm
        
        call s__UIPicture_show(s__Equipment_selector[s__Inventory_pid[inv]],false , s__Inventory_camera[inv])
       
        if ( gear <= 0 ) then
            return
        endif
        
        if ( EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]] > 0 ) then
            
            set gearSlot=EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]] - 1

            if ( (LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot))) == 0 ) then // INLINED!!
                set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear]+gearSlot]]=s___Equipment_itemId[s__Equipment_itemId[gear]+gearSlot]
                call s__Inventory_setItem(inv,slot , s___Equipment_item[s__Equipment_item[gear]+gearSlot])
                
                set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear]+gearSlot]]=s___Equipment_itemId[s__Equipment_itemId[gear]+gearSlot]
                call s__Equipment_unequip(gear,s___Equipment_item[s__Equipment_item[gear]+gearSlot] , gearSlot)
            endif
            
            set EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]]=0
        else
            set itm=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot))) // INLINED!!
            
            if ( itm > 0 and not s__InvItem_isSocket[itm] ) then
                set but=(s__s__Equipment_buttons[( s__User_id[s__Equipment_user[(gear)]] * s__Equipment_MAX_SLOTS ) + (s__InvItem_slot[itm] - 1)]) // INLINED!!
                
                call s__UIPicture_show(s__Equipment_selector[s__Inventory_pid[inv]],true , s__Inventory_camera[inv])
                call s__UIPicture_setPosition(s__Equipment_selector[s__Inventory_pid[inv]],s__UIButton_centerx[but] - 0.007 , s__UIButton_centery[but] + 0.0272)
                call s__UIPicture_showPlayer(s__Equipment_selector[s__Inventory_pid[inv]],Player(s__Inventory_pid[inv]) , true , s__Inventory_camera[inv])
            endif
        endif
    endfunction
    
    function EquipmentCore__OnInventoryItemRightClick takes nothing returns nothing
        local integer but= (UserInterface__ClickedButton) // INLINED!!
        local player p= (UserInterface__ClickingPlayer) // INLINED!!
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        local integer slot=  s__UIButton_customValue[but]
        local integer gear= (s__Equipment_UnitsIndex[GetUnitUserData((s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]]))]) // INLINED!!
        local integer itm= (LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot))) // INLINED!!
        local integer gearSlot= s__InvItem_slot[itm] - 1
        local integer unequippedSlot= 0
        local integer unequipItem= 0
        local integer unequipId= 0
        
        if ( gear <= 0 or itm <= 0 ) then
            return
        endif
        
        set s__InvItem_tempCustomId[itm]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (slot))) // INLINED!!
        
        if ( s___Equipment_item[s__Equipment_item[gear]+gearSlot] > 0 ) then
            set unequipId=s___Equipment_itemId[s__Equipment_itemId[gear]+gearSlot]
            set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear]+gearSlot]]=unequipId
            call s__Equipment_unequip(gear,s___Equipment_item[s__Equipment_item[gear]+gearSlot] , gearSlot)
            set unequippedSlot=InvEventSlot
            set unequipItem=InvEventItem
        endif
        
        set s__InvItem_tempCustomId[itm]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (slot))) // INLINED!!
        
        if ( s__Equipment_equip(gear,itm , s__InvItem_slot[itm] - 1) ) then
            call s__Inventory_setItem(inv,slot , 0)
            set s__InvItem_tempCustomId[unequipItem]=unequipId
            call s__Inventory_addItem(inv,unequipItem)
        elseif ( unequipItem > 0 ) then
            call s__Equipment_equip(gear,unequipItem , unequippedSlot)
        endif
    endfunction

    function EquipmentCore__RClickItemSlot takes nothing returns boolean
        local integer but= (UserInterface__ClickedButton) // INLINED!!
        local unit u= s__Equipment_PlayerCurrentUnit[GetPlayerId((UserInterface__ClickingPlayer))] // INLINED!!
        local integer gear= (s__Equipment_UnitsIndex[GetUnitUserData((u))]) // INLINED!!
        local integer inv= (LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId((u)))) // INLINED!!
        local integer slot= s__UIButton_customValue[but]
        local integer itemId
        local integer itm
        local integer cid
        
        if ( (UserInterface__ClickingPlayer) != s__User_handle[(s__Inventory_pid[inv])] or s___Equipment_item[s__Equipment_item[gear]+slot] <= 0 ) then // INLINED!!
            return false
        endif

        // clear tooltip
        call s__Inventory_showLines(inv,s__Inventory_pid[inv] , false , s__Inventory_camera[inv])
        
        set itm=s___Equipment_item[s__Equipment_item[gear]+slot]
        set itemId=s__InvItem_id[itm]
        set cid=s___Equipment_itemId[s__Equipment_itemId[gear]+slot]
        
        set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear]+slot]]=cid
        
        if ( s__Equipment_unequip(gear,itm , slot) ) then
            set s__InvItem_tempCustomId[itm]=cid
            if ( not s__Inventory_addItem(inv,itm) ) then
                set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear]+slot]]=cid
                call s__Equipment_equip(gear,itm , slot)
                return false
            endif
        else
            return false
        endif
    
        call s__Inventory_showTooltip(inv , false)
        
        return false
    endfunction
    
    function EquipmentCore__LClickItemSlot takes nothing returns boolean
        local integer but= (UserInterface__ClickedButton) // INLINED!!
        local player p= (UserInterface__ClickingPlayer) // INLINED!!
        local integer equip= (s__Equipment_UnitsIndex[GetUnitUserData((s__Equipment_PlayerCurrentUnit[GetPlayerId(p)]))]) // INLINED!!
        local integer inv= s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[equip]]]
        local integer slot=  s__UIButton_customValue[but]
        local integer last= InvPlayerLastSlot[s__Inventory_pid[inv]] - 1
        local integer itemId= 0
        local integer lastButton= InvPlayerLastButton[s__User_id[s__Equipment_user[equip]]]
        local integer itm
        
        if ( s__User_Local == p ) then
            call SelectUnit(s__UIButton_picture[but], false)
            call SelectUnit(s__Equipment_unit[equip], true)
        endif
        
        if ( p != s__User_handle[s__Equipment_user[equip]] ) then
            return false
        endif
        
        if ( InvButtonDisabled[but] ) then
            return false
        endif

        call s__Inventory_showLines(inv,s__Inventory_pid[inv] , false , s__Inventory_camera[inv])
        
        set EquipmentCore_PlayerLastSlot[s__User_id[s__Equipment_user[equip]]]=slot + 1
        
        // equip item
        if ( inv > 0 and last + 1 > 0 ) then
        
            set last=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
            
            set itm=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (last))) // INLINED!!
            
            if ( s__InvItem_slot[itm] - 1 == slot or s__InvItem_slotAlt[itm] - 1 == slot ) then
                set s__InvItem_tempCustomId[itm]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (last))) // INLINED!!
                
                if ( s__Equipment_equip(equip,itm , slot) ) then
                    set EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]]=0
                    call s__Inventory_setItem(inv,last , 0)
            
                    call TimerStart(NewTimerEx(but), 2, false, function InventoryCore_GracePeriod)
                    set InvButtonDisabled[but]=true
                endif
            endif
        endif
        
        set InvPlayerLastButton[s__User_id[s__Equipment_user[equip]]]=but
        set InvPlayerLastSlot[s__User_id[s__Equipment_user[equip]]]=0
        
        if ( but != lastButton ) then
            call SetUnitVertexColor(s__UIButton_picture[lastButton], 255, 255, 255, 255)
            call SetUnitVertexColor(s__UIButton_picture[but], 175, 175, 175, 255)
        endif
        
        set itemId=s__InvItem_id[s___Equipment_item[s__Equipment_item[equip]+slot]]
        
        call s__UIPicture_show(s__Inventory_selector[s__Inventory_pid[inv]],false , s__Inventory_camera[inv])
        call s__UIPicture_setPosition(s__Equipment_selector[s__Inventory_pid[inv]],s__UIButton_centerx[but] - 0.007 , s__UIButton_centery[but] + 0.0272)
        call s__UIPicture_showPlayer(s__Equipment_selector[s__Inventory_pid[inv]],Player(s__Inventory_pid[inv]) , true , s__Inventory_camera[inv])
        
        if ( itemId > 0 ) then
            set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[equip]+slot]]=s___Equipment_itemId[s__Equipment_itemId[equip]+slot]
            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[(inv)]]], (GetObjectName(itemId)), 10 * 0.0023) // INLINED!!
            call s__InvItem_buildDescription((LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), ((itemId)))),s__Inventory_owner[inv]) // INLINED!!
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxCost[s__Inventory_pid[(inv)]]], ("|cffffcc00" + I2S(s__InvItem_cost[(LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), ((itemId))))]) + "|r"), 8 * 0.0023) // INLINED!!
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[(inv)]],(s__Inventory_localInt(s__Inventory_pid[inv] , GetItemIcon(itemId) , s__Inventory_ICON_TRANSPARENT))) // INLINED!!
            
            set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[equip]+slot]]=0
        endif
        
        // display tooltip
        set s__Inventory_TOOLTIP_X=s__UIButton_minx[but] - 0.4
        set s__Inventory_TOOLTIP_Y=s__UIButton_miny[but] - 0.08
        
        call s__Inventory_showTooltip(inv , itemId > 0)

        return false
    endfunction
    
    function EquipmentCore__Init takes nothing returns nothing
        set EquipmentCore_FuncLClickSlot=Filter(function EquipmentCore__LClickItemSlot)
        set EquipmentCore_FuncRClickSlot=Filter(function EquipmentCore__RClickItemSlot)
        call TriggerAddAction(s__Inventory_ExecL, (function EquipmentCore__OnInventoryItemClick)) // INLINED!!
        call TriggerAddAction(s__Inventory_ExecR, (function EquipmentCore__OnInventoryItemRightClick)) // INLINED!!
    endfunction











//============================================================================
// SpellEffectEvent
// - Version 1.1.0.0
//
// API
// ---
//     RegisterSpellEffectEvent(integer abil, code onCast)
//
// Requires
// --------
//     RegisterPlayerUnitEvent: hiveworkshop.com/forums/showthread.php?t=203338
//
// Optional
// --------
//     Table: hiveworkshop.com/forums/showthread.php?t=188084
//




// TerrainDev local instrumentation, Classic 1.27b. See docs/planes/multiboard-misiles.md.
// Hooks only observe: never kill, unpause, move or recycle gameplay objects.

















    
    function CustomItemCondition takes nothing returns boolean
        local integer id= GetUnitTypeId(s__InvItem_eventUnit)
        return ( id == 'Hpal' or id == 'Obla' ) // Paladin or Blademaster
    endfunction
    
    function InvItemSetups___Init takes nothing returns nothing
        local integer itm
        
        // The more verbose way to delcare items:
        // Crown of Kings +5
        set itm=CreateInvItem('ckng' , 'B00G' , 1000 , 0 , "Increases the Strength, Intelligence, and Agility of the Hero by 5 when worn.")
        set s__InvItem_slot[itm]=1
        set s__InvItem_reqUnitType[itm]='Hpal'
        set s__InvItem_reqLevel[itm]=3
        set s__InvItem_maxSockets[itm]=1
        
        call s__InvItem_addBonus(itm,BONUS_STRENGTH , 5)
        call s__InvItem_addBonus(itm,BONUS_AGILITY , 5)
        call s__InvItem_addBonus(itm,BONUS_INTELLIGENCE , 5)
        
        // with string parser
        // Claws of Attack +15
        call sc___prototype76_execute(1,'ratf' , "Increases the attack damage of the Hero by 15 when worn.^type=weapon; class=1h; maxsock=1; icon='D009'; cost=28; ^dmg=15;0;0;")
        
        // Robe of the Last Guardian
        call sc___prototype76_execute(1,'I007' , "Powerful magic robe.^type=armor; lvl=10; icon=B00Z; utype='Ulic'; cost=600; maxsock=2; ^def=0;10;20; int=20;0;5; life=300;0;0;")
        
        // Gems
        call sc___prototype76_execute(1,'I009' , "Can be socketed..^type=gem; icon=B012; cost=600; ^life=0;10;50;")
        call sc___prototype76_execute(1,'I00A' , "Can be socketed..^type=gem; icon=B013; cost=600; ^mana=0;5;35;")
        
        // two lines
        // Mask of Death
        set itm=CreateInvItem('modt' , 'D02Z' , 1000 , 0 , "While wearing this mask, a Hero will recover hit points equal to 50% of the attack damage dealt to an enemy unit.")
        set itm=SetEquipItemStats(1 , 0 , 'AIva' , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , itm)
        set s__InvItem_maxSockets[itm]=1
        
        // Orb of Frost
        set itm=CreateInvItem('ofro' , 'D04U' , 1000 , 'A003' , " Adds 6 bonus cold damage to the attack of a Hero when carried. The Hero's attacks also become ranged when attacking air and slow the movement speed and attack rate of the enemy for 1 second.")
    
        // Boots of Quel'Thalas +6
        set itm=CreateInvItem('belv' , 'B00I' , 500 , 0 , " Increases the Agility of the Hero by 6 when worn.")
        set s__InvItem_slot[itm]=11
        call s__InvItem_addBonus(itm,BONUS_AGILITY , 6)
        set s__InvItem_maxSockets[itm]=1
        
        // Belt of Giant Strength +6
        set itm=CreateInvItem('bgst' , 'B00J' , 500 , 0 , " Increases the Strength of the Hero by 6 when worn.")
        set s__InvItem_slot[itm]=4
        call s__InvItem_addBonus(itm,BONUS_STRENGTH , 6)
        set s__InvItem_maxSockets[itm]=1
        
        // Gauntlets of Ogre Strength +3
        set itm=CreateInvItem('rst1' , 'B00K' , 100 , 0 , " Increases the Strength of the Hero by 3 when worn.")
        set s__InvItem_slot[itm]=9
        call s__InvItem_addBonus(itm,BONUS_STRENGTH , 3)
        set s__InvItem_maxSockets[itm]=1
        
        // Necklace of Spell Immunity
        set itm=CreateInvItem('nspi' , 'B00L' , 1000 , 0 , " Renders the Hero invulnerable to magic.")
        set s__InvItem_slot[itm]=7
        set s__InvItem_equipAbility[itm]='AImx'
        set s__InvItem_maxSockets[itm]=1
        
        // Runed Bracers
        set itm=CreateInvItem('brac' , 'B00M' , 400 , 0 , " Reduces Magic damage dealt to the Hero by 33%.")
        set s__InvItem_slot[itm]=10
        set s__InvItem_equipAbility[itm]='AIsr'
        set s__InvItem_maxSockets[itm]=1
        
        // Ring of Protection +4
        set itm=CreateInvItem('rde3' , 'B00O' , 500 , 0 , " Increases the armor of the Hero by 4 when worn.")
        set s__InvItem_slot[itm]=6
        set s__InvItem_slotAlt[itm]=12
        call s__InvItem_addBonus(itm,BONUS_ARMOR , 4)
        set s__InvItem_maxSockets[itm]=1
        
        // Pauldron
        set itm=CreateInvItem('V001' , 'B00P' , 600 , 0 , " Increases the armor of the Hero by 4 when worn.")
        set s__InvItem_slot[itm]=2
        set s__InvItem_slotAlt[itm]=8
        call s__InvItem_addBonus(itm,BONUS_ARMOR , 4)
        set s__InvItem_maxSockets[itm]=1
        
        // Battlescarred Shoulderplate
        set itm=CreateInvItem('I003' , 'B00V' , 600 , 0 , " Increases the armor by 4 and strenght by 2 when worn.")
        set s__InvItem_slot[itm]=2
        set s__InvItem_slotAlt[itm]=8
        set s__InvItem_reqUnitType[itm]='Hpal'
        set s__InvItem_reqLevel[itm]=3
        call s__InvItem_addBonus(itm,BONUS_ARMOR , 4)
        call s__InvItem_addBonus(itm,BONUS_STRENGTH , 2)
        set s__InvItem_maxSockets[itm]=1
        
        // Lich Mantle
        set itm=CreateInvItem('I006' , 'B00Y' , 600 , 0 , " Increases Intelligence by 3 and Health by 50 when worn.")
        set s__InvItem_slot[itm]=2
        set s__InvItem_slotAlt[itm]=8
        set s__InvItem_reqUnitType[itm]='Ulic'
        set s__InvItem_reqLevel[itm]=3
        call s__InvItem_addBonus(itm,BONUS_INTELLIGENCE , 3)
        call s__InvItem_addBonus(itm,BONUS_LIFE , 50)
        set s__InvItem_maxSockets[itm]=1
        
        // Armor
        set itm=CreateInvItem('I001' , 'B00Q' , 600 , 0 , " Increases armor by 8 and life by 100 when worn.")
        set s__InvItem_slot[itm]=3
        call s__InvItem_addBonus(itm,BONUS_ARMOR , 8)
        call s__InvItem_addBonus(itm,BONUS_LIFE , 100)
        set s__InvItem_maxSockets[itm]=1
        
        // Silverhand Cuirass
        set itm=CreateInvItem('I004' , 'B00W' , 600 , 0 , " Increases armor by 10 and life by 150 when worn.")
        set s__InvItem_slot[itm]=3
        set s__InvItem_reqUnitType[itm]='Hpal'
        set s__InvItem_reqLevel[itm]=2
        call s__InvItem_addBonus(itm,BONUS_ARMOR , 10)
        call s__InvItem_addBonus(itm,BONUS_LIFE , 150)
        set s__InvItem_maxSockets[itm]=2
        
        // Pants
        set itm=CreateInvItem('I002' , 'B00R' , 600 , 0 , "Increases Strength by 3 when worn.")
        set s__InvItem_slot[itm]=5
        call s__InvItem_addBonus(itm,BONUS_STRENGTH , 3)
        set s__InvItem_maxSockets[itm]=1
        
        // Golden Legguards
        set itm=CreateInvItem('I005' , 'B00X' , 600 , 0 , "Increases Strength by 3 and Armor by 1 when worn.")
        set s__InvItem_slot[itm]=5
        set s__InvItem_reqUnitType[itm]='Hpal'
        call s__InvItem_addBonus(itm,BONUS_STRENGTH , 2)
        call s__InvItem_addBonus(itm,BONUS_ARMOR , 1)
        set s__InvItem_maxSockets[itm]=2
        
        // Kel'Thuzard's Robe
        set itm=CreateInvItem('I008' , 'B010' , 600 , 0 , "Increases Intelligence by 5, Health by 40, and Mana by 50 when worn.")
        set s__InvItem_slot[itm]=3
        set s__InvItem_reqUnitType[itm]='Ulic'
        call s__InvItem_addBonus(itm,BONUS_INTELLIGENCE , 5)
        call s__InvItem_addBonus(itm,BONUS_LIFE , 40)
        call s__InvItem_addBonus(itm,BONUS_MANA , 50)
        set s__InvItem_maxSockets[itm]=1
        
        // Searing Blade
        set itm=CreateInvItem('srbd' , 'V000' , 1650 , 0 , "Adds 10 bonus fire damage to the attack of a Hero when carried. The Hero's attacks also do splash damage to nearby enemy units.")
        set s__InvItem_slot[itm]=13
        set s__InvItem_equipAbility[itm]='AIfw'
        set s__InvItem_equipCondition[itm]=Filter(function CustomItemCondition)
        set s__InvItem_equipConditionStrPrefix[itm]="Usable"
        set s__InvItem_equipConditionStr[itm]="PL or BM"
        set s__InvItem_maxSockets[itm]=3
        
        // Shield of Honor
        set itm=CreateInvItem('shhn' , 'B001' , 3350 , 0 , "|cff8b00ffUnique|r\nGrants nearby friendly units a 10% bonus to attack damage. Also increases the armor of the Hero by 8 when worn.")
        set s__InvItem_slot[itm]=14
        set s__InvItem_equipAbility[itm]='AIcd'
        call s__InvItem_addBonus(itm,BONUS_ARMOR , 8)
        set s__InvItem_maxSockets[itm]=2
        
        // Dagger of Escape
        set itm=CreateInvItem('desc' , 'B002' , 400 , 0 , "Allows the Hero to teleport a short distance.")
        set s__InvItem_slot[itm]=13
        set s__InvItem_slotAlt[itm]=14
        set s__InvItem_reqUnitType[itm]='Edem'
        set s__InvItem_equipAbility[itm]='AIbk'
        set s__InvItem_maxSockets[itm]=1
    endfunction
    

    
    function AcquireItem__Actions takes nothing returns nothing
        local unit u= GetTriggerUnit()
        local item itm= GetManipulatedItem()
        local integer inv= (LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId((u)))) // INLINED!!
        local integer itemData
        local integer data
        
        if ( inv == 0 ) then
            return
        endif
        
        set itemData=(LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), ((GetItemTypeId(itm))))) // INLINED!!
        if ( itemData <= 0 ) then
            return
        endif
        
        set data=GetItemUserData(itm)
        
        if ( data == 0 ) then
            set data=s__InvCustomItem_create()
            call SetItemUserData(itm, data)
        endif
        
        set s__InvItem_tempCustomId[itemData]=data
        
        if ( s__Inventory_addItem(inv,itemData) ) then
            call RemoveItem(itm)
        else
            call UnitRemoveItem(u, itm)
        endif
        
        set itm=null
        set u=null
    endfunction

    //===========================================================================
    function AcquireItem__Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        call TriggerAddAction(t, function AcquireItem__Actions)
    endfunction



    function IsInvItm2H takes integer itm returns boolean
        return ( s__InvItem_slot[itm] == 13 and s__InvItem_slotAlt[itm] == 0 )
    endfunction
    
    function EquipItem___Actions takes nothing returns nothing
        local integer itm= InvEventItem
        local player p= InvEventPlayer
        local unit u= s__Equipment_PlayerCurrentUnit[s__User_id[(GetPlayerId((p)))]] // INLINED!!
        local integer inv= (LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId((u)))) // INLINED!!
        local integer gear= (s__Equipment_UnitsIndex[GetUnitUserData((u))]) // INLINED!!
        local boolean is2h= IsInvItm2H(itm)
        
        // 2H weapon conditions
        if ( is2h ) then
        
            if ( s___Equipment_item[s__Equipment_item[gear]+14 - 1] > 0 ) then
                call SimError(p , "You cannot equip a two-handed weapon with an offhand item.")
                call s__Equipment_unequip(gear,s___Equipment_item[s__Equipment_item[gear]+s__InvItem_slot[itm] - 1] , s__InvItem_slot[itm] - 1)
                
                if ( inv > 0 ) then
                    call s__Inventory_addItem(inv,itm)
                else
                    call SetItemUserData(UnitAddItemById(u, s__InvItem_id[itm]), s__InvItem_tempCustomId[itm])
                    set s__InvItem_tempCustomId[itm]=0
                endif
            endif
            
        elseif ( s__InvItem_slot[itm] == 14 or s__InvItem_slotAlt[itm] == 14 ) then
        
            if ( s___Equipment_item[s__Equipment_item[gear]+13 - 1] > 0 and IsInvItm2H(s___Equipment_item[s__Equipment_item[gear]+13 - 1]) ) then
                call SimError(p , "You cannot equip an offhand item with a two-handed weapon.")
                call s__Equipment_unequip(gear,s___Equipment_item[s__Equipment_item[gear]+14 - 1] , 14 - 1)
                
                if ( inv > 0 ) then
                    call s__Inventory_addItem(inv,itm)
                else
                    call SetItemUserData(UnitAddItemById(u, s__InvItem_id[itm]), s__InvItem_tempCustomId[itm])
                    set s__InvItem_tempCustomId[itm]=0
                endif
            
            endif
            
        endif
        
        set u=null
    endfunction

    //===========================================================================
    function EquipItem___Init takes nothing returns nothing
        set s__InvItem_onEquip=CreateTrigger()
        call TriggerAddAction(s__InvItem_onEquip, function EquipItem___Actions)
    endfunction



    function UnequipItem__Actions takes nothing returns nothing
        //call BJDebugMsg(GetPlayerName(InvEquipPlayer) + " unequipped " + GetObjectName(InvEquipItem.id))
    endfunction

    //===========================================================================
    function UnequipItem__Init takes nothing returns nothing
        set s__InvItem_onUnequip=CreateTrigger()
        call TriggerAddAction(s__InvItem_onUnequip, function UnequipItem__Actions)
    endfunction



    
    function SellItem___OnAgree takes nothing returns boolean
        local integer user= (GetPlayerId((GetTriggerPlayer()))) // INLINED!!
        local integer itm= SellItem___SellItem[s__User_id[user]]
        local integer slot= SellItem___SellSlot[s__User_id[user]]
        local integer inv= SellItem___SellInv[s__User_id[user]]
        
        call s__Inventory_setItem(inv,slot , 0)
        call SetPlayerState((s__User_handle[(s__Inventory_user[inv])]), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState((s__User_handle[(s__Inventory_user[inv])]), PLAYER_STATE_RESOURCE_GOLD) + s__InvItem_cost[itm]) // INLINED!!
        call DisplayTimedTextToPlayer((s__User_handle[(s__Inventory_user[inv])]), 0, 0, 15, "You sold \"" + GetObjectName(s__InvItem_id[itm]) + "\" for |cffffcc00" + I2S(s__InvItem_cost[itm]) + "|r gold.") // INLINED!!
        
        return false
    endfunction
    
    function SellItem___Actions takes nothing returns nothing
        local integer itm= InvEventItem
        local player p= InvEventPlayer
        local integer inv= s__Inventory_PlayerCurrent[s__User_id[(GetPlayerId((p)))]] // INLINED!!
        local integer slot= InvEventSlot
        
        if ( itm <= 0 ) then
            return
        endif
        
        set SellItem___SellItem[s__User_id[s__Inventory_user[inv]]]=itm
        set SellItem___SellSlot[s__User_id[s__Inventory_user[inv]]]=slot
        set SellItem___SellInv[s__User_id[s__Inventory_user[inv]]]=inv
        
        call s__Inventory_showTooltip(inv , false)
        
        call ShowYesNoDialog("Sell " + GetObjectName(s__InvItem_id[itm]) + "?" , s__Inventory_user[inv] , Filter(function SellItem___OnAgree))
    endfunction

    //===========================================================================
    function SellItem___Init takes nothing returns nothing
        set s__Inventory_onSell=CreateTrigger()
        call TriggerAddAction(s__Inventory_onSell, function SellItem___Actions)
    endfunction



    
    function DropItem__OnAgree takes nothing returns boolean
        local integer user= (GetPlayerId((GetTriggerPlayer()))) // INLINED!!
        local integer itm= DropItem__DropItem[s__User_id[user]]
        local integer slot= DropItem__DropSlot[s__User_id[user]]
        local integer inv= DropItem__DropInv[s__User_id[user]]
        
        call SetItemUserData(CreateItem(s__InvItem_id[itm], GetUnitX(s__Inventory_owner[inv]), GetUnitY(s__Inventory_owner[inv])), (LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (slot)))) // INLINED!!
        call s__Inventory_setItem(inv,slot , 0)
        
        call DisplayTimedTextToPlayer((s__User_handle[(user)]), 0, 0, 15, "You dropped \"" + GetObjectName(s__InvItem_id[itm]) + "\".") // INLINED!!
        
        return false
    endfunction
    
    function DropItem__Actions takes nothing returns nothing
        local integer itm= InvEventItem
        local player p= InvEventPlayer
        local integer inv= s__Inventory_PlayerCurrent[s__User_id[(GetPlayerId((p)))]] // INLINED!!
        local integer slot= InvEventSlot
        
        if ( itm <= 0 ) then
            return
        endif
        
        set DropItem__DropItem[s__User_id[s__Inventory_user[inv]]]=itm
        set DropItem__DropSlot[s__User_id[s__Inventory_user[inv]]]=slot
        set DropItem__DropInv[s__User_id[s__Inventory_user[inv]]]=inv
        
        call s__Inventory_showTooltip(inv , false)
        
        call ShowYesNoDialog("Drop " + GetObjectName(s__InvItem_id[itm]) + "?" , s__Inventory_user[inv] , Filter(function DropItem__OnAgree))
    endfunction

    //===========================================================================
    function DropItem__Init takes nothing returns nothing
        set s__Inventory_onDrop=CreateTrigger()
        call TriggerAddAction(s__Inventory_onDrop, function DropItem__Actions)
    endfunction



    
    function SocketItem___OnAgree takes nothing returns boolean
        local integer user= (GetPlayerId((GetTriggerPlayer()))) // INLINED!!
        local integer itm= SocketItem___SockItem[s__User_id[user]]
        local integer slot= SocketItem___SockSlot[s__User_id[user]]
        local integer inv= SocketItem___SockInv[s__User_id[user]]
        local integer socketItm= (LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (slot))) // INLINED!!
        
        set s__InvItem_tempCustomId[socketItm]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (slot))) // INLINED!!
        
        if ( s__InvItem_addSocket(socketItm,itm) ) then
        

                set s__InvItem_tempCustomId[socketItm]=(LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + (( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot))) // INLINED!!

                call s__InvItem_buildDescription(socketItm,s__Inventory_owner[inv])



            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[(inv)]]], (GetObjectName(s__InvItem_id[socketItm])), 10 * 0.0023) // INLINED!!
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxCost[s__Inventory_pid[(inv)]]], ("|cffffcc00" + I2S(s__InvItem_cost[(LoadInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), ((s__InvItem_id[socketItm]))))]) + "|r"), 8 * 0.0023) // INLINED!!
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[(inv)]],(s__Inventory_localInt(s__Inventory_pid[inv] , GetItemIcon(s__InvItem_id[socketItm]) , s__Inventory_ICON_TRANSPARENT))) // INLINED!!
            
            call s__Inventory_showTooltip(inv , true)
            
            call s__Inventory_setItem(inv,SocketItem___SockLast[s__User_id[user]] , 0)
        endif
        
        return false
    endfunction
    
    function SocketItem___Actions takes nothing returns nothing
        local integer inv= SocketInv
        local integer itm= (LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (SocketLast))) // INLINED!!
        local integer socketItm= (LoadInteger(s__Inventory_Hashtable, (inv), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + (SocketSlot))) // INLINED!!
        
        set SocketItem___SockItem[s__User_id[s__Inventory_user[inv]]]=itm
        set SocketItem___SockSlot[s__User_id[s__Inventory_user[inv]]]=SocketSlot
        set SocketItem___SockInv[s__User_id[s__Inventory_user[inv]]]=SocketInv
        set SocketItem___SockLast[s__User_id[s__Inventory_user[inv]]]=SocketLast
        
        call s__Inventory_showTooltip(inv , false)
        
        call ShowYesNoDialog("Socket " + GetObjectName(s__InvItem_id[itm]) + " into " + GetObjectName(s__InvItem_id[socketItm]) + "?" , s__Inventory_user[inv] , Filter(function SocketItem___OnAgree))
    endfunction

    //===========================================================================
    function SocketItem___Init takes nothing returns nothing
        set s__Equipment_onSocket=CreateTrigger()
        call TriggerAddAction(s__Equipment_onSocket, function SocketItem___Actions)
    endfunction



    function HideInventory__OnIndex takes nothing returns boolean
        local unit u= (s__UnitDex_Unit[s__UnitDex_LastIndex]) // INLINED!!
        local integer inv= (LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId((u)))) // INLINED!!
        local unit u2= s__Equipment_unit[(s__Equipment_UnitsIndex[GetUnitUserData((s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]]))])] // INLINED!!

        if inv == 0 then
            set u=null
            return false
        endif

        if ( u == u2 and u != null ) then
            call s__Equipment_show((s__Equipment_UnitsIndex[GetUnitUserData((u2))]),false , PlayerCamera[s__Inventory_pid[inv]]) // INLINED!!
        endif
        
        if ( s__Inventory_PlayerCurrent[s__Inventory_pid[inv]] == inv ) then
            call s__Inventory_show(inv,false , PlayerCamera[s__Inventory_pid[inv]])
        endif
        
        return false
    endfunction
    
    function HideInventory__OnDeath takes nothing returns nothing
        local unit u= GetTriggerUnit()
        local integer inv= (LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId((u)))) // INLINED!!
        local unit u2= s__Equipment_unit[(s__Equipment_UnitsIndex[GetUnitUserData((s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]]))])] // INLINED!!
        
        if inv == 0 then
            set u=null
            return
        endif

        if ( u == u2 and u != null ) then
            call s__Equipment_show((s__Equipment_UnitsIndex[GetUnitUserData((u2))]),false , PlayerCamera[s__Inventory_pid[inv]]) // INLINED!!
        endif
        
        if ( s__Inventory_PlayerCurrent[s__Inventory_pid[inv]] == inv ) then
            call s__Inventory_show(inv,false , PlayerCamera[s__Inventory_pid[inv]])
        endif
    endfunction
    
    function HideInventory__Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddAction(t, function HideInventory__OnDeath)
        
call TriggerAddCondition(UnitDex___IndexTrig[EVENT_UNIT_DEINDEX], Filter((function HideInventory__OnIndex))) // INLINED!!
    endfunction











//TESH.scrollpos=0
//TESH.alwaysfold=0

//TESH.scrollpos=172
//TESH.alwaysfold=0

//TESH.scrollpos=0
//TESH.alwaysfold=0

//TESH.scrollpos=9
//TESH.alwaysfold=0

//TESH.scrollpos=9
//TESH.alwaysfold=0

//TESH.scrollpos=0
//TESH.alwaysfold=0



//TESH.scrollpos=0
//TESH.alwaysfold=0


// Integration of TriggerHappy's InventorySys 1.4.1 into the TerrainDev copy.
// Original terrain, placed units, melee initialization and missile sources retained.

    function TerrainInventory___ToggleInventory takes integer pid returns nothing
        local integer inv= (LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId((PlayerHero[pid])))) // INLINED!!
        if inv != 0 then
            call s__Inventory_show(inv,not s__Inventory_displayed[inv] , PlayerCamera[pid])
        endif
    endfunction

    function TerrainInventory___ToggleEquipment takes integer pid returns nothing
        local integer eq= (s__Equipment_UnitsIndex[GetUnitUserData((PlayerHero[pid]))]) // INLINED!!
        if eq != 0 then
            call s__Equipment_show(eq,not s__Equipment_displayed[eq] , PlayerCamera[pid])
        endif
    endfunction

    function TerrainInventory___Spell takes nothing returns nothing
        local unit u= GetTriggerUnit()
        local integer pid= GetPlayerId(GetOwningPlayer(u))
        if u == PlayerHero[pid] then
            if GetSpellAbilityId() == 'A001' then
                call TerrainInventory___ToggleEquipment(pid)
            elseif GetSpellAbilityId() == 'A002' then
                call TerrainInventory___ToggleInventory(pid)
            endif
        endif
        set u=null
    endfunction

    function TerrainInventory___Chat takes nothing returns nothing
        local integer pid= GetPlayerId(GetTriggerPlayer())
        local string s= GetEventPlayerChatString()
        if s == "-inventario" then
            call TerrainInventory___ToggleInventory(pid)
        elseif s == "-equipo" then
            call TerrainInventory___ToggleEquipment(pid)
        elseif s == "-ui" then
            call TerrainInventory___ToggleInventory(pid)
            call TerrainInventory___ToggleEquipment(pid)
        elseif s == "-ayudaui" then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 30, "Inventario: -inventario / Equipo: -equipo / Ambos: -ui. Clic izquierdo: seleccionar. Clic derecho: equipar o quitar. Botones laterales: paginas, soltar y vender. Los requisitos del objeto se conservan.")
        endif
    endfunction

    function TerrainInventory___Start takes nothing returns nothing
        local integer pid= 0
        local unit u
        local integer eq
        local integer inv
        local real x
        local real y
        loop
            exitwhen pid == 12
            if GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER then
                set x=GetStartLocationX(GetPlayerStartLocation(Player(pid)))
                set y=GetStartLocationY(GetPlayerStartLocation(Player(pid)))
                set PlayerCamera[pid]=s__Camera_create()
                set u=CreateUnit(Player(pid), 'Hpal', x + 220, y, 270)
                set PlayerHero[pid]=u
                set eq=s__Equipment_create(u)
                set inv=s__Inventory_create(u)
                call UnitAddAbility(u, 'A001')
                call UnitAddAbility(u, 'A002')
                call UnitAddItemById(u, 'ckng')
                call UnitAddItemById(u, 'ratf')
                call UnitAddItemById(u, 'belv')
                call UnitAddItemById(u, 'bgst')
                call UnitAddItemById(u, 'rde3')
                call UnitAddItemById(u, 'I004')
                call UnitAddItemById(u, 'I009')
                call UnitAddItemById(u, 'I00A')
                call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(pid), bj_ALLIANCE_ALLIED_VISION)
                call SetPlayerAllianceStateBJ(Player(pid), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_ALLIED_VISION)
                if GetLocalPlayer() == Player(pid) then
                    call ClearSelection()
                    call SelectUnit(u, true)
                    call PanCameraToTimed(x + 220, y, 0)
                endif
                call DisplayTimedTextToPlayer(Player(pid), 0, 0, 25, "TerrainDev + InventorySys 1.4.1. -ui abre inventario y equipo; -ayudaui muestra controles. Heroe de integracion con ocho objetos de la demo.")
            endif
            set pid=pid + 1
        endloop
        call DestroyTimer(GetExpiredTimer())
        set u=null
    endfunction

    function TerrainInventory___Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        local trigger c= CreateTrigger()
        local integer i= 0
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t, function TerrainInventory___Spell)
        loop
            exitwhen i == 12
            call TriggerRegisterPlayerChatEvent(c, Player(i), "-", false)
            set i=i + 1
        endloop
        call TriggerAddAction(c, function TerrainInventory___Chat)
        // Wait until native melee setup and original item definitions have run.
        call TimerStart(CreateTimer(), 0.20, false, function TerrainInventory___Start)
    endfunction




//===========================================================================
// 
// Swamped Temple_v2
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Wed Oct 21 01:40:22 2026
//   Map Author: Kai Trausenegger / Anomines
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
endfunction

//***************************************************************************
//*
//*  Map Item Tables
//*
//***************************************************************************

function ItemTable000000_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('tdx2', 25)
        call RandomDistAddItem('tin2', 25)
        call RandomDistAddItem('tpow', 25)
        call RandomDistAddItem('tst2', 25)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction


//***************************************************************************
//*
//*  Unit Item Tables
//*
//***************************************************************************

function Unit000003_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000007_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000022_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000029_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000031_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000032_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000038_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('I000', 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000039_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('texp', 20)
        call RandomDistAddItem('tdx2', 20)
        call RandomDistAddItem('tin2', 20)
        call RandomDistAddItem('tpow', 20)
        call RandomDistAddItem('tst2', 20)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000043_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000046_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000048_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000054_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000055_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000056_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000067_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000068_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000070_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000072_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000077_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('tdx2', 25)
        call RandomDistAddItem('tin2', 25)
        call RandomDistAddItem('tpow', 25)
        call RandomDistAddItem('tst2', 25)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000079_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000080_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000081_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000083_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000084_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('tdx2', 25)
        call RandomDistAddItem('tin2', 25)
        call RandomDistAddItem('tpow', 25)
        call RandomDistAddItem('tst2', 25)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000085_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('rhe1', 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000090_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000095_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000104_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction


//***************************************************************************
//*
//*  Sounds
//*
//***************************************************************************

function InitSounds takes nothing returns nothing
    set gg_snd_WaterWaterFallLoop1=CreateSound("Sound\\Ambient\\DoodadEffects\\WaterWaterFallLoop1.wav", true, true, true, 30, 30, "DoodadsEAX")
    call SetSoundParamsFromLabel(gg_snd_WaterWaterFallLoop1, "WaterfallLoop")
    call SetSoundDuration(gg_snd_WaterWaterFallLoop1, 1022)
    call SetSoundVolume(gg_snd_WaterWaterFallLoop1, 127)
    set gg_snd_FreakyForest4=CreateSound("Sound\\Ambient\\Ashenvale\\FreakyForest4.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundParamsFromLabel(gg_snd_FreakyForest4, "FreakyForest4")
    call SetSoundDuration(gg_snd_FreakyForest4, 5248)
    call SetSoundVolume(gg_snd_FreakyForest4, 90)
endfunction

//***************************************************************************
//*
//*  Regions
//*
//***************************************************************************

function CreateRegions takes nothing returns nothing
    local weathereffect we

    set gg_rct_Region_001=Rect(- 3776.0, - 704.0, - 3136.0, - 32.0)
    set we=AddWeatherEffect(gg_rct_Region_001, 'LRma')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_000=Rect(- 1248.0, - 1600.0, 608.0, 256.0)
    set we=AddWeatherEffect(gg_rct_Region_000, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_002=Rect(2208.0, 1984.0, 2528.0, 2272.0)
    set we=AddWeatherEffect(gg_rct_Region_002, 'LRaa')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_003=Rect(- 2656.0, - 5568.0, - 2240.0, - 5248.0)
    set we=AddWeatherEffect(gg_rct_Region_003, 'LRaa')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_004=Rect(- 5920.0, - 2272.0, - 4352.0, - 288.0)
    call SetSoundPosition(gg_snd_WaterWaterFallLoop1, - 5136.0, - 1280.0, 175.4)
    call RegisterStackedSound(gg_snd_WaterWaterFallLoop1, true, 1568.0, 1984.0)
    set gg_rct_Region_005=Rect(160.0, 384.0, 672.0, 896.0)
    set we=AddWeatherEffect(gg_rct_Region_005, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_006=Rect(896.0, - 192.0, 1216.0, 64.0)
    set we=AddWeatherEffect(gg_rct_Region_006, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_007=Rect(- 1568.0, - 480.0, - 1312.0, - 128.0)
    set we=AddWeatherEffect(gg_rct_Region_007, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_008=Rect(2016.0, 1760.0, 2784.0, 2496.0)
    set we=AddWeatherEffect(gg_rct_Region_008, 'FDbl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_008_Copy=Rect(2272.0, 2048.0, 3040.0, 2784.0)
    set we=AddWeatherEffect(gg_rct_Region_008_Copy, 'FDbh')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_010=Rect(- 2848.0, 5408.0, - 2752.0, 5472.0)
    set we=AddWeatherEffect(gg_rct_Region_010, 'LRma')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_003_Copy=Rect(- 5344.0, - 2880.0, - 4928.0, - 2560.0)
    set we=AddWeatherEffect(gg_rct_Region_003_Copy, 'LRaa')
    call EnableWeatherEffect(we, true)
endfunction

//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: Melee Initialization
//
// Default melee game initialization for all players
//===========================================================================
function Trig_Melee_Initialization_Actions takes nothing returns nothing
    call MeleeStartingVisibility()
    call MeleeStartingHeroLimit()
    call MeleeGrantHeroItems()
    call MeleeStartingResources()
    call MeleeClearExcessUnits()
    call MeleeStartingUnits()
    call MeleeStartingAI()
    call MeleeInitVictoryDefeat()
endfunction

//===========================================================================
function InitTrig_Melee_Initialization takes nothing returns nothing
    set gg_trg_Melee_Initialization=CreateTrigger()
    call TriggerAddAction(gg_trg_Melee_Initialization, function Trig_Melee_Initialization_Actions)
endfunction

//===========================================================================
// Trigger: TurtleNet
//===========================================================================
function Trig_TurtleNet_Actions takes nothing returns nothing
endfunction

//===========================================================================
function InitTrig_TurtleNet takes nothing returns nothing
    set gg_trg_TurtleNet=CreateTrigger()
    call TriggerRegisterUnitEvent(gg_trg_TurtleNet, gg_unit_ntrd_0023, EVENT_UNIT_TARGET_IN_RANGE)
    call TriggerAddAction(gg_trg_TurtleNet, function Trig_TurtleNet_Actions)
endfunction

//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    call InitTrig_Melee_Initialization()
    call InitTrig_TurtleNet()
endfunction

//===========================================================================
function RunInitializationTriggers takes nothing returns nothing
    call ConditionalTriggerExecute(gg_trg_Melee_Initialization)
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(1), true)
    call SetPlayerController(Player(1), MAP_CONTROL_USER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_007
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerTeam(Player(1), 0)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 1)
    call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 1)
    call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 27776.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 27776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6400.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 6144.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 27776.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 6144.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 6400.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 27776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call SetTerrainFogEx(0, 1900.0, 4000.0, 0.150, 1.000, 1.000, 0.000)
    call SetWaterBaseColor(0, 255, 255, 255)
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("SunkenRuinsDay")
    call SetAmbientNightSound("SunkenRuinsNight")
    call SetMapMusic("Music", true, 0)
    call InitSounds()
    call CreateRegions()
    call InitBlizzard()

    call ExecuteFunc("jasshelper__init2895")


    call ExecuteFunc("jasshelper__init3735")

    call InitGlobals()
    call InitCustomTriggers()
    call ConditionalTriggerExecute(gg_trg_Melee_Initialization) // INLINED!!

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_001")
    call SetMapDescription("TRIGSTR_003")
    call SetPlayers(2)
    call SetTeams(2)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, - 5376.0, 2688.0)
    call DefineStartLocation(1, 2944.0, - 5696.0)

    // Player setup
    call InitCustomPlayerSlots()
    call SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
    call InitGenericPlayerSlots()
    call InitAllyPriorities()
endfunction




//All initializer functions called in proper order:

function jasshelper__init3735 takes nothing returns nothing



endfunction



// UI Studio | Warcraft III 1.27b | InventorySys 1.4.1
// Import this library alongside UserInterface. Call factories synchronously.
// Factories create controls; existing inventory callbacks must be retained.
// Example: UIStudioButton("inventory.slot.0", runtimeTexture).
// Pass -1 to use the designed texture; pass 0 for no texture.
// Dynamic show()/tooltip code must use UIStudioX/Y to retain edited positions.
// Model heroes are metadata only; keep Equipment.charModel and its attachment.



//All initializer functions called in proper order:

//Functions for BigArrays:
function sa__InventoryTable___GTable_onDestroy takes nothing returns boolean
local integer this=f__arg_this
            call FlushChildHashtable(InventoryTable___ht, ((this))) // INLINED!!
   return true
endfunction
function sa__UnitMaxStateBonuses___BonusValues_onDestroy takes nothing returns boolean
local integer this=f__arg_this
        set s__UnitMaxStateBonuses___BonusValues_owners[(GetUnitUserData((s__UnitMaxStateBonuses___BonusValues_owner[this])))]=(0) // INLINED!!
        set s__UnitMaxStateBonuses___BonusValues_owner[this]=null
   return true
endfunction
function sa__InventoryTable__getindex takes nothing returns boolean
local integer this=f__arg_this
local integer key=f__arg_integer1
set f__result_integer= LoadInteger(InventoryTable___ht, (this), key)
   return true
endfunction
function sa__InventoryTable__setindex takes nothing returns boolean
local integer this=f__arg_this
local integer key=f__arg_integer1
local integer value=f__arg_integer2
            call SaveInteger(InventoryTable___ht, (this), key, value)
   return true
endfunction
function sa__RegenBonuses__BonusValues_onDestroy takes nothing returns boolean
local integer this=f__arg_this
        set s__RegenBonuses__BonusValues_owners[(GetUnitUserData((s__RegenBonuses__BonusValues_owner[this])))]=(0) // INLINED!!
        set s__RegenBonuses__BonusValues_all[s__RegenBonuses__BonusValues_index[this]]=s__RegenBonuses__BonusValues_all[s__RegenBonuses__BonusValues_count]
        set s__RegenBonuses__BonusValues_count=s__RegenBonuses__BonusValues_count - 1
        if s__RegenBonuses__BonusValues_count == 0 then
            call PauseTimer(RegenBonuses__regenTimer)
        endif
        set s__RegenBonuses__BonusValues_owner[this]=null
   return true
endfunction
function sa__MovementBonus__BonusValue_onDestroy takes nothing returns boolean
local integer this=f__arg_this
        set s__MovementBonus__BonusValue_owners[(GetUnitUserData((s__MovementBonus__BonusValue_owner[this])))]=(0) // INLINED!!
        set s__MovementBonus__BonusValue_all[s__MovementBonus__BonusValue_index[this]]=s__MovementBonus__BonusValue_all[s__MovementBonus__BonusValue_count]
        set s__MovementBonus__BonusValue_count=s__MovementBonus__BonusValue_count - 1
        set s__MovementBonus__BonusValue_owner[this]=null
   return true
endfunction
function sa__Inventory_setTooltipLine takes nothing returns boolean
local integer pid=f__arg_integer1
local integer line=f__arg_integer2
local string str=f__arg_string1
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[(pid)*(16)+line]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
   return true
endfunction
function sa__Inventory_setTooltipSlot takes nothing returns boolean
local integer pid=f__arg_integer1
local integer line=f__arg_integer2
local string str=f__arg_string1
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[(pid)*(16)+s__Inventory_TOOLTIP_LINES_MAX - 1]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
   return true
endfunction
function sa__Inventory_clearLines takes nothing returns boolean
local integer pid=f__arg_integer1
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[(pid)*(16)+i]], "", s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
                set i=i + 1
            endloop
   return true
endfunction
function sa__UIText_show takes nothing returns boolean
local integer this=f__arg_this
local boolean show=f__arg_boolean1
local integer Cam=f__arg_integer1
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
   return true
endfunction
function sa__UIPicture_show takes nothing returns boolean
local integer this=f__arg_this
local boolean show=f__arg_boolean1
local integer Cam=f__arg_integer1
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
   return true
endfunction
function sa__UIButton_show takes nothing returns boolean
local integer this=f__arg_this
local boolean flag=f__arg_boolean1
local integer Cam=f__arg_integer1
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
   return true
endfunction
function sa__BonusModStruct_addBonus takes nothing returns boolean
    set f__result_integer=s__BonusModStruct_addBonus(f__arg_unit1,f__arg_integer1,f__arg_integer2)
   return true
endfunction
function sa__UnitDex_Remove takes nothing returns boolean
    set f__result_boolean=s__UnitDex_Remove(f__arg_unit1,f__arg_boolean1)
   return true
endfunction
function sa__InvCustomItem_seed takes nothing returns boolean
local integer this=f__arg_this
set f__result_integer= (LoadInteger(InventoryTable___ht, ((s__InvCustomItem_SeedTable)), (this))) // INLINED!!
   return true
endfunction
function sa__InvItem__get_sockets takes nothing returns boolean
local integer this=f__arg_this
set f__result_integer= LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket___KEY_SOCKETS_COUNT * 100)
   return true
endfunction
function sa__InvItem_socketId takes nothing returns boolean
local integer this=f__arg_this
local integer index=f__arg_integer1
set f__result_integer= LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket___KEY_SOCKETS_ID * 100 ) + index)
   return true
endfunction
function sa__InvItem_getSocket takes nothing returns boolean
local integer this=f__arg_this
local integer index=f__arg_integer1
            if s__InvItem_isSocket[this] then
set f__result_integer= 0
return true
            endif
set f__result_integer= LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket___KEY_SOCKETS * 100 ) + index)
   return true
endfunction
function sa__Bonus_create takes nothing returns boolean

        local integer this= s__Bonus__allocate()
        set s__Bonus_BonusMod___isBonusObject[this]=true
set f__result_integer= this
   return true
endfunction
function sa__Bonus_setBonus takes nothing returns boolean
    set f__result_integer=s__Bonus_setBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__Bonus_getBonus takes nothing returns boolean
    set f__result_integer=s__Bonus_getBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__Bonus_removeBonus takes nothing returns boolean
    call sc__Bonus_setBonus((f__arg_this),(f__arg_unit1) , 0) // INLINED!!
   return true
endfunction
function sa__Bonus_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__Bonus_isValidBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus takes nothing returns boolean
    call s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus((f__arg_this),(f__arg_unit1) , 0) // INLINED!!
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__BonusMod___AbilityBonus_create takes nothing returns boolean
local integer rawcode=f__arg_integer1
local integer count=f__arg_integer2
local integer negativeRawcode=f__arg_integer3
local boolean heroesOnly=f__arg_boolean1
        local integer bonus= s__BonusMod___AbilityBonus__allocate()
        local integer i
        if BonusMod___powersOf2Count < count then
            set i=BonusMod___powersOf2Count
            loop
                exitwhen i > count
                set BonusMod___powersOf2[i]=2 * BonusMod___powersOf2[i - 1]
                set i=i + 1
            endloop
            set BonusMod___powersOf2Count=count
        endif
            set i=0
            loop
                exitwhen i == count
                call UnitAddAbility(xepreload__dum, ((rawcode + i))) // INLINED!!
                set i=i + 1
            endloop
            if negativeRawcode != 0 then
                call UnitAddAbility(xepreload__dum, ((negativeRawcode))) // INLINED!!
            endif
        set s__BonusMod___AbilityBonus_count[bonus]=count
        set s__BonusMod___AbilityBonus_negativeRawcode[bonus]=negativeRawcode
        set s__BonusMod___AbilityBonus_rawcode[bonus]=rawcode
        set s__BonusMod___AbilityBonus_heroesOnly[bonus]=heroesOnly
        if negativeRawcode != 0 then
            set s__BonusMod___BonusInterface_minBonus[bonus]=- BonusMod___powersOf2[count]
        else
            set s__BonusMod___BonusInterface_minBonus[bonus]=0
        endif
        set s__BonusMod___BonusInterface_maxBonus[bonus]=BonusMod___powersOf2[count] - 1
set f__result_integer= bonus
   return true
endfunction
function sa__BonusMod___AbilityBonus_setBonus takes nothing returns boolean
    set f__result_integer=s__BonusMod___AbilityBonus_setBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__BonusMod___AbilityBonus_getBonus takes nothing returns boolean
    set f__result_integer=s__BonusMod___AbilityBonus_getBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__BonusMod___AbilityBonus_removeBonus takes nothing returns boolean
    call s__BonusMod___AbilityBonus_removeBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__BonusMod___AbilityBonus_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__BonusMod___AbilityBonus_isValidBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__MovementBonus__MovementBonus_setBonus takes nothing returns boolean
    set f__result_integer=s__MovementBonus__MovementBonus_setBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__MovementBonus__MovementBonus_getBonus takes nothing returns boolean
    set f__result_integer=s__MovementBonus__MovementBonus_getBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__MovementBonus__MovementBonus_removeBonus takes nothing returns boolean
    call s__MovementBonus__MovementBonus_setBonus((f__arg_this),(f__arg_unit1) , 0) // INLINED!!
   return true
endfunction
function sa__MovementBonus__MovementBonus_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__MovementBonus__MovementBonus_isValidBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses__RegenBonus_life_setBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses__RegenBonus_life_setBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses__RegenBonus_life_getBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses__RegenBonus_life_getBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__RegenBonuses__RegenBonus_life_removeBonus takes nothing returns boolean
    call s__RegenBonuses__RegenBonus_life_setBonus((f__arg_this),(f__arg_unit1) , 0) // INLINED!!
   return true
endfunction
function sa__RegenBonuses__RegenBonus_life_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__RegenBonuses__RegenBonus_life_isValidBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses__RegenBonus_mana_setBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses__RegenBonus_mana_setBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses__RegenBonus_mana_getBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses__RegenBonus_mana_getBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__RegenBonuses__RegenBonus_mana_removeBonus takes nothing returns boolean
    call s__RegenBonuses__RegenBonus_mana_setBonus((f__arg_this),(f__arg_unit1) , 0) // INLINED!!
   return true
endfunction
function sa__RegenBonuses__RegenBonus_mana_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__RegenBonuses__RegenBonus_mana_isValidBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_setBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_getBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_life_getBonus(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus takes nothing returns boolean
    call s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus((f__arg_this),(f__arg_unit1) , 0) // INLINED!!
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus(f__arg_this,f__arg_unit1,f__arg_integer1)
   return true
endfunction
function sa___prototype3_TimerUtils__init takes nothing returns boolean

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
function sa___prototype46_RemoveUnitBonus takes nothing returns boolean
    call RemoveUnitBonus(f__arg_unit1,f__arg_integer1)
    return true
endfunction
function sa___prototype47_SetUnitBonus takes nothing returns boolean
    set f__result_integer=SetUnitBonus(f__arg_unit1,f__arg_integer1,f__arg_integer2)
    return true
endfunction
function sa___prototype48_GetUnitBonus takes nothing returns boolean
    set f__result_integer=GetUnitBonus(f__arg_unit1,f__arg_integer1)
    return true
endfunction
function sa___prototype43_MovementBonus__OnLeaveMap takes nothing returns boolean
    call MovementBonus__OnLeaveMap(f__arg_unit1)
    return true
endfunction
function sa___prototype43_RegenBonuses__OnLeaveMap takes nothing returns boolean
    call RegenBonuses__OnLeaveMap(f__arg_unit1)
    return true
endfunction
function sa___prototype43_UnitMaxStateBonuses___OnLeaveMap takes nothing returns boolean
    call UnitMaxStateBonuses___OnLeaveMap(f__arg_unit1)
    return true
endfunction
function sa___prototype3_EquipmentItem_Init takes nothing returns boolean

        set EquipmentItem_BonusString[BONUS_DAMAGE]="Damage"
        set EquipmentItem_BonusString[BONUS_ARMOR]="Armor"
        set EquipmentItem_BonusString[BONUS_STRENGTH]="Strength"
        set EquipmentItem_BonusString[BONUS_AGILITY]="Agility"
        set EquipmentItem_BonusString[BONUS_INTELLIGENCE]="Intelligence"
        set EquipmentItem_BonusString[BONUS_ATTACK_SPEED]="Attack Speed"
        set EquipmentItem_BonusString[BONUS_SIGHT_RANGE]="Visibility"
        set EquipmentItem_BonusString[BONUS_LIFE_REGEN]="Life Regen"
        set EquipmentItem_BonusString[BONUS_MANA_REGEN_PERCENT]="% Mana Regen"
        set EquipmentItem_BonusString[BONUS_MOVEMENT_SPEED]="Movement Speed"
        set EquipmentItem_BonusString[BONUS_LIFE]="Life"
        set EquipmentItem_BonusString[BONUS_MANA]="Mana"
    return true
endfunction
function sa___prototype76_InitEquipItem takes nothing returns boolean
 local integer itemId=f__arg_integer1
 local string data=f__arg_string1

        local integer itm= s__InvItem__allocate()
        local integer len= StringLength(data)
        local integer i= 0
        local string desc= ""
        local string param= ""
        local string array value
        local integer curVal= 0
        local string s= ""
        local integer step= 0
        set s__InvItem_id[itm]=itemId
        call SaveInteger(InventoryTable___ht, ((s__InvItem_InventoryTable)), (s__InvItem_id[itm]), ( itm)) // INLINED!!
        loop
            exitwhen i >= len
            set s=SubString(data, i, i + 1)
            if ( step > 0 and s == " " ) then
            elseif ( step == 0 ) then
                if ( s == "^" ) then
                    set step=1
                else
                    set desc=desc + s
                endif
            elseif ( step == 1 ) then
                if ( s == "^" ) then
                    set step=3
                    set param=""
                elseif ( s == "=" ) then
                    set step=2
                else
                    set param=param + s
                endif
            elseif ( step == 2 ) then
                if ( s == ";" ) then
                    call EquipItemParser__ParseParam(itm , StringCase(param, false) , value[0])
                    set param=""
                    set value[0]=""
                    set step=1
                else
                    set value[0]=value[0] + s
                endif
            elseif ( step == 3 ) then
                if ( s == "=" ) then
                    set step=4
                else
                    set param=param + s
                endif
            elseif ( step == 4 ) then
                if ( s == ";" ) then
                    set curVal=curVal + 1
                    if ( curVal >= 3 ) then
                        if ( value[0] == "" ) then
                            set value[0]="0"
                        elseif ( value[1] == "" ) then
                            set value[0]="0"
                      elseif ( value[2] == "" ) then
                            set value[0]="0"
                        endif
                        call EquipItemParser_ParseBonusParam(itm , param , value[0] , value[1] , value[2])
                        set step=3
                        set curVal=0
                        set value[0]=""
                        set value[1]=""
                        set value[2]=""
                        set param=""
                    endif
                else
                    set value[curVal]=value[curVal] + s
                endif
            endif
            set i=i + 1
        endloop
        set s__InvItem_info[itm]=desc
    set f__result_integer= itm
    return true
endfunction

function jasshelper__init2895 takes nothing returns nothing
    set st__InventoryTable___GTable_onDestroy[3]=CreateTrigger()
    set st__InventoryTable___GTable_onDestroy[4]=st__InventoryTable___GTable_onDestroy[3]
    set st__InventoryTable___GTable_onDestroy[5]=st__InventoryTable___GTable_onDestroy[3]
    set st__InventoryTable___GTable_onDestroy[6]=st__InventoryTable___GTable_onDestroy[3]
    call TriggerAddCondition(st__InventoryTable___GTable_onDestroy[3],Condition( function sa__InventoryTable___GTable_onDestroy))
    set st__UnitMaxStateBonuses___BonusValues_onDestroy=CreateTrigger()
    call TriggerAddCondition(st__UnitMaxStateBonuses___BonusValues_onDestroy,Condition( function sa__UnitMaxStateBonuses___BonusValues_onDestroy))
    set st__InventoryTable__getindex=CreateTrigger()
    call TriggerAddCondition(st__InventoryTable__getindex,Condition( function sa__InventoryTable__getindex))
    set st__InventoryTable__setindex=CreateTrigger()
    call TriggerAddCondition(st__InventoryTable__setindex,Condition( function sa__InventoryTable__setindex))
    set st__RegenBonuses__BonusValues_onDestroy=CreateTrigger()
    call TriggerAddCondition(st__RegenBonuses__BonusValues_onDestroy,Condition( function sa__RegenBonuses__BonusValues_onDestroy))
    set st__MovementBonus__BonusValue_onDestroy=CreateTrigger()
    call TriggerAddCondition(st__MovementBonus__BonusValue_onDestroy,Condition( function sa__MovementBonus__BonusValue_onDestroy))
    set st__Inventory_setTooltipLine=CreateTrigger()
    call TriggerAddCondition(st__Inventory_setTooltipLine,Condition( function sa__Inventory_setTooltipLine))
    set st__Inventory_setTooltipSlot=CreateTrigger()
    call TriggerAddCondition(st__Inventory_setTooltipSlot,Condition( function sa__Inventory_setTooltipSlot))
    set st__Inventory_clearLines=CreateTrigger()
    call TriggerAddCondition(st__Inventory_clearLines,Condition( function sa__Inventory_clearLines))
    set st__UIText_show=CreateTrigger()
    call TriggerAddCondition(st__UIText_show,Condition( function sa__UIText_show))
    set st__UIPicture_show=CreateTrigger()
    call TriggerAddCondition(st__UIPicture_show,Condition( function sa__UIPicture_show))
    set st__UIButton_show=CreateTrigger()
    call TriggerAddCondition(st__UIButton_show,Condition( function sa__UIButton_show))
    set st__BonusModStruct_addBonus=CreateTrigger()
    call TriggerAddCondition(st__BonusModStruct_addBonus,Condition( function sa__BonusModStruct_addBonus))
    set st__UnitDex_Remove=CreateTrigger()
    call TriggerAddCondition(st__UnitDex_Remove,Condition( function sa__UnitDex_Remove))
    set st__InvCustomItem_seed=CreateTrigger()
    call TriggerAddCondition(st__InvCustomItem_seed,Condition( function sa__InvCustomItem_seed))
    set st__InvItem__get_sockets=CreateTrigger()
    call TriggerAddCondition(st__InvItem__get_sockets,Condition( function sa__InvItem__get_sockets))
    set st__InvItem_socketId=CreateTrigger()
    call TriggerAddCondition(st__InvItem_socketId,Condition( function sa__InvItem_socketId))
    set st__InvItem_getSocket=CreateTrigger()
    call TriggerAddCondition(st__InvItem_getSocket,Condition( function sa__InvItem_getSocket))
    set st__Bonus_create=CreateTrigger()
    call TriggerAddCondition(st__Bonus_create,Condition( function sa__Bonus_create))
    set st__Bonus_setBonus[69]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[69],Condition( function sa__Bonus_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[69], function sa__Bonus_setBonus)
    set st__Bonus_getBonus[69]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[69],Condition( function sa__Bonus_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[69], function sa__Bonus_getBonus)
    set st__Bonus_removeBonus[69]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[69],Condition( function sa__Bonus_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[69], function sa__Bonus_removeBonus)
    set st__Bonus_isValidBonus[69]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[69],Condition( function sa__Bonus_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[69], function sa__Bonus_isValidBonus)
    set st__BonusMod___BonusInterface_onDestroy[69]=null
    set st__BonusMod___BonusInterface_onDestroy[70]=null
    set st__BonusMod___BonusInterface_onDestroy[83]=null
    set st__BonusMod___BonusInterface_onDestroy[85]=null
    set st__BonusMod___BonusInterface_onDestroy[86]=null
    set st__BonusMod___BonusInterface_onDestroy[88]=null
    set st__BonusMod___BonusInterface_onDestroy[89]=null
    set st__Bonus_setBonus[89]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[89],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[89], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus)
    set st__Bonus_getBonus[89]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[89],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[89], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus)
    set st__Bonus_removeBonus[89]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[89],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[89], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus)
    set st__Bonus_isValidBonus[89]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[89],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[89], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus)
    set st__BonusMod___AbilityBonus_create=CreateTrigger()
    call TriggerAddCondition(st__BonusMod___AbilityBonus_create,Condition( function sa__BonusMod___AbilityBonus_create))
    set st__Bonus_setBonus[70]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[70],Condition( function sa__BonusMod___AbilityBonus_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[70], function sa__BonusMod___AbilityBonus_setBonus)
    set st__Bonus_getBonus[70]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[70],Condition( function sa__BonusMod___AbilityBonus_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[70], function sa__BonusMod___AbilityBonus_getBonus)
    set st__Bonus_removeBonus[70]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[70],Condition( function sa__BonusMod___AbilityBonus_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[70], function sa__BonusMod___AbilityBonus_removeBonus)
    set st__Bonus_isValidBonus[70]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[70],Condition( function sa__BonusMod___AbilityBonus_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[70], function sa__BonusMod___AbilityBonus_isValidBonus)
    set st__Bonus_setBonus[83]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[83],Condition( function sa__MovementBonus__MovementBonus_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[83], function sa__MovementBonus__MovementBonus_setBonus)
    set st__Bonus_getBonus[83]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[83],Condition( function sa__MovementBonus__MovementBonus_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[83], function sa__MovementBonus__MovementBonus_getBonus)
    set st__Bonus_removeBonus[83]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[83],Condition( function sa__MovementBonus__MovementBonus_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[83], function sa__MovementBonus__MovementBonus_removeBonus)
    set st__Bonus_isValidBonus[83]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[83],Condition( function sa__MovementBonus__MovementBonus_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[83], function sa__MovementBonus__MovementBonus_isValidBonus)
    set st__Bonus_setBonus[85]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[85],Condition( function sa__RegenBonuses__RegenBonus_life_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[85], function sa__RegenBonuses__RegenBonus_life_setBonus)
    set st__Bonus_getBonus[85]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[85],Condition( function sa__RegenBonuses__RegenBonus_life_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[85], function sa__RegenBonuses__RegenBonus_life_getBonus)
    set st__Bonus_removeBonus[85]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[85],Condition( function sa__RegenBonuses__RegenBonus_life_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[85], function sa__RegenBonuses__RegenBonus_life_removeBonus)
    set st__Bonus_isValidBonus[85]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[85],Condition( function sa__RegenBonuses__RegenBonus_life_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[85], function sa__RegenBonuses__RegenBonus_life_isValidBonus)
    set st__Bonus_setBonus[86]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[86],Condition( function sa__RegenBonuses__RegenBonus_mana_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[86], function sa__RegenBonuses__RegenBonus_mana_setBonus)
    set st__Bonus_getBonus[86]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[86],Condition( function sa__RegenBonuses__RegenBonus_mana_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[86], function sa__RegenBonuses__RegenBonus_mana_getBonus)
    set st__Bonus_removeBonus[86]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[86],Condition( function sa__RegenBonuses__RegenBonus_mana_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[86], function sa__RegenBonuses__RegenBonus_mana_removeBonus)
    set st__Bonus_isValidBonus[86]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[86],Condition( function sa__RegenBonuses__RegenBonus_mana_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[86], function sa__RegenBonuses__RegenBonus_mana_isValidBonus)
    set st__Bonus_setBonus[88]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[88],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_life_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[88], function sa__UnitMaxStateBonuses___MaxStateBonus_life_setBonus)
    set st__Bonus_getBonus[88]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[88],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_life_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[88], function sa__UnitMaxStateBonuses___MaxStateBonus_life_getBonus)
    set st__Bonus_removeBonus[88]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[88],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[88], function sa__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus)
    set st__Bonus_isValidBonus[88]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[88],Condition( function sa__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[88], function sa__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus)
    set st___prototype3[1]=CreateTrigger()
    call TriggerAddAction(st___prototype3[1],function sa___prototype3_TimerUtils__init)
    call TriggerAddCondition(st___prototype3[1],Condition(function sa___prototype3_TimerUtils__init))
    set st___prototype46[1]=CreateTrigger()
    call TriggerAddAction(st___prototype46[1],function sa___prototype46_RemoveUnitBonus)
    call TriggerAddCondition(st___prototype46[1],Condition(function sa___prototype46_RemoveUnitBonus))
    set st___prototype47[1]=CreateTrigger()
    call TriggerAddAction(st___prototype47[1],function sa___prototype47_SetUnitBonus)
    call TriggerAddCondition(st___prototype47[1],Condition(function sa___prototype47_SetUnitBonus))
    set st___prototype48[1]=CreateTrigger()
    call TriggerAddAction(st___prototype48[1],function sa___prototype48_GetUnitBonus)
    call TriggerAddCondition(st___prototype48[1],Condition(function sa___prototype48_GetUnitBonus))
    set st___prototype43[1]=CreateTrigger()
    call TriggerAddAction(st___prototype43[1],function sa___prototype43_MovementBonus__OnLeaveMap)
    call TriggerAddCondition(st___prototype43[1],Condition(function sa___prototype43_MovementBonus__OnLeaveMap))
    set st___prototype43[2]=CreateTrigger()
    call TriggerAddAction(st___prototype43[2],function sa___prototype43_RegenBonuses__OnLeaveMap)
    call TriggerAddCondition(st___prototype43[2],Condition(function sa___prototype43_RegenBonuses__OnLeaveMap))
    set st___prototype43[3]=CreateTrigger()
    call TriggerAddAction(st___prototype43[3],function sa___prototype43_UnitMaxStateBonuses___OnLeaveMap)
    call TriggerAddCondition(st___prototype43[3],Condition(function sa___prototype43_UnitMaxStateBonuses___OnLeaveMap))
    set st___prototype3[2]=CreateTrigger()
    call TriggerAddAction(st___prototype3[2],function sa___prototype3_EquipmentItem_Init)
    call TriggerAddCondition(st___prototype3[2],Condition(function sa___prototype3_EquipmentItem_Init))
    set st___prototype76[1]=CreateTrigger()
    call TriggerAddAction(st___prototype76[1],function sa___prototype76_InitEquipItem)
    call TriggerAddCondition(st___prototype76[1],Condition(function sa___prototype76_InitEquipItem))


call ExecuteFunc("s__DummyCaster_DummyCaster___N__onInit")
//------------------------------------
call ExecuteFunc("EquipHeroModels___Init")
//------------------------------------
call ExecuteFunc("s__IsDestructableTree__I_IsDestructableTree__Inits__onInit")
//------------------------------------
call ExecuteFunc("s__User_PlayerUtils__PlayerUtilsInit___onInit")
//------------------------------------
call ExecuteFunc("SimError__init")
//------------------------------------
call ExecuteFunc("TimerUtils__init")
//------------------------------------
call ExecuteFunc("UIMath__Init")
//------------------------------------
call ExecuteFunc("s__WorldBounds_WorldBounds__WorldBoundInit___onInit")
//------------------------------------
call ExecuteFunc("s__Camera___CamInit_Camera___CamInitModule__onInit")
//------------------------------------
call ExecuteFunc("s__InvItem_onInit")
call ExecuteFunc("s__InvCustomItem_onInit")
//------------------------------------
call ExecuteFunc("MissileDiagnostics__Init")
//------------------------------------
call ExecuteFunc("s__SpellEffectEvent___S_SpellEffectEvent___M___onInit")
//------------------------------------
call ExecuteFunc("s__UnitDex_UnitDex___UnitDexCore___onInit")
//------------------------------------
call ExecuteFunc("s__xepreload__Init_xepreload__PreloadInit__onInit")
//------------------------------------
call ExecuteFunc("s__BonusModStruct_BonusMod___BonusModInitModule___onInit")
//------------------------------------
call ExecuteFunc("MissileRecycler___PreInit")
//------------------------------------
call ExecuteFunc("s__UnitMaxState___Data_UnitMaxState___UnitStatInit__onInit")
//------------------------------------
call ExecuteFunc("UserInterface__Init")
//------------------------------------
call ExecuteFunc("InventoryCore___Init")
//------------------------------------
call ExecuteFunc("s__Missile_onInit")
//------------------------------------
call ExecuteFunc("MovementBonus__OnInit")
//------------------------------------
call ExecuteFunc("RegenBonuses__OnInit")
//------------------------------------
call ExecuteFunc("UIStudioLayout__Init")
//------------------------------------
call ExecuteFunc("s__UnitMaxStateBonuses___Data_UnitMaxStateBonuses___StateInit___onInit")
//------------------------------------
call ExecuteFunc("s__YesNoDialog_YesNoDialog___INITS__onInit")
//------------------------------------
call ExecuteFunc("EquipmentItem_Init")
//------------------------------------
call ExecuteFunc("s__Equipment_onInit")
call ExecuteFunc("EquipmentCore__Init")
//------------------------------------
call ExecuteFunc("InvItemSetups___Init")
//------------------------------------
call ExecuteFunc("AcquireItem__Init")
//------------------------------------
call ExecuteFunc("EquipItem___Init")
//------------------------------------
call ExecuteFunc("UnequipItem__Init")
//------------------------------------
call ExecuteFunc("SellItem___Init")
//------------------------------------
call ExecuteFunc("DropItem__Init")
//------------------------------------
call ExecuteFunc("SocketItem___Init")
//------------------------------------
call ExecuteFunc("HideInventory__Init")
//------------------------------------
call ExecuteFunc("TerrainInventory___Init")
//------------------------------------

endfunction

