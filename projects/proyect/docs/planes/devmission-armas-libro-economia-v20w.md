# Dev Mission: libro de armas, recarga automática, pulls comprados y economía fija (desde v20w)

Pedido de Leon el 20/11/2026, tras las Armas por cartas (v20v). Base: v20v (`011e6fea…`, prueba `cefaae84…`); el w3a
de partida es el de v20s (v20t–v20v sólo cambiaron el j).

## Lo pedido

- **Cuchillo:** mucho más daño, porque obliga a acercarse; sus mejoras, aún mayores.
- **Botonera:**
  - las armas van en un libro arriba a la izquierda;
  - a su derecha, F (arma anterior) y G (arma siguiente); si faltan armas, se salta a la siguiente que se tenga;
  - arriba a la derecha, Disparar (A);
  - cada arma del libro, 1 s de recarga;
  - las habilidades del personaje, sueltas en la fila de abajo, sin libro;
  - el dash, donde estaba, junto a la linterna.
- **Recarga y dash:**
  - la recarga es automática y se quita su botón;
  - cambiar de arma corta la recarga, y la nueva se recarga sola si lo necesita;
  - el dash ya no corta la recarga;
  - el dash tiene 3 cargas de base, y cada una vuelve en 2 s.
- **Pulls:**
  - los pulls que no se eligen se acumulan;
  - bajo los cuadros de la pantalla de inicio, botones para comprar pulls por rareza (baja, media y alta);
  - Leon dejó los precios a mi elección.
- **Economía:**
  - no escala;
  - 1-3 de oro por enemigo y bolsas más pequeñas;
  - por wave, el oro de ganarla más las bolsas de élite debe dar para una mejora media y un par de bajas.

Respuestas de Leon:

- **Pull comprado:** "Mezcla de ambas": cartas del héroe y de armas.
- **Acumulación:** "Armas y pulls del héroe", con tope de 7 pasos del héroe.
- **Recarga automática:** "Al vaciar el cargador".

## Decisiones del agente

- **Cuchillo (daño por golpe, T1…T6):** antes 38, 38, 41, 45, 50, 56; ahora 112, 125, 141, 158, 181 y 203. Es unas 2 veces el
  DPS de la SMG en T1 y unas 3 veces en T6; los intervalos no cambian.
- **Libro de armas 'AWlb' (V, 0,0):**
  - contiene, en este orden: Aw01, Aw02, Aw03, Aw04, Aw05, Aw06 y Aw00;
  - sólo se ven las armas que se tienen (`SetPlayerAbilityAvailable`), y el nivel es el tier;
  - cada arma tiene 1 s de recarga;
  - F ('AwFa', 1,0) y G ('AwGa', 2,0) recorren ese orden y no tienen recarga;
  - Disparar (Arp1) pasa a 3,0, y el dash se queda en 3,1;
  - quitado: el botón de recarga Aw08 (el objeto sigue en el w3a, sin usar).
- **Habilidades:** los 27 puentes de los 7 libros de personaje pasan a la fila 2, en su misma columna, y se añaden
  sueltos (`Don_Botones`, `Gk_Botones`). Los libros ALGk/ALTb/… siguen en el w3a, sin usar.
- **Recarga automática:**
  - `Arm_Latido` la empieza cuando el arma activa (no el cuchillo) tiene el cargador vacío y queda reserva;
  - `Arm_Elegir` sigue cortando la recarga al cambiar de arma;
  - el dash ya no pone `Arm_Fin` a 0.
- **Dash:** `Dash_Max = 3 + extra` y `Dash_Recarga = max(1, 2 × (1 − reducción))`.
- **Acumulación:**
  - **Armas:** +2 elecciones por wave (1 la primera), hasta 8; las que no se usan pasan a la siguiente.
  - **Héroe:**
    - al acabar la wave se anota desde qué paso quedan cartas sin elegir (`HerS_Desde`);
    - al empezar el descanso, esos pasos se guardan con sus mismas cartas detrás de las 2 mejoras nuevas, en el orden
      guardados, First blood, MVP y rachas;
    - hasta 7 pasos en total; lo que no cabe se pierde.
  - **Nombre del paso guardado:** "Mejora del héroe (guardada)" o el nombre que tenía.
