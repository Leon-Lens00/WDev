#!/usr/bin/env python3
"""v21y (22/11/2026): Naruto Kurama de Battle Stadium D.O.N 2.1a, personaje nuevo en la celda 6.

Leon: "Naruto Kurama" (tras cerrar Trunks: "vamos con el siguiente pj"). Naruto sabio (hNar/hNaK, celda 5) no cambia.
Reglas de los personajes D.O.N: retrato propio, tamaño, sin efectos de muerte en resultados, icono propio en rachas,
barra y selección, -pj 6 con todas las técnicas y partida normal sólo con Q, tiers T1-T6, sonidos 3D y regla de área
de v21n ("habilidades que toman un target en la explosivo o momento que hace danio deben hacerlos en area").

1. Código de Kurama 2.1a trasplantado (GLOB.j, FUNC.j, prefijo G2; objetos_nk21.py remapea h0DI>hKu0, A0F5>AKu1,
   A0F3>AKu4): Q Rasenrengan (AKu1), W RasenKyuugan (A0K2), E Bijuu RasenShuriken (A0KY), R Bijuu Dama (AKu4),
   X Kyuubi Chakra Cloak (A0K5, buff B04L, sin código: lo lanza el cuerpo).
2. Puentes AKp1-AKp5 en el controlador (Q W E R X) -> copia hCpU (Dcp_Lanzar), salvo X en el cuerpo.
3. Tiers T1-T6 (curva de v21m), daño por enemigo en T6: Q 2900, W 2000, E 2000, R 5800 (onda 2320 + explosión 3480).
   Técnicas 89-93 del libro (Tec_EsTec amplía 40-77).
4. Regla de área: Q, al final de los 15 rasengan, el resto en 1000 del blanco; W, cada golpe también en 250 alrededor
   del golpeado (una vez por enemigo, Group3[88]); E, tras los 15 cortes de la explosión, el resto en 650; R, la
   explosión al final de la onda en 700.
5. X: mientras dura B04L las armas hacen 0,75 x curva del nivel (T6 +75 %), como Golden Form y Sword of Hope.
Registro (sólo prueba): "kurama dano" por técnica (Gk_Suma 15 Q, 16 W, 17 E, 18 R) y "kurama manto bono".
Uso: v21y.py ENTRADA.j GLOB.j FUNC.j CAMBIOS.tsv SALIDA.j [prueba]   (normal de v21x; prueba de v21x-prueba).
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


# ---------------------------------------------------------------- sonidos 3D (como v21s)
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


func, nsf, kif = sonidos3d(func, {'G2F_': 4})
assert 'PlaySoundBJ(' not in func and kif == 1 and nsf == 6, (nsf, kif)
for s in ('M3D_Rasenrengan', 'M3D_bijustart', 'M3D_bijuudama', 'M3D_rasenkyuugan'):
    assert s in func, s


def golpe(linea, s, x, src_, tgt, dmg, veces=1):
    if prueba:
        tr(linea + '\n', linea + '\ncall Gk_Suma(%d,%d,%s,%s,%s)\n' % (s, x, src_, tgt, dmg), veces)


# ---------------------------------------------------------------- daño por tier y área (FUNC.j)
# W RasenKyuugan: lo lanza la copia (G2V_Caster[5790] lo ponía en D.O.N otro disparador). Los blancos en 600 se marcan
# en Group3[88]; los cercanos reciben el golpe al momento y los lejanos al llegar arrastrados (Butcher_MUI).
tr('function G2F_RasenKyuugan_Actions takes nothing returns nothing\ncall TriggerSleepAction(.07)\n',
   'function G2F_RasenKyuugan_Actions takes nothing returns nothing\n'
   '// v21y: el que lanza es la copia de Kurama.\nset G2V_Caster[5790]=GetSpellAbilityUnit()\ncall TriggerSleepAction(.07)\n')
tr("set G2V_Damage[5790]=((100*GetUnitAbilityLevelSwapped('A0K2',G2V_Caster[5790]))+(2*Gk_Fuerza(G2V_Caster[5790])))\n",
   "set G2V_Damage[5790]=R2I(Gk_TDano(G2V_Caster[5790],91,2000.))\n", 2)
for tgt in ('G2V_Caster[5791]', 'G2V_BUTarget[G2V_BLoop]'):
    linea = ('call UnitDamageTargetBJ(G2V_Caster[5790],%s,I2R(G2V_Damage[5790]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)'
             % tgt)
    golpe(linea, 16, 91, 'G2V_Caster[5790]', tgt, 'I2R(G2V_Damage[5790])')
    tr(linea + '\n', linea + '\n// v21y: regla de área, también los enemigos en 250 del golpeado (una vez cada uno).\n'
       'call Fz_Area(G2V_Caster[5790],GetUnitX(%s),GetUnitY(%s),250.,I2R(G2V_Damage[5790]),G2V_Group3[88],16,91)\n'
       % (tgt, tgt))
# Q Rasenrengan: 15 rasengan a enemigos elegidos en 1000 del blanco (Group3[93]); al volver el último, el resto.
tr("set G2V_Damage[5170]=((75*GetUnitAbilityLevelSwapped('AKu1',G2V_Caster[5170]))+(3*Gk_Fuerza(G2V_Caster[5170])))\n",
   "set G2V_Damage[5170]=R2I(Gk_TDano(G2V_Caster[5170],92,2900.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[5170],G2V_RasenRenganTarget[G2V_DLoop],I2R(G2V_Damage[5170]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      15, 92, 'G2V_Caster[5170]', 'G2V_RasenRenganTarget[G2V_DLoop]', 'I2R(G2V_Damage[5170])')
tr('set G2V_Point[5171]=GetUnitLoc(G2V_Caster[5171])\n',
   'set G2V_Point[5171]=GetUnitLoc(G2V_Caster[5171])\n// v21y: centro del área final.\n'
   'set Ku_QX=GetLocationX(G2V_Point[5171])\nset Ku_QY=GetLocationY(G2V_Point[5171])\n')
tr('call PauseUnit(G2V_Caster[5170],false)\ncall GroupClear(G2V_Group3[93])\n',
   'call PauseUnit(G2V_Caster[5170],false)\n'
   '// v21y: regla de área, todos los enemigos en 1000 del blanco que no estaban entre los 15.\n'
   'call Fz_Area(G2V_Caster[5170],Ku_QX,Ku_QY,1000.,Gk_TDano(G2V_Caster[5170],92,2900.),G2V_Group3[93],15,92)\n'
   'call GroupClear(G2V_Group3[93])\n')
# E Bijuu RasenShuriken: cortes en 350 durante el vuelo y 15 en 650 al estallar (Group3[301]); luego el resto en 650.
tr('set G2V_Damage2[6380]=((Gk_Fuerza(G2V_Caster[6380])*3)+((20*R2I(GetUnitStateSwap(UNIT_STATE_MAX_LIFE,G2V_Caster[6380])))/100))\n',
   'set G2V_Damage2[6380]=R2I(Gk_TDano(G2V_Caster[6380],90,2000.))\n')
golpe('call UnitDamageTargetBJ(G2V_Caster[6380],GetEnumUnit(),I2R(G2V_Damage2[6380]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      17, 90, 'G2V_Caster[6380]', 'GetEnumUnit()', 'I2R(G2V_Damage2[6380])', 2)
tr('call ForGroupBJ(G2V_Group[6380],function G2F_Bijuu2_Func006Func004Func002A)\ncall DestroyGroup(G2V_Group[6380])\n'
   'set bj_forLoopAIndex=bj_forLoopAIndex+1\nendloop\n',
   'call ForGroupBJ(G2V_Group[6380],function G2F_Bijuu2_Func006Func004Func002A)\ncall DestroyGroup(G2V_Group[6380])\n'
   'set bj_forLoopAIndex=bj_forLoopAIndex+1\nendloop\n'
   '// v21y: regla de área, todos los enemigos en 650 de la explosión que no estaban entre los cortados.\n'
   'call Fz_Area(G2V_Caster[6380],GetLocationX(G2V_Point[6385]),GetLocationY(G2V_Point[6385]),650.,I2R(G2V_Damage2[6380]),G2V_Group3[301],17,90)\n')
# R Bijuu Dama: onda (G2F_WAVE, de Goku, una vez por enemigo en 400) 2320 en T6 y explosión en 700, 3480.
tr("set G2V_WaveDamage[G2V_WaveIndex]=((400*GetUnitAbilityLevelSwapped('AKu4',G2V_Caster[6300]))+(3*Gk_Fuerza(G2V_Caster[6300])))\n",
   "set G2V_WaveDamage[G2V_WaveIndex]=R2I(Gk_TDano(G2V_Caster[6300],89,2320.))\n")
tr('call EnableTrigger(G2T_WAVE)\n', 'call EnableTrigger(G2T_WAVE)\ncall Don_Motor(G2T_WAVE,.04)\n')
tr('call RemoveUnit(G2V_Caster[6301])\nset G2V_Point[6304]=GetUnitLoc(G2V_Caster[6302])\n',
   'call RemoveUnit(G2V_Caster[6301])\nset G2V_Point[6304]=GetUnitLoc(G2V_Caster[6302])\n'
   '// v21y: explosión al final de la onda (regla de área).\n'
   'call Fz_Area(G2V_Caster[6300],GetLocationX(G2V_Point[6304]),GetLocationY(G2V_Point[6304]),700.,Gk_TDano(G2V_Caster[6300],89,3480.),null,18,89)\n')
assert 'Gk_Fuerza' not in func and "GetUnitAbilityLevelSwapped('AKu" not in func and "GetUnitAbilityLevelSwapped('A0K2'" not in func
assert func.count('call EnableTrigger(') == func.count('call Don_Motor(') + 2, 'motor salvo RasenKyuugan2 y Bijuu_Dama_sfx (periódicos)'

MANTO = '''// v21y: Kyuubi Chakra Cloak (X, A0K5 en el cuerpo, buff B04L): las armas hacen 0,75 x curva del nivel (T6 +75 %).
function Ku_Manto takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer p = GetPlayerId(GetOwningPlayer(u))
    if p >= 0 and p < 12 then
        set Fz_Bono[p] = .75 * Tec_Curva[IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 100 + 93]))]
''' + ('''        set Cop_Log = "kurama manto bono " + R2S(Fz_Bono[p]) + " nivel " + I2S(Tec_Niv[p * 100 + 93])
        call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''    endif
    set u = null
endfunction
'''

# ---------------------------------------------------------------- globales y bloque de Kurama
cambia('real array Fz_Bono\n', 'real array Fz_Bono\n' + glob + 'real Ku_QX=0.\nreal Ku_QY=0.\n')
cambia('// ==== Trunks de 1.8c (sin uso desde v21s salvo Tr_Stat: su init ya no se llama) ====\n',
       '// ==== v21y: Naruto Kurama de Battle Stadium D.O.N 2.1a (trasplantado; ver scripts/v21y.py) ====\n' + func + MANTO
       + '// ==== Trunks de 1.8c (sin uso desde v21s salvo Tr_Stat: su init ya no se llama) ====\n')

# ---------------------------------------------------------------- selección, ficha, copias
cambia('''    call Pj_Fijar('hNaK', 5, 'hCpK', 'hMf6', 1., 'DT4N', 'hbi6', "Naruto", 57, 6)
''', '''    call Pj_Fijar('hNaK', 5, 'hCpK', 'hMf6', 1., 'DT4N', 'hbi6', "Naruto", 57, 6)
    // v21y: Naruto Kurama (2.1a), celda 6; cabeza a 160 en Stand.
    call Pj_Fijar('hKur', 6, 'hCpU', 'hMf7', 175. / 160., 'DT4K', 'hbi7', "Naruto Kurama", 89, 5)
''')
cambia("        call s__UnitHitShape_register('hNaK' , 1.6 , 48.) // v16u: como h005\n",
       "        call s__UnitHitShape_register('hNaK' , 1.6 , 48.) // v16u: como h005\n"
       "        call s__UnitHitShape_register('hKur' , 1.6 , 48.) // v21y: como h005\n")
cambia("    call RemoveUnit(CreateUnit(Player(15), 'hCpK', -12000., 9000., 0.))\n",
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpK', -12000., 9000., 0.))\n"
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpU', -12000., 9000., 0.))\n")
cambia('''        // v21n: Golden Form de Freezer (buff B025 en su cuerpo); v21s: Sword of Hope de Trunks (B05L).
        if Fz_Bono[p] > 0. and (GetUnitAbilityLevel(Game_Hero[p], 'B025') > 0 or GetUnitAbilityLevel(Game_Hero[p], 'B05L') > 0) then
''', '''        // v21n: Golden Form de Freezer (buff B025 en su cuerpo); v21s: Sword of Hope de Trunks (B05L); v21y: manto de
        // Kurama (B04L).
        if Fz_Bono[p] > 0. and (GetUnitAbilityLevel(Game_Hero[p], 'B025') > 0 or GetUnitAbilityLevel(Game_Hero[p], 'B05L') > 0 or GetUnitAbilityLevel(Game_Hero[p], 'B04L') > 0) then
''')
cambia("GetUnitTypeId(s__RapidPair_actor[this]) == 'hNaK')",
       "GetUnitTypeId(s__RapidPair_actor[this]) == 'hNaK' or GetUnitTypeId(s__RapidPair_actor[this]) == 'hKur')", 2)
cambia("    return a == 'A0OH' or a == 'A0I5' or a == 'A0H5' or a == 'A00U' or a == 'A00T'\n",
       "    return a == 'A0OH' or a == 'A0I5' or a == 'A0H5' or a == 'A00U' or a == 'A00T' or a == 'A0K5'\n")
m = re.search(r'(function Dcp_Rango takes integer a returns real\n.*?)(    endif\n    return 0\.\nendfunction\n)', src, re.S)
assert m and src.count(m.group(0)) == 1
src = src.replace(m.group(0), m.group(1) + U('''    // v21y: Kurama (aran de 2.1a).
    elseif a == 'AKu1' then
        return 600.
    elseif a == 'A0KY' then
        return 1500.
    elseif a == 'AKu4' then
        return 2500.
''') + m.group(2))
cambia("    elseif tb == 'hNaK' then\n        set tc = 'hCpK'\n    endif\n",
       "    elseif tb == 'hNaK' then\n        set tc = 'hCpK'\n    elseif tb == 'hKur' then\n        set tc = 'hCpU'\n    endif\n")
cambia("    elseif tc == 'hCpT' then\n        set Son_Foco[2] = c\n    else\n",
       "    elseif tc == 'hCpT' then\n        set Son_Foco[2] = c\n    elseif tc == 'hCpU' then\n        set Son_Foco[4] = c\n    else\n")
if prueba:
    # Dcp_Efecto de la prueba también anota los cuerpos.
    cambia("t == 'hCpT' or t == 'hCpN' or t == 'hCpK' or t == 'hGok'", "t == 'hCpT' or t == 'hCpN' or t == 'hCpK' or t == 'hCpU' or t == 'hGok'")
    cambia("or t == 'hNar' or t == 'hNaK' then\n", "or t == 'hNar' or t == 'hNaK' or t == 'hKur' then\n")
else:
    cambia("t == 'hCpT' or t == 'hCpN' or t == 'hCpK' then\n", "t == 'hCpT' or t == 'hCpN' or t == 'hCpK' or t == 'hCpU' then\n")
cambia('''    elseif t == 'hNar' or t == 'hNaK' or t == 'hCpN' or t == 'hCpK' then
        return 3
    endif
''', '''    elseif t == 'hNar' or t == 'hNaK' or t == 'hCpN' or t == 'hCpK' then
        return 3
    elseif t == 'hKur' or t == 'hCpU' then
        return 4
    endif
''')
cambia('k: 0 Goku, 1 Freezer, 2 Trunks, 3 Naruto.', 'k: 0 Goku, 1 Freezer, 2 Trunks, 3 Naruto, 4 Kurama (v21y).')

# ---------------------------------------------------------------- D.O.N: cuerpo, botones, habilidades, init
cambia('''    if Don_Toca(p, 5) then
        return 'hNar'
    endif
    return id
''', '''    if Don_Toca(p, 5) then
        return 'hNar'
    endif
    if Don_Toca(p, 6) then
        return 'hKur'
    endif
    return id
''')
cambia("or t == 'hTrk' or t == 'hNar' or t == 'hNaK'\nendfunction\n",
       "or t == 'hTrk' or t == 'hNar' or t == 'hNaK' or t == 'hKur'\nendfunction\n")
cambia("    elseif id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' then\n",
       "    elseif id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' and id != 'hKur' then\n")
cambia('''        call UnitAddAbility(Game_Ctrl[p], 'ANa3')
    endif
endfunction
''', '''        call UnitAddAbility(Game_Ctrl[p], 'ANa3')
    endif
    // v21y: Naruto Kurama (Q Rasenrengan, W RasenKyuugan, E Bijuu RasenShuriken, R Bijuu Dama, X manto).
    if id == 'hKur' then
        call UnitAddAbility(Game_Ctrl[p], 'AKp1')
        call UnitAddAbility(Game_Ctrl[p], 'AKp2')
        call UnitAddAbility(Game_Ctrl[p], 'AKp3')
        call UnitAddAbility(Game_Ctrl[p], 'AKp4')
        call UnitAddAbility(Game_Ctrl[p], 'AKp5')
    endif
endfunction
''')
ARMA = ''.join('''        call UnitAddAbility(b, '%s')
        call SetUnitAbilityLevel(b, '%s', %d)
        call UnitMakeAbilityPermanent(b, true, '%s')
''' % (a, a, n, a) for a, n in [('AKu1', 4), ('A0K2', 4), ('A0KY', 3), ('AKu4', 4), ('A0K5', 1)])
cambia('''        set NaV_s8[5790]=b
    endif
    set b = null
endfunction
''', '''        set NaV_s8[5790]=b
    endif
    if id == 'hKur' then
''' + ARMA + '''    endif
    set b = null
endfunction
''')
cambia('''    elseif a == 'A0F3' then
        return IsTriggerEnabled(NaV_kB) or IsTriggerEnabled(NaV_mB)
    endif
    return false
''', '''    elseif a == 'A0F3' then
        return IsTriggerEnabled(NaV_kB) or IsTriggerEnabled(NaV_mB)
    // v21y: Kurama (G2T_WAVE es compartido con Goku: la R cuenta hasta la explosión).
    elseif a == 'AKu1' then
        return IsTriggerEnabled(G2T_Missile_UCDummy)
    elseif a == 'A0K2' then
        return IsTriggerEnabled(G2T_RasenKyuugan2) or IsTriggerEnabled(G2T_Butcher_MUI)
    elseif a == 'A0KY' then
        return IsTriggerEnabled(G2T_Bijuu2)
    elseif a == 'AKu4' then
        return IsTriggerEnabled(G2T_Bijuu_Dama_sfx)
    endif
    return false
''')
cambia('''function Don_Init takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 5
''', '''function Don_Init takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 6
''')
BOTS = ''.join('''    set Don_BotId[Don_Bots] = '%s'
    set Don_BotReal[Don_Bots] = '%s'
    set Don_BotObj[Don_Bots] = %d
    set Don_BotOrden[Don_Bots] = "%s"
    call RegisterSpellEffectEvent('%s', function Don_Relevo)
    set Don_Bots = Don_Bots + 1
''' % (b, r, o, n, b) for b, r, o, n in [('AKp1', 'AKu1', 1, 'forkedlightning'), ('AKp2', 'A0K2', 0, 'voodoo'),
                                         ('AKp3', 'A0KY', 2, 'rainoffire'), ('AKp4', 'AKu4', 2, 'ward'),
                                         ('AKp5', 'A0K5', 0, 'roar')])
cambia('    call ExecuteFunc("G2Y_InitDON")\n', '    call ExecuteFunc("G2Y_InitDON")\n'
       '    // v21y: Naruto Kurama.\n    call ExecuteFunc("G2X_InitDON")\n' + BOTS
       + "    call RegisterSpellEffectEvent('A0K5', function Ku_Manto)\n")
cambia('''    if StringLength(n) != 1 or k < 0 or k > 5 or (k == 0 and n != "0") then
        call Pj_Aviso(pl, "Uso: -pj N   0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto")
''', '''    if StringLength(n) != 1 or k < 0 or k > 6 or (k == 0 and n != "0") then
        call Pj_Aviso(pl, "Uso: -pj N   0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto, 6 Kurama")
''')
cambia('''    set i = 3
    loop
        exitwhen i > 5
        if Don_Dueno[i] == p then
''', '''    set i = 3
    loop
        exitwhen i > 6
        if Don_Dueno[i] == p then
''')
cambia("    set Hero_Icon[5] = 'DT4N'\n", "    set Hero_Icon[5] = 'DT4N'\n    // v21y: Naruto Kurama.\n    set Hero_Icon[6] = 'DT4K'\n")

# ---------------------------------------------------------------- libro: técnicas 89-93
TEC = [(89, 'AKp4', 'AKu4', 4, '5800.0', 'R', 0, 'Bijuu Dama', 'Técnica de D.O.N.', 'DK0N'),
       (90, 'AKp3', 'A0KY', 3, '2000.0', 'E', 0, 'Bijuu RasenShuriken', 'Técnica de D.O.N.', 'DK0O'),
       (91, 'AKp2', 'A0K2', 4, '2000.0', 'W', 0, 'RasenKyuugan', 'Técnica de D.O.N.', 'DK0P'),
       (92, 'AKp1', 'AKu1', 4, '2900.0', 'Q', 1, 'Rasenrengan', 'Técnica de D.O.N.', 'DK0Q'),
       (93, 'AKp5', 'A0K5', 1, '0.0', 'X', 0, 'Kyuubi Chakra Cloak',
        'Manto 25 s: las armas hacen|nhasta +75 % en el nivel 6.', 'DK0R')]
filas = '    // v21y: Naruto Kurama (2.1a), con tiers salvo el manto (niveles 1-6 sólo para su bono).\n'
for x, pu, re_, tope, t6, tec, ini, nom, des, tex in TEC:
    filas += (f"    set Tec_Puente[{x}] = '{pu}'\n    set Tec_Real[{x}] = '{re_}'\n    set Tec_Max[{x}] = 6\n"
              f"    set Tec_Tope[{x}] = {tope}\n" + (f"    set Tec_T6[{x}] = {t6}\n" if t6 != '0.0' else '')
              + f'    set Tec_Tecla[{x}] = "{tec}"\n    set Tec_Ini[{x}] = {ini}\n    set Cua_Nom[{x}] = "{nom}"\n'
              f'    set Cua_Des[{x}] = "{des}"\n    set Cua_Tex[{x}] = \'{tex}\'\n')
cambia("    set Cua_Tex[62] = 'DK0M'\n", "    set Cua_Tex[62] = 'DK0M'\n" + filas)
cambia('''function Her_Etiqueta takes integer x returns string
''', '''// v21y: técnicas de personaje en el libro (40-77 y, desde v21y, Kurama 89-93).
function Tec_EsTec takes integer x returns boolean
    return (x >= 40 and x < 78) or (x >= 89 and x < 94)
endfunction

function Her_Etiqueta takes integer x returns string
''')
cambia('    elseif x >= 40 and x < 78 then\n', '    elseif Tec_EsTec(x) then\n', 3)
cambia('    if x >= 40 and x < 78 then\n', '    if Tec_EsTec(x) then\n', 2)
cambia('        if x < 40 or x >= 78 then\n', '        if not Tec_EsTec(x) then\n')
cambia('        if Cua_HCand[k + i] < 40 or Cua_HCand[k + i] >= 78 then\n', '        if not Tec_EsTec(Cua_HCand[k + i]) then\n')
cambia('(Cua_HCand[k + i] < 39 or Cua_HCand[k + i] >= 78)', '(Cua_HCand[k + i] != 39 and not Tec_EsTec(Cua_HCand[k + i]))')
assert len(re.findall(r'[<>]=? 78\b', src)) == 1, 'queda un 78 en los predicados del libro (sólo Tec_EsTec)'

if prueba:
    cambia('''    elseif s >= 10 then
        // v21s: Trunks (10 Q, 11 W, 12 E, 13 R, 14 T).''', '''    elseif s >= 15 then
        // v21y: Kurama (15 Q, 16 W, 17 E, 18 R).
        set q = "kurama"
        set n = SubString("QWERX", s - 15, s - 14)
    elseif s >= 10 then
        // v21s: Trunks (10 Q, 11 W, 12 E, 13 R, 14 T).''')
    cambia('lat\\\\v21x-', 'lat\\\\v21y-', src.count('lat\\\\v21x-'))
    cambia('v21x-don.txt', 'v21y-don.txt', src.count('v21x-don.txt'))
    assert 'lat\\\\v21x-' not in src and 'v21x-don.txt' not in src, 'quedan registros v21x'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[5]).write_bytes(src.encode('latin-1'))
print('v21y', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas; sonidos 3D', nsf)
