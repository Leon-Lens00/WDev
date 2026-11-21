# Dev Mission v14i: retrato del golem, abastecer todo, precios y velocidades de la IA

Base: v14h (`TerrainDev-Titulo-v14h.w3x`, `87d98b18…6455bf`, con el Burning Rage violeta y plata corregidos), plan
anterior [devmission-tienda-municion-v14h.md](devmission-tienda-municion-v14h.md). Integration es el único escritor.
Estado: **Designed** (evaluación, sin implementar).

## Corrección previa (hecha, 04/11/2026)

Burning Rage violeta salía como un cráneo opaco. `VioletaGlow.blp` y `PlataGlow.blp` se reescribían sin alfa. Sus
originales (`RoyalGlow02`, `AzureGlow5`) son BLP JPEG con alfa de 8 bits en capas Blend, y Pillow los lee con alfa 255.
`efectos_v14h.py` decodifica ahora el JPEG a mano y guarda BLP1 con alfa de 8 bits. La media de alfa coincide con el
original (45,1 y 34,6). Validated: reextracción igual y `mpq verify` correcto. Falta verlo en juego. Anotado en la skill
wc3-classic-modeling.

## Requisitos del usuario (04/11/2026)

1. **Retrato del golem** en el cuadro del panel, como los personajes de la selección de la intro. También la unidad en
   la tienda, con su grupo de sonidos, que suena al comprar.
2. **Botón para abastecer todas las armas** en el panel del golem:
   - Rellena todas las armas si alcanza el oro; si no, reparte el oro que queda.
   - La munición cuesta según la mejora: si la última mejora costó 1000 y se gastaron todas sus balas, rellenar cuesta
     1000.
3. **Precios de los tiers** ajustados a cuánto mejora cada uno.
4. **Élites con teleport.**
5. **Velocidades de la IA:**
   - Más bonificación al perseguir.
   - A menos del 50% de vida, todas (normales y élites) persiguen a velocidad máxima.
   - Las que sólo corren también corren al máximo a menos del 50%.
   - Élites a menos del 25%: corren sin parar.
6. **Jefe:**
   - Rachas de persecución a velocidad máxima aunque no esté cerca: 10-15 s de racha y 10-15 s de descanso.
   - A menos del 25% de vida, la racha es permanente.

## Estado actual medido en el script v14h

- **IA** (`DevWave_IA`):
  - **Élites** `ne00..ne09`: `WaveAIEnableChaseSprint(500, +40%, 3600 s, 0)`. A 500 o menos se activa y ya no se apaga.
  - **Jefes:** teleport a 150 detrás, cada 15-25 s.
  - **Prisa con poca vida** (+40% al 50%): sólo `nmmu`, `ntrg`, `ntrd` y las élites 6, 8 y 9.
  - **Tope de velocidad:** `WAVE_AI_MAX_MOVE_SPEED = 522`, el máximo del motor. "Velocidad máxima" es 522.
- **Munición:**
  - Rellenar toda la reserva cuesta `(precio + 100) / 4`; un AK-47 (1000) cuesta 275.
  - Las armas de tier 0 cuestan 0 y los cuchillos no gastan munición.
- **Oro por muerte:** `max(3, vida máxima / 5) × (2 + ronda) / 3`, para quien mata; al empezar se tienen 150.
- **Golem:**
  - 'ngst', con modelo `units\creeps\RockGolem\RockGolem` y grupo de sonidos `RockGolem` (unitUI.slk de classic-assets).
  - No está comprobado que exista `RockGolem_Portrait.mdx` en el MPQ de 1.27b.

## Evaluación

**1. Retrato.** Viable con el método de la intro (memorias `retrato-ligero-pared`, `controlador-misma-unidad`).
- Se pone el retrato del golem en el cuadro, en lugar del modelo entero, y anima `portrait talk` mientras habla.
- El sonido al comprar sale sólo para el comprador (`GetLocalPlayer` con un sonido creado en todos los clientes), con
  LAN de dos clientes.
- Hay que comprobar el retrato del golem y los archivos de su grupo `RockGolem` en el MPQ.
- Pregunta: ¿"la unidad player" es el golem que habla al comprar, o el personaje del jugador?

**2. Abastecer todo.** Nombre propuesto: **"Abastecer todo"** (otras opciones: "Reabastecer", "Carga completa").
- Precio por bala = precio de la mejora del arma / (cargador + reserva). Rellenar de vacío cuesta la mejora.
- Hay que decidir:
  - **Armas de tier 0:** el Colt cuesta 0, así que su munición sería gratis. Propuesta: precio de referencia de 100 para
    las armas de tier 0.
  - **Reparto sin oro suficiente.** Propuesta: todas las armas llegan al mismo porcentaje, que es justo y fácil de leer.
    Alternativa: primero el arma en uso.
  - **El botón de cada arma** ("60 balas: 21 oro") pasa a la misma regla, para que no haya dos precios.
- Riesgo: es unas 3,6 veces más cara que ahora. Con 3 jugadores el oro se reparte por muertes, y las zonas de munición
  gratis lo compensan en parte. Conviene medir el oro por ronda en la prueba antes de fijarlo.

**3. Precios por tier.** Estimación sin medir:
- Daño sostenido = daño × perdigones × (1 + crítico) × cargador / (cargador × intervalo + recarga).
- Supone el crítico ×2 e ignora atravesar y el área.

| Categoría | T1 | T2 | T3 |
|---|---|---|---|
| Pistolas | Colt 0 oro, 53 | Borchardt 300, 86 (×1,63) | M1911 600, 142 (×2,70) |
| Subfusiles | MP18 160, 37 | Thompson 400, 53 (×1,42) | MP40 800, 90 (×2,44) |
| Rifles | Fedorov 200, 45 | StG 44 500, 71 (×1,58) | AK-47 1000, 117 (×2,61) |
| Francotiradores | Whitworth 220, 160 | Mosin 550, 284 (×1,78) | Kar98k 1100, 622 (×3,89) |
| Escopetas | Trabuco 180, 127 | Winchester 450, 153 (×1,20) | Browning 900, 227 (×1,79) |
| Cuerpo a cuerpo | Sílex 0, 120 | Pugio 250, 180 (×1,50) | Trinchera 500, 250 (×2,08) |
| Explosivos | Pólvora 220, 171 | Mills 550, 257 (×1,50) | Mk 2 1100, 369 (×2,15) |

- **Lo que más destaca:**
  - El Kar98k casi cuadruplica al Whitworth por 1100.
  - Los subfusiles son la categoría más débil.
  - El Winchester apenas mejora al Trabuco.
- Propuesta: medir antes el daño real en el juego, con un registro de daño por arma contra un muñeco durante 30 s y
  contra un grupo para atravesar y área. Después, fijar los precios proporcionales a la mejora medida.

**4-6. Velocidades.** Casi todo se hace con la configuración de la propia biblioteca:
- **Élites con teleport:** `WaveAIEnableTeleport('ne00'+k, …)`, como los jefes.
- **Más bonificación al perseguir:** subir el +40% de `ChaseSprint`. Propuesta: +70%.
- **Menos del 50% → máximo**, para todos los tipos de oleada: `WaveAIEnableLowLifeHaste(tipo, 50, +400%)`. El tope
  de 522 lo deja en la velocidad máxima, se combine o no con la persecución.
- **Élites a menos del 25%:**
  - Tal como lo entiendo, "corren sin cesar" es persecución a 522 sin límite de distancia y sin reintentos.
  - Esto necesita lógica nueva en la capa del mapa: el umbral de prisa es uno por tipo, y el 50% ya las pone al máximo.
- **Rachas del jefe:**
  - Un temporizador propio alterna 10-15 s de racha y 10-15 s de descanso.
  - En la racha, el jefe va a 522 hacia el jugador objetivo, sin condición de distancia. A menos del 25%, la racha
    queda fija.
  - Se cambia en la capa DevJefe del mapa, sin tocar los originales de WaveSys.
- **Riesgo:** a 522, los cuerpo a cuerpo con vida baja casi no se pueden esquivar. Conviene probarlo con un jugador
  antes de fijar la bonificación.

## Oleadas actuales (v14h), 1/2/3 jugadores

- **Escalado:** cada tipo da `base + redondeo(base × 0,5 × (jugadores − 1))`. Las élites (1 por tipo) y el jefe no
  escalan.
- **Topes:**
  - 40 vivas por dueño, con 6 dueños (8-13): 240 vivas como máximo, un tope al que no se llega.
  - Cada entrada por tipo puede tener vivas todas las suyas.
  - Sale una cada 0,25 s.
- **El jefe** sale cuando sólo queda él por matar.

| Ronda | nmcf | nlpr | ntrh | nmtw | nmsn | nlds | nmmu | nnsw | ntrg | ntrd | Normales | Élites | Jefe | Total |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 18/27/36 | — | — | — | — | — | — | — | — | — | 18/27/36 | 1 | 0 | 19/28/37 |
| 2 | 14/21/28 | 11/17/22 | — | — | — | — | — | — | — | — | 25/38/50 | 2 | 1 | 28/41/53 |
| 3 | 11/17/22 | 11/17/22 | 9/14/18 | — | — | — | — | — | — | — | 31/48/62 | 3 | 1 | 35/52/66 |
| 4 | 9/14/18 | 9/14/18 | 9/14/18 | 9/14/18 | — | — | — | — | — | — | 36/56/72 | 4 | 1 | 41/61/77 |
| 5 | 7/11/14 | 7/11/14 | 9/14/18 | 9/14/18 | 9/14/18 | — | — | — | — | — | 41/64/82 | 5 | 1 | 47/70/88 |
| 6 | 7/11/14 | 7/11/14 | 7/11/14 | 9/14/18 | 9/14/18 | 7/11/14 | — | — | — | — | 46/72/92 | 6 | 1 | 53/79/99 |
| 7 | 6/9/12 | 7/11/14 | 7/11/14 | 7/11/14 | 9/14/18 | 7/11/14 | 7/11/14 | — | — | — | 50/78/100 | 7 | 1 | 58/86/108 |
| 8 | 6/9/12 | 6/9/12 | 7/11/14 | 7/11/14 | 7/11/14 | 7/11/14 | 7/11/14 | 7/11/14 | — | — | 54/84/108 | 8 | 1 | 63/93/117 |
| 9 | 6/9/12 | 6/9/12 | 6/9/12 | 7/11/14 | 7/11/14 | 7/11/14 | 7/11/14 | 7/11/14 | 6/9/12 | — | 59/91/118 | 9 | 1 | 69/101/128 |
| 10 | 4/6/8 | 6/9/12 | 6/9/12 | 6/9/12 | 6/9/12 | 7/11/14 | 7/11/14 | 7/11/14 | 6/9/12 | 2/3/4 | 57/87/114 | 10 | 1 | 68/98/125 |

**Refuerzos del jefe:**
- La primera llamada llega a los 15-20 s de aparecer, y después una cada 41,5-51,5 s.
- La llamada k añade min(k, 6) × (2/3/4) unidades por cada tipo de la ronda.
- De esos refuerzos, cada tipo puede tener min(k, 6) vivos a la vez.

| Ronda | Llamada 1 | Llamada 2 | Llamada 3 | Llamada 4 | Llamada 6 y siguientes (cada una) |
|---|---|---|---|---|---|
| 2 | 4/6/8 | 8/12/16 | 12/18/24 | 16/24/32 | 24/36/48 |
| 3 | 6/9/12 | 12/18/24 | 18/27/36 | 24/36/48 | 36/54/72 |
| 4 | 8/12/16 | 16/24/32 | 24/36/48 | 32/48/64 | 48/72/96 |
| 5 | 10/15/20 | 20/30/40 | 30/45/60 | 40/60/80 | 60/90/120 |
| 6 | 12/18/24 | 24/36/48 | 36/54/72 | 48/72/96 | 72/108/144 |
| 7 | 14/21/28 | 28/42/56 | 42/63/84 | 56/84/112 | 84/126/168 |
| 8 | 16/24/32 | 32/48/64 | 48/72/96 | 64/96/128 | 96/144/192 |
| 9 | 18/27/36 | 36/54/72 | 54/81/108 | 72/108/144 | 108/162/216 |
| 10 | 20/30/40 | 40/60/80 | 60/90/120 | 80/120/160 | 120/180/240 |

