#!/usr/bin/env python3
"""v21n (22/11/2026): Freezer de Battle Stadium D.O.N 2.1a con tiers, como Goku en v21m.

Leon: "pasamos ahora con el desarrollo del siguiente pj"; "habilidades que toman un target en la explosivo o momento
que hace danio deben hacerlos en area para que ayude en las oleadas"; Golden Form como "Técnica T con recarga" y
"Modelo dorado y bonos"; "verificar que con el morph no se rompa el light".

1. Código de Freezer 2.1a trasplantado (fz21_trasplante: GLOB.j, FUNC.j) en lugar del de 1.8c: Q You Will Die By My
   Hand (A0IX), W Imprisonment Ball (A0JD, a punto), E Death Break (A0J1), R Death Ball (A0IW), X Death Saucer (A0IY,
   sigue saliendo como pasiva al acertar con las armas), T Golden Form (A0OH). El init viejo (Fz_InitDON) ya no se
   llama; sus funciones quedan sin uso. Power Up por muertes desaparece.
2. Tiers T1-T6 (curva de v21m). Daño por enemigo en T6: Q 2900, W 2000, E 2000, R 5800, X 1500. Ya no depende del
   nivel de A0OH ni de Gk_Fuerza.
3. Regla de área: los golpes a un blanco pasan a área. E: cada uno de los 20 puñetazos da en 200 alrededor del blanco
   (la mitad del daño, repartida) y el remate en 350 (la otra mitad). W: al final, además de los 15 elegidos, todos
   los enemigos en 600 (una vez cada uno), también en la rama con blanco atrapado (G2F_Homing). R: el remate en 700
   alrededor de la explosión (60 %), además del 40 % al barrer. X: cada disco golpea una vez a cada enemigo en 125.
4. WAVE propia (G2F_WAVE): mueve los discos de Death Saucer (vuelven hacia la copia al pasar de 900 y se recogen al
   llegar) y los anillos de Golden. La WAVE de 2.1a no se trae.
5. Golden Form (T, 3 niveles, recarga 80 s): el cuerpo pasa a hFrG 35 s (copias hCpH) y las armas hacen +25/50/75 %
   mientras tenga el buff B025 (Her_Dano, como el Kaioken). Al acabar quita A06T, A00Y y A0G4.
6. Luz de la batería: se vuelve a poner cuando el cuerpo cambia de tipo (Golden, Kyuubi) y otra vez 0,6 y 1,2 s
   después, por si el modelo cambia al final de la transformación.
7. Pasiva X: Freezer espera 10 s entre discos (antes 1,5 s, cuando el disco hacía poco daño).
8. Sonidos de Freezer en 3D, como en v21e (CAMBIOS: SSfrieza mono).
9. Warp Kamehameha destruía G2V_Group[6060] en vez del grupo que crea (fuga): ahora G2V_Group[5850].
Registro (sólo prueba): "freezer dano" por técnica, como "goku dano"; -gt N pone en el tier N todas las técnicas con
tier del personaje del jugador.
Uso: v21n.py ENTRADA.j GLOB.j FUNC.j CAMBIOS.tsv SALIDA.j [prueba]   (normal de v21m; prueba de v21m-prueba).
"""
import re
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
glob = Path(sys.argv[2]).read_bytes().decode('latin-1').replace('\r\n', '\n')
func = Path(sys.argv[3]).read_bytes().decode('latin-1').replace('\r\n', '\n')
CAMBIOS = dict(l.rstrip('\n').split('\t') for l in open(sys.argv[4], encoding='latin-1') if l.strip())
prueba = len(sys.argv) > 6 and sys.argv[6] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


def fz(viejo, nuevo, veces=1):
    global func
    assert func.count(viejo) == veces, (func.count(viejo), viejo[:90])
    func = func.replace(viejo, nuevo)


# ---------------------------------------------------------------- sonidos 3D (como v21e)
def sonidos3d(t, cuerpo_de):
    def crea(m):
        ruta = m.group(1).replace('\\\\', '\\')
        ruta = CAMBIOS.get(ruta, ruta).replace('\\', '\\\\')
        return f'CreateSound("{ruta}",{m.group(2)},true,true,'
    n = 0

    def init(m):
        nonlocal n
        cuerpo, c = re.subn(r'CreateSound\("([^"]+)",(true|false),(?:true|false),(?:true|false),', crea, m.group(0))
        n += c
        vars_ = re.findall(r'^set (\w+)=CreateSound\(', cuerpo, re.M)
        return cuerpo[:-len('endfunction\n')] + ''.join(f'call Son_DON3D({v})\n' for v in vars_) + 'endfunction\n'
    t, k = re.subn(r'^function \w+_InitDON takes.*?^endfunction\n', init, t, flags=re.S | re.M)

    def bloque(m):
        nombre = m.group(1)
        for pref, kk in cuerpo_de.items():
            if nombre.startswith(pref):
                return re.sub(r'call PlaySoundBJ\((\w+)\)', lambda q: f'call Son_DONSuena({q.group(1)},{kk})', m.group(0))
        return m.group(0)
    t = re.sub(r'^function (\w+) takes.*?^endfunction\n', bloque, t, flags=re.S | re.M)
    return t, n, k


