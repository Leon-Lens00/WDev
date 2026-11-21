#!/usr/bin/env python3
"""v19b (18/11/2026): todas las habilidades del Tauren y de Cairne para probarlas de una vez (Leon: "implementa todas
para un test mas rapido probando todas").
- Puentes 'ANcl' de punto como 'ATb1' (alcance 90000, lanzamiento 0, 1 de maná); órdenes distintas dentro de cada
  libro (blizzard, flamestrike, impale, banish, polymorph, sleep): los dos libros nunca están en el mismo controlador.
- Tauren, libro 'ALTb' (rehecho): Q Embestida espiritual (ATb1, de v19a), W Tótem arrojado, E Lanzar roca,
  R Bombardeo (definitiva, 10 s), A Garra espiritual, S Rugido desafiante, D pasiva Disparo encantado.
  Corrige v19a: su 'ALTb' tenía spb3/spb4 = 1 con tres habilidades. Los iconos sin efecto ATa1/ATa2 salen del libro.
- Cairne, libro nuevo 'ALCb': Q Grieta ancestral, W Lanza ancestral, E Espíritu ancestral, R Estampida de los
  ancestros (definitiva, 12 s), A Tótem del trueno, S Marca ancestral, D pasiva Réplica, F pasiva Espíritus guardianes.
- w3u: 'hCp1' copia de Cairne (modelo y escala de 'h006') y 'hCp2' espíritu (SpiritWalker), como 'hCp0'.
Uso: objetos_v19b.py DIR_ENTRADA (w3a y w3u de v19a) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
Z = b'\0\0\0\0'
I = lambda v: struct.pack('<i', v)
R = lambda v: struct.pack('<f', v)
S = lambda v: v.encode('utf-8')
BTN = lambda n: S(f'ReplaceableTextures\\CommandButtons\\BTN{n}.blp')

b = (src / 'war3map.w3a').read_bytes()
version, tablas = parse_w3a(b)
assert encode_w3a(version, tablas) == b
usados = {r[1] for t in tablas for r in t}
assert b'ATb1' in usados and b'ALTb' in usados


def puente(rid, quien, nom, tecla, x, y, orden, icono, cd, desc):
    assert rid.encode() not in usados, rid
    tablas[1].append((b'ANcl', rid.encode(), [
        (b'anam', 3, 0, 0, S(f'{quien}: {nom}'), Z),
        (b'aher', 0, 0, 0, I(0), Z), (b'alev', 0, 0, 0, I(1), Z),
        (b'ahky', 3, 0, 0, tecla.encode(), Z),
        (b'aart', 3, 0, 0, BTN(icono), Z),
        (b'atp1', 3, 1, 0, S(f'{nom} (|cffffcc00{tecla}|r)'), Z),
        (b'aub1', 3, 1, 0, S(desc + ('' if not cd else f'|n|cff808080Recarga {cd} s.|r')), Z),
        (b'aran', 2, 1, 0, R(90000.), Z), (b'acdn', 2, 1, 0, R(float(cd)), Z), (b'amcs', 0, 1, 0, I(1), Z),
        (b'acas', 2, 1, 0, R(0.), Z),
        (b'Ncl1', 2, 1, 1, R(0.), Z), (b'Ncl2', 0, 1, 2, I(2), Z), (b'Ncl3', 0, 1, 3, I(1), Z),
        (b'Ncl4', 2, 1, 4, R(0.), Z), (b'Ncl5', 0, 1, 5, I(0), Z), (b'Ncl6', 3, 1, 6, orden.encode(), Z),
        (b'abpx', 0, 0, 0, I(x), Z), (b'abpy', 0, 0, 0, I(y), Z),
        (b'aeat', 3, 0, 0, b'', Z), (b'atat', 3, 0, 0, b'', Z), (b'acat', 3, 0, 0, b'', Z)]))
    usados.add(rid.encode())


def pasiva(rid, quien, nom, x, y, icono, desc):
    assert rid.encode() not in usados, rid
    tablas[1].append((b'ACev', rid.encode(), [
        (b'anam', 3, 0, 0, S(f'{quien}: {nom}'), Z),
        (b'aart', 3, 0, 0, BTN(icono), Z),
        (b'abpx', 0, 0, 0, I(x), Z), (b'abpy', 0, 0, 0, I(y), Z),
        (b'atp1', 3, 1, 0, S(f'{nom} (pasiva)'), Z),
        (b'aub1', 3, 1, 0, S(desc), Z),
        (b'Eev1', 2, 1, 1, R(0.), Z)]))
    usados.add(rid.encode())


C = 'La hace una copia; el héroe sigue libre.'
puente('ATb2', 'Tauren', 'Tótem arrojado', 'W', 1, 0, 'flamestrike', 'StasisTrap', 0,
       f'Lanza un tótem al punto (hasta 900): 250 en 200 y aturde 1 s. Se queda 4 s ralentizando un 50 % a 300 y luego '
       f'vuelve al Tauren dañando 200 a su paso. {C}')
puente('ATb3', 'Tauren', 'Lanzar roca', 'E', 2, 0, 'impale', 'GolemStormBolt', 0,
       f'Lanza una roca en arco al punto (hasta 1000): 300 en 180, y rebota 3 veces hacia delante (cada bote 80 % del '
       f'daño). {C}')
puente('ATb4', 'Tauren', 'Bombardeo', 'R', 3, 0, 'banish', 'Earthquake', 10,
       f'Definitiva. La copia se planta en el punto (hasta 900) y durante 8 s lanza rocas en espiral alrededor: 180 en '
       f'150 cada una. {C}')
puente('ATb5', 'Tauren', 'Garra espiritual', 'A', 0, 1, 'polymorph', 'SpiritLink', 0,
       'Un espíritu aparece en el punto (300 a 1000) y durante 2,5 s arrastra hacia él a los enemigos a 450; al irse '
       'golpea 250 en 250. Nunca los acerca al Tauren.')
puente('ATb6', 'Tauren', 'Rugido desafiante', 'S', 1, 1, 'sleep', 'BattleRoar', 0,
       f'La copia aparece en el punto (hasta 700) y ruge: los enemigos a 700 van hacia ella durante 4 s. Luego estalla: '
       f'500 en 350 y aturde 1 s. {C}')
pasiva('ATbP', 'Tauren', 'Disparo encantado', 2, 1, 'Command',
       'Cada 4.º impacto de tus disparos hace el triple de daño y suelta una onda que daña lo mismo que el disparo a 200 '
       'alrededor.')
puente('ACb1', 'Cairne', 'Grieta ancestral', 'Q', 0, 0, 'blizzard', 'Impale', 0,
       f'Abre una grieta de 900 hacia el punto. A los 1,5 s se parte: 250 más el 6 % de la vida máxima (hasta +1500) a '
       f'150 de la línea, junta a los enemigos sobre ella y los ralentiza un 50 % 2 s. {C}')
puente('ACb2', 'Cairne', 'Lanza ancestral', 'W', 1, 0, 'flamestrike', 'SpiritOfVengeance', 0,
       f'Lanza espiritual de 1100 que atraviesa: 250 a cada enemigo. Al final se parte en 3 lanzas de 500 (150). {C}')
puente('ACb3', 'Cairne', 'Espíritu ancestral', 'E', 2, 0, 'impale', 'AncestralSpirit', 0,
       'La copia sale hasta el punto (400 a 1000) dañando 150 al pasar, pisa (350 en 300) y vuelve a Cairne dañando 100; '
       'al llegar le cura 15 por enemigo tocado (hasta 300).')
puente('ACb4', 'Cairne', 'Estampida de los ancestros', 'R', 3, 0, 'banish', 'Stampede', 12,
       'Definitiva. 14 kodos espirituales salen detrás de Cairne y corren 1600 hacia el punto en un frente de 700: 180 '
       'a cada enemigo y lo apartan.')
puente('ACb5', 'Cairne', 'Tótem del trueno', 'A', 0, 1, 'polymorph', 'LightningShield', 0,
       f'Lanza un tótem al punto (hasta 900): 150 en 200. Dura 6 s: atrae a los enemigos a 600 y cada 0,5 s lanza rayos '
       f'a 3 de ellos (150). {C}')
puente('ACb6', 'Cairne', 'Marca ancestral', 'S', 1, 1, 'sleep', 'Doom', 0,
       'Marca al enemigo con más vida a 400 del punto. A los 3 s explota (500 en 300) y marca a 3 cercanos, que '
       'explotan a los 1,5 s (250 en 250) sin contagiar más.')
pasiva('ACbP', 'Cairne', 'Réplica', 2, 1, 'WarStomp',
       'Cada habilidad, al golpear, aturde 1 s a los enemigos a 250 de Cairne y 0,75 s a los de 250 del golpe.')
pasiva('ACbQ', 'Cairne', 'Espíritus guardianes', 3, 1, 'Reincarnation',
       'Al reaparecer, y una vez por ronda al bajar del 25 % de vida, salen 3 copias de Cairne en tres direcciones: '
       '250 a cada enemigo que tocan y lo apartan.')

# Libro del Tauren rehecho; libro nuevo de Cairne.
LIBROS = [('ALTb', 'Tauren', ['ATb1', 'ATb2', 'ATb3', 'ATb4', 'ATb5', 'ATb6', 'ATbP']),
          ('ALCb', 'Cairne', ['ACb1', 'ACb2', 'ACb3', 'ACb4', 'ACb5', 'ACb6', 'ACbP', 'ACbQ'])]
tablas[1] = [r for r in tablas[1] if r[1] != b'ALTb']
for rid, quien, lista in LIBROS:
    n = len(lista)
    tablas[1].append((b'Aspb', rid.encode(), [
        (b'anam', 3, 0, 0, S(f'{quien}: libro de habilidades'), Z),
        (b'aart', 3, 0, 0, BTN('SpellBookBLS'), Z),
        (b'abpx', 0, 0, 0, I(3), Z), (b'abpy', 0, 0, 0, I(2), Z),
        (b'ahky', 3, 0, 0, b'V', Z),
        (b'atp1', 3, 1, 0, S('Habilidades especiales (|cffffcc00V|r)'), Z),
        (b'aub1', 3, 1, 0, S(f'Abre las habilidades especiales de {quien}.'), Z),
        (b'spb1', 3, 1, 1, S(','.join(lista)), Z),
        (b'spb2', 0, 1, 2, I(0), Z), (b'spb3', 0, 1, 3, I(n), Z), (b'spb4', 0, 1, 4, I(n), Z),
        (b'spb5', 3, 1, 5, b'spellbook', Z)]))
salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida
(dst / 'war3map.w3a').write_bytes(salida)

# --- w3u ---
b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
ids = {r[1] for t in tablas for r in t}
assert b'hCp0' in ids and b'hCp1' not in ids and b'hCp2' not in ids
cairne = {m[0]: m for m in next(r for r in tablas[1] if r[1] == b'h006')[2]}
assert cairne[b'umdl'][2] == b'units\\orc\\HeroTaurenChieftainCIN\\HeroTaurenChieftainCIN.mdl'
F = lambda k, t, v: (k, t, v, Z)


def copia(rid, nom, mdl, esc):
    tablas[1].append((b'otau', rid, [
        F(b'unam', 3, S(nom)), F(b'umdl', 3, mdl), F(b'usca', 1, esc),
        F(b'uabi', 3, b'Aloc,Avul'),
        F(b'ucol', 2, R(0.)), F(b'ufoo', 0, I(0)), F(b'uaen', 0, I(0)),
        F(b'ubba', 0, I(0)), F(b'ubdi', 0, I(0)), F(b'ubsi', 0, I(0)),
        F(b'uhom', 0, I(1)), F(b'usid', 0, I(200)), F(b'usin', 0, I(200)),
        F(b'upoi', 0, I(0)), F(b'umvr', 2, R(3.))]))


copia(b'hCp1', 'Copia espiritual (Cairne)', cairne[b'umdl'][2], cairne[b'usca'][2] if b'usca' in cairne else R(1.))
copia(b'hCp2', 'Espíritu de la garra', b'units\\orc\\SpiritWalker\\SpiritWalker.mdl', R(1.2))
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3a v19b: ATb2-6, ATbP, ALTb, ACb1-6, ACbP, ACbQ, ALCb; w3u: hCp1, hCp2')
