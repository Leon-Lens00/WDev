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
