globals
//globals from EquipHeroModels:
constant boolean LIBRARY_EquipHeroModels=true
integer EquipHeroModels___HeroModels
string array EquipHeroModels___Path
integer EquipHeroModels___Models= 0
//endglobals from EquipHeroModels
//globals from EquipmentSockets:
constant boolean LIBRARY_EquipmentSockets=true
//endglobals from EquipmentSockets
//globals from InventoryPlugins:
constant boolean LIBRARY_InventoryPlugins=true
//endglobals from InventoryPlugins
//globals from InventoryTooltip:
constant boolean LIBRARY_InventoryTooltip=true
//endglobals from InventoryTooltip
//globals from PlayerUtils:
constant boolean LIBRARY_PlayerUtils=true
        // automatically change unit colors when changing player color
constant boolean PlayerUtils___AUTO_COLOR_UNITS= true
   
        // use an array for name / color lookups (instead of function calls)
constant boolean PlayerUtils___ARRAY_LOOKUP= false
   
        // this only applies if ARRAY_LOOKUP is true
constant boolean PlayerUtils___HOOK_SAFETY= false
   
constant force FORCE_PLAYING= CreateForce()
   
string array PlayerUtils___Name
string array PlayerUtils___Hex
string array PlayerUtils___OriginalHex
playercolor array PlayerUtils___CurrentColor
//endglobals from PlayerUtils
//globals from SimError:
constant boolean LIBRARY_SimError=true
sound SimError___error
//endglobals from SimError
//globals from Table:
constant boolean LIBRARY_Table=true
constant integer Table___MAX_INSTANCES=8100
        //Feel free to change max instances if necessary, it will only affect allocation
        //speed which shouldn't matter that much.

    //=========================================================
hashtable Table___ht= InitHashtable()
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
constant boolean TimerUtils___USE_HASH_TABLE= true
constant boolean TimerUtils___USE_FLEXIBLE_OFFSET= false

constant integer TimerUtils___OFFSET= 0x100000
integer TimerUtils___VOFFSET= TimerUtils___OFFSET
              
        //Timers to preload at map init:
constant integer TimerUtils___QUANTITY= 256
        
        //Changing this  to something big will allow you to keep recycling
        // timers even when there are already AN INCREDIBLE AMOUNT of timers in
        // the stack. But it will make things far slower so that's probably a bad idea...
constant integer TimerUtils___ARRAY_SIZE= 8190

// processed:         integer array TimerUtils___data[TimerUtils___ARRAY_SIZE]
hashtable TimerUtils___ht
// processed:         timer array TimerUtils___tT[TimerUtils___ARRAY_SIZE]
integer TimerUtils___tN= 0
constant integer TimerUtils___HELD=0x28829022
        //use a totally random number here, the more improbable someone uses it, the better.
        
boolean TimerUtils___didinit= false
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
trigger array UnitDex___IndexTrig
integer UnitDex___Index= 0
real UnitDex___E=- 1
boolexpr UnitDex___FilterEnter
//endglobals from UnitDex
//globals from xebasic:
constant boolean LIBRARY_xebasic=true
constant integer XE_DUMMY_UNITID= 'e001'
constant integer XE_HEIGHT_ENABLER= 'Amrf'
constant integer XE_TREE_RECOGNITION= 'Aeat'
constant real XE_ANIMATION_PERIOD=  0.025
constant real XE_MAX_COLLISION_SIZE=  197.0
//endglobals from xebasic
//globals from AutoIndex:
constant boolean LIBRARY_AutoIndex=true
//endglobals from AutoIndex
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
//globals from xepreload:
constant boolean LIBRARY_xepreload=true
unit xepreload___dum=null
constant boolean xepreload___ALLOW_DEBUGGING=true
//endglobals from xepreload
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
trigger UserInterface___Trig= CreateTrigger()
integer UserInterface___ClickedButton= 0
player UserInterface___ClickingPlayer= null
location UserInterface___DummyLoc= Location(0, 0)
//endglobals from UserInterface
//globals from InventoryBonuses:
constant boolean LIBRARY_InventoryBonuses=true
//endglobals from InventoryBonuses
//globals from InventoryCore:
constant boolean LIBRARY_InventoryCore=true
//endglobals from InventoryCore
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
real RegenBonuses___REGEN_PERIOD= 0.32
integer BONUS_MANA_REGEN
integer BONUS_LIFE_REGEN_PERCENT
timer RegenBonuses___regenTimer= CreateTimer()
//endglobals from RegenBonuses
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
    // Generated
trigger gg_trg_StartGame= null
trigger gg_trg_Inventory= null
trigger gg_trg_InventoryItem= null
trigger gg_trg_InventoryPlugins= null
trigger gg_trg_InventoryTooltip= null
trigger gg_trg_InventoryBonus= null
trigger gg_trg_InventoryGlobals= null
trigger gg_trg_Equipment= null
trigger gg_trg_EquipmentItem= null
trigger gg_trg_EquipmentSockets= null
trigger gg_trg_EquipHeroModels= null
trigger gg_trg_EquipItemParser= null
trigger gg_trg_Item_Setups= null
trigger gg_trg_Show_Equipment= null
trigger gg_trg_Show_Inventory= null
trigger gg_trg_AcquireItem= null
trigger gg_trg_Equip_Item= null
trigger gg_trg_Unequip_Item= null
trigger gg_trg_Sell_Item= null
trigger gg_trg_Drop_Item= null
trigger gg_trg_Socket_Item= null
trigger gg_trg_HideInv= null
trigger gg_trg_YesNoDialog= null
trigger gg_trg_UserInterface= null
trigger gg_trg_UnitDex= null
trigger gg_trg_PlayerUtils= null
trigger gg_trg_Camera= null
trigger gg_trg_Math= null
trigger gg_trg_TimerUtils= null
trigger gg_trg_Table= null
trigger gg_trg_SimError= null
trigger gg_trg_BoundSentinel= null
trigger gg_trg_BonusMod= null
trigger gg_trg_RegenBonuses= null
trigger gg_trg_UnitMaxStateBonuses= null
trigger gg_trg_MovementBonus= null
trigger gg_trg_UnitMaxState= null
trigger gg_trg_AutoIndex_UD= null
trigger gg_trg_AutoIndex= null
trigger gg_trg_xebasic= null
trigger gg_trg_xepreload= null
trigger gg_trg_AbilityPreload= null
integer array PlayerCamera
unit array PlayerHero
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
integer array DropItem___DropItem
integer array DropItem___DropSlot
integer array DropItem___DropInv
integer array SocketItem___SockItem
integer array SocketItem___SockSlot
integer array SocketItem___SockInv
integer array SocketItem___SockLast
        
integer SocketLast
integer SocketSlot
integer SocketInv

trigger l__library_init

//JASSHelper struct globals:
constant integer si__HeroModelData=1
integer si__HeroModelData_F=0
integer si__HeroModelData_I=0
integer array si__HeroModelData_V
string array s__HeroModelData_path
real array s__HeroModelData_scale
constant integer si__User=2
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
constant integer si__Table___GTable=3
integer si__Table___GTable_F=0
integer si__Table___GTable_I=0
integer array si__Table___GTable_V
constant integer si__Table=4
constant integer si__StringTable=5
constant integer si__HandleTable=6
constant integer si__VECTOR3=7
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
constant integer si__MATRIX3=8
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
constant integer si__MATRIX4=9
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
constant integer si__UnitDex=10
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
constant integer si__AutoIndex=11
integer si__AutoIndex_F=0
integer si__AutoIndex_I=0
integer array si__AutoIndex_V
integer array s__AutoIndex_indexfuncs
integer s__AutoIndex_indexfuncs_n= - 1
integer array s__AutoIndex_deindexfuncs
integer s__AutoIndex_deindexfuncs_n= - 1
integer s__AutoIndex_indexfunc
constant integer si__Camera=12
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
constant integer si__Camera___CamInit=13
integer si__Camera___CamInit_F=0
integer si__Camera___CamInit_I=0
integer array si__Camera___CamInit_V
constant integer si__InvItem=14
integer si__InvItem_F=0
integer si__InvItem_I=0
integer array si__InvItem_V
integer s__InvItem_Table
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
constant integer s__InvItem_KeyBonusType=4
constant integer s__InvItem_KeyBonusAmount=6
constant integer s__InvItem_KeyBonusMin=8
constant integer s__InvItem_KeyBonusMax=10
constant integer s__InvItem_KeyBonusRand=12
integer s__InvItem_KEY_BONUS_TYPE= INVENTORY_KEY_START + s__InvItem_KeyBonusType
integer s__InvItem_KEY_BONUS_AMOUNT= INVENTORY_KEY_START + s__InvItem_KeyBonusAmount
integer s__InvItem_KEY_BONUS_MIN= INVENTORY_KEY_START + s__InvItem_KeyBonusMin
integer s__InvItem_KEY_BONUS_MAX= INVENTORY_KEY_START + s__InvItem_KeyBonusMax
integer s__InvItem_KEY_BONUS_RND= INVENTORY_KEY_START + s__InvItem_KeyBonusRand
integer array s__InvItem_maxSockets
boolean array s__InvItem_isSocket
hashtable s__InvItem_SocketTable= InitHashtable()
constant integer s__InvItem_InvItemSocket__KEY_SOCKETS=14
constant integer s__InvItem_InvItemSocket__KEY_SOCKETS_ID=16
constant integer s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT=18
constant integer si__InvCustomItem=15
integer s__InvCustomItem_Counter= 1
integer s__InvCustomItem_SeedTable
constant integer si__xepreload___Init=16
constant integer si__BonusMod___BonusInterface=17
integer si__BonusMod___BonusInterface_F=0
integer si__BonusMod___BonusInterface_I=0
integer array si__BonusMod___BonusInterface_V
integer array si__BonusMod___BonusInterface_type
trigger array st__BonusMod___BonusInterface_onDestroy
integer array s__BonusMod___BonusInterface_minBonus
integer array s__BonusMod___BonusInterface_maxBonus
trigger array st__BonusMod___BonusInterface_destroy
constant integer si__Bonus=18
boolean array s__Bonus_BonusMod___isBonusObject
constant integer si__BonusMod___AbilityBonus=19
integer array s__BonusMod___AbilityBonus_count
integer array s__BonusMod___AbilityBonus_rawcode
integer array s__BonusMod___AbilityBonus_negativeRawcode
integer array s__BonusMod___AbilityBonus_minBonus
integer array s__BonusMod___AbilityBonus_maxBonus
boolean array s__BonusMod___AbilityBonus_heroesOnly
constant integer si__BonusModStruct=20
constant integer si__UnitMaxState___Data=21
integer si__UnitMaxState___Data_F=0
integer si__UnitMaxState___Data_I=0
integer array si__UnitMaxState___Data_V
constant integer si__UIButton=22
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
constant integer si__UIPicture=23
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
constant integer si__UIText=24
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
constant integer si__Interface=25
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
constant integer si__Inventory=26
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
constant integer s__Inventory_KEY_ITEMS=20
constant integer s__Inventory_KEY_ITEM_ID=22
constant integer s__Inventory_KeyUnit=24
constant integer s__Inventory_KEY_UNIT= INVENTORY_KEY_START + s__Inventory_KeyUnit
constant integer s__Inventory_KeyItemCount=26
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
constant integer si__MovementBonus___BonusValue=28
integer si__MovementBonus___BonusValue_F=0
integer si__MovementBonus___BonusValue_I=0
integer array si__MovementBonus___BonusValue_V
integer array s__MovementBonus___BonusValue_speed
unit array s__MovementBonus___BonusValue_owner
integer array s__MovementBonus___BonusValue_owners
integer array s__MovementBonus___BonusValue_all
integer s__MovementBonus___BonusValue_count= 0
integer array s__MovementBonus___BonusValue_index
constant integer si__MovementBonus___MovementBonus=29
integer array s__MovementBonus___MovementBonus_minBonus
integer array s__MovementBonus___MovementBonus_maxBonus
constant integer si__RegenBonuses___BonusValues=30
integer si__RegenBonuses___BonusValues_F=0
integer si__RegenBonuses___BonusValues_I=0
integer array si__RegenBonuses___BonusValues_V
integer array s__RegenBonuses___BonusValues_manaRegen
integer array s__RegenBonuses___BonusValues_lifeRegen
unit array s__RegenBonuses___BonusValues_owner
integer array s__RegenBonuses___BonusValues_owners
integer array s__RegenBonuses___BonusValues_all
integer s__RegenBonuses___BonusValues_count= 0
integer array s__RegenBonuses___BonusValues_index
constant integer si__RegenBonuses___RegenBonus_life=31
integer array s__RegenBonuses___RegenBonus_life_minBonus
integer array s__RegenBonuses___RegenBonus_life_maxBonus
constant integer si__RegenBonuses___RegenBonus_mana=32
integer array s__RegenBonuses___RegenBonus_mana_minBonus
integer array s__RegenBonuses___RegenBonus_mana_maxBonus
constant integer si__UnitMaxStateBonuses___BonusValues=33
integer si__UnitMaxStateBonuses___BonusValues_F=0
integer si__UnitMaxStateBonuses___BonusValues_I=0
integer array si__UnitMaxStateBonuses___BonusValues_V
integer array s__UnitMaxStateBonuses___BonusValues_mana
integer array s__UnitMaxStateBonuses___BonusValues_life
unit array s__UnitMaxStateBonuses___BonusValues_owner
integer array s__UnitMaxStateBonuses___BonusValues_owners
constant integer si__UnitMaxStateBonuses___MaxStateBonus_life=34
integer array s__UnitMaxStateBonuses___MaxStateBonus_life_minBonus
integer array s__UnitMaxStateBonuses___MaxStateBonus_life_maxBonus
constant integer si__UnitMaxStateBonuses___MaxStateBonus_mana=35
integer array s__UnitMaxStateBonuses___MaxStateBonus_mana_minBonus
integer array s__UnitMaxStateBonuses___MaxStateBonus_mana_maxBonus
constant integer si__UnitMaxStateBonuses___Data=36
integer si__UnitMaxStateBonuses___Data_F=0
integer si__UnitMaxStateBonuses___Data_I=0
integer array si__UnitMaxStateBonuses___Data_V
constant integer si__YesNoDialog=37
constant integer si__Equipment=38
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
integer array s__TimerUtils___data
timer array s__TimerUtils___tT
integer array s__s__Inventory_ItemInfoTags
integer array s__s__Equipment_buttons
integer array s__s__Equipment_slotButton
integer array s__s__Equipment_pictures
trigger array st__Bonus_setBonus
trigger array st__Bonus_getBonus
trigger array st__Bonus_removeBonus
trigger array st__Bonus_isValidBonus
integer array si__Table___GTable_type
trigger array st__Table___GTable_onDestroy
trigger st__Table__getindex
trigger st__Table__setindex
trigger st__UnitDex_Remove
trigger st__InvItem__get_sockets
trigger st__InvItem_socketId
trigger st__InvItem_getSocket
trigger st__InvCustomItem_seed
trigger st__Bonus_create
trigger st__BonusMod___AbilityBonus_create
trigger st__BonusModStruct_addBonus
trigger st__UIText_show
trigger st__Inventory_setTooltipLine
trigger st__Inventory_setTooltipSlot
trigger st__Inventory_clearLines
trigger st__MovementBonus___BonusValue_onDestroy
trigger st__RegenBonuses___BonusValues_onDestroy
trigger st__UnitMaxStateBonuses___BonusValues_onDestroy
trigger array st___prototype3
trigger array st___prototype30
trigger array st___prototype41
trigger array st___prototype42
integer f__result_integer
trigger array st___prototype43
trigger array st___prototype60
integer f__arg_integer1
integer f__arg_integer2
integer f__arg_integer3
unit f__arg_unit1
boolean f__arg_boolean1
string f__arg_string1
integer f__arg_this
boolean f__result_boolean



//JASSHelper struct globals:

// Recorder-owned state only. The demo remains the owner of all gameplay state.
    constant string ILM_BUILD = "inv-manual-20261019-01"
    constant integer ILM_CHUNK_ROWS = 128
    constant integer ILM_MAX_CHUNKS = 64
    constant integer ILM_QUEUE_ROWS = 256
    boolean ILM_Active = false
    boolean ILM_Used = false
    boolean ILM_EndPending = false
    boolean ILM_SavePending = false
    boolean ILM_ChunkDirty = false
    boolean ILM_Dirty = false
    string ILM_Session = ""
    string ILM_Reason = ""
    integer ILM_Dropped = 0
    integer ILM_Sequence = 0
    integer ILM_Head = 0
    integer ILM_Tail = 0
    integer ILM_Queued = 0
    string array ILM_Queue
    string array ILM_Chunk
    integer ILM_ChunkIndex = 0
    integer ILM_ChunkCount = 0
    integer ILM_LastSample = -1000
    integer array ILM_Items
    integer array ILM_Custom
    integer ILM_Str = -1
    integer ILM_Agi = -1
    integer ILM_Int = -1
    integer ILM_Gold = -1
    unit ILM_Hero = null
    integer ILM_Inventory = 0
    timer ILM_Clock = null
    timer ILM_Poll = null
    trigger ILM_Work = null
    trigger ILM_Chat = null
endglobals
// Early hooks depend ONLY on natives and recorder globals; no gameplay handles.
function ILM_Bool takes boolean value returns string
    if value then
        return "1"
    endif
    return "0"
endfunction

function ILM_Now takes nothing returns integer
    return R2I(TimerGetElapsed(ILM_Clock) * 1000.0)
endfunction

function ILM_Append takes string source, string eventName, string data returns nothing
    set ILM_Sequence = ILM_Sequence + 1
    set ILM_Queue[ILM_Tail] = "IL141M|" + ILM_BUILD + "|" + ILM_Session + "|" + I2S((ILM_Sequence - 1) / ILM_CHUNK_ROWS) + "|" + I2S(ILM_Sequence) + "|" + I2S(ILM_Now()) + "|" + source + "|" + eventName + "|" + data
    set ILM_Tail = ILM_Tail + 1
    if ILM_Tail == ILM_QUEUE_ROWS then
        set ILM_Tail = 0
    endif
    set ILM_Queued = ILM_Queued + 1
endfunction

function ILM_Log takes string source, string eventName, string data returns nothing
    if not ILM_Active then
        return
    endif
    // Always reserve one queue position and one total row for TERMINAL.
    if ILM_Queued >= ILM_QUEUE_ROWS - 1 or ILM_Sequence >= ILM_CHUNK_ROWS * ILM_MAX_CHUNKS - 1 then
        set ILM_Dropped = ILM_Dropped + 1
        set ILM_Active = false
        set ILM_Reason = "OVERFLOW"
        set ILM_EndPending = true
        return
    endif
    call ILM_Append(source, eventName, data)
    set ILM_Dirty = true
endfunction





//Generated allocator of HeroModelData
function s__HeroModelData__allocate takes nothing returns integer
 local integer this=si__HeroModelData_F
    if ( this != 0 ) then
        set si__HeroModelData_F=si__HeroModelData_V[this]
    else
        set si__HeroModelData_I=si__HeroModelData_I + 1
        set this=si__HeroModelData_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__HeroModelData_V[this]=- 1
 return this
endfunction

//Generated destructor of HeroModelData
function s__HeroModelData_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__HeroModelData_V[this] != - 1 ) then
        return
    endif
    set si__HeroModelData_V[this]=si__HeroModelData_F
    set si__HeroModelData_F=this
endfunction

//Generated allocator of Equipment
function s__Equipment__allocate takes nothing returns integer
 local integer this=si__Equipment_F
    if ( this != 0 ) then
        set si__Equipment_F=si__Equipment_V[this]
    else
        set si__Equipment_I=si__Equipment_I + 1
        set this=si__Equipment_I
    endif
    if ( this > 584 ) then
        return 0
    endif
    set s__Equipment_item[this]=( this - 1 ) * 14
    set s__Equipment_itemId[this]=( this - 1 ) * 14
    set si__Equipment_V[this]=- 1
 return this
endfunction

//Generated destructor of Equipment
function s__Equipment_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__Equipment_V[this] != - 1 ) then
        return
    endif
    set si__Equipment_V[this]=si__Equipment_F
    set si__Equipment_F=this
endfunction

//Generated allocator of UnitMaxStateBonuses___Data
function s__UnitMaxStateBonuses___Data__allocate takes nothing returns integer
 local integer this=si__UnitMaxStateBonuses___Data_F
    if ( this != 0 ) then
        set si__UnitMaxStateBonuses___Data_F=si__UnitMaxStateBonuses___Data_V[this]
    else
        set si__UnitMaxStateBonuses___Data_I=si__UnitMaxStateBonuses___Data_I + 1
        set this=si__UnitMaxStateBonuses___Data_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__UnitMaxStateBonuses___Data_V[this]=- 1
 return this
endfunction

//Generated destructor of UnitMaxStateBonuses___Data
function s__UnitMaxStateBonuses___Data_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__UnitMaxStateBonuses___Data_V[this] != - 1 ) then
        return
    endif
    set si__UnitMaxStateBonuses___Data_V[this]=si__UnitMaxStateBonuses___Data_F
    set si__UnitMaxStateBonuses___Data_F=this
endfunction

//Generated method caller for Table___GTable.onDestroy
function sc__Table___GTable_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__Table___GTable_onDestroy[3])
endfunction

//Generated allocator of Table___GTable
function s__Table___GTable__allocate takes nothing returns integer
 local integer this=si__Table___GTable_F
    if ( this != 0 ) then
        set si__Table___GTable_F=si__Table___GTable_V[this]
    else
        set si__Table___GTable_I=si__Table___GTable_I + 1
        set this=si__Table___GTable_I
    endif
    if ( this > 8100 ) then
        return 0
    endif

    set si__Table___GTable_type[this]=3
    set si__Table___GTable_V[this]=- 1
 return this
endfunction

//Generated destructor of Table___GTable
function sc__Table___GTable_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__Table___GTable_V[this] != - 1 ) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__Table___GTable_onDestroy[si__Table___GTable_type[this]])
    set si__Table___GTable_V[this]=si__Table___GTable_F
    set si__Table___GTable_F=this
endfunction

//Generated method caller for UnitMaxStateBonuses___BonusValues.onDestroy
function sc__UnitMaxStateBonuses___BonusValues_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__UnitMaxStateBonuses___BonusValues_onDestroy)
endfunction

//Generated allocator of UnitMaxStateBonuses___BonusValues
function s__UnitMaxStateBonuses___BonusValues__allocate takes nothing returns integer
 local integer this=si__UnitMaxStateBonuses___BonusValues_F
    if ( this != 0 ) then
        set si__UnitMaxStateBonuses___BonusValues_F=si__UnitMaxStateBonuses___BonusValues_V[this]
    else
        set si__UnitMaxStateBonuses___BonusValues_I=si__UnitMaxStateBonuses___BonusValues_I + 1
        set this=si__UnitMaxStateBonuses___BonusValues_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

   set s__UnitMaxStateBonuses___BonusValues_mana[this]=0
   set s__UnitMaxStateBonuses___BonusValues_life[this]=0
    set si__UnitMaxStateBonuses___BonusValues_V[this]=- 1
 return this
endfunction

//Generated destructor of UnitMaxStateBonuses___BonusValues
function sc__UnitMaxStateBonuses___BonusValues_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__UnitMaxStateBonuses___BonusValues_V[this] != - 1 ) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__UnitMaxStateBonuses___BonusValues_onDestroy)
    set si__UnitMaxStateBonuses___BonusValues_V[this]=si__UnitMaxStateBonuses___BonusValues_F
    set si__UnitMaxStateBonuses___BonusValues_F=this
endfunction

//Generated method caller for Table._getindex
function sc__Table__getindex takes integer this,integer key returns integer
    set f__arg_this=this
    set f__arg_integer1=key
    call TriggerEvaluate(st__Table__getindex)
 return f__result_integer
endfunction

//Generated method caller for Table._setindex
function sc__Table__setindex takes integer this,integer key,integer value returns nothing
    set f__arg_this=this
    set f__arg_integer1=key
    set f__arg_integer2=value
    call TriggerEvaluate(st__Table__setindex)
endfunction

//Generated allocator of Table
function s__Table__allocate takes nothing returns integer
 local integer this=s__Table___GTable__allocate()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__Table___GTable_type[this]=4
    set kthis=this

 return this
endfunction


//Generated allocator of StringTable
function s__StringTable__allocate takes nothing returns integer
 local integer this=s__Table___GTable__allocate()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__Table___GTable_type[this]=5
    set kthis=this

 return this
endfunction


//Generated method caller for RegenBonuses___BonusValues.onDestroy
function sc__RegenBonuses___BonusValues_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__RegenBonuses___BonusValues_onDestroy)
endfunction

//Generated allocator of RegenBonuses___BonusValues
function s__RegenBonuses___BonusValues__allocate takes nothing returns integer
 local integer this=si__RegenBonuses___BonusValues_F
    if ( this != 0 ) then
        set si__RegenBonuses___BonusValues_F=si__RegenBonuses___BonusValues_V[this]
    else
        set si__RegenBonuses___BonusValues_I=si__RegenBonuses___BonusValues_I + 1
        set this=si__RegenBonuses___BonusValues_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

   set s__RegenBonuses___BonusValues_manaRegen[this]=0
   set s__RegenBonuses___BonusValues_lifeRegen[this]=0
    set si__RegenBonuses___BonusValues_V[this]=- 1
 return this
endfunction

//Generated destructor of RegenBonuses___BonusValues
function sc__RegenBonuses___BonusValues_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__RegenBonuses___BonusValues_V[this] != - 1 ) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__RegenBonuses___BonusValues_onDestroy)
    set si__RegenBonuses___BonusValues_V[this]=si__RegenBonuses___BonusValues_F
    set si__RegenBonuses___BonusValues_F=this
endfunction

//Generated allocator of HandleTable
function s__HandleTable__allocate takes nothing returns integer
 local integer this=s__Table___GTable__allocate()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__Table___GTable_type[this]=6
    set kthis=this

 return this
endfunction


//Generated method caller for MovementBonus___BonusValue.onDestroy
function sc__MovementBonus___BonusValue_onDestroy takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__MovementBonus___BonusValue_onDestroy)
endfunction

//Generated allocator of MovementBonus___BonusValue
function s__MovementBonus___BonusValue__allocate takes nothing returns integer
 local integer this=si__MovementBonus___BonusValue_F
    if ( this != 0 ) then
        set si__MovementBonus___BonusValue_F=si__MovementBonus___BonusValue_V[this]
    else
        set si__MovementBonus___BonusValue_I=si__MovementBonus___BonusValue_I + 1
        set this=si__MovementBonus___BonusValue_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

   set s__MovementBonus___BonusValue_speed[this]=0
    set si__MovementBonus___BonusValue_V[this]=- 1
 return this
endfunction

//Generated destructor of MovementBonus___BonusValue
function sc__MovementBonus___BonusValue_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__MovementBonus___BonusValue_V[this] != - 1 ) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__MovementBonus___BonusValue_onDestroy)
    set si__MovementBonus___BonusValue_V[this]=si__MovementBonus___BonusValue_F
    set si__MovementBonus___BonusValue_F=this
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
    if ( this != 0 ) then
        set si__Inventory_F=si__Inventory_V[this]
    else
        set si__Inventory_I=si__Inventory_I + 1
        set this=si__Inventory_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__Inventory_V[this]=- 1
 return this
endfunction

//Generated destructor of Inventory
function s__Inventory_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__Inventory_V[this] != - 1 ) then
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
    if ( this != 0 ) then
        set si__UIText_F=si__UIText_V[this]
    else
        set si__UIText_I=si__UIText_I + 1
        set this=si__UIText_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__UIText_V[this]=- 1
 return this
endfunction

//Generated destructor of UIText
function s__UIText_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__UIText_V[this] != - 1 ) then
        return
    endif
    set si__UIText_V[this]=si__UIText_F
    set si__UIText_F=this
endfunction

//Generated allocator of UIPicture
function s__UIPicture__allocate takes nothing returns integer
 local integer this=si__UIPicture_F
    if ( this != 0 ) then
        set si__UIPicture_F=si__UIPicture_V[this]
    else
        set si__UIPicture_I=si__UIPicture_I + 1
        set this=si__UIPicture_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__UIPicture_V[this]=- 1
 return this
endfunction

//Generated destructor of UIPicture
function s__UIPicture_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__UIPicture_V[this] != - 1 ) then
        return
    endif
    set si__UIPicture_V[this]=si__UIPicture_F
    set si__UIPicture_F=this
endfunction

//Generated allocator of UIButton
function s__UIButton__allocate takes nothing returns integer
 local integer this=si__UIButton_F
    if ( this != 0 ) then
        set si__UIButton_F=si__UIButton_V[this]
    else
        set si__UIButton_I=si__UIButton_I + 1
        set this=si__UIButton_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__UIButton_V[this]=- 1
 return this
endfunction

//Generated destructor of UIButton
function s__UIButton_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__UIButton_V[this] != - 1 ) then
        return
    endif
    set si__UIButton_V[this]=si__UIButton_F
    set si__UIButton_F=this
endfunction

//Generated allocator of UnitMaxState___Data
function s__UnitMaxState___Data__allocate takes nothing returns integer
 local integer this=si__UnitMaxState___Data_F
    if ( this != 0 ) then
        set si__UnitMaxState___Data_F=si__UnitMaxState___Data_V[this]
    else
        set si__UnitMaxState___Data_I=si__UnitMaxState___Data_I + 1
        set this=si__UnitMaxState___Data_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__UnitMaxState___Data_V[this]=- 1
 return this
endfunction

//Generated destructor of UnitMaxState___Data
function s__UnitMaxState___Data_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__UnitMaxState___Data_V[this] != - 1 ) then
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

