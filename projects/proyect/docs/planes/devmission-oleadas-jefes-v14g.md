# Plan: oleadas, élites y jefes de Dev Mission (v14g)

Estado: **Tested in map** con un jugador, por registros y por capturas del usuario del icono del jefe,
el 02/11/2026. Falta la LAN de dos clientes.
Tercera versión: el usuario aprobó implementar con los dos ajustes de la última respuesta
(refuerzos y límites del icono).

## Construido

- `TerrainDev-Titulo-v14g.w3x`, SHA-256 `558f6cfe…98105c38`.
- `TerrainDev-Titulo-v14g-prueba.w3x`, SHA-256 `9f76f587…a0800b`. Empieza en la ronda 7
  con el héroe que recibe daño y se cura cada 0,03 s, y registro oculto.
- Scripts: `objetos_v14g.py`, `esfera_v14g.py`, `v14g.py`, `prueba_v14g.py`, `hacer-v14g.sh`,
  `entrar-v14g(-prueba).sh` y `leer-v14g.py`.
- Comprobado: pJASS de las dos copias. El script, los objetos, la mejora, los 9 iconos y el
  efecto salen idénticos al reextraer.
- Tope de vivos por dueño subido de 10 a 40, para que no corte antes que el tope por tipo ni
  que los refuerzos.

## Resultados de la prueba (ronda 7, un jugador)

Hubo dos ejecuciones de `TerrainDev-Titulo-v14g-prueba.w3x`. El registro se escribe en
`CustomMapData/lat`.

1. **Primera ejecución** (15:05). Encontró dos problemas:
   - los refuerzos ampliaban las entradas normales de tope 2, así que vivían 2 de un tipo
     en la primera llamada;
   - el jefe no saltó nunca. Con el héroe invulnerable, la IA sólo espera cerca y no
     llega al salto. Era un fallo de la copia de prueba, no del mapa.
2. **Corrección:**
   - una entrada de refuerzo por tipo (grupo 800 + tipo), cuyo tope sube con el número de
     llamada hasta 6;
   - el límite inferior del icono baja a 770: se dibuja unos 20 px por debajo del punto
     calculado y tapaba la consola;
   - en la prueba, el héroe recibe daño y se cura cada 0,03 s.
3. **Segunda ejecución** (15:12, hasta FIN), con el mapa corregido:
   - vivos por tipo: 3 normales y 1 élite;
   - el jefe sale con 1 por matar y 4400/4400 de vida;
   - el primer salto fue desde 6142 de distancia. Hubo 7 saltos en 150 s, uno cada unos
     21 s;
   - llamadas de refuerzos a los 22, 70, 116 y 162 s del jefe. Dejan 1, 2 y 3 vivos por
     tipo;
   - un tanque corrió con poca vida;
   - el icono se ve sólo con el jefe lejos, también cuando el héroe salta lejos.

4. **Ajustes del icono del jefe**, pedidos por el usuario con vídeo y capturas:
   - temblaba al moverse: tenía un reloj propio de 0,03 s, desfasado de la cámara. Ahora se
     coloca en `HealthBarsUpdate`, en el mismo tick de 0,01 s que la cámara (`DevJefe_Poner`);
   - márgenes a unos 6 px del borde de la vista. Para el centro del icono: x 25–1895,
     y 63–803, y 780 sobre el minimapa;
   - el panel de vida lo tapaba. El HUD no usa prueba de profundidad y se ordena por el plano
     de prioridad del material, que en el marco es 1–2. `JefeIcono*.mdx` pasa al plano 3;
   - esfera del tablero de estrategia alrededor del icono (`ubj0`, `JefeEsfera.mdx`, de
     `esfera_v14g.py`):
     - las esferas, que son billboard, se aplanan en su mitad frontal para que se vean
       redondas en cualquier borde; se quita el anillo oscuro, que no es billboard;
     - rubí con matiz 348°, conservando la saturación y el brillo de cada color;
     - planos de prioridad 4–5, delante del icono;
     - nace al aparecer;
   - centrado: el icono es billboard y su cuadro estaba desplazado de su origen, así que
     ningún desplazamiento fijo de la esfera servía en todos los bordes. El cuadro se centra
     en el origen, con sus extensiones, y los límites suben los +28/+23 px que tenía.
     El usuario lo confirmó correcto con captura.
