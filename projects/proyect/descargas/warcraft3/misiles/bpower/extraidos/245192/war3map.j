globals
//globals from DummyCaster:
constant boolean LIBRARY_DummyCaster=true
constant integer UNITS_DUMMY_CASTER= 'n002'
   
    
constant player DummyCaster___PLAYER_OWNER= Player(15)
unit DummyCaster___u
//endglobals from DummyCaster
//globals from IsDestructableTree:
constant boolean LIBRARY_IsDestructableTree=true
constant integer IsDestructableTree___HARVESTER_UNIT_ID= 'hpea'
constant integer IsDestructableTree___HARVEST_ABILITY= 'Ahrl'
constant integer IsDestructableTree___HARVEST_ORDER_ID= 0xD0032
constant player IsDestructableTree___NEUTRAL_PLAYER= Player(PLAYER_NEUTRAL_PASSIVE)
unit IsDestructableTree___harvester= null
//endglobals from IsDestructableTree
//globals from RegisterPlayerUnitEvent:
constant boolean LIBRARY_RegisterPlayerUnitEvent=true
trigger array RegisterPlayerUnitEvent___t
//endglobals from RegisterPlayerUnitEvent
//globals from Table:
constant boolean LIBRARY_Table=true
integer Table___less= 0
integer Table___more= 8190
    //Configure it if you use more than 8190 "key" variables in your map (this will never happen though).
   
hashtable Table___ht= InitHashtable()
constant integer Table___sizeK=7
constant integer Table___listK=8
//endglobals from Table
//globals from TerrainPathability:
constant boolean LIBRARY_TerrainPathability=true
constant real TerrainPathability___MAX_RANGE= 100.
constant integer TerrainPathability___DUMMY_ITEM_ID= 'wolg'
item TerrainPathability___Item= null
rect TerrainPathability___Find= null
item array TerrainPathability___stack
integer TerrainPathability___size= 0
real TerrainPathability_X= 0.
real TerrainPathability_Y= 0.
//endglobals from TerrainPathability
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
//globals from WorldBounds:
constant boolean LIBRARY_WorldBounds=true
//endglobals from WorldBounds
//globals from CameraEQNoise:
constant boolean LIBRARY_CameraEQNoise=true
timer array CameraEQNoise___clock
//endglobals from CameraEQNoise
//globals from IsTerrainWalkable:
constant boolean LIBRARY_IsTerrainWalkable=true
//endglobals from IsTerrainWalkable
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
        
        
constant real Missile___DELAYED_MISSILE_DEATH_ANIMATION_TIME= 2.

        
constant boolean Missile_USE_DESTRUCTABLE_FILTER= true
constant boolean Missile_USE_ITEM_FILTER= true
        // Core constant handle variables of Missile.
constant trigger Missile___CORE= CreateTrigger()
constant timer Missile___TMR= CreateTimer()
constant location Missile___LOC= Location(0., 0.)
constant rect Missile___RECT= Rect(0., 0., 0., 0.)
constant group Missile___GROUP= CreateGroup()
constant hashtable Missile___HASH= InitHashtable()
        // For starting and stopping the timer.
integer Missile___active= 0
        // Arrays for data structure.
integer array Missile___instances
integer array Missile___missileStack
boolexpr array Missile___expression
triggercondition array Missile___condition
integer array Missile___remove
        // Arrays for widgets filter functions in structs.
boolexpr array Missile___destFilter
boolexpr array Missile___itemFilter
        // Rectangle filter functions in Missile.
boolexpr Missile___unitFilter
//endglobals from Missile
//globals from SpellEffectEvent:
constant boolean LIBRARY_SpellEffectEvent=true
//endglobals from SpellEffectEvent
//globals from SpellIndex:
constant boolean LIBRARY_SpellIndex=true
//endglobals from SpellIndex
//globals from BoneSpirit:
constant boolean LIBRARY_BoneSpirit=true
constant integer BoneSpirit___BONE_SPIRIT_ABILITY= 'A008'
        //*  Damage options.
constant attacktype BoneSpirit___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype BoneSpirit___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
constant boolean BoneSpirit___HIT_TARGET_ONLY= false
        //*  Missile options.                                   For true it only hit the unit it's chasing after.
constant real BoneSpirit___SPIRIT_FLY_HEIGHT= 65.
constant real BoneSpirit___UNIT_DETECTION_AOE= 400.
constant real BoneSpirit___COLLISION_SIZE= 32.
constant real BoneSpirit___DETECTION_DELAY= 0.3
constant real BoneSpirit___SPIRIT_SCALE= 0.9
constant string BoneSpirit___SPIRIT_MODEL= "Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdl"
        //*  Buff variables.
constant integer BoneSpirit___BUFF_CAST_ID= 'A009'
constant integer BoneSpirit___ORDER_ID= 852095
        //*  "tempOwner" is always set to the owner of the spirit before "ConsiderUnitFiltered" is called.
player BoneSpirit___tempOwner= null
//endglobals from BoneSpirit
//globals from Chaosflare:
constant boolean LIBRARY_Chaosflare=true
constant integer Chaosflare___CHAOSFLARE_ABILITY= 'A002'
constant real Chaosflare___TIMER_TIMEOUT= 1.0
        //*  Damage options.
constant attacktype Chaosflare___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype Chaosflare___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
        //*  Effects options.
constant string Chaosflare___FLAME_FX= "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
constant real Chaosflare___SPACE_BETWEEN_FLAMES= 75.
constant integer Chaosflare___MAX_FLAMES= 15
constant string Chaosflare___ON_CASTER_FX= "Abilities\\Spells\\Other\\Volcano\\VolcanoDeath.mdl"
constant string Chaosflare___ON_TARGET_FX= "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
constant string Chaosflare___DOT_FX= "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
constant string Chaosflare___DOT_FX_ATTACH_POINT= "origin"
        //*  Buff variables.
constant integer Chaosflare___BUFF_ID= 'B000'
constant integer Chaosflare___BUFF_CAST_ID= 'A000'
constant integer Chaosflare___ORDER_ID= 852075
//endglobals from Chaosflare
//globals from ChaoticBoulder:
constant boolean LIBRARY_ChaoticBoulder=true
constant integer ChaoticBoulder___CHAOTIC_BOULDER_ABILITY= 'A00D'
        //*  Damage options.
constant attacktype ChaoticBoulder___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype ChaoticBoulder___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
        //*  Effect options. 
constant string ChaoticBoulder___ON_EFFECT_FX= "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
constant string ChaoticBoulder___ON_DAMAGE_BIG_FX= "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
//endglobals from ChaoticBoulder
//globals from Fireball:
constant boolean LIBRARY_Fireball=true
constant integer Fireball___FIREBALL_ABILITY= 'A007'
        //*  Damage options.
constant attacktype Fireball___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype Fireball___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
        //*  Constant missile options.
constant real Fireball___FIREBALL_FLY_HEIGHT= 65.
        //*  Effect options.
constant string Fireball___ON_EXPLODE_FX= "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
//endglobals from Fireball
//globals from FistOfThunder:
constant boolean LIBRARY_FistOfThunder=true
constant integer FistOfThunder___FIST_OF_THUNDER_ABILITY= 'A00C'
        //*  Damage options.
constant attacktype FistOfThunder___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype FistOfThunder___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
        //*  Set the lightning end z.
constant real FistOfThunder___MISSILE_END_Z= 175.
        //*  Effect options.
constant string FistOfThunder___LIGHTNING_MODEL= "CLPB"
constant string FistOfThunder___SLAM_CENTER_FX= "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl"
constant real FistOfThunder___SLAM_CENTER_FX_DURATION= 2.
        //*  Concept.
constant boolean FistOfThunder___DESTROY_MISSILE_ON_COLLIDE= true
//endglobals from FistOfThunder
//globals from GuidedArrow:
constant boolean LIBRARY_GuidedArrow=true
constant integer GuidedArrow___GUIDED_ARROW_ABILITY= 'A00E'
        // Damage options.
constant attacktype GuidedArrow___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype GuidedArrow___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
        // Effect options.
constant string GuidedArrow___ON_TARGET_FX= "Abilities\\Spells\\NightElf\\Barkskin\\BarkSkinTarget.mdl"
constant string GuidedArrow___FX_ATTACH_POINT= "overhead"
        // Constant missile options.
constant real GuidedArrow___ARROW_ACTION_DELAY= 0.3
constant real GuidedArrow___UNIT_DETECTION_AOE= 400.
constant real GuidedArrow___ARROW_FLY_RUN_OUT_DISTANCE= 350.
constant real GuidedArrow___ARROW_FLY_HEIGHT= 65.
constant real GuidedArrow___ARROW_TURN_RATE= 8. * bj_DEGTORAD
constant real GuidedArrow___ALLOW_HIT_AFTER= 1.
        // "tempOwner" is always set to the owner of the arrow before "ConsiderUnitFiltered" is called.
player GuidedArrow___tempOwner= null
//endglobals from GuidedArrow
//globals from IceSiege:
constant boolean LIBRARY_IceSiege=true
constant integer IceSiege___ICE_SIEGE_ABILITY= 'A001'
constant real IceSiege___TIMER_TIMEOUT= 1.0
        //*  Damage options.
constant attacktype IceSiege___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype IceSiege___DAMAGE_TYPE= DAMAGE_TYPE_NORMAL
        //*  Effect options.
constant string IceSiege___ON_CASTER_FX= "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl"
constant string IceSiege___FX_ATTACH_POINT= "chest"
        //*  Buff variables.
constant integer IceSiege___BUFF_CAST_ID= 'A004'
constant integer IceSiege___ORDER_ID= 852226
//endglobals from IceSiege
//globals from Leap:
constant boolean LIBRARY_Leap=true
constant integer Leap___LEAP_ABILITY= 'A003'
        //*  Damage type options.
constant attacktype Leap___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype Leap___DAMAGE_TYPE= DAMAGE_TYPE_NORMAL
        //*  Effect options
constant string Leap___ON_LANDING_FX= "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
constant string Leap___WHILE_LEAPING_FX= "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl"
constant string Leap___FX_ATTACH_POINT= "weapon"
        //*  Buff variables.
constant integer Leap___BUFF_CAST_ID= 'A00B'
constant integer Leap___ORDER_ID= 852075
sound Leap___error
//endglobals from Leap
//globals from ReapersScythe:
constant boolean LIBRARY_ReapersScythe=true
constant integer ReapersScythe___REAPERS_SCYTHE_ABILITY= 'A005'
        //*  Damage type options.
constant attacktype ReapersScythe___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype ReapersScythe___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
        //*  Effect options.
constant string ReapersScythe___ON_GROUND_FX= "Doodads\\BlackCitadel\\Props\\RuneArt\\RuneArt1.mdl"
constant string ReapersScythe___GROUND_FX_ATTACH_POINT= "origin"
constant string ReapersScythe___ON_DAMAGE_FX= "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
constant string ReapersScythe___DAMAGE_FX_ATTACH_POINT= "origin"
        //*  Buff variables. You may want to integrate you own stun system.
constant real ReapersScythe___STUN_DURATION= 1.5
constant integer ReapersScythe___BUFF_ID= 'B001'
constant integer ReapersScythe___BUFF_CAST_ID= 'A006'
constant integer ReapersScythe___ORDER_ID= 852095
//endglobals from ReapersScythe
//globals from Whirlwind:
constant boolean LIBRARY_Whirlwind=true
        //*  Only works for immolation based abilities.
constant integer Whirlwind___WHIRLWIND_ABILITY= 'A00A'
constant integer Whirlwind___WHIRLWIND_BUFF= 'B003'
        //*  Do you wish to disable the default attack during whirlwind?
constant boolean Whirlwind___DISABLE_ATTACK= true
        //*  Damage type options.
constant attacktype Whirlwind___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype Whirlwind___DAMAGE_TYPE= DAMAGE_TYPE_NORMAL
        //*  Set how often damage is dealt. Adjust the damage along with the timeout.
constant real Whirlwind___TIMER_TIMEOUT= 0.25
        //*  Reference casters.
integer Whirlwind___table
//endglobals from Whirlwind
    // Generated
trigger gg_trg_OrderIds= null
trigger gg_trg_Table= null
trigger gg_trg_Missile= null
trigger gg_trg_TimerUtils= null
trigger gg_trg_World_Bounds= null
trigger gg_trg_Dummy_Caster= null
trigger gg_trg_SpellEffectEvent= null
trigger gg_trg_RegisterPlayerUnitEvent= null
trigger gg_trg_Spell_Index= null
trigger gg_trg_TerrainPathability= null
trigger gg_trg_CameraEQNoise= null
trigger gg_trg_IsDestructableTree= null
trigger gg_trg_Important_Information= null
trigger gg_trg_Fireball= null
trigger gg_trg_Ice_Siege= null
trigger gg_trg_Chaosflare= null
trigger gg_trg_Choatic_Boulder= null
trigger gg_trg_Bone_Spirit= null
trigger gg_trg_Reapers_Scythe= null
trigger gg_trg_Leap= null
trigger gg_trg_Whirlwind= null
trigger gg_trg_Fist_of_Thunder= null
trigger gg_trg_This_Map_only= null
trigger gg_trg_Guided_Arrow= null
real map___X= - 1500
real map___Y= - 2280
real map___X0= 1177
real map___Y0= 1370

trigger l__library_init

//JASSHelper struct globals:
constant integer si__DummyCaster=1
constant integer si__IsDestructableTree___I=2
constant integer si__Table___dex=3
constant integer si__Table___handles=4
constant integer si__Table___agents=5
constant integer si__Table___reals=6
constant integer si__Table___booleans=7
constant integer si__Table___strings=8
constant integer si__Table___players=9
constant integer si__Table___widgets=10
constant integer si__Table___destructables=11
constant integer si__Table___items=12
constant integer si__Table___units=13
constant integer si__Table___abilitys=14
constant integer si__Table___timers=15
constant integer si__Table___triggers=16
constant integer si__Table___triggerconditions=17
constant integer si__Table___triggeractions=18
constant integer si__Table___events=19
constant integer si__Table___forces=20
constant integer si__Table___groups=21
constant integer si__Table___locations=22
constant integer si__Table___rects=23
constant integer si__Table___boolexprs=24
constant integer si__Table___sounds=25
constant integer si__Table___effects=26
constant integer si__Table___unitpools=27
constant integer si__Table___itempools=28
constant integer si__Table___quests=29
constant integer si__Table___questitems=30
constant integer si__Table___defeatconditions=31
constant integer si__Table___timerdialogs=32
constant integer si__Table___leaderboards=33
constant integer si__Table___multiboards=34
constant integer si__Table___multiboarditems=35
constant integer si__Table___trackables=36
constant integer si__Table___dialogs=37
constant integer si__Table___buttons=38
constant integer si__Table___texttags=39
constant integer si__Table___lightnings=40
constant integer si__Table___images=41
constant integer si__Table___ubersplats=42
constant integer si__Table___regions=43
constant integer si__Table___fogstates=44
constant integer si__Table___fogmodifiers=45
constant integer si__Table___hashtables=46
constant integer si__Table=47
constant integer si__TableArray=48
integer s__TableArray_tempTable
integer s__TableArray_tempEnd
constant integer si__WorldBounds=49
integer s__WorldBounds_maxX
integer s__WorldBounds_maxY
integer s__WorldBounds_minX
integer s__WorldBounds_minY
integer s__WorldBounds_centerX
integer s__WorldBounds_centerY
rect s__WorldBounds_world
region s__WorldBounds_worldRegion
constant integer si__Missile___RecycleBin=50
constant timer s__Missile___RecycleBin_t= CreateTimer()
integer s__Missile___RecycleBin_max= 0
unit array s__Missile___RecycleBin_dummy
real array s__Missile___RecycleBin_time
constant integer si__MissilePosition=51
integer array s__MissilePosition_recycler
integer s__MissilePosition_alloc= 0
real array s__MissilePosition_x
real array s__MissilePosition_y
real array s__MissilePosition_z
real array s__MissilePosition_angle
real array s__MissilePosition_distance
real array s__MissilePosition_slope
real array s__MissilePosition_alpha
integer array s__MissilePosition_ref
constant integer si__Missile=52
integer s__Missile_Missile___MissileStructure__collectionCount= 0
integer s__Missile_Missile___MissileStructure__nodeCount= 0
integer array s__Missile_Missile___MissileStructure___list
integer array s__Missile_Missile___MissileStructure___next
integer array s__Missile_Missile___MissileStructure___prev
integer array s__Missile_Missile___MissileStructure___first
integer array s__Missile_Missile___MissileStructure___last
constant string s__Missile_ORIGIN= "origin"
constant real s__Missile_HIT_BOX= ( 2. / 3. )
boolean array s__Missile_launched
real array s__Missile_xPrivate
real array s__Missile_yPrivate
real array s__Missile_xPrev
real array s__Missile_yPrev
boolean array s__Missile_allocated
unit array s__Missile_dummy
integer array s__Missile_origin
integer array s__Missile_impact
real array s__Missile_terrainZ
real array s__Missile_x
real array s__Missile_y
real array s__Missile_z
real array s__Missile_angle
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
real array s__Missile_collisionDebug
real array s__Missile_collisionZDebug
effect array s__Missile_sfx
string array s__Missile_path
real array s__Missile_open
real array s__Missile_height
real array s__Missile_scaleValue
boolean array s__Missile_wantDestroy
integer array s__Missile_stackSize
integer s__Missile_temp= 0
boolean s__Missile_circle= true
constant integer si__SpellEffectEvent___S=53
integer s__SpellEffectEvent___S_tb
constant integer si__SpellIndex=54
integer si__SpellIndex_F=0
integer si__SpellIndex_I=0
integer array si__SpellIndex_V
constant group s__SpellIndex_GLOBAL_GROUP= bj_lastCreatedGroup
unit array s__SpellIndex_source
unit array s__SpellIndex_target
player array s__SpellIndex_user
effect array s__SpellIndex_fx
ubersplat array s__SpellIndex_splat
lightning array s__SpellIndex_flash
timer array s__SpellIndex_clock
real array s__SpellIndex_damage
real array s__SpellIndex_collision
real array s__SpellIndex_time
integer array s__SpellIndex_count
integer array s__SpellIndex_level
integer array s__SpellIndex_phase
constant integer si__BoneSpirit___BoneSpirit=55
boolexpr s__BoneSpirit___BoneSpirit_filter
real array s__BoneSpirit___BoneSpirit_delay
constant integer si__ChaoticBoulder___ChaoticBoulder=56
constant integer si__Fireball___Fireball=57
constant integer si__FistOfThunder___FistOfThunder=58
constant integer si__GuidedArrow___GuidedArrow=59
boolexpr s__GuidedArrow___GuidedArrow_filter
constant integer si__Leap___Leap=60
constant integer si__map___preload=61
constant integer si__map___xxx=62
integer array s__TimerUtils___data
timer array s__TimerUtils___tT
trigger st__ChaoticBoulder___ChaoticBoulder_launch
trigger array st___prototype2
integer f__arg_integer1

endglobals
    native UnitAlive takes unit id returns boolean


//Generated method caller for ChaoticBoulder___ChaoticBoulder.launch
function sc__ChaoticBoulder___ChaoticBoulder_launch takes integer missile returns nothing
    set f__arg_integer1=missile
    call TriggerEvaluate(st__ChaoticBoulder___ChaoticBoulder_launch)
endfunction

//Generated allocator of SpellIndex
function s__SpellIndex__allocate takes nothing returns integer
 local integer this=si__SpellIndex_F
    if (this!=0) then
        set si__SpellIndex_F=si__SpellIndex_V[this]
    else
        set si__SpellIndex_I=si__SpellIndex_I+1
        set this=si__SpellIndex_I
    endif
    if (this>8190) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Unable to allocate id for an object of type: SpellIndex")
        return 0
    endif

    set si__SpellIndex_V[this]=-1
 return this
endfunction

//Generated destructor of SpellIndex
function s__SpellIndex_deallocate takes integer this returns nothing
    if this==null then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Attempt to destroy a null struct of type: SpellIndex")
        return
    elseif (si__SpellIndex_V[this]!=-1) then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Double free of type: SpellIndex")
        return
    endif
    set si__SpellIndex_V[this]=si__SpellIndex_F
    set si__SpellIndex_F=this
endfunction
function sc___prototype2_execute takes integer i returns nothing

    call TriggerExecute(st___prototype2[i])
endfunction
function sc___prototype2_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype2[i])

endfunction

//library DummyCaster:

//Implemented from module DummyCaster___N:
        function s__DummyCaster_DummyCaster___N__onInit takes nothing returns nothing
//#             static if LIBRARY_UnitIndexer then
//#                 set UnitIndexer.enabled=false
//#                 set DummyCaster___u=CreateUnit(DummyCaster___PLAYER_OWNER,UNITS_DUMMY_CASTER,0,0,0)
//#                 set UnitIndexer.enabled=true
//#             else
                    set DummyCaster___u=CreateUnit(DummyCaster___PLAYER_OWNER, UNITS_DUMMY_CASTER, 0, 0, 0)
//#             endif
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

//library DummyCaster ends
//library IsDestructableTree:
    function IsDestructableTree takes destructable d returns boolean
        //*  851973 is the order id for stunned, it will interrupt the preceding harvest order.
        return ( IssueTargetOrderById(IsDestructableTree___harvester, IsDestructableTree___HARVEST_ORDER_ID, d) ) and ( IssueImmediateOrderById(IsDestructableTree___harvester, 851973) )
    endfunction
    function IsDestructableDead takes destructable d returns boolean
        return ( GetWidgetLife(d) <= 0.405 )
    endfunction
    function IsDestructableAlive takes destructable d returns boolean
        return ( GetWidgetLife(d) > .405 )
    endfunction
    function IsTreeAlive takes destructable tree returns boolean
        return IsDestructableAlive(tree) and IsDestructableTree(tree)
    endfunction
    function KillTree takes destructable tree returns boolean
        if ( IsTreeAlive(tree) ) then
            call KillDestructable(tree)
            return true
        endif
        return false
    endfunction
    function IsDestructableTree___Init takes nothing returns nothing
//#         static if LIBRARY_UnitIndexer then//*  You may adapt this to your own indexer.
//#             set UnitIndexer.enabled = false
//#         endif
        set IsDestructableTree___harvester=CreateUnit(IsDestructableTree___NEUTRAL_PLAYER, IsDestructableTree___HARVESTER_UNIT_ID, 0, 0, 0)
//#         static if LIBRARY_UnitIndexer then
//#             set UnitIndexer.enabled = true
//#         endif
        call UnitAddAbility(IsDestructableTree___harvester, IsDestructableTree___HARVEST_ABILITY)
        call UnitAddAbility(IsDestructableTree___harvester, 'Aloc')
        call ShowUnit(IsDestructableTree___harvester, false)
    endfunction
    //*  Seriously?
//Implemented from module IsDestructableTree___Inits:
        function s__IsDestructableTree___I_IsDestructableTree___Inits__onInit takes nothing returns nothing
            call IsDestructableTree___Init()
        endfunction
    

