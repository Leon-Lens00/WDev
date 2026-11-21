# Dev Mission v14h: tienda móvil, zonas de munición, élites y Burning Rage

Base: v14g (`TerrainDev-Titulo-v14g.w3x`, sha256 `558f6cfe…98105c38`), plan anterior
[devmission-oleadas-jefes-v14g.md](devmission-oleadas-jefes-v14g.md). Trabajo en
`work/titulo-devmission-20261026/`; Integration es el único escritor del mapa. Objetivo Classic 1.27b, sin Blz/Frame/Lua.

## Requisitos del usuario (04/11/2026)

- **Tienda (golem 'ngst')**:
  - No está al empezar la partida. Al terminar una oleada baja dormida (`sleep`), frenando, hasta el suelo, y nace
    (`birth`, después `stand`).
  - Al acabar el descanso sube acelerando hasta salir de la vista. Arriba y oculta pasa a otro punto `nPtA` al azar
    (nunca dos veces seguidas el mismo), con el facing de su campesino.
- **Abrir la tienda**:
  - Sin clic. A 300 o menos, en el descanso, aparece el texto "Press [ESC] to buy supplies" en el centro de la pantalla,
    grande y en degradado de la paleta.
  - ESC abre la tienda y ESC dentro la cierra.
- **Descanso**:
  - Un solo descanso de 45 s, sin la pausa de 120 s con la tienda abierta.
  - El tiempo se ve también dentro de la tienda y parpadea en rojo a 10 s o menos.
  - A 0 s se cierra la tienda.
- **Zonas de munición (20 `nPtB`)**:
  - Al empezar hay 2 activas al azar, y se suman 2 en cada oleada. Las inactivas no se ven.
  - Efecto Radiance Nature (verde) o Crimson (roja, ya usada), visto por cada jugador según su propio uso.
  - A 250 o menos aparece "[ESC] Pick up Ammo". ESC llena el cargador de todas las armas y suma un cargador a la
    reserva, hasta su máximo.
  - Vuelven a verde al empezar la oleada siguiente. Se usan en ronda y en descanso.
- **Élites**:
  - Siempre 1 por tipo y oleada.
  - Vida = 45% de la del jefe de la oleada, con su escala por jugadores.
  - Escala de élites ×2,1 y de jefes ×2,7, con la selección igual.
- **Colisión** 0 en todos los tipos de oleada, élites y jefes.
- **Burning Rage**:
  - Un color por tipo, el mismo para la élite y el jefe de esa oleada: verde, turquesa, azul, púrpura, rosa, amarillo,
    naranja, rojo, plata y violeta-negro.
  - Recolorear conservando los blancos.
- **Localizador de la tienda**: como el del jefe, con esfera azul, en ronda y descanso.
- **Puntos de oleada**: los 100 `nPto` nuevos del usuario.

## Decisiones del agente

- **Alturas y tiempos de la tienda**:
  - Espera a 2200 de altura.
  - Baja con altura × (1 − t/2,4)².
  - Sube con 1800/s². Se recrea en cada punto para nacer con su facing, y la altura usa el truco de la forma de cuervo.
- **ESC**:
  - Si hay zona y tienda a mano, ESC toma la munición primero.
  - Sin nada cerca, ESC no hace nada ni suena error. Seleccionar el golem ya no abre la tienda.
- **Textos**:
  - El aviso está en y = 520 (escala UIText), tamaño 0,026, degradado azul claro (115,200,255) → blanco → rojo
    (255,48,48).
  - El tiempo de la tienda es "Descanso N" en (1601, 88); el parpadeo es de 2 Hz.
- **Efectos por jugador**: un efecto por zona y jugador, creado en todos los clientes con el modelo solo en el cliente
  de ese jugador.
- **Vida de las élites**: 0,45 × round(800 × (1 + 0,75 (r − 1))) × jugadores.
  - La base 360 está en el w3u.
  - El resto se suma con 'ALh0'..'ALhA' (copias de 'AIlf', nivel 2 = +10 × 2^b): añadir, subir a nivel 2 y quitar,
    en binario.
- **Localizador**: apunta al punto aunque la tienda esté arriba oculta, a 150 sobre el suelo.
- **Barras**: 110 sobre las élites y 170 sobre los jefes. UnitHitShape con las escalas nuevas.

## Archivos

| Script | Salida |
|---|---|
| `scripts/efectos_v14h.py` (Pillow del runtime de Slendytubbies) | `v14h-efectos/`: BurningRage1..10, texturas plata/violeta, RecargaVerde/Roja, TiendaEsfera |
| `scripts/objetos_v14h.py` | `v14h/war3map.w3u`, `war3map.w3a`, `TiendaIcono.mdx` |
| `scripts/v14h.py` | `v14h/war3map.j` (lee `puntos/guardado-v14h-1318/war3mapUnits.doo`) |
| `scripts/prueba_v14h.py` | `v14h-prueba/war3map.j` |
| `scripts/hacer-v14h.sh`, `entrar-v14h.sh`, `entrar-v14h-prueba.sh` | mapas y lanzadores |

El mapa de puntos del usuario se copió a `puntos/guardado-v14h-1318/` (w3x `af0af8bc…`, doo `ca30e86c…`).

## Créditos

Burning Rage y Radiance son de **Vinz** (Hive Workshop): `efectos/burning-rage/` y `efectos/radiance/`, con sus readme.
Los colores plata y violeta son recoloreados de sus modelos azul y púrpura.

## Estado

