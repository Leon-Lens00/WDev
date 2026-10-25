
library stage1 initializer InitStage1 requires WavePlayerUtils, WaveCore, WaveOwnerPolicy, WaveRestTimeBridge, HeroLives, AIProfiles, AIConfig, IAManager, TenderSystem, PreConfi, WavePointGroupsConfig, PlayerHeroState, WaveMultiboard

// Presentacion de cada oleada: animacion del tendero, musica y mensaje.
private function Stage1PlayIntro takes integer waveIndex returns nothing
    if GetTenderUnit() != null then
        call SetUnitAnimation(GetTenderUnit(), "Spell")
    endif
    if waveIndex > 1 then
        if SwlsSound != null then
            call StopSound(SwlsSound, true, false)
            set SwlsSound = null
        endif
    endif
    if waveIndex == 1 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 1.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 80
    call SetSoundVolume(SwlsSound,80)
    set Message = "Ahora siendo cannon por aqui jeje, asi que un saludo mio y mi creador Leforyer por cierto tienes un apartado especial para que este pendiende de lo que viene en la sig Wave"
    elseif waveIndex == 2 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 2.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 60
    call SetSoundVolume(SwlsSound,60)
    set Message = "Se que no es mucho pero ante los fuertes ataque que sufri es lo minimo que puedo dar, pero animos ire mejorando implementaciones a futuro, defiende The Pueblo!!! "
    elseif waveIndex == 3 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 3.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 60
    call SetSoundVolume(SwlsSound,60)
    set Message = "Estas waves se vuelven mas fuertes cada vez, ahora incluso aprendieron habilidades especiales debido a la DevCorruption, Animos adquiere unas mejoras y eliminalos de aqui"
    elseif waveIndex == 4 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 4.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 60
    call SetSoundVolume(SwlsSound,60)
    set Message = "Lamentablemente en este tiempo los heroes encargados de defender el pueblo no lograron, me causa mucha tristeza.. pero ustedes se que lo lograran, animos!!"
    elseif waveIndex == 5 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 5.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 80
    call SetSoundVolume(SwlsSound,80)
    set Message = "Aquella mutacion de las unidades a mas grandes llamado bosses es un monton, hasta potencia mucho su habilidad normal, esto la verda aterra mucho a la vez"
    elseif waveIndex == 6 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 6.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 80
    call SetSoundVolume(SwlsSound,80)
    set Message = "Segun lo que me conto roucky aquella corrupcion que ocurrio en tu mundo se propago por aqui, pero a cambio tambien puedo beneficiarte pronto con mejoras exclusivas de este mundo!!"
    elseif waveIndex == 7 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 7.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 80
    call SetSoundVolume(SwlsSound,80)
    set Message = "Queda poco no te rindas, espero poder anhelar la recuperacion del pueblo, extrano sus lindos momentos cuando todo era armonia aqui"
    elseif waveIndex == 8 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 8.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 90
    call SetSoundVolume(SwlsSound,90)
    set Message = "Segun lo que conton roucky esta corruption conecta varios mundo... no me imagino un ataque aqui con criaturas de diferentes mundo.."
    elseif waveIndex == 9 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 9.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 80
    call SetSoundVolume(SwlsSound,80)
    set Message = "Estamos a un paso de librar esta corrupcion, pondre a disposicion toda la enegia que pueda para mantener equilibrio por aqui"
    elseif waveIndex == 10 then
    set SwlsSound = CreateSound("war3mapImported\\Wave 11.wav", true, false, false, 12700,12700,"")
    call SetSoundPitch(SwlsSound,1.0)
    set SwlsSoundWaveVolume = 80
    call SetSoundVolume(SwlsSound,80)
    set Message = "Llegamos a la final!! derrotando esta wave tendre la energia suficiente para llevarle al enemigo final o poner fin a este desastre (FinalBossAunPorTerminar)"
    else
    endif
    if SwlsSound != null then
        call StartSound(SwlsSound)
    endif
endfunction

