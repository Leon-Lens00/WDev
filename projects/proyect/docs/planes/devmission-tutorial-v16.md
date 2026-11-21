# Dev Mission: tutorial guiado (serie v16)

Estado: **Designed** (07/11/2026). Base: v14zy (`TerrainDev-Titulo-v14zy.w3x` d62460ab…). Classic 1.27b, JASS.
Las versiones v15a–v15c ya se usaron como prototipos experimentales: el tutorial va en v16a, v16b…

## Objetivo (guion de Leon, 07/11/2026)

Un tutorial que se ve como un vídeo: todo a puro script, sin ninguna acción del jugador, una sola instancia (la misma
cámara y las mismas piezas para todos). Al terminar, un fundido lleva a la partida real.

1. Fundido desde negro; el Tauren entra caminando a cámara en un terreno plano y se detiene.
2. Abajo a la izquierda, el retrato del Tauren con su panel: saluda, da la bienvenida a «Proyect Dev Us» y dice que
   ayudará a entender las mecánicas.
3. Habilidades base en la zona de habilidades (abajo a la derecha). Para cada una: fondo negro translúcido con un
   círculo de foco; el icono y el foco se mueven al centro; el narrador explica con texttag.
   - A (atacar/disparo): un cursor con la textura del cursor del juego lanza a 3 puntos al frente (arriba, centro,
     abajo); luego explica que se puede mover mientras sale el proyectil.
   - Cambio de arma: la misma A con otra arma (escopeta) para mostrar que cambia.
   - Recargas.
   - Dash. La linterna, de momento no.
   - Durante la muestra, la barra de vida, de arma y de oleada como en la partida, enfocadas con el fondo.
4. Oleadas: 5 enemigos básicos; foco en el número de oleada y enemigos restantes (a la derecha de la barra de vida);
   cómo bajan; el jefe sale al matar a todos y llama refuerzos; se muestra el indicador de jefe con una demostración.
5. Tienda: foco en el indicador del golem; la unidad sube hasta la zona del golem; cómo abrirla; dentro, con el cursor,
   cómo comprar, recargar balas, los tiers y lo demás; cómo salir.
6. Cajas verdes: «¿Te quedaste sin balas durante la oleada?». Al acercarse y pulsar ESC recarga un cartucho y añade un
   stack; cada jugador tiene su activación independiente.
7. Desea suerte; fundido a la partida real.

## Decisiones técnicas propuestas (del agente, pendientes de visto bueno)

- Sitio: franja norte, llana (altura 8518, `Zvin`), libre fuera de X −1500..4500 (menús y tienda). Tutorial en
  X 6000..10000, Y 7500..9500: abrir pathing (wpm), suelo propio, golem y caja verde de muestra, visibilidad con un
  modificador limitado a ese recuadro (no todo el mapa: recuadro negro en el minimapa).
- Una instancia: control del usuario desactivado y selección vacía para todos; cámara fija igual para todos. Las piezas
  son unidades de interfaz `uids` (lejos de X 0 `uidb` se pone de canto) visibles para todos; nada local salvo lo ya
  local del HUD real.
- La consola del juego (barra de abajo, tarjeta de órdenes) se dibuja encima del mundo: el fondo oscuro y las piezas no
  pueden taparla ni ir debajo de ella. Los iconos salen justo encima de la tarjeta de órdenes, o se oculta la interfaz
  con el modo cinemático (franjas negras). A decidir con una captura.
- Cursor: textura del cursor del juego recortada a una potencia de dos, en una pieza que se mueve por script.
- Narrador: tarjeta como la de rachas, más grande, con texto que se escribe letra a letra y voces del Tauren.
- Oleada, jefe y tienda de muestra: el estado de la partida real (oro, armas, rondas) no se toca, o se restaura antes
  del fundido final. La tienda real es local por jugador; se abre para todos a la vez con clics de script.

## Fases

| Fase | Entrega | Comprobación |
|---|---|---|
| v16a | terreno del tutorial, entrada (fundido, Tauren caminando), narrador, foco, cursor, salida a la partida | registro de pasos y capturas |
| v16b | capítulo de habilidades (A, escopeta, recargas, dash) con HUD enfocado | capturas por paso |
| v16c | capítulo de oleadas y jefe | registro de la oleada de muestra |
| v16d | tienda, cajas verdes, despedida; estado real intacto | registro del estado antes y después; LAN de 2 |

## Preguntas abiertas

- ¿Cómo se entra: rombo «Tutorial» en la pantalla de modo, o siempre antes de la primera partida?
- Nombre exacto del saludo: «Proyect Dev Us».
- Consola: iconos sobre la tarjeta de órdenes o modo cinemático.

## v16a construido (08/11/2026)

Base `TerrainDev-Titulo-v14zy.w3x` (j comprobado con `cmp`). Fuentes: `scripts/terreno_v16a.py`,
`objetos_v16a.py`, `tutorial_tex_v16a.py`, `v16a.py`, `prueba_v16a.py`, `hacer-v16a.sh`; lanzadores
`entrar-v16a.sh` y `entrar-v16a-prueba.sh`.

- Terreno: 312 vértices de baldosa Ztil (X 6400..9600, Y 7700..9300) y 7750 celdas wpm abiertas (X 6000..10000,
  Y 7500..9500); alturas sin tocar.
