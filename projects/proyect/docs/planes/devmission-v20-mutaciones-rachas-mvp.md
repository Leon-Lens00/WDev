# Dev Mission v19t+: mutaciones, linterna, dash, rachas y MVP de la oleada

Plan pedido por Leon el 19/11/2026 tras jugar v19s ("anota este plan ya que es algo extenso para implementar").
Base: v19s (`a5e38d7e…`, prueba `3b0958ce…`), Warcraft III Classic 1.27b, sólo JASS. Una letra nueva por entrega;
reglas de entrega en la skill `mapa-dev-mission`. Estado por fase en «Registro de entregas», al final.

## Pedido (resumen fiel)

1. **Cartas de Mutación Evo** (las del inicio de oleada, hoy 230 × 300 negras con borde rojo): con el diseño de los
   cuadros de mejora (ventana de la tienda) y otro cuadro debajo con la descripción del cambio al enemigo.
2. **Que funcionen** todas las mejoras de enemigos (jefe, élite, comunes, oleadas) y las del jugador que aún no hagan
   efecto.
3. **Caparazón espinoso** (pasiva de súper élite): con poca vida del jugador hace demasiado daño. Reducirlo o
   cambiarlo; puede pasar a ser una mejora de enemigos que, al elegirla, entra en la baraja de mejoras enemigas.
4. **Baraja de mejoras del enemigo** (recuadro "Élites: vida y daño ×150" con las 4 pasivas, hoy debajo del icono del
   arma): abajo, cerca del minimapa. El hueco queda libre para algo que Leon dirá después.
5. **Linterna ilimitada** por defecto. Una mejora maldita da una ventaja y a cambio la linterna pasa a la mecánica
   actual de recargar: cargas por oleada y por enemigos muertos, calibradas para que matar mucho no dé 10-20 cargas de
   golpe (la ganancia por muertes es una ayuda mínima). Con la linterna limitada pueden salir mejoras de duración.
6. **Sonido al mostrar el resultado de la votación**: `ArrangedTeamInvitation.wav` (nativo).
7. **Dash en las mejoras**: sin maná; usos con icono debajo de las armas, texttag de cargas y otro de recarga; 2 cargas
   de base; mejoras de cargas, distancia y velocidad sin que se dispare con pocas mejoras.
8. **Rework de rachas**: más difíciles de alcanzar (ambos tipos). Según la racha conseguida, en la tienda se ofrece un
   pull extra de mejoras con más probabilidad de mejoras fuertes. Mejoras con tier: la misma mejora (p. ej. habilidad 1
   +10 % de daño) a tier 3-5 sube de golpe (p. ej. +50 %).
9. **First blood**: mejora garantizada y equilibrada para quien la consiga.
10. **Mejoras raras que cambian una habilidad** (ejemplo de Leon: RasenShuriken lanza 3, los dos extra rodean al
    principal y llegan al mismo destino). Propuestas abajo.
11. **Mejoras por tipo de arma**: menos recarga y más daño para un solo tipo; se mantiene el bono general de daño.
12. **Cuadro de resultado de la oleada**: para 8 jugadores (hoy 4). Tras las estrellas, una puntuación por jugador;
    MVP (mayor) y su contrario (menor) con modelo, nombre, animaciones, sonidos y recompensa del MVP. Detalle en la
    fase 8.

## Estado actual comprobado en v19s (lectura del j)

- Cartas de mutación al empezar la oleada: `Cua_MuestraEmpezar`, `Mut_Bg[p*3+k] = Punt_Pieza(…, 230 × 300, 'DS01')`.
  Votos y ganador en `Cua_Recuento` (sincronizado; suma `Cua_Activa`).
- Mutaciones x 0-17 (`Cua_Nom`, `Cua_Des`). Uso de `Cua_Activa[x]` con índice literal en el j: x 0, 3, 5, 6 y 11 sólo
  aparecen una vez, así que pueden no tener efecto. Hay que auditarlo una por una; el número no lo demuestra.
- Pasivas de súper élite: `Sup_PaNom[3] = "Caparazón espinoso"`; HUD `Sup_Hud`/`Sup_Bg` (4 filas desde py 345).
- Linterna: batería `Bat_T[p]` de 0 a 100 s, gasta 0,1 cada 0,1 s, se llena al empezar la oleada (`Bat_T[p] = 100.`),
  `Bat_Recargar`, `Luz_NivelDe` y `Luz_Ajustar` (BatLuz0-5.mdx).
- Dash: `RapidPair` (450 de distancia, 0,375 s), gasta maná del controlador; el bot espera `Bot_ESPERA_DASH`.
- Rachas: `Racha_Muerte`.
  - Racha sin morir: tier = N / 25, máximo 8 (200 muertes).
  - Multi-kill: ventana de 3 s, umbrales `Racha_MultiUmbral` 8 / 15 / 25 / 40.
  - Primera muerte de cada oleada: `Racha_PrimeraRonda`.
- Resultado de la oleada: `Punt_*`, cuadro 'DSP3' de 600 × 470 con estrellas 'DSP1'/'DSP2' y 4 columnas.
- Mejoras del héroe x 20-77 con calidad 1-5 (`Her_Cal`, `Her_Valor`).
  - Habilidades: Goku 40-44, Freezer 45-50, Trunks 51-56, Naruto 57-62, Tauren 63-77.
  - Toda habilidad la lanza una copia dummy (memoria `habilidades-por-copia`).

## Decisiones tomadas (las que Leon dejó a mi elección); se pueden cambiar

- **Maldita de la linterna: "Pacto de sombras".**
  - Ventaja: +20 % de daño de todas las armas y +10 % de velocidad de movimiento.
  - Coste: la linterna pasa a batería limitada.
  - Con la batería limitada salen en la baraja del héroe "Pilas reforzadas" (+25 % de duración, hasta 3 veces) y
    "Recarga rápida" (+50 % de lo ganado al matar).
- **Batería limitada:**
  - Al empezar cada oleada recupera 45 s, hasta el máximo de 100 s, en vez de llenarse.
  - Al matar: 1 s cada 12 enemigos, con un tope de 8 s por oleada. Nunca llega de golpe a cantidades grandes.