//Generated allocator of VECTOR3
function s__VECTOR3__allocate takes nothing returns integer
 local integer this=si__VECTOR3_F
    if ( this != 0 ) then
        set si__VECTOR3_F=si__VECTOR3_V[this]
    else
        set si__VECTOR3_I=si__VECTOR3_I + 1
        set this=si__VECTOR3_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__VECTOR3_V[this]=- 1
 return this
endfunction

//Generated destructor of VECTOR3
function s__VECTOR3_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__VECTOR3_V[this] != - 1 ) then
        return
    endif
    set si__VECTOR3_V[this]=si__VECTOR3_F
    set si__VECTOR3_F=this
endfunction

//Generated allocator of MATRIX3
function s__MATRIX3__allocate takes nothing returns integer
 local integer this=si__MATRIX3_F
    if ( this != 0 ) then
        set si__MATRIX3_F=si__MATRIX3_V[this]
    else
        set si__MATRIX3_I=si__MATRIX3_I + 1
        set this=si__MATRIX3_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__MATRIX3_V[this]=- 1
 return this
endfunction

//Generated destructor of MATRIX3
function s__MATRIX3_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__MATRIX3_V[this] != - 1 ) then
        return
    endif
    set si__MATRIX3_V[this]=si__MATRIX3_F
    set si__MATRIX3_F=this
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
    if this == null then
        return
    elseif ( si__BonusMod___BonusInterface_V[this] != - 1 ) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__BonusMod___BonusInterface_onDestroy[si__BonusMod___BonusInterface_type[this]])
    set si__BonusMod___BonusInterface_V[this]=si__BonusMod___BonusInterface_F
    set si__BonusMod___BonusInterface_F=this
endfunction

//Generated method caller for InvCustomItem.seed
function sc__InvCustomItem_seed takes integer this returns integer
    set f__arg_this=this
    call TriggerEvaluate(st__InvCustomItem_seed)
 return f__result_integer
endfunction

//Generated method caller for InvItem._get_sockets
function sc__InvItem__get_sockets takes integer this returns integer
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100)
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
    if ( this != 0 ) then
        set si__InvItem_F=si__InvItem_V[this]
    else
        set si__InvItem_I=si__InvItem_I + 1
        set this=si__InvItem_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__InvItem_V[this]=- 1
 return this
endfunction

//Generated destructor of InvItem
function s__InvItem_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__InvItem_V[this] != - 1 ) then
        return
    endif
    set si__InvItem_V[this]=si__InvItem_F
    set si__InvItem_F=this
endfunction

//Generated allocator of Camera___CamInit
function s__Camera___CamInit__allocate takes nothing returns integer
 local integer this=si__Camera___CamInit_F
    if ( this != 0 ) then
        set si__Camera___CamInit_F=si__Camera___CamInit_V[this]
    else
        set si__Camera___CamInit_I=si__Camera___CamInit_I + 1
        set this=si__Camera___CamInit_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__Camera___CamInit_V[this]=- 1
 return this
endfunction

//Generated destructor of Camera___CamInit
function s__Camera___CamInit_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__Camera___CamInit_V[this] != - 1 ) then
        return
    endif
    set si__Camera___CamInit_V[this]=si__Camera___CamInit_F
    set si__Camera___CamInit_F=this
endfunction

//Generated allocator of Camera
function s__Camera__allocate takes nothing returns integer
 local integer this=si__Camera_F
    if ( this != 0 ) then
        set si__Camera_F=si__Camera_V[this]
    else
        set si__Camera_I=si__Camera_I + 1
        set this=si__Camera_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__Camera_V[this]=- 1
 return this
endfunction

//Generated destructor of Camera
function s__Camera_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__Camera_V[this] != - 1 ) then
        return
    endif
    set si__Camera_V[this]=si__Camera_F
    set si__Camera_F=this
endfunction

//Generated allocator of AutoIndex
function s__AutoIndex__allocate takes nothing returns integer
 local integer this=si__AutoIndex_F
    if ( this != 0 ) then
        set si__AutoIndex_F=si__AutoIndex_V[this]
    else
        set si__AutoIndex_I=si__AutoIndex_I + 1
        set this=si__AutoIndex_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__AutoIndex_V[this]=- 1
 return this
endfunction

//Generated destructor of AutoIndex
function s__AutoIndex_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__AutoIndex_V[this] != - 1 ) then
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

//Generated allocator of MATRIX4
function s__MATRIX4__allocate takes nothing returns integer
 local integer this=si__MATRIX4_F
    if ( this != 0 ) then
        set si__MATRIX4_F=si__MATRIX4_V[this]
    else
        set si__MATRIX4_I=si__MATRIX4_I + 1
        set this=si__MATRIX4_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

    set si__MATRIX4_V[this]=- 1
 return this
endfunction

//Generated destructor of MATRIX4
function s__MATRIX4_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__MATRIX4_V[this] != - 1 ) then
        return
    endif
    set si__MATRIX4_V[this]=si__MATRIX4_F
    set si__MATRIX4_F=this
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
    if ( this != 0 ) then
        set si__BonusMod___BonusInterface_F=si__BonusMod___BonusInterface_V[this]
    else
        set si__BonusMod___BonusInterface_I=si__BonusMod___BonusInterface_I + 1
        set this=si__BonusMod___BonusInterface_I
    endif
    if ( this > 8190 ) then
        return 0
    endif

   set s__BonusMod___BonusInterface_minBonus[this]=0
   set s__BonusMod___BonusInterface_maxBonus[this]=0
    set si__BonusMod___BonusInterface_type[this]=18
    set kthis=this

   set s__Bonus_BonusMod___isBonusObject[this]=false
    set si__BonusMod___BonusInterface_V[this]=- 1
 return this
endfunction


//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.setBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[35])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.getBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[35])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.removeBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[35])
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_mana.isValidBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[35])
 return f__result_boolean
endfunction

//Generated allocator of UnitMaxStateBonuses___MaxStateBonus_mana
function s__UnitMaxStateBonuses___MaxStateBonus_mana__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=35
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]=- 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=2147483647
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
    call TriggerEvaluate(st__Bonus_setBonus[19])
 return f__result_integer
endfunction

//Generated method caller for BonusMod___AbilityBonus.getBonus
function sc__BonusMod___AbilityBonus_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[19])
 return f__result_integer
endfunction

//Generated method caller for BonusMod___AbilityBonus.removeBonus
function sc__BonusMod___AbilityBonus_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[19])
endfunction

//Generated method caller for BonusMod___AbilityBonus.isValidBonus
function sc__BonusMod___AbilityBonus_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[19])
 return f__result_boolean
endfunction

//Generated allocator of BonusMod___AbilityBonus
function s__BonusMod___AbilityBonus__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=19
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]=0
   set s__BonusMod___BonusInterface_maxBonus[this]=0
 return this
endfunction


//Generated method caller for MovementBonus___MovementBonus.setBonus
function sc__MovementBonus___MovementBonus_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[29])
 return f__result_integer
endfunction

//Generated method caller for MovementBonus___MovementBonus.getBonus
function sc__MovementBonus___MovementBonus_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[29])
 return f__result_integer
endfunction

//Generated method caller for MovementBonus___MovementBonus.removeBonus
function sc__MovementBonus___MovementBonus_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[29])
endfunction

//Generated method caller for MovementBonus___MovementBonus.isValidBonus
function sc__MovementBonus___MovementBonus_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[29])
 return f__result_boolean
endfunction

//Generated allocator of MovementBonus___MovementBonus
function s__MovementBonus___MovementBonus__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=29
    set kthis=this

 return this
endfunction


//Generated method caller for RegenBonuses___RegenBonus_life.setBonus
function sc__RegenBonuses___RegenBonus_life_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[31])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses___RegenBonus_life.getBonus
function sc__RegenBonuses___RegenBonus_life_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[31])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses___RegenBonus_life.removeBonus
function sc__RegenBonuses___RegenBonus_life_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[31])
endfunction

//Generated method caller for RegenBonuses___RegenBonus_life.isValidBonus
function sc__RegenBonuses___RegenBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[31])
 return f__result_boolean
endfunction

//Generated allocator of RegenBonuses___RegenBonus_life
function s__RegenBonuses___RegenBonus_life__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=31
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]=- 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=2147483647
 return this
endfunction


//Generated method caller for RegenBonuses___RegenBonus_mana.setBonus
function sc__RegenBonuses___RegenBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[32])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses___RegenBonus_mana.getBonus
function sc__RegenBonuses___RegenBonus_mana_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[32])
 return f__result_integer
endfunction

//Generated method caller for RegenBonuses___RegenBonus_mana.removeBonus
function sc__RegenBonuses___RegenBonus_mana_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[32])
endfunction

//Generated method caller for RegenBonuses___RegenBonus_mana.isValidBonus
function sc__RegenBonuses___RegenBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[32])
 return f__result_boolean
endfunction

//Generated allocator of RegenBonuses___RegenBonus_mana
function s__RegenBonuses___RegenBonus_mana__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=32
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]=- 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=2147483647
 return this
endfunction


//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.setBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_setBonus takes integer this,unit u,integer amount returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=amount
    call TriggerEvaluate(st__Bonus_setBonus[34])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.getBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_getBonus takes integer this,unit u returns integer
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_getBonus[34])
 return f__result_integer
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.removeBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus takes integer this,unit u returns nothing
    set f__arg_this=this
    set f__arg_unit1=u
    call TriggerEvaluate(st__Bonus_removeBonus[34])
endfunction

//Generated method caller for UnitMaxStateBonuses___MaxStateBonus_life.isValidBonus
function sc__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
    set f__arg_this=this
    set f__arg_unit1=u
    set f__arg_integer1=value
    call TriggerEvaluate(st__Bonus_isValidBonus[34])
 return f__result_boolean
endfunction

//Generated allocator of UnitMaxStateBonuses___MaxStateBonus_life
function s__UnitMaxStateBonuses___MaxStateBonus_life__allocate takes nothing returns integer
 local integer this=sc__Bonus_create()
 local integer kthis
    if ( this == 0 ) then
        return 0
    endif
    set si__BonusMod___BonusInterface_type[this]=34
    set kthis=this

   set s__BonusMod___BonusInterface_minBonus[this]=- 2147483648
   set s__BonusMod___BonusInterface_maxBonus[this]=2147483647
 return this
endfunction

function sc___prototype3_execute takes integer i returns nothing

    call TriggerExecute(st___prototype3[i])
endfunction
function sc___prototype3_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype3[i])

endfunction
function sc___prototype30_execute takes integer i,unit a1 returns nothing
    set f__arg_unit1=a1

    call TriggerExecute(st___prototype30[i])
endfunction
function sc___prototype30_evaluate takes integer i,unit a1 returns nothing
    set f__arg_unit1=a1

    call TriggerEvaluate(st___prototype30[i])

endfunction
function sc___prototype41_execute takes integer i,unit a1,integer a2 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerExecute(st___prototype41[i])
endfunction
function sc___prototype41_evaluate takes integer i,unit a1,integer a2 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerEvaluate(st___prototype41[i])

endfunction
function sc___prototype42_execute takes integer i,unit a1,integer a2,integer a3 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2
    set f__arg_integer2=a3

    call TriggerExecute(st___prototype42[i])
endfunction
function sc___prototype42_evaluate takes integer i,unit a1,integer a2,integer a3 returns integer
    set f__arg_unit1=a1
    set f__arg_integer1=a2
    set f__arg_integer2=a3

    call TriggerEvaluate(st___prototype42[i])
 return f__result_integer
endfunction
function sc___prototype43_execute takes integer i,unit a1,integer a2 returns nothing
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerExecute(st___prototype43[i])
endfunction
function sc___prototype43_evaluate takes integer i,unit a1,integer a2 returns integer
    set f__arg_unit1=a1
    set f__arg_integer1=a2

    call TriggerEvaluate(st___prototype43[i])
 return f__result_integer
endfunction
function sc___prototype60_execute takes integer i,integer a1,string a2 returns nothing
    set f__arg_integer1=a1
    set f__arg_string1=a2

    call TriggerExecute(st___prototype60[i])
endfunction
function sc___prototype60_evaluate takes integer i,integer a1,string a2 returns integer
    set f__arg_integer1=a1
    set f__arg_string1=a2

    call TriggerEvaluate(st___prototype60[i])
 return f__result_integer
endfunction

//library EquipHeroModels:
    
    
    
    function EquipSetHeroModel takes integer utype,real scale,string path returns nothing
        local integer data= s__HeroModelData__allocate()
        set s__HeroModelData_path[data]=path
        set s__HeroModelData_scale[data]=scale
        call sc__Table__setindex(EquipHeroModels___HeroModels , utype , data)
    endfunction
    
    function EquipGetHeroModel takes integer id returns integer
        return sc__Table__getindex(EquipHeroModels___HeroModels , id)
    endfunction
    
    function EquipHeroModels___Init takes nothing returns nothing
        set EquipHeroModels___HeroModels=s__Table__allocate()
        
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


//library EquipHeroModels ends
//library EquipmentSockets:



//library EquipmentSockets ends
//library InventoryPlugins:

    // add plugins here
    


//library InventoryPlugins ends
//library InventoryTooltip:

    
    

//library InventoryTooltip ends
//library PlayerUtils:




     
       

   




   
        // similar to Player(#)
        function s__User_fromIndex takes integer i returns integer
            return ( i )
        endfunction
   
        // similar to GetLocalPlayer
        function s__User_fromLocal takes nothing returns integer
            return ( s__User_LocalId )
        endfunction
   
        // access active players array
        function s__User_fromPlaying takes integer index returns integer
            return s__User_PlayingPlayer[index]
        endfunction
   
        function s__User__staticgetindex takes player p returns integer
            return ( GetPlayerId(p) )
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
            return PlayerUtils___OriginalHex[GetHandleId(( GetPlayerColor(s__User_handle[( this )]) ))] // INLINED!!
        endfunction
   
        function s__User__set_color takes integer this,playercolor c returns nothing
            call SetPlayerColor(s__User_handle[this], c)
       








        endfunction
   
        function s__User__get_defaultColor takes integer this returns playercolor
            return s__User_Color[this]
        endfunction
   
        function s__User__get_nameColored takes integer this returns string
            return ( PlayerUtils___OriginalHex[GetHandleId(( GetPlayerColor(s__User_handle[( ( this ) )]) ))] ) + ( GetPlayerName(s__User_handle[( this )]) ) + "|r" // INLINED!!
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
            local integer p= ( GetPlayerId(( GetTriggerPlayer() )) )
            local integer i= s__User_PlayingPlayerIndex[s__User_id[p]]
       
            // clean up
            call ForceRemovePlayer(FORCE_PLAYING, ( s__User_handle[( p )] )) // INLINED!!
       
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
   
//Implemented from module PlayerUtils___PlayerUtilsInit:
        function s__User_PlayerUtils___PlayerUtilsInit__onInit takes nothing returns nothing
            local trigger t= CreateTrigger()
            local integer i= 0
            local integer p
       
            set s__User_Local=GetLocalPlayer()
            set s__User_LocalId=GetPlayerId(s__User_Local)
       
            set PlayerUtils___OriginalHex[0]="|cffff0303"
            set PlayerUtils___OriginalHex[1]="|cff0042ff"
            set PlayerUtils___OriginalHex[2]="|cff1ce6b9"
            set PlayerUtils___OriginalHex[3]="|cff540081"
            set PlayerUtils___OriginalHex[4]="|cfffffc01"
            set PlayerUtils___OriginalHex[5]="|cfffe8a0e"
            set PlayerUtils___OriginalHex[6]="|cff20c000"
            set PlayerUtils___OriginalHex[7]="|cffe55bb0"
            set PlayerUtils___OriginalHex[8]="|cff959697"
            set PlayerUtils___OriginalHex[9]="|cff7ebff1"
            set PlayerUtils___OriginalHex[10]="|cff106246"
            set PlayerUtils___OriginalHex[11]="|cff4e2a04"
         
            set s__User_first=s__User_NULL

            loop
                exitwhen i == 12

                set p=( i )
                set s__User_handle[p]=Player(i)
                set s__User_id[p]=i
           
                set s__User_Color[i]=GetPlayerColor(s__User_handle[p])
                set PlayerUtils___CurrentColor[i]=s__User_Color[i]
             
                if ( GetPlayerController(s__User_handle[p]) == MAP_CONTROL_USER and GetPlayerSlotState(s__User_handle[p]) == PLAYER_SLOT_STATE_PLAYING ) then

                    set s__User_PlayingPlayer[s__User_AmountPlaying]=p
                    set s__User_PlayingPlayerIndex[i]=s__User_AmountPlaying
                   
                   set s__User_last=i
                   
                    if ( s__User_first == s__User_NULL ) then
                        set s__User_first=i
                        set s__User_next[( i )]=s__User_NULL
                        set s__User_prev[( i )]=s__User_NULL
                    else
                        set s__User_prev[( i )]=s__User_id[s__User_PlayingPlayer[s__User_AmountPlaying - 1]]
                        set s__User_next[s__User_PlayingPlayer[s__User_AmountPlaying - 1]]=( i )
                        set s__User_next[( i )]=s__User_NULL
                    endif

                    set s__User_isPlaying[p]=true
               
                    call TriggerRegisterPlayerEvent(t, s__User_handle[p], EVENT_PLAYER_LEAVE)
                    call ForceAddPlayer(FORCE_PLAYING, s__User_handle[p])
               
                    set PlayerUtils___Hex[p]=PlayerUtils___OriginalHex[GetHandleId(s__User_Color[i])]
               
                    set s__User_AmountPlaying=s__User_AmountPlaying + 1

                endif
           
                set PlayerUtils___Name[p]=GetPlayerName(s__User_handle[p])
                set s__User_originalName[p]=PlayerUtils___Name[p]
           
                set i=i + 1
            endloop
       
            call TriggerAddCondition(t, Filter(function s__User_onLeave))
        endfunction
   


    //===========================================================================

























//library PlayerUtils ends
//library SimError:
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
            call StartSound(SimError___error)
        endif
    endfunction

    function SimError___init takes nothing returns nothing
         set SimError___error=CreateSoundFromLabel("InterfaceError", false, false, false, 10, 10)
         //call StartSound( error ) //apparently the bug in which you play a sound for the first time
                                    //and it doesn't work is not there anymore in patch 1.22
    endfunction


//library SimError ends
//library Table:
//***************************************************************
//* Table object 3.1
//* ------------
//*
//*   set t=Table.create() - instanceates a new table object
//*   call t.destroy()     - destroys it
//*   t[1234567]           - Get value for key 1234567
//*                          (zero if not assigned previously)
//*   set t[12341]=32      - Assigning it.
//*   call t.flush(12341)  - Flushes the stored value, so it
//*                          doesn't use any more memory
//*   t.exists(32)         - Was key 32 assigned? Notice
//*                          that flush() unassigns values.
//*   call t.reset()       - Flushes the whole contents of the
//*                          Table.
//*
//*   call t.destroy()     - Does reset() and also recycles the id.
//*
//*   If you use HandleTable instead of Table, it is the same
//* but it uses handles as keys, the same with StringTable.
//*
//*  You can use Table on structs' onInit  if the struct is
//* placed in a library that requires Table or outside a library.
//*
//*  You can also do 2D array syntax if you want to touch
//* mission keys directly, however, since this is shared space
//* you may want to prefix your mission keys accordingly:
//*
//*  set Table["thisstring"][ 7 ] = 2
//*  set Table["thisstring"][ 5 ] = Table["thisstring"][7]
//*
//***************************************************************

//=============================================================


        function s__Table___GTable_reset takes integer this returns nothing
            call FlushChildHashtable(Table___ht, ( this ))
        endfunction

        function s__Table___GTable_onDestroy takes integer this returns nothing
            call FlushChildHashtable(Table___ht, ( ( this ) )) // INLINED!!
        endfunction


    //Hey: Don't instanciate other people's textmacros that you are not supposed to, thanks.

//textmacro instance: Table__make("Table","integer","key" )

        function s__Table__getindex takes integer this,integer key returns integer
            return LoadInteger(Table___ht, ( this ), key)
        endfunction

        function s__Table__setindex takes integer this,integer key,integer value returns nothing
            call SaveInteger(Table___ht, ( this ), key, value)
        endfunction

        function s__Table_flush takes integer this,integer key returns nothing
            call RemoveSavedInteger(Table___ht, ( this ), key)
        endfunction

        function s__Table_exists takes integer this,integer key returns boolean
            return HaveSavedInteger(Table___ht, ( this ), key)
        endfunction

        function s__Table_flush2D takes string firstkey returns nothing
            call FlushChildHashtable(Table___ht, ( ( ( - StringHash(firstkey) ) ) )) // INLINED!!
        endfunction

        function s__Table__staticgetindex takes string firstkey returns integer
            return ( - StringHash(firstkey) )
        endfunction

//end of: Table__make("Table","integer","key" )
//textmacro instance: Table__make("StringTable","string", "StringHash(key)" )

        function s__StringTable__getindex takes integer this,string key returns integer
            return LoadInteger(Table___ht, ( this ), StringHash(key))
        endfunction

        function s__StringTable__setindex takes integer this,string key,integer value returns nothing
            call SaveInteger(Table___ht, ( this ), StringHash(key), value)
        endfunction

        function s__StringTable_flush takes integer this,string key returns nothing
            call RemoveSavedInteger(Table___ht, ( this ), StringHash(key))
        endfunction

        function s__StringTable_exists takes integer this,string key returns boolean
            return HaveSavedInteger(Table___ht, ( this ), StringHash(key))
        endfunction

        function s__StringTable_flush2D takes string firstkey returns nothing
            call FlushChildHashtable(Table___ht, ( ( ( - StringHash(firstkey) ) ) )) // INLINED!!
        endfunction

        function s__StringTable__staticgetindex takes string firstkey returns integer
            return ( - StringHash(firstkey) )
        endfunction

//end of: Table__make("StringTable","string", "StringHash(key)" )
//textmacro instance: Table__make("HandleTable","handle","GetHandleId(key)" )

        function s__HandleTable__getindex takes integer this,handle key returns integer
            return LoadInteger(Table___ht, ( this ), GetHandleId(key))
        endfunction

        function s__HandleTable__setindex takes integer this,handle key,integer value returns nothing
            call SaveInteger(Table___ht, ( this ), GetHandleId(key), value)
        endfunction

        function s__HandleTable_flush takes integer this,handle key returns nothing
            call RemoveSavedInteger(Table___ht, ( this ), GetHandleId(key))
        endfunction

        function s__HandleTable_exists takes integer this,handle key returns boolean
            return HaveSavedInteger(Table___ht, ( this ), GetHandleId(key))
        endfunction

        function s__HandleTable_flush2D takes string firstkey returns nothing
            call FlushChildHashtable(Table___ht, ( ( ( - StringHash(firstkey) ) ) )) // INLINED!!
        endfunction

        function s__HandleTable__staticgetindex takes string firstkey returns integer
            return ( - StringHash(firstkey) )
        endfunction

//end of: Table__make("HandleTable","handle","GetHandleId(key)" )