- Objetos: DS1A TutFoco, DS1B TutPanel, DS1C TutMano, DS1D TutMira y DS1E con `BTNFireBolt.blp` del juego.
- Guion de 20 fases a 0,02 s: fundido, Tauren entra, panel con retrato, saludo «Proyect Dev Us», consola como
  referencia, icono A con foco hasta el centro, cursor que pulsa, mira a 3 blancos, «moverte mientras disparas»,
  suerte, fundido y entrada a la partida (como la entrada directa). Disparos provisionales (explosión en el blanco).
- `TerrainDev-Titulo-v16a.w3x` 9a410b55…, `-prueba` 467f1138… (notas en `CustomMapData/lat/v16a-1.txt` al terminar).

Estado: **Validated** (pJASS, reextracción por hash del j, w3e, wpm, w3b, imp y las 4 BLP, `mpq verify`).
Sin probar en el juego: encuadre de cámara, tamaño y posición del panel, renglones y fuente, foco y cursor.
Siguiente: Leon prueba `entrar-v16a-prueba.sh`; ajustar con sus capturas y el registro; luego v16b.

## Prueba de v16a y v16b (08/11/2026)

Vídeo de Leon `~/Vídeos/recording_2026-11-08_00.24.22.mp4` y registro `lat/v16a-1.txt`: las 20 fases corren
(fin a 37,4 s), el texto a máquina y los acentos salen bien, el foco con el icono en el centro y la mira se ven.
Fallos: (1) panel, retrato y el icono junto a la consola no se ven: piezas fuera de la visión, tapadas por la máscara;
(2) el Tauren vuelve hacia donde nació (acaba en X 7473); (3) cámara lejana, Tauren muy pequeño.
v16b (`scripts/v16b.py`, `hacer-v16b.sh`, sólo cambia el j): visión hasta Tut_Y - 2000 y visión compartida con el
dueño de las piezas, `RemoveGuardPosition`, cámara a distancia ~1610. `v16b` ecdb32e5…, `v16b-prueba` 8e9670ec….
Estado: **Validated**; pendiente de probar en el juego. Las fases de contenido (habilidades, oleadas, tienda) siguen
siendo las del plan, con letras a partir de la siguiente libre.

## v16c: consola 3 × 4 (08/11/2026)

La captura que mandó Leon era de v16a (el registro presente era `v16a-1.txt` y el encuadre coincide), así que v16b
sigue sin probar. Cálculo con la cámara: en v16a el panel caía en Y≈6847, fuera de la visión (desde 7000); en v16b,
en Y≈7530, dentro. Pedido de Leon: los iconos salen en la zona marcada, sobre la consola a la derecha, como la
cuadrícula nativa de 3 × 4. v16c (`v16c.py`, `objetos_v16c.py` DS1F..DS1N, `tutorial_tex_v16c.py` TutCasilla):
casillas e iconos en su sitio nativo (abpx/abpy del w3a) que entran desde la derecha mientras el Tauren las nombra,
quedan detrás del foco y salen al pasar a la mira; el Disparo (0,1) se ilumina y va al centro.
`v16c` 7c1b31c8…, `v16c-prueba` 93e126e4… (notas en `lat/v16c-1.txt`). Estado: **Validated**.

## Prueba de v16c y v16d (08/11/2026)

Vídeo `~/Vídeos/recording_2026-11-08_00.33.49.mp4` y `lat/v16c-1.txt` (20 fases, fin a 37,0 s): el panel con retrato,
la consola 3 × 4 (entra, queda bajo el foco, el Disparo va al centro) y la mira se ven. Fallos: el Tauren llega al
centro y a los ~6 s vuelve a la izquierda (acaba en X 7475; RemoveGuardPosition no basta) y no suena nada.
v16d (`v16d.py`, sólo el j): el Tauren camina por guion (SetUnitX/Y, walk/stand) con SetUnitPropWindow 0; los cinco
sonidos se precargan en silencio con Racha_Registrar. `v16d` 3c58408c…, `v16d-prueba` 487435cc…. **Validated**.
Por mirar: el retrato del panel cambia mucho de encuadre según la animación (cara, armadura, tótem).

## Prueba de v16d (08/11/2026): **Tested in map** (un jugador, Leon)

Vídeo `~/Vídeos/recording_2026-11-08_00.37.20.mp4` y `lat/v16d-1.txt`: 20 fases, fin a 37,0 s, Tauren en (8000, 8300)
al terminar (ya no se va). Se ven panel, consola 3 × 4, foco, mira y las explosiones; tras el fundido entra a la
partida de noche. Audio del vídeo: sonidos en 5,7 s (What1), 10,7 (clic), 14,1 (clic), 17,6-20,0 (Ready1),
22,4-26,1 (clics y disparos), 28,1-29,8 y 30,2-31,0 (Yes3), en línea con las fases del registro.
Sin probar: multijugador (escena compartida, cámara aplicada a todos). Siguiente: fase de habilidades del plan.

## v16e: habilidades reales, HUD, recarga, escopeta y dash (08/11/2026)

Pedido de Leon tras v16d: el Tauren usaba una animación y una explosión, no las habilidades; que dispare de verdad,
se vea el movimiento artificial con su efecto y siga la fase. v16e (`v16e.py`, `objetos_v16e.py` DS1O BTNLoad,
`prueba_v16e.py`, `hacer-v16e.sh`; del mapa v16d cambian j y w3b):
- El Tauren es una pareja real (`Game_Cuerpo`) del hueco `Tut_P` (el primero sin jugador desde el 7; con 8 jugadores
  se entra directo sin tutorial), con escopeta T1 además de las armas base y los colores del primer jugador. El guion
  da las órdenes del juego al controlador, una por fase: `smart`, `carrionswarm` (A), `stomp` (F, Recarga, abpx 1,1),
  `avatar` (R, Escopetas) y `shockwave` (D, Dash, con maná repuesto). Si una orden no entra, llama a lo mismo que la
  habilidad y lo anota. Al terminar (`Tut_Soltar`) se destruye la pareja y se restablecen armas, vidas y luz del hueco.