// Composicion de cada oleada: slots acumulativos por tipo y jefe propio de la oleada.
private function Stage1AddSlots takes Wave w, integer waveIndex returns nothing
    //call w.addSlot('n00B', 10, 2, 2, 4,  50, true, Player(10))
    //call w.addSlot('n00B', 10, 2, 2, 5,  50, true, Player(11)) AI_PROFILE_WAVE1_SPELL
    
    if waveIndex >= 1 then
        call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HPEA, 'hpea', 1, false, 2, 1, 1, -1, false, AI_PROFILE_MELEE, 0, 0, 1.00)
        //call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HKNI, 'hkni', 2, true, 2, 1, 5, -1, false, AI_PROFILE_MELEE, 0, 0, 1.00)
        //call WaveAddSlotExByPlayer(w, 'zA04', 1,true, 2, 1, 1, 15, true,Player(11), AI_PROFILE_BOSS, 0, 0, 1.00)
        //call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HMPR, 'hmpr', 1, true, 2, 1, 7, -1, false, AI_PROFILE_WAVE7_SPELL, 0, 0, 1.10)
        // Ejemplo spell-profile (requiere que la unidad tenga la habilidad configurada en AIConfig):
        // call WaveAddSlotExByPlayers(w, 'hfoo', 2, true, 2, 1, 1, -1, false, AI_PROFILE_WAVE1_SPELL, 0, 0, 1.00)
        // Boss unico REAL (owner puntual, sin escalar por jugadores activos):
        // call WaveAddSlotExByPlayer(w, 'Ubos', 1, false, 1, 9, 10, -1, true, Player(10), AI_PROFILE_CASTER, 0, 0, 2.00)
        // Miniboss escalable por jugadores activos:
        // call WaveAddSlotExByPlayers(w, 'Umbs', 1, true, 1, 8, 11, -1, true, AI_PROFILE_MELEE, 0, 0, 1.40)

        //call WaveAddSlotExByPlayer(w, 'hpea', 1,false, 2, 1, 1, -1, false,Player(11), AI_PROFILE_MELEE, 0, 0, 1.00)
        //call WaveAddSlotExByPlayer(w, 'hmpr', 2,false, 2, 1, 1, -1, false,Player(11), AI_PROFILE_WAVE7_SPELL, 0, 0, 1.00)
        endif
        if waveIndex >= 2 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HMIL, 'hmil', 2, false, 2, 1, 2, -1, false, AI_PROFILE_MELEE, 0, 0, 1.00)
            if waveIndex == 2 then
                call WaveAddSlotExByPlayer(w, 'zA01', 2,false, 2, 1, 1, 5, true,Player(11), AI_PROFILE_BOSS, 0, 0, 1.00)
            endif
        endif
        if waveIndex >= 3 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HFOO, 'hfoo', 2, false, 2, 1, 3, -1, false, AI_PROFILE_MELEE, 0, 0, 1.00)
            if waveIndex == 3 then
            call WaveAddSlotExByPlayer(w, 'zA02', 2,false, 2, 1, 1, 10, true,Player(11), AI_PROFILE_BOSS, 0, 0, 1.00)
        endif
            endif
        if waveIndex >= 4 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HRIF, 'hrif', 2, false, 2, 1, 4, -1, false, AI_PROFILE_WAVE4_SPELL, 0, 0, 1.00)
            if waveIndex == 4 then
            call WaveAddSlotExByPlayer(w, 'zA03', 2,false, 2, 1, 1, 15, true,Player(11), AI_PROFILE_BOSS, 0, 0, 1.00)
        endif
            endif
        if waveIndex >= 5 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HKNI, 'hkni', 2, true, 2, 1, 5, -1, false, AI_PROFILE_MELEE, 0, 0, 1.00)
            if waveIndex == 5 then
            call WaveAddSlotExByPlayer(w, 'zA04', 2,false, 2, 1, 1, 15, true,Player(11), AI_PROFILE_BOSS, 0, 0, 1.00)
            endif
        endif
        if waveIndex >= 6 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HMTM, 'hmtm', 2, true, 2, 1, 6, -1, false, AI_PROFILE_WAVE6_SPELL, 0, 0, 1.00)
            if waveIndex == 6 then
            call WaveAddSlotExByPlayer(w, 'zA05', 2,false, 2, 1, 1, 15, true,Player(11), AI_PROFILE_WAVE6_BOSS, 0, 0, 1.00)
            endif
        endif
        if waveIndex >= 7 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HMPR, 'hmpr', 2, true, 2, 1, 7, -1, false, AI_PROFILE_WAVE7_SPELL, 0, 0, 1.10)
            if waveIndex == 7 then
            call WaveAddSlotExByPlayer(w, 'zA07', 2,false, 2, 1, 1, 15, true,Player(11), AI_PROFILE_WAVE7_BOSS, 0, 0, 1.00)
            endif
        endif
        if waveIndex >= 8 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HSOR, 'hsor', 2, true, 2, 1, 8, -1, false, AI_PROFILE_WAVE8_SPELL, 0, 0, 1.20)
            if waveIndex == 8 then
            call WaveAddSlotExByPlayer(w, 'zA06', 2,false, 2, 1, 1, 15, true,Player(11), AI_PROFILE_WAVE8_BOSS, 0, 0, 1.00)
            endif
        endif
        if waveIndex >= 9 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HMTT, 'hmtt', 2, true, 2, 1, 9, -1, false, AI_PROFILE_WAVE9_SPELL, 0, 0, 1.00)
            if waveIndex == 9 then
            call WaveAddSlotExByPlayer(w, 'zA08', 2,false, 2, 1, 1, 15, true,Player(11), AI_PROFILE_WAVE9_BOSS, 0, 0, 1.00)
            endif
        endif
        if waveIndex >= 10 then
            call WaveUpsertSlotExByPlayers(w, AI_STAGE1_SLOT_GROUP_HWT3, 'hwt3', 2, true, 2, 1, 10, -1, false, AI_PROFILE_WAVE10_SPELL, 0, 0, 1.00)
            if waveIndex == 10 then
            call WaveAddSlotExByPlayer(w, 'zA09', 2,false, 2, 1, 1, 15, true,Player(11), AI_PROFILE_WAVE10_BOSS, 0, 0, 1.00)
            endif
        endif

    