5. **Impacto de balas**: las élites (×1,25) y los jefes (×1,8) escalan `ussc` y `ucol`
   (máximo 200) y se registran en `UnitHitShape` con esos valores. Antes usaban el `ucol` sin
   escalar del tipo original.
6. **Ejecución final** (02/11/2026, build anterior `e805ce5c…`, aún con tope por tipo; hasta FIN y después hasta la ronda 10, jugada por el
   usuario):
   - ronda 7: 1 jugador, 7 tipos, 22 entradas, 58 por matar;
   - el jefe nj07 salió con 4400/4400 a los 24 s, saltó 2 veces y llamó refuerzos una vez,
     que dejaron 1 vivo por tipo;
   - el usuario lo mató unos 50 s después de aparecer; a los 112 s quedaban 0 por matar y FIN a los 174 s;
   - rondas siguientes: nj08 con 5000, 2 llamadas; nj09 con 5600, 3 llamadas; nj0A con 6200.
     Las vidas cuadran con 800 × (1 + 0,75 × (ronda − 1)).

Pendiente: LAN de dos clientes (el icono y la esfera usan `GetLocalPlayer` sólo para el
alfa) y revisar el daño y la vida del jefe.
Fecha: 02/11/2026. Chat: Integration, único escritor del mapa.

## Base

- Mapa de partida: `work/titulo-devmission-20261026/TerrainDev-Titulo-v14f.w3x`
  (SHA-256 `4669d666…68ce8`). Script: `v14f/war3map.j`.
- Salida nueva: `TerrainDev-Titulo-v14g.w3x` y su copia `-prueba`, generadas con
  `scripts/v14g.py`, `scripts/objetos_v14g.py` y `scripts/hacer-v14g.sh`. Los originales de
  WaveSys no se tocan.
- Referencia de los refuerzos, sólo lectura:
  `/home/snz/Documentos/WarDatsPy/struct/WaveSysAnAI/AI/IAManager.j`
  (`AITryBossReinforcement`, `AIBossReinforcementApply`).
- Objetivo: Classic 1.27b. Sin Blz, Frame ni Lua.

## Lo que ya trae el mapa y se reutiliza

- **WaveCore:**
  - tope de vivos por entrada y dueño, y tope total por dueño;
  - entradas de jefe;
  - espera hasta que queden N por matar, con los jefes contados;
  - reparto escalado por jugadores (`WaveComputeScaledAmount`).
- **IA de WaveSys:**
  - `WaveAIEnableTeleport`;
  - `WaveAIEnableChaseSprint`: acelera cerca del objetivo;
  - `WaveAIEnableLowLifeHaste`: acelera con poca vida.
- **Sistema de interfaz:**
  - una cámara lógica por jugador (`Game_Cam[p]`), calculada en todos los clientes;
  - `world2Win` y `win2World`;
  - dummies de icono por jugador (`HealthBars__Dummy`), como el icono `'hbi0'` del HUD.
- **No existe un tope por tipo para todo el mapa.** No aparece en v14f ni en las dos copias
  de WaveSys. Se consigue con el reparto del punto 1, sin tocar WaveCore.

## 1. Tope de vivos por tipo y escalado por jugadores

> **Cambio del 02/11/2026, tras jugar v14g:** el usuario pidió quitar el tope por tipo, que con
> un jugador dejaba 3 vivos. Ahora cada tipo se reparte entre los 6 dueños, con el primero
> rotando, y cada entrada puede tener vivas todas las suyas. Sólo corta el tope de 40 por
> dueño. Siguen el escalado de totales, la élite con tope 1 y los refuerzos con tope min(k, 6).
> Lo que sigue describe el diseño original.

Problema medido: cada tipo se reparte entre 6 dueños con tope 10 por dueño, y sale una
unidad cada 0,25 s. En la ronda 1 salen las 18 en unos 4–5 s.