//library IsDestructableTree ends
//library RegisterPlayerUnitEvent:
   
    function RegisterPlayerUnitEvent takes playerunitevent p,code c returns nothing
        local integer i= GetHandleId(p)
        local integer k= 15
        if RegisterPlayerUnitEvent___t[i] == null then
            set RegisterPlayerUnitEvent___t[i]=CreateTrigger()
            loop
                call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent___t[i], Player(k), p, null)
                exitwhen k == 0
                set k=k - 1
            endloop
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent___t[i], Filter(c))
    endfunction
   
    function RegisterPlayerUnitEventForPlayer takes playerunitevent p,code c,player pl returns nothing
        local integer i= 16 * GetHandleId(p) + GetPlayerId(pl)
        if RegisterPlayerUnitEvent___t[i] == null then
            set RegisterPlayerUnitEvent___t[i]=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent___t[i], pl, p, null)
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent___t[i], Filter(c))
    endfunction
   
    function GetPlayerUnitEventTrigger takes playerunitevent p returns trigger
        return RegisterPlayerUnitEvent___t[GetHandleId(p)]
    endfunction

//library RegisterPlayerUnitEvent ends
//library Table:
   
   
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
        local integer this= s__Table__getindex(s__Table___dex__get_list(),0)
       
        if this == 0 then
            set this=Table___more + 1
            set Table___more=this
        else
            call s__Table__setindex(s__Table___dex__get_list(),0, s__Table__getindex(s__Table___dex__get_list(),this))
            call s__Table_remove(s__Table___dex__get_list(),this) //Clear hashed memory
        endif
       
         call s__Table__setindex(s__Table___dex__get_list(),this, - 1)
        return this
    endfunction
   
    // Removes all data from a Table instance and recycles its index.
    //
    //     call tb.destroy()
    //
    function s__Table_destroy takes integer this returns nothing
         if s__Table__getindex(s__Table___dex__get_list(),this) != - 1 then
             call BJDebugMsg("Table Error: Tried to double-free instance: " + I2S(this))
             return
         endif
       
        call s__Table_flush(this)
       
        call s__Table__setindex(s__Table___dex__get_list(),this, s__Table__getindex(s__Table___dex__get_list(),0))
        call s__Table__setindex(s__Table___dex__get_list(),0, this)
    endfunction
   
//ignored textmacro command: TABLE_BC_METHODS()
   
//ignored textmacro command: TABLE_BC_STRUCTS()
   
   
    //Returns a new TableArray to do your bidding. Simply use:
    //
    //    local TableArray ta = TableArray[array_size]
    //
    function s__TableArray__staticgetindex takes integer array_size returns integer
        local integer tb= s__Table__getindex(s__Table___dex__get_size(),array_size)
        local integer this= s__Table__getindex(tb,0)
       
         if array_size <= 0 then
             call BJDebugMsg("TypeError: Invalid specified TableArray size: " + I2S(array_size))
             return 0
         endif
       
        if this == 0 then
            set this=Table___less - array_size
            set Table___less=this
        else
            call s__Table__setindex(tb,0, s__Table__getindex(tb,this)) //Set the last destroyed to the last-last destroyed
            call s__Table_remove(tb,this) //Clear hashed memory
        endif
       
        call s__Table__setindex(s__Table___dex__get_size(),this, array_size) //This remembers the array size
        return this
    endfunction
   
    //Returns the size of the TableArray
    function s__TableArray__get_size takes integer this returns integer
        return s__Table__getindex(s__Table___dex__get_size(),this)
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
//#         static if true then
                local integer i= s__TableArray__get_size(this)
                if i == 0 then
                    call BJDebugMsg("IndexError: Tried to get key from invalid TableArray instance: " + I2S(this))
                    return 0
                elseif key < 0 or key >= i then
                    call BJDebugMsg("IndexError: Tried to get key [" + I2S(key) + "] from outside TableArray bounds: " + I2S(i))
                    return 0
                endif
//#         endif
        return this + key
    endfunction
   
    //Destroys a TableArray without flushing it; I assume you call .flush()
    //if you want it flushed too. This is a public method so that you don't
    //have to loop through all TableArray indices to flush them if you don't
    //need to (ie. if you were flushing all child-keys as you used them).
    //
    function s__TableArray_destroy takes integer this returns nothing
        local integer tb= s__Table__getindex(s__Table___dex__get_size(),s__TableArray__get_size(this))
       
         if s__TableArray__get_size(this) == 0 then
             call BJDebugMsg("TypeError: Tried to destroy an invalid TableArray: " + I2S(this))
             return
         endif
       
        if tb == 0 then
            //Create a Table to index recycled instances with their array size
            set tb=s__Table_create()
            call s__Table__setindex(s__Table___dex__get_size(),s__TableArray__get_size(this), tb)
        endif
       
        call s__Table_remove(s__Table___dex__get_size(),this) //Clear the array size from hash memory
       
        call s__Table__setindex(tb,this, s__Table__getindex(tb,0))
        call s__Table__setindex(tb,0, this)
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
            call s__Table_flush(tb)
            set tb=tb + 1
            exitwhen tb == end
        endloop
    endfunction
   
    //Flushes the TableArray and also destroys it. Doesn't get any more
    //similar to the FlushParentHashtable native than this.
    //
    function s__TableArray_flush takes integer this returns nothing
         if s__TableArray__get_size(this) == 0 then
             call BJDebugMsg("TypeError: Tried to flush an invalid TableArray instance: " + I2S(this))
             return
         endif
        set s__TableArray_tempTable=this
        set s__TableArray_tempEnd=this + s__TableArray__get_size(this)
        call ForForce(bj_FORCE_PLAYER[0], function s__TableArray_clean)
        call s__TableArray_destroy(this)
    endfunction
   
   

//library Table ends
//library TerrainPathability:
//******************************************************************************
//* BY: Rising_Dusk, edited by BPower
//* 
//* This script can be used to detect the type of pathing at a specific point.
//* It is valuable to do it this way because the IsTerrainPathable is very
//* counterintuitive and returns in odd ways and aren't always as you would
//* expect. This library, however, facilitates detecting those things reliably
//* and easily.
//* 
//******************************************************************************
//* 
//*    > function IsTerrainDeepWater    takes real x, real y returns boolean
//*    > function IsTerrainShallowWater takes real x, real y returns boolean
//*    > function IsTerrainLand         takes real x, real y returns boolean
//*    > function IsTerrainPlatform     takes real x, real y returns boolean
//*    > function IsTerrainWalkable     takes real x, real y returns boolean
//* 
//* These functions return true if the given point is of the type specified
//* in the function's name and false if it is not. For the IsTerrainWalkable
//* function, the MAX_RANGE constant below is the maximum deviation range from
//* the supplied coordinates that will still return true.
//* 
//* The IsTerrainPlatform works for any preplaced walkable destructable. It will
//* return true over bridges, destructable ramps, elevators, and invisible
//* platforms. Walkable destructables created at runtime do not create the same
//* pathing hole as preplaced ones do, so this will return false for them. All
//* other functions except IsTerrainWalkable return false for platforms, because
//* the platform itself erases their pathing when the map is saved.
//* 
//* After calling IsTerrainWalkable(x, y), the following two global variables
//* gain meaning. They return the X and Y coordinates of the nearest walkable
//* point to the specified coordinates. These will only deviate from the
//* IsTerrainWalkable function arguments if the function returned false.
//* 
//* Variables that can be used from the library:
//*     [real]    TerrainPathability_X
//*     [real]    TerrainPathability_Y
//* 


function IsTerrainDeepWater takes real x,real y returns boolean
    return not IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY) and IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
endfunction
function IsTerrainShallowWater takes real x,real y returns boolean
    return not IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY) and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) and IsTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY)
endfunction
function IsTerrainLand takes real x,real y returns boolean
    return IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY)
endfunction
function IsTerrainPlatform takes real x,real y returns boolean
    return not IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY) and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) and not IsTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY)
endfunction

function TerrainPathability___HideItem takes nothing returns nothing
    if IsItemVisible(GetEnumItem()) then
        set TerrainPathability___stack[TerrainPathability___size]=GetEnumItem()
        call SetItemVisible(TerrainPathability___stack[TerrainPathability___size], false)
        set TerrainPathability___size=TerrainPathability___size + 1
    endif
endfunction
function IsTerrainWalkable takes real x,real y returns boolean
    //Hide any items in the area to avoid conflicts with our item
    call MoveRectTo(TerrainPathability___Find, x, y)
    call EnumItemsInRect(TerrainPathability___Find, null, function TerrainPathability___HideItem)
    //Try to move the test item and get its coords
    call SetItemPosition(TerrainPathability___Item, x, y) //Unhides the item
    set TerrainPathability_X=GetItemX(TerrainPathability___Item)
    set TerrainPathability_Y=GetItemY(TerrainPathability___Item)
    call SetItemVisible(TerrainPathability___Item, false) //Hide it again
    //Unhide any items hidden at the start
    loop
        exitwhen ( 0 == TerrainPathability___size )
        set TerrainPathability___size=TerrainPathability___size - 1
        call SetItemVisible(TerrainPathability___stack[TerrainPathability___size], true)
        set TerrainPathability___stack[TerrainPathability___size]=null
    endloop
    //Return walkability
    return ( TerrainPathability_X - x ) * ( TerrainPathability_X - x ) + ( TerrainPathability_Y - y ) * ( TerrainPathability_Y - y ) <= TerrainPathability___MAX_RANGE and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
endfunction

function TerrainPathability___Init takes nothing returns nothing
    set TerrainPathability___Find=Rect(0., 0., 128., 128.)
    set TerrainPathability___Item=CreateItem(TerrainPathability___DUMMY_ITEM_ID, 0, 0)
    call SetItemVisible(TerrainPathability___Item, false)
endfunction

//library TerrainPathability ends
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
//#         static if TimerUtils___USE_HASH_TABLE  then
                // new blue
                call SaveInteger(TimerUtils___ht, 0, GetHandleId(t), value)
                
//#         elseif (TimerUtils___USE_FLEXIBLE_OFFSET) then
//#             // orange
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils___VOFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             set TimerUtils___data[GetHandleId(t)-TimerUtils___VOFFSET]=value
//#         else
//#             // new red
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils___OFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             set TimerUtils___data[GetHandleId(t)-TimerUtils___OFFSET]=value
//#         endif        
    endfunction

    function GetTimerData takes timer t returns integer
//#         static if TimerUtils___USE_HASH_TABLE  then
                // new blue
                return LoadInteger(TimerUtils___ht, 0, GetHandleId(t))
                
//#         elseif (TimerUtils___USE_FLEXIBLE_OFFSET) then
//#             // orange
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils___VOFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             return TimerUtils___data[GetHandleId(t)-TimerUtils___VOFFSET]
//#         else
//#             // new red
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils___OFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             return TimerUtils___data[GetHandleId(t)-TimerUtils___OFFSET]
//#         endif        
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
                call sc___prototype2_evaluate(1)
                set TimerUtils___tN=TimerUtils___tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
                 call BJDebugMsg("NewTimer: Warning, Exceeding TimerUtils_QUANTITY, make sure all timers are getting recycled correctly")
                set s__TimerUtils___tT[0]= CreateTimer()
//#                 static if  not TimerUtils___USE_HASH_TABLE  then
//#                      call BJDebugMsg("In case of errors, please increase it accordingly, or set TimerUtils_USE_HASH_TABLE to true")
//#                     static if  TimerUtils___USE_FLEXIBLE_OFFSET  then
//#                         if (GetHandleId(TimerUtils___tT[0])-TimerUtils___VOFFSET<0) or (GetHandleId(TimerUtils___tT[0])-TimerUtils___VOFFSET>=TimerUtils___ARRAY_SIZE) then
//#                             //all right, couldn't fix it
//#                             call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
//#                             return null
//#                         endif
//#                     else
//#                         if (GetHandleId(TimerUtils___tT[0])-TimerUtils___OFFSET<0) or (GetHandleId(TimerUtils___tT[0])-TimerUtils___OFFSET>=TimerUtils___ARRAY_SIZE) then
//#                             //all right, couldn't fix it
//#                             call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
//#                             return null
//#                         endif
//#                     endif
//#                 endif
            endif
        else
            set TimerUtils___tN=TimerUtils___tN - 1
        endif
        call SetTimerData(s__TimerUtils___tT[TimerUtils___tN] , value)
     return s__TimerUtils___tT[TimerUtils___tN]
    endfunction
    
    function NewTimer takes nothing returns timer
        return NewTimerEx(0)
    endfunction


    //==========================================================================================
    function ReleaseTimer takes timer t returns nothing
        if ( t == null ) then
             call BJDebugMsg("Warning: attempt to release a null timer")
            return
        endif
        if ( TimerUtils___tN == TimerUtils___ARRAY_SIZE ) then
             call BJDebugMsg("Warning: Timer stack is full, destroying timer!!")

            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( GetTimerData(t) == TimerUtils___HELD ) then
                 call BJDebugMsg("Warning: ReleaseTimer: Double free!")
                return
            endif
            call SetTimerData(t , TimerUtils___HELD)
            set s__TimerUtils___tT[TimerUtils___tN]= t
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
     
//#         static if  TimerUtils___USE_HASH_TABLE   then
                set TimerUtils___ht=InitHashtable()
                loop
                    exitwhen ( i == TimerUtils___QUANTITY )
                    set s__TimerUtils___tT[i]= CreateTimer()
                    call SetTimerData(s__TimerUtils___tT[i] , TimerUtils___HELD)
                    set i=i + 1
                endloop
                set TimerUtils___tN=TimerUtils___QUANTITY
//#         else
//#             loop
//#                 set i=0
//#                 loop
//#                     exitwhen (i==TimerUtils___QUANTITY)
//#                     set TimerUtils___tT[i] = CreateTimer()
//#                     if(i==0) then
//#                         set TimerUtils___VOFFSET = GetHandleId(TimerUtils___tT[i])
//#                         static if TimerUtils___USE_FLEXIBLE_OFFSET  then
//#                             set o=TimerUtils___VOFFSET
//#                         else
//#                             set o=TimerUtils___OFFSET
//#                         endif
//#                     endif
//#                     if (GetHandleId(TimerUtils___tT[i])-o>=TimerUtils___ARRAY_SIZE) then
//#                         exitwhen true
//#                     endif
//#                     if (GetHandleId(TimerUtils___tT[i])-o>=0)  then
//#                         set i=i+1
//#                     endif
//#                 endloop
//#                 set TimerUtils___tN = i
//#                 exitwhen(TimerUtils___tN == TimerUtils___QUANTITY)
//#                 set oops = true
//#                 exitwhen not TimerUtils___USE_FLEXIBLE_OFFSET
//#                  call BJDebugMsg("TimerUtils_init: Failed a initialization attempt, will try again")               
//#             endloop
//#             
//#             if(oops) then
//#                 static if   TimerUtils___USE_FLEXIBLE_OFFSET  then
//#                      call BJDebugMsg("The problem has been fixed.")
//#                     //If this message doesn't appear then there is so much
//#                     //handle id fragmentation that it was impossible to preload
//#                     //so many timers and the thread crashed! Therefore this
//#                     //debug message is useful.
//#                 elseif true  then
//#                     call BJDebugMsg("There were problems and the new timer limit is "+I2S(i))
//#                     call BJDebugMsg("This is a rare ocurrence, if the timer limit is too low:")
//#                     call BJDebugMsg("a) Change USE_FLEXIBLE_OFFSET to true (reduces performance a little)")
//#                     call BJDebugMsg("b) or try changing OFFSET to "+I2S(TimerUtils___VOFFSET) )
//#                 endif
//#             endif
//#         endif

    endfunction


//library TimerUtils ends
//library WorldBounds:
   
//Implemented from module WorldBounds___WorldBoundInit:
        function s__WorldBounds_WorldBounds___WorldBoundInit__onInit takes nothing returns nothing
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

//library WorldBounds ends
//library CameraEQNoise:

    function StopCameraEQNoise takes player whichPlayer returns nothing
        local integer id= GetPlayerId(whichPlayer)
        if ( CameraEQNoise___clock[id] != null ) then
            call ReleaseTimer(CameraEQNoise___clock[id])
            set CameraEQNoise___clock[id]=null
        endif
        if ( GetLocalPlayer() == whichPlayer ) then
            call CameraSetSourceNoise(0, 0)
            call CameraSetTargetNoise(0, 0)
        endif
    endfunction
    
    function CameraEQNoise___TimerExpire takes nothing returns nothing
        call StopCameraEQNoise(Player(GetTimerData(GetExpiredTimer())))
    endfunction
    
    function CameraSetEQNoise takes player whichPlayer,real magnitude,real duration returns nothing
        local real richter= magnitude
        local integer id= GetPlayerId(whichPlayer)
        local real pow
        if ( richter > 5. ) then
            set richter=5.
        elseif ( richter < 2. ) then
            set richter=2.
        endif
        call StopCameraEQNoise(whichPlayer)
        set CameraEQNoise___clock[id]=NewTimerEx(id)
        call TimerStart(CameraEQNoise___clock[id], duration, false, function CameraEQNoise___TimerExpire)
        set pow=magnitude * Pow(10, richter)
        if ( GetLocalPlayer() == whichPlayer ) then
            call CameraSetTargetNoiseEx(magnitude * 2., pow, true)
            call CameraSetSourceNoiseEx(magnitude * 2., pow, true)
        endif
    endfunction


//library CameraEQNoise ends
//library IsTerrainWalkable:

//library IsTerrainWalkable ends
//library Missile:

    
    function GetUnitBodySize takes unit whichUnit returns real
        return 100. // Other example: return LoadReal(hash, GetHandleId(whichUnit), KEY_UNIT_BODY_SIZE)
    endfunction

    
    function GetDestructableHeight takes destructable d returns real
        return GetDestructableOccluderHeight(d) // Other example: return 100.
    endfunction

    
    function GetItemHeight takes item i returns real
        return 20.
    endfunction
    
    
    function Missile___ToogleUnitIndexer takes boolean enable returns boolean
        local boolean prev= true
        // set UnitIndexer.enabled = enable
        return prev
    endfunction
    


// Hello and welcome to Missile.
// I wrote a guideline for every piece of code inside Missile, so you 
// can easily understand how the code gets compiled and evaluated.
//
// Let's go!
        
    
    function Missile_GetLocZ takes real x,real y returns real
        call MoveLocation(Missile___LOC, x, y)
        return GetLocationZ(Missile___LOC)
    endfunction
    
    // For WRITE_DELAYED_MISSILE_RECYCLING = true Missile will hold back dummy for DELAYED_MISSILE_DEATH_ANIMATION_TIME,
    // until the are recylced. ( placed in a static if )
    //
//textmacro instance: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
//#     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
    
         
                function s__Missile___RecycleBin_onPeriodic takes nothing returns nothing
                    local integer dex= 0
                    loop
                        exitwhen dex == s__Missile___RecycleBin_max
                        set s__Missile___RecycleBin_time[dex]=s__Missile___RecycleBin_time[dex] - 1
                        if ( 0 >= s__Missile___RecycleBin_time[dex] ) then
                        
//#                         static if LIBRARY_MissileRecycler then
//#                             call RecycleMissile(Missile___RecycleBin.dummy[dex])
//#                     
//#                         elseif Dummy.create.exists and LIBRARY_Dummy then
//#                             call Dummy[Missile___RecycleBin.dummy[dex]].destroy()
//#                         
//#                         elseif LIBRARY_xedummy and xedummy.release.exists then
//#                             call xedummy.release(Missile___RecycleBin.dummy[dex])
//#                     
//#                         else
                                call RemoveUnit(s__Missile___RecycleBin_dummy[dex])
//#                         endif
                        
                            set s__Missile___RecycleBin_dummy[dex]=null
                            set s__Missile___RecycleBin_max=s__Missile___RecycleBin_max - 1
                            set s__Missile___RecycleBin_dummy[dex]=s__Missile___RecycleBin_dummy[s__Missile___RecycleBin_max]
                            set s__Missile___RecycleBin_time[dex]=s__Missile___RecycleBin_time[s__Missile___RecycleBin_max]
                            set s__Missile___RecycleBin_dummy[s__Missile___RecycleBin_max]=null
                            set dex=dex - 1
                        
                            if ( 0 == s__Missile___RecycleBin_max ) then
                                call PauseTimer(s__Missile___RecycleBin_t)
                            endif
                        
                        endif
                        set dex=dex + 1
                    endloop
                endfunction
        
                function s__Missile___RecycleBin_recycle takes unit toRecycle returns nothing
                    if ( 0 == s__Missile___RecycleBin_max ) then
                        call TimerStart(s__Missile___RecycleBin_t, 1., true, function s__Missile___RecycleBin_onPeriodic)
                    endif
                    set s__Missile___RecycleBin_dummy[s__Missile___RecycleBin_max]=toRecycle
                    set s__Missile___RecycleBin_time[s__Missile___RecycleBin_max]=Missile___DELAYED_MISSILE_DEATH_ANIMATION_TIME + TimerGetRemaining(s__Missile___RecycleBin_t)
                    set s__Missile___RecycleBin_max=s__Missile___RecycleBin_max + 1
                endfunction
        
//#     endif
//end of: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
    
    // The code of this macro boxes a missiles position and does the required trigonometry.
    //
//textmacro instance: WRITE_MISSILE_POSITION_CODE()
            
            // Readonly members you can access.
            
            // Creates an origin - impact link.
            
            function s__MissilePosition_math takes integer a,integer b returns boolean
                // Set a.
                set s__MissilePosition_angle[a]=Atan2(s__MissilePosition_y[b] - s__MissilePosition_y[a], s__MissilePosition_x[b] - s__MissilePosition_x[a])
                set s__MissilePosition_distance[a]=SquareRoot(( s__MissilePosition_x[b] - s__MissilePosition_x[a] ) * ( s__MissilePosition_x[b] - s__MissilePosition_x[a] ) + ( s__MissilePosition_y[b] - s__MissilePosition_y[a] ) * ( s__MissilePosition_y[b] - s__MissilePosition_y[a] ))
                if ( s__MissilePosition_distance[a] != 0 ) then
                    set s__MissilePosition_slope[a]=( s__MissilePosition_z[b] - s__MissilePosition_z[a] ) / s__MissilePosition_distance[a]
                else // For distance == 0 the thread crashes! 
                    set s__MissilePosition_x[a]=s__MissilePosition_x[a] + .0001
                    return false // Runs the thread again.
                endif
                set s__MissilePosition_alpha[a]=Atan(s__MissilePosition_slope[a]) * bj_RADTODEG
                // Set b.
                set s__MissilePosition_angle[b]=s__MissilePosition_angle[a] + bj_PI
                set s__MissilePosition_distance[b]=s__MissilePosition_distance[a]
                set s__MissilePosition_slope[b]=- s__MissilePosition_slope[a]
                set s__MissilePosition_alpha[b]=- s__MissilePosition_alpha[a]
                return true
            endfunction
            
            function s__MissilePosition_link takes integer a,integer b returns nothing
                set s__MissilePosition_ref[a]=b
                set s__MissilePosition_ref[b]=a
                loop
                    exitwhen s__MissilePosition_math(a , b)
                endloop
            endfunction
            
            function s__MissilePosition_move takes integer this,real toX,real toY,real toZ returns nothing
                set s__MissilePosition_x[this]=toX
                set s__MissilePosition_y[this]=toY
                set s__MissilePosition_z[this]=toZ + Missile_GetLocZ(toX , toY)
                if ( s__MissilePosition_ref[this] != this ) then
                    loop
                        exitwhen s__MissilePosition_math(this , s__MissilePosition_ref[this])
                    endloop
                endif
            endfunction
    
            function s__MissilePosition_destroy takes integer this returns nothing
                set s__MissilePosition_recycler[this]=s__MissilePosition_recycler[0]
                set s__MissilePosition_recycler[0]=this
            endfunction
    
            function s__MissilePosition_create takes real x,real y,real z returns integer
                local integer this= s__MissilePosition_recycler[0]
                 if ( 0 == this ) then
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
    // allocateCollection(), allocateNode(), insertEnd(node) and remove()
    //
