// Ivan, Arch Sage de Twilight's Eve Final R4.13a (Donach & KryptonRazer): prueba privada de Leon, 12/11/2026.
// Boreas y la definitiva Twilight's Eve portadas a JASS 1.27b desde las funciones dUw/aUw y sIw del mapa original.
// Lightning Avenger, Warmth y Energy Shield son nativas (Forked Lightning, Brilliance Aura, Mana Shield).
// Comandos: -ivan (crea o trae a Ivan junto al personaje y lo selecciona), -ivan cd (recargas y maná), -ivan fuera.

function Ivan_Fundido takes force f, string tex, integer r, integer g, integer b, integer a0, integer a1, real dur returns nothing
    // Sólo visual: el filtro de pantalla de los jugadores de la secuencia.
    if IsPlayerInForce(GetLocalPlayer(), f) then
        call SetCineFilterTexture(tex)
        call SetCineFilterBlendMode(BLEND_MODE_BLEND)
        call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
        call SetCineFilterStartUV(0, 0, 1, 1)
        call SetCineFilterEndUV(0, 0, 1, 1)
        call SetCineFilterStartColor(r, g, b, a0)
        call SetCineFilterEndColor(r, g, b, a1)
        call SetCineFilterDuration(dur)
        call DisplayCineFilter(true)
    endif
endfunction

function Ivan_FiltroEnemigo takes nothing returns boolean
    local unit u = GetFilterUnit()
    local boolean ok = UnitAlive(u) and IsUnitEnemy(u, Ivan_Owner) and GetUnitAbilityLevel(u, 'Aloc') == 0
    set u = null
    return ok
endfunction

// Como mB de TeveF: unidades de jugadores humanos, aquí sólo las no enemigas (Dev Mission es cooperativo).
function Ivan_FiltroAliado takes nothing returns boolean
    local unit u = GetFilterUnit()
    local player o = GetOwningPlayer(u)
    local boolean ok = UnitAlive(u) and not IsUnitEnemy(u, Ivan_Owner) and GetUnitAbilityLevel(u, 'Aloc') == 0 and GetPlayerId(o) < 8 and GetPlayerController(o) == MAP_CONTROL_USER
    set u = null
    set o = null
    return ok
endfunction

// Los aliados cercanos ven la secuencia con Ivan (su cámara), sin pausa ni invulnerabilidad.
function Ivan_Detener takes nothing returns nothing
    call ForceAddPlayer(Ivan_F, GetOwningPlayer(GetEnumUnit()))
endfunction

// 12/11/2026, Leon, como en Battle Stadium D.O.N: en lugar de pausar, todo va muy lento mientras Ivan actúa.
// Animación al 10 % aquí; movimiento y ataque con el aura AIv5 (-90 %) y MinUnitSpeed 50 en war3mapMisc.
function Ivan_FiltroLento takes nothing returns boolean
    local unit u = GetFilterUnit()
    local boolean ok = UnitAlive(u) and u != Ivan_Caster and GetUnitAbilityLevel(u, 'Aloc') == 0 and not IsUnitType(u, UNIT_TYPE_STRUCTURE)
    set u = null
    return ok
endfunction

function Ivan_Lento takes nothing returns nothing
    call SetUnitTimeScale(GetEnumUnit(), 0.1)
endfunction

function Ivan_Normal takes nothing returns nothing
    call SetUnitTimeScale(GetEnumUnit(), 1.)
endfunction

// Zona negra de D.O.N (noche y niebla gris al 15 %); al terminar, la niebla vigente de Storm. Sólo visual.
function Ivan_Oscuro takes boolean on returns nothing
    if on then
        call SetTerrainFogEx(0, 800., 5000., 0.7, 0.15, 0.15, 0.15)
    elseif s__Storm__TStorm_TempTF then
        call SetTerrainFogEx(s__Storm__TStorm_TempTF_style, s__Storm__TStorm_TempTF_zstart, s__Storm__TStorm_TempTF_zend, s__Storm__TStorm_TempTF_density, s__Storm__TStorm_TempTF_red, s__Storm__TStorm_TempTF_green, s__Storm__TStorm_TempTF_blue)
    else
        call ResetTerrainFog()
    endif
