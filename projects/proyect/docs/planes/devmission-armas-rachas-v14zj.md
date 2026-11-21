# Dev Mission: armas, misil de calor, élites y rachas (desde v14zi)

Estado: **decidido, sin implementar** (07/11/2026). Base: `work/titulo-devmission-20261026/v14zi/war3map.j`
(mapa v14zi `d0a17188`). Objetivo Classic 1.27b, JASS sin Blz/Frame. Cada fase sale como versión nueva (v14zj, v14zk…)
con su `hacer-vNN.sh`, mapa normal sin registros y mapa de prueba; LAN de 2 clientes en las fases que toquen
`GetLocalPlayer` (anuncios y marcador).

## Petición de Leon (07/11/2026), resumida

1. Quitar las pistolas; el subfusil pasa a ser el arma inicial. Menos precisión en subfusil y rifle.
2. Teclas: R pasa a ser un arma; Recargar a F y Recargar batería («linternar») a G, las dos al centro (F izquierda,
   G derecha).
3. Quitar el brillo (luz de modelo) a balas, dash y «efecto artificial» para no gastar luces.
4. Élite: vida al 20 %; en su ronda sólo aparece con la llamada de refuerzos del jefe; desde la ronda siguiente entra en
   la oleada normal.
5. Cuchillo: animación de ataque al ritmo de los golpes; ángulo que crece con el tier; nuevos efectos Culling Cleave
   (por delante) y Culling Slash (área): 6 golpes por 1,5 s alternando A (delante) y B (área); cada tier suma golpes de
   dos en dos y daño.
6. Misil de calor en lugar de la pistola, en la última posición: Interceptor Shell (no la versión Rain); arco alto que
   crece con la distancia, rápido, explota en área al tocar el suelo; si un enemigo entra en su radio de detección lo
   persigue; si muere, sigue su trayecto, y puede tomar otro objetivo. El daño y el área suben con el tier; el radio de
   detección no.
7. Revisar precios contra el daño (el francotirador parece desequilibrado).
8. Variantes de color de los dos modelos nuevos, sin brillo.
9. Tiers por ronda: T1 siempre; T2 tras la ronda 1; T3 tras la 2; T4 tras la 4; T5 tras la 6; T6 tras la 8; un tier
   por ronda.
10. Rachas de WaveSys, mejor equilibradas, con anuncio arriba al centro (hasta 3 filas apiladas), voz del locutor y
    después una voz aleatoria de la unidad autora. Multiboard con nombre/color, muertes causadas, racha y vidas.

## Hechos comprobados en v14zi

- **Botones del controlador** (x, y; tecla): Recarga Aw08 (1,0) R · Dash Ard1 (2,0) D · Disparo Arp1 (3,0) A ·
  Pistolas Aw00 (0,1) Q · Subfusiles Aw01 (1,1) W · Rifles Aw02 (2,1) E · Francotiradores Aw03 (3,1) S ·
  Escopetas Aw04 (0,2) Z · Cuerpo a cuerpo Aw05 (1,2) X · Explosivos Aw06 (2,2) C · Recargar batería Aw0A (3,2) V.
  La casilla (0,0) queda libre. Arm_Botones da al empezar la categoría 0 (pistola) y el cuerpo a cuerpo (5).
- **Armas**: 7 categorías × 6 tiers en `Arm_Datos` (índice c × 6 + t − 1). Dispersión: subfusil 8°, rifle 3° más el
  retroceso acumulado del rifle (+0,8° por tiro, tope 12°), francotirador 0°.
- **Daño sostenido** (con cargador, recarga y crítico; sin perforación ni área):

  | Categoría | T1 | T2 | T3 | T6 |
  |---|---|---|---|---|
  | Subfusil | 36 dps · 200 | 54 · 600 | 88 · 1200 | 232 · 5500 |
  | Rifle | 43 · 250 | 69 · 700 | 107 · 1400 | 277 · 6000 |
  | Francotirador | **240 · 300** (perfora 2) | 394 · 800 | 781 · 1600 | 1828 · 6500 (perfora 7) |
  | Escopeta | 127 · 220 | 175 · 650 | 246 · 1300 | 683 · 5600 |
  | Cuerpo a cuerpo | 120 · 0 (área 220) | 180 · 250 | 250 · 600 | 613 · 3600 |
  | Granadas | 171 · 300 (área 200) | 257 · 800 | 415 · 1600 | 970 · 6500 |

  El francotirador T1 hace 6,7 veces el daño del subfusil T1 por 1,5 veces el precio, y además perfora: la sospecha de
  Leon se confirma. La escopeta también va muy por encima; el subfusil y el rifle, por debajo.
- **Modelos con luz** importados en v14zi: Shot y Shot II (7 colores cada uno), Firebrand Shot (9), Chain Grenade (6),
  Valiant Charge del dash (9), Windwalk (9), RecargaRoja/RecargaVerde, BossFlamestrike/SoulBeam/Spark (L/R),
  StormLuz (rayo, a propósito) y BatLuz0..5 (linterna, a propósito). Los dos modelos nuevos también traen una luz.
- **Culling Slash** (Vinz): círculo completo; a escala 1 llega a ~300 de radio en su pico (escala 2,5 del hueso), y
  gira. **Culling Cleave**: arco de ~±120° alrededor de un punto 50 por delante, ~250 de alcance en su pico (escala
  3,5). Las dos animaciones duran 2 s (Stand 1000–3000), con colores base, Purple, Red y Silver.
- **Interceptor Shell** (Vinz): Stand y Death (explosión), 23 emisores de partículas y 8 cintas: es pesado. Créditos
  Vinz.
