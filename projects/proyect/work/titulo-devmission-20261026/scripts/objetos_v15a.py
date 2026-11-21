#!/usr/bin/env python3
"""Objetos de v15a (05/11/2026): las 4 armas fijas en Q W E R y Refrescar sobrecarga en F.

v15a.py cambia en el script las categorías 2 y 4 (Rifles y Escopetas): la Escopeta pasa a la categoría 2 y usa Aw02
(E); los Rifles, ocultos, quedan en Aw04. Francotirador (Aw03) pasa de S a R. La recarga (Aw08) pasa a ser Refrescar
sobrecarga en F, en la misma casilla (1,0). Disparo y Dash cambian sólo su texto.
w3b/imp: la textura HudCarga (DS0F), relleno blanco de la barra de sobrecarga que el script tiñe de verde a rojo.

Uso: objetos_v15a.py DIR_ENTRADA DIR_SALIDA (war3map.w3a, war3map.w3b y war3map.imp)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
import w3b_modos

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)

# (anam, tecla, icono, [(nombre, rasgo) por tier]) por habilidad; los rasgos son los de v15a.py.
ARMAS = {
    b'Aw00': ('Pistola', 'Q', 'war3mapImported\\BTNArma0.blp',
              [('Colt Paterson', 'Básica, poca sobrecarga'), ('Borchardt C-93', 'Más daño'), ('M1911', 'Atraviesa 1')]),
    b'Aw01': ('Subfusil', 'W', 'war3mapImported\\BTNArma1.blp',
              [('MP18', 'Cadencia alta'), ('Thompson M1928', 'Cadencia muy alta'),
               ('MP40', 'Menos dispersión, crítico 15%')]),
    b'Aw02': ('Escopeta', 'E', 'war3mapImported\\BTNArma4.blp',
              [('Trabuco', 'Cinco perdigones, corta distancia'), ('Winchester 1887', 'Seis perdigones'),
               ('Browning Auto-5', 'Seis perdigones, cono cerrado')]),
    b'Aw03': ('Francotirador', 'R', 'war3mapImported\\BTNArma3.blp',
              [('Whitworth', 'Sin dispersión'), ('Mosin-Nagant', 'Atraviesa 2'), ('Kar98k', 'Atraviesa 2, crítico 25%')]),
    b'Aw04': ('Rifles', 'Z', 'war3mapImported\\BTNArma2.blp',
              [('Fedorov Avtomat', 'Equilibrado'), ('StG 44', 'Atraviesa 1'), ('AK-47', 'Atraviesa 1, crítico 15%')]),
}
TEXTOS = {
    b'Arp1': {(b'aub1', 1): 'Dispara el arma activa durante 1,5 s hacia el punto elegido, en movimiento. Cada disparo '
                            'suma sobrecarga; al llenarse, el arma se bloquea hasta bajar del 60 %.'},
    b'Ard1': {(b'aub1', 1): 'Avanza 450 en 0.375 s hacia el punto elegido. Cancela el disparo y el refresco de sobrecarga.'},
    b'Aw08': {(b'anam', 0): 'Refrescar sobrecarga', (b'ahky', 0): 'F',
              (b'aart', 0): 'ReplaceableTextures\\CommandButtons\\BTNManaRecharge.blp',
              (b'atp1', 1): 'Refrescar sobrecarga (|cffffcc00F|r)',
              (b'aub1', 1): 'Gasta un kit y en 2 s deja la sobrecarga a 0. El dash y disparar lo cancelan sin gastar el '
                            'kit. Los kits se compran en la tienda.'},
}
for rid, (nombre, tecla, icono, tiers) in ARMAS.items():
    cambios = {(b'anam', 0): nombre, (b'ahky', 0): tecla, (b'aart', 0): icono}
    for t, (arma, rasgo) in enumerate(tiers, 1):
        cambios[(b'atp1', t)] = f'{arma} T{t} (|cffffcc00{tecla}|r)'
        cambios[(b'aub1', t)] = f'Activa esta arma. {rasgo}.'
    TEXTOS[rid] = cambios

version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
hechos = set()
for i, f in enumerate(tablas[1]):
    if f[1] not in TEXTOS:
        continue
    cambios, vistos, mods = TEXTOS[f[1]], set(), []
    for m in f[2]:
        clave = (m[0], m[2])
        if clave in cambios:
            assert m[1] == 3, clave
            m = (m[0], m[1], m[2], m[3], cambios[clave].encode('utf-8'), m[5])
            vistos.add(clave)
        mods.append(m)
    assert vistos == set(cambios), (f[1], set(cambios) - vistos)
    tablas[1][i] = (f[0], f[1], mods)
    hechos.add(f[1])
assert hechos == set(TEXTOS), set(TEXTOS) - hechos
(dst / 'war3map.w3a').write_bytes(encode_w3a(version, tablas))
w3b_modos.add([('DS0F', 'HudCarga')], ['war3mapImported\\HudCarga.blp'],
              ['', src / 'war3map.w3b', dst / 'war3map.w3b', src / 'war3map.imp', dst / 'war3map.imp'])