- Fases nuevas 14..37 (45 en total): HUD bajo el foco (vida, arma y balas, oleada; foco a 398, delante del HUD y
  detrás del panel), recarga con F (la consola vuelve con el botón de Recarga), moverse mientras dispara (dos órdenes de
  mover durante la ráfaga: Windwalk en los pies), cambio a la escopeta con R y su ráfaga, dash con D a la derecha y de
  vuelta. Despedida ajustada ("verás las oleadas y la tienda"). La linterna queda fuera.
- HUD del tutorial: piezas y textos para todos (hbhr, hbi0, icono de categoría, nombre, balas que bajan y
  "Recargando", "Wave 1" / 30). Son 5 texttags más, que se destruyen antes de entrar a la partida.
`v16e` fb36f702…, `v16e-prueba` bb2330bc… (notas en `lat/v16e-1.txt`: fases, órdenes y estado de la pareja cada
0,5 s desde el primer disparo). Estado: **Validated** (pJASS, reextracción por hash, mpq verify). Sin probar en el
juego: que el controlador acepte cada orden, la colocación del HUD y de los focos, y la consola con el botón nuevo.

### Prueba de v16e (08/11/2026): **Tested in map** por registro (un jugador, Leon)

`lat/v16e-1.txt`: 46 fases (0..45), fin a 66,3 s, sin ninguna orden rechazada (el controlador aceptó smart,
carrionswarm, stomp, avatar y shockwave). Disparo: 24 tiros de MP18 (32 → 8) con movimiento artificial y pies activos
mientras dura la ráfaga. Recarga a 38,2 s, termina a 40,5 (2,2 s): 8/320 → 32/296. Disparando en marcha: el Tauren va a
Y 8630 y vuelve a 8258..8300 con art 1 y pies 1, 21 tiros más. Escopeta: arma 4, 6/60 → 0/60 (6 disparos). Dash: 2,
efecto del dash activo, X 8000 → 8449 → 7999, maná 5 → 4 y se repone. Tauren al final en (8000, 8300).
Vídeo de Leon (`recording_2026-11-08_00.57.11.mp4`, 66,3 s, coincide con el registro): se ven proyectiles reales,
Windwalk en los pies al moverse, "Recargando 1.7 / 0.7" y luego 32/296, la consola con el icono BTNLoad en la casilla
de Recarga, el cambio a Trabuco T1 6/60 con sus perdigones y el dash con su efecto rojo. HUD (vida, "MP18 T1 8/320",
"Wave 1" / 30) y oscurecimiento del foco visibles. Foco de vida (175, 105, r165) y de oleada (385, 84, r75) bien
centrados. Foco del arma (205, 205, r135): el icono (x 40..140) queda en el borde y sale en penumbra; corregir a
(150, 210, r125) en la siguiente versión. Los textos (texttags) no se oscurecen bajo el foco; es del motor.
Sin probar: multijugador.

## v16f: tiempo de lectura, doble recarga y oleadas con jefe (08/11/2026)

Pedido de Leon tras el vídeo de v16e: más tiempo entre secciones para leer con calma; en la recarga, enfocar también
el texto "Recargando" y mostrarla dos veces gastando las balas deprisa; luego seguir con la siguiente fase (oleadas).
v16f (`v16f.py`, `prueba_v16f.py`, `hacer-v16f.sh`; del mapa v16e cambia sólo el j):
- Cada texto del narrador se queda 0,6 s + 0,025 s por carácter además de su espera.
- Foco del arma en (150, 212, r125). Recarga: botón F → el foco pasa al texto de las balas (delante del HUD) mientras
  dice "aquí ves los segundos que faltan"; después tres ráfagas seguidas vacían el cargador con el foco en las balas,
  la mano pulsa F otra vez y el foco vuelve a "Recargando".
- Oleadas (fases 50..61 de 64): vuelve el subfusil con el cargador lleno; 5 'nmcf' del jugador neutral hostil (no son
  de las oleadas 8..11 ni dan oro) entran desde la derecha; foco en el contador ("5"); el Tauren dispara de verdad
  al último vivo cada 0,6 s, recarga si vacía y el contador baja. Luego "Wave 2": el jefe 'nj02' aparece fuera de la
  pantalla a X+1600 con su indicador para todos ('hbj2' y la esfera 'ubj0' en el borde, como DevJefe_Poner) y foco
  sobre él; entra, llama refuerzos (animación, Bondage Blue, "llamando refuerzos") y salen 3 'nmcf'. El Tauren acaba
  con todos; "¡Oleada superada!" y despedida ("verás la tienda y sus armas").
- Vida baja para la muestra (enemigos 45, jefe 250); si uno sigue vivo 3,5 s después de apuntarle se remata y queda
  anotado ("remate k"). Todo se borra con la pareja en `Tut_Soltar`.