- **Dash:**
  - 2 cargas de base y recarga de 6 s por carga, una a la vez.
  - Mejoras (con calidad, pocas veces cada una):
    - "Impulso extra": +1 carga, hasta 4.
    - "Enfriamiento": −12 % de recarga, mínimo 3,5 s.
    - "Zancada larga": +12 % de distancia, máximo +36 %.
    - "Dash veloz": −12 % de duración del dash, máximo −30 %.
  - Icono del dash debajo de las armas, con un texttag de cargas a la derecha y otro con la recarga en segundos.
- **Caparazón espinoso:**
  - Sale de la baraja aleatoria de pasivas de súper élite.
  - Pasa a ser una carta de Mutación Evo de élite ("Espinas"): la élite devuelve el 8 % del daño recibido, con un tope
    de 2 % de la vida máxima del jugador por golpe, y nunca deja al jugador por debajo de 1 de vida.
  - Al elegirla en la votación entra en la baraja de pasivas enemigas para las siguientes élites.
- **Rachas** (calibrar con registros de -prueba antes de fijarlos):
  - Racha sin morir: 40, 90, 150, 220, 300, 390, 490, 600 muertes.
  - Multi-kill: 12 / 22 / 35 / 55 en 3 s.
  - Cada tier alcanzado en la oleada suma "puntos de racha". En la tienda se abre un pull extra: 1 carta por cada 2
    tiers. La calidad mínima sube con el tier más alto (tier 4+: calidad 3 o más; tier 7+: 4 o más).
- **Mejoras con tier:**
  - Calidades 1-2: valores normales.
  - Calidad 3: ×2 del valor base.
  - Calidades 4-5: valor fuerte; p. ej. daño de habilidad +10 / +15 / +25 / +40 / +50 %.
  - Las calidades 4-5 salen sobre todo del pull de rachas.
- **First blood:** la primera muerte de cada oleada (ya se detecta con `Racha_PrimeraRonda`) da a ese jugador una
  carta extra garantizada de calidad 3 en la tienda, de estadística, no maldita.
  - Alternativa: una sola vez por partida, como en Dota. Elegir antes de la fase 6.
- **Mejoras por tipo de arma:**
  - "Calibre": +15 % de daño a un tipo.
  - "Cargador ágil": −12 % de recarga a un tipo.
  - El tipo sale al azar entre los que tiene el jugador. Se suman al bono general.
- **Mejoras raras de habilidad** (calidad 5, sólo pull de rachas; usan el motor Missile sin tocar la biblioteca):

  | Héroe | Habilidad | Cambio |
  |---|---|---|
  | Naruto | RasenShuriken | 3 proyectiles; los 2 extra orbitan al principal y convergen en el destino (pedido de Leon) |
  | Naruto | Odama Rasengan | deja un remolino 2 s que atrae y daña |
  | Naruto | Kage Bunshin | cada clon lanza un Rasengan pequeño al aparecer |
  | Goku | Kamehameha | al final se abre en 3 rayos en abanico |
  | Goku | Spirit Bomb | al impactar suelta 4 bombas menores |
  | Goku | Warp Kamehameha | 2 teletransportes |
  | Freezer | Destructo Disc | vuelve como bumerán |
  | Freezer | Death Ball | deja un rastro que quema |
  | Freezer | Death Break | rebota a 2 enemigos |
  | Trunks | Burning Slash | 2 ondas cruzadas |
  | Trunks | Finish Buster | 3 en abanico |
  | Trunks | Heat Dome | atrae antes de explotar |
  | Tauren | Estampida | doble oleada |
  | Tauren | Lanza ancestral | atraviesa y vuelve |
  | Tauren | Tótem arrojado | rebota 2 veces |

  Una por habilidad como máximo. Se empieza por las que Leon elija.
- **Puntuación de la oleada (MVP):**
  - Fórmula: 1 por muerte + 5 por élite + 25 por el golpe final al jefe + 1 por cada 150 de daño + 3 por bolsa
    recogida − 20 por cada caída.
  - Se redondea a entero y el valor mínimo es 0.
  - Empates: gana quien tenga más daño.
  - El MVP recibe una carta extra de calidad 3-4 en la tienda.
  - Con un solo jugador activo sólo se muestra el MVP; el cuadro del contrario queda vacío.

## Fases (en orden; cada una es una entrega con letra nueva)

1. **v19t: sonido de votación, linterna ilimitada y baraja enemiga abajo.**
   - `ArrangedTeamInvitation.wav` al mostrar el ganador de la votación.
   - `Bat_T` sin gasto mientras no haya pacto.
   - Mover `Sup_Hud`/`Sup_Bg`/`Sup_TT` junto al minimapa (medir el hueco libre con una captura antes).
2. **v19u: auditoría y puesta en marcha de mutaciones y mejoras.**
   - Tabla x → efecto, archivo y función de cada mutación 0-17, de las súper élites y de las mejoras del héroe 20-39.
   - Implementar las que no hagan nada; prueba con registros que demuestre cada efecto (vida, velocidad, número).
   - Caparazón espinoso como carta "Espinas", con el tope descrito.
3. **v19v: cartas de Mutación Evo con la ventana de la tienda.**
   - Ventana como CuaPanel (texturas_v19r `ventana()`) y caja de descripción debajo.
   - Mismo flujo de votación.
4. **v19w: dash por cargas** (sin maná), HUD con icono y 2 texttags, y sus 4 mejoras. El bot usa las cargas.
   - Presupuesto de texttags: revisar el máximo con la tienda abierta (memoria `texttags-presupuesto`).
5. **v19x: Pacto de sombras y batería limitada** con las cargas y topes descritos, más "Pilas reforzadas" y "Recarga
   rápida".
6. **v19y: rachas, pull de racha, first blood, tiers fuertes y mejoras por tipo de arma.** Calibrar los umbrales con
   los registros de 2-3 partidas -prueba (muertes por oleada y por jugador).
