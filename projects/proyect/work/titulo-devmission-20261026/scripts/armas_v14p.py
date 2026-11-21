"""Tabla de armas de v14p: siete categorías y seis tiers (las seis filas del prototipo de la tienda).

Pedido de Leon (05/11/2026): cada tier mejora el daño, el cargador, la reserva, la velocidad de la bala y los tiros por
ráfaga de 1,5 s; la precisión es la misma en todos los tiers de una categoría. Rifle y escopeta salen ya rápidos.
Francotirador: 3 tiros por ráfaga como máximo (pedido de v14o), así que mejora por daño, perforación y crítico.
Colores por tier: Yellow, Green, Cyan, Blue, Purple y Red (paleta de TerrainDev/assets/balas-colores).

Fila: nombre, año, tiros por ráfaga (melee: intervalo en s), daño, perdigones, cargador, reserva, precio, recarga en s,
atraviesa, crítico, área, velocidad de la bala y comentario del golem.
Por categoría: dispersión en grados, alcance y tipo de daño (6 Estándar, como en v14l).
"""
CATS = ['Pistolas', 'Subfusiles', 'Rifles', 'Francotiradores', 'Escopetas', 'Cuerpo a cuerpo', 'Explosivos']
COLORES = ['Yellow', 'Green', 'Cyan', 'Blue', 'Purple', 'Red']
RGB = {'Yellow': (253, 234, 0), 'Green': (101, 253, 0), 'Cyan': (0, 227, 253), 'Blue': (0, 69, 253),
       'Purple': (114, 0, 253), 'Red': (253, 0, 6)}