**Validated (04/11/2026)**:
- pJASS pasa en `v14h` y en `v14h-prueba`.
- Empaquetado en `TerrainDev-Titulo-v14h.w3x` (`e96b8023…1d66db55`) y `TerrainDev-Titulo-v14h-prueba.w3x`
  (`75b6c65c…078675d8`).
- Reextraídos y comparados: j, w3u, w3a, BurningRage10 y VioletaGlow. `mpq verify` correcto.

**Tested in map, un jugador (04/11/2026, primera prueba, rondas 2-4)**:
- Bien:
  - La tienda baja al terminar la oleada (estados 1 → 2) con el facing de su campesino (268/82/198 frente a
    269/83/199).
  - Sube al acabar el descanso y pasa a otro punto (6 → 5 → 3).
  - Aviso de tienda, abrir y cerrar, y el reloj "Descanso N" dentro de la tienda.
  - Zonas acumuladas (2, 4 y 6) que vuelven a verde en cada oleada.
  - La toma de munición deja los cargadores al máximo y suma un cargador a la reserva (0/0 → 12/12 y 32/32).
  - Vida de los jefes 1400 y 2000. Élites vivas en la ronda 2: 2.
- **Fallo**: la vida de las élites bajaba (90/90 en vez de 630 en la ronda 2; −180 en la ronda 3). En 1.27b, quitar
  'AIlf' en el nivel 2 resta el valor de ese nivel. Corregido: nivel 1 = +10 × 2^k y nivel 2 = 0.
- No comprobado:
  - El cierre a 0 s, porque la segunda apertura falló con el héroe lejos; la prueba ahora lo coloca antes de abrir.
  - Una toma en la ronda 2, porque el héroe quedó a 265 de la zona; ahora se coloca con SetUnitX/Y.

Cambio del usuario: Burning Rage va en `head`.

**Cambios del usuario tras ver el mapa normal**:
- Burning Rage pasa a `overhead`.
- El golem espera más alto: 4000, con subida a 2400/s² y bajada en 3 s.
- El reloj de la tienda tapaba "Golem de roca". Ahora va a la izquierda en (1650, 92), con tamaño 0,022.

**LAN de dos clientes** (`scripts/puente_lan_v14h.py`, `hacer-lan-v14h.sh`, `lan-v14h.sh`):
- Juegan J1 y J2, rondas 2 a 5.
- Cada uno toma munición en su zona, y después J2 toma la que ya usó J1.
- Las dos tiendas se abren a la vez y se cierran por separado. A 0 s se cierra la tienda.
- Cada 2 s se escribe una suma del estado sincronizado más lo local de cada cliente.

Mapas actuales (con los tres cambios del usuario):
- `TerrainDev-Titulo-v14h.w3x`: `350dfa9d…04599a`.
- `TerrainDev-Titulo-v14h-prueba.w3x`: `99ea9d31…28fae`.
- `TerrainDev-Titulo-v14h-lan.w3x`: `0fdb2dfc…68c4`.

**Tested in map, un jugador (04/11/2026, segunda prueba, `d97a94c1…`, rondas 2-4)**: todo correcto.
- Élites con la vida esperada: 630/630, 900/900 y 1170/1170.
- La tienda abierta a 6 s del final se cerró al empezar la oleada (`tiendaAbierta=0`).
- Toma de munición en las tres rondas, con zonas 2 → 4 → 6.
- Puntos de la tienda 4 → 0 → 4, sin repetir seguidos.

**Tested in multiplayer (04/11/2026, LAN con ydhost y dos clientes en esta misma PC, `v14h-lan/lan/try1/`)**:
- Los dos clientes llegaron a FIN (ronda 5). 160 líneas de registro en cada uno.
- Todas las sumas del estado sincronizado y todos los eventos son iguales en los dos clientes. El registro de ydhost
  no muestra desincronización ni desconexión.
- Lo local es correcto en cada cliente:
  - J2, en la zona que J1 ya había usado, vio el aviso de munición y la zona verde, mientras J1 la veía roja.
  - El localizador se vio en cada cliente.
  - El reloj de la tienda sólo aparece en el cliente que la tiene abierta.
- Vida con 2 jugadores: élites 1260, 1800, 2340 y 2880 (rondas 2-5); jefes 2800, 4000 y 5200.
- Las dos tiendas se abren a la vez y se cierran por separado. Al empezar la ronda las dos quedan cerradas.
- El golem espera a 4000 de altura.
- Capturas:
  - el aviso en degradado;
  - "Descanso N" a la izquierda de "Golem de roca", sin taparlo, y en rojo a 10 s o menos;
  - "[ESC] Pick up Ammo" sobre la zona verde, y la zona roja después de tomarla.
- No comprobado: Burning Rage en `overhead` no se distingue en las capturas, porque la prueba mata a las élites
  enseguida. Tampoco la LAN entre dos PCs distintas.

**Fallo visto por el usuario (04/11/2026)**: el Burning Rage violeta salía como un cráneo opaco, porque las texturas
propias recoloreadas perdían el alfa. Corregido en `efectos_v14h.py`; detalle en
[devmission-tienda-ia-v14i.md](devmission-tienda-ia-v14i.md).
- Mapa nuevo: `TerrainDev-Titulo-v14h.w3x` `87d98b18…6455bf`.
- Prueba: `TerrainDev-Titulo-v14h-prueba.w3x` `212acdd7…bf395d4588`.
- El mapa LAN `0fdb2dfc…` es anterior a esta corrección.

**Pendiente**: revisión visual del usuario en el mapa normal (bajada y subida del golem a 4000, `sleep`/`birth`,
colores de Burning Rage en `overhead`).