endfunction

function Trig_w1_Actions takes nothing returns nothing
    local Wave w
    local integer i = 0
    local integer stage1MainPathExpected = 0
    local integer stage1MainPathPoints = 0
    local WavePlayer u
    
    call Stage1PlayIntro(TargetWave)
    set isWavez = true
    //call KillSoundWhenDone(SwlsSound)
    set w = Wave.create(30, 15, 0.25, TargetWave, 10)
    // Conexiones de partida: el tablero se refresca por eventos y RestTime encadena el descanso al terminar.
    call WaveMultiboardBind(w, SwlsMultiboard)
    call WaveRestTimeBindNext(w, "Trig_w1_Actions")
    // Escalado por jugador adicional:
    // 100.0 = +100% de la base por jugador extra (equivalente al comportamiento anterior 2*jugadores)
    // 50.0  = +50% de la base por jugador extra
    call WaveSetAdditionalPerPlayerPercent(w, 100.0)
    // Si el grupo fue cargado desde markers, este bloque reemplaza el manual.
    set stage1MainPathExpected = WavePointGroupCount("Stage1_ThePueblo")
    if stage1MainPathExpected == 0 then
        call BJDebugMsg("Error No Points")
    endif
    set stage1MainPathPoints = WavePointGroupApplyToWave(w, "Stage1_ThePueblo")
    if stage1MainPathPoints < stage1MainPathExpected then
        call BJDebugMsg("Error No Partial Points") 
    endif
    
    
    set i = 0
    loop
        exitwhen i == WavePlayer.AmountPlaying //static jeje por eso sin variable
        set u = WavePlayer.fromPlaying(i)
        call AISetTrackedHero(PlayerHero[u.id])
        call w.addNearUnit(PlayerHero[u.id])
        set i = i + 1
    endloop
    // Con heroes registrados, evitamos fallback por group para mapa amplio.
    call AISetUseGroupFallbackNoHeroes(false)
    

    call Stage1AddSlots(w, TargetWave)

    call w.start()
    set i = 0
    loop
        exitwhen i == WavePlayer.AmountPlaying
        set u = WavePlayer.fromPlaying(i)
        if WavePlayer.Local == u.handle and PlayerHero[u.id] != null and GetUnitTypeId(PlayerHero[u.id]) != 0 then
            call SelectUnit(PlayerHero[u.id], true)
        endif
        set i = i + 1
    endloop

endfunction

private function InitStage1 takes nothing returns nothing
    if SwlsWaveStartTrigger == null then
        set SwlsWaveStartTrigger = CreateTrigger()
    endif
    call TriggerAddAction(SwlsWaveStartTrigger, function Trig_w1_Actions)
endfunction

//===========================================================================
endlibrary




