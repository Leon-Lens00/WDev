# Importar Rapid Fire a otro mapa

Guía para llevar las ráfagas (Firebrand, Shots I y II), el alcance fijo y el efecto Windwalk a otro mapa de Warcraft III Classic 1.27b con vJASS.

**Alcance de esta guía:** describe lo que usa TerrainDev (`RapidFire 1.8.1`, mapa `maps/work/rango-20261028b/TerrainDev-rango.w3x`). Ese mapa compila, pasa pjass y se probó a mano en un cliente. El traslado a *otro* mapa con estos pasos no se ha ensayado, ni tampoco el multijugador.

Necesitas JassHelper (NewGen, YDWE o similar). El mapa de destino no debe usar ya los rawcodes de abajo; si alguno choca, cámbialo en el objeto y en el código.

## 1. Copiar el código

Pega cada archivo de `src/libraries/` en un disparador de texto personalizado, en este orden:

| # | Archivo | Para qué |
|---|---|---|
| 1 | `WorldBounds.j` | Límites del mapa |
| 2 | `ErrorMessage.j` | Mensajes de error de Missile en modo debug |
| 3 | `TimerUtils.j` | Timers |
| 4 | `Table.j` | Tablas |
| 5 | `RegisterPlayerUnitEvent.j` | Eventos |
| 6 | `SpellEffectEvent.j` | Evento de habilidad |
| 7 | `IsDestructableTree.j` | Detectar árboles |
| 8 | `MissileRecycler.j` | Reciclar dummies. Conserva la corrección local: no sustituir por la versión pública |
| 9 | `Missile.j` | Vuelo de los proyectiles |
| 10 | `UnitHitShape.j` | Cuerpo de impacto por tipo de unidad |
| 11 | `GroundCollision.j` | Colisión con terreno y unidades |
| 12 | `GroundMotion.j` | Movimiento artificial |
| 13 | `RapidFire.j` | La ráfaga y el Windwalk |

Opcionales: `MissileDiagnostics.j` (panel `-misiles`; si la usas, va antes de `MissileRecycler`). `RapidFireDemo.j` es sólo el laboratorio: no lo copies, pero sirve de ejemplo. `DummyCaster.j` y las bibliotecas `X3*` no hacen falta.

Usa las copias de este proyecto, no las de otros sistemas llamados Missile: `libraries.json` guarda la versión y el hash de cada una.

## 2. Crear los objetos

Los valores exactos están en `scripts/rapid_objects.py` y `scripts/shots_objects.py`. Puedes copiarlos desde `TerrainDev-rango.w3x` con el editor de objetos.

| Rawcode | Tipo | Base | Claves |
|---|---|---|---|
| `dumi` | Unidad | Definida en `assets/dumi.w3u` | Dummy de Missile, modelo `war3mapImported\dummy.mdx` |
| `rfct` | Unidad | Fusilero `hrif` | **Controlador**: colisión 0, velocidad 350, habilidades `Arpf,Arp1,Arp3,Avul` |
| `rfex` | Unidad | Fusilero `hrif` | **Actor visible**: colisión 24, velocidad 350, sin habilidades |
| `Arpf` | Habilidad | Channel `ANcl` | Firebrand, tecla Q, orden `channel` |
| `Arp1` | Habilidad | Copia de `Arpf` | Shots I, tecla W, orden `carrionswarm` |
| `Arp3` | Habilidad | Copia de `Arpf` | Shots II, tecla R, orden `breathoffire` |

Para las tres habilidades: objetivo de punto, alcance 90000, sin coste ni cooldown, tiempo de lanzamiento 0. El alcance alto evita que la unidad camine antes de disparar; la distancia del misil la fija el código.

Si no usas alguna familia, puedes omitir su habilidad, pero no sus líneas en `RapidPair.initialize`: registrar un rawcode inexistente no falla, y dejarlo evita tocar `RapidFire.j`.

`GroundCollision` también usa el ítem nativo `wolg` para consultar el terreno: no lo elimines del mapa.

