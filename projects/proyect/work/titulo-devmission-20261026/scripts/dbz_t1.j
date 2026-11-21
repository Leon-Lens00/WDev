// v16t-dbz1 (12/11/2026): tanda 1 de habilidades DBZ (Goku y Vegeta) rehechas sobre el núcleo Missile del mapa.
// De Battle Stadium D.O.N 2.1a (Valkemiere) se toman las recetas visuales: modelos, sonidos, carga y explosiones. El
// movimiento es nuestro: cada proyectil es un Missile de la familia DBZT_SID (iteración propia, como el módulo
// MissileStruct) y los segmentos del rayo son efectos sobre dummies del reciclador que se sueltan al acabar.
// Habilidades (rawcodes de objetos_dbz.py):
//   Goku:   Az06 Kamehameha, Az04 Warp Kamehameha, Az05 Dragon Fist, Az01 Spirit Bomb, Az00 Power Up.
//   Vegeta: Az0B Galick Gun, Az0D Big Bang Attack, Az0C Final Flash, Az07 Final Explosion, Az08 Power Up.
// Power Up sube la forma (Goku: SSJ, SSJ3, SSJ4; Vegeta: Blue) y vuelve a la normal tras la última; cada forma suma
// un 25 % al daño de las habilidades. No se modifica la biblioteca Missile.

// --- utilidades ---