//Implemented from module Missile___MissileStructure:
        
//#         static if LIBRARY_ErrorMessage then
//#              private boolean Missile___MissileStructure__isNode
//#              private boolean Missile___MissileStructure__isCollection
//#         endif
        
        function s__Missile__get_list takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "list", "Missile", this, "Attempted To Read Null Node.")
//#                  call ThrowError(not Missile___MissileStructure__isNode,   "MissileStructure", "list", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile___MissileStructure___list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "next", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile___MissileStructure__isNode,   "MissileStructure", "next", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile___MissileStructure___next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "prev", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile___MissileStructure__isNode,   "MissileStructure", "prev", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile___MissileStructure___prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "MissileStructure", "first", "Missile", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Missile___MissileStructure__isCollection, "MissileStructure", "first", "Missile", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile___MissileStructure___first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "MissileStructure", "last", "Missile", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Missile___MissileStructure__isCollection, "MissileStructure", "last", "Missile", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile___MissileStructure___last[this]
        endfunction
        
        function s__Missile_allocateCollection takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure___first[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Missile___MissileStructure__collectionCount == 8191, "MissileStructure", "allocateCollection", "Missile", 0, "Overflow.")
//#                 endif
                
                set this=s__Missile_Missile___MissileStructure__collectionCount + 1
                set s__Missile_Missile___MissileStructure__collectionCount=this
            else
                set s__Missile_Missile___MissileStructure___first[(0)]=s__Missile_Missile___MissileStructure___first[this]
            endif
            
//#             static if LIBRARY_ErrorMessage then
//#                  set Missile___MissileStructure__isCollection = true
//#             endif
            
            set s__Missile_Missile___MissileStructure___first[this]=0
            
            return this
        endfunction
        
        function s__Missile_allocateNode takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure___next[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Missile___MissileStructure__nodeCount == 8191, "MissileStructure", "allocateNode", "Missile", 0, "Overflow.")
//#                 endif
                
                set this=s__Missile_Missile___MissileStructure__nodeCount + 1
                set s__Missile_Missile___MissileStructure__nodeCount=this
            else
                set s__Missile_Missile___MissileStructure___next[(0)]=s__Missile_Missile___MissileStructure___next[this]
            endif
            
            return this
        endfunction
        
        function s__Missile_insertEnd takes integer this,integer node returns integer
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "MissileStructure", "enqueue", "Missile", this, "Attempted To Enqueue On To Null List.")
//#                  call ThrowError(not Missile___MissileStructure__isCollection, "MissileStructure", "enqueue", "Missile", this, "Attempted To Enqueue On To Invalid List.")
//#                  set node.Missile___MissileStructure__isNode = true
//#             endif
            
            
            set s__Missile_Missile___MissileStructure___list[node]=this
        
            if ( s__Missile_Missile___MissileStructure___first[this] == 0 ) then
                set s__Missile_Missile___MissileStructure___first[this]=node
                set s__Missile_Missile___MissileStructure___last[this]=node
                set s__Missile_Missile___MissileStructure___prev[node]=0
            else
                set s__Missile_Missile___MissileStructure___next[s__Missile_Missile___MissileStructure___last[this]]=node
                set s__Missile_Missile___MissileStructure___prev[node]=s__Missile_Missile___MissileStructure___last[this]
                set s__Missile_Missile___MissileStructure___last[this]=node
            endif
            
            set s__Missile_Missile___MissileStructure___next[node]=0
            
            return node
        endfunction
        
        function s__Missile_Missile___remove takes integer this returns nothing
            local integer node= this
            set this=s__Missile_Missile___MissileStructure___list[node]
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(node == 0,        "MissileStructure", "remove", "Missile", this, "Attempted To Remove Null Node.")
//#                  call ThrowError(not node.Missile___MissileStructure__isNode,  "MissileStructure", "remove", "Missile", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
//#                  set node.Missile___MissileStructure__isNode = false
//#             endif
            
            set s__Missile_Missile___MissileStructure___list[node]=0
        
            if ( 0 == s__Missile_Missile___MissileStructure___prev[node] ) then
                set s__Missile_Missile___MissileStructure___first[this]=s__Missile_Missile___MissileStructure___next[node]
            else
                set s__Missile_Missile___MissileStructure___next[s__Missile_Missile___MissileStructure___prev[node]]=s__Missile_Missile___MissileStructure___next[node]
            endif
            if ( 0 == s__Missile_Missile___MissileStructure___next[node] ) then
                set s__Missile_Missile___MissileStructure___last[this]=s__Missile_Missile___MissileStructure___prev[node]
            else
                set s__Missile_Missile___MissileStructure___prev[s__Missile_Missile___MissileStructure___next[node]]=s__Missile_Missile___MissileStructure___prev[node]
            endif
            
            set s__Missile_Missile___MissileStructure___next[node]=s__Missile_Missile___MissileStructure___next[(0)]
            set s__Missile_Missile___MissileStructure___next[(0)]=node
        endfunction

        // Constants:
        // ==========
        //
        // Attach point name for effects created via model=. 
        
        // Set a ficitional hit box in range of 0 to 1,
        // while 0 is the toe and 1 the head of a unit.
        
        // DEBUG_MODE only members:
        // ========================
        //
        // Checks for double launching. Throws an error message. 

        // Private members:
        // ================
        //        
        // The position of a missile using curve= does not
        // match the position used by Missile's trigonometry.
        // Therefore we need this member two times.
        // Readable x / y / z for your needs and xPrivate / yPrivate for cool mathematics.
        
        // Readonly members:
        // =================
        //
        // Prevents a double free case.
        
        // The dummy unit.
        
        // Position members for you needs.

        // Collision detection type. ( Evaluated new in each loop )
        
        // Members you can set:
        // ====================
        //
        
        // Members which are monitored: ( DEBUG_MODE )
        // ============================
        //
//# static if not true then
//#         
//#         real       collision     // Collision size in plane x / y.
//#         real       collisionZ    // Collision size in z - axis.
//# else
            // Check for collision < 0.
            function s__Missile__set_collision takes integer this,real value returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError((value < 0), "Missile", "collision=", "collision", this, "Found collision below zero [" + R2S(value) + "]!")
//#             endif
                 set s__Missile_collisionDebug[this]=value
            endfunction
            function s__Missile__get_collision takes integer this returns real
                 return s__Missile_collisionDebug[this]
            endfunction
            
            // Check for collisionZ < 0.
            function s__Missile__set_collisionZ takes integer this,real value returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError((value < 0), "Missile", "collisionZ=", "collisionZ", this, "found collisionZ below zero [" + R2S(value) + "]!")
//#             endif
                 set s__Missile_collisionZDebug[this]=value
            endfunction
            function s__Missile__get_collisionZ takes integer this returns real
                 return s__Missile_collisionZDebug[this]
            endfunction   