- **Élites**: entran por muertes (`DevWave_Elite` a i × Total / (E + 1)); vida 0,40 × 800 × (1 + 0,75 (r − 1)); la
  llamada del jefe (`DevJefe_Aplicar`) añade refuerzos de los tipos normales de la ronda.
- **Rachas**: `WaveStreaks.j` de WaveSys no está en el mapa y necesita 5 bibliotecas que el mapa no tiene
  (WavePlayerUtils, SelectionSystem, WaveDamageCredit, PlayerHeroState, PrisonerDropSystem). Sus sonidos están en
  `WaveSys/resources/devmission-v096/war3mapImported/`.

## Evaluación

Todo se puede hacer en 1.27b. Puntos con riesgo o con decisión pendiente:

- **Rachas**: conviene escribir un módulo propio y pequeño sobre las muertes del mapa (`Oro_Muerte`), con los
  umbrales, la cola y los sonidos de WaveStreaks como referencia, en vez de traer la biblioteca con sus 5
  dependencias. El anuncio arriba al centro se hace con los textos de pantalla (UIText) que ya usa el HUD, en 3 filas
  que suben al llegar otro. El marcador es un multiboard: sólo se ve uno a la vez, así que reemplaza al de misiles
  (que ya está oculto).
- **Voz de la unidad**: 1.27b no tiene una función para «reproducir la voz de esta unidad». Hace falta una lista de
  sonidos por héroe (Tauren, Cairne), de la que se elige uno al azar.
- **Equilibrio de rachas**: con oleadas de hasta 240 unidades, las rachas tienen que ir por muertes sin perder una
  vida, y los multikill por ventana de tiempo. Propuesta inicial: racha cada 25 muertes (25, 50, 75… 8 escalones);
  multikill a 8 / 15 / 25 / 40 muertes en 3 s. Se ajusta con el registro de una partida.
- **Cuchillo**: los efectos duran 2 s y a 6 golpes por 1,5 s se solaparían. Se pondrían en una unidad ficticia con
  `SetUnitTimeScale` para acortarlos (probado en el motor con otros efectos). El arco del modelo es fijo: para que el
  ángulo crezca con el tier hay que generar variantes del modelo con el arco abierto (se puede con ModelEditor) o
  sólo ensanchar el área de daño. Golpes por 1,5 s (corrección de Leon, 07/11): 4 en T1 (2 por delante y 2 de área, alternos) y +2 por tier: 4, 6, 8, 10, 12 y 14.
- **Misil de calor**: se puede con el sistema de misiles del mapa (arco, búsqueda por proximidad, cambio de objetivo,
  explosión al tocar el suelo). Por las partículas del modelo hace falta un tope de misiles en vuelo y una cadencia
  baja (propuesta: 1 cada 0,8 s), y medir el rendimiento.
- **Luces**: quitar la luz de balas, dash y Windwalk libera el límite de 8 luces, pero las balas dejarán de iluminar
  de noche. Las del jefe y las de la recarga también se quitan si Leon lo confirma. La luz de la linterna y la del rayo
  se quedan.
- **Precios**: propuesta: igualar el daño sostenido útil por tier (con un valor para la perforación y el área) y fijar
  los precios por tier y no por arma. El francotirador perdería daño o perforación; el subfusil y el rifle subirían.
  Las cifras finales se presentan en tabla antes de aplicarlas.

## Decisiones de Leon (07/11/2026)

1. Teclas: según la propuesta. Arriba Q W E R = subfusil, rifle, francotirador, escopeta; en medio A disparo,
   F recargar, G batería, D dash; abajo Z X C = cuerpo a cuerpo, granadas, misil.
2. «Efecto artificial» = el efecto de los pies durante el movimiento artificial (Windwalk de Vinz, `walkModelOf`): se
   le quita la luz, como a las balas y al dash.
3. Requisito de ronda para todas las armas: el siguiente tier de cualquier arma pide haber pasado su ronda: T2 tras la
   1, T3 tras la 2, T4 tras la 4, T5 tras la 6 y T6 tras la 8. T1 siempre. No hay otro tope por ronda.
4. Élite al 20 % de la vida del jefe (hoy 40 %).
5. Se quita la luz de los efectos del jefe (Flamestrike, SoulBeam, Spark y sus L/R) y de RecargaRoja/RecargaVerde.
6. El resto, según la recomendación de este plan: dispersión propuesta de subfusil 8° → 12° y de rifle 3° → 6° (más
   su retroceso), rachas por módulo propio, cuchillo acelerado con unidad ficticia, misil con tope en vuelo.

## Tabla de precios (07/11/2026, aprobada por Leon)

Criterio: el mismo daño sostenido por tier para todas las armas (100 / 150 / 220 / 300 / 400 / 520 por segundo) y el
mismo precio por tier (250 / 600 / 1200 / 2200 / 3600 / 5500; T1 gratis para el subfusil y el cuchillo de inicio).
Ajustes por papel: escopeta ×1,1 (todos los perdigones deben acertar), granadas y misil ×0,8 (dan en área). El
francotirador pasa a 1 disparo por segundo y conserva su perforación; el cuchillo usa sus golpes nuevos. Se cambia el
daño por golpe; la cadencia, el cargador y la recarga siguen como en v14zi salvo esas dos armas y el misil (0,8 s,
cargador 4, recarga 2,5 s). Los valores definitivos se ajustan tras jugar una partida con registro.