7. **v19z+: mejoras raras de habilidad**, una o dos por entrega, empezando por RasenShuriken ×3.
8. **v20a+: resultado para 8 jugadores con puntuación y MVP.**
   - Cuadro más grande:
     - 8 filas: nombre, muertes, élites, daño, bolsas, caídas, estrellas y puntuación;
     - a la derecha, un cuadro vacío para el MVP y debajo otro para el contrario.
   - Secuencia, igual para todos (sincronizada; sólo texto y modelos locales):
     1. Por cada dato, 1,5 s de números aleatorios en los texttags de todos los jugadores activos, con el sonido de
        recoger bolsa, y luego el valor real.
     2. Para la puntuación, 2,5 s; a la vez, los cuadros MVP/contrario pasan rápido nombres y modelos de los héroes
        activos.
     3. Se fija el resultado: número del MVP en verde y del contrario en rojo, con el modelo y el nombre de cada uno.
     4. Poco después, `GoodJob.wav` y el MVP hace la animación de ataque una vez y queda en stand, con el anuncio de su
        recompensa.
     5. Luego `QuestFailed.wav` y el contrario hace la animación de muerte.
   - Modelos: unidades dummy con el modelo del héroe (sin billboard), colocadas como piezas HUD por distancia real; la
     muerte no debe dejar cadáver ni sonido 3D.

## Comprobaciones previstas

- Cada entrega: pJASS, reextracción por hash, bytes-diff y mpq verify (Validated); copia a Maps/Test y cmp.
- Efectos de mutaciones, dash, batería y rachas: registros Preload en -prueba (`lat/v19x-*.txt`) con valores medidos
  antes y después.
- Fases 4, 6 y 8 tocan HUD local y cartas extra por jugador: LAN de dos clientes antes de dar por buena la
  sincronización (memoria `pruebas-segun-local-player`).
- Rutas nativas por confirmar en el MPQ de 1.27b antes de usarlas: `Sound\Interface\ArrangedTeamInvitation.wav`,
  `Sound\Interface\GoodJob.wav`, `Sound\Interface\QuestFailed.wav`.

## Pendiente de Leon

- First blood: por oleada o una vez por partida.
- Qué mejoras raras de habilidad van primero.
- Qué irá en el hueco que deja la baraja enemiga ("algo adicional que diré luego").
- Confirmar o cambiar las cifras propuestas (pacto, batería, dash, rachas, fórmula del MVP).

## Registro de entregas

### v19t (19/11/2026): fase 1

- `scripts/v19t.py`, `hacer-v19t.sh`; sólo cambia war3map.j.
- Sonido `Sound\Interface\ArrangedTeamInvitation.wav` (confirmado en War3x.mpq, 2914 ms) en `Cua_MuestraEmpezar`, al
  mostrar el resultado de la votación. Rutas confirmadas también: `GoodJob.wav` y `QuestFailed.wav` en war3.mpq.
- Linterna ilimitada: `Bat_Limitada[p]` (falso para todos hasta el Pacto de sombras) controla el gasto en `Bat_Paso`, la
  barra y el texto de batería y que el controlador reciba 'Aw0A' (G, recargar).
- Baraja del enemigo (`Sup_Hud`): título a py 561 y filas a 610 + 62 k (antes 296 y 345 + 62 k).
- Mapas: v19t `04264a4a…`, v19t-prueba `efbf156c…`, copiados a Maps/Test (cmp). Validated (pJASS, reextracción del j,
  bytes-diff sólo j, attributes y listfile; mpq verify). Sin probar en el juego.
- Pendientes de esta fase:
  - Encaje real de la baraja sobre el minimapa.
  - Volumen del sonido.
  - El tutorial (`Tut_Bat*`) sigue enseñando la batería y la tecla G: Leon lo deja para un rework del tutorial.
  - El indicador de borde de tienda o jefe puede pasar por encima de la baraja abajo a la izquierda.

### v19u (19/11/2026): fase 2

- `scripts/v19u.py`, `hacer-v19u.sh`; sólo cambia war3map.j (sobre v19t y v19t-prueba).
- Auditoría (lectura del j de v19t):

  | x | Mutación | Dónde actúa | Estado |
  |---|---|---|---|
  | 0 Coloso, 1 Escolta, 3 Corona | jefe al salir | `Mut_Aparece` (después de `DevJefe_Aparece`) | con efecto |
  | 2 Furia | jefe a media vida | `DevJefe_Mirar` | con efecto |
  | 4 Ascenso | élites extra | `DevWave_Elite` → `Mut_Elites` | con efecto |
  | 5, 8, 9, 10, 12, 14-17 | comunes al salir | `Mut_Aparece` | con efecto |
  | 6 Élite feroz | élites al salir | `Mut_Aparece` | con efecto |
  | 7 Último aliento | élite al morir | `Mut_Muere` | con efecto |
  | 11 Horda, 12 Pocos | número de la oleada | `WaveAI__Init` | con efecto |
  | 16 Asalto inicial | intervalo de aparición | `DevWave_Start` | con efecto |
  | 13 Caparazón | tortugas +3 armadura y aura 'ANth' | `Mut_Aparece` | cambiada a Espinas |

  - La -prueba ya anotaba las unidades de cada mutación por oleada (`Mut_Anotar`) y tiene `-mut N` desde v18x.
  - Mejoras del héroe que salen en la tienda (`Her_Pool`: 18-23, 26, 27, 37, 38; malditas 28, 33-36; Purga 39):
    todas tienen consumidor (`Her_Dano`, `Bolsa_Coger`, imán, `Cur_Coger`, `Her_Sortear`, reembolso en la compra),
    salvo **Zancada (22)**: sumaba velocidad nativa, pero al héroe lo mueve `GroundMotion` a 350 fijos. 24 y 25 ya
    no salen (las técnicas 40-77 las sustituyen); 29 es la carta de refrescar.
