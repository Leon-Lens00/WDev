#!/usr/bin/env python3
"""v14l: tipos de daño y de armadura (05/11/2026).

Pedido de Leon: que cada enemigo resista ciertas armas y obligue a elegir la adecuada. Los 7 tipos de ataque del motor
se renombran y la tabla de daño (DamageBonus*, en war3mapMisc.txt) es propia; ver objetos_v14l.py para las armaduras.

| Daño (nuestro) | Ataque del motor  | JASS                |
| Perforante     | Pierce            | ATTACK_TYPE_PIERCE  |
| Impacto        | Normal            | ATTACK_TYPE_MELEE   |
| Antiblindaje   | Magic             | ATTACK_TYPE_MAGIC   |
| Explosivo      | Siege             | ATTACK_TYPE_SIEGE   |
| Energía        | Hero              | ATTACK_TYPE_HERO    |
| Habilidad      | Spells            | ATTACK_TYPE_NORMAL  |
| Estándar       | Chaos             | ATTACK_TYPE_CHAOS   |

(La ranura Chaos se llama Estándar mientras se use así; Verdadero queda para después.)

Decisión de Leon (05/11/2026), tras medir la tabla: de momento todas las armas hacen Estándar (100 % contra toda
armadura) y las diferencias entre enemigos las pone su defensa (udef): las tres llamadas a UnitDamageTarget de las
armas (impacto, área y golpe) pasan a DAMAGE_TYPE_NORMAL (Dano_TipoArma), que sí aplica la defensa (medido en
v14l-dano: 6 % por punto); con DAMAGE_TYPE_MAGIC sólo contaba la tabla. Con NORMAL las unidades etéreas no reciben daño
de las armas (no hay ninguna en las oleadas). Los demás tipos, la tabla y las armaduras quedan listos para usarlos más
adelante: basta con cambiar CATEGORIA.
La tienda muestra bajo la lista de tiers el tipo y su descripción, y si lo tiene, contra qué es eficaz o débil (3
texttags más: la tienda crea 38 al abrir).
Uso: v14l.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base
from objetos_v14g import TIPOS as OLEADA, escalada, formas

ELITE = 1.8  # escala de las élites sobre su modelo (antes 2,1)


def once(s, old, new):
    # El script está en UTF-8 y se lee como latin-1: los acentos de lo insertado también.
    return base.once(s, old.encode('utf-8').decode('latin-1'), new.encode('utf-8').decode('latin-1'))


# Tipo de daño por categoría (0 Pistolas ... 6 Explosivos), índices de TIPOS.
CATEGORIA = [6, 6, 6, 6, 6, 6, 6]  # Más adelante: [0, 0, 1, 2, 1, 0, 3] (Perforante, Impacto, Antiblindaje, Explosivo).
# (nombre, color, ataque JASS, descripción, eficaz contra, débil contra), según la tabla de objetos_v14l.py.
TIPOS = [
    ('Perforante', 'ffe0b040', 'ATTACK_TYPE_PIERCE', 'Balas ligeras, flechas y filos: desgarran la carne.',
     'Orgánica y Ágil', 'Caparazón y Pétrea'),
    ('Impacto', 'ffff9030', 'ATTACK_TYPE_MELEE', 'Munición pesada y golpes que abollan el metal.',
     'Acorazada', 'Pétrea y Escudo'),
    ('Antiblindaje', 'ffff4848', 'ATTACK_TYPE_MAGIC', 'Puntas duras que atraviesan las corazas gruesas.',
     'Caparazón, Pétrea y Colosal', 'Ágil y Orgánica'),
    ('Explosivo', 'ffff7020', 'ATTACK_TYPE_SIEGE', 'Metralla y onda expansiva: derriban la piedra.',
     'Pétrea y Orgánica', 'Escudo, Acorazada y Colosal'),
    ('Energía', 'ff40e0ff', 'ATTACK_TYPE_HERO', 'Láser y plasma que deshacen los escudos.',
     'Escudo', 'Caparazón y Pétrea'),
    ('Habilidad', 'ffb070ff', 'ATTACK_TYPE_NORMAL', 'Poderes del héroe: daño parejo.',
     '', 'Colosal'),
    ('Estándar', 'ffe8e8e8', 'ATTACK_TYPE_CHAOS', 'Igual contra toda armadura; sólo lo reduce la defensa.', '', ''),
]

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'real array Bala_Dano\n', 'real array Bala_Dano\n// v14l: tipo de daño (0..6, Dano_Ataque) por arma y por bala.\n'
         'integer array Arm_Tipo\ninteger array Bala_Tipo\nstring array Dano_Nombre\nstring array Dano_Desc\n'
         'string array Dano_Eficaz\nstring array Dano_Debil\n'
         '// v14l: tipo de daño de las armas; NORMAL aplica la defensa (udef) del enemigo.\ndamagetype Dano_TipoArma= DAMAGE_TYPE_NORMAL\n')

datos = ''.join(f'    set Dano_Nombre[{k}] = "|c{c}{n}|r"\n    set Dano_Desc[{k}] = "{d}"\n'
                f'    set Dano_Eficaz[{k}] = "{e}"\n    set Dano_Debil[{k}] = "{b}"\n'
                for k, (n, c, _, d, e, b) in enumerate(TIPOS))
datos += ''.join(f'    set Arm_Tipo[{c * 3 + t}] = {k}\n' for c, k in enumerate(CATEGORIA) for t in range(3))
s = once(s, '    set Shop_Frase[0] = ', datos + '    set Shop_Frase[0] = ')

ataque = '// v14l: tipo de daño (Arm_Tipo) a tipo de ataque del motor; la tabla propia está en war3mapMisc.txt.\n' \
         'function Dano_Ataque takes integer k returns attacktype\n'
for k, t in enumerate(TIPOS[:-1]):
    ataque += f'    {"if" if k == 0 else "elseif"} k == {k} then\n        return {t[2]}\n'
ataque += f'    endif\n    return {TIPOS[-1][2]}\nendfunction\n\n'
s = once(s, 'function Arm_W takes integer p returns integer\n', ataque + 'function Arm_W takes integer p returns integer\n')

s = once(s, '        call UnitDamageTarget(caster, target, d, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)\n',
         '        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)\n')
s = once(s, '                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)\n',
         '                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)\n')
s = once(s, '                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)\n',
         '                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, Dano_Ataque(Arm_Tipo[w]), Dano_TipoArma, null)\n')
s = once(s, '        set Bala_Dano[m]=Arm_Dano[w]\n', '        set Bala_Dano[m]=Arm_Dano[w]\n        set Bala_Tipo[m]=Arm_Tipo[w]\n')

# Tres texttags más para la tienda (Shop_T[21..23]).
s = once(s, '''    loop
        exitwhen i > 20
        set Shop_T[i] = Shop_Tag(960, 400, 0.02, 0, "")''', '''    loop
        exitwhen i > 23
        set Shop_T[i] = Shop_Tag(960, 400, 0.02, 0, "")''')
s = once(s, '''    loop
        exitwhen i > 20
        set Shop_T[i] = null''', '''    loop
        exitwhen i > 23
        set Shop_T[i] = null''')
s = once(s, '// Sólo en el cliente de quien abre la tienda: 35 texttags', '// Sólo en el cliente de quien abre la tienda: 38 texttags')
s = once(s, '    call Shop_Izq(p, Shop_T[11], Arm_Rasgo[w], 950, 684, 0.020)\n', '''    call Shop_Izq(p, Shop_T[11], Arm_Rasgo[w], 950, 684, 0.020)
    // v14l: tipo de daño en el hueco entre la lista de tiers y la imagen del arma. Shop_Centro cuenta los 12
    // caracteres del color (|cAARRGGBB y |r) como texto: el centro va 12 × 0,019 × 470 / 2 = 53,6 px a la derecha.
    set k = Arm_Tipo[w]
    call Shop_Centro(p, Shop_T[21], "Daño " + Dano_Nombre[k] + ": " + Dano_Desc[k], 998.6, 330, 0.019)
    if Dano_Eficaz[k] == "" then
        set s = ""
    else
        set s = "|cff60ff60Eficaz|r contra " + Dano_Eficaz[k]
    endif
    call Shop_Centro(p, Shop_T[22], s, 998.6, 380, 0.019)
    if Dano_Debil[k] == "" then
        set s = ""
    else
        set s = "|cffff6060Débil|r contra " + Dano_Debil[k]
    endif
    call Shop_Centro(p, Shop_T[23], s, 998.6, 420, 0.019)
''')
# Élites (Leon, 05/11/2026): escala × 1,8 sobre su modelo (antes × 2,1, objetos_v14h.py) y vida 0,40 de la del jefe de
# la ronda (antes 0,70); base 320 en el w3u (objetos_v14l.py), 0,40 × 800 de la ronda 1. UnitHitShape con la escala
# nueva y la barra a 80 sobre la cabeza (110 con × 2,1: 110 × 0,8 / 1,1).
forma = formas(s)
for k, t in enumerate(OLEADA):
    viejo = escalada(forma[t], 2.1)
    nuevo = escalada(forma[t], ELITE)
    s = once(s, f"call s__UnitHitShape_register('ne0{k}' , {viejo[0]} , {viejo[1]})",
             f"call s__UnitHitShape_register('ne0{k}' , {nuevo[0]} , {nuevo[1]})")
s = once(s, "call SaveReal(Barras_HT, 1, 'ne00' + k, 110.)", "call SaveReal(Barras_HT, 1, 'ne00' + k, 80.)")
s = once(s, '// Vida de élite 0,70 × 800', '// Vida de élite 0,40 × 800')
s = once(s, 'base 360 del w3u', 'base 320 del w3u')
s = once(s, 'set n=R2I(( 0.70 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) - 360. ) / 10. + 0.5)',
         'set n=R2I(( 0.40 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) - 320. ) / 10. + 0.5)')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
