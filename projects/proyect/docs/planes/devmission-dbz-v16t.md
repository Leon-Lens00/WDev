# Dev Mission v16t-dbz: personajes DBZ de Battle Stadium D.O.N

Estado: **en curso** (12/11/2026; fase 1 y tanda 1 construidas). Prueba privada de Leon; no sustituye a v16t ni a v16t-ivan.

## Objetivo

- Traer los 16 personajes DBZ de Battle Stadium D.O.N 2.1a con todas sus habilidades.
- Entrar directo a una selección de personaje, sin título ni cartas de jefe, y probar cada uno en la partida.
- Las habilidades disparadas por script se rehacen sobre nuestro núcleo `Missile` (sin modificarlo; pertenece a
  otro chat). De DON se toman las recetas visuales, no su movimiento.
- Entrada «Créditos» en Misiones (F9) con los autores de todos los recursos ajenos usados en el mapa.

Criterio de aceptación: Leon elige cada personaje, aparece con su modelo, iconos y habilidades, y cada habilidad hace su
efecto. Estado por niveles: Validated (pJASS, reextracción por hash) antes que Tested in map (lo prueba Leon).

## Fuente

- `Proyect/work/battle-don-ref-20261112/descarga/BattlestadiumDON-2.1a.w3x`, SHA-256 `e2666e8b…d152f`, de Valkemiere.
  Última versión clásica para 1.27b. Descargada con permiso de Leon el 12/11/2026.
- `extraido/j.j` (script, 192 000 líneas, GUI convertido), `war3map.w3u`, `war3map.w3a`, `dbz-inventario.txt`.
- El archivo no trae listfile: los recursos se extraen por su ruta exacta, sacada del w3u/w3a/j y de los TEXS de
  cada modelo.

## Comparativa de misiles (decisión)

Nuestro `Missile` (BPower, timer 1/32, SetUnitX/Y, Z, reciclador, filtros por unidad/destructible/objeto) es mejor que
el movimiento de DON: DON usa `udg_Caster[$NNN]` de huecos fijos (no MUI), triggers periódicos a 0,04 s con
`SetUnitPositionLoc` y `GetUnitsInRangeOfLocMatching` (fugas de location y grupos), sin altura ni recargas.

Lo que sí se adapta de DON, en nuestra capa (`dbz.j`), sin tocar `Missile`:

1. Rayos en cadena: segmentos de un mismo modelo que crecen tras la cabeza del misil (Kamehameha, Galick Gun).
2. Limpieza de destructibles en la trayectoria (árboles).
3. Teletransporte e imagen residual (Instant Transmission, Afterimage).
4. Coreografía de animación del lanzador con `SetUnitTimeScale` y `SetUnitAnimationByIndex`.
5. Transformaciones (Power Up / Super Saiyan) por reemplazo de cabeza (`AId5` con modelo de cabeza) y cambio de tipo.

## Fases

1. **Selección y personajes** (esta entrega): los 20 tipos (16 elegibles + 4 formas: Goku God H0LF, Gotenks H02X,
   Golden Frieza H0LH, Great Ape H0J3) con rawcodes nuevos `HDz*`, sus 110 habilidades con ids `ADz*`/`AD*`, modelos,
   cabezas, iconos y texturas. Entrada directa y diálogo de 16 personajes; `-dbz` vuelve a abrirlo. Las habilidades de
   base nativa funcionan ya; las de script quedan marcadas en su descripción hasta su fase.
2. **Tanda 1**: Goku y Vegeta (Kamehameha, Warp Kamehameha, Galick Gun, Big Bang Attack, Final Flash, Power Up).
   Medido en DON: ~7 900 líneas de triggers (con la IA compartida) y ~90 tipos de dummy con modelo propio (Galick.mdl,
   SO2.mdl, SuperShinyThingy.mdl, valkkame2/3, IonCannonBeam, NuclearExplosion, FreezingRing…). Cada receta = cabeza
   en `Missile` + segmentos de rayo + explosiones; los dummies pasan a efectos/recursos del mapa, no a unidades.
3. **Tanda 2**: Gohan, Piccolo, Future Trunks, Gotenks.
4. **Tanda 3**: Gogeta, Vegito, Majin Buu, Kid Buu.
5. **Tanda 4**: Broly, Cell, Janemba, Frieza, Bardock, Goku Black.
6. Ajuste de daño a las oleadas de Dev Mission (por ahora valores de DON) y decisión sobre unidades no héroe.