//# endif
        // Operator overloading:
        // =====================
        //
        // Effect handle on a missile dummy. For multiple effects attaching, access "dummy" in your struct.
        function s__Missile__set_model takes integer this,string modelFile returns nothing
            if ( s__Missile_sfx[this] != null ) then
                call DestroyEffect(s__Missile_sfx[this])
            endif

            set s__Missile_path[this]=modelFile
            set s__Missile_sfx[this]=AddSpecialEffectTarget(modelFile, s__Missile_dummy[this], s__Missile_ORIGIN)
        endfunction
        function s__Missile__get_model takes integer this returns string
            return s__Missile_path[this]
        endfunction
       
       // Enables curved movement for your missile. PI/2 is not allowed.
        function s__Missile__set_curve takes integer this,real value returns nothing
            set s__Missile_open[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]]
        endfunction
        function s__Missile__get_curve takes integer this returns real
            if ( s__MissilePosition_distance[s__Missile_origin[this]] == 0. ) then
                return 0. // It's a limit of sequence and crashes the thread. Intuitively chosen 0 as return value.
            endif
            return Atan(s__Missile_open[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        // Enables arcing movement for your missile. PI/2 is not allowed.
        function s__Missile__set_arc takes integer this,real value returns nothing
            set s__Missile_height[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]] / 4.
        endfunction
        function s__Missile__get_arc takes integer this returns real
            if ( s__MissilePosition_distance[s__Missile_origin[this]] == 0. ) then
                return 0. // It's a limit of sequence and crashes the thread. Intuitively chosen 0 as return value.
            endif
            return Atan(4. * s__Missile_height[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        function s__Missile__set_scale takes integer this,real value returns nothing
            call SetUnitScale(s__Missile_dummy[this], value, 1., 1.)
            set s__Missile_scaleValue[this]=value
        endfunction
        function s__Missile__get_scale takes integer this returns real
            return s__Missile_scaleValue[this]
        endfunction
        
        // Methods:
        // ========
        //
        function s__Missile_bounce takes integer this returns nothing
            call s__MissilePosition_move(s__Missile_origin[this],s__Missile_xPrivate[this] , s__Missile_yPrivate[this] , s__Missile_z[this])
            set s__Missile_distance[this]=0.
        endfunction
       
        function s__Missile_deflect takes integer this,real tx,real ty returns nothing
            local real a= 2. * Atan2(ty - s__Missile_yPrivate[this], tx - s__Missile_xPrivate[this]) + bj_PI - s__Missile_angle[this]
            call s__MissilePosition_move(s__Missile_impact[this],s__Missile_xPrivate[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_distance[this] ) * Cos(a) , s__Missile_yPrivate[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_distance[this] ) * Sin(a) , s__MissilePosition_z[s__Missile_impact[this]])
            call s__Missile_bounce(this)
        endfunction
        
        function s__Missile_deflectEx takes integer this,real tx,real ty,real tz returns nothing
            call s__MissilePosition_move(s__Missile_impact[this],s__MissilePosition_x[s__Missile_impact[this]] , s__MissilePosition_y[s__Missile_impact[this]] , tz)
            call s__Missile_deflect(this,tx , ty)
        endfunction
    
        // Please do not pass in 0.
        function s__Missile_flightTime2Speed takes integer this,real duration returns nothing
            set s__Missile_speed[this]=RMaxBJ(0.00000001, ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_distance[this] ) * Missile_TIMER_TIMEOUT / duration)
        endfunction
        
        function s__Missile_setMovementSpeed takes integer this,real value returns nothing
            set s__Missile_speed[this]=value * Missile_TIMER_TIMEOUT
        endfunction
    
        function s__Missile_destroy takes integer this returns nothing
            set s__Missile_wantDestroy[this]=true
        endfunction

        // Instantly destroys a missile.
        function s__Missile_terminate takes integer this returns nothing
            set s__Missile_allocated[this]=false
            call s__Missile_Missile___remove(this) // Throws an error for invalid nodes.
            call s__MissilePosition_destroy(s__Missile_impact[this])
            call s__MissilePosition_destroy(s__Missile_origin[this])
            //
            call DestroyEffect(s__Missile_sfx[this])
            call FlushChildHashtable(Missile___HASH, this)
            if ( GetUnitTypeId(s__Missile_dummy[this]) == Missile_DUMMY_UNIT_ID ) then
                // MissileRecycler > Dummy > xe.
//#                 static if LIBRARY_MissileRecycler then
//#                     call RecycleMissile(dummy)
//#                 elseif LIBRARY_Dummy and Dummy.create.exists then
//#                     call Dummy[dummy].destroy()
//#                 elseif LIBRARY_xedummy and xedummy.release.exists then
//#                     call xedummy.release(dummy)
//#                 else
                        call RemoveUnit(s__Missile_dummy[this])
//#                 endif
            endif
            //
            set s__Missile_sfx[this]=null
            set s__Missile_source[this]=null
            set s__Missile_target[this]=null
            set s__Missile_dummy[this]=null
            set s__Missile_owner[this]=null
        endfunction
        
        // Runs in createEx.
    
        // Launches a dummy of your choice.
        function s__Missile_createEx takes unit missileDummy,real impactX,real impactY,real impactZ returns integer
            local integer this= s__Missile_allocateNode()
            local real originX= GetUnitX(missileDummy)
            local real originY= GetUnitY(missileDummy)
            local real originZ= GetUnitFlyHeight(missileDummy)
            set s__Missile_allocated[this]=true
            //
//textmacro instance: MISSILE_RESET_ALL_MEMBERS()
            set s__Missile_path[this]=null
            set s__Missile_speed[this]=0.
            set s__Missile_acceleration[this]=0.
            set s__Missile_distance[this]=0.
            set s__Missile_height[this]=0.
            set s__Missile_turn[this]=0.
            set s__Missile_open[this]=0.
            call s__Missile__set_collision(this,0.)
            call s__Missile__set_collisionZ(this,0.)
            set s__Missile_collisionType[this]=0
            set s__Missile_scaleValue[this]=1.
            set s__Missile_wantDestroy[this]=false
            set s__Missile_recycle[this]=false
//end of: MISSILE_RESET_ALL_MEMBERS()
            //
            set s__Missile_origin[this]=s__MissilePosition_create(originX , originY , originZ)
            set s__Missile_impact[this]=s__MissilePosition_create(impactX , impactY , impactZ)
            call s__MissilePosition_link(s__Missile_origin[this] , s__Missile_impact[this])
                        
            set s__Missile_xPrivate[this]=originX
            set s__Missile_yPrivate[this]=originY
            set s__Missile_x[this]=originX
            set s__Missile_y[this]=originY
            set s__Missile_z[this]=originZ
            set s__Missile_angle[this]=s__MissilePosition_angle[s__Missile_origin[this]]
            set s__Missile_dummy[this]=missileDummy
            set s__Missile_stackSize[this]=0
            
            call SetUnitFlyHeight(missileDummy, s__MissilePosition_z[s__Missile_origin[this]] - Missile_GetLocZ(originX , originY), 0.)
            //
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError((GetUnitTypeId(missileDummy) == 0), "Missile", "createEx", "missileDummy", this, "Invalid missile dummy unit (null)!")
//#             endif
             set s__Missile_launched[this]=false
            return this
        endfunction
    
        // Freaky static if ensures these libraries really don't exist.
//#         static if not LIBRARY_MissileRecycler and not LIBRARY_Dummy and not Dummy.create.exists and not LIBRARY_xe_dummy and not xe_dummy.new.exists then
                function s__Missile_newMissileUnit takes real x,real y,real z,real face returns unit
                    local boolean prev= Missile___ToogleUnitIndexer(false)
                    set bj_lastCreatedUnit=CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, x, y, face)
                    call Missile___ToogleUnitIndexer(prev)
                    call SetUnitX(bj_lastCreatedUnit, x)
                    call SetUnitY(bj_lastCreatedUnit, y)
                    call UnitAddAbility(bj_lastCreatedUnit, 'Amrf')
                    call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
                    call PauseUnit(bj_lastCreatedUnit, true)
                    return bj_lastCreatedUnit
                endfunction
//#         endif
    
        // MissileRecylcer > Dummy > xe > Missile.
    
        // Wrapper to createEx.
        function s__Missile_create takes real x,real y,real z,real angle,real distance,real impactZ returns integer
            local real impactX= x + distance * Cos(angle)
            local real impactY= y + distance * Sin(angle)
            // Get Dummy.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
//#                 return createEx(GetRecycledMissile(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_Dummy and Dummy.create.exists then
//#                 local Dummy dummy = Dummy.create(x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(dummy.unit, z, 0.)
//#                 return createEx(dummy.unit, impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_xedummy and xedummy.new.exists then
//#                 set bj_lastCreatedUnit = xedummy.new(Missile_NEUTRAL_PASSIVE, x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
//#                 return createEx(bj_lastCreatedUnit, impactX, impactY, impactZ)
//#             
//#             else
                    return s__Missile_createEx(s__Missile_newMissileUnit(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
//#             endif
//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
        
        // Wrapper to createEx.
        function s__Missile_createXYZ takes real x,real y,real z,real impactX,real impactY,real impactZ returns integer
            local real angle= Atan2(impactY - y, impactX - x)
            // Get Dummy.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
//#                 return createEx(GetRecycledMissile(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_Dummy and Dummy.create.exists then
//#                 local Dummy dummy = Dummy.create(x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(dummy.unit, z, 0.)
//#                 return createEx(dummy.unit, impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_xedummy and xedummy.new.exists then
//#                 set bj_lastCreatedUnit = xedummy.new(Missile_NEUTRAL_PASSIVE, x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
//#                 return createEx(bj_lastCreatedUnit, impactX, impactY, impactZ)
//#             
//#             else
                    return s__Missile_createEx(s__Missile_newMissileUnit(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
//#             endif
//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
    
        // Called from each active struct every Missile_TIMER_TIMEOUT seconds. 
        // In this method performance matters.
        //  • Locals used for faster multiple lookups.
        //  • Short variable names. 
        function s__Missile_move takes integer this returns nothing
            local integer loc
            local real a
            local real d
            local real s
            local real v
            local unit u
            
            local real h
            local real tx
            local real ty
            local real dex
            
            loop
                exitwhen ( 0 == this )
                set loc=s__Missile_origin[this]
                set h=s__Missile_height[this]
                
                // Missile target.
                set u=s__Missile_target[this]
                if ( u != null ) then
                    if ( 0 != GetUnitTypeId(u) ) then
                        set tx=GetUnitX(u)
                        set ty=GetUnitY(u)
                        set a=Atan2(ty - s__Missile_yPrivate[this], tx - s__Missile_xPrivate[this])
                        // 
                        // Uses a fictional hit box of GetUnitBodySize()*HIT_BOX  for the z offset.
                        call s__MissilePosition_move(s__Missile_origin[this],s__Missile_x[this] , s__Missile_y[this] , s__Missile_z[this])
                        call s__MissilePosition_move(s__Missile_impact[this],tx , ty , GetUnitFlyHeight(u) + GetUnitBodySize(u) * s__Missile_HIT_BOX)
                        set s__Missile_distance[this]=s__MissilePosition_distance[loc] - SquareRoot(( tx - s__Missile_xPrivate[this] ) * ( tx - s__Missile_xPrivate[this] ) + ( ty - s__Missile_yPrivate[this] ) * ( ty - s__Missile_yPrivate[this] ))
                    else
                        set a=s__MissilePosition_angle[loc]
                        set s__Missile_target[this]=null
                    endif
                else
                    set a=s__MissilePosition_angle[loc]
                endif
                set u=s__Missile_dummy[this]
                
                // Missile turn.
                if ( 0 != s__Missile_turn[this] ) and ( Cos(s__Missile_angle[this] - a) < Cos(s__Missile_turn[this]) ) then
                    if ( Sin(a - s__Missile_angle[this]) >= 0 ) then
                        set s__Missile_angle[this]=s__Missile_angle[this] + s__Missile_turn[this]
                    else
                        set s__Missile_angle[this]=s__Missile_angle[this] - s__Missile_turn[this]
                    endif
                else
                    set s__Missile_angle[this]=a
                endif
                
                // Update position members.
                set v=s__Missile_speed[this]
                set d=s__MissilePosition_distance[loc]
                //call BJDebugMsg(R2S(d))
                if ( s__Missile_distance[this] + v > d ) then
                    set s=d + 0.000001
                else
                    set s=s__Missile_distance[this] + v
                endif
                set s__Missile_distance[this]=s
                //
                set tx=s__Missile_xPrivate[this] + v * Cos(s__Missile_angle[this])
                set ty=s__Missile_yPrivate[this] + v * Sin(s__Missile_angle[this])
                set s__Missile_speed[this]=v + s__Missile_acceleration[this]
                set s__Missile_xPrivate[this]=tx
                set s__Missile_yPrivate[this]=ty
                
                // Detect the collision type.
                if ( v < s__Missile__get_collision(this) * Missile_COLLISION_ACCURACY_FACTOR ) then
                    set s__Missile_collisionType[this]=Missile_COLLISION_TYPE_CIRCLE
                else
                    set s__Missile_collisionType[this]=Missile_COLLISION_TYPE_RECTANGLE
                endif
                
                // Missile curve.
                if ( s__Missile_open[this] != 0 ) then
                    set a=4 * s__Missile_open[this] * s * ( d - s ) / ( d * d )
                    set tx=tx + a * Cos(s__Missile_angle[this] + 1.57)
                    set ty=ty + a * Sin(s__Missile_angle[this] + 1.57)
                    call SetUnitFacing(u, ( s__Missile_angle[this] + Atan(- ( ( 4 * s__Missile_open[this] ) * ( 2 * s - d ) ) / ( d * d )) ) * bj_RADTODEG)
                else
                    call SetUnitFacing(u, s__Missile_angle[this] * bj_RADTODEG)
                endif
                
                // Missile arc.
                call MoveLocation(Missile___LOC, tx, ty)
                set s__Missile_terrainZ[this]=GetLocationZ(Missile___LOC)
                if ( h != 0 ) or ( s__MissilePosition_slope[loc] != 0 ) then
                    set s__Missile_z[this]=s__MissilePosition_z[loc] - s__Missile_terrainZ[this] + s__MissilePosition_slope[loc] * s
                    set dex=s__MissilePosition_alpha[loc]
                    if ( h != 0 ) then
                        set s__Missile_z[this]=s__Missile_z[this] + ( 4 * h * s * ( d - s ) / ( d * d ) )
                        set dex=dex - Atan(( ( 4 * h ) * ( 2 * s - d ) ) / ( d * d )) * bj_RADTODEG
                    endif
                    if ( GetUnitTypeId(u) == Missile_DUMMY_UNIT_ID ) then
                        call SetUnitAnimationByIndex(u, R2I(dex + 90.5))
                    endif
                else
                    set s__Missile_z[this]=s__MissilePosition_z[loc] - s__Missile_terrainZ[this]
                endif
                
                // Missile position.
//#                 static if not LIBRARY_BoundSentinel and LIBRARY_WorldBounds then
                        if ( tx > s__WorldBounds_maxX ) or ( tx < s__WorldBounds_minX ) or ( ty > s__WorldBounds_maxY ) or ( ty < s__WorldBounds_minY ) then
                            // set wantDestroy = true
                        else
                            call SetUnitX(u, tx)
                            call SetUnitY(u, ty)
                        endif
//#                 else
//#                     call SetUnitX(u, tx)
//#                     call SetUnitY(u, ty)
//#                 endif
                call SetUnitFlyHeight(u, s__Missile_z[this], 0.)
               
                // Update missile x / y ( readonly )
                set s__Missile_xPrev[this]=s__Missile_x[this]
                set s__Missile_yPrev[this]=s__Missile_y[this]
                set s__Missile_x[this]=tx
                set s__Missile_y[this]=ty
               
                // Check for destination reached.
                if ( s >= d ) then
                    set s__Missile_recycle[this]=true
                endif
               
                set this=s__Missile__get_next(this)
            endloop
            set u=null
        endfunction
            
        // Widget collision API:
        // =====================
        //
        // Runs automatically on widget collision.
        function s__Missile_hitWidget takes integer this,widget w returns nothing
            call SaveWidgetHandle(Missile___HASH, this, GetHandleId(w), w)
        endfunction
        
        // All widget which have been hit return true.
        function s__Missile_hasHitWidget takes integer this,widget w returns boolean
            return HaveSavedHandle(Missile___HASH, this, GetHandleId(w))
        endfunction
        
        // Removes a widget from the missile's memory of hit widgets. ( This widget can be hit again )
        function s__Missile_removeHitWidget takes integer this,widget w returns nothing
            call RemoveSavedHandle(Missile___HASH, this, GetHandleId(w))
        endfunction
        
        // Flushes a missile's memory for collision. ( All widgets can be hit again )
        function s__Missile_flushHitWidgets takes integer this returns nothing
            call FlushChildHashtable(Missile___HASH, this)
        endfunction
        
        // Tells missile to call removeHitWidget(w) after "seconds" time.
        // Does not apply to widgets, which are already hit by this missile.
        function s__Missile_enableHitAfter takes integer this,widget w,real seconds returns nothing
            local integer id= GetHandleId(w)
            local integer dex
            if ( id == 0 ) then
                return
            endif
            if HaveSavedInteger(Missile___HASH, this, id) then
                set dex=LoadInteger(Missile___HASH, this, id)
            else
                set dex=s__Missile_stackSize[this]
                set s__Missile_stackSize[this]=s__Missile_stackSize[this] + 1
                call SaveInteger(Missile___HASH, this, id, dex)
                call SaveInteger(Missile___HASH, this, dex, id)
            endif
            call SaveReal(Missile___HASH, this, id, seconds) // Set time.
        endfunction
        
        function s__Missile_updateStack takes integer this returns nothing
            local integer dex= 0
            local integer id
            local real time
            loop
                exitwhen ( dex == s__Missile_stackSize[this] )
                set id=LoadInteger(Missile___HASH, this, dex)
                set time=LoadReal(Missile___HASH, this, id) - Missile_TIMER_TIMEOUT
                if ( time <= 0. ) or not HaveSavedHandle(Missile___HASH, this, id) then
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] - 1
                    set id=LoadInteger(Missile___HASH, this, s__Missile_stackSize[this])
                    call SaveInteger(Missile___HASH, this, dex, id)
                    call SaveInteger(Missile___HASH, this, id, dex)
                    // Enables hit.
                    call RemoveSavedHandle(Missile___HASH, this, id)
                    // Remove data from stack.
                    call RemoveSavedReal(Missile___HASH, this, id)
                    call RemoveSavedInteger(Missile___HASH, this, id)
                    call RemoveSavedInteger(Missile___HASH, this, s__Missile_stackSize[this])
                    set dex=dex - 1
                else
                    call SaveReal(Missile___HASH, this, id, time)
                endif
                set dex=dex + 1
            endloop
        endfunction
    
        // Widget collision code:
        // ======================
        //
        // Transfer data to action functions.                  
        //
        // 1.) Rectangle collision for fast moving missiles with small collision radius.
        //        
        // Runs for destructables and items in a rectangle.
        // Checks if widget w is in collision range of a missile.
        // Is not precise in z - axis collision.
        function s__Missile_checkWidgetRectangle takes integer this,widget w,real height returns boolean
            local real wx= GetWidgetX(w)
            local real wy= GetWidgetY(w)
            local real wz= Missile_GetLocZ(wx , wy) - s__Missile_terrainZ[this]
            local real dx= s__Missile_x[this] - s__Missile_xPrev[this]
            local real dy= s__Missile_y[this] - s__Missile_yPrev[this]
            local real s= ( dx * ( wx - s__Missile_xPrev[this] ) + dy * ( wy - s__Missile_yPrev[this] ) ) / ( dx * dx + dy * dy )
//# static if Missile_USE_COLLISION_Z_FILTER then
                local real cz= s__Missile__get_collisionZ(this)
//# else
//#             local real cz = collision
//# endif       //
            if ( s < 0 ) then
                set s=0.
            elseif ( s > 1 ) then
                set s=1.
            endif
            set dx=( s__Missile_xPrev[this] + s * dx ) - wx
            set dy=( s__Missile_yPrev[this] + s * dy ) - wy
            set s=dx * dx + dy * dy
            if ( s < bj_enumDestructableRadius ) and ( wz + height >= s__Missile_z[this] - cz ) and ( wz <= s__Missile_z[this] + cz ) then
                set bj_enumDestructableRadius=s
                return true
            endif
            return false
        endfunction        
        //
        // 2.) Circular collision detection for all other missiles.
        //
        // Runs for destructables and items in a circle.
        // Z - axis collision is precise.
        function s__Missile_checkWidgetCircle takes integer this,widget w,real height returns boolean
            local real wx= GetWidgetX(w)
            local real wy= GetWidgetY(w)
            local real wz= Missile_GetLocZ(wx , wy) - s__Missile_terrainZ[this]
            local real d= ( s__Missile_x[this] - wx ) * ( s__Missile_x[this] - wx ) + ( s__Missile_y[this] - wy ) * ( s__Missile_y[this] - wy )
//# static if Missile_USE_COLLISION_Z_FILTER then
                local real cz= s__Missile__get_collisionZ(this)
//# else
//#             local real cz = collision
//# endif       //
            if ( d < bj_enumDestructableRadius ) and ( wz + height >= s__Missile_z[this] - cz ) and ( wz <= s__Missile_z[this] + cz ) then
                set bj_enumDestructableRadius=d
                return true
            endif
            return false
        endfunction
        //
        //  3.) Action functions inside the widget enumeration thread.
        //
        // Runs for every enumerated destructable.
        //  • Searches the closest available destructables
        //  • Distance formula based on the Pythagorean theorem.
        //                         
        function s__Missile_enumDests takes nothing returns nothing
            local destructable d= GetEnumDestructable()
            if HaveSavedHandle(Missile___HASH, s__Missile_temp, GetHandleId(d)) then
                set d=null
                return
            endif
            if ( s__Missile_circle ) then
                if s__Missile_checkWidgetCircle(s__Missile_temp,d , GetDestructableHeight(d)) then
                    set bj_destRandomCurrentPick=d
                endif
            // Runs rectangle collision check.
            elseif s__Missile_checkWidgetRectangle(s__Missile_temp,d , GetDestructableHeight(d)) then
                set bj_destRandomCurrentPick=d
            endif
            set d=null
        endfunction
        //
        // Runs for every enumerated item.
        //  • Searches the closest available item.
        //  • Distance formula based on the Pythagorean theorem.
        // 
        function s__Missile_enumItems takes nothing returns nothing
            local item i= GetEnumItem()
            if HaveSavedHandle(Missile___HASH, s__Missile_temp, GetHandleId(i)) then
                set i=null
                return
            endif
            if ( s__Missile_circle ) then
                if s__Missile_checkWidgetCircle(s__Missile_temp,i , GetItemHeight(i)) then
                    set bj_itemRandomCurrentPick=i
                endif
            // Runs rectangle collision check.
            elseif s__Missile_checkWidgetRectangle(s__Missile_temp,i , GetItemHeight(i)) then
                set bj_itemRandomCurrentPick=i
            endif
            set i=null
        endfunction
        //
        //  4.) Filter function for rectangle unit collision.
        //
        // Runs for every enumerated units.
        //  • Filters out units which are not in collision range in plane x / y.
        //
        function s__Missile_filterUnits takes nothing returns boolean
            local integer this= s__Missile_temp
            //
            local unit u= GetFilterUnit()
            local real a
            local real b
            local real s
            local boolean is
            // Missile knows this unit already.
            if HaveSavedBoolean(Missile___HASH, this, GetHandleId(u)) then
                set u=null
                return false
            endif
            //
            set a=s__Missile_x[this] - s__Missile_xPrev[this]
            set b=s__Missile_y[this] - s__Missile_yPrev[this]
            set s=( a * ( GetUnitX(u) - s__Missile_xPrev[this] ) + b * ( GetUnitY(u) - s__Missile_yPrev[this] ) ) / ( a * a + b * b )
            if ( s < 0 ) then
                set s=0.
            elseif ( s > 1 ) then
                set s=1.
            endif
            set is=IsUnitInRangeXY(u, s__Missile_xPrev[this] + s * a, s__Missile_yPrev[this] + s * b, s__Missile__get_collision(this))
            set u=null
            return is
        endfunction
        //
        // 5.) Proper rect preparation.
        //
        // For rectangle.
        function s__Missile_prepareRectRectangle takes integer this returns nothing
            local real x1= s__Missile_xPrev[this]
            local real y1= s__Missile_yPrev[this]
            local real x2= s__Missile_x[this]
            local real y2= s__Missile_y[this]
            local real d= s__Missile__get_collision(this) + Missile_MAXIMUM_COLLISION_SIZE
            // What is min, what is max ...
            if ( x1 < x2 ) then
                if ( y1 < y2 ) then
                    call SetRect(Missile___RECT, x1 - d, y1 - d, x2 + d, y2 + d)
                else
                    call SetRect(Missile___RECT, x1 - d, y2 - d, x2 + d, y1 + d)
                endif
            else
                if ( y1 < y2 ) then
                    call SetRect(Missile___RECT, x2 - d, y1 - d, x1 + d, y2 + d)
                else
                    call SetRect(Missile___RECT, x2 - d, y2 - d, x1 + d, y1 + d)
                endif
            endif
        endfunction
        //
        // For circular.
        function s__Missile_prepareRectCircle takes integer this returns nothing
            local real d= s__Missile__get_collision(this) + Missile_MAXIMUM_COLLISION_SIZE
            call SetRect(Missile___RECT, s__Missile_x[this] - d, s__Missile_y[this] - d, s__Missile_x[this] + d, s__Missile_y[this] + d)
        endfunction
        //
        // 6.) API for the MissileStruct iteration.
        //
        function s__Missile_groupEnumUnitsRectangle takes integer this returns nothing
            call s__Missile_prepareRectRectangle(this)
            set s__Missile_temp=this
            call GroupEnumUnitsInRect(Missile___GROUP, Missile___RECT, Missile___unitFilter)
        endfunction
        //
        // Prepares destructable enumeration, then runs enumDests.
        function s__Missile_checkDestCollision takes integer this,boolexpr expr returns nothing
            set s__Missile_circle=( s__Missile_collisionType[this] == Missile_COLLISION_TYPE_CIRCLE )
            if ( s__Missile_circle ) then
                call s__Missile_prepareRectCircle(this)
            else
                call s__Missile_prepareRectRectangle(this)
            endif
            //
            set s__Missile_temp=this
            set bj_destRandomCurrentPick=null
            set bj_enumDestructableRadius=s__Missile__get_collision(this) * s__Missile__get_collision(this) + 1.
            call EnumDestructablesInRect(Missile___RECT, expr, function s__Missile_enumDests)
        endfunction
        //
        // Prepares item enumeration, then runs enumItems.
        function s__Missile_checkItemCollision takes integer this,boolexpr expr returns nothing
            set s__Missile_circle=( s__Missile_collisionType[this] == Missile_COLLISION_TYPE_CIRCLE )
            if ( s__Missile_circle ) then
                call s__Missile_prepareRectCircle(this)
            else
                call s__Missile_prepareRectRectangle(this)
            endif
            //
            set s__Missile_temp=this
            set bj_itemRandomCurrentPick=null
            set bj_enumDestructableRadius=s__Missile__get_collision(this) * s__Missile__get_collision(this) + 1.
            call EnumItemsInRect(Missile___RECT, expr, function s__Missile_enumItems)
        endfunction

//# static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
        function s__Missile_nullBefore takes integer this returns nothing
            set s__Missile_dummy[this]=null
        endfunction
//# endif

// Does not check for 'Aloc' and 'Amrf' as they could be customized.
        function s__Missile_onInit takes nothing returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  local boolean prev = Missile___ToogleUnitIndexer(false)
//#                  local unit dummy = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0, 0, 0)
//#                  call Missile___ToogleUnitIndexer(prev)
//#                 //
//#                  call ThrowError((GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "typeid",    0, "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
//#                  call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),            "Missile", "DEBUG_MISSILE", "collision", 0, "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
//#                  call RemoveUnit(dummy)
//#                  set dummy = null
//#             endif
            //
            set Missile___unitFilter=Filter(function s__Missile_filterUnits)
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
    // Filter function for item enumeration. ( Runs only if a filter is declared in the struct )
    function Missile___MissileCreateItemFilter takes integer structId,code func returns nothing
        set Missile___itemFilter[structId]=Filter(func)
    endfunction
    
    // Filter function for destructable enumeration. ( Runs only if a filter is declared in the struct ) 
    function Missile___MissileCreateDestructableFilter takes integer structId,code func returns nothing
        set Missile___destFilter[structId]=Filter(func)
    endfunction
    
    // Condition function for the core trigger evaluation. ( Runs for all struct using module MissileStruct )
    function Missile___MissileCreateExpression takes integer structId,code func returns nothing
        set Missile___expression[structId]=Condition(func)
    endfunction
    
    // Creates a collection for a struct. ( Runs for all struct using module MissileStruct )
    function Missile___MissileCreateCollection takes integer structId returns nothing
        set Missile___missileStack[structId]=s__Missile_allocateCollection()
    endfunction
    
    // Core:
    // =====
    //
    // Fires every Missile_TIMER_TIMEOUT.
    function Missile___Fire takes nothing returns nothing
        local integer i= Missile___remove[0]
        set Missile___remove[0]=0
        loop
            exitwhen i == 0
            if ( Missile___instances[i] == 0 ) and ( Missile___condition[i] != null ) then
                call TriggerRemoveCondition(Missile___CORE, Missile___condition[i])
                set Missile___condition[i]=null
                set Missile___active=Missile___active - 1
            endif
            set i=Missile___remove[i]
        endloop
        if ( Missile___active == 0 ) then
            call PauseTimer(Missile___TMR)
        else
            call TriggerEvaluate(Missile___CORE)
        endif
    endfunction
    
    // Conditionally starts the timer.
    function Missile___StartPeriodic takes integer structId returns nothing
        if ( Missile___instances[structId] == 0 ) then
            if ( Missile___active == 0 ) then
                call TimerStart(Missile___TMR, Missile_TIMER_TIMEOUT, true, function Missile___Fire)
            endif
            if ( Missile___condition[structId] == null ) then
                set Missile___condition[structId]=TriggerAddCondition(Missile___CORE, Missile___expression[structId])
                set Missile___active=Missile___active + 1
            endif
        endif
        set Missile___instances[structId]=Missile___instances[structId] + 1
    endfunction
    
    // Conditionally stops the timer.
    function Missile___StopPeriodic takes integer structId returns nothing
        set Missile___instances[structId]=Missile___instances[structId] - 1
        if ( Missile___instances[structId] == 0 ) then
            set Missile___remove[structId]=Missile___remove[0]
            set Missile___remove[0]=structId
        endif
    endfunction
    
    // Module:
    // =======
    //
    
    
    // Missile position:
    // =================
    //
    // Simple trigonometry.
    
    // Delayed dummy recycling:
    // ========================
    //
    // Ensures proper fx death animations.
    
// The end!

//library Missile ends
//library SpellEffectEvent:
 
//============================================================================
 
//============================================================================
//Implemented from module SpellEffectEvent___M:
   
//#     static if LIBRARY_Table then
//#     else
//#         static hashtable ht = InitHashtable()
//#     endif
   
    function s__SpellEffectEvent___S_onCast takes nothing returns nothing
//#         static if LIBRARY_Table then
                call TriggerEvaluate(s__Table___triggers__getindex(s__Table__get_trigger(s__SpellEffectEvent___S_tb),GetSpellAbilityId()))
//#         else
//#             call TriggerEvaluate(LoadTriggerHandle(.ht, 0, GetSpellAbilityId()))
//#         endif
    endfunction
 
    function s__SpellEffectEvent___S_SpellEffectEvent___M__onInit takes nothing returns nothing
//#         static if LIBRARY_Table then
                set s__SpellEffectEvent___S_tb=s__Table_create()
//#         endif
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT , function s__SpellEffectEvent___S_onCast)
    endfunction
 
//============================================================================
function RegisterSpellEffectEvent takes integer abil,code onCast returns nothing
//#     static if LIBRARY_Table then
            if not s__Table___handles_has(s__Table__get_handle(s__SpellEffectEvent___S_tb),abil) then
                call s__Table___triggers__setindex(s__Table__get_trigger(s__SpellEffectEvent___S_tb),abil, CreateTrigger())
            endif
            call TriggerAddCondition(s__Table___triggers__getindex(s__Table__get_trigger(s__SpellEffectEvent___S_tb),abil), Filter(onCast))
//#     else
//#         if not HaveSavedHandle(SpellEffectEvent___S.ht, 0, abil) then
//#             call SaveTriggerHandle(SpellEffectEvent___S.ht, 0, abil, CreateTrigger())
//#         endif
//#         call TriggerAddCondition(LoadTriggerHandle(SpellEffectEvent___S.ht, 0, abil), Filter(onCast))
//#     endif
endfunction
 

//library SpellEffectEvent ends
//library SpellIndex:
    

    
        //*  implement your Alloc module here.
    
        //*  Add or remove struct members you to needs.
        //*  Units.
        //* Effects.
        //* Timer.
        //*  Damage options.
        //*  Misc.
        
        //*  Conditionally destroy an handle on instance.destroy().
        
        function s__SpellIndex_destroy takes integer this returns nothing
//textmacro instance: SPELL_INDEX_CHECK_MEMBER("fx", "Effect")
            if s__SpellIndex_fx[this] != null then
                call DestroyEffect(s__SpellIndex_fx[this])
                set s__SpellIndex_fx[this]=null
            endif
//end of: SPELL_INDEX_CHECK_MEMBER("fx", "Effect")
//textmacro instance: SPELL_INDEX_CHECK_MEMBER("splat", "Ubersplat")
            if s__SpellIndex_splat[this] != null then
                call DestroyUbersplat(s__SpellIndex_splat[this])
                set s__SpellIndex_splat[this]=null
            endif
//end of: SPELL_INDEX_CHECK_MEMBER("splat", "Ubersplat")
//textmacro instance: SPELL_INDEX_CHECK_MEMBER("flash", "Lightning")
            if s__SpellIndex_flash[this] != null then
                call DestroyLightning(s__SpellIndex_flash[this])
                set s__SpellIndex_flash[this]=null
            endif
//end of: SPELL_INDEX_CHECK_MEMBER("flash", "Lightning")
            set s__SpellIndex_target[this]=null
            set s__SpellIndex_clock[this]=null
            set s__SpellIndex_source[this]=null
            call s__SpellIndex_deallocate(this)
        endfunction
    


//library SpellIndex ends
//library BoneSpirit:
//**
//*  User settings:
//*  ==============
    
    //*  Filter out which units should be damaged.
    function BoneSpirit___FilterUnits takes unit target,player p returns boolean
        return ( UnitAlive(target) ) and ( IsUnitEnemy(target, p) ) and ( not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) )
    endfunction
    //*  Set the maximum fly distance.
    constant function BoneSpirit___GetFlyDistance takes integer level returns real
        return 800. + ( 250 * level )
    endfunction
    //*  Set the movement speed for the spirit.
    constant function BoneSpirit___GetMovementSpeed takes integer level returns real
        return 440. + ( 0 * level )
    endfunction
    //*  Set the impact damage.
    constant function BoneSpirit___GetImpactDamage takes integer level returns real
        return 0. + ( 90. * level )
    endfunction
    
//========================================================================
//*  Bone spirit code. Make changes carefully.
//========================================================================
    
    
    //*  Filters valid targets for the spirit.
    function BoneSpirit___ConsiderUnitsFiltered takes nothing returns boolean
        return BoneSpirit___FilterUnits(GetFilterUnit() , BoneSpirit___tempOwner)
    endfunction
    
    //*  Uses Missile's API. Add or remove whatever you need.
                
        //*  Removes the effect delayed.
        function s__BoneSpirit___BoneSpirit_onRemove takes integer missle returns boolean
            return true
        endfunction
        
        //*  Runs on missile collide with any unit.
        function s__BoneSpirit___BoneSpirit_onCollide takes integer missile,unit hit returns boolean
            if ( BoneSpirit___FilterUnits(hit , s__Missile_owner[missile]) ) then
//#                 static if BoneSpirit___HIT_TARGET_ONLY then
//#                     if (hit != missile.target) then
//#                         return false
//#                     endif
//#                 endif
                call s__DummyCaster_castTarget((BoneSpirit___BUFF_CAST_ID),s__Missile_owner[missile] , 1 , BoneSpirit___ORDER_ID , hit)
                call UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, BoneSpirit___ATTACK_TYPE, BoneSpirit___DAMAGE_TYPE, null)
                return true
            endif
            return false
        endfunction
        
        //*  Checks for new valid targets.
        function s__BoneSpirit___BoneSpirit_onPeriod takes integer missile returns boolean
            set s__BoneSpirit___BoneSpirit_delay[missile]=s__BoneSpirit___BoneSpirit_delay[missile] - Missile_TIMER_TIMEOUT
            if not UnitAlive(s__Missile_target[missile]) and ( s__BoneSpirit___BoneSpirit_delay[missile] <= 0. ) then
                set s__BoneSpirit___BoneSpirit_delay[missile]=BoneSpirit___DETECTION_DELAY
                set BoneSpirit___tempOwner=s__Missile_owner[missile]
                call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, s__Missile_x[missile], s__Missile_y[missile], BoneSpirit___UNIT_DETECTION_AOE, s__BoneSpirit___BoneSpirit_filter)
                if ( FirstOfGroup(s__SpellIndex_GLOBAL_GROUP) != null ) then
                    set bj_groupRandomConsidered=0
                    set bj_groupRandomCurrentPick=null
                    call ForGroup(s__SpellIndex_GLOBAL_GROUP, function GroupPickRandomUnitEnum)
                    call GroupClear(s__SpellIndex_GLOBAL_GROUP) //*  Not really required. GroupEnum functions always clear groups.
                    set s__Missile_target[missile]=bj_groupRandomCurrentPick
                    set bj_groupRandomCurrentPick=null
                endif
            endif
            return false
        endfunction
        
//Implemented from module MissileStruct:
        
