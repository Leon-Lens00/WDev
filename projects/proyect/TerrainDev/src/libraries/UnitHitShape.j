// TerrainDev Classic 1.27b. Per-model unit bodies for missile hits.
// Classic has no native to read the selection scale, so each type registers
// it from Units/unitUI.slk (War3Patch.mpq 1.27b, FrozenThone classic-assets).
library UnitHitShape initializer Init requires Table
struct UnitHitShape extends array
    // UI\MiscData.txt [SelectionCircle] ScaleFactor=72 (War3Patch.mpq 1.27b): the
    // circle quad is 72 x selection scale wide, so its radius is 36 x scale. The
    // drawn ring sits at 0.88..0.98 of that radius in SelectionCircle*.blp.
    static constant real UNIT_RADIUS = 36.
    private static Table selection
    private static Table collision

    static method register takes integer id, real selectionScale, real ucol returns nothing
        set selection.real[id] = selectionScale
        set collision.real[id] = ucol
    endmethod
    static method known takes unit u returns boolean
        return selection.real.has(GetUnitTypeId(u))
    endmethod
    // Body radius, or -1 for unregistered types (callers keep the native ucol test).
    static method radius takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if selection.real.has(id) then
            return selection.real[id]*UNIT_RADIUS
        endif
        return -1.
    endmethod
    static method ucol takes unit u returns real
        return collision.real[GetUnitTypeId(u)]
    endmethod

    static method initialize takes nothing returns nothing
        set selection = Table.create()
        set collision = Table.create()
        // Selection scale (unitUI.slk) and collision (UnitBalance.slk), 1.27b.
        call register('rftg',1.,24.) // hfoo base; ucol 24 set by rapid_objects.py
        call register('hfoo',1.,31.)
        call register('ugho',1.1,31.)
        call register('hkni',1.4,32.)
        call register('otau',1.6,48.)
        call register('ucry',1.85,32.)
        call register('uabo',2.1,48.)
        call register('okod',2.25,48.)
        // Missile models as test units (rapid_objects.py): ussc = collision radius / 36.
        call register('rfm1',30./36.,8.)
        call register('rfm2',6./36.,8.)
        call register('rfm3',18./36.,8.)
        // Bosses: abomination at model scale 2 / 3 (rapid_objects.py boss_targets).
        call register('rbs2',4.2,96.)
        call register('rbs3',6.3,144.)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call UnitHitShape.initialize()
endfunction
endlibrary