| Arma | T1 | T2 | T3 | T4 | T5 | T6 |
|---|---|---|---|---|---|---|
| Subfusil (golpe, dps) | 19, 98 | 25, 151 | 28, 224 | 33, 296 | 38, 395 | 43, 525 |
| Rifle | 21, 101 | 26, 150 | 31, 222 | 38, 301 | 45, 403 | 49, 521 |
| Francotirador (perfora 2..7) | 150, 100 | 197, 150 | 215, 220 | 293, 300 | 359, 400 | 443, 520 |
| Escopeta (perdigón, dps) | 12, 109 | 14, 163 | 17, 246 | 18, 325 | 21, 436 | 20, 569 |
| Cuerpo a cuerpo (área) | 38, 101 | 38, 152 | 41, 219 | 45, 300 | 50, 400 | 56, 523 |
| Granadas (área) | 28, 80 | 42, 120 | 51, 176 | 69, 239 | 79, 319 | 103, 416 |
| Misil de calor (área 180..280) | 114, 80 | 171, 120 | 251, 176 | 342, 240 | 456, 320 | 593, 416 |

Antes (v14zi, dps sostenido T1 → T6): subfusil 36 → 232, rifle 43 → 277, francotirador 240 → 1828,
escopeta 127 → 683, cuerpo a cuerpo 120 → 613, granadas 171 → 970.

## Fases propuestas

1. **v14zj, armas y teclas**: quitar pistola, subfusil inicial, dispersión de subfusil y rifle, nuevo orden de
   botones, tiers por ronda, precios. Prueba de un jugador.
2. **v14zk, luces fuera**: copias sin luz de Shot, Shot II, Firebrand, Chain Grenade, Valiant Charge y Windwalk; vista
   previa en el visor 3D antes del juego.
3. **v14zl, élites**: vida al 20 %; en su ronda sólo con la llamada de refuerzos.
4. **v14zm, cuchillo nuevo**: Culling Cleave/Slash con colores por tier, sin luz; golpes A/B; animación al ritmo;
   ángulo por tier.
5. **v14zn, misil de calor**: Interceptor Shell con colores, sin luz; arco, búsqueda y explosión; medición de FPS.
6. **v14zo, rachas y marcador**: módulo de rachas, anuncios arriba al centro, voces, multiboard. LAN de 2 clientes.

Créditos nuevos: Vinz (Culling Slash, Interceptor Shell). Copias extraídas en
`work/titulo-devmission-20261026/fuentes/culling-interceptor/x`.

## Estado de la fase 1: v14zj (07/11/2026)

Fuentes: `scripts/v14zj.py` (j de v14zi), `scripts/objetos_v14zj.py` (w3a del mapa v14zi),
`scripts/prueba_v14zj.py` y `scripts/hacer-v14zj.sh`. Esta versión parte del mapa v14zi y sólo cambia
`war3map.j` y `war3map.w3a`.

| Mapa | SHA-256 |
|---|---|
| `TerrainDev-Titulo-v14zj.w3x` | `e9c296b7` |
| `TerrainDev-Titulo-v14zj-prueba-dia.w3x` | `46a19e34` |

Cambios:

- **Sin pistolas.** Se empieza con el MP18 (subfusil T1, `Arm_Cat` 1) y con el cuchillo T1.
  - La categoría 0 queda oculta en la tienda hasta la fase 5 (`Shop_CatFila`). Las otras seis suben una fila.
  - La tienda crea un texttag menos.
- **Daño y precios** según la tabla aprobada:
  - El francotirador dispara una vez por segundo.
  - El cuchillo usa `Arm_Int = 1,5 / (4 + 2(t−1))`.
  - La dispersión pasa a 12° en el subfusil y a 6° en el rifle.
- **Requisito de ronda** (`Arm_Req`, `Ronda_Pasadas`):

  | Tier | Requisito |
  |---|---|
  | T2 | ronda 1 |
  | T3 | ronda 2 |
  | T4 | ronda 4 |
  | T5 | ronda 6 |
  | T6 | ronda 8 |

  En la tienda, la fila muestra «Tras la ronda N» y el botón «Disponible tras la ronda N» (sin encender); `Shop_Comprar` lo rechaza.
- **Botones nuevos:**

  | Fila | Botones |
  |---|---|
  | Arriba | Q subfusil, W rifle, E francotirador, R escopeta |
  | Centro | A disparo, F recargar, G batería, D dash |
  | Abajo | Z cuchillo, X granadas, C misil (Aw00; todavía no se da) |

  El texto del HUD dice «Recargas (G)».

Comprobado:

- **Validated:** pJASS correcto en las dos variantes, reextracción igual por hash del j y del w3a, `mpq verify` correcto.
- **Tested in map** (un jugador, `v14zj-prueba-dia`; registros en `work/.../v14zj-prueba-dia/lat/`, capturas en `v14zj-capturas/`):
  - **Arranque y botones:** se entra con el MP18 T1. La casilla (0,0) muestra el subfusil, la fila central sale como se pidió y el HUD dice «Recargas (G): 3».
  - **Ronda 1:** el rifle T1 se compra por 250; el rifle T2 se rechaza.
  - **Descanso de la ronda 1:** el rifle T2 se compra por 600 y el subfusil T2 también; el rifle T3 se rechaza. La tienda muestra seis categorías sin Pistolas y «Tras la ronda 2» en el T3.
  - **Ronda 2 en curso:** el T3 sigue rechazado.
  - **Tras la ronda 2:** el T3 se compra por 1200; el T4 se rechaza.

No comprobado:

- El texto del botón Comprar con el requisito sin cumplir.
- Las teclas nuevas una por una con el teclado, ni el equilibrio del daño en partida.
- La munición del subfusil T1 cuesta menos que antes: `(precio + 100) / 4` con precio 0 da 25 por cargador.

**Siguiente paso:** fase 2 (v14zk), luces fuera de los efectos.