//library Table ends
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
            call SaveInteger(TimerUtils___ht, 0, GetHandleId(t), value)
            

















    endfunction

    function GetTimerData takes timer t returns integer

            // new blue
            return LoadInteger(TimerUtils___ht, 0, GetHandleId(t))
            

















    endfunction

    //==========================================================================================

    //==========================================================================================
    // I needed to decide between duplicating code ignoring the "Once and only once" rule
    // and using the ugly textmacros. I guess textmacros won.
    //

    function NewTimerEx takes integer value returns timer
        if ( TimerUtils___tN == 0 ) then
            if ( not TimerUtils___didinit ) then
                //This extra if shouldn't represent a major performance drawback
                //because QUANTITY rule is not supposed to be broken every day. 
                call TriggerEvaluate(st___prototype3[( 1 )]) // INLINED!!
                set TimerUtils___tN=TimerUtils___tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
                set s__TimerUtils___tT[0]=CreateTimer()















            endif
        else
            set TimerUtils___tN=TimerUtils___tN - 1
        endif
        call SaveInteger(TimerUtils___ht, 0, GetHandleId(( s__TimerUtils___tT[TimerUtils___tN] )), ( value )) // INLINED!!
     return s__TimerUtils___tT[TimerUtils___tN]
    endfunction
    
    function NewTimer takes nothing returns timer
        return NewTimerEx(0)
    endfunction


    //==========================================================================================
    function ReleaseTimer takes timer t returns nothing
        if ( t == null ) then
            return
        endif
        if ( TimerUtils___tN == TimerUtils___ARRAY_SIZE ) then
            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( ( LoadInteger(TimerUtils___ht, 0, GetHandleId(( t ))) ) == TimerUtils___HELD ) then // INLINED!!
                return
            endif
            call SaveInteger(TimerUtils___ht, 0, GetHandleId(( t )), ( TimerUtils___HELD )) // INLINED!!
            set s__TimerUtils___tT[TimerUtils___tN]=t
            set TimerUtils___tN=TimerUtils___tN + 1
        endif
    endfunction

    function TimerUtils___init takes nothing returns nothing
     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils___didinit ) then
            return
        else
            set TimerUtils___didinit=true
        endif
     

            set TimerUtils___ht=InitHashtable()
            loop
                exitwhen ( i == TimerUtils___QUANTITY )
                set s__TimerUtils___tT[i]=CreateTimer()
                call SaveInteger(TimerUtils___ht, 0, GetHandleId(( s__TimerUtils___tT[i] )), ( TimerUtils___HELD )) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils___tN=TimerUtils___QUANTITY










































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
        return s__MATRIX3_SetValues(Output , s__MATRIX3_m11[M1] * s__MATRIX3_m11[M2] + s__MATRIX3_m21[M1] * s__MATRIX3_m12[M2] + s__MATRIX3_m31[M1] * s__MATRIX3_m13[M2] , s__MATRIX3_m12[M1] * s__MATRIX3_m11[M2] + s__MATRIX3_m22[M1] * s__MATRIX3_m12[M2] + s__MATRIX3_m32[M1] * s__MATRIX3_m13[M2] , s__MATRIX3_m13[M1] * s__MATRIX3_m11[M2] + s__MATRIX3_m23[M1] * s__MATRIX3_m12[M2] + s__MATRIX3_m33[M1] * s__MATRIX3_m13[M2] , s__MATRIX3_m11[M1] * s__MATRIX3_m21[M2] + s__MATRIX3_m21[M1] * s__MATRIX3_m22[M2] + s__MATRIX3_m31[M1] * s__MATRIX3_m23[M2] , s__MATRIX3_m12[M1] * s__MATRIX3_m21[M2] + s__MATRIX3_m22[M1] * s__MATRIX3_m22[M2] + s__MATRIX3_m32[M1] * s__MATRIX3_m23[M2] , s__MATRIX3_m13[M1] * s__MATRIX3_m21[M2] + s__MATRIX3_m23[M1] * s__MATRIX3_m22[M2] + s__MATRIX3_m33[M1] * s__MATRIX3_m23[M2] , s__MATRIX3_m11[M1] * s__MATRIX3_m31[M2] + s__MATRIX3_m21[M1] * s__MATRIX3_m32[M2] + s__MATRIX3_m31[M1] * s__MATRIX3_m33[M2] , s__MATRIX3_m12[M1] * s__MATRIX3_m31[M2] + s__MATRIX3_m22[M1] * s__MATRIX3_m32[M2] + s__MATRIX3_m32[M1] * s__MATRIX3_m33[M2] , s__MATRIX3_m13[M1] * s__MATRIX3_m31[M2] + s__MATRIX3_m23[M1] * s__MATRIX3_m32[M2] + s__MATRIX3_m33[M1] * s__MATRIX3_m33[M2])
    endfunction

    function Matrix3Scaling takes integer Output,real x,real y,real z returns integer
        return s__MATRIX3_SetValues(Output , x , 0 , 0 , 0 , y , 0 , 0 , 0 , z)
    endfunction

    function Matrix3RotationX takes integer Output,real a returns integer
        return s__MATRIX3_SetValues(Output , 1 , 0 , 0 , 0 , Cos(a) , - Sin(a) , 0 , Sin(a) , Cos(a))
    endfunction

    function Matrix3RotationY takes integer Output,real a returns integer
        return s__MATRIX3_SetValues(Output , Cos(a) , 0 , Sin(a) , 0 , 1 , 0 , - Sin(a) , 0 , Cos(a))
    endfunction

    function Matrix3RotationZ takes integer Output,real a returns integer
        return s__MATRIX3_SetValues(Output , Cos(a) , - Sin(a) , 0 , Sin(a) , Cos(a) , 0 , 0 , 0 , 1)
    endfunction

    function Matrix3RotationAxis takes integer Output,integer v,real a returns integer
        local real cosa= Cos(a)
        local real sina= Sin(a)
        return s__MATRIX3_SetValues(Output , cosa + ( 1 - cosa ) * s__VECTOR3_x[v] * s__VECTOR3_x[v] , ( 1 - cosa ) * s__VECTOR3_x[v] * s__VECTOR3_y[v] - sina * s__VECTOR3_z[v] , ( 1 - cosa ) * s__VECTOR3_x[v] * s__VECTOR3_z[v] + sina * s__VECTOR3_y[v] , ( 1 - cosa ) * s__VECTOR3_y[v] * s__VECTOR3_x[v] + sina * s__VECTOR3_z[v] , cosa + ( 1 - cosa ) * s__VECTOR3_y[v] * s__VECTOR3_y[v] , ( 1 - cosa ) * s__VECTOR3_y[v] * s__VECTOR3_z[v] - sina * s__VECTOR3_x[v] , ( 1 - cosa ) * s__VECTOR3_z[v] * s__VECTOR3_x[v] - sina * s__VECTOR3_y[v] , ( 1 - cosa ) * s__VECTOR3_z[v] * s__VECTOR3_y[v] + sina * s__VECTOR3_x[v] , cosa + ( 1 - cosa ) * s__VECTOR3_z[v] * s__VECTOR3_z[v])
    endfunction

    function Matrix3RotationYawPitchRoll takes integer Output,real Yaw,real Pitch,real Roll returns integer
        local real cosa= Cos(Yaw)
        local real sina= Sin(Yaw)
        local real cosb= Cos(Pitch)
        local real sinb= Sin(Pitch)
        local real cosy= Cos(Roll)
        local real siny= Sin(Roll)
        return s__MATRIX3_SetValues(Output , cosa * cosb , cosa * sinb * siny - sina * cosy , cosa * sinb * cosy + sina * siny , sina * cosb , sina * sinb * siny + cosa * cosy , sina * sinb * cosy - cosa * siny , - sinb , cosb * siny , cosb * cosy)
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
        return s__MATRIX4_SetValues(Output , s__MATRIX4_m11[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m11[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m12[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m13[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m14[M2] , s__MATRIX4_m11[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m21[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m22[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m23[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m24[M2] , s__MATRIX4_m11[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m31[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m32[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m33[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m34[M2] , s__MATRIX4_m11[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m21[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m31[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m41[M1] * s__MATRIX4_m44[M2] , s__MATRIX4_m12[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m22[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m32[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m42[M1] * s__MATRIX4_m44[M2] , s__MATRIX4_m13[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m23[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m33[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m43[M1] * s__MATRIX4_m44[M2] , s__MATRIX4_m14[M1] * s__MATRIX4_m41[M2] + s__MATRIX4_m24[M1] * s__MATRIX4_m42[M2] + s__MATRIX4_m34[M1] * s__MATRIX4_m43[M2] + s__MATRIX4_m44[M1] * s__MATRIX4_m44[M2])
    endfunction

    function UIMath___Init takes nothing returns nothing
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
        return ( ( s__UnitDex_Unit[( ( GetUnitUserData(( u )) ) )] ) != null ) // INLINED!!
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
        
        
        
        
        
//Implemented from module UnitDex___UnitDexCore:
    
        function s__UnitDex_Remove takes unit u,boolean runEvents returns boolean
            local integer i
            
            if ( ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) ) then // INLINED!!
                set i=( GetUnitUserData(( u )) ) // INLINED!!
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
        
        function s__UnitDex_UnitDex___UnitDexCore__onGameStart takes nothing returns nothing
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
        
        function s__UnitDex_UnitDex___UnitDexCore__onEnter takes nothing returns boolean
            local unit u= GetFilterUnit()
            local integer i= ( GetUnitUserData(( u )) )
            local integer t= UnitDex___Index
            
            if ( i == 0 and s__UnitDex_Enabled ) then
                
                // If a filter was defined pass the unit through it.






                
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

        function s__UnitDex_UnitDex___UnitDexCore__onLeave takes nothing returns boolean
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
                
                set i=( GetUnitUserData(( u )) ) // INLINED!!

                // If unit has been indexed then deindex it
                if ( i > 0 and i <= s__UnitDex_Counter and u == ( s__UnitDex_Unit[( i )] ) ) then // INLINED!!
                    
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
        
        function s__UnitDex_UnitDex___UnitDexCore__onInit takes nothing returns nothing
            local trigger t= CreateTrigger()
            local integer i= 0
            local player p
            local unit u
            

                local region reg= CreateRegion()
                local rect world= GetWorldBounds()

            
            set UnitDex___FilterEnter=Filter(function s__UnitDex_UnitDex___UnitDexCore__onEnter)
            
            // Begin to index units when they enter the map



                call RegionAddRect(reg, world)
                call TriggerRegisterEnterRegion(CreateTrigger(), reg, UnitDex___FilterEnter)
                call RemoveRect(world)
                set world=null

            
            call TriggerAddCondition(t, Filter(function s__UnitDex_UnitDex___UnitDexCore__onLeave))
            
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
            
            call TimerStart(CreateTimer(), 0, false, function s__UnitDex_UnitDex___UnitDexCore__onGameStart)
        endfunction
    
    
    
     
    

//library UnitDex ends
//library xebasic:
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


//library xebasic ends
//library AutoIndex:

//processed:     function interface IndexFunc takes unit u returns nothing
    
    
    
        function s__AutoIndex_getIndex takes unit u returns integer
            return ( GetUnitUserData(( u )) ) // INLINED!!
        endfunction
        
        function s__AutoIndex_isUnitIndexed takes unit u returns boolean
            return u != null and s__UnitDex_Unit[( GetUnitUserData(( u )) )] == u // INLINED!!
        endfunction
    
        function s__AutoIndex_getIndexDebug takes unit u returns integer
            if u == null then
                return 0
            elseif GetUnitTypeId(u) == 0 then
                   call BJDebugMsg("AutoIndex error: Removed or decayed unit passed to GetUnitId.")
            elseif s__UnitDex_Unit[( GetUnitUserData(( u )) )] != u and GetIssuedOrderId() != 852056 then // INLINED!!
                call BJDebugMsg("AutoIndex error: " + GetUnitName(u) + " is a filtered unit.")
            endif
            
            return ( GetUnitUserData(( ( u ) )) ) // INLINED!!
        endfunction
        
        function s__AutoIndex_onUnitIndexed_sub takes nothing returns nothing
            call sc___prototype30_evaluate(s__AutoIndex_indexfunc , GetEnumUnit())
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


//library AutoIndex ends
//library Camera:


    function GetTerrainZ takes real x,real y returns real
        call MoveLocation(Camera_DummyLoc, x, y)
        return GetLocationZ(Camera_DummyLoc)
    endfunction
    
    function GetCameraDeltaZ takes nothing returns real
        return Camera___DeltaZ
    endfunction
    
    function Camera___Matrix4Perspective1 takes integer Output,real fovy,real Aspect,real zn,real zf returns integer
        return s__MATRIX4_SetValues(Output , 2 * zn / fovy , 0 , 0 , 0 , 0 , 2 * zn / Aspect , 0 , 0 , 0 , 0 , zf / ( zf - zn ) , 1 , 0 , 0 , zn * zf / ( zn - zf ) , 0)
    endfunction

    function Camera___Matrix4Perspective2 takes integer Output,real n,real f,real r,real l,real t,real b returns integer
        return s__MATRIX4_SetValues(Output , 2 * n / ( r - l ) , 0 , ( r + l ) / ( r - l ) , 0 , 0 , 2 * n / ( t - b ) , ( t + b ) / ( t - b ) , 0 , 0 , 0 , - ( f + n ) / ( f - n ) , - 2 * f * n / ( f - n ) , 0 , 0 , - 1 , 0)
    endfunction

    function Camera___Matrix4Look takes integer Output,integer PosCamera,integer AxisX,integer AxisY,integer AxisZ returns integer
        return s__MATRIX4_SetValues(Output , s__VECTOR3_x[AxisX] , s__VECTOR3_x[AxisY] , s__VECTOR3_x[AxisZ] , 0 , s__VECTOR3_y[AxisX] , s__VECTOR3_y[AxisY] , s__VECTOR3_y[AxisZ] , 0 , s__VECTOR3_z[AxisX] , s__VECTOR3_z[AxisY] , s__VECTOR3_z[AxisZ] , 0 , - Vec3Dot(AxisX , PosCamera) , - Vec3Dot(AxisY , PosCamera) , - Vec3Dot(AxisZ , PosCamera) , 1)
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
            call s__Camera_destroy(this)
        endfunction
        

    
//Implemented from module Camera___CamInitModule:
        function s__Camera___CamInit_Camera___CamInitModule__onInit takes nothing returns nothing
            local integer i= 0
            local integer user
            
            loop
                exitwhen i == s__User_AmountPlaying
                
                set user=( s__User_PlayingPlayer[( i )] ) // INLINED!!
                
                set Camera_DummyUnit[s__User_id[user]]=CreateUnit(CAMERA_DUMMY_PLAYER, CAMERA_DUMMY_TYPE, 0, 0, 0)
                call ShowUnit(Camera_DummyUnit[s__User_id[user]], false)
                call PauseUnit(Camera_DummyUnit[s__User_id[user]], true)
                
                set i=i + 1
            endloop
            
            // init delta z
            call SetCameraPosition(CHECK_DELTAZ_X, CHECK_DELTAZ_Y)
            set Camera___DeltaZ=GetCameraTargetPositionZ() - 6
        endfunction
    

//library Camera ends
//library InventoryItem:
    
    
        
        
//Implemented from module InvItemPlugins:
        //
        // Tooltip building 
        //
        
        function s__InvItem_InvItemTooltip__getStringLine takes string str,integer line returns string
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
        
            if ( StringLength(s__InvItem_lTrim(this , s__InvItem_info[this])) <= 0 ) then
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
                    
                    call sc__Inventory_setTooltipLine(pid , startLine + j , s__InvItem_lTrim(this , line))
    
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
                call sc__Inventory_setTooltipLine(pid , startLine , s__InvItem_lTrim(this , line))
            elseif ( line != "" ) then
                call sc__Inventory_setTooltipLine(pid , startLine + j , s__InvItem_lTrim(this , line))
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
                local integer total= ( LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_AMOUNT, ( ( this ) * s__InvItem_MAX_BONUSES ) + ( index )) )
                set bj_cineModeSavedSeed=GetRandomInt(0, 1000000)
                call SetRandomSeed(sc__InvCustomItem_seed(( s__InvItem_tempCustomId[this] )))
                set total=total + ( GetRandomInt(( LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MIN, ( ( this ) * s__InvItem_MAX_BONUSES ) + ( index )) ), ( LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_MAX, ( ( this ) * s__InvItem_MAX_BONUSES ) + ( index )) )) ) // INLINED!!
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
                    
                    call sc__BonusModStruct_addBonus(u , ( LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( ( this ) * s__InvItem_MAX_BONUSES ) + ( i )) ) , s__InvItem_getBonusTotal(this , i) * m) // INLINED!!
                    
                    set i=i + 1
                endloop

                set i=0
                
                loop
                    exitwhen i >= ( LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( this )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100) ) // INLINED!!
                    
                    set itm=sc__InvItem_getSocket(this , i)
                    set s__InvItem_tempCustomId[itm]=sc__InvItem_socketId(this , i)
                    
                    set n=0
                    
                    loop
                        exitwhen n == s__InvItem_bonuses[itm]
                        
                        call sc__BonusModStruct_addBonus(u , ( LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( ( itm ) * s__InvItem_MAX_BONUSES ) + ( n )) ) , s__InvItem_getBonusTotal(itm , n) * m) // INLINED!!
                        
                        set n=n + 1
                    endloop
                    
                    set i=i + 1
                endloop
            endfunction
            
            function s__InvItem_applyBonuses takes integer this,unit u returns nothing
                call s__InvItem_addBonusesMultiplier(this , u , 1)
            endfunction
            
            function s__InvItem_removeBonuses takes integer this,unit u returns nothing
                call s__InvItem_addBonusesMultiplier(this , u , - 1)
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
            
            call TriggerExecute(st___prototype3[( 2 )]) // INLINED!!
            
            call sc__Inventory_clearLines(pid)
            
            // slot type
            set out=s__InvItem_GearSlotName(s__InvItem_slot[this])
            
            if ( out != "" ) then
                set out="|cffffcc00Slot:|r " + out

                call sc__Inventory_setTooltipSlot(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + s__Inventory_TOOLTIP_LINES_MAX] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
            endif
            
            // item description
            set lines=s__InvItem_buildDescriptionLines(this , pid , 0)
            
            if ( lines != 0 ) then
                set lines=lines + 1
            endif
            
            // item ability
            if ( s__InvItem_ability[this] > 0 ) then
                set out="|cfffedaac" + GetObjectName(s__InvItem_ability[this]) + "|r (Does not stack)\n"
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // equip ability
            if ( s__InvItem_equipAbility[this] > 0 ) then
                set out="|cfffedaac" + GetObjectName(s__InvItem_equipAbility[this]) + "|r\n"
                
                call sc__Inventory_setTooltipLine(pid , lines , out)
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // equip bonuses

                loop
                    exitwhen i >= s__InvItem_bonuses[this]
                    
                    set bonusName=( EquipmentItem_BonusString[( ( LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( ( this ) * s__InvItem_MAX_BONUSES ) + ( i )) ) )] ) // INLINED!!
  
                    if ( bonusName != null and bonusName != "" ) then
                        
                        set total=s__InvItem_getBonusTotal(this , i)
                        
                        if ( total > 0 ) then
                            set out="|cfffedaac+" + I2S(total) + " to " + bonusName + "|r"
                            
                            call sc__Inventory_setTooltipLine(pid , lines , out)
                            call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
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
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
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
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
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
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
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
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                
                set lines=lines + 1
            endif
            
            // sockets
            set i=0
            
            if ( s__InvItem_maxSockets[this] > 0 ) then
                if ( s__Inventory_RightSideStart[pid] != lines ) then
                    call sc__Inventory_setTooltipLine(pid , lines , "")
                    call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                    set lines=lines + 1
                endif
                call sc__Inventory_setTooltipLine(pid , lines , "Sockets: " + I2S(( LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( this )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100) )) + "/" + I2S(s__InvItem_maxSockets[this])) // INLINED!!
                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                set lines=lines + 1
            endif
            
            loop
                exitwhen i >= s__InvItem_maxSockets[this]
                
                set itm=sc__InvItem_getSocket(this , i)
                
                if ( itm > 0 ) then
                
                    set s__InvItem_tempCustomId[itm]=sc__InvItem_socketId(this , i)
                    
                    set n=0
                    
                    loop
                        exitwhen n >= s__InvItem_bonuses[itm]
                    
                        set bonusName=( EquipmentItem_BonusString[( ( LoadInteger(s__Inventory_Hashtable, s__InvItem_KEY_BONUS_TYPE, ( ( itm ) * s__InvItem_MAX_BONUSES ) + ( n )) ) )] ) // INLINED!!
   
                        if ( bonusName != null and bonusName != "" ) then
                            
                            set total=s__InvItem_getBonusTotal(itm , n)
                            
                            if ( total > 0 ) then
                                set out="|cff5566bb+" + I2S(total) + " to " + bonusName + "|r\n"
                                
                                call sc__Inventory_setTooltipLine(pid , lines , out)
                                call sc__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + lines] , true , s__Inventory_camera[s__Inventory_PlayerCurrent[pid]])
                                
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
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100)
        endfunction
        
        function s__InvItem__set_sockets takes integer this,integer val returns nothing
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100, val)
        endfunction
        
        function s__InvItem_socketId takes integer this,integer index returns integer
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket__KEY_SOCKETS_ID * 100 ) + index)
        endfunction
        
        
        function s__InvItem_addSocket takes integer this,integer socket returns boolean
            if s__InvItem_isSocket[this] then
                return false
            endif
            
            if ( ( LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( this )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100) ) >= s__InvItem_maxSockets[this] ) then // INLINED!!
                return false
            endif
            
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket__KEY_SOCKETS * 100 ) + ( LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( this )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100) ), socket) // INLINED!!
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket__KEY_SOCKETS_ID * 100 ) + ( LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( this )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100) ), s__InvItem_tempCustomId[socket]) // INLINED!!
            
            call SaveInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( this )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100, ( ( LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( this )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100) ) + 1 )) // INLINED!!
            
            return true
        endfunction
        
        function s__InvItem_getSocket takes integer this,integer index returns integer
            if s__InvItem_isSocket[this] then
                return 0
            endif
            
            return LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket__KEY_SOCKETS * 100 ) + index)
        endfunction
        
        





        





        
        function s__InvItem_onInit takes nothing returns nothing
            set s__InvItem_Table=s__Table__allocate()
        endfunction
    
    function GetInvItem takes integer id returns integer
        return ( ( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( id )) ) ) // INLINED!!
    endfunction
    
    function GetItemInfo takes integer id returns string
        return s__InvItem_info[( ( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( id )) ) )] // INLINED!!
    endfunction
    
    function GetItemDescription takes integer id returns string
        return s__InvItem_info[( ( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( id )) ) )] // INLINED!!
    endfunction
    
    function GetItemIcon takes integer id returns integer
        local integer icon= s__InvItem_icon[( ( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( id )) ) )]
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
        call SaveInteger(Table___ht, ( ( s__InvItem_Table ) ), ( s__InvItem_id[itm] ), ( itm )) // INLINED!!
        return itm
    endfunction
    
        
        function s__InvCustomItem_create takes nothing returns integer
            local integer this= s__InvCustomItem_Counter
            call SaveInteger(Table___ht, ( ( s__InvCustomItem_SeedTable ) ), ( this ), ( GetRandomInt(InventoryItem_SEED_START, InventoryItem_SEED_END) )) // INLINED!!
            set s__InvCustomItem_Counter=s__InvCustomItem_Counter + 1
            return this
        endfunction
        
        function s__InvCustomItem_seed takes integer this returns integer
            return ( LoadInteger(Table___ht, ( ( s__InvCustomItem_SeedTable ) ), ( this )) ) // INLINED!!
        endfunction
        
        function s__InvCustomItem_onInit takes nothing returns nothing
            set s__InvCustomItem_SeedTable=s__Table__allocate()
        endfunction


//library InventoryItem ends
//library xepreload:
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
        call UnitAddAbility(xepreload___dum, abilid)







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
    function xepreload___DebugIdInteger2IdString takes integer value returns string
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
    function xepreload___kill takes nothing returns nothing
        call RemoveUnit(xepreload___dum)
        set xepreload___dum=null

            call ReleaseTimer(GetExpiredTimer())



    endfunction


//Implemented from module xepreload___PreloadInit:
        function s__xepreload___Init_xepreload___PreloadInit__onInit takes nothing returns nothing
            local timer t
            set xepreload___dum=CreateUnit(Player(15), XE_DUMMY_UNITID, 0, 0, 0)
            if ( xepreload___dum == null ) then
            endif

                set t=( NewTimerEx(0) ) // INLINED!!



            call TimerStart(t, 0.0, false, function xepreload___kill)
            set t=null
        endfunction
    

//library xepreload ends
//library BonusMod:

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
//processed :     //! externalblock extension=lua ObjectMerger $FILENAME$
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
    set BONUS_ARMOR=sc__BonusMod___AbilityBonus_create('(A)a' , 10 , '(A)-' , false)
//end of: BonusMod_DeclareBonus("ARMOR",        "10",  "AId1", "(A)", "Idef", "false", "BTNHumanArmorUpOne.blp")
//textmacro instance: BonusMod_DeclareBonus("DAMAGE",       "10",  "AItg", "(B)", "Iatt", "false", "BTNSteelMelee.blp")
    set BONUS_DAMAGE=sc__BonusMod___AbilityBonus_create('(B)a' , 10 , '(B)-' , false)
//end of: BonusMod_DeclareBonus("DAMAGE",       "10",  "AItg", "(B)", "Iatt", "false", "BTNSteelMelee.blp")
//textmacro instance: BonusMod_DeclareBonus("SIGHT_RANGE",  "11",  "AIsi", "(C)", "Isib", "false", "BTNTelescope.blp")
    set BONUS_SIGHT_RANGE=sc__BonusMod___AbilityBonus_create('(C)a' , 11 , '(C)-' , false)
//end of: BonusMod_DeclareBonus("SIGHT_RANGE",  "11",  "AIsi", "(C)", "Isib", "false", "BTNTelescope.blp")
//textmacro instance: BonusMod_DeclareBonus("LIFE_REGEN",   "8",   "Arel", "(E)", "Ihpr", "false", "BTNRingSkull.blp")
    set BONUS_LIFE_REGEN=sc__BonusMod___AbilityBonus_create('(E)a' , 8 , '(E)-' , false)
//end of: BonusMod_DeclareBonus("LIFE_REGEN",   "8",   "Arel", "(E)", "Ihpr", "false", "BTNRingSkull.blp")
//textmacro instance: BonusMod_DeclareBonus("STRENGTH",     "8",   "AIa1", "(F)", "Istr", "true" , "BTNGoldRing.blp")
    set BONUS_STRENGTH=sc__BonusMod___AbilityBonus_create('(F)a' , 8 , '(F)-' , true)
//end of: BonusMod_DeclareBonus("STRENGTH",     "8",   "AIa1", "(F)", "Istr", "true" , "BTNGoldRing.blp")
//textmacro instance: BonusMod_DeclareBonus("AGILITY",      "8",   "AIa1", "(G)", "Iagi", "true" , "BTNGoldRing.blp")
    set BONUS_AGILITY=sc__BonusMod___AbilityBonus_create('(G)a' , 8 , '(G)-' , true)
//end of: BonusMod_DeclareBonus("AGILITY",      "8",   "AIa1", "(G)", "Iagi", "true" , "BTNGoldRing.blp")
//textmacro instance: BonusMod_DeclareBonus("INTELLIGENCE", "8",   "AIa1", "(H)", "Iint", "true" , "BTNGoldRing.blp")
    set BONUS_INTELLIGENCE=sc__BonusMod___AbilityBonus_create('(H)a' , 8 , '(H)-' , true)
//end of: BonusMod_DeclareBonus("INTELLIGENCE", "8",   "AIa1", "(H)", "Iint", "true" , "BTNGoldRing.blp")
    
    //                                           |     NAME          |ABILITY|SOURCE |PREFIX|FIELD  |HERO   |  ICON
    //                                           |                   | COUNT |ABILITY|      |       | ONLY  |
//textmacro instance: BonusMod_DeclarePercentBonus("ATTACK_SPEED",       "9", "AIsx",  "(I)", "Isx1", "false", "BTNGlove.blp")
    set BONUS_ATTACK_SPEED=sc__BonusMod___AbilityBonus_create('(I)a' , 9 , '(I)-' , false)
//end of: BonusMod_DeclarePercentBonus("ATTACK_SPEED",       "9", "AIsx",  "(I)", "Isx1", "false", "BTNGlove.blp")
//textmacro instance: BonusMod_DeclarePercentBonus("MANA_REGEN_PERCENT", "9", "AIrm",  "(D)", "Imrp", "false", "BTNSobiMask.blp")
    set BONUS_MANA_REGEN_PERCENT=sc__BonusMod___AbilityBonus_create('(D)a' , 9 , '(D)-' , false)
//end of: BonusMod_DeclarePercentBonus("MANA_REGEN_PERCENT", "9", "AIrm",  "(D)", "Imrp", "false", "BTNSobiMask.blp")
    
//textmacro instance: BonusMod_EndBonuses()
    //*
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


            call UnitAddAbility(xepreload___dum, ( abilityId )) // INLINED!!






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
        return 0
    endfunction
    
    function s__Bonus_getBonus takes integer this,unit u returns integer
        return 0
    endfunction
    
    function s__Bonus_removeBonus takes integer this,unit u returns nothing
        call sc__Bonus_setBonus(this , u , 0)
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
                
                call UnitAddAbility(xepreload___dum, ( ( rawcode + i ) )) // INLINED!!
                
                set i=i + 1
            endloop
            
            if negativeRawcode != 0 then
                call UnitAddAbility(xepreload___dum, ( ( negativeRawcode ) )) // INLINED!!
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
        return sc___prototype42_evaluate(1 , u , this , amount)
    endfunction
    
    function s__BonusMod___AbilityBonus_getBonus takes integer this,unit u returns integer
        return sc___prototype43_evaluate(1 , u , this)
    endfunction
    
    function s__BonusMod___AbilityBonus_removeBonus takes integer this,unit u returns nothing
        call sc___prototype41_evaluate(1 , u , this)
    endfunction
    
    function s__BonusMod___AbilityBonus_isValidBonus takes integer this,unit u,integer value returns boolean
        return ( value >= s__BonusMod___BonusInterface_minBonus[this] ) and ( value <= s__BonusMod___BonusInterface_maxBonus[this] )
    endfunction

// ===
//  Public API
// ===

function IsBonusValid takes unit u,integer abstractBonus,integer value returns boolean
    local integer bonus= ( abstractBonus )
    





    
    if ( s__BonusMod___BonusInterface_minBonus[( abstractBonus )] ) > value or ( s__BonusMod___BonusInterface_maxBonus[( abstractBonus )] ) < value then // INLINED!!
        return false
    endif
    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        return sc__Bonus_isValidBonus(abstractBonus , u , value)
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
        return false
    endif
    
    return ( value >= s__BonusMod___BonusInterface_minBonus[bonus] ) and ( value <= s__BonusMod___BonusInterface_maxBonus[bonus] )
endfunction

function RemoveUnitBonus takes unit u,integer abstractBonus returns nothing
    local integer i= 0
    local integer bonus= ( abstractBonus )






    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        call sc__Bonus_removeBonus(abstractBonus , u)
        return
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
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
    local integer bonus= ( abstractBonus )
    local boolean applyMinBonus= false
    





    
    if amount == 0 then
        call RemoveUnitBonus(u , bonus)
        return 0
    endif
    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        return sc__Bonus_setBonus(abstractBonus , u , amount)
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
        return 0
    endif
    
    if amount < s__BonusMod___BonusInterface_minBonus[bonus] then
        set amount=s__BonusMod___BonusInterface_minBonus[bonus]
    elseif amount > s__BonusMod___BonusInterface_maxBonus[bonus] then
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
    local integer bonus= ( abstractBonus )






    
    if si__BonusMod___BonusInterface_type[abstractBonus] != si__BonusMod___AbilityBonus then
        return sc__Bonus_getBonus(abstractBonus , u)
    endif
    
    if s__BonusMod___AbilityBonus_heroesOnly[bonus] and not IsUnitType(u, UNIT_TYPE_HERO) then
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

    function s__BonusModStruct_BonusMod___BonusModInitModule__onInit takes nothing returns nothing
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


//library BonusMod ends
//library UnitMaxState:
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
//processed :     //! externalblock extension=lua ObjectMerger $FILENAME$
    // */
    
//end of: UnitMaxState_Configuration("false", "3", "ZxL", "ZxM")

//------------------------------------------------------------------------------
// End of configuration
//------------------------------------------------------------------------------


function UnitMaxState___ErrorMsg takes string s returns nothing
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


//library UnitMaxState ends
//library UserInterface:


    // configuration
    // end configuration


    function GetTriggerButton takes nothing returns integer
        return UserInterface___ClickedButton
    endfunction
    
    function GetClickingPlayer takes nothing returns player
        return UserInterface___ClickingPlayer
    endfunction

    function UserInterface_Eval takes filterfunc func returns boolean
        call TriggerClearConditions(UserInterface___Trig)
        call TriggerAddCondition(UserInterface___Trig, func)
        return TriggerEvaluate(UserInterface___Trig)
    endfunction

    function UserInterface_GetTerrainZ takes real x,real y returns real
        call MoveLocation(UserInterface___DummyLoc, x, y)
        return GetLocationZ(UserInterface___DummyLoc)
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

    function UserInterface___LocalReal takes player p,real forPlayer,real default returns real
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
                set Pos=s__Camera_win2World(s__UIButton_camera[this] , s__UIButton_centerx[this] , s__UIButton_centery[this] , s__UIButton_z[this])
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
            call s__UIButton_show(this , flag , cam)
            
            if ( flag ) then
                call SetUnitScale(s__UIButton_picture[this], UserInterface___LocalReal(p , s__UIButton_scale[this] , 0), 0, 0)
            endif
        endfunction

        function s__UIButton_isClicked takes integer this,real x,real y returns boolean
            return s__UIButton_minx[this] < x and x < s__UIButton_maxx[this] and s__UIButton_miny[this] < y and y < s__UIButton_maxy[this]
        endfunction
        
        function s__UIButton_clickL takes integer this returns nothing
            set UserInterface___ClickedButton=this

            if ( s__UIButton_triggerL[this] != null and TriggerEvaluate(s__UIButton_triggerL[this]) ) then
                call TriggerExecute(s__UIButton_triggerL[this])
            endif

            if ( s__UIButton_onLeftClick[this] != null ) then
                 call UserInterface_Eval(s__UIButton_onLeftClick[this])
            endif
        endfunction
        
        function s__UIButton_clickR takes integer this returns nothing
            set UserInterface___ClickedButton=this

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

                if s__UIButton_isClicked(s__UIButton_AllShow[i] , x , y) then
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


                local integer btn= ( ( LoadInteger(TimerUtils___ht, 0, GetHandleId(( t ))) ) )




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
                set Pos=s__Camera_win2World(s__UIPicture_camera[this] , s__UIPicture_centerx[this] , s__UIPicture_centery[this] , s__UIPicture_z[this])
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
            call s__UIPicture_show(this , flag , cam)
            
            if ( flag ) then
                call SetUnitScale(s__UIPicture_picture[this], UserInterface___LocalReal(p , s__UIPicture_scale[this] , 0), 0, 0)
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
            local integer Pos= s__Camera_win2World(s__UIText_camera[this] , s__UIText_minx[this] , s__UIText_maxy[this] , s__UIText_z[this])
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


        
//Implemented from module UserInterface___InterfaceConfig:
    
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
        return s__UIPicture_createEx(x , y , 2 , size , s__Interface_WINDOW_DUMMY , width , height , ( s__Interface_RACE_BORDERS_START + ( GetHandleId(( playerRace )) - 1 ) )) // INLINED!!
    endfunction
    
    function UserInterface___InterfaceClickR takes nothing returns nothing
        local unit clicker= GetTriggerUnit()
        local unit btnUnit= GetOrderTargetUnit()
        
        set UserInterface___ClickingPlayer=GetOwningPlayer(clicker)
        
        if ( s__UIButton_click(btnUnit , false) ) then
            call PauseUnit(clicker, true)
            call IssueImmediateOrderById(clicker, 851973)
            call PauseUnit(clicker, false)
        endif
        
        set clicker=null
    endfunction
    
    function UserInterface___InterfaceClickL takes nothing returns nothing
        set UserInterface___ClickingPlayer=GetTriggerPlayer()
        call s__UIButton_click(GetTriggerUnit() , true)
    endfunction

    function UserInterface___InterfaceClickL_Timer takes nothing returns nothing
        local integer i= 0
        local integer c= s__UIButton_CountShow
        local integer user= s__User_first
        
        loop
            exitwhen user == s__User_NULL
  
            set UserInterface___ClickingPlayer=s__User_handle[user]
            
            call s__UIButton_clickPeriodicSelect(s__User_handle[user] , true)

            set user=s__User_next[user]
        endloop
    endfunction
    
    function UserInterface___Init takes nothing returns nothing
         local trigger t= CreateTrigger()
         local trigger t2= CreateTrigger()
         local integer i= 0
         local integer user= s__User_first
        
         loop
            exitwhen user == s__User_NULL
            
            call TriggerRegisterPlayerUnitEvent(t, s__User_handle[user], EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null)
            



            
            set user=s__User_next[user]
        endloop

        call TriggerAddAction(t, function UserInterface___InterfaceClickR)
        

            call TimerStart(CreateTimer(), s__Interface_LEFT_CLICK_TIMER_RATE, true, function UserInterface___InterfaceClickL_Timer)




        set s__UIButton_useDelay=s__Interface_LEFT_CLICK_TIMER
    endfunction
    