`rfct` y `dumi` están excluidos de los impactos por rawcode en `GroundCollision.j`. Si les cambias el rawcode, cámbialo también ahí.

## 3. Importar los modelos

Importa estos archivos **con la ruta interna exacta** (columna «Ruta en el mapa»). El gestor de importación suele añadir `war3mapImported\`: hay que quitarlo.

| Origen en `assets/` | Ruta en el mapa | Archivos |
|---|---|---|
| `dummy.mdx` | `war3mapImported\dummy.mdx` | 1 |
| `firebrand-shots/FirebrandShots/` | `FirebrandShots\…` y texturas en la raíz | 14 |
| `shots-ajustados/ShotsAjustados/` | `ShotsAjustados\…` | 12 |
| `windwalk-colores/Windwalk/` | `Windwalk\…` | 15 |

La lista exacta de rutas y hashes de cada grupo está en su `manifest.json`, campo `imports` (`internal` es la ruta en el mapa). Las texturas `Ghost2 <color>.blp` son necesarias: sin ellas los seis colores nuevos no se ven bien. No importes `shots-originales` ni `windwalk-originales`: sólo son la entrada de los scripts.

Créditos: los modelos son de Vinz. Conserva los HTML de `assets/firebrand-shots`, `assets/shots-originales` y `assets/windwalk-originales`.

## 4. Crear la pareja de unidades

Cada personaje son dos unidades: el jugador controla un **controlador** invisible y ve al **actor**. Haz esto después de iniciar el mapa, por ejemplo con un timer de 0 segundos:

```jass
local unit actor = CreateUnit(Player(0),'rfex',x,y,0.)
local unit controller = CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.)
local RapidPair pair
call SetUnitVertexColor(controller,255,255,255,0)
set pair = RapidPair.create(controller,actor)
if GetLocalPlayer() == Player(0) then
    call ClearSelection()
    call SelectUnit(controller,true)
    call SetCameraTargetController(actor,0.,0.,false)
endif
```

Crea y destruye unidades siempre fuera del bloque `GetLocalPlayer`. El ejemplo completo está en `RapidDemo.setup` (`RapidFireDemo.j`).

El actor puede ser otra unidad o un héroe, pero `RapidPair` controla su pathing y su velocidad de animación durante la ráfaga.

## 5. Registrar las unidades de tu mapa

Abre `UnitHitShape.j` y añade en `initialize` cada tipo que deba recibir impactos con su círculo de selección:

```jass
call register('hfoo',1.,31.) // rawcode, escala de selección, colisión
```

Los tipos sin registrar usan su colisión nativa. Es válido, pero el impacto no coincidirá con el círculo de selección.

## 6. Comprobar

1. Compila el mapa y arregla cualquier error de JassHelper antes de abrir el juego.
2. Lanza Q, W y R: deben salir 6 misiles, el primero al instante y luego uno cada 0.25 s.
3. Dispara cerca y lejos: el misil debe recorrer 1350 en ambos casos.
4. Clic derecho durante la ráfaga: el actor se mueve y sigue apuntando a la misma dirección.
5. Windwalk debe aparecer en los pies al empezar y apagarse al terminar.
6. Si ves cuadros negros, la textura `Ghost2` no es la de este proyecto. Si no ves el misil o el efecto, revisa la ruta interna.

## Ajustes habituales

| Qué | Dónde |
|---|---|
| Alcance | `RapidBolt.RANGE` en `RapidFire.j` |
| Daño | `UnitDamageTarget` en `RapidBolt`, valor `25.` |
| Velocidad del misil | `m.setMovementSpeed(1200.)` en `shootFamily` |
| Intervalo | `RapidPair.INTERVAL` |
| Color de una unidad | `pair.setColor(PLAYER_COLOR_BLUE)`, y `pair.clearColor()` para volver al del jugador |
| Punto de anclaje de Windwalk | `"origin"` en `RapidPair.showWalk` |

Los proyectiles vuelan a ras de suelo y terminan al chocar con un desnivel. Es intencional.

Más detalle: [mecánica](rapid-fire.md) y [colores](misiles-colores.md).