`v16f` 7ed672ee…, `v16f-prueba` e1496df9… (notas en `lat/v16f-1.txt`, hasta 900: fases, estado cada 0,5 s,
"quedan n", "marca x y", "remate", "oleada limpia"). Estado: **Validated** (pJASS de las dos, reextracción del j por
hash, w3b/w3u/imp iguales a v16e, mpq verify). Sin probar en el juego: que los disparos maten a los enemigos sin
remates, la posición del indicador y su foco, la duración total (unos 2 min) y multijugador.

### Prueba de v16f (08/11/2026): **Tested in map** (un jugador, Leon), con fallos

`lat/v16f-1.txt` y vídeo `~/Vídeos/recording_2026-11-08_01.11.22.mp4`: 65 fases, fin a 167,7 s. Recarga doble
correcta (8 → 32/296, vaciado 32 → 0 con tres ráfagas, 0 → 32/264), foco del arma y textos más largos en pantalla.
Indicador del jefe en el borde derecho (1895, 407) con su foco; se oculta al entrar el jefe; "llamando refuerzos" y
3 refuerzos que caen a tiros. Fallos: los 5 primeros enemigos llegan y se vuelven solos hacia la derecha antes de
disparar (96 tiros sin baja, los 5 rematados) y el jefe se aparta al recibir daño (rematado). Leon: poner a las
unidades "no huir".

## v16g: enemigos que se quedan (08/11/2026)

`v16g.py`, `objetos_v16g.py`, `prueba_v16g.py`, `hacer-v16g.sh`; del mapa v16f cambian j y w3u.
- `ufle` (Can Flee) = 0 en 'nmcf' y 'nj02'. Afecta también a esos dos tipos en la partida real.
- Cada enemigo guarda su destino; si se aleja más de 60 se le manda de vuelta y al llegar queda en holdposition.
- Destinos más cerca: los 5 a X+420..480, el jefe se para en X+500. Plazo de remate 5 s sin contar la recarga.
- Notas "apunta k xy vida orden" y "remate k xy vida orden".
`v16g` e2ba43a6…, `v16g-prueba` 067f6889…. Estado: **Validated** (pJASS, reextracción de j y w3u por hash, w3b/imp
iguales a v16f, mpq verify). Sin probar en el juego.

## v16h: tienda, caja verde y despedida (08/11/2026)

`v16h.py`, `prueba_v16h.py`, `hacer-v16h.sh`, `entrar-v16h.sh`, `entrar-v16h-prueba.sh`; del mapa v16g sólo cambia
el j. Puntos 5, 6 y 7 del guion, fases 62..91 tras «¡Oleada superada!».
- Decisión del agente: la tienda real no sirve en el tutorial (se construye en `Shop_Construir`, tras el tutorial; usa
  la cámara cenital de `Menu_Ancla[1]` y es local por jugador). Se usa una réplica para todos con la cámara del
  tutorial: mismas texturas (DS00..DS0D, DT3E, `Cat_Tex`), píxeles de `Shop_Construir`, textos y reglas de
  `Shop_Refrescar` (tiers, «Tras la ronda N», precio, «Comprar», balas, «Abastecer todo», vida, oro). Oro 800 del
  guion; no toca el oro de los jugadores, `Arm_Tier` ni la tienda real. 43 piezas `uidb` y 37 textos (más 2 avisos).
- Golem 'ngst' que cae a X+1500 (4000 → 0 en 3 s); el indicador del borde pasa a 'hbjt'/'ubjt' con foco.
- El Tauren camina al golem y la cámara del tutorial lo sigue hasta X+1000 (suavizado 6 % por paso), recalibrando la
  altura con `Camera_calibrateHeightForPlayer` en cada paso; panel y textos (`UIText_updateAll`) se recolocan.
- Aviso de la partida copiado de `DevTienda_Hud` («Press [ESC] to buy supplies»), foco, ESC y fundido corto.
- En la tienda la narración va a la columna derecha (retrato del Tauren en el hueco del golem). Mano: recargar
  balas del MP18 (su reserva, como mucho 256, para que haya balas que comprar), Abastecer todo y vida, Escopetas, T2 Winchester 1887 y
  «Comprar» (oro 800 → 600 menos las balas), reloj «Descanso» desde 45 y Salir.
- Caja verde: MP18 a 0/0 con foco en las balas, RecargaVerde.mdx a (X+850, Y−260), el Tauren va a ella (espera
  hasta 8 s), aviso «[ESC] Pick up Ammo», recarga como `Recarga_Tomar` (32/32) y la caja pasa a RecargaRoja.mdx.
- Despedida nueva («¡Ya conoces lo básico!…») y fundido; todo se borra en `Tut_Soltar`.
`v16h` f94132da…, `v16h-prueba` 2fdb99a6… (notas en `lat/v16h-1.txt`, hasta 1500; nuevas: «golem en el suelo»,
«camara x», «tienda piezas/textos», «tienda cat fila tier oro falta»). Estado: **Validated** (pJASS de las dos,
reextracción del j por hash, w3u/w3b/imp iguales a v16g, mpq verify). Sin probar en el juego: alineación de los
textos de la réplica con sus cajas (la conversión píxel → UIText se dedujo de los textos del tutorial), radios de
los focos, que la cámara siga sin saltos ni desplazar el HUD, llegada del Tauren al golem y a la caja, presupuesto de
texttags con la réplica abierta y multijugador. v16g tampoco se ha probado.

## v16i: hora del día parada (08/11/2026)