- Cambios:
  - Zancada suma a `s__GroundMotion_speed` (`Her_Zancada[p]`, que `Game_Cuerpo` reaplica si cambia el cuerpo con -pj).
  - Caparazón espinoso (aura nativa 'ANth', que reparte espinas a los aliados cercanos) sale de la tirada de pasivas
    (`Sup_PaAzar`: 0-6 sin el 3), de la animación de barajar y de Corona / Élite feroz.
  - Carta 13 "Espinas": las élites que salen con ella devuelven al héroe del dueño del golpe el 8 % del daño por carta;
    tope 2 % de su vida máxima por golpe y 6 % por segundo (añadido mío para las armas rápidas); nunca baja de 1 de
    vida (`SetWidgetLife`). Un disparador `Esp_Tr` con las élites de la oleada, rehecho en `Cua_MuestraFin`. Las
    tortugas conservan +3 de armadura por carta, sin aura.
  - `Cua_MuestraFin` ya no dice "(aún sin efecto)".
  - La posición inicial de los textos de la baraja enemiga (Sup_Cargar / Sup_Barajar) sigue a la de v19t (561 y
    610 + 62 k).
  - Prueba: `Mut_Anotar` añade "espinas jN golpes total de vida-máx" por oleada; `Her_Log` lleva "vel N".
- Mapas: v19u `1254b9f9…`, v19u-prueba `ad724655…`, copiados a Maps/Test (cmp). Validated (pJASS, reextracción del j,
  bytes-diff sólo j y attributes; mpq verify). Sin probar en el juego.
- Cómo probarlo en la -prueba: `-mut 13` antes de una oleada con élites y golpearlas; elegir Zancada y comparar la
  carrera. Los registros caen en `CustomMapData/lat/v19u-bolsas.txt`.
- Observaciones sin cambiar:
  - Las ralentizaciones nativas de las pasivas Orbe de escarcha y Veneno lento tampoco frenan al héroe, por el mismo
    motivo que Zancada. Se puede hacer que GroundMotion las lea si Leon lo quiere.
  - Espinas no aparece como fila en la baraja enemiga de abajo: se ve como carta activa en los paneles de mutaciones.

### v19v (19/11/2026): fase 3

- `scripts/v19v.py`, `objetos_v19v.py`, `texturas_v19v.py`, `hacer-v19v.sh`; cambian j, w3b e imp; imports nuevos
  `CuaMutCarta.blp` y `CuaMutDes.blp`.
- Texturas con el método de texturas_v19r (ShopPanelL en nueve partes) y esquinas a escala para cuadros bajos:
  'DS1V' CuaMutCarta 270 × 250 (esquinas ×0,75, con gema) y 'DS1W' CuaMutDes 270 × 130 (×0,5, sin gema).
- `Mut_Hud`: ventana sin tinte en py 395, icono 360, nombre 478 (0,02), cuadro de descripción en 600 con `Cua_Des`
  a 0,016 alineado a la izquierda (cx − 112, py 588), título en 230; cartas a 290 px entre centros. Misma entrada y
  salida animadas.
- Los 3 textos de descripción por jugador (`Mut_DT`) se crean en `Cua_MuestraEmpezar` y se destruyen en
  `Cua_MuestraFin`: no ocupan texttags fuera de la muestra.
- Mapas: v19v `85244f42…`, v19v-prueba `ff40ba11…`, copiados a Maps/Test (cmp). Validated (pJASS, reextracción del
  j, w3b, imp y las 2 texturas; bytes-diff sólo esos; mpq verify). Sin probar en el juego.
- Pendiente de ver en el juego: alto real de los dos renglones de la descripción dentro del cuadro y que el nombre
  quede dentro de la ventana; posiciones estimadas, sin medir.

### v19w (19/11/2026): fase 4

- `scripts/v19w.py`, `objetos_v19w.py`, `hacer-v19w.sh`; cambian j, w3a y w3b; sin imports (iconos del juego).
- 'Ard1' sin coste de maná (amcs 0) y texto con las cargas. 2 cargas de base; vuelven de una en una, 6 s cada una
  (`Dash_Tick`, reloj común de 0,1 s). Sin carga: sonido de error y no sale; tampoco gasta si el cuerpo no está vivo.
  `Ronda_Reponer` llena las cargas como antes el maná.
- HUD: icono 'DC0N' (BTNBootsOfSpeed) 46 × 46 en (62, 276) bajo el arma, gris sin cargas; textos locales "xN"
  (0,022, x 92, y 256) y recarga "N.N s" (0,015, y 280). +2 texttags fijos por cliente.
- Mejoras: 24 Impulso extra (+1 carga, máx. 4), 25 Enfriamiento (−6/8/10/12/15 %, mín. 3,5 s), 78 Dash largo
  (+6/8/10/12/15 % distancia, máx. +36 %), 79 Dash veloz (−5/7/9/11/13 % duración, máx. −30 %); iconos DC0K–DC0N,
  etiqueta naranja "Dash". Salen por `Her_Pool[10]` (1 de 11 en las casillas de estadística), que elige al azar entre
  las que no están al máximo. 24 y 25 eran Pisotón / Onda de choque, fuera de la tirada. 78/79 excluidas del rango
  de técnicas en Her_Etiqueta, Her_TipoColor, Her_Des, Pan_HDes y Her_Aplicar.
- Bot (desactivado): cuenta cargas; ahora da "shockwave" a un punto (antes "thunderclap"/"stomp", que no son 'Ard1').
- Prueba: `Mut_Anotar` añade "dash jN usos sin carga F max rec" por oleada; `Her_Log` lleva dash/rec/dist/dur.
- Mapas: v19w `68c6decf…`, v19w-prueba `453f8423…`, copiados a Maps/Test (cmp). Validated (pJASS, reextracción del
  j, w3a y w3b; bytes-diff sólo esos; mpq verify). Sin probar en el juego.
- Pendiente de ver: posición de icono y textos (estimada), que el tutorial siga avanzando con 2 cargas.

### v19x (19/11/2026): fase 5

- `scripts/v19x.py`, `objetos_v19x.py`, `hacer-v19x.sh`; cambian j y w3b; iconos del juego 'DC0O' BTNShadowPact,
  'DC0P' BTNManaStone, 'DC0Q' BTNReplenishMana (confirmados en los listfiles de war3/War3x).