function DbzT_Sonido takes string ruta, real x, real y returns nothing
    local sound s = CreateSound(ruta, false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundChannel(s, 0)
    call SetSoundVolume(s, 127)
    call SetSoundDistances(s, 600., 4000.)
    call SetSoundPosition(s, x, y, 0.)
    call StartSound(s)
    call KillSoundWhenDone(s)
    set s = null
endfunction

function DbzT_Factor takes unit c returns real
    return 1. + 0.25 * DbzT_Forma[GetPlayerId(GetOwningPlayer(c))]
endfunction

function DbzT_Enemigo takes unit t, player p returns boolean
    return UnitAlive(t) and IsUnitEnemy(t, p) and not IsUnitType(t, UNIT_TYPE_STRUCTURE) and GetUnitAbilityLevel(t, 'Aloc') == 0
endfunction

// Daño en área a enemigos del dueño de c.
function DbzT_Area takes unit c, real x, real y, real radio, real dano returns nothing
    local player p = GetOwningPlayer(c)
    local unit t
    call GroupEnumUnitsInRange(DbzT_G, x, y, radio, null)
    loop
        set t = FirstOfGroup(DbzT_G)
        exitwhen t == null
        call GroupRemoveUnit(DbzT_G, t)
        if DbzT_Enemigo(t, p) then
            call UnitDamageTarget(c, t, dano, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
        endif
    endloop
    set p = null
endfunction

function DbzT_Efecto takes string m, real x, real y, real escala returns nothing
    local unit d = GetRecycledMissile(x, y, 0., 0.)
    call SetUnitScale(d, escala, escala, escala)
    call DestroyEffect(AddSpecialEffectTarget(m, d, "origin"))
    call RecycleMissile(d)
    set d = null
endfunction

// --- familia Missile propia ---

// Segmentos del rayo: dummy en la clave i y su efecto en 100 + i de la fila del misil.
function DbzT_Segmento takes integer m returns nothing
    local integer n = DbzT_SegN[m]
    local unit d
    if n >= 40 or DbzT_SegModelo[m] == "" then
        return
    endif
    set d = GetRecycledMissile(s__Missile_x[m], s__Missile_y[m], s__Missile_z[m], s__Missile_angle[m] * bj_RADTODEG)
    call SetUnitScale(d, DbzT_SegEscala[m], DbzT_SegEscala[m], DbzT_SegEscala[m])
    call SaveUnitHandle(DbzT_H, m, n, d)
    call SaveEffectHandle(DbzT_H, m, 100 + n, AddSpecialEffectTarget(DbzT_SegModelo[m], d, "origin"))
    set DbzT_SegN[m] = n + 1
    set d = null
endfunction

function DbzT_Soltar takes integer m returns nothing
    local integer i = 0
    loop
        exitwhen i >= DbzT_SegN[m]
        call DestroyEffect(LoadEffectHandle(DbzT_H, m, 100 + i))
        call RecycleMissile(LoadUnitHandle(DbzT_H, m, i))
        set i = i + 1
    endloop
    set DbzT_SegN[m] = 0
    call FlushChildHashtable(DbzT_H, m)
endfunction

function DbzT_Terminar takes integer m returns nothing
    if s__Missile_allocated[m] then
        call DbzT_Soltar(m)
        if DbzT_Jinete[m] != null then
            // Dragon Fist: el lanzador vuelve a un punto transitable.
            call SetUnitPosition(DbzT_Jinete[m], GetUnitX(DbzT_Jinete[m]), GetUnitY(DbzT_Jinete[m]))
            call PauseUnit(DbzT_Jinete[m], false)
            call SetUnitTimeScale(DbzT_Jinete[m], 1.)
            call SetUnitAnimation(DbzT_Jinete[m], "stand")
            set DbzT_Jinete[m] = null
        endif
        call s__Missile_terminate(m)
        call Missile__StopPeriodic(DBZT_SID)
    endif
endfunction

// Al llegar al final: explosión según el tipo (s__Missile_data).
function DbzT_Final takes integer m returns nothing
    local integer k = s__Missile_data[m]
    local real x = s__Missile_x[m]
    local real y = s__Missile_y[m]
    local unit c = s__Missile_source[m]
    if k == 3 then
        // Big Bang Attack
        call DbzT_Efecto("war3mapImported\\NUKE2.mdx", x, y, 1.)
        call DbzT_Efecto("war3mapImported\\ArtilleryExplosion.mdx", x, y, 1.5)
        call DbzT_Sonido("war3mapImported\\explosion00.mp3", x, y)
        call DbzT_Area(c, x, y, 350., DbzT_Explosion[m])
    elseif k == 4 then
        // Final Flash
        call DbzT_Efecto("war3mapImported\\DivineRage.mdx", x, y, 1.)
        call DbzT_Efecto("war3mapImported\\NuclearExplosion.mdx", x, y, 1.)
        call DbzT_Efecto("war3mapImported\\LightStrikeArray.mdx", x, y, 1.)
        call DbzT_Sonido("war3mapImported\\massive_energy_explosion2.mp3", x, y)
        call DbzT_Area(c, x, y, 450., DbzT_Explosion[m])
    elseif k == 5 then
        // Spirit Bomb
        call DbzT_Efecto("war3mapImported\\NuclearExplosion.mdx", x, y, 1.5)
        call DbzT_Efecto("war3mapImported\\FreezingRingas2.mdx", x, y, 2.)
        call DbzT_Sonido("war3mapImported\\nuke.mp3", x, y)
        call DbzT_Area(c, x, y, 600., DbzT_Explosion[m])
    elseif k == 6 then
        // Dragon Fist
        call DbzT_Efecto("war3mapImported\\NewValkDust.mdx", x, y, 1.5)
        call DbzT_Efecto("war3mapImported\\ArtilleryExplosion.mdx", x, y, 1.5)
        call DbzT_Area(c, x, y, 300., DbzT_Explosion[m])
    else
        // Kamehameha, Galick Gun y Warp Kamehameha
        call DbzT_Efecto("war3mapImported\\NewValkDust.mdx", x, y, 1.)
        if DbzT_Explosion[m] > 0. then
            call DbzT_Area(c, x, y, 250., DbzT_Explosion[m])
        endif
    endif
    set c = null
endfunction

// Cada tic: daño a los enemigos que toca la cabeza (una vez por unidad) y segmentos del rayo.
function DbzT_Tic takes integer m returns nothing
    local player p = s__Missile_owner[m]
    local unit c = s__Missile_source[m]
    local unit t
    if DbzT_Jinete[m] != null then
        call SetUnitX(DbzT_Jinete[m], s__Missile_x[m])
        call SetUnitY(DbzT_Jinete[m], s__Missile_y[m])
    endif
    if s__Missile_damage[m] > 0. then
        call GroupEnumUnitsInRange(DbzT_G, s__Missile_x[m], s__Missile_y[m], s__Missile_collision[m], null)
        loop
            set t = FirstOfGroup(DbzT_G)
            exitwhen t == null
            call GroupRemoveUnit(DbzT_G, t)
            if DbzT_Enemigo(t, p) and not s__Missile_hasHitWidget(m, t) then
                call s__Missile_hitWidget(m, t)
                call UnitDamageTarget(c, t, s__Missile_damage[m], true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
            endif
        endloop
    endif
    set DbzT_Paso[m] = DbzT_Paso[m] + 1
    if DbzT_Paso[m] >= 2 then
        set DbzT_Paso[m] = 0
        call DbzT_Segmento(m)
    endif
    set p = null
    set c = null
endfunction

function DbzT_Iterar takes nothing returns boolean
    local integer m = s__Missile_Missile__MissileStructure____first[Missile__missileList[DBZT_SID]]
    local integer sig
    loop
        exitwhen m == 0
        set sig = s__Missile_Missile__MissileStructure____next[m]
        if s__Missile_wantDestroy[m] then
            call DbzT_Terminar(m)
        else
            if s__Missile_stackSize[m] > 0 then
                call s__Missile_updateStack(m)
            endif
            if s__Missile_allocated[m] then
                call DbzT_Tic(m)
            endif
            if s__Missile_recycle[m] and s__Missile_allocated[m] then
                call DbzT_Final(m)
                call DbzT_Terminar(m)
            endif
        endif
        set m = sig
    endloop
    return false
endfunction

// Lanza un proyectil del tipo k desde c hacia (tx, ty). Devuelve el misil.
function DbzT_Lanzar takes unit c, integer k, real tx, real ty, real vel, real z, string cabeza, real escala, string seg, real segEscala, real radio, real dano, real explosion returns integer
    local real x = GetUnitX(c)
    local real y = GetUnitY(c)
    local real a = Atan2(ty - y, tx - x)
    local real iz = z
    local integer m
    if k == 5 then
        // Spirit Bomb cae desde lo alto hasta el suelo.
        set iz = 0.
    endif
    set m = s__Missile_createXYZ(x + 60. * Cos(a), y + 60. * Sin(a), z, tx, ty, iz)
    set s__Missile_source[m] = c
    set s__Missile_owner[m] = GetOwningPlayer(c)
    set s__Missile_speed[m] = vel * Missile_TIMER_TIMEOUT
    set s__Missile_collision[m] = radio
    set s__Missile_damage[m] = dano
    set s__Missile_data[m] = k
    call s__Missile__set_model(m, cabeza)
    call s__Missile__set_scale(m, escala)
    set DbzT_SegModelo[m] = seg
    set DbzT_SegEscala[m] = segEscala
    set DbzT_SegN[m] = 0
    set DbzT_Paso[m] = 0
    set DbzT_Explosion[m] = explosion
    set DbzT_Jinete[m] = null
    call s__Missile_insertFront(Missile__missileList[DBZT_SID], m)
    call Missile__StartPeriodic(DBZT_SID)
    return m
endfunction

// --- carga con temporizador: el lanzador queda quieto y dispara al vencer ---

function DbzT_Disparo takes nothing returns nothing
    local timer tm = GetExpiredTimer()
    local integer h = GetHandleId(tm)
    local unit c = LoadUnitHandle(DbzT_H, h, 0)
    local integer k = LoadInteger(DbzT_H, h, 1)
    local real tx = LoadReal(DbzT_H, h, 2)
    local real ty = LoadReal(DbzT_H, h, 3)
    local real f
    call DestroyEffect(LoadEffectHandle(DbzT_H, h, 4))
    call FlushChildHashtable(DbzT_H, h)
    call DestroyTimer(tm)
    if UnitAlive(c) then
        set f = DbzT_Factor(c)
        call PauseUnit(c, false)
        call SetUnitTimeScale(c, 1.)
        call SetUnitAnimation(c, "spell throw")
        call QueueUnitAnimation(c, "stand")
        if k == 1 then
            call DbzT_Sonido("war3mapImported\\kamehameha.mp3", GetUnitX(c), GetUnitY(c))
            call DbzT_Lanzar(c, 1, tx, ty, 1500., 70., "war3mapImported\\SO2.mdx", 1.2, "war3mapImported\\SO2.mdx", 0.9, 150., 220. * f, 120. * f)
        elseif k == 2 then
            call DbzT_Sonido("war3mapImported\\galcksounds.wav", GetUnitX(c), GetUnitY(c))
            call DbzT_Lanzar(c, 2, tx, ty, 1500., 70., "war3mapImported\\Galick.mdx", 1.2, "war3mapImported\\lasernew.mdx", 1., 150., 200. * f, 100. * f)
        elseif k == 3 then
            call DbzT_Sonido("war3mapImported\\Bikkubangatack.wav", GetUnitX(c), GetUnitY(c))
            call DbzT_Lanzar(c, 3, tx, ty, 1100., 70., "war3mapImported\\utsuhoredsun.mdx", 0.6, "", 0., 120., 80. * f, 280. * f)
        elseif k == 4 then
            call DbzT_Sonido("war3mapImported\\finalflash2.mp3", GetUnitX(c), GetUnitY(c))
            call DbzT_Lanzar(c, 4, tx, ty, 1800., 80., "war3mapImported\\SuperShinyThingy.mdx", 2.5, "war3mapImported\\IonCannonBeam.mdx", 1.2, 220., 300. * f, 450. * f)
        elseif k == 5 then
            call DbzT_Sonido("war3mapImported\\charge.mp3", GetUnitX(c), GetUnitY(c))
            call DbzT_Lanzar(c, 5, tx, ty, 700., 300., "war3mapImported\\SuperShinyThingy.mdx", 5., "", 0., 0., 0., 900. * f)
        endif
    endif
    set tm = null
    set c = null
endfunction

function DbzT_Cargar takes unit c, integer k, real tx, real ty, real t, string animacion, real escala, string efecto, string punto, string sonido returns nothing
    local timer tm = CreateTimer()
    local integer h = GetHandleId(tm)
    call SetUnitFacing(c, Atan2(ty - GetUnitY(c), tx - GetUnitX(c)) * bj_RADTODEG)
    call PauseUnit(c, true)
    call SetUnitAnimation(c, animacion)
    call SetUnitTimeScale(c, escala)
    call SaveUnitHandle(DbzT_H, h, 0, c)
    call SaveInteger(DbzT_H, h, 1, k)
    call SaveReal(DbzT_H, h, 2, tx)
    call SaveReal(DbzT_H, h, 3, ty)
    if efecto != "" then
        call SaveEffectHandle(DbzT_H, h, 4, AddSpecialEffectTarget(efecto, c, punto))
    endif
    if sonido != "" then
        call DbzT_Sonido(sonido, GetUnitX(c), GetUnitY(c))
    endif
    call TimerStart(tm, t, false, function DbzT_Disparo)
    set tm = null
endfunction

// --- habilidades ---

function DbzT_Kamehameha takes nothing returns nothing
    call DbzT_Cargar(GetTriggerUnit(), 1, GetSpellTargetX(), GetSpellTargetY(), 0.8, "spell slam", 0.33, "war3mapImported\\SuperShinyThingy.mdx", "hand right", "war3mapImported\\kame_charge3.mp3")
endfunction

function DbzT_Galick takes nothing returns nothing
    call DbzT_Cargar(GetTriggerUnit(), 2, GetSpellTargetX(), GetSpellTargetY(), 0.5, "spell", 2., "war3mapImported\\SuperShinyThingy.mdx", "chest", "")
endfunction

function DbzT_BigBang takes nothing returns nothing
    call DbzT_Cargar(GetTriggerUnit(), 3, GetSpellTargetX(), GetSpellTargetY(), 0.3, "spell", 1., "war3mapImported\\utsuhoredsun.mdx", "hand right", "")
endfunction

function DbzT_FinalFlash takes nothing returns nothing
    call DbzT_Cargar(GetTriggerUnit(), 4, GetSpellTargetX(), GetSpellTargetY(), 1.2, "spell", 0.5, "war3mapImported\\SuperShinyThingy.mdx", "chest", "war3mapImported\\mase_charge.mp3")
endfunction

function DbzT_SpiritBomb takes nothing returns nothing
    local unit c = GetTriggerUnit()
    call DbzT_Cargar(c, 5, GetSpellTargetX(), GetSpellTargetY(), 2., "spell channel", 1., "war3mapImported\\SuperShinyThingy.mdx", "overhead", "war3mapImported\\charge.mp3")
    set c = null
endfunction

// Warp Kamehameha: aparece detrás del objetivo y dispara a quemarropa hacia él.
function DbzT_Warp takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local unit t = GetSpellTargetUnit()
    local real a = GetUnitFacing(t) * bj_DEGTORAD + bj_PI
    local real x = GetUnitX(t) + 120. * Cos(a)
    local real y = GetUnitY(t) + 120. * Sin(a)
    call DbzT_Efecto("war3mapImported\\BlackBlink.mdx", GetUnitX(c), GetUnitY(c), 1.)
    call DbzT_Sonido("war3mapImported\\teleport2.mp3", GetUnitX(c), GetUnitY(c))
    call SetUnitPosition(c, x, y)
    call DbzT_Efecto("war3mapImported\\BlackBlink.mdx", GetUnitX(c), GetUnitY(c), 1.)
    call DbzT_Cargar(c, 1, GetUnitX(t) + 500. * Cos(a + bj_PI), GetUnitY(t) + 500. * Sin(a + bj_PI), 0.3, "spell slam", 1., "war3mapImported\\SuperShinyThingy.mdx", "hand right", "")
    set c = null
    set t = null
endfunction

// Dragon Fist: Goku vuela con el puño por delante hasta el punto.
function DbzT_DragonFist takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local real tx = GetSpellTargetX()
    local real ty = GetSpellTargetY()
    local real f = DbzT_Factor(c)
    local integer m
    call SetUnitFacing(c, Atan2(ty - GetUnitY(c), tx - GetUnitX(c)) * bj_RADTODEG)
    call PauseUnit(c, true)
    call SetUnitAnimation(c, "attack")
    call SetUnitTimeScale(c, 0.3)
    call DestroyEffect(AddSpecialEffectTarget("war3mapImported\\BitchAura.mdx", c, "origin"))
    call DbzT_Sonido("war3mapImported\\df (1).mp3", GetUnitX(c), GetUnitY(c))
    set m = DbzT_Lanzar(c, 6, tx, ty, 1600., 60., "war3mapImported\\valkkame3.mdx", 1., "", 0., 160., 350. * f, 300. * f)
    set DbzT_Jinete[m] = c
    set c = null
endfunction

function DbzT_ExplosionFinal takes nothing returns nothing
    local timer tm = GetExpiredTimer()
    local integer h = GetHandleId(tm)
    local unit c = LoadUnitHandle(DbzT_H, h, 0)
    local real x = GetUnitX(c)
    local real y = GetUnitY(c)
    call DestroyEffect(LoadEffectHandle(DbzT_H, h, 4))
    call FlushChildHashtable(DbzT_H, h)
    call DestroyTimer(tm)
    call PauseUnit(c, false)
    call SetUnitTimeScale(c, 1.)
    call SetUnitVertexColor(c, 255, 255, 255, 255)
    call DbzT_Efecto("war3mapImported\\NuclearExplosion.mdx", x, y, 2.)
    call DbzT_Efecto("war3mapImported\\NUKE2.mdx", x, y, 1.5)
    call DbzT_Sonido("war3mapImported\\massive_energy_explosion2.mp3", x, y)
    if UnitAlive(c) then
        call DbzT_Area(c, x, y, 650., 600. * DbzT_Factor(c))
    endif
    set tm = null
    set c = null
endfunction

// Final Explosion: Vegeta se carga un segundo y estalla alrededor de sí mismo.
function DbzT_FinalExplosion takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local timer tm = CreateTimer()
    local integer h = GetHandleId(tm)
    call PauseUnit(c, true)
    call SetUnitAnimation(c, "spell")
    call SetUnitTimeScale(c, 0.2)
    call SetUnitVertexColor(c, 255, 220, 120, 255)
    call SaveUnitHandle(DbzT_H, h, 0, c)
    call SaveEffectHandle(DbzT_H, h, 4, AddSpecialEffectTarget("war3mapImported\\Orgia Mode3.mdx", c, "origin"))
    call DbzT_Sonido("war3mapImported\\charge.mp3", GetUnitX(c), GetUnitY(c))
    call TimerStart(tm, 1., false, function DbzT_ExplosionFinal)
    set c = null
    set tm = null
endfunction

// Power Up: siguiente forma, cabeza nueva y aura. La cabeza normal es la habilidad AId5 de la unidad.
function DbzT_Cabeza takes integer p, integer goku, integer forma returns string
    if goku == 1 then
        if forma == 1 then
            return "war3mapImported\\GokuHead_SS_squished.mdx"
        elseif forma == 2 then
            return "war3mapImported\\GokuHead_SS3_squished.mdx"
        endif
        return "war3mapImported\\GokuHeadSS4.mdx"
    endif
    return "war3mapImported\\VegetaHeadBlue.mdx"
endfunction

function DbzT_PowerUp takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local integer p = GetPlayerId(GetOwningPlayer(c))
    local integer goku = 0
    local integer maximo = 1
    local integer normal = 'Az09'
    if GetSpellAbilityId() == 'Az00' then
        set goku = 1
        set maximo = 3
        set normal = 'Az02'
    endif
    if DbzT_CabezaFx[p] != null then
        call DestroyEffect(DbzT_CabezaFx[p])
        set DbzT_CabezaFx[p] = null
    endif
    if DbzT_AuraFx[p] != null then
        call DestroyEffect(DbzT_AuraFx[p])
        set DbzT_AuraFx[p] = null
    endif
    set DbzT_Forma[p] = DbzT_Forma[p] + 1
    if DbzT_Forma[p] > maximo then
        set DbzT_Forma[p] = 0
        call UnitAddAbility(c, normal)
        call DisplayTimedTextToPlayer(Player(p), 0., 0., 4., "Forma normal.")
    else
        call UnitRemoveAbility(c, normal)
        set DbzT_CabezaFx[p] = AddSpecialEffectTarget(DbzT_Cabeza(p, goku, DbzT_Forma[p]), c, "head")
        if goku == 1 and DbzT_Forma[p] == 3 then
            set DbzT_AuraFx[p] = AddSpecialEffectTarget("war3mapImported\\RaikageLightning.mdx", c, "origin")
        elseif goku == 1 then
            set DbzT_AuraFx[p] = AddSpecialEffectTarget("war3mapImported\\SaianAura.mdx", c, "origin")
        else
            set DbzT_AuraFx[p] = AddSpecialEffectTarget("war3mapImported\\BlueChakra2.mdx", c, "origin")
        endif
        call DestroyEffect(AddSpecialEffectTarget("war3mapImported\\BitchAura.mdx", c, "origin"))
        call DbzT_Sonido("war3mapImported\\SS.mp3", GetUnitX(c), GetUnitY(c))
        call DisplayTimedTextToPlayer(Player(p), 0., 0., 4., "Forma " + I2S(DbzT_Forma[p]) + ": daño +" + I2S(25 * DbzT_Forma[p]) + " %.")
    endif
    set c = null
endfunction

// Al cambiar de personaje (Dbz_Crear) se pierde la forma.
function DbzT_Reiniciar takes integer p returns nothing
    set DbzT_Forma[p] = 0
    if DbzT_CabezaFx[p] != null then
        call DestroyEffect(DbzT_CabezaFx[p])
        set DbzT_CabezaFx[p] = null
    endif
    if DbzT_AuraFx[p] != null then
        call DestroyEffect(DbzT_AuraFx[p])
        set DbzT_AuraFx[p] = null
    endif
endfunction

function DbzT_Init takes nothing returns nothing
    set DbzT_H = InitHashtable()
    set DbzT_G = CreateGroup()
    set Missile__missileList[DBZT_SID] = s__Missile_allocateCollection()
    set Missile__expression[DBZT_SID] = Condition(function DbzT_Iterar)
    call RegisterSpellEffectEvent('Az06', function DbzT_Kamehameha)
    call RegisterSpellEffectEvent('Az04', function DbzT_Warp)
    call RegisterSpellEffectEvent('Az05', function DbzT_DragonFist)
    call RegisterSpellEffectEvent('Az01', function DbzT_SpiritBomb)
    call RegisterSpellEffectEvent('Az00', function DbzT_PowerUp)
    call RegisterSpellEffectEvent('Az0B', function DbzT_Galick)
    call RegisterSpellEffectEvent('Az0D', function DbzT_BigBang)
    call RegisterSpellEffectEvent('Az0C', function DbzT_FinalFlash)
    call RegisterSpellEffectEvent('Az07', function DbzT_FinalExplosion)
    call RegisterSpellEffectEvent('Az08', function DbzT_PowerUp)
endfunction