Leon vio v16h entero (vídeo `recording_2026-11-08_01.33.44.mp4`, 253 s) y salió bien. Pidió congelar la hora:
la hora corría desde las 8:00 (`bj_MELEE_STARTING_TOD`) y hacia los 200 s anochecía. La tienda, la caja verde y la
despedida se veían casi negras, y desde los ~170 s una franja oscura cubría el lado del golem.

- `scripts/v16i.py`: en `Tut_Begin`, tras `EnableUserControl(false)`, fija las 12:00 y suspende la hora. Al entrar en la
  partida, `Storm_Oscuro` sigue poniendo la hora de la variante elegida y la suspende, así que no hay que restaurarla.
- Otros detalles del vídeo, sin cambios: los avisos "Press [ESC] to buy supplies" y "[ESC] Pick up Ammo" salen en
  inglés porque copian los avisos reales del juego. La niebla no influye, porque la zona visible ya cubre X ± 2600.
- `hacer-v16i.sh` parte del mapa v16h comprobando su j con `cmp`; sólo cambia `war3map.j`.
- Mapas: `TerrainDev-Titulo-v16i.w3x` c5ef642a…, `TerrainDev-Titulo-v16i-prueba.w3x` 0cd24ece….
- **Validated**: pJASS correcto, reextracción idéntica, w3u/w3b/imp sin cambios, mpq verify correcto.
- Pendiente: **Tested in map** (que Leon lo vea) y multijugador.

## v16j: cuadro mayor, suelo negro, teclas, iconos al centro y cadenas al recargar (08/11/2026)

Leon pidió tras v16i (hora fija bien) una lista larga. Se reparte en dos versiones:

**v16j (hecha, `scripts/v16j.py`):**
- Cuadro de diálogo un 35 % mayor: panel 864 × 216 con centro en (455, 708), marco 202 × 171, texto 0,025 con
  renglones cada 36 px y nombre 0,020. En la tienda el texto sigue a 0,019 (`Tut_TxtTam`).
- Retrato a profundidad 384, delante del marco amarillo (388) y del panel (396), como en la tienda. Escala 160.
- Suelo negro: el plano del título (`TitlePlano.mdx`, 4096 × 4096, `NegroSolido.blp`) en (X + 500, Y) durante el
  tutorial. Se destruye en `Tut_Terminar`.
- Una tecla en la esquina de cada casilla de la consola. Son las reales por posición, según el w3a: QWER / A F G D /
  Z X C V (F recarga en la columna 2, G batería en la 3, D dash en la 4). Las 12 se destruyen antes de abrir la réplica
  de la tienda, para no gastar texttags.
- `Tut_Centro`/`Tut_CentroPaso`/`Tut_CentroVolver`: F (fase 19), R (fase 39) y D (fase 44) hacen como la A: el icono
  va al centro con su etiqueta, la mano lo pulsa allí y luego vuelve a su casilla.
- Partida y tutorial: `Arm_Latido` pone `Bondage Blue SD.mdx` en el "chest" del cuerpo mientras `Arm_Fin[p] > 0` y lo
  destruye al acabar o cancelarse la recarga.
- Mapas: `TerrainDev-Titulo-v16j.w3x` a2f603c1…, `-prueba` f266cfd5…. **Validated** (pJASS, reextracción, mpq verify;
  w3u/w3b/imp sin cambios). Pendiente: **Tested in map**.
- Riesgos a mirar en el juego: que el plano negro no tape partes del terreno con relieve; que cambiar la piel del icono
  (grabtree) funcione tras crearlo; el tamaño de las cadenas sobre el Tauren.

**v16k (pendiente): escenas nuevas**
- Tiers: explicar y demostrar la mejora frente al arma base (más alcance y otros beneficios).
- Vidas: el personaje muere y no revive sin vidas hasta que alguien supera la oleada.
- Iluminación: cómo ayuda en los mapas de noche y su recarga (G, batería).
- Rachas, con la frase "compite en multijugador por quién hace más muertes sin morir".
- Cuchillo (Z) al final, para cuando no quedan balas, avisando de que obliga a acercarse al enemigo.

## v16k: retrato dentro del marco, suelo azul pastel y escenas nuevas (08/11/2026)

Base: v16j (cmp del j en `hacer-v16k.sh`). Cambian war3map.j y war3map.imp; se añaden `war3mapImported\SueloAzur.mdx`
(TitlePlano con otra textura) y `SueloAzur.blp` (BLP1 8×8, color 180/220/245), ambos de `scripts/suelo_v16k.py`.

- Retrato del diálogo a escala 125 (antes 160) y de la tienda a 175 (antes 200), para que no asomen los bordes.
- Suelo del tutorial azul celeste pastel: resalta el foco negro.
- Fases 89..130 nuevas (`scripts/v16k.py`); la despedida pasa a la 131, el fundido a la 132 y el final a la 133.
  - Tiers: se libera la réplica de la tienda (texttags); Trabuco T1 (400, 5 perdigones, cargador 6) contra
    Winchester T2 (450, 6, 8) disparando al blanco, con marcas de alcance en el suelo.
  - Rachas: tres enemigos, Triple Kill y Killing Spree (25) con la voz del anunciador; frase de multijugador.
  - Vidas: el Tauren cae (animación congelada), vida 0 %, «Vidas: 0»; sin vidas espera a que se supere la oleada;
    vuelve con ResurrectTarget; las vidas se compran en la tienda.
  - Luz: noche (hora 0), linterna BatLuz5 y batería propia del tutorial que se gasta hasta apagarse; consola con
    teclas, G al centro y recarga a 100 % (recargas 3→2); vuelve el mediodía.
  - Cuchillo: armas sin balas, Z al centro, cono del cuchillo; un enemigo se acerca, el Tauren se le pega y lo
    remata con golpes reales; aviso del riesgo de acercarse.