- **Tope por tipo:** `tope = 2 + jugadores activos`. Con 1 jugador son 3 y con 6 son 8.
- **Reparto del tope:**
  - el tope se divide entre los 6 dueños como tope por entrada (1 o 2 cada uno);
  - los dueños sin tope no reciben ese tipo;
  - la cantidad de la ronda se reparte en la misma proporción;
  - el primer dueño rota con cada tipo para equilibrar la carga.
- **Totales por ronda:** se escalan con los jugadores mediante `WaveComputeScaledAmount`,
  sumando un 50% por cada jugador extra (recomendado; WaveSys trae 100%). Con 6 jugadores
  son 3,5 veces la tabla `RONDAS`. Con 1 jugador, la tabla queda igual.
- Efecto: salen por goteo. Cuando muere una unidad, otra ocupa su sitio.

## 2. Élites ("unidades jefe")

- Una por cada tipo presente en la ronda, mezclada entre las normales. El número se escala
  con los jugadores como los totales.
- Hay 10 tipos nuevos de unidad, copias de su base con:
  - escala ×1,25;
  - tinte más oscuro (150, 150, 150);
  - daño +50% y vida +50%.
- Las habilidades amplificadas quedan para más adelante.
- **Acelerón permanente:** `WaveAIEnableChaseSprint`.
  - Distancia 500.
  - +40%: pasan de 270 a 378.
  - Duración muy larga y sin enfriamiento útil, para que no se apague.
  - El sistema la termina si la unidad se aleja; en la prueba compruebo que siga activa.
- **Tanques que corren:** `WaveAIEnableLowLifeHaste` con el 50% de vida y +40%.
  - Se aplica a `nmmu`, `ntrg` y `ntrd`, normales y élites.

## 3. Jefes

| Ronda | Jefe (tipo nuevo) | Vida con 1 jugador |
|---|---|---|
| 2 | nlpr | 1400 |
| 3 | ntrh | 2000 |
| 4 | nmtw | 2600 |
| 5 | nmsn | 3200 |
| 6 | nlds | 3800 |
| 7 | nmmu | 4400 |
| 8 | nnsw | 5000 |
| 9 | ntrg | 5600 |
| 10 | ntrd | 6200 |

- **Aparición:** un jefe por ronda desde la 2, del tipo nuevo de esa ronda.
  - Sale cuando quedan 0 normales: es una entrada de jefe que espera a que quede 1 por
    matar.
- **Objetos:** 9 tipos nuevos, copias de su base, con:
  - escala ×1,8 y daño ×2,5;
  - perfil `AI_PROFILE_BOSS`;
  - el icono de su unidad.
- **Vida:** base 800 × (1 + 0,75 × (ronda − 1)). La ronda 10 lleva 7,75 veces la base.
- **Multiplicador por jugadores, al final:**
  - es una mejora nueva con `rhpo` ("Hit Points %"), +100% por nivel;
  - sólo la llevan los jefes, en su campo de mejoras usadas;
  - al empezar cada ronda se fija en el nivel `jugadores − 1` para los 6 dueños;
  - ejemplo: con 3 jugadores, el jefe de la ronda 10 tiene 6200 × 3 = 18 600;
  - en la prueba compruebo la escala del valor (1,0 = 100%).
- **Teleport:** a la espalda de su objetivo.
  - Distancia aleatoria entre 150 y 450, desde cualquier distancia.
  - Cada 15–25 s.
  - Hay que añadir el rango aleatorio a la IA, que hoy sólo admite una distancia fija.
- **Refuerzos**, rehechos a partir de `IAManager.j`:
  - **Frecuencia:** la primera llamada a los 15–20 s; después, cada 40–50 s.
  - **Llamada:**
    - el jefe se detiene 1,5 s y hace una animación según su tipo, que compruebo en el
      visor;
    - sale el texto "llamando refuerzos" (1 texttag temporal);
    - efecto de carga `Bondage Blue SD.mdx` (70 KB, con texturas del juego), importado
      desde `WaveSys/resources/devmission-v096`;
    - al terminar, efecto de Resurrección.
  - **Unidades de cada llamada:**
    - 2 por tipo de la ronda, con tope de 1 vivo, así que llegan de una en una;
    - la llamada k las reparte entre los dueños 1..k: la primera, un dueño; la segunda,
      dos; y así hasta los 6 (decisión del usuario);
    - cada dueño recibe las suyas con tope 1 vivo por tipo. Si ya tiene una entrada de ese
      tipo, se amplía esa entrada y conserva su tope; así no se pasa del límite de 100.
  - **Escalado con jugadores:** 2 por tipo más un 50% por cada jugador extra, por dueño.
  - Si el jefe muere durante la carga, la llamada se cancela.

