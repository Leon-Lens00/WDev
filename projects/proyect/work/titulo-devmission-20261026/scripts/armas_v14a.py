"""Tabla de armas de v14a: siete categorías, tres tiers (tres modelos de misil por ahora).

Cada fila: nombre, año, cargador, reserva, disparos por minuto, daño, perdigones, dispersión en grados, precio,
recarga en s, atraviesa, crítico, área, alcance, rasgos (acumulados) y comentario del golem.
Tier 3 acumula los rasgos del 2. Melee: área es el radio del cono de 120 grados.
"""
CATS = ['Pistolas', 'Subfusiles', 'Rifles', 'Francotiradores', 'Escopetas', 'Cuerpo a cuerpo', 'Explosivos']
BALA = 1350
ARMAS = [
    # Pistolas
    ('Colt Paterson', 1836, 5, 15, 120, 22, 1, 3, 0, 2.0, 0, 0, 0, BALA, 'Básica', 'La primera que giró su tambor. Vieja, pero nunca te deja solo.'),
    ('Borchardt C-93', 1893, 8, 24, 150, 26, 1, 2, 300, 1.2, 0, 0, 0, BALA, 'Recarga rápida', 'Primera pistola automática que funcionó de verdad. Cambia el cargador en un momento.'),
    ('M1911', 1911, 7, 21, 180, 38, 1, 2, 600, 1.2, 1, 0, 0, BALA, 'Recarga rápida, atraviesa 1', 'Un siglo de servicio. Su bala pesada pasa a través del primero.'),
    # Subfusiles
    ('MP18', 1918, 32, 96, 500, 7, 1, 6, 160, 2.2, 0, 0, 0, BALA, 'Cadencia alta', 'El primer subfusil. Escupe mucho plomo y cada bala pega poco.'),
    ('Thompson M1928', 1928, 30, 90, 700, 8, 1, 3, 400, 2.0, 0, 0, 0, BALA, 'Cadencia alta, menos dispersión', 'Dispara más rápido y se abre menos que la anterior.'),
    ('MP40', 1940, 32, 96, 550, 13, 1, 3, 800, 1.8, 0, 0.15, 0, BALA, 'Menos dispersión, crítico 15%', 'Más lenta y mucho más dura. A veces rompe de un golpe.'),
    # Rifles
    ('Fedorov Avtomat', 1916, 25, 75, 600, 9, 1, 4, 200, 2.5, 0, 0, 0, BALA, 'Equilibrado', 'El abuelo de todos los fusiles de asalto. Rara pieza.'),
    ('StG 44', 1944, 30, 90, 550, 13, 1, 3, 500, 2.2, 1, 0, 0, BALA, 'Atraviesa 1', 'Dio nombre a su familia. Sus balas no paran en el primero.'),
    ('AK-47', 1947, 30, 90, 600, 17, 1, 2, 1000, 2.0, 1, 0.15, 0, BALA, 'Atraviesa 1, crítico 15%', 'Barro, arena o lluvia: dispara igual. Como una roca.'),
    # Francotiradores
    ('Whitworth', 1857, 1, 10, 10, 120, 1, 0, 220, 3.0, 0, 0, 0, BALA, 'Un disparo, sin dispersión', 'Una bala cada seis segundos, y cada una cuenta.'),
    ('Mosin-Nagant', 1891, 5, 10, 30, 160, 1, 0, 550, 2.5, 2, 0, 0, BALA, 'Atraviesa 2', 'Cerrojo sencillo y bala larga. Pasa a través de dos.'),
    ('Kar98k', 1935, 5, 10, 35, 220, 1, 0, 1100, 2.2, 2, 0.25, 0, BALA, 'Atraviesa 2, crítico 25%', 'Preciso como un buen golpe de martillo.'),
    # Escopetas
    ('Trabuco', 1650, 1, 10, 15, 14, 5, 12, 180, 1.8, 0, 0, 0, 650, 'Cinco perdigones, corta distancia', 'Pólvora y clavos. De cerca lo arregla todo.'),
    ('Winchester 1887', 1887, 5, 15, 40, 14, 6, 12, 450, 2.4, 0, 0, 0, 650, 'Seis perdigones', 'Palanca, un perdigón más y cinco tiros seguidos.'),
    ('Browning Auto-5', 1902, 5, 15, 60, 16, 6, 7, 900, 2.0, 0, 0, 0, 650, 'Seis perdigones, cono cerrado', 'La primera automática. Cierra el cono y pega más.'),
    # Cuerpo a cuerpo
    ('Cuchillo de sílex', -9000, 0, 0, 75, 30, 1, 0, 0, 0, 0, 0, 220, 0, 'Cono delante, sin munición', 'La herramienta más vieja del mundo. Nunca se queda sin balas.'),
    ('Pugio', -50, 0, 0, 85, 40, 1, 0, 250, 0, 0, 0, 220, 0, 'Más daño', 'La daga corta del legionario romano.'),
    ('Cuchillo de trinchera', 1918, 0, 0, 120, 50, 1, 0, 500, 0, 0, 0, 220, 0, 'Golpe rápido', 'Hecho para espacios estrechos. Golpea antes de que te vean.'),
    # Explosivos
    ('Granada de pólvora', 1500, 1, 6, 20, 60, 1, 0, 220, 0.6, 0, 0, 200, 900, 'Área 200, cae en el punto', 'Una bola de hierro con mecha. Lánzala lejos de ti.'),
    ('Granada Mills', 1915, 1, 6, 25, 90, 1, 0, 550, 0.6, 0, 0, 260, 900, 'Área 260', 'La primera granada moderna de seguridad.'),
    ('Granada Mk 2', 1918, 1, 6, 30, 120, 1, 0, 1100, 0.6, 0, 0, 300, 900, 'Área 300', 'La piña clásica. Mucho ruido y mucho alcance.'),
]
FRASES = ['Que cada bala encuentre su camino.', 'La tierra guíe tus pasos. Vuelve con vida.',
          'Dispara firme y no te detengas.', 'Buen acero. Que te dure toda la guerra.',
          'Que tus ancestros cuiden tu puntería.', 'Con esto, ninguna oleada te doblará.']
