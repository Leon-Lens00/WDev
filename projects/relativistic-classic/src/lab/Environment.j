library LabEnvironment requires LabSupport
    globals
        private boolean sightReady = false
        private boolean fallbackReady = false
        private boolean previousFog = true
        private boolean previousMask = true
        private boolean array sharedVision
        private boolean cliffReady = false
        private integer array tileLast
        private integer array savedTile
        private integer array savedVariation
        private integer originalTile = 0
        private integer alternateTile = 0
        private boolean tileArmed = false
        private constant real VISION_WAIT = 2.0
        private fogmodifier array referenceFog
        private boolean referenceEligible = false
        private integer visionPhase = 0
        private real phaseClock = 0.
        private real referenceX = -2000.
        private integer idleRemove1 = 0
        private integer idleRemove2 = 0
        private boolean visionRestored = false
    endglobals
    // Save every incoming shared-vision edge to the two probe players.
    private function ProbeAlliances takes boolean restore returns nothing
        local integer i = 0
        local integer j
        loop
            exitwhen i > PLAYER_NEUTRAL_PASSIVE
            set j = 1
            loop
                exitwhen j > 2
                if i != j then
                    if restore then
                        call SetPlayerAlliance(Player(i), Player(j), ALLIANCE_SHARED_VISION, sharedVision[i*2+j])
                    else
                        set sharedVision[i*2+j] = GetPlayerAlliance(Player(i), Player(j), ALLIANCE_SHARED_VISION)
                        call SetPlayerAlliance(Player(i), Player(j), ALLIANCE_SHARED_VISION, false)
                    endif
                endif
                set j = j + 1
            endloop
            set i = i + 1
        endloop
    endfunction

    private function VisionBoolean takes boolean value returns string
        if value then
            return "true"
        endif
        return "false"
    endfunction

    private function ReferenceStop takes integer i returns nothing
        if referenceFog[i] != null then
            call FogModifierStop(referenceFog[i])
            call DestroyFogModifier(referenceFog[i])
            set referenceFog[i] = null
        endif
    endfunction

    private function ReferenceSet takes integer i, player p, real x, real radius returns nothing
        call ReferenceStop(i)
        if radius > 0. then
            set referenceFog[i] = CreateFogModifierRadius(p, FOG_OF_WAR_VISIBLE, x, 3000., radius, true, false)
            call FogModifierStart(referenceFog[i])
        endif
    endfunction

    private function VisionPhase takes integer nextPhase returns nothing
        set visionPhase = nextPhase
        set phaseClock = TimerGetElapsed(RM_CLOCK)
    endfunction

    // ONLY native reference visibility enters these predicates, never missile probes.
    private function ReferenceTransferReady takes nothing returns boolean
        return not IsVisibleToPlayer(-800., 3000., Player(1)) and IsVisibleToPlayer(-800., 3000., Player(2)) and not IsVisibleToPlayer(2400., 3000., Player(2)) and IsVisibleToPlayer(2400., 3000., Player(1))
    endfunction

    private function ReferenceReady takes nothing returns boolean
        if visionPhase == 1 then
            return IsVisibleToPlayer(-1600., 3000., Player(1)) and not IsVisibleToPlayer(-1100., 3000., Player(1)) and not IsVisibleToPlayer(2400., 3000., Player(1)) and IsVisibleToPlayer(2400., 3000., Player(2)) and not IsVisibleToPlayer(2900., 3000., Player(2)) and not IsVisibleToPlayer(-1600., 3000., Player(2))
        elseif visionPhase == 2 then
            return not IsVisibleToPlayer(-1600., 3000., Player(1)) and not IsVisibleToPlayer(2400., 3000., Player(2))
        elseif visionPhase == 3 then
            return not IsVisibleToPlayer(-1600., 3000., Player(1)) and IsVisibleToPlayer(2400., 3000., Player(2))
        elseif visionPhase == 6 then
            return IsVisibleToPlayer(-800., 3000., Player(1)) and not IsVisibleToPlayer(-2400., 3000., Player(1)) and not IsVisibleToPlayer(-800., 3000., Player(2))
        elseif visionPhase == 8 then
            return ReferenceTransferReady()
        endif
        // Withdrawal and post-termination cleanup must both be clear.
        return not IsVisibleToPlayer(-800., 3000., Player(1)) and not IsVisibleToPlayer(-800., 3000., Player(2)) and not IsVisibleToPlayer(2400., 3000., Player(1)) and not IsVisibleToPlayer(2400., 3000., Player(2)) and not IsVisibleToPlayer(-1600., 3000., Player(1))
    endfunction

    private function VisionObservation takes string source returns nothing
        call RM_Record("OBS", "vision-reference-state", "phase=" + I2S(visionPhase) + " wait=" + source + " clock=" + R2S(TimerGetElapsed(RM_CLOCK)) + " elapsed=" + R2S(TimerGetElapsed(RM_CLOCK)-phaseClock) + " deadline=" + R2S(VISION_WAIT) + " rawInitialP1=" + VisionBoolean(IsVisibleToPlayer(-1600., 3000., Player(1))) + " actualInitialP1=" + VisionBoolean(IsVisibleToPlayer(-1600., 0., Player(1))) + " rawMovedP1=" + VisionBoolean(IsVisibleToPlayer(-800., 3000., Player(1))) + " rawMovedP2=" + VisionBoolean(IsVisibleToPlayer(-800., 3000., Player(2))) + " actualMovedP1=" + VisionBoolean(IsVisibleToPlayer(-800., 0., Player(1))) + " actualMovedP2=" + VisionBoolean(IsVisibleToPlayer(-800., 0., Player(2))) + " rawSourceP1=" + VisionBoolean(IsVisibleToPlayer(2400., 3000., Player(1))) + " rawSourceP2=" + VisionBoolean(IsVisibleToPlayer(2400., 3000., Player(2))) + " actualSourceP1=" + VisionBoolean(IsVisibleToPlayer(2400., 0., Player(1))) + " actualSourceP2=" + VisionBoolean(IsVisibleToPlayer(2400., 0., Player(2))))
    endfunction

    private function VisionRestorationCheck takes nothing returns nothing
        local integer i = 0
        local integer j
        local boolean restored = true
        loop
            exitwhen i > PLAYER_NEUTRAL_PASSIVE
            set j = 1
            loop
                exitwhen j > 2
                if i != j then
                    set restored = restored and GetPlayerAlliance(Player(i), Player(j), ALLIANCE_SHARED_VISION) == sharedVision[i*2+j]
                endif
                set j = j + 1
            endloop
            set i = i + 1
        endloop
        call RM_Check(restored, "vision-alliances-restored", "all saved incoming probe edges")
        call RM_Check(IsFogEnabled() == previousFog and IsFogMaskEnabled() == previousMask, "vision-fog-flags-restored", "saved fog and mask enable flags")
    endfunction

    private function VisionCleanup takes nothing returns nothing
        // Reuse the lab's public, idempotent missile/source disposal path.
        call RM_Cleanup()
        call ReferenceStop(1)
        call ReferenceStop(2)
        if not visionRestored then
            call ProbeAlliances(true)
            call FogEnable(previousFog)
            call FogMaskEnable(previousMask)
            set visionRestored = true
            call RM_Record("SKIP", "multiplayer", "single client cannot establish synchronization; repeat with two 1.27b clients")
        endif
        call VisionRestorationCheck()
        call RM_Equal(RM_REMOVE[1], 1, "vision-remove-once")
        call RM_Equal(RM_REMOVE[2], 1, "vision-fallback-remove-once")
        set idleRemove1 = RM_REMOVE[1]
        set idleRemove2 = RM_REMOVE[2]
        call VisionPhase(12)
    endfunction

    private function VisionVisibilityCleanup takes nothing returns nothing
        if sightReady then
            call RM_Check(not IsVisibleToPlayer(-1600., 0., Player(1)), "vision-cleanup", "current visibility removed; explored fog is not visibility")
        endif
        if fallbackReady then
            call RM_Check(not IsVisibleToPlayer(2400., 0., Player(2)), "vision-fallback-cleanup", "source remains far from probe")
        endif
    endfunction

    private function VisionTimeout takes string source returns nothing
        call RM_Record("FAIL", "vision-reference-timeout", "phase=" + I2S(visionPhase) + " wait=" + source + " deadline=" + R2S(VISION_WAIT) + " elapsed=" + R2S(TimerGetElapsed(RM_CLOCK)-phaseClock))
        call RM_Record("OBS", "vision-aborted-original-rules", "remaining original visibility rules not evaluated after fixture timeout; not acceptance")
        if visionPhase == 13 then
            // Cleanup timeout also fails loudly, but restoration can never wait again.
            call VisionCleanup()
        else
            call RM_Cleanup()
            call ReferenceStop(1)
            call ReferenceStop(2)
            call VisionPhase(13)
        endif
    endfunction

    private function VisionGate takes string source, boolean ready returns boolean
        call VisionObservation(source)
        if ready then
            return true
        endif
        if TimerGetElapsed(RM_CLOCK)-phaseClock >= VISION_WAIT then
            call VisionTimeout(source)
        endif
        return false
    endfunction

    private function ReferenceStart takes nothing returns nothing
        // Full original-radius extents and every translated probe must be in bounds.
        // The +3000Y strip cannot overlap the actual circles at Y0.
        set referenceEligible = WorldBounds.minX < -2900. and WorldBounds.maxX > 2900. and WorldBounds.minY < 2400. and WorldBounds.maxY > 3600.
        set referenceEligible = referenceEligible and not IsVisibleToPlayer(-1600., 3000., Player(1)) and not IsVisibleToPlayer(-1100., 3000., Player(1)) and not IsVisibleToPlayer(-2400., 3000., Player(1)) and not IsVisibleToPlayer(-800., 3000., Player(1)) and not IsVisibleToPlayer(-800., 3000., Player(2)) and not IsVisibleToPlayer(2400., 3000., Player(1)) and not IsVisibleToPlayer(2400., 3000., Player(2)) and not IsVisibleToPlayer(2900., 3000., Player(2)) and not IsVisibleToPlayer(-1600., 3000., Player(2))
        set referenceX = -2000.
        set visionRestored = false
        call VisionPhase(1)
        call RM_Record("OBS", "vision-reference-readiness", "bounds-and-hidden=" + VisionBoolean(referenceEligible) + " primaryActualEligible=" + VisionBoolean(sightReady) + " fallbackActualEligible=" + VisionBoolean(fallbackReady) + " translation=0,3000 radius=600 visible,true,false")
        if referenceEligible then
            // Later than actual vision setters/launch, not an earlier raw deadline.
            call ReferenceSet(1, Player(1), -2000., 600.)
            call ReferenceSet(2, Player(2), 2000., 600.)
        endif
    endfunction

    struct LabEnvironmentMissile extends Missiles
        method onBoundaries takes nothing returns boolean
            set RM_BOUNDS[data] = RM_BOUNDS[data] + 1
            return true
        endmethod
        method onTerrain takes nothing returns boolean
            if RM_CASE == 28 and data == 1 then
                set RM_HITS[data] = RM_HITS[data] + 1
                return true
            endif
            return false
        endmethod
        method onCliff takes nothing returns boolean
            set RM_DESTS[data] = RM_DESTS[data] + 1
            return RM_CASE == 28 and data == 2
        endmethod
        method onTileset takes integer tile returns boolean
            set RM_ITEMS[data] = RM_ITEMS[data] + 1
            set tileLast[data] = tile
            return RM_CASE == 46 and data == 2 and tileArmed
        endmethod
        method onRemove takes nothing returns nothing
            set RM_REMOVE[data] = RM_REMOVE[data] + 1
        endmethod
    endstruct

    function RM_EnvironmentStart takes nothing returns nothing
        local LabEnvironmentMissile m
        local LabEnvironmentMissile b
        local real wallZ
        if RM_CASE == 27 then
            call PanCameraToTimed(WorldBounds.maxX-200., 0., .2)
            set m = LabEnvironmentMissile.create(WorldBounds.maxX-10., 0., 100., WorldBounds.maxX+800., 0., 100.)
            call RM_Visual(m, 1)
            set m.speed = 400.
        elseif RM_CASE == 28 then
            set m = LabEnvironmentMissile.create(0., 0., -20., 800., 0., -20.)
            call RM_Visual(m, 1)
            set m.speed = 400.
            // Read-only W3E survey found a level0->1 edge at these vertices.
            // Gate against real native levels; never substitute bytes for runtime proof.
            set cliffReady = GetTerrainCliffLevel(-2048., 1536.) < GetTerrainCliffLevel(-1920., 1536.)
            if cliffReady then
                set wallZ = (GetTerrainCliffLevel(-1920., 1536.)-GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY))*bj_CLIFFHEIGHT-1.
                set b = LabEnvironmentMissile.create(-2048., 1536., wallZ-RM_Ground(-2048., 1536.), -1024., 1536., wallZ-RM_Ground(-1024., 1536.))
                call RM_Visual(b, 2)
                set b.speed = 128./Missiles_PERIOD
                set RM_M[2] = b
                call b.launch()
                call PanCameraToTimed(-2048., 1536., .2)
                call RM_Record("OBS", "surveyed-cliff-fixture", "native uphill -2048,1536 to -1920,1536; Z one below source wall equation")
            else
                call RM_Record("SKIP", "cliff-transition", "W3E candidate -2048,1536 to -1920,1536 lacks native uphill; needs native-confirmed adjacent128 uphill edge and wall equation minus1 Z")
            endif
        else
            call PanCameraToTimed(-2000., 0., .2)
            set previousFog = IsFogEnabled()
            set previousMask = IsFogMaskEnabled()
            call FogEnable(true)
            call FogMaskEnable(true)
            call ProbeAlliances(false)
            // Hard case watchdog; normal completion lowers this at the final idle step.
            set RM_LIMIT = 160
            // Gate all probes before any modifier exists: initial map vision is
            // not evidence that this missile revealed a point.
            set sightReady = not IsVisibleToPlayer(-1600., 0., Player(1)) and not IsVisibleToPlayer(-1100., 0., Player(1)) and not IsVisibleToPlayer(-2400., 0., Player(1)) and not IsVisibleToPlayer(-800., 0., Player(1)) and not IsVisibleToPlayer(-800., 0., Player(2))
            set fallbackReady = not IsVisibleToPlayer(2400., 0., Player(2)) and not IsVisibleToPlayer(2900., 0., Player(2)) and not IsVisibleToPlayer(2400., 0., Player(1))
            set m = LabEnvironmentMissile.create(-2000., 0., 1000., -1000., 0., 1000.)
            call RM_Visual(m, 1)
            set m.owner = Player(1)
            set m.vision = 600.
            set m.speed = 0.
            set RM_U = CreateUnit(Player(2), RM_UNIT, 0., -3000., 0.)
            call PauseUnit(RM_U, true)
            set b = LabEnvironmentMissile.create(2000., 0., 1000., 3000., 0., 1000.)
            call RM_Visual(b, 2)
            set b.owner = null
            set b.source = RM_U
            set b.vision = 600.
            set b.speed = 0.
            set RM_M[2] = b
            call b.launch()
            call RM_Near(m.vision, 600., .01, "vision-getter")
            call RM_Check(GetOwningPlayer(m.dummy) == Player(1), "vision-explicit-owner", "public dummy owner")
            call RM_Check(GetOwningPlayer(b.dummy) == Player(2), "vision-source-fallback", "public source owner")
        endif
        set RM_M[1] = m
        call m.launch()
        if RM_CASE == 29 then
            call ReferenceStart()
        endif
    endfunction

    // E29 owns its phases; the runner still supplies the same .25s checkpoints.
    private function VisionStep takes nothing returns nothing
        if visionPhase == 12 then
            call RM_Equal(RM_REMOVE[1], idleRemove1, "vision-idle-no-extra-remove")
            call RM_Equal(RM_REMOVE[2], idleRemove2, "vision-fallback-idle-no-extra-remove")
            call VisionRestorationCheck()
            set RM_LIMIT = RM_STAGE
            return
        endif
        if RM_STAGE >= RM_LIMIT then
            call RM_Record("FAIL", "vision-case-watchdog", "maximum160 runner checkpoints reached; forced cleanup/restoration")
            call VisionCleanup()
            set RM_LIMIT = RM_STAGE + 1
            return
        endif
        if visionPhase == 13 then
            if VisionGate("abort-cleanup-reference", ReferenceReady()) then
                call VisionVisibilityCleanup()
                call VisionCleanup()
            endif
            return
        endif
        if not referenceEligible then
            if not sightReady then
                call RM_Record("SKIP", "vision-radius-owner", "probe initially visible; needs unrevealed unoccluded region")
            endif
            if not fallbackReady then
                call RM_Record("SKIP", "vision-radius-source", "probe initially visible; needs unrevealed unoccluded region")
            endif
            call RM_Record("SKIP", "vision-reference-readiness", "translated reference bounds/initial hidden eligibility invalid; original visibility rules inconclusive, not PASS")
            call VisionCleanup()
            return
        endif
        if visionPhase == 4 then
            // First original .25s movement interval; never wait for reference here.
            call VisionPhase(5)
            return
        elseif visionPhase == 5 then
            // Stop after EXACTLY two existing runner ticks at1600, before any wait.
            set RM_M[1].speed = 0.
            set referenceX = RM_M[1].x
            call RM_Record("OBS", "vision-motion-stopped", "clock=" + R2S(TimerGetElapsed(RM_CLOCK)) + " publicX=" + R2S(referenceX) + " publicY=" + R2S(RM_M[1].y) + " dummyX=" + R2S(GetUnitX(RM_M[1].dummy)) + " dummyY=" + R2S(GetUnitY(RM_M[1].dummy)))
            call ReferenceSet(1, Player(1), referenceX, 600.)
            call VisionPhase(6)
            return
        elseif visionPhase == 7 then
            if not VisionGate("public-owner-reconciliation", GetOwningPlayer(RM_M[1].dummy) == Player(2) and GetOwningPlayer(RM_M[2].dummy) == Player(1)) then
                return
            endif
            call RM_Check(GetOwningPlayer(RM_M[1].dummy) == Player(2), "vision-owner-field-refresh", "direct owner change reconciled on visit")
            call RM_Check(GetOwningPlayer(RM_M[2].dummy) == Player(1), "vision-source-owner-refresh", "source owner change reconciled on visit")
            // Raw transfer is no earlier than observed public dummy reconciliation.
            call ReferenceSet(1, Player(2), referenceX, 600.)
            call ReferenceSet(2, Player(1), 2000., 600.)
            call VisionPhase(8)
            return
        elseif visionPhase == 9 then
            if not VisionGate("public-neutral-reconciliation", GetOwningPlayer(RM_M[1].dummy) == Player(PLAYER_NEUTRAL_PASSIVE) and GetOwningPlayer(RM_M[2].dummy) == Player(PLAYER_NEUTRAL_PASSIVE)) then
                return
            endif
            call RM_Check(GetOwningPlayer(RM_M[1].dummy) == Player(PLAYER_NEUTRAL_PASSIVE), "vision-null-source-neutral", "no explicit owner or source")
            call RM_Check(GetOwningPlayer(RM_M[2].dummy) == Player(PLAYER_NEUTRAL_PASSIVE), "vision-removed-source-neutral", "removed source is not a valid owner fallback")
            call ReferenceStop(1)
            call ReferenceStop(2)
            call VisionPhase(10)
            return
        endif
        if not VisionGate("native-reference", ReferenceReady()) then
            return
        endif
        if visionPhase == 1 then
            call RM_Check(ReferenceReady(), "vision-reference-reveal-isolation", "initially hidden raw probes reveal each owner and isolate other owner; original600/400/900 geometry")
            if sightReady then
                call RM_Check(IsVisibleToPlayer(-1600., 0., Player(1)), "vision-radius-owner", "initially hidden point 400 units inside requested600")
                call RM_Check(not IsVisibleToPlayer(-1100., 0., Player(1)), "vision-outside-owner", "point900 outside requested600")
                call RM_Check(not IsVisibleToPlayer(2400., 0., Player(1)), "vision-owner-isolation", "other owner instance must not reveal")
            else
                call RM_Record("SKIP", "vision-radius-owner", "probe initially visible; needs unrevealed unoccluded region")
            endif
            if fallbackReady then
                call RM_Check(IsVisibleToPlayer(2400., 0., Player(2)), "vision-radius-source", "initially hidden point400 inside requested600")
                call RM_Check(not IsVisibleToPlayer(2900., 0., Player(2)), "vision-outside-source", "point900 outside requested600")
            else
                call RM_Record("SKIP", "vision-radius-source", "probe initially visible; needs unrevealed unoccluded region")
            endif
            set RM_M[1].vision = 200.
            set RM_M[2].vision = 0.
            call ReferenceSet(1, Player(1), -2000., 200.)
            call ReferenceStop(2)
            call VisionPhase(2)
        elseif visionPhase == 2 then
            if sightReady then
                call RM_Check(not IsVisibleToPlayer(-1600., 0., Player(1)), "vision-shrink", "probe400 outside new200 radius")
            endif
            if fallbackReady then
                call RM_Check(not IsVisibleToPlayer(2400., 0., Player(2)), "vision-zero", "nonpositive radius removes current reveal")
            endif
            set RM_M[1].vision = -1.
            set RM_M[2].vision = 600.
            call ReferenceStop(1)
            call ReferenceSet(2, Player(2), 2000., 600.)
            call VisionPhase(3)
        elseif visionPhase == 3 then
            if sightReady then
                call RM_Check(not IsVisibleToPlayer(-1600., 0., Player(1)), "vision-negative", "negative radius also clears")
            endif
            if fallbackReady then
                call RM_Check(IsVisibleToPlayer(2400., 0., Player(2)), "vision-restored", "source fallback still reveals after zero")
            endif
            set RM_M[1].vision = 600.
            set RM_M[1].speed = 1600.
            call VisionPhase(4)
        elseif visionPhase == 6 then
            if sightReady then
                call RM_Check(IsVisibleToPlayer(-800., 0., Player(1)), "vision-moved-reveal", "new probe inside moving circle")
                call RM_Check(not IsVisibleToPlayer(-2400., 0., Player(1)), "vision-moved-clears-old", "old circle no longer supplies current visibility")
            endif
            set RM_M[1].owner = Player(2)
            call SetUnitOwner(RM_U, Player(1), false)
            call VisionPhase(7)
        elseif visionPhase == 8 then
            if sightReady then
                call RM_Check(not IsVisibleToPlayer(-800., 0., Player(1)) and IsVisibleToPlayer(-800., 0., Player(2)), "vision-owner-transfer", "no cross-player lingering reveal")
            endif
            if fallbackReady then
                call RM_Check(not IsVisibleToPlayer(2400., 0., Player(2)) and IsVisibleToPlayer(2400., 0., Player(1)), "vision-source-transfer", "effective source owner changed")
            endif
            set RM_M[1].owner = null
            call RemoveUnit(RM_U)
            set RM_U = null
            call VisionPhase(9)
        elseif visionPhase == 10 then
            if sightReady then
                call RM_Check(not IsVisibleToPlayer(-800., 0., Player(2)), "vision-neutral-transfer-clears", "previous effective owner loses reveal")
            endif
            if fallbackReady then
                call RM_Check(not IsVisibleToPlayer(2400., 0., Player(1)), "vision-source-removal-clears", "removed source no longer supplies owner")
            endif
            call RM_M[1].terminate()
            call RM_M[2].terminate()
            // Later-or-equal to actual termination, including the abort path.
            call ReferenceStop(1)
            call ReferenceStop(2)
            call VisionPhase(11)
        elseif visionPhase == 11 then
            call VisionVisibilityCleanup()
            call VisionCleanup()
        endif
    endfunction

    function RM_EnvironmentStep takes nothing returns nothing
        if RM_CASE == 29 then
            call VisionStep()
            return
        endif
        if RM_STAGE == RM_LIMIT then
            if RM_CASE == 27 then
                call RM_Equal(RM_BOUNDS[1], 1, "bounds-once")
                call RM_Equal(RM_REMOVE[1], 1, "bounds-remove-once")
            elseif RM_CASE == 28 then
                call RM_Equal(RM_HITS[1], 1, "below-terrain-event-once")
                call RM_Equal(RM_REMOVE[1], 1, "terrain-remove-once")
                if cliffReady then
                    call RM_Equal(RM_DESTS[2], 1, "surveyed-cliff-once")
                    call RM_Equal(RM_REMOVE[2], 1, "surveyed-cliff-remove-once")
                endif
            endif
        endif
    endfunction

    private function TileX takes integer i returns real
        return 64.+((i-1)-((i-1)/3)*3-1)*128.
    endfunction
    private function TileY takes integer i returns real
        return 64.+((i-1)/3-1)*128.
    endfunction

    private function RestoreTiles takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > 9
            call SetTerrainType(TileX(i), TileY(i), savedTile[i], savedVariation[i], 1, 1)
            set i = i + 1
        endloop
        set i = 1
        loop
            exitwhen i > 9
            call RM_Equal(GetTerrainType(TileX(i), TileY(i)), savedTile[i], "restored-tile-type-" + I2S(i))
            call RM_Equal(GetTerrainVariance(TileX(i), TileY(i)), savedVariation[i], "restored-tile-variation-" + I2S(i))
            set i = i + 1
        endloop
    endfunction

    private function TileMissile takes integer tag returns LabEnvironmentMissile
        local LabEnvironmentMissile m = LabEnvironmentMissile.create(64., 64., 1000., 1064., 64., 1000.)
        call RM_Visual(m, tag)
        set m.speed = 0.
        set RM_M[tag] = m
        call m.launch()
        return m
    endfunction

    function RM_TilesStart takes nothing returns nothing
        local integer i = 1
        local LabEnvironmentMissile m
        set tileArmed = false
        loop
            exitwhen i > 9
            set savedTile[i] = GetTerrainType(TileX(i), TileY(i))
            set savedVariation[i] = GetTerrainVariance(TileX(i), TileY(i))
            set i = i + 1
        endloop
        set originalTile = GetTerrainType(64., 64.)
        // Both rawcodes verified in the immutable W3E ground-tile inventory.
        if originalTile == 'Ldrt' then
            set alternateTile = 'Lgrs'
        else
            set alternateTile = 'Ldrt'
        endif
        set m = TileMissile(1)
    endfunction

    function RM_TilesStep takes nothing returns nothing
        local LabEnvironmentMissile m
        if RM_STAGE == 1 then
            call RM_Equal(RM_ITEMS[1], 1, "tileset-initialization-not-transition")
            call RM_Equal(tileLast[1], originalTile, "tileset-initial-callback-type")
            call SetTerrainType(64., 64., alternateTile, 0, 1, 1)
            call RM_Equal(GetTerrainType(64., 64.), alternateTile, "controlled-tileset-fixture")
        elseif RM_STAGE == 2 then
            call RM_Equal(RM_ITEMS[1], 2, "actual-tileset-transition-once")
            call RM_Equal(tileLast[1], alternateTile, "transition-callback-type")
            call RM_Equal(RM_M[1].tileset, alternateTile, "public-current-tileset")
            call RestoreTiles()
        elseif RM_STAGE == 3 then
            call RM_Equal(RM_ITEMS[1], 3, "restoration-transition-once")
            call RM_Equal(tileLast[1], originalTile, "restoration-callback-type")
            call RM_Equal(RM_M[1].tileset, originalTile, "public-restored-tileset")
            call RM_M[1].terminate()
            set m = TileMissile(2)
        elseif RM_STAGE == 4 then
            call RM_Equal(RM_ITEMS[2], 1, "terminal-tileset-initialization")
            set tileArmed = true
            call SetTerrainType(64., 64., alternateTile, 0, 1, 1)
        elseif RM_STAGE == 5 then
            call RM_Equal(RM_ITEMS[2], 2, "tileset-true-actual-transition")
            call RM_Equal(RM_REMOVE[2], 1, "tileset-true-removes-once")
            call RestoreTiles()
        elseif RM_STAGE == RM_LIMIT then
            call RM_Equal(RM_ITEMS[1], 3, "no-post-remove-tileset-callback")
            call RM_Equal(RM_REMOVE[1], 1, "tileset-observer-remove-once")
            call RM_Equal(RM_REMOVE[2], 1, "tileset-terminal-remove-still-once")
        endif
    endfunction
endlibrary
