"""Datos del misil de calor de v14zn (07/11/2026), compartidos por v14zn.py (Arm_Datos) y objetos_v14zn.py (Aw00)."""
MISILES = [
    ('FIM-43 Redeye', 1967, 'El primero que se llevó al hombro. Sigue el calor de lo que quema.'),
    ('9K32 Strela-2', 1968, 'Ligero y terco. No suelta al que ya vio.'),
    ('FIM-92 Stinger', 1981, 'Busca rápido y cae fuerte. Mucho más difícil de esquivar.'),
    ('9K38 Igla', 1983, 'Su cabeza no se deja engañar por el humo.'),
    ('Mistral', 1988, 'Corre más que todo lo que persigue.'),
    ('Tipo 91 Kin-SAM', 1991, 'Ve el calor y la forma. Donde cae no queda nada.'),
]
DANO = [114, 171, 251, 342, 456, 593]
AREA = [180, 200, 220, 240, 260, 280]
PRECIO = [250, 600, 1200, 2200, 3600, 5500]
ALC, VEL, RADIO = 1100, 1200, 350


def rasgo(t):
    return '|cff7fd4ffAlcance %d|r, área %d, busca a %d, bala %d' % (ALC, AREA[t], RADIO, VEL)
