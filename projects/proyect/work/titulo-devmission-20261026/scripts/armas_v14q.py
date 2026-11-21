"""Tabla de armas de v14q: la de v14p con alcance por tier (pedido de Leon, 06/11/2026: que se note más el alcance).

Hasta v14p el alcance era fijo por categoría (1350; escopeta 650; granada 900, distancia máxima del lanzamiento). Ahora
crece en cada tier y la tienda lo muestra en color al principio del renglón de rasgos. Cuerpo a cuerpo sigue con su cono
(no usa alcance).
"""
from armas_v14p import CATS, COLORES, RGB, TIERS, DISP, ARMAS, intervalo

ALC = [
    [800, 900, 1000, 1100, 1200, 1300],      # pistolas
    [700, 800, 900, 1000, 1100, 1200],       # subfusiles
    [1100, 1200, 1300, 1400, 1500, 1650],    # rifles
    [1500, 1650, 1800, 1950, 2100, 2300],    # francotiradores
    [400, 450, 500, 550, 600, 700],          # escopetas
    [0, 0, 0, 0, 0, 0],                      # cuerpo a cuerpo
    [650, 700, 750, 800, 850, 900],          # explosivos: distancia máxima del lanzamiento
]
AZUL = '|cff7fd4ff'


def alcance(c, t):
    return ALC[c][t - 1]


def rasgo(c, a, t):
    r = []
    if c != 5:
        r.append(f'{AZUL}Alcance {alcance(c, t)}|r')
    if a[4] > 1:
        r.append(f'{a[4]} perdigones')
    if a[9]:
        r.append(f'atraviesa {a[9]}')
    if a[10]:
        r.append(f'crítico {round(a[10] * 100)}%')
    if a[11]:
        r.append(('Cono ' if c == 5 else 'área ') + str(a[11]))
    if c != 5:
        r.append(f'bala {a[12]}')
    return ', '.join(r)


def rasgo_plano(c, a, t):
    """Sin códigos de color, para los textos de las habilidades."""
    return rasgo(c, a, t).replace(AZUL, '').replace('|r', '')