# Totales por ronda en el orden de aparición; cada tipo sigue saliendo en las rondas siguientes.
TIPOS = ['nmcf', 'nlpr', 'ntrh', 'nmtw', 'nmsn', 'nlds', 'nmmu', 'nnsw', 'ntrg', 'ntrd']
RANGO = {'ntrh', 'nmsn', 'nlds', 'nnsw'}
RONDAS = [[10], [8, 6], [6, 6, 5], [5, 5, 5, 5], [4, 4, 5, 5, 5], [4, 4, 4, 5, 5, 4], [3, 4, 4, 4, 5, 4, 4],
          [3, 3, 4, 4, 4, 4, 4, 4], [3, 3, 3, 4, 4, 4, 4, 4, 3], [2, 3, 3, 3, 3, 4, 4, 4, 3, 1]]
# Usados en armas_v14a por objetos_v14a.py y v14a.py
HOTKEYS = 'QWESZXC'
POS = [(0, 1), (1, 1), (2, 1), (3, 1), (0, 2), (1, 2), (2, 2)]
ORDENES = ['thunderclap', 'fanofknives', 'howlofterror', 'divineshield', 'avatar', 'berserk', 'windwalk']
TEX = {'ShopPanelL': 'DS00', 'ShopPanelC': 'DS01', 'ShopPanelR': 'DS02', 'ShopWindow': 'DS03', 'ShopCell': 'DS04',
       'ShopCatOn': 'DS05', 'ShopCatOff': 'DS06', 'ShopRowOn': 'DS07', 'ShopRowOff': 'DS08', 'ShopBtnOn': 'DS09',
       'ShopBtnOff': 'DS0A', 'ShopWide': 'DS0B', 'ShopGem': 'DS0C', 'ShopGolem': 'DS0D', 'HudBlindaje': 'DS0E',
       'Arma-pistola': 'DS10', 'Arma-subfusil': 'DS11', 'Arma-rifle': 'DS12', 'Arma-francotirador': 'DS13',
       'Arma-escopeta': 'DS14', 'Arma-melee': 'DS15', 'Arma-granada': 'DS16'}