Calculado a partir de `DevWave_Slots`, `DevWave_Reparto`, `WaveComputeScaledAmount` y `DevJefe_Aplicar` del j de v14h
(Scanned). No se ha contado en el juego.

## Nuevo sistema de generación propuesto por el usuario (04/11/2026, evaluado, sin implementar)

**Fórmulas:**
- Por tipo: `Wave × 6 × J`.
- Base por tipo, con antigüedad `A = wave − desbloqueo + 1`: `ceil(A/2) × min(6, 1 + floor(A/2))`.
- Base total: `round(Σ base × (1 + (J − 1) × pct/100))`, con pct de 0 a 200 y 100 por defecto. Se reparte entre los
  tipos por restos mayores.
- Límite simultáneo: `min(5 × wave × J, 240)`, con 40 por bot como máximo. La cola se repone con cada muerte.
- Sin tope por tipo.

**Comprobaciones de las fórmulas:** los ejemplos del enunciado cuadran.
- Base de la wave 10: 30 + 25 + 20 + 16 + 12 + 9 + 6 + 4 + 2 + 1 = 125.
- Wave 2 con 2 jugadores: 24 + 6 = 30, con límite 20.

**Simulación con pct 100.** Cada celda es total / límite simultáneo. "Actual" es el total de v14h, contando élites y
jefe.

| Wave | 1J | Actual 1J | 2J | Actual 2J | 3J | Actual 3J |
|---|---|---|---|---|---|---|
| 1 | 7 / 5 | 19 | 14 / 10 | 28 | 21 / 15 | 37 |
| 2 | 15 / 10 | 28 | 30 / 20 | 41 | 45 / 30 | 53 |
| 3 | 25 / 15 | 35 | 50 / 30 | 52 | 75 / 45 | 66 |
| 4 | 37 / 20 | 41 | 74 / 40 | 61 | 111 / 60 | 77 |
| 5 | 52 / 25 | 47 | 104 / 50 | 70 | 156 / 75 | 88 |
| 6 | 70 / 30 | 53 | 140 / 60 | 79 | 210 / 90 | 99 |
| 7 | 92 / 35 | 58 | 184 / 70 | 86 | 276 / 105 | 108 |
| 8 | 118 / 40 | 63 | 236 / 80 | 93 | 354 / 120 | 117 |
| 9 | 149 / 45 | 69 | 298 / 90 | 101 | 447 / 135 | 128 |
| 10 | 185 / 50 | 68 | 370 / 100 | 98 | 555 / 150 | 125 |

**Lo que ya tiene el sistema:**
- 40 vivas por bot (`Wave_create(40, …)`).
- Cola que se repone al morir una unidad, sin perder pendientes.
- La ronda acaba cuando ya salió todo y está todo muerto.
- Aparición escalonada: una cada 0,25 s, con aviso de 1,5 s.

**Lo que falta:**
- Un tope global por wave. Hoy sólo existe el tope por dueño: hay que añadir en `Wave_trySpawn` la comprobación de
  `activeOnMap` frente a `LimiteWave`.
- Las nuevas cuentas en `DevWave_Slots`/`Reparto`.
- Un tope por tipo sin límite.

**Entradas:** hasta 6 por tipo (una por bot, juntando "por tipo" y "base"). Más élites, jefe y refuerzos, unas 81 de las
100 de `WAVE_MAX_SLOTS`.

**Riesgos:**
- **Más enemigos en las waves altas:** en la wave 10, ×2,7 con 1 jugador y ×4,4 con 3. Las primeras waves quedan más
  suaves.
- **Más oro:** el oro por muerte sube en la misma proporción. Hay que reajustar la economía junto con los precios.
- **Composición:** se carga hacia los tipos más viejos (base 30 del primero contra 1 del último en la wave 10). "Por
  tipo" da 6 × J de cada tipo sin mirar su fuerza: con 3 jugadores salen 18 `ntrd` en la wave 10, contra 4 ahora.
- **Con pct 100**, cada jugador extra suma una wave entera de un jugador. Ahora suma +50%.

**Preguntas:**
- ¿Las élites (1 por tipo) cuentan dentro del límite?
- ¿Los refuerzos del jefe siguen? ¿Entran en la cola, dentro del límite?
- Si cambian los jugadores a mitad de wave: propuesta de fijar el total al empezar, recalcular el límite en cada
  aparición y no quitar nunca pendientes.
- ¿Peso por tipo para las unidades fuertes?

### Decisiones del usuario (04/11/2026)

- **Porcentaje de la base** configurable de 0 a 200, con 100 por defecto: constante `DevWave_PCT_BASE`, acotada a ese
  rango.
- **Intervalo de aparición:** 0,10 s (ahora 0,25). El aviso de 1,5 s se mantiene.
- **Reparto equilibrado entre los 6 bots.** Ningún bot debe quedarse sin pendientes mientras otros siguen cargados,
  porque con el tope de 40 por bot eso frena la wave.

### Diseño del reparto (propuesta del agente)

- **El problema hoy:** cada entrada está atada a un dueño desde que se crea. Si un bot vacía las suyas, sólo quedan
  los demás, cada uno con 40 como máximo, y el límite de la wave no se alcanza.
- **Propuesta:**
  - Los pendientes de cada tipo son un único fondo, sin dueño.
  - En cada aparición se elige el tipo cuya fracción pendiente (pendientes / total) sea mayor. Así la mezcla de tipos
    se mantiene toda la wave, sin RNG.
  - El dueño se elige en ese momento: el bot con menos vivas y por debajo de 40 (`WavePickDefaultOwnerPid` ya lo
    hace).
  - Con eso, las vivas por bot quedan en torno a `LimiteWave / 6`. El tope de 40 sólo actúa cuando el límite es 240.
- **Consecuencia:** "1 por bot" y `BotsBase` siguen sirviendo para contar el total, pero ya no fijan qué bot genera
  cada unidad.
- **Cambio necesario:** se hace en el núcleo de oleadas de este mapa (`Wave_trySpawn` y `addSlotInternal`): entradas
  sin dueño, con el dueño elegido al aparecer y el tope global. No se tocan los originales de WaveSys.
- **Comprobar en la prueba:**
  - vivas por bot en cada segundo (que la diferencia entre bots sea de 1 como mucho mientras queden pendientes);
  - tiempo de la wave;
  - coste por cuadro a 0,10 s, que en el primer golpe llega a 150 apariciones en 15 s con 3 jugadores en la wave 10.

### Respuestas del usuario (04/11/2026)

1. **Élites:**
   - Entran en el límite. El tope de 40 vivas por bot es estricto: nunca 41.
   - **Aparición repartida.** Con E tipos de élite en la wave, el total de enemigos se divide en E secciones. Con una
     sola élite, sale cuando ha muerto la mitad del total.
   - **Una élite por jugador activo** en cada aparición.
   - **Objetivo fijo:** cada élite sigue sí o sí a su jugador, y no se juntan 4 o 5 sobre uno. Mira las vidas de ese
     jugador (`Vidas_Actual`); si llega a 0, elige otro jugador vivo al azar, con RNG sincronizado.
2. **Refuerzos del jefe:** siguen, y entran en la cola dentro del límite.
3. **Si un jugador se va a mitad de wave:** no se cambia nada. Su élite, si la tenía, cambia de objetivo como con 0
   vidas.
4. **Tipos fuertes:** salen como los demás.
5. **Aparición:** cada 0,10 s.
6. **Aviso de aparición de WaveSys:**
   - Primero un efecto en el punto ("In") y, 1,5 s después, la unidad con su efecto ("Out").
   - Ya está en el núcleo (`WaveSpawnFx`, ajustes 1-19), pero hoy todas las entradas usan el ajuste 0, sin efecto.
     Basta con darles un ajuste.

### Decisiones finales del usuario (04/11/2026)

- **Élites:**
  - Salen a puntos iguales: la i de E sale con `i × Total / (E + 1)` muertes (Total fijado al empezar). Con 1 → 50%;
    con 2 → 33% y 67%.
  - Su vida es el 70% de la del jefe, sin multiplicar por jugadores, porque sale una por jugador.
- **Refuerzos del jefe:**
  - Se quita el tope de vivos por tipo; sólo cuenta el límite de la wave.
  - Cada llamada trae 2 de cada tipo de la wave, más 2 del tipo nuevo de esa wave, que así suma 4 y se ve más.
- **Efectos de aparición:**
  - Ajuste 1 (MassTeleport) sólo para los refuerzos.
  - Ajuste 17 (ControlMagic / DarkRitual) para las élites.
  - Ajuste 2 (Resurrect) para el jefe.
  - El resto de unidades de la wave usan al azar uno de los otros 16 en cada aparición. El azar se tira en la
    elección sincronizada del núcleo.
- **Aparición cerca de un jugador:**
  - Ya está en el núcleo: `Wave_create(…, nearChance, …)`, hoy a 0%. Los objetivos son los héroes (`DevWave_AddTarget`).
  - Cuando sale, aparece a 64-256 de un héroe vivo al azar, en terreno caminable. Si no lo encuentra en 10 intentos,
    usa un punto `nPto`.
  - Propuesta del agente: 15% de probabilidad y distancia de 400-800. A 64-256 sale casi encima, aunque con el aviso de
    1,5 s.

**Por confirmar:**
- **Refuerzos:** ¿la cantidad de cada llamada escala con los jugadores (2 → 2 × J) y sigue creciendo con cada llamada,
  como ahora (× min(k, 6))? Propuesta: escala con J como la base y no crece por llamada.
- **Aparición cercana:** el porcentaje y la distancia.

## Fases propuestas (tras las respuestas)

1. **v14i-a:** velocidades, teleport de élites y rachas del jefe. Prueba de un jugador con registro de velocidad y vida.
2. **v14i-b:** abastecer todo y la nueva regla de munición. Registro de oro por ronda.
3. **v14i-c:** retrato del golem y sonidos al comprar. LAN de dos clientes por `GetLocalPlayer`.
4. **Precios por tier:** después de medir el daño real, con la tabla para que la apruebe el usuario.

## v14i: sistema de generación implementado (04/11/2026)

**Respuestas del usuario a lo pendiente:**
- Los refuerzos siguen creciendo con cada llamada (× min(k, 6)) y se multiplican por jugadores.
- La aparición cercana va al 15%, con un área de tolerancia para no salir en un hueco sin salida.
- **Corrección de premisa:** el núcleo no tenía esa tolerancia. `tryGetNearUnitPoint` sólo miraba si el punto era
  caminable, y `SMART_POINT_TOLERANCE` de WaveSys es para órdenes de movimiento. Se añadió.

**Cambios, en `scripts/v14i.py`, sólo en el núcleo de este mapa:**
- **Cantidades** (`DevWave_Slots`):
  - una entrada por tipo (grupo 700 + k) con 6 × J más su parte de la base, repartida por restos mayores;
  - `DevWave_PCT_BASE` 100, acotado a 0-200;
  - límite `DevWave_Limite = min(5 × n × J, 240)`.
- **Aparición** (`Wave_trySpawn`, `pickSlot`, `PendingSpawn_execute`, `releaseEntity`):
  - tope de la wave contando reservas, y 40 por bot;
  - el tipo con la mayor fracción pendiente, sin azar;
  - el dueño elegido al aparecer (el bot con menos vivas) y guardado por unidad en `DevWave_HT`;
  - una aparición cada 0,10 s.
- **Élites:**
  - E = n eventos a `i × Total / (E + 1)` muertes de unidades normales;
  - en cada evento, una élite por jugador en partida, que sigue a ese jugador (`DevWave_HT` clave 1, en
    `WaveAIUnit_think`). Si se queda sin vidas o se va, pasa a otro al azar;
  - vida 0,70 × la del jefe.