- Mapas: v16k `22cc3c36…`, v16k-prueba `b161796c…`.
- Estado: **Validated** (pJASS, reextracción por hash de j/imp/imports, w3u/w3b/w3a iguales, mpq verify).
  Sin probar en el mapa ni en multijugador; no se lanzó el juego (Leon lo prueba con `entrar-v16k.sh`).
- A vigilar en la prueba: que la animación de muerte quede tendida, que el enemigo del cuchillo llegue y que la luz no
  se duplique con la del sistema Luz del jugador.

## v16l: textura del suelo con formato probado (08/11/2026)

La prueba de v16k-prueba terminó a los ~25 s sin registro ni informe de error
(`informes/errores/resueltos/2026-11-08-025000-devmission-v16k-cierre.md`). Sospecha: el BLP de 8×8 sin alfa. v16l conserva el j
de v16k y rehace `SueloAzur.blp` desde `NegroSolido.blp` cambiando sólo la paleta (`scripts/suelo_v16l.py`).
Mapas: v16l `a77d30df…`, v16l-prueba `7f598f02…`. **Validated**; sin probar en el mapa.

## v16m: Tut_Guion partido (08/11/2026)

v16l también cerraba el juego antes de cargar y el diagnóstico d0 (mapa v16j + j de v16k) también: es el script.
Sospecha: 133 `elseif` seguidos en `Tut_Guion` (v16j tenía 91). v16m mueve las fases 89.. a `Tut_Guion2`.
Regla para lo que sigue: no pasar de ~90 `elseif` por función; añadir fases en otra función.
Mapas: v16m `770f1d39…`, v16m-prueba `b2c7b2b4…`. **Validated**; sin probar en el mapa.

### Prueba de v16m-prueba (08/11/2026, 03:04, Leon, un jugador)

Registro `lat/v16m-1.txt` (915 notas): el tutorial llega al final (fase 133 a los 371 s) y pasa por las 42 fases
nuevas. Tiers: el Trabuco dispara 6 tiros (5/60 → 0/60) y la Winchester 7 (7/80 → 0/80). Cuchillo: el Tauren se acerca
de X 8043 a 8426 y el enemigo cae a cuchilladas (tiros 195..198, «quedan 0» antes del remate). Fallo: en rachas la
Winchester seguía en 0/80 y no salió ningún tiro; los tres cayeron por KillUnit, tras agotar la espera de 6 s.

## v16n: rachas a tiros (08/11/2026)

`scripts/v16n.py`: la fase 95 llena el cargador de la Winchester y los enemigos salen a X+750..800 (antes 950..1000)
hacia X+300..330. Mapas: v16n `24107be7…`, v16n-prueba `face4303…`. **Validated**; sin probar en el mapa.
Lo visual de vidas, luz y retrato depende de lo que vea Leon; el registro no lo cubre.

## v16o: aldea, iconos, tier máximo, tarjetas de racha, caja, tienda y batería (08/11/2026)

Pedido de Leon tras el vídeo de v16m (`/home/snz/Vídeos/recording_2026-11-08_02.57.52.mp4`):
- Suelo (`scripts/terreno_v16o.py`): fuera el plano SueloAzur. El recinto (X 6000..10000, Y 7500..9500) copia la
  textura y variación de cada vértice de la aldea de X ~1100..1600, Y ~-1900..-1450 (desplazamiento 6100, 10550);
  alturas, capas y agua siguen llanas (z 209,5). Se copian 105 objetos: 26 árboles (ZTtw, LTlt), 5 casas VSvb, el
  edificio YS15, el pozo, vallas, faroles y plantas. Se excluyen el carril del guion (X 7850..9750, Y 7750..8750 con
  margen) y juncos o piezas de agua. Los árboles ponen su trazado al cargar; el de las casas no se graba en el wpm
  porque el guion no pasa por allí. La aldea queda arriba a la izquierda del Tauren.
- Icono al centro (`Tut_Centro`): R, D y Z mostraban el icono anterior. Cambiar la textura con
  `UserInterface_ApplySkin` sobre un dummy ya usado a veces no prende. Ahora se crea un dummy nuevo con su textura.
- Tiers: nueva fase 93 con el máximo, SPAS-12 T6 (alcance 700, 8 perdigones, cargador 14), con marca T6 en X+700. La
  fase siguiente vuelve a T2 para las rachas. Las fases de `Tut_Guion2` desde la 93 suben en uno: 45 `elseif`, hasta
  la 134.
- Rachas: tarjetas como `Racha_Hud`, con la cámara del tutorial (`Tut_Tarjeta`, `Tut_TarjetasPaso`):
  - cada tarjeta lleva el cuadro DS18, el retrato Tauren o Cairne en el marco DS19, el nombre y la racha;
  - bajan desde arriba, dos por fila (x 705 y 1125; y `Racha_Y` y +62);
  - Triple Kill y Killing Spree salen del Tauren;
  - en la frase de multijugador entran Double Kill y Dominating de «Jugador 2» y «Jugador 3» (Cairne): cuatro a la vez;
  - luego suben y desaparecen.
- Caja verde: Y+60 (antes Y−260), lejos del cuadro de diálogo. El aviso ESC va 100 px sobre la caja en pantalla y el
  foco sobre el aviso.