- **Pulls comprados (botones 50-52 bajo los cuadros, y ≈ 785):**
  - **Precios:** bajo 50, medio 120 y alto 350.
  - **Condiciones:** se compran en la pantalla de inicio. Cada compra añade un paso del héroe, hasta 7. El reembolso
    (carta 18) también se aplica a los pulls.
  - **Mano:** 4 cartas, 2 del héroe y 2 de armas. Las de armas salen entre Filo, Golpe de suerte, Calibre y Cargador
    ágil. En medio y alto, una de ellas es "Subir tier" de un arma que se tiene, si se puede. Las técnicas se quedan
    como salieron.
  - **Calidad (T1…T5):**
    - bajo: 55/35/10 % en T1/T2/T3;
    - medio: 10/35/55 % en T1/T2/T3;
    - alto: 20/70/10 % en T3/T4/T5.
  - Si al elegir, "Subir tier" ya no se puede (se subió por Armas) o "Arma nueva" ya se tiene, la carta cuenta como
    Filo.
- **Economía:**
  - 1-3 de oro por enemigo;
  - bolsa común 10, de élite 20, y el jefe suelta 3 de 20;
  - 100 de oro al ganar la wave;
  - empieza con 150 de oro;
  - el interés (carta 37) sigue con tope de 250.
  - **Cálculo:** con el oro de ganar la wave (100), unas 2-3 élites (40-60) y las bolsas comunes (unas 30) se llega a
    unos 220: un pull medio y 2 bajos. El alto pide ahorrar o más élites.

## Registro de entregas

### v20w (20/11/2026)

Fuentes:

- `scripts/v20w.py` (j);
- `scripts/objetos_v20w.py` (w3a, sobre el de v20s);
- `scripts/hacer-v20w.sh`;
- lanzadores `entrar-v20w.sh` y `entrar-v20w-prueba.sh`.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20w.w3x | `48a9ddbf8dbb3a1a3e2be25a7de26ce3d58f7c52e0b98c271d02d02c2c78ef06` |
| TerrainDev-Titulo-v20w-prueba.w3x | `1eefc26d16076b61c55a9044343bc76a870fa6e702540577b2699bb88e4adc1a` |

**Comprobado:**

- pJASS en las dos variantes;
- j y w3a reextraídos iguales;
- bytes-diff: sólo cambian (attributes), (listfile), j y w3a;
- `mpq verify`;
- construcción reproducible (dos veces, mismo hash);
- copias en WOE con cmp;
- campos de AWlb, AwFa, AwGa, Arp1 y los puentes leídos del w3a empaquetado.

En -prueba van a `lat\v20w-don.txt` (con -reg) estas líneas: "pull compra j… rareza … precio … pasos …", y en el log de
pulls "guardados N armas N".

Estado: **Validated**; sin jugar.

- No hay `GetLocalPlayer` nuevo: 120 y 124 líneas, igual que v20v.
- Lo local que se añade:
  - 3 texttags por cliente (`Cua_TCompra`);
  - el color de los botones de compra.

Se recomienda una prueba LAN de la pantalla de cartas.

**Por comprobar en juego:**

- **Libro y botones:**
  - que el libro de armas abra con V y muestre sólo las armas que se tienen;
  - que el arma nueva aparezca en el libro con su tier;
  - que F y G salten bien con 2-3 armas;
  - que las habilidades se vean abajo y que Tec_Aplicar las siga mostrando u ocultando.
- **Recarga y dash:**
  - que la recarga automática empiece al vaciar el cargador;
  - que el dash no la corte;
  - que cambiar de arma la corte y la nueva se recargue si está vacía;
  - que el dash tenga 3 cargas y cada una vuelva en 2 s.
- **Pulls:**
  - que los botones de compra se vean bajo los cuadros y no los tape la consola (y ≈ 785);
  - que se pongan grises sin oro;
  - que los pasos guardados del héroe y las elecciones de Armas pasen a la wave siguiente.
- **Economía:** el equilibrio de oro con los números de arriba.
- **Sin tocar:** el tutorial automático, que pedía la recarga con la orden "stomp" (ahora la recarga sola), y el bot
  interno (apagado).

### v20x (21/11/2026): recarga por inactividad

Pedido de Leon: recargar también sin vaciar el cargador si no se dispara durante un rato, y que se cancele al volver a
disparar.

- **Cuándo empieza:** tras 1,5 s sin disparar ni cambiar de arma (`Arm_OCIO_ESPERA`), si el cargador no está lleno y
  queda reserva, empieza la recarga normal (`Arm_Ocio` = verdadero).