- **Refuerzos:** `min(k, 6) × round(2 × factor)` por tipo, el doble del tipo nuevo, sin tope por tipo.
- **Efectos de aparición:** 1 refuerzos, 17 élites, 2 jefe; el resto, uno al azar entre 3-16, 18 y 19, tirado al
  reservar.
- **Aparición cercana:** 15%, a 400-800 de un héroe, con tolerancia:
  - camino recto caminable cada 32 desde el héroe;
  - al menos 6 de 8 puntos libres a 128;
  - una sonda de objeto (`'afac'`) que no se desplaza, para detectar árboles y bloqueadores.

**Archivos:**
- `scripts/v14i.py`, `prueba_v14i.py`, `hacer-v14i.sh [RONDA] [RJ]`, `entrar-v14i.sh`, `entrar-v14i-prueba.sh`.
- Sólo cambia `war3map.j` sobre `TerrainDev-Titulo-v14h.w3x` (`87d98b18…`).

**Validated:**
- pJASS correcto en `v14i` y `v14i-prueba`.
- `war3map.j` reextraído igual, `w3u` igual al de v14h, `mpq verify` correcto.
- `TerrainDev-Titulo-v14i.w3x`: `5c48ded9…3466714`.

**Tested in map, un jugador, primera pasada (`v14i-prueba/try1/registro.txt`):**

| | Ronda 5, J = 1 | Ronda 6, contando 8 jugadores |
|---|---|---|
| Total y límite | 52 / 25 | 560 / 240 |
| Eventos de élite | a 9, 18, 26, 35 y 44 muertes | cada 80 muertes |
| Vida de las élites | 2240 (70% de 3200) | 2660 |
| Refuerzos, llamada 1 | 2 por tipo, 4 del nuevo | 16 por tipo, 32 del nuevo |
| Efectos | 1: 12 refuerzos, 2: 1 jefe, 17: 5 élites; 52 normales en los otros 16 | 1: 112, 2: 1, 17: 6; 560 en los otros 16 |
| Apariciones cercanas | 9, a 448-754 del héroe | 103 (≈ 15%) |
| Duración | 46 s | 89 s |

- Cada élite sigue al jugador 0. La ronda acaba cuando todo salió y murió.
- Las vivas por bot difieren en 1 como mucho (5 4 4 4 4 4).
- Esa pasada mataba tan rápido como salían, así que no llegó a los topes de 240 y 40 por bot. La segunda pasada deja
  llenar el mapa 30 s.
- **Observación:** con 8 jugadores la vida del jefe fue 22800 (3800 × 6), no × 8. La mejora `'Rdjv'` llega hasta
  × 6. Esto venía de antes y sólo afecta a más de 6 jugadores.

**Tested in map, un jugador, segunda pasada (`v14i-prueba/try2/registro.txt`, ronda 6 contando 8 jugadores, sin matar
en los primeros 30 s):**
- El mapa se llena a 10 por segundo con los bots iguales: 30 (5 cada uno), 120 (20), 230 (39 39 38 38 38 38).
- A los 24 s queda en 240/240 con 40 en cada bot. Máximos de la ronda: `maxBot=40`, `maxMapa=240`; nunca 41.
- Al matar después, los pendientes reponen la cola y los bots se vuelven a igualar.
- Ronda completa en 97 s: 560/560 muertes, 6/6 eventos de élite, 96 apariciones cercanas, efectos 1: 112, 2: 1, 17: 6.
- La prueba se cerró al empezar la ronda 7 (736 en total, límite 240), sin esperar a su final.

**Tested in multiplayer (LAN con ydhost y dos clientes en esta misma PC, 04/11/2026):**
mapa `TerrainDev-Titulo-v14i-lan.w3x` (d0f151c9…db921d), puente `scripts/puente_lan_v14i.py`, lanzador
`scripts/lan-v14i.sh 1`; evidencia en `v14i-lan/lan/try1/` (82 registros por cliente en `lat/`, 62 capturas por
cliente en `f/`, registro de ydhost).
- Los 82 registros de J1 y J2 son idénticos (estado cada 2 s: vivas, bots, pendientes, muertes, élites y objetivos,
  posición de héroes). Sin desincronización ni desconexión en el registro del host.
- Ronda 2 (J=2, total 30, límite 20): 2 eventos de élite (a 10 y 20 muertes), cada uno con 2 élites, una con objetivo
  J1 y otra J2. Las cuatro se acercan a su jugador (p. ej. élite 0 hacia J1: 6350→5552; élite 3 hacia J2: 5591→4897).
- Ronda 3 (total 50, límite 30): primer evento con 2 élites; al retirar a J2 (`Vidas_Retirar`, como sin vidas), su
  élite pasa a seguir a J1 en el mismo segundo (5>1 → 5>0) y avanza hacia él (6690→5662). Los dos eventos siguientes
  traen una sola élite, con objetivo J1.
- Refuerzos del jefe repartidos 2 por bot; bots equilibrados en todo el ensayo.
- ydhost.cfg y map.cfg restaurados (comparados con `.orig`).

**No comprobado:**
- Salida real de un jugador del juego (se probó la retirada por vidas, que usa la misma comprobación de jugador válido).
- Más de dos jugadores; otra PC o red real.
- Que la tolerancia evite huecos cerrados concretos del terreno. Sólo se midieron las distancias y la cantidad.
- Coste por cuadro con 240 vivas (no se midieron FPS).
- Mapa de prueba vigente (rondas 5 y 6): `TerrainDev-Titulo-v14i-prueba.w3x`.

## v14j: minimapa con el terreno ensanchado (04/11/2026, evaluación)

El usuario ensanchó el terreno 48 casillas a cada lado en `puntos/Swamped-Puntos-v14g.w3x` (199 × 133 jugable).
`scripts/terreno_v14j.py` lo pasa al mapa con las franjas planas y selladas, y `scripts/v14j.py` ensancha los límites
de `main`. Mapa `TerrainDev-Titulo-v14j.w3x` (2c75e112…6d494): sólo **Validated** (pJASS, reextracción, mpq verify).

**Tested in map** con pings en puntos conocidos (`scripts/vista_v14j.py`, `scripts/vista.sh`, evidencia en
`evidencia/vista-v14i-vista` y `evidencia/vista-v14j-vista`):
- El minimapa no muestra el terreno ni el área jugable: dibuja la zona de los límites de cámara del jugador, estirada a
  todo el recuadro (las esquinas -7296,-7296 y 5888,5632 caen en las esquinas; lo que queda fuera se pega al borde).
  En partida esos límites son `bj_mapInitialCameraBounds`, fijados desde v14e a la zona de juego, así que v14i y v14j
  dan el mismo minimapa. Ensanchar el terreno sólo cambia algo si se ensanchan también esos límites (la cámara podría
  entonces ir a las franjas, que están bajo la máscara negra).
- En la tienda (y la intro) los límites son un punto de 2 × 2: la zona del minimapa es menor que la vista y el
  recuadro blanco sobresale. Probado en la tienda: límites de ±900 × ±1400 y la cámara fijada a un `dumi` en el centro
  (`SetCameraTargetController`) dejan el recuadro dentro; con las flechas la cámara se desplazó 51 en una lectura y
  volvió al centro. Ese salto momentáneo podría mover los trackables mientras el jugador desplaza la cámara.
- Pendiente de decisión del usuario; nada integrado en el mapa normal.

**Idea del usuario: límites más altos con la franja nueva bajo la máscara negra (04/11/2026, Tested in map).**
`scripts/vista2_v14j.py` y `scripts/hacer-vista2.sh` cambian sólo `bj_mapInitialCameraBounds` sobre v14j-vista;
evidencia en `evidencia/vista-vista2-A`, `evidencia/vista-vista2-B` y `evidencia/minimapa-v14j-A-B.png`.
- Lo que está bajo la máscara negra no se pinta en el minimapa: se ve el fondo de la consola. Sólo queda negra la
  zona visible (la de juego, visible siempre desde línea ~19996, y el rectángulo de la tienda de ~19997).
- El minimapa no estira la zona: la encaja conservando la proporción y marca sus bordes con líneas grises.
- A (X -13440..12032, Y -7296..9728, apaisada): el cuadro negro queda dentro de la consola, sin sobresalir; el
  recuadro blanco es pequeño. Arriba se ve la muesca del rectángulo visible de la tienda.
- B (sólo más alta, vertical): sigue sobresaliendo por arriba, ahora con la muesca de la tienda. Descartada.

**Integrado en v14j (04/11/2026, decisión del usuario: «A en todo»).** `scripts/v14j.py` fija
`bj_mapInitialCameraBounds` a la variante A; la intro, el título y la tienda usan esos límites en lugar del punto de
2 × 2, y la cámara se fija con `SetCameraTargetController` a `Menu_Ancla[0]` (título, creado en `Title_Camera`, que
sólo corre en temporizadores sincronizados) o `Menu_Ancla[1]` (tienda, creado en `Shop_Construir`). Mapa
`TerrainDev-Titulo-v14j.w3x` 92497b84…90d21b: **Validated** (pJASS, reextracción, mpq verify).
**Tested in map** (un jugador, sin LAN; `scripts/vista3_v14j.py`, `scripts/vista3t_v14j.py`):
- Tienda (`evidencia/vista-v14j-vista`): cámara en 2400, 8700 todos los segundos, también con las flechas; al cerrar
  vuelve al héroe. Recuadro dentro del minimapa.
- Con el bloqueo la cámara informa el ojo 127,25 más alto. Compensarlo con ZOFFSET ampliaba la tienda 1,4 veces; sin
  compensar (`evidencia/vista-v14j-dz0`) la tienda coincide píxel a píxel con v14i (0 de 364 800 distintos).
- Intro y título (`evidencia/vista-v14j-intro` frente a `evidencia/vista-v14i-intro`): cámara fija en 0, 8700 durante
  40 s con flechas; título igual que v14i salvo la nebulosa animada (≤ 0,9 % de píxeles).
- Pendiente: clics reales en título y tienda, y LAN de dos clientes (el bloqueo de la tienda va dentro de
  `GetLocalPlayer`, sólo cámara).
- Corrección (04/11/2026): la cueva de acantilado YCr2 y dos rampas estaban desplazadas porque los doodads
  especiales de `war3map.doo` van por casilla. `terreno_v14j.py` los corre 48 casillas. Mapa v14j actual:
  a7fd6f0d…25e98. Informe: `informes/errores/resueltos/2026-11-04-225652-v14j-cueva-desplazada.md`.
- Entrega para que juegue Leon (04/11/2026): `TerrainDev-Titulo-v14j.w3x` a7fd6f0d…25e98 (sin registros),
  `v14j-prueba` 5993ca36…69c02 (entrada directa) y `v14j-prueba-intro` 1a3a7a4f…71924 (con intro). Los dos de prueba
  salen de `scripts/prueba_v14j.py`, sin atajos, con un registro de cámara, tienda y ronda cada 2 s en
  `lat/v14j-*.txt`. Lanzadores: `scripts/entrar-v14j.sh`, `scripts/entrar-v14j-prueba.sh` y
  `scripts/entrar-v14j-prueba-intro.sh`. Prueba corta de la directa (40 s, `evidencia/vista-v14j-prueba-humo`):
  arranca y registra.

## v14k: retratos vivos, voz del comprador y «Abastecer todo» (04-05/11/2026)

Pedido del usuario:
- en la tienda, el retrato del golem y el de la unidad que compra, en lugar de la imagen fija;
- una voz al azar del comprador al comprar un arma;
- un botón «Abastecer todo» que, si el oro no alcanza, lo reparte entre las armas;
- una variante que abre la tienda con las zonas de clic pintadas.

La velocidad, el teletransporte de las élites y las ráfagas del jefe siguen aplazados.

Construcción:
- `scripts/hacer-v14k.sh` construye todo a partir de v14j, usando `scripts/v14k.py`, `objetos_v14k.py`,
  `retrato_golem.cjs`, `retrato_sin_billboard.cjs` y `zona_clic.py`.