//library UserInterface ends
//library InventoryBonuses:

//library InventoryBonuses ends
//library InventoryCore:
    
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
            if ( s__User_Local != s__User_handle[( pid )] ) then
                set value=other
            endif
            return value
        endfunction
        
        function s__Inventory_err takes player p,string s returns nothing


                    call SimError(p , s)




        endfunction
        
        function s__Inventory__staticgetindex takes unit u returns integer
            return ( LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(u)) )
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
            return ( LoadInteger(Table___ht, ( ( s__Inventory_countTable[this] ) ), ( id )) ) // INLINED!!
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
            
            set btn=( s__Inventory_buttons[( s__Inventory_pid[( this )] * s__Inventory_MAX_SLOTS ) + ( slot )] ) // INLINED!!

            set oldItem=( LoadInteger(s__Inventory_Hashtable, ( this ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( index )) ) // INLINED!!
            
            call SaveInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + index, itm)
            
            if ( s__InvItem_tempCustomId[itm] > 0 ) then
                call SaveInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + index, s__InvItem_tempCustomId[itm])
            endif
            
            set s__InvItem_tempCustomId[itm]=0
            
            if ( id == 0 and HaveSavedInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + index) ) then
                set id=s__InvItem_id[oldItem]
                
                set s__Inventory_itemCount[this]=s__Inventory_itemCount[this] - 1
                call SaveInteger(Table___ht, ( ( s__Inventory_countTable[this] ) ), ( id ), ( ( LoadInteger(Table___ht, ( ( s__Inventory_countTable[this] ) ), ( id )) ) - 1 )) // INLINED!!
                
                call RemoveSavedInteger(s__Inventory_Hashtable, this, ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + index)
                
                // remove ability
                if ( s__InvItem_ability[oldItem] > 0 and ( LoadInteger(Table___ht, ( ( s__Inventory_countTable[( this )] ) ), ( ( id ) )) ) <= 0 ) then // INLINED!!
                    call UnitRemoveAbility(s__Inventory_owner[this], s__InvItem_ability[oldItem])
                endif
            elseif ( id > 0 ) then
                set s__Inventory_itemCount[this]=s__Inventory_itemCount[this] + 1
                call SaveInteger(Table___ht, ( ( s__Inventory_countTable[this] ) ), ( id ), ( ( LoadInteger(Table___ht, ( ( s__Inventory_countTable[this] ) ), ( id )) ) + 1 )) // INLINED!!
                
                // add ability
                if ( s__InvItem_ability[itm] > 0 and ( LoadInteger(Table___ht, ( ( s__Inventory_countTable[( this )] ) ), ( ( id ) )) ) == 1 ) then // INLINED!!
                    call UnitAddAbility(s__Inventory_owner[this], s__InvItem_ability[itm])
                endif
            endif
            
            call s__UIButton_setTexture(btn , s__Inventory_localInt(s__Inventory_pid[this] , icon , s__Inventory_ICON_TRANSPARENT))
            call s__UIButton_showPlayer(btn , s__User_handle[s__Inventory_user[this]] , s__Inventory_displayed[this] , s__Inventory_camera[this])
        endfunction
        
        function s__Inventory_findFreeSlot takes integer this,integer page returns integer
            local integer i= 0
            loop
                exitwhen i == s__Inventory_MAX_SLOTS
                if ( ( LoadInteger(s__Inventory_Hashtable, ( this ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( ( s__Inventory_MAX_SLOTS * page ) + i )) ) == 0 ) then // INLINED!!
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
                call s__UIPicture_show(s__Inventory_selector[s__User_id[s__Inventory_user[this]]] , false , s__Inventory_camera[this])
                
                call AddSpecialEffectTarget("UI\\TRSHerolevel.mdx", s__UIPicture_picture[s__Inventory_selector[s__Inventory_pid[this]]], "origin")
            endif
            
            loop
                exitwhen col == s__Inventory_BUTTON_COLS
                
                set row=0
                
                loop
                    exitwhen row == s__Inventory_BUTTON_ROWS
                    
                    if ( ( s__Inventory_buttons[( s__Inventory_pid[( this )] * s__Inventory_MAX_SLOTS ) + ( i )] ) == 0 ) then // INLINED!!
                    
                        set btn=s__UIButton_create(( s__Inventory_X + s__Inventory_SLOT_OFFSET_X ) + ( row * ( s__Inventory_SLOT_WIDTH * s__Inventory_SLOT_SPACING ) ) , ( s__Inventory_Y + s__Inventory_SLOT_OFFSET_Y ) - ( col * ( s__Inventory_SLOT_HEIGHT * s__Inventory_SLOT_SPACING ) ) , s__Inventory_SLOT_WIDTH , s__Inventory_SLOT_HEIGHT , 0.5 , GetItemIcon(s__InvItem_id[( LoadInteger(s__Inventory_Hashtable, ( this ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( i )) )])) // INLINED!!
                        
                        set s__UIButton_customValue[btn]=i
                        
                        set s__UIButton_selectUnit[btn]=s__Inventory_owner[this]
                        
                        set s__UIButton_onLeftClick[btn]=InvFuncLClickSlot
                        set s__UIButton_onRightClick[btn]=InvFuncRClickSlot
                        
                        set s__Inventory_buttons[( s__Inventory_pid[( this )] * s__Inventory_MAX_SLOTS ) + ( i )]=( btn ) // INLINED!!

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
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[this]] , id)
        endfunction
        
        function s__Inventory_setTooltipLine takes integer pid,integer line,string str returns nothing
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + line]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
        endfunction
        
        function s__Inventory_setTooltipSlot takes integer pid,integer line,string str returns nothing
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + s__Inventory_TOOLTIP_LINES_MAX - 1]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
        endfunction
        
        function s__Inventory_showLines takes integer this,integer pid,boolean flag,integer cam returns nothing
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                if ( not flag ) then
                    call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + i]], "", s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
                endif
                call s__UIText_show(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + i] , flag , cam)
                set i=i + 1
            endloop
        endfunction
        
        function s__Inventory_clearLines takes integer pid returns nothing
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + i]], "", s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
                set i=i + 1
            endloop
        endfunction
        
        function s__Inventory_updateLines takes integer pid returns nothing
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                call s__UIText_update(s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + i])
                set i=i + 1
            endloop
        endfunction
        
        function s__Inventory_createTooltip takes integer this,integer raceId returns nothing
            local boolean showLocally= ( s__User_Local == s__User_handle[( s__Inventory_pid[this] )] )
            local integer i= 0
        
            //if (showLocally) then
                if ( s__Inventory_infoBoxTitle[s__Inventory_pid[this]] == null ) then
                    set s__Inventory_infoBoxTitle[s__Inventory_pid[this]]=s__UIText_createEx(( s__User_handle[( s__Inventory_user[this] )] ) , s__Inventory_TOOLTIP_X - 0.1 , s__Inventory_TOOLTIP_Y + .22 , 1) // INLINED!!
                    
                    set s__Inventory_infoBoxDesc[s__Inventory_pid[this]]=s__UIText_createEx(( s__User_handle[( s__Inventory_user[this] )] ) , s__Inventory_TOOLTIP_X - 0.1 , s__Inventory_TOOLTIP_Y + .25 , 1) // INLINED!!
                endif
                
                if ( s__Inventory_infoBoxCost[s__Inventory_pid[this]] == null ) then
                    set s__Inventory_infoBoxCost[s__Inventory_pid[this]]=s__UIText_createEx(( s__User_handle[( s__Inventory_user[this] )] ) , s__Inventory_TOOLTIP_X - ( 0.065 - 0. ) , s__Inventory_TOOLTIP_Y + .15 , 1) // INLINED!!
                endif
                
                
                // description lines
                if ( s__s__Inventory_ItemInfoTags[( s__Inventory_pid[this] ) * ( 16 ) + 0] == 0 ) then
                    loop
                        exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                        
                        if ( i == s__Inventory_TOOLTIP_LINES_MAX - 1 ) then
                            set s__s__Inventory_ItemInfoTags[( s__Inventory_pid[this] ) * ( 16 ) + i]=s__UIText_createEx(( s__User_handle[( s__Inventory_user[this] )] ) , s__Inventory_TOOLTIP_X + 0.05 , s__Inventory_TOOLTIP_Y + .16 , 1) // INLINED!!
                        else
                            set s__s__Inventory_ItemInfoTags[( s__Inventory_pid[this] ) * ( 16 ) + i]=s__UIText_createEx(( s__User_handle[( s__Inventory_user[this] )] ) , s__Inventory_TOOLTIP_X - 0.18 , s__Inventory_TOOLTIP_Y - ( - .05 + ( s__Inventory_TOOLTIP_LINE_SPACING * i ) ) , 1) // INLINED!!
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
            
            call s__UIPicture_setTexture(s__Inventory_costIcon[s__Inventory_pid[this]] , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_TOOLTIP_GOLD , s__Inventory_ICON_TRANSPARENT))
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[this]] , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_ICON_TOOLTIP_GOLD , s__Inventory_ICON_TRANSPARENT))
            
            call SetUnitVertexColor(s__UIPicture_picture[s__Inventory_infoBox[s__Inventory_pid[this]]], 255, 255, 255, s__Inventory_localInt(s__Inventory_pid[this] , 255 , 0))
        endfunction
        
        function s__Inventory_showTooltip takes integer this,boolean flag returns nothing
            local integer i= 0
            
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                if ( i < s__Inventory_RightSideStart[s__Inventory_pid[this]] ) then
                    call s__UIText_setPosition(s__s__Inventory_ItemInfoTags[( s__Inventory_pid[this] ) * ( 16 ) + i] , s__Inventory_TOOLTIP_X - 0.15 , ( s__Inventory_TOOLTIP_Y - 0.05 ) - ( ( s__Inventory_TOOLTIP_LINE_SPACING * i ) ))
                else
                    call s__UIText_setPosition(s__s__Inventory_ItemInfoTags[( s__Inventory_pid[this] ) * ( 16 ) + i] , s__Inventory_TOOLTIP_X + 0.175 , ( s__Inventory_TOOLTIP_Y - 0.05 ) - ( ( s__Inventory_TOOLTIP_LINE_SPACING * ( i - s__Inventory_RightSideStart[s__Inventory_pid[this]] ) ) ))
                endif
                set i=i + 1
            endloop
                    
            call s__UIText_setPosition(s__s__Inventory_ItemInfoTags[( s__Inventory_pid[this] ) * ( 16 ) + s__Inventory_TOOLTIP_LINES_MAX - 1] , s__Inventory_TOOLTIP_X + 0.175 , s__Inventory_TOOLTIP_Y + 0.05)
            
            call s__UIPicture_setPosition(s__Inventory_infoBox[s__Inventory_pid[this]] , s__Inventory_TOOLTIP_X , s__Inventory_TOOLTIP_Y)
            call s__UIText_setPosition(s__Inventory_infoBoxTitle[s__Inventory_pid[this]] , s__Inventory_TOOLTIP_X - 0.15 , s__Inventory_TOOLTIP_Y + 0.1)
            call s__UIText_setPosition(s__Inventory_infoBoxCost[s__Inventory_pid[this]] , s__Inventory_TOOLTIP_X - 0.11 , s__Inventory_TOOLTIP_Y + 0.022)
            call s__UIPicture_setPosition(s__Inventory_costIcon[s__Inventory_pid[this]] , s__Inventory_TOOLTIP_X - 0.15 , s__Inventory_TOOLTIP_Y + 0.1)

            call s__UIPicture_show(s__Inventory_infoBox[s__Inventory_pid[this]] , flag , s__Inventory_camera[this])
            //call .infoIcon[this.pid].show(flag, this.camera)
            call s__UIText_show(s__Inventory_infoBoxTitle[s__Inventory_pid[this]] , flag , s__Inventory_camera[this])
            call s__Inventory_showLines(this , s__Inventory_pid[this] , flag , s__Inventory_camera[this])
            call s__UIText_show(s__Inventory_infoBoxCost[s__Inventory_pid[this]] , flag , s__Inventory_camera[this])
            call s__UIPicture_show(s__Inventory_costIcon[s__Inventory_pid[this]] , flag , s__Inventory_camera[this])
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
            set s__Inventory_user[this]=( s__Inventory_pid[this] )
            set s__Inventory_countTable[this]=s__Table__allocate()
            
            set raceId=GetHandleId(GetPlayerRace(s__User_handle[( s__Inventory_pid[this] )])) - 1
            
            set showLocally=( s__User_Local == s__User_handle[( s__Inventory_pid[this] )] )
            
            call s__Inventory_createButtons(this)
            

                call s__Inventory_createTooltip(this , raceId)

            
            if ( s__Inventory_pageNum[s__Inventory_pid[this]] == 0 ) then
                set s__Inventory_pageNum[s__Inventory_pid[this]]=s__UIText_createEx(( s__User_handle[( s__Inventory_user[this] )] ) , s__Inventory_X + 0.300 , s__Inventory_Y + .10 , 1) // INLINED!!
            endif
            
            call SaveInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(( s__Inventory_owner[this] )), ( this )) // INLINED!!
            
            if ( s__Inventory_background[s__Inventory_pid[this]] == 0 ) then
                set s__Inventory_background[s__Inventory_pid[this]]=s__UIPicture_createEx(s__Inventory_X , s__Inventory_Y , 2 , s__Inventory_SCALE , s__Inventory_BACKGROUND , 70. , 60 , s__Inventory_localInt(s__Inventory_pid[this] , s__Inventory_RACE_BORDERS_START + raceId , s__Inventory_ICON_TRANSPARENT))
            endif

            set s__Inventory_prev[s__Inventory_next[( 0 )]]=this
            set s__Inventory_next[this]=s__Inventory_next[( 0 )]
            set s__Inventory_next[( 0 )]=this

            set s__Inventory_prev[this]=0

            return this
        endfunction
        
        function s__Inventory_addItem takes integer this,integer itm returns boolean
            local integer slot
            
            if ( itm <= 0 or s__InvItem_id[itm] <= 0 ) then
                return false
            endif
            
            set slot=s__Inventory_findFreeSlot(this , s__Inventory_currentPage[this])
            
            if ( slot == - 1 ) then
                call SimError(( s__User_handle[( s__Inventory_pid[this] )] ) , ( "There are no free slots on this inventory page." )) // INLINED!!
                return false
            endif
            
            if ( s__InvItem_icon[itm] == s__Inventory_ICON_EMPTY ) then
                return false
            endif
            
            call s__Inventory_setItem(this , ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[this] ) + slot , itm)
            
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
            
            local integer user= ( s__User_LocalId )
            
            set inv=s__Inventory_PlayerCurrent[s__User_id[user]]
            
            if ( inv == 0 or not s__Inventory_displayed[inv] ) then
                return
            endif
            
            set x=GetUnitX(s__Inventory_owner[inv])
            set y=GetUnitY(s__Inventory_owner[inv])
            set z=GetTerrainZ(x , y) + GetUnitDefaultFlyHeight(s__Inventory_owner[inv])
            
            call s__Camera_setPosition(s__Inventory_camera[inv] , x , y , z)
            
            if s__Camera_applyCameraForPlayer(s__Inventory_camera[inv] , s__User_handle[user] , false) then
                call s__Interface_updateAll(true , true , true)
            endif

        endfunction
        
        function s__Inventory_show takes integer this,boolean flag,integer cam returns nothing
            local integer i
            local integer equip
            local real timeout
            
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
                    call s__Inventory_show(s__Inventory_PlayerCurrent[s__Inventory_pid[this]] , false , cam)
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
            
            call s__UIButton_show(s__Inventory_btnPageUp[s__Inventory_pid[this]] , flag , cam)
            call s__UIButton_show(s__Inventory_btnSell[s__Inventory_pid[this]] , flag , cam)
            call s__UIButton_show(s__Inventory_btnDrop[s__Inventory_pid[this]] , flag , cam)
            //call this.selector[this.pid].show(flag, cam)
            call s__UIButton_show(s__Inventory_btnPageDown[s__Inventory_pid[this]] , flag , cam)
            call s__UIPicture_show(s__Inventory_background[s__Inventory_pid[this]] , flag , cam)


                if ( not flag ) then
                    call s__Inventory_showTooltip(this , flag)
                endif

            
            call SetTextTagText(s__UIText_text[s__Inventory_pageNum[s__Inventory_pid[this]]], I2S(s__Inventory_currentPage[this] + 1) + "/" + I2S(s__Inventory_MAX_PAGES), 10 * 0.0023)
            
            call s__UIText_show(s__Inventory_pageNum[s__Inventory_pid[this]] , flag , cam)
            
            set i=0
            
            loop
                exitwhen i == s__Inventory_MAX_SLOTS
                
                call s__UIButton_setTexture(( s__Inventory_buttons[( s__Inventory_pid[( this )] * s__Inventory_MAX_SLOTS ) + ( i )] ) , s__Inventory_localInt(s__Inventory_pid[this] , GetItemIcon(s__InvItem_id[( LoadInteger(s__Inventory_Hashtable, ( this ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[this] ) + i )) )]) , s__Inventory_ICON_TRANSPARENT)) // INLINED!!

                call s__UIButton_showPlayer(( s__Inventory_buttons[( s__Inventory_pid[( this )] * s__Inventory_MAX_SLOTS ) + ( i )] ) , s__User_handle[s__Inventory_user[this]] , flag , s__Inventory_camera[this]) // INLINED!!
                
                call s__UIButton_showPlayer(( s__Inventory_buttons[( s__Inventory_pid[( this )] * s__Inventory_MAX_SLOTS ) + ( i )] ) , s__User_handle[s__Inventory_user[this]] , flag , s__Inventory_camera[this]) // INLINED!!
                
                
                set i=i + 1
            endloop

        endfunction
        
        
    
    function InventoryCore_GracePeriod takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer but= ( ( LoadInteger(TimerUtils___ht, 0, GetHandleId(( t ))) ) )
        
        set InvButtonDisabled[but]=false
        
        call ReleaseTimer(t)
    endfunction
    
    function DisableButtonIfUsingTimer takes integer but,real time returns nothing




    endfunction
    
    function InventoryCore___LClickItemSlot takes nothing returns boolean
        local integer but= ( UserInterface___ClickedButton )
        local player p= ( UserInterface___ClickingPlayer )
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        local integer slot=  s__UIButton_customValue[but]
        local integer itemId= 0
        local integer icon= 0
        local integer last= InvPlayerLastSlot[s__Inventory_pid[inv]] - 1
        local integer lastItemId
        local integer lastItem
        local integer lastButton= InvPlayerLastButton[s__Inventory_pid[inv]]
        call ILM_Log("inventory", "LEFT_ENTRY", "pid=" + I2S(pid) + " inv=" + I2S(inv) + " slot=" + I2S(slot) + " button=" + I2S(but))

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
            
           if ( p != s__User_handle[( s__Inventory_pid[inv] )] ) then
                return false
            endif
            
            // run onSell event
            set InvEventPlayer=s__User_handle[( s__Inventory_pid[inv] )]
            set InvEventItem=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last )) ) // INLINED!!
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
            
           if ( p != s__User_handle[( s__Inventory_pid[inv] )] ) then
                return false
            endif
            
            // run onSell event
            set InvEventPlayer=s__User_handle[( s__Inventory_pid[inv] )]
            set InvEventItem=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last )) ) // INLINED!!
            set InvEventSlot=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
            
            if ( s__Inventory_onDrop != null and TriggerEvaluate(s__Inventory_onDrop) ) then
                call TriggerExecute(s__Inventory_onDrop)
                return false
            endif
            
            call DisableButtonIfUsingTimer(but , 2)
        elseif ( but == s__Inventory_btnPageDown[s__Inventory_pid[inv]] ) then
           if ( p != s__User_handle[( s__Inventory_pid[inv] )] ) then
                return false
            endif
        
            call ILM_Log("page", "REQUEST", "inv=" + I2S(inv) + " direction=1 before=" + I2S(s__Inventory_currentPage[inv]))
            set s__Inventory_currentPage[inv]=s__Inventory_currentPage[inv] + 1
            call s__Inventory_show(inv , true , s__Inventory_camera[inv])
            call ILM_Log("page", "SHOWN", "inv=" + I2S(inv) + " normalized=" + I2S(s__Inventory_currentPage[inv]))
            call DisableButtonIfUsingTimer(but , .6)
            return false
        elseif ( but == s__Inventory_btnPageUp[s__Inventory_pid[inv]] ) then
           if ( p != s__User_handle[( s__Inventory_pid[inv] )] ) then
                return false
            endif
            
            call ILM_Log("page", "REQUEST", "inv=" + I2S(inv) + " direction=-1 before=" + I2S(s__Inventory_currentPage[inv]))
            set s__Inventory_currentPage[inv]=s__Inventory_currentPage[inv] - 1
            call s__Inventory_show(inv , true , s__Inventory_camera[inv])
            call ILM_Log("page", "SHOWN", "inv=" + I2S(inv) + " normalized=" + I2S(s__Inventory_currentPage[inv]))
            call DisableButtonIfUsingTimer(but , .6)
            return false
        else
            call s__UIPicture_show(s__Inventory_selector[s__Inventory_pid[inv]] , true , s__Inventory_camera[inv])
            call s__UIPicture_setPosition(s__Inventory_selector[pid] , s__UIButton_centerx[but] - 0.004 , s__UIButton_centery[but] + 0.0262)
            call s__UIPicture_showPlayer(s__Inventory_selector[pid] , Player(pid) , true , s__Inventory_camera[inv])
        endif

        if ( p != s__User_handle[( s__Inventory_pid[inv] )] ) then
            return false
        endif
        
        if ( last + 1 != slot ) then
            call s__Inventory_showLines(inv , s__Inventory_pid[inv] , false , s__Inventory_camera[inv])
        endif
        
        call TriggerExecute(s__Inventory_ExecL)
        
        // get item in slot
        set itemId=s__InvItem_id[( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot )) )] // INLINED!!
        
         // check for switch
        if ( last + 1 != 0 ) then

            call SetUnitVertexColor(s__UIButton_picture[lastButton], 255, 255, 255, 255)
            call SetUnitVertexColor(s__UIButton_picture[but], 255, 255, 255, 255)
            
            set InvPlayerLastSlot[s__Inventory_pid[inv]]=0
            set InvPlayerLastButton[s__Inventory_pid[inv]]=but
                
            if ( itemId == 0 ) then
                set last=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
                
                set lastItem=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( last )) ) // INLINED!!
            
                set lastItemId=s__InvItem_id[lastItem]
                
                set s__InvItem_tempCustomId[lastItem]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( last )) ) // INLINED!!
            
                call s__Inventory_setItem(inv , ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot , lastItem)
                call s__Inventory_setItem(inv , last , 0)
                
                call DisableButtonIfUsingTimer(but , 2)
            elseif ( s__InvItem_isSocket[( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last )) )] ) then // INLINED!!
                
                set last=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
                
                set lastItem=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( last )) ) // INLINED!!
                set s__InvItem_tempCustomId[lastItem]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( last )) ) // INLINED!!
                set slot=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot
                
                if ( s__Equipment_onSocket != null ) then
                    if ( ( LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[( lastItem )], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100) ) <= s__InvItem_maxSockets[lastItem] ) then // INLINED!!
                        set SocketInv=inv
                        set SocketLast=last
                        set SocketSlot=slot
                        
                        if ( not s__InvItem_isSocket[( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) )] and s__Equipment_onSocket != null and TriggerEvaluate(s__Equipment_onSocket) ) then // INLINED!!
                            call TriggerExecute(s__Equipment_onSocket)
                            return false
                        endif
                    endif
                else
                    set s__InvItem_tempCustomId[( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) )]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( slot )) ) // INLINED!!
                    
                    if ( s__InvItem_addSocket(( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) ) , lastItem) ) then // INLINED!!
                        call s__Inventory_setItem(inv , last , 0)
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
            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[( inv )]]], ( GetObjectName(itemId) ), 10 * 0.0023) // INLINED!!
            

                set s__InvItem_tempCustomId[( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( ( itemId ) )) )]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot )) ) // INLINED!!

                call s__InvItem_buildDescription(( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( ( itemId ) )) ) , s__Inventory_owner[inv]) // INLINED!!



            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxCost[s__Inventory_pid[( inv )]]], ( "|cffffcc00" + I2S(s__InvItem_cost[( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( ( itemId ) )) )]) + "|r" ), 8 * 0.0023) // INLINED!!
            
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[( inv )]] , ( s__Inventory_localInt(s__Inventory_pid[inv] , GetItemIcon(itemId) , s__Inventory_ICON_TRANSPARENT) )) // INLINED!!
        endif
        
        set s__Inventory_TOOLTIP_X=s__UIButton_minx[but] - 0.4
        set s__Inventory_TOOLTIP_Y=s__UIButton_maxy[but] + 0.4
        
        call s__Inventory_showTooltip(inv , itemId > 0)
        
        return false
    endfunction

    function InventoryCore___RClickItemSlot takes nothing returns boolean
        local integer but= ( UserInterface___ClickedButton )
        local player p= ( UserInterface___ClickingPlayer )
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        
        local integer slot=  s__UIButton_customValue[but]
        local integer itemId
        call ILM_Log("inventory", "RIGHT_ENTRY", "pid=" + I2S(pid) + " inv=" + I2S(inv) + " slot=" + I2S(slot))
 
        if ( p != s__User_handle[( s__Inventory_pid[inv] )] ) then
            return false
        endif
        
        call TriggerExecute(s__Inventory_ExecR)
        
        set slot=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot

        set itemId=s__InvItem_id[( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) )] // INLINED!!

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
    

//library InventoryCore ends
//library MovementBonus:
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

function MovementBonus___ErrorMsg takes string func,string s returns nothing
    call BJDebugMsg("|cffFF0000MovementBonus Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

    
    
    
    
    function s__MovementBonus___BonusValue_create takes unit u returns integer
        local integer this= s__MovementBonus___BonusValue__allocate()
        
        set s__MovementBonus___BonusValue_owner[this]=u
        
        set s__MovementBonus___BonusValue_owners[( GetUnitUserData(( u )) )]=this // INLINED!!
        
        set s__MovementBonus___BonusValue_all[s__MovementBonus___BonusValue_count]=this
        set s__MovementBonus___BonusValue_index[this]=s__MovementBonus___BonusValue_count
        set s__MovementBonus___BonusValue_count=s__MovementBonus___BonusValue_count + 1
        
        return this
    endfunction
    
    function s__MovementBonus___BonusValue_onDestroy takes integer this returns nothing
        set s__MovementBonus___BonusValue_owners[( GetUnitUserData(( s__MovementBonus___BonusValue_owner[this] )) )]=( 0 ) // INLINED!!
        
        set s__MovementBonus___BonusValue_all[s__MovementBonus___BonusValue_index[this]]=s__MovementBonus___BonusValue_all[s__MovementBonus___BonusValue_count]
        set s__MovementBonus___BonusValue_count=s__MovementBonus___BonusValue_count - 1
        
        set s__MovementBonus___BonusValue_owner[this]=null
    endfunction

//Generated destructor of MovementBonus___BonusValue
function s__MovementBonus___BonusValue_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__MovementBonus___BonusValue_V[this] != - 1 ) then
        return
    endif
    call s__MovementBonus___BonusValue_onDestroy(this)
    set si__MovementBonus___BonusValue_V[this]=si__MovementBonus___BonusValue_F
    set si__MovementBonus___BonusValue_F=this