// Runs check during compile time.
//# static if true then
//#     static if BoneSpirit___BoneSpirit.onMissile.exists then
//#         Error Message from library Missile in struct BoneSpirit___BoneSpirit !
//#         BoneSpirit___BoneSpirit.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         BoneSpirit___BoneSpirit.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif
        
        // Called from missileIterate. "P" to avoid code collision.
        function s__BoneSpirit___BoneSpirit_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if BoneSpirit___BoneSpirit.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
                        if s__BoneSpirit___BoneSpirit_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call BoneSpirit___BoneSpirit.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile___StopPeriodic(si__BoneSpirit___BoneSpirit)
        endfunction
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__BoneSpirit___BoneSpirit_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileStack[si__BoneSpirit___BoneSpirit])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            call s__Missile_move(this) // Moves all missiles of this collection. 
            loop
                exitwhen ( 0 == this )
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if BoneSpirit___BoneSpirit.onFinish.exists then
//#                         if BoneSpirit___BoneSpirit.onFinish(this) then
//#                             call BoneSpirit___BoneSpirit.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__BoneSpirit___BoneSpirit_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                    if ( s__Missile_stackSize[this] > 0 ) then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if BoneSpirit___BoneSpirit.onCollide.exists then
                            if ( s__Missile_allocated[this] ) and ( 0 != s__Missile__get_collision(this) ) then
                                set b=( s__Missile_collisionType[this] == Missile_COLLISION_TYPE_RECTANGLE )
                                if b then
                                    call s__Missile_groupEnumUnitsRectangle(this)
                                else
                                    call GroupEnumUnitsInRange(Missile___GROUP, s__Missile_x[this], s__Missile_y[this], s__Missile__get_collision(this) + Missile_MAXIMUM_COLLISION_SIZE, null)
                                endif
                                loop
                                    set u=FirstOfGroup(Missile___GROUP)
                                    exitwhen u == null
                                    call GroupRemoveUnit(Missile___GROUP, u)
                                    if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
                                        if ( ( IsUnitInRange(u, s__Missile_dummy[this], s__Missile__get_collision(this)) ) or ( b ) ) then
                                            // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
                                                set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                                if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile__get_collisionZ(this) ) and ( collideZ <= s__Missile_z[this] + s__Missile__get_collisionZ(this) ) then
                                                    // Mark as hit.
                                                    call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
                                                    if s__BoneSpirit___BoneSpirit_onCollide(this , u) then
                                                        call s__BoneSpirit___BoneSpirit_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                                endif
        
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if BoneSpirit___BoneSpirit.onCollide(this, u) then
//#                                                 call BoneSpirit___BoneSpirit.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
                                        endif
                                    endif
                                endloop
                            endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if BoneSpirit___BoneSpirit.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkDestCollision(Missile___destFilter[BoneSpirit___BoneSpirit.typeid])
//#                             if (bj_destRandomCurrentPick != null) then 
//#                                 call SaveDestructableHandle(Missile___HASH, this, GetHandleId(bj_destRandomCurrentPick), bj_destRandomCurrentPick) 
//#                                 if BoneSpirit___BoneSpirit.onDestructable(this, bj_destRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if BoneSpirit___BoneSpirit.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkItemCollision(Missile___itemFilter[BoneSpirit___BoneSpirit.typeid])
//#                             if (bj_itemRandomCurrentPick != null) then 
//#                                 call SaveItemHandle(Missile___HASH, this, GetHandleId(bj_itemRandomCurrentPick), bj_itemRandomCurrentPick) 
//#                                 if BoneSpirit___BoneSpirit.onItem(this, bj_itemRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if BoneSpirit___BoneSpirit.onFinish.exists then
//#                             if BoneSpirit___BoneSpirit.onFinish(this) then
//#                                 call BoneSpirit___BoneSpirit.MissileStruct__missileTerminateP(this)
//#                             else
//#                                 set this.recycle = false
//#                             endif
//#                         else
                                call s__BoneSpirit___BoneSpirit_MissileStruct__missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if BoneSpirit___BoneSpirit.onTerrain.exists then
//#                         if (this.allocated) and (this.z < 0) and BoneSpirit___BoneSpirit.onTerrain(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if BoneSpirit___BoneSpirit.onPeriod.exists then
                            if ( s__Missile_allocated[this] ) and s__BoneSpirit___BoneSpirit_onPeriod(this) then
                                call s__BoneSpirit___BoneSpirit_MissileStruct__missileTerminateP(this)
                            endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        // Places the launcher in your struct.
        function s__BoneSpirit___BoneSpirit_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "BoneSpirit___BoneSpirit", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertEnd(Missile___missileStack[si__BoneSpirit___BoneSpirit],missile)
            call Missile___StartPeriodic(si__BoneSpirit___BoneSpirit)
        endfunction
    
        // Runs onInit. Creates the collection, trigger condition and widget filters.
        function s__BoneSpirit___BoneSpirit_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__BoneSpirit___BoneSpirit)
            call Missile___MissileCreateExpression(si__BoneSpirit___BoneSpirit , function s__BoneSpirit___BoneSpirit_MissileStruct__missileIterateP)
//#             static if BoneSpirit___BoneSpirit.onDestructableFilter.exists and BoneSpirit___BoneSpirit.onDestructable.exists then
//#                 call Missile___MissileCreateDestructableFilter(BoneSpirit___BoneSpirit.typeid, function BoneSpirit___BoneSpirit.onDestructableFilter)
//#             endif
//#             static if BoneSpirit___BoneSpirit.onItemFilter.exists and BoneSpirit___BoneSpirit.onItem.exists then
//#                 call Missile___MissileCreateItemFilter(BoneSpirit___BoneSpirit.typeid, function BoneSpirit___BoneSpirit.onItemFilter)
//#             endif
        endfunction
    
        
    function OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local integer level= GetUnitAbilityLevel(source, BoneSpirit___BONE_SPIRIT_ABILITY)
        local real x= GetUnitX(source)
        local real y= GetUnitY(source)
        local real angle= Atan2(GetSpellTargetY() - y, GetSpellTargetX() - x)
        //*  Create a new missile and assign members.
        local integer missile= s__Missile_create(x , y , BoneSpirit___SPIRIT_FLY_HEIGHT , angle , BoneSpirit___GetFlyDistance(level) , BoneSpirit___SPIRIT_FLY_HEIGHT)
        set s__Missile_damage[missile]=BoneSpirit___GetImpactDamage(level)
        call s__Missile__set_collision(missile,BoneSpirit___COLLISION_SIZE)
        set s__Missile_source[missile]=source
        set s__Missile_target[missile]=GetSpellTargetUnit()
        set s__Missile_owner[missile]=GetTriggerPlayer()
        set s__Missile_speed[missile]=BoneSpirit___GetMovementSpeed(level) * Missile_TIMER_TIMEOUT
        call s__Missile__set_model(missile,BoneSpirit___SPIRIT_MODEL)
        call s__Missile__set_scale(missile,BoneSpirit___SPIRIT_SCALE)
        call s__BoneSpirit___BoneSpirit_launch(missile)
        //*
        set s__BoneSpirit___BoneSpirit_delay[missile]=BoneSpirit___DETECTION_DELAY
        set source=null
    endfunction
    
    function BoneSpirit___Init takes nothing returns nothing
        set s__BoneSpirit___BoneSpirit_filter=Filter(function BoneSpirit___ConsiderUnitsFiltered)
        call RegisterSpellEffectEvent(BoneSpirit___BONE_SPIRIT_ABILITY , function OnEffect)
    endfunction


//library BoneSpirit ends
//library Chaosflare:
//**
//*  User settings:
//*  ==============
    
    //*  Set the impact damage.  
    constant function Chaosflare___GetImpactDamage takes integer level returns real
        return 45. + ( 10 * level )
    endfunction
    //*  Set the periodic damage.
    constant function Chaosflare___GetDamageOverTime takes integer level returns real
        return 20. + ( 10 * level )
    endfunction
    //*  Set how often damage over time is applied.
    constant function Chaosflare___GetDamageOverTimeCount takes integer level returns integer
        return 4 + 0 * level
    endfunction
    
//========================================================================
//*  Chaosflare code. Make changes carefully.
//========================================================================
    
    function Chaosflare___OnPeriodic takes nothing returns nothing
        local integer dex= GetTimerData(GetExpiredTimer())
        if ( s__SpellIndex_count[dex] <= 0 ) or not UnitAlive(s__SpellIndex_target[dex]) or ( GetUnitAbilityLevel(s__SpellIndex_target[dex], Chaosflare___BUFF_ID) == 0 ) then
            call UnitRemoveAbility(s__SpellIndex_target[dex], Chaosflare___BUFF_ID)
            call ReleaseTimer(GetExpiredTimer())
            call s__SpellIndex_destroy(dex) //*  Nulls members automatically.
            return
        //*  Deal damage.
        elseif ( GetUnitTypeId(s__SpellIndex_source[dex]) != 0 ) then
            call UnitDamageTarget(s__SpellIndex_source[dex], s__SpellIndex_target[dex], s__SpellIndex_damage[dex], false, false, Chaosflare___ATTACK_TYPE, Chaosflare___DAMAGE_TYPE, null)
            call DestroyEffect(AddSpecialEffectTarget(Chaosflare___DOT_FX, s__SpellIndex_target[dex], Chaosflare___DOT_FX_ATTACH_POINT))
        endif
        set s__SpellIndex_count[dex]=s__SpellIndex_count[dex] - 1
    endfunction
    
    function Chaosflare___OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local unit target= GetSpellTargetUnit()
        local real posX= GetUnitX(source)
        local real posY= GetUnitY(source)
        local real angle= Atan2(GetUnitY(target) - posY, GetUnitX(target) - posX)
        local real cos= Chaosflare___SPACE_BETWEEN_FLAMES * Cos(angle)
        local real sin= Chaosflare___SPACE_BETWEEN_FLAMES * Sin(angle)
        local integer level= GetUnitAbilityLevel(source, Chaosflare___CHAOSFLARE_ABILITY)
        local integer i= 0
        local integer dex
        //*  Run effects.
        call DestroyEffect(AddSpecialEffect(Chaosflare___ON_CASTER_FX, posX, posY))
        call DestroyEffect(AddSpecialEffectTarget(Chaosflare___ON_TARGET_FX, target, "origin"))
        loop
            exitwhen ( IsUnitInRangeXY(target, posX, posY, Chaosflare___SPACE_BETWEEN_FLAMES) ) or ( i == Chaosflare___MAX_FLAMES )
            set posX=posX + cos
            set posY=posY + sin
            call DestroyEffect(AddSpecialEffect(Chaosflare___FLAME_FX, posX, posY))
            set i=i + 1
        endloop
        //*  Deal damage and apply the buff. Conditionally start the timer.
        if UnitDamageTarget(source, target, Chaosflare___GetImpactDamage(level), false, false, Chaosflare___ATTACK_TYPE, Chaosflare___DAMAGE_TYPE, null) then
            if s__DummyCaster_castTarget((Chaosflare___BUFF_CAST_ID),GetOwningPlayer(source) , 1 , Chaosflare___ORDER_ID , target) then
                //*  Allocate a spell instance.
                set dex=s__SpellIndex__allocate()
                set s__SpellIndex_source[dex]=source
                set s__SpellIndex_target[dex]=target
                set s__SpellIndex_count[dex]=Chaosflare___GetDamageOverTimeCount(level)
                set s__SpellIndex_damage[dex]=Chaosflare___GetDamageOverTime(level)
                call TimerStart(NewTimerEx(dex), Chaosflare___TIMER_TIMEOUT, true, function Chaosflare___OnPeriodic)
            endif
        endif
        set source=null
        set target=null
    endfunction
    
    function Chaosflare___Init takes nothing returns nothing
        call RegisterSpellEffectEvent(Chaosflare___CHAOSFLARE_ABILITY , function Chaosflare___OnEffect)
    endfunction

//library Chaosflare ends
//library ChaoticBoulder:
//**
//*  User settings:
//*  ==============

    //*  Filter valid target units.
    function ChaoticBoulder___FilterUnits takes unit target,player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_FLYING)
    endfunction
    //*  Set the travel distance.
    function ChaoticBoulder___GetSmallBoulderFlyDistance takes integer level returns real
        return GetRandomReal(50., 200.)
    endfunction
    //*  Set the explosion radius on impact.
    constant function ChaoticBoulder___GetExplosionRadius takes integer level returns real
        return 200. + ( 0. * level )
    endfunction
    //*  Set the amount of fragments.
    function ChaoticBoulder___GetSmallBoulderCount takes integer level returns integer
        return GetRandomInt(4, 6) + 2 * level
    endfunction
    //*  Customize all missile members to your needs. 
    function ChaoticBoulder___CustomizeSmallMissile takes integer missile,real distance,integer level returns nothing
        call s__Missile_flightTime2Speed(missile,GetRandomReal(1., 1.5) * distance / 200.)
        set s__Missile_damage[missile]=10. + 10. * level
        call s__Missile__set_collision(missile,96.)
        call s__Missile__set_arc(missile,GetRandomReal(80., 85.) * bj_DEGTORAD)
        call s__Missile__set_model(missile,"Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl")
        call s__Missile__set_scale(missile,0.8)
    endfunction
    //*  Customize all missile members to your needs.
    function ChaoticBoulder___CustomizeBigMissile takes integer missile,real distance,integer level returns nothing
        call s__Missile_flightTime2Speed(missile,GetRandomReal(1., 2.) * distance / 800.)
        set s__Missile_damage[missile]=200. + 70. * level
        call s__Missile__set_arc(missile,45. * bj_DEGTORAD + RMinBJ(20., distance * .1) * bj_DEGTORAD)
        call s__Missile__set_collision(missile,128.)
        call s__Missile__set_model(missile,"Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl")
        call s__Missile__set_scale(missile,1.2)
    endfunction

//========================================================================
//*  Chaotic boulder code. Make changes carefully.
//========================================================================
    
    //*  Uses Missile's API. Add or remove whatever you need.
        
        //*  Only living trees are valid targets.
        function s__ChaoticBoulder___ChaoticBoulder_onDestructable takes integer missile,destructable hit returns boolean
            if IsDestructableTree(hit) and ( GetWidgetLife(hit) > .405 ) then
                call KillDestructable(hit)
            endif
            return false
        endfunction
                
        function s__ChaoticBoulder___ChaoticBoulder_createSmallBoulders takes integer big returns nothing
            local integer level= GetUnitAbilityLevel(s__Missile_source[big], ChaoticBoulder___CHAOTIC_BOULDER_ABILITY)
            local integer dex= 0
            local integer max= ChaoticBoulder___GetSmallBoulderCount(level)
            local integer small
            loop
                exitwhen ( dex >= max )
                set small=s__Missile_create(s__Missile_x[big] , s__Missile_y[big] , 0. , GetRandomReal(- bj_PI, bj_PI) , ChaoticBoulder___GetSmallBoulderFlyDistance(level) , 0.)
                call ChaoticBoulder___CustomizeSmallMissile(small , s__MissilePosition_distance[s__Missile_origin[small]] , level)
                set s__Missile_source[small]=s__Missile_source[big]
                set s__Missile_owner[small]=s__Missile_owner[big]
                set s__Missile_data[small]=0
                call sc__ChaoticBoulder___ChaoticBoulder_launch(small)
                set dex=dex + 1
            endloop
        endfunction
                
        //*  Damages close unit on missile removal.
        function s__ChaoticBoulder___ChaoticBoulder_onRemove takes integer missile returns boolean
            local unit u
            call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, s__Missile_x[missile], s__Missile_y[missile], s__Missile__get_collision(missile), null)
            loop
                set u=FirstOfGroup(s__SpellIndex_GLOBAL_GROUP)
                exitwhen u == null
                call GroupRemoveUnit(s__SpellIndex_GLOBAL_GROUP, u)
                if ChaoticBoulder___FilterUnits(u , s__Missile_owner[missile]) then
                    call UnitDamageTarget(s__Missile_source[missile], u, s__Missile_damage[missile], false, false, ChaoticBoulder___ATTACK_TYPE, ChaoticBoulder___DAMAGE_TYPE, null)
                endif
            endloop
            //*  Detect big boulder. 
            if ( s__Missile_data[missile] == - 1 ) then
                //*  Runs effects.
                call DestroyEffect(AddSpecialEffect(ChaoticBoulder___ON_DAMAGE_BIG_FX, s__Missile_x[missile], s__Missile_y[missile]))
                call s__ChaoticBoulder___ChaoticBoulder_createSmallBoulders(missile)
            endif
            return true
        endfunction
        
//Implemented from module MissileStruct:
        
// Runs check during compile time.
//# static if true then
//#     static if ChaoticBoulder___ChaoticBoulder.onMissile.exists then
//#         Error Message from library Missile in struct ChaoticBoulder___ChaoticBoulder !
//#         ChaoticBoulder___ChaoticBoulder.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         ChaoticBoulder___ChaoticBoulder.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif
        
        // Called from missileIterate. "P" to avoid code collision.
        function s__ChaoticBoulder___ChaoticBoulder_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if ChaoticBoulder___ChaoticBoulder.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
                        if s__ChaoticBoulder___ChaoticBoulder_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call ChaoticBoulder___ChaoticBoulder.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile___StopPeriodic(si__ChaoticBoulder___ChaoticBoulder)
        endfunction
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__ChaoticBoulder___ChaoticBoulder_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileStack[si__ChaoticBoulder___ChaoticBoulder])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            call s__Missile_move(this) // Moves all missiles of this collection. 
            loop
                exitwhen ( 0 == this )
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if ChaoticBoulder___ChaoticBoulder.onFinish.exists then
//#                         if ChaoticBoulder___ChaoticBoulder.onFinish(this) then
//#                             call ChaoticBoulder___ChaoticBoulder.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__ChaoticBoulder___ChaoticBoulder_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                    if ( s__Missile_stackSize[this] > 0 ) then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if ChaoticBoulder___ChaoticBoulder.onCollide.exists then
//#                         if (this.allocated) and (0 != this.collision) then
//#                             set b = (this.collisionType == Missile_COLLISION_TYPE_RECTANGLE)  
//#                             if b then
//#                                 call this.groupEnumUnitsRectangle()
//#                             else
//#                                 call GroupEnumUnitsInRange(Missile___GROUP, this.x, this.y, this.collision + Missile_MAXIMUM_COLLISION_SIZE, null)
//#                             endif
//#                             loop
//#                                 set u = FirstOfGroup(Missile___GROUP)
//#                                 exitwhen u == null
//#                                 call GroupRemoveUnit(Missile___GROUP, u)
//#                                 if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
//#                                     if ((IsUnitInRange(u, this.dummy, this.collision)) or (b)) then  
//#                                         // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
//#                                             set collideZ = Missile_GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u) - this.terrainZ
//#                                             if (collideZ + GetUnitBodySize(u) >= this.z - this.collisionZ) and (collideZ <= this.z + this.collisionZ) then
//#                                                 // Mark as hit.
//#                                                 call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                                 if ChaoticBoulder___ChaoticBoulder.onCollide(this, u) then
//#                                                     call ChaoticBoulder___ChaoticBoulder.MissileStruct__missileTerminateP(this)
//#                                                     exitwhen true
//#                                                 endif
//#                                             endif
//#     
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if ChaoticBoulder___ChaoticBoulder.onCollide(this, u) then
//#                                                 call ChaoticBoulder___ChaoticBoulder.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
//#                                     endif                                    
//#                                 endif
//#                             endloop
//#                         endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if ChaoticBoulder___ChaoticBoulder.onDestructable.exists then
                            // Check if the missile is not terminated.
                            if ( s__Missile_allocated[this] ) and ( 0 != s__Missile__get_collision(this) ) then
                                call s__Missile_checkDestCollision(this,Missile___destFilter[si__ChaoticBoulder___ChaoticBoulder])
                                if ( bj_destRandomCurrentPick != null ) then
                                    call SaveDestructableHandle(Missile___HASH, this, GetHandleId(bj_destRandomCurrentPick), bj_destRandomCurrentPick)
                                    if s__ChaoticBoulder___ChaoticBoulder_onDestructable(this , bj_destRandomCurrentPick) then
                                        call s__ChaoticBoulder___ChaoticBoulder_MissileStruct__missileTerminateP(this)
                                    endif
                                endif
                            endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if ChaoticBoulder___ChaoticBoulder.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkItemCollision(Missile___itemFilter[ChaoticBoulder___ChaoticBoulder.typeid])
//#                             if (bj_itemRandomCurrentPick != null) then 
//#                                 call SaveItemHandle(Missile___HASH, this, GetHandleId(bj_itemRandomCurrentPick), bj_itemRandomCurrentPick) 
//#                                 if ChaoticBoulder___ChaoticBoulder.onItem(this, bj_itemRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if ChaoticBoulder___ChaoticBoulder.onFinish.exists then
//#                             if ChaoticBoulder___ChaoticBoulder.onFinish(this) then
//#                                 call ChaoticBoulder___ChaoticBoulder.MissileStruct__missileTerminateP(this)
//#                             else
//#                                 set this.recycle = false
//#                             endif
//#                         else
                                call s__ChaoticBoulder___ChaoticBoulder_MissileStruct__missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if ChaoticBoulder___ChaoticBoulder.onTerrain.exists then
//#                         if (this.allocated) and (this.z < 0) and ChaoticBoulder___ChaoticBoulder.onTerrain(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if ChaoticBoulder___ChaoticBoulder.onPeriod.exists then
//#                         if (this.allocated) and ChaoticBoulder___ChaoticBoulder.onPeriod(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        // Places the launcher in your struct.
        function s__ChaoticBoulder___ChaoticBoulder_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "ChaoticBoulder___ChaoticBoulder", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertEnd(Missile___missileStack[si__ChaoticBoulder___ChaoticBoulder],missile)
            call Missile___StartPeriodic(si__ChaoticBoulder___ChaoticBoulder)
        endfunction
    
        // Runs onInit. Creates the collection, trigger condition and widget filters.
        function s__ChaoticBoulder___ChaoticBoulder_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__ChaoticBoulder___ChaoticBoulder)
            call Missile___MissileCreateExpression(si__ChaoticBoulder___ChaoticBoulder , function s__ChaoticBoulder___ChaoticBoulder_MissileStruct__missileIterateP)
//#             static if ChaoticBoulder___ChaoticBoulder.onDestructableFilter.exists and ChaoticBoulder___ChaoticBoulder.onDestructable.exists then
//#                 call Missile___MissileCreateDestructableFilter(ChaoticBoulder___ChaoticBoulder.typeid, function ChaoticBoulder___ChaoticBoulder.onDestructableFilter)
//#             endif
//#             static if ChaoticBoulder___ChaoticBoulder.onItemFilter.exists and ChaoticBoulder___ChaoticBoulder.onItem.exists then
//#                 call Missile___MissileCreateItemFilter(ChaoticBoulder___ChaoticBoulder.typeid, function ChaoticBoulder___ChaoticBoulder.onItemFilter)
//#             endif
        endfunction
    
        
    function ChaoticBoulder___OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local integer level= GetUnitAbilityLevel(source, ChaoticBoulder___CHAOTIC_BOULDER_ABILITY)
        local real x= GetUnitX(source)
        local real y= GetUnitY(source)
        //*  Create the main missile.
        local integer missile= s__Missile_createXYZ(x , y , GetUnitFlyHeight(source) , GetSpellTargetX() , GetSpellTargetY() , 0.)
        call ChaoticBoulder___CustomizeBigMissile(missile , s__MissilePosition_distance[s__Missile_origin[missile]] , level)
        set s__Missile_source[missile]=source
        set s__Missile_data[missile]=- 1
        set s__Missile_owner[missile]=GetTriggerPlayer()
        call s__ChaoticBoulder___ChaoticBoulder_launch(missile)
        //*  Runs Effects.
        call DestroyEffect(AddSpecialEffect(ChaoticBoulder___ON_EFFECT_FX, x, y))
        set source=null
    endfunction
    
    function ChaoticBoulder___Init takes nothing returns nothing
        call RegisterSpellEffectEvent(ChaoticBoulder___CHAOTIC_BOULDER_ABILITY , function ChaoticBoulder___OnEffect)
    endfunction
    

