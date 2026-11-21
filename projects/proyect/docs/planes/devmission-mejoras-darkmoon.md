# Dev Mission: élite al azar, puntuación de ronda y mejoras del héroe al estilo Dark Moon

Abierto el 14/11/2026. Mapa: `Proyect/work/titulo-devmission-20261026` (`$M`), base vigente v17r. Objetivo Warcraft III
Classic 1.27b (JASS, sin Blz/Frame/Lua). Estado: **Designed** (sin código todavía). Plan largo: se anota aquí cada idea
nueva de Leon con fecha.

## Objetivo

Traer a Dev Mission sistemas de "Dark Moon" (juego personalizado de Dota 2), adaptados a Warcraft III y a nuestra
interfaz (piezas de HUD, trackables, texttags y texturas de texto):

1. **Súper élite al azar** con 2 mejoras de estadística y 2 habilidades, mostradas en 4 tarjetas a la izquierda.
2. **Puntuación de fin de ronda** con estrellas, bolsas de oro que hay que recoger y edificios que dan oro si resisten.
3. **Mejoras permanentes del héroe a elegir, con refresco**, en un apartado de la tienda, con aviso en partida
   (modelo PVZ Fusion desde el 14/11/2026, ver décima tanda).
4. **Mutación Evo**: mejoras de enemigos por votación (modelo PVZ Fusion).

## Fuente estudiada

- Imágenes y capturas de vídeo que pasó Leon: presentación "Dark Moon 2022 v3.6.0", cuadro "Round Score" y el panel
  "Super Creep Random Boost" en partida (ronda 2, inferno).
- Juego ya descargado por Leon: Steam Workshop 570/2837608304 "Dark Moon 2026" (`source_folder` dark_moon_2,
  publicado 19/09/2026), versión actual del mismo juego. Extraído para estudio con `scripts/vpk2.py`; copias de los
  archivos usados en `$M/referencias/darkmoon-2026/` (`ORIGEN.txt`, `SHA256SUMS`; `holdout_game_round.lua` y
  `dark_moon.txt` añadidos después, sin suma). Sólo se toman mecánicas y números; ni código ni recursos de Dark Moon van
  al mapa.
- Lo de abajo sale de leer el código (Scanned), no de jugarlo.

### Súper criatura (`holdout_game_boost_creeps.lua`)

- Durante la ronda: primera a los **6 s**, luego cada **20-30 s** al azar. Se elige un enemigo fuerte que no sea jefe ni
  súper criatura ya. No en rondas de bonificación.
- Recibe **2 mejoras de estadística al azar** de 12 (daño de ataque, reducción de armadura al golpear, robo de vida,
  armadura, velocidad de ataque, evasión, regeneración de vida, reducción de daño físico, armadura mágica,
  amplificación de hechizos, reducción de enfriamiento, resistencia a estados, velocidad de movimiento) y **2 habilidades
  pasivas** al azar. En partida se ven como 4 tarjetas: las 2 de estadística con icono y valor ("+19", "+37") y las 2
  habilidades con icono y nombre ("Berserker's Blood", "Backtrack").
- Vida y daño × (1,25 + 0,05 × (ronda − 1)), máximo × 2,25. Nivel de la pasiva: el de la criatura (la mitad hasta ronda 5).
- Valor de cada mejora: base al azar según dificultad (fácil 14-20, normal 18-24, hard 24-30, **nightmare 28/30/32/34**,
  inferno 32-38), + 2 por ronda, y ajuste por tipo y tramo de ronda (1-3, 4-6, 7-11, 12+), p. ej. armadura y robo de vida
  ÷3 / ×0,5 / ×0,65 / ×0,8; daño ×0,75 / ×1,5 / ×2,5 / ×4; velocidad de ataque ×0,75 / ×1 / ×1,25 / ×1,5; velocidad de
  movimiento ×1,5; reducción de enfriamiento ÷2. Se redondea hacia abajo.
- La interfaz gira la lista antes de mostrar las elegidas: 0,2 s por elemento + 0,5 s.
- Al morir suelta 2 pociones de vida, 2 de maná y 50 % una mejora de torre.

### Ronda, bolsas de oro y torres (`holdout_game_round.lua`, `dark_moon.txt`)

- Cada ronda tiene un oro total (`MaxGold`, 5000 en la 1, +500 por ronda) repartido en **40 bolsas**. Al morir un enemigo
  principal cae una bolsa con probabilidad bolsas restantes / (1 + enemigos restantes); cada bolsa lleva oro restante /
  bolsas restantes. Hay que recogerlas: caducan a los **35 s** (`ItemExpireTime`) y cuentan como perdidas. Las rondas de
  jefe no tienen bolsas.
- **Torres**: al acabar la ronda, cada torre en pie da a cada jugador 85 + 5 × (ronda − 1) de oro.
- **Estrellas** ("Rank this round" del cuadro "Round Score", Leon lo identificó): el mínimo de dos notas. Bolsas
  perdidas: ≤ 3 → 3, > 3 → 2, ≥ 8 → 1. Muertes del equipo: ≤ 1 → 3, > 1 → 2, > 3 → 1. Ronda de jefe cuenta como 4. El
  cuadro muestra muertes, bolsas y asesinatos por jugador, torres restantes con su oro, bolsas recogidas y perdidas,
  muertes del equipo, estrellas, puntos de la ronda y total. Descanso entre rondas: 15 s.

### Recompensa del héroe (`holdout_game_round_rewards.lua`) — SUSTITUIDA por el modelo PVZ (décima tanda)

Se conserva sólo como referencia de valores; no se implementa tal cual.

- Al acabar cada ronda, por jugador: **2 mejoras de estadística** (21 tipos) + **2 mejoras de habilidad** (sube un % una
  propiedad de una habilidad del héroe) + desde la ronda 6 una mejora especial del héroe.
- Una de las de estadística se fuerza a su atributo principal; las de alcance no salen a héroes cuerpo a cuerpo.
- Rareza: normal 7-10, mítica 15-18, + ronda × 0,5. Mítica 10 % + 5/35/65 % según estrellas (1/2/3); la ronda 1 siempre
  mítica. Ajuste por tipo: vida y maná ×10, alcance ×4, velocidad de movimiento ×2,5, daño y velocidad de ataque ×1,5,
  armadura ÷2,5, regeneración, atributos, evasión y amplificación ×0,5.
- **Reroll**: 2 al empezar, +1 cada 2 rondas. Se elige con "Accept"; es permanente.
- Elección de la siguiente ronda por votos (`round_choice.lua`, 12 s): no entra en este plan.

## Decisiones de Leon

### 14/11/2026, primera tanda

Cita: "si esa lo que quiero claro que con ciertos ajustes, los cuatro paneles ..., 2 de stat y 2 de habilidad, se los
puede adaptar bien ya que dota 2 nacio practicamente del warcraft".