- Maldita 80 "Pacto de sombras" (una vez): +20 % de daño (Her_Filo) y +35 de velocidad de GroundMotion (+10 %);
  activa `Bat_Limitada`.
- Batería limitada:
  - el descanso suma 45 s hasta 100 en vez de llenarla;
  - al matar (`Racha_Muerte`, fuera del descanso) 1 s cada 12 muertes, tope 8 s por oleada;
  - sin G: decisión nueva, el controlador ya no recibe 'Aw0A' y el texto del HUD es sólo "Batería N%".
- Cartas con el pacto (hueco `Her_Pool[11]`): 81 Pilas reforzadas (gasto / (1 + 0,25 n), hasta 3) y 82 Recarga
  rápida (+50 % de ganancia y tope, hasta 2). Etiqueta amarilla "Linterna".
- Corrige Her_Etiqueta/Her_TipoColor de v19w: el rango de técnicas es 40-77.
- Prueba: `Mut_Anotar` añade "bat jN batería ganado pilas recarga"; `Her_Log` lleva pilas/recarga.
- Mapas: v19x `b9c65f42…`, v19x-prueba `7f69b445…`, copiados a Maps/Test (cmp). Validated (pJASS, reextracción del
  j y w3b; bytes-diff sólo esos; mpq verify). Sin probar en el juego.
- Pendiente: cifras por probar (duración real de una oleada frente a 100 s de batería).

### v19y (19/11/2026), fase 6: hecha (Validated)

- Rachas sin morir 40/90/150/220/300/390/490/600 (luego cada 100); multi-kill 12/22/35/55. Cada tier nuevo en oleada = 1
  punto; 1 pull extra cada 2 puntos (máx. 2), calidad mínima T2 / T3 (tier 4+) / T4 (tier 7+).
- First blood: pull extra T3+ sin malditas ni Purga; por oleada (`Her_FB_CADA_OLEADA = true`; false = una por partida).
  Leon eligió por oleada (19/11/2026).
- Pasos extra de cartas del héroe (`Her_FinDe`), cartas en p*40, `Cua_Elegido` p*12.
- Tiradas normales hasta T3 (garantía T3); T4-T5 sólo en pulls extra. Tiers fuertes ×1/1,5/2,5/4/5 en 20, 21, 22, 23,
  26 y 38.
- 83 Calibre (+10..50 % daño de un tipo), 84 Cargador ágil (−8..40 % recarga, tope 60 %, sin cuerpo a cuerpo); iconos
  DC0R BTNHumanMissileUpThree y DC0S BTNAmmoDump.
- Prueba: `pulls ronda N; jP extra E fb F pts N max T` en el registro de la bolsa.
- v19y `9680bf34…`, v19y-prueba `321e51bc…`; pJASS ok, reextracción y verify ok, copiados a WOE (cmp ok).
- Sin probar en el juego: flujo de los pasos extra y refresco, umbrales sin calibrar, balance de tiers.

### v19z (19/11/2026), fase 7: primera rara (Validated)

- 85 "Shuriken triple" (Naruto con RasenShuriken aprendido, una vez): 2 shuriken más (h0D2) giran alrededor del
  principal con radio de 260 a 40 durante los 50 pasos de vuelo y se juntan con él en 0,24 s al explotar. Cada extra
  hace el 50 % del daño de vuelo una vez por enemigo; la explosión pasa a +50 %. Código: Rs_Lanzar / Rs_Paso /
  Rs_Quitar, desde NaF_Fg7 y el motor NaF_Fl7 (una instancia, como NaV_*).
- Sólo en pulls de racha, cuarta casilla, T5: 45 / 60 / 75 % según la calidad mínima. Etiqueta "Rara".
- Prueba: `rasen triple 1 golpes extra N` al acabar cada explosión.
- v19z `e7b05df1…`, v19z-prueba `6f04c4b8…`; pJASS ok, reextracción y verify ok, WOE cmp ok. Sin probar en el juego.

### v20a (19/11/2026), fase 8 primera parte: tabla de 8 y MVP (Validated)

- Piezas 'DSP4' PuntTabla (tabla, x 805) y 'DSP5' PuntLado (MVP y menos puntos, x 1265); puntos_v20a.py.
- Datos nuevos: Mvp_Elites, Mvp_Jefe (golpe final), Mvp_Dano (disparador EVENT_UNIT_DAMAGED por oleada con cada
  unidad que aparece, daño hasta la vida restante).
- Puntos con la fórmula del plan; MVP y menos puntos (este sólo con 2+ jugadores); recuento de 1,5 s por columna con
  ReceiveGold.wav, puntos 2,5 s, GoodJob.wav y QuestFailed.wav. El cuadro dura unos 15 s más que antes.
- Recompensa: pull extra T3-T4 "MVP · TN+" (Her_ExTipo 2), sólo con 2 o más jugadores.
- Texttags del cuadro: 7 → 15 por cliente (+8). Falta medir el total con la tienda abierta.
- Prueba: `mvp ronda N gana F pierde F; jP b e d o c jefe pts`.
- v20a `f4d40861…`, v20a-prueba `e9e00200…`; pJASS ok, reextracción y verify ok, WOE cmp ok. Sin probar en el juego.
- Probado por Leon (v20a-prueba, 19/11, un jugador, Tauren, hasta la oleada 10): tabla y MVP se ven; ver v20b.
- Los modelos de los héroes en los cuadros MVP / menos puntos pasan a v20c.

### v20b (20/11/2026): correcciones de la prueba de v20a (Validated)

- Pantalla de inicio sin nombres ni descripciones unos 4 s al volver de la tienda con Esc (vídeo, oleada 9 → 10).
  Fallaron justo los 10 últimos texttags que crea Cua_Textos (Cua_TN/TD): patrón del tope de 100. Ahora los 15
  textos del cuadro de resultados existen sólo mientras se ve (Punt_TxPoner / Punt_TxQuitar): 15 libres en descanso
  y tienda. Informe: informes/errores/2026-11-20-001752-devmission-inicio-sin-textos-tope-texttags.md.