- **Cuándo se corta:**
  - al disparar con munición en el cargador, esa recarga se corta y se dispara sin esperar;
  - la recarga del cargador vacío no se corta.
- **Lo que no cambia:** cambiar de arma sigue cortando cualquier recarga.

Fuentes: `scripts/v20x.py` (j), `scripts/hacer-v20x.sh`; lanzadores `entrar-v20x.sh` y `entrar-v20x-prueba.sh`.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20x.w3x | `415183c4bc8a328cd3d60a8732b4a80e6df3dde3d45bc452b7d0035913c365d9` |
| TerrainDev-Titulo-v20x-prueba.w3x | `45d4ebf15de23fda44d50c3568b3a5a138c09866d50d2441271c43fe514d0910` |

**Comprobado:**

- pJASS en las dos variantes;
- j reextraído igual;
- bytes-diff: sólo cambian (attributes), (listfile) y j;
- `mpq verify`;
- construcción reproducible;
- copias en WOE con cmp.

No hay `GetLocalPlayer` nuevo. Estado: **Validated**; sin jugar.

**Por comprobar en juego:**

- si 1,5 s es buena espera;
- que al disparar durante esa recarga se corte y se dispare enseguida.

### v20y (21/11/2026): botones de compra y héroe fijo por color

Pedido de Leon con una captura de v20w: los textos de compra salían a la izquierda y por debajo de sus botones; preparar
una LAN rojo + amarillo (azul a morado cerrados); sin selección de héroe por ahora, cada color con su héroe.

- **Botones de compra:** botón y trackable en y 795; el texto en y 774 (va unos 21 px más abajo que su py en pantalla),
  centrado con el largo visible (`HerC_Plano`, sin códigos de color). El separador pasa de "·" a "-".
- **Héroe por color** (en `Game_Enter`, sólo jugadores humanos):

| Jugador | Color | Héroe |
|---|---|---|
| 0 | rojo | Tauren |
| 1 | azul | Cairne |
| 2 | verde azulado | Tauren (relleno) |
| 3 | morado | Goku |
| 4 | amarillo | Freezer |
| 5 | naranja | Trunks |
| 6 | verde | Naruto |
| 7 | rosa | Cairne (relleno) |

- **LAN:** `TerrainDev-Titulo-v20y-lan.w3x` es el normal sin cambios; `v20y-lan/map.cfg` cierra los colores 1, 2 y 3.
  Lanzador `scripts/lan-v20y.sh` (copia de lan-v20p).

Fuentes: `scripts/v20y.py`, `scripts/hacer-v20y.sh`; lanzadores `entrar-v20y.sh`, `entrar-v20y-prueba.sh`, `lan-v20y.sh`.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20y.w3x (y -lan, idéntico) | `71012d2437a84e38dcdc7b216cdfdc4174b21ab9f3100ca9646ff432355c8875` |
| TerrainDev-Titulo-v20y-prueba.w3x | `e36ca6c21be5bec816bf120d4458a0c5d824553c9d710a3bb3ac575aa6197d17` |
| v20y-lan/map.cfg | `bde8650f7bcf32c541cd499349d7cb94e6be8be828eea809f5e0951f819c8c1b` |

**Comprobado:** pJASS en las dos variantes; j reextraído igual; bytes-diff sólo (attributes), (listfile) y j;
`mpq verify`; construcción y map.cfg reproducibles; copias en WOE con cmp. No hay `GetLocalPlayer` nuevo (120/124).
Estado: **Validated**; sin jugar ni LAN.

**Por comprobar en juego:** que los textos queden dentro de sus botones; que amarillo salga con Freezer y sus
habilidades en LAN; la pantalla de cartas en LAN.

## v20z (21/11/2026): pulls comprados para las dos tiendas, páginas, rachas con icono y MVP de interfaz

Pedido de Leon tras la LAN de v20y.