endfunction
    
    function s__MovementBonus___BonusValue_getInstance takes unit u returns integer
        if s__MovementBonus___BonusValue_owners[( GetUnitUserData(( u )) )] == 0 then // INLINED!!
            return s__MovementBonus___BonusValue_create(u)
        else
            return s__MovementBonus___BonusValue_owners[( GetUnitUserData(( u )) )] // INLINED!!
        endif
    endfunction
    
    function s__MovementBonus___BonusValue__staticgetindex takes unit u returns integer
        return s__MovementBonus___BonusValue_owners[( GetUnitUserData(( u )) )] // INLINED!!
    endfunction
    
    function s__MovementBonus___BonusValue__staticsetindex takes unit u,integer i returns nothing
        set s__MovementBonus___BonusValue_owners[( GetUnitUserData(( u )) )]=i // INLINED!!
    endfunction

    
    function s__MovementBonus___MovementBonus_create takes integer min,integer max returns integer
        local integer this= s__MovementBonus___MovementBonus__allocate()
        
        set s__BonusMod___BonusInterface_minBonus[this]=min
        set s__BonusMod___BonusInterface_maxBonus[this]=max
        
        return this
    endfunction
    
    function s__MovementBonus___MovementBonus_setBonus takes integer this,unit u,integer amount returns integer
        local integer value
        local integer min
        local integer max
        
        local integer actualSpeed
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set value=s__MovementBonus___BonusValue_getInstance(u)
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min=MIN_BUILDING_MOVEMENT
            set max=MAX_BUILDING_MOVEMENT
        else
            set min=MIN_UNIT_MOVEMENT
            set max=MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed=R2I(GetUnitMoveSpeed(u)) - s__MovementBonus___BonusValue_speed[value]
        
        if actualSpeed + amount < min then
            set amount=- actualSpeed + min
        elseif actualSpeed + amount > max then
            set amount=max - actualSpeed
        endif
        
        call SetUnitMoveSpeed(u, actualSpeed + amount)
        set s__MovementBonus___BonusValue_speed[value]=amount
        
        return amount
    endfunction
    
    function s__MovementBonus___MovementBonus_getBonus takes integer this,unit u returns integer
        local integer value
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set value=( s__MovementBonus___BonusValue_owners[( GetUnitUserData(( ( u ) )) )] ) // INLINED!!
        
        if value == 0 then
            return 0
        endif
        
        return s__MovementBonus___BonusValue_speed[value]
    endfunction
    
    function s__MovementBonus___MovementBonus_removeBonus takes integer this,unit u returns nothing
        call s__MovementBonus___MovementBonus_setBonus(this , u , 0)
    endfunction
    
    function s__MovementBonus___MovementBonus_isValidBonus takes integer this,unit u,integer value returns boolean
        local integer min
        local integer max
        
        local integer currentBonus
        local integer actualSpeed
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return false
        endif
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min=MIN_BUILDING_MOVEMENT
            set max=MAX_BUILDING_MOVEMENT
        else
            set min=MIN_UNIT_MOVEMENT
            set max=MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed=R2I(GetUnitMoveSpeed(u)) - s__MovementBonus___MovementBonus_getBonus(this , u)
        
        if actualSpeed + value < min then
            return false
        elseif actualSpeed + value > max then
            return false
        else
            return true
        endif
    endfunction

function MovementBonus___OnLeaveMap takes unit u returns nothing
    if ( s__MovementBonus___BonusValue_owners[( GetUnitUserData(( ( u ) )) )] ) != 0 then // INLINED!!
        call s__MovementBonus___BonusValue_deallocate(( s__MovementBonus___BonusValue_owners[( GetUnitUserData(( ( u ) )) )] )) // INLINED!!
    endif
endfunction

function MovementBonus___OnInit takes nothing returns nothing
    local integer min
    local integer max
    
    call s__AutoIndex_onUnitDeindexed(( ( 1 ) )) // INLINED!!
    
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
    
    set BONUS_MOVEMENT_SPEED=s__MovementBonus___MovementBonus_create(min , max)
endfunction

//library MovementBonus ends
//library RegenBonuses:
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


function RegenBonuses___ErrorMsg takes string func,string s returns nothing
    call BJDebugMsg("|cffFF0000RegenBonuses Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction



function RegenBonuses___DoRegen takes nothing returns nothing
    local integer i
    local integer values
    
    // Loop over all active bonuses
    set i=0
    loop
        exitwhen i == s__RegenBonuses___BonusValues_count
        
        set values=s__RegenBonuses___BonusValues_all[i]
        
        if GetWidgetLife(s__RegenBonuses___BonusValues_owner[values]) > 0.0 then
            if s__RegenBonuses___BonusValues_manaRegen[values] > 0 then
                // Do mana regen:
                call SetUnitState(s__RegenBonuses___BonusValues_owner[values], UNIT_STATE_MANA, GetUnitState(s__RegenBonuses___BonusValues_owner[values], UNIT_STATE_MANA) + ( s__RegenBonuses___BonusValues_manaRegen[values] * RegenBonuses___REGEN_PERIOD ))
            endif
            
            if s__RegenBonuses___BonusValues_lifeRegen[values] > 0 then
                // Do life regen:
                call SetUnitState(s__RegenBonuses___BonusValues_owner[values], UNIT_STATE_LIFE, GetUnitState(s__RegenBonuses___BonusValues_owner[values], UNIT_STATE_LIFE) + ( GetUnitState(s__RegenBonuses___BonusValues_owner[values], UNIT_STATE_MAX_LIFE) * ( s__RegenBonuses___BonusValues_lifeRegen[values] / 100.0 ) ) * RegenBonuses___REGEN_PERIOD)
            endif
        endif
        
        set i=i + 1
    endloop
endfunction

    
    
    
    
    function s__RegenBonuses___BonusValues_create takes unit u returns integer
        local integer this= s__RegenBonuses___BonusValues__allocate()
        
        set s__RegenBonuses___BonusValues_owner[this]=u
        
        set s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( u )) )]=this // INLINED!!
        
        if s__RegenBonuses___BonusValues_count == 0 then
            call TimerStart(RegenBonuses___regenTimer, RegenBonuses___REGEN_PERIOD, true, function RegenBonuses___DoRegen)
        endif
        
        set s__RegenBonuses___BonusValues_all[s__RegenBonuses___BonusValues_count]=this
        set s__RegenBonuses___BonusValues_index[this]=s__RegenBonuses___BonusValues_count
        set s__RegenBonuses___BonusValues_count=s__RegenBonuses___BonusValues_count + 1
        
        return this
    endfunction
    
    function s__RegenBonuses___BonusValues_onDestroy takes integer this returns nothing
        set s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( s__RegenBonuses___BonusValues_owner[this] )) )]=( 0 ) // INLINED!!
        
        set s__RegenBonuses___BonusValues_all[s__RegenBonuses___BonusValues_index[this]]=s__RegenBonuses___BonusValues_all[s__RegenBonuses___BonusValues_count]
        set s__RegenBonuses___BonusValues_count=s__RegenBonuses___BonusValues_count - 1
        
        if s__RegenBonuses___BonusValues_count == 0 then
            call PauseTimer(RegenBonuses___regenTimer)
        endif
        
        set s__RegenBonuses___BonusValues_owner[this]=null
    endfunction

//Generated destructor of RegenBonuses___BonusValues
function s__RegenBonuses___BonusValues_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__RegenBonuses___BonusValues_V[this] != - 1 ) then
        return
    endif
    call s__RegenBonuses___BonusValues_onDestroy(this)
    set si__RegenBonuses___BonusValues_V[this]=si__RegenBonuses___BonusValues_F
    set si__RegenBonuses___BonusValues_F=this
endfunction
    
    function s__RegenBonuses___BonusValues_getInstance takes unit u returns integer
        if s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( u )) )] == 0 then // INLINED!!
            return s__RegenBonuses___BonusValues_create(u)
        else
            return s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( u )) )] // INLINED!!
        endif
    endfunction
    
    function s__RegenBonuses___BonusValues__staticgetindex takes unit u returns integer
        return s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( u )) )] // INLINED!!
    endfunction
    
    function s__RegenBonuses___BonusValues__staticsetindex takes unit u,integer i returns nothing
        set s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( u )) )]=i // INLINED!!
    endfunction


//textmacro instance: RegenBonuses_RegenBonusDefine("life")
    
    function s__RegenBonuses___RegenBonus_life_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set values=s__RegenBonuses___BonusValues_getInstance(u)
        set s__RegenBonuses___BonusValues_lifeRegen[values]=amount
        
        return amount
    endfunction
    
    function s__RegenBonuses___RegenBonus_life_getBonus takes integer this,unit u returns integer
        local integer values
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set values=( s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] ) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        return s__RegenBonuses___BonusValues_lifeRegen[values]
    endfunction
    
    function s__RegenBonuses___RegenBonus_life_removeBonus takes integer this,unit u returns nothing
        call s__RegenBonuses___RegenBonus_life_setBonus(this , u , 0)
    endfunction
    
    function s__RegenBonuses___RegenBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
        return ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) // INLINED!!
    endfunction
//end of: RegenBonuses_RegenBonusDefine("life")
//textmacro instance: RegenBonuses_RegenBonusDefine("mana")
    
    function s__RegenBonuses___RegenBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set values=s__RegenBonuses___BonusValues_getInstance(u)
        set s__RegenBonuses___BonusValues_manaRegen[values]=amount
        
        return amount
    endfunction
    
    function s__RegenBonuses___RegenBonus_mana_getBonus takes integer this,unit u returns integer
        local integer values
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set values=( s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] ) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        return s__RegenBonuses___BonusValues_manaRegen[values]
    endfunction
    
    function s__RegenBonuses___RegenBonus_mana_removeBonus takes integer this,unit u returns nothing
        call s__RegenBonuses___RegenBonus_mana_setBonus(this , u , 0)
    endfunction
    
    function s__RegenBonuses___RegenBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
        return ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) // INLINED!!
    endfunction
//end of: RegenBonuses_RegenBonusDefine("mana")

function RegenBonuses___OnLeaveMap takes unit u returns nothing
    if ( s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] ) != 0 then // INLINED!!
        call s__RegenBonuses___BonusValues_deallocate(( s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] )) // INLINED!!
    endif
endfunction

function RegenBonuses___OnInit takes nothing returns nothing
    call s__AutoIndex_onUnitDeindexed(( ( 2 ) )) // INLINED!!
    
    set BONUS_MANA_REGEN=s__RegenBonuses___RegenBonus_mana__allocate()
    set BONUS_LIFE_REGEN_PERCENT=s__RegenBonuses___RegenBonus_life__allocate()
endfunction

//library RegenBonuses ends
//library UnitMaxStateBonuses:
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
        
        set s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( u )) )]=this // INLINED!!
        
        return this
    endfunction
    
    function s__UnitMaxStateBonuses___BonusValues_onDestroy takes integer this returns nothing
        set s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( s__UnitMaxStateBonuses___BonusValues_owner[this] )) )]=( 0 ) // INLINED!!
        set s__UnitMaxStateBonuses___BonusValues_owner[this]=null
    endfunction

//Generated destructor of UnitMaxStateBonuses___BonusValues
function s__UnitMaxStateBonuses___BonusValues_deallocate takes integer this returns nothing
    if this == null then
        return
    elseif ( si__UnitMaxStateBonuses___BonusValues_V[this] != - 1 ) then
        return
    endif
    call s__UnitMaxStateBonuses___BonusValues_onDestroy(this)
    set si__UnitMaxStateBonuses___BonusValues_V[this]=si__UnitMaxStateBonuses___BonusValues_F
    set si__UnitMaxStateBonuses___BonusValues_F=this
endfunction
    
    function s__UnitMaxStateBonuses___BonusValues_getInstance takes unit u returns integer
        if s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( u )) )] == 0 then // INLINED!!
            return s__UnitMaxStateBonuses___BonusValues_create(u)
        else
            return s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( u )) )] // INLINED!!
        endif
    endfunction
    
    function s__UnitMaxStateBonuses___BonusValues__staticgetindex takes unit u returns integer
        return s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( u )) )] // INLINED!!
    endfunction
    
    function s__UnitMaxStateBonuses___BonusValues__staticsetindex takes unit u,integer i returns nothing
        set s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( u )) )]=i // INLINED!!
    endfunction


//textmacro instance: UnitMaxStateBonus_DefineBonus("life", "LIFE", "1")
    
    function s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        local integer actual
        local integer new
        local real factor
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
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
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set values=( s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] ) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        set s__UnitMaxStateBonuses___BonusValues_life[values]=R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)) - ( R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)) - s__UnitMaxStateBonuses___BonusValues_life[values] )
        
        return s__UnitMaxStateBonuses___BonusValues_life[values]
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus takes integer this,unit u returns nothing
        call s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus(this , u , 0)
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus takes integer this,unit u,integer value returns boolean
        local integer currentBonus
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return false
        endif
        
        set currentBonus=s__UnitMaxStateBonuses___MaxStateBonus_life_getBonus(this , u)
        
        return R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)) - currentBonus + value >= 1
    endfunction
//end of: UnitMaxStateBonus_DefineBonus("life", "LIFE", "1")
//textmacro instance: UnitMaxStateBonus_DefineBonus("mana", "MANA", "1")
    
    function s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus takes integer this,unit u,integer amount returns integer
        local integer values
        local integer actual
        local integer new
        local real factor
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
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
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return 0
        endif
        
        set values=( s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] ) // INLINED!!
        
        if values == 0 then
            return 0
        endif
        
        set s__UnitMaxStateBonuses___BonusValues_mana[values]=R2I(GetUnitState(u, UNIT_STATE_MAX_MANA)) - ( R2I(GetUnitState(u, UNIT_STATE_MAX_MANA)) - s__UnitMaxStateBonuses___BonusValues_mana[values] )
        
        return s__UnitMaxStateBonuses___BonusValues_mana[values]
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus takes integer this,unit u returns nothing
        call s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus(this , u , 0)
    endfunction
    
    function s__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus takes integer this,unit u,integer value returns boolean
        local integer currentBonus
        
        if not ( ( s__UnitDex_Unit[( ( GetUnitUserData(( ( u ) )) ) )] ) != null ) then // INLINED!!
            return false
        endif
        
        set currentBonus=s__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus(this , u)
        
        return R2I(GetUnitState(u, UNIT_STATE_MAX_MANA)) - currentBonus + value >= 1
    endfunction
//end of: UnitMaxStateBonus_DefineBonus("mana", "MANA", "1")

function UnitMaxStateBonuses___OnLeaveMap takes unit u returns nothing
    if ( s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] ) != 0 then // INLINED!!
        call s__UnitMaxStateBonuses___BonusValues_deallocate(( s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( ( u ) )) )] )) // INLINED!!
    endif
endfunction


//Implemented from module UnitMaxStateBonuses___StateInit:
function s__UnitMaxStateBonuses___Data_UnitMaxStateBonuses___StateInit__onInit takes nothing returns nothing
    set BONUS_LIFE=s__UnitMaxStateBonuses___MaxStateBonus_life__allocate()
    set BONUS_MANA=s__UnitMaxStateBonuses___MaxStateBonus_mana__allocate()
    
    call s__AutoIndex_onUnitDeindexed(( ( 3 ) )) // INLINED!!
endfunction




//library UnitMaxStateBonuses ends
//library YesNoDialog:

    
    function YesNoDialog___OnClick takes nothing returns nothing
        local integer user= s__User_first
        local button btn= GetClickedButton()
        call ILM_Log("dialog", "CLICK", "pid=" + I2S(GetPlayerId(GetTriggerPlayer())) + " dialog=" + I2S(GetHandleId(GetClickedDialog())) + " button=" + I2S(GetHandleId(btn)) + " yes=" + ILM_Bool(btn == YesNoDialog___YesBtn[GetPlayerId(GetTriggerPlayer())]))

        loop
            exitwhen user == s__User_NULL
            
            if ( YesNoDialog___YesCallback[s__User_id[user]] != null and YesNoDialog___YesBtn[s__User_id[user]] == btn ) then
                set YesNoPlayer=( s__User_handle[( user )] ) // INLINED!!
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
        call DialogDisplay(( s__User_handle[( user )] ), Dialog[s__User_id[user]], true) // INLINED!!
    endfunction
    

//library YesNoDialog ends
//library EquipmentItem:
    

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
            call s__InvItem_addBonus(itm , BONUS_DAMAGE , dmg)
        endif
        
        if ( def != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_ARMOR , def)
        endif
        
        if ( str != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_STRENGTH , str)
        endif
        
        if ( agi != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_AGILITY , agi)
        endif
        
        if ( it != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_INTELLIGENCE , it)
        endif

        if ( as != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_ATTACK_SPEED , as)
        endif
        
        if ( sight != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_SIGHT_RANGE , sight)
        endif
        
        if ( lreg != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_LIFE_REGEN , lreg)
        endif
        
        if ( mreg != 0 ) then
            call s__InvItem_addBonus(itm , BONUS_MANA_REGEN_PERCENT , lreg)
        endif
        
        return itm
    endfunction

    

//library EquipmentItem ends
//library EquipItemParser:
    
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
            call s__InvItem_addBonusRange(itm , BONUS_DAMAGE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "def" ) then
            call s__InvItem_addBonusRange(itm , BONUS_ARMOR , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "str" ) then
            call s__InvItem_addBonusRange(itm , BONUS_STRENGTH , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "agi" ) then
            call s__InvItem_addBonusRange(itm , BONUS_AGILITY , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "int" ) then
            call s__InvItem_addBonusRange(itm , BONUS_INTELLIGENCE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "ias" ) then
            call s__InvItem_addBonusRange(itm , BONUS_ATTACK_SPEED , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "hp" or param == "life" ) then
            call s__InvItem_addBonusRange(itm , BONUS_LIFE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "mp" or param == "mana" ) then
            call s__InvItem_addBonusRange(itm , BONUS_MANA , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "manareg" ) then
            call s__InvItem_addBonusRange(itm , BONUS_MANA_REGEN , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "sight" ) then
            call s__InvItem_addBonusRange(itm , BONUS_SIGHT_RANGE , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "ms" or param == "move" ) then
            call s__InvItem_addBonusRange(itm , BONUS_MOVEMENT_SPEED , S2I(value) , S2I(min) , S2I(max))
        elseif ( param == "lifereg" ) then
            call s__InvItem_addBonusRange(itm , BONUS_LIFE_REGEN , S2I(value) , S2I(min) , S2I(max))
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
    
    function EquipItemParser___ParseParam takes integer itm,string param,string value returns nothing
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
        call SaveInteger(Table___ht, ( ( s__InvItem_Table ) ), ( s__InvItem_id[itm] ), ( itm )) // INLINED!!

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
                    call EquipItemParser___ParseParam(itm , StringCase(param, false) , value[0])
                    
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
    