- Retratos: unidades 'dgo0', 'dts0' y 'dcs0' a profundidad 405, sin billboard. El giro va en una secuencia global;
  con billboard no se ven lejos de X 0.
- Marco: `StratFrame` (DT3E) de la selección de héroe, delante del retrato, de 298 × 290 px.
- La voz es una de 7 por personaje (Hero_Choice 1 = Cairne). Sonido, escala y animación van dentro de
  `GetLocalPlayer`; el azar se elige fuera.
- «Abastecer todo» (`Shop_Todo`) reparte por rondas: `oro / armas restantes`. Llena las que caben y compra
  balas proporcionales en las demás.

Mapa `TerrainDev-Titulo-v14k.w3x` 3a2067df…654056d0:
- **Validated**: pJASS, reextracción y mpq verify.
- **Tested in map**: recorrido automático `scripts/vista_v14k.py`, en `evidencia/vista-v14k-vista2` a `vista5`.

  | Oro | Antes | Después |
  |---|---|---|
  | 10 | tres armas vacías | 8/72, 14/320 y 10/250 |
  | 100 | todas vacías | pistola llena, 182/320 y 123/250 |
  | 0 | — | error, sin cambios |
  | 99999 | todas vacías | todo lleno |

- **Tested in multiplayer**: LAN con dos clientes (`scripts/puente_lan_v14k.py`, `scripts/lan-v14k.sh`,
  `v14k-lan/lan/try1` a `try3`).
  - Los registros de los dos clientes son idénticos: oro, reservas, tienda abierta, estado de los jugadores y azar.
  - Al comprar a la vez, J1 ve al Tauren y J2 a Cairne. Con la tienda de J1 cerrada, J2 la sigue viendo.
  - En `try1` el golem salió enorme un instante al abrir; quedó corregido con la secuencia global (`try3`).

Abierto: las zonas de clic pintadas (v14k-tienda, v14k-vista) no se dibujan. Los clics sí funcionan. Informe en
`informes/errores/2026-11-04-235244-tienda-v14k-retratos-y-zonas-pintadas.md`.

Entregas y lanzadores:
- `v14k`: `scripts/entrar-v14k.sh`.
- `v14k-prueba`: `scripts/entrar-v14k-prueba.sh`.
- `v14k-prueba-intro`: `scripts/entrar-v14k-prueba-intro.sh`.
- `v14k-tienda`: `scripts/entrar-v14k-tienda.sh`.

En las variantes de prueba, el chat acepta `-oro N` y `-vaciar`.

## v14l: tipos de daño y armaduras (05/11/2026)

Scripts en `work/titulo-devmission-20261026/scripts`:
- `v14l.py`: tipo de daño por arma (`Arm_Tipo`, `Bala_Tipo`, `Dano_Ataque`) en las tres llamadas a `UnitDamageTarget`
  y tres líneas nuevas en la tienda (tipo, eficaz, débil).
- `objetos_v14l.py`: `udty` de 31 unidades y tabla `DamageBonus*` en `war3mapMisc.txt`.
- `hacer-v14l.sh`: construye las variantes.

Tipos de daño por categoría:

| Categoría | Daño |
|---|---|
| Pistolas, subfusiles y cuerpo a cuerpo | Perforante |
| Rifles y escopetas | Impacto |
| Francotiradores | Antiblindaje |
| Explosivos | Explosivo |

Armaduras:

| Unidades | Armadura |
|---|---|
| ntrh, nmsn | Orgánica |
| nmcf, nnsw | Ágil |
| nmtw, nmmu | Acorazada |
| nlpr, nlds | Caparazón |
| ntrg, ntrd | Pétrea |
| Élites | Como su base |
| Jefes | Colosal |
| Personajes | Ranura `normal` («Jugador»), con la columna hero de antes |

Etérea quedó sin ranura.

Mapa `TerrainDev-Titulo-v14l.w3x` 73752bc0…:
- **Validated**: pJASS, reextracción y mpq verify.
- **Tested in map**: medición de la tabla con `TerrainDev-Titulo-v14l-dano.w3x`
  (`prueba_dano_v14l.py`, `objetos_dano_prueba.py`, evaluada con `leer-dano-v14l.py`).
  - Registro en `v14l-dano/lat`; resultado en `v14l-dano/resultado.txt`.
  - **OK en las 56 casillas** con 8 unidades sin defensa.
  - La tabla de `war3mapMisc.txt` se aplica en 1.27b.
  - Con `DAMAGE_TYPE_MAGIC` (el de las armas) la defensa `udef` no reduce nada: solo cuenta la tabla. Con
    `DAMAGE_TYPE_NORMAL` sí la reduce (6 % por punto).
  - Los personajes reciben lo mismo que antes: Perforante 50 %, Impacto 100 %, Antiblindaje 50 %, Verdadero 100 %.

Pendiente:
- Ver las líneas nuevas de la tienda en el juego (`scripts/entrar-v14l-tienda.sh`).
- Iconos de tipos.
- Probar el equilibrio de las oleadas jugando.

Lanzadores:
- `v14l`: no hay lanzador propio todavía.
- `v14l-prueba`, `v14l-prueba-intro` y `v14l-tienda`: `scripts/entrar-v14l-*.sh`.
- Medición: `scripts/entrar-v14l-dano.sh`.

### v14l, cambio del 05/11/2026 (decisión de Leon)

Las armas cambian a `DAMAGE_TYPE_NORMAL` (`Dano_TipoArma`), así que la defensa `udef` de los enemigos sí reduce el daño
(6 % por punto).

De momento todas las armas usan **Estándar**: la ranura Chaos, que hace 100 % contra toda armadura. Las diferencias
entre enemigos solo vienen de su defensa.

Los demás tipos, la tabla y las armaduras quedan listos para más adelante: basta con cambiar `CATEGORIA` en `v14l.py`.

La tienda muestra «Daño Estándar» y su descripción, sin líneas de eficaz o débil.

Mapa `TerrainDev-Titulo-v14l.w3x` e503057b…:
- **Validated**.
- La medición la evalúa `leer-dano-v14l.py`, que ahora exige defensa en las reales; ya se probó con un registro
  sintético.
- Falta ejecutarla en el juego.

Después, también a petición de Leon:
- Todos los enemigos (oleada, élites y jefes) llevan una sola armadura: `medium`, Acorazada.
- El reparto acordado queda en `LUEGO`, dentro de `objetos_v14l.py`.
- Mapa `TerrainDev-Titulo-v14l.w3x` 1072fb79…: **Validated**; la medición en el juego sigue pendiente.

Balance por tamaño (`objetos_v14l.py`, `TALLA`):

| Tamaño | Unidades | Defensa | Velocidad |
|---|---|---|---|
| Pequeños | nmcf, nlpr, ntrh, nnsw | 0 | 320 |
| Medianos | nmtw, nmsn, nlds | 3 | 270 |
| Grandes | nmmu, ntrg, ntrd | 6 | 230 |

- Élites: +2 de defensa sobre su tamaño. Jefes: +4.
- Antes todos iban a 270 de velocidad, con defensas de 0 a 6.
- La vida y el ataque no cambian.
- Mapa `TerrainDev-Titulo-v14l.w3x` 5fcbcb2d…: **Validated**; falta la medición y jugarlo.

Élites (Leon, 05/11/2026):
- Escala ×1,8 sobre su modelo (antes ×2,1), con selección y UnitHitShape a juego.
- Barra de vida a 80 sobre la cabeza (antes 110).
- Vida 0,40 de la del jefe de la ronda (antes 0,70): base 320 en el w3u.
- Mapa `TerrainDev-Titulo-v14l.w3x` afe8c2c0…: **Validated**; falta verlo en partida.

## v14m: habilidades del Prawn (05/11/2026)

Pedido de Leon: las unidades normales con una versión menor de la habilidad de su élite y jefe, y otro conjunto de
refuerzos para sí mismas y aliados alrededor. Primera familia: Prawn (`nlpr`, élite `ne01`, jefe `nj02`).
Fuente `scripts/v14m.py` sobre `v14l/war3map.j`; sólo cambia el j. `hacer-v14m.sh` construye v14m (sin registros),
v14m-prueba y v14m-prueba-intro (con registro de habilidades `lat\v14m-hab-N.txt`) y v14m-habil (sin oleadas, Prawns
alrededor del personaje, mide daño y defensa; evalúa `leer-habil-v14m.py`).

| Nivel | Embestida | Caparazón |
|---|---|---|
| Normal | 1 de cada 3, a ≤ 450: aviso 0,4 s, 300, 8 de daño; cada 15-25 s | Endurecer: bajo 50 % de vida, +3 defensa 5 s, una vez |
| Élite | contra su jugador a ≤ 650: aviso 1 s, 600, 18; cada 10-14 s | cada 14 s cerca de un jugador: +3 a sí y aliados en 400 durante 6 s |
| Jefe | 3 seguidas, una por jugador: aviso 1 s, 800, 30; cada 12 s | cada 18 s: +5 defensa y +15 % de ataque en 700 durante 8 s |

Daño +10 % por ronda desde la 2. Defensa con las habilidades de objeto 'AId3'/'AId5', ataque 'AIsx'. La embestida
para en lo no caminable (IsTerrainWalkable). El jefe aplaza la llamada de refuerzos si está embistiendo. Sin
GetLocalPlayer: prueba de un jugador suficiente.

Estado: **Validated** (pJASS en las cuatro variantes, j reextraído igual, mpq verify). Hashes: v14m c4a13118,
v14m-prueba 6ccb3425, v14m-prueba-intro 3454332c, v14m-habil 530ddf54. Pendiente: v14m-habil en el juego y la vista.

## v14n: sin habilidades del Prawn; avisos de ShootingGay importados (05/11/2026)

Leon: las habilidades se van a rehacer, así que v14n quita la última hecha (Prawn, v14m) y vuelve al `war3map.j` de
v14l (idéntico por cmp). Además importa, **sin usarlos todavía**, los avisos de habilidad de ShootingGay 0.7ENG
(ver `work/titulo-devmission-20261026/fuentes/shootinggay-0.7/HALLAZGOS.md`). **Créditos:** recursos de los autores de
ShootingGay 0.7ENG (modelos de aviso, texturas de rayo y filas de LightningData.slk).