- **Pulls comprados:**
  - Comprar ya no añade un paso del héroe con 2 cartas de armas mezcladas.
  - El pull entra en una cola de hasta 5 (`HerC_N`, `HerC_R`) y abre Armas y Habilidades. El jugador elige dónde
    gastarlo.
  - Entrar y salir con ESC no gasta nada: `HerC_Soltar` devuelve el pull a la cola con las mismas cartas. Lo mismo
    pasa al acabar el descanso.
  - Habilidades: el pull se abre como un paso más al final (`HerC_AbrirH`, `Her_ExTipo` 3-5) con una mano sólo del
    héroe (`HerC_Mano`).
  - Armas: la mano sale como las de Armas (`HerC_AbrirA` usa `ArmC_Cartas`), con la calidad de la rareza y sin
    malditas. Se rehace si una carta ya no vale.
  - Al elegir se sigue con la siguiente mano mientras queden: primero las de la oleada, luego las compradas.
- **Por qué volvía al menú:**
  - Leído en el código de v20y: el menú vuelve sólo cuando `Cua_Paso` llega a `Her_FinDe` (5 + extra), al acabar
    Mutación Evo, o en Armas al llegar `ArmC_Quedan` a 0.
  - No hay salida a mitad de los pasos. Un pull comprado con los pasos del héroe ya hechos era exactamente 1 paso.
  - La prueba anota cada elección ("cua elige").
- **Panel del héroe:**
  - 15 iconos por página (3 filas), botones `<` `>` en y 442 con "1/N" (trackables 100 y 101).
  - Hasta 60 mejoras guardadas (`p * 60`); 3 texttags más por cliente con la tienda abierta.
- **Rachas:**
  - La tarjeta lleva el icono del personaje (`Hero_Icon`, pieza 'uidb' de 46 px) en lugar del retrato.
  - Sin voz del personaje: la cola espera sólo el anuncio + 0,3 s (antes + 1,9 s).
- **MVP:**
  - hMf0-6 pasan a ser copias de la pieza de retrato 'dta0' (ewsp float, sin colisión ni sombra), con
    `scripts/objetos_v20z.py`.
  - Los modelos van limpios con `scripts/mvp_limpio.cjs` a `mvp-frente/limpio/`. Quita partículas, cintas y eventos:
    Cairne 14, Tauren 12, Kyuubi 3, Goku/Freezer/Trunks 1, Naruto ninguno.
  - Las poses de todos los vértices son iguales a las del original.

Fuentes: `scripts/v20z.py`, `objetos_v20z.py`, `mvp_limpio.cjs`, `hacer-v20z.sh`; lanzadores `entrar-v20z.sh`,
`entrar-v20z-prueba.sh`, `lan-v20z.sh`.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20z.w3x (y -lan, idéntico) | `19eed0e3eb6527ea228174c5da4f28e3c5ac56640c72307f7262fe5cde9bbe01` |
| TerrainDev-Titulo-v20z-prueba.w3x | `97906e027168308338b3e6cd6d5b6be5cfd4737a4de1f64625f9ef8834b6da12` |
| v20z-lan/map.cfg | `773a56f56d39d028d989fc8fd1b31419980197fecdbe8377779ea2ffd9fde1d4` |

**Comprobado:**
- pJASS correcto en las dos variantes.
- j, w3u y los 6 MDX cambiados se reextraen iguales. Naruto no cambia.
- bytes-diff sólo muestra esos miembros, (attributes) y (listfile); `mpq verify` correcto.
- La construcción es reproducible y las copias en WOE pasan cmp.
- Hay los mismos `GetLocalPlayer` que en v20y (116/120).

Estado: **Validated**; sin jugar ni LAN.

**Por comprobar en juego:**
- la cola de pulls en las dos tiendas, ESC sin gastar y elegir varias seguidas;
- que el icono quepa en el marco de la racha;
- los botones de página;
- que el MVP no baje en terreno con niveles y no deje manchas.

## v21a (21/11/2026): vidas base 25

Leon: vidas base a 25. `Vidas_INICIO` pasa de 3 a 25; nada más cambia respecto de v20z.
Fuentes: `scripts/v21a.py`, `scripts/hacer-v21a.sh`; lanzadores `entrar-v21a.sh`, `entrar-v21a-prueba.sh`.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v21a.w3x | `535a0a77cd2e2ceedfceb7b5c9a5a9943d6daf0c8cdb807309c4c773023d83a0` |
| TerrainDev-Titulo-v21a-prueba.w3x | `164976d780494c8f6927714a1d1af71c7881899bd78846e2d9a52f66f504fbb3` |

Comprobado: pJASS correcto, j reextraído igual, bytes-diff sólo con j, (attributes) y (listfile), `mpq verify`,
construcción reproducible y copias en WOE con cmp. Estado: **Validated**; sin jugar.