endfunction

function Ivan_Laser takes nothing returns nothing
    call CreateUnit(Ivan_Owner, 'hIv2', GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), 270.)
endfunction

function Ivan_Golpe takes nothing returns nothing
    call UnitDamageTarget(Ivan_Caster, GetEnumUnit(), IVAN_DANO_DEFINITIVA, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS)
endfunction

function Ivan_Efecto takes string m, real x, real y returns nothing
    call DestroyEffect(AddSpecialEffect(m, x, y))
endfunction

// Mueve la cámara de los jugadores de la secuencia (PanCameraToTimedLocForPlayer en TeveF).
function Ivan_Mirar takes force f, unit cam, real x, real y returns nothing
    call SetUnitX(cam, x)
    call SetUnitY(cam, y)
    if IsPlayerInForce(GetLocalPlayer(), f) then
        call SetCameraTargetController(cam, 0., 0., false)
    endif
endfunction

// El planeta con la cámara por defecto de TeveF (1650, 304°): la de Dev Mission está a ~2860 y más alta, y la Tierra
// se veía pequeña. La niebla del mapa (Storm) teñía la zona enmascarada; mientras se ve el planeta la niebla es negra.
// Sólo visual; al terminar se repone la niebla vigente de Storm y la cámara vuelve sola con FollowCamera.
function Ivan_Planeta takes force f, boolean on returns nothing
    if IsPlayerInForce(GetLocalPlayer(), f) then
        if on then
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1650., 0.)
            call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 304., 0.)
            call SetCameraField(CAMERA_FIELD_ZOFFSET, 0., 0.)
            call SetTerrainFogEx(0, 4000., 12000., 0., 0., 0., 0.)
        elseif s__Storm__TStorm_TempTF then
            call SetTerrainFogEx(s__Storm__TStorm_TempTF_style, s__Storm__TStorm_TempTF_zstart, s__Storm__TStorm_TempTF_zend, s__Storm__TStorm_TempTF_density, s__Storm__TStorm_TempTF_red, s__Storm__TStorm_TempTF_green, s__Storm__TStorm_TempTF_blue)
        else
            call ResetTerrainFog()
        endif
    endif
endfunction

function Ivan_Ruido takes force f, boolean on returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if IsPlayerInForce(Player(p), f) then
            if on then
                call CameraSetEQNoiseForPlayer(Player(p), 13.)
            else
                call CameraClearNoiseForPlayer(Player(p))
            endif
        endif
        set p = p + 1
    endloop
endfunction