//library ChaoticBoulder ends
//library Fireball:
//**
//*  User settings:
//*  ==============
    
    //*  Filter valid target units.
    function Fireball___FilterUnits takes unit target,player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction
    //*  Set the travel distance.
    constant function Fireball___GetFlyDistance takes integer level returns real
        return 800. + ( 200 * level )
    endfunction
    //*  Set the explosion aoe on impact.
    constant function Fireball___GetExplosionRadius takes integer level returns real
        return 200. + ( 0 * level )
    endfunction
    //*  Customize all missile members to your needs. For example there is also arc & curve
    function Fireball___CustomizeMissile takes integer missile,integer level returns nothing
        set s__Missile_speed[missile]=20. + 0. * level
        set s__Missile_damage[missile]=70. + 70. * level
        call s__Missile__set_collision(missile,32.)
        call s__Missile__set_model(missile,"Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl")
        call s__Missile__set_scale(missile,1.)
    endfunction

//========================================================================
//*  Fireball code. Make changes carefully.
//========================================================================
    
    //*  Uses Missile's API. Add or remove whatever you need.
                
        //*  Damages close unit on missile removal.
        function s__Fireball___Fireball_onRemove takes integer missile returns boolean
            local unit u
            call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, s__Missile_x[missile], s__Missile_y[missile], Fireball___GetExplosionRadius(s__Missile_data[missile]), null)
            loop
                set u=FirstOfGroup(s__SpellIndex_GLOBAL_GROUP)
                exitwhen u == null
                call GroupRemoveUnit(s__SpellIndex_GLOBAL_GROUP, u)
                if Fireball___FilterUnits(u , s__Missile_owner[missile]) then
                    call UnitDamageTarget(s__Missile_source[missile], u, s__Missile_damage[missile], false, false, Fireball___ATTACK_TYPE, Fireball___DAMAGE_TYPE, null)
                endif
            endloop
            //*  Run Effects.
            call DestroyEffect(AddSpecialEffectTarget(Fireball___ON_EXPLODE_FX, s__Missile_dummy[missile], "origin"))
            return true
        endfunction
        
        //*  Runs on missile collide with any unit. Explodes on valid targets.
        function s__Fireball___Fireball_onCollide takes integer missile,unit hit returns boolean
            return ( Fireball___FilterUnits(hit , s__Missile_owner[missile]) )
        endfunction
        
//Implemented from module MissileStruct:
        
// Runs check during compile time.
//# static if true then
//#     static if Fireball___Fireball.onMissile.exists then
//#         Error Message from library Missile in struct Fireball___Fireball !
//#         Fireball___Fireball.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         Fireball___Fireball.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif
        
        // Called from missileIterate. "P" to avoid code collision.
        function s__Fireball___Fireball_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if Fireball___Fireball.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
                        if s__Fireball___Fireball_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call Fireball___Fireball.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile___StopPeriodic(si__Fireball___Fireball)
        endfunction
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__Fireball___Fireball_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileStack[si__Fireball___Fireball])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            call s__Missile_move(this) // Moves all missiles of this collection. 
            loop
                exitwhen ( 0 == this )
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if Fireball___Fireball.onFinish.exists then
//#                         if Fireball___Fireball.onFinish(this) then
//#                             call Fireball___Fireball.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__Fireball___Fireball_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                    if ( s__Missile_stackSize[this] > 0 ) then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if Fireball___Fireball.onCollide.exists then
                            if ( s__Missile_allocated[this] ) and ( 0 != s__Missile__get_collision(this) ) then
                                set b=( s__Missile_collisionType[this] == Missile_COLLISION_TYPE_RECTANGLE )
                                if b then
                                    call s__Missile_groupEnumUnitsRectangle(this)
                                else
                                    call GroupEnumUnitsInRange(Missile___GROUP, s__Missile_x[this], s__Missile_y[this], s__Missile__get_collision(this) + Missile_MAXIMUM_COLLISION_SIZE, null)
                                endif
                                loop
                                    set u=FirstOfGroup(Missile___GROUP)
                                    exitwhen u == null
                                    call GroupRemoveUnit(Missile___GROUP, u)
                                    if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
                                        if ( ( IsUnitInRange(u, s__Missile_dummy[this], s__Missile__get_collision(this)) ) or ( b ) ) then
                                            // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
                                                set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                                if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile__get_collisionZ(this) ) and ( collideZ <= s__Missile_z[this] + s__Missile__get_collisionZ(this) ) then
                                                    // Mark as hit.
                                                    call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
                                                    if s__Fireball___Fireball_onCollide(this , u) then
                                                        call s__Fireball___Fireball_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                                endif
        
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if Fireball___Fireball.onCollide(this, u) then
//#                                                 call Fireball___Fireball.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
                                        endif
                                    endif
                                endloop
                            endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if Fireball___Fireball.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkDestCollision(Missile___destFilter[Fireball___Fireball.typeid])
//#                             if (bj_destRandomCurrentPick != null) then 
//#                                 call SaveDestructableHandle(Missile___HASH, this, GetHandleId(bj_destRandomCurrentPick), bj_destRandomCurrentPick) 
//#                                 if Fireball___Fireball.onDestructable(this, bj_destRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if Fireball___Fireball.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkItemCollision(Missile___itemFilter[Fireball___Fireball.typeid])
//#                             if (bj_itemRandomCurrentPick != null) then 
//#                                 call SaveItemHandle(Missile___HASH, this, GetHandleId(bj_itemRandomCurrentPick), bj_itemRandomCurrentPick) 
//#                                 if Fireball___Fireball.onItem(this, bj_itemRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if Fireball___Fireball.onFinish.exists then
//#                             if Fireball___Fireball.onFinish(this) then
//#                                 call Fireball___Fireball.MissileStruct__missileTerminateP(this)
//#                             else
//#                                 set this.recycle = false
//#                             endif
//#                         else
                                call s__Fireball___Fireball_MissileStruct__missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if Fireball___Fireball.onTerrain.exists then
//#                         if (this.allocated) and (this.z < 0) and Fireball___Fireball.onTerrain(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if Fireball___Fireball.onPeriod.exists then
//#                         if (this.allocated) and Fireball___Fireball.onPeriod(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        // Places the launcher in your struct.
        function s__Fireball___Fireball_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "Fireball___Fireball", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertEnd(Missile___missileStack[si__Fireball___Fireball],missile)
            call Missile___StartPeriodic(si__Fireball___Fireball)
        endfunction
    
        // Runs onInit. Creates the collection, trigger condition and widget filters.
        function s__Fireball___Fireball_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__Fireball___Fireball)
            call Missile___MissileCreateExpression(si__Fireball___Fireball , function s__Fireball___Fireball_MissileStruct__missileIterateP)
//#             static if Fireball___Fireball.onDestructableFilter.exists and Fireball___Fireball.onDestructable.exists then
//#                 call Missile___MissileCreateDestructableFilter(Fireball___Fireball.typeid, function Fireball___Fireball.onDestructableFilter)
//#             endif
//#             static if Fireball___Fireball.onItemFilter.exists and Fireball___Fireball.onItem.exists then
//#                 call Missile___MissileCreateItemFilter(Fireball___Fireball.typeid, function Fireball___Fireball.onItemFilter)
//#             endif
        endfunction
    
        
    function Fireball___OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local integer level= GetUnitAbilityLevel(source, Fireball___FIREBALL_ABILITY)
        local real x= GetUnitX(source)
        local real y= GetUnitY(source)
        local real angle= Atan2(GetSpellTargetY() - y, GetSpellTargetX() - x)
        //*  Create a new missile and assign its members.
        local integer missile= s__Missile_create(x , y , Fireball___FIREBALL_FLY_HEIGHT , angle , Fireball___GetFlyDistance(level) , Fireball___FIREBALL_FLY_HEIGHT)
        //*  Allows high level configuration.
        call Fireball___CustomizeMissile(missile , level)
        //*  Override user settings. These missile members are reserved.
        set s__Missile_source[missile]=source
        set s__Missile_owner[missile]=GetTriggerPlayer()
        set s__Missile_data[missile]=level
        call s__Fireball___Fireball_launch(missile)
        set source=null
    endfunction
    
    function Fireball___Init takes nothing returns nothing
        call RegisterSpellEffectEvent(Fireball___FIREBALL_ABILITY , function Fireball___OnEffect)
    endfunction
    

//library Fireball ends
//library FistOfThunder:
//**
//*  User settings:
//*  ==============
    
    //*  Set the slam collision size.
    constant function FistOfThunder___GetSlamCollisionSize takes integer level returns real
        return 180.
    endfunction
    //*  Set the damage dealt on slam.  
    constant function FistOfThunder___GetSlamDamage takes integer level returns real
        return 40. * level - 10.
    endfunction
    //*  Set the travel distance for each missile.
    constant function FistOfThunder___GetMissileFlyDistance takes integer level returns real
        return 600. + ( 50 * level )
    endfunction
    //*  Set the amount of Missiles based on the ability level.
    constant function FistOfThunder___GetMissileCount takes integer level returns integer
        return 4 + 2 * level
    endfunction
    //*  Filter valid target units.
    function FistOfThunder___FilterUnits takes unit target,player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction
    //*  Customize all missile members to your needs.
    function FistOfThunder___CustomizeMissile takes integer missile,integer level returns nothing
        set s__Missile_speed[missile]=22. + 0. * level
        set s__Missile_damage[missile]=10. + 10. * level
        call s__Missile__set_collision(missile,32.)
        call s__Missile__set_model(missile,"Abilities\\Weapons\\SpiritOfVengeanceMissile\\SpiritOfVengeanceMissile.mdl")
        call s__Missile__set_scale(missile,1.)
    endfunction
    //*  These effects run on spell effect event.  Customize them to your needs.  
    function FistOfThunder___RunOnSlamEffects takes unit source,real slamX,real slamY returns nothing
        //*  Runs sounds.
        local string file= "Abilities\\Spells\\Orc\\LightningBolt\\LightningBolt.wav"
        local sound s
        if ( GetRandomInt(0, 1) == 0 ) then
            set file="Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.wav"
        endif
        set s=CreateSound(file, false, false, false, 10, 10, "")
        call AttachSoundToUnit(s, source)
        call StartSound(s)
        call KillSoundWhenDone(s)
        //*  Run special effects.
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", slamX, slamY))
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl", source, "weapon,right"))
        //*
        set s=null
    endfunction
    //*  These effects run when a missile ( source ) collides with a unit ( hit )
    function FistOfThunder___RunOnCollideEffects takes unit source,unit hit returns nothing
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl", hit, "origin"))
    endfunction 
    
//========================================================================
//*  Fist of Thunder code. Make changes carefully.
//========================================================================
    
    //*  Uses Missile's API. For a destructable enum, add .onDestructable and .onDestructableFilter.
        
        //*  Releases the lightning model.
        function s__FistOfThunder___FistOfThunder_onRemove takes integer missile returns boolean
            call s__SpellIndex_destroy((s__Missile_data[missile]))
            return true
        endfunction
        
        function s__FistOfThunder___FistOfThunder_onCollide takes integer missile,unit hit returns boolean
            if FistOfThunder___FilterUnits(hit , s__Missile_owner[missile]) then
                call UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, FistOfThunder___ATTACK_TYPE, FistOfThunder___DAMAGE_TYPE, null)
                call FistOfThunder___RunOnCollideEffects(s__Missile_dummy[missile] , hit)
                return FistOfThunder___DESTROY_MISSILE_ON_COLLIDE
            endif
            return false
        endfunction
        
        function s__FistOfThunder___FistOfThunder_onPeriod takes integer missile returns boolean
            local integer pos= s__Missile_origin[missile]
            call MoveLightningEx(s__SpellIndex_flash[(s__Missile_data[missile])], true, s__MissilePosition_x[pos], s__MissilePosition_y[pos], s__MissilePosition_z[pos], s__Missile_x[missile], s__Missile_y[missile], s__Missile_z[missile] + s__Missile_terrainZ[missile])
            return false
        endfunction
        
//Implemented from module MissileStruct:
        
// Runs check during compile time.
//# static if true then
//#     static if FistOfThunder___FistOfThunder.onMissile.exists then
//#         Error Message from library Missile in struct FistOfThunder___FistOfThunder !
//#         FistOfThunder___FistOfThunder.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         FistOfThunder___FistOfThunder.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif
        
        // Called from missileIterate. "P" to avoid code collision.
        function s__FistOfThunder___FistOfThunder_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if FistOfThunder___FistOfThunder.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
                        if s__FistOfThunder___FistOfThunder_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call FistOfThunder___FistOfThunder.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile___StopPeriodic(si__FistOfThunder___FistOfThunder)
        endfunction
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__FistOfThunder___FistOfThunder_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileStack[si__FistOfThunder___FistOfThunder])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            call s__Missile_move(this) // Moves all missiles of this collection. 
            loop
                exitwhen ( 0 == this )
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if FistOfThunder___FistOfThunder.onFinish.exists then
//#                         if FistOfThunder___FistOfThunder.onFinish(this) then
//#                             call FistOfThunder___FistOfThunder.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__FistOfThunder___FistOfThunder_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                    if ( s__Missile_stackSize[this] > 0 ) then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if FistOfThunder___FistOfThunder.onCollide.exists then
                            if ( s__Missile_allocated[this] ) and ( 0 != s__Missile__get_collision(this) ) then
                                set b=( s__Missile_collisionType[this] == Missile_COLLISION_TYPE_RECTANGLE )
                                if b then
                                    call s__Missile_groupEnumUnitsRectangle(this)
                                else
                                    call GroupEnumUnitsInRange(Missile___GROUP, s__Missile_x[this], s__Missile_y[this], s__Missile__get_collision(this) + Missile_MAXIMUM_COLLISION_SIZE, null)
                                endif
                                loop
                                    set u=FirstOfGroup(Missile___GROUP)
                                    exitwhen u == null
                                    call GroupRemoveUnit(Missile___GROUP, u)
                                    if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
                                        if ( ( IsUnitInRange(u, s__Missile_dummy[this], s__Missile__get_collision(this)) ) or ( b ) ) then
                                            // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
                                                set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                                if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile__get_collisionZ(this) ) and ( collideZ <= s__Missile_z[this] + s__Missile__get_collisionZ(this) ) then
                                                    // Mark as hit.
                                                    call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
                                                    if s__FistOfThunder___FistOfThunder_onCollide(this , u) then
                                                        call s__FistOfThunder___FistOfThunder_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                                endif
        
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if FistOfThunder___FistOfThunder.onCollide(this, u) then
//#                                                 call FistOfThunder___FistOfThunder.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
                                        endif
                                    endif
                                endloop
                            endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if FistOfThunder___FistOfThunder.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkDestCollision(Missile___destFilter[FistOfThunder___FistOfThunder.typeid])
//#                             if (bj_destRandomCurrentPick != null) then 
//#                                 call SaveDestructableHandle(Missile___HASH, this, GetHandleId(bj_destRandomCurrentPick), bj_destRandomCurrentPick) 
//#                                 if FistOfThunder___FistOfThunder.onDestructable(this, bj_destRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if FistOfThunder___FistOfThunder.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkItemCollision(Missile___itemFilter[FistOfThunder___FistOfThunder.typeid])
//#                             if (bj_itemRandomCurrentPick != null) then 
//#                                 call SaveItemHandle(Missile___HASH, this, GetHandleId(bj_itemRandomCurrentPick), bj_itemRandomCurrentPick) 
//#                                 if FistOfThunder___FistOfThunder.onItem(this, bj_itemRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if FistOfThunder___FistOfThunder.onFinish.exists then
//#                             if FistOfThunder___FistOfThunder.onFinish(this) then
//#                                 call FistOfThunder___FistOfThunder.MissileStruct__missileTerminateP(this)
//#                             else
//#                                 set this.recycle = false
//#                             endif
//#                         else
                                call s__FistOfThunder___FistOfThunder_MissileStruct__missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if FistOfThunder___FistOfThunder.onTerrain.exists then
//#                         if (this.allocated) and (this.z < 0) and FistOfThunder___FistOfThunder.onTerrain(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if FistOfThunder___FistOfThunder.onPeriod.exists then
                            if ( s__Missile_allocated[this] ) and s__FistOfThunder___FistOfThunder_onPeriod(this) then
                                call s__FistOfThunder___FistOfThunder_MissileStruct__missileTerminateP(this)
                            endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        // Places the launcher in your struct.
        function s__FistOfThunder___FistOfThunder_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "FistOfThunder___FistOfThunder", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertEnd(Missile___missileStack[si__FistOfThunder___FistOfThunder],missile)
            call Missile___StartPeriodic(si__FistOfThunder___FistOfThunder)
        endfunction
    
        // Runs onInit. Creates the collection, trigger condition and widget filters.
        function s__FistOfThunder___FistOfThunder_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__FistOfThunder___FistOfThunder)
            call Missile___MissileCreateExpression(si__FistOfThunder___FistOfThunder , function s__FistOfThunder___FistOfThunder_MissileStruct__missileIterateP)
//#             static if FistOfThunder___FistOfThunder.onDestructableFilter.exists and FistOfThunder___FistOfThunder.onDestructable.exists then
//#                 call Missile___MissileCreateDestructableFilter(FistOfThunder___FistOfThunder.typeid, function FistOfThunder___FistOfThunder.onDestructableFilter)
//#             endif
//#             static if FistOfThunder___FistOfThunder.onItemFilter.exists and FistOfThunder___FistOfThunder.onItem.exists then
//#                 call Missile___MissileCreateItemFilter(FistOfThunder___FistOfThunder.typeid, function FistOfThunder___FistOfThunder.onItemFilter)
//#             endif
        endfunction
    
    
    function FistOfThunder___Callback takes nothing returns nothing
//#         static if LIBRARY_TimerUtilsEx then
//#             call SpellIndex(ReleaseTimer(GetExpiredTimer())).destroy()
//#         else
                call s__SpellIndex_destroy((GetTimerData(GetExpiredTimer())))
                call ReleaseTimer(GetExpiredTimer())
//#         endif
    endfunction
    
    function FistOfThunder___CreateMissiles takes unit source,player user,real x,real y,integer level returns nothing
        local integer dex= 0
        local integer end= FistOfThunder___GetMissileCount(level)
        local real spacing= bj_PI * 2 / end
        local real angle= GetRandomReal(- bj_PI, bj_PI)
        local real distance= FistOfThunder___GetMissileFlyDistance(level)
        local integer missile
        loop
            exitwhen ( dex == end )
            //*  Create a new missile and assign it's members.
            set missile=s__Missile_create(x , y , 0. , angle , distance , FistOfThunder___MISSILE_END_Z)
            call FistOfThunder___CustomizeMissile(missile , level)
            set s__Missile_source[missile]=source
            set s__Missile_owner[missile]=user
            set s__Missile_data[missile]=s__SpellIndex__allocate()
            set s__SpellIndex_flash[(s__Missile_data[missile])]=AddLightningEx(FistOfThunder___LIGHTNING_MODEL, true, x, y, s__MissilePosition_z[s__Missile_origin[missile]], x, y, s__Missile_z[missile] + s__Missile_terrainZ[missile])
            call s__FistOfThunder___FistOfThunder_launch(missile)
            //*  Next missile.
            set angle=angle + spacing
            set dex=dex + 1
        endloop
    endfunction
    
    function FistOfThunder___OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local player user= GetTriggerPlayer()
        local integer level= GetUnitAbilityLevel(source, FistOfThunder___FIST_OF_THUNDER_ABILITY)
        local real x= GetSpellTargetX()
        local real y= GetSpellTargetY()
        local real damage= FistOfThunder___GetSlamDamage(level)
        local integer dex= s__SpellIndex__allocate()
        local unit u
        //*  Runs Effects.
        call FistOfThunder___RunOnSlamEffects(source , x , y)
        call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, x, y, FistOfThunder___GetSlamCollisionSize(level), null)
        loop
            set u=FirstOfGroup(s__SpellIndex_GLOBAL_GROUP)
            exitwhen u == null
            call GroupRemoveUnit(s__SpellIndex_GLOBAL_GROUP, u)
            if ( FistOfThunder___FilterUnits(u , user) ) then
                call UnitDamageTarget(source, u, damage, false, false, FistOfThunder___ATTACK_TYPE, FistOfThunder___DAMAGE_TYPE, null)
            endif
        endloop
        //*  Create all missiles.
        call FistOfThunder___CreateMissiles(source , user , x , y , level)
        //*  Create center model
        set s__SpellIndex_fx[dex]=AddSpecialEffect(FistOfThunder___SLAM_CENTER_FX, x, y)
        call TimerStart(NewTimerEx(dex), FistOfThunder___SLAM_CENTER_FX_DURATION, false, function FistOfThunder___Callback)
        set user=null
        set source=null
    endfunction
    
    function FistOfThunder___Init takes nothing returns nothing
        call RegisterSpellEffectEvent(FistOfThunder___FIST_OF_THUNDER_ABILITY , function FistOfThunder___OnEffect)
    endfunction

//library FistOfThunder ends
//library GuidedArrow:
//**
//*  User settings:
//*  ==============
    
    // Filter valid target units.
    function GuidedArrow___FilterUnits takes unit target,player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner)
    endfunction
    // Set the maximum travel distance. Does no longer count, when a traget is found.
    constant function GuidedArrow___GetFlyDistance takes integer level returns real
        return 800. + ( 200 * level )
    endfunction
    // Set the number of pierce events. 
    function GuidedArrow___GetPiercingCount takes integer level returns integer
        return GetRandomInt(0, 3) + 1 * level
    endfunction
    //*  Customize all missile members to your needs.
    function GuidedArrow___CustomizeMissile takes integer missile,integer level returns nothing
        set s__Missile_speed[missile]=20. + 0. * level
        set s__Missile_damage[missile]=0. + 30. * level
        call s__Missile__set_collision(missile,32.)
        call s__Missile__set_model(missile,"Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl")
        call s__Missile__set_scale(missile,1.)
    endfunction
    