## v21b (21/11/2026): aviso de balas ligeras en cada oleada

Leon: al empezar cada oleada, avisar de `-bl 0 1 2` para el lag. `Ronda_Lanzar` muestra a cada jugador en partida,
8 s en el chat: "¿Lag con muchas balas? Escribe -bl 1 (ligeras las de los demás) o -bl 2 (todas ligeras); -bl 0 las
deja normales. Ahora: <modo actual>." El comando `-bl` no cambia (v17b).
Fuentes: `scripts/v21b.py`, `scripts/hacer-v21b.sh`; lanzadores `entrar-v21b.sh`, `entrar-v21b-prueba.sh`.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v21b.w3x | `700b5def9c7141517cd480d54b37a4f228cfecb52c1d4d5087f8e76fa8d9dd75` |
| TerrainDev-Titulo-v21b-prueba.w3x | `33cb0839890661d3978eaa6059c4e7c5c5d12a7c0864e597115ece3ce4991aa9` |

Comprobado: pJASS, j reextraído igual, bytes-diff sólo j y (attributes), `mpq verify`, reproducible, WOE con cmp.
Estado: **Validated**; sin jugar.

## LAN de la copia de Leon de v21b (21/11)

Origen: `~/Descargas/TerrainDevv21b.w3x` (`e3372215…`, sin tocar). Es v21b pasada por un optimizador:
- el j está compactado (1,72 MB frente a 2,24 MB), con el mismo contenido y `Ronda_AvisoBalas`; también se guarda como `scripts\war3map.j`;
- sin listfile, `war3mapUnits.doo`, `war3map.imp`, `(attributes)`, wtg/wct/w3r/w3s;
- al w3i le falta la cola de tecnologías; jugadores y fuerzas iguales;
- de la wts se quitaron los comentarios.

Los 963 imports están íntegros por contenido y se encuentran por nombre en la tabla hash (locale 0). wc3ctl no los extrae por nombre sin listfile; es una limitación de la herramienta, no del mapa.

El LAN usa el mapa tal cual (`TerrainDev-Titulo-v21b-leon-lan.w3x`, mismo sha256) más `v21b-leon-lan/map.cfg` (`2e06df60…`). Las ranuras son las mismas que en v20z: rojo y amarillo libres; azul, verde azulado y morado cerrados.
- Construcción: `scripts/hacer-v21b-leon-lan.sh`, reproducible.
- Lanzador: `scripts/lan-v21b-leon.sh`.
- Comprobado: pJASS del j optimizado; reproducible.
- Estado: **Validated**; sin jugar en LAN.

## v21c (22/11): sin transformaciones por muertes

En la partida real de Leon (5 jugadores, wave 1 con 35 enemigos) sólo se contaron 5 bajas; desde ahí nada sumaba: ni oro por baja, ni rachas, ni bajas en resultados o MVP, ni puntos de transformación.

Causa, deducida leyendo el código:
- `Oro_Muerte` → `Mvp_Muerte` → `Frm_Matar` corre dentro del disparador de muertes compartido (RegisterPlayerUnitEvent).
- Al llegar Goku al 20 % de máx(10, enemigos ÷ jugadores), que con 35 ÷ 5 son 2 puntos, se ejecuta `GkF_B77` de D.O.N. Igual con `TrF_gi4` de Trunks.
- Esas funciones hacen `DisableTrigger(GetTriggeringTrigger())`, que apaga ese disparador para toda la partida.
- `Frm_Fin` (fin de oleada, `GkF_Bf7`/`TrF_go4`) tenía el mismo riesgo sobre `WaveEvtFinish`.

Cambio (`scripts/v21c.py`): se quitan las llamadas a `Frm_Matar` y `Frm_Fin`, que quedan sin uso. Las transformaciones esperan un rework aparte. Las formas que se lanzan con habilidad propia de D.O.N siguen en sus disparadores originales.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21c.w3x | `73ab26051e5eedb4cbcc0742e58d4894454a5c5b45bbe2ec5e538f465d707cf7` |
| TerrainDev-Titulo-v21c-prueba.w3x | `174c9f1de6759a106d896464255622889bdb663de4df55e944c61eb2476e0ed1` |

Comprobado: pJASS, j reextraído igual, bytes-diff sólo j y (attributes), `mpq verify`, reproducible, WOE con cmp.
Estado: **Validated**; sin jugar.
