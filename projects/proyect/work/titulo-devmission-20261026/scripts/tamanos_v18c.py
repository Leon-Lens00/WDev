"""v18c (15/11/2026): tamaños de élites y jefes. Leon: élites más grandes y jefes casi del tamaño del jefe 10, para que
se note la diferencia común < élite < jefe.

Medidas: extensión de la secuencia Stand de cada MDX del juego (war3.mpq / War3x.mpq de 1.27b) por su modelScale de
unitUI.slk, es decir, el tamaño del común en el juego. 'tam' = mayor de alto y ancho (las tortugas son anchas y
bajas). Son extensiones guardadas en el modelo, no la pose medida: sirven para comparar tipos, no al píxel.
Regla:
- Jefe 10 ('nj0A', Dragon Turtle ×2,7) se queda igual: 353,1 × 2,7 = 953 de tamaño.
- Jefes 2-9: 90 % de eso (858) → factor = 858 / tam del común.
- Élites: factor 2,5, salvo que pasen del 60 % del jefe 10 (572); nunca por debajo de 1,8 (lo de antes).
"""
TIPOS = ['nmcf', 'nlpr', 'ntrh', 'nmtw', 'nmsn', 'nlds', 'nmmu', 'nnsw', 'ntrg', 'ntrd']
ESCALA = {'nmcf': .8, 'nlpr': .55, 'ntrh': .4, 'nmtw': 1., 'nmsn': 1.1, 'nlds': .8, 'nmmu': 2., 'nnsw': 1., 'ntrg': 1., 'ntrd': 1.2}
ALTO = {'nmcf': 75.5, 'nlpr': 114.4, 'ntrh': 38.8, 'nmtw': 94.4, 'nmsn': 105.5, 'nlds': 166.4, 'nmmu': 159.1,
        'nnsw': 209.0, 'ntrg': 96.9, 'ntrd': 116.3}
ANCHO = {'nmcf': 96.4, 'nlpr': 132.4, 'ntrh': 117.7, 'nmtw': 120.5, 'nmsn': 129.1, 'nlds': 192.6, 'nmmu': 191.7,
         'nnsw': 168.7, 'ntrg': 294.3, 'ntrd': 353.1}
TAM = {t: max(ALTO[t], ANCHO[t]) for t in TIPOS}
JEFE10 = TAM['ntrd'] * 2.7
LETRA = '23456789A'


def elite(t):
    return round(min(2.5, max(1.8, 0.6 * JEFE10 / TAM[t])), 2)


def jefe(t):
    return 2.7 if t == 'ntrd' else round(0.9 * JEFE10 / TAM[t], 2)


def ids():
    """(rawcode, tipo común, factor, es jefe) de las 10 élites y los 9 jefes."""
    out = [(f'ne0{k}', t, elite(t), False) for k, t in enumerate(TIPOS)]
    out += [(f'nj0{LETRA[k - 1]}', t, jefe(t), True) for k, t in enumerate(TIPOS) if k]
    return out


def barra(t, f, es_jefe):
    """Altura extra de la barra (Barras_HT, sobre 150): por encima del modelo, nunca menos que antes (80 / 170)."""
    return max(170 if es_jefe else 80, round(ALTO[t] * f + 30 - 150))


if __name__ == '__main__':
    print(f'jefe 10: {JEFE10:.0f}')
    for rid, t, f, j in ids():
        print(f'{rid} {t} ×{f:<5} tamaño {TAM[t] * f:6.0f} (antes {TAM[t] * (2.7 if j else 1.8):6.0f}) alto {ALTO[t] * f:5.0f} barra +{barra(t, f, j)}')