- **Habilidades de Warcraft III** en lugar de las de Dota ("asi un jugador se familiariza con lo que hace igualmente como
  hacen en la original usando las del dota").
- **Un enemigo al azar se convierte en élite** con sus mejoras: sí. Soltar curaciones: **después**.
- **Tiempos e intervalos: los de Dark Moon para probar, con nightmare como dificultad máxima.**
- **Mejoras del héroe**: en partida sólo un **cuadro de notificación**; la elección va en **un apartado de la tienda**.
- **Texttags**: optimizar; los textos fijos que casi no cambian pasan a **textura con la frase** en lugar de texttag.
- **Reroll** también; con esas elecciones se mejoran **habilidades especiales y estadísticas**, como en Dark Moon.

### 14/11/2026, segunda tanda

- **Los 4 paneles** son los de la súper criatura a la izquierda (captura de Leon): 2 de estadística y 2 de habilidad. Se
  corrige la lectura anterior (había entendido el cuadro de elección del héroe).
- **Puntuación de fin de ronda** con estrellas: "me gusta esa mecanica, la podriamos colocar al final al terminar la
  ronda". **Bolsas de oro** que hay que recoger: sí. **Edificios** que representen las torres y den **oro adicional si se
  defienden**.
- **Habilidades de WC3 para la élite y las mejoras**: las elijo yo explorando cuáles van mejor con el modo; se pueden
  combinar con **habilidades de objetos** (fáciles de añadir a una unidad). **Sin auras**, o limitadas al portador.
- **La nueva élite se suma** a las élites actuales (45 % del jefe).
- **Acumulación de elecciones** sin abrir la tienda: a mi elección (ver decisión abajo).
- **Tienda con apartados**: al entrar, de momento **2 cuadros con su icono**:
  1. "Mejora tus armas aquí" y otros detalles (la tienda de armas actual).
  2. "Mejora aquí tus habilidades especiales ganadas al superar la wave" (las elecciones nuevas).
  Así no se saturan los cuadros de la tienda.

### Decisiones mías (revisables por Leon)

- **Acumulación**: hasta **3 elecciones pendientes** por jugador (una por ronda superada). Si llega una cuarta, la más
  antigua se resuelve sola con una de sus opciones al azar, para no perder la mejora. El aviso muestra cuántas quedan.
- **Estrellas en Dev Mission**: bolsas perdidas y muertes del equipo, como Dark Moon; los umbrales se escalan con el
  número de jugadores al probar (Dark Moon es para 4-5).

## Estado actual del mapa a tener en cuenta (comprobar en el j antes de usarlo)

- 10 rondas; descanso de 45 s con tienda móvil (golem); élites a 45 % del jefe, una por jugador, por número de muertes.
- Oro: `Oro_Muerte` da vida máxima / 10 por muerte (v17n). Con bolsas habrá que repartir ese oro o parte de él.
- Tienda: armas Q/W/E/R con 7 tiers de color; tokens y mejoras por personaje con rareza (memoria
  `mp5-basica-mejoras-labyrinth`); clics por trackables (con retraso de red).
- Texttags: 100 en total; la tienda crea los suyos al abrir y las barras usan 24 fijos.
- 'Rdjv' sube la vida del jefe por jugador; tabla de daño en war3mapMisc.
- Reencarnación ('AOre') ya se usa para reaparecer: no usarla como pasiva de élite.

## Habilidades de Warcraft III candidatas (por explorar)

Sólo nombres; rawcode, nivel y datos se comprueban en el AbilityData/SLK de 1.27b antes de usarlos. Sin auras.

- **Pasivas de la súper élite** (2 al azar): Golpe aplastante (Bash), Golpe crítico, Evasión, Piel endurecida,
  Caparazón espinoso / Espinas, Ataque hendiente, Ataque de escarcha, Ataque envenenado, Robo de vida de objeto,
  Regeneración de objeto. Descartadas de inicio: auras, Reencarnación, invocaciones.
- **Mejoras de estadística** (élite y héroe): habilidades de objeto con niveles (daño, armadura, vida, maná, velocidad
  de ataque, velocidad de movimiento, regeneración) o mejoras de tipo 'Rdjv'. Comprobar cuáles admiten niveles para
  acumular valores.
- **Mejoras de habilidades del héroe**: sólo las habilidades especiales del personaje (libro), no las armas. Por código
  (alcance, daño, acciones nuevas, tiers) y por nivel lo que es dato (enfriamiento).

### 14/11/2026, tercera tanda

Leon: "primero vamos armar muy bien el plan, sera algo largo y detalle ... seria lo mejor para que salga bien". Queda
**otra mecánica** por contar (pendiente). No se implementa nada hasta cerrar el plan.

- **Habilidades especiales = habilidades propias del personaje**, no más mejoras de armas ("ya no podemos ir amplificando
  aun mas las armas"). Las armas siguen siendo el ataque principal; las especiales son "un buen plus que ayudara".
- **Libro de hechizos**: una habilidad (o de objeto) de tipo libro; al abrirlo se lanzan las habilidades especiales que
  tenga el personaje y cada una entra en enfriamiento.
- **Personajes D.O.N** (Goku, Freezer, Trunks, Naruto, ya en el mapa aunque incompletos): sus habilidades van a ese libro.
  **Tauren y Cairne**: aún sin habilidades; se dejan en blanco por plantear.
- **Cómo se mejoran**: casi todo por código (vJASS/JASS): alcance, daño y **acciones nuevas** (p. ej. lanzar 3 Q en
  abanico), con **tiers que cambian el comportamiento** como en Dark Moon. Lo que sólo es dato del objeto, como el
  **enfriamiento**, sube por **nivel de la habilidad**, porque en 1.27b no hay función para cambiar el enfriamiento.
- **Edificios y torres**: se definen **al final**; Leon irá pensando cómo encajan con el modo.
- **Bolsas de oro**: a mi recomendación, cuidando la economía sin inflación (ver abajo).

### Recomendación de economía para las bolsas (revisable)

Estado actual (v17r, `Oro_Muerte`): cada muerte de oleada da al que la mata max(3, vida máx. / 10) × (2 + ronda) / 3.
Precios de armas por tier: 250, 600, 1200, 2200, 3600, 5500.

- **No crear oro nuevo**: el oro de cada muerte se parte. Una parte sigue llegando al momento al que mata (propuesta
  60 %); el resto (40 %) va a la **bolsa de la ronda**.
- La bolsa de la ronda se reparte en **bolsas de oro** que caen al morir enemigos, con la regla de Dark Moon
  (probabilidad = bolsas restantes / (1 + enemigos restantes); cada bolsa lleva oro restante / bolsas restantes). Número
  de bolsas por ronda: proporcional a los jugadores (propuesta 6 + 4 × J, ajustable al probar).
- Cada bolsa da su oro a **quien la recoge**; caduca a los **35 s** y su oro se pierde. Así el total nunca supera el
  actual: jugar bien da lo mismo que hoy y descuidar bolsas da menos (deflación, nunca inflación).
- Las bolsas perdidas cuentan para las estrellas. Las rondas de jefe también tienen bolsas por sus esbirros (Dark Moon
  no las tiene porque sus jefes van solos).
- El oro de torres se decide con los edificios, al final.
- Comprobación prevista: registro de prueba con oro por muerte, oro en bolsas, recogido y perdido por ronda, y
  comparación con v17r en la misma partida.

### 14/11/2026, cuarta tanda: bolsas por tamaño, recogida al acercarse, libro y prioridad

- **Pocas bolsas y más grandes** (40 como en Dark Moon saturaría la partida): que se note el botín. Tres tamaños:
  **común < élite < jefe**; el **jefe suelta varias**. El ajuste de números me lo deja a mí.
- **Recogida automática al acercarse**, como en Dark Moon; hay que planear cómo hacerlo bien y ligero.
- **Libro**: entran **todas las habilidades D.O.N** y **las de Cairne**; luego se recortan o adaptan. El libro va como
  **habilidad, con su propia casilla junto a las armas** (no objeto).
- **Prioridad**: las habilidades se deciden luego. Lo importante es que **los cuadros funcionen y respondan su evento de
  mejora**; al final sólo se ancla la mejora a cada cuadro.

### 14/11/2026, quinta tanda: bolsas que crecen, iconos sin efecto y PVZ Fusion

- **Las bolsas escalan con la ronda** y dan más oro según se avanza, para sostener la compra de las armas por tier.
  Corrige el "sin inflación" anterior: el oro de las bolsas se suma al de muerte y se calibra contra los precios de
  tier (`Arm_Precio` 250, 600, 1200, 2200, 3600, 5500), no contra el oro actual.
- **Habilidades con icono pero sin efecto**: los cuadros muestran iconos de habilidades reales y se pueden elegir, pero
  no mejoran nada todavía; las habilidades se plantean cuando todo lo demás esté implementado.
- **Nueva fuente**: PVZ Fusion 4.1, sobre todo el modo Odisea (mejoras al jugador y a los enemigos). Ver su sección.

### Bolsas de oro: tamaños y recogida (propuesta revisable, sustituye al reparto por probabilidad de Dark Moon)

- **Fondo de la ronda** (revisado en la quinta tanda): el oro de muerte sigue igual y las bolsas son un extra que
  crece con la ronda. Fondo = base × curva de ronda, calibrado para que un jugador que recoge su parte pueda subir
  aproximadamente un tier cada 1–2 rondas (curva a fijar con la tabla de `Arm_Precio`, p. ej. ronda 1 ≈ 150 por
  jugador y ronda 10 ≈ 1500 por jugador). El registro de prueba compara oro ganado por ronda con el precio del
  siguiente tier.
- **Reparto del fondo** (propuesta): comunes 40 %, élites 25 %, jefe 35 %.
  - **Comunes**: pocas bolsas, 2 + J por ronda (J = jugadores), en muertes al azar repartidas por la oleada.
  - **Élite** (las del 45 % y la súper élite): 1 bolsa cada una, más grande que una común.
  - **Jefe**: 3 bolsas grandes que saltan alrededor al morir.
  - Comprobación en el registro de prueba: tamaño común < élite < jefe en cada ronda y número de jugadores; si no, se
    reajustan los porcentajes. Oro no repartido al acabar la ronda (muertes sin bolsa) se pierde igual que una caducada.
- **Aspecto**: tres modelos o escalas (bolsa pequeña, mediana, cofre) y texto de oro al recogerla, sólo para quien la
  recoge.
- **Recogida ligera**: las bolsas son unidades sin selección (con Langosta, sin ocultar/mostrar). Un único reloj de
  0,10 s que sólo corre mientras haya bolsas en el suelo comprueba la distancia de cada héroe vivo a cada bolsa
  (≤ 8 jugadores × ≤ ~12 bolsas, cuadrado de la distancia, sin crear handles). Al recogerla: oro al que llega primero,
  efecto, se quita la bolsa. Caducan a los 35 s con un parpadeo los últimos 5 s. Alternativa estudiada: evento de
  "unidad en rango" por bolsa; se descarta de inicio porque crea un disparador por bolsa.

## PVZ Fusion 4.1: modo Odisea (旅行, "Travel" en el código)

Fuente: `/home/snz/Descargas/PC_PVZ-Fusion-4.1` (Unity IL2CPP, sólo lectura). No hay código fuente: se leyeron nombres
de clases, campos, métodos y textos del `global-metadata.dat`. Tablas en `$M/referencias/pvzfusion-4.1/` (ORIGEN.txt,
SHA256SUMS); lector `$M/scripts/il2cpp_tipos.py`. Las cifras vienen de los textos del juego; las fórmulas internas
(pesos exactos, curvas) no son legibles sin desensamblar `GameAssembly.dll`.

**Cómo funciona (Scanned)**
- **Mejoras del jugador** ("词条", 238 en el enum `AdvBuff`): de juego general (daño +20 %, +100 % a jefes, robo de
  vida, "tras 50 disparos 1 s de cadencia infinita", +1 % de daño por cada 1 % de velocidad de ataque…), de planta
  concreta (desbloquean una forma nueva o cambian su comportamiento) y **malditas** (gran ventaja con coste: "por cada
  mejora de zombi, +5 % de ataque"; "cartas sin enfriamiento pero coste ×15").
- **Mejoras de los zombis** (143 en `TravelDebuff`) que se **acumulan toda la partida**: más vida/velocidad a líderes o
  a esbirros (+30 %), "élite: mitad de zombis pero vida y daño ×2", aparición más rápida, curaciones del jugador a la
  mitad, daño recibido ×1,5, ocultar barras de vida, armadura que crece con el daño recibido, resistencia a control
  tras 5 s seguidos, explotar al morir, revivir como otro zombi, zombis extra que crecen con la oleada.
- **Elección**: menú con N opciones (2/3/5 según dificultad), refrescos (0/1/2; "合理投资" da +3) y botón de renunciar.
  El menú puede **exigir aceptar una mejora de zombi** para recibir la tuya (`withDebuff`, `debuffNeedCount`). Modo
  difícil: "5 rondas, en cada una eliges 1 de 5 mejoras de zombi".
- **Líderes**: zombis jefe con rasgos propios; sus mejoras **no se pueden purgar**. Objeto "净化" quita 1 mejora de
  zombi que no sea de líder.
- **Ciclos** (轮回): cada vuelta los zombis ganan vida +20/40/60 % y velocidad +20/25/30 %; al final, el rey zombi.
- **Calidades** (sub-modo 诸神进化): madera, plata, oro, diamante, prismático y maldita; **Suerte** (0–300 o más) sube la
  probabilidad de calidad alta, con **garantía** (保底) tras varias tiradas; refrescar o elegir calidad alta gasta
  suerte; algunas mejoras de zombi juegan con la suerte ("-75 de suerte", "préstamo de suerte").
- **Golpe de suerte** (幸运一击): probabilidad de crítico y su daño como estadísticas propias de las mejoras.
- **Sinergias** (羁绊): bonos por tener varias piezas del mismo grupo.

**Pantalla de elección de mejora de zombi (captura de Leon, 14/11/2026)**
- 4 cuadros iguales en fila, cada uno con: **retrato del zombi afectado** arriba, **texto de la mejora** en un panel
  claro y botón **Elegir** debajo. Arriba a la derecha, **Ver mejoras actuales**; abajo, **Cancelar elección** y
  **Refrescar (3)** con contador. Pie: ruta del recorrido ("将军线", ruta del General) y dificultad.
- Las 4 opciones son todas para los enemigos: el jugador decide **cuál** acepta, no si acepta una.
- Textos de la captura: "tras rodar, el samurái y su jefe doblan su ataque"; "primera oleada a los 5 s y aparición
  cada 15 s"; "el lector de periódico ametrallador es inmune a casi todos los estados" con "◇ si **no** se elige, el
  profesor Z gana un periódico de repuesto"; "el samurái rueda en cuanto aparece".
- Detalle útil: **una opción no elegida también tiene efecto** (◇). Así descartar no sale gratis.
- **Adaptación a Dev Mission**: el mismo marco de 4 cuadros que la súper élite y las mejoras del héroe. El retrato
  usa el sistema de retratos vivos de la tienda (v14k) con el modelo del enemigo afectado; el texto fijo va como textura
  (decisión de la segunda tanda); el botón con trackable como los de la tienda; refrescos con contador. Un único marco
  sirve para las tres pantallas cambiando el contenido.

**Secuencia combinada jugador + zombis (4 capturas de Leon, mismo vídeo, 2:50–2:54)**
- Una misma ventana encadena varias elecciones: primero **mejoras del jugador** (fondo del retrato **verde**, retrato de
  la planta) y, tras el aviso grande **"¡Vienen más zombis!"**, **mejoras de zombi** (fondo **azul**, retrato del
  zombi). Orden observado: planta (自爆兵工厂) → planta (可控核聚变) → zombi (精英部队) → otra elección de zombi.
  Es el par `selectBuffCount` / `debuffNeedCount` del código: por cada tanda de mejoras propias hay que aceptar
  mejoras de zombi.
- Lo elegido aparece como **subtítulo grande** en la parte baja durante unos segundos mientras salen las 4 opciones
  siguientes. El contador **Refrescar (4)** es el mismo en las dos clases de elección.
- Las mejoras del jugador mezclan tipos: estadística general ("强力打击: ataque +20 %"), de economía ("等价交换: el
  dinero que pasa del límite se convierte en sol 2:1"; "多多益善: mejora de la maceta dorada cuesta como máximo 8000"),
  de planta concreta y de desbloqueo ("解锁…": desbloquea una forma nueva).
- Las de zombi también: de toda la oleada ("精英部队: mitad de zombis, vida y ataque ×2"; "虎狼之师: no líderes +30 %
  vida y velocidad"), de un tipo concreto ("死亡行军: el ametrallador ignora plantas al andar"), de invocación ("钢铁蜂群:
  los mini-dirigibles invocados ×50 de vida") y de jefe ("战意激增: el general crece el doble de rápido").
- **Adaptación**: misma ventana de 4 cuadros con dos colores de fondo (héroe / enemigo), aviso de cambio entre fases,
  subtítulo de lo elegido y un contador de refrescos común. El número de elecciones de cada lado por ronda queda por
  decidir (propuesta inicial: 2 del héroe → 1 de enemigos, y la súper élite de Dark Moon aparte).

**Qué encaja con Dev Mission (propuesta, pendiente de Leon)**
1. **Contrato héroe/enemigo** al fin de ronda: elegir una mejora del héroe puede obligar a aceptar una mejora permanente
   de los enemigos; con eso se compensa la súper élite de Dark Moon (que sólo afecta a una unidad) con efectos que
   afectan a toda la oleada.
2. **Mejoras de enemigos acumuladas** visibles en un panel (como el de la súper élite), con un objeto de purga que quita
   una, excepto las del jefe.
3. **Calidades con color** (ya existen 6–7 tiers con color en la tienda de armas): reutilizar esa escala para las
   mejoras del héroe; **suerte** como recurso que sube la calidad y que gana o pierde con las estrellas de la ronda.
4. **Mejoras malditas**: opción rara con gran ventaja y un coste claro.
5. **Golpe de suerte** como estadística de las mejoras de estadística (crítico de las armas por código).
6. **Ciclos**: tras la ronda 10, otra vuelta con enemigos más fuertes (+20/40/60 % de vida), si se quiere partida larga.
- Se descarta por ahora: sinergias por grupo de plantas (no hay equivalente directo) y el modo autobattler (TravelRogue).

## 14/11/2026, sexta tanda: mejoras de enemigos por votación (diseño de Leon)

**Decisiones de Leon**
- Las mejoras de enemigos se adaptan a **nuestras unidades**: más vida en porcentaje, o que una unidad de oleada 1 salga
  con estadísticas de oleada 9–10 o más. También pueden tocar la **tabla de élites**: que más comunes pasen a élite.
- **2 mejoras por oleada**, con mejor probabilidad o seguridad según las estrellas: 3 puede ser perfecta y 4–5 podrían
  asegurarlas. Lectura provisional: son las 2 mejoras del héroe y las estrellas suben su calidad; falta confirmarlo
  (Dark Moon puntúa de 1 a 3, así que habría que ampliar la escala a 5). Ver "Por decidir".
- **Tienda bloqueada hasta votar.** Al entrar a la tienda (ESC) los 2 cuadros grandes de antes (armas / habilidades
  especiales) aparecen **bloqueados**; en el centro aparece un icono nuevo, **mejoras del enemigo**, con cuadro de tono
  **rojo carmesí** y su descripción. El jugador tiene que entrar ahí para desbloquear la tienda de armas y sus mejoras.
- **Formato de las capturas**: 4 cuadros con retrato, texto y Elegir. Candidatos de nivel **jefe, élite y normales**,
  al azar, con **más probabilidad para las unidades que vienen después del descanso**.
- **Multijugador**:
  - Los candidatos salen al azar pero **son los mismos para todos**.
  - Con varios jugadores la elección es una **votación**. Gana el más votado; si hay empate, uno al azar entre los
    empatados; si nadie vota, uno al azar entre todos los candidatos.
  - **No hace falta que todos voten**: quien vota ya puede comprar, sin esperar a los demás.
- **Al terminar el descanso**: los cuadros ganadores se muestran **8 segundos** con la interfaz para que todos vean lo
  que viene; luego salen de pantalla y empieza la oleada.
- **Sin refresco en las mejoras de enemigos.** Se compensa con **cuadros adicionales según el número de jugadores**.
  Las mejoras del jugador sí tienen refresco.

**Nombre del apartado** (propuesta): "Infección forzada" está bien y explica que es obligatoria. Alternativas:
"Mutación de la horda", "Pacto de sangre", "Decreto del pantano" (encaja con el terreno Swamped Temple), "Marea
carmesí". Recomiendo **"Marea carmesí"** si se quiere un nombre que case con el color, o "Infección forzada" si se
prefiere que el nombre diga que es obligatoria.

**Cuántos candidatos** (propuesta): 4 cuadros con 1 jugador; +1 cada 2 jugadores más, hasta 6 con 5–8 jugadores (cabe
en dos filas de 3). Si entran 2 mejoras de enemigos por oleada, ganan las 2 más votadas de la misma pantalla.

**Unidades actuales a las que se adaptan** (v17r, `DevWave_TipoN`): la ronda n usa los tipos 0..n-1, así que cada ronda
añade un tipo nuevo: 0 `nmcf`, 1 `nlpr`, 2 `ntrh` (distancia), 3 `nmtw`, 4 `nmsn` (distancia), 5 `nlds` (distancia),
6 `nmmu`, 7 `nnsw` (distancia), 8 `ntrg`, 9 `ntrd`. Élites `ne00`+k (por muertes, una por jugador), jefe `nj01`…`nj0A`
por ronda, súper élite pendiente. "Unidades que vienen después del descanso" = el tipo k = ronda siguiente − 1 y el jefe
de esa ronda: tienen más peso entre los candidatos.

**Lista recomendada de mejoras de enemigos** (para revisar con Leon; valores iniciales a medir)

*Normales (toda la oleada o un tipo)*
1. **Piel gruesa**: comunes +25 % de vida.
2. **Marea rápida**: comunes +20 % de velocidad de movimiento.
3. **Veteranos**: un tipo antiguo (ronda 1–3) sale con la vida y el daño de la ronda actual + 3 (p. ej. `nmcf` con
   estadísticas de ronda 9–10). Por código, multiplicador por tipo.
4. **Horda**: +20 % de unidades en la oleada (respetando el límite de 240).
5. **Pocos pero fuertes**: mitad de unidades, vida y daño ×2 (como "精英部队").
6. **Caparazón**: tortugas (`ntrh`, `ntrg`, `ntrd`) +3 de armadura y devuelven parte del daño cuerpo a cuerpo.
7. **Lluvia de flechas**: unidades a distancia +150 de alcance.
8. **Red de pesca**: los lanzadores de red (`nmsn`) atrapan más seguido.
9. **Asalto inicial**: la oleada aparece más rápido (aparición cada 0,05 s en vez de 0,10 s) y los primeros 10 s +30 %
   de velocidad.
10. **Regeneración**: comunes regeneran 1 % de vida por segundo fuera de combate.

*Élite*
11. **Ascenso**: el umbral de élites baja (más élites por ronda; p. ej. una más por jugador).
12. **Promoción**: al aparecer, 10 % de los comunes pasan a ser élite de su tipo.
13. **Élite feroz**: las élites ganan una pasiva al azar de la lista de la súper élite.
14. **Último aliento**: las élites al morir explotan o sueltan 2 comunes de su tipo.

*Jefe*
15. **Coloso**: el jefe +30 % de vida (se suma a 'Rdjv').
16. **Escolta**: el jefe aparece con 2 élites.
17. **Furia**: el jefe al 50 % de vida gana +50 % de velocidad de ataque.
18. **Corona**: el jefe recibe 2 mejoras de la súper élite.

*Con efecto si no se elige* (◇ de PVZ): algunas cartas pueden traer una consecuencia menor si pierden la votación, para
que descartar no salga gratis. Opcional.

**Sincronización (diseño, sin probar)**: los candidatos se sacan con `GetRandomInt` en código común al empezar el
descanso (mismo resultado en todos los clientes). Cada voto llega por el clic del trackable, que ya viaja por red
(memoria `trackables-latencia-red`); el recuento y el desempate al azar se hacen en código común al acabar el descanso.
Lo único local es dibujar la ventana y el estado "ya votaste".

**Por decidir**
- Confirmar que las "2 mejoras por oleada" son del héroe (estrellas 1–3 suben su calidad).
- Ventana de Mutación Evo: 3 filas a la vez o 3 pasos seguidos.

## 14/11/2026, séptima tanda: Mutación Evo

- **Nombre del apartado**: **Mutación Evo** (cuadro carmesí central de la tienda).
- **3 elecciones por descanso, una por nivel**: 1 mejora para el **jefe**, 1 para las **élites** y 1 para los
  **comunes**. Cada nivel tiene su propia fila de candidatos y su votación (mismas reglas: más votado, empate o sin
  votos al azar). La tienda se desbloquea al votar las 3.
- La lista recomendada (18) vale; se pueden añadir más. Cada mejora lleva su nivel (jefe / élite / común).
- **Estrellas de 1 a 3, igual que Dark Moon**, para no complicarlo. 3 estrellas = mejor calidad para las 2 mejoras del
  héroe (lectura provisional, ver "Por decidir").
- Cuadros por nivel (propuesta): 3 candidatos con 1–2 jugadores, 4 con 3–5 y 5 con 6–8 (compensa la falta de
  refresco). Ventana: 3 filas (jefe arriba, élite, comunes) o 3 pestañas en secuencia como en PVZ; se decide en la fase
  de interfaz. Al terminar el descanso se muestran los 3 ganadores 8 s.

## 14/11/2026, octava tanda

- **Mejoras del héroe: 2 por oleada; si el jugador no las usa, las pierde.** Sustituye a mi decisión de "hasta 3
  pendientes": lo no elegido se pierde al empezar la oleada siguiente.
- **Las estrellas suben la probabilidad de mejores cartas** (calidad más alta en las 4 opciones), con escala 1–3.
- **Mutación Evo en 3 pasos seguidos**, como en PVZ: jefe → élite → comunes, cada paso con su aviso.

## 14/11/2026, novena tanda: piezas de PVZ Fusion que entran

Leon aprueba las cinco, como se propusieron:
1. **Calidades con color** en las 2 mejoras del héroe por oleada, con los mismos colores de tier de la tienda de armas
   (borde del cuadro). Las estrellas (1–3) desplazan la probabilidad hacia calidades altas. Cada mejora tiene un valor
   por calidad (p. ej. daño +10 % en plata, +30 % en diamante).
2. **Suerte** por jugador: sube con las estrellas y al recoger bolsas, baja al refrescar cartas; más suerte = más
   probabilidad de calidad alta, sumada a las estrellas. **Garantía**: tras 3 oleadas sin sacar oro o superior, la
   siguiente lo asegura. Mutación Evo puede incluir mejoras de enemigos que quitan suerte. Contador visible en la tienda.
3. **Mejoras malditas**: raras entre las 4 opciones del héroe, cuadro morado oscuro, gran ventaja con coste claro.
   Ejemplos: "Sed de sangre" (+40 % daño de armas, sin curación), "Codicia" (bolsas ×2, +25 % de daño recibido),
   "Pacto mutante" (+6 % de daño por cada Mutación Evo activa).
4. **Golpe de suerte**: estadísticas nuevas de probabilidad y daño de crítico de las armas, calculadas por código al
   impactar, con número o efecto distinto. Entran en el grupo de mejoras de estadística.
5. **Vueltas tras la ronda 10**: al vencer al jefe 10 se repiten las rondas 1–10 con enemigos más fuertes (+20/40/60 %
   de vida por vuelta), conservando armas, mejoras y Mutaciones Evo. **Al final**, con las dificultades.

Valores iniciales (probabilidades por calidad, suerte ganada y gastada, tasa de malditas, crítico base) se fijan en la
fase 9 con el registro de prueba.

## 14/11/2026, décima tanda: el modelo PVZ sustituye a la recompensa de Dark Moon

- Las mejoras del jugador de Dark Moon (2 de estadística + 2 de habilidad fijas, rareza normal/mítica) son el mismo
  concepto que las de PVZ; **se reemplazan por el modelo PVZ**: 4 cartas mezcladas por tipo (estadística, habilidad
  especial, economía, maldita), calidad con color, suerte con garantía, crítico, refresco.
- **Se queda de Dark Moon**: súper élite (4 cuadros), bolsas de oro, puntuación con 1–3 estrellas, torres con oro,
  curaciones al morir la élite, tiempos nightmare de prueba.
- **Viene de PVZ**: mejoras del héroe y Mutación Evo (mejoras de enemigos acumuladas, por votación en 3 pasos).
- Valores que pueden reutilizarse de Dark Moon como punto de partida: refrescos (2 al empezar, +1 cada 2 rondas) y el
  ajuste de valores por tipo de estadística (vida ×10, alcance ×4…). Se decide en la fase 9.

## Libro de habilidades especiales

- **Base**: el Libro de hechizos de Warcraft III (habilidad 'Aspb', también usada por objetos). Comprobar en los datos de
  1.27b: número máximo de habilidades dentro, cómo se añaden (lista del libro o `SetPlayerAbilityAvailable`), y que dos
  habilidades con la misma orden base comparten enfriamiento (cada especial debe tener su propia orden; p. ej. Canalizar
  con orden base distinta).
- **Contenido**: las habilidades especiales que el personaje haya desbloqueado; se desbloquean y mejoran con las
  elecciones de fin de ronda.
- **Mejoras por código**: alcance, daño, número de proyectiles, formas (abanico), efectos añadidos; por tiers.
- **Mejoras por nivel**: enfriamiento, coste de maná y otros datos sin función en 1.27b.
- **Por personaje**: Goku, Freezer, Trunks y Naruto con todas sus habilidades D.O.N (memoria
  `don-habilidades-pendientes`, `dbz-fidelidad-don`) y Cairne con las suyas; luego se recortan. Tauren pendiente.
- **Casilla propia**: el libro es una habilidad del personaje junto a las armas Q/W/E/R (comprobar qué casilla de la
  botonera queda libre).
- **Primero el marco, luego las mejoras**: cuadros de elección y evento de mejora funcionando con mejoras de prueba
  (sólo registran que se aplicaron); las mejoras reales se anclan al final.
- **Iconos ya visibles**: cada cuadro de habilidad muestra el icono de una habilidad real y se puede seleccionar, pero
  no aplica nada hasta plantear las habilidades al final.

## Preguntas abiertas

1. Valores iniciales de calidades, suerte, malditas y crítico (se fijan en la fase 9 con registros).
2. Habilidades concretas y tiers de cada personaje: se deciden con el marco ya hecho.
3. Habilidades del Tauren y cuáles de Cairne (sin auras; Reencarnación ya se usa para reaparecer).
4. Edificios y torres: se plantean al final.

## Fases propuestas

1. **Marco de cuadros**: ventana de 4+ cuadros reutilizable (retrato vivo, texto en textura, botón por trackable, color
   de fondo por tipo: héroe, enemigo, carmesí), evento de elección y registro. Base de las fases 2, 7, 8 y 9.
2. **Súper élite al azar**: temporizador por ronda (6 s y 20-30 s), enemigo vivo que no sea jefe ni élite, vida y daño
   multiplicados, 2 mejoras de estadística (valores nightmare) + 2 pasivas de WC3, mostradas con el marco.
3. **Textos fijos a textura**: inventario de los texttags fijos del HUD y la tienda; pasar a BLP los que no cambian.
4. **Bolsas de oro**: extra que crece por ronda calibrado contra los precios de tier; tres tamaños (común, élite, jefe);
   recogida al acercarse con un reloj ligero; caducidad a 35 s; registro de economía.
5. **Puntuación de fin de ronda**: cuadro con 1–3 estrellas (bolsas caducadas y muertes), al acabar la ronda.
6. **Libro de habilidades especiales**: habilidad con casilla propia; todas las D.O.N y de Cairne; iconos sin efecto.
7. **Tienda con apartados**: pantalla inicial con 2 cuadros (armas / habilidades especiales) bloqueados y Mutación Evo
   en el centro (carmesí); aviso de elecciones pendientes en el HUD.
8. **Mutación Evo**: 3 votaciones por descanso (jefe, élite, comunes); mismos candidatos para todos, más peso a las
   unidades de la ronda siguiente, cuadros extra según jugadores, sin refresco; desbloqueo de la tienda al votar;
   recuento y desempate en código común; muestra de 8 s de los ganadores antes de la oleada. Primero con mejoras de
   prueba que sólo registran; luego las 18 recomendadas y las que se añadan. Prueba LAN de dos clientes obligatoria.
9. **Elección de mejoras del héroe (modelo PVZ)**: 2 por oleada, 4 opciones mezcladas (estadística, habilidad
   especial, economía, maldita), refrescos con contador, calidad con color según estrellas y suerte (con garantía), malditas raras, crítico como estadística;
   lo no elegido se pierde al empezar la oleada. Primero mejoras de prueba; las reales al final.
10. **Al final**: mejoras reales de habilidades; edificios-torre con oro; curaciones al morir la élite; dificultades;
    vueltas tras la ronda 10.

Orden de fases cerrado el 14/11/2026 (pendiente sólo de valores y de habilidades concretas).

Cada fase es una versión nueva (`vNN` + letra) con su `hacer-vNN.sh`, normal y prueba, según la skill mapa-dev-mission.

## Estado de las fases

### Fase 1, v17s (14/11/2026): marco de cuadros — **Validated**, sin probar en el mapa

Fuentes: `scripts/v17s.py`, `scripts/objetos_v17s.py`, `scripts/hacer-v17s.sh`; base v17r / v17r-prueba (hashes
comprobados por el script). Lanzadores `scripts/entrar-v17s.sh` y `entrar-v17s-prueba.sh`; copias también en WOE
`Maps/Test/DevMission-v17s(-prueba).w3x`.

- `TerrainDev-Titulo-v17s.w3x` 6dde5a59b8802eb9ee3bd8da635954a824ee7028fbeede04be0fea85d419a795
- `TerrainDev-Titulo-v17s-prueba.w3x` 12445ff5218fbfa015454e509fd128f97826f3842231aaa95e25f6ca37f57ab8

Qué hace:
- Escena propia en (4800, 8700) con ancla `Menu_Ancla[2]` (los trackables no se quitan; en la escena de la tienda
  interceptarían sus clics). Niebla visible ampliada con el rectángulo 4000..5600 × 7700..9700.
- Esc en el golem durante el descanso abre primero los cuadros: Mutación Evo jefe → élite → comunes (fondo carmesí) y
  mejora del héroe 1/2 → 2/2 (verde). Al elegir el quinto se abre la tienda de siempre. Esc sale y guarda el paso.
- Candidatos sorteados al empezar el descanso (`Cua_Sortear` desde `Ronda_AlTerminar`, código común): Mutación Evo
  igual para todos (3 / 4 / 5 cuadros con 1–2 / 3–5 / 6+ jugadores; jefe y élite como mucho 4), héroe 4 por jugador.
  El sorteo nuevo borra lo no elegido (se pierde al empezar la oleada). Sorteo uniforme, sin peso de unidades.
- Cuadro: fondo `DS01` teñido, icono del juego (destructables `DC00`–`DC0G`, rutas BTN de war3.mpq/War3x.mpq
  comprobadas), nombre, descripción y botón «Elegir» con trackable `CuaHitBtn.mdx` (170 × 56 px). Sólo el botón es
  clicable. 9 posiciones fijas cada 180 px; n cuadros usan `5 − n + 2j`.
- Elegir no cambia nada: mensaje «(aún sin efecto)». 18 texttags locales con la ventana abierta; reloj del descanso.
- Prueba: sorteo y elecciones en `CustomMapData\lat\v17s-cuadros.txt`, escrito 1 s después del último evento.

Comprobado: pJASS correcto (normal y prueba), reextracción por hash del j, w3b y mdx, miembros ajenos iguales,
`mpq verify`. No comprobado: nada en el juego (posición y tamaño de textos, tinte del fondo, que el icono cambie al
elegir, clic del botón, Esc a mitad). Votación, refresco, calidades, pantalla de apartados y muestra de 8 s siguen en
las fases 7–9. El retrato vivo del marco queda en icono por ahora (las unidades reales vistas desde arriba se ven mal).

### v17s en el juego y v17t (14/11/2026)

Primera prueba de Leon con v17s-prueba (1 min 28 s, vídeo `Videocaptura de pantalla_20261114_225032.mp4`): al pulsar
Esc junto al golem la pantalla queda **negra del todo**, sin cuadros ni textos; al salir vuelve la partida. El registro
sólo tiene el sorteo de la ronda 1 (Corona/Escolta/Furia; Ascenso/Último aliento/Élite feroz; Red de pesca/Lluvia de
flechas/Caparazón). Como tampoco salen los texttags, la cámara no mira a (4800, 8700). Causa sin confirmar; sospecha:
el ancla 'dumi' creada con CreateUnit no queda en su punto.

v17t: ancla fijada con SetUnitX/SetUnitY; la de prueba anota 0,5 s tras abrir la ventana o la tienda el ancla, el
objetivo y el ojo de la cámara, máscara/niebla en el punto y una pieza (visible, posición, vuelo, suelo), en
`lat\v17t-cuadros.txt`. **Validated** (pJASS, reextracción, mpq verify); sin probar en el mapa.
- `TerrainDev-Titulo-v17t.w3x` 12a3ab280f4dac0fc45d0082a276eca61547fd63b4e64d387d91c13e0af23f72
- `TerrainDev-Titulo-v17t-prueba.w3x` bb04ad4555c488edc7a6d009e0232d048976e9b4edae52a3e39f78b0c10265d6

Prueba de Leon con v17t-prueba (14/11/2026, 1 min 34 s, vídeo `Videocaptura de pantalla_20261114_225550.mp4`):
**Tested in map (un jugador)**. La ventana se ve: cabecera carmesí/verde, 3 cuadros de Mutación Evo por paso y 4 del
héroe, iconos que cambian por paso, reloj del descanso; los 5 clics llegan y se abre la tienda de siempre. Registro:
ancla y cámara en (4800, 8700, 209,5), ojo a 1859,5, sin máscara ni niebla, fondo visible a vuelo 1220. Con el ancla
fijada la escena aparece (en v17s salía negra): la causa del negro queda atribuida al ancla, sin la medida de v17s.
Detalles a pulir: descripción muy pequeña y mitad inferior del cuadro vacía; «Elegir» cae sobre el borde inferior
del botón; el pie se parte en dos renglones; los avisos «(aún sin efecto)» salen encima de los cuadros y siguen en la
tienda. Esc a mitad no se probó.

### v17u: cuadros pulidos y fase 2, súper élite (14/11/2026)

Leon: "pullir y avanzar la siguiente fase". Fuentes `scripts/v17u.py`, `scripts/objetos_v17u.py`,
`scripts/hacer-v17u.sh`, lanzadores `entrar-v17u(-prueba).sh`.

Cuadros: cuadro de 480 de alto (antes 560), icono de 190, nombre 0,025 y descripción 0,021 (antes 0,016); botón y zona
de clic a y 610; «Elegir» subido (el texto se dibujaba ~25 px por debajo de su punto, medido en el vídeo de v17t); pie
corto en un renglón ("Esc: salir (se guarda hasta la oleada)"). Al elegir ya no hay aviso: lo elegido se junta y sale
en un solo aviso de 8 s al empezar la oleada ("Elegido para esta oleada (aún sin efecto): …").

Súper élite (fase 2):
- Temporizador por oleada: primera a los 6 s de `Ronda_Lanzar`, luego cada 20-30 s; 2 s de reintento si no hay
  candidatos; se para en `Ronda_AlTerminar`.
- Candidatos: unidades vivas y visibles de los dueños 8-13 de los 10 tipos comunes, sin la marca 'Sp0M'. Élites,
  jefes y súper élites quedan fuera. Elección al azar uniforme en código común.
- Vida × m con 'Sp0L' (AIlf de 15 niveles, nivel b + 2 = 2^b, mismo truco que la vida de las élites en
  `DevFuego_Aparece`), conservando la proporción de vida. Daño: 'Sp0M' (AIat) = daño medio del tipo × (m − 1), con el
  daño medio sacado de UnitWeapons.slk de 1.27b (el script de 1.27b no puede leer el daño).
- Estadísticas: 'Sp0D' daño (+2 por nivel), 'Sp0A' armadura, 'Sp0V' robo de vida, 'Sp0S' velocidad de ataque,
  'Sp0E' evasión (tope 50 %), 'Sp0R' regeneración, 'Sp0O' velocidad de movimiento; 100 niveles cada una, nivel = valor.
  Factores de armadura y robo de vida según el plan. **Elección mía, para revisar:** evasión y regeneración usan los de
  armadura (1/3, 0,5, 0,65, 0,8).
- Pasivas (sin auras, rawcodes del juego sin copiar): Golpe aplastante 'AIbx', Golpe crítico 'AIcs', Piel endurecida
  'Assk', Caparazón espinoso 'ANth', Ataque hendiente 'ACce' (sólo cuerpo a cuerpo), Orbe de escarcha 'AIob', Veneno
  lento 'AIsz' (los dos orbes no van juntos). Nivel 1, sin la regla de nivel de la criatura de Dark Moon.
- Marca: modelo de Frenesí profano sobre la cabeza.
- HUD: cabecera "Súper élite: vida y daño ×m" y 4 tarjetas a la izquierda (x 30-330, y 317-559): fondo de racha
  'DS18' dorado para las 2 de estadística ("+21 de daño") y violeta para las 2 pasivas (nombre). Iconos DE00-DE0D (BTN
  del juego), recreados al cambiar la súper élite que se muestra (la más reciente viva). Ocultas con tienda o cuadros
  abiertos. 5 texttags locales por jugador.
- Prueba: `lat\v17u-super.txt` con candidatos, multiplicador, vida antes/después, nivel real de cada habilidad,
  muertes y fin de oleada; los cuadros en `lat\v17u-cuadros.txt`.

Estado: **Validated** (pJASS de las dos variantes, j/w3a/w3b reextraídos iguales, resto igual a v17t, mpq verify).
Sin probar en el mapa ni en multijugador. Copias en WOE `Maps/Test/DevMission-v17u(-prueba).w3x` comparadas con cmp.
- `TerrainDev-Titulo-v17u.w3x` 3c91ff39e0257fc5725dc1420b51c5fe4ccf4d03d072f1b6cd11b02ccbf57c49
- `TerrainDev-Titulo-v17u-prueba.w3x` d655260acc83ad10b576ee56b12742a7e1abc3c4f1ad85c5a3ef2956d7ec0a7d

Pendiente de comprobar en la prueba:
- que la vida y el daño suben (mirar el panel de la unidad);
- que los niveles de las habilidades aplican su valor;
- dónde quedan las tarjetas y sus textos;
- los textos nuevos de los cuadros;
- Esc a mitad de los cuadros.

### v17v: súper élite sin cuelgue (14/11/2026)

Resultado de v17u-prueba (Leon): tirón fuerte al salir las 4 tarjetas; en la segunda partida el juego se cerró. El
registro mostró la vida de la súper élite bajando (120 → 90). El rastreo puso el hilo principal al 100 % justo en cada
creación de súper élite. Informe: `Proyect/informes/errores/resueltos/2026-11-14-232017-v17u-super-elite-cuelgue.md`.

Cambios (`scripts/v17v.py`, `scripts/objetos_v17v.py`, `scripts/hacer-v17v.sh`, lanzadores `entrar-v17v(-prueba).sh`):
- Sin habilidades de varios niveles: daño, armadura, velocidad de ataque y regeneración con una habilidad de un nivel
  por bit; evasión y robo de vida por tramos de 5 %; vida con `ALh0..ALhA`; velocidad con `SetUnitMoveSpeed`.
- Todas se precargan al entrar en una pieza oculta, con `Preload` del modelo de marca.
- La prueba anota vida antes/después y los bits puestos en `lat\v17v-super.txt`.

Hashes: v17v d203032dbaaec865…, v17v-prueba 92fe34500223475a…. Estado: **Validated** (pJASS, reextracción, mpq
verify). Pendiente en juego: sin tirón al aparecer; vida y daño suben; posición y textos de tarjetas y cuadros; Esc a
mitad de los cuadros; multijugador.

### v17w: precarga aplazada y marcada (14/11/2026)

v17v-prueba se cerró al terminar la barra de carga (Leon). v17w sólo cambia el j: la precarga de la súper élite
corre 3 s después de entrar, y la de prueba anota cada paso en `lat\v17w-precarga.txt` para saber dónde se cierra.
Hashes: v17w 82a70f69…, v17w-prueba 9aeebff9…. Estado: **Validated**. Pendiente: lo mismo que v17v, más el resultado
de `v17w-precarga.txt`.

### v17x: súper élite con BonusMod (14/11/2026)

v17w-prueba se cerró en el paso 4 de la precarga: la armadura con base AIde. Leon pasó BonusMod.w3x y pidió
adaptarlo. Créditos: **BonusMod v3.3.1 de Earth-Fury, basado en el trabajo de weaaddar**; SetUnitMaxState y
AbilityPreload del mismo mapa de ejemplo.
- Objetos `(A)` armadura (AId1), `(B)` daño (AItg), `(C)` visión, `(D)` maná %, `(E)` regeneración (Arel),
  `(F)`-`(H)` atributos de héroe, `(I)` velocidad de ataque (AIsx), `Zx00`/`Zx01` maná y vida máximos, copiados tal
  cual; sustituyen las `(A)`-`(I)` viejas sin uso y las `SpD/SpA/SpS/SpR`. Siguen `SpM0`, `SpE*`, `SpV*`.
- JASS: `BM_Set/BM_Get/BM_Add` (tipos 0 armadura, 1 daño, 2 regeneración, 3 vel. ataque) y `BM_VidaMax`.
- Precarga en `main` (durante la carga). La de prueba escribe cada paso en `lat\v17x-precarga.txt` (18 = fin).

Hashes: v17x e661ea6f…, v17x-prueba d7bd3605…. Estado: **Validated**. Pendiente en juego: precarga hasta el paso
18; vida, daño y armadura de la súper élite suben; sin tirón; tarjetas y cuadros; Esc; multijugador.

Resultado de v17x-prueba (Leon, con grabación): **Tested in map** (un jugador). Precarga completa en la carga; dos
súper élites con vida 120 → 150 y bonus aplicados; sin picos del hilo principal al crearlas; cuadros elegidos y fin de
oleada correctos. Falta: una súper élite con armadura; los iconos de las tarjetas se ven oscuros en la grabación;
multijugador.

### v17y: tarjetas en escalera (14/11/2026)

Leon: los cuadros de bonus deben entrar "tipo escalera" desde fuera de la pantalla y ocultarse igual. Fuente
`scripts/v17y.py` (sólo cambia el j), `hacer-v17y.sh`, lanzadores `entrar-v17y(-prueba).sh`.
- Cada tarjeta entra desde 420 px a la izquierda en 0,25 s, una cada 0,08 s; la cabecera con la primera. Salen igual
  al morir la súper élite, al acabar la oleada o al cambiar a otra (y entra la nueva). Tienda/HUD oculto: al momento.
- Iconos: en la grabación de v17x quedaban tapados por el fondo; el fondo pasa a 412 de la cámara (icono a 398) con
  tamaño corregido. Es la causa probable, no comprobada.
- Prueba: carga, entrada, salida y fuera por jugador en `lat\v17y-super.txt`.

Hashes: v17y 3ffc8e34…, v17y-prueba 95c4b0fb…. Estado: **Validated**. Pregunta abierta: ¿"tiempo de vista" fijo
(p. ej. N s) o mientras viva la súper élite, como ahora?

Resultado de v17y-prueba (Leon, 1 min 38 s, con grabación): **Tested in map** (un jugador) para la escalera:
entrada a 9,000 s, salida a 12,180 s y fuera a 12,680 s; la segunda súper élite entró a 30,852 s y salió a 54,320 s;
en el vídeo cada tarjeta entra y sale en orden. Los iconos siguen oscuros: el fondo a 412 no lo corrigió.

### v17z: iconos delante del fondo (15/11/2026)

Causa de los iconos oscuros: lo translúcido se ordena por la distancia real al ojo de la cámara, no por el rango de
`HealthBars__Place` (distancia a lo largo del eje). Fuera del centro la distancia real es rango × sqrt(1 + desvío²):
el icono (398, x 60) quedaba a ~482,6 y el fondo (412, x 180, más cerca del centro) a ~479,5, así que el relleno
oscuro de `DS18` (alfa 215) se dibujaba encima. Ese criterio explica también el relleno de la tienda a 385.
- Icono a 380, tamaño ×380/400: en todo el deslizamiento queda 19-22 unidades por delante del fondo.
- Fuente `scripts/v17z.py` (sólo cambia el j), `hacer-v17z.sh`, lanzadores `entrar-v17z(-prueba).sh`; registros en
  `lat\v17z-*.txt`.

Hashes: v17z 2baa6f07…, v17z-prueba d912877a…. Estado: **Validated**. Pendiente en juego: iconos con su color;
pregunta abierta de v17y sobre el "tiempo de vista"; súper élite con armadura; multijugador.

### v18a: tirada como "Super Creep Random Boost" de Dark Moon (15/11/2026)

Leon envió una grabación de Dark Moon y pidió seguirla, con el sonido del original en cada cambio. Medido en el vídeo a
60 fps: el panel entra en bloque desde la izquierda en ~0,1 s; las 4 cartas cambian a la vez cada 0,2 s y se fijan a
los ~2,4 s; luego se quedan. Fuentes `scripts/v18a.py`, `scripts/sonido_v18a.py`, `hacer-v18a.sh`, lanzadores
`entrar-v18a(-prueba).sh`; sonido en `sonidos-darkmoon/` (LEEME con procedencia; sonido de Valve, sólo prueba privada).
- Entrada y salida en bloque en 0,12 s (sustituye la escalera de v17y).
- Tirada: 13 cambios cada 0,2 s con iconos y valores al azar; el 13.º pone los de la súper élite. Se sortea en el tick
  del HUD, igual en todos los clientes.
- `war3mapImported\SupTic.wav`: promedio de 6 tics del vídeo (correlación 0,71-0,85), 0,19 s; suena en cada cambio
  sólo para el jugador y si ve sus tarjetas, volumen 100/127.
- Iconos: 7 por ranura creados en `Sup_HudCrear` (28 por jugador); la tirada sólo cambia cuál se ve. Siguen a 380.

Hashes: v18a 7895b03e…, v18a-prueba aaf8d607…. Estado: **Validated**. Pendiente en juego: entrada, 13 cambios con tic
y valores finales correctos; volumen del tic; iconos con color (v17z); multijugador (el sorteo de la tirada usa
GetRandomInt en el tick sincronizado: comprobar en LAN).

## v18b (15/11/2026): sonido original de la tirada

- Leon probó v18a: el tic "suena muy diferente al del dark moon"; pidió además un sonido nuevo en cada cambio
  (uno solo reutilizado se corta y satura).
- Causa: v18a promediaba del vídeo un tic de 0,19 s; el real dura 0,69 s y se solapan hasta 4.
- Sonido real: `BoostCreeps.Random` → `panorama_custom_lobby_drawer_slide_in_01` de Dota 2 (procedencia en
  `work/titulo-devmission-20261026/sonidos-darkmoon/LEEME.md`). Se mete tal cual, 44,1 kHz estéreo.
- `Sup_Hud`: en cada cambio `CreateSound` en todos los clientes, volumen 100 sólo para el jugador que ve sus
  tarjetas (0 en el resto), `StartSound` y `KillSoundWhenDone`. `Sup_TicSnd` de init queda sólo para precargar.
- Fuentes: `scripts/v18b.py`, `sonido_v18b.py`, `vpkmulti.py`, `hacer-v18b.sh`; lanzadores `entrar-v18b(-prueba).sh`.
- Hashes: v18b 3eaec51210c6…; v18b-prueba 701b0a49be0d…
- Estado: **Tested in map** (v18b-prueba de Leon, 15/11/2026: 4 tiradas de 13 cambios cada 0,2 s; en su grabación
  el sonido original aparece en cada cambio, correlación 0,5-0,88). Leon: "sonido perfecto". Sin probar en multijugador. Pendiente aparte: cartas repetidas durante la tirada y cuadro oscuro a la derecha.

## v18c (15/11/2026): fondo propio, súper sólo en élites, tirada común y tamaños

Pedido de Leon tras v18b:
- Quitar el cuadro negro junto a las 4 mejoras. Causa: el fondo era RachaCaja.blp ('DS18'), que guarda a la derecha
  el fondo oscuro del retrato de la racha. Ahora 'DSC0' con SupCaja.blp propio (`scripts/tarjeta_v18c.py`).
- Las mejoras son generales, iguales para todos. Ya lo eran: la súper élite, sus valores y su efecto se eligen en
  código común. Lo que cambiaba por jugador era la tirada (valores al azar intermedios); desde v18c los 12 cambios se
  sortean al crear la súper élite y todos ven la misma, sin estadística ni pasiva repetida dentro de un cambio.
- La súper élite es exclusiva de élites. Candidatas: élites y comunes vivas de la oleada. Si toca una común,
  `Sup_Convertir` crea la élite de su tipo en su sitio (orientación, dueño, proporción de vida), la registra como
  externa de la común (`WaveRegisterExternalUnit`: cuenta en la oleada, IA, vida por ronda de `DevFuego_Aparece`) y
  mata y quita la común sin cadáver. Su muerte cuenta para los eventos de élites.
- Élites más grandes y jefes casi del tamaño del jefe 10 (`scripts/tamanos_v18c.py`, medidas de la secuencia Stand de
  los MDX del juego por modelScale):

| Tipo | Élite (antes 1,8) | Jefe (antes 2,7) |
|---|---|---|
| nmcf, nlpr, ntrh, nmtw, nmsn | ×2,5 | ×6,5-7,3 (sólo nlpr..nmsn) |
| nlds, nmmu, nnsw | ×2,5 | ×4,1-4,5 |
| ntrg | ×1,94 | ×2,92 |
| ntrd | ×1,8 | ×2,7 (jefe 10, sin cambio) |

  Jefes 2-9 al 90 % del jefe 10 (858 frente a 953); élites como mucho al 60 % (572). Selección (`ussc`, UnitHitShape)
  y altura de la barra (`Sup_Barra`) siguen al factor.
- Fuentes: `scripts/v18c.py`, `objetos_v18c.py`, `tamanos_v18c.py`, `tarjeta_v18c.py`, `hacer-v18c.sh`; lanzadores
  `entrar-v18c(-prueba).sh`. Hashes: v18c 9ea4f2b58ee5…; v18c-prueba 7ddc42a473e8…
- Estado: **Tested in map** con v18c-prueba (5 súper élites, todas cambiadas desde comunes con su proporción de vida;
  grabación 011321: tarjetas sin cuadro negro y élite más grande con la barra encima). Jefes no alcanzados; sin LAN.
  Antes era: **Validated** (pJASS; reextracción de j, w3u, w3b, imp y SupCaja.blp; resto igual a v18b). Sin probar en el
  mapa. A mirar en la prueba: la élite que sustituye a la común (IA, sigue a un jugador, vida), el alcance de ataque
  de los jefes cuerpo a cuerpo ahora mucho más grandes, y las barras de vida a la nueva altura.

## v18d (15/11/2026): mejoras para todas las élites

Leon, tras probar v18c: las mejoras de élite son para todas, también para las que estén por salir; si ya no pueden
salir élites, pausa; al acabar su tiempo se retiran y, al fijarse la tirada nueva, se ponen las nuevas.

- Cada tirada sortea un juego de mejoras sin unidad (vida y daño ×m, 2 estadísticas, 2 pasivas) en código común.
  Al fijarse (2,55 s) se aplica a todas las élites vivas ('ne00'..'ne09' de los dueños de oleada) y, mientras dure
  (20-30 s), a cada élite que aparezca (`DevFuego_Aparece` → `Sup_Dar`).
- Al acabar su tiempo `Sup_Tick` las quita de todas (`Sup_Quitar`, con lo guardado por unidad en `Sup_HT`: vida
  sumada, daño sumado, juego puesto, efecto) y las tarjetas salen; después empieza otra tirada.
- Pausa: sin élites vivas, sin eventos de élite pendientes (`DevWave_EliteSig > DevWave_EliteE`) y sin élites en cola
  (`DevWave_ColaI >= DevWave_ColaF`) no se tira. La primera élite que aparezca la reanuda a los 0,5 s. En la ronda 1 no
  hay eventos de élite: queda en pausa toda la ronda.
- Quitado: el cambio de común a élite de v18c (`Sup_Convertir`), porque las mejoras ya no van a una unidad elegida.
  Pendiente de que Leon diga si lo quiere de otra forma.
- Tarjetas: cabecera "Élites: vida y daño ×…". Valores con tope: daño ≤ 200, robo de vida y evasión en tramos de 5 %
  (5-50), resto ≤ 127.
- Fuentes: `scripts/v18d.py`, `hacer-v18d.sh`; lanzadores `entrar-v18d(-prueba).sh`. Sólo cambia war3map.j.
  Hashes: v18d 9c35e32d293c…; v18d-prueba 736aa144bb5b…
- Registros de prueba en `lat\v18d-super.txt`: tirada, "aplicadas N a M elites", "nueva elite … recibe N",
  "retiradas de M elites", pausa, reanuda, fin de oleada.
- Estado: **Tested in map** con v18d-prueba (15/11, registro `lat\v18d-super.txt`, rondas 1-2): pausa en la ronda 1
  a los 9 s; en la 2, 4 tiradas; retiro al acabar cada una (de 0, 1, 0, 0 élites vivas); una élite nueva recibió la
  tirada vigente; tirada 2 aplicada a 1 élite viva; pausa a los 162 s y reanudación al salir ne01 a los 173 s; fin de
  oleada limpio. Sin LAN. Antes: Validated (pJASS de las dos; reextracción del j; resto igual a v18c; `mpq verify`).

## v18e (15/11/2026): multiplicador barajado y élites más duras

Leon, tras probar v18d (la élite tras la pausa vino de "llamando refuerzos", y el ciclo volvió a barajar bien):
- El multiplicador de vida y daño también se baraja, con sumas más grandes: real = 1,25 + 0,05 (r − 1) + 0,05 × (0..12),
  tope ×3 (ronda 2: ×1,30-1,90). Cada cambio de la tirada muestra en la cabecera uno al azar del mismo rango
  (`Sup_RM`, código común); el 13.º fija el real.
- Élites al 35 % de la vida del jefe de la ronda. Premisa corregida: Leon creía que estaban al 20 %, pero la fórmula
  vieja (0,20 × 800 × (1 + 0,75 (r − 1)) − 160 sobre base 320) daba el 11-16 % del jefe real (w3u: 400 + 1200 r con
  un jugador). Ahora 0,35 × (400 + 1200 r): 980 (r2) … 4340 (r10), antes 440 … 1400. Con 'Rdjv' (más jugadores) el
  jefe sube y la élite no: la proporción baja con más jugadores, como antes.
- Fuentes `scripts/v18e.py`, `hacer-v18e.sh`; lanzadores `entrar-v18e(-prueba).sh`. Sólo cambia war3map.j.
  Hashes: v18e 0fbc051c7b58…; v18e-prueba 8732ddb4697d…
- Estado: **Validated** (pJASS de las dos; reextracción del j; resto igual a v18d; `mpq verify`). Sin probar en el mapa.

Con esto la fase 2 (súper élite) queda completa salvo la prueba LAN.

## Fase 3: inventario de textos fijos (15/11/2026, sobre el j de v18e)

Texttags que se crean con texto que nunca cambia, candidatos a pasar a textura (todo local del cliente que lo ve):

| Dónde | Textos fijos | Texttags | Cuándo |
|---|---|---|---|
| Tienda (`Shop_Textos`) | "Categorías", "Precio", "Daño", "Cargador", "Cadencia", "Precisión", "Oro", "Salir (Esc)" | 8 | al abrir la tienda |
| Tienda | nombres de las 6-7 categorías (`Cat_Nombre`) | 6-7 | al abrir la tienda |
| Cuadros de elección (`Cua_TB`) | "Elegir" en cada cuadro | 1 por cuadro | con los cuadros abiertos |
| Aviso de tienda (`DevTienda_Aviso`) | "Press [ESC] …" / "[ESC] Pic…" en degradado, 2 variantes | 1 por jugador | partida |

No son fijos (se quedan como texttag): reloj y 30 textos de la tienda (`Shop_T`, precios, valores), valores de las
barras, ronda y su cifra, batería, arma y balas, tarjetas de racha y de élites, nombre y descripción de los cuadros.

Propuesta: primer lote, los 14-15 fijos de la tienda pintados en su fondo (de 45 texttags al abrir a ~30); luego
"Elegir" en el fondo del cuadro y el aviso de ESC como pieza con textura. Leon dio el visto bueno ("Sí, empieza").

### Fase 3, v18f (15/11/2026): etiquetas fijas de la tienda

- Las 8 etiquetas fijas (Categorías, Precio, Daño, Cargador, Cadencia, Precisión, Oro, Salir (Esc)) son piezas
  `Shop_Pic` con textura propia ('DSE0'..'DSE7', `TiendaEt0..7.blp`), profundidad 397. Los nombres de categoría siguen
  como texttag porque cambian de color al elegirlos. Texttags al abrir la tienda: de 45 a 37.
- Medidas sobre la grabación 020522 (tienda de v18d): el texttag mide como Friz Quadrata a ~985 px por unidad de
  tamaño ("Categorías" algo mayor: se ajusta a sus 137 px); se pinta a 4× con trazo de un cuarto de píxel para igualar
  el grosor. Posición: centro de la tinta medido; `Shop_Pic` no cae en sus coordenadas (gemas: x = −22,6 + 1,022 px,
  y = 0,8 + 1,020 py, resto ≤ 1,5 px), se invierte. Texturas 1:1 con la pantalla.
- Fuentes `scripts/etiquetas_v18f.py`, `objetos_v18f.py`, `v18f.py`, `hacer-v18f.sh`; texturas en `etiquetas-v18f/`.
  Hashes: v18f 44d44bc282c0…; v18f-prueba a770d2d200f8…
- Estado: **Tested in map** con v18f-prueba (15/11, grabación 161557, s 54): las 8 etiquetas caen a ≤ 2 px del centro
  que tenían en v18d (Salir 2 px a la derecha, Precio 2 px más arriba), mismo tamaño de tinta (±3 px) y sin recuadro
  alrededor. Sólo se jugó la ronda 1 (pausa de élites a los 9 s, correcta): v18e (multiplicador barajado, élites al
  35 %) sigue sin verse en el mapa. Sin LAN.
- Siguiente lote de la fase 3: "Elegir" de los cuadros y el aviso de ESC.

### Fase 3, v18g (15/11/2026): "Elegir", pie de los cuadros y aviso de la tienda

Leon (15/11): "si, y pasemos a la siguiente fase": se mantiene quitada la conversión de común a élite (v18d) y se cierra
la fase 3 con este lote.
- Cuadros: "Elegir" (Cua_TB) es la pieza 'DSE8' de cada ranura (Cua_Et, a 397, delante del botón) y el pie "Esc: salir
  (se guarda hasta la oleada)" (Cua_TPie, no estaba en el inventario) la pieza 'DSEB' (Cua_PieP). Mismo alfa local que
  el botón. Texttags con la ventana abierta: de 18 a 12.
- Aviso de la tienda: dos piezas del HUD por jugador ('uidb' + Arm_Foto, 512 × 64, 'DSE9' "Press [ESC] to buy
  supplies", 'DSEA' "[ESC] Pick up Ammo") con el degradado letra a letra y la sombra del texttag, colocadas con
  HealthBars__Place a 400 en el sitio del texto; ShowUnit en código común (DevTienda_AvisoK y la cámara lógica son
  iguales en todos), visibles sólo para su dueño, oscurecidas con JefeTx_F como las barras. Ya no se crea el UIText.
- Medidas (grabación 161557): s 42 cuadros ("Elegir" 58 px de tinta, centro 0,6 px a la derecha del botón, y 621; pie
  298 px, centro 946,5, 737,5); s 40,5 aviso (x 774-1098, y 516-539; empieza en 960 − 6,882 n). La variante de
  munición no salió en la grabación: se coloca por la misma regla (61,9 px más a la derecha).
- Fuentes `scripts/etiquetas_v18g.py`, `v18g.py`, `hacer-v18g.sh` (objetos con `objetos_v18f.py`); texturas en
  `etiquetas-v18g/` (TiendaEt8..11). Hashes: v18g f03376ace21e…; v18g-prueba 1e7218736baa…
- Estado: **Validated** (pJASS; reextracción de j, w3b, imp y los 4 blp; resto igual a v18f; `mpq verify`). Sin probar
  en el mapa. A mirar: "Elegir" y el pie en su sitio; el aviso de ESC en su sitio al acercarse al golem y al punto de
  munición, que siga a la cámara sin temblar y que se oscurezca con la presentación del jefe. HealthBars__Place no se
  había calibrado contra una pieza ancha: puede quedar algún píxel corrido.
- Con esto la fase 3 queda hecha (salvo prueba). Siguiente: fase 4, bolsas de oro.

## Fase 4, v18h (15/11/2026): bolsas de oro

Leon: "Sí, empieza". Valores míos, a ajustar con el registro (`scripts/v18h.py`, `objetos_v18h.py`, `hacer-v18h.sh`):
- Fondo extra por ronda r: 150 r por jugador, encima del oro de muerte y del premio de ronda (40 r + 10 r²).
- Comunes: 2 + J bolsas por ronda, en las muertes de comunes i × Total / (3 + J) (como los eventos de élites).
  Élites: una bolsa cada una. Jefe: 3 bolsas a 140 alrededor. Sólo con muerte real (no retiradas). Máximo 60.
- Tamaños: común c, élite 1,5 c, jefe 2,25 c; c = 150 r J / (2 + J + 1,5 (r − 1) J + 6,75). Con J 1: c = 15, 27, 35,
  42, 48, 52, 56, 59, 62, 65 (rondas 1-10); fondo completo si salen las élites previstas y el jefe.
- Modelos del juego: 'nbg0' PotofGold ×1,2, 'nbg1' PotofGold ×1,7, 'nbg2' treasurechest ×1,0 (copias de 'dumi', con
  Langosta, sin colisión ni minimapa).
- Recogida: reloj de 0,10 s sólo con bolsas en el suelo; héroe vivo fuera de la tienda a ≤ 160 (distancia al
  cuadrado); oro, efecto PileofGold y "+N" dorado local de 2 s. Caducan a 35 s, parpadeo los últimos 5 s.
- Registro de prueba `lat\v18h-bolsas.txt`: valores de la ronda, cada bolsa (creada, recogida con tiempo, caducada) y
  resumen al acabar la ronda (oro de muerte, premio, bolsas creadas/recogidas/caducadas con su oro, oro de j0).
  El resumen cuenta también bolsas de la ronda anterior recogidas en el descanso.
- Hashes: v18h b46ca67dc055…; v18h-prueba aaf6c9c49935…
- Estado: **Validated** (pJASS; reextracción de j y w3u; resto igual a v18g; `mpq verify`). Sin probar en el mapa.
  A mirar: que se vean los tres tamaños, que se recojan al pasar, el "+N", el parpadeo y la caducidad, y si el oro
  por ronda alcanza para subir de tier (registro). Pendiente de la fase: estrellas de ronda (fase 5) usarán las
  caducadas.

### Prueba de v18h-prueba (15/11/2026, grabación 20261115_163328, registros `lat\v18h-*.txt`)

- Bolsas: **Tested in map**, rondas 1-2, un jugador.
  - Ronda 1: 3 comunes de 15, recogidas a los 0,7-3 s.
  - Ronda 2:
    - 3 comunes de 27;
    - 2 de élite de 41, una de ellas de refuerzos;
    - 3 cofres del jefe de 61, recogidos 6-7 s después de aparecer.
  - Ninguna caducó, así que el parpadeo y la caducidad siguen sin verse.
  - En la ronda 2: oro por muertes 1111, premio 120, bolsas 346 (aprox. +28 %).
- "+N" dorado: se ve.
- Tamaño: desde la cámara de juego, las bolsas (PotofGold 1,2 / 1,7) y los cofres (1,0) se ven muy pequeños. Propuesta para v18i: subir las escalas.
- Aviso de ESC (v18g): **Tested in map**. Degradado y sombra correctos.
  - Medido: tinta en x 772-1100, y 527-549.
  - Original (v18f): x 774-1098, y 516-539.
  - Queda unos 11 px más abajo y 2 px a la izquierda. Corrección para v18i: cy −11.
- "Elegir" y el pie de los cuadros (v18g): sin medir. La grabación no recoge la ventana de cuadros, aunque el registro la muestra abierta en las rondas 1 y 2.
- Multiplicador de v18e: tira valores distintos (×1,35-×1,80 en la ronda 2). La vida de élite al 35 % no se registra.
- Sin LAN.

## v18i (15/11/2026): correcciones de la prueba de v18h

- El aviso de ESC sube 10,5 px (cy 524,7 → 514,2). Hay dos variantes con el mismo cy: "Press [ESC] to buy supplies" (golem) y "[ESC] Pick up Ammo" (cofres verdes de munición). Leon pidió corregir las dos. Script: `scripts/v18i.py`.
- Bolsas más grandes, en `scripts/objetos_v18i.py` (sólo el w3u):

| Unidad | Escala |
|---|---|
| 'nbg0' | 1,2 → 2,0 |
| 'nbg1' | 1,7 → 2,8 |
| 'nbg2' | 1,0 → 2,0 |

- Construcción: `scripts/hacer-v18i.sh`. Lanzadores: `entrar-v18i(-prueba).sh`. Registros en `lat\v18i-*.txt`.
- Hashes: v18i 05ddc19c…, v18i-prueba 9a677915….
- Estado: **Validated** (pJASS de las dos; reextracción de j y w3u; resto igual a v18h; `mpq verify`). Sin probar en el mapa.
- A mirar en la próxima prueba:
  - el aviso a la altura del texto antiguo, en sus dos variantes;
  - el tamaño de las bolsas;
  - "Elegir" y el pie de los cuadros (sin medir aún).
- Siguiente: fase 5 (estrellas de ronda), sobre v18i.

## Fase 5, v18j (15/11/2026): puntuación de fin de ronda

- Cuadro "Puntuación de la ronda N", centrado arriba (panel de 460 × 230 px, centro en (960, 175), sobre el héroe). Contiene:
  - 3 estrellas que aparecen una a una cada 0,3 s, con el tic de la tirada por cada estrella ganada;
  - "Bolsas recogidas x / y";
  - "Caídas del equipo n" (en verde si es 0, en rojo si no).
- Se ve 8 s y sólo lo ve su jugador. Se oculta con la tienda o los cuadros abiertos.
- Texturas en `scripts/puntos_v18j.py`:
  - 'DSP0' panel, con las etiquetas fijas;
  - 'DSP1' estrella dorada;
  - 'DSP2' estrella apagada.
- Texttags: 3 por cliente (título, valor de bolsas y valor de caídas).
- Notas de la ronda; las estrellas son la menor de las dos:
  - **Bolsas perdidas** (caducadas de las que cayeron en la ronda): 3 si perdidas × 40 ≤ 3 × caídas; 1 si perdidas × 40 ≥ 8 × caídas; 2 en otro caso.
  - **Caídas del equipo** durante la oleada (`s__RapidPair_fall`): 3 si caídas ≤ J/4; 2 si caídas ≤ max(1, 3J/4); 1 si más. Con J = 4 son los umbrales de Dark Moon; en solitario: 0 caídas → 3, 1 → 2, 2 o más → 1.
- Momento de puntuar: cuando no queda ninguna bolsa en el suelo, porque los cofres del jefe caen al final. Como mucho 36 s después del fin de la oleada.
- `Punt_Hist[ronda]` guarda las estrellas de cada ronda para la fase 9.
- Decisión mía, revisable por Leon: la escala de los umbrales por número de jugadores.
- Construcción: `scripts/v18j.py` y `scripts/hacer-v18j.sh`. Lanzadores: `entrar-v18j(-prueba).sh`.
- Prueba: la línea "puntuacion rN" va a `lat\v18j-bolsas.txt`.
- Hashes: v18j 8dca71b7…, v18j-prueba e18544f4….
- Estado: **Validated** (pJASS de las dos; reextracción de j, w3b, imp y los 3 blp; resto igual a v18i; `mpq verify`). Sin probar en el mapa.
- A mirar en la prueba:
  - que el cuadro salga al recoger los cofres del jefe, o a los 35 s si no se recogen;
  - las estrellas una a una con su tic;
  - los números del registro;
  - que no tape lo importante;
  - que se oculte con la tienda.
- Sin LAN: el cambio usa `GetLocalPlayer` sólo para el volumen.

### Prueba de v18j-prueba (15/11/2026, grabación 20261115_165747, 60 s, sólo ronda 1)

- Cuadro de puntuación: **Tested in map**, un jugador, una ronda.
  - Registro: 3 bolsas, 3 recogidas (una después del final), 0 perdidas → 3; 0 caídas con J 1 → 3; **3 estrellas**. Puntuó 7,0 s después del final, al recoger la última bolsa.
  - Vídeo: el cuadro se ve unos 8 s y las estrellas aparecen una a una. No tapa al héroe.
- Panel: borde de y 62 a 293 en pantalla (previsto 60-290).
- Estrellas: centro en y 149,5 (previsto 148).
- Texttags, unos 14 px más arriba de lo previsto:

| Texto | Arriba del todo, medido | Previsto (alineado con su etiqueta) |
|---|---|---|
| Título | y 68 (centro 76) | — |
| "3 / 3" | 188 | 202 |
| "0" | 233 | 248 |

  Corrección para la próxima versión: cy de los valores 205 → 219 y 250 → 265; título 90 → 104.
- Sin comprobar:
  - 1 o 2 estrellas;
  - caídas;
  - bolsas caducadas;
  - ocultarse con la tienda;
  - rondas con jefe.
- Sin LAN.

## v18k (15/11/2026): cuadro "Round Score" y fase 6 (libro de habilidades)

Leon: el cuadro de puntuación con el formato del de Dark Moon (vídeo 20261115_002900), con sus sonidos, al centro;
entra desde arriba y al irse baja hasta desaparecer. Fase 6: libro con las habilidades D.O.N y el del Tauren.

- Cuadro: textura 'DSP3' PuntCuadro (`scripts/puntos_v18k.py`), 600 × 470 px centrado en x 960, y 145-615. Título,
  tabla JUGADOR / BAJAS / CAÍDAS / BOLSAS (hasta 4 filas, una columna por texttag con renglón en blanco entre filas,
  paso 41,6 px = 2 × 1095 × 0,019) y 4 casillas: bolsas recogidas, perdidas, caídas del equipo (lápida) y nota con
  las estrellas 'DSP1'/'DSP2' de v18j.
- Entrada: dy = −640·a³ en 0,4 s; salida: +960·a² en 0,5 s tras `Punt_Sale` (= inicio de estrellas + 0,4 × E + 3 s).
- Recuento como Dark Moon: bolsas recogidas suben con el bucle `PuntSube` y cierran con `PuntSubeFin`; cada perdida
  `PuntPerdida`; cada caída `PuntTic`; cada estrella `PuntEstrella1/2`; fanfarria al abrir. Pasos ≤ 0,2 s (2,4/N o
  2/N), 0,4 s entre fases. Origen y formatos: `$M/sonidos-darkmoon/LEEME.md`.
- Corrección de texttags (≈ 14 px altos en v18j): centro de mayúsculas y cifras en cy con y = cy − 150 × tamaño;
  centrado horizontal x = cx − n × 271 × tamaño.
- Contadores por jugador: bajas (no en descanso), caídas, bolsas recogidas; se reinician con la ronda.
- Fase 6: 'Aspb' ALGk/ALFz/ALTr/ALNa/ALTa en (3,2), tecla V. El último puente (AGk5, AFz6, ATr6, ANa6) pasa de
  (3,2)/T a (0,0)/Q, porque (3,2) es cerrar dentro del libro. Tauren: ATa1 Onda de choque y ATa2 Pisotón de guerra,
  copias de 'ACev' con 0 % (sólo icono, no cortan la orden).
- Construcción: `scripts/hacer-v18k.sh` (puntos_v18k, sonido_v18k, objetos_v18f para w3b/imp, objetos_v18k, v18k.py).
  Los 7 wav van en `war3mapImported\` sin entrada en el imp, como SupTic.wav desde v18a.
- Hashes: v18k `03843c44…`, v18k-prueba `2f92d508…` (registros `lat\v18k-*.txt`). Copiados a WOE `Maps/Test`.
- Estado: **Validated** (pJASS de las dos, reextracción por hash de j, w3a, w3b, imp, blp y 7 wav, resto igual a
  v18j, `mpq verify`). Sin probar: posición real de los textos, volúmenes, animaciones de entrada y salida, libro en
  el juego (puentes D.O.N dentro, Kyuubi), Tauren, varias filas; sin LAN.

### Prueba de v18k (15/11/2026, grabación 20261115_172554, Tauren, ronda 1)

- Cuadro: **Tested in map**, un jugador. Centrado en x 665-1254, y 148-627; tabla alineada (7 / 0 / 3), bolsas
  0 → 3, estrellas una a una; salida hacia abajo visible (~0,3 s hasta la consola). El libro aparece en (3,2).
- Entrada: el juego se queda quieto ~0,15-0,25 s al acabar la ronda (37,27-37,40 s, sin cambios entre cuadros) y el
  cuadro aparece ya a ~60 px de su sitio: la caída pasó durante el parón.
- El nombre y la vida del héroe (texttag del mundo) se dibujan encima del cuadro.
- Sin comprobar desde el vídeo: sonidos y contenido del libro.

## v18l (15/11/2026): correcciones del cuadro

- Leon: al salir el cuadro suena el sonido nativo de misión completada (etiqueta "QuestCompleted", el de
  bj_questCompletedSound), no la fanfarria de Dark Moon. `PuntFanfarria.wav` sigue en el mapa sin usarse (wc3ctl no
  quita entradas).
- Entrada: 0,25 s oculto y caída de 0,5 s (termina a 0,75 s; el recuento sigue empezando a 1 s).
- Precarga de los 6 wav del recuento en BM.
- Barras del mundo (Barras_Visible) ocultas para quien ve el cuadro.
- Sólo cambia el j (`scripts/v18l.py`, `hacer-v18l.sh`; respeta los finales de línea mezclados del j).
- Hashes: v18l `2f2121c4…`, v18l-prueba `08d4f335…` (registros `lat\v18l-*.txt`). Copiados a WOE.
- Estado: **Validated**. Sin probar: entrada visible, sonido de misión y volúmenes, libro de D.O.N; sin LAN.
- Fases pendientes: 7 (tienda con apartados), 8 (Mutación Evo), 9 (mejoras del héroe modelo PVZ), 10 (al final).

### Prueba de v18l (15/11/2026, grabación 20261115_174219, Tauren, ronda 1)

- Entrada: **Tested in map**. El cuadro baja desde fuera de la pantalla en ~0,35 s visibles (45,9-46,3 s) y frena
  al llegar; durante un cuadro (~50 ms) se ven los textos y las estrellas sin el fondo, que aún está por encima.
- Recuento (bolsas 0 → 3, estrellas una a una) y barras del mundo ocultas con el cuadro: bien.
- Sin comprobar desde el vídeo: el sonido de misión completada.

## v18m (15/11/2026): recuento tras el sonido de misión y fase 7 (tienda con apartados)

Leon: el recuento empieza al terminar el sonido de misión; sonidos de estrella individuales; precargar los recursos;
y fase 7.
- `QuestCompleted.wav` (war3.mpq, 22050 Hz estéreo) dura 5,155 s: `Punt_Ini[1]` 1 → 5,45 s. El cuadro dura ~4,5 s más.
- Sonidos de estrella: ya eran individuales (`Punt_Sonar` crea uno por estrella y lo libera al terminar).
- Precarga añadida: PuntCuadro, PuntEstrella, PuntEstrellaVacia y QuestCompleted.wav (los 6 wav ya desde v18l).
- Textos y estrellas del cuadro sólo con el centro del fondo en pantalla (destello de ~50 ms de v18l).
- Fase 7: pantalla "Tienda" al abrir, con 3 cuadros del marco (Cua_Modo 0): Armas (azul, DC0H BTNDwarvenLongRifle),
  Mutación Evo (carmesí, centro, DC0I BTNUnholyFrenzy) y Habilidades (verde, DC0J BTNSpellBookBLS). Armas y
  Habilidades en gris hasta acabar Mutación Evo; lo hecho queda gris; clic en gris = sonido de error. Cada grupo
  vuelve al inicio al terminar. Esc y Salir vuelven al inicio; desde el inicio, cierran.
- Aviso de elecciones pendientes: en la descripción de cada cuadro; el aviso fuera de la tienda pasa a la fase 9.
- Construcción: `scripts/hacer-v18m.sh` (v18m.py, objetos_v18m.py); cambian j y w3b.
- Hashes: v18m `499341a1…`, v18m-prueba `0200edfa…` (registros `lat\v18m-*.txt`). Copiados a WOE.
- Estado: **Validated**. Sin probar: pantalla de inicio en el juego (posiciones, colores, textos), Esc/Salir,
  recuento tras el sonido; sin LAN.

## v18n (15/11/2026): recuento 2 s antes del final del sonido de misión

- Leon: "a eso restale 2 segundos para que suene algo antes". `Punt_Ini[1]` 5,45 → 3,45 s (QuestCompleted.wav dura
  5,155 s y empieza a 0,25 s; el recuento arranca ~1,95 s antes de que termine). Lo demás se encadena igual.
- Construcción: `scripts/hacer-v18n.sh` (v18n.py); sólo cambia el j (bytes-diff: (attributes), (listfile), war3map.j).
- Hashes: v18n `df69177c…`, v18n-prueba `d000aac4…` (registros `lat\v18n-*.txt`). Copiados a WOE.
- Estado: **Validated**. Sin probar en el juego: este arranque y todo lo de v18m (pantalla de inicio de la tienda).

### Prueba de v18n (Leon, grabación 20261115_180003)

- Sonido de misión localizado por correlación con QuestCompleted.wav a 41,64 s y ~262,0 s. En las dos rondas el cuadro
  baja con el sonido y la primera bolsa sube ~3,1-3,2 s después de que empiece; el sonido acaba ~2 s más tarde.
  **Tested in map** (un jugador): el recuento empieza 2 s antes del final del sonido.
- Visto de paso: el texto del mundo "[ESC] Pick up …" se dibuja encima del cuadro (44,75-45,0 s); las barras sí se
  ocultan.
- Sin comprobar en la grabación: la pantalla de inicio de la tienda (v18m).

## v18o (15/11/2026): sonidos del recuento calentados y fase 8, votación de Mutación Evo

- **Sonidos**: Leon vio que no suenan desde el principio. En la grabación 180003, en la ronda 1 faltan PuntTic y
  PuntSubeFin, y en la ronda 2 suenan. `Preload` del wav no basta. Ahora los 6 wav del recuento y QuestCompleted se
  reproducen a volumen 0 al empezar (`Son_Cero`, el método del mapa desde v17d). Anotado en la skill
  (`build-warcraft3-vjass-127b/references/preload-127b.md`).
- **Fase 8**:
  - **Votación**: el voto es la elección de cada jugador en su paso. Con 2+ jugadores cada cuadro muestra sus votos,
    que se refrescan para quien está en el mismo paso.
  - **Recuento** (`Cua_Recuento`, código común) al llegar el descanso a 0: gana el más votado; con empate, uno al azar
    entre los empatados; sin votos, uno al azar entre todos. Los ganadores se acumulan en `Cua_Activa` y todavía no
    tienen efecto.
  - **Muestra de 8 s**: se cierran las tiendas y todos ven los 3 ganadores (jefe, élites, comunes) con sus votos y
    «Oleada en N». Después sale el aviso «Mutación Evo (aún sin efecto): …» y empieza la oleada, 8 s más tarde que
    antes. Durante la muestra no se puede abrir la tienda.
  - **Peso**: entre los comunes, ×3 para Caparazón, Lluvia de flechas y Red de pesca si el tipo nuevo de la ronda
    siguiente es tortuga, de distancia o el trampero.
  - El resumen al empezar la oleada sólo lista las mejoras del héroe.
- **Registros**: la variante de prueba anota en `lat\v18o-cuadros.txt` una línea por paso del recuento (votos de cada
  candidato, ganador, modo y veces acumuladas). La variante LAN es igual que la de prueba, pero escribe por jugador en
  `lat\j<id>-v18o-*.txt`; con `lan-v18o.sh` (ydhost y dos clientes) las dos deben coincidir.
- **Construcción**: `scripts/hacer-v18o.sh` (v18o.py, que también hace el map.cfg de ydhost); sólo cambia el j.
- **Hashes**: v18o `db0cf5e0…`, v18o-prueba `f29d6447…`, v18o-lan `4de372f5…`. Normal y prueba copiadas a WOE.
- **Estado**: **Validated**. Sin probar: nada de esto en el juego. Prueba LAN de dos clientes pendiente; es
  obligatoria para la votación.
- **Siguiente**: los efectos reales de las 18 mutaciones.

## v18p (15/11/2026): fin de oleada en tres tiempos

- Leon: el cuadro de resultados no salía de golpe al acabar la oleada porque esperaba a que no quedaran bolsas.
- **Bolsas**: si quedan en el suelo, hay 8 s para recogerlas. El HUD pone «Recoge las bolsas» con el número en rojo
  parpadeando y suena un tic de reloj nativo en cada segundo (UISounds «ChatroomTimerTick», BattleNetTick.wav, calentado
  a volumen 0 y en la precarga). Lo que quede después se borra y cuenta como perdido. Sin bolsas, el cuadro sale enseguida.
- **Resultados**: el HUD pone «Resultados» mientras se ve el cuadro.
- **Tiempo de compra**: al cerrarse el cuadro (`Ronda_DescansoEmpezar`, desde `Punt_Tick`) empiezan los 45 s y baja el
  golem. Antes empezaban al acabar la oleada.
- El tic sólo suena en la cuenta de las bolsas. El parpadeo de los últimos 10 s del tiempo de compra sigue sin tic.
- **Construcción**: `scripts/hacer-v18p.sh` (v18p.py, sobre v18o; la variante LAN sale de v18o-lan).
- **Hashes**: v18p `81ecf159…`, v18p-prueba `610d054c…`, v18p-lan `ed214963…`. Normal y prueba copiadas a WOE.
- **Estado**: **Validated**. Sin probar en el juego, igual que v18o (fase 8 y LAN).

### Prueba de v18p-prueba (15/11/2026, grabación 20261115_182516)

- **Bien**: las bolsas caducaron a los 8 s en la ronda 2 (registro de bolsas 214,04 → 221,96) y después salió el cuadro.
  La votación y el recuento también funcionaron (r1: Escolta, Ascenso y Lluvia de flechas).
- **Tic casi inaudible**: había picos cada segundo en la cuenta de las bolsas, pero con correlación 0,1-0,42 frente al
  wav. En UISounds, la etiqueta tiene el mismo volumen (80) que QuestCompleted, que sí se oye; el fallo está en el
  sonido global que se reutilizaba.
- **La muestra de la Mutación Evo no se vio**: tras el descanso de la ronda 1, durante 8 s (vídeo 101-108) se veía el
  mundo con «Tiempo de compra 0». La cámara que sigue al héroe (ConversationUI) sólo se detiene con `Shop_Open`, y la
  muestra sólo abría `Cua_Open`.
- **Tiempo de compra**: sin tic en los últimos 10 s, porque no estaba hecho.

## v18q (15/11/2026): correcciones de la prueba de v18p

- **Tic**: se crea un sonido nuevo en cada tic (etiqueta «ChatroomTimerTick», volumen 127, `KillSoundWhenDone`), igual
  que QuestCompleted. Al empezar la partida se calienta a volumen 0 por etiqueta y con `Son_Cero` de la ruta.
- **Tiempo de compra**: tic en cada uno de los 10 últimos segundos.
- **Muestra de la Mutación Evo**:
  - abre la tienda (`Shop_Open`) igual que ESC junto al golem, así que la cámara se queda en la escena y el HUD del
    mundo se oculta;
  - Esc no hace nada mientras dura;
  - `Ronda_Fase 3` cuenta `Ronda_Resta` de 8 a 1 con un reloj de 1 s y un tic por segundo;
  - «Oleada en N» parpadea en rojo;
  - al llegar a 0 cierra la tienda y lanza la oleada.
- **Reloj de la escena de cuadros**: `Cua_Reloj` parpadea ahora con ≤ 10 s, como el de la tienda de armas.
- **Cuadro de resultados**: el HUD muestra los segundos que le quedan, sin parpadeo ni tic.
- **Construcción**: `scripts/hacer-v18q.sh` (v18q.py sobre v18p, v18p-prueba y v18p-lan).
- **Hashes**: v18q `afb173df…`, v18q-prueba `af15f153…`, v18q-lan `38523639…`. Normal y prueba copiadas a WOE (cmp).
- **Estado**: **Validated** (pJASS, j reextraído, `mpq verify`). Sin probar en el juego. LAN de dos clientes pendiente.

## v18r (15/11/2026): muestra de la Mutación Evo como cuadro de interfaz central

- Leon: los ganadores de la votación se dibujan con piezas de interfaz al centro, como el cuadro de puntuación y las
  bolsas contadas. La cámara se queda en el héroe (en v18q la muestra abría la tienda y llevaba la cámara a la escena).
- **Cuadro** (`Mut_HudCrear`, `Mut_Hud`, `Mut_Tick`):
  - título «Mutación Evo»;
  - 3 cuadros carmesí ('DS01', el fondo de los cuadros de la tienda) con el icono y el nombre de cada ganador (jefe,
    élite y comunes, de izquierda a derecha);
  - piezas 'uidb' como las del cuadro de puntuación, delante de la cámara de cada jugador;
  - entra desde arriba en 0,5 s y sale hacia abajo en los últimos 0,5 s.
- **Contador**: el HUD de la ronda pone «Oleada en» con 8..1, parpadeo rojo y tic cada segundo.
- La muestra ya no abre la tienda ni la escena de cuadros. Son 4 texttags locales más por cliente (título y nombres).
- **Construcción**: `scripts/hacer-v18r.sh` (v18r.py sobre v18q).
- **Hashes**: v18r `7e51f435…`, v18r-prueba `9784a2cf…`, v18r-lan `09e4dea9…`. Normal y prueba copiadas a WOE (cmp).
- **Estado**: **Validated**. Sin probar en el juego: posición y tamaño del cuadro, legibilidad de los nombres (el
  centrado es estimado) y el tic. LAN pendiente.

### Prueba de v18r-prueba (15/11/2026, grabación 20261115_212510)

Desfase: vídeo = registro de bolsas + 1,26 s (QuestCompleted de r1 a 53,60).

- **Cuadro de la Mutación Evo**: se ve centrado, con título, iconos y nombres legibles, y la cámara se queda en el
  héroe. Fallo: la barra del mundo del héroe («WorldEdit 100 %») se dibujaba encima del cuadro del medio. Coloso y
  Caparazón comparten icono ('DC05' en `Cua_Tex`, así desde v18m).
- **Tic**: en los 10 últimos segundos de compra se oye claro (correlación 0,81-0,97, vídeo 99-108). En las bolsas
  de r2 y en la muestra se oye más flojo (0,3-0,48), con el ruido del combate o de la oleada encima.
- **Estrellas**: sí suenan en r1 (PuntEstrella1 0,99 en 59,16) y en r2 (0,96).
- **Recuento de bolsas** (Leon: «los sonidos de las bolsas … aún no se precargan»): ni el bucle ni el final se ven
  en el audio de ninguna ronda (energía igual al ambiente, -23 a -27 dB). No es la precarga: los .wav tienen una
  media de -23 y -25 dB (estrellas -10) y sonaban a volumen 38 y 51 (estrellas 102). Quedaban unos 20 dB por debajo.

## v18s (15/11/2026): sonidos de las bolsas más fuertes y barras ocultas con la Mutación Evo

- PuntSube, PuntSubeFin y PuntPerdida suben +12, +12 y +16 dB con limitador (`sonidos-v18s/`; medias -12,4, -14,5
  y -19,5 dB; mismo formato y duración). El bucle suena a 90 y el final a 127.
- `Barras_Visible`: las barras del mundo se ocultan mientras se ve el cuadro de la Mutación Evo (`Mut_T >= 0`).
- **Construcción**: `scripts/hacer-v18s.sh` (v18s.py y los 3 .wav; comprueba que sólo cambian esos 4 miembros).
- **Hashes**: v18s `980e0342…`, v18s-prueba `63dc798b…`, v18s-lan `367a6b86…`. Normal y prueba copiadas a WOE (cmp).
- **Estado**: **Validated**. Sin probar en el juego: volumen de las bolsas y barras ocultas. LAN pendiente.

## v18t-prueba (15/11/2026): comando "-punt" para probar los sonidos del cuadro

- Leon pidió sacar el cuadro de resultados con resultados altos para probar el sonido directamente.
- **Comando**:
  - `-punt` muestra el cuadro con 30 bolsas recogidas, 6 perdidas, 3 caídas y 3 estrellas, con todos sus sonidos;
  - `-punt N` cambia las recogidas (1..60).
- **Condiciones**: sólo funciona con `Ronda_Fase` 0, sin otro cuadro en pantalla y fuera de la muestra. Al cerrarse
  no empieza el descanso. Pisa los contadores de la ronda en curso.
- Sólo en la variante de prueba, registrado junto a `-pres`; el mapa normal sigue siendo v18s.
- **Hash**: v18t-prueba `27b9734d…`, copiada a WOE (cmp). **Validated**.

## v18u-prueba (15/11/2026): sin oleadas ni música para probar el cuadro

- Leon pidió desactivar la oleada para probar los resultados sin unidades ni música.
- `DevWave_Arrancar` ya no llama a `Ronda_Lanzar`: no salen unidades, no suena el tema de la oleada y no corre la
  tirada de élites. Además hace `StopMusic` y `ClearMapMusic`, y avisa de que se use `-punt [N]` (de v18t).
- **Hash**: v18u-prueba `191c5a9d…`, copiada a WOE (cmp). **Validated**. Sólo es variante de prueba.

## Prueba de v18u-prueba (15/11/2026, grabación 20261115_214358)

- Dos `-punt 20` seguidos (registro `lat/v18u-bolsas.txt`: 7,492 y 23,891 s). Correlación del audio con cada `.wav`:
  - primer cuadro: QuestCompleted 0,46, PuntSube 0,91, Perdida 0,49/0,69, tic 0,8, 1.ª estrella 0,99;
    **PuntSubeFin ≤ 0,10 y 2.ª/3.ª estrella 0,19-0,36** (no sonaron);
  - segundo cuadro: PuntSubeFin 0,73 y las tres estrellas 0,59-0,69.
- Confirma lo que dijo Leon: algunos sonidos callan la primera vez y suenan desde la siguiente, aunque Son_Cero los
  calienta desde v18o.

## v18v (15/11/2026): sonidos del cuadro calentados ya en partida

- Hipótesis: Son_Init corre en la carga (Precarga_Todo) y un `StartSound` antes de empezar la partida no llega a
  cargar el sonido.
- `Son_Calentar` corre 1 s y 3 s después de empezar: crea cada sonido del cuadro con los mismos parámetros que
  `Punt_Sonar` (duración, canal 0) a volumen 0; perdida, tic y estrellas, dos a la vez. También QuestCompleted y el
  tic por etiqueta.
- **Variantes**: v18v (sobre v18s) y v18v-prueba (sobre v18u-prueba: sin oleadas, `-punt [N]`, registros `lat\v18v-*`).
  Sin lan: el cambio no toca lo local.
- **Construcción**: `scripts/hacer-v18v.sh`; lanzadores `entrar-v18v.sh` y `entrar-v18v-prueba.sh`.
- **Hashes**: v18v `4a454222…`, v18v-prueba `71b46307…`; copiadas a WOE (cmp). **Validated**.
- **Prueba de Leon** (v18v-prueba, grabación 20261115_214939, un `-punt 20` a 9,492 s del registro; vídeo ≈ registro
  + 0,3 s): en el **primer** cuadro sonó todo a su hora: QuestCompleted 10,05 (0,42), PuntSube 13,16 (0,61),
  PuntSubeFin 15,57 (0,74), perdidas 16,17-16,97 (0,45-0,65), tic 17,57/17,97 (0,6/0,51) y las tres estrellas
  18,58/18,98/19,38 (0,55-0,68). **Tested in map** (un jugador). La partida normal v18v no se ha jugado.

## v18w (15/11/2026): QuestCompleted y el tic se oían al empezar

- Leon los oye al empezar la partida. Eran los calentados por etiqueta de v18v (`CreateSoundFromLabel` con
  `SetSoundVolume 0` antes de `StartSound`): con etiqueta (sonidos nativos de UISounds) el 0 no se respeta; los `.wav`
  por ruta del cuadro sí.
- Ahora se calientan por ruta con `Son_Cero` (`Sound\Interface\QuestCompleted.wav` y `BattleNetTick.wav`).
- **Construcción**: `scripts/hacer-v18w.sh` (normal sobre v18v, prueba sobre v18v-prueba).
- **Hashes**: v18w `4b9324c1…`, v18w-prueba `97b35bdf…`; copiadas a WOE (cmp). **Validated**. Sin probar: silencio al
  empezar y que el primer cuadro siga sonando entero.

## v18x (15/11/2026): fase 8, efectos de la Mutación Evo

- Las 18 mutaciones tienen efecto y se acumulan (`Cua_Activa[id]` = veces ganada; n abajo).
  - **Jefe**: Coloso +30 % de vida por n; Corona 2n pasivas de la súper élite y daño de su tabla; Escolta 2n élites
    del último tipo (grupo 980); Furia bajo el 50 % de vida: +50n % de ataque y +30n % de velocidad.
  - **Élite**: Ascenso n élites más (grupos 960+k); Élite feroz n pasivas al azar; Último aliento explota al morir
    (radio 260, (30 + 15·ronda)·n a los héroes). Promoción: 10n % de comunes con vida ×3 y daño +50 %.
  - **Comunes**: Piel gruesa +25n % de vida; Marea rápida +20n % de velocidad; Veteranos (k ≤ 2) +60n % de vida y
    +50n % de daño; Horda +20n % de unidades; Pocos pero fuertes, menos unidades y +100n % de vida y daño; Caparazón
    (tortugas) +3n de armadura y espinas; Lluvia de flechas (a distancia) +25n % de ataque; Red de pesca (nmsn) +30n %
    de ataque y movimiento; Asalto inicial, salen más rápido y los de los 10 primeros s van +30n % más deprisa;
    Regeneración 1n % de la vida por segundo.
- Cambios frente al diseño, por falta de nativas 1.27b sin tocar datos de objeto: Lluvia de flechas da velocidad de
  ataque en lugar de +150 de alcance; Red de pesca, velocidad en lugar de redes más seguidas; Promoción refuerza a la
  común en su sitio en vez de cambiarla por élite.
- **Prueba**: oleadas otra vez (v18u-prueba las quitaba), `-mut N` (0-17) suma una mutación y al acabar cada oleada se
  anotan activas y unidades afectadas (`lat\v18x-bolsas.txt`).
- **Hashes**: v18x `a19e6175…`, v18x-prueba `80348a93…`; en WOE (cmp). **Validated**; sin jugar.

## v18y (15/11/2026): fase 9, mejoras del héroe (modelo PVZ)

- Dos elecciones por descanso (pasos 3 y 4 de la tienda): 4 cartas y una quinta, **Refrescar**. Se sortean al
  cerrarse el cuadro de resultados, con las estrellas de esa ronda.
- **Calidad** con los colores de tier (T1 amarillo … T5 morado) en el fondo y el nombre: tirada 1-100 + suerte·2 (tope
  30) + 5 por estrella sobre 1; cortes 45/72/88/97. **Garantía**: tras 3 descansos sin carta T4 o mejor, la primera lo es.
- **Suerte**: + estrellas de la ronda, +1 cada 5 bolsas, −1 al refrescar; se ve en la cabecera. **Refrescos**: 2 al
  empezar y +1 cada 2 rondas.
- **Maldita**: Pacto maldito sale un 8 % en lugar de la 4.ª carta (+40 % de daño, −25 % de vida máxima), fondo morado.
- **Valores** (T1..T5): Filo +6/9/13/18/25 % de daño de armas; Vitalidad +80/120/170/230/300 de vida; Zancada
  +10/15/20/26/34 de movimiento; Golpe de suerte +4/6/8/11/15 % de crítico ×2 (balas, explosiones y cuchillo); Botín
  +8/12/17/23/30 % de oro de bolsas; Evasión +5/5/10/10/15 % (tope 50).
- Pisotón y Onda de choque (Cairne) quedan fuera del sorteo hasta tener efecto.
- **Prueba**: cada elección se anota. **Hashes**: v18y `679b61e1…`, v18y-prueba `bbb0f8de…`; en WOE. **Validated**.
- Sin comprobar: que Zancada se note (el héroe sigue a su controlador; la velocidad que se sube es la del héroe).

## v18z (15/11/2026): fase 10, curaciones al morir la élite

- Cada élite que muere suelta 4 runas: 2 de vida (+25 % de la vida máxima) y 2 de maná (+25 % del maná del
  controlador). Se cogen al pasar a 160; con la vida o el maná llenos no se gastan. Duran 30 s (parpadean los 5
  últimos); tope 40. Son runas nativas ('rhe2', 'rma2') que coge el código; sin datos de objeto nuevos.
- **Variantes**: normal (sobre v18y), prueba (sobre v18y-prueba, `-mut`, `-punt`, registros `lat\v18z-*`) y **lan**
  (sobre v18s-lan con v18v..v18y y v18z en modo lan): por jugador `lat\j<id>-v18z-bolsas.txt` con runas, cada
  elección de carta y, al acabar cada oleada, mutaciones activas y el estado de cartas de cada jugador (suerte,
  refrescos, Filo, crítico, botín, evasión, vida máxima, velocidad) para comparar los dos clientes.
- **Construcción**: `scripts/hacer-v18z.sh`; lanzadores `entrar-v18z.sh`, `entrar-v18z-prueba.sh`, `lan-v18z.sh`.
- **Hashes**: v18z `186d1e2b…`, v18z-prueba `894a3db4…`, v18z-lan `1d14b355…`; normal y prueba en WOE (cmp).
  **Validated**; sin jugar ni probar en LAN.
- **Pendiente de la fase 10, con decisión de Leon**: torres con oro, dificultades, vueltas tras la ronda 10 y efectos
  reales de las habilidades del libro y de Pisotón/Onda de choque.

### 15/11/2026, Leon: habilidades del Tauren únicas, como las de D.O.N

- Pidió: "deberian ser mas poderosas, que sean unicas, como las de DON, mas orientado que ayuden contra las oleadas".
  No sirven las nativas tal cual (Onda de choque, Pisotón, Lanzar roca, Rugido, Estampida, Pulverizar): se rehacen por
  código, con el motor Missile y efectos propios, y con el mismo reparto que los de D.O.N (5-6 activas: línea, objetivo,
  zona, refuerzo/transformación, definitiva, y una pasiva).
- Propuesta en espera del sí de Leon (ver la respuesta del chat de este día): Grieta sísmica, Pisotón ancestral, Tótem
  del trueno, Embestida, Espíritu ancestral, Estampida de los ancestros y la pasiva Pulverizar.
- Leon pregunta para quién es: hay dos personajes, Tauren ('h005') y Cairne ('h006'); hoy los dos llevan el mismo libro
  'ALTa' (Don_Botones). Propuesta: separar libros. **Cairne** (jefe, tierra y espíritus): Grieta sísmica, Pisotón
  ancestral, Tótem del trueno, Espíritu ancestral, Estampida de los ancestros y pasiva Furia ancestral. **Tauren**
  (guerrero bruto, cuerpo a cuerpo): Embestida, Tótem bumerán, Torbellino, Rugido desafiante, Terremoto y pasiva
  Pulverizar. En espera del sí de Leon.
- Leon (15/11/2026): más habilidades de lanzar, y "como la unidad de jugador tiene poca vida", las que acercan al
  enemigo no las hace el héroe: genera una **copia espiritual** (dummy del mismo tipo, translúcida, sin control) que
  hace la habilidad mientras el original se queda a salvo. Para el Tauren y Cairne. Propuesta revisada:
  - **Cairne**: Grieta sísmica (línea), Lanza ancestral (lanza que atraviesa y se parte en 3), Tótem del trueno
    (lanzado al punto, atrae y lanza rayos), Pisotón ancestral (la copia salta al punto y pisa en 3 anillos), Carga del
    espíritu (la copia carga hasta el punto), Estampida de los ancestros (definitiva); pasiva Furia ancestral.
  - **Tauren**: Tótem bumerán, Lanzar roca (en arco, rebota 3 veces), Embestida espiritual (copia), Torbellino
    espiritual (copia), Rugido desafiante (la copia es señuelo: atrae y aguanta 5 s, luego explota), Terremoto
    (definitiva, alrededor del héroe para defenderse); pasiva Pulverizar.
  - Cartas de mejora posibles: copias que duran más, una segunda copia, señuelo con más vida.
- Investigación (15/11/2026, Leon pidió foros rusos, ingleses o chinos y DotA 1): Hive Workshop rechaza la lectura
  automática (403 y verificación anti-bots; no se intenta saltar). En xgm.guru y en foros chinos no salió ningún spell
  pack de tauren. Referencias útiles: Tauren Chieftain de DotA (Echo Stomp, Ancestral Spirit, Natural Order, Earth
  Splitter), Earthshaker (Fissure, Enchant Totem, Aftershock, Echo Slam), Centaur (Hoof Stomp, Double Edge, Insult,
  Stampede), Spirit Breaker (carga) y en Hive "Earth Splitter v1.05", "Raigor ... spells", "Tauren Spell Ideas"
  (Seismic Charge, Outrage). Ancestral Spirit es la idea de la copia de Leon.
- Propuesta revisada con eso: **Cairne**: Grieta ancestral (estilo Earth Splitter: se parte a los 2 s, % de vida
  máxima, junta y ralentiza), Espíritu ancestral (copia que sale, daña al pasar, pisa al volver a pulsar y regresa
  dándole daño por enemigo tocado), Lanza ancestral, Tótem del trueno, Estampida de los ancestros; pasiva Réplica
  (estilo Aftershock: cada habilidad aturde alrededor de Cairne y de la copia). **Tauren**: Fisura (muro que bloquea;
  comprobar si WaveAI respeta los bloqueadores), Tótem bumerán, Lanzar roca, Embestida espiritual (copia, estilo carga
  de Spirit Breaker), Rugido desafiante (copia señuelo, estilo Insult/Berserker's Call), Eco devastador (definitiva
  estilo Echo Slam: más daño cuantos más enemigos); pasiva Tótem encantado (cada 4.º impacto ×3 con onda).
- Segunda búsqueda (18/11/2026, Leon: mapas o juegos con el tauren como héroe o jefe poderoso). Hallazgos:
  - **Echo of Baine** (WoW, End Time): Throw Totem, que deja el tótem en el suelo y se puede devolver al jefe; Pulverize,
    que salta a un punto lejano y golpea la zona.
  - **E.T.C.** (Heroes of the Storm, tauren): Powerslide (deslizamiento que aturde), Face Melt (empuje instantáneo
    alrededor), Mosh Pit (aturdimiento canalizado alrededor), Stage Dive (salto a cualquier punto que ralentiza).
  - **Cairne en Warcraft Rumble**: su ataque aturde; Aftershock deja aturdidos 5 s a los que salen del aturdimiento;
    en heroico, antes de reencarnarse invoca 3 fantasmas suyos que barren cada calle.
  - Jefe tauren de juegos chinos para móvil: carga con aviso rojo e invoca crías.
  - En Hive sólo salieron mapas de defensa sin un Cairne jefe concreto (Theramore Hero Defense, Mercenary Call, Xnd Hero
    Siege); Hive no deja leerlos automáticamente.
- Ideas que se añaden a la propuesta: **Cairne**, pasiva Espíritus guardianes (al reencarnar —ya usamos AOre— salen 3
  copias que barren en 3 direcciones) y Réplica con aturdimiento prolongado (Rumble). **Tauren**: Tótem arrojado
  (Baine: se clava y aturde, ralentiza alrededor; al volver a pulsar vuelve dañando en línea), Salto devastador (copia,
  Stage Dive/Pulverize a un punto lejano), Bramido (empuje instantáneo alrededor del original para escapar, Face Melt)
  y Llamada de la manada (2-3 kodos jóvenes que luchan unos segundos).

### 18/11/2026: Impossible Bosses (mapa de Psyris, sugerido por Leon)

- Jefes del mapa de WC3: Belthazar, Ai, Gaven, Zephire, Gaia, Remington, Varenel, Selia, Ancient Spirit, Pandemonium.
  Corrección 18/11: la captura de Leon del mapa muestra a **Gaven the Brute** con retrato de tauren y daño
  850 (+600), igual que la wiki: Gaven es el jefe tauren. Fandom, NamuWiki, Hive, tl.net y Steam bloquean la
  lectura automática; sólo hubo fragmentos de búsqueda.
- Ideas útiles: **Gaven el Bruto** (aura que protege a quien está pegado a él de su Earthshock; golpes repetidos al
  frente; cono de piedras de pie quieto; orbes de poder que revienta al pisarlos y le dan invulnerabilidad breve;
  más daño cuanto menos vida), **Belthazar** (Molten Fuse: marca con halo que explota a los 3 s), **Ancient Spirit**
  (Ancient Blast: rayo frontal cuyo retroceso lo empuja hacia atrás; raíces gigantes en las esquinas; espíritu que se
  fusiona con él), **Remington** (9 orbes que salen en todas direcciones; revive dos veces), **Varenel** (proyectil
  que rebota entre estatuas y daña alrededor en cada rebote) y la regla común: energía que se llena sola y lanza la
  definitiva con 3 s de aviso.
- Propuestas derivadas (pendientes del sí de Leon):
  - **Tauren, Tótem rebotador**: el tótem arrojado rebota entre enemigos/élites (Varenel) y aturde en cada rebote.
  - **Tauren, Golpe de onda** (Ancient Blast): onda frontal larga que empuja al Tauren hacia atrás; ataque y huida.
  - **Cairne, Marca ancestral** (Molten Fuse): marca a un élite; a los 3 s explota y daña a los de alrededor.
  - **Cairne, Orbes de los ancestros** (Remington): 8 orbes salen en círculo desde él y atraviesan la oleada.
  - Pasiva compartida opcional **Furia del jefe** (Gaven): más daño cuanto menos vida le queda al héroe.
- Ideas sacadas de Gaven para el Tauren (pendientes del sí de Leon): **Golpes al frente** (3 pisotones seguidos en
  cono), **Lluvia de piedras** (de pie quieto, cono de piedras), **Orbes de fuerza** (deja orbes en el suelo; al
  pisarlos el Tauren gana fuerza e invulnerabilidad breve), **Furia del bruto** (más daño cuanto menos vida).

### 18/11/2026: Gaven medido en la copia local de Impossible Bosses BetaV3V

Fuente: `FrozenThone/games/WarcraftIII-1.27b/Maps/devdev/Impossible Bosses BetaV3V.w3x` (SHA-256 `f43fe956…b307`),
copiada y extraída en el scratch de la sesión; original intacto. Mapa de Psyris; script ofuscado. Estado: **Scanned**
(lectura estática del j y de las SLK), sin juego. Es la versión beta de 2010, no la v1.11.6 de la wiki.

- Unidad `h002` "Gaven the Brute": modelo nativo `units\orc\Tauren\Tauren.mdl`, escala 2, 28000 de vida, golpe
  850 (849+1d1), alcance 150, velocidad 150, punto de daño 0,467 s.
- Animaciones de Tauren.mdx (war3.mpq): Stand 2,667 s; Walk 1,0 s (240); Attack 1,333 s; **Attack Slam 1,267 s**;
  Death 3,134 s. SpiritWalker.mdx (War3x.mpq): Spell Morph 1,267 s, Walk 180.
- Habilidades (cada una anuncia su nombre con un texttag sobre él):
  - **SLAM V**: se para, 0,4 s, `attack slam`, 0,6 s después onda: ondulación del terreno a 200 delante y anillo que
    crece 50 cada 0,03 s hasta 2000 (≈1670/s); recoge a los alcanzados y revienta los orbes.
  - **PUMMEL**: si hay jugadores a 350 delante, cada 0,2 s `attack slam` a 350 % con polvo; al 6.º golpe uno lento
    (espera 0,53 s) con explosión de tierra grande.
  - **EARTHSHOCK**: a un jugador lejano (hasta 2000) que no esté pegado a él: pisotón de guerra en sus pies,
    900 + 150 × dificultad. El aura Influencia protege a los cercanos.
  - **PULL**: aparece un **caminante espiritual tauren** (SpiritWalker) 350 delante, dura 2,5 s, y arrastra a un
    jugador hacia él a 15 cada 0,03 s (500/s) hasta 150, sin colisión.
  - **CHARGE**: elige a un jugador a 500-1800, se encara 0,6 s y carga 2000 a ≈714/s (`Walk` a 200 %) con 450 de daño
    en 150 por paso; para si llega a 180 del blanco, se sale de lo transitable o recorrió 2000.
  - **QUAKE**: marca con ManaFlareBase el suelo de jugadores al azar durante 1-2 s.
  - **POWERUP / orbes**: siembra 1-3 orbes a 300-900 que duran 3-6,5 s; sube su daño si nadie está pegado a él;
    al pisar un orbe gana 3 s de invulnerabilidad.
  - **BARRAGE** (definitiva): se queda quieto con `attack slam` a 50 %; cada 0,05 s dispara un proyectil de catapulta
    a un punto en espiral (ángulo +22°, radio de 1000 bajando 100 cada 16 disparos) durante 8 s.
  - **PROTECTION / Intimidate**: inmune 5 s.
- Para nuestro Tauren (pendiente del sí de Leon): **Garra espiritual** (de PULL: aparece un caminante espiritual que
  arrastra a un élite o grupo hacia él), **Embestida** (de CHARGE, con la copia), **Onda de tierra** (de SLAM V),
  **Aporreo** (de PUMMEL: 5 golpes rápidos y uno fuerte), **Bombardeo** (de BARRAGE: espiral de rocas como
  definitiva). Tiempos de animación de la tabla de arriba; código propio, sólo se toman ideas y medidas.

### 18/11/2026: lista unida de Tauren y Cairne (propuesta, sin cerrar)

Recordatorio pedido por Leon; junta todas las rondas de ideas. Libros separados (hoy los dos usan 'ALTa').
- **Tauren** ('h005', guerrero bruto, base Gaven): Tótem arrojado, Lanzar roca, Garra espiritual, Embestida
  espiritual (copia), Rugido desafiante (copia señuelo), definitiva Bombardeo; pasiva Tótem encantado.
  Reserva: Bramido, Aporreo, Onda de tierra, Golpe de onda, Salto devastador (copia), Llamada de la manada, Fisura,
  Orbes de fuerza, Furia del bruto.
- **Cairne** ('h006', jefe ancestral): Grieta ancestral, Lanza ancestral, Espíritu ancestral (copia), Tótem del
  trueno, Marca ancestral, definitiva Estampida de los ancestros; pasivas Réplica y Espíritus guardianes.
  Reserva: Orbes de los ancestros, Pisotón ancestral (copia), Carga del espíritu (copia).
- Sin decidir: coste (D.O.N: sin enfriamiento, 1 de maná) y cifras de daño.
- Ajuste 18/11 para el modo de disparos y oleadas (Leon: retirar lo que no encaja o adaptarlo). Regla: el héroe no se
  queda quieto, pocas de un solo objetivo, pasivas ligadas a los disparos, modelos ligeros.
  - Tauren, **Bombardeo** → la **copia** se planta en el punto 8 s y lanza las rocas en espiral; el héroe sigue libre.
  - Tauren, **Garra espiritual** → el espíritu aparece lejos (≈600 delante) y arrastra hacia él, nunca hacia el héroe.
  - Tauren, pasiva **Tótem encantado** → **Disparo encantado**: cada 4.º disparo hace ×3 y suelta una onda en el impacto.
  - Cairne, **Marca ancestral** → con contagio: al explotar marca a 3 enemigos cercanos, que también explotan (una vez).
  - Cairne, pasiva **Espíritus guardianes** → además de al reaparecer, una vez por ronda al bajar del 25 % de vida.

### 18/11/2026, Leon: todas las habilidades las lanza una copia

- Decisión de Leon: al lanzar, se crea una **copia dummy invulnerable** del personaje y es ella la que hace la
  habilidad. Vale para Tauren, Cairne y los héroes de D.O.N. El héroe sigue moviéndose y disparando.
- Diseño propuesto (pendiente de sí):
  - Biblioteca común `Copia`: `Copia_Crear(p, x, y, ang, anim, dur)` crea la copia en la posición del héroe, con
    Aloc + invulnerable, sin colisión, sin comida ni habilidades, translúcida; `Copia_Fin` la desvanece y quita.
    Un tipo de copia por modelo (Tauren, Cairne, Goku y formas, Freezer, Trunks, Naruto/Kyuubi).
  - Las habilidades nacen de la copia (origen del Missile, animación, canalización). La habilidad del héroe pasa a
    punto de lanzamiento 0 para no detenerlo.
  - Excepciones: refuerzos y transformaciones (Power Up, SSJ, Kyuubi) siguen en el héroe; la copia sólo hace el
    gesto. Rugido desafiante: la copia invulnerable no puede ser atacada; la atracción de la oleada va por script.
  - Precedente: el controlador `Game_Ctrl[p]` ya es una segunda unidad del mismo tipo.
- Efecto en el equilibrio: canalizaciones como Kamehameha o Spirit Bomb dejan de inmovilizar al héroe; ajustar daño o
  coste al probar.

## v19a (18/11/2026): copia espiritual y Embestida espiritual del Tauren

Primera habilidad hecha por una copia (idea de Leon del 18/11). Medidas inspiradas en CHARGE de Gaven
(Impossible Bosses BetaV3V, de Psyris; sólo ideas y números, código propio).

- Libro del Tauren (V) pasa a ser `'ALTb'`: Embestida espiritual (Q, `'ATb1'`) y los dos iconos sin efecto de v18k
  (Onda de choque W, Pisotón E). Cairne sigue con `'ALTa'`.
- Al lanzar: aparece una copia `'hCp0'` (base `otau`, no héroe; modelo y escala del Tauren; Aloc + Avul; azulada y
  translúcida) en la posición del héroe. El héroe no recibe ninguna orden.
- Copia: 0,2 s de amago; carga hacia el punto (350 a 1000) a 1100/s con Walk a 250 %; 300 de daño a cada enemigo
  que toca (radio 140, una vez) y lo aparta 180 a su lado; para si el suelo no es transitable. Al final Attack Slam:
  500 en 260 delante, pisotón y empujón 150. Se desvanece en 0,3 s. Daño con Her_Dano y Barras_Golpe, la copia es
  la fuente (cuenta para el jugador). Máx. 24 copias y 128 empujones.
- Prueba: `lat\v19a-bolsas.txt` anota "embestida jN golpes G dano D" al terminar cada una.
- Fuentes: `scripts/v19a.py`, `objetos_v19a.py`, `hacer-v19a.sh`, `entrar-v19a(-prueba).sh`.
- Hashes: v19a `936c2b08…`, v19a-prueba `09dd9fd5…` (bases v18z `186d1e2b…`, v18z-prueba `894a3db4…`).
- Estado: **Validated** (pJASS, reextracción de j/w3a/w3u, bytes-diff sólo esos tres, verify). Sin jugar.
- Por comprobar en juego: que el héroe siga moviéndose y disparando al lanzar Q; animación y color de la copia;
  que la carga no atraviese acantilados; el daño y el apartado; que las muertes cuenten para el jugador.

## v19b (18/11/2026): todas las habilidades de Tauren y Cairne, para probarlas de una vez

Leon: "implementa todas para un test mas rapido probando todas". Cifras de prueba, sin equilibrar.

- **Corrección de v19a**: su libro 'ALTb' tenía mínimo/máximo de hechizos en 1 con tres dentro (sólo se vería uno).
- **Motor común** (`scripts/v19b.py`, sustituye el bloque de v19a): un reloj de 0,03 s, hasta 200 piezas; copias
  'hCp0' (Tauren), 'hCp1' (Cairne, nueva), 'hCp2' (espíritu SpiritWalker, nueva); proyectiles 'dumi' del jugador
  neutral con modelo pegado. El daño lo hace un 'dumi' del jugador (cuenta para él) con Her_Dano y Barras_Golpe.
  Aturdir = PauseUnit con contador (no toca unidades ya pausadas por otro sistema); ralentizar = 50 % de la velocidad
  que tenía; rayos de 0,24 s.
- **Tauren** (libro V): Q Embestida; W Tótem arrojado (250 a 200 + 1 s aturdido, 4 s ralentiza a 300, vuelve dañando
  200); E Lanzar roca (300 a 180 y 3 botes al 80 %); R Bombardeo (definitiva, recarga 10 s: la copia 8 s en el punto,
  piedras en espiral 180 a 150); A Garra espiritual (espíritu en el punto, atrae a 450 durante 2,5 s, 250 a 250);
  S Rugido desafiante (copia en el punto, 4 s ordena "move" hacia ella a 700, estalla 500 a 350 + 1 s aturdido);
  D pasiva Disparo encantado (cada 4.º impacto de bala ×3 y onda del daño de la bala a 200), en `Arm_Impacto`.
- **Cairne** (libro V, 'ALCb'): Q Grieta ancestral (900, se parte a 1,5 s: 250 + 6 % de vida máx. hasta +1500 a 150
  de la línea, junta y ralentiza 2 s); W Lanza ancestral (1100 atravesando 250, se parte en 3 de 500 con 150);
  E Espíritu ancestral (copia sale dañando 150, pisa 350 a 300, vuelve dañando 100 y cura 15 por golpe, hasta 300);
  R Estampida (definitiva, recarga 12 s: 14 kodos espirituales en frente de 700, 1600, 180 y apartan); A Tótem del
  trueno (150 a 200, 6 s atrae a 600 y rayos a 3 cada 0,5 s de 150); S Marca ancestral (el de más vida a 400 del punto,
  3 s, 500 a 300; contagia a 3 a 450 que explotan a 1,5 s con 250 a 250); D pasiva Réplica (cada golpe principal
  aturde 1 s a 250 de Cairne y 0,75 s a 250 del golpe); F pasiva Espíritus guardianes (3 copias en tres direcciones,
  900, 250 y apartan; al reaparecer y una vez por ronda bajo el 25 % de vida).
- Prueba: `lat\v19b-bolsas.txt` anota "hab <nombre> jP golpes G dano D" al terminar cada habilidad (el Bombardeo
  suma sus piedras; los corredores de la Estampida van uno a uno).
- Fuentes: `v19b.py`, `objetos_v19b.py`, `hacer-v19b.sh`, `entrar-v19b(-prueba).sh`.
- Hashes: v19b `45324a03…`, v19b-prueba `dafeb217…` (bases v19a `936c2b08…`, v19a-prueba `09dd9fd5…`); en WOE (cmp).
- Estado: **Validated** (pJASS, reextracción j/w3a/w3u, bytes-diff sólo esos tres, verify). Sin jugar ni LAN.
- Riesgos a mirar: WaveAI puede volver a dar órdenes durante el Rugido; PauseUnit/SetUnitMoveSpeed podrían chocar
  con otros sistemas que pausan o cambian velocidad (élites); el modelo CIN de Cairne no tiene "spell" (se usan
  "attack", "attack slam", "spell slam", "stand victory"); coste visual con muchas piedras y kodos.

## v19c (19/11/2026): copias de D.O.N, rocas ×3, Embestida que arrastra

Petición de Leon: que las habilidades de los personajes de D.O.N las lance una copia, como con el Tauren; rocas del
Tauren con área ×3; Q del Tauren atacando y llevándose a los enemigos; comando para elegir personaje.

- Copias 'hCpG' Goku, 'hCpF' Freezer, 'hCpT' Trunks, 'hCpN' Naruto y 'hCpK' Kyuubi. Base 'otau' como 'hCp0', con
  el modelo y la escala del héroe y 10000 de maná. Cada técnica real (A00P, A0IA, A0BZ, A01G; A0IY, A0J1, A0IX, A0IW,
  A0IV; A0GV, A086, A05B, A03W, A0I5; A0AI, A0F5, A0F3, A0HW) la recibe la copia al nivel del héroe. La copia la
  lanza mirando al objetivo y el héroe sigue libre (ya no se cortan su dash ni su ráfaga).
- En el héroe siguen Power Up (A0G2, A0IZ, A0H5), Kyuubi Mode (A00U) y Kage Bunshin (A00T).
- Una copia por jugador a la vez, salvo Destructo Disc.
- Vida de la copia: ocupada de 1 a 15 s; se desvanece en 0,5 s y sigue invisible hasta los 25 s, o hasta 60 s si
  `Don_EnCurso`.
- Rasenrengan comprobaba el tipo del lanzador; ahora usa `Dcp_Tipo`.
- Lanzar roca: 540 por bote (antes 180). Piedra del Bombardeo: 450 (antes 150). Las dos llevan anillos de polvo.
- Embestida: "attack" en bucle a 1,5. Quien toca recibe 300 una vez y va 90 por delante de la copia, a no más de 70
  de su línea. El golpe final no cambia (500 a 260).
- `-pj N` ya estaba (0 Tauren, 1 Cairne, 2 Goku, 3 Freezer, 4 Trunks, 5 Naruto).
- Registro de prueba: "don copia jP orden" y "don fin jP orden tN" en lat\v19c-bolsas.txt.

Builds (hacer-v19c.sh sobre v19b 45324a03… y v19b-prueba dafeb217…), pJASS correcto, j/w3a/w3u reextraídos:

- v19c: `2f4314c4cdf90472026f3d653f8dc8f2dd302920d42ddd07e60a3b47ac9f93bf`
- v19c-prueba: `b49eef44e35eae66a3d081e66924512beaca61323d624695f9fc4e2d179cfae7`

Estado: Validated. Sin jugar. Riesgos sin comprobar:

- Técnicas de D.O.N que miren buffs o estado del lanzador.
- Warp Kamehameha y los dashes mueven la copia, no al héroe.
- Disparos que siguen al lanzador después de los 25 s.

## v19d (19/11/2026): correcciones tras probar v19c

Quejas de Leon con v19c:
- Rasen Shuriken a veces deja una pieza.
- Burning Attack y Dragon Fist no salen.
- Las copias tardan y caminan hasta el objetivo.
- La copia de Goku no lleva su SSJ.
- La roca del Tauren es pequeña para su área.

Petición nueva: las técnicas a una unidad deben alcanzar también a las cercanas.

Cambios:
- **Alcance:** la copia aparece dentro del alcance de la técnica (`Dcp_Rango`, del aran al nivel usado; Burning Slash
  sólo tiene 125). Queda a alcance − 50 del objetivo (mínimo 60), con un destello. ucpt/ucbs 0 en las copias.
  - Causa probable de que no salieran Burning Attack (1500) y Dragon Fist (2000): fuera de alcance la unidad acepta la
    orden y camina; ya pasaba en v16y con el héroe.
- **Estado del héroe:** la copia lleva sus piezas (A069, A06A, A06B, A0JO, A00Y, A0G4, A07X, A03Z, A0AO, A0HX) al
  mismo nivel, y "alternate" con Goku en nivel 5.
- **Eco:** para las técnicas a una unidad, un disparador de daño en el objetivo mientras viva la copia. El daño de la
  copia o de las piezas del jugador (no el héroe ni 'dumi') se repite a 8 enemigos a 300, con BoltImpact.
  - Es un eco del daño, no de aturdimientos ni arrastres.
- **Rasen Shuriken:** las piezas sin vida ahora mueren solas: 'h01B' y 'h0DM' a los 4 s; en modo Kyuubi 'h064' a los
  2,5 s y 'h05B' a los 2 s. Es la causa más probable, no confirmada.
- **Tauren:** la roca y las piedras del Bombardeo, con SetUnitScale 3 en su 'dumi'.
- **Registro de prueba:** "don copia jP orden a D" (D = distancia de la copia al héroe), "don efecto jP orden" y
  "don fin … eco N dano D".

Builds (hacer-v19d.sh sobre v19c 2f4314c4… y v19c-prueba b49eef44…), pJASS correcto, j y w3u reextraídos:

- v19d: `72158cc75b1b5d835050eb94711d1bf527e327d86085ad8a47cb66775917217a`
- v19d-prueba: `9ababbd0b0220083de8ec4a8053aab98ae98434bba26289cdbfb7aa2db4ada52`

Estado: Validated. Sin jugar.

Pendiente de comprobar en juego:
- que la escala de 'dumi' agrande el modelo pegado;
- que las técnicas a una unidad hagan eco;
- que Dragon Fist salga ahora.

Las esperas cortas propias de D.O.N (TriggerSleepAction 0,07–0,08 al lanzar) siguen.

## v19e-prueba (19/11/2026): diagnóstico de las copias de D.O.N

Leon: "varias habilidades no se estan casteando con el dummy", "sobretodo en las DON"; pide registros por habilidad y
empezar en la oleada 6. Sólo variante de prueba sobre v19d-prueba (`scripts/v19e.py`, `hacer-v19e.sh`); cambia sólo el j.
El mapa normal sigue siendo v19d.

- Registro `CustomMapData/lat/v19e-don.txt` (máx. 3000 líneas; se escribe 2 s tras la última o con `-reg`):
  `pulsa` (botón, técnica real, orden, guardas: down, vivo, pausa, curso, ocupada, nivel, distancia), `copia cN` o
  `copia NO ACEPTA` (tipo, nivel, maná, distancias, alcance), muestras `cN kK` a 1/4/10/20/60 ticks, `ev` CHANNEL/CAST/
  EFFECT/ENDCAST/FINISH de copias y héroes D.O.N, `cN libre` y `don fin cN`. Tauren/Cairne también van ahí.
- La partida empieza en la oleada 6 (`Ronda_Numero = 6` antes del primer `Ronda_Lanzar`).
- Comprobación estática: todos los disparadores D.O.N de estas técnicas son SPELL_EFFECT de cualquier unidad, siempre
  activos, con condición sólo de id (Naruto con `Dcp_Tipo`). Si sale `ev EFFECT` de la copia, el disparador corrió.
- v19e-prueba `d8201e67d31b821a12ea921a60203babe2c1ba1334e4302c238a09f3fb6df1f1`: pJASS correcto, j reextraído igual,
  sólo cambia war3map.j, mpq verify ok, copiado a WOE (cmp ok). **Validated**; sin jugar.
- Pendiente: Leon prueba cada técnica y pasa el registro para el diagnóstico.

### Resultado de v19e-prueba y v19f (19/11/2026)

- Registro de Leon: todas las técnicas con copia dan EFFECT salvo Dragon Fist (A0BZ) y Burning Attack (A05B), que
  aceptan la orden sin empezar; 14 pulsaciones frenadas por la copia ocupada de otra técnica. Informe en
  `informes/errores/2026-11-19-devmission-don-copias-sin-lanzar.md`.
- v19f (`objetos_v19f.py`, `v19f.py`, `hacer-v19f.sh`): A0BZ y A05B con base ANrf y datos de Death Ball (orden
  rainoffire); copia ocupada sólo por la misma técnica. Normal sobre v19d, prueba sobre v19e-prueba (oleada 6 y registro).
  - v19f `791372baba034a93ce81d31082f29c281bccd940dc705012f28c1570dbc6df17`
  - v19f-prueba `cdd003c3479c1633bab49c61bc7780f71ae285f075b2d0a9345e7764a650393f`
  - pJASS correcto, j y w3a reextraídos iguales, sólo cambian esos dos, mpq verify ok, copiados a WOE. **Validated**; sin jugar.

### v19g (19/11/2026)

- Leon con v19f: funcionan la mayoría; fallan Rasen Shuriken y Destructo Disc; quedan visibles efectos de la copia (SSJ).
- `v19g.py`/`hacer-v19g.sh` (sólo j): FzF_ki4 y NaF_Fe7/Ff7 usan el lanzador guardado antes de la espera; la copia se
  oculta (ShowUnit false) al acabar el desvanecido. Normal sobre v19f, prueba sobre v19f-prueba.
  - v19g `1fb537440e9ad06cfc294c19bed86fc7639f8ba573656c2399fccfa86ca04c3c`
  - v19g-prueba `0fd74259a8200ebdc67c57f94e70d89617e48aa6e670fff339733e5640e36ac7`
  - pJASS correcto, j reextraído igual, sólo cambia war3map.j, mpq verify ok, copiados a WOE. **Validated**; sin jugar.

## v19h (19/11/2026): restos de las técnicas de D.O.N

Leon, tras v19g: "fue bien ahora si, ahora evalua bien las habilidades y verifica que no queden reciduos tanto en la
spell como con los dommy de jugador" (capturas de Naruto modo sabio: copias azules visibles, esferas verdes sueltas).

- Barrido (normal y prueba): cada 0,5 s revisa las unidades de los jugadores 0-5. Las de los 92 tipos de pieza que
  crean las funciones GkF_/FzF_/TrF_/NaF_ se anotan al verse por primera vez y se quitan a los 15 s. La pieza más larga
  de D.O.N tiene 10 s de vida (Dragon Fist, disco). Las piezas sin vida temporal que D.O.N quita desde otra función
  también caen si pasan de 15 s.
- Copias: al desvanecerse sueltan A069, A06A, A06B, A0JO, A00Y, A0G4, A07X, A03Z, A0AO y A0HX. Si algo las vuelve a
  mostrar, se ocultan de nuevo.
- Prueba: `lat\v19h-don.txt` anota "pieza larga" (8 s) y "resto … quitado" con tipo, edad y posición, y muestras de
  la copia a los 5, 10 y 15 s.
- v19h `31386ffd…`, v19h-prueba `aebe8195…`. Validated (pJASS, reextracción, mpq verify). Sin probar en el juego.
- Pendiente: Leon prueba v19h-prueba con todas las técnicas y manda el registro; sus "resto" dicen qué técnica deja
  piezas y si 15 s corta alguna que debía durar más.

### Resultado de v19h-prueba y v19i (19/11/2026)

- `lat\v19h-don.txt` llegó al tope de 3000 líneas (copia en `work/titulo-devmission-20261026/datos/v19h-don-registro.txt`).
  El barrido quitó 858 restos a los 15 s; 855 eran piezas muertas. Tipos: h0D3 369, h05X 170, h0H2 92, h0DL 24,
  h06G 22, más otros 22 tipos. Sólo 3 seguían vivas (h01M).
- Causa: las piezas se basan en `hpea`/`hfoo`; 77 de los 92 tipos dejan cadáver que se descompone (udea 3). El modelo
  del efecto queda en el suelo hasta pudrirse (unos 90 s). El D.O.N original usa los mismos datos.
- Copias: todas ocultas (fase 2) en las muestras de 5, 10 y 15 s. Sólo las de A0IW (Freezer) seguían ocupadas a los
  5 s, en pausa con la técnica en curso, como debe ser.
- v19i: una pieza muerta se quita al pasar su tiempo de muerte + 0,5 s. El tiempo sale de `udtm` o del `death` de la
  base, en `datos/v19i-muerte.json` (de `scripts/muerte_v19i.py`). Las vivas siguen con el límite de 15 s.
  En la prueba se anotan el total de cadáveres quitados y los restos vivos.
- v19i `7a8ebdf9…`, v19i-prueba `97804590…`. Validated (pJASS, reextracción, mpq verify). Sin probar en el juego.

### Resultado de v19i-prueba y v19j (19/11/2026)

- `lat\v19i-don.txt` (1308 líneas, copia en `datos/v19i-don-registro.txt`): 1381 cadáveres de piezas quitados;
  restos vivos sólo 2 (h01M, a los 15 s). Piezas vivas a 8 s: h0CH, h0FW, h054 (ninguna llegó a 15 s).
- Copia atascada: c36 (Goku, A0IA "thunderbolt") en pausa y visible 15 s. Se pulsó 3,6 s después de c35; el motor
  GkF_qV4 dura ~3,3 s con el lanzador en una sola variable (GkV_s8[5850]); c35 ya estaba libre (k57) y su hilo, al
  acabar, dejó la variable en null, así que la nueva copia no se despausó.
- v19j: Dcp_Ocupada bloquea la misma técnica hasta 2 s después de soltar su copia, sea del jugador que sea; una copia
  ocupada sin su técnica en curso se suelta a los 8 s.
- v19j `b3f9b7f0…`, v19j-prueba `a96b5c2a…`. Validated (pJASS, reextracción, mpq verify). Sin probar en el juego.

### v19k: teclas de D.O.N, orden por fuerza y técnicas por carta (19/11/2026)

Leon: "apliquemosles mejor hotkeys a los DON tomando de referencia la original y tambien ordenando del mas fuerte al mas
ligero, apliquemos al menu de mejoras tambien que permitira aprender esas habilidad individualmente segun la seleccion".

- w3a (`scripts/objetos_v19k.py`): cada puente del libro V lleva la tecla de su técnica en D.O.N 1.8c y los botones van
  del más fuerte al más ligero (fila de arriba y luego la segunda). Orden: Goku R T W Q X; Freezer R X E W Q T;
  Trunks R T E W Q X; Naruto R D T Q E X. Kyuubi Chakra Blast es T en D.O.N pero comparte libro con Odama Rasengan:
  aquí va en D.
- w3b: iconos DK00-DK0M (copias de D000) para las 23 cartas de técnica.
- j (`scripts/v19k.py`): cartas 40-62, una por técnica. Al crear el cuerpo sólo se sabe la técnica inicial
  (Kamehameha, You Will Die By My Hand!, Burning Attack, Rasenrengan); el resto queda oculto en el libro
  (SetPlayerAbilityAvailable). En cada tanda de mejoras del héroe las cartas 2 y 3 son técnicas aún aprendibles o
  mejorables del personaje elegido; elegirla la aprende a nivel 1 o la sube un nivel hasta el máximo original (las de
  nivel 4 de D.O.N llegan a 4; definitivas a 3; Spirit Bomb, Power Up, transformaciones, Kage Bunshin a 1). El color de
  la carta es amarillo para aprender y el del nivel al que sube. No cuentan para la garantía de T4.
- Prueba: "-tec" aprende todas al máximo; registros `lat\v19k-*.txt`.
- v19k `c70817f1…`, v19k-prueba `035be7ba…`. Validated (pJASS, reextracción de j/w3a/w3b, mpq verify). Sin probar en
  el juego: comprobar que los botones ocultos no aparecen, que la tecla abre la técnica correcta y que la copia usa el
  nivel aprendido.

## v19l (19/11/2026): malditas, economía, técnicas de Tauren y Cairne por carta e iconos de los cuadros

Leon: "de momento torrres afuera, no las usaremos aun. dificultad siempre en nightmare, agrega mas malditas de acuerdo a
nuestra jugabilidad, las habilidades como carta de las habilidades que ya desarrollamos de cairne y tauren, mas cartas
de economia, y las propuestas no cerradas aun para desarollar, adicional como darle un mejor acabado visual al apartado
de mejorar al boss y mejoras de jugador, ya que no se ven bien vistosas y se puede confundir".

Decisiones de Leon: **torres fuera** por ahora (no se desarrollan); **dificultad fija en nightmare** (sin selector).

- Causa principal de la confusión: desde v17s todos los iconos de los cuadros (Mutación Evo, Tienda, mejoras del
  héroe) mostraban 'DC00', la tortuga verde (fotogramas de la grabación de v18r). Title_Skin no cambiaba la textura de
  la pieza ya colocada. v19l rehace la pieza del icono con su textura cuando cambia (Cua_Pintar, Cua_IcoTex).
- Etiqueta de tipo en el primer renglón de cada carta del héroe: Estadística (gris), Economía (oro), Maldita (rosa),
  Técnica (celeste). La descripción baja un renglón (py 440 → 457) porque el texttag crece hacia arriba.
- Técnicas de Tauren (63-69) y Cairne (70-77), del más fuerte al más ligero: Bombardeo R, Rugido S, Embestida Q,
  Garra A, Tótem W, Lanzar roca E (inicial), Disparo encantado (pasiva) / Estampida R, Marca S, Grieta Q, Trueno A,
  Espíritu E, Lanza W (inicial), Guardianes y Réplica (pasivas). Activas hasta nivel 3: +30 % de daño por nivel sobre
  el 1.º (Cop_Fac, guardado por pieza en Cop_Mul y aplicado en Cop_Area y en los rayos del Tótem del trueno). Pasivas
  de un nivel: hasta aprenderlas no actúan. Iconos DL00-DL0E (el aart de cada habilidad; Disparo encantado
  BTNSearingArrows).
- Malditas (una vez cada una; 12 % en la 4.ª carta, al azar entre las que quedan): Pacto maldito, Sed de sangre (+50 %
  de daño de armas; las runas de vida no curan), Codicia (+100 % de oro de bolsas; suerte a 0 y ya no sube), Pacto
  mutante (+8 % de daño por cada Mutación Evo activa; entra una más al azar), Ruleta (+10 % de crítico y crítico ×3;
  -20 % de vida máxima). Iconos DM00-DM03.
- Economía con calidad T1-T5, en el sorteo con las de estadística (10 cartas): Reembolso 5/8/12/16/20 % de lo gastado en
  armas y munición (tope 50 %), Imán +40/60/85/115/150 de radio de recogida, Interés 3/4/6/8/10 % del oro al empezar el
  descanso (tope 250), Bolsa doble 8/12/17/23/30 %. Iconos DM04-DM07.
- Índice de técnicas por jugador p × 100 + x; Tec_Listo por jugador y personaje.
- v19l `ac3bfba1…`, v19l-prueba `83e9db2e…` (registros `lat\v19l-*`; "-tec" sirve también para Tauren y Cairne).
  Validated (pJASS, reextracción de j/w3b, mpq verify). Sin probar en el juego: iconos distintos por carta, renglón de
  la etiqueta dentro del cuadro, pasivas ocultas hasta aprenderlas, daño por nivel, efectos de malditas y economía.

### Acabado visual propuesto (pendiente de que Leon elija; v19m)

- Pantallas con identidad: Mutación Evo con cabecera y marco rojo oscuro y título "MEJORA DEL JEFE"; mejoras del héroe
  con marco dorado/azul y "TU HÉROE". Hoy sólo cambia el color de la cabecera.
- Banda de tipo encima de cada carta (una pieza de color, sin texto nuevo): roja para mutación, gris estadística, oro
  economía, morada maldita, celeste técnica. Ahorra el renglón de la etiqueta.
- Al elegir: destello y escala de la carta elegida, las otras se apagan 0,3 s antes de cerrar.
- Panel de mutaciones activas con su número (×2, ×3) y el objeto para purgar una; aviso de transición héroe/jefe.

## v19m (19/11/2026): acabado visual de los cuadros

Leon eligió "Todo lo propuesto".

- Texturas claras para teñir (`scripts/texturas_v19m.py`, carpeta `texturas-v19m/`): CuaBanda 'DS1P', CuaMarco
  'DS1Q', CuaCabecera 'DS1R'. Icono de Purga 'DM08' (BTNDispelMagic). `scripts/objetos_v19m.py` (w3b e imp).
- Marco por pantalla sobre cada carta (profundidad 428, entre el fondo 430 y el icono 405): rojo en la mejora del jefe
  (Mutación Evo y su resultado), dorado en las mejoras del héroe, ninguno en la pantalla de inicio.
- Banda de tipo encima de cada carta (py 168, 415): roja en mutaciones; en el héroe gris estadística, oro economía,
  morada maldita, verde purga, celeste técnica; sin banda en la carta de refrescar.
- Cabecera con banda de color (py 66, 420) y títulos "MEJORA DEL JEFE · …" / "TU HÉROE · …". La pantalla de inicio
  dice "Tienda · primero, la mejora del jefe" (rojo) o "Tienda · ahora, las mejoras de tu héroe" (dorado): es el aviso
  de transición entre jefe y héroe.
- Destello al elegir: la elegida con marco blanco y las demás al 30-35 % durante 0,3 s; la elección se aplica después
  (Cua_Hacer, por temporizador y en código común). Se ignoran clics y refrescos durante el destello; si se sale o cambia
  de paso en ese tiempo, la elección no se aplica.
- Panel "Mutaciones activas" (texttag Cua_TMut, uno más por cliente con el cuadro abierto) bajo la cabecera, 6 por
  renglón, jefe rojo / élites naranja / comunes claro, con ×n.
- Carta Purga (39): 15 % en la 4.ª carta del héroe si no salió maldita y hay mutaciones de élites o comunes; quita una al
  azar (las del jefe 0-3 no) y lo avisa a todos. No cuenta para la garantía de T4.
- v19m `68298a9a…`, v19m-prueba `62464b79…` (registros `lat\v19m-*`). Validated (pJASS, reextracción de j/w3b/imp y
  las 3 texturas, mpq verify). Sin probar en el juego: tintes reales (vista previa sólo en PNG), orden de lo translúcido
  de marco/banda/icono, que el panel de 3 renglones no pise la cabecera, destello y Purga.

## v19n (19/11/2026): correcciones tras la prueba de v19m

Grabación de Leon con v19m: iconos distintos, marcos, bandas, carta Purga, panel de mutaciones y cabeceras de inicio se
ven bien. Fallos vistos y corregidos (`scripts/v19n.py`, `hacer-v19n.sh`, sólo cambia el j):

- Mejoras del héroe: la 1.ª carta y Refrescar (casillas 0 y 8 de 5 cartas) salían sólo con texto, sin fondo, icono ni
  pista de clic. Las casillas de 5 cartas nunca se marcaban en `Cua_SlotUsa` (fallo desde v18y). Ahora se marcan.
- Cabecera: los prefijos "MEJORA DEL JEFE ·" / "TU HÉROE ·" partían el título en dos renglones y el texto rojo o dorado
  se perdía sobre la banda del mismo color. Vuelven los títulos de v19l, en blanco; la banda baja de py 66 a 87.

Mapas: v19n `bde2052a…`, v19n-prueba `cbb2b01d…`. Validated (pJASS, reextracción, bytes-diff sólo j, mpq verify).
Sin probar en el juego: el aspecto de las casillas 0/8 y de la cabecera, y el destello al elegir (no visible a 3 s por
fotograma en la grabación).

## v19o (19/11/2026): cartas con las ventanas de la tienda y contorno de los indicadores

Pedido de Leon: usar el mismo formato de ventanas y cuadros de la tienda de armas, y dar el color con el efecto que
rodea al indicador de la tienda (azul) o del jefe (carmesí), rehecho para rodear un rectángulo alto.

- Carta: `CuaCarta` ('DS1S', `texturas_v19o.py`): ShopPanelL en nueve partes a 330 × 480, con esquinas, bordes y gemas
  del mismo tamaño que en la tienda. Sin teñir. Encima, recuadro del icono 'DS03' (ShopWindow), placa del nombre 'DS06'
  y caja del texto 'DS04'. Icono a py 285, nombre a 386, texto 14 px más abajo y 12 más adentro.
- Contorno: `aro_v19o.py` convierte las esferas TiendaEsfera/JefeEsfera en franjas alrededor de un rectángulo de
  esquinas redondeadas (el borde de cada disco recorre el perímetro tres veces; mismas texturas, colores y animaciones);
  `mdx_sin_billboard.py` lo hornea para la cámara de los menús. Unidades 'ubjA' (azul) y 'ubjR' (carmesí), copias de
  'ubjt', a profundidad 426 con escala 7,5747e-4 × 426. Azul: héroe, Armas y Habilidades; carmesí: Mutación Evo y
  votaciones del jefe; cerrados sin contorno; al elegir, el de las demás baja al 25 %. Se muestra sólo en el cliente
  que mira (escala y alfa locales, visual).
- Fuera el marco plano 'DS1Q' y la banda 'DS1P' de v19m (texturas sin uso en el mapa).
- Vista aproximada sin animación: `texturas-v19o/maqueta-aproximada.png` (`scripts/aro_vista_v19o.py`).

Mapas: v19o `5091daaa…`, v19o-prueba `5f9f5734…`. Validated (pJASS; reextracción de j, w3u, w3b, imp y los 3
archivos nuevos; bytes-diff sólo esos; mpq verify). Sin probar en el juego: que el contorno se vea del tamaño y en el
sitio previstos (escala calculada, no medida), su brillo real con las animaciones, y que el texto quepa en la caja.

## v19p (19/11/2026): burbuja de la esfera en cada carta, teñida por calidad; gris opaca en las cerradas

Pedido de Leon tras v19o: tomar la esfera del indicador entera (con su rejilla de hexágonos), en forma de rectángulo alto
con puntas redondeadas que cubra la carta, y teñirla según la calidad. Tras ver el Stand en el visor: ajustar contorno y
esquinas, hexágonos más pequeños y regulares, pulso más corto sin cambiar su tiempo; luego, una versión gris opaca para
los cuadros cerrados (Armas y Habilidades mientras la Mutación Evo es obligatoria). Leon aprobó la forma en el visor.

- `burbuja_v19p.py` (desde TiendaEsfera.mdx): contorno 344 × 496 px con esquinas de radio 20 (la carta 330 × 480 cabe
  con 7-8 px); 307 hexágonos regulares de 15 px con 18 % de hueco, recortados por el contorno, con el uv del disco
  original por escala radial inversa (texturas y sus animaciones iguales); anillo ping4 llevado al contorno; pulso del
  ayudante Globe 1,0 → 1,03 → 1,0 en el mismo ciclo de 4 s (antes 1,1); colores de geoset sin saturación y Blue_Glow2
  gris (`CuaBurbujaBrillo.blp`) para teñir con SetUnitVertexColor.
- `burbuja_gris_v19p.py`: misma forma; hexágonos grises opacos (brillo en mezcla, alfa 0,55), resto de capas al
  15-30 %, sin animaciones de textura ni pulso.
- `v19p.py`: 'ubjB' (teñible) y 'ubjG' (gris) por carta a profundidad 428 (delante del fondo, detrás de recuadro,
  placa, caja, icono y botón). Color = r, g, b de Cua_Ver: calidad 1-5 de Her_Tinte, Purga, maldita, refresco; Armas,
  Mutación y Habilidades en el inicio; carmesí del jefe en la Mutación Evo. Cerrados: gris opaca. Al elegir, las demás
  al 25 %. Fuera 'ubjA'/'ubjR' y sus modelos.
- Visor: `burbuja-v19p/visor` con `burbuja-v19p/servidor.py 4397` (mdx-m3-viewer 5.12, cenital, carta debajo).

Mapas: v19p `863b0c8f…`, v19p-prueba `dc436171…`, copiados a Maps/Test de WOE (cmp). Validated (pJASS; reextracción de
j, w3u, imp y los 3 archivos nuevos; los 2 modelos quitados ya no están; bytes-diff sólo j, w3u e imp; mpq verify).
Sin probar en el juego: tamaño y posición reales de la burbuja (escala calculada), que SetUnitVertexColor tiña también
las capas aditivas como en el visor, y el aspecto de la gris opaca sobre los cuadros cerrados.

## v19q (19/11/2026): cartas altas, cabecera en cuadro, fondo de rayos, descanso de 60 s

Pedido de Leon tras jugar v19p ("fue bien, queda asi"): cartas más altas, efecto de contorno con un cuadro en la
cabecera, ajustar el texto de la descripción, el fondo de rayos de la intro detrás de las cartas, la tienda de armas y
las mejoras del héroe, quitar la burbuja gris opaca (cerradas sólo oscuras) y "sube a 60 el tiempo de compra".

- `burbuja_v19q.py carta|cabecera`: mismo método de v19p. Carta: contorno 172 × 278 (carta 330 × 540). Cabecera:
  contorno 388 × 48, radio 16, con la banda exterior del anillo a grosor fijo (K = 2 px por unidad, W = 15) en vez de la
  escala radial, que en una forma tan apaisada engordaba los extremos. 337 y 149 hexágonos.
- `texturas_v19q.py`: CuaCarta a 330 × 540 (marco de la tienda en nueve partes, esquinas sin estirar).
- `objetos_v19q.py`: fuera 'ubjG' y CuaBurbujaGris.mdx; 'ubjC' (copia de 'ubjt') con CuaBurbujaCab.mdx.
- `v19q.py`: carta en py 425 (155..695), icono 278, placa 404 (nombre 385), caja 150 px a 511, descripción 0,022 a
  456 / 473 (héroe), botón y pista a 645, pie a 748; cabecera 'DS0B' (ShopWide) 760 × 80 a py 84 sin teñir, con
  'ubjC' teñida con el color de la pantalla, título a 67. `Fondo_Ver(p, k, x, on)`: una 'uidn' (nebulosa del título)
  por pantalla (1 tienda X 2400, 2 cartas X 4800), creada en código sincronizado en Shop_Mostrar / Cua_Mostrar, a la
  altura Title_BgHeight + Z(0, 8700) − Z(x, 8700), y escala sólo en el cliente del jugador. Ronda_DESCANSO 45 → 60.
- Visor: `burbuja-v19q/visor` con `burbuja-v19q/servidor.py 4398` (pantalla entera con nebulosa, cabecera y 3 cartas).

Mapas: v19q `4f183622…`, v19q-prueba `e63296a5…`, copiados a Maps/Test de WOE (cmp). Validated (pJASS; reextracción
de j, w3u, imp y los 3 archivos cambiados/nuevos; CuaBurbujaGris fuera; bytes-diff sólo en lo esperado; mpq verify).
Sin probar en el juego: tamaño y encuadre de la nebulosa en las dos pantallas, que la nebulosa no tape piezas de la
tienda, textos en la caja más alta, pista del botón a 645, descanso de 60 s. El reloj de la réplica del tutorial
sigue contando desde 45 (Tut_STiendaT0), sin cambiar.

## v19r (19/11/2026): textos dentro de sus cuadros, sin pie de Esc, paneles de mejoras en el inicio

Pedido de Leon tras ver v19q: textos que tocaban el borde del cuadro, quitar el texto blanco "Esc…" de abajo, bajar
los cuadros aprovechando el espacio libre, y en la pantalla de elegir mejora del jefe y del jugador un panel arriba a
la izquierda (rojo, mejoras del jefe) y otro a la derecha (verde, mejoras del jugador), con iconos sólo de lo elegido;
al pulsar un icono, debajo un cuadro grande con contorno que copia el icono y muestra la descripción (vacío hasta
elegir uno); y 3 rectángulos pequeños arriba para alternar entre jefe, élite y comunes.

- `v19r.py`: cabecera a py 96 (título 0,027 a py 77, textos cortos "Tienda · primero, el jefe" / "Tienda · ahora, tu
  héroe"; a 0,03 partía en dos renglones desde ~33 caracteres); cartas a py 480 (210..750), todas sus piezas 55 px más
  abajo; descripción a px − 126 y centrada en la caja (546, héroe 559); fuera el pie 'DSEB'. "Mutaciones activas" ya
  no sale en el inicio (lo muestra el panel). Paneles (sólo Cua_Modo 0):
  - Piezas sincronizadas creadas una vez en `Pan_Construir` (desde Cua_Construir): ventanas 'DS1T' (340 × 310, py 325)
    y 'DS1U' (340 × 290, py 656) en px 210 y 1710, burbujas 'ubjP' / 'ubjD' (rojo 225,45,70 / verde 70,205,95),
    pestañas 'DS06'/'DS05' 100 × 34 a py 205 (px 102, 210, 318), placa "Mejoras de tu héroe", marco 'DS03' 132 del
    icono grande a py 586, un icono por mutación (18, `Pan_MIco`).
  - Iconos 52 cada 60 desde py 262, 5 por fila: hasta 10 por pestaña a la izquierda, 20 del héroe a la derecha.
    `Pan_Ordenar` (sincronizado, al abrir y tras cada mejora del héroe) coloca los de Cua_Activa > 0;
    `Pan_Registrar` (en Cua_Hacer tras Her_Aplicar) crea el icono de la mejora con su calidad.
  - Clics por trackables de Shop_Pista: 60-62 pestañas, 70-79 iconos de mutación, 80-99 iconos del héroe; Shop_Clic los
    pasa a `Pan_Clic` (sincronizado), que rehace el icono grande (`Pan_Detalle`).
  - `Pan_Ver` (local, dentro de Cua_Ver) muestra piezas, burbujas y 10 texttags (pestañas, título, "Ninguna todavía."
    ×2, nombre y descripción ×2). Detalle de mutación: nombre (× n si se repite), grupo y Cua_Des; del héroe: nombre
    con el color de su calidad (5 maldita) y `Pan_HDes(p, x, q)`, copia de Her_Des para una mejora ya elegida.
- `texturas_v19r.py` (CuaPanel, CuaDetalle), `hits_v19r.cjs` (CuaHitIco 56 × 56, CuaHitTab 104 × 36),
  `burbuja_v19q.py panel|detalle` (contornos 178 × 163 y 178 × 153), `objetos_v19r.py` (w3b DS1T DS1U, w3u ubjP ubjD,
  6 imports).
- Visor: `burbuja-v19r/visor` con `burbuja-v19r/servidor.py 4399` (pantalla entera con paneles, detalle y guías).

Mapas: v19r `6bd52fbf…`, v19r-prueba `ecfacfdd…`, copiados a Maps/Test de WOE (cmp). Validated (pJASS; reextracción
de j, w3u, w3b, imp y los 6 imports nuevos; bytes-diff sólo en lo esperado; mpq verify). Sin probar en el juego: que
los textos queden dentro de cajas y paneles (la posición de texttags se estimó con la de v19q), que los trackables de
iconos y pestañas respondan a los clics, el aspecto de los paneles a los lados de las cartas y 13 + 10 texttags en la
pantalla de cartas. Multijugador: los clics y el orden son sincronizados y lo local sólo visual, sin ensayo LAN.

## v19s (19/11/2026): textos de los paneles, sin burbujas laterales, 75 s de compra, indicadores de borde

Leon tras jugar v19r ("esta muy bien"): ajustar los textos de los paneles, quitar el contorno de brillo de los cuadros
de izquierda y derecha, +15 s de compra, y los indicadores de tienda y jefe: junto al minimapa (abajo a la izquierda)
el icono subía por una regla antigua que ya no hace falta, y en los bordes izquierdo y derecho se cortaba.

- Medido en su captura: lejos del centro, piezas y texttags salen ~3 % más afuera de su px (1,02-1,03 en X).
- `v19s.py`: descripciones del detalle a px 95 / 1586 (antes 60 / 1560, que caían en 35 / 1583, sobre el marco);
  pestañas 92 × 34 en px 110 / 210 / 310 y profundidad 396 (la de Jefe a 412 quedaba detrás de la ventana por el orden
  de lo translúcido por distancia real); textos de pestaña a 0,016 alineados a la izquierda (95 / 195 / 274); iconos a
  393 y marco del detalle a 392; fuera `Pan_Aro`. Ronda_DESCANSO 75. DevJefe_Poner, DevTienda_Poner y Tut_Marca: sin
  la regla del minimapa (x < 375 → py ≤ 780) y límites laterales 58 / 1863 (antes 25 / 1895).
- `objetos_v19s.py`: fuera 'ubjP', 'ubjD', CuaBurbujaPan.mdx y CuaBurbujaDet.mdx.

Mapas: v19s `a5e38d7e…`, v19s-prueba `3b0958ce…`, copiados a Maps/Test de WOE (cmp). Validated (pJASS; reextracción
de j, w3u e imp; las 2 burbujas fuera; bytes-diff sólo en lo esperado; mpq verify). Sin probar en el juego: posición
final de los textos (estimada con la medida de v19r), que la pestaña de Jefe ya se vea, y los indicadores en los bordes.