TIERS = 6
DISP = [2, 8, 3, 0, 10, 0, 0]
ALC = [1350, 1350, 1350, 1350, 650, 0, 900]
ARMAS = [
    # Pistolas: 7..12 tiros por ráfaga, bala de 1200 a 1700.
    ('Colt Paterson', 1836, 7, 22, 1, 12, 72, 0, 2.0, 0, 0, 0, 1200, 'La primera que giró su tambor. Vieja, pero nunca te deja solo.'),
    ('Borchardt C-93', 1893, 8, 28, 1, 14, 90, 300, 1.2, 0, 0, 0, 1300, 'Primera pistola automática que funcionó de verdad. Cambia el cargador en un momento.'),
    ('M1911', 1911, 9, 36, 1, 16, 110, 800, 1.2, 1, 0, 0, 1400, 'Un siglo de servicio. Su bala pesada pasa a través del primero.'),
    ('Browning Hi-Power', 1935, 10, 46, 1, 18, 130, 1600, 1.1, 1, 0, 0, 1500, 'Trece balas en la empuñadura. Medio mundo la llevó al cinto.'),
    ('Beretta 92', 1975, 11, 58, 1, 20, 150, 3000, 1.0, 1, 0.10, 0, 1600, 'Fina y constante. Tira rápido sin perder la mano.'),
    ('Glock 17', 1982, 12, 72, 1, 24, 180, 5000, 0.9, 2, 0.15, 0, 1700, 'Plástico y acero. No se traba nunca, y pasa a través de dos.'),
    # Subfusiles: 12..22 tiros, bala de 1300 a 1800.
    ('MP18', 1918, 12, 7, 1, 32, 320, 200, 2.2, 0, 0, 0, 1300, 'El primer subfusil. Escupe mucho plomo y cada bala pega poco.'),
    ('Thompson M1928', 1928, 14, 9, 1, 34, 340, 600, 2.0, 0, 0, 0, 1400, 'La de los gánsteres. Más rápida y más dura que la anterior.'),
    ('MP40', 1940, 16, 11, 1, 36, 360, 1200, 1.8, 0, 0.15, 0, 1500, 'Más dura todavía. A veces rompe de un golpe.'),
    ('PPSh-41', 1941, 18, 13, 1, 40, 400, 2200, 1.8, 0, 0.15, 0, 1600, 'Tambor grande y lluvia de balas. No dejes que se enfríe.'),
    ('Uzi', 1950, 20, 16, 1, 45, 450, 3600, 1.6, 0, 0.15, 0, 1700, 'Pequeña y feroz. Cabe en una mano y vacía una calle.'),
    ('MP5', 1966, 22, 19, 1, 50, 500, 5500, 1.5, 0, 0.20, 0, 1800, 'La favorita de los que entran primero. Rápida y certera.'),
    # Rifles: 14..20 tiros, bala de 1800 a 2400; la dispersión sigue abriéndose en ráfaga sostenida.
    ('Fedorov Avtomat', 1916, 14, 9, 1, 25, 250, 250, 2.5, 0, 0, 0, 1800, 'El abuelo de todos los fusiles de asalto. Rara pieza.'),
    ('StG 44', 1944, 15, 12, 1, 30, 300, 700, 2.2, 1, 0, 0, 1920, 'Dio nombre a su familia. Sus balas no paran en el primero.'),
    ('AK-47', 1947, 16, 15, 1, 30, 330, 1400, 2.0, 1, 0.15, 0, 2040, 'Barro, arena o lluvia: dispara igual. Como una roca.'),
    ('M16', 1964, 17, 18, 1, 35, 350, 2500, 2.0, 1, 0.15, 0, 2160, 'Ligera y veloz. Su bala llega antes de que la oigan.'),
    ('Steyr AUG', 1977, 18, 22, 1, 40, 400, 4000, 1.8, 2, 0.15, 0, 2280, 'Corta y precisa. Pasa a través de dos sin pestañear.'),
    ('FN SCAR', 2004, 20, 26, 1, 45, 450, 6000, 1.7, 2, 0.20, 0, 2400, 'Lo último que ha salido de la forja. Rápida y brutal.'),
    # Francotiradores: 3 tiros, bala de 2400 a 3000.
    ('Whitworth', 1857, 3, 240, 1, 6, 60, 300, 3.0, 2, 0, 0, 2400, 'Una bala lenta de cargar, y cada una cuenta.'),
    ('Mosin-Nagant', 1891, 3, 320, 1, 8, 80, 800, 2.5, 3, 0, 0, 2520, 'Cerrojo sencillo y bala larga. Pasa a través de tres.'),
    ('Kar98k', 1935, 3, 450, 1, 10, 100, 1600, 2.2, 4, 0.25, 0, 2640, 'Preciso como un buen golpe de martillo.'),
    ('Dragunov SVD', 1963, 3, 560, 1, 10, 110, 2800, 2.2, 5, 0.25, 0, 2760, 'Semiautomático y largo. Atraviesa una fila entera.'),
    ('Barrett M82', 1982, 3, 700, 1, 12, 120, 4400, 2.0, 6, 0.30, 0, 2880, 'Calibre de cañón. Lo que toca, cae.'),
    ('AWM', 1996, 3, 880, 1, 12, 140, 6500, 1.8, 7, 0.35, 0, 3000, 'La más precisa que he forjado. Elige bien a quién.'),
    # Escopetas: 6..9 tiros, perdigones 5..8, bala de 1700 a 2200.
    ('Trabuco', 1650, 6, 14, 5, 6, 60, 220, 1.8, 0, 0, 0, 1700, 'Pólvora y clavos. De cerca lo arregla todo.'),
    ('Winchester 1887', 1887, 7, 15, 6, 8, 80, 650, 2.4, 0, 0, 0, 1800, 'Palanca y un perdigón más.'),
    ('Browning Auto-5', 1902, 7, 17, 6, 10, 100, 1300, 2.0, 0, 0, 0, 1900, 'La primera automática. Pega más fuerte.'),
    ('Ithaca 37', 1937, 8, 19, 7, 10, 110, 2300, 2.0, 0, 0, 0, 2000, 'Corredera suave y siete perdigones. Despeja pasillos.'),
    ('Remington 870', 1950, 8, 21, 7, 12, 120, 3700, 1.8, 0, 0, 0, 2100, 'La más vendida del mundo, por algo será.'),
    ('SPAS-12', 1979, 9, 24, 8, 14, 140, 5600, 1.6, 0, 0, 0, 2200, 'Ocho perdigones y un rugido. Nada se le acerca.'),
    # Cuerpo a cuerpo: intervalo en s, sin bala.
    ('Cuchillo de sílex', -9000, 0.25, 30, 1, 0, 0, 0, 0, 0, 0, 220, 0, 'La herramienta más vieja del mundo. Nunca se queda sin balas.'),
    ('Pugio', -50, 0.2222, 40, 1, 0, 0, 250, 0, 0, 0, 225, 0, 'La daga corta del legionario romano.'),
    ('Cuchillo de trinchera', 1918, 0.2, 50, 1, 0, 0, 600, 0, 0, 0, 230, 0, 'Hecho para espacios estrechos. Golpea antes de que te vean.'),
    ('Ka-Bar', 1942, 0.1875, 62, 1, 0, 0, 1200, 0, 0, 0, 240, 0, 'Hoja ancha de marine. Corta lo que haga falta.'),
    ('Tomahawk táctico', 1966, 0.1667, 76, 1, 0, 0, 2200, 0, 0, 0, 250, 0, 'Hacha corta de acero. Abre corazas a golpes.'),
    ('Bayoneta M9', 1986, 0.15, 92, 1, 0, 0, 3600, 0, 0, 0, 260, 0, 'Rápida y afilada. El último recurso que nunca falla.'),
    # Explosivos: 6..8 tiros, granada de 900 a 1150.
    ('Granada de pólvora', 1500, 6, 60, 1, 6, 36, 300, 0.6, 0, 0, 200, 900, 'Una bola de hierro con mecha. Lánzala lejos de ti.'),
    ('Granada Mills', 1915, 6, 90, 1, 6, 48, 800, 0.6, 0, 0, 230, 950, 'La primera granada moderna de seguridad.'),
    ('Granada Mk 2', 1918, 7, 120, 1, 8, 64, 1600, 0.6, 0, 0, 260, 1000, 'La piña clásica. Mucho ruido y mucho alcance.'),
    ('Stielhandgranate 24', 1924, 7, 155, 1, 8, 72, 2800, 0.6, 0, 0, 280, 1050, 'El mango la lleva más lejos. Cuidado dónde cae.'),
    ('RGD-5', 1954, 8, 195, 1, 10, 90, 4400, 0.6, 0, 0, 300, 1100, 'Ligera y llena de metralla. Limpia un corro entero.'),
    ('M67', 1968, 8, 240, 1, 10, 100, 6500, 0.6, 0, 0, 320, 1150, 'La bola de acero de hoy. Nada queda de pie alrededor.'),
]
assert len(ARMAS) == len(CATS) * TIERS


def intervalo(c, a):
    """Intervalo entre tiros: melee lo trae; las demás, 1,5 s entre los tiros de la ráfaga (4 decimales)."""
    return a[2] if c == 5 else round(1.5 / a[2], 4)


def rasgo(c, a):
    r = []
    if a[4] > 1:
        r.append(f'{a[4]} perdigones')
    if a[9]:
        r.append(f'atraviesa {a[9]}')
    if a[10]:
        r.append(f'crítico {round(a[10] * 100)}%')
    if a[11]:
        r.append(('cono ' if c == 5 else 'área ') + str(a[11]))
    if c != 5:
        r.append(f'bala {a[12]}')
    return ', '.join(r).capitalize()


# Comprobación de la ráfaga del juego: IMaxBJ(1, R2I(1.5 / Int + 0.01)) da los tiros pedidos.
for c in range(7):
    if c != 5:
        for t in range(TIERS):
            a = ARMAS[c * TIERS + t]
            assert int(1.5 / intervalo(c, a) + 0.01) == a[2], a[0]