## Estado de la fase 2: v14zk (07/11/2026)

**Fuentes** (en `scripts/`):

| Fuente | Qué hace |
|---|---|
| `sin_luz_v14zk.cjs` | Quita el nodo de luz y renumera los ObjectId, los padres y los pivotes. Comprueba antes y después que los ObjectId van seguidos. |
| `visor_sin_luz_v14zk.cjs` | Genera el visor 3D. |
| `prueba_v14zk.py` | Mapa de prueba con «-efectos». |
| `hacer-v14zk.sh` | Construye todo. |

Copias, originales, lista y texturas para el visor en `work/.../sin-luz-v14zk/`. Las texturas del juego se sacaron, sólo leyendo, de los MPQ de la instalación.

**58 modelos sin luz**: Shot ×7, Shot II ×7, Firebrand Shot ×9, Chain Grenade ×6, Valiant Charge ×9, Windwalk ×9,
BossFlamestrike/SoulBeam/Spark y sus L/R, RecargaRoja y RecargaVerde. Conservan su luz StormLuz, BatLuz0..5 y los dos
Dark Nights (ciclo día/noche). El j es el de v14zj sin cambios.

| Mapa | SHA-256 |
|---|---|
| `TerrainDev-Titulo-v14zk.w3x` | `bc5046a1` |
| `TerrainDev-Titulo-v14zk-prueba-noche.w3x` | `d9d4cf73` |
| `TerrainDev-Titulo-v14zk-conluz.w3x` (sólo A/B: mismo j de prueba sobre v14zj) | `86c2d435` |

Comprobado:

- **Validated:**
  - pJASS correcto en las tres variantes.
  - Los 58 originales del mapa v14zj son iguales por hash a los de `sin-luz-v14zk/orig`.
  - Al reextraerlos, el j y los 58 modelos son iguales por hash; `mpq verify` correcto.
- **Visor 3D:** los 58 se muestran a la vez, original y sin luz, con 1 y 0 luces respectivamente.
  - Brillo de la mitad sin luz frente a la original: 0,97–1,00 en balas, dash y Windwalk.
  - Los efectos L/R del jefe y la granada roja (0,75–1,48) se revisaron a ojo y tienen la misma forma. La diferencia sale de su posición lateral y de las partículas al azar.
- **Tested in map** (un jugador, de noche; `v14zk-capturas/`):
  - Con «-efectos», los 24 efectos sin luz (Shot, Shot II, Valiant Charge, RecargaRoja) se ven igual que en `-conluz` (`comparacion-efectos.jpg`).
  - Con luz, esos 24 efectos no apagaron la linterna: el brillo del suelo fue igual antes y después (0,098/0,187/0,149 frente a 0,095/0,187/0,149). La mayoría de esas luces tienen intensidad 0 o animada en Stand.
  - Por eso esta prueba no demuestra un problema de luces que se arregle; sólo que quitarlas no cambia lo que se ve.

No comprobado:

- El disparo y el dash reales con las balas nuevas.
- Los efectos del jefe y de la recarga en su momento de juego.
- Las granadas, Firebrand y Windwalk en el juego (se vieron en el visor).

## Estado de la fase 3: v14zl (07/11/2026)

**Fuentes** (en `scripts/`):

| Archivo | Qué hace |
|---|---|
| `v14zl.py` | Parche del j de v14zk |
| `objetos_v14zl.py` | Vida base (`uhpm`) de 'ne00'..'ne09' de 320 a 160 |
| `prueba_v14zl.py` | Registro de eventos de élites, apariciones y llamadas; «-llamar» fuerza la llamada del jefe |
| `hacer-v14zl.sh` | Parte del mapa v14zk; cambia sólo war3map.j y war3map.w3u |
| `entrar-v14zl.sh`, `entrar-v14zl-prueba-dia.sh` | Lanzadores (el de prueba con registro en `lat\v14zl-N.txt`) |

**Cambios:**

- Vida de las élites: 20 % de la del jefe de la ronda (`800 × (1 + 0,75 × (ronda − 1))`), antes 40 %. Base 160 en el w3u
  más los bonos 'ALh0'..'ALhA' al aparecer.
- En su propia ronda, la élite del tipo nuevo sólo llega con la **primera** llamada de refuerzos del jefe, una por
  jugador (elección del agente; las llamadas siguientes no traen más élites). Los eventos por muertes
  (`DevWave_EliteE = n − 1`, a `i × Total / n`) sólo traen élites de los tipos de rondas anteriores.
- Ronda 1: sin jefe, así que sin élites; la élite del tipo 1 se ve por primera vez en la oleada de la ronda 2.

**Resultado:**

- **Validated:** pJASS correcto en las dos; reextracción por hash del j y del w3u; `mpq verify` correcto. El j normal sólo
  difiere de v14zk en las tres líneas del parche (sin registros).
- **Tested in map** (un jugador, `v14zl-prueba-dia`, registros en `work/.../v14zl-prueba-dia/eventos.txt` y `registros/`):

| Ronda | Por muertes | Con la 1.ª llamada | Vida |
|---|---|---|---|
| 1 | ninguna | sin jefe | — |
| 2 | tipo 0 (8/15) | tipo 1; llamadas 2 y 3 sin élite | 280 |
| 3 | tipos 0 (9/25) y 1 (17/25) | no probado: el jefe murió con «-fin» antes de llamar | 400 |
| 4 | tipos 0 (10/37), 1 (19/37) y 2 (28/37) | tipo 3 | 520 |

| Mapa | SHA-256 |
|---|---|
| v14zl | a7a3c49a |
| v14zl-prueba-dia | 495a371f |