- Cartas de técnica viejas: el vídeo muestra "Tótem arrojado · Ya está al máximo (nivel 3)" en first blood y en el
  pull de racha; el registro, Tótem arrojado elegido 3 veces en la ronda 9. Her_AlDia revisa las cartas al abrir
  cada paso (técnica al máximo o repetida → otra técnica o carta común; rara ya aprendida → común; nivel al día).
- Puntos: daño / 1000 (en la ronda 9, 241 580 de daño daba 1610 de 1999 puntos).
- Aviso de oleada: "Mejoras del héroe:" sin "(aún sin efecto)".
- Prueba: el diagnóstico de cuadros anota los ids de sus texttags y se lanza también al ir y volver de la tienda.
- v20b `91860dec…`, v20b-prueba `5de22590…`; pJASS ok, reextracción y verify ok, WOE cmp ok. Sin probar en el juego.
- Rachas: rachas (en la prueba hubo 3 pulls extra en cada oleada: first blood y 2 de racha con 4-15 puntos). Leon pidió endurecerlas: v20c.

### v20c (20/11/2026), fase 8 segunda parte y rachas más difíciles (Validated)

- Modelos: al fijarse el resultado, copia del personaje del MVP (y de quien menos, con 2+ jugadores) en su cuadro:
  unidad del mismo tipo que el personaje, del jugador de cámara, Locust, invulnerable, sin Aatk, forma voladora; una
  por jugador y cuadro, colocada con HealthBars__Place (x 1345, y 352 / 585, distancia 360), escala 0,40, giro 290,
  sólo visible para su jugador. GoodJob → ataque y stand; QuestFailed → muerte, congelada a 1,2 s; se quitan al
  acabar el cuadro (Mvp_ModQuitar en Punt_TxQuitar). Constantes MVP_MOD_* para calibrar.
- Cambio respecto al diseño: durante los 2,5 s sólo pasan los nombres; los modelos aparecen al fijarse (pasar modelos
  exigiría una unidad por jugador, cuadro y personaje, hasta 128).
- Rachas: multi-kill 15/28/45/70; el multi-kill da punto sólo la primera vez que alcanza cada tier en la oleada
  (Racha_MultiOla); un pull extra cada 3 puntos (máx. 2).
- Prueba: `mvp modelos ronda N gana T pierde T` (tipos de unidad) en el registro de la bolsa.
- v20c `cfd5df6e…`, v20c-prueba `ceb76fbc…`; pJASS ok, reextracción y verify ok, WOE cmp ok. Sin probar en el juego:
  tamaño y encuadre de los modelos, animaciones de los héroes D.O.N, si queda sonido de muerte del modelo.
- Con v20c quedan hechas todas las fases del plan; falta probarlas.

### v20d (20/11/2026), modelos del MVP corregidos (Validated)

- Prueba de Leon con v20c (vídeo 20261120_003930, un jugador): el modelo del MVP salía negro, demasiado grande y se
  salía del cuadro por la derecha y por abajo (encima de "MENOS PUNTOS").
- Causa del negro: la noche fija de Dark Nights (luz 0,05) sólo deja ver unidades cerca de la luz del héroe; el modelo
  está junto a la cámara, lejos de toda luz. Cada modelo lleva ahora MvpLuz.mdx (de BatLuz5: alcance 0-500, pivote
  Z 150, intensidad 700, ambiental 3, Death para apagarse al momento; `scripts/luz_mvp.cjs`), creada sólo en el
  cliente que lo ve. Con el cuadro abierto hay como mucho 2 luces más (límite de 8).
- Escala 0,40 → 0,22; x 1330; pies a y 290 (MVP) y 522 (menos puntos).
- v20d `4e0861d3…`, v20d-prueba `9616daea…`; pJASS ok, reextracción de j y MvpLuz ok, verify ok, WOE cmp ok.
  Sin probar en el juego: brillo de la luz (puede quedar corto o quemar), encuadre con escala 0,22.

### v20e (20/11/2026), encuadre del modelo del MVP (Validated)

- Prueba de Leon con v20d (vídeo 20261120_005241, un jugador): el modelo ya se ve iluminado, de buen tamaño y dentro
  del cuadro; el ataque se reproduce. Se veía de espaldas (el tótem de Tauren.mdl tapaba el cuerpo) y con el ataque
  asomaba por el borde de arriba.
- Giro 290 → 110; pies 30 px más abajo (y 320 MVP, 552 menos puntos).
- v20e `4e3e884b…`, v20e-prueba `ca0a7c63…`; pJASS ok, reextracción y verify ok, WOE cmp ok. Sin probar en el juego.
  Pendiente con 2+ jugadores: cuadro de menos puntos, animación de muerte, héroes D.O.N.

### v20f-prueba (20/11/2026), calibración del modelo del MVP (Validated, sólo prueba)

- Vídeo de v20e (20261120_005724): ya no tapa el tótem, pero se ve de lado y desde arriba. Leon quiere que mire de
  frente y pidió quitar las oleadas para ajustarlo.
- Sin oleadas (Ronda_Lanzar no llama a DevWave_Start). Comandos: -mvp (cuadro fijo con el modelo), -giro N,
  -escala N, -mvpx N, -mvpy N, -anim NOMBRE; muestran los valores en pantalla y valen también para el cuadro real.
- v20f-prueba `7587b6bb…`; pJASS ok, reextracción y verify ok, WOE cmp ok. La normal sigue siendo v20e.
- Siguiente: con los valores que elija Leon, v20g normal y prueba con oleadas.

### v20g (20/11/2026), valores del modelo del MVP (Validated)

- Elegidos en la partida de v20f-prueba de Leon (comandos enviados a su ventana, capturas con Spectacle): barrido de
  giro 0-330 cada 30; de frente a 240 (cara, aro de la nariz y pecho; tótem detrás). x 1310, pies a y 300 (menos
  puntos 532), escala 0,22.