- Tienda: `Tut_STexto` y `Tut_SEscribir` bajan el texto 750·tamaño, como hace `Shop_At` en la tienda real. En el
  vídeo los nombres quedaban unos 16 px por encima del centro de su fila.
- Batería: el cuadro del juego (marco DS0E en 230,124; relleno DS0F con ancho 1,566·% y color de `Bat_Hud`; texto
  0,015 en y 158) en lugar del texto suelto en y 252. El foco de esa fase va a (230,135).
- Mapas: v16o `da680a9b…`, v16o-prueba `d728e5e9…`.
- Estado: **Validated**:
  - pJASS correcto en los dos j;
  - el j, el w3e y el doo reextraídos coinciden por hash;
  - `mpq bytes-diff` contra v16n sólo cambia j, w3e, doo, (attributes) y (listfile);
  - `mpq verify` correcto;
  - wc3ctl lee 5721 doodads, 105 en el recinto.
- Sin probar en el mapa ni en multijugador. A mirar en la prueba:
  - que se vean la aldea y los árboles, y la noche con la linterna;
  - el icono correcto en F, R, D, G y Z;
  - la marca T6;
  - las cuatro tarjetas;
  - la caja y el aviso por encima del diálogo;
  - los textos centrados en las filas de la tienda;
  - el cuadro de batería igual al del juego.

### Prueba de v16o (08/11/2026)

- Registro `lat/v16o-1.txt`: las 134 fases en 376 s, sin órdenes rechazadas. Tier 6 (fase 93) dispara (12/140 → 9/140);
  las rachas caen a tiros (quedan 3→0 en 267..273 s, antes del remate de la fase 99).
- Leon: "salió bien"; único fallo en su vídeo (`~/Vídeos/recording_2026-11-08_03.25.54.mp4`): en la escena del cuchillo
  el foco quedaba fijo en (960, 300), donde lo deja el icono central, mientras el Tauren caminaba hacia el enemigo.
- Estado v16o: **Tested in map** (un jugador, Leon).

## v16p: el foco sigue al Tauren con el cuchillo (08/11/2026)

- `scripts/v16p.py` sobre el j de v16o: `Tut_FocoHeroe` desde la fase 126 hasta la 133 (y en `Tut_Soltar`); cada tick el
  foco se acerca un 25 % al punto de pantalla del Tauren (`Tut_Z + 60`) y se abre a radio 125.
- `hacer-v16p.sh`: cmp de la base, pJASS en las dos, reextracción por hash, bytes-diff sólo j (+ atributos), mpq verify.
- SHA-256: v16p `50d1dc697202adee…`, v16p-prueba `d681cd359108be3d…`. Estado **Validated**; falta ver el foco en el juego.
- Prueba de v16p (Leon, 08/11/2026 03:36): registro `lat/v16p-1.txt` con las 134 fases en 381,5 s, sin rechazos; en su
  vídeo (`recording_2026-11-08_03.36.35.mp4`) el foco queda centrado en el Tauren durante el cuchillo. **Tested in map**.

## v16q: balas de RapidBolt sin cortes (08/11/2026)

Motivo: estrés de v16p (informe `informes/errores/2026-11-08-152941-estres-misiles-limite-operaciones.md`). `scripts/v16q.py`:
- `Bala_Barrer` sustituye al barrido de las balas: una búsqueda de unidades por bala y tick con primer contacto exacto
  del círculo a lo largo del tramo (comprobado en Python contra muestreo denso, 20 000 casos), y paredes/árboles por
  casillas de 16 guardadas en una tabla por radio (6, 16,2, 18, 30), vaciada al empezar cada ronda. Pasos de 16.
  El héroe, el dash y el bot siguen con `GroundCollision_trace` sin cambios.
- `RapidBolt_missileIterateP` en tandas de 16 balas con `TriggerEvaluate`, como `Missile_move`.
- Se descartó agrandar el radio de búsqueda al cuerpo máximo real (jefe nj0A, 389): costaría más; se mantiene radio + 256,
  igual que antes.
- Diferencias esperadas: paredes y árboles con error de hasta ~11 unidades (centro de casilla).

Mapas: v16q `38e2322bd171…`, v16q-prueba `080d0a86d8e4…`; estrés v16q-estres (MP5) `5b87c9fc70b2…`, v16q-estres-spas
`be2ddaa6094c…` (`hacer-estres-v16q.sh`, `entrar-estres-v16q.sh [spas]`, `analizar_estres_v16q.py`).
Estado: **Validated** (pJASS, reextracción, mpq verify). Falta el estrés en el juego y una partida normal.

### Estrés de v16q con MP5 (08/11/2026, `estres-v16q/20261108-154548-mp5`)

| Tiradores | v16p fps | v16q fps | v16q máx. | v16q balas vivas | v16q tandas cortadas |
|---|---|---|---|---|---|
| 1 | 59,4 | 62,1 | 31 ms | 9 | 0 |
| 2 | 43,0 | 60,9 | 30 ms | 20 | 0 |
| 4 | 20,6 | 53,3 | 36 ms | 40 | 0 |
| 8 | 0,6 → bloqueo | 41,0 | 113 ms (2 cuadros > 100) | 77 | 3 de 8557 |

Juego a tiempo real en todos los escalones. Las 3 tandas cortadas sólo pierden ese tick de 16 balas (siguen al
siguiente). Con 8 tiradores la oleada llegó a 0 al final del escalón: parte del tramo fue sin enemigos.
**Tested in map** (un cliente con bots). Pendiente: SPAS-12 y partida normal.