**No comprobado:** multijugador (una élite por jugador con varios jugadores: el código no cambió en ese punto); rondas 5 a
10; el equilibrio de la vida nueva jugando con armas.

**Siguiente paso:** fase 4 (v14zm), cuchillo nuevo.

## Estado de la fase 4: v14zm (07/11/2026)

**Fuentes** (en `scripts/`):

| Archivo | Qué hace |
|---|---|
| `efectos_v14zm.cjs` | Culling Cleave y Culling Slash (Vinz) en los 6 colores de tier, Slash sin luz → `cuchillo-v14zm/` |
| `visor_cuchillo_v14zm.cjs` | Visor 3D de los 12 modelos (`cuchillo-v14zm/visor`, entrada `cuchillo-v14zm` de launch.json) |
| `objetos_v14zm.py` | 12 unidades ficticias copia de 'h00S': 'hkA1'..'hkA6' (Cleave) y 'hkB1'..'hkB6' (Slash) |
| `v14zm.py` | Parche del j de v14zl |
| `prueba_v14zm.py` | Registro por golpe (tipo, tier, reloj, dañados); «-cuchillo T» y «-ataque» |
| `hacer-v14zm.sh` | Parte del mapa v14zl; cambia war3map.j y war3map.w3u y añade los 12 mdx |
| `entrar-v14zm.sh`, `entrar-v14zm-prueba-dia.sh` | Lanzadores (el de prueba con registro en `lat\v14zm-N.txt`) |

**Cambios:**

- Golpes alternos por jugador: A (Cleave) por delante, con semiángulo 60° + 8° × (t − 1) (60° en T1, 100° en T6) y
  alcance `Arm_Area`; B (Slash) en círculo completo de radio `Arm_Area`. Intervalo de v14zj: 4 golpes por 1,5 s en T1
  y dos más por tier (14 en T6). Daño por golpe en `Arm_Dano`.
- Cada golpe pone su efecto en una unidad ficticia que mira hacia donde apunta el héroe, del color del tier y sin luz.
  Escala `Arm_Area / 150` (Cleave) y `Arm_Area / 180` (Slash). Se acelera por encima de 1 sólo en T5 y T6 y se quita a
  los 0,35 s / escala.
- Animación de ataque del héroe al ritmo de los golpes: escala de tiempo 1,4 / intervalo.

**Ajuste de escala probado:** con `/250` y `/300` (alcance del modelo a escala 1) y con `/190` y `/215` (alcance
visible medio ponderado por alfa: 153 y 172) se veían a la mitad del cono de daño, porque la parte brillante del modelo
es la del principio. Con `/150` y `/180` el anillo llega al borde del cono y el arco también al final. Evidencia en
`work/.../v14zm-prueba-dia/registros/` (`t1-escala-250-300`, `escala-190-215`, `escala-150-180`).

**Resultado:**

- **Validated:** pJASS correcto en las dos; reextracción por hash del j, el w3u y los 12 mdx; `mpq verify` correcto. El
  j normal no tiene código de prueba.
- **Tested in map** (un jugador, `v14zm-prueba-dia`):

| Prueba | Registro |
|---|---|
| T1 sin enemigos | `A1@3925 B1@3962 A1@4000 B1@4037`, escala 3,733, intervalo 0,375 |
| T1 con enemigos | `A1@1593:1 B1@1631:2 A1@1668:0 B1@1706:1` (dañados por golpe) |
| T6 con enemigos | 14 golpes alternos `A6@5731:5 B6@5743:5 …B6@5875:0` en 1,44 s, escala 13,07, intervalo 0,107; los dos primeros matan a 5 |

- Visual: arco amarillo y anillo en T1, rojos en T6, con la animación de ataque.

| Mapa | SHA-256 |
|---|---|
| v14zm | 3bde36b2 |
| v14zm-prueba-dia | 5391297c |

**No comprobado:**

- Que A sólo dañe por delante y B alrededor, con enemigos colocados a propósito (los conteos del registro son
  coherentes, pero no es una prueba controlada).
- Los sonidos de Slash (3 eventos de sonido; 7 por 1,5 s en T6), sin audio en la prueba.
- Tiers 2 a 5 en el juego (sólo en el visor).
- Multijugador.

**Pendiente de decidir:** el indicador `ConoCuchillo.mdx` sigue con su ángulo fijo de siempre y gira con el héroe, no
con el golpe.

**Siguiente paso:** fase 5 (v14zn), misil de calor (Interceptor Shell).

## Estado de la fase 5: v14zn (07/11/2026)

Parte del j de v14zm (comprobado contra el mapa por `hacer-v14zn.sh`). Fuentes: `scripts/v14zn.py`, `v14zn_datos.py`,
`objetos_v14zn.py`, `efectos_v14zn.cjs`, `iconos_v14zn.py`, `visor_misil_v14zn.cjs`, `prueba_v14zn.py` y
`hacer-v14zn.sh`. Modelos: Interceptor Shell de Vinz (no la versión Rain), sin luz, recoloreado al tono de cada tier.

- La categoría 0 pasa a «Misiles», en la última fila de la tienda y en el botón C (Aw00, icono `BTNMisil.blp`, foto
  'DS17'). Nombres: FIM-43 Redeye, 9K32 Strela-2, FIM-92 Stinger, 9K38 Igla, Mistral, Tipo 91 Kin-SAM.
- Datos de la tabla aprobada: daño 114 a 593, área 180 a 280, precio 250 a 5500, 1 cada 0,8 s, cargador 4, recarga
  2,5 s. Elección del agente: alcance 1100, velocidad 1200, reserva 16 + 4 (t − 1), búsqueda 350 en todos los tiers.