## Cambio de método (12/11/2026, petición de Leon: «tal cual el mapa original», con nuestro sistema y sin prisa)

La tanda 1 (v16t-dbz1) usa recetas aproximadas: tiempos y daños estimados, menos dummies. No cumple «tal cual». Nuevo
método para todos los personajes, tanda 1 incluida:

1. **Objetos completos de DON** (`objetos_don.py`, desde la base v16t-ivan): las 110 habilidades con los mismos ids
   `Az00..` de la fase 1 y sus buffs propios (B01W, B01Z, B025, B05J → `Bz??`). Además, las ~52 habilidades auxiliares
   que los triggers dan a dummies o lanzadores y las ~35 de los propios dummies (`Az..` siguientes), y los 216 tipos de
   unidad dummy `h???` → `hD??`, con su modelo, escala, color, altura y animación.
2. **Trasplante mecánico del código** (`don_trasplante.py`): los 177 triggers de la familia DBZ, unas 20 000 líneas,
   cerrada por `gg_trg_` sin IA ni contadores. Renombra:
   - `Trig_X` → `Don_X`, `gg_trg_X` → `DonT_X`, `udg_V` → `DonV_V`, `gg_snd_S` → `DonS_S`;
   - rawcodes por las tablas de los objetos.

   Copia también las inicializaciones necesarias: InitGlobals de las variables usadas, los sonidos de InitSounds y las
   tablas `udg_Missile[]` y `udg_AllPlayer` de `Trig_Quest_Actions`. Sólo usa nativas y BJ: no depende de bibliotecas
   de DON.
3. **Motor Missile** (por personaje): los triggers periódicos de 0,04 s con `SetUnitPositionLoc` que mueven cabezas y
   proyectiles pasan a Missile (`s__Missile_createEx` con el propio dummy de DON, que no recicla porque no es 'dumi').
   Se conserva la coreografía: dummies, escalas, colores, `TriggerSleepAction`, sonidos, cámara y daño con su fórmula
   (`100 × nivel + k × atributo`).
4. Selección: cada personaje sólo para un jugador (las variables de hueco fijo de DON no son MUI y la regla de Dev
   Mission lo pide igual).

Orden de entrega: trasplante de todos los personajes con el movimiento original de DON (comprobación de fidelidad);
después, personaje a personaje, el cambio a Missile, empezando por Goku y Vegeta y siguiendo con Gohan, Piccolo,
Trunks y Gotenks.

Trasplante construido 12/11/2026: `TerrainDev-Titulo-v16t-don.w3x` SHA-256 `55d660885b3f…540404` (50,3 MB),
`hacer-v16t-don.sh`. **Validated**:
- pJASS correcto (j de 2,86 MB);
- j, w3u, w3a, w3h y los 350 recursos nuevos reextraídos idénticos;
- sólo 350 entradas nuevas y `mpq verify` ok.

Base v16t-dbz; v16t-dbz1 (recetas aproximadas) queda descartada. Lanzador `entrar-v16t-don.sh`. Sin probar en juego.
- Objetos: 219 unidades auxiliares (`hD??`, `nD??`, `uD??`), 77 habilidades auxiliares, 36 buffs `Bz??`.
- Código: 177 triggers y 2 555 funciones; sólo quedan activos los eventos de lanzamiento de habilidad, y los
  periódicos los activa cada habilidad como en DON.
- Recursos: NewMassiveEX y NuclearExplosion de DON van como `DON_*.mdx`, porque los del mapa (Ivan) son distintos.
- Faltan dentro del propio DON, así que allí tampoco se ven: Ultrabeam, BlueSun, JenembaSword, NormalAura,
  dummyGuanyu, Specialit.tga y varios iconos.
- Un personaje por jugador (`Dbz_Libre`).

Siguiente: Leon comprueba la fidelidad. Después, paso a Missile por personaje: los triggers `next_*` / periódicos con
`SetUnitPositionLoc` de la cabeza pasan a `s__Missile_createEx` con el dummy de DON.

Pendiente de decidir con Leon: las habilidades siguen a nivel 1 (en DON el héroe sube y aprende 1-4 niveles).

## Interfaces

