// v16t-dbz (12/11/2026): personajes DBZ de Battle Stadium D.O.N 2.1a (Valkemiere) para la prueba privada de Leon.
// Al entrar a la partida cada jugador elige uno de los 16 en un diálogo de dos páginas; "-dbz" vuelve a abrirlo. El
// cuerpo de la MP5 queda oculto, pausado y pegado al personaje (las oleadas siguen yendo hacia él) y la cámara sigue al
// personaje (ConversationUI___FollowCamera). Rawcodes: HDz0..HDzF elegibles; las habilidades 'Az??' salen de
// objetos_dbz.py. Misión "Créditos" en F9 con los autores de los recursos ajenos del mapa.

function Dbz_Nombre takes integer k returns string
    if k == 0 then
        return "Goku"
    elseif k == 1 then
        return "Vegeta"
    elseif k == 2 then
        return "Gohan"
    elseif k == 3 then
        return "Piccolo"
    elseif k == 4 then
        return "Future Trunks"
    elseif k == 5 then
        return "Goten y Trunks"
    elseif k == 6 then
        return "Gogeta"
    elseif k == 7 then
        return "Vegito"
    elseif k == 8 then
        return "Majin Buu"
    elseif k == 9 then
        return "Kid Buu"
    elseif k == 10 then
        return "Broly"
    elseif k == 11 then
        return "Cell"
    elseif k == 12 then
        return "Janemba"
    elseif k == 13 then
        return "Frieza"
    elseif k == 14 then
        return "Bardock"
    endif
    return "Goku Black"
endfunction

function Dbz_Tipo takes integer k returns integer
    if k < 10 then
        return 'HDz0' + k
    endif
    // 'HDz9' + 1 no es 'HDzA': las cifras y las letras no son contiguas.
    return 'HDzA' + k - 10
endfunction

// Página 0: personajes 0-7 y "Más"; página 1: 8-15 y "Volver". Cada botón guarda su personaje en Dbz_BtnK.
function Dbz_Pagina takes integer p, integer pag returns nothing
    local integer i = 0
    local integer k
    call DialogClear(Dbz_D[p])
    call DialogSetMessage(Dbz_D[p], "Personajes DBZ (" + I2S(pag + 1) + "/2)")
    loop
        exitwhen i > 7
        set k = pag * 8 + i
        set Dbz_Btn[p * 10 + i] = DialogAddButton(Dbz_D[p], Dbz_Nombre(k), 0)
        set Dbz_BtnK[p * 10 + i] = k
        set i = i + 1
    endloop
    if pag == 0 then
        set Dbz_Btn[p * 10 + 8] = DialogAddButton(Dbz_D[p], "Más personajes...", 0)
        set Dbz_BtnK[p * 10 + 8] = - 2
    else
        set Dbz_Btn[p * 10 + 8] = DialogAddButton(Dbz_D[p], "Volver...", 0)
        set Dbz_BtnK[p * 10 + 8] = - 1
    endif
    set Dbz_Btn[p * 10 + 9] = DialogAddButton(Dbz_D[p], "Cerrar", 0)
    set Dbz_BtnK[p * 10 + 9] = - 3
    call DialogDisplay(Player(p), Dbz_D[p], true)
endfunction

function Dbz_Crear takes integer p, integer k returns nothing
    local real x = GetUnitX(Game_Hero[p])
    local real y = GetUnitY(Game_Hero[p])
    if Dbz_U[p] != null then
        set x = GetUnitX(Dbz_U[p])
        set y = GetUnitY(Dbz_U[p])
        call RemoveUnit(Dbz_U[p])
    endif
    set Dbz_U[p] = CreateUnit(Player(p), Dbz_Tipo(k), x, y, 270.)
    set Dbz_K[p] = k
    call WaveAIRegisterTarget(Dbz_U[p])
    call ShowUnit(Game_Hero[p], false)
    call PauseUnit(Game_Hero[p], true)
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl", x, y))
    call DisplayTimedTextToPlayer(Player(p), 0., 0., 8., "|cffffcc00" + Dbz_Nombre(k) + "|r listo. Escribe |cffffcc00-dbz|r para cambiar de personaje.")
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
        call SelectUnit(Dbz_U[p], true)
    endif
endfunction

function Dbz_Clic takes nothing returns nothing
    local button b = GetClickedButton()
    local integer p = 0
    local integer i
    local integer k
    loop
        exitwhen p > 7
        if Dbz_D[p] == GetClickedDialog() then
            set i = 0
            loop
                exitwhen i > 9
                if Dbz_Btn[p * 10 + i] == b then
                    set k = Dbz_BtnK[p * 10 + i]
                    if k == - 2 then
                        call Dbz_Pagina(p, 1)
                    elseif k == - 1 then
                        call Dbz_Pagina(p, 0)
                    elseif k >= 0 then
                        call DialogDisplay(Player(p), Dbz_D[p], false)
                        call Dbz_Crear(p, k)
                    else
                        call DialogDisplay(Player(p), Dbz_D[p], false)
                    endif
                    set b = null
                    return
                endif
                set i = i + 1
            endloop
        endif
        set p = p + 1
    endloop
    set b = null
endfunction