- 14 modelos v800 en `war3mapImported\`: DangerousCircle, bossjinggaoh, BigDangerous, SpawnCircle, Snipe Target,
  ExclamationMarkMini, az_firering1a, CommandAuraTarget, MrWar3_XZ4 (y Pink), LightningCircle, LightningGround,
  WhiteBox, WhiteBox3X2. Sus 7 texturas propias van en la raíz, donde las piden; las demás son del juego (comprobado
  en los MPQ de 1.27b). Todas en potencia de dos y ≤ 512.
- `Splats\LightningData.slk` = el de War3x.mpq + 9 rayos (AIMI, BLAS, ARLE, BLNK, BOLG, BLSR, BLNP, WLSR, B3LS) y sus 7
  texturas en `ReplaceableTextures\Weather\` (`scripts/rayos_v14n.py`). El de ShootingGay no se copia tal cual: le falta
  LEAS. No se importa su `SpellAreaOfEffect.blp`, que cambiaría el círculo de área del juego.
- Construcción `scripts/hacer-v14n.sh`: pJASS correcto, reextracción igual por hash de los 30 miembros, `mpq verify`
  bien; frente a v14l sólo cambian (listfile) y (attributes) y se añaden los 29 archivos.
  SHA-256: v14n 3a666349, v14n-prueba d9d4e78a, v14n-prueba-intro 2350e1fb.
- Estado: **Validated**. No probado en el juego; como nada usa los recursos, el juego sólo debería cambiar si el SLK
  nuevo fallara al cargar (los rayos del juego quedan iguales).

## v14o: bala por categoría y color por tier, granada en arco y ajustes de armas (05/11/2026)

Parte de v14n (la línea entregada; v15c sigue como prototipo aparte). Scripts en `work/titulo-devmission-20261026/scripts`:
`v14o.py`, `prueba_v14o.py` (variantes prueba, prueba-intro y auto), `hacer-v14o.sh` y `entrar-v14o*.sh`.

- Bala por categoría; el tier sólo cambia el color. T1 es Yellow, T2 Green y T3 Cyan, los tres primeros de la paleta de
  tiers de v15.

  | Categoría | Bala |
  |---|---|
  | Pistola | Shot |
  | Subfusil | Shot II |
  | Rifle y francotirador | Daemonic Arrow ajustada |
  | Escopeta | Firebrand (el Cyan es Teal) |
  | Explosivos | Chain Grenade |

  El Windwalk y el dash siguen con el color del jugador.
- **Chain Grenade** (Vinz, Hive 315385; dar crédito):
  - El zip va copiado en `TerrainDev/assets/chain-grenade/origen` sin cambios: Blue, Green, Orange y Purple.
  - Yellow, Cyan y Red son la Blue teñida (`TerrainDev/scripts/chain_grenade_colores.cjs`, manifiesto en la carpeta).
  - Todas sus texturas son del juego: War3x.mpq y war3.mpq de 1.27b.
- **Granada:** va en arco (0,85 rad, 900 de velocidad) al punto del lanzamiento, entre 150 y su alcance. No choca por el
  camino y sólo daña al caer. La explosión es su animación Death; se quita FireLordDeathExplode.
- **Ráfaga:** se mide en tiempo, 1,5 s al ritmo del arma (`Arm_Rafaga`); antes eran 6 tiros fijos.
- **Pistola:** intervalo 0,2143 / 0,1875 / 0,1667, es decir 7 / 8 / 9 tiros por ráfaga.
- **Subfusil:** dispersión 8 / 5 / 5 (+2°). La animación va a 1 / intervalo (8,3 / 11,7 / 9,2; antes 4).
- **Rifle:** cada tiro suma 0,8° de dispersión, hasta 12° extra, aunque se relance. Vuelve a 0 al terminar la ráfaga,
  al recargar o con el dash (`s__RapidPair_finish`).
- **Francotirador:** un tiro cada 0,50 s (3 por ráfaga), daño 240 / 320 / 450 y atraviesa 2 / 3 / 4 enemigos.
- **MissileRecycler:** ya estaba activo en v14n. No se cambia.

Estado:

- **Validated:** pJASS en las 4 variantes, j y 19 imports reextraídos iguales, `mpq verify` correcto.
- SHA-256:

  | Mapa | SHA-256 |
  |---|---|
  | v14o | 3e2bd80a |
  | v14o-prueba | d00a3a66 |
  | v14o-prueba-intro | ae331785 |
  | v14o-auto | 95401269 |

- **Tested in map** (un jugador, v14o-auto, registro y 21 capturas):
  - Tiros por ráfaga iguales a lo esperado en las 18 fases que dispararon. En la escopeta se cuentan perdigones.
  - El modelo de la última bala es el de su categoría y tier en todas.
  - La granada cae a 11,5 del punto. No daña a los 3 soldados que sobrevuela; sí al que está en el punto.
  - Rifle: dispersión extra 4,8 → 8,8 → 12 mientras se relanza; 0 al parar y 0 tras el dash.
  - Francotirador: 3 tiros por ráfaga, que atraviesan a los 4 blancos.
  - Al terminar, RapidBolt vivos 0.
- **Fallos:**
  - Una orden de disparo rechazada (francotirador T1), que es el punto 4 del informe
    `informes/errores/2026-11-05-200240-v15a-refrescar-y-barra.md`.
  - La ráfaga de granada T2 se cortó a 1 tiro porque el actor cayó ante la oleada 1. La prueba hacía invulnerable a
    `Game_Hero`, no al actor: es un fallo del ensayo, no del arma.
- **Sin comprobar:**
  - El arco visto de cerca: con la cámara cenital apenas se aprecia.
  - El balance en partida completa.
  - LAN: no se toca GetLocalPlayer.

## v14p: seis tiers por arma con mejoras por tier (05-06/11/2026)

Pedido de Leon: llenar las filas que quedaban en la tienda con armas nuevas (el prototipo tenía seis). Cada tier mejora
el daño, el cargador, la reserva, la velocidad de la bala y los tiros por ráfaga de 1,5 s. La precisión es la misma en
todos los tiers de una categoría, y rifle y escopeta salen ya rápidos. Números elegidos por el agente, en
`scripts/armas_v14p.py`; fuentes `v14p.py`, `objetos_v14p.py`, `prueba_v14p.py` y `hacer-v14p.sh`.

| Categoría | Tiros T1→T6 | Daño T1→T6 | Bala | Otros |
|---|---|---|---|---|
| Pistolas | 7→12 | 22→72 | 1200→1700 | atraviesa 0→2, crítico T5–T6 |
| Subfusiles | 12→22 | 7→19 | 1300→1800 | crítico 0→20 % |
| Rifles | 14→20 | 9→26 | 1800→2400 | atraviesa 0→2, crítico 0→20 % |
| Francotiradores | 3 | 240→880 | 2400→3000 | atraviesa 2→7, crítico 0→35 % |
| Escopetas | 6→9 | 14→24 | 1700→2200 | perdigones 5→8 |
| Cuerpo a cuerpo | intervalo 0,25→0,15 s | 30→92 | — | cono 220→260 |
| Explosivos | 6→8 | 60→240 | 900→1150 | área 200→320 |

Precios T2→T6 de unos 250 a 6500 (el registro de v15c llegó a unos 38 000 de oro en la ronda 9). Armas nuevas: Browning
Hi-Power, Beretta 92, Glock 17; PPSh-41, Uzi, MP5; M16, Steyr AUG, FN SCAR; Dragunov SVD, Barrett M82, AWM; Ithaca 37,
Remington 870, SPAS-12; Ka-Bar, Tomahawk táctico, Bayoneta M9; Stielhandgranate 24, RGD-5, M67.

Cambios:

- Arma `w = categoría × 6 + tier − 1`; velocidad por arma en `Arm_Vel`; clave del HUD `c × 8 + tier`.
- Colores: Yellow, Green, Cyan, Blue, Purple, Red. «T1»..«T6» con su color en la tienda y el HUD (`Arm_TierTexto`).
- Imports nuevos: Daemonic Arrow Blue/Red/Purple, Chain Grenade Blue/Purple/Red (Red teñida), sus texturas y RoyalGlow.
- Tienda: seis filas (texttags 24..29 para las filas 4..6, trackables 10..15). El tipo de daño pasa al panel izquierdo.
- Aw00..Aw06 con 6 niveles; cada nivel copia los campos del nivel 1 para conservar la orden propia.

Estado:

- **Validated:** pJASS en las 4 variantes, j, w3a y los imports reextraídos iguales, `mpq verify` correcto.

  | Mapa | SHA-256 |
  |---|---|
  | v14p | 16ac61c4 |
  | v14p-prueba | a59e100f |
  | v14p-prueba-intro | 5ef8a695 |
  | v14p-auto | 412ad578 |

- **Tested in map** (un jugador, v14p-auto, dos corridas; la segunda tras mover el tipo de daño):
  - Las 36 ráfagas dieron los tiros esperados, con la velocidad y el modelo de color de su tier.
  - Atravesar funciona. Las granadas caen a 5–26 del punto y sólo dañan al blanco del punto.
  - Dispersión del rifle 4 → 8 → 12; 0 al parar y tras el dash.
  - Capturas de la tienda con 6 filas y estados Obsoleta / En uso / precio / Bloqueada.
  - Texttags libres: 61 sin tienda, 15 con la tienda abierta.
  - Corrida 2: RapidBolt vivos 0 al final, COMPLETE.
- **Visto una vez, sin reproducir:** la corrida 1 acabó con RapidBolt vivos −1. Causa sin identificar.
- **Sin comprobar:**
  - LAN de dos clientes (la tienda usa GetLocalPlayer).
  - Balance y economía en partida completa. La munición completa a T6 cuesta unos 1650.
  - El color del «T» en el HUD (las capturas no lo distinguen).
  - Margen de texttags: con la tienda abierta quedan 15.

Créditos: Vinz (Shots, Firebrand, Chain Grenade); Vinz y Daemonic Sword (Daemonic Arrow, Hive 337124); ShootingGay 0.7ENG.

## v14q (06/11/2026): alcance por tier, precarga y cadáveres de las oleadas

Pedido de Leon: que se note más el alcance de las armas en las mejoras; quitar el lag cuando salen y mueren muchas
unidades de golpe; investigar cómo se precargan bien los recursos del mapa, evaluar y contrastar.

Alcance por tier (`scripts/armas_v14q.py`, `ALC`). Sale primero y en azul (`|cff7fd4ff`) en la tienda y en el texto
de cada nivel de Aw00..Aw06:

| Categoría | T1 → T6 |
|---|---|
| Pistolas | 800, 900, 1000, 1100, 1200, 1300 |
| Subfusiles | 700 → 1200 (+100) |
| Rifles | 1100, 1200, 1300, 1400, 1500, 1650 |
| Francotiradores | 1500, 1650, 1800, 1950, 2100, 2300 |
| Escopetas | 400, 450, 500, 550, 600, 700 |
| Cuerpo a cuerpo | sin alcance |
| Explosivos | 650 → 900 (+50) |

Investigación de la precarga (Hive Workshop y documentación de natives):

- `Preload(ruta)` sólo lee el archivo a la caché del sistema en segundo plano; no carga el modelo. El motor lo carga
  la primera vez que se usa de verdad (Luashine, [hilo 252220](https://www.hiveworkshop.com/threads/252220/)).
- Los `.pld` de Blizzard son listas de `Preload` terminadas en `PreloadEnd` (Tasyen,
  [hilo 314550](https://www.hiveworkshop.com/threads/314550/)).
- Las habilidades no se precargan por ruta: hay que añadirlas y quitarlas a una unidad (xepreload, AbilityPreload).
- Las unidades se precargan creándolas y quitándolas una vez (TriggerHappy,
  [hilo 179785](https://www.hiveworkshop.com/threads/179785/)).
- Un rawcode inválido al precargar cuelga el mapa ([hilo 174304](https://www.hiveworkshop.com/threads/174304/)). Muchas
  habilidades de golpe pueden agotar el límite de operaciones: usar `ExecuteFunc`.
- Los cadáveres son unidades: ocupan memoria y entran en cada búsqueda de área. Conviene quitarlos poco después de
  morir ([hilo 330068](https://www.hiveworkshop.com/threads/330068/),
  [hilo 269138](https://www.hiveworkshop.com/threads/269138/)).
- Crear y ordenar muchas unidades a la vez cuesta más que el número de unidades: repartir la aparición
  ([hilo 226140](https://www.hiveworkshop.com/threads/226140/),
  [hilo 370384](https://www.hiveworkshop.com/threads/370384/)).

Contraste con este mapa:

- La aparición ya va repartida, una cada 0,10 s.
- Las balas buscan con `GroupEnumUnitsInRange` sin filtro, así que los cadáveres entran en cada búsqueda. En v14p se
  acumulaban (hasta 195) porque tardan más de 60 s en desaparecer.
- Cada ronda estrena un tipo normal, una élite y un jefe; antes se cargaban en mitad de la oleada.

Cambios (`scripts/v14q.py`):

- `Precarga_Todo` corre en `main`, durante la pantalla de carga. En orden hace:
  - `Preload` de los 521 imports y `PreloadEnd(2.0)`;
  - un efecto creado y destruido por cada uno de los 159 `.mdx` importados y por cada efecto de aparición;
  - crea y quita una vez los 10 tipos normales, las 10 élites y los 9 jefes;
  - añade y quita las 11 habilidades de vida de las élites a una unidad temporal.
- Cadáveres de las oleadas: un anillo de 512 con un reloj de 0,5 s los quita 3,5 s después de morir. Se engancha en
  `DevFuego_Muere`.

Prueba A/B (`v14p-estres` y `v14q-estres`, el mismo puente; analizado con `scripts/analizar_estres.py`):

- Entrada directa a la ronda 9: nueve tipos nuevos, límite 45, total 149.
- El héroe no muere; cada 10 s mueren 30 unidades de golpe; 14 matanzas.
- Cuadros medidos con la capa Vulkan como intervalo entre presents, con maxfps 60. Se quitan los cuadros de escritura
  del registro.

| | v14p | v14q |
|---|---|---|
| Cadáveres tras cada matanza | 30 → 195 | 30 o menos |
| Ronda: mediana / p99 / máx | 16,1 / 21,0 / 174 ms | 16,0 / 20,7 / 34 ms |
| Cuadros > 50 ms en la ronda | 3 (81, 174, 57) | 0 |
| Primeros 20 s (tipos nuevos): máx | 81 ms | 34 ms |
| Tras matanzas: máx | 174 ms | 29 ms |
| Carga hasta la ronda | 10,2 s | 12,1 s (precarga) |

Estado:

- **Validated:** pJASS en las 5 variantes; j y w3a reextraídos iguales; `mpq verify` correcto.

  | Mapa | SHA-256 |
  |---|---|
  | v14q | 4dcc1e1e |
  | v14q-prueba | 448de610 |
  | v14q-prueba-intro | 0d3467c9 |
  | v14q-estres | 6739836b |
  | v14p-estres | 243c94e0 |

- **Tested in map:** un jugador, una corrida por mapa, la prueba A/B de arriba.
- **Sin comprobar:**
  - El texto azul del alcance en la tienda; no se tomó captura.
  - Partida completa con balas reales. En la prueba las muertes son por daño directo, así que el coste de los
    cadáveres en las búsquedas de las balas queda sin medir.
  - LAN.
  - Con una sola corrida por mapa, los tirones aislados pueden variar entre corridas.
- **Observado:** la oleada de la ronda 9 se vacía a los 140 s. La prueba no llega al registro «fin»; el analizador
  usa la última matanza más 2 s.

## v14r (06/11/2026): relámpagos y truenos de Storm

Pedido de Leon: integrar Storm v1.3.1 primero y Dark Nights después. Recursos y procedencia en
`work/titulo-devmission-20261026/fuentes/LEEME-storm-darknights.md`.

### Cambios (`scripts/v14r.py`, `objetos_v14r.py`, `hacer-v14r.sh`)

- La biblioteca sale del j compilado del ejemplo, adaptada así:
  - Cada jugador tiene su tormenta, que sigue a su `Camera_DummyUnit`. Esa posición es la misma en todos los clientes;
    el original usaba `GetCameraTargetPosition`, que es distinta en cada uno.
  - El efecto y el trueno sólo tienen ruta para ese jugador.
  - La unidad se quita con `RemoveUnit`.
  - La niebla base es la del mapa.
- La unidad es `h00S` (StormDummy), copia de la Ldummy: Locust, vuelo, 180 animaciones.
- Imports: `war3mapImported\StormDummy.mdx`, `StormL1..3.mdx` y `StormT1..3.wav`.
- `Storm_Tick`: una tormenta cada 15–40 s con la ronda activa y fuera del descanso.
- Precarga de la unidad, las luces y los truenos (a volumen 0).
- En las variantes de prueba, el chat `-rayo N` lanza una tormenta.

### Prueba por registro (`v14r-rayos`)

Una tormenta cada 4 s, 12 en total, más las de `Storm_Tick`.

- Nunca hubo más de una tormenta activa. Al final quedaron 0 activas y 0 unidades `h00S`, en todas las corridas.
- Capturas: durante el destello el azul de la escena pasa de 17 % a 34 % y luego vuelve. De día se nota poco.
- Tirones:

  | Corrida | Cuadros | Tirones > 50 ms |
  |---|---|---|
  | 1 | 3392 | 3 (175, 179, 175 ms), a 0,16 s de lanzar |
  | 2 | 3391 | 3 (178, 175, 176 ms), a 0,16 s de lanzar |
  | Sin cambio de niebla (`v14r-sinniebla`) | 3395 | 2 (175, 176 ms), a 0,16 s de lanzar |
  | Sin efecto de luz (`v14r-sinluz`) | 3392 | 1 (176 ms), a 3,76 s; ninguno tras las tormentas |

- Causa: crear el efecto con luz direccional. Ni la niebla ni la unidad. Pasa en 2 o 3 de cada 13–14 tormentas.
- Sólo hay datos de esta PC con Wine/DXVK. Repetir la corrida no lo quitó, así que no es una caché que se llene la
  primera vez.

### Estado

- Mapas (SHA-256): v14r 7bcf438d, v14r-prueba 181ed061, v14r-prueba-intro a4638ec9, v14r-rayos 222291c9.
- **Validated:** pJASS en v14r, v14r-prueba, v14r-prueba-intro y v14r-rayos; j, w3u e imports reextraídos iguales;
  `mpq verify` correcto.
- **Tested in map:** un jugador.
- **Sin comprobar:**
  - LAN de dos clientes. Toca `GetLocalPlayer`, aunque sólo para la ruta del efecto y del sonido.
  - Que se oigan los truenos: el registro no oye y no se escuchó.
  - Si el tirón también ocurre en Windows.

## v14s: luz fija de Storm y niebla oscura (06/11/2026)

Pedido de Leon: usar un modelo con la luz siempre presente en lugar de crearla en cada destello, y oscurecer la niebla
como en el mapa original de Storm.

### Cambios

- **StormLuz.mdx** (`storm-luz/`, script `scripts/storm_luz.cjs`, SHA-256 c523b43c):
  - Es Ldummy (OVOgenez) con la luz direccional de L1 dentro, hija de `Bone_Chest`. Color 0,5/0,75/1 y giro fijo de
    secuencia global.
  - Tiene 184 secuencias:
    - 0 «Stand», apagada;
    - 1 + (v−1)·61 + (cenit+90), «Spell LuzV cenit»: encendida con la intensidad v (0,4, 0,8 o 1,2) y el giro de
      Ldummy para ese cenit (−90..−30).
  - Cada secuencia dura 1 s y lleva una sola clave sin interpolar. BoundsRadius 1e9.
  - ObjectId en orden de bloques: luz 0, ayudantes 1–2, anexos 3–5.
  - Visor 3D (chat): dirección de la luz según acimut, cenit y variante. El −Z local de la luz apunta abajo con
    elevación igual al cenit.
- **Unidad `h00S`** (`objetos_v14s.py`): ahora se llama StormLuz y usa ese modelo. Se quitan los imports StormDummy y
  StormL1..3.
- **Script** (`v14s.py`):
  - Storm_Iniciar crea una unidad persistente por jugador humano en partida.
  - La tormenta la mueve a su cámara y la gira al acimut. El primer destello llega 0,25 s después, para dar tiempo al
    giro.
  - Un destello cambia la animación sólo en el cliente del dueño; al terminar vuelve a la 0. La unidad no se destruye.
- **Niebla oscura** (`Storm_Oscuro`, al entrar en la partida):
  - Estilo 0, de 1730 a 5190, densidad 0, color negro.
  - Es la del original (1000/3000 con la cámara a 1650) escalada a la cámara de juego, cuya distancia medida es
    2856,6 en todas las tormentas.
  - Los destellos le suman su color como antes. Los menús conservan la niebla de main.

### Pruebas (un jugador, esta PC con Wine/DXVK)

| Corrida | Cuadros | > 100 ms | Dónde |
|---|---|---|---|
| `v14s-rayos-1` | 3398 | 0 (máx 37 ms) | — |
| `v14s-rayos-2` (con ráfagas de capturas) | 3403 | 1 (142 ms) | +0,13 s tras escribir el registro |
| `v14s-sinniebla-prueba` (sin cambios de niebla) | 3385 | 5 (~175 ms) | +0,16 s tras escribir el registro |
| `v14s-separado-prueba` (registro 1 s después de lanzar) | 3232 | 2 (172, 163 ms) | +0,16 s tras escribir el registro; ninguno al lanzar |

- **Corrección de v14r.** Los tirones de ~175 ms van 0,16 s detrás de la escritura del registro Preload, aunque ésta
  se retrase 1 s respecto a la tormenta. El cuadro largo empieza justo al escribir.
  - Por tanto, lo que en v14r se atribuyó a crear el efecto de luz sale, con más probabilidad, de la propia prueba.
  - Queda sin explicar por qué `v14r-sinluz` no tuvo ninguno tras las tormentas (0 de 12).
- La luz funciona: sin niebla, el destello enfría y azula el terreno (+5–7 % de brillo). Con la niebla negra, la
  escena se aclara mucho más (brillo de 250 a 507 en la variante 3).
- Al final quedan 0 tormentas activas y 1 unidad `h00S`, la persistente.
- Capturas: `v14s-rayos-capturas/`, `v14s-sinniebla-capturas/` (`comparar-t6.png`, `comparar-t4.png`).
- Script de análisis: `scripts/analizar_rayos.py`.

### Estado

- Mapas (SHA-256):
  - para Leon: v14s 89a38129, v14s-prueba d4ee37b5, v14s-prueba-intro 9e0dac95;
  - de prueba: v14s-rayos 278ac231, v14s-sinniebla fc575447, v14s-separado 3f3df60c.
- **Validated:** pJASS en las seis variantes; j, w3u e imports reextraídos iguales; `mpq verify` correcto en las cuatro
  de `hacer-v14s.sh`.
- **Tested in map:** un jugador.
- **Sin comprobar:**
  - LAN de dos clientes. El cambio de animación es local (sólo visual), pero toca `GetLocalPlayer`.
  - Truenos audibles.
  - Windows.
  - Que el giro (velocidad de giro 3) llegue siempre antes de 0,25 s.
- La oscuridad de la noche completa (ciclo de día propio) queda para Dark Nights.

## v14t: niebla más oscura y prueba sin registros (06/11/2026)

Pedido de Leon: comprobar sin registros que los tirones son de la prueba, y oscurecer más la niebla. Hay que tener en
cuenta que la cámara está más alta de lo normal.

### Cambios

- **Niebla** (`v14t.py`, función `Storm_Oscuro`): negra, de 1000 a 4500. En v14s era 1730/5190.
  - Cerca del objetivo de la cámara, a 2856, ya cubre ~53 %.
  - El borde superior de la pantalla, más lejos, queda casi negro.
- **Ajuste en vivo** en las de prueba (`prueba_v14t.py`): `-niebla INICIO FIN`, por ejemplo `-niebla 800 4000`. El
  ajuste dura sólo esa partida.
- **Prueba muda** (`v14t-muda`, no se entrega):
  - Lanza las tormentas cada 4 s, igual que `rayos`.
  - Sólo escribe «inicio» 4 s antes de la primera y «fin … COMPLETE» al final.

### Resultado (un jugador, esta PC con Wine/DXVK)

- `v14t-muda-prueba`: 104 s entre «inicio» y «fin», 14 tormentas, 6374 cuadros.
  - Mediana 16,0 ms, p99 21,3, máximo 54. Ningún cuadro de más de 100 ms.
  - El único tirón de la corrida (174 ms) cae 0,01 s después de escribir el registro «fin».
- Queda confirmado que los ~170 ms son de la escritura Preload de la prueba y no de Storm.
- Capturas en `v14t-capturas/`:
  - `comparar-niebla.png`: v14s, v14t y un destello de v14t;
  - `m27-peq.png`: la tienda, que no se ve afectada.
- La escena sigue siendo de día. La noche completa llega con Dark Nights.

### Estado

- Mapas (SHA-256):
  - para Leon: v14t 6269c00e, v14t-prueba 9872fc04, v14t-prueba-intro 0a5d050e;
  - de prueba: v14t-rayos 71e5c296, v14t-muda 147a5a0a.
- **Validated:** pJASS en las cinco variantes; j, w3u e imports reextraídos iguales; `mpq verify` correcto.
- **Tested in map:** un jugador, sólo con `v14t-muda`. `-niebla` está compilado, pero no se probó en partida.
- **Sin comprobar:** LAN, truenos audibles, Windows.

## v14u: Dark Nights con Storm (06/11/2026)

Pedido de Leon: volver a la niebla negra de v14s (no la de v14t) y probar Dark Nights junto a Storm.

### Cambios (`scripts/v14u.py`, `hacer-v14u.sh`, a partir del j de v14t)

- `Storm_Oscuro` vuelve a 1730/5190, negra, densidad 0 (la de v14s).
- Al entrar en la partida: medianoche fija (`SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.)` y `SuspendTimeOfDay(true)`).
- `SetDayNightModels` usa los modelos de Dark Nights, versión Lordaeron, de The_Silent
  ([Hive 324142](https://www.hiveworkshop.com/threads/dark-nights-day-night-cycle.324142/)), importados como
  `war3mapImported\DNCDarkNightsLordaeronTerrain.mdx` y `...Unit.mdx`. De noche su luz ambiente cae a 0,05.
- En las de prueba (`prueba_v14u.py`) se añaden `-hora H` (0..24) y `-hora corre` (deja correr el reloj), además de
  `-niebla A B` y `-rayo N`.
- Menús e intro siguen con la niebla amarilla del mapa original: `Storm_Oscuro` sólo se llama al entrar a jugar.

### Resultado (un jugador, esta PC con Wine/DXVK)

- `v14u-muda-prueba`: 104 s, 14 tormentas, 6363 cuadros.
  - Mediana 16,0 ms, p99 21,5, máximo 46. Ningún cuadro de más de 50 ms.
- Capturas `v14u-capturas/n01..n40.png`. En `comparar-noche.png` se ven la partida en dos momentos y la tienda.
  - Escena de noche: brillo medio de 21 a 44, frente a 150-250 de día.
  - La tienda (panel, textos y retrato del golem) se lee bien de noche.
  - En las capturas de 1,5 s no cayó ningún destello, así que la mezcla con el relámpago no se ha visto.

### Estado

- Mapas (SHA-256):
  - para Leon: v14u 5cc1dcfd, v14u-prueba 730a732f, v14u-prueba-intro 2da19983;
  - de prueba: v14u-rayos 4e24490a, v14u-muda 0f5b0211.
- **Validated:** pJASS en las cinco variantes; j, w3u y los seis imports reextraídos iguales; `mpq verify` correcto.
- **Tested in map:** un jugador, sólo con `v14u-muda`.
- **Sin comprobar:**
  - un destello capturado de noche;
  - `-hora` y `-niebla` en partida;
  - LAN, truenos audibles y Windows.

## v14v: marcos de la tienda y atardecer (06/11/2026)

Pedido de Leon: los cuadros de interfaz no se mostraban, y Dark Nights estaba demasiado oscuro.

### Causa de los marcos (informe `informes/errores/2026-11-06-171024-tienda-marcos-preload-texturas.md`)

- Desde v14q faltaban los paneles, filas, botones y el marco del retrato de la tienda. No era la niebla ni Dark Nights.
- Lo provocaba la lista de `Preload()` de `Precarga_Todo` (v14q).
- Pruebas:
  - `v14q-q1`, sin precarga: los marcos aparecen;
  - `v14q-q2`, sin la lista de `Preload` pero con los efectos: aparecen;
  - v14v quitando sólo las .blp/.tga: siguen faltando;
  - quitando también `TitleDummyAdd/Blend/Flat.mdl` (los modelos de esas piezas): aparecen.

### Cambios (`scripts/v14v.py`, `hacer-v14v.sh`, a partir del j de v14u)

- Quita 346 `Preload` de `Precarga_Todo`: las .blp/.tga y los tres modelos `TitleDummy*`. El resto sigue igual: modelos,
  sonidos, efectos y unidades de precarga.
- Hora fija al entrar: 18:15, atardecer de Dark Nights. El sol queda a ~0,86, frente a 1,3 de día y 0,05 de noche.
- La niebla negra 1730/5190 y los comandos de prueba (`-hora`, `-niebla`, `-rayo`) siguen como en v14u.

### Resultado (un jugador, `v14v-muda`)

- Tienda completa con sus marcos (`v14v-capturas/comparar.png`).
- Brillo medio de la escena: 0,119 a las 18:15, frente a 0,087 a las 18:30 y 0,037 a medianoche.
- Cuadros: 64 s entre «inicio» y la tienda, mediana 15,9 ms, ningún cuadro de más de 50 ms. Esta corrida terminó al
  abrirse la tienda, antes de las 14 tormentas completas.

### Estado

- Mapas (SHA-256):
  - para Leon: v14v cb74bf00, v14v-prueba 697eb584, v14v-prueba-intro fe66317b;
  - de prueba: v14v-rayos 3f3592cf, v14v-muda 84203c42.
- **Validated:** pJASS en las cinco variantes; reextracción y `mpq verify` correctos.
- **Tested in map:** un jugador.
- **Sin comprobar:**
  - si sin esos `Preload` vuelve algún tirón en las rondas altas;
  - los menús (también usan piezas `TitleDummy`);
  - LAN.

## v14w: variantes Día, Tarde y Noche (06/11/2026)

Pedido de Leon: tres variantes de hora como en Slendytubbies. De momento sólo visuales y para probar cada una por
separado; más adelante se eligen en la intro de selección.

### Cambios (`scripts/v14w.py`, `hacer-v14w.sh`, a partir del j de v14v)

- `Variante` (0 Día, 1 Tarde, 2 Noche) y `Variante_Aplicar(v)`, que fija la hora de Dark Nights y la niebla.
- Es estado común y se llama igual en todos los clientes. `Storm_Oscuro` la aplica al entrar, con la hora parada.

| | Día | Tarde | Noche |
|---|---|---|---|
| Hora | 12:00 | 18:15 | 0:00 |
| Niebla | 2500/8000, gris azulada (0,55 0,62 0,72) | 1900/6000, naranja (0,95 0,5 0,18) | 1730/5190, negra |
| Tormentas en oleada | ninguna | cada 25-50 s | cada 12-25 s |

- La normal y `-prueba-intro` entran de Tarde. `-prueba-dia`, `-prueba-tarde` y `-prueba-noche` entran directas con su
  variante.
- En las de prueba, `-variante dia|tarde|noche` la cambia en vivo. Siguen `-hora`, `-niebla` y `-rayo`.

### Resultado (un jugador, unos 45 s por variante; `v14w-capturas/comparar-variantes.png`)

- Brillo medio de la escena: Día 0,18-0,21; Tarde 0,25-0,26; Noche 0,03-0,04.
- La Tarde sale naranja tostado y sin oscurecer. La niebla naranja suma luz, por eso brilla más que el Día.
- La tienda se ve completa en la Tarde.

### Estado

- Mapas (SHA-256):
  - v14w 557c996d;
  - v14w-prueba-dia 641f75fe;
  - v14w-prueba-tarde dc6f976a;
  - v14w-prueba-noche 79cb7b21;
  - v14w-prueba-intro 1c6bf07c.
- **Validated:** pJASS en las cinco variantes; reextracción y `mpq verify` correctos.
- **Tested in map:** un jugador, visual.
- **Sin comprobar:**
  - `-variante` en partida;
  - la frecuencia de tormentas por variante;
  - LAN;
  - la elección en la intro, que queda pendiente.

## v14x: linterna en Tarde y Noche (06/11/2026)

- `scripts/v14x.py` sobre el j de v14w: `Linterna_Poner` (lo llama `Variante_Aplicar`) pega `war3mapImported\Linterna.mdx`
  en "origin" de cada `Game_Hero[p]` con Variante 1 o 2 y la quita con el Día. Estado común, sin GetLocalPlayer.
- `Linterna.mdx` (`scripts/linterna.cjs`): sólo cuatro luces omni, sin geometría ni textura (petición de Leon). Los
  valores siguen a `FlashLightBeamMax.mdx` de OVOgenez ([xgm.guru/p/wc3/212665](https://xgm.guru/p/wc3/212665), copia
  en `fuentes/linterna-ovogenez/`): atenuación 3..8 e intensidad ambiental 2..6, que es la que alumbra a las unidades.
  Luces en X 0 (círculo en el héroe), 300, 600 y 900, a 60 de altura.
- Intentos descartados: una omni con atenuación 80..650 (casi no alumbra); abanico aditivo con textura (`linterna_haz.py`,
  variante `haz` de linterna.cjs): a ras de suelo lo cortan las lomas; elevado sin prueba de profundidad se ve bien,
  pero Leon pidió quitar la textura de momento.
- Probado en mapa: Noche, un jugador, capturas en `v14x-capturas/noche/`. Sin comprobar: Tarde en detalle, varios
  jugadores juntos (límite de luces del motor), rendimiento, LAN.

## v14y: visión clásica y tarde oscura (06/11/2026)

- Leon descarta la linterna (v14x queda como intento; sus mapas se reconstruyeron con el cono de 10 luces, fb1d23eb).
- `scripts/v14y.py` sobre el j de v14w: sin el FOG_OF_WAR_VISIBLE del campo de juego en Game_Enter (queda el de
  menús/tienda) y `FogEnable(true)` en HudMask_Apply. `objetos_v14y.py`: h005 y h006 ven 1100 (antes 300).
- Tarde: 18:36 y niebla 0,30/0,17/0,06 de 1500 a 5000. Media de la captura 0,149/0,113/0,056 frente a 0,165/0,102/0,054
  de la referencia de Leon (Slendytubbies).
- Hashes: v14y 41a84ca3, prueba-tarde e5f6a9f5, prueba-noche 038aa0c2, prueba-dia 3f7c5406, prueba-intro 9fd3c600.
- Probado en mapa (un jugador, capturas `v14y-capturas/`): Tarde marrón con el círculo de visión; Noche casi negra
  (media 0,01), pendiente de aclarar. Sin comprobar: menús y tienda con la niebla de guerra, barras de vida de
  enemigos fuera de la visión, LAN.

## v14z: tarde más oscura y noche azul (06/11/2026)

- `scripts/v14z.py` sobre el j de v14y (w3u de v14y, visión 1100). Tarde 18:51, niebla 0,22/0,12/0,04 de 1500 a 5000:
  media 0,107/0,080/0,042 (v14y 0,149/0,113/0,056). Noche 0:00, niebla azul oscuro 0,10/0,20/0,35 de 1500 a 5000:
  media 0,047/0,092/0,146 (v14y 0,008/0,012/0,013).
- Hashes: v14z e1893fdb, prueba-tarde d048f7af, prueba-noche 920efab2, prueba-dia 33fe3492, prueba-intro 3c537cf5.
- Pendiente: luz radial pegada al héroe con «Light - Lights» de DarknessFalls003
  (hiveworkshop.com/threads/light-lights.368691, paquete 9,83 KB, 15 modelos por color y alcance). La descarga desde
  aquí devuelve una página intermedia; Leon la bajará a mano.

## v14za: luz radial en el héroe (06/11/2026)

- `scripts/v14za.py` sobre el j de v14z: `Luz_Poner` pega `war3mapImported\LightWhite700.mdx` («Light - Lights»,
  DarknessFalls003, copia en `fuentes/light-lights/`; omni blanca, atenuación 0..700, intensidad 300, ambiental 2) en
  "origin" de cada héroe con Tarde o Noche. Tarde a las 19:00. Vuelven el campo de juego visible y FogEnable(false).
- Medias (un jugador, `v14za-capturas/`): Tarde 0,123/0,110/0,066, Noche 0,062/0,110/0,148; el círculo de luz se ve
  alrededor del héroe en las dos.
- Hashes: v14za 289eaea7, prueba-tarde 35f64ee5, prueba-noche 1e80afeb, prueba-dia 73be0b68, prueba-intro 5b8502f6.
- Sin comprobar: varios jugadores (varias luces juntas), menús, LAN.

## v14zb: luz de 1500 y más oscuridad (06/11/2026)

- `scripts/luz_1500.cjs`: `luz-1500/LightWhite1500.mdx` = LightWhite700 con AttenuationEnd 1500. `scripts/v14zb.py`
  sobre el j de v14za: usa esa luz; Tarde 19:09 (sol ~0,08); Noche con niebla 0,07/0,14/0,26 (la hora ya da el mínimo
  de Dark Nights).
- Medias (un jugador, `v14zb-capturas/`): Tarde 0,121/0,097/0,057, Noche 0,057/0,094/0,123.
- Hashes: v14zb f855d314, prueba-tarde 7e5a4fd5, prueba-noche 2b12b48a, prueba-dia bd47ea4d, prueba-intro 6a988673.

## v14zc (06/11/2026): sólo prueba, elegir la luz del héroe con «-luz N»

- `scripts/luz_variantes.cjs` → `luz-prueba/Luz1..10.mdx` (LightWhite700 de DarknessFalls003 con Z, atenuación,
  intensidad y ambiental cambiados); `scripts/prueba_v14zc.py` sobre el j de v14zb; `hacer-v14zc.sh`.
- Mapas: v14zc-prueba-tarde `da11b83f`, v14zc-prueba-noche `03a50816`. Sin mapa normal (el juego es v14zb).
- Validated: pJASS, reextracción por hash y mpq verify. Tested in map (Noche): «-luz N» cambia la luz y muestra su
  descripción; con `wtype` el chat no recibe texto, con `ydotool type` sí.
- Hallazgo: una luz destruida tarda en apagarse (sigue a 2 s, ya no a 10 s); cambiar cada 2 s las acumula. Comparar
  esperando ~10 s entre luces. En una secuencia 0, 2, 0 con 12 s el «-luz 2» no llegó al chat (entrada automática).
- Pendiente: que Leon elija la variante.

## v14zd (06/11/2026): sólo prueba, la luz se apaga al momento

- `scripts/luz_variantes_muerte.cjs` → `luz-prueba-d/Luz1..10.mdx`: las de v14zc más una secuencia Death (3400-3433,
  sin bucle) con KLAV 0 e intensidad 0. `prueba_v14zd.py`, `hacer-v14zd.sh`, `entrar-v14zd-prueba-{tarde,noche}.sh`.
- Mapas: v14zd-prueba-noche `dac33c1b`, v14zd-prueba-tarde `fbe5b2d5`.
- Validated: pJASS, reextracción y mpq verify. Tested in map (Noche): «-luz 8» 6 s y luego «-luz 0»: brillo del centro
  0,132/0,248/0,165 con luz, 0,033/0,067/0,111 a los 0,5 s, igual que a los 2 y 10 s. La luz ya no se queda.
- Sin revisión en visor 3D: el modelo no tiene geometría que mostrar. Pendiente: que Leon elija el número.

## v14ze (06/11/2026): pasto y antorchas respetan la oscuridad

- Análisis (war3map.doo de v14zb, 5616 piezas, 89 tipos; 266 modelos de war3.mpq/War3x.mpq): los juncos RiverRushes
  (LPrs, 1163) eran el único pasto con material Unshaded; Ruins_Shrub, flores, trigo y setas ya eran sombreados como
  los árboles. Con luz omni: TorchHumanOmni (40), LanternPost (15), TorchHuman (13), Firepot (2) = 70 luces de doodad
  (el motor dibuja 8). Con brillo aditivo sin luz quedan GlowingRunes (50), CrystalLamp, MagicRunes, MineCart,
  KeeperStatue y la cascada (Unshaded); no se tocaron.
- `scripts/doodads_v14ze.cjs`: originales en `fuentes/doodads-juego/orig/`, salida `doodads-v14ze/Doodads/...`
  importada con la misma ruta del juego (reemplazo, sin doodads nuevos). Juncos sin Unshaded; antorchas, faroles y
  Firepot sin luz, sin el geoset del halo aditivo y sin Unshaded; fuego de partículas intacto.
- Visor: `scripts/visor_doodads_v14ze.cjs` → `doodads-v14ze/visor/` (original/corregido lado a lado).
- Mapas: v14ze `5ee86c08` (j de v14zb), v14ze-prueba-noche `874c0295`, -tarde `6e8ff75d` («-luz N» de v14zd).
- Validated: pJASS, reextracción de los 9 modelos y mpq verify. Tested in map (Noche, sin luz del héroe): en v14zd se
  ven juncos claros y una antorcha con halo en el suelo; en v14ze no. El héroe aparece en otro sitio en cada partida,
  así que no es la misma vista. Pendiente: que Leon lo vea en Tarde y Noche.

## v14zf (06/11/2026): batería de la luz

- Luz del héroe = Luz 8 de v14zc (BatLuz5, idéntica byte a byte a Luz8 con Death). `scripts/luz_bateria.cjs` crea
  BatLuz0..4 (10/20/40/60/80% de intensidad y ambiental; alcance 825..1350).
- Batería de 100 s por jugador (`v14zf.py`): baja 0,1 cada 0,10 s salvo de día o con la tienda abierta. Por encima
  del 10% luz entera; del 10% al 0% cinco pasos; a 0 sin luz. Barra en el marco HudBlindaje con el relleno HudCarga
  (DS0F) de v15a a distancia 385, amarilla y roja al ≤10%; texto «Batería N%   Recargas (V): C».
- Recargar batería `Aw0A` (V, casilla 3,2; `objetos_v14zf.py`): 3 al entrar, +2 en cada `Ronda_AlTerminar`.
  Game_Volver ya no deja al héroe sin luz (Luz_Nivel -2).
- Pruebas (`prueba_v14zf.py`): vida ilimitada (reloj de 0,03 s), «-bateria N», «-cargas N», batería en el registro.
- Hashes: v14zf `fa8353a4`, v14zf-prueba-noche `8060ca0f`, v14zf-prueba-tarde `4dfa8318`. pJASS, reextracción y
  mpq verify correctos.
- Tested in map (noche, un jugador): barra y texto bajo la vida; con «-bateria 11» la luz baja por pasos y a 0 queda
  a oscuras; V la llena (99%, recargas 3→2). Vida 68-90 en el registro, sin morir en ~5 min. Capturas en
  `v14zf-capturas/`. La partida se cerró sola a t≈298 sin informe en Errors/.
- Sin comprobar: +2 recargas al descanso en el juego, mensaje sin recargas, tarde, LAN, 12 jugadores (límite de 8 luces).

## v14zg (06/11/2026): batería en el descanso

- `v14zg.py` sobre el j de v14zf: al empezar el descanso la batería vuelve a 100 (más las 2 recargas) y Bat_Paso sólo
  descuenta con Ronda_Activa y sin Ronda_Descanso (no baja antes de la primera oleada ni en el descanso).
- `prueba_v14zg.py`: las de v14zf más «-fin» (mata las unidades vivas de los dueños 8-13) y registro lat\v14zg-N.txt.
- Hashes: v14zg `d7a86b73`, -prueba-noche `eb454f86`, -prueba-tarde `394bb083`. pJASS, reextracción y verify correctos.
- Tested in map (noche, un jugador): con la batería a 37,8 y «-fin», al entrar en descanso pasó a 100 y las recargas
  de 3 a 5; quedó en 100 los 45 s del descanso y volvió a bajar (99, 97, 95…) al empezar la oleada 2.

## v14zh (06/11/2026): tarde más oscura y naranja

- `tarde_v14zh.cjs`: Dark Nights con el tramo de tarde rehecho (mesetas naranjas en 18,0/18,4/18,8/19,2 h; color
  lineal). Día (12 h) y noche (0 h) iguales. Medido: entre mesetas la imagen casi no cambia (sin linterna 0,073→0,070),
  porque con la cámara a ~2850 y la niebla 1500-5000 manda el color de la niebla.
- `v14zh.py` (sobre v14zg): tarde a las 18,8 h y niebla naranja según Tarde_N: 1 (0,30 0,13 0,03), 2 (0,22 0,09 0,02),
  3 (0,15 0,06 0,012, por defecto), 4 (0,09 0,035 0,008). Antes (0,22 0,12 0,04) a las 19,15 h.
- Prueba: «-tarde N». Brillo medio con linterna: 1 = 0,130, 2 = 0,114, 3 = 0,101, 4 = 0,089 (v14zg tarde: 0,117;
  noche con linterna ~0,12). Sin linterna: 1 = 0,069, 4 = 0,031. Capturas `v14zh-capturas/`.
- Hashes: v14zh `22822551`, -prueba-tarde `bc29a485`, -prueba-noche `ebec5eb5`. pJASS, reextracción y verify correctos.
- Incidente de prueba: una espera tomó un registro viejo y unas líneas de chat fueron a otra ventana antes de abrirse
  el juego; luego algunas teclas entraron como atajos. Repetido comprobando foco y el registro de cada comando.

## v14zi (06/11/2026): día con neblina blanca

- Petición: quedarse con la tarde 4 (la más oscura) y hacer el día igual de oscuro, pero con neblina blanca que la
  linterna despeje. La niebla depende de la distancia a la cámara, así que la linterna no la borra: dentro del círculo
  se ven los colores del terreno y fuera queda la neblina.
- `scripts/dia_v14zi.cjs` (sobre `tarde-v14zh`): meseta de día a las 3,0 h con luz directa 0,10 y ambiental 0,06
  (+0,02 en Unit), en tonos blancos. `scripts/v14zi.py`: `Tarde_N= 4`, `Dia_Hora= 3.0`, `Dia_N= 3`; la luz y la
  batería funcionan también de día; `Dia_Niebla()` con 4 grises (0,62 / 0,50 / 0,40 / 0,30). Prueba: `-dia N`.
- Hashes: v14zi `d0a17188`, prueba-dia `e63db72e`, prueba-tarde `185bc06b`, prueba-noche `8ba93edf`.
- Validated (pJASS, reextracción, verify). Tested in map (un jugador, día): brillo medio con linterna 0,306 / 0,264 /
  0,229 / 0,194 para `-dia 1..4`; `-dia 3` sin batería 0,176, gris azulado. La batería baja de día (luz 5 hasta 10 %).
  Captura: `v14zi-capturas/dias-1-4-y-sin-linterna.jpg`.
- Sin comprobar: tarde y noche en v14zi (sólo cambia `Tarde_N` por defecto), LAN, varios jugadores.
- 06/11/2026: Leon elige el día 3, que ya es el valor por defecto de v14zi; no hace falta otra versión.

## LAN de 4 clientes con v14zi (07/11/2026)

- `scripts/puente_lan_v14zi.py` (sólo prueba) y `scripts/hacer-lan-v14zi.sh` → `TerrainDev-Titulo-v14zi-lan.w3x`
  (`4090b3ff`); lanzador `scripts/lan-v14zi.sh` (ydhost con `bot_autostart_players = 4`, dos ventanas por pantalla).
- Guion del timer común: J2 recarga a A+10, J3 a 8 s y J4 a 0 s a A+12, J4 recarga y J1 sin recargas a A+20, oleada
  matada hasta el descanso.
- Tested in multiplayer (LAN en esta PC, 4 clientes): 180 registros iguales en los 4 clientes, con el aleatorio
  incluido, hasta el segundo 346 (ronda 3); el 181 sólo falta en J1 porque fue el primero en cerrarse. Batería,
  recargas y paso de luz coinciden: J2 100 % y 2 recargas, J3 se apaga (luz -1), J4 vuelve a 100 %, J1 sin recargas no
  recarga; en el descanso todos a 100 % y +2. Cada cliente muestra sólo su texto de batería. Sin desconexiones.
- Carga lenta: ~5 min entre "started loading with 4" y el primer registro (no medido qué parte es carga y qué parte
  entrada). Un fallo del lanzador (`wait` esperaba también al juego) dejó una sola ronda de capturas; corregido.
- Sin comprobar: el aviso «Sin recargas» visto en pantalla, el conteo exacto de luces con 8 jugadores.