- v20g `0f59e0d4…`, v20g-prueba `00e82f62…`; pJASS ok, reextracción y verify ok, WOE cmp ok.
- Queda (Leon): el modelo se ve inclinado, como mirando hacia abajo, porque la cámara de juego lo mira desde ~45-55°
  por encima. El giro no lo arregla; hace falta inclinar el modelo hacia la cámara (copia del MDX con el nodo raíz
  rotado y tipo de unidad propio por héroe, como los retratos de la tienda).

## v20h-prueba (20/11/2026): Tauren inclinado para elegir el ángulo

- Warcraft 1.27b no inclina unidades desde JASS: copias del MDX inclinadas hacia atrás (cabeza alejándose de la
  cámara) con `scripts/inclinar_mvp.cjs`. Sin nodos nuevos: la rotación fija se compone en cada nodo raíz (19 en el
  Tauren); raíces sin pista reciben una pista constante en una secuencia global nueva; pistas por secuencia sin claves
  en alguna secuencia, claves con el valor por defecto. Comprobado con la pose completa: 10 secuencias × 3 instantes,
  17 130 vértices, desviación máxima 0,00003 respecto de R0 × original. Roundtrip MDX/MDL del ModelEditor correcto.
- Base: `Units\Orc\Tauren\Tauren.mdx` de war3.mpq (sha256 eae59ad2…). Copias `mvp-incl/t/MvpTauren25/35/45/55.mdx`.
- Objetos: 'hMv2' 'hMv3' 'hMv4' 'hMv5' (copias de 'h005', uabi vacío). `objetos_v20h.py`.
- `v20h.py` sobre v20f-prueba con giro 240, x 1310, y 300 (v20g) y el comando `-incl N`; `hacer-v20h.sh`.
- v20h-prueba `6af059ed21bee6e2750b271dd8e8999cd551d1befc5b724ad7609a33da061ed0`. pJASS, reextracción de j, w3u,
  imp y los 4 MDX, mpq verify: correctos. Copiado a WOE (cmp).
- Pendiente: elegir el ángulo en la partida; después inclinar los 7 modelos de héroe a ese ángulo, tipos MVP por
  héroe y entrega normal + prueba con oleadas.

## v20i-prueba (20/11/2026): modelos del MVP de frente, como el retrato de las rachas

- Leon: "¿no lo puedes ajustar el modelo a nivel de los portraits?". El retrato de las tarjetas de racha
  (RetratoTauren.mdx) no está inclinado a mano: cuelga de un hueso Billboarded (PortraitBillboard) y sus capas no tienen
  sombra ni niebla. `scripts/mvp_frente.cjs` hace lo mismo con el modelo entero: hueso nuevo "MvpFrente" (ObjectId 0,
  Billboarded, pivote en los pies) del que cuelgan todas las raíces; el resto de ids sube 1; capas 1|32. El giro de la
  unidad deja de contar.
- Siete copias en `mvp-frente/` (bases en `mvp-frente/base`, sacadas de war3.mpq y del mapa): Tauren, Cairne, Goku,
  Freezer, Trunks, Naruto, Kyuubi. Cairne tenía 1 nodo con "no heredar": se quita (rompería con el billboard, como el
  NoseRing del retrato). Pose sin billboard igual al original en todas las secuencias (desviación 0).
- Tipos 'hMf0'..'hMf6' (copias de h005, h006, hGok, hFrz, hTrk, hNar, hNaK; uabi vacío). `-frente` alterna; pies a
  y 345 (de frente se ve todo el alto).
- v20i-prueba `cf44ec6ed49963b02e6e2736abf94d768c153b3db667ab99733ede3e3e841a8c`: pJASS, reextracción de j, w3u, imp y los
  7 MDX, mpq verify correctos; copiado a WOE.
- Sin probar en el juego. Riesgos: la animación de muerte cae hacia atrás, lejos de la cámara, y puede verse corta;
  alturas distintas por personaje (145-245) con una sola escala.
- Si se acepta, la entrega normal + prueba con oleadas usará estas copias (Mvp_Modelo con el tipo de frente).

## v20j-prueba (20/11/2026): ajuste en la partida de Leon

- En v20i-prueba (partida de Leon, ajustado por chat con su permiso): de frente y de pie, pero corrido a la derecha y
  pequeño. Con -mvpx 1262, -escala 0.27, -mvpy 362 queda centrado y más grande (captura). El Tauren sigue con la
  cabeza agachada: es la postura de su stand, no la cámara.
- v20j-prueba sobre v20i-prueba: escala 0.27, x 1262, y 358; 'hMg1'..'hMg3' = Tauren inclinado 10/20/30° y después
  billboard (`mvp-frente/incl`); `-incl 10|20|30` con -frente activo.
- v20j-prueba `e91006810669ebfc38bb50f043a7773d02a2b429c9bcd36addff3c18b706a0c6`: pJASS, reextracción, mpq verify
  correctos; WOE. Sin probar en el juego.

## v20k-prueba (20/11/2026): inclinación con el método del retrato

- En la partida de v20j las copias 'hMg1'..'hMg3' no se vieron y desde la primera el cuadro dejó de dibujar modelos
  (informe `informes/errores/resueltos/2026-11-20-013609-devmission-mvp-copias-inclinadas-invisibles.md`).
- `mvp_frente.cjs ENTRADA SALIDA GRADOS`: ayudante `MvpVista` (giro fijo, secuencia global de dos claves) bajo el
  hueso billboard; las raíces cuelgan de él; pistas del original intactas. Sin grados, idéntico byte a byte a v20i.
- v20k-prueba `1f9804079e292654e2f35737de80c283ca225ea143135ed218b9d90954802f12`: sólo cambian el j (prefijo de
  registros) y los tres MDX `MvpFrenteTauren10/20/30`; pJASS, reextracción y mpq verify correctos; WOE. Sin probar.

## v20l (20/11/2026): entrega con los modelos de frente