// Cada 0,1 s: ofrece la selección al entrar, el cuerpo de la MP5 acompaña al personaje y, si el personaje muere, se
// ofrece otra vez la selección.
function Dbz_Paso takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Game_On[p] and GetUnitTypeId(Game_Hero[p]) != 0 then
            if not Dbz_Visto[p] then
                set Dbz_Visto[p] = true
                call Dbz_Pagina(p, 0)
            elseif Dbz_U[p] != null and UnitAlive(Dbz_U[p]) then
                call SetUnitX(Game_Hero[p], GetUnitX(Dbz_U[p]))
                call SetUnitY(Game_Hero[p], GetUnitY(Dbz_U[p]))
                set Dbz_Muerto[p] = false
            elseif Dbz_U[p] != null and not Dbz_Muerto[p] then
                set Dbz_Muerto[p] = true
                call Dbz_Pagina(p, Dbz_K[p] / 8)
            endif
        endif
        set p = p + 1
    endloop
endfunction

function Dbz_Comando takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    if GetEventPlayerChatString() == "-dbz cd" and Dbz_U[p] != null then
        call UnitResetCooldown(Dbz_U[p])
        call SetUnitState(Dbz_U[p], UNIT_STATE_MANA, GetUnitState(Dbz_U[p], UNIT_STATE_MAX_MANA))
        call SetUnitState(Dbz_U[p], UNIT_STATE_LIFE, GetUnitState(Dbz_U[p], UNIT_STATE_MAX_LIFE))
        return
    endif
    if Game_On[p] then
        call Dbz_Pagina(p, 0)
    endif
endfunction

function Dbz_Creditos takes nothing returns nothing
    local quest q = CreateQuest()
    call QuestSetTitle(q, "Créditos")
    call QuestSetIconPath(q, "ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp")
    call QuestSetRequired(q, false)
    call QuestSetDiscovered(q, true)
    call QuestSetDescription(q, "Recursos de otros autores usados en Dev Mission. Gracias a todos.|n|n" + "|cffffcc00Mapas de referencia|r|nTwilight's Eve ORPG: Donach y KryptonRazer (Final R4.13a), Green_Day_Dance y Asayaki_Zac ([AF] Final), Jem (Evo). Ivan, Arch Sage y su definitiva.|nBattle Stadium D.O.N 2.1a: Valkemiere. Personajes DBZ, sus modelos, iconos y efectos; cámara lenta de la definitiva.|n|n" + "|cffffcc00Modelos y efectos|r|nVinz: Shot, Shot II, Firebrand Shot, Chain Grenade, Valiant Charge, Windwalk, Lightning Ball, Ghost, Purple Star, Royal Glow, Flare.|nVinz y Daemonic Sword: Daemonic Arrow.|nVexorian: dummy.mdx.|n|n")
    set q = CreateQuest()
    call QuestSetTitle(q, "Créditos: sistemas y sonidos")
    call QuestSetIconPath(q, "ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp")
    call QuestSetRequired(q, false)
    call QuestSetDiscovered(q, true)
    call QuestSetDescription(q, "|cffffcc00Sistemas|r|nBPower: Missile.|nBribe: SpellEffectEvent, Table.|nMagtheridon96: RegisterPlayerUnitEvent.|nNestharus: depuración de List.|nleandrotp: AbilitySilence.|nOVOgenez: Storm v1.3.1.|nThe_Silent: Dark Nights (ciclo de día y noche).|nVexorian: JassHelper.|n|n" + "|cffffcc00Sonidos|r|nShootingGay 0.7ENG: sonidos de disparo y avisos de habilidad.|n|n" + "|cffffcc00Mapa base|r|nAnomines (Kai Trausenegger).|n|nCada recurso pertenece a su autor. Copia de prueba privada.")
    set q = CreateQuest()
    call QuestSetTitle(q, "Personajes DBZ (prueba)")
    call QuestSetIconPath(q, "war3mapImported\\BTNSaiyanForm.blp")
    call QuestSetRequired(q, true)
    call QuestSetDiscovered(q, true)
    call QuestSetDescription(q, "Elige un personaje al entrar. |cffffcc00-dbz|r abre otra vez la selección; |cffffcc00-dbz cd|r recarga habilidades, vida y maná.|n|nFase 1: modelos, iconos y habilidades de base nativa. Las habilidades hechas por script en D.O.N se rehacen por tandas sobre el núcleo Missile del mapa (Goku y Vegeta primero).")
    set q = null
endfunction

function Dbz_Init takes nothing returns nothing
    local trigger d = CreateTrigger()
    local trigger c = CreateTrigger()
    local integer p = 0
    loop
        exitwhen p > 7
        set Dbz_D[p] = DialogCreate()
        call TriggerRegisterDialogEvent(d, Dbz_D[p])
        call TriggerRegisterPlayerChatEvent(c, Player(p), "-dbz", false)
        set p = p + 1
    endloop
    call TriggerAddAction(d, function Dbz_Clic)
    call TriggerAddAction(c, function Dbz_Comando)
    call TimerStart(CreateTimer(), 0.1, true, function Dbz_Paso)
    call Dbz_Creditos()
    set d = null
    set c = null
endfunction