## 4. Localizador del jefe en el borde de la cámara

Se hace con el sistema de interfaz, igual que el icono del HUD.

- **Dummies:** uno por jugador y jefe vivo.
  - Es una copia de `'hbi0'` con el icono nativo de la unidad, por ejemplo
    `BTNMurgulTideWarrior.blp` o `BTNSeaTurtleRed.blp`.
  - Se crea con `HealthBars__Dummy(tipo, p)`.
  - Tamaño pequeño: unas 0,04 unidades de pantalla, la mitad del icono del HUD. Se ajusta
    en la prueba.
- **Posición:**
  - se calcula cada 0,03 s con la cámara lógica `Game_Cam[p]`, la misma en todos los
    clientes, así que `SetUnitX/Y` no desincroniza;
  - se proyecta el jefe con `world2Win`;
  - si cae fuera de la pantalla, el icono va al borde en la dirección centro → jefe;
  - se limita a x 70–1850 e y 110–800 de 1920×1080, para que no salga de la vista ni quede
    bajo la consola. Se lleva al mundo con `win2World`;
  - sólo lo ve su jugador: los demás lo tienen oculto en local, como el resto del HUD.
- **Cuándo se ve:** sólo con el jefe vivo y fuera de la pantalla de ese jugador, aunque esté
  bajo niebla. Al entrar en pantalla se oculta. Al morir el jefe se borra.
- **Coste:** 9 tipos de dummy de icono, uno por jefe. Con 6 jugadores, 6 dummies a la vez.

## 5. Barras de vida (texttags)

- Normales y héroes: +30 de altura. Enemigos a 150, héroes a 175.
- Élites y jefes, además: +100 × (escala − 1). Élites +25, jefes +80.

## Comprobaciones previstas

1. pJASS de v14g y de la copia de prueba.
2. Reextraer el script y los objetos y comparar hashes.
3. Partida de un jugador, por registros:
   - tope de 3 vivos por tipo, con relevo al morir uno;
   - el jefe aparece con 0 normales y con la vida esperada;
   - teleport cada 15–25 s, a 150–450;
   - refuerzos: 2 por tipo de uno en uno, cambiando de dueño en cada llamada;
   - élites y tanques aceleran.
4. Capturas, sólo para lo visual:
   - escala y tinte;
   - texto y efecto de los refuerzos;
   - icono en el borde y su tamaño;
   - altura de las barras.
5. **LAN de dos clientes:** el icono se oculta en local, así que hay que comprobar que no hay
   desincronización y que cada jugador ve su propio icono según su ángulo.
6. Sin registros ni rastreo en la versión final.

## Decisiones

**Del usuario:**

- tope por tipo de 3, que sube con los jugadores junto con totales y topes;
- un jefe por ronda desde la 2;
- vida del jefe +75% por ronda, sumado, y ×jugadores al final mediante la mejora;
- salto de 150–450 cada 15–25 s;
- refuerzos cada 40–50 s: 2 por tipo, tope 1, un dueño por llamada en rotación;
- icono sólo fuera de cámara, por jugador, pequeño, con el sistema de interfaz;
- altura de las barras propuesta;
- el resto, según lo recomendado.

**Elegido por mí, dentro de lo recomendado:**

- fórmula del tope y escalado del 50% por jugador;
- vida base 800;
- jefe ×1,8 de escala y ×2,5 de daño;
- valores de las élites;
- acelerón a 500 con +40%;
- lista de tanques;
- primera llamada a los 15–20 s;
- tope de vivos de los refuerzos con más jugadores;
- icono visible bajo niebla.

## Fuera de alcance

- Habilidades de élites y jefes.
- Prueba de la cámara de la tienda en el flujo real.
- Adaptación del bot.