- `Dbz_U[p]`: unidad DBZ de cada jugador; `ConversationUI___FollowCamera` la sigue cuando existe.
- El cuerpo MP5 (`Game_Hero`/`Game_Ctrl`) queda oculto, pausado e invulnerable mientras haya personaje DBZ.
- `Dbz_Init` al final de `main`: misión de créditos, diálogo, comando `-dbz`.

## Créditos (texto de la misión)

- Twilight's Eve ORPG: Donach y KryptonRazer (Final R4.13a); Green_Day_Dance y Asayaki_Zac ([AF] Final); Jem (Evo).
- Battle Stadium D.O.N 2.1a: Valkemiere (personajes DBZ, efectos, cámara lenta de definitiva).
- Vinz: Shots, Shot II, Firebrand, Chain Grenade, Valiant Charge, Windwalk, LightningBall, Ghost, Purple Star, Royal
  Glow, Flare. Vinz y Daemonic Sword: Daemonic Arrow.
- ShootingGay 0.7ENG: sonidos de disparo y avisos de habilidad.
- The_Silent: Dark Nights (ciclo día/noche).
- OVOgenez: Storm v1.3.1.
- BPower: Missile. Bribe: SpellEffectEvent, Table. Magtheridon96: RegisterPlayerUnitEvent. Nestharus: código de
  depuración de List. leandrotp: AbilitySilence. Vexorian: dummy.mdx, JassHelper.
- Anomines (Kai Trausenegger): mapa base.
- Pendiente de confirmar antes de añadir: autores de InventorySys 1.4.1 (iconos de inventario) y de los modelos DBZ
  sueltos que DON no acredita en su propio mapa (DON cita «byValkemiere», «byKitabatake» en nombres de archivo).

## Estado

- Fase 1 construida 12/11/2026: `TerrainDev-Titulo-v16t-dbz.w3x` SHA-256 `70c2d7e1…65293` (47,9 MB). **Validated**:
  pJASS correcto, j/w3u/w3a y los 127 recursos reextraídos idénticos por hash, sólo 130 entradas nuevas, `mpq verify` ok.
  Lanzador `scripts/entrar-v16t-dbz.sh`. Sin probar en juego.
- Faltan en el propio DON 2.1a (no importados): Zamas.mdl (Goku Black), BlueSun.mdx, JenembaSword.mdx y 3 iconos
  (BTNAvatarOn, BTNBundleOfLumber, BTNDoom). DON no trae iconos DISBTN.
- No cubierto: barra de vida del HUD sigue al cuerpo MP5 oculto; daño con valores de DON a nivel 1.
- Tanda 1 construida 12/11/2026: `TerrainDev-Titulo-v16t-dbz1.w3x` SHA-256 `226141720f04…62b3d3` (`hacer-v16t-dbz1.sh`,
  `dbz_t1.j` vía `dbz_t1.py`, 46 recursos de `recursos_dbz_t1.tsv`). **Validated**: pJASS correcto, j y recursos
  reextraídos idénticos, sólo 46 entradas nuevas, `mpq verify` ok. Sin probar en juego. Lanzador `entrar-v16t-dbz1.sh`.
  - Familia Missile propia `DBZT_SID` = 200 (iteración como el módulo MissileStruct, sin tocar la biblioteca). Cabeza
    del rayo = Missile; segmentos cada 2 tics = efecto sobre dummy del reciclador (máx. 40 por rayo), se sueltan al
    acabar. Golpe una vez por unidad con `hitWidget`.
  - Goku: Kamehameha (carga 0,8 s, 220 + explosión 120), Warp Kamehameha (detrás del objetivo y disparo corto),
    Dragon Fist (vuela con el misil, 350 + 300), Spirit Bomb (carga 2 s, cae desde 300 de altura, 900 en 600),
    Power Up (SSJ, SSJ3, SSJ4 y vuelta a normal). Vegeta: Galick Gun (200 + 100), Big Bang (80 + 280 en 350),
    Final Flash (carga 1,2 s, 300 + 450 en 450), Final Explosion (1 s, 600 en 650), Power Up (Blue). Cada forma
    +25 % de daño; cambiar de personaje la reinicia.
  - No cubierto: limpieza de árboles (falta saber qué destructibles del terreno son árboles sin romper bloqueadores),
    nombres de animación de DON no comprobados en los modelos, las bases nativas siguen activas (AOvd de Power Up
    canaliza 10 s como en DON; AOsw invoca un ward de 0,01 s).