//========================================================================
// Guided arrow code. Make changes carefully.
//========================================================================

    
    // Filters valid targets for the arrow.
    function GuidedArrow___ConsiderUnitsFiltered takes nothing returns boolean
        return GuidedArrow___FilterUnits(GetFilterUnit() , GuidedArrow___tempOwner)
    endfunction

        
        // Runs when the missile is deallocated.
        function s__GuidedArrow___GuidedArrow_onRemove takes integer missile returns boolean
            call s__SpellIndex_destroy((s__Missile_data[missile]))
            return true
        endfunction
        
        // Runs when the maximum range is reached.
        function s__GuidedArrow___GuidedArrow_onFinish takes integer missile returns boolean
            local integer dex= s__Missile_data[missile]
            return ( s__SpellIndex_phase[dex] == 0 ) or ( GetUnitTypeId(s__SpellIndex_target[dex]) == 0 )
        endfunction
        
        // Runs when a missile collides with a unit.
        function s__GuidedArrow___GuidedArrow_onCollide takes integer missile,unit hit returns boolean
            local integer dex= s__Missile_data[missile]
            // Only the target is valid.
            if ( hit == s__Missile_target[missile] ) then
                // Allows the missile to hit the target again after 1 second.
                call s__Missile_enableHitAfter(missile,hit , GuidedArrow___ALLOW_HIT_AFTER)
                call UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, GuidedArrow___ATTACK_TYPE, GuidedArrow___DAMAGE_TYPE, null)
                set s__Missile_target[missile]=null
                set s__Missile_turn[missile]=0
                // Reduce the total amount of pierces.
                set s__SpellIndex_count[dex]=s__SpellIndex_count[dex] - 1
            endif
            return ( s__SpellIndex_count[dex] < 0 )
        endfunction
        
        function s__GuidedArrow___GuidedArrow_searchTarget takes integer missile returns nothing
            local integer dex= s__Missile_data[missile]
            //
            set GuidedArrow___tempOwner=s__Missile_owner[missile]
            call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, s__Missile_x[missile], s__Missile_y[missile], GuidedArrow___UNIT_DETECTION_AOE, s__GuidedArrow___GuidedArrow_filter)
            if ( FirstOfGroup(s__SpellIndex_GLOBAL_GROUP) != null ) then
                set bj_groupRandomConsidered=0
                set bj_groupRandomCurrentPick=null
                call ForGroup(s__SpellIndex_GLOBAL_GROUP, function GroupPickRandomUnitEnum)
                call GroupClear(s__SpellIndex_GLOBAL_GROUP)
                // 
                set s__Missile_target[missile]=bj_groupRandomCurrentPick
                set s__SpellIndex_target[dex]=bj_groupRandomCurrentPick
                set s__SpellIndex_time[dex]=GuidedArrow___ARROW_ACTION_DELAY
                set s__Missile_turn[missile]=GuidedArrow___ARROW_TURN_RATE
                // Just in case this unit was already hit, while missile.target was null.
                // Remember: onCollide runs before onPeriod.
                call s__Missile_removeHitWidget(missile,bj_groupRandomCurrentPick)
                //
                set bj_groupRandomCurrentPick=null
                if ( s__SpellIndex_fx[dex] != null ) then
                    call DestroyEffect(s__SpellIndex_fx[dex])
                    set s__SpellIndex_fx[dex]=null
                endif
                set s__SpellIndex_fx[dex]=AddSpecialEffectTarget(GuidedArrow___ON_TARGET_FX, s__SpellIndex_target[dex], GuidedArrow___FX_ATTACH_POINT)
            endif
        endfunction
        
        // Runs every timer interval. Let's break the mechanics down.
        function s__GuidedArrow___GuidedArrow_onPeriod takes integer missile returns boolean
            local integer dex= s__Missile_data[missile]
            
            // In this phase no target was found yet. And no pierce event did take place.
            if ( s__SpellIndex_target[dex] == null ) and ( s__SpellIndex_count[dex] >= 0 ) then
                // Check the action delay.
                if ( s__SpellIndex_time[dex] > 0. ) then
                    set s__SpellIndex_time[dex]=s__SpellIndex_time[dex] - Missile_TIMER_TIMEOUT
                    return false
                endif
                call s__GuidedArrow___GuidedArrow_searchTarget(missile)
            //
            // In this phase we have a target stored on dex.target, but the missile doesn't know that.
            elseif ( s__Missile_target[missile] == null ) and ( UnitAlive(s__SpellIndex_target[dex]) ) then
                // Check the action delay.
                if ( s__SpellIndex_time[dex] > 0. ) then
                    set s__SpellIndex_time[dex]=s__SpellIndex_time[dex] - Missile_TIMER_TIMEOUT
                    return false
                endif
                set s__SpellIndex_time[dex]=GuidedArrow___ARROW_ACTION_DELAY
                set s__Missile_turn[missile]=GuidedArrow___ARROW_TURN_RATE
                set s__Missile_target[missile]=s__SpellIndex_target[dex]
            //
            // In this phase the target died. Let the missile run out.
            elseif not UnitAlive(s__SpellIndex_target[dex]) then
                set s__SpellIndex_count[dex]=- 1
                set s__SpellIndex_target[dex]=null
                set s__Missile_turn[missile]=0.
                set s__Missile_target[missile]=null
                call s__Missile__set_collision(missile,0.)
                if ( s__SpellIndex_phase[dex] == 1 ) then
                    set s__SpellIndex_phase[dex]=0
                    call s__MissilePosition_move(s__Missile_origin[missile],s__Missile_x[missile] , s__Missile_y[missile] , s__Missile_z[missile])
                    call s__MissilePosition_move(s__Missile_impact[missile],s__Missile_x[missile] + Cos(s__Missile_angle[missile]) * GuidedArrow___ARROW_FLY_RUN_OUT_DISTANCE , s__Missile_y[missile] + Sin(s__Missile_angle[missile]) * GuidedArrow___ARROW_FLY_RUN_OUT_DISTANCE , s__Missile_z[missile])
                endif
            endif
            return false
        endfunction

//Implemented from module MissileStruct:
        
// Runs check during compile time.
//# static if true then
//#     static if GuidedArrow___GuidedArrow.onMissile.exists then
//#         Error Message from library Missile in struct GuidedArrow___GuidedArrow !
//#         GuidedArrow___GuidedArrow.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         GuidedArrow___GuidedArrow.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif
        
        // Called from missileIterate. "P" to avoid code collision.
        function s__GuidedArrow___GuidedArrow_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if GuidedArrow___GuidedArrow.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
                        if s__GuidedArrow___GuidedArrow_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call GuidedArrow___GuidedArrow.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile___StopPeriodic(si__GuidedArrow___GuidedArrow)
        endfunction
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__GuidedArrow___GuidedArrow_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileStack[si__GuidedArrow___GuidedArrow])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            call s__Missile_move(this) // Moves all missiles of this collection. 
            loop
                exitwhen ( 0 == this )
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if GuidedArrow___GuidedArrow.onFinish.exists then
                            if s__GuidedArrow___GuidedArrow_onFinish(this) then
                                call s__GuidedArrow___GuidedArrow_MissileStruct__missileTerminateP(this)
                            endif
//#                     else
//#                         call GuidedArrow___GuidedArrow.MissileStruct__missileTerminateP(this)
//#                     endif
                else
                    if ( s__Missile_stackSize[this] > 0 ) then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if GuidedArrow___GuidedArrow.onCollide.exists then
                            if ( s__Missile_allocated[this] ) and ( 0 != s__Missile__get_collision(this) ) then
                                set b=( s__Missile_collisionType[this] == Missile_COLLISION_TYPE_RECTANGLE )
                                if b then
                                    call s__Missile_groupEnumUnitsRectangle(this)
                                else
                                    call GroupEnumUnitsInRange(Missile___GROUP, s__Missile_x[this], s__Missile_y[this], s__Missile__get_collision(this) + Missile_MAXIMUM_COLLISION_SIZE, null)
                                endif
                                loop
                                    set u=FirstOfGroup(Missile___GROUP)
                                    exitwhen u == null
                                    call GroupRemoveUnit(Missile___GROUP, u)
                                    if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
                                        if ( ( IsUnitInRange(u, s__Missile_dummy[this], s__Missile__get_collision(this)) ) or ( b ) ) then
                                            // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
                                                set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                                if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile__get_collisionZ(this) ) and ( collideZ <= s__Missile_z[this] + s__Missile__get_collisionZ(this) ) then
                                                    // Mark as hit.
                                                    call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
                                                    if s__GuidedArrow___GuidedArrow_onCollide(this , u) then
                                                        call s__GuidedArrow___GuidedArrow_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                                endif
        
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if GuidedArrow___GuidedArrow.onCollide(this, u) then
//#                                                 call GuidedArrow___GuidedArrow.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
                                        endif
                                    endif
                                endloop
                            endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if GuidedArrow___GuidedArrow.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkDestCollision(Missile___destFilter[GuidedArrow___GuidedArrow.typeid])
//#                             if (bj_destRandomCurrentPick != null) then 
//#                                 call SaveDestructableHandle(Missile___HASH, this, GetHandleId(bj_destRandomCurrentPick), bj_destRandomCurrentPick) 
//#                                 if GuidedArrow___GuidedArrow.onDestructable(this, bj_destRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if GuidedArrow___GuidedArrow.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkItemCollision(Missile___itemFilter[GuidedArrow___GuidedArrow.typeid])
//#                             if (bj_itemRandomCurrentPick != null) then 
//#                                 call SaveItemHandle(Missile___HASH, this, GetHandleId(bj_itemRandomCurrentPick), bj_itemRandomCurrentPick) 
//#                                 if GuidedArrow___GuidedArrow.onItem(this, bj_itemRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if GuidedArrow___GuidedArrow.onFinish.exists then
                                if s__GuidedArrow___GuidedArrow_onFinish(this) then
                                    call s__GuidedArrow___GuidedArrow_MissileStruct__missileTerminateP(this)
                                else
                                    set s__Missile_recycle[this]=false
                                endif
//#                         else
//#                             call GuidedArrow___GuidedArrow.MissileStruct__missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if GuidedArrow___GuidedArrow.onTerrain.exists then
//#                         if (this.allocated) and (this.z < 0) and GuidedArrow___GuidedArrow.onTerrain(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if GuidedArrow___GuidedArrow.onPeriod.exists then
                            if ( s__Missile_allocated[this] ) and s__GuidedArrow___GuidedArrow_onPeriod(this) then
                                call s__GuidedArrow___GuidedArrow_MissileStruct__missileTerminateP(this)
                            endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        // Places the launcher in your struct.
        function s__GuidedArrow___GuidedArrow_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "GuidedArrow___GuidedArrow", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertEnd(Missile___missileStack[si__GuidedArrow___GuidedArrow],missile)
            call Missile___StartPeriodic(si__GuidedArrow___GuidedArrow)
        endfunction
    
        // Runs onInit. Creates the collection, trigger condition and widget filters.
        function s__GuidedArrow___GuidedArrow_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__GuidedArrow___GuidedArrow)
            call Missile___MissileCreateExpression(si__GuidedArrow___GuidedArrow , function s__GuidedArrow___GuidedArrow_MissileStruct__missileIterateP)
//#             static if GuidedArrow___GuidedArrow.onDestructableFilter.exists and GuidedArrow___GuidedArrow.onDestructable.exists then
//#                 call Missile___MissileCreateDestructableFilter(GuidedArrow___GuidedArrow.typeid, function GuidedArrow___GuidedArrow.onDestructableFilter)
//#             endif
//#             static if GuidedArrow___GuidedArrow.onItemFilter.exists and GuidedArrow___GuidedArrow.onItem.exists then
//#                 call Missile___MissileCreateItemFilter(GuidedArrow___GuidedArrow.typeid, function GuidedArrow___GuidedArrow.onItemFilter)
//#             endif
        endfunction
    

    function GuidedArrow___OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local integer level= GetUnitAbilityLevel(source, GuidedArrow___GUIDED_ARROW_ABILITY)
        local real x= GetUnitX(source)
        local real y= GetUnitY(source)
        local real angle= Atan2(GetSpellTargetY() - y, GetSpellTargetX() - x)
        local integer dex= s__SpellIndex__allocate()
        // Create a new missile and assign its members.
        local integer missile= s__Missile_create(x , y , GuidedArrow___ARROW_FLY_HEIGHT , angle , GuidedArrow___GetFlyDistance(level) , GuidedArrow___ARROW_FLY_HEIGHT)
        // Allows configuration.
        call GuidedArrow___CustomizeMissile(missile , level)
        // Override user settings. These missile members are reserved.
        set s__Missile_source[missile]=source
        set s__Missile_owner[missile]=GetTriggerPlayer()
        set s__Missile_data[missile]=dex
        set s__Missile_target[missile]=null
        call s__GuidedArrow___GuidedArrow_launch(missile)
        // Assign data to the spell index.
        set s__SpellIndex_count[dex]=GuidedArrow___GetPiercingCount(level)
        set s__SpellIndex_time[dex]=GuidedArrow___ARROW_ACTION_DELAY
        set s__SpellIndex_target[dex]=GetSpellTargetUnit()
        if not GuidedArrow___FilterUnits(s__SpellIndex_target[dex] , s__Missile_owner[missile]) then
            set s__SpellIndex_target[dex]=null
        endif
        set s__SpellIndex_phase[dex]=1
        // Run effects.
        if ( s__SpellIndex_target[dex] != null ) then
            set s__SpellIndex_fx[dex]=AddSpecialEffectTarget(GuidedArrow___ON_TARGET_FX, s__SpellIndex_target[dex], GuidedArrow___FX_ATTACH_POINT)
        endif
        set source=null
    endfunction

    function GuidedArrow___Init takes nothing returns nothing
        set s__GuidedArrow___GuidedArrow_filter=Filter(function GuidedArrow___ConsiderUnitsFiltered)
        call RegisterSpellEffectEvent(GuidedArrow___GUIDED_ARROW_ABILITY , function GuidedArrow___OnEffect)
    endfunction


//library GuidedArrow ends
//library IceSiege:
//**
//*  User settings:
//*  ==============
    
    //*  Filter out which units should recieve period damage.
    function IceSiege___FilterUnits takes unit target,player p returns boolean
        return ( UnitAlive(target) ) and ( IsUnitEnemy(target, p) ) and ( not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) )
    endfunction
    //*  Set the damage.
    constant function IceSiege___GetDamage takes integer level returns real
        return 45. + ( 10 * level )
    endfunction
    //*  Set how often periodic damage is applied.
    constant function IceSiege___GetWaves takes integer level returns integer
        return 4 + 0 * level
    endfunction
    //*  Set the collision size of the spell.
    constant function IceSiege___GetRange takes integer level returns integer
        return 400 + 100 * level
    endfunction

//========================================================================
//*  Ice siege code. Make changes carefully.
//========================================================================
    
    function IceSiege___OnPeriodic takes nothing returns nothing
        local integer dex= GetTimerData(GetExpiredTimer())
        local unit u
        if ( s__SpellIndex_count[dex] > 0 ) and UnitAlive(s__SpellIndex_source[dex]) then
            set s__SpellIndex_count[dex]=s__SpellIndex_count[dex] - 1
            call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, GetUnitX(s__SpellIndex_source[dex]), GetUnitY(s__SpellIndex_source[dex]), s__SpellIndex_collision[dex], null)
            loop
                set u=FirstOfGroup(s__SpellIndex_GLOBAL_GROUP)
                exitwhen u == null
                call GroupRemoveUnit(s__SpellIndex_GLOBAL_GROUP, u)
                if ( IceSiege___FilterUnits(u , s__SpellIndex_user[dex]) ) then
                    call s__DummyCaster_castTarget((IceSiege___BUFF_CAST_ID),s__SpellIndex_user[dex] , 1 , IceSiege___ORDER_ID , u)
                    call UnitDamageTarget(s__SpellIndex_source[dex], u, s__SpellIndex_damage[dex], false, false, IceSiege___ATTACK_TYPE, IceSiege___DAMAGE_TYPE, null)
                endif
            endloop
        else
            call s__SpellIndex_destroy(dex) //*  Nulls all members automatically.
            call ReleaseTimer(GetExpiredTimer())
        endif
    endfunction
        
    function IceSiege___OnEffect takes nothing returns nothing
        local integer level= GetUnitAbilityLevel(GetTriggerUnit(), IceSiege___ICE_SIEGE_ABILITY)
        //*  Allocate a spell index and assign members.
        local integer dex= s__SpellIndex__allocate()
        set s__SpellIndex_user[dex]=GetTriggerPlayer()
        set s__SpellIndex_source[dex]=GetTriggerUnit()
        set s__SpellIndex_damage[dex]=IceSiege___GetDamage(level)
        set s__SpellIndex_collision[dex]=IceSiege___GetRange(level)
        set s__SpellIndex_count[dex]=IceSiege___GetWaves(level)
        set s__SpellIndex_fx[dex]=AddSpecialEffectTarget(IceSiege___ON_CASTER_FX, s__SpellIndex_source[dex], IceSiege___FX_ATTACH_POINT)
        call TimerStart(NewTimerEx(dex), IceSiege___TIMER_TIMEOUT, true, function IceSiege___OnPeriodic)
    endfunction
        
    function IceSiege___Init takes nothing returns nothing
        call RegisterSpellEffectEvent(IceSiege___ICE_SIEGE_ABILITY , function IceSiege___OnEffect)
    endfunction
    

//library IceSiege ends
//library Leap:
//**
//*  User settings:
//*  ==============
    //*  The slow duration is hardcoded in the leap buff. Change it there.
    
    //*  Set the impact damage.
    constant function Leap___GetImpactDamage takes integer level returns real
        return 0. + 70 * level
    endfunction
    //*  Set the arc of the unit. Play a bit with the values to find a good setup.
    function Leap___GetArc takes real distance returns real
        return 45. * bj_DEGTORAD + RMinBJ(20., distance * .1) * bj_DEGTORAD
    endfunction
    //*  Set the damage collision radius on leap finish.
    function Leap___GetDamageRadius takes integer level returns real
        return 190. + 0. * level
    endfunction
    //*  Set the total air time. Returning 0. is invalid! 
    //* The current setup is -->  minimum + (distance/2)/movement speed.
    function Leap___GetAirTime takes real distance,integer level returns real
        return .3 + ( distance * .5 ) / 500.
    endfunction
    //*  Set the offset for the damage effects. It's an empirical value. 
    constant function Leap___GetUnitWeaponOffset takes unit source returns real
        return 75.
    endfunction
    //*  Read the animation time out from the object editor field for your unit.
    //* The current setup is --> slam animation time blademaster 1.133
    constant function Leap___GetUnitAnimationTime takes unit source returns real
        return 1.133
    endfunction
    //*  Filter valid targets.
    function Leap___FilterUnits takes unit target,player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_FLYING)
    endfunction
    //*  Code which should run on finish leap.
    function Leap___OnFinishLeap takes unit source returns nothing
        if UnitAlive(source) then
            call CameraSetEQNoise(GetOwningPlayer(source) , 3. , .33)
        endif
    endfunction
    
//========================================================================
//*  Leap code. Make changes carefully.
//========================================================================

    //*  Quite useful, you may outsource it and make it a public function.
    function Leap___IsPointJumpable takes real x,real y returns boolean
        if not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
            return IsTerrainWalkable(x , y)
        endif
        return false
    endfunction
    
    
    //*  Uses Missile's API. For a destructable enum, add .onDestructable and .onDestructableFilter.
        
        //*  Runs on finish.
        function s__Leap___Leap_onFinish takes integer missile returns boolean
            local unit source= s__Missile_dummy[missile]
            local real unitX= GetUnitX(source)
            local real unitY= GetUnitY(source)
            local real posX= unitX + Leap___GetUnitWeaponOffset(source) * Cos(s__Missile_angle[missile])
            local real posY= unitY + Leap___GetUnitWeaponOffset(source) * Sin(s__Missile_angle[missile])
            local unit u
            //*  Restore pathing.
            call SetUnitPathing(source, true)
            if UnitAlive(source) then
                //*  Run effects.
                call DestroyEffect(AddSpecialEffect(Leap___ON_LANDING_FX, posX, posY))
                call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, posX, posY, s__Missile__get_collision(missile), null)
                loop
                    set u=FirstOfGroup(s__SpellIndex_GLOBAL_GROUP)
                    exitwhen u == null
                    call GroupRemoveUnit(s__SpellIndex_GLOBAL_GROUP, u)
                    if ( Leap___FilterUnits(u , s__Missile_owner[missile]) ) then
                        //*  Make pathing space for the leaping unit.
                        call SetUnitPosition(u, GetUnitX(u), GetUnitY(u))
                        //*  Deal damage and apply the buff.
                        if ( UnitDamageTarget(source, u, s__Missile_damage[missile], false, false, Leap___ATTACK_TYPE, Leap___DAMAGE_TYPE, null) ) then
                            call s__DummyCaster_castTarget((Leap___BUFF_CAST_ID),s__Missile_owner[missile] , 1 , Leap___ORDER_ID , u)
                        endif
                    endif
                endloop
            endif
            call SetUnitPosition(source, unitX, unitY)
            call Leap___OnFinishLeap(source)
            call SetUnitTimeScale(source, 1.)
            call s__SpellIndex_destroy((s__Missile_data[missile]))
            set source=null
            return true
        endfunction
        
//Implemented from module MissileStruct:
        
// Runs check during compile time.
//# static if true then
//#     static if Leap___Leap.onMissile.exists then
//#         Error Message from library Missile in struct Leap___Leap !
//#         Leap___Leap.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         Leap___Leap.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif
        
        // Called from missileIterate. "P" to avoid code collision.
        function s__Leap___Leap_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if Leap___Leap.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
//#                     if Leap___Leap.onRemove(node) and (GetUnitTypeId(node.dummy) == Missile_DUMMY_UNIT_ID) then
//#                         call Missile___RecycleBin.recycle(node.dummy)
//#                         call node.nullBefore()
//#                     endif
//#                 else
//#                     call Leap___Leap.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile___StopPeriodic(si__Leap___Leap)
        endfunction
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__Leap___Leap_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileStack[si__Leap___Leap])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            call s__Missile_move(this) // Moves all missiles of this collection. 
            loop
                exitwhen ( 0 == this )
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if Leap___Leap.onFinish.exists then
                            if s__Leap___Leap_onFinish(this) then
                                call s__Leap___Leap_MissileStruct__missileTerminateP(this)
                            endif
//#                     else
//#                         call Leap___Leap.MissileStruct__missileTerminateP(this)
//#                     endif
                else
                    if ( s__Missile_stackSize[this] > 0 ) then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if Leap___Leap.onCollide.exists then
//#                         if (this.allocated) and (0 != this.collision) then
//#                             set b = (this.collisionType == Missile_COLLISION_TYPE_RECTANGLE)  
//#                             if b then
//#                                 call this.groupEnumUnitsRectangle()
//#                             else
//#                                 call GroupEnumUnitsInRange(Missile___GROUP, this.x, this.y, this.collision + Missile_MAXIMUM_COLLISION_SIZE, null)
//#                             endif
//#                             loop
//#                                 set u = FirstOfGroup(Missile___GROUP)
//#                                 exitwhen u == null
//#                                 call GroupRemoveUnit(Missile___GROUP, u)
//#                                 if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
//#                                     if ((IsUnitInRange(u, this.dummy, this.collision)) or (b)) then  
//#                                         // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
//#                                             set collideZ = Missile_GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u) - this.terrainZ
//#                                             if (collideZ + GetUnitBodySize(u) >= this.z - this.collisionZ) and (collideZ <= this.z + this.collisionZ) then
//#                                                 // Mark as hit.
//#                                                 call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                                 if Leap___Leap.onCollide(this, u) then
//#                                                     call Leap___Leap.MissileStruct__missileTerminateP(this)
//#                                                     exitwhen true
//#                                                 endif
//#                                             endif
//#     
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if Leap___Leap.onCollide(this, u) then
//#                                                 call Leap___Leap.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
//#                                     endif                                    
//#                                 endif
//#                             endloop
//#                         endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if Leap___Leap.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkDestCollision(Missile___destFilter[Leap___Leap.typeid])
//#                             if (bj_destRandomCurrentPick != null) then 
//#                                 call SaveDestructableHandle(Missile___HASH, this, GetHandleId(bj_destRandomCurrentPick), bj_destRandomCurrentPick) 
//#                                 if Leap___Leap.onDestructable(this, bj_destRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if Leap___Leap.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             call this.checkItemCollision(Missile___itemFilter[Leap___Leap.typeid])
//#                             if (bj_itemRandomCurrentPick != null) then 
//#                                 call SaveItemHandle(Missile___HASH, this, GetHandleId(bj_itemRandomCurrentPick), bj_itemRandomCurrentPick) 
//#                                 if Leap___Leap.onItem(this, bj_itemRandomCurrentPick) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             endif
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if Leap___Leap.onFinish.exists then
                                if s__Leap___Leap_onFinish(this) then
                                    call s__Leap___Leap_MissileStruct__missileTerminateP(this)
                                else
                                    set s__Missile_recycle[this]=false
                                endif