- Leon comparó en v20k-prueba y eligió 0° ("usemos 0"): copia de frente sin inclinar.
- `v20l.py` sobre v20g / v20g-prueba: `Mvp_TipoFrente` ('h005'→'hMf0' … 'hNaK'→'hMf6'; otro tipo, el suyo), escala
  0,27, x 1262, pies a y 358 (MVP) y 590 (menos puntos). Objetos con `objetos_v20i.py`; 7 MDX de `mvp-frente/`.
- v20l `b606d6206274c6e9e03f7b7c7a132801f70d135076d7a825c1f3dbbe8bd0d435`, v20l-prueba
  `a6a03a32d3fbb9e25f176d465e637b0d6ffb04ea2c0a684c6edc0321922ef0dd`: pJASS, reextracción de j, w3u, imp y 7 MDX,
  mpq verify correctos; WOE.
- Tested in map (calibración v20i/v20k): Tauren de frente con -mvp. Sin probar: el cuadro real al acabar la oleada,
  los otros 6 personajes, la animación de ataque y la de muerte (cae hacia atrás, lejos de la cámara), multijugador.

## v20m (20/11/2026): piezas de forma en el modelo del cuadro MVP

- Leon: "cuando salia goku no se mostraba su cabeza". Causa comprobada: `Goku_squished.mdx` es sólo el cuerpo (pose
  Stand dibujada de frente: termina en el cuello). La cabeza es arte de habilidad de objeto en `head`: A069 normal,
  A06A SS, A06B SS3, A0JO SS4. Igual Trunks (A07X cabeza, A03Z espada en `hand right`) y Naruto (A0AO ojos en
  `origin`). Las copias `hMf*` tienen `uabi` vacío, así que salían sin piezas (también en v20c–v20g con el tipo real,
  porque la copia se creaba sin las habilidades que el héroe recibe por script).
- `scripts/v20m.py`: `Mvp_Pieza`/`Mvp_Piezas` pegan las piezas que tenga el héroe en ese momento con
  `AddSpecialEffectTarget`, modelo sólo en el cliente de p (como la luz de v20d), hasta 3 por modelo en `Mvp_Pz`;
  `Mvp_ModQuitar` las destruye. Las auras de forma (A0G4, A00Y, A0HX) no se copian.
- `hacer-v20m.sh`: base v20l / v20l-prueba por hash, sólo cambia el j. pJASS correcto, reextracción del j igual,
  bytes-diff sólo `(attributes) (listfile) war3map.j`, `mpq verify` correcto. Los seis modelos de pieza están dentro
  del mapa (extraídos de v20m).
- v20m `ea8d9ffee40f…`, v20m-prueba `c23f4477e6eb…`; copiadas a WOE, cmp correcto.
- Sin probar en el juego: Goku con su cabeza en cada forma, Trunks, Naruto, ataque/muerte con piezas, multijugador.

## v20n (20/11/2026): escala del modelo MVP por altura

- Revisión de los siete modelos de frente en Stand con sus piezas (render propio de la pose, no del juego): Goku,
  Freezer, Trunks, Naruto y Kyuubi completos; Cairne lleva su brillo de héroe (equipo, alfa 0,75), igual que el héroe.
- Alturas: Tauren 165, Cairne 202, Goku 197-204, Freezer 144, Trunks 194, Naruto 248, Kyuubi 127. Según la captura de
  v20k caben ~180 unidades a 0,27 entre los pies y el título: Naruto se salía y Goku/Trunks/Cairne tapaban el título.
- `scripts/v20n.py`: `Mvp_Escala` = 0,27 × 175 / altura para h006 (0,234), hGok (0,232), hTrk (0,244), hNar (0,191);
  el resto 0,27. `hacer-v20n.sh` sobre v20m / v20m-prueba: pJASS, reextracción, bytes-diff sólo el j, verify.
- v20n `c899513c2f73…`, v20n-prueba `109eb746e88d…`; WOE cmp correcto. Sin probar en el juego.

## v20o (20/11/2026): recuento de la tabla MVP más rápido

- Leon: "aceleremos un 50 la velocidad de contador o animacion de resultados del mvp".
- `scripts/v20o.py`: `MVP_PASO` 1,0 (antes 1,5) por columna; ruleta de nombres desde 5 × paso (antes 7,5); resultado
  fijo a paso × 10 / 1,5 = 6,67 s (antes 10). Sonidos de columna con el mismo paso. Tras fijarse no cambia (ataque
  +0,5, muerte +2, congelado +3,2, salida +5). El recuento de puntos previo (bolsas, caídas, estrellas) no cambia.
- `hacer-v20o.sh` sobre v20n / v20n-prueba: pJASS, reextracción, bytes-diff sólo el j, verify.
- v20o `f411ede03c14…`, v20o-prueba `1964478019a4…`; WOE cmp correcto. Sin probar en el juego.

## v20p-lan (20/11/2026): LAN rojo y morado con vidas infinitas

- Leon aceptó v20o ("anda correcto todo") y pidió una LAN de dos jugadores, rojo y morado con hueco entre ellos, y vida
  infinita para probar mejor.
- `scripts/v20p.py` sobre v20o: `Vidas_INICIO` 99 y caer no resta (aviso "infinitas en la LAN"); sin registros.
- `hacer-v20p.sh`: pJASS, reextracción, bytes-diff sólo el j, verify; `v20p-lan/map.cfg` generado con
  ydhost_mapcfg.py y slots 2-3 (azul, verde azulado) cerrados, así el segundo jugador entra como morado (id 3).
- `scripts/lan-v20p.sh`: el lanzador de lan-v18z con el mapa nuevo (ydhost con autostart 2, dos clientes YDWE,
  espacios 6 y 7, devuelve ydhost.cfg y map.cfg al cerrar).
- v20p-lan `04af064c5950…`. Sin probar: carga con dos, hueco de slots, sincronía.
- Prueba de Leon (20/11/2026, LAN en esta PC): ydhost con slots 2-3 cerrados, dos uniones, carga con 2 a las 17:45:45;
  ~19 min de partida; salidas a las 18:04:28 y 18:05:00 (cierre normal), sin desincronización ni desconexión en el
  registro de ydhost. El lanzador devolvió ydhost.cfg y map.cfg. Leon: "test listo".