Corrección del mismo ensayo: después de COMPLETE el juego siguió con los 8 tiradores hasta ~440 s y fue bajando
(medias por 20 s: 36 fps a 150 s, 22 a 190 s, 15-17 a 350-390 s; picos de 234-238 ms a ~260 y ~435 s). Hilo principal
84-89 % de CPU; memoria 552 → 651 MB. Las rondas siguientes (límite 240 vivos con 8 jugadores) no se registraron:
falta separar cuánto es de balas, de enemigos y de dibujo. Los 41 fps sólo valen para el comienzo de la ronda 5.

### Medición por modos (v16q-perfil, preparada 08/11/2026)

`scripts/perfil_v16q.py` sobre el j de v16q-estres: enemigos que no mueren (población fija en su límite), 25 s de llenado y
16 tramos de 15 s: 2 vueltas × [MP5, SPAS-12] × [enemigos solos, normal, sin colisión, sin modelo]. COMPLETE a los 265 s
de ronda. `hacer-perfil-v16q.sh` (`7b00639d6ba8…`, Validated), `entrar-perfil-v16q.sh`, `analizar_perfil_v16q.py`.
Límite: el tope de 60 fps del perfil oculta coste por debajo de 16,7 ms; la CPU del hilo principal lo complementa.
Ideas de foros (sin verificar en 1.27b): enum con filtro nulo, radio de colisión máximo preciso, reserva de dummies al
empezar, repartir enemigos entre más jugadores y bajar su colisión para el movimiento.

## v16r: cuelgue con escopeta y casillas baratas (08/11/2026)

Causa leída en el código: el tick de RapidPair disparaba a todos los tiradores en un hilo y adelantaba `nextShot` después
del disparo. Con 8 SPAS-12 el hilo se cortaba antes y el mismo tirador repetía el disparo en cada tick. `scripts/v16r.py`:

- disparo en su propio hilo (`Par_Emitir`);
- sonda de suelo única por casilla de 16 (`Bala_Celda`), sin vaciar cada ronda;
- tipo de árbol por destructible (`Bala_Arbol`);
- boca del arma en dos casillas (`Bala_Boca`);
- tandas de 8 con rescate.

El héroe, el dash y el bot siguen igual. Estado: Validated (pJASS, reextracción, `mpq verify`); sin probar en el juego.

| Mapa | SHA-256 |
|---|---|
| `TerrainDev-Titulo-v16r.w3x` | `ac7ed1b2fdc5…` |
| `-v16r-prueba` | `754111824d28…` |
| `-v16r-estres` (MP5) | `3767fcb27f38…` |
| `-v16r-estres-spas` | `76dd7a017fba…` |
| `-v16r-perfil` | `28be82fd59f7…` |

La medición de v16r corrige la de v16q: los enemigos son invulnerables (la población queda fija) y cada tramo corta las
ráfagas en curso. Los registros nuevos añaden `sondas` (pruebas de suelo nuevas) y `rescates`.

Siguiente paso: `entrar-estres-v16r.sh spas`, luego `entrar-perfil-v16r.sh`.

## v16s: búsqueda de unidades ajustada (08/11/2026)

La medición de v16r (perfil-v16r/20261108-163450) da SPAS-12 × 8 normal 5,2 fps con cientos de tandas cortadas, y
20,4 fps sin colisión. La búsqueda por bala (+256 para el jefe de cuerpo 389) recorría la multitud entera.

`scripts/v16s.py`:
- radio de búsqueda medio tramo + radio + 80;
- unidades con cuerpo > 80 en una lista aparte (`Bala_Grande`, cada 0,25 s);
- tandas de 4.

Estado: Validated.

| Mapa | SHA-256 |
|---|---|
| `TerrainDev-Titulo-v16s.w3x` | `7b8613f07b2e…` |
| `-v16s-prueba` | `cb7efb261483…` |
| `-v16s-estres` | `6134e6a9d5e6…` |
| `-v16s-estres-spas` | `bdeceb8719d3…` |
| `-v16s-perfil` | `9e3144b11a8d…` |

Siguiente paso: `entrar-perfil-v16s.sh` y comparar con v16r. Pendiente si no basta: coste de crear ~384 perdigones/s
(33 ms por cuadro en SPAS × 8).

## v16t: Firebrand ligero (08/11/2026)

En la medición de v16s, SPAS-12 × 8 normal da 14,8 fps y sin modelo 41,4 fps. La muerte de cada perdigón soltaba
~70 partículas. `scripts/efectos_v16t.cjs` hace estos cambios en los 6 colores de Firebrand Shot (Yellow, Green,
Teal, Blue, Purple y Red):
- tasa de todos los emisores a 1/4;
- estela «S L Trail» de 0,4 a 0,25 s;
- cintas «Rib US» de 0,10 a 0,05 s.

El j es el de v16s y se reemplazan los 6 modelos en el mapa (`hacer-v16t.sh`). Estado: Validated.

| Mapa | SHA-256 |
|---|---|
| `TerrainDev-Titulo-v16t.w3x` | `d307d552ed8c…` |
| `-v16t-prueba` | `90c0c1a87a62…` |
| `-v16t-perfil` | `322c2269233e…` |
| `-v16t-estres-spas` | `c57d6a265595…` |

Siguiente paso: `entrar-perfil-v16t.sh` y que Leon mire el aspecto con `entrar-v16t-prueba.sh`.
