#!/usr/bin/env python3
"""v22d (23/11/2026): Vegito de Battle Stadium D.O.N 2.1a, personaje nuevo en la celda 8.

Leon tras v22c: "fue correcto, vamos al siguiente pj" y eligió Vegito.
Reglas de los personajes D.O.N (como Vegeta en v22b, con la lista de "Fallos repetidos" de
WDev/skills/claude/mapa-dev-mission/references/importar-heroes-don.md): retrato propio, tamaño, icono propio, -pj 8
con todas las técnicas y partida normal sólo con Q, tiers T1-T6, sonidos 3D, regla de área, choques con árboles y
precipicios, el efecto de la X sigue al cuerpo y toda sacudida tiene su quitar, sin efectos de pantalla ni UserData.

1. Código de Vegito 2.1a trasplantado (GLOB.j, FUNC.j, prefijo G2; objetos_vt21.py remapea A00S>AG2a, h05X>hVg5):
   Q Banshee Blast (A03E, 5 explosiones dirigidas en 300), W Big Bang (A033, bola que vuela y 12 estallidos en
   cadena), E Spirit Sword (A03F, a una unidad), R Final Kamehameha (A0DS, rayo), X Power Up (A0HL, en el cuerpo, como
   la de Vegeta: Vt_SubirX) y la pasiva Afterimage (2.1a no le daba evento: aquí al recibir un ataque cuerpo a cuerpo,
   cada 4 s, aparece detrás del atacante y golpea en 250).
2. Puentes AVt1-AVt5 en el controlador (Q W E R X) -> copia hCpW (Dcp_Lanzar), salvo X en el cuerpo.
3. Tiers T1-T6, daño por enemigo en T6: Q 900 por explosión, W 2000, E 2500, R 5800, Afterimage 1500. Técnicas
   99-104 del libro (104 = Afterimage, pasiva con tiers). Hay 105 técnicas: Tec_Niv/Tec_Listo pasan de p*100 a p*200.
4. Regla de área: Q estalla en 300; W golpea en 250 al volar, en la cadena y en 400 al final; E daña en 300 alrededor
   del blanco; R daña en 400 por paso del rayo y ahora en 700 al final con el daño del tier (2.1a: 3 x fuerza).
5. Choques: la bola de la W y la cabeza del rayo de la R se paran en árboles y precipicios hasta acabar su vida; la
   cadena de la W estalla donde se paró la bola. Los misiles de la Q usan Homing (Don_Pon ya los para).
6. Formas (base, Super, Blue) con su código de 2.1a: X sube una forma (1 s de carga); las muertes de la oleada al
   25 y 50 % de la cuota; cada forma dura Frm_DURA y vuelve a la base (Frm_Reloj). La pieza y las auras de la carga
   siguen a Vegito y se quitan a 1,2 s con la sacudida de la carga (Vt_XFin + Gk_SacudeFinX, lección de v22c).
7. Se quitan del código trasplantado: la fuerza de 2.1a en el daño y la unidad ajena de Afterimage
   (G2V_Caster[4960]); el blanco de la E se guarda por si desaparece (si no, la copia saltaría al centro del mapa).
Registro (sólo prueba): "vegito dano" por técnica (Gk_Suma 23 Q, 24 W, 25 E, 26 R, 27 pasiva), "vegito W/R choca en
X Y", "vegito forma N", "vegito X temblor fuera N" y "vegito afterimage".
Uso: v22d.py ENTRADA.j GLOB.j FUNC.j CAMBIOS.tsv SALIDA.j [prueba]   (normal de v22c; prueba de v22c-prueba).
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


# ---------------------------------------------------------------- sonidos 3D (como v22b)
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


func, nsf, kif = sonidos3d(func, {'G2F_': 6})
assert 'PlaySoundBJ(' not in func and kif == 1 and nsf == 1, (nsf, kif)
assert 'M3D_Finalkamehameha' in func


def golpe(linea, s, x, src_, tgt, dmg, veces=1):
    if prueba:
        tr(linea + '\n', linea + '\ncall Gk_Suma(%d,%d,%s,%s,%s)\n' % (s, x, src_, tgt, dmg), veces)


# ---------------------------------------------------------------- daño por tier, área y choques (FUNC.j)
# Q Banshee Blast: 5 misiles dirigidos (Homing de la base) que estallan en 300 con G2V_Damage[$AA]. El daño se calcula
# al lanzar y otra vez en cada explosión (código de la base, ver abajo).
tr("set G2V_Damage[$AA]=((100*GetUnitAbilityLevelSwapped('A03E',G2V_Caster[$AA]))+(2*Gk_Fuerza(G2V_Caster[$AA])))\n",
   "set G2V_Damage[$AA]=R2I(Gk_TDano(G2V_Caster[$AA],99,900.))\n")

# W Big Bang: la bola (G2V_Caster[81], 1,6 s de vida) vuela 70 cada 0,04 s golpeando en 250; al morir, 12 estallidos
# en cadena cada 100 desde donde quedó, y 400 al final.
tr("set G2V_Damage2[80]=((100*GetUnitAbilityLevelSwapped('A033',G2V_Caster[80]))+(2*Gk_Fuerza(G2V_Caster[80])))\n",
   "set G2V_Damage2[80]=R2I(Gk_TDano(G2V_Caster[80],100,2000.))\n"
   "set Vt_WPara=false\nset Vt_WAv=1.\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[80],GetEnumUnit(),I2R(G2V_Damage2[80]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      24, 100, 'G2V_Caster[80]', 'GetEnumUnit()', 'I2R(G2V_Damage2[80])', 3)
tr('set G2V_Point[83]=PolarProjectionBJ(G2V_Point[82],70.,G2V_Angle[80])\n'
   'call SetUnitPositionLoc(G2V_Caster[81],G2V_Point[83])\n',
   'set G2V_Point[83]=PolarProjectionBJ(G2V_Point[82],70.,G2V_Angle[80])\n'
   '// v22d: se para en árboles y precipicios (GroundCollision, como Don_Pon) hasta acabar su vida.\n'
   'if Vt_WPara then\n'
   'call MoveLocation(G2V_Point[83],GetLocationX(G2V_Point[82]),GetLocationY(G2V_Point[82]))\n'
   'elseif s__GroundCollision_trace(GetLocationX(G2V_Point[82]),GetLocationY(G2V_Point[82]),GetLocationX(G2V_Point[83]),'
   'GetLocationY(G2V_Point[83]),24.,G2V_Caster[81],GetOwningPlayer(G2V_Caster[80]),false)!=0 then\n'
   'set Vt_WPara=true\n'
   'set Vt_WAv=0.\n'
   'call MoveLocation(G2V_Point[83],s__GroundCollision_x,s__GroundCollision_y)\n'
   + log('"vegito W choca en "+I2S(R2I(s__GroundCollision_x))+" "+I2S(R2I(s__GroundCollision_y))') +
   'endif\n'
   'call SetUnitPositionLoc(G2V_Caster[81],G2V_Point[83])\n')
# la cadena no cruza el obstáculo: si la bola se paró, los 12 estallidos son donde quedó.
tr('set G2V_Point[83]=PolarProjectionBJ(G2V_Point[82],(100.*I2R(G2V_Int[80])),G2V_Angle[80])\n',
   'set G2V_Point[83]=PolarProjectionBJ(G2V_Point[82],(Vt_WAv*100.*I2R(G2V_Int[80])),G2V_Angle[80])\n')

# E Spirit Sword: la copia golpea al blanco 16 + 40 pasos y estalla en 300 alrededor de él.
tr("set G2V_Damage2[$B4]=(4*Gk_Fuerza(G2V_Caster[$B4]))\n",
   "set G2V_Damage2[$B4]=R2I(Gk_TDano(G2V_Caster[$B4],101,2500.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[$B4],GetEnumUnit(),I2R(G2V_Damage2[$B4]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      25, 101, 'G2V_Caster[$B4]', 'GetEnumUnit()', 'I2R(G2V_Damage2[$B4])')
# si el blanco desaparece (muerto y retirado), sigue en su último punto y no en el centro del mapa.
tr('set G2V_Point[$B5]=GetUnitLoc(G2V_Caster[$B5])\n',
   'set G2V_Point[$B5]=GetUnitLoc(G2V_Caster[$B5])\nset Vt_EX=GetLocationX(G2V_Point[$B5])\nset Vt_EY=GetLocationY(G2V_Point[$B5])\n')
tr('set G2V_Point[$B7]=GetUnitLoc(G2V_Caster[$B5])\n',
   'set G2V_Point[$B7]=GetUnitLoc(G2V_Caster[$B5])\n'
   '// v22d: blanco retirado: su último punto.\n'
   'if GetUnitTypeId(G2V_Caster[$B5])==0 then\n'
   'call MoveLocation(G2V_Point[$B7],Vt_EX,Vt_EY)\n'
   'else\n'
   'set Vt_EX=GetLocationX(G2V_Point[$B7])\n'
   'set Vt_EY=GetLocationY(G2V_Point[$B7])\n'
   'endif\n', 2)
# 2.1a creaba el primer golpe en G2V_Point[$B8], que aún no existe al lanzar: va en el blanco.
tr("call CreateNUnitsAtLoc(1,'h00T',GetOwningPlayer(G2V_Caster[$B4]),G2V_Point[$B8],AngleBetweenPoints(G2V_Point[$B4],G2V_Point[$B5]))\n"
   "call SetUnitTimeScalePercent(bj_lastCreatedUnit,50.)\n",
   "call CreateNUnitsAtLoc(1,'h00T',GetOwningPlayer(G2V_Caster[$B4]),G2V_Point[$B5],AngleBetweenPoints(G2V_Point[$B4],G2V_Point[$B5]))\n"
   "call SetUnitTimeScalePercent(bj_lastCreatedUnit,50.)\n")

# R Final Kamehameha: la cabeza del rayo (G2V_Caster[4853]) avanza 70 cada 0,04 s y daña en 400 a cada enemigo una
# vez (Group2[81]); al acabar, 2.1a daba 3 x fuerza en 700: ahora el daño del tier con la regla de área.
tr("set G2V_Damage2[4850]=((400*GetUnitAbilityLevelSwapped('A0DS',G2V_Caster[4850]))+(R2I(3.)*Gk_Fuerza(G2V_Caster[4850])))\n",
   "set G2V_Damage2[4850]=R2I(Gk_TDano(G2V_Caster[4850],102,5800.))\nset Vt_RPara=false\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[4850],GetEnumUnit(),I2R(G2V_Damage2[4850]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      26, 102, 'G2V_Caster[4850]', 'GetEnumUnit()', 'I2R(G2V_Damage2[4850])')
tr('set G2V_Point[4858]=PolarProjectionBJ(G2V_Point[4857],70.,AngleBetweenPoints(G2V_Point[4850],G2V_Point[4851]))\n'
   'call SetUnitPositionLoc(G2V_Caster[4853],G2V_Point[4858])\n',
   'set G2V_Point[4858]=PolarProjectionBJ(G2V_Point[4857],70.,AngleBetweenPoints(G2V_Point[4850],G2V_Point[4851]))\n'
   '// v22d: la cabeza del rayo se para en árboles y precipicios hasta acabar su vida.\n'
   'if Vt_RPara then\n'
   'call MoveLocation(G2V_Point[4858],GetLocationX(G2V_Point[4857]),GetLocationY(G2V_Point[4857]))\n'
   'elseif s__GroundCollision_trace(GetLocationX(G2V_Point[4857]),GetLocationY(G2V_Point[4857]),GetLocationX(G2V_Point[4858]),'
   'GetLocationY(G2V_Point[4858]),24.,G2V_Caster[4853],GetOwningPlayer(G2V_Caster[4850]),false)!=0 then\n'
   'set Vt_RPara=true\n'
   'call MoveLocation(G2V_Point[4858],s__GroundCollision_x,s__GroundCollision_y)\n'
   + log('"vegito R choca en "+I2S(R2I(s__GroundCollision_x))+" "+I2S(R2I(s__GroundCollision_y))') +
   'endif\n'
   'call SetUnitPositionLoc(G2V_Caster[4853],G2V_Point[4858])\n')
# parado, no se apilan más trozos del rayo en el mismo punto.
tr('call CreateNUnitsAtLoc(1,G2V_Missile[30],GetOwningPlayer(G2V_Caster[4850]),G2V_Point[4857],AngleBetweenPoints(G2V_Point[4850],G2V_Point[4851]))\n',
   'if not Vt_RPara then\n'
   'call CreateNUnitsAtLoc(1,G2V_Missile[30],GetOwningPlayer(G2V_Caster[4850]),G2V_Point[4857],AngleBetweenPoints(G2V_Point[4850],G2V_Point[4851]))\n')
tr('call GroupAddUnit(G2V_Group2[80],bj_lastCreatedUnit)\n'
   'call SetUnitFlyHeight(bj_lastCreatedUnit,(GetUnitFlyHeight(G2V_Caster[4850])+100.),100000000.)\n'
   'set G2V_Group[4850]=',
   'call GroupAddUnit(G2V_Group2[80],bj_lastCreatedUnit)\n'
   'call SetUnitFlyHeight(bj_lastCreatedUnit,(GetUnitFlyHeight(G2V_Caster[4850])+100.),100000000.)\nendif\n'
   'set G2V_Group[4850]=')
tr('return(G2V_Int[4850]>=4)\n', 'return(G2V_Int[4850]>=4)and(not Vt_RPara)\n')
tr('set G2V_Group[4850]=GetUnitsInRangeOfLocMatching(700.,G2V_Point[4857],Condition(function G2F_SKTrail_vegito_Func018Func002002003))\n'
   'call ForGroupBJ(G2V_Group[4850],function G2F_SKTrail_vegito_Func018Func003A)\n'
   'call DestroyGroup(G2V_Group[4850])\n',
   '// v22d: estallido final en 700 con el daño del tier, una vez a cada enemigo que el rayo no tocó.\n'
   'call Fz_Area(G2V_Caster[4850],GetLocationX(G2V_Point[4857]),GetLocationY(G2V_Point[4857]),700.,'
   'Gk_TDano(G2V_Caster[4850],102,5800.),G2V_Group2[81],26,102)\n')
tr('function G2F_SKTrail_vegito_Func018Func003A takes nothing returns nothing\n'
   'call UnitDamageTargetBJ(G2V_Caster[4850],GetEnumUnit(),(3.*I2R(Gk_Fuerza(G2V_Caster[4850]))),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n'
   'endfunction\n', '')

# X Power Up (Saian_Vegito, A0HL en el cuerpo G2V_Caster[5710]; G2V_Int[5710] forma 1-3).
tr('return(GetSpellAbilityUnit()==G2V_Caster[5710])and(G2V_Bool[5710]==false)and(G2V_Int[5710]<3)\n',
   'return(Vt_XOk or GetSpellAbilityUnit()==G2V_Caster[5710])and(G2V_Bool[5710]==false)and(G2V_Int[5710]<3)\n')
for aura in ('BitchAura', 'SaianAura'):
    tr('call AddSpecialEffectLocBJ(G2V_Point[5710],"war3mapImported\\\\%s.mdx")\n' % aura,
       ('// v22d: las auras siguen a Vegito (lista de fallos repetidos, v22c).\n' if aura == 'BitchAura' else '')
       + 'call AddSpecialEffectTargetUnitBJ("origin",G2V_Caster[5710],"war3mapImported\\\\%s.mdx")\n' % aura)
tr('set G2V_Int[5712]=(G2V_Int[5712]+1)\nset G2V_Point[5710]=GetUnitLoc(G2V_Caster[5710])\n',
   'set G2V_Int[5712]=(G2V_Int[5712]+1)\n'
   '// v22d: la pieza de la carga sigue a Vegito (v22c en Vegeta).\n'
   'if G2V_Caster[5711]!=null then\n'
   'call SetUnitX(G2V_Caster[5711],GetUnitX(G2V_Caster[5710]))\n'
   'call SetUnitY(G2V_Caster[5711],GetUnitY(G2V_Caster[5710]))\n'
   'endif\n'
   'set G2V_Point[5710]=GetUnitLoc(G2V_Caster[5710])\n')
# la forma vuelve a la base por Frm_Reloj (Frm_DURA), no a los 50 s propios de 2.1a.
tr('return(G2V_Int[5713]>=50)\n', 'return Frm_Corte\n')

# Afterimage (pasiva 104): G2V_Caster[$579] es el atacante; Vegito aparece detrás de él y golpea en 250.
tr("set G2V_Damage2[$578]=(((100*GetUnitAbilityLevelSwapped('A0HN',G2V_Caster[5710]))+(2*Gk_Fuerza(G2V_Caster[5710])))/3)\n",
   "set G2V_Damage2[$578]=R2I(Gk_TDano(G2V_Caster[5710],104,1500.))\n")
tr("set G2V_HeatDome[6]=(1*Gk_Fuerza(G2V_Caster[5710]))\n",
   "set G2V_HeatDome[6]=R2I(Gk_TDano(G2V_Caster[5710],104,500.))\n")
golpe('call UnitDamageTargetBJ(G2V_Caster[5710],GetEnumUnit(),I2R(G2V_Damage2[$578]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      27, 104, 'G2V_Caster[5710]', 'GetEnumUnit()', 'I2R(G2V_Damage2[$578])')
golpe('call UnitDamageTargetBJ(G2V_Caster[5710],GetEnumUnit(),I2R(G2V_HeatDome[6]),ATTACK_TYPE_CHAOS,DAMAGE_TYPE_NORMAL)',
      27, 104, 'G2V_Caster[5710]', 'GetEnumUnit()', 'I2R(G2V_HeatDome[6])')
# 2.1a dejaba aquí la imagen de otra técnica (G2V_Caster[4960]): la imagen es de Vegito, donde estaba.
tr("call CreateNUnitsAtLocFacingLocBJ(1,'h03W',GetOwningPlayer(G2V_Caster[4960]),G2V_Point[4962],G2V_Point[4961])\n",
   "call CreateNUnitsAtLocFacingLocBJ(1,'h03W',GetOwningPlayer(G2V_Caster[5710]),G2V_Point[$578],G2V_Point[$579])\n"
   "call UnitApplyTimedLifeBJ(1.5,'BTLF',bj_lastCreatedUnit)\n")

for malo in ('Gk_Fuerza', 'GetUnitAbilityLevelSwapped', 'SetUnitUserData', 'CinematicFade', '[4960]', '[4961]', '[4962]'):
    assert malo not in func, malo
assert 'call Don_Motor(' not in func.replace('call Don_Motor(G2T_slider,.04)', '').replace('call Don_Motor(G2T_Homing,.04)', ''), \
    'sólo slider y Homing van con motor'

VT = '''// v22d: X de Vegito (Power Up de 2.1a): al acabar la carga se quitan la pieza, las auras y la sacudida de la carga.
function Vt_XFin takes nothing returns nothing
    local unit b = G2V_Caster[5710]
    call DestroyEffect(G2V_Effect[5710])
    call DestroyEffect(G2V_Effect[5711])
    set G2V_Effect[5710] = null
    set G2V_Effect[5711] = null
    if G2V_Caster[5711] != null then
        call RemoveUnit(G2V_Caster[5711])
        set G2V_Caster[5711] = null
    endif
''' + ('''    set Cop_Log = "vegito X temblor fuera " + I2S(Gk_SacudeFinX())
    call ExecuteFunc("Cop_Anotar")
''' if prueba else '''    call Gk_SacudeFinX()
''') + '''    if b != null and UnitAlive(b) and not G2V_Bool[5710] then
''' + ('''        set Cop_Log = "vegito forma " + I2S(G2V_Int[5710]) + " por X"
        call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''        if G2V_Int[5710] == 2 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "|cffffcc00¡Super Vegito!|r")
        elseif G2V_Int[5710] == 3 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "|cffffcc00¡Vegito al máximo!|r")
        endif
    endif
    call DestroyTimer(GetExpiredTimer())
    set b = null
endfunction

// v22d: X de Vegito: carga de 1 s y una forma más, hasta la tercera. La lanza el controlador (AVt5), como Ve_SubirX.
function Vt_SubirX takes nothing returns nothing
    local integer this = s__RapidPair_fromController(GetTriggerUnit())
    local unit b = G2V_Caster[5710]
    local player p = GetTriggerPlayer()
    if b == null or this == 0 or s__RapidPair_actor[this] != b or not UnitAlive(b) then
        set b = null
        return
    endif
    if G2V_Int[5710] < 1 then
        set G2V_Int[5710] = 1
    endif
    if G2V_Bool[5710] then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya se está transformando.")
    elseif G2V_Int[5710] >= 3 then
        call DisplayTimedTextToPlayer(p, 0., 0., 2., "Ya está en su forma máxima.")
    else
        set Vt_XOk = true
        call G2F_Saian_Vegito_Actions()
        set Vt_XOk = false
        call TimerStart(CreateTimer(), 1.2, false, function Vt_XFin)
    endif
    set b = null
endfunction

// v22d: Afterimage (2.1a no le daba evento). Al recibir un ataque de un enemigo a 300 o menos, si la tiene aprendida y
// han pasado 4 s, Vegito aparece detrás del atacante y golpea en 250 (G2F_Afterimage_Actions).
function Vt_AfterListo takes nothing returns nothing
    set Vt_AfterCd = false
    call DestroyTimer(GetExpiredTimer())
endfunction

function Vt_AfterAtaque takes nothing returns nothing
    local unit b = G2V_Caster[5710]
    local unit a = GetAttacker()
    local player pl
    local integer p
    if b != null and GetTriggerUnit() == b and a != null and not Vt_AfterCd and G2V_Caster[$579] == null then
        set pl = GetOwningPlayer(b)
        set p = GetPlayerId(pl)
        if UnitAlive(b) and not IsUnitPaused(b) and not G2V_Bool[5710] and Tec_Niv[p * 100 + 104] > 0 and UnitAlive(a) and IsUnitEnemy(a, pl) and not IsUnitType(a, UNIT_TYPE_STRUCTURE) and IsUnitInRangeXY(a, GetUnitX(b), GetUnitY(b), 300.) then
            set Vt_AfterCd = true
            call TimerStart(CreateTimer(), 4., false, function Vt_AfterListo)
            set G2V_Caster[$579] = a
''' + ('''            set Cop_Log = "vegito afterimage"
            call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''            call G2F_Afterimage_Actions()
        endif
        set pl = null
    endif
    set b = null
    set a = null
endfunction

function Vt_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ATTACKED)
    call TriggerAddAction(t, function Vt_AfterAtaque)
    set t = null
endfunction
'''

# ---------------------------------------------------------------- globales y bloque de Vegito
cambia('real array Fz_Bono\n', 'real array Fz_Bono\n' + glob
       + 'boolean Vt_WPara=false\nreal Vt_WAv=1.\nboolean Vt_RPara=false\nboolean Vt_XOk=false\nreal Vt_EX=0.\nreal Vt_EY=0.\n'
       + 'boolean Vt_AfterCd=false\ninteger Frm_VtNiv=1\nreal Frm_VtFin=0.\n')
cambia('// ==== Trunks de 1.8c (sin uso desde v21s salvo Tr_Stat: su init ya no se llama) ====\n',
       '// ==== v22d: Vegito de Battle Stadium D.O.N 2.1a (trasplantado; ver scripts/v22d.py) ====\n' + func + VT
       + '// ==== Trunks de 1.8c (sin uso desde v21s salvo Tr_Stat: su init ya no se llama) ====\n')

# ---------------------------------------------------------------- formas: reloj, muertes y nivel
cambia('''    set b = null
endfunction

function Tec_Vigila takes nothing returns nothing
''', '''    // v22d: Vegito (base, Super, máxima).
    set b = G2V_Caster[5710]
    if b != null then
        if IMaxBJ(1, G2V_Int[5710]) != Frm_VtNiv then
            set Frm_VtNiv = IMaxBJ(1, G2V_Int[5710])
            set Frm_VtFin = now + Frm_DURA
        elseif Frm_VtNiv > 1 and not G2V_Bool[5710] and now >= Frm_VtFin then
            set Frm_Corte = true
            call G2F_Saian_Vegito3_Actions()
            set Frm_Corte = false
            call DisableTrigger(G2T_Saian_Vegito3)
            set Frm_VtNiv = 1
            call DisplayTimedTextToPlayer(GetOwningPlayer(b), 0., 0., 3., "Vegito vuelve a su forma normal.")
''' + ('''            call Dia_Anotar("forma vegito fin")
''' if prueba else '') + '''        endif
    endif
    set b = null
endfunction

function Tec_Vigila takes nothing returns nothing
''')
cambia('''                call Frm_Aviso(k, "¡Super Saiyan Blue!")
            endif
        endif
''', '''                call Frm_Aviso(k, "¡Super Saiyan Blue!")
            endif
        endif
    elseif t == 'hVto' and h == G2V_Caster[5710] and not G2V_Bool[5710] then
        // v22d: formas de Vegito de 2.1a (base, Super, máxima) con su código, como Vegeta.
        if Frm_Llega(k, 50) then
            set n = 3
        elseif Frm_Llega(k, 25) then
            set n = 2
        endif
        if G2V_Int[5710] < 1 then
            set G2V_Int[5710] = 1
        endif
        if G2V_Int[5710] < n and n > Frm_Dado[k] then
            set G2V_Bool[5710] = true
            set G2V_Int[5717] = 1
            call ExecuteFunc("G2F_Saian_Vegito2_Actions")
            set Frm_Dado[k] = G2V_Int[5710]
''' + ('''            set Cop_Log = "vegito forma " + I2S(G2V_Int[5710]) + " por muertes"
            call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''            if G2V_Int[5710] == 2 then
                call Frm_Aviso(k, "¡Super Vegito!")
            elseif G2V_Int[5710] == 3 then
                call Frm_Aviso(k, "¡Vegito al máximo!")
            endif
        endif
''')
cambia('''            elseif h == G2V_Caster[5720] and GetUnitTypeId(h) == 'hVeg' then
                set n=G2V_Int[5720] - 1
''', '''            elseif h == G2V_Caster[5720] and GetUnitTypeId(h) == 'hVeg' then
                set n=G2V_Int[5720] - 1
            // v22d: Vegito 0-2.
            elseif h == G2V_Caster[5710] and GetUnitTypeId(h) == 'hVto' then
                set n=G2V_Int[5710] - 1
''')

# ---------------------------------------------------------------- selección, ficha, copias
cambia('''    call Pj_Fijar('hVeg', 7, 'hCpV', 'hMf8', 175. / 164., 'DT4V', 'hbi8', "Vegeta", 94, 5)
''', '''    call Pj_Fijar('hVeg', 7, 'hCpV', 'hMf8', 175. / 164., 'DT4V', 'hbi8', "Vegeta", 94, 5)
    // v22d: Vegito (2.1a), celda 8; cabeza a 164 en Stand, como Vegeta.
    call Pj_Fijar('hVto', 8, 'hCpW', 'hMf9', 175. / 164., 'DT4W', 'hbi9', "Vegito", 99, 6)
''')
cambia("        call s__UnitHitShape_register('hVeg' , 1.6 , 48.) // v22b: como h005\n",
       "        call s__UnitHitShape_register('hVeg' , 1.6 , 48.) // v22b: como h005\n"
       "        call s__UnitHitShape_register('hVto' , 1.6 , 48.) // v22d: como h005\n")
cambia("    call RemoveUnit(CreateUnit(Player(15), 'hCpV', -12000., 9000., 0.))\n",
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpV', -12000., 9000., 0.))\n"
       "    call RemoveUnit(CreateUnit(Player(15), 'hCpW', -12000., 9000., 0.))\n")
cambia("GetUnitTypeId(s__RapidPair_actor[this]) == 'hVeg')",
       "GetUnitTypeId(s__RapidPair_actor[this]) == 'hVeg' or GetUnitTypeId(s__RapidPair_actor[this]) == 'hVto')", 2)
cambia(" or a == 'A0K5' or a == 'A0HM'\n", " or a == 'A0K5' or a == 'A0HM' or a == 'A0HL'\n")
cambia('''    elseif a == 'A01F' then
        return 1500.
    endif
    return 0.
endfunction
''', '''    elseif a == 'A01F' then
        return 1500.
    // v22d: Vegito (aran de 2.1a; la E es a una unidad a 600).
    elseif a == 'A03E' then
        return 1500.
    elseif a == 'A033' then
        return 2500.
    elseif a == 'A03F' then
        return 600.
    elseif a == 'A0DS' then
        return 2500.
    endif
    return 0.
endfunction
''')
cambia("    elseif tb == 'hVeg' then\n        set tc = 'hCpV'\n    endif\n",
       "    elseif tb == 'hVeg' then\n        set tc = 'hCpV'\n    elseif tb == 'hVto' then\n        set tc = 'hCpW'\n    endif\n")
cambia("    elseif tc == 'hCpV' then\n        set Son_Foco[5] = c\n    else\n",
       "    elseif tc == 'hCpV' then\n        set Son_Foco[5] = c\n    elseif tc == 'hCpW' then\n        set Son_Foco[6] = c\n    else\n")
# la copia de Vegito lleva el aura de su forma (A0H4, por niveles); sólo Vegito: Trunks también usa A0H4.
cambia("    call Dcp_Pieza(b, c, 'A0JN')\n", "    call Dcp_Pieza(b, c, 'A0JN')\n    if GetUnitTypeId(b) == 'hVto' then\n"
       "        call Dcp_Pieza(b, c, 'A0H4')\n    endif\n")
cambia("    call UnitRemoveAbility(c, 'A0JN')\nendfunction\n",
       "    call UnitRemoveAbility(c, 'A0JN')\n    call UnitRemoveAbility(c, 'A0H4')\nendfunction\n")
if prueba:
    cambia("t == 'hCpU' or t == 'hCpV' or t == 'hGok'", "t == 'hCpU' or t == 'hCpV' or t == 'hCpW' or t == 'hGok'")
    cambia("or t == 'hKur' or t == 'hVeg' then\n", "or t == 'hKur' or t == 'hVeg' or t == 'hVto' then\n")
else:
    cambia("t == 'hCpU' or t == 'hCpV' then\n", "t == 'hCpU' or t == 'hCpV' or t == 'hCpW' then\n")
cambia('''    elseif t == 'hVeg' or t == 'hCpV' then
        return 5
    endif
''', '''    elseif t == 'hVeg' or t == 'hCpV' then
        return 5
    elseif t == 'hVto' or t == 'hCpW' then
        return 6
    endif
''')
cambia('5 Vegeta (v22b).', '5 Vegeta (v22b), 6 Vegito (v22d).')

# ---------------------------------------------------------------- D.O.N: cuerpo, botones, habilidades, init
cambia('''    if Don_Toca(p, 7) then
        return 'hVeg'
    endif
    return id
''', '''    if Don_Toca(p, 7) then
        return 'hVeg'
    endif
    if Don_Toca(p, 8) then
        return 'hVto'
    endif
    return id
''')
cambia("or t == 'hKur' or t == 'hVeg'\nendfunction\n", "or t == 'hKur' or t == 'hVeg' or t == 'hVto'\nendfunction\n")
cambia(" and id != 'hKur' and id != 'hVeg' then\n", " and id != 'hKur' and id != 'hVeg' and id != 'hVto' then\n")
cambia('''        call UnitAddAbility(Game_Ctrl[p], 'AVp5')
    endif
endfunction
''', '''        call UnitAddAbility(Game_Ctrl[p], 'AVp5')
    endif
    // v22d: Vegito (Q Banshee Blast, W Big Bang, E Spirit Sword, R Final Kamehameha, X Power Up).
    if id == 'hVto' then
        call UnitAddAbility(Game_Ctrl[p], 'AVt1')
        call UnitAddAbility(Game_Ctrl[p], 'AVt2')
        call UnitAddAbility(Game_Ctrl[p], 'AVt3')
        call UnitAddAbility(Game_Ctrl[p], 'AVt4')
        call UnitAddAbility(Game_Ctrl[p], 'AVt5')
    endif
endfunction
''')
ARMA = ''.join('''        call UnitAddAbility(b, '%s')
        call SetUnitAbilityLevel(b, '%s', %d)
        call UnitMakeAbilityPermanent(b, true, '%s')
''' % (a, a, n, a) for a, n in [('A03E', 4), ('A033', 4), ('A03F', 4), ('A0DS', 4), ('A0HL', 1)])
cambia('''        set G2V_Caster[5720]=b
        if G2V_Int[5720] < 1 then
            set G2V_Int[5720] = 1
        endif
    endif
    set b = null
endfunction
''', '''        set G2V_Caster[5720]=b
        if G2V_Int[5720] < 1 then
            set G2V_Int[5720] = 1
        endif
    endif
    if id == 'hVto' then
''' + ARMA + '''        set G2V_Caster[5710]=b
        if G2V_Int[5710] < 1 then
            set G2V_Int[5710] = 1
        endif
    endif
    set b = null
endfunction
''')
cambia('''    elseif a == 'A01F' then
        return G2V_FinalFlashCaster != null
    endif
    return false
''', '''    elseif a == 'A01F' then
        return G2V_FinalFlashCaster != null
    // v22d: Vegito (la Q, la E y la R son esperas en su acción: cuentan mientras tienen a quien lanza).
    elseif a == 'A03E' then
        return IsTriggerEnabled(G2T_Banshee2) or IsTriggerEnabled(G2T_Homing)
    elseif a == 'A033' then
        return G2V_Caster[80] != null
    elseif a == 'A03F' then
        return G2V_Caster[$B4] != null
    elseif a == 'A0DS' then
        return G2V_Caster[4850] != null
    endif
    return false
''')
cambia('''function Don_Init takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 7
''', '''function Don_Init takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 8
''')
BOTS = ''.join('''    set Don_BotId[Don_Bots] = '%s'
    set Don_BotReal[Don_Bots] = '%s'
    set Don_BotObj[Don_Bots] = %d
    set Don_BotOrden[Don_Bots] = "%s"
    call RegisterSpellEffectEvent('%s', function %s)
    set Don_Bots = Don_Bots + 1
''' % (b, r, o, n, b, f) for b, r, o, n, f in [
    ('AVt1', 'A03E', 2, 'clusterrockets', 'Don_Relevo'), ('AVt2', 'A033', 2, 'flamestrike', 'Don_Relevo'),
    ('AVt3', 'A03F', 1, 'entanglingroots', 'Don_Relevo'), ('AVt4', 'A0DS', 2, 'rainoffire', 'Don_Relevo'),
    ('AVt5', 'A0HL', 0, 'voodoo', 'Vt_SubirX')])
cambia("    call RegisterSpellEffectEvent('AVp5', function Ve_SubirX)\n    set Don_Bots = Don_Bots + 1\n",
       "    call RegisterSpellEffectEvent('AVp5', function Ve_SubirX)\n    set Don_Bots = Don_Bots + 1\n"
       '    // v22d: Vegito (X directa al cuerpo con Vt_SubirX; Afterimage con su propio disparador).\n'
       '    call ExecuteFunc("G2U_InitDON")\n    call Vt_Init()\n' + BOTS)
cambia('''    if StringLength(n) != 1 or k < 0 or k > 7 or (k == 0 and n != "0") then
        call Pj_Aviso(pl, "Uso: -pj N   0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto, 6 Kurama, 7 Vegeta")
''', '''    if StringLength(n) != 1 or k < 0 or k > 8 or (k == 0 and n != "0") then
        call Pj_Aviso(pl, "Uso: -pj N   0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto, 6 Kurama, 7 Vegeta, 8 Vegito")
''')
cambia('''    set i = 3
    loop
        exitwhen i > 7
        if Don_Dueno[i] == p then
''', '''    set i = 3
    loop
        exitwhen i > 8
        if Don_Dueno[i] == p then
''')
cambia("    set Hero_Icon[7] = 'DT4V'\n", "    set Hero_Icon[7] = 'DT4V'\n    // v22d: Vegito.\n    set Hero_Icon[8] = 'DT4W'\n")

# ---------------------------------------------------------------- libro: técnicas 99-104
TEC = [(99, 'AVt1', 'A03E', 4, '900.0', 'Q', 1, 'Banshee Blast', 'Técnica de D.O.N.', 'DK10'),
       (100, 'AVt2', 'A033', 4, '2000.0', 'W', 0, 'Big Bang', 'Técnica de D.O.N.', 'DK0Z'),
       (101, 'AVt3', 'A03F', 4, '2500.0', 'E', 0, 'Spirit Sword', 'Técnica de D.O.N.', 'DK0Y'),
       (102, 'AVt4', 'A0DS', 4, '5800.0', 'R', 0, 'Final Kamehameha', 'Técnica de D.O.N.', 'DK0X')]
filas = '    // v22d: Vegito (2.1a), con tiers salvo Power Up; Afterimage es pasiva con tiers (sin habilidad).\n'
for x, pu, re_, tope, t6, tec, ini, nom, des, tex in TEC:
    filas += (f"    set Tec_Puente[{x}] = '{pu}'\n    set Tec_Real[{x}] = '{re_}'\n    set Tec_Max[{x}] = 6\n"
              f"    set Tec_Tope[{x}] = {tope}\n    set Tec_T6[{x}] = {t6}\n"
              f'    set Tec_Tecla[{x}] = "{tec}"\n    set Tec_Ini[{x}] = {ini}\n    set Cua_Nom[{x}] = "{nom}"\n'
              f'    set Cua_Des[{x}] = "{des}"\n    set Cua_Tex[{x}] = \'{tex}\'\n')
filas += '''    set Tec_Puente[103] = 'AVt5'
    set Tec_Real[103] = 'A0HL'
    set Tec_Max[103] = 1
    set Tec_Tecla[103] = "X"
    set Tec_Ini[103] = 0
    set Cua_Nom[103] = "Power Up"
    set Cua_Des[103] = "Carga y sube una forma.|nTambién suben con las muertes."
    set Cua_Tex[103] = 'DK11'
    set Tec_Puente[104] = 0
    set Tec_Real[104] = 0
    set Tec_Max[104] = 6
    set Tec_Tope[104] = 0
    set Tec_T6[104] = 1500.0
    set Tec_Tecla[104] = ""
    set Tec_Ini[104] = 0
    set Cua_Nom[104] = "Afterimage"
    set Cua_Des[104] = "Pasiva: al recibir un golpe|naparece detrás y golpea (4 s)."
    set Cua_Tex[104] = 'DK12'
'''
cambia("    set Cua_Tex[98] = 'DK0W'\n", "    set Cua_Tex[98] = 'DK0W'\n" + filas)
cambia('''    return (x >= 40 and x < 78) or (x >= 89 and x < 99)
''', '''    // v22d: Vegito 99-104.
    return (x >= 40 and x < 78) or (x >= 89 and x < 105)
''')
# pasiva con tiers: "Pasiva." en lugar de la tecla.
cambia('''    elseif Tec_T6[x] > 0. then
        // v21m: técnica con tier: daño por enemigo del tier nuevo.
''', '''    elseif Tec_T6[x] > 0. and Tec_Tecla[x] == "" then
        // v22d: pasiva con tier (Afterimage de Vegito).
        return "Sube a " + Arm_TierTexto(n + 1) + ": " + I2S(R2I(Tec_T6[x] * Tec_Curva[n + 1])) + " de daño|npor enemigo. Pasiva."
    elseif Tec_T6[x] > 0. then
        // v21m: técnica con tier: daño por enemigo del tier nuevo.
''')

if prueba:
    cambia('''    elseif s >= 19 then
        // v22b: Vegeta (19 Q, 20 W, 21 E, 22 R).''', '''    elseif s >= 23 then
        // v22d: Vegito (23 Q, 24 W, 25 E, 26 R, 27 pasiva).
        set q = "vegito"
        set n = SubString("QWERP", s - 23, s - 22)
    elseif s >= 19 then
        // v22b: Vegeta (19 Q, 20 W, 21 E, 22 R).''')
    cambia('lat\\\\v22c-', 'lat\\\\v22d-', src.count('lat\\\\v22c-'))
    cambia('v22c-don.txt', 'v22d-don.txt', src.count('v22c-don.txt'))
    assert 'lat\\\\v22c-' not in src and 'v22c-don.txt' not in src, 'quedan registros v22c'

# ---------------------------------------------------------------- Q: explosión de los misiles (código de la base)
cambia("set G2V_Damage[$AA]=(((100*GetUnitAbilityLevelSwapped('A03E',G2V_Caster[$AA]))+(2*Gk_Fuerza(G2V_Caster[$AA])))/3)\n",
       "set G2V_Damage[$AA]=R2I(Gk_TDano(G2V_Caster[$AA],99,900.))\n")
if prueba:
    l = 'call UnitDamageTargetBJ(G2V_Caster[$AA],GetEnumUnit(),I2R(G2V_Damage[$AA]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n'
    cambia(l, l + 'call Gk_Suma(23,99,G2V_Caster[$AA],GetEnumUnit(),I2R(G2V_Damage[$AA]))\n')

# ---------------------------------------------------------------- libro con 105 técnicas: p*100 -> p*200
src, k = re.subn(r'Tec_(Niv|Listo)\[(\w+) ?\* ?100 ?\+', lambda m: m.group(0).replace('100', '200'), src)
assert k >= 25, k
assert not re.search(r'Tec_(Niv|Listo)\[[^\]]*\*\s*100', src), 'quedan índices p*100'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[5]).write_bytes(src.encode('latin-1'))
print('v22d', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas; sonidos 3D', nsf, '; p*200', k)