func, nsf, kif = sonidos3d(func, {'G2F_': 1})
assert 'PlaySoundBJ(' not in func and kif == 1 and nsf == 18, (nsf, kif)
assert 'M3D_SSfrieza' in func


def golpe(linea, s, x, src_, tgt, dmg, veces=1):
    if prueba:
        fz(linea + '\n', linea + '\ncall Gk_Suma(%d,%d,%s,%s,%s)\n' % (s, x, src_, tgt, dmg), veces)


# ---------------------------------------------------------------- daño por tier y área (FUNC.j)
# Q: una vez por enemigo (Group2[$C4]).
fz("set G2V_Damage[6000]=((100*GetUnitAbilityLevelSwapped('A0IX',G2V_Caster[6000]))+(2*Gk_Fuerza(G2V_Caster[6000])))\n",
   "set G2V_Damage[6000]=R2I(Gk_TDano(G2V_Caster[6000],49,2900.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[6000],GetEnumUnit(),I2R(G2V_Damage[6000]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      3, 49, 'G2V_Caster[6000]', 'GetEnumUnit()', 'I2R(G2V_Damage[6000])')
# R: 40 % al barrer (una vez por enemigo, Group3[$B]) y 60 % en área al explotar.
fz("set G2V_Damage2[5990]=((300*GetUnitAbilityLevelSwapped('A0OH',G2V_Caster[5990]))+(3*Gk_Fuerza(G2V_Caster[5990])))\n",
   "set G2V_Damage2[5990]=R2I(.4*Gk_TDano(G2V_Caster[5990],45,5800.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[5990],GetEnumUnit(),I2R(G2V_Damage2[5990]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      6, 45, 'G2V_Caster[5990]', 'GetEnumUnit()', 'I2R(G2V_Damage2[5990])')
fz('call ForGroupBJ(G2V_Group3[$B],function G2F_Next_Deathball_Func001Func001Func016Func059A)\n',
   '// v21n: el remate de la Death Ball es en área (700), no sólo a los barridos.\n'
   'call Fz_Area(G2V_Caster[5990],GetLocationX(G2V_Point[5992]),GetLocationY(G2V_Point[5992]),700.,'
   '.6*Gk_TDano(G2V_Caster[5990],45,5800.),null,6,45)\n')
# X: medio daño por disco (dos discos); los golpes los da G2F_WAVE.
fz('set G2V_WaveDamage[G2V_WaveIndex]=((2*Gk_Fuerza(G2V_Caster[5980]))/$A)\n',
   'set G2V_WaveDamage[G2V_WaveIndex]=R2I(Gk_TDano(G2V_Caster[5980],46,1500.)/2.)\n', 2)
# W sin atrapar: los 15 elegidos y luego el resto en 600, una vez cada uno.
fz("set G2V_Damage2[5970]=((75*GetUnitAbilityLevelSwapped('A0JD',G2V_Caster[5970]))+(2*Gk_Fuerza(G2V_Caster[5970])))\n",
   "set G2V_Damage2[5970]=R2I(Gk_TDano(G2V_Caster[5970],48,2000.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[5970],GetEnumUnit(),I2R(G2V_Damage2[5970]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      4, 48, 'G2V_Caster[5970]', 'GetEnumUnit()', 'I2R(G2V_Damage2[5970])')
fz("""call DestroyGroup(G2V_Group[5970])
set bj_forLoopAIndex=bj_forLoopAIndex+1
endloop
call CreateNUnitsAtLoc(1,'h03A',GetOwningPlayer(G2V_Caster[5970]),G2V_Point[5973],G2V_Angle[5970])
""", """call DestroyGroup(G2V_Group[5970])
set bj_forLoopAIndex=bj_forLoopAIndex+1
endloop
// v21n: regla de área, todos los enemigos en 600 que no estaban entre los 15.
call Fz_Area(G2V_Caster[5970],GetLocationX(G2V_Point[5973]),GetLocationY(G2V_Point[5973]),600.,I2R(G2V_Damage2[5970]),G2V_Group3[$9B],4,48)
call CreateNUnitsAtLoc(1,'h03A',GetOwningPlayer(G2V_Caster[5970]),G2V_Point[5973],G2V_Angle[5970])
""")
# E: 20 puñetazos en área alrededor del blanco (mitad del daño) y remate en 350 (la otra mitad).
fz('call UnitDamageTargetBJ(G2V_Caster[6010],G2V_Caster[6011],(I2R(Gk_Fuerza(G2V_Caster[6010]))/6.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n',
   '// v21n: cada puñetazo da en 200 alrededor del blanco.\n'
   'call Fz_Area(G2V_Caster[6010],GetLocationX(G2V_Point[6012]),GetLocationY(G2V_Point[6012]),200.,'
   'Gk_TDano(G2V_Caster[6010],47,2000.)*.5/20.,null,5,47)\n')
fz("call UnitDamageTargetBJ(G2V_Caster[6010],GetEnumUnit(),(100.*I2R(GetUnitAbilityLevelSwapped('A0J1',G2V_Caster[6010]))),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n",
   "call UnitDamageTargetBJ(G2V_Caster[6010],GetEnumUnit(),.5*Gk_TDano(G2V_Caster[6010],47,2000.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[6010],GetEnumUnit(),.5*Gk_TDano(G2V_Caster[6010],47,2000.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      5, 47, 'G2V_Caster[6010]', 'GetEnumUnit()', '.5*Gk_TDano(G2V_Caster[6010],47,2000.)')

# ---------------------------------------------------------------- Golden Form
fz("""function G2F_Frieza_Golden_Transformation_Actions takes nothing returns nothing
set G2V_Caster[7190]=GetSpellAbilityUnit()
""", """function G2F_Frieza_Golden_Transformation_Actions takes nothing returns nothing
local unit fzc=GetSpellAbilityUnit()
local integer fzp=GetPlayerId(GetOwningPlayer(fzc))
set G2V_Caster[7190]=fzc
""")
fz("""call SetUnitAbilityLevelSwapped('A06T',G2V_Caster[7190],GetUnitAbilityLevelSwapped('A0OH',G2V_Caster[7190]))
call TriggerSleepAction(1.)
call ForForce(bj_FORCE_ALL_PLAYERS,function G2F_Frieza_Golden_Transformation_Func056A)
call PauseUnit(G2V_Caster[7190],false)
call IssueImmediateOrderById(G2V_Caster[7190],$D0004)
call RemoveLocation(G2V_Point[7190])
loop
exitwhen(G2F_Frieza_Golden_Transformation_Func060001())
call TriggerSleepAction(RMaxBJ(bj_WAIT_FOR_COND_MIN_INTERVAL,1))
endloop
call UnitRemoveAbility(G2V_Caster[7190],'A06T')
endfunction
""", """call SetUnitAbilityLevelSwapped('A06T',G2V_Caster[7190],GetUnitAbilityLevelSwapped('A0OH',G2V_Caster[7190]))
// v21n: +25 % de daño de las armas por nivel mientras dure el buff (Her_Dano).
set Fz_Bono[fzp]=.25*I2R(GetUnitAbilityLevel(fzc,'A0OH'))
""" + ("""set Cop_Log="freezer Golden bono "+R2S(Fz_Bono[fzp])+" tipo "+GetUnitName(fzc)
call ExecuteFunc("Cop_Anotar")
""" if prueba else '') + """call TriggerSleepAction(1.)
call ForForce(bj_FORCE_ALL_PLAYERS,function G2F_Frieza_Golden_Transformation_Func056A)
call PauseUnit(fzc,false)
call IssueImmediateOrderById(fzc,$D0004)
call RemoveLocation(G2V_Point[7190])
// v21n: con el cuerpo propio (otro Freezer puede cambiar G2V_Caster[7190] mientras dura).
loop
exitwhen GetUnitAbilityLevel(fzc,'B025')==0
call TriggerSleepAction(RMaxBJ(bj_WAIT_FOR_COND_MIN_INTERVAL,1))
endloop
call UnitRemoveAbility(fzc,'A06T')
call UnitRemoveAbility(fzc,'A00Y')
call UnitRemoveAbility(fzc,'A0G4')
set Fz_Bono[fzp]=0.
""" + ("""set Cop_Log="freezer Golden fin tipo "+GetUnitName(fzc)
call ExecuteFunc("Cop_Anotar")
""" if prueba else '') + """set fzc=null
endfunction
""")

# ---------------------------------------------------------------- WAVE propia
fz('call EnableTrigger(G2T_WAVE)\n', 'call EnableTrigger(G2T_WAVE)\ncall Don_Motor(G2T_WAVE,.04)\n', 3)
WAVE = '''// v21n: discos de Death Saucer y anillos de Golden (sustituye a la WAVE de 2.1a). Cada disco avanza WaveSpeed por paso,
// golpea una vez a cada enemigo en WaveRange y, al pasar de 900 de la copia que lo lanzó, vuelve hacia ella.
function G2F_WAVE takes nothing returns nothing
    local integer i = 1
    local unit u
    local unit e
    local unit c
    local unit f
    local real x
    local real y
    local real a
    local real dx
    local real dy
    loop
        exitwhen i > G2V_WaveIndex
        set u = G2V_WaveDummy[i]
        if u != null then
            if GetUnitTypeId(u) == 0 or not UnitAlive(u) then
                set G2V_WaveDummy[i] = null
                set G2V_WaveCount = G2V_WaveCount - 1
                if Fz_WaveG[i] != null then
                    call GroupClear(Fz_WaveG[i])
                endif
            else
                set G2V_WaveInt[i] = G2V_WaveInt[i] + 1
                set a = GetUnitFacing(u) * bj_DEGTORAD
                set x = GetUnitX(u) + I2R(G2V_WaveSpeed[i]) * Cos(a)
                set y = GetUnitY(u) + I2R(G2V_WaveSpeed[i]) * Sin(a)
                if x < GetRectMinX(bj_mapInitialPlayableArea) or x > GetRectMaxX(bj_mapInitialPlayableArea) or y < GetRectMinY(bj_mapInitialPlayableArea) or y > GetRectMaxY(bj_mapInitialPlayableArea) then
                    call KillUnit(u)
                else
                    call SetUnitX(u, x)
                    call SetUnitY(u, y)
                    set c = null
                    if IsUnitInGroup(u, G2V_Group3[$A7]) then
                        set c = G2V_Caster[5980]
                        if c != null and GetUnitTypeId(c) != 0 then
                            set dx = GetUnitX(c) - x
                            set dy = GetUnitY(c) - y
                            if G2V_WaveCam[i] then
                                call SetUnitFacing(u, bj_RADTODEG * Atan2(dy, dx))
                                if dx * dx + dy * dy < 10000. then
                                    call KillUnit(u)
                                endif
                            elseif dx * dx + dy * dy > 810000. then
                                set G2V_WaveCam[i] = true
                            endif
                        else
                            set c = null
                        endif
                    endif
                    if G2V_WaveDamage[i] > 0 and UnitAlive(u) then
                        if Fz_WaveG[i] == null then
                            set Fz_WaveG[i] = CreateGroup()
                        endif
                        set f = c
                        if f == null then
                            set f = u
                        endif
                        call GroupEnumUnitsInRange(Fz_Tmp, x, y, I2R(G2V_WaveRange[i]), null)
                        loop
                            set e = FirstOfGroup(Fz_Tmp)
                            exitwhen e == null
                            call GroupRemoveUnit(Fz_Tmp, e)
                            if UnitAlive(e) and IsUnitEnemy(e, GetOwningPlayer(u)) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and not IsUnitInGroup(e, Fz_WaveG[i]) then
                                call GroupAddUnit(Fz_WaveG[i], e)
                                call UnitDamageTarget(f, e, I2R(G2V_WaveDamage[i]), true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
                                call DestroyEffect(AddSpecialEffectTarget(G2V_WaveEffectPicked[i], e, "chest"))
''' + ('''                                call Gk_Suma(7, 46, f, e, I2R(G2V_WaveDamage[i]))
''' if prueba else '') + '''                            endif
                        endloop
                    endif
                    if ModuloInteger(G2V_WaveInt[i], 5) == 0 then
                        if StringLength(G2V_WaveEffect[i]) > 5 then
                            call DestroyEffect(AddSpecialEffect(G2V_WaveEffect[i], x, y))
                        endif
                        if StringLength(G2V_WaveEffect2[i]) > 5 then
                            call DestroyEffect(AddSpecialEffect(G2V_WaveEffect2[i], x, y))
                        endif
                    endif
                endif
            endif
        endif
        set i = i + 1
    endloop
    loop
        exitwhen G2V_WaveIndex <= 0 or G2V_WaveDummy[G2V_WaveIndex] != null
        set G2V_WaveIndex = G2V_WaveIndex - 1
    endloop
    if G2V_WaveCount <= 0 then
        set G2V_WaveCount = 0
        set G2V_WaveIndex = 0
        call DisableTrigger(G2T_WAVE)
    endif
    set u = null
    set e = null
    set c = null
    set f = null
endfunction
'''
fz('function G2Z_InitDON takes nothing returns nothing\n', WAVE + 'function G2Z_InitDON takes nothing returns nothing\n')
fz('''set G2T_death_break3=CreateTrigger()
call DisableTrigger(G2T_death_break3)
call TriggerAddAction(G2T_death_break3,function G2F_death_break3_Actions)
''', '''set G2T_death_break3=CreateTrigger()
call DisableTrigger(G2T_death_break3)
call TriggerAddAction(G2T_death_break3,function G2F_death_break3_Actions)
set G2T_WAVE=CreateTrigger()
call DisableTrigger(G2T_WAVE)
call TriggerAddAction(G2T_WAVE,function G2F_WAVE)
set Fz_Tmp=CreateGroup()
''')
assert func.count('Don_Motor(') == func.count('call EnableTrigger(') - 0, 'motor por cada EnableTrigger'

# ---------------------------------------------------------------- homing de W (código de Goku, rama de Freezer)
cambia("call UnitDamageTargetBJ(G2V_Caster[5970],GetEnumUnit(),((125.*I2R(GetUnitAbilityLevelSwapped('A0JD',G2V_Caster[5970])))+(2.5*I2R(Gk_Fuerza(G2V_Caster[5970])))),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n",
       "call UnitDamageTargetBJ(G2V_Caster[5970],GetEnumUnit(),Gk_TDano(G2V_Caster[5970],48,2000.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n"
       + ("call Gk_Suma(4,48,G2V_Caster[5970],GetEnumUnit(),Gk_TDano(G2V_Caster[5970],48,2000.))\n" if prueba else ''))
cambia('''call ForGroupBJ(G2V_Group[5970],function G2F_Homing_Func001Func001Func012Func002Func001Func002A)
call DestroyGroup(G2V_Group[5970])
set bj_forLoopAIndex=bj_forLoopAIndex+1
endloop
''', '''call ForGroupBJ(G2V_Group[5970],function G2F_Homing_Func001Func001Func012Func002Func001Func002A)
call DestroyGroup(G2V_Group[5970])
set bj_forLoopAIndex=bj_forLoopAIndex+1
endloop
// v21n: regla de área, todos los enemigos en 600 que no estaban entre los 15.
call Fz_Area(G2V_Caster[5970],GetLocationX(G2V_HoPointDummy[G2V_HoLoop]),GetLocationY(G2V_HoPointDummy[G2V_HoLoop]),600.,Gk_TDano(G2V_Caster[5970],48,2000.),G2V_Group3[$9B],4,48)
''')
cambia('''call CreateNUnitsAtLoc(1,'h03A',GetOwningPlayer(G2V_Caster[5970]),G2V_HoPointDummy[G2V_HoLoop],G2V_HoAngle[G2V_HoLoop])
call SetUnitTimeScalePercent(bj_lastCreatedUnit,75.)
call Son_DONSuena(G2S_SpellShieldImpact1,0)
''', '''call CreateNUnitsAtLoc(1,'h03A',GetOwningPlayer(G2V_Caster[5970]),G2V_HoPointDummy[G2V_HoLoop],G2V_HoAngle[G2V_HoLoop])
call SetUnitTimeScalePercent(bj_lastCreatedUnit,75.)
call Son_DONSuenaEn(G2S_SpellShieldImpact1,G2V_Caster[5970])
''')

# ---------------------------------------------------------------- área común (antes del homing)
AREA = '''// v21n: daño d a los enemigos vivos (no estructuras) en r alrededor de (x, y). Con no: salta los que ya están y los
// añade (golpe único por lanzamiento). s y x: registro de prueba.
function Fz_Area takes unit src, real x, real y, real r, real d, group no, integer s, integer tec returns nothing
    local group g = CreateGroup()
    local unit u
    if src == null or GetUnitTypeId(src) == 0 then
        call DestroyGroup(g)
        set g = null
        return
    endif
    call GroupEnumUnitsInRange(g, x, y, r, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if UnitAlive(u) and IsUnitEnemy(u, GetOwningPlayer(src)) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and (no == null or not IsUnitInGroup(u, no)) then
            if no != null then
                call GroupAddUnit(no, u)
            endif
            call UnitDamageTarget(src, u, d, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
''' + ('''            call Gk_Suma(s, tec, src, u, d)
''' if prueba else '') + '''        endif
    endloop
    call DestroyGroup(g)
    set g = null
endfunction

'''
cambia('// Rojo: SSJ Dios, o Blue con Kaioken. Amarillo: SSJ3.\nfunction G2_Rojo takes nothing returns boolean\n',
       AREA + '// Rojo: SSJ Dios, o Blue con Kaioken. Amarillo: SSJ3.\nfunction G2_Rojo takes nothing returns boolean\n')

# ---------------------------------------------------------------- globales y bloque de Freezer
cambia('boolean Don_Choco = false\n', 'boolean Don_Choco = false\n' + glob + '''real array Fz_Bono
group array Fz_WaveG
group Fz_Tmp = null
integer array Luz_Tipo
integer array Luz_Otra
''')
cambia('function Fz_Stat takes integer k returns integer\n',
       '// ==== v21n: Freezer de Battle Stadium D.O.N 2.1a (trasplantado; ver scripts/v21n.py) ====\n' + U(func)
       + '// ==== Freezer de 1.8c (sin uso desde v21n: su init ya no se llama) ====\nfunction Fz_Stat takes integer k returns integer\n')
cambia('    call ExecuteFunc("Fz_InitDON")\n', '    call ExecuteFunc("G2Z_InitDON")\n')

# ---------------------------------------------------------------- bot, copia y cuerpo
cambia('''    set Don_BotId[Don_Bots] = 'AFz5'
    set Don_BotReal[Don_Bots] = 'A0IV'
    set Don_BotObj[Don_Bots] = 1
    set Don_BotOrden[Don_Bots] = "thunderbolt"
''', '''    set Don_BotId[Don_Bots] = 'AFz5'
    set Don_BotReal[Don_Bots] = 'A0JD'
    set Don_BotObj[Don_Bots] = 2
    set Don_BotOrden[Don_Bots] = "impale"
''')
cambia('''    set Don_BotId[Don_Bots] = 'AFz6'
    set Don_BotReal[Don_Bots] = 'A0IZ'
    set Don_BotObj[Don_Bots] = 0
    set Don_BotOrden[Don_Bots] = "berserk"
''', '''    set Don_BotId[Don_Bots] = 'AFz6'
    set Don_BotReal[Don_Bots] = 'A0OH'
    set Don_BotObj[Don_Bots] = 0
    set Don_BotOrden[Don_Bots] = "chemicalrage"
''')
cambia('''        call UnitAddAbility(Game_Ctrl[p], 'AFz4')
    endif
''', '''        call UnitAddAbility(Game_Ctrl[p], 'AFz4')
        // v21n: Golden Form (T).
        call UnitAddAbility(Game_Ctrl[p], 'AFz6')
    endif
''')
cambia('''        call UnitAddAbility(b, 'A0IW')
        call SetUnitAbilityLevel(b, 'A0IW', 3)
        call UnitMakeAbilityPermanent(b, true, 'A0IW')
        call UnitAddAbility(b, 'A0IV')
        call SetUnitAbilityLevel(b, 'A0IV', 4)
        call UnitMakeAbilityPermanent(b, true, 'A0IV')
        call UnitAddAbility(b, 'A0IZ')
        call SetUnitAbilityLevel(b, 'A0IZ', 1)
        call UnitMakeAbilityPermanent(b, true, 'A0IZ')
''', '''        call UnitAddAbility(b, 'A0IW')
        call SetUnitAbilityLevel(b, 'A0IW', 1)
        call UnitMakeAbilityPermanent(b, true, 'A0IW')
        // v21n: W Imprisonment Ball (2.1a) y T Golden Form.
        call UnitAddAbility(b, 'A0JD')
        call SetUnitAbilityLevel(b, 'A0JD', 4)
        call UnitMakeAbilityPermanent(b, true, 'A0JD')
        call UnitAddAbility(b, 'A0OH')
        call SetUnitAbilityLevel(b, 'A0OH', 1)
        call UnitMakeAbilityPermanent(b, true, 'A0OH')
''')
cambia('''    if a == 'A0IX' then
        return IsTriggerEnabled(FzV_at)
    elseif a == 'A0IW' then
        return IsTriggerEnabled(FzV_bt)
    elseif a == 'A0IV' then
        return IsTriggerEnabled(FzV_Dt)
    elseif a == 'A0J1' then
        return IsTriggerEnabled(FzV_Uy) or IsTriggerEnabled(FzV_Vy)
''', '''    if a == 'A0IX' then
        return IsTriggerEnabled(G2T_next_die_by_my_hand)
    elseif a == 'A0IW' then
        return IsTriggerEnabled(G2T_Next_Deathball)
    elseif a == 'A0JD' then
        return IsTriggerEnabled(G2T_Improsen2)
    elseif a == 'A0J1' then
        return IsTriggerEnabled(G2T_death_break2) or IsTriggerEnabled(G2T_death_break3)
''')
cambia('''    elseif a == 'A0IV' then
        return 900.
''', '''    elseif a == 'A0JD' then
        return 2000.
''')
cambia("    return a == 'A0IZ' or a == 'A0H5' or a == 'A00U' or a == 'A00T'\n",
       "    return a == 'A0OH' or a == 'A0H5' or a == 'A00U' or a == 'A00T'\n")
cambia('''    if tb == 'hFrz' then
        set tc = 'hCpF'
''', '''    if tb == 'hFrz' then
        set tc = 'hCpF'
    elseif tb == 'hFrG' then
        set tc = 'hCpH'
''')
cambia("    elseif tc == 'hCpF' then\n        set Son_Foco[1] = c\n", "    elseif tc == 'hCpF' or tc == 'hCpH' then\n        set Son_Foco[1] = c\n")
cambia("    if t == 'hCpG' or t == 'hCpF' or t == 'hCpT' or t == 'hCpN' or t == 'hCpK'",
       "    if t == 'hCpG' or t == 'hCpF' or t == 'hCpH' or t == 'hCpT' or t == 'hCpN' or t == 'hCpK'")
cambia("    elseif t == 'hFrz' or t == 'hCpF' then\n        return 1\n",
       "    elseif t == 'hFrz' or t == 'hCpF' or t == 'hFrG' or t == 'hCpH' then\n        return 1\n")
cambia("    return t == 'hGok' or t == 'hFrz' or t == 'hTrk' or t == 'hNar' or t == 'hNaK'\n",
       "    return t == 'hGok' or t == 'hFrz' or t == 'hFrG' or t == 'hTrk' or t == 'hNar' or t == 'hNaK'\n")
cambia('''    call Pj_Fijar('hFrz', 3, 'hCpF', 'hMf3', 1., 'DT4F', 'hbi4', "Freezer", 45, 6)
''', '''    call Pj_Fijar('hFrz', 3, 'hCpF', 'hMf3', 1., 'DT4F', 'hbi4', "Freezer", 45, 6)
    call Pj_Fijar('hFrG', 3, 'hCpH', 'hMf3', 1., 'DT4F', 'hbi4', "Freezer", 45, 6)
''')
cambia("        call s__UnitHitShape_register('hFrz' , 1.6 , 48.) // v16u: como h005\n",
       "        call s__UnitHitShape_register('hFrz' , 1.6 , 48.) // v16u: como h005\n"
       "        call s__UnitHitShape_register('hFrG' , 1.6 , 48.) // v21n: Golden\n")
cambia("    call RemoveUnit(CreateUnit(Player(15), 'hCpF', -12000., 9000., 0.))\n",
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpF', -12000., 9000., 0.))\n"
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpH', -12000., 9000., 0.))\n")
cambia("GetUnitTypeId(Game_Hero[Prc_P]) == 'hFrz' or", "GetUnitTypeId(Game_Hero[Prc_P]) == 'hFrz' or GetUnitTypeId(Game_Hero[Prc_P]) == 'hFrG' or")
cambia("GetUnitTypeId(s__RapidPair_actor[this]) == 'hFrz' or", "GetUnitTypeId(s__RapidPair_actor[this]) == 'hFrz' or GetUnitTypeId(s__RapidPair_actor[this]) == 'hFrG' or", 2)
cambia('''    elseif t == 'hFrz' then
        if not Dcp_Ocupada(p, 'A0IY') and Dcp_Lanzar(h, 'A0IY', 0, "roar", null, 0., 0.) then
            set Prc_Listo[p] = ahora + 1.5
''', '''    elseif t == 'hFrz' or t == 'hFrG' then
        // v21n: Death Saucer con tier: un disco cada 10 s como mucho.
        if not Dcp_Ocupada(p, 'A0IY') and Dcp_Lanzar(h, 'A0IY', 0, "roar", null, 0., 0.) then
            set Prc_Listo[p] = ahora + 10.
''')
# Power Up por muertes fuera (en prueba lleva además su Dia_Anotar).
m = re.search(r"    elseif t == 'hFrz' and Frm_Llega\(k, 30\).*?\n(    endif\n    set h = null\n)", src, re.S)
assert m and src.count(m.group(0)) == 1
src = src.replace(m.group(0), m.group(1))
cambia('''                if t == 'hNar' or t == 'hNaK' then
                    call Tec_Aplicar(p)''', '''                if t == 'hNar' or t == 'hNaK' or t == 'hFrz' or t == 'hFrG' then
                    call Tec_Aplicar(p)''')

# ---------------------------------------------------------------- bono de Golden a las armas
cambia('''        if Kai_Bono[p] > 0. and G2V_Caster[7150] != null and GetPlayerId(GetOwningPlayer(G2V_Caster[7150])) == p and GetUnitAbilityLevel(G2V_Caster[7150], 'B05J') > 0 then
            set d = d * ( 1. + Kai_Bono[p] )
        endif
''', '''        if Kai_Bono[p] > 0. and G2V_Caster[7150] != null and GetPlayerId(GetOwningPlayer(G2V_Caster[7150])) == p and GetUnitAbilityLevel(G2V_Caster[7150], 'B05J') > 0 then
            set d = d * ( 1. + Kai_Bono[p] )
        endif
        // v21n: Golden Form de Freezer (buff B025 en su cuerpo).
        if Fz_Bono[p] > 0. and GetUnitAbilityLevel(Game_Hero[p], 'B025') > 0 then
            set d = d * ( 1. + Fz_Bono[p] )
        endif
''')

# ---------------------------------------------------------------- luz tras el morph
cambia('''function Luz_Ajustar takes integer p, boolean forzar returns nothing
    local integer n = Luz_NivelDe(p)
''', '''function Luz_Ajustar takes integer p, boolean forzar returns nothing
    local integer n = Luz_NivelDe(p)
    // v21n: el efecto pegado se pierde al cambiar de modelo (Golden, Kyuubi): se vuelve a poner al cambiar el tipo
    // del cuerpo y otra vez 0,6 y 1,2 s después (fin de la transformación).
    if GetUnitTypeId(Game_Hero[p]) != Luz_Tipo[p] then
        set Luz_Tipo[p] = GetUnitTypeId(Game_Hero[p])
        set Luz_Otra[p] = 12
        set forzar = true
    elseif Luz_Otra[p] > 0 then
        set Luz_Otra[p] = Luz_Otra[p] - 1
        if Luz_Otra[p] == 6 or Luz_Otra[p] == 0 then
            set forzar = true
        endif
    endif
''')

# ---------------------------------------------------------------- fuga del Warp Kamehameha
cambia('''call ForGroupBJ(G2V_Group[5850],function G2F_Warp_Kamehameha_Func109Func002A)
call DestroyGroup(G2V_Group[6060])
''', '''call ForGroupBJ(G2V_Group[5850],function G2F_Warp_Kamehameha_Func109Func002A)
call DestroyGroup(G2V_Group[5850])
''')

# ---------------------------------------------------------------- libro: tiers de Freezer
TEC = {45: ('A0IW', 1, 5800.), 46: ('A0IY', 1, 1500.), 47: ('A0J1', 4, 2000.), 48: ('A0JD', 4, 2000.), 49: ('A0IX', 4, 2900.)}
cambia("    set Tec_Real[48] = 'A0IV'\n", "    set Tec_Real[48] = 'A0JD'\n")
cambia("    set Tec_Real[50] = 'A0IZ'\n", "    set Tec_Real[50] = 'A0OH'\n")
for x, (real, tope, t6) in TEC.items():
    m = re.search(r"    set Tec_Max\[%d\] = \d+\n" % x, src)
    assert m and src.count(m.group(0)) == 1, x
    src = src.replace(m.group(0), '    set Tec_Max[%d] = 6\n    set Tec_Tope[%d] = %d\n    set Tec_T6[%d] = %s\n' % (x, x, tope, x, repr(t6)))
cambia('    set Tec_Max[50] = 0\n', '    set Tec_Max[50] = 3\n    set Tec_Tope[50] = 3\n')
cambia('    set Cua_Nom[46] = "Destructo Disc"\n    set Cua_Des[46] = "Técnica de D.O.N."\n',
       '    set Cua_Nom[46] = "Death Saucer"\n    set Cua_Des[46] = "Técnica de D.O.N.|nSale sola al acertar con las armas."\n')
cambia('    set Cua_Nom[49] = "Die By My Hand!"\n', '    set Cua_Nom[49] = "You Will Die By My Hand!"\n')
cambia('    set Cua_Nom[50] = "Power Up"\n    set Cua_Des[50] = "Técnica de D.O.N."\n',
       '    set Cua_Nom[50] = "Golden Form"\n    set Cua_Des[50] = "Forma dorada 35 s.|n+25 % de daño de armas por nivel."\n')

if prueba:
    cambia("or t == 'hGok' or t == 'hFrz' or t == 'hTrk'", "or t == 'hGok' or t == 'hFrz' or t == 'hFrG' or t == 'hTrk'")
    cambia('''    local string n = "Q"
    if s == 1 then
        set n = "W"
    elseif s == 2 then
        set n = "R forma " + I2S(G2V_Int[7160])
    endif
    set Cop_Log = "goku dano " + n''', '''    local string n = "Q"
    local string q = "goku"
    if s == 1 then
        set n = "W"
    elseif s == 2 then
        set n = "R forma " + I2S(G2V_Int[7160])
    elseif s >= 3 then
        // v21n: Freezer (3 Q, 4 W, 5 E, 6 R, 7 X).
        set q = "freezer"
        set n = SubString("QWERX", s - 3, s - 2)
    endif
    set Cop_Log = q + " dano " + n''')
    cambia('''    local integer n = S2I(SubString(s, 4, StringLength(s)))
    if SubString(s, 0, 4) != "-gt " or n < 1 or n > 6 then''', '''    local integer n = S2I(SubString(s, 4, StringLength(s)))
    local integer x
    if SubString(s, 0, 4) != "-gt " or n < 1 or n > 6 then''')
    cambia('''    set Tec_Niv[p * 100 + 40] = n
    set Tec_Niv[p * 100 + 42] = n
    set Tec_Niv[p * 100 + 43] = n
    call Tec_Aplicar(p)
    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 5., "Goku: Q, W y R en " + Arm_TierTexto(n))
    set Cop_Log = "goku tiers -gt " + I2S(n)
''', '''    // v21n: todas las técnicas con tier del personaje del jugador.
    call Tec_Rango(p)
    set x = Tec_A
    loop
        exitwhen x >= Tec_A + Tec_N
        if Tec_T6[x] > 0. then
            set Tec_Niv[p * 100 + x] = n
        endif
        set x = x + 1
    endloop
    call Tec_Aplicar(p)
    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 5., "Técnicas con tier en " + Arm_TierTexto(n))
    set Cop_Log = "tiers -gt " + I2S(n) + " " + Don_Nombre(p)
''')
    cambia('lat\\\\v21m-', 'lat\\\\v21n-', src.count('lat\\\\v21m-'))
    cambia('v21m-don.txt', 'v21n-don.txt', src.count('v21m-don.txt'))
assert not prueba or ('lat\\\\v21m-' not in src and 'v21m-don.txt' not in src), 'quedan registros v21m'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[5]).write_bytes(src.encode('latin-1'))
print('v21n', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas; sonidos 3D', nsf)