- Vuelo: cae en el punto elegido (150 a 1100) con un arco de 1,1 rad; la altura crece con la distancia (≈ 0,49 × d).
  Pasada la cima, persigue al enemigo vivo más cercano a 350 o menos. Si muere, sigue hacia donde iba y puede tomar
  otro. Explota con la animación Death y daña en área.
- Tope de 24 misiles en vuelo entre todos los jugadores.

**Comprobaciones:**

- **Validated:** pJASS correcto en las dos variantes; reextracción por hash del j, el w3a, el w3b, el imp, los 6 mdx y
  los 2 BLP; `mpq verify` correcto. El j normal no tiene código de prueba. La construcción es reproducible (mismo
  hash del mapa normal en dos construcciones).
- **Visor 3D:** los 6 colores (amarillo, verde, cian, azul, morado, rojo) en Stand y Death, sin luces.
- **Tested in map** (un jugador, `v14zn-prueba-dia`; registros en `v14zn-prueba-dia/registros/prueba-1` y
  `prueba-2`, capturas en `v14zn-prueba-dia/capturas`). Tiempos en centésimas desde el lanzamiento:

| Prueba | Resultado |
|---|---|
| T1 a 700, sin enemigos | `L1@2525:700 C1@2556:367 E1@2581:0`: cima a altura 367, explota a 0,56 s |
| T1 a 600, enemigos junto al héroe | `C1@6131:323 O1@6131:227 E1@6150:5`: toma objetivo en la cima y daña a 5 (la oleada baja de 7 a 2) |
| T6, 30 de golpe (oleada 1) | 10 toman el mismo grupo; el primero en llegar daña a 5, los otros 9 pierden el objetivo (P) y siguen hasta su punto |
| T6, 30 de golpe (oleada 2) | la mayoría hace O → P → O → P: cambia de objetivo al morir el anterior |
| HUD y botón | «FIM-43 Redeye T1 3/16», icono nuevo en el botón C |

- **Rendimiento** con 30 misiles T6 en vuelo, por encima del tope (capa de cuadros, perfil de 60 FPS):

| Tramo | FPS | p95 | Cuadros > 33 ms |
|---|---|---|---|
| Antes | 60,2 | 18,0 ms | los del registro de prueba |
| Ráfaga, 0 a 3 s | 61,7 | 20,0 ms | 1 (54 ms, al crear los 30 a la vez) |
| 3 a 9 s | 62,2 | 18,5 ms | 0 |

  Los cuadros de unos 173 ms que se repiten cada pocos segundos son las escrituras del registro de prueba; el mapa
  normal no las tiene.

| Mapa | SHA-256 |
|---|---|
| v14zn | 8dda89ae |
| v14zn-prueba-dia | 61c12b3f |

**No comprobado:**

- La fila de Misiles dentro de la tienda en el juego. Por código: `Shop_CatFila(0)` devuelve 6 y la foto 'DS17' está
  en el w3b. No se llegó a abrir la tienda en la prueba.
- Que el tope de 24 frene los disparos: un solo jugador no llega (4 por cargador, cada 0,8 s, ~1 s de vuelo). La ráfaga
  de prueba se lo salta a propósito.
- La compra en la tienda, los tiers 2 a 5 en el juego (sólo en el visor) y el multijugador.

**Siguiente paso:** fase 6 (v14zo): rachas, voces y multiboard, con LAN de 2 clientes.

## Estado de la fase 6: v14zo (07/11/2026)

Construido con `scripts/hacer-v14zo.sh` desde v14zn: `v14zo.py` (módulo propio de rachas, sin WaveStreaks.j),
`objetos_v14zo.py` (14 sonidos en el imp), datos en `v14zo_datos.py`, sonidos copiados de
`WaveSys/resources/devmission-v096/war3mapImported` a `racha-v14zo/`. pJASS correcto, reextracción igual, `mpq verify`.

- **Rachas:** un tier cada 25 bajas sin caer (Killing Spree … Beyond Godlike); en el último, aviso cada 25.
- **Multimuertes:** 8 / 15 / 25 / 40 bajas, cada una a menos de 3 s de la anterior (Double, Triple, Ultra, Rampage);
  en Rampage, aviso cada 15. Si un aviso del mismo tipo y jugador sigue en cola, se sustituye por el nuevo.
- **First Blood** en la primera baja de cada ronda; al caer con 25 o más, «perdió su racha (N)» con RompeRacha.
- **Anuncios** arriba al centro, bajo el contador de la ronda: hasta 3 filas, 5 s cada una; la más vieja sale por arriba.
  Anunciador primero y, 0,2 s antes de que acabe, una voz al azar del personaje que hizo la baja (Tauren o Cairne).
- **Marcador** «Jugador / Muertes / Racha / Vidas», nombre en su color; se oculta con la tienda abierta.
- Todo el estado es sincronizado; sólo la visibilidad de textos y marcador va dentro de `GetLocalPlayer`. Duraciones de
  sonido fijas (medidas con ffprobe), no `GetSoundFileDuration`.

**Tested in map** (v14zo-prueba-dia, un jugador; registros en `v14zo-prueba-dia/`, capturas en `capturas/`):

| Prueba | Resultado |
|---|---|
| «-sumar 40» | First Blood → Rampage (40) → Killing Spree, voz tras cada uno; los multis intermedios se sustituyeron |
| «-caer» + «-sumar 60» | RompeRacha, Rampage (55), Dominating (50); filas apiladas que suben (serie s01–s14) |
| «-matar 5» (baja real por Oro_Muerte) | total 125 → 130, racha 25 → 30, multi 5 (sin aviso) |
| Marcador | Muertes, Racha y Vidas al día |