//library EquipItemParser ends
//library EquipmentCore:
    
    
     function EquipmentCore_HERO_WINDOW_NAME takes unit u returns string
        return s__User__get_nameColored(( GetPlayerId(( GetOwningPlayer(u) )) )) // INLINED!!
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
            set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + index]=value
        endfunction
        
        function s__Equipment_create takes unit u returns integer
            local integer this= s__Equipment__allocate()
            local real x1= s__Equipment_X + s__Equipment_SLOT_OFFSET_ROWLEFT_X
            local real x2= s__Equipment_X + s__Equipment_SLOT_OFFSET_ROWRIGHT_X
            local real y1= s__Equipment_Y - s__Equipment_SLOT_OFFSET_Y
            local integer i= 0

            set s__Equipment_unit[this]=u
            set s__Equipment_player[this]=GetOwningPlayer(u)
            set s__Equipment_user[this]=( GetPlayerId(( s__Equipment_player[this] )) ) // INLINED!!
            
            set s__Equipment_UnitsIndex[GetUnitUserData(u)]=this

            //
            // GEAR SLOTS
            //
            
            if ( ( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 0 )] ) == 0 ) then // INLINED!!
            
                set s__Equipment_selector[s__User_id[s__Equipment_user[this]]]=s__UIPicture_createEx(s__Equipment_X - 0.15 , ( s__Equipment_Y + s__Equipment_SLOT_OFFSET_Y ) - .250 , 0 , .70 , 'e000' , 1 , 1 , 0)
                set s__UIPicture_animIndex[s__Equipment_selector[s__User_id[s__Equipment_user[this]]]]=56
                call s__UIPicture_show(s__Equipment_selector[s__User_id[s__Equipment_user[this]]] , false , s__Equipment_camera[this])

                call AddSpecialEffectTarget("UI\\TRSHerolevel.mdx", s__UIPicture_picture[s__Equipment_selector[s__User_id[s__Equipment_user[this]]]], "origin")
                
                // middle
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 12 )]=( s__UIButton_create(x1 + ( s__Equipment_SLOT_WIDTH * 1.5 ) , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B005') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 13 )]=( s__UIButton_create(x2 - ( s__Equipment_SLOT_WIDTH * 1.5 ) , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00B') ) // INLINED!!
                
                // left side
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 0 )]=( s__UIButton_create(x1 , y1 , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B003') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 1 )]=( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 1 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B004') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 2 )]=( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 2 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B006') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 3 )]=( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 3 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B007') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 4 )]=( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 4 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B008') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 5 )]=( s__UIButton_create(x1 , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'D05W') ) // INLINED!!
                
                // right side
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 6 )]=( s__UIButton_create(x2 , y1 , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B009') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 7 )]=( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 1 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00A') ) // INLINED!!
            
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 8 )]=( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 2 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00C') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 9 )]=( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 3 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00D') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 10 )]=( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 4 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00E') ) // INLINED!!
                set s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( 11 )]=( s__UIButton_create(x2 , y1 - ( s__Equipment_SLOT_HEIGHT * 5 ) , s__Equipment_SLOT_WIDTH , s__Equipment_SLOT_HEIGHT , 10 , 'B00F') ) // INLINED!!
                            
                loop
                    exitwhen i == 14
                    set s__UIButton_customValue[( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] )]=i // INLINED!!
                    
                     set s__UIButton_selectUnit[( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] )]=s__Equipment_unit[this] // INLINED!!
                     
                    set s__UIButton_onLeftClick[( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] )]=EquipmentCore_FuncLClickSlot // INLINED!!
                    set s__UIButton_onRightClick[( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] )]=EquipmentCore_FuncRClickSlot // INLINED!!
                    
                    set s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i]=s__UIPicture_create(s__UIButton_minx[( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] )] + ( s__Equipment_SLOT_WIDTH / 6.3 ) , s__UIButton_maxy[( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] )] - 0.022 , s__Equipment_SLOT_WIDTH * .7 , s__Equipment_SLOT_HEIGHT * .7 , 9 , s__Inventory_ICON_EMPTY) // INLINED!!
                    set s__UIPicture_customValue[s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i]]=i

                    set i=i + 1
                endloop
                
                set s__s__Equipment_pictures[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + 0]=s__UIPicture_createEx(s__Equipment_X , s__Equipment_Y , 11 , s__Equipment_WINDOW_SIZE , s__Equipment_WINDOW_DUMMY , 140. , 130. , s__Inventory_localInt(s__User_id[s__Equipment_user[this]] , s__Inventory_RACE_BORDERS_START + ( GetHandleId(GetPlayerRace(s__Equipment_player[this])) - 1 ) , s__Inventory_ICON_TRANSPARENT))
                
            endif
            
            // unit model
            set i=( sc__Table__getindex(EquipHeroModels___HeroModels , ( GetUnitTypeId(s__Equipment_unit[this]) )) ) // INLINED!!
            
            set s__Equipment_charModel[this]=s__UIPicture_createEx(s__Equipment_CHARMODEL_OFFSET_X , s__Equipment_CHARMODEL_OFFSET_Y , 5 , s__HeroModelData_scale[( i )] , s__Equipment_MODEL_DUMMY , 1 , 1 , 0)
            set s__UIPicture_animIndex[s__Equipment_charModel[this]]=140
            call SetUnitColor(s__UIPicture_picture[s__Equipment_charModel[this]], ( GetPlayerColor(s__User_handle[( s__Equipment_user[this] )]) )) // INLINED!!

            call AddSpecialEffectTarget(s__HeroModelData_path[( i )], s__UIPicture_picture[s__Equipment_charModel[this]], "origin")

            set s__Equipment_title[s__User_id[s__Equipment_user[this]]]=s__UIText_createEx(( s__User_handle[( s__Equipment_user[this] )] ) , s__Equipment_X / 1.4 , 0.1 , 1) // INLINED!!

            set s__Equipment_prev[s__Equipment_next[( 0 )]]=this
            set s__Equipment_next[this]=s__Equipment_next[( 0 )]
            set s__Equipment_next[( 0 )]=this

            set s__Equipment_prev[this]=0

            return this
        endfunction

        function s__Equipment_equip takes integer this,integer itm,integer equipSlot returns boolean
            local integer slot= s__InvItem_slot[itm] - 1
            call ILM_Log("equip", "ENTRY", "gear=" + I2S(this) + " item=" + I2S(itm) + " type=" + I2S(s__InvItem_id[itm]) + " cid=" + I2S(s__InvItem_tempCustomId[itm]) + " slot=" + I2S(equipSlot))
            
            if ( slot < 0 ) then
                call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
            endif
            
            if ( s___Equipment_item[s__Equipment_item[this] + equipSlot] != 0 ) then
                call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
            endif
            
            if ( s__InvItem_slotAlt[itm] - 1 > 0 ) then
                if ( equipSlot != slot and equipSlot != s__InvItem_slotAlt[itm] - 1 ) then
                    call SimError(( s__Equipment_player[this] ) , ( "The item doesn't belong in that slot." )) // INLINED!!
                    call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
                endif
            else
                if ( equipSlot != slot ) then
                    call SimError(( s__Equipment_player[this] ) , ( "The item doesn't belong in that slot." )) // INLINED!!
                    call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
                endif
            endif
            
            if ( s__InvItem_reqUnitType[itm] > 0 and GetUnitTypeId(s__Equipment_unit[this]) != s__InvItem_reqUnitType[itm] ) then
                call SimError(( s__Equipment_player[this] ) , ( "Your unit type cannot equip this item." )) // INLINED!!
                call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
            endif
            
            if ( s__InvItem_reqAbility[itm] > 0 and GetUnitAbilityLevel(s__Equipment_unit[this], s__InvItem_reqAbility[itm]) < 0 ) then
                call SimError(( s__Equipment_player[this] ) , ( "Failed requirements." )) // INLINED!!
                call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
            endif
            
            if ( GetHeroLevel(s__Equipment_unit[this]) < s__InvItem_reqLevel[itm] and GetUnitLevel(s__Equipment_unit[this]) < s__InvItem_reqLevel[itm] ) then
                call SimError(( s__Equipment_player[this] ) , ( "Your level is too low to equip that item." )) // INLINED!!
                call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
            endif
            
            if ( s__InvItem_equipCondition[itm] != null ) then
                call TriggerClearConditions(s__InvItem_equipEval)
                call TriggerAddCondition(s__InvItem_equipEval, s__InvItem_equipCondition[itm])
                set s__InvItem_eventUnit=s__Equipment_unit[this]
                if ( not TriggerEvaluate(s__InvItem_equipEval) ) then
                    call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
                endif
            endif

            set slot=equipSlot
            
            if ( s___Equipment_item[s__Equipment_item[this] + slot] != 0 ) then
                call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=0")
                return false
            endif
            
            if ( s__InvItem_equipAbility[itm] > 0 ) then
                call UnitAddAbility(s__Equipment_unit[this], s__InvItem_equipAbility[itm])
            endif
            
            set s___Equipment_item[s__Equipment_item[this] + slot]=itm
            set s___Equipment_itemId[s__Equipment_itemId[this] + slot]=s__InvItem_tempCustomId[itm]
            
            call s__UIPicture_setTexture(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot] , s__Inventory_localInt(s__User_id[s__Equipment_user[this]] , s__InvItem_icon[itm] , s__Inventory_ICON_TRANSPARENT))
            call s__UIPicture_show(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot] , true , s__Equipment_camera[this])

            set InvEventPlayer=s__Equipment_player[this]
            set InvEventItem=itm
            set InvEventSlot=equipSlot
            
            if ( s__InvItem_onEquip != null and TriggerEvaluate(s__InvItem_onEquip) ) then
                call TriggerExecute(s__InvItem_onEquip)
            endif
                    
            // add bonuses
            call s__InvItem_addBonusesMultiplier(( itm ) , ( s__Equipment_unit[this] ) , 1) // INLINED!!
            
            set s__InvItem_tempCustomId[itm]=0
            
            call ILM_Log("equip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(equipSlot) + " value=1")
            return true
        endfunction
        
        function s__Equipment_unequip takes integer this,integer itm,integer slot returns boolean
            local integer i2
            local integer i= 0
            local integer cid= s__InvItem_tempCustomId[itm]
            call ILM_Log("unequip", "ENTRY", "gear=" + I2S(this) + " item=" + I2S(itm) + " type=" + I2S(s__InvItem_id[itm]) + " cid=" + I2S(cid) + " slot=" + I2S(slot))
            
            if ( slot != s__InvItem_slot[itm] - 1 and slot != s__InvItem_slotAlt[itm] - 1 ) then
                call ILM_Log("unequip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(slot) + " value=0")
                return false
            endif
            
            if ( s__InvItem_equipAbility[itm] > 0 ) then
                call UnitRemoveAbility(s__Equipment_unit[this], s__InvItem_equipAbility[itm])
            endif
            
            // run unequip event
            set InvEventPlayer=s__Equipment_player[this]
            set InvEventItem=s___Equipment_item[s__Equipment_item[this] + slot]
            set InvEventSlot=slot
                
            if ( s__InvItem_onUnequip != null and TriggerEvaluate(s__InvItem_onUnequip) ) then
                call TriggerExecute(s__InvItem_onUnequip)
            endif
            
            set s___Equipment_item[s__Equipment_item[this] + slot]=0

            call s__UIPicture_setTexture(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot] , s__Inventory_ICON_EMPTY)
            call s__UIPicture_show(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + slot] , false , s__Equipment_camera[this])
            
            // remove bonuses
            call s__InvItem_addBonusesMultiplier(( itm ) , ( s__Equipment_unit[this] ) , - 1) // INLINED!!

            call ILM_Log("unequip", "RETURN", "gear=" + I2S(this) + " item=" + I2S(itm) + " slot=" + I2S(slot) + " value=1")
            return true
        endfunction
        
        function s__Equipment_destroy takes integer this returns nothing
            set s__Equipment_prev[s__Equipment_next[this]]=s__Equipment_prev[this]
            set s__Equipment_next[s__Equipment_prev[this]]=s__Equipment_next[this]
            
            call s__UIPicture_destroy(s__Equipment_charModel[this])
            
            call s__Equipment_deallocate(this)
        endfunction

        function s__Equipment_onDisplay takes nothing returns nothing
            local integer user= ( s__User_LocalId )
            local integer equipment= ( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[s__User_id[user]] ))] )
            local real x
            local real y
            local real z
            
            if ( equipment == 0 or not s__Equipment_displayed[equipment] or s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[equipment]]] > 0 or s__User_Local != s__User_handle[user] ) then
                return
            endif
            
            set x=GetUnitX(s__Equipment_unit[equipment])
            set y=GetUnitY(s__Equipment_unit[equipment])
            set z=GetTerrainZ(x , y) + GetUnitDefaultFlyHeight(s__Equipment_unit[equipment])
            
            call s__Camera_setPosition(s__Equipment_camera[equipment] , x , y , z)
            
            if s__Camera_applyCameraForPlayer(s__Equipment_camera[equipment] , s__User_handle[user] , false) then
                call s__Interface_updateAll(true , true , true)
            endif
        endfunction
        
        function s__Equipment_show takes integer this,boolean flag,integer cam returns nothing
            local integer i= 0
            local integer equip= 0
            local integer len
            local real timeout
            
            set s__Equipment_displayed[this]=flag
            set s__Equipment_camera[this]=cam
            
            if ( flag ) then
                set s__Equipment_DisplayCount=s__Equipment_DisplayCount + 1

                if ( s__Equipment_DisplayCount >= 1 ) then
                    call PauseTimer(s__Equipment_UpdateTimer)
                    
                    call TimerStart(s__Equipment_UpdateTimer, s__Inventory_UI_REFRESH_RATE, true, function s__Equipment_onDisplay)
                endif
                
                if ( s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]] != null ) then
                    set equip=( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]] ))] ) // INLINED!!
                endif
                
                if ( s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]] != null and s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]] != s__Equipment_unit[this] and equip != this ) then
                    call s__Equipment_show(equip , false , s__Equipment_camera[this])
                endif
                
                set s__Equipment_PlayerCurrentUnit[s__User_id[s__Equipment_user[this]]]=s__Equipment_unit[this]
                
                if ( s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[this]]] > 0 and s__Inventory_owner[s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[this]]]] != s__Equipment_unit[this] ) then
                    call s__Inventory_show(s__Inventory_PlayerCurrent[s__User_id[s__Equipment_user[this]]] , false , s__Equipment_camera[this])
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
            
            call s__UIPicture_showPlayer(s__Equipment_charModel[this] , ( s__User_handle[( s__Equipment_user[this] )] ) , flag , s__Equipment_camera[this]) // INLINED!!
            //call this.selector[this.user.id].show(flag, cam)
            
            call SetUnitColor(s__UIPicture_picture[s__Equipment_charModel[this]], ( GetPlayerColor(s__User_handle[( s__Equipment_user[this] )]) )) // INLINED!!

            // todo: make one line / recode
            set len=StringLength(( GetPlayerName(s__User_handle[( s__Equipment_user[this] )]) )) // INLINED!!
            
            call s__UIText_setPosition(s__Equipment_title[s__User_id[s__Equipment_user[this]]] , s__Equipment_X + 0.10 , s__Equipment_HERO_NAME_Y)

            call SetTextTagText(s__UIText_text[s__Equipment_title[s__User_id[s__Equipment_user[this]]]], ( s__User__get_nameColored(( GetPlayerId(( GetOwningPlayer(( s__Equipment_unit[this] )) )) )) ), 8 * 0.0023) // INLINED!!
            
            call s__UIText_show(s__Equipment_title[s__User_id[s__Equipment_user[this]]] , flag , s__Equipment_camera[this])
            
            set i=0
            
            loop
                exitwhen i == s__Equipment_MAX_SLOTS
                
                if ( ( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] ) != 0 ) then // INLINED!!
                    call s__UIButton_showPlayer(( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( this )]] * s__Equipment_MAX_SLOTS ) + ( i )] ) , s__User_handle[s__Equipment_user[this]] , flag , s__Equipment_camera[this]) // INLINED!!
                endif
                
                if ( s__s__Equipment_pictures[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i] != 0 ) then
                    call s__UIPicture_showPlayer(s__s__Equipment_pictures[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i] , s__User_handle[s__Equipment_user[this]] , flag , s__Equipment_camera[this])
                endif
                
                if ( s___Equipment_item[s__Equipment_item[this] + i] > 0 ) then
                    call s__UIPicture_showPlayer(s__s__Equipment_slotButton[( s__User_id[s__Equipment_user[this]] * s__Equipment_MAX_SLOTS ) + i] , s__User_handle[s__Equipment_user[this]] , flag , s__Equipment_camera[this])
                endif
                
                set i=i + 1
            endloop
        endfunction
        
        function s__Equipment_onInit takes nothing returns nothing
            set s__Equipment_Hashtable=InitHashtable()
            set s__Equipment_UpdateTimer=CreateTimer()
            set s__Equipment_Initialized=true
        endfunction
        
    
    function EquipmentCore___OnInventoryItemClick takes nothing returns nothing
        local integer but= ( UserInterface___ClickedButton )
        local player p= ( UserInterface___ClickingPlayer )
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        local integer slot=  s__UIButton_customValue[but]
        local integer itemId= 0
        local integer last= InvPlayerLastSlot[s__Inventory_pid[inv]] - 1
        local integer lastItemId
        local integer lastButton= InvPlayerLastButton[s__Inventory_pid[inv]]
        local integer gear= ( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]] ))] )
        local integer gearSlot
        local integer itm
        
        call s__UIPicture_show(s__Equipment_selector[s__Inventory_pid[inv]] , false , s__Inventory_camera[inv])
       
        if ( gear <= 0 ) then
            return
        endif
        
        if ( EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]] > 0 ) then
            
            set gearSlot=EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]] - 1

            if ( ( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) ) == 0 ) then // INLINED!!
                set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear] + gearSlot]]=s___Equipment_itemId[s__Equipment_itemId[gear] + gearSlot]
                call s__Inventory_setItem(inv , slot , s___Equipment_item[s__Equipment_item[gear] + gearSlot])
                
                set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear] + gearSlot]]=s___Equipment_itemId[s__Equipment_itemId[gear] + gearSlot]
                call s__Equipment_unequip(gear , s___Equipment_item[s__Equipment_item[gear] + gearSlot] , gearSlot)
            endif
            
            set EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]]=0
        else
            set itm=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) ) // INLINED!!
            
            if ( itm > 0 and not s__InvItem_isSocket[itm] ) then
                set but=( s__s__Equipment_buttons[( s__User_id[s__Equipment_user[( gear )]] * s__Equipment_MAX_SLOTS ) + ( s__InvItem_slot[itm] - 1 )] ) // INLINED!!
                
                call s__UIPicture_show(s__Equipment_selector[s__Inventory_pid[inv]] , true , s__Inventory_camera[inv])
                call s__UIPicture_setPosition(s__Equipment_selector[s__Inventory_pid[inv]] , s__UIButton_centerx[but] - 0.007 , s__UIButton_centery[but] + 0.0272)
                call s__UIPicture_showPlayer(s__Equipment_selector[s__Inventory_pid[inv]] , Player(s__Inventory_pid[inv]) , true , s__Inventory_camera[inv])
            endif
        endif
    endfunction
    
    function EquipmentCore___OnInventoryItemRightClick takes nothing returns nothing
        local integer but= ( UserInterface___ClickedButton )
        local player p= ( UserInterface___ClickingPlayer )
        local integer pid= GetPlayerId(p)
        local integer inv=  s__Inventory_PlayerCurrent[pid]
        local integer slot=  s__UIButton_customValue[but]
        local integer gear= ( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]] ))] )
        local integer itm= ( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) )
        local integer gearSlot= s__InvItem_slot[itm] - 1
        local integer unequippedSlot= 0
        local integer unequipItem= 0
        local integer unequipId= 0
        
        if ( gear <= 0 or itm <= 0 ) then
            return
        endif
        
        set s__InvItem_tempCustomId[itm]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( slot )) ) // INLINED!!
        
        if ( s___Equipment_item[s__Equipment_item[gear] + gearSlot] > 0 ) then
            set unequipId=s___Equipment_itemId[s__Equipment_itemId[gear] + gearSlot]
            set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear] + gearSlot]]=unequipId
            call s__Equipment_unequip(gear , s___Equipment_item[s__Equipment_item[gear] + gearSlot] , gearSlot)
            set unequippedSlot=InvEventSlot
            set unequipItem=InvEventItem
        endif
        
        set s__InvItem_tempCustomId[itm]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( slot )) ) // INLINED!!
        
        if ( s__Equipment_equip(gear , itm , s__InvItem_slot[itm] - 1) ) then
            call s__Inventory_setItem(inv , slot , 0)
            set s__InvItem_tempCustomId[unequipItem]=unequipId
            call s__Inventory_addItem(inv , unequipItem)
        elseif ( unequipItem > 0 ) then
            call s__Equipment_equip(gear , unequipItem , unequippedSlot)
        endif
    endfunction

    function EquipmentCore___RClickItemSlot takes nothing returns boolean
        local integer but= ( UserInterface___ClickedButton )
        local unit u= s__Equipment_PlayerCurrentUnit[GetPlayerId(( UserInterface___ClickingPlayer ))]
        local integer gear= ( s__Equipment_UnitsIndex[GetUnitUserData(( u ))] )
        local integer inv= ( LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(( u ))) )
        local integer slot= s__UIButton_customValue[but]
        local integer itemId
        local integer itm
        local integer cid
        
        if ( ( UserInterface___ClickingPlayer ) != s__User_handle[( s__Inventory_pid[inv] )] or s___Equipment_item[s__Equipment_item[gear] + slot] <= 0 ) then // INLINED!!
            return false
        endif

        // clear tooltip
        call s__Inventory_showLines(inv , s__Inventory_pid[inv] , false , s__Inventory_camera[inv])
        
        set itm=s___Equipment_item[s__Equipment_item[gear] + slot]
        set itemId=s__InvItem_id[itm]
        set cid=s___Equipment_itemId[s__Equipment_itemId[gear] + slot]
        
        set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear] + slot]]=cid
        
        if ( s__Equipment_unequip(gear , itm , slot) ) then
            set s__InvItem_tempCustomId[itm]=cid
            if ( not s__Inventory_addItem(inv , itm) ) then
                set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[gear] + slot]]=cid
                call s__Equipment_equip(gear , itm , slot)
                return false
            endif
        else
            return false
        endif
    
        call s__Inventory_showTooltip(inv , false)
        
        return false
    endfunction
    
    function EquipmentCore___LClickItemSlot takes nothing returns boolean
        local integer but= ( UserInterface___ClickedButton )
        local player p= ( UserInterface___ClickingPlayer )
        local integer equip= ( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[GetPlayerId(p)] ))] )
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

        call s__Inventory_showLines(inv , s__Inventory_pid[inv] , false , s__Inventory_camera[inv])
        
        set EquipmentCore_PlayerLastSlot[s__User_id[s__Equipment_user[equip]]]=slot + 1
        
        // equip item
        if ( inv > 0 and last + 1 > 0 ) then
        
            set last=( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + last
            
            set itm=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( last )) ) // INLINED!!
            
            if ( s__InvItem_slot[itm] - 1 == slot or s__InvItem_slotAlt[itm] - 1 == slot ) then
                set s__InvItem_tempCustomId[itm]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( last )) ) // INLINED!!
                
                if ( s__Equipment_equip(equip , itm , slot) ) then
                    set EquipmentCore_PlayerLastSlot[s__Inventory_pid[inv]]=0
                    call s__Inventory_setItem(inv , last , 0)
            
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
        
        set itemId=s__InvItem_id[s___Equipment_item[s__Equipment_item[equip] + slot]]
        
        call s__UIPicture_show(s__Inventory_selector[s__Inventory_pid[inv]] , false , s__Inventory_camera[inv])
        call s__UIPicture_setPosition(s__Equipment_selector[s__Inventory_pid[inv]] , s__UIButton_centerx[but] - 0.007 , s__UIButton_centery[but] + 0.0272)
        call s__UIPicture_showPlayer(s__Equipment_selector[s__Inventory_pid[inv]] , Player(s__Inventory_pid[inv]) , true , s__Inventory_camera[inv])
        
        if ( itemId > 0 ) then
            set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[equip] + slot]]=s___Equipment_itemId[s__Equipment_itemId[equip] + slot]
            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[( inv )]]], ( GetObjectName(itemId) ), 10 * 0.0023) // INLINED!!
            call s__InvItem_buildDescription(( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( ( itemId ) )) ) , s__Inventory_owner[inv]) // INLINED!!
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxCost[s__Inventory_pid[( inv )]]], ( "|cffffcc00" + I2S(s__InvItem_cost[( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( ( itemId ) )) )]) + "|r" ), 8 * 0.0023) // INLINED!!
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[( inv )]] , ( s__Inventory_localInt(s__Inventory_pid[inv] , GetItemIcon(itemId) , s__Inventory_ICON_TRANSPARENT) )) // INLINED!!
            
            set s__InvItem_tempCustomId[s___Equipment_item[s__Equipment_item[equip] + slot]]=0
        endif
        
        // display tooltip
        set s__Inventory_TOOLTIP_X=s__UIButton_minx[but] - 0.4
        set s__Inventory_TOOLTIP_Y=s__UIButton_miny[but] - 0.08
        
        call s__Inventory_showTooltip(inv , itemId > 0)

        return false
    endfunction
    
    function EquipmentCore___Init takes nothing returns nothing
        set EquipmentCore_FuncLClickSlot=Filter(function EquipmentCore___LClickItemSlot)
        set EquipmentCore_FuncRClickSlot=Filter(function EquipmentCore___RClickItemSlot)
        call TriggerAddAction(s__Inventory_ExecL, ( function EquipmentCore___OnInventoryItemClick )) // INLINED!!
        call TriggerAddAction(s__Inventory_ExecR, ( function EquipmentCore___OnInventoryItemRightClick )) // INLINED!!
    endfunction


//library EquipmentCore ends
//===========================================================================
// 
// Inventory & Equipment System v1.4.1
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Thu Jan 25 09:40:31 2018
//   Map Author: TriggerHappy
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
//*  Items
//*
//***************************************************************************

function CreateAllItems takes nothing returns nothing
    local integer itemID

    call CreateItem('I000', 642.1, - 19.0)
    call CreateItem('I000', 596.8, - 78.2)
    call CreateItem('I000', 616.2, - 49.7)
    call CreateItem('I001', 200.1, - 81.3)
    call CreateItem('I001', 233.0, 12.2)
    call CreateItem('I001', 141.3, - 57.6)
    call CreateItem('I001', 249.7, - 81.3)
    call CreateItem('I001', 196.9, - 46.5)
    call CreateItem('I001', 268.3, - 27.1)
    call CreateItem('I001', 154.5, 2.3)
    call CreateItem('I002', 408.5, - 30.4)
    call CreateItem('I002', 456.6, - 25.5)
    call CreateItem('I002', 488.9, - 7.6)
    call CreateItem('I003', 355.8, 366.7)
    call CreateItem('I003', - 119.6, 293.0)
    call CreateItem('I003', 480.1, 368.7)
    call CreateItem('I003', 405.8, 366.7)
    call CreateItem('I003', 445.3, 368.7)
    call CreateItem('I003', - 167.9, 294.9)
    call CreateItem('I004', 709.1, 427.7)
    call CreateItem('I004', 669.8, 348.8)
    call CreateItem('I005', 486.8, 305.6)
    call CreateItem('I005', - 170.7, 357.7)
    call CreateItem('I006', 673.5, 396.0)
    call CreateItem('I006', 598.1, 390.1)
    call CreateItem('I006', 634.6, 390.1)
    call CreateItem('I007', - 228.4, - 404.5)
    call CreateItem('I007', - 234.3, - 369.2)
    call CreateItem('I009', - 201.5, - 605.8)
    call CreateItem('I009', - 103.5, - 586.6)
    call CreateItem('I009', - 111.9, - 550.6)
    call CreateItem('I009', - 175.9, - 639.1)
    call CreateItem('I009', - 183.0, - 550.6)
    call CreateItem('I009', - 148.4, - 565.7)
    call CreateItem('I009', - 136.2, - 613.1)
    call CreateItem('I009', - 223.2, - 562.7)
    call CreateItem('I00A', 18.2, - 393.0)
    call CreateItem('I00A', - 21.6, - 389.2)
    call CreateItem('I00A', - 5.1, - 343.8)
    call CreateItem('I00A', - 38.7, - 347.8)
    call CreateItem('belv', 10.8, 114.8)
    call CreateItem('belv', - 75.9, 102.8)
    call CreateItem('belv', 5.8, 169.7)
    call CreateItem('belv', - 38.1, 114.8)
    call CreateItem('belv', - 12.6, 82.3)
    call CreateItem('belv', - 33.4, 168.7)
    call CreateItem('belv', - 61.2, 147.0)
    call CreateItem('bgst', 379.9, 98.9)
    call CreateItem('bgst', 368.1, 181.2)
    call CreateItem('bgst', 408.9, 166.6)
    call CreateItem('bgst', 419.3, 120.7)
    call CreateItem('bgst', 352.7, 137.9)
    call CreateItem('brac', 206.0, 362.9)
    call CreateItem('brac', 167.8, 288.3)
    call CreateItem('brac', 197.7, 302.9)
    call CreateItem('brac', 142.3, 336.7)
    call CreateItem('ckng', 10.1, - 111.1)
    call CreateItem('ckng', - 43.9, - 24.2)
    call CreateItem('ckng', - 14.7, - 39.0)
    call CreateItem('ckng', - 62.5, - 134.9)
    call CreateItem('ckng', - 108.5, - 37.6)
    call CreateItem('desc', - 399.1, - 434.9)
    call CreateItem('desc', - 446.0, - 472.0)
    call CreateItem('desc', - 435.5, - 432.4)
    call CreateItem('desc', - 359.8, - 434.9)
    call CreateItem('desc', - 363.7, - 469.6)
    call CreateItem('desc', - 405.1, - 472.0)
    call CreateItem('modt', - 58.7, 367.1)
    call CreateItem('modt', 43.6, 353.5)
    call CreateItem('modt', - 13.9, 311.0)
    call CreateItem('modt', - 21.0, 351.0)
    call CreateItem('modt', 38.8, 319.4)
    call CreateItem('modt', 7.9, 336.3)
    call CreateItem('nspi', 665.9, 138.9)
    call CreateItem('nspi', 599.6, 106.8)
    call CreateItem('nspi', 574.5, 126.8)
    call CreateItem('nspi', 632.6, 146.0)
    call CreateItem('ofro', - 307.6, 357.8)
    call CreateItem('ofro', - 290.0, 328.8)
    call CreateItem('ofro', - 238.1, 324.6)
    call CreateItem('pghe', - 359.4, - 583.5)
    call CreateItem('pghe', - 406.5, - 583.5)
    call CreateItem('pghe', - 450.8, - 583.5)
    call CreateItem('ratf', - 202.8, - 92.5)
    call CreateItem('ratf', - 312.2, - 46.6)
    call CreateItem('rde3', - 315.5, 134.8)
    call CreateItem('rde3', - 259.9, 150.1)
    call CreateItem('rde3', - 294.7, 109.8)
    call CreateItem('rde3', - 259.9, 95.9)
    call CreateItem('rde3', - 266.5, 182.2)
    call CreateItem('rde3', - 305.3, 165.6)
    call CreateItem('rst1', 128.0, 151.1)
    call CreateItem('rst1', 162.0, 156.3)
    call CreateItem('rst1', 225.6, 171.8)
    call CreateItem('rst1', 184.8, 182.2)
    call CreateItem('shhn', - 234.4, - 251.8)
    call CreateItem('srbd', - 394.2, - 302.5)
    call CreateItem('srbd', - 446.0, - 307.3)
    call CreateItem('srbd', - 411.0, - 244.2)
    call CreateItem('srbd', - 460.6, - 249.3)
    call CreateItem('tkno', 863.7, 63.8)
    call CreateItem('tkno', - 427.0, - 73.7)
    call CreateItem('tkno', 857.6, - 55.1)
    call CreateItem('tkno', 818.7, - 68.6)
    call CreateItem('tkno', - 456.9, - 61.6)
    call CreateItem('tkno', 865.7, - 17.8)
    call CreateItem('tkno', 831.3, 65.1)
    call CreateItem('tkno', - 393.5, 162.8)
    call CreateItem('tkno', 803.1, - 31.6)
    call CreateItem('tkno', - 472.3, 115.5)
    call CreateItem('tkno', - 424.3, 134.8)
    call CreateItem('tkno', - 429.9, - 27.1)
    call CreateItem('tkno', - 433.7, - 123.6)
    call CreateItem('tkno', 894.4, - 32.9)
    call CreateItem('tkno', 811.0, 15.3)
    call CreateItem('tkno', 896.4, 30.9)
    call CreateItem('tkno', - 383.4, - 59.2)
    call CreateItem('tkno', - 489.8, - 70.1)
    call CreateItem('tkno', - 467.1, 175.5)
endfunction

//***************************************************************************
//*
//*  Custom Script Code
//*
//***************************************************************************
//TESH.scrollpos=0
//TESH.alwaysfold=0

//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: StartGame
//===========================================================================
// scope StartGame begins


    function StartGame___StartGame takes nothing returns nothing
        local trigger trig
        local integer i= 0
        local integer user
        local integer equipment
        local integer inv
        local integer array urace
        
        set urace[1]='Hpal'
        set urace[2]='Obla'
        set urace[3]='Ulic'
        set urace[4]='Edem'

        loop
            exitwhen i == s__User_AmountPlaying
            
            set user=( s__User_PlayingPlayer[( i )] ) // INLINED!!
            set PlayerCamera[s__User_id[user]]=s__Camera_create()
            
            // create hero
            set equipment=s__Equipment_create(CreateUnitAtLoc(s__User_handle[user], urace[GetHandleId(GetPlayerRace(s__User_handle[user]))], GetStartLocationLoc(GetPlayerStartLocation(s__User_handle[user])), 180))
            
            call UnitAddAbility(s__Equipment_unit[equipment], 'A001')
            call UnitAddAbility(s__Equipment_unit[equipment], 'A002')
            
            if ( s__User_Local == s__User_handle[user] ) then
                call SelectUnit(s__Equipment_unit[equipment], true)
                call PanCameraToTimed(GetUnitX(s__Equipment_unit[equipment]), GetUnitY(s__Equipment_unit[equipment]), 0)
            endif
            
            set inv=s__Inventory_create(s__Equipment_unit[equipment])
            
            set PlayerHero[s__User_id[user]]=s__Equipment_unit[equipment]
            
            call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), s__User_handle[user], bj_ALLIANCE_ALLIED_VISION)
            call SetPlayerAllianceStateBJ(s__User_handle[user], Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_ALLIED_VISION)
            
            set i=i + 1
        endloop
    endfunction
    
    function StartGame___Init takes nothing returns nothing
        call SetSkyModel("Environment\\Sky\\Sky\\SkyLight.mdl")
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 22.00)
        call StartGame___StartGame()
    endfunction

// scope StartGame ends
// Trigger: Inventory
//===========================================================================
// Trigger: InventoryItem
//===========================================================================
// Trigger: InventoryPlugins
//===========================================================================
// Trigger: InventoryTooltip
//===========================================================================
// Trigger: InventoryBonus
//===========================================================================
// Trigger: InventoryGlobals
//===========================================================================
// Trigger: Equipment
//===========================================================================
// Trigger: EquipmentItem
//===========================================================================
// Trigger: EquipmentSockets
//===========================================================================
// Trigger: EquipHeroModels
//===========================================================================
// Trigger: EquipItemParser
//===========================================================================
// Trigger: Item Setups
//===========================================================================
// scope InvItemSetups begins
    
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
        
        call s__InvItem_addBonus(itm , BONUS_STRENGTH , 5)
        call s__InvItem_addBonus(itm , BONUS_AGILITY , 5)
        call s__InvItem_addBonus(itm , BONUS_INTELLIGENCE , 5)
        
        // with string parser
        // Claws of Attack +15
        call sc___prototype60_execute(1 , 'ratf' , "Increases the attack damage of the Hero by 15 when worn.^type=weapon; class=1h; maxsock=1; icon='D009'; cost=28; ^dmg=15;0;0;")
        
        // Robe of the Last Guardian
        call sc___prototype60_execute(1 , 'I007' , "Powerful magic robe.^type=armor; lvl=10; icon=B00Z; utype='Ulic'; cost=600; maxsock=2; ^def=0;10;20; int=20;0;5; life=300;0;0;")
        
        // Gems
        call sc___prototype60_execute(1 , 'I009' , "Can be socketed..^type=gem; icon=B012; cost=600; ^life=0;10;50;")
        call sc___prototype60_execute(1 , 'I00A' , "Can be socketed..^type=gem; icon=B013; cost=600; ^mana=0;5;35;")
        
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
        call s__InvItem_addBonus(itm , BONUS_AGILITY , 6)
        set s__InvItem_maxSockets[itm]=1
        
        // Belt of Giant Strength +6
        set itm=CreateInvItem('bgst' , 'B00J' , 500 , 0 , " Increases the Strength of the Hero by 6 when worn.")
        set s__InvItem_slot[itm]=4
        call s__InvItem_addBonus(itm , BONUS_STRENGTH , 6)
        set s__InvItem_maxSockets[itm]=1
        
        // Gauntlets of Ogre Strength +3
        set itm=CreateInvItem('rst1' , 'B00K' , 100 , 0 , " Increases the Strength of the Hero by 3 when worn.")
        set s__InvItem_slot[itm]=9
        call s__InvItem_addBonus(itm , BONUS_STRENGTH , 3)
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
        call s__InvItem_addBonus(itm , BONUS_ARMOR , 4)
        set s__InvItem_maxSockets[itm]=1
        
        // Pauldron
        set itm=CreateInvItem('I000' , 'B00P' , 600 , 0 , " Increases the armor of the Hero by 4 when worn.")
        set s__InvItem_slot[itm]=2
        set s__InvItem_slotAlt[itm]=8
        call s__InvItem_addBonus(itm , BONUS_ARMOR , 4)
        set s__InvItem_maxSockets[itm]=1
        
        // Battlescarred Shoulderplate
        set itm=CreateInvItem('I003' , 'B00V' , 600 , 0 , " Increases the armor by 4 and strenght by 2 when worn.")
        set s__InvItem_slot[itm]=2
        set s__InvItem_slotAlt[itm]=8
        set s__InvItem_reqUnitType[itm]='Hpal'
        set s__InvItem_reqLevel[itm]=3
        call s__InvItem_addBonus(itm , BONUS_ARMOR , 4)
        call s__InvItem_addBonus(itm , BONUS_STRENGTH , 2)
        set s__InvItem_maxSockets[itm]=1
        
        // Lich Mantle
        set itm=CreateInvItem('I006' , 'B00Y' , 600 , 0 , " Increases Intelligence by 3 and Health by 50 when worn.")
        set s__InvItem_slot[itm]=2
        set s__InvItem_slotAlt[itm]=8
        set s__InvItem_reqUnitType[itm]='Ulic'
        set s__InvItem_reqLevel[itm]=3
        call s__InvItem_addBonus(itm , BONUS_INTELLIGENCE , 3)
        call s__InvItem_addBonus(itm , BONUS_LIFE , 50)
        set s__InvItem_maxSockets[itm]=1
        
        // Armor
        set itm=CreateInvItem('I001' , 'B00Q' , 600 , 0 , " Increases armor by 8 and life by 100 when worn.")
        set s__InvItem_slot[itm]=3
        call s__InvItem_addBonus(itm , BONUS_ARMOR , 8)
        call s__InvItem_addBonus(itm , BONUS_LIFE , 100)
        set s__InvItem_maxSockets[itm]=1
        
        // Silverhand Cuirass
        set itm=CreateInvItem('I004' , 'B00W' , 600 , 0 , " Increases armor by 10 and life by 150 when worn.")
        set s__InvItem_slot[itm]=3
        set s__InvItem_reqUnitType[itm]='Hpal'
        set s__InvItem_reqLevel[itm]=2
        call s__InvItem_addBonus(itm , BONUS_ARMOR , 10)
        call s__InvItem_addBonus(itm , BONUS_LIFE , 150)
        set s__InvItem_maxSockets[itm]=2
        
        // Pants
        set itm=CreateInvItem('I002' , 'B00R' , 600 , 0 , "Increases Strength by 3 when worn.")
        set s__InvItem_slot[itm]=5
        call s__InvItem_addBonus(itm , BONUS_STRENGTH , 3)
        set s__InvItem_maxSockets[itm]=1
        
        // Golden Legguards
        set itm=CreateInvItem('I005' , 'B00X' , 600 , 0 , "Increases Strength by 3 and Armor by 1 when worn.")
        set s__InvItem_slot[itm]=5
        set s__InvItem_reqUnitType[itm]='Hpal'
        call s__InvItem_addBonus(itm , BONUS_STRENGTH , 2)
        call s__InvItem_addBonus(itm , BONUS_ARMOR , 1)
        set s__InvItem_maxSockets[itm]=2
        
        // Kel'Thuzard's Robe
        set itm=CreateInvItem('I008' , 'B010' , 600 , 0 , "Increases Intelligence by 5, Health by 40, and Mana by 50 when worn.")
        set s__InvItem_slot[itm]=3
        set s__InvItem_reqUnitType[itm]='Ulic'
        call s__InvItem_addBonus(itm , BONUS_INTELLIGENCE , 5)
        call s__InvItem_addBonus(itm , BONUS_LIFE , 40)
        call s__InvItem_addBonus(itm , BONUS_MANA , 50)
        set s__InvItem_maxSockets[itm]=1
        
        // Searing Blade
        set itm=CreateInvItem('srbd' , 'B000' , 1650 , 0 , "Adds 10 bonus fire damage to the attack of a Hero when carried. The Hero's attacks also do splash damage to nearby enemy units.")
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
        call s__InvItem_addBonus(itm , BONUS_ARMOR , 8)
        set s__InvItem_maxSockets[itm]=2
        
        // Dagger of Escape
        set itm=CreateInvItem('desc' , 'B002' , 400 , 0 , "Allows the Hero to teleport a short distance.")
        set s__InvItem_slot[itm]=13
        set s__InvItem_slotAlt[itm]=14
        set s__InvItem_reqUnitType[itm]='Edem'
        set s__InvItem_equipAbility[itm]='AIbk'
        set s__InvItem_maxSockets[itm]=1
    endfunction
    