//#                         else
//#                             call Leap___Leap.MissileStruct__missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if Leap___Leap.onTerrain.exists then
//#                         if (this.allocated) and (this.z < 0) and Leap___Leap.onTerrain(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if Leap___Leap.onPeriod.exists then
//#                         if (this.allocated) and Leap___Leap.onPeriod(this) then
//#                             call MissileStruct__missileTerminateP(this)
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        // Places the launcher in your struct.
        function s__Leap___Leap_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "Leap___Leap", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertEnd(Missile___missileStack[si__Leap___Leap],missile)
            call Missile___StartPeriodic(si__Leap___Leap)
        endfunction
    
        // Runs onInit. Creates the collection, trigger condition and widget filters.
        function s__Leap___Leap_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__Leap___Leap)
            call Missile___MissileCreateExpression(si__Leap___Leap , function s__Leap___Leap_MissileStruct__missileIterateP)
//#             static if Leap___Leap.onDestructableFilter.exists and Leap___Leap.onDestructable.exists then
//#                 call Missile___MissileCreateDestructableFilter(Leap___Leap.typeid, function Leap___Leap.onDestructableFilter)
//#             endif
//#             static if Leap___Leap.onItemFilter.exists and Leap___Leap.onItem.exists then
//#                 call Missile___MissileCreateItemFilter(Leap___Leap.typeid, function Leap___Leap.onItemFilter)
//#             endif
        endfunction
    
    
    function Leap___OnEffect takes nothing returns nothing
        local string prefix= "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffcc00"
        local unit source= GetTriggerUnit()
        local integer level=  GetUnitAbilityLevel(source, Leap___LEAP_ABILITY)
        local real time
        local real distance
        local integer missile
        //*  Check for terrain pathability.
        if Leap___IsPointJumpable(GetSpellTargetX() , GetSpellTargetY()) then
            //*  Make sure the caster can fly.
            if UnitAddAbility(source, 'Amrf') and UnitRemoveAbility(source, 'Amrf') then
            endif
            //*  Transform the source unit into a Missile instance.
            set missile=s__Missile_createEx(source , GetSpellTargetX() , GetSpellTargetY() , GetUnitDefaultFlyHeight(source))
            set distance=s__MissilePosition_distance[s__Missile_origin[missile]]
            set time=Leap___GetAirTime(distance , level)
            call s__Missile__set_arc(missile,Leap___GetArc(distance))
            set s__Missile_speed[missile]=distance / time * Missile_TIMER_TIMEOUT
            set s__Missile_owner[missile]=GetTriggerPlayer()
            set s__Missile_damage[missile]=Leap___GetImpactDamage(level)
            call s__Missile__set_collision(missile,Leap___GetDamageRadius(level))
            call s__Leap___Leap_launch(missile)
            //*  Add effect.
            set s__Missile_data[missile]=s__SpellIndex__allocate()
            set s__SpellIndex_fx[(s__Missile_data[missile])]=AddSpecialEffectTarget(Leap___WHILE_LEAPING_FX, source, Leap___FX_ATTACH_POINT)
            //*
            call SetUnitTimeScale(source, Leap___GetUnitAnimationTime(source) * .5 / time)
            call SetUnitPathing(source, false)
        else
            //*  Invalid jump location!
            call PauseUnit(source, true)
            call IssueImmediateOrderById(source, 851972)
            call PauseUnit(source, false)
            //*  Simulate Warcraft III error message.
            if GetLocalPlayer() == GetTriggerPlayer() then
                call StartSound(Leap___error)
                call ClearTextMessages()
            endif
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), .52, .96, 2., prefix + GetUnitName(source) + " can't jump there!|r")
        endif
        set source=null
    endfunction
    
    function Leap___Init takes nothing returns nothing
        set Leap___error=CreateSoundFromLabel("InterfaceError", false, false, false, 10, 10)
        call RegisterSpellEffectEvent(Leap___LEAP_ABILITY , function Leap___OnEffect)
    endfunction
    

//library Leap ends
//library ReapersScythe:
//**
//*  User settings:
//*  ==============
    
    //*  Set the damage factor. The original Dota setup would be 0.4, 0.6, 0.9
    constant function ReapersScythe___GetDamageFactor takes integer level returns real
        return 0.2 + ( 0.2 * level )
    endfunction
    
//========================================================================
//*  Reaper's scythe code. Make changes carefully.
//========================================================================

    function ReapersScythe___Callback takes nothing returns nothing
        local integer dex= GetTimerData(GetExpiredTimer())
        local real life= GetUnitState(s__SpellIndex_target[dex], UNIT_STATE_MAX_LIFE) - GetWidgetLife(s__SpellIndex_target[dex])
        if UnitAlive(s__SpellIndex_target[dex]) and ( GetUnitTypeId(s__SpellIndex_source[dex]) != 0 ) then
            call DestroyEffect(AddSpecialEffectTarget(ReapersScythe___ON_DAMAGE_FX, s__SpellIndex_target[dex], ReapersScythe___DAMAGE_FX_ATTACH_POINT))
            call UnitDamageTarget(s__SpellIndex_source[dex], s__SpellIndex_target[dex], s__SpellIndex_damage[dex] * life, false, false, ReapersScythe___ATTACK_TYPE, ReapersScythe___DAMAGE_TYPE, null)
        endif
        call s__SpellIndex_destroy(dex) //*  Null automatically all members.
        call ReleaseTimer(GetExpiredTimer())
    endfunction
    
    function ReapersScythe___OnEffect takes nothing returns nothing
        //*  Get event variables now, because DummyCaster will override them.
        local unit target= GetSpellTargetUnit()
        local unit source= GetTriggerUnit()
        local integer dex
        //*  Conditionally create a spell index.
        if s__DummyCaster_castTarget((ReapersScythe___BUFF_CAST_ID),GetTriggerPlayer() , 1 , ReapersScythe___ORDER_ID , target) then
            set dex=s__SpellIndex__allocate()
            set s__SpellIndex_source[dex]=source
            set s__SpellIndex_target[dex]=target
            //*  Hardcoded ubersplat handle. I think you'll like it.
            set s__SpellIndex_splat[dex]=CreateUbersplat(GetUnitX(target), GetUnitY(target), "HFS1", 255, 255, 255, 150, true, true)
            set s__SpellIndex_fx[dex]=AddSpecialEffectTarget(ReapersScythe___ON_GROUND_FX, target, ReapersScythe___GROUND_FX_ATTACH_POINT)
            set s__SpellIndex_damage[dex]=ReapersScythe___GetDamageFactor(GetUnitAbilityLevel(source, ReapersScythe___REAPERS_SCYTHE_ABILITY))
            call SetUbersplatRenderAlways(s__SpellIndex_splat[dex], true)
            call TimerStart(NewTimerEx(dex), ReapersScythe___STUN_DURATION, false, function ReapersScythe___Callback)
        endif
        set source=null
        set target=null
    endfunction
        
    function ReapersScythe___Init takes nothing returns nothing
        call RegisterSpellEffectEvent(ReapersScythe___REAPERS_SCYTHE_ABILITY , function ReapersScythe___OnEffect)
    endfunction
    

//library ReapersScythe ends
//library Whirlwind:
//**
//*  User settings:
//*  ==============
    //*  Set the damage dealt per timer timeout.
    constant function Whirlwind___GetDamage takes integer level returns real
        return 0.00 + level * 50.00
    endfunction
    //*  Set the collision size.
    constant function Whirlwind___GetCollision takes integer level returns real
        return 200.
    endfunction
    //*  Filter valid target units.
    function Whirlwind___FilterUnits takes unit target,player owner returns boolean
        return IsUnitEnemy(target, owner) and UnitAlive(target)
    endfunction
    
//========================================================================
//*  Whirlwind code. Make changes carefully.
//========================================================================
        
        
    function Whirlwind___Clear takes integer dex returns nothing
//#         static if Whirlwind___DISABLE_ATTACK then
                if ( s__SpellIndex_count[dex] == 0 ) then
                    call UnitRemoveAbility(s__SpellIndex_source[dex], 'Abun')
                endif
//#         endif
        call s__Table_remove(Whirlwind___table,GetHandleId(s__SpellIndex_source[dex]))
        call AddUnitAnimationProperties(s__SpellIndex_source[dex], "spin", false)
        call UnitRemoveAbility(s__SpellIndex_source[dex], Whirlwind___WHIRLWIND_BUFF)
        call ReleaseTimer(s__SpellIndex_clock[dex])
        call s__SpellIndex_destroy(dex)
    endfunction
        
    function Whirlwind___OnPeriodic takes nothing returns nothing
        local integer dex= GetTimerData(GetExpiredTimer())
        local unit u
        if UnitAlive(s__SpellIndex_source[dex]) and ( GetUnitAbilityLevel(s__SpellIndex_source[dex], Whirlwind___WHIRLWIND_BUFF) != 0 ) then
            call GroupEnumUnitsInRange(s__SpellIndex_GLOBAL_GROUP, GetUnitX(s__SpellIndex_source[dex]), GetUnitY(s__SpellIndex_source[dex]), s__SpellIndex_collision[dex], null)
            loop
                set u=FirstOfGroup(s__SpellIndex_GLOBAL_GROUP)
                exitwhen null == u
                call GroupRemoveUnit(s__SpellIndex_GLOBAL_GROUP, u)
                if Whirlwind___FilterUnits(u , s__SpellIndex_user[dex]) then
                    call UnitDamageTarget(s__SpellIndex_source[dex], u, s__SpellIndex_damage[dex], false, false, Whirlwind___ATTACK_TYPE, Whirlwind___DAMAGE_TYPE, null)
                endif
            endloop
        else
            call Whirlwind___Clear(dex)
        endif
    endfunction
        
    function Whirlwind___OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local integer dex= s__SpellIndex__allocate()
        set s__SpellIndex_source[dex]=source
        set s__SpellIndex_level[dex]=GetUnitAbilityLevel(source, Whirlwind___WHIRLWIND_ABILITY)
        set s__SpellIndex_damage[dex]=Whirlwind___GetDamage(s__SpellIndex_level[dex])
        set s__SpellIndex_collision[dex]=Whirlwind___GetCollision(s__SpellIndex_level[dex])
        set s__SpellIndex_user[dex]=GetTriggerPlayer()
        //*  Run effects.
        call SetUnitAnimation(source, "spin")
        call AddUnitAnimationProperties(source, "spin", true)
//#         static if Whirlwind___DISABLE_ATTACK then
                set s__SpellIndex_count[dex]=GetUnitAbilityLevel(source, 'Abun')
                if ( s__SpellIndex_count[dex] == 0 ) then
                    call UnitAddAbility(source, 'Abun')
                endif
//#         endif
        set s__SpellIndex_clock[dex]=NewTimerEx(dex)
        call TimerStart(s__SpellIndex_clock[dex], Whirlwind___TIMER_TIMEOUT, true, function Whirlwind___OnPeriodic)
        //*
        call s__Table__setindex(Whirlwind___table,GetHandleId(source), dex)
        set source=null
    endfunction
    
    function Whirlwind___OnOrder takes nothing returns nothing
        local unit source= GetTriggerUnit()
        if ( GetIssuedOrderId() == 852178 ) and ( GetUnitAbilityLevel(source, Whirlwind___WHIRLWIND_BUFF) != 0 ) and s__Table_has(Whirlwind___table,GetHandleId(source)) then
            //*  For pause units the clear function will not work at all.
            if not ( IsUnitPaused(source) ) then
                call Whirlwind___Clear(s__Table__getindex(Whirlwind___table,GetHandleId(source)))
            endif
        endif
        set source=null
    endfunction
  
    function Whirlwind___Init takes nothing returns nothing
        set Whirlwind___table=s__Table_create()
        call RegisterSpellEffectEvent(Whirlwind___WHIRLWIND_ABILITY , function Whirlwind___OnEffect)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER , function Whirlwind___OnOrder)
    endfunction
    

//library Whirlwind ends
//===========================================================================
// 
// Simple Spell Collection #1
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Tue Jan 19 17:22:18 2016
//   Map Author: BPower
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
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateBuildingsForPlayer1 takes nothing returns nothing
    local player p= Player(1)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'hgtw', - 1152.0, - 2624.0, 270.000)
    set u=CreateUnit(p, 'hgtw', - 1920.0, - 1984.0, 270.000)
    set u=CreateUnit(p, 'hgtw', - 1984.0, - 2688.0, 270.000)
endfunction

//===========================================================================
function CreateBuildingsForPlayer2 takes nothing returns nothing
    local player p= Player(2)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'hgtw', 832.0, 1664.0, 270.000)
    set u=CreateUnit(p, 'hgtw', 1600.0, 1088.0, 270.000)
    set u=CreateUnit(p, 'hgtw', 1600.0, 1856.0, 270.000)
endfunction

//===========================================================================
function CreateNeutralHostile takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_AGGRESSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'nstw', 620.3, - 540.9, 44.738)
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
    call CreateBuildingsForPlayer1()
    call CreateBuildingsForPlayer2()
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreatePlayerBuildings()
    call CreateNeutralHostile()
    call CreatePlayerUnits()
endfunction

//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: Table
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: Missile
//===========================================================================
//TESH.scrollpos=665
//TESH.alwaysfold=0
// Trigger: TimerUtils
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: World Bounds
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: Dummy Caster
//===========================================================================
//TESH.scrollpos=19
//TESH.alwaysfold=0
//===========================================================================
// Trigger: SpellEffectEvent
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
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
// Trigger: RegisterPlayerUnitEvent
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0

//===========================================================================
// Trigger: Spell Index
//===========================================================================
//TESH.scrollpos=24
//TESH.alwaysfold=0

//===========================================================================
// Trigger: TerrainPathability
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0

// Trigger: CameraEQNoise
//===========================================================================
//TESH.scrollpos=39
//TESH.alwaysfold=0
//===========================================================================
// Trigger: IsDestructableTree
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// Trigger: Fireball
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: Ice Siege
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0

//===========================================================================
// Trigger: Chaosflare
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// Trigger: Choatic Boulder
//===========================================================================
//TESH.scrollpos=12
//TESH.alwaysfold=0

//===========================================================================
// Trigger: Bone Spirit
//===========================================================================
//TESH.scrollpos=3
//TESH.alwaysfold=0
// Trigger: Reapers Scythe
//===========================================================================
//TESH.scrollpos=15
//TESH.alwaysfold=0

//===========================================================================
// Trigger: Leap
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: Whirlwind
//===========================================================================
//TESH.scrollpos=81
//TESH.alwaysfold=0
//===========================================================================
// Trigger: Fist of Thunder
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: This Map only
//===========================================================================
//TESH.scrollpos=59
//TESH.alwaysfold=0
// scope map begins

    
        function s__map___preload_sfx takes nothing returns nothing
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Volcano\\VolcanoDeath.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Doodads\\BlackCitadel\\Props\\RuneArt\\RuneArt1.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdl", 2300, - 2900))

        endfunction
    
    function s__map___xxx_spawn takes nothing returns nothing
        local integer i= 0
        local unit u
        loop
            exitwhen i == 4
            set u=CreateUnit(Player(1), 'ugho', map___X, map___Y, 0)
            call IssuePointOrder(u, "attack", map___X0, map___Y0)
            set u=CreateUnit(Player(2), 'ugho', map___X0, map___Y0, 0)
            call IssuePointOrder(u, "attack", map___X, map___Y)
            set i=i + 1
        endloop
        set u=null
    endfunction
    
    function s__map___xxx_revive takes nothing returns boolean
        local player p= GetTriggerPlayer()
        local unit u
        if p == Player(1) then
            set u=CreateUnit(p, 'ugho', map___X, map___Y, 0)
            call IssuePointOrder(u, "attack", map___X0, map___Y0)
        elseif p == Player(2) then
            set u=CreateUnit(p, 'ugho', map___X0, map___Y0, 0)
            call IssuePointOrder(u, "attack", map___X, map___Y)
        elseif IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) then
            call ReviveHero(GetTriggerUnit(), 0, 0, true)
        endif
        set u=null
        set p=null
        return false
    endfunction

    function s__map___xxx_reset takes nothing returns boolean
        call ClearTextMessages()
        call GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(0), null)
        loop
            set bj_lastCreatedUnit=FirstOfGroup(bj_lastCreatedGroup)
            exitwhen bj_lastCreatedUnit == null
            call GroupRemoveUnit(bj_lastCreatedGroup, bj_lastCreatedUnit)
            call UnitResetCooldown(bj_lastCreatedUnit)
            call SetUnitState(bj_lastCreatedUnit, UNIT_STATE_MANA, GetUnitState(bj_lastCreatedUnit, UNIT_STATE_MAX_MANA))
        endloop
        return false
    endfunction
    
    function s__map___xxx_NewHero takes integer unitId returns nothing
        local unit u= CreateUnit(Player(0), unitId, 0, 0, 0)
        call SetHeroLevel(u, 12, true)
        set u=null
    endfunction
    
    function s__map___xxx_onInit takes nothing returns nothing
        local trigger t= CreateTrigger()
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH , function s__map___xxx_revive)
        call s__map___xxx_spawn()
        call s__map___xxx_NewHero('Hblm')
        call s__map___xxx_NewHero('Uktl')
        call s__map___xxx_NewHero('Obla')
        call s__map___xxx_NewHero('Hmkg')
        call s__map___xxx_NewHero('Hvwd')
        call FogModifierStart(CreateFogModifierRect(Player(0), FOG_OF_WAR_VISIBLE, s__WorldBounds_world, false, false))
        call TriggerRegisterPlayerEventEndCinematic(t, Player(0))
        call TriggerAddCondition(t, Condition(function s__map___xxx_reset))
        call BJDebugMsg("Press |cffdaa520ESC|r to reset cooldowns and refresh mana")
        set t=null
        call s__map___preload_sfx()
    endfunction
// scope map ends

//===========================================================================
// Trigger: Guided Arrow
//===========================================================================
//TESH.scrollpos=75
//TESH.alwaysfold=0
function InitCustomTriggers takes nothing returns nothing
    //Function not found: call InitTrig_Table()
    //Function not found: call InitTrig_Missile()
    //Function not found: call InitTrig_TimerUtils()
    //Function not found: call InitTrig_World_Bounds()
    //Function not found: call InitTrig_Dummy_Caster()
    //Function not found: call InitTrig_SpellEffectEvent()
    //Function not found: call InitTrig_RegisterPlayerUnitEvent()
    //Function not found: call InitTrig_Spell_Index()
    //Function not found: call InitTrig_TerrainPathability()
    //Function not found: call InitTrig_CameraEQNoise()
    //Function not found: call InitTrig_IsDestructableTree()
    //Function not found: call InitTrig_Fireball()
    //Function not found: call InitTrig_Ice_Siege()
    //Function not found: call InitTrig_Chaosflare()
    //Function not found: call InitTrig_Choatic_Boulder()
    //Function not found: call InitTrig_Bone_Spirit()
    //Function not found: call InitTrig_Reapers_Scythe()
    //Function not found: call InitTrig_Leap()
    //Function not found: call InitTrig_Whirlwind()
    //Function not found: call InitTrig_Fist_of_Thunder()
    //Function not found: call InitTrig_This_Map_only()
    //Function not found: call InitTrig_Guided_Arrow()
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
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_002
    call SetPlayerTeam(Player(0), 0)

endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl", "Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("AshenvaleDay")
    call SetAmbientNightSound("AshenvaleNight")
    call SetMapMusic("Music", true, 0)
    call CreateAllUnits()
    call InitBlizzard()

call ExecuteFunc("jasshelper__initstructs73445468")
call ExecuteFunc("TerrainPathability___Init")
call ExecuteFunc("TimerUtils___init")
call ExecuteFunc("BoneSpirit___Init")
call ExecuteFunc("Chaosflare___Init")
call ExecuteFunc("ChaoticBoulder___Init")
call ExecuteFunc("Fireball___Init")
call ExecuteFunc("FistOfThunder___Init")
call ExecuteFunc("GuidedArrow___Init")
call ExecuteFunc("IceSiege___Init")
call ExecuteFunc("Leap___Init")
call ExecuteFunc("ReapersScythe___Init")
call ExecuteFunc("Whirlwind___Init")

    call InitGlobals()
    call InitCustomTriggers()

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_018")
    call SetMapDescription("TRIGSTR_020")
    call SetPlayers(1)
    call SetTeams(1)
    call SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)

    call DefineStartLocation(0, - 512.0, - 768.0)

    // Player setup
    call InitCustomPlayerSlots()
    call SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    call InitGenericPlayerSlots()
endfunction




//Struct method generated initializers/callers:

//Functions for BigArrays:
function sa__ChaoticBoulder___ChaoticBoulder_launch takes nothing returns boolean
local integer missile=f__arg_integer1
             set s__Missile_launched[missile]=true
            call s__Missile_insertEnd(Missile___missileStack[si__ChaoticBoulder___ChaoticBoulder],missile)
            call Missile___StartPeriodic(si__ChaoticBoulder___ChaoticBoulder)
   return true
endfunction
function sa___prototype2_TimerUtils___init takes nothing returns boolean

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
                    set s__TimerUtils___tT[i]= CreateTimer()
                    call SetTimerData(s__TimerUtils___tT[i] , TimerUtils___HELD)
                    set i=i + 1
                endloop
                set TimerUtils___tN=TimerUtils___QUANTITY
    return true
endfunction

function jasshelper__initstructs73445468 takes nothing returns nothing
    set st__ChaoticBoulder___ChaoticBoulder_launch=CreateTrigger()
    call TriggerAddCondition(st__ChaoticBoulder___ChaoticBoulder_launch,Condition( function sa__ChaoticBoulder___ChaoticBoulder_launch))
    set st___prototype2[1]=CreateTrigger()
    call TriggerAddAction(st___prototype2[1],function sa___prototype2_TimerUtils___init)
    call TriggerAddCondition(st___prototype2[1],Condition(function sa___prototype2_TimerUtils___init))

call ExecuteFunc("s__DummyCaster_DummyCaster___N__onInit")

call ExecuteFunc("s__IsDestructableTree___I_IsDestructableTree___Inits__onInit")















































call ExecuteFunc("s__WorldBounds_WorldBounds___WorldBoundInit__onInit")




call ExecuteFunc("s__SpellEffectEvent___S_SpellEffectEvent___M__onInit")


call ExecuteFunc("s__BoneSpirit___BoneSpirit_MissileStruct__onInit")

call ExecuteFunc("s__ChaoticBoulder___ChaoticBoulder_MissileStruct__onInit")

call ExecuteFunc("s__Fireball___Fireball_MissileStruct__onInit")

call ExecuteFunc("s__FistOfThunder___FistOfThunder_MissileStruct__onInit")

call ExecuteFunc("s__GuidedArrow___GuidedArrow_MissileStruct__onInit")

call ExecuteFunc("s__Leap___Leap_MissileStruct__onInit")



    call ExecuteFunc("s__Missile_onInit")
    call ExecuteFunc("s__map___xxx_onInit")
endfunction