**Tested in multiplayer** (LAN de 2 clientes en esta PC, `v14zo-lan/lan/try1`, `puente_lan_v14zo.py`): 27 registros
por cliente, **0 diferencias** en el estado sincronizado (bajas, rachas, tiers, vidas, celdas, filas, cola, eventos con
su reloj, aleatorio). Marcador visible en los dos con los mismos valores; avisos de J1 y J2 en ambas pantallas.

| Mapa | SHA-256 |
|---|---|
| v14zo | 248e6eb7 |
| v14zo-prueba-dia | c9de37a8 |
| v14zo-lan (sólo prueba) | cdffb2bf |

**No comprobado:**

- Que se oigan anunciador y voces: la grabación del monitor de audio quedó tapada por la música (la correlación no
  separa los sonidos). Los eventos de sonido sí salen en el registro en su momento.
- La voz de Cairne (h006): en las dos pruebas los personajes eran Tauren.
- Que el marcador y los anuncios se oculten con la tienda abierta (no se abrió la tienda).
- Multimuertes con bajas reales seguidas (la oleada 1 sólo tenía 7 enemigos); los umbrales se probaron con «-sumar».

## v14zp: música de oleada a la mitad (07/11/2026, petición de Leon)

`scripts/hacer-v14zp.sh` desde v14zo; sólo cambia war3map.j (`v14zp.py`): el volumen de `Ronda_Tema[1..10]` pasa a la
mitad (125→63, 127→64, 95→48, 117→59). pJASS correcto, reextracción igual, `mpq verify`.

**Tested in map:** oleada 1, 12 s grabados del monitor de audio sin tocar nada, misma escena: v14zo media −17,2 dB
(pico −5,0), v14zp media −23,7 dB (pico −9,4). Unos −6 dB, la mitad de amplitud; el ambiente del mapa sigue en la
grabación. Las otras 9 oleadas no se oyeron en la prueba.

**Sonidos de rachas (añadido en v14zp, a pregunta de Leon):** en v14zo `Racha_Sonar` creaba un sonido nuevo y lo
arrancaba en el mismo instante; la grabación de v14zo no los encontraba (correlación 0,11 a 0,17 en momentos que no
coinciden con el registro). Ahora `Racha_Registrar` crea al entrar un sonido fijo por archivo (13 del anunciador, First
Blood, RompeRacha y 9 voces), lo suena una vez a volumen 0 y `Racha_Sonar` reutiliza ese sonido (Stop + Start).

**Tested in map** (v14zp-prueba-dia, «-sumar 30», 18 s grabados): Ultra Kill con correlación 0,91 a 2,70 s, Killing
Spree 0,85 a 7,34 s (4,64 s después; el registro dice 4,69) y la voz TaurenWarcry1 0,91 a 9,56 s (2,22 s tras el
Spree; el registro dice 2,25). La voz tras Ultra Kill sale débil (0,09), tapada por el final del anunciador.

| Mapa | SHA-256 |
|---|---|
| v14zp | 2f16c9e6 |
| v14zp-prueba-dia | e6a467cd |

## v14zq: tarjeta del anuncio de rachas (07/11/2026)

Pedido: texto de racha más grande, en un cuadro rectangular con el retrato del personaje al final (anima hablar con su
voz); la tarjeta baja rápido desde arriba y, al acabar su tiempo, sube hasta salir; nombre arriba y racha debajo.

- Fuentes: `scripts/tarjeta_v14zq.py` (RachaCaja 512 × 64, BLP sha256 742aa586…), `objetos_v14zq.py` ('DS18'),
  `v14zq.py` (j), `prueba_v14zq.py`, `hacer-v14zq.sh`, `entrar-v14zq.sh`, `entrar-v14zq-prueba-dia.sh`.
- Diseño: una tarjeta a la vez (grupo de 2: la que sale y la que entra). Cuadro 'uidb' 480 × 60 px centrado en X 960,
  centro en Y 150 (`Racha_Y`); nombre 0,015 y racha 0,020 centrados en X 926,7; retrato 'dta0'/'dca0' de 48 px en
  X 1168,1 a 398. Entra desde Y −80 y sale a −90 con `y += (meta − y) × 0,2` cada 0,01 s (`Racha_Mover`, igual en
  todos los clientes); dura 5 s o hasta el anuncio siguiente. Habla durante `Racha_VozLen` de la voz elegida.
- Texttags: los dos de cada tarjeta se crean sólo en el cliente del que mira y sólo mientras se ve (antes 3 fijos por
  jugador); con la tienda abierta, ninguno.
- Mapas: `TerrainDev-Titulo-v14zq.w3x` caff4f0f… y `-v14zq-prueba-dia.w3x` dacc9264….
- Estado: **Validated** (pJASS de los dos, reextracción por hash del j, w3b, imp y BLP, `mpq verify`). No probado en el
  mapa ni en LAN: lo prueba Leon. Pendiente comprobar posición de textos y retrato (ajustables con «-ajuste»), que el
  retrato hable y vuelva a reposo, que la textura 'DS18' prenda y, por tocar lo local, una LAN de dos clientes.

## v14zr: textos de la tarjeta más abajo (07/11/2026)

Con las capturas de Leon en v14zq (tarjeta, textura y retrato bien; el nombre tocaba el borde de arriba y la racha iba
pegada a la línea), `scripts/v14zr.py` baja el nombre 6 px (y − 18) y la racha 8 px (y + 9); «-ajuste» sigue sumando
encima. Sólo cambia el j. Mapas: `TerrainDev-Titulo-v14zr.w3x` 55e6d198… y `-v14zr-prueba-dia.w3x` ac9c6cc7….
**Validated** (pJASS, reextracción, `mpq verify`); sin probar en el mapa. Pendiente: el habla del retrato y la LAN.

