#!/usr/bin/env python3
"""v21s (22/11/2026): Future Trunks de Battle Stadium D.O.N 2.1a con tiers, como Freezer en v21n.

Leon: "pasala a area y vamos con trunks". Regla de área de v21n: "habilidades que toman un target en la explosivo o
momento que hace danio deben hacerlos en area para que ayude en las oleadas".

1. Código de Trunks 2.1a trasplantado (tr21_trasplante: GLOB.j, FUNC.j, prefijo G2) en lugar del de 1.8c: Q Burning
   Attack (A05B), W Finish Buster (A0GV), E Heat Dome Attack (A086), R Final Hope Slash (A03W), T Sword of Hope (A0I5),
   formas Saian_Trunks (A0H5). El init viejo (Tr_InitDON) ya no se llama; sus funciones quedan sin uso.
2. Tiers T1-T6 (curva de v21m). Daño por enemigo en T6: Q 2900, W 2000, E 2000, R 5800, T 4350. Ya no depende del
   nivel de la habilidad ni de Gk_Fuerza.
3. Regla de área: Q, al final de los 20 elegidos, todos los enemigos en 800 que no tocó (una vez cada uno). E: tras los
   15 golpes a enemigos elegidos, el resto en 400 alrededor del blanco. R: tras los 15 cortes, el resto en 500 alrededor
   de la explosión. W y T ya eran de área (barrido y explosión, una vez por enemigo; Sword of Hope en 600).
4. Sword of Hope (T, recarga 80 s): ya no pide Super Saiyan (con las formas por muertes el botón quedaba muerto al
   empezar cada oleada). La lanza el cuerpo (espada de 2.1a en la mano, buff B05L, 18 s); mientras dura, las armas hacen
   0,75 x curva del tier (T6 +75 %), como la Golden Form de Freezer.
5. Formas por muertes (25 SSJ, 50 SSJ2) con el código nuevo; el Finish Sign automático a las 75 muertes desaparece.
   SSJ dura hasta el final de la oleada (Frm_Corte), como antes.
6. Cabezas de 2.1a (TrunkHead, SS2, SS3) en el MVP y en las copias.
Registro (sólo prueba): "trunks dano" por técnica (Gk_Suma 10 Q, 11 W, 12 E, 13 R, 14 T; el 9 es de los
temporizadores) y "trunks Sword bono".
Uso: v21s.py ENTRADA.j GLOB.j FUNC.j CAMBIOS.tsv SALIDA.j [prueba]   (normal de v21r; prueba de v21r-prueba).
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


def tr(viejo, nuevo, veces=1):
    global func
    viejo, nuevo = U(viejo), U(nuevo)
    assert func.count(viejo) == veces, (func.count(viejo), viejo[:90])
    func = func.replace(viejo, nuevo)


# ---------------------------------------------------------------- sonidos 3D (como v21e/v21n)
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


func, nsf, kif = sonidos3d(func, {'G2F_': 2})
assert 'PlaySoundBJ(' not in func and kif == 1 and nsf == 8, (nsf, kif)
assert 'M3D_FinishBuster' in func


def golpe(linea, s, x, src_, tgt, dmg, veces=1):
    if prueba:
        tr(linea + '\n', linea + '\ncall Gk_Suma(%d,%d,%s,%s,%s)\n' % (s, x, src_, tgt, dmg), veces)


# ---------------------------------------------------------------- daño por tier y área (FUNC.j)
# Q Burning Attack: barrido en 250 y 20 elegidos en 800 (una vez por enemigo, Group3[53]); luego el resto en 800.
tr("set G2V_Damage2[$C8]=((100*GetUnitAbilityLevelSwapped('A05B',G2V_Caster[$C8]))+(2*Gk_Fuerza(G2V_Caster[$C8])))\n",
   "set G2V_Damage2[$C8]=R2I(Gk_TDano(G2V_Caster[$C8],55,2900.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[$C8],GetEnumUnit(),I2R(G2V_Damage2[$C8]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      10, 55, 'G2V_Caster[$C8]', 'GetEnumUnit()', 'I2R(G2V_Damage2[$C8])', 2)
tr('call GroupClear(G2V_Group3[53])\n',
   '// v21s: regla de área, todos los enemigos en 800 que no estaban entre los golpeados.\n'
   'call Fz_Area(G2V_Caster[$C8],GetLocationX(G2V_Point[$CB]),GetLocationY(G2V_Point[$CB]),800.,I2R(G2V_Damage2[$C8]),G2V_Group3[53],10,55)\n'
   'call GroupClear(G2V_Group3[53])\n')
# W Finish Buster: barrido en 300 y explosión en 500, una vez por enemigo (Group2[$8B]).
tr("set G2V_Damage2[5570]=((100*GetUnitAbilityLevelSwapped('A0GV',G2V_Caster[5570]))+(Gk_Fuerza(G2V_Caster[5570])*(1+G2V_Int[5630])))\n",
   "set G2V_Damage2[5570]=R2I(Gk_TDano(G2V_Caster[5570],54,2000.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[5570],GetEnumUnit(),I2R(G2V_Damage2[5570]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      11, 54, 'G2V_Caster[5570]', 'GetEnumUnit()', 'I2R(G2V_Damage2[5570])')
tr("call UnitDamageTargetBJ(G2V_Caster[5570],GetEnumUnit(),(150.+(I2R(Gk_Fuerza(G2V_Caster[5570]))*I2R(GetUnitAbilityLevelSwapped('A0GV',G2V_Caster[5570])))),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n",
   "call UnitDamageTargetBJ(G2V_Caster[5570],GetEnumUnit(),Gk_TDano(G2V_Caster[5570],54,2000.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[5570],GetEnumUnit(),Gk_TDano(G2V_Caster[5570],54,2000.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      11, 54, 'G2V_Caster[5570]', 'GetEnumUnit()', 'Gk_TDano(G2V_Caster[5570],54,2000.)')
# E Heat Dome: 15 enemigos elegidos en 400 del blanco y luego el resto (Group3[58]).
tr("set G2V_Damage2[$CF8]=((100*GetUnitAbilityLevelSwapped('A086',G2V_Caster[$CF8]))+(2*Gk_Fuerza(G2V_Caster[$CF8])))\n",
   "set G2V_Damage2[$CF8]=R2I(Gk_TDano(G2V_Caster[$CF8],53,2000.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[$CF8],G2V_Caster[$CFD],I2R(G2V_Damage2[$CF8]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      12, 53, 'G2V_Caster[$CF8]', 'G2V_Caster[$CFD]', 'I2R(G2V_Damage2[$CF8])')
tr('call GroupClear(G2V_Group3[58])\n',
   '// v21s: regla de área, todos los enemigos en 400 del blanco que no estaban entre los 15.\n'
   'call Fz_Area(G2V_Caster[$CF8],GetLocationX(G2V_Point[$CF9]),GetLocationY(G2V_Point[$CF9]),400.,I2R(G2V_Damage2[$CF8]),G2V_Group3[58],12,53)\n'
   'call GroupClear(G2V_Group3[58])\n')
# R Final Hope Slash: 15 cortes a enemigos elegidos en 500 de la explosión y luego el resto (Group3[57]).
tr("set G2V_Damage2[300]=((400*GetUnitAbilityLevelSwapped('A03W',G2V_Caster[300]))+(3*Gk_Fuerza(G2V_Caster[300])))\n",
   "set G2V_Damage2[300]=R2I(Gk_TDano(G2V_Caster[300],51,5800.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[300],G2V_Caster[305],I2R(G2V_Damage2[300]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      13, 51, 'G2V_Caster[300]', 'G2V_Caster[305]', 'I2R(G2V_Damage2[300])')
tr('call GroupClear(G2V_Group3[57])\n',
   '// v21s: regla de área, todos los enemigos en 500 que no estaban entre los 15.\n'
   'call Fz_Area(G2V_Caster[300],GetLocationX(G2V_Point[304]),GetLocationY(G2V_Point[304]),500.,I2R(G2V_Damage2[300]),G2V_Group3[57],13,51)\n'
   'call GroupClear(G2V_Group3[57])\n')
# T Sword of Hope: explosión en 600 con tier, sin pedir SSJ, y bono a las armas mientras dura el buff B05L.
tr('call UnitDamageTargetBJ(G2V_Caster[7370],GetEnumUnit(),(I2R(Gk_Fuerza(G2V_Caster[7370]))*3.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n',
   'call UnitDamageTargetBJ(G2V_Caster[7370],GetEnumUnit(),Gk_TDano(G2V_Caster[7370],52,4350.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n')
golpe('call UnitDamageTargetBJ(G2V_Caster[7370],GetEnumUnit(),Gk_TDano(G2V_Caster[7370],52,4350.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      14, 52, 'G2V_Caster[7370]', 'GetEnumUnit()', 'Gk_TDano(G2V_Caster[7370],52,4350.)')
tr('function G2F_sword_of_hope_Func002C takes nothing returns boolean\nreturn(G2V_Int[5630]>1)\n',
   '// v21s: sin pedir Super Saiyan.\nfunction G2F_sword_of_hope_Func002C takes nothing returns boolean\nreturn true\n')
tr('''function G2F_sword_of_hope_Actions takes nothing returns nothing
set G2V_Caster[7370]=GetSpellAbilityUnit()
''', '''function G2F_sword_of_hope_Actions takes nothing returns nothing
local integer trp
set G2V_Caster[7370]=GetSpellAbilityUnit()
// v21s: bono de las armas por tier mientras dure el buff B05L (T6 +75 %).
set trp=GetPlayerId(GetOwningPlayer(G2V_Caster[7370]))
set Fz_Bono[trp]=.75*Tec_Curva[IMinBJ(6,IMaxBJ(1,Tec_Niv[trp*100+52]))]
''' + ('''set Cop_Log="trunks Sword bono "+R2S(Fz_Bono[trp])+" buff "+I2S(GetUnitAbilityLevel(G2V_Caster[7370],'B05L'))
call ExecuteFunc("Cop_Anotar")
''' if prueba else ''))
# Formas: SSJ hasta el final de la oleada (como en 1.8c dentro de Dev Mission), no 50 s.
tr('function G2F_Saian_Trunks3_Func002Func009001 takes nothing returns boolean\nreturn(G2V_Int[5633]>=50)\n',
   '// v21s: la forma dura hasta el final de la oleada (Frm_Fin).\n'
   'function G2F_Saian_Trunks3_Func002Func009001 takes nothing returns boolean\nreturn Frm_Corte\n')
assert func.count('call Don_Motor(') == func.count('call EnableTrigger(') - 3, 'motor por cada EnableTrigger salvo Saian_Trunks2/3 (periódicos)'

# ---------------------------------------------------------------- globales y bloque de Trunks
cambia('real array Fz_Bono\n', 'real array Fz_Bono\n' + glob)
cambia('// Future Trunks: atributos de D.O.N al nivel Gk_Nivel (fuerza, agilidad, inteligencia).\nfunction Tr_Stat takes integer k returns integer\n',
       '// ==== v21s: Future Trunks de Battle Stadium D.O.N 2.1a (trasplantado; ver scripts/v21s.py) ====\n' + func
       + '// ==== Trunks de 1.8c (sin uso desde v21s salvo Tr_Stat: su init ya no se llama) ====\n'
       '// Future Trunks: atributos de D.O.N al nivel Gk_Nivel (fuerza, agilidad, inteligencia).\n'
       'function Tr_Stat takes integer k returns integer\n')
cambia('    call ExecuteFunc("Tr_InitDON")\n', '    call ExecuteFunc("G2Y_InitDON")\n')

# ---------------------------------------------------------------- controlador, cuerpo y copia
cambia('''        call UnitAddAbility(Game_Ctrl[p], 'ATr5')
    endif
''', '''        call UnitAddAbility(Game_Ctrl[p], 'ATr5')
        // v21s: Sword of Hope (T).
        call UnitAddAbility(Game_Ctrl[p], 'ATr6')
    endif
''')
cambia('        set TrV_s8[$CEE]=b\n', '        set G2V_Caster[$CEE]=b\n')
cambia('''    elseif a == 'A0GV' then
        return IsTriggerEnabled(TrV_Mu)
    elseif a == 'A05B' then
        return IsTriggerEnabled(TrV_BB)
''', '''    elseif a == 'A0GV' then
        return IsTriggerEnabled(G2T_Finish_Buster2)
    elseif a == 'A05B' then
        return IsTriggerEnabled(G2T_BurningExplode)
    elseif a == 'A086' then
        return IsTriggerEnabled(G2T_HeatCombo)
    elseif a == 'A03W' then
        return IsTriggerEnabled(G2T_Burning_Slash2)
''')
cambia('''    elseif a == 'A03W' then
        return 125.
''', '''    elseif a == 'A03W' then
        return 1000.
''')
cambia("    return a == 'A0OH' or a == 'A0H5' or a == 'A00U' or a == 'A00T'\n",
       "    return a == 'A0OH' or a == 'A0I5' or a == 'A0H5' or a == 'A00U' or a == 'A00T'\n")
cambia("    call Dcp_Pieza(b, c, 'A07X')\n", "    call Dcp_Pieza(b, c, 'A07X')\n    call Dcp_Pieza(b, c, 'A07Y')\n    call Dcp_Pieza(b, c, 'A07Z')\n")
cambia("    call UnitRemoveAbility(c, 'A07X')\n", "    call UnitRemoveAbility(c, 'A07X')\n    call UnitRemoveAbility(c, 'A07Y')\n    call UnitRemoveAbility(c, 'A07Z')\n")
cambia('''    set k = Mvp_Pieza(p, h, i, k, 'A07X', "war3mapImported\\\\Future Trunks Super Saiyan Head_squished.mdx", "head")
''', '''    // v21s: cabezas de Trunks de 2.1a (normal, SSJ, SSJ2).
    set k = Mvp_Pieza(p, h, i, k, 'A07X', "war3mapImported\\\\TrunkHead.mdx", "head")
    set k = Mvp_Pieza(p, h, i, k, 'A07Y', "war3mapImported\\\\TrunkHeadSS2.mdx", "head")
    set k = Mvp_Pieza(p, h, i, k, 'A07Z', "war3mapImported\\\\TrunkHeadSS3.mdx", "head")
''')

# ---------------------------------------------------------------- formas por muertes (en prueba con Dia_Anotar)
m = re.search(r"    elseif t == 'hTrk' and h == TrV_s8\[\$CEE\] and not TrV_o8\[5630\] then\n.*?\n(    endif\n    set h = null\n)",
              src, re.S)
assert m and src.count(m.group(0)) == 1
FORMAS = '''    elseif t == 'hTrk' and h == G2V_Caster[$CEE] and not G2V_Bool[5630] then
        // v21s: formas de Trunks de 2.1a (base, SSJ, SSJ2) con su código; sin Finish Sign automático.
        if Frm_Llega(k, 50) then
            set n = 3
        elseif Frm_Llega(k, 25) then
            set n = 2
        endif
        if G2V_Int[5630] < 1 then
            set G2V_Int[5630] = 1
        endif
        if G2V_Int[5630] < n then
            set G2V_Bool[5630] = true
            set G2V_Int[5637] = 1
            call ExecuteFunc("G2F_Saian_Trunks2_Actions")
            if G2V_Int[5630] == 2 then
                call Frm_Aviso(k, "¡Super Saiyan!")
            elseif G2V_Int[5630] == 3 then
                call Frm_Aviso(k, "¡Super Saiyan 2!")
            endif
''' + ('''    call Dia_Anotar("forma trunks " + I2S(G2V_Int[5630]) + " pts " + I2S(Frm_Pts[k]))
''' if prueba else '') + '''        endif
'''
src = src.replace(m.group(0), U(FORMAS) + m.group(1))
cambia('''    if TrV_s8[$CEE] != null then
        call ExecuteFunc("TrF_go4")
        call DisableTrigger(TrV_ft)
''', '''    if G2V_Caster[$CEE] != null then
        call ExecuteFunc("G2F_Saian_Trunks3_Actions")
        call DisableTrigger(G2T_Saian_Trunks3)
''')
cambia("            call UnitRemoveAbility(h, 'B03N')\n", "            call UnitRemoveAbility(h, 'B03N')\n            call UnitRemoveAbility(h, 'B05L')\n")

# ---------------------------------------------------------------- bono de Sword of Hope a las armas
cambia('''        // v21n: Golden Form de Freezer (buff B025 en su cuerpo).
        if Fz_Bono[p] > 0. and GetUnitAbilityLevel(Game_Hero[p], 'B025') > 0 then
''', '''        // v21n: Golden Form de Freezer (buff B025 en su cuerpo); v21s: Sword of Hope de Trunks (B05L).
        if Fz_Bono[p] > 0. and (GetUnitAbilityLevel(Game_Hero[p], 'B025') > 0 or GetUnitAbilityLevel(Game_Hero[p], 'B05L') > 0) then
''')

# ---------------------------------------------------------------- libro: tiers de Trunks
TEC = {51: (3, 5800.), 52: (1, 4350.), 53: (4, 2000.), 54: (4, 2000.), 55: (4, 2900.)}
for x, (tope, t6) in TEC.items():
    m = re.search(r"    set Tec_Max\[%d\] = \d+\n" % x, src)
    assert m and src.count(m.group(0)) == 1, x
    src = src.replace(m.group(0), '    set Tec_Max[%d] = 6\n    set Tec_Tope[%d] = %d\n    set Tec_T6[%d] = %s\n' % (x, x, tope, x, repr(t6)))
cambia('    set Cua_Nom[51] = "Burning Slash"\n', '    set Cua_Nom[51] = "Final Hope Slash"\n')
cambia('    set Cua_Nom[52] = "Finish Sign"\n    set Cua_Des[52] = "Técnica de D.O.N."\n',
       '    set Cua_Nom[52] = "Sword of Hope"\n    set Cua_Des[52] = "Explota alrededor de Trunks y 18 s|nlas armas hacen hasta +75 % en T6."\n')
cambia('    set Cua_Nom[53] = "Heat Dome"\n', '    set Cua_Nom[53] = "Heat Dome Attack"\n')

if prueba:
    cambia('''    elseif s >= 3 then
        // v21n: Freezer (3 Q, 4 W, 5 E, 6 R, 7 X).''', '''    elseif s >= 10 then
        // v21s: Trunks (10 Q, 11 W, 12 E, 13 R, 14 T).
        set q = "trunks"
        set n = SubString("QWERT", s - 10, s - 9)
    elseif s >= 3 then
        // v21n: Freezer (3 Q, 4 W, 5 E, 6 R, 7 X).''')
    cambia('lat\\\\v21r-', 'lat\\\\v21s-', src.count('lat\\\\v21r-'))
    cambia('v21r-don.txt', 'v21s-don.txt', src.count('v21r-don.txt'))
    assert 'lat\\\\v21r-' not in src and 'v21r-don.txt' not in src, 'quedan registros v21r'
assert 'TrV_s8[$CEE]=b' not in src and 'ExecuteFunc("Tr_InitDON")' not in src
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[5]).write_bytes(src.encode('latin-1'))
print('v21s', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas; sonidos 3D', nsf)
