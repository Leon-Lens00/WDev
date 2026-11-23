#!/usr/bin/env python3
"""v22b (22/11/2026): Vegeta de Battle Stadium D.O.N 2.1a, personaje nuevo en la celda 7.

Leon: "vamos siguiente personaje entonces" y eligió Vegeta.
Reglas de los personajes D.O.N: retrato propio, tamaño, sin efectos de muerte en resultados, icono propio en rachas,
barra y selección, -pj 7 con todas las técnicas y partida normal sólo con Q, tiers T1-T6, sonidos 3D, regla de área de
v21n y, desde v21z/v22a, proyectiles que se paran al chocar con árboles o precipicios y estallan al acabar su vida.

1. Código de Vegeta 2.1a trasplantado (GLOB.j, FUNC.j, prefijo G2; objetos_vg21.py remapea h05X>hVg5, h0CA>hVg6):
   Q Big Bang Attack (A01D), W Galick Gun (A01E), E Final Explosion (A0HT), R Final Flash (A01F), X Power Up (A0HM,
   en el cuerpo, como la de Trunks: Ve_SubirX).
2. Puentes AVp1-AVp5 en el controlador (Q W E R X) -> copia hCpV (Dcp_Lanzar), salvo X en el cuerpo.
3. Tiers T1-T6 (curva de v21m), daño por enemigo en T6: Q 2900, W 2000, E 2500, R 5800. Técnicas 94-98 del libro.
4. Regla de área: Q ya estalla en 500; W golpea una vez a cada enemigo en 300 del rayo y en 400 al final; E daña a 20
   enemigos al azar en 1000 y ahora también al resto en 1000; R ya daña en 1600 alrededor de 800 delante.
5. Choques: la bola de la Q se para en árboles y precipicios y estalla cuando habría llegado al destino (o al morir la
   bola); el rayo de la W se para y estalla al acabar su vida (2 s), como la W de Trunks y la R de Kurama.
6. Formas (base, SSJ, SSJ2, Blue) con su código de 2.1a: X sube una forma (1 s de carga); las muertes de la oleada al
   25, 50 y 75 % de la cuota; cada forma dura Frm_DURA y vuelve a la base (Frm_Reloj), con los bonos de forma de v21v.
   Las auras y la pieza de la carga, que 2.1a no quitaba, se quitan a 1,2 s (Ve_XFin, como Tr_XFin).
7. Se quitan del código trasplantado: el destello blanco de pantalla de la R (CinematicFadeBJ para todos), sus
   SetUnitUserData (el dueño es UnitIndexer) y una animación sobre G2V_Caster[4970] (unidad ajena).
Registro (sólo prueba): "vegeta dano" por técnica (Gk_Suma 19 Q, 20 W, 21 E, 22 R), "vegeta Q/W choca en X Y" y
"vegeta forma N" (X o muertes).
Uso: v22b.py ENTRADA.j GLOB.j FUNC.j CAMBIOS.tsv SALIDA.j [prueba]   (normal de v22a; prueba de v22a-prueba).
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


def log(texto):
    """Línea de registro (sólo prueba); texto es una expresión JASS de cadena."""
    return ('set Cop_Log=' + texto + '\ncall ExecuteFunc("Cop_Anotar")\n') if prueba else ''


# ---------------------------------------------------------------- sonidos 3D (como v21s/v21y)
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


func, nsf, kif = sonidos3d(func, {'G2F_': 5})
assert 'PlaySoundBJ(' not in func and kif == 1 and nsf == 7, (nsf, kif)
assert 'M3D_finalflash2' in func


def golpe(linea, s, x, src_, tgt, dmg, veces=1):
    if prueba:
        tr(linea + '\n', linea + '\ncall Gk_Suma(%d,%d,%s,%s,%s)\n' % (s, x, src_, tgt, dmg), veces)


# ---------------------------------------------------------------- daño por tier, área y choques (FUNC.j)
# W Galick Gun: el rayo (G2V_Caster[$8FE], 2 s de vida) avanza 80 cada 0,03 s; golpea una vez en 300 (Group2[105]) y al
# morir el rayo, en 400 a los que faltaban. v22b: si el paso cruza un árbol o un precipicio, se queda en el último punto
# libre hasta que muere.
tr("set G2V_Damage2[$8FC]=((75*GetUnitAbilityLevelSwapped('A01E',G2V_Caster[$8FC]))+((0+G2V_Int[5720])*Gk_Fuerza(G2V_Caster[$8FC])))\n"
   "call EnableTrigger(G2T_galickgun_2)\n",
   "set G2V_Damage2[$8FC]=R2I(Gk_TDano(G2V_Caster[$8FC],96,2000.))\n"
   "set Ve_WPara=false\ncall EnableTrigger(G2T_galickgun_2)\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[$8FC],GetEnumUnit(),I2R(G2V_Damage2[$8FC]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      20, 96, 'G2V_Caster[$8FC]', 'GetEnumUnit()', 'I2R(G2V_Damage2[$8FC])', 2)
tr('set G2V_Point[$8FF]=PolarProjectionBJ(G2V_Point[$8FE],80.,AngleBetweenPoints(G2V_Point[$8FC],G2V_Point[$8FD]))\n',
   'set G2V_Point[$8FF]=PolarProjectionBJ(G2V_Point[$8FE],80.,AngleBetweenPoints(G2V_Point[$8FC],G2V_Point[$8FD]))\n'
   '// v22b: se para en árboles y precipicios (GroundCollision, como Don_Pon) hasta acabar su vida.\n'
   'if Ve_WPara then\n'
   'call MoveLocation(G2V_Point[$8FF],GetLocationX(G2V_Point[$8FE]),GetLocationY(G2V_Point[$8FE]))\n'
   'elseif s__GroundCollision_trace(GetLocationX(G2V_Point[$8FE]),GetLocationY(G2V_Point[$8FE]),GetLocationX(G2V_Point[$8FF]),'
   'GetLocationY(G2V_Point[$8FF]),24.,G2V_Caster[$8FE],GetOwningPlayer(G2V_Caster[$8FC]),false)!=0 then\n'
   'set Ve_WPara=true\n'
   'call MoveLocation(G2V_Point[$8FF],s__GroundCollision_x,s__GroundCollision_y)\n'
   + log('"vegeta W choca en "+I2S(R2I(s__GroundCollision_x))+" "+I2S(R2I(s__GroundCollision_y))') +
   'endif\n')

# Q Big Bang Attack: la bola (G2V_BigbangBall) avanza 75 cada 0,04 s y estalla en 500 a 100 del destino o al morir.
# v22b: si choca, se queda en el último punto libre y estalla cuando habría llegado (Ve_QEspera pasos).
tr("set G2V_Damage2[$8FF]=((100*GetUnitAbilityLevelSwapped('A01D',G2V_BigbangCaster))+(2*Gk_Fuerza(G2V_BigbangCaster)))\n"
   "call EnableTrigger(G2T_bigbang_move)\n",
   "set G2V_Damage2[$8FF]=R2I(Gk_TDano(G2V_BigbangCaster,97,2900.))\n"
   "set Ve_QEspera=-1\ncall EnableTrigger(G2T_bigbang_move)\n")
golpe('call UnitDamageTargetBJ(G2V_BigbangCaster,GetEnumUnit(),I2R(G2V_Damage2[$8FF]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      19, 97, 'G2V_BigbangCaster', 'GetEnumUnit()', 'I2R(G2V_Damage2[$8FF])')
tr('set G2V_BigbangOffset=PolarProjectionBJ(G2V_BigBangDummyPoint,75.,AngleBetweenPoints(G2V_BigbangCasterPoint,G2V_BigbangTargetPoint))\n'
   'call SetUnitPositionLoc(G2V_BigbangBall,G2V_BigbangOffset)\n',
   'set G2V_BigbangOffset=PolarProjectionBJ(G2V_BigBangDummyPoint,75.,AngleBetweenPoints(G2V_BigbangCasterPoint,G2V_BigbangTargetPoint))\n'
   '// v22b: se para en árboles y precipicios y espera lo que le faltaba para llegar.\n'
   'if Ve_QEspera>0 then\n'
   'set Ve_QEspera=Ve_QEspera-1\n'
   'call MoveLocation(G2V_BigbangOffset,GetLocationX(G2V_BigBangDummyPoint),GetLocationY(G2V_BigBangDummyPoint))\n'
   'elseif Ve_QEspera<0 and s__GroundCollision_trace(GetLocationX(G2V_BigBangDummyPoint),GetLocationY(G2V_BigBangDummyPoint),'
   'GetLocationX(G2V_BigbangOffset),GetLocationY(G2V_BigbangOffset),24.,G2V_BigbangBall,GetOwningPlayer(G2V_BigbangCaster),false)!=0 then\n'
   'call MoveLocation(G2V_BigbangOffset,s__GroundCollision_x,s__GroundCollision_y)\n'
   'set Ve_QEspera=IMaxBJ(1,R2I((DistanceBetweenPoints(G2V_BigbangOffset,G2V_BigbangTargetPoint)-100.)/75.))\n'
   + log('"vegeta Q choca en "+I2S(R2I(s__GroundCollision_x))+" "+I2S(R2I(s__GroundCollision_y))+" espera "+I2S(Ve_QEspera)') +
   'endif\n'
   'call SetUnitPositionLoc(G2V_BigbangBall,G2V_BigbangOffset)\n')
tr('return(R2I(DistanceBetweenPoints(G2V_BigBangDummyPoint,G2V_BigbangTargetPoint))<=100)or(IsUnitDeadBJ(G2V_BigbangBall))\n',
   'return(R2I(DistanceBetweenPoints(G2V_BigBangDummyPoint,G2V_BigbangTargetPoint))<=100)or(IsUnitDeadBJ(G2V_BigbangBall))or(Ve_QEspera==0)\n')
tr('call DisableTrigger(GetTriggeringTrigger())\ncall RemoveUnit(G2V_Caster[5576])\n',
   'call DisableTrigger(GetTriggeringTrigger())\nset Ve_QEspera=-1\ncall RemoveUnit(G2V_Caster[5576])\n')

# E Final Explosion: 20 enemigos al azar en 1000 (Group2[$CA]) recibían la vida perdida del que lanza / 2.
tr('call UnitDamageTargetBJ(G2V_Caster[5760],GetEnumUnit(),((GetUnitStateSwap(UNIT_STATE_MAX_LIFE,G2V_Caster[5760])-'
   'GetUnitStateSwap(UNIT_STATE_LIFE,G2V_Caster[5760]))/2.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n',
   'call UnitDamageTargetBJ(G2V_Caster[5760],GetEnumUnit(),Gk_TDano(G2V_Caster[5760],95,2500.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n')
golpe('call UnitDamageTargetBJ(G2V_Caster[5760],GetEnumUnit(),Gk_TDano(G2V_Caster[5760],95,2500.),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      21, 95, 'G2V_Caster[5760]', 'GetEnumUnit()', 'Gk_TDano(G2V_Caster[5760],95,2500.)')
tr('call GroupClear(G2V_Group2[$CA])\n',
   '// v22b: regla de área, todos los enemigos en 1000 que no estaban entre los 20.\n'
   'call Fz_Area(G2V_Caster[5760],GetLocationX(G2V_Point[5760]),GetLocationY(G2V_Point[5760]),1000.,'
   'Gk_TDano(G2V_Caster[5760],95,2500.),G2V_Group2[$CA],21,95)\n'
   'call GroupClear(G2V_Group2[$CA])\n')
tr('call SetUnitAnimation(G2V_Caster[4970],"Stand Channel")\n', '')

# R Final Flash: ya daña en 1600 alrededor del punto a 800 delante.
tr("set G2V_Damage2[$EBF]=((400*GetUnitAbilityLevelSwapped('A01F',G2V_FinalFlashCaster))+(3*Gk_Fuerza(G2V_FinalFlashCaster)))\n",
   "set G2V_Damage2[$EBF]=R2I(Gk_TDano(G2V_FinalFlashCaster,94,5800.))\n")
golpe('call UnitDamageTargetBJ(G2V_FinalFlashCaster,GetEnumUnit(),I2R(G2V_Damage2[$EBF]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      22, 94, 'G2V_FinalFlashCaster', 'GetEnumUnit()', 'I2R(G2V_Damage2[$EBF])')
tr('call CinematicFadeBJ(2,.4,"ReplaceableTextures\\\\CameraMasks\\\\White_mask.blp",100.,100.,100.,0)\n', '')
func, k = re.subn(r'^call SetUnitUserData\(G2V_FinalFlashCaster,[01]\)\n', '', func, flags=re.M)
assert k == 5, k
assert 'SetUnitUserData' not in func and 'CinematicFade' not in func and '[4970]' not in func

# X Power Up (Saian_Bejita, A0HM en el cuerpo G2V_Caster[5720]; G2V_Int[5720] forma 1-4).
tr('return(GetSpellAbilityUnit()==G2V_Caster[5720])and(G2V_Bool[5720]==false)and(G2V_Int[5720]<4)\n',
   'return(Ve_XOk or GetSpellAbilityUnit()==G2V_Caster[5720])and(G2V_Bool[5720]==false)and(G2V_Int[5720]<4)\n')
for aura in ('BitchAura', 'SaianAura'):
    tr('call AddSpecialEffectLocBJ(G2V_Point[5720],"war3mapImported\\\\%s.mdx")\n' % aura,
       ('// v22b: las auras siguen a Vegeta, como las de Trunks (v21x).\n' if aura == 'BitchAura' else '')
       + 'call AddSpecialEffectTargetUnitBJ("origin",G2V_Caster[5720],"war3mapImported\\\\%s.mdx")\n' % aura)
# la forma vuelve a la base por Frm_Reloj (Frm_DURA), no a los 50 s propios de 2.1a.
tr('return(G2V_Int[5723]>=50)\n', 'return Frm_Corte\n')

assert 'Gk_Fuerza' not in func and 'GetUnitAbilityLevelSwapped' not in func
assert 'call Don_Motor(' not in func.replace('call Don_Motor(G2T_slider,.04)', ''), 'sólo el slider va con motor'

XFIN = '''// v22b: X de Vegeta (Power Up de 2.1a): al acabar la carga se quitan la pieza y las auras que 2.1a dejaba puestas.
function Ve_XFin takes nothing returns nothing
    local unit b = G2V_Caster[5720]
    call DestroyEffect(G2V_Effect[5720])
    call DestroyEffect(G2V_Effect[5721])
    set G2V_Effect[5720] = null
    set G2V_Effect[5721] = null
    if G2V_Caster[5721] != null then
        call RemoveUnit(G2V_Caster[5721])
        set G2V_Caster[5721] = null
    endif
    if b != null and UnitAlive(b) and not G2V_Bool[5720] then
''' + ('''        set Cop_Log = "vegeta forma " + I2S(G2V_Int[5720]) + " por X"
        call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''        if G2V_Int[5720] == 2 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "|cffffcc00¡Super Saiyan!|r")
        elseif G2V_Int[5720] == 3 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "|cffffcc00¡Super Saiyan 2!|r")
        elseif G2V_Int[5720] == 4 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "|cffffcc00¡Super Saiyan Blue!|r")
        endif
    endif
    call DestroyTimer(GetExpiredTimer())
    set b = null
endfunction

// v22b: X de Vegeta: carga de 1 s y una forma más, hasta Blue. La lanza el controlador (AVp5), como Tr_SubirX.
function Ve_SubirX takes nothing returns nothing
    local integer this = s__RapidPair_fromController(GetTriggerUnit())
    local unit b = G2V_Caster[5720]
    local player p = GetTriggerPlayer()
    if b == null or this == 0 or s__RapidPair_actor[this] != b or not UnitAlive(b) then
        set b = null
        return
    endif
    if G2V_Int[5720] < 1 then
        set G2V_Int[5720] = 1
    endif
    if G2V_Bool[5720] then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya se está transformando.")
    elseif G2V_Int[5720] >= 4 then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya está en Super Saiyan Blue.")
    else
        set Ve_XOk = true
        call G2F_Saian_Bejita_Actions()
        set Ve_XOk = false
        call TimerStart(CreateTimer(), 1.2, false, function Ve_XFin)
    endif
    set b = null
endfunction
'''

# ---------------------------------------------------------------- globales y bloque de Vegeta
cambia('real array Fz_Bono\n', 'real array Fz_Bono\n' + glob
       + 'boolean Ve_WPara=false\ninteger Ve_QEspera=-1\nboolean Ve_XOk=false\ninteger Frm_VeNiv=1\nreal Frm_VeFin=0.\n')
cambia('// ==== Trunks de 1.8c (sin uso desde v21s salvo Tr_Stat: su init ya no se llama) ====\n',
       '// ==== v22b: Vegeta de Battle Stadium D.O.N 2.1a (trasplantado; ver scripts/v22b.py) ====\n' + func + XFIN
       + '// ==== Trunks de 1.8c (sin uso desde v21s salvo Tr_Stat: su init ya no se llama) ====\n')

# ---------------------------------------------------------------- formas: reloj, muertes y nivel
cambia('''    set b = null
endfunction

function Tec_Vigila takes nothing returns nothing
''', '''    // v22b: Vegeta (base, SSJ, SSJ2, Blue).
    set b = G2V_Caster[5720]
    if b != null then
        if IMaxBJ(1, G2V_Int[5720]) != Frm_VeNiv then
            set Frm_VeNiv = IMaxBJ(1, G2V_Int[5720])
            set Frm_VeFin = now + Frm_DURA
        elseif Frm_VeNiv > 1 and not G2V_Bool[5720] and now >= Frm_VeFin then
            set Frm_Corte = true
            call G2F_Saian_Bejita3_Actions()
            set Frm_Corte = false
            call DisableTrigger(G2T_Saian_Bejita3)
            set Frm_VeNiv = 1
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "Vegeta vuelve a su forma normal.")
''' + ('''            call Dia_Anotar("forma vegeta fin")
''' if prueba else '''''') + '''        endif
    endif
    set b = null
endfunction

function Tec_Vigila takes nothing returns nothing
''')
cambia('''    endif
    set h = null
endfunction

// v20s: al terminar la wave, todos vuelven a su forma base.
''', '''    elseif t == 'hVeg' and h == G2V_Caster[5720] and not G2V_Bool[5720] then
        // v22b: formas de Vegeta de 2.1a (base, SSJ, SSJ2, Blue) con su código, como Trunks.
        if Frm_Llega(k, 75) then
            set n = 4
        elseif Frm_Llega(k, 50) then
            set n = 3
        elseif Frm_Llega(k, 25) then
            set n = 2
        endif
        if G2V_Int[5720] < 1 then
            set G2V_Int[5720] = 1
        endif
        if G2V_Int[5720] < n and n > Frm_Dado[k] then
            set G2V_Bool[5720] = true
            set G2V_Int[5727] = 1
            call ExecuteFunc("G2F_Saian_Bejita2_Actions")
            set Frm_Dado[k] = G2V_Int[5720]
''' + ('''            set Cop_Log = "vegeta forma " + I2S(G2V_Int[5720]) + " por muertes"
            call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''            if G2V_Int[5720] == 2 then
                call Frm_Aviso(k, "¡Super Saiyan!")
            elseif G2V_Int[5720] == 3 then
                call Frm_Aviso(k, "¡Super Saiyan 2!")
            elseif G2V_Int[5720] == 4 then
                call Frm_Aviso(k, "¡Super Saiyan Blue!")
            endif
        endif
    endif
    set h = null
endfunction

// v20s: al terminar la wave, todos vuelven a su forma base.
''')
cambia('''            elseif h == G2V_Caster[$CEE] and GetUnitTypeId(h) == 'hTrk' then
                set n=G2V_Int[5630] - 1
''', '''            elseif h == G2V_Caster[$CEE] and GetUnitTypeId(h) == 'hTrk' then
                set n=G2V_Int[5630] - 1
            // v22b: Vegeta 0-3.
            elseif h == G2V_Caster[5720] and GetUnitTypeId(h) == 'hVeg' then
                set n=G2V_Int[5720] - 1
''')

# ---------------------------------------------------------------- selección, ficha, copias
cambia('''    call Pj_Fijar('hKur', 6, 'hCpU', 'hMf7', 175. / 160., 'DT4K', 'hbi7', "Naruto Kurama", 89, 5)
''', '''    call Pj_Fijar('hKur', 6, 'hCpU', 'hMf7', 175. / 160., 'DT4K', 'hbi7', "Naruto Kurama", 89, 5)
    // v22b: Vegeta (2.1a), celda 7; cabeza a 164 en Stand.
    call Pj_Fijar('hVeg', 7, 'hCpV', 'hMf8', 175. / 164., 'DT4V', 'hbi8', "Vegeta", 94, 5)
''')
cambia("        call s__UnitHitShape_register('hKur' , 1.6 , 48.) // v21y: como h005\n",
       "        call s__UnitHitShape_register('hKur' , 1.6 , 48.) // v21y: como h005\n"
       "        call s__UnitHitShape_register('hVeg' , 1.6 , 48.) // v22b: como h005\n")
cambia("    call RemoveUnit(CreateUnit(Player(15), 'hCpU', -12000., 9000., 0.))\n",
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpU', -12000., 9000., 0.))\n"
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpV', -12000., 9000., 0.))\n")
cambia("GetUnitTypeId(s__RapidPair_actor[this]) == 'hKur')",
       "GetUnitTypeId(s__RapidPair_actor[this]) == 'hKur' or GetUnitTypeId(s__RapidPair_actor[this]) == 'hVeg')", 2)
cambia("    return a == 'A0OH' or a == 'A0I5' or a == 'A0H5' or a == 'A00U' or a == 'A00T' or a == 'A0K5'\n",
       "    return a == 'A0OH' or a == 'A0I5' or a == 'A0H5' or a == 'A00U' or a == 'A00T' or a == 'A0K5' or a == 'A0HM'\n")
m = re.search(r'(function Dcp_Rango takes integer a returns real\n.*?)(    endif\n    return 0\.\nendfunction\n)', src, re.S)
assert m and src.count(m.group(0)) == 1
src = src.replace(m.group(0), m.group(1) + U('''    // v22b: Vegeta (aran de 2.1a).
    elseif a == 'A01D' then
        return 2500.
    elseif a == 'A01E' then
        return 2000.
    elseif a == 'A01F' then
        return 1500.
''') + m.group(2))
cambia("    elseif tb == 'hKur' then\n        set tc = 'hCpU'\n    endif\n",
       "    elseif tb == 'hKur' then\n        set tc = 'hCpU'\n    elseif tb == 'hVeg' then\n        set tc = 'hCpV'\n    endif\n")
cambia("    elseif tc == 'hCpU' then\n        set Son_Foco[4] = c\n    else\n",
       "    elseif tc == 'hCpU' then\n        set Son_Foco[4] = c\n    elseif tc == 'hCpV' then\n        set Son_Foco[5] = c\n    else\n")
# cabezas de Vegeta (base y SSJ: A080/A081; Blue: A0JN); A00Y y A0OC ya estaban.
cambia("    call Dcp_Pieza(b, c, 'A0OD')\n",
       "    call Dcp_Pieza(b, c, 'A0OD')\n    call Dcp_Pieza(b, c, 'A080')\n    call Dcp_Pieza(b, c, 'A081')\n"
       "    call Dcp_Pieza(b, c, 'A0JN')\n")
cambia("    call UnitRemoveAbility(c, 'A0OD')\nendfunction\n",
       "    call UnitRemoveAbility(c, 'A0OD')\n    call UnitRemoveAbility(c, 'A080')\n    call UnitRemoveAbility(c, 'A081')\n"
       "    call UnitRemoveAbility(c, 'A0JN')\nendfunction\n")
if prueba:
    cambia("t == 'hCpK' or t == 'hCpU' or t == 'hGok'", "t == 'hCpK' or t == 'hCpU' or t == 'hCpV' or t == 'hGok'")
    cambia("or t == 'hNaK' or t == 'hKur' then\n", "or t == 'hNaK' or t == 'hKur' or t == 'hVeg' then\n")
else:
    cambia("t == 'hCpK' or t == 'hCpU' then\n", "t == 'hCpK' or t == 'hCpU' or t == 'hCpV' then\n")
cambia('''    elseif t == 'hKur' or t == 'hCpU' then
        return 4
    endif
''', '''    elseif t == 'hKur' or t == 'hCpU' then
        return 4
    elseif t == 'hVeg' or t == 'hCpV' then
        return 5
    endif
''')
cambia('k: 0 Goku, 1 Freezer, 2 Trunks, 3 Naruto, 4 Kurama (v21y).',
       'k: 0 Goku, 1 Freezer, 2 Trunks, 3 Naruto, 4 Kurama (v21y), 5 Vegeta (v22b).')

# ---------------------------------------------------------------- D.O.N: cuerpo, botones, habilidades, init
cambia('''    if Don_Toca(p, 6) then
        return 'hKur'
    endif
    return id
''', '''    if Don_Toca(p, 6) then
        return 'hKur'
    endif
    if Don_Toca(p, 7) then
        return 'hVeg'
    endif
    return id
''')
cambia("or t == 'hNar' or t == 'hNaK' or t == 'hKur'\nendfunction\n",
       "or t == 'hNar' or t == 'hNaK' or t == 'hKur' or t == 'hVeg'\nendfunction\n")
cambia("    elseif id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' and id != 'hKur' then\n",
       "    elseif id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' and id != 'hKur' and id != 'hVeg' then\n")
cambia('''        call UnitAddAbility(Game_Ctrl[p], 'AKp5')
    endif
endfunction
''', '''        call UnitAddAbility(Game_Ctrl[p], 'AKp5')
    endif
    // v22b: Vegeta (Q Big Bang, W Galick Gun, E Final Explosion, R Final Flash, X Power Up).
    if id == 'hVeg' then
        call UnitAddAbility(Game_Ctrl[p], 'AVp1')
        call UnitAddAbility(Game_Ctrl[p], 'AVp2')
        call UnitAddAbility(Game_Ctrl[p], 'AVp3')
        call UnitAddAbility(Game_Ctrl[p], 'AVp4')
        call UnitAddAbility(Game_Ctrl[p], 'AVp5')
    endif
endfunction
''')
ARMA = ''.join('''        call UnitAddAbility(b, '%s')
        call SetUnitAbilityLevel(b, '%s', %d)
        call UnitMakeAbilityPermanent(b, true, '%s')
''' % (a, a, n, a) for a, n in [('A01D', 4), ('A01E', 4), ('A01F', 3), ('A0HT', 1), ('A0HM', 1)])
cambia('''        call UnitMakeAbilityPermanent(b, true, 'A0K5')
    endif
    set b = null
endfunction
''', '''        call UnitMakeAbilityPermanent(b, true, 'A0K5')
    endif
    if id == 'hVeg' then
''' + ARMA + '''        // cabeza base (2.1a la cuelga con A080); en SSJ/SSJ2 (A081) o Blue (A0JN) ya lleva la suya.
        if GetUnitAbilityLevel(b, 'A081') == 0 and GetUnitAbilityLevel(b, 'A0JN') == 0 then
            call UnitAddAbility(b, 'A080')
            call UnitMakeAbilityPermanent(b, true, 'A080')
        endif
        set G2V_Caster[5720]=b
        if G2V_Int[5720] < 1 then
            set G2V_Int[5720] = 1
        endif
    endif
    set b = null
endfunction
''')
cambia('''    elseif a == 'AKu4' then
        return IsTriggerEnabled(G2T_Bijuu_Dama_sfx)
    endif
    return false
''', '''    elseif a == 'AKu4' then
        return IsTriggerEnabled(G2T_Bijuu_Dama_sfx)
    // v22b: Vegeta (la E y la R son esperas en su acción: cuentan mientras tienen a quien lanza).
    elseif a == 'A01D' then
        return IsTriggerEnabled(G2T_bigbang_move)
    elseif a == 'A01E' then
        return IsTriggerEnabled(G2T_galickgun_2)
    elseif a == 'A0HT' then
        return G2V_Caster[5760] != null
    elseif a == 'A01F' then
        return G2V_FinalFlashCaster != null
    endif
    return false
''')
cambia('''function Don_Init takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 6
''', '''function Don_Init takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 7
''')
BOTS = ''.join('''    set Don_BotId[Don_Bots] = '%s'
    set Don_BotReal[Don_Bots] = '%s'
    set Don_BotObj[Don_Bots] = %d
    set Don_BotOrden[Don_Bots] = "%s"
    call RegisterSpellEffectEvent('%s', function %s)
    set Don_Bots = Don_Bots + 1
''' % (b, r, o, n, b, f) for b, r, o, n, f in [
    ('AVp1', 'A01D', 2, 'flamestrike', 'Don_Relevo'), ('AVp2', 'A01E', 2, 'clusterrockets', 'Don_Relevo'),
    ('AVp3', 'A0HT', 0, 'roar', 'Don_Relevo'), ('AVp4', 'A01F', 2, 'rainoffire', 'Don_Relevo'),
    ('AVp5', 'A0HM', 0, 'voodoo', 'Ve_SubirX')])
cambia("    call RegisterSpellEffectEvent('A0K5', function Ku_Manto)\n",
       "    call RegisterSpellEffectEvent('A0K5', function Ku_Manto)\n"
       '    // v22b: Vegeta (X directa al cuerpo con Ve_SubirX, como la de Trunks).\n    call ExecuteFunc("G2W_InitDON")\n' + BOTS)
cambia('''    if StringLength(n) != 1 or k < 0 or k > 6 or (k == 0 and n != "0") then
        call Pj_Aviso(pl, "Uso: -pj N   0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto, 6 Kurama")
''', '''    if StringLength(n) != 1 or k < 0 or k > 7 or (k == 0 and n != "0") then
        call Pj_Aviso(pl, "Uso: -pj N   0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto, 6 Kurama, 7 Vegeta")
''')
cambia('''    set i = 3
    loop
        exitwhen i > 6
        if Don_Dueno[i] == p then
''', '''    set i = 3
    loop
        exitwhen i > 7
        if Don_Dueno[i] == p then
''')
cambia("    set Hero_Icon[6] = 'DT4K'\n", "    set Hero_Icon[6] = 'DT4K'\n    // v22b: Vegeta.\n    set Hero_Icon[7] = 'DT4V'\n")

# ---------------------------------------------------------------- libro: técnicas 94-98
TEC = [(94, 'AVp4', 'A01F', 3, '5800.0', 'R', 0, 'Final Flash', 'Técnica de D.O.N.', 'DK0S'),
       (95, 'AVp3', 'A0HT', 1, '2500.0', 'E', 0, 'Final Explosion', 'Técnica de D.O.N.', 'DK0T'),
       (96, 'AVp2', 'A01E', 4, '2000.0', 'W', 0, 'Galick Gun', 'Técnica de D.O.N.', 'DK0U'),
       (97, 'AVp1', 'A01D', 4, '2900.0', 'Q', 1, 'Big Bang Attack', 'Técnica de D.O.N.', 'DK0V')]
filas = '    // v22b: Vegeta (2.1a), con tiers salvo Power Up (como el de Trunks).\n'
for x, pu, re_, tope, t6, tec, ini, nom, des, tex in TEC:
    filas += (f"    set Tec_Puente[{x}] = '{pu}'\n    set Tec_Real[{x}] = '{re_}'\n    set Tec_Max[{x}] = 6\n"
              f"    set Tec_Tope[{x}] = {tope}\n    set Tec_T6[{x}] = {t6}\n"
              f'    set Tec_Tecla[{x}] = "{tec}"\n    set Tec_Ini[{x}] = {ini}\n    set Cua_Nom[{x}] = "{nom}"\n'
              f'    set Cua_Des[{x}] = "{des}"\n    set Cua_Tex[{x}] = \'{tex}\'\n')
filas += '''    set Tec_Puente[98] = 'AVp5'
    set Tec_Real[98] = 'A0HM'
    set Tec_Max[98] = 1
    set Tec_Tecla[98] = "X"
    set Tec_Ini[98] = 0
    set Cua_Nom[98] = "Power Up"
    set Cua_Des[98] = "Carga y sube una forma (50 s).|nTambién suben con las muertes."
    set Cua_Tex[98] = 'DK0W'
'''
cambia("    set Cua_Tex[93] = 'DK0R'\n", "    set Cua_Tex[93] = 'DK0R'\n" + filas)
cambia('''// v21y: técnicas de personaje en el libro (40-77 y, desde v21y, Kurama 89-93).
function Tec_EsTec takes integer x returns boolean
    return (x >= 40 and x < 78) or (x >= 89 and x < 94)
endfunction
''', '''// v21y: técnicas de personaje en el libro (40-77 y, desde v21y, Kurama 89-93; v22b: Vegeta 94-98).
function Tec_EsTec takes integer x returns boolean
    return (x >= 40 and x < 78) or (x >= 89 and x < 99)
endfunction
''')

if prueba:
    cambia('''    elseif s >= 15 then
        // v21y: Kurama (15 Q, 16 W, 17 E, 18 R).''', '''    elseif s >= 19 then
        // v22b: Vegeta (19 Q, 20 W, 21 E, 22 R).
        set q = "vegeta"
        set n = SubString("QWERX", s - 19, s - 18)
    elseif s >= 15 then
        // v21y: Kurama (15 Q, 16 W, 17 E, 18 R).''')
    cambia('lat\\\\v22a-', 'lat\\\\v22b-', src.count('lat\\\\v22a-'))
    cambia('v22a-don.txt', 'v22b-don.txt', src.count('v22a-don.txt'))
    assert 'lat\\\\v22a-' not in src and 'v22a-don.txt' not in src, 'quedan registros v22a'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[5]).write_bytes(src.encode('latin-1'))
print('v22b', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas; sonidos 3D', nsf)