// scope InvItemSetups ends
// Trigger: Show Equipment
//===========================================================================
function Trig_show_equip_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A001' ) ) then
        return false
    endif
    return true
endfunction

function Trig_show_equip_Actions takes nothing returns nothing
    local unit u= GetTriggerUnit()
    local integer pid= GetPlayerId(GetOwningPlayer(u))
    local boolean flag= not s__Equipment_displayed[( s__Equipment_UnitsIndex[GetUnitUserData(( u ))] )]
    
    call s__Equipment_show(( s__Equipment_UnitsIndex[GetUnitUserData(( u ))] ) , flag , PlayerCamera[pid]) // INLINED!!
    
    set u=null
endfunction

//===========================================================================
function InitTrig_Show_Equipment takes nothing returns nothing
    set gg_trg_Show_Equipment=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Show_Equipment, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(gg_trg_Show_Equipment, Condition(function Trig_show_equip_Conditions))
    call TriggerAddAction(gg_trg_Show_Equipment, function Trig_show_equip_Actions)
endfunction

//===========================================================================
// Trigger: Show Inventory
//===========================================================================
function Trig_show_bag_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A002' ) ) then
        return false
    endif
    return true
endfunction

function Trig_show_bag_Actions takes nothing returns nothing
    local unit u= GetTriggerUnit()
    local integer inv= ( LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(( u ))) )
    local integer pid= GetPlayerId(GetOwningPlayer(u))
    local unit u2= s__Equipment_unit[( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[pid] ))] )]
    
    call s__Inventory_show(inv , not s__Inventory_displayed[inv] , PlayerCamera[pid])
    
    if ( u2 != null and u2 != u ) then
        call s__Equipment_show(( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[pid] ))] ) , false , PlayerCamera[pid]) // INLINED!!
    endif
    
    set u=null
endfunction

//===========================================================================
function InitTrig_Show_Inventory takes nothing returns nothing
    set gg_trg_Show_Inventory=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Show_Inventory, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(gg_trg_Show_Inventory, Condition(function Trig_show_bag_Conditions))
    call TriggerAddAction(gg_trg_Show_Inventory, function Trig_show_bag_Actions)
endfunction

//===========================================================================
// Trigger: AcquireItem
//===========================================================================
// scope AcquireItem begins
    
    function AcquireItem___Actions takes nothing returns nothing
        local unit u= GetTriggerUnit()
        local item itm= GetManipulatedItem()
        local integer inv= ( LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(( u ))) )
        local integer itemData
        local integer data
        call ILM_Log("pickup", "ENTRY", "unit=" + I2S(GetHandleId(u)) + " type=" + I2S(GetItemTypeId(itm)) + " cid=" + I2S(GetItemUserData(itm)))
        
        if ( inv == 0 ) then
            return
        endif
        
        set itemData=( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( ( GetItemTypeId(itm) ) )) ) // INLINED!!
        if ( itemData <= 0 ) then
            return
        endif
        
        set data=GetItemUserData(itm)
        
        if ( data == 0 ) then
            set data=s__InvCustomItem_create()
            call SetItemUserData(itm, data)
        endif
        
        set s__InvItem_tempCustomId[itemData]=data
        call ILM_Log("pickup", "PRE_ADD", "inv=" + I2S(inv) + " item=" + I2S(itemData) + " type=" + I2S(GetItemTypeId(itm)) + " cid=" + I2S(data))
        
        if ( s__Inventory_addItem(inv , itemData) ) then
            call ILM_Log("pickup", "ADD_TRUE", "type=" + I2S(GetItemTypeId(itm)) + " cid=" + I2S(data))
            call RemoveItem(itm)
        else
            call ILM_Log("pickup", "ADD_FALSE", "type=" + I2S(GetItemTypeId(itm)) + " cid=" + I2S(data))
            call UnitRemoveItem(u, itm)
        endif
        
        set itm=null
        set u=null
    endfunction

    //===========================================================================
    function AcquireItem___Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        call TriggerAddAction(t, function AcquireItem___Actions)
    endfunction

// scope AcquireItem ends
// Trigger: Equip Item
//===========================================================================
// scope EquipItem begins

    function IsInvItm2H takes integer itm returns boolean
        return ( s__InvItem_slot[itm] == 13 and s__InvItem_slotAlt[itm] == 0 )
    endfunction
    
    function EquipItem___Actions takes nothing returns nothing
        local integer itm= InvEventItem
        local player p= InvEventPlayer
        local unit u= s__Equipment_PlayerCurrentUnit[s__User_id[( GetPlayerId(( p )) )]]
        local integer inv= ( LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(( u ))) )
        local integer gear= ( s__Equipment_UnitsIndex[GetUnitUserData(( u ))] )
        local boolean is2h= IsInvItm2H(itm)
        
        // 2H weapon conditions
        if ( is2h ) then
        
            if ( s___Equipment_item[s__Equipment_item[gear] + 14 - 1] > 0 ) then
                call SimError(p , "You cannot equip a two-handed weapon with an offhand item.")
                call s__Equipment_unequip(gear , s___Equipment_item[s__Equipment_item[gear] + s__InvItem_slot[itm] - 1] , s__InvItem_slot[itm] - 1)
                
                if ( inv > 0 ) then
                    call s__Inventory_addItem(inv , itm)
                else
                    call SetItemUserData(UnitAddItemById(u, s__InvItem_id[itm]), s__InvItem_tempCustomId[itm])
                    set s__InvItem_tempCustomId[itm]=0
                endif
            endif
            
        elseif ( s__InvItem_slot[itm] == 14 or s__InvItem_slotAlt[itm] == 14 ) then
        
            if ( s___Equipment_item[s__Equipment_item[gear] + 13 - 1] > 0 and IsInvItm2H(s___Equipment_item[s__Equipment_item[gear] + 13 - 1]) ) then
                call SimError(p , "You cannot equip an offhand item with a two-handed weapon.")
                call s__Equipment_unequip(gear , s___Equipment_item[s__Equipment_item[gear] + 14 - 1] , 14 - 1)
                
                if ( inv > 0 ) then
                    call s__Inventory_addItem(inv , itm)
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

// scope EquipItem ends
// Trigger: Unequip Item
//===========================================================================
// scope UnequipItem begins

    function UnequipItem___Actions takes nothing returns nothing
        //call BJDebugMsg(GetPlayerName(InvEquipPlayer) + " unequipped " + GetObjectName(InvEquipItem.id))
    endfunction

    //===========================================================================
    function UnequipItem___Init takes nothing returns nothing
        set s__InvItem_onUnequip=CreateTrigger()
        call TriggerAddAction(s__InvItem_onUnequip, function UnequipItem___Actions)
    endfunction

// scope UnequipItem ends
// Trigger: Sell Item
//===========================================================================
// scope SellItem begins

    
    function SellItem___OnAgree takes nothing returns boolean
        local integer user= ( GetPlayerId(( GetTriggerPlayer() )) )
        local integer itm= SellItem___SellItem[s__User_id[user]]
        local integer slot= SellItem___SellSlot[s__User_id[user]]
        local integer inv= SellItem___SellInv[s__User_id[user]]
        call ILM_Log("sell", "AGREE_ENTRY", "inv=" + I2S(inv) + " item=" + I2S(itm) + " type=" + I2S(s__InvItem_id[itm]) + " cost=" + I2S(s__InvItem_cost[itm]) + " slot=" + I2S(slot))
        
        call s__Inventory_setItem(inv , slot , 0)
        call SetPlayerState(( s__User_handle[( s__Inventory_user[inv] )] ), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(( s__User_handle[( s__Inventory_user[inv] )] ), PLAYER_STATE_RESOURCE_GOLD) + s__InvItem_cost[itm]) // INLINED!!
        call DisplayTimedTextToPlayer(( s__User_handle[( s__Inventory_user[inv] )] ), 0, 0, 15, "You sold \"" + GetObjectName(s__InvItem_id[itm]) + "\" for |cffffcc00" + I2S(s__InvItem_cost[itm]) + "|r gold.") // INLINED!!
        
        return false
    endfunction
    
    function SellItem___Actions takes nothing returns nothing
        local integer itm= InvEventItem
        local player p= InvEventPlayer
        local integer inv= s__Inventory_PlayerCurrent[s__User_id[( GetPlayerId(( p )) )]]
        local integer slot= InvEventSlot
        call ILM_Log("sell", "REQUEST", "inv=" + I2S(inv) + " item=" + I2S(itm) + " type=" + I2S(s__InvItem_id[itm]) + " cost=" + I2S(s__InvItem_cost[itm]) + " slot=" + I2S(slot))
        
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

// scope SellItem ends
// Trigger: Drop Item
//===========================================================================
// scope DropItem begins

    
    function DropItem___OnAgree takes nothing returns boolean
        local integer user= ( GetPlayerId(( GetTriggerPlayer() )) )
        local integer itm= DropItem___DropItem[s__User_id[user]]
        local integer slot= DropItem___DropSlot[s__User_id[user]]
        local integer inv= DropItem___DropInv[s__User_id[user]]
        call ILM_Log("drop", "AGREE_ENTRY", "inv=" + I2S(inv) + " item=" + I2S(itm) + " type=" + I2S(s__InvItem_id[itm]) + " slot=" + I2S(slot))
        
        call SetItemUserData(CreateItem(s__InvItem_id[itm], GetUnitX(s__Inventory_owner[inv]), GetUnitY(s__Inventory_owner[inv])), ( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( slot )) )) // INLINED!!
        call s__Inventory_setItem(inv , slot , 0)
        
        call DisplayTimedTextToPlayer(( s__User_handle[( user )] ), 0, 0, 15, "You dropped \"" + GetObjectName(s__InvItem_id[itm]) + "\".") // INLINED!!
        
        return false
    endfunction
    
    function DropItem___Actions takes nothing returns nothing
        local integer itm= InvEventItem
        local player p= InvEventPlayer
        local integer inv= s__Inventory_PlayerCurrent[s__User_id[( GetPlayerId(( p )) )]]
        local integer slot= InvEventSlot
        call ILM_Log("drop", "REQUEST", "inv=" + I2S(inv) + " item=" + I2S(itm) + " type=" + I2S(s__InvItem_id[itm]) + " slot=" + I2S(slot))
        
        if ( itm <= 0 ) then
            return
        endif
        
        set DropItem___DropItem[s__User_id[s__Inventory_user[inv]]]=itm
        set DropItem___DropSlot[s__User_id[s__Inventory_user[inv]]]=slot
        set DropItem___DropInv[s__User_id[s__Inventory_user[inv]]]=inv
        
        call s__Inventory_showTooltip(inv , false)
        
        call ShowYesNoDialog("Drop " + GetObjectName(s__InvItem_id[itm]) + "?" , s__Inventory_user[inv] , Filter(function DropItem___OnAgree))
    endfunction

    //===========================================================================
    function DropItem___Init takes nothing returns nothing
        set s__Inventory_onDrop=CreateTrigger()
        call TriggerAddAction(s__Inventory_onDrop, function DropItem___Actions)
    endfunction

// scope DropItem ends
// Trigger: Socket Item
//===========================================================================
// scope SocketItem begins

    
    function SocketItem___OnAgree takes nothing returns boolean
        local integer user= ( GetPlayerId(( GetTriggerPlayer() )) )
        local integer itm= SocketItem___SockItem[s__User_id[user]]
        local integer slot= SocketItem___SockSlot[s__User_id[user]]
        local integer inv= SocketItem___SockInv[s__User_id[user]]
        local integer socketItm= ( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( slot )) )
        
        call ILM_Log("socket", "AGREE_ENTRY", "inv=" + I2S(inv) + " gem=" + I2S(itm) + " gem_type=" + I2S(s__InvItem_id[itm]) + " target=" + I2S(socketItm) + " slot=" + I2S(slot))
        set s__InvItem_tempCustomId[socketItm]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( slot )) ) // INLINED!!
        
        if ( s__InvItem_addSocket(socketItm , itm) ) then
            call ILM_Log("socket", "ADD_TRUE", "inv=" + I2S(inv) + " gem=" + I2S(itm) + " target=" + I2S(socketItm) + " slot=" + I2S(slot))
        

                set s__InvItem_tempCustomId[socketItm]=( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEM_ID ) + ( ( s__Inventory_MAX_SLOTS * s__Inventory_currentPage[inv] ) + slot )) ) // INLINED!!

                call s__InvItem_buildDescription(socketItm , s__Inventory_owner[inv])



            
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxTitle[s__Inventory_pid[( inv )]]], ( GetObjectName(s__InvItem_id[socketItm]) ), 10 * 0.0023) // INLINED!!
            call SetTextTagText(s__UIText_text[s__Inventory_infoBoxCost[s__Inventory_pid[( inv )]]], ( "|cffffcc00" + I2S(s__InvItem_cost[( LoadInteger(Table___ht, ( ( s__InvItem_Table ) ), ( ( s__InvItem_id[socketItm] ) )) )]) + "|r" ), 8 * 0.0023) // INLINED!!
            call s__UIPicture_setTexture(s__Inventory_infoIcon[s__Inventory_pid[( inv )]] , ( s__Inventory_localInt(s__Inventory_pid[inv] , GetItemIcon(s__InvItem_id[socketItm]) , s__Inventory_ICON_TRANSPARENT) )) // INLINED!!
            
            call s__Inventory_showTooltip(inv , true)
            
            call s__Inventory_setItem(inv , SocketItem___SockLast[s__User_id[user]] , 0)
        endif
        
        return false
    endfunction
    
    function SocketItem___Actions takes nothing returns nothing
        local integer inv= SocketInv
        local integer itm= ( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( SocketLast )) )
        local integer socketItm= ( LoadInteger(s__Inventory_Hashtable, ( inv ), ( s__Inventory_MAX_ITEMS * s__Inventory_KEY_ITEMS ) + ( SocketSlot )) )
        
        call ILM_Log("socket", "REQUEST", "inv=" + I2S(inv) + " gem=" + I2S(itm) + " gem_type=" + I2S(s__InvItem_id[itm]) + " target=" + I2S(socketItm) + " from=" + I2S(SocketLast) + " slot=" + I2S(SocketSlot))
        call ILM_Log("socket", "DETAIL", "target_type=" + I2S(s__InvItem_id[socketItm]) + " max_sockets=" + I2S(s__InvItem_maxSockets[socketItm]) + " gem_cost=" + I2S(s__InvItem_cost[itm]) + " is_gem=" + ILM_Bool(s__InvItem_isSocket[itm]))
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

// scope SocketItem ends
// Trigger: HideInv
//===========================================================================
// scope HideInventory begins

    function HideInventory___OnIndex takes nothing returns boolean
        local unit u= ( s__UnitDex_Unit[s__UnitDex_LastIndex] )
        local integer inv= ( LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(( u ))) )
        local unit u2= s__Equipment_unit[( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]] ))] )]

        if ( u == u2 and u != null ) then
            call s__Equipment_show(( s__Equipment_UnitsIndex[GetUnitUserData(( u2 ))] ) , false , PlayerCamera[s__Inventory_pid[inv]]) // INLINED!!
        endif
        
        if ( s__Inventory_PlayerCurrent[s__Inventory_pid[inv]] == inv ) then
            call s__Inventory_show(inv , false , PlayerCamera[s__Inventory_pid[inv]])
        endif
        
        return false
    endfunction
    
    function HideInventory___OnDeath takes nothing returns nothing
        local unit u= GetTriggerUnit()
        local integer inv= ( LoadInteger(s__Inventory_Hashtable, s__Inventory_KEY_UNIT, GetHandleId(( u ))) )
        local unit u2= s__Equipment_unit[( s__Equipment_UnitsIndex[GetUnitUserData(( s__Equipment_PlayerCurrentUnit[s__Inventory_pid[inv]] ))] )]
        
        if ( u == u2 and u != null ) then
            call s__Equipment_show(( s__Equipment_UnitsIndex[GetUnitUserData(( u2 ))] ) , false , PlayerCamera[s__Inventory_pid[inv]]) // INLINED!!
        endif
        
        if ( s__Inventory_PlayerCurrent[s__Inventory_pid[inv]] == inv ) then
            call s__Inventory_show(inv , false , PlayerCamera[s__Inventory_pid[inv]])
        endif
    endfunction
    
    function HideInventory___Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddAction(t, function HideInventory___OnDeath)
        
call TriggerAddCondition(UnitDex___IndexTrig[EVENT_UNIT_DEINDEX], Filter(( function HideInventory___OnIndex ))) // INLINED!!
    endfunction