// Boreas (dUw/aUw): Pisotón nativo congela 3 s; aquí el daño caótico y el hielo sobre cada enemigo.
function Ivan_Boreas takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local group g = CreateGroup()
    local unit u
    set Ivan_Owner = GetOwningPlayer(c)
    call GroupEnumUnitsInRange(g, GetUnitX(c), GetUnitY(c), 550., Condition(function Ivan_FiltroEnemigo))
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        call CreateUnit(GetOwningPlayer(c), 'hIv8', GetUnitX(u), GetUnitY(u), 270.)
        call UnitDamageTarget(c, u, IVAN_DANO_BOREAS, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    endloop
    call DestroyGroup(g)
    set g = null
    set c = null
endfunction

// Twilight's Eve (sIw), con sus esperas y efectos en el mismo orden.
// 12/11/2026, Leon: pasos de la versión larga de [AF] Twilight's Eve ORPG Final (Green_Day_Dance & Asayaki_Zac, ~40 s)
// acortados a unos 20 s; R4.13a la deja en ~10 s.
function Ivan_Eve takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local unit t = GetSpellTargetUnit()
    local player o = GetOwningPlayer(c)
    local real cx = GetUnitX(c)
    local real cy = GetUnitY(c)
    local real tx = GetUnitX(t)
    local real ty = GetUnitY(t)
    local real rx = Ivan_PX - 144.
    local real ry = Ivan_PY - 96.
    local real tod = GetTimeOfDay()
    local group hu = CreateGroup()
    local group nu = CreateGroup()
    local group le = CreateGroup()
    local unit aura
    local force f = CreateForce()
    local rect zona = Rect(cx - 1500., cy - 1500., cx + 1500., cy + 1500.)
    local weathereffect we
    local fogmodifier array fm
    local unit cam = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', cx, cy, 0.)
    local unit sig
    local unit tierra
    local unit u
    local effect el
    local effect er
    local effect fx
    local texttag tt = CreateTextTag()
    local integer i = 1
    local integer p
    local real x
    local real y
    call ForceAddPlayer(f, o)
    set Ivan_Owner = o
    call GroupEnumUnitsInRange(hu, cx, cy, 1200., Condition(function Ivan_FiltroAliado))
    call GroupEnumUnitsInRange(nu, tx, ty, 700., Condition(function Ivan_FiltroEnemigo))
    set Ivan_F = f
    call ForGroup(hu, function Ivan_Detener)
    // Sólo Ivan queda quieto e invulnerable mientras ejecuta; el resto, a cámara lenta.
    call SetUnitInvulnerable(c, true)
    call PauseUnit(c, true)
    set Ivan_Caster = c
    call GroupEnumUnitsInRange(le, cx, cy, 1800., Condition(function Ivan_FiltroLento))
    call ForGroup(le, function Ivan_Lento)
    set aura = CreateUnit(o, 'dumi', cx, cy, 0.)
    call UnitAddAbility(aura, 'AIv5')
    set p = 0
    loop
        exitwhen p > 11
        if IsPlayerInForce(Player(p), f) then
            set Ivan_Cine[p] = true
        endif
        set p = p + 1
    endloop
    call Ivan_Mirar(f, cam, cx, cy)
    set el = AddSpecialEffectTarget("Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl", c, "left hand")
    set er = AddSpecialEffectTarget("Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl", c, "right hand")
    call SetUnitAnimation(c, "channel")
    call PolledWait(0.5)
    call Ivan_Efecto("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl", cx, cy)
    call PolledWait(0.6)
    call Ivan_Efecto("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", cx, cy)
    call PolledWait(0.6)
    call Ivan_Efecto("Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl", cx, cy)
    call PolledWait(0.5)
    call Ivan_Efecto("war3mapImported\\Great Lightning.mdx", cx, cy)
    call PolledWait(0.7)
    call SetUnitTimeScale(c, 0.4)
    call SetUnitAnimation(c, "spell")
    call SetTextTagText(tt, "|cff009ACDI call upon the highest of all Arcane magics, the embodiment of destruction, power enough to smash even those of gods! Twilight's Eve!!|r", 0.0276)
    call SetTextTagPosUnit(tt, c, 0.)
    call SetTextTagPermanent(tt, true)
    call SetTextTagVisibility(tt, IsPlayerInForce(GetLocalPlayer(), f))
    call PolledWait(1.)
    set sig = CreateUnit(o, 'hIv0', cx, cy, 270.)
    call SetUnitTimeScale(sig, 0.4)
    call SetTimeOfDay(24.)
    call Ivan_Oscuro(true)
    set we = AddWeatherEffect(zona, 'LRma')
    call EnableWeatherEffect(we, true)
    call SetUnitAnimation(c, "channel")
    call Ivan_Ruido(f, true)
    loop
        exitwhen i > 12
        call Ivan_Efecto("Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl", GetRandomReal(cx - 400., cx + 400.), GetRandomReal(cy - 400., cy + 400.))
        call Ivan_Efecto("Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl", GetRandomReal(cx - 400., cx + 400.), GetRandomReal(cy - 400., cy + 400.))
        call Ivan_Efecto("Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl", GetRandomReal(cx - 400., cx + 400.), GetRandomReal(cy - 400., cy + 400.))
        call CreateUnit(o, 'hIv1', GetRandomReal(cx - 400., cx + 400.), GetRandomReal(cy - 400., cy + 400.), 270.)
        call PolledWait(0.1)
        set fx = AddSpecialEffect("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", GetRandomReal(cx - 400., cx + 400.), GetRandomReal(cy - 400., cy + 400.))
        call PolledWait(0.2)
        if i == 4 or i == 8 or i == 12 then
            call Ivan_Efecto("war3mapImported\\Great Lightning.mdx", cx, cy)
            call Ivan_Efecto("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", cx, cy)
            call Ivan_Efecto("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", cx, cy)
        endif
        call DestroyEffect(fx)
        set i = i + 1
    endloop
    call SetUnitTimeScale(sig, 0.05)
    call Ivan_Mirar(f, cam, tx, ty)
    set u = CreateUnit(o, 'hIv2', tx, ty, 270.)
    call SetUnitTimeScale(u, 0.7)
    call DestroyTextTag(tt)
    call PolledWait(1.)
    set Ivan_Owner = o
    call ForGroup(nu, function Ivan_Laser)
    call PolledWait(2.)
    set i = 1
    loop
        exitwhen i > 10
        call PolledWait(0.4)
        call CreateUnit(o, 'hIv3', GetRandomReal(tx - 400., tx + 400.), GetRandomReal(ty - 400., ty + 400.), 270.)
        set i = i + 1
    endloop
    call Ivan_Fundido(f, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0, 255, 0.4)
    call PolledWait(0.5)
    // El planeta: una zona enmascarada (negra) del borde norte, con visión sólo alrededor de la Tierra.
    set p = 0
    loop
        exitwhen p > 11
        if IsPlayerInForce(Player(p), f) then
            set fm[p] = CreateFogModifierRadius(Player(p), FOG_OF_WAR_VISIBLE, Ivan_PX, Ivan_PY, 700., true, true)
            call FogModifierStart(fm[p])
        endif
        set p = p + 1
    endloop
    call Ivan_Mirar(f, cam, Ivan_PX, Ivan_PY)
    call Ivan_Planeta(f, true)
    call RemoveWeatherEffect(we)
    call PolledWait(0.4)
    call Ivan_Fundido(f, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 255, 0, 0.4)
    set tierra = CreateUnit(o, 'hIv4', Ivan_PX, Ivan_PY, 270.)
    call PolledWait(0.05)
    set u = CreateUnit(o, 'hIv5', rx, ry, 230.)
    call SetUnitTimeScale(u, 0.4)
    call DestroyEffect(el)
    call DestroyEffect(er)
    call PolledWait(2.)
    set u = CreateUnit(o, 'hIv6', rx, ry, 230.)
    call SetUnitTimeScale(u, 0.6)
    call PolledWait(0.8)
    set u = CreateUnit(o, 'hIv7', rx, ry, 230.)
    call SetUnitTimeScale(u, 0.4)
    call PolledWait(0.7)
    call CreateUnit(o, 'hIv5', rx, ry, 230.)
    call PolledWait(1.5)
    call Ivan_Ruido(f, false)
    call Ivan_Fundido(f, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 255, 255, 255, 0, 255, 0.4)
    call PolledWait(0.1)
    call RemoveUnit(sig)
    call Ivan_Mirar(f, cam, cx, cy)
    call Ivan_Planeta(f, false)
    call Ivan_Oscuro(false)
    call PolledWait(0.1)
    call Ivan_Fundido(f, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 255, 255, 255, 255, 0, 0.3)
    call ResetUnitAnimation(c)
    call PolledWait(0.03)
    set Ivan_Caster = c
    call ForGroup(nu, function Ivan_Golpe)
    call RemoveUnit(aura)
    call ForGroup(le, function Ivan_Normal)
    call SetUnitInvulnerable(c, false)
    call PauseUnit(c, false)
    call SetUnitTimeScale(c, 1.)
    call SetTimeOfDay(tod)
    set p = 0
    loop
        exitwhen p > 11
        if IsPlayerInForce(Player(p), f) then
            set Ivan_Cine[p] = false
            call FogModifierStop(fm[p])
            call DestroyFogModifier(fm[p])
            set fm[p] = null
        endif
        set p = p + 1
    endloop
    call RemoveUnit(tierra)
    call RemoveUnit(cam)
    call PolledWait(0.3)
    if IsPlayerInForce(GetLocalPlayer(), f) then
        call DisplayCineFilter(false)
    endif
    call DestroyGroup(hu)
    call DestroyGroup(nu)
    call DestroyGroup(le)
    call DestroyForce(f)
    call RemoveRect(zona)
    set hu = null
    set nu = null
    set le = null
    set aura = null
    set f = null
    set zona = null
    set we = null
    set cam = null
    set sig = null
    set tierra = null
    set u = null
    set el = null
    set er = null
    set fx = null
    set tt = null
    set c = null
    set t = null
    set o = null
endfunction

function Ivan_EsBoreas takes nothing returns boolean
    return GetSpellAbilityId() == 'AIv0'
endfunction

function Ivan_EsEve takes nothing returns boolean
    return GetSpellAbilityId() == 'AIv4'
endfunction

function Ivan_Comando takes nothing returns nothing
    local player pl = GetTriggerPlayer()
    local integer p = GetPlayerId(pl)
    local string s = GetEventPlayerChatString()
    local real x
    local real y
    if s == "-ivan fuera" then
        if Ivan_U[p] != null then
            call RemoveUnit(Ivan_U[p])
            set Ivan_U[p] = null
        endif
        return
    endif
    if Ivan_U[p] == null or not UnitAlive(Ivan_U[p]) then
        if not Game_On[p] or GetUnitTypeId(Game_Hero[p]) == 0 then
            call DisplayTimedTextToPlayer(pl, 0., 0., 6., "Ivan: entra a la partida primero.")
            return
        endif
        if Ivan_U[p] != null then
            call RemoveUnit(Ivan_U[p])
        endif
        set x = GetUnitX(Game_Hero[p]) + 150.
        set y = GetUnitY(Game_Hero[p])
        set Ivan_U[p] = CreateUnit(pl, 'hIva', x, y, 270.)
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl", x, y))
    elseif s == "-ivan cd" then
        call UnitResetCooldown(Ivan_U[p])
        call SetUnitState(Ivan_U[p], UNIT_STATE_MANA, GetUnitState(Ivan_U[p], UNIT_STATE_MAX_MANA))
        call SetUnitState(Ivan_U[p], UNIT_STATE_LIFE, GetUnitState(Ivan_U[p], UNIT_STATE_MAX_LIFE))
    elseif GetUnitTypeId(Game_Hero[p]) != 0 then
        call SetUnitPosition(Ivan_U[p], GetUnitX(Game_Hero[p]) + 150., GetUnitY(Game_Hero[p]))
    endif
    if GetLocalPlayer() == pl then
        call ClearSelection()
        call SelectUnit(Ivan_U[p], true)
    endif
endfunction

function Ivan_Init takes nothing returns nothing
    local trigger b = CreateTrigger()
    local trigger e = CreateTrigger()
    local trigger c = CreateTrigger()
    local integer p = 0
    loop
        exitwhen p > 7
        call TriggerRegisterPlayerUnitEvent(b, Player(p), EVENT_PLAYER_UNIT_SPELL_EFFECT, null)
        call TriggerRegisterPlayerUnitEvent(e, Player(p), EVENT_PLAYER_UNIT_SPELL_EFFECT, null)
        call TriggerRegisterPlayerChatEvent(c, Player(p), "-ivan", false)
        set p = p + 1
    endloop
    call TriggerAddCondition(b, Condition(function Ivan_EsBoreas))
    call TriggerAddAction(b, function Ivan_Boreas)
    call TriggerAddCondition(e, Condition(function Ivan_EsEve))
    call TriggerAddAction(e, function Ivan_Eve)
    call TriggerAddAction(c, function Ivan_Comando)
    set b = null
    set e = null
    set c = null
endfunction