## v14zs: oleada junto a la barra y 4 tarjetas en 2 filas (07/11/2026)

Pedido de Leon tras v14zr: llevar el título de la oleada y su cifra al lado de la barra de vida, poner «Tiempo de
compra» en lugar de «Descanso», subir las tarjetas y mostrar varias a la misma altura, hasta 4 en 2 filas.

- `scripts/v14zs.py`: «Wave N» y la cifra en x 345, y 70 y 98, alineados a la izquierda (`Ronda_Texto`).
- Tarjetas de 410 × 56 entre la oleada y el marcador (que empieza en x ≈ 1335): columnas con centro en x 705 y 1125,
  filas con centro en y 76 y 138. La nueva ocupa el primer hueco libre; con los 4 llenos sale la más vieja y la nueva
  entra en su hueco cuando aquélla ya subió. Las de abajo van 3 unidades más lejos, para pasar por detrás al bajar o
  subir (los textos sí se cruzan un instante). Grupo de 5 tarjetas por jugador; habla sólo la más nueva del que anota.
- Mapas: `TerrainDev-Titulo-v14zs.w3x` 1146f989… y `-v14zs-prueba-dia.w3x` 9dffb441…. **Validated** (pJASS,
  reextracción, `mpq verify`); sin probar en el mapa ni en LAN.

## v14zt: marco delante del retrato (07/11/2026)

En v14zs el retrato asomaba por los lados de su cuadro. `scripts/tarjeta_v14zt.py` rehace RachaCaja (cuadro del texto
x 1..420, fondo oscuro del retrato x 428..510, en pantalla 66 × 56 con centro en cx + 170,6) y crea RachaMarco
128 × 128 ('DS19'): borde oscuro y dorado con una ventana transparente de 48 × 44 px. `v14zt.py` lo pone a 397,
delante del retrato (398), y sube el retrato a 50 px de alto para que el marco tape sus bordes; texto centrado en
cx − 36,4. Mapas: `TerrainDev-Titulo-v14zt.w3x` 64ab2b52… y `-v14zt-prueba-dia.w3x` ccb6f7d7….
**Validated**; sin probar en el mapa. Riesgo a mirar: que el marco translúcido quede delante del retrato.

## v14zu: marco del retrato más ancho (07/11/2026)

Con la captura de v14zt el retrato aún asomaba por la izquierda: `tarjeta_v14zu.py` da al marco 80 × 56 px con la misma
ventana de 48 × 44 y acorta el cuadro del texto (x 1..400); `v14zu.py` centra retrato y marco en cx + 163 y el texto
en cx − 44,4. Mapas: `TerrainDev-Titulo-v14zu.w3x` c1457cc6… y `-v14zu-prueba-dia.w3x` c5219c7c…. **Validated**.

## v14zv: marco del retrato a 390 (07/11/2026)

Las capturas de Leon eran de v14zt (no de v14zu): la tarjeta de la columna izquierda bien, en la derecha el retrato
tapaba las líneas del marco. Con 1 unidad entre marco (397) y retrato (398) el orden de dibujo no es seguro; `v14zv.py`
pone el marco a 390 con su tamaño × 390/400 y vuelve a las medidas de v14zt (marco 66 × 56, texturas racha-v14zt).
Mapas: `TerrainDev-Titulo-v14zv.w3x` 13c503b2… y `-v14zv-prueba-dia.w3x` 1a8c17b1…. **Validated**; v14zu queda sin uso.

## v14zw: el personaje elegido entra a la partida; LAN para Leon (07/11/2026)

Leon notó que con la intro, eligiendo a Cairne, siempre entraba el Tauren. Causa: `v12y.py` dejó `Game_Cuerpo` con
'h005' fijo y nunca se restauró la rama de Cairne (informe `informes/errores/2026-11-07-215933-pick-cairne-entra-tauren.md`).
`v14zw.py` la restaura (sólo 4 líneas de diferencia con v14zv). Las pruebas sin intro (Entrada_Directa) siguen con el
Tauren porque `Hero_Choice` vale 0.
- Mapas: `TerrainDev-Titulo-v14zw.w3x` 01417078… (con intro, sin registros), `-v14zw-prueba-dia.w3x` e53552f7…,
  `-v14zw-lan.w3x` = copia idéntica del normal, con `v14zw-lan/map.cfg` para ydhost.
- Lanzadores: `entrar-v14zw.sh`, `entrar-v14zw-prueba-dia.sh` y `lan-v14zw.sh` (ydhost + 2 clientes en los espacios 6
  y 7, sin entradas automáticas; al cerrar las dos ventanas devuelve ydhost.cfg y map.cfg originales).
- **Validated**; sin probar en el mapa ni en LAN. La tarjeta de rachas (v14zv) sigue pendiente de confirmación visual.

## v14zx y v14zy: noche predeterminada y tiempos de la intro (07/11/2026)

- v14zx (`v14zx.py`): `Variante` 2 (noche) al entrar; antes 1 (tarde). Mapa c561e1cb…, para jugar con amigos.
- v14zy (`v14zy.py`): Start 5 → 60 s y modo 5 → 60 s, ambos bajan a 3 s cuando todos eligieron (antes no bajaban);
  héroe ya era 60 → 3; jefe 30 → 60 s (ya bajaba a 3). Tablero de estrategia 5 s sin cambios.
  Mapas `TerrainDev-Titulo-v14zy.w3x` y `-v14zy-lan.w3x` d62460ab…. **Validated**; sin probar en el mapa ni en LAN.