// scope HideInventory ends
// Trigger: YesNoDialog
//===========================================================================
//===========================================================================
// Trigger: UserInterface
//===========================================================================
// Trigger: UnitDex
//===========================================================================
// Trigger: PlayerUtils
//===========================================================================
// Trigger: Camera
//===========================================================================
// Trigger: Math
//===========================================================================
// Trigger: TimerUtils
//===========================================================================
// Trigger: Table
//===========================================================================
// Trigger: SimError
//===========================================================================
// Trigger: BonusMod
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: RegenBonuses
//===========================================================================
//TESH.scrollpos=172
//TESH.alwaysfold=0
// Trigger: UnitMaxStateBonuses
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: MovementBonus
//===========================================================================
//TESH.scrollpos=9
//TESH.alwaysfold=0
// Trigger: UnitMaxState
//===========================================================================
//TESH.scrollpos=9
//TESH.alwaysfold=0
// Trigger: AutoIndex UD
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: xebasic
//===========================================================================
//===========================================================================
// Trigger: xepreload
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    //Function not found: call InitTrig_StartGame()
    //Function not found: call InitTrig_Inventory()
    //Function not found: call InitTrig_InventoryItem()
    //Function not found: call InitTrig_InventoryPlugins()
    //Function not found: call InitTrig_InventoryTooltip()
    //Function not found: call InitTrig_InventoryBonus()
    //Function not found: call InitTrig_InventoryGlobals()
    //Function not found: call InitTrig_Equipment()
    //Function not found: call InitTrig_EquipmentItem()
    //Function not found: call InitTrig_EquipmentSockets()
    //Function not found: call InitTrig_EquipHeroModels()
    //Function not found: call InitTrig_EquipItemParser()
    //Function not found: call InitTrig_Item_Setups()
    call InitTrig_Show_Equipment()
    call InitTrig_Show_Inventory()
    //Function not found: call InitTrig_AcquireItem()
    //Function not found: call InitTrig_Equip_Item()
    //Function not found: call InitTrig_Unequip_Item()
    //Function not found: call InitTrig_Sell_Item()
    //Function not found: call InitTrig_Drop_Item()
    //Function not found: call InitTrig_Socket_Item()
    //Function not found: call InitTrig_HideInv()
    //Function not found: call InitTrig_YesNoDialog()
    //Function not found: call InitTrig_UserInterface()
    //Function not found: call InitTrig_UnitDex()
    //Function not found: call InitTrig_PlayerUtils()
    //Function not found: call InitTrig_Camera()
    //Function not found: call InitTrig_Math()
    //Function not found: call InitTrig_TimerUtils()
    //Function not found: call InitTrig_Table()
    //Function not found: call InitTrig_SimError()
    //Function not found: call InitTrig_BonusMod()
    //Function not found: call InitTrig_RegenBonuses()
    //Function not found: call InitTrig_UnitMaxStateBonuses()
    //Function not found: call InitTrig_MovementBonus()
    //Function not found: call InitTrig_UnitMaxState()
    //Function not found: call InitTrig_AutoIndex_UD()
    //Function not found: call InitTrig_xebasic()
    //Function not found: call InitTrig_xepreload()
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call ForcePlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call ForcePlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(1), true)
    call SetPlayerController(Player(1), MAP_CONTROL_USER)

    // Player 2
    call SetPlayerStartLocation(Player(2), 2)
    call ForcePlayerStartLocation(Player(2), 2)
    call SetPlayerColor(Player(2), ConvertPlayerColor(2))
    call SetPlayerRacePreference(Player(2), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(2), true)
    call SetPlayerController(Player(2), MAP_CONTROL_USER)

    // Player 3
    call SetPlayerStartLocation(Player(3), 3)
    call ForcePlayerStartLocation(Player(3), 3)
    call SetPlayerColor(Player(3), ConvertPlayerColor(3))
    call SetPlayerRacePreference(Player(3), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(3), true)
    call SetPlayerController(Player(3), MAP_CONTROL_USER)

    // Player 4
    call SetPlayerStartLocation(Player(4), 4)
    call ForcePlayerStartLocation(Player(4), 4)
    call SetPlayerColor(Player(4), ConvertPlayerColor(4))
    call SetPlayerRacePreference(Player(4), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(4), true)
    call SetPlayerController(Player(4), MAP_CONTROL_USER)

    // Player 5
    call SetPlayerStartLocation(Player(5), 5)
    call ForcePlayerStartLocation(Player(5), 5)
    call SetPlayerColor(Player(5), ConvertPlayerColor(5))
    call SetPlayerRacePreference(Player(5), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(5), true)
    call SetPlayerController(Player(5), MAP_CONTROL_USER)

    // Player 6
    call SetPlayerStartLocation(Player(6), 6)
    call ForcePlayerStartLocation(Player(6), 6)
    call SetPlayerColor(Player(6), ConvertPlayerColor(6))
    call SetPlayerRacePreference(Player(6), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(6), true)
    call SetPlayerController(Player(6), MAP_CONTROL_USER)

    // Player 7
    call SetPlayerStartLocation(Player(7), 7)
    call ForcePlayerStartLocation(Player(7), 7)
    call SetPlayerColor(Player(7), ConvertPlayerColor(7))
    call SetPlayerRacePreference(Player(7), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(7), true)
    call SetPlayerController(Player(7), MAP_CONTROL_USER)

    // Player 8
    call SetPlayerStartLocation(Player(8), 8)
    call ForcePlayerStartLocation(Player(8), 8)
    call SetPlayerColor(Player(8), ConvertPlayerColor(8))
    call SetPlayerRacePreference(Player(8), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(8), true)
    call SetPlayerController(Player(8), MAP_CONTROL_USER)

    // Player 9
    call SetPlayerStartLocation(Player(9), 9)
    call ForcePlayerStartLocation(Player(9), 9)
    call SetPlayerColor(Player(9), ConvertPlayerColor(9))
    call SetPlayerRacePreference(Player(9), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(9), true)
    call SetPlayerController(Player(9), MAP_CONTROL_USER)

    // Player 10
    call SetPlayerStartLocation(Player(10), 10)
    call ForcePlayerStartLocation(Player(10), 10)
    call SetPlayerColor(Player(10), ConvertPlayerColor(10))
    call SetPlayerRacePreference(Player(10), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(10), true)
    call SetPlayerController(Player(10), MAP_CONTROL_USER)

    // Player 11
    call SetPlayerStartLocation(Player(11), 11)
    call ForcePlayerStartLocation(Player(11), 11)
    call SetPlayerColor(Player(11), ConvertPlayerColor(11))
    call SetPlayerRacePreference(Player(11), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(11), true)
    call SetPlayerController(Player(11), MAP_CONTROL_COMPUTER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_002
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerTeam(Player(3), 0)
    call SetPlayerTeam(Player(4), 0)
    call SetPlayerTeam(Player(5), 0)
    call SetPlayerTeam(Player(6), 0)
    call SetPlayerTeam(Player(7), 0)
    call SetPlayerTeam(Player(8), 0)
    call SetPlayerTeam(Player(9), 0)
    call SetPlayerTeam(Player(10), 0)

    //   Allied
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(9), true)

    //   Shared Vision
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(9), true)

    // Force: TRIGSTR_471
    call SetPlayerTeam(Player(11), 1)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 1)
    call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 2)
    call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 1, 2, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(2, 2)
    call SetStartLocPrio(2, 0, 1, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(2, 1, 3, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(3, 2)
    call SetStartLocPrio(3, 0, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(3, 1, 4, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(4, 2)
    call SetStartLocPrio(4, 0, 3, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(4, 1, 5, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(5, 2)
    call SetStartLocPrio(5, 0, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(5, 1, 6, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(6, 2)
    call SetStartLocPrio(6, 0, 5, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(6, 1, 7, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(7, 2)
    call SetStartLocPrio(7, 0, 6, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(7, 1, 8, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(8, 1)
    call SetStartLocPrio(8, 0, 7, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(9, 5)
    call SetStartLocPrio(9, 0, 5, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(9, 1, 6, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(9, 2, 7, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(9, 3, 8, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(9, 4, 10, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(10, 6)
    call SetStartLocPrio(10, 0, 2, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(10, 1, 3, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(10, 2, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(10, 3, 5, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(10, 4, 6, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(10, 5, 9, MAP_LOC_PRIO_LOW)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
// Late helpers use only the original PUBLIC inventory getters and demo hero.
function ILM_Say takes string message returns nothing
    call DisplayTimedTextToPlayer(Player(0), 0, 0, 15, "IL141M: " + message)
endfunction

function ILM_Guidance takes nothing returns nothing
    call ILM_Say("Ready, NOT recording. Single client / Player 0 only. Original controls remain yours.")
    call ILM_Say("-im start <label> | -im status | -im mark | -im save | -im stop")
    call ILM_Say("NEW label each launch: 1-32 ASCII letters/digits/_/-, first alphanumeric. Never reuse files.")
    call ILM_Say("Writing is unverified until files are checked. No semantic PASS certification.")
endfunction

function ILM_Label takes string text returns boolean
    local string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
    local integer i = 0
    local integer j
    local integer bound = 62
    local string c
    if StringLength(text) < 1 or StringLength(text) > 32 then
        return false
    endif
    loop
        exitwhen i == StringLength(text)
        set c = SubString(text, i, i + 1)
        set j = 0
        loop
            exitwhen j == bound or c == SubString(alphabet, j, j + 1)
            set j = j + 1
        endloop
        if j == bound then
            return false
        endif
        set i = i + 1
        set bound = 64
    endloop
    return true
endfunction

function ILM_WriteChunk takes nothing returns nothing
    local integer i = 0
    // Only the current chunk is retained. Sealed chunks are never rewritten.
    if ILM_ChunkCount == 0 or not ILM_ChunkDirty then
        return
    endif
    call PreloadGenClear()
    call PreloadGenStart()
    loop
        exitwhen i == ILM_ChunkCount
        call Preload(ILM_Chunk[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\IL141M-" + ILM_BUILD + "--" + ILM_Session + "--" + I2S(ILM_ChunkIndex) + ".pld")
    set ILM_ChunkDirty = false
endfunction

function ILM_Sample takes nothing returns nothing
    local integer i = 0
    local integer itemValue
    local integer customValue
    local integer strength
    local integer agility
    local integer intelligence
    local integer gold
    if not ILM_Active then
        return
    endif
    // Public getters only: no socket-table reconstruction or tempCustomId writes.
    loop
        exitwhen i == 150 or not ILM_Active
        set itemValue = s__Inventory_getItem(ILM_Inventory, i)
        set customValue = s__Inventory_getItemId(ILM_Inventory, i)
        if itemValue != ILM_Items[i] or customValue != ILM_Custom[i] then
            call ILM_Log("sample", "SLOT", "slot=" + I2S(i) + " item=" + I2S(itemValue) + " cid=" + I2S(customValue))
            set ILM_Items[i] = itemValue
            set ILM_Custom[i] = customValue
        endif
        set i = i + 1
    endloop
    set strength = GetHeroStr(ILM_Hero, true)
    set agility = GetHeroAgi(ILM_Hero, true)
    set intelligence = GetHeroInt(ILM_Hero, true)
    set gold = GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)
    if strength != ILM_Str or agility != ILM_Agi or intelligence != ILM_Int or gold != ILM_Gold then
        call ILM_Log("sample", "STATS", "str=" + I2S(strength) + " agi=" + I2S(agility) + " int=" + I2S(intelligence) + " gold=" + I2S(gold))
        set ILM_Str = strength
        set ILM_Agi = agility
        set ILM_Int = intelligence
        set ILM_Gold = gold
    endif
    set ILM_LastSample = ILM_Now()
    set ILM_Dirty = false
endfunction

function ILM_Persist takes nothing returns boolean
    local boolean terminal = ILM_EndPending
    // This trigger owns persistence and its operation budget, never an early hook.
    if terminal then
        call ILM_Append("recorder", "TERMINAL", "reason=" + ILM_Reason + " rows=" + I2S(ILM_Sequence + 1) + " dropped=" + I2S(ILM_Dropped))
        set ILM_EndPending = false
    endif
    loop
        exitwhen ILM_Queued == 0
        set ILM_Chunk[ILM_ChunkCount] = ILM_Queue[ILM_Head]
        set ILM_Queue[ILM_Head] = null
        set ILM_Head = ILM_Head + 1
        if ILM_Head == ILM_QUEUE_ROWS then
            set ILM_Head = 0
        endif
        set ILM_Queued = ILM_Queued - 1
        set ILM_ChunkCount = ILM_ChunkCount + 1
        set ILM_ChunkDirty = true
        if ILM_ChunkCount == ILM_CHUNK_ROWS then
            call ILM_WriteChunk()
            set ILM_ChunkCount = 0
            set ILM_ChunkIndex = ILM_ChunkIndex + 1
        endif
    endloop
    call ILM_WriteChunk()
    set ILM_SavePending = false
    if terminal then
        call ILM_Say("Recorder stopped: " + ILM_Reason + "; rows=" + I2S(ILM_Sequence) + "; refused=" + I2S(ILM_Dropped) + ". Gameplay continues.")
        call ILM_Say("Persistence requested, NOT filesystem-verified. OVERFLOW means partial coverage; later actions are unrecorded.")
    endif
    return true
endfunction

function ILM_Tick takes nothing returns nothing
    // Dirty bursts coalesce; also poll once/second for changes outside our hooks.
    if ILM_Active and ((ILM_Dirty and ILM_Now() - ILM_LastSample >= 250) or ILM_Now() - ILM_LastSample >= 1000) then
        call ILM_Sample()
    endif
    if ILM_Queued > 0 or ILM_EndPending or ILM_SavePending then
        call TriggerEvaluate(ILM_Work)
    endif
endfunction

function ILM_Status takes nothing returns nothing
    if not ILM_Used then
        call ILM_Guidance()
    elseif ILM_Active then
        call ILM_Say("Recording " + ILM_BUILD + " / " + ILM_Session + "; rows=" + I2S(ILM_Sequence) + "; queued=" + I2S(ILM_Queued) + "; chunk=" + I2S(ILM_ChunkIndex) + ". Writing unverified.")
    else
        call ILM_Say("NOT recording: " + ILM_Reason + "; rows=" + I2S(ILM_Sequence) + ". No restart this launch. Gameplay continues unrecorded.")
    endif
endfunction

function ILM_Command takes nothing returns nothing
    local string text = GetEventPlayerChatString()
    local string label
    if text == "-im status" then
        call ILM_Status()
        return
    endif
    if SubString(text, 0, 10) == "-im start " then
        set label = SubString(text, 10, StringLength(text))
        if ILM_Used then
            call ILM_Say("Start refused: one session per launch, even after stop. Nothing changed.")
        elseif not ILM_Label(label) then
            call ILM_Say("Start refused: invalid label. Use 1-32 ASCII letters/digits/_/-, first alphanumeric.")
        elseif s__User_AmountPlaying != 1 or GetPlayerController(Player(0)) != MAP_CONTROL_USER or PlayerHero[0] == null then
            call ILM_Say("Start refused: requires the original single-client Player 0 hero. Nothing changed.")
        else
            set ILM_Hero = PlayerHero[0]
            set ILM_Inventory = s__Inventory__staticgetindex(ILM_Hero)
            if ILM_Inventory <= 0 then
                call ILM_Say("Start refused: original inventory not ready. Nothing changed.")
                return
            endif
            set ILM_Session = label
            set ILM_Used = true
            set ILM_Active = true
            call ILM_Log("recorder", "BEGIN", "schema=1")
            call ILM_Sample()
            set ILM_SavePending = true
            call ILM_Say("Recording " + ILM_BUILD + " / " + label + ". Original bag/equipment controls remain yours. Writing unverified.")
        endif
        return
    endif
    if text == "-im mark" or text == "-im save" or text == "-im stop" then
        if not ILM_Active then
            call ILM_Status()
            call ILM_Say("Command refused: recorder not active. No new observations recorded.")
            return
        endif
        if text == "-im mark" then
            call ILM_Log("recorder", "MARK", "manual")
            call ILM_Say("Mark requested. Writing unverified.")
        else
            call ILM_Sample()
            if text == "-im stop" and ILM_Active then
                set ILM_Active = false
                set ILM_Reason = "USER_STOP"
                set ILM_EndPending = true
            endif
            set ILM_SavePending = true
            call ILM_Say("Checkpoint requested; writing unverified. Stop affects recorder only.")
        endif
        return
    endif
    call ILM_Say("Unknown command. Exact forms: -im start <label> | -im status | -im mark | -im save | -im stop")
endfunction

function ILM_Init takes nothing returns nothing
    set ILM_Clock = CreateTimer()
    set ILM_Poll = CreateTimer()
    set ILM_Work = CreateTrigger()
    set ILM_Chat = CreateTrigger()
    call TimerStart(ILM_Clock, 1000000.0, false, null)
    call TriggerAddCondition(ILM_Work, Condition(function ILM_Persist))
    call TriggerRegisterPlayerChatEvent(ILM_Chat, Player(0), "-im", false)
    call TriggerAddAction(ILM_Chat, function ILM_Command)
    call TimerStart(ILM_Poll, 0.25, true, function ILM_Tick)
    call ILM_Guidance()
endfunction
function main takes nothing returns nothing
    call SetCameraBounds(- 1280.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 1408.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 1280.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 1024.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 1280.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 1024.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 1280.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 1408.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("LordaeronSummerDay")
    call SetAmbientNightSound("LordaeronSummerNight")
    call SetMapMusic("Music", true, 0)
    call CreateAllItems()
    call InitBlizzard()



call ExecuteFunc("jasshelper__initstructs779454218")
call ExecuteFunc("EquipHeroModels___Init")
call ExecuteFunc("SimError___init")
call ExecuteFunc("TimerUtils___init")
call ExecuteFunc("UIMath___Init")
call ExecuteFunc("UserInterface___Init")
call ExecuteFunc("InventoryCore___Init")
call ExecuteFunc("MovementBonus___OnInit")
call ExecuteFunc("RegenBonuses___OnInit")
call ExecuteFunc("EquipmentItem_Init")
call ExecuteFunc("EquipmentCore___Init")
call StartGame___Init()
call InvItemSetups___Init()
call AcquireItem___Init()
call EquipItem___Init()
call UnequipItem___Init()
call SellItem___Init()
call DropItem___Init()
call SocketItem___Init()
call HideInventory___Init()

    call InitGlobals()
    call InitCustomTriggers()

    call ILM_Init()
endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_456")
    call SetMapDescription("TRIGSTR_830")
    call SetPlayers(12)
    call SetTeams(12)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, 0.0, - 384.0)
    call DefineStartLocation(1, 64.0, - 384.0)
    call DefineStartLocation(2, 128.0, - 384.0)
    call DefineStartLocation(3, 192.0, - 384.0)
    call DefineStartLocation(4, 256.0, - 384.0)
    call DefineStartLocation(5, 320.0, - 384.0)
    call DefineStartLocation(6, 384.0, - 384.0)
    call DefineStartLocation(7, 448.0, - 384.0)
    call DefineStartLocation(8, 512.0, - 384.0)
    call DefineStartLocation(9, 448.0, - 512.0)
    call DefineStartLocation(10, 256.0, - 512.0)
    call DefineStartLocation(11, 0.0, - 512.0)

    // Player setup
    call InitCustomPlayerSlots()
    call InitCustomTeams()
    call InitAllyPriorities()
endfunction




//Struct method generated initializers/callers:

//Functions for BigArrays:
function sa__Table___GTable_onDestroy takes nothing returns boolean
local integer this=f__arg_this
            call FlushChildHashtable(Table___ht, ( ( this ) )) // INLINED!!
   return true
endfunction
function sa__UnitMaxStateBonuses___BonusValues_onDestroy takes nothing returns boolean
local integer this=f__arg_this
        set s__UnitMaxStateBonuses___BonusValues_owners[( GetUnitUserData(( s__UnitMaxStateBonuses___BonusValues_owner[this] )) )]=( 0 ) // INLINED!!
        set s__UnitMaxStateBonuses___BonusValues_owner[this]=null
   return true
endfunction
function sa__Table__getindex takes nothing returns boolean
local integer this=f__arg_this
local integer key=f__arg_integer1
set f__result_integer=LoadInteger(Table___ht, ( this ), key)
   return true
endfunction
function sa__Table__setindex takes nothing returns boolean
local integer this=f__arg_this
local integer key=f__arg_integer1
local integer value=f__arg_integer2
            call SaveInteger(Table___ht, ( this ), key, value)
   return true
endfunction
function sa__RegenBonuses___BonusValues_onDestroy takes nothing returns boolean
local integer this=f__arg_this
        set s__RegenBonuses___BonusValues_owners[( GetUnitUserData(( s__RegenBonuses___BonusValues_owner[this] )) )]=( 0 ) // INLINED!!
        set s__RegenBonuses___BonusValues_all[s__RegenBonuses___BonusValues_index[this]]=s__RegenBonuses___BonusValues_all[s__RegenBonuses___BonusValues_count]
        set s__RegenBonuses___BonusValues_count=s__RegenBonuses___BonusValues_count - 1
        if s__RegenBonuses___BonusValues_count == 0 then
            call PauseTimer(RegenBonuses___regenTimer)
        endif
        set s__RegenBonuses___BonusValues_owner[this]=null
   return true
endfunction
function sa__MovementBonus___BonusValue_onDestroy takes nothing returns boolean
local integer this=f__arg_this
        set s__MovementBonus___BonusValue_owners[( GetUnitUserData(( s__MovementBonus___BonusValue_owner[this] )) )]=( 0 ) // INLINED!!
        set s__MovementBonus___BonusValue_all[s__MovementBonus___BonusValue_index[this]]=s__MovementBonus___BonusValue_all[s__MovementBonus___BonusValue_count]
        set s__MovementBonus___BonusValue_count=s__MovementBonus___BonusValue_count - 1
        set s__MovementBonus___BonusValue_owner[this]=null
   return true
endfunction
function sa__Inventory_setTooltipLine takes nothing returns boolean
local integer pid=f__arg_integer1
local integer line=f__arg_integer2
local string str=f__arg_string1
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + line]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
   return true
endfunction
function sa__Inventory_setTooltipSlot takes nothing returns boolean
local integer pid=f__arg_integer1
local integer line=f__arg_integer2
local string str=f__arg_string1
            call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + s__Inventory_TOOLTIP_LINES_MAX - 1]], str, s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
   return true
endfunction
function sa__Inventory_clearLines takes nothing returns boolean
local integer pid=f__arg_integer1
            local integer i= 0
            loop
                exitwhen i == s__Inventory_TOOLTIP_LINES_MAX
                call SetTextTagText(s__UIText_text[s__s__Inventory_ItemInfoTags[( pid ) * ( 16 ) + i]], "", s__Inventory_TOOLTIP_FONT_SIZE * 0.0023)
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
function sa__BonusModStruct_addBonus takes nothing returns boolean
    set f__result_integer=s__BonusModStruct_addBonus(f__arg_unit1 , f__arg_integer1 , f__arg_integer2)
   return true
endfunction
function sa__InvCustomItem_seed takes nothing returns boolean
local integer this=f__arg_this
set f__result_integer=( LoadInteger(Table___ht, ( ( s__InvCustomItem_SeedTable ) ), ( this )) ) // INLINED!!
   return true
endfunction
function sa__InvItem__get_sockets takes nothing returns boolean
local integer this=f__arg_this
set f__result_integer=LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], s__InvItem_InvItemSocket__KEY_SOCKETS_COUNT * 100)
   return true
endfunction
function sa__InvItem_socketId takes nothing returns boolean
local integer this=f__arg_this
local integer index=f__arg_integer1
set f__result_integer=LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket__KEY_SOCKETS_ID * 100 ) + index)
   return true
endfunction
function sa__InvItem_getSocket takes nothing returns boolean
local integer this=f__arg_this
local integer index=f__arg_integer1
            if s__InvItem_isSocket[this] then
set f__result_integer=0
return true
            endif
set f__result_integer=LoadInteger(s__InvItem_SocketTable, s__InvItem_tempCustomId[this], ( s__InvItem_InvItemSocket__KEY_SOCKETS * 100 ) + index)
   return true
endfunction
function sa__UnitDex_Remove takes nothing returns boolean
    set f__result_boolean=s__UnitDex_Remove(f__arg_unit1 , f__arg_boolean1)
   return true
endfunction
function sa__Bonus_create takes nothing returns boolean

        local integer this= s__Bonus__allocate()
        set s__Bonus_BonusMod___isBonusObject[this]=true
set f__result_integer=this
   return true
endfunction
function sa__Bonus_setBonus takes nothing returns boolean
    set f__result_integer=s__Bonus_setBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__Bonus_getBonus takes nothing returns boolean
    set f__result_integer=s__Bonus_getBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__Bonus_removeBonus takes nothing returns boolean
    call sc__Bonus_setBonus(( f__arg_this ) , ( f__arg_unit1 ) , 0) // INLINED!!
   return true
endfunction
function sa__Bonus_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__Bonus_isValidBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus takes nothing returns boolean
    call s__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus(( f__arg_this ) , ( f__arg_unit1 ) , 0) // INLINED!!
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
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
                call UnitAddAbility(xepreload___dum, ( ( rawcode + i ) )) // INLINED!!
                set i=i + 1
            endloop
            if negativeRawcode != 0 then
                call UnitAddAbility(xepreload___dum, ( ( negativeRawcode ) )) // INLINED!!
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
set f__result_integer=bonus
   return true
endfunction
function sa__BonusMod___AbilityBonus_setBonus takes nothing returns boolean
    set f__result_integer=s__BonusMod___AbilityBonus_setBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__BonusMod___AbilityBonus_getBonus takes nothing returns boolean
    set f__result_integer=s__BonusMod___AbilityBonus_getBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__BonusMod___AbilityBonus_removeBonus takes nothing returns boolean
    call s__BonusMod___AbilityBonus_removeBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__BonusMod___AbilityBonus_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__BonusMod___AbilityBonus_isValidBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__MovementBonus___MovementBonus_setBonus takes nothing returns boolean
    set f__result_integer=s__MovementBonus___MovementBonus_setBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__MovementBonus___MovementBonus_getBonus takes nothing returns boolean
    set f__result_integer=s__MovementBonus___MovementBonus_getBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__MovementBonus___MovementBonus_removeBonus takes nothing returns boolean
    call s__MovementBonus___MovementBonus_setBonus(( f__arg_this ) , ( f__arg_unit1 ) , 0) // INLINED!!
   return true
endfunction
function sa__MovementBonus___MovementBonus_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__MovementBonus___MovementBonus_isValidBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses___RegenBonus_life_setBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses___RegenBonus_life_setBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses___RegenBonus_life_getBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses___RegenBonus_life_getBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__RegenBonuses___RegenBonus_life_removeBonus takes nothing returns boolean
    call s__RegenBonuses___RegenBonus_life_setBonus(( f__arg_this ) , ( f__arg_unit1 ) , 0) // INLINED!!
   return true
endfunction
function sa__RegenBonuses___RegenBonus_life_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__RegenBonuses___RegenBonus_life_isValidBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses___RegenBonus_mana_setBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses___RegenBonus_mana_setBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__RegenBonuses___RegenBonus_mana_getBonus takes nothing returns boolean
    set f__result_integer=s__RegenBonuses___RegenBonus_mana_getBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__RegenBonuses___RegenBonus_mana_removeBonus takes nothing returns boolean
    call s__RegenBonuses___RegenBonus_mana_setBonus(( f__arg_this ) , ( f__arg_unit1 ) , 0) // INLINED!!
   return true
endfunction
function sa__RegenBonuses___RegenBonus_mana_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__RegenBonuses___RegenBonus_mana_isValidBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_setBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_getBonus takes nothing returns boolean
    set f__result_integer=s__UnitMaxStateBonuses___MaxStateBonus_life_getBonus(f__arg_this , f__arg_unit1)
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus takes nothing returns boolean
    call s__UnitMaxStateBonuses___MaxStateBonus_life_setBonus(( f__arg_this ) , ( f__arg_unit1 ) , 0) // INLINED!!
   return true
endfunction
function sa__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus takes nothing returns boolean
    set f__result_boolean=s__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus(f__arg_this , f__arg_unit1 , f__arg_integer1)
   return true
endfunction
function sa___prototype3_TimerUtils___init takes nothing returns boolean

     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils___didinit ) then
    return true
        else
            set TimerUtils___didinit=true
        endif
            set TimerUtils___ht=InitHashtable()
            loop
                exitwhen ( i == TimerUtils___QUANTITY )
                set s__TimerUtils___tT[i]=CreateTimer()
                call SaveInteger(TimerUtils___ht, 0, GetHandleId(( s__TimerUtils___tT[i] )), ( TimerUtils___HELD )) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils___tN=TimerUtils___QUANTITY
    return true
endfunction
function sa___prototype41_RemoveUnitBonus takes nothing returns boolean
    call RemoveUnitBonus(f__arg_unit1 , f__arg_integer1)
    return true
endfunction
function sa___prototype42_SetUnitBonus takes nothing returns boolean
    set f__result_integer=SetUnitBonus(f__arg_unit1 , f__arg_integer1 , f__arg_integer2)
    return true
endfunction
function sa___prototype43_GetUnitBonus takes nothing returns boolean
    set f__result_integer=GetUnitBonus(f__arg_unit1 , f__arg_integer1)
    return true
endfunction
function sa___prototype30_MovementBonus___OnLeaveMap takes nothing returns boolean
    call MovementBonus___OnLeaveMap(f__arg_unit1)
    return true
endfunction
function sa___prototype30_RegenBonuses___OnLeaveMap takes nothing returns boolean
    call RegenBonuses___OnLeaveMap(f__arg_unit1)
    return true
endfunction
function sa___prototype30_UnitMaxStateBonuses___OnLeaveMap takes nothing returns boolean
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
function sa___prototype60_InitEquipItem takes nothing returns boolean
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
        call SaveInteger(Table___ht, ( ( s__InvItem_Table ) ), ( s__InvItem_id[itm] ), ( itm )) // INLINED!!
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
                    call EquipItemParser___ParseParam(itm , StringCase(param, false) , value[0])
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
    set f__result_integer=itm
    return true
endfunction

function jasshelper__initstructs779454218 takes nothing returns nothing
    set st__Table___GTable_onDestroy[3]=CreateTrigger()
    set st__Table___GTable_onDestroy[4]=st__Table___GTable_onDestroy[3]
    set st__Table___GTable_onDestroy[5]=st__Table___GTable_onDestroy[3]
    set st__Table___GTable_onDestroy[6]=st__Table___GTable_onDestroy[3]
    call TriggerAddCondition(st__Table___GTable_onDestroy[3], Condition(function sa__Table___GTable_onDestroy))
    set st__UnitMaxStateBonuses___BonusValues_onDestroy=CreateTrigger()
    call TriggerAddCondition(st__UnitMaxStateBonuses___BonusValues_onDestroy, Condition(function sa__UnitMaxStateBonuses___BonusValues_onDestroy))
    set st__Table__getindex=CreateTrigger()
    call TriggerAddCondition(st__Table__getindex, Condition(function sa__Table__getindex))
    set st__Table__setindex=CreateTrigger()
    call TriggerAddCondition(st__Table__setindex, Condition(function sa__Table__setindex))
    set st__RegenBonuses___BonusValues_onDestroy=CreateTrigger()
    call TriggerAddCondition(st__RegenBonuses___BonusValues_onDestroy, Condition(function sa__RegenBonuses___BonusValues_onDestroy))
    set st__MovementBonus___BonusValue_onDestroy=CreateTrigger()
    call TriggerAddCondition(st__MovementBonus___BonusValue_onDestroy, Condition(function sa__MovementBonus___BonusValue_onDestroy))
    set st__Inventory_setTooltipLine=CreateTrigger()
    call TriggerAddCondition(st__Inventory_setTooltipLine, Condition(function sa__Inventory_setTooltipLine))
    set st__Inventory_setTooltipSlot=CreateTrigger()
    call TriggerAddCondition(st__Inventory_setTooltipSlot, Condition(function sa__Inventory_setTooltipSlot))
    set st__Inventory_clearLines=CreateTrigger()
    call TriggerAddCondition(st__Inventory_clearLines, Condition(function sa__Inventory_clearLines))
    set st__UIText_show=CreateTrigger()
    call TriggerAddCondition(st__UIText_show, Condition(function sa__UIText_show))
    set st__BonusModStruct_addBonus=CreateTrigger()
    call TriggerAddCondition(st__BonusModStruct_addBonus, Condition(function sa__BonusModStruct_addBonus))
    set st__InvCustomItem_seed=CreateTrigger()
    call TriggerAddCondition(st__InvCustomItem_seed, Condition(function sa__InvCustomItem_seed))
    set st__InvItem__get_sockets=CreateTrigger()
    call TriggerAddCondition(st__InvItem__get_sockets, Condition(function sa__InvItem__get_sockets))
    set st__InvItem_socketId=CreateTrigger()
    call TriggerAddCondition(st__InvItem_socketId, Condition(function sa__InvItem_socketId))
    set st__InvItem_getSocket=CreateTrigger()
    call TriggerAddCondition(st__InvItem_getSocket, Condition(function sa__InvItem_getSocket))
    set st__UnitDex_Remove=CreateTrigger()
    call TriggerAddCondition(st__UnitDex_Remove, Condition(function sa__UnitDex_Remove))
    set st__Bonus_create=CreateTrigger()
    call TriggerAddCondition(st__Bonus_create, Condition(function sa__Bonus_create))
    set st__Bonus_setBonus[18]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[18], Condition(function sa__Bonus_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[18], function sa__Bonus_setBonus)
    set st__Bonus_getBonus[18]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[18], Condition(function sa__Bonus_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[18], function sa__Bonus_getBonus)
    set st__Bonus_removeBonus[18]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[18], Condition(function sa__Bonus_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[18], function sa__Bonus_removeBonus)
    set st__Bonus_isValidBonus[18]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[18], Condition(function sa__Bonus_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[18], function sa__Bonus_isValidBonus)
    set st__BonusMod___BonusInterface_onDestroy[18]=null
    set st__BonusMod___BonusInterface_onDestroy[19]=null
    set st__BonusMod___BonusInterface_onDestroy[29]=null
    set st__BonusMod___BonusInterface_onDestroy[31]=null
    set st__BonusMod___BonusInterface_onDestroy[32]=null
    set st__BonusMod___BonusInterface_onDestroy[34]=null
    set st__BonusMod___BonusInterface_onDestroy[35]=null
    set st__Bonus_setBonus[35]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[35], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[35], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_setBonus)
    set st__Bonus_getBonus[35]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[35], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[35], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_getBonus)
    set st__Bonus_removeBonus[35]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[35], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[35], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_removeBonus)
    set st__Bonus_isValidBonus[35]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[35], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[35], function sa__UnitMaxStateBonuses___MaxStateBonus_mana_isValidBonus)
    set st__BonusMod___AbilityBonus_create=CreateTrigger()
    call TriggerAddCondition(st__BonusMod___AbilityBonus_create, Condition(function sa__BonusMod___AbilityBonus_create))
    set st__Bonus_setBonus[19]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[19], Condition(function sa__BonusMod___AbilityBonus_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[19], function sa__BonusMod___AbilityBonus_setBonus)
    set st__Bonus_getBonus[19]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[19], Condition(function sa__BonusMod___AbilityBonus_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[19], function sa__BonusMod___AbilityBonus_getBonus)
    set st__Bonus_removeBonus[19]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[19], Condition(function sa__BonusMod___AbilityBonus_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[19], function sa__BonusMod___AbilityBonus_removeBonus)
    set st__Bonus_isValidBonus[19]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[19], Condition(function sa__BonusMod___AbilityBonus_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[19], function sa__BonusMod___AbilityBonus_isValidBonus)
    set st__Bonus_setBonus[29]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[29], Condition(function sa__MovementBonus___MovementBonus_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[29], function sa__MovementBonus___MovementBonus_setBonus)
    set st__Bonus_getBonus[29]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[29], Condition(function sa__MovementBonus___MovementBonus_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[29], function sa__MovementBonus___MovementBonus_getBonus)
    set st__Bonus_removeBonus[29]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[29], Condition(function sa__MovementBonus___MovementBonus_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[29], function sa__MovementBonus___MovementBonus_removeBonus)
    set st__Bonus_isValidBonus[29]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[29], Condition(function sa__MovementBonus___MovementBonus_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[29], function sa__MovementBonus___MovementBonus_isValidBonus)
    set st__Bonus_setBonus[31]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[31], Condition(function sa__RegenBonuses___RegenBonus_life_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[31], function sa__RegenBonuses___RegenBonus_life_setBonus)
    set st__Bonus_getBonus[31]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[31], Condition(function sa__RegenBonuses___RegenBonus_life_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[31], function sa__RegenBonuses___RegenBonus_life_getBonus)
    set st__Bonus_removeBonus[31]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[31], Condition(function sa__RegenBonuses___RegenBonus_life_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[31], function sa__RegenBonuses___RegenBonus_life_removeBonus)
    set st__Bonus_isValidBonus[31]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[31], Condition(function sa__RegenBonuses___RegenBonus_life_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[31], function sa__RegenBonuses___RegenBonus_life_isValidBonus)
    set st__Bonus_setBonus[32]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[32], Condition(function sa__RegenBonuses___RegenBonus_mana_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[32], function sa__RegenBonuses___RegenBonus_mana_setBonus)
    set st__Bonus_getBonus[32]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[32], Condition(function sa__RegenBonuses___RegenBonus_mana_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[32], function sa__RegenBonuses___RegenBonus_mana_getBonus)
    set st__Bonus_removeBonus[32]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[32], Condition(function sa__RegenBonuses___RegenBonus_mana_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[32], function sa__RegenBonuses___RegenBonus_mana_removeBonus)
    set st__Bonus_isValidBonus[32]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[32], Condition(function sa__RegenBonuses___RegenBonus_mana_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[32], function sa__RegenBonuses___RegenBonus_mana_isValidBonus)
    set st__Bonus_setBonus[34]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_setBonus[34], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_life_setBonus))
    call TriggerAddAction(st__Bonus_setBonus[34], function sa__UnitMaxStateBonuses___MaxStateBonus_life_setBonus)
    set st__Bonus_getBonus[34]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_getBonus[34], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_life_getBonus))
    call TriggerAddAction(st__Bonus_getBonus[34], function sa__UnitMaxStateBonuses___MaxStateBonus_life_getBonus)
    set st__Bonus_removeBonus[34]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_removeBonus[34], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus))
    call TriggerAddAction(st__Bonus_removeBonus[34], function sa__UnitMaxStateBonuses___MaxStateBonus_life_removeBonus)
    set st__Bonus_isValidBonus[34]=CreateTrigger()
    call TriggerAddCondition(st__Bonus_isValidBonus[34], Condition(function sa__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus))
    call TriggerAddAction(st__Bonus_isValidBonus[34], function sa__UnitMaxStateBonuses___MaxStateBonus_life_isValidBonus)
    set st___prototype3[1]=CreateTrigger()
    call TriggerAddAction(st___prototype3[1], function sa___prototype3_TimerUtils___init)
    call TriggerAddCondition(st___prototype3[1], Condition(function sa___prototype3_TimerUtils___init))
    set st___prototype41[1]=CreateTrigger()
    call TriggerAddAction(st___prototype41[1], function sa___prototype41_RemoveUnitBonus)
    call TriggerAddCondition(st___prototype41[1], Condition(function sa___prototype41_RemoveUnitBonus))
    set st___prototype42[1]=CreateTrigger()
    call TriggerAddAction(st___prototype42[1], function sa___prototype42_SetUnitBonus)
    call TriggerAddCondition(st___prototype42[1], Condition(function sa___prototype42_SetUnitBonus))
    set st___prototype43[1]=CreateTrigger()
    call TriggerAddAction(st___prototype43[1], function sa___prototype43_GetUnitBonus)
    call TriggerAddCondition(st___prototype43[1], Condition(function sa___prototype43_GetUnitBonus))
    set st___prototype30[1]=CreateTrigger()
    call TriggerAddAction(st___prototype30[1], function sa___prototype30_MovementBonus___OnLeaveMap)
    call TriggerAddCondition(st___prototype30[1], Condition(function sa___prototype30_MovementBonus___OnLeaveMap))
    set st___prototype30[2]=CreateTrigger()
    call TriggerAddAction(st___prototype30[2], function sa___prototype30_RegenBonuses___OnLeaveMap)
    call TriggerAddCondition(st___prototype30[2], Condition(function sa___prototype30_RegenBonuses___OnLeaveMap))
    set st___prototype30[3]=CreateTrigger()
    call TriggerAddAction(st___prototype30[3], function sa___prototype30_UnitMaxStateBonuses___OnLeaveMap)
    call TriggerAddCondition(st___prototype30[3], Condition(function sa___prototype30_UnitMaxStateBonuses___OnLeaveMap))
    set st___prototype3[2]=CreateTrigger()
    call TriggerAddAction(st___prototype3[2], function sa___prototype3_EquipmentItem_Init)
    call TriggerAddCondition(st___prototype3[2], Condition(function sa___prototype3_EquipmentItem_Init))
    set st___prototype60[1]=CreateTrigger()
    call TriggerAddAction(st___prototype60[1], function sa___prototype60_InitEquipItem)
    call TriggerAddCondition(st___prototype60[1], Condition(function sa___prototype60_InitEquipItem))


call ExecuteFunc("s__User_PlayerUtils___PlayerUtilsInit__onInit")








call ExecuteFunc("s__UnitDex_UnitDex___UnitDexCore__onInit")



call ExecuteFunc("s__Camera___CamInit_Camera___CamInitModule__onInit")



call ExecuteFunc("s__xepreload___Init_xepreload___PreloadInit__onInit")




call ExecuteFunc("s__BonusModStruct_BonusMod___BonusModInitModule__onInit")

call ExecuteFunc("s__UnitMaxState___Data_UnitMaxState___UnitStatInit__onInit")















call ExecuteFunc("s__UnitMaxStateBonuses___Data_UnitMaxStateBonuses___StateInit__onInit")

call ExecuteFunc("s__YesNoDialog_YesNoDialog___INITS__onInit")





    call ExecuteFunc("s__InvItem_onInit")
    call ExecuteFunc("s__InvCustomItem_onInit")
    call ExecuteFunc("s__Equipment_onInit")
endfunction




//Struct method generated initializers/callers:

