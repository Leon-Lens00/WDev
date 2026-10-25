# Plan: WaveSys con conexiones limpias (rework)

Fecha: 2026-10-24. Agente: Claude (chat WavSys). Estado: **Fase 1 completada y aprobada por Judgment Day; Fase 2 (integraciones) pendiente**.
Objetivo Classic 1.27b, vJASS. Base: `src/WaveSysAnAI/SwlsWave/SwlsWave.j` con E02/E03/E06/E07/E08/E09/E11/E13/E14
resueltos (ver `ciclo-vida-e13-e03-e02-2026-10-24.md`).

## Objetivo

Que el núcleo de oleadas sólo dependa de utilidades genéricas y exponga eventos. Todo lo que hoy es política de
partida (descansos, tablero, jugadores, efectos visuales, configuración del mapa) pasa a adaptadores que escuchan los
eventos o configuran la Wave desde fuera. Criterio de aceptación: el núcleo compila sin TheEnd, sin multiboard y sin
`ExecuteFunc`; los laboratorios dejan de necesitar el `endF` vacío; las regresiones actuales pasan con adaptadores.

## Clasificación (evidencia: lectura de `SwlsWave.j` y búsqueda en `src/` activo, 2026-10-24)

### Dependencias que se quedan

| Dependencia | Uso real en el núcleo | Decisión |
|---|---|---|
| Table | 12 tablas (unidad→Wave, slot, índice, tipo, externas...) | **Se queda** |
| TimerUtils | `NewTimer`/`ReleaseTimer`/`SetTimerData`/`GetTimerData` (tick y reservas) | **Se queda**. `SetTimerDebugTag`/`TIMER_DEBUG_TAG_WAVE_CORE` son una extensión local de TimerUtils: se conserva, aislada en un punto |
| Nativas Classic (`GetRandomInt`, `IsTerrainPathable`, `CreateUnit`...) | spawn y punto cercano | **Se quedan** (common.j) |
| `UnitAlive` | `killAllTrackedUnits`, punto cercano | **Sustituida** por `not IsUnitType(u, UNIT_TYPE_DEAD)` (mismo significado para unidades existentes): el núcleo ya no la necesita |

### Dependencias y conexiones que se apartan para rework

| Conexión actual | Problema | Destino propuesto |
|---|---|---|
| `requires SwlsMath` | Ninguna de sus 3 funciones se usa | **Eliminar** del `requires` |
| `requires TheEnd` + `endF(finishFuncName)` | Dependencia hacia arriba con nombre en texto; duplica el evento Finish | **Adaptador RestTime**: escucha Finish y llama a `RestTimeOnWaveFinished`. El núcleo deja de conocer TheEnd |
| Multiboard en la Wave (`board`, `titleFunc`, `WaveByBoard`, `refreshBoard`, `ExecuteFunc`, `CurrentBoardContext`) | Presentación dentro del núcleo; llamada por nombre no verificable | **Adaptador de tablero**: refresca por eventos (Start/Spawn/Death/Pause/Resume/Finish) |
| Recuento de jugadores (`WaveCountPlayingUsers`) y escalado por jugadores | Política de partida dentro del núcleo | **Entrada de configuración**: el stage pasa el número de jugadores o un escalado ya calculado |
| Dueños por defecto 8-12 (`WAVE_DEFAULT_OWNER_*`, `WaveIsDefaultOwnerPlayerId`, `pickDefaultOwnerPid`, `addSlot*ByPlayers`) | Constantes del mapa en el núcleo; WaveStreaks depende de `WaveIsDefaultOwnerPlayerId` | **Configuración del mapa** (rango definido fuera) |
| Rutas de efectos (`InitFX`, `FX_UnitIn/Out`) | Recursos del mapa cableados | **Configuración de presentación**; el núcleo conserva sólo `fxId` como dato del slot, o emite el evento y el adaptador pinta |
| Ayudantes públicos sin consumidores (`WaveSpawnUnitFromDefault*`, `WaveCanSpawnUnitFromDefaultOwnerPid`, `WaveGetSpawnFxIdForUnit`, `TerminateWaveInstance*`, `BindWave*`) | Sin uso en código activo (sólo fixtures); puede haber triggers del mapa no cubiertos | **Decidir**: conservar los genéricos (terminate/bind), mover los de dueños por defecto con su política |
| `WavePointGroupsConfig` (rects, `'l00A'`) | Configuración del mapa | **Capa de mapa**; `WavePointGroups`/`WavePointApi` se quedan en el sistema |
| Stages (`stage1`/`StageExample`) | Componen IA, HeroLives, Tender, tablero... | **Capa de composición** (montaje de partida); fuera del núcleo |

### Consumidores que no cambian de dirección

IAManager, WaveStreaks y las 9 habilidades ya dependen del núcleo por eventos, nunca al revés. Se mantienen, salvo
`WaveIsDefaultOwnerPlayerId` (WaveStreaks), que seguirá a la configuración de dueños.

## Fases

| Fase | Entregable | Comprobación |
|---|---|---|
| 0 | Decisiones abajo | — |
| 1 | Núcleo limpio: fuera SwlsMath, TheEnd/`endF`, multiboard/`ExecuteFunc`, recuento de jugadores; `UnitAlive` declarada en librería propia; FX y dueños por configuración | Compila aislado con Table, TimerUtils y la librería de nativas, **sin** el `endF` vacío del lab |
| 2 | Adaptadores: RestTime↔Finish, tablero↔eventos, configuración de dueños/FX/jugadores, stage adaptado | Build completo de 114 fuentes compila y valida |
| 3 | Regresiones con run-id nuevos: Lifecycle, Pause, Feature, Core, Removal, Table, RestBoard, Integration, Survival | Mismos resultados que hoy (Survival 67/0, 518/518; RestBoard 0 títulos ajenos) |
| 4 | Documentación del contrato público (eventos, retirada, `GetWaveEventUnitTypeId`) y traspaso | — |

Archivos previstos: `SwlsWave.j`, librería nueva de nativas, adaptadores nuevos en `SwlsWave/`, `RestTime*`,
`WaveMultiboard.j`, `StageExample.j`, `WaveStreaks.j` (sólo la llamada de dueños), fixtures y builders que crean Waves.

## Decisiones del usuario necesarias (Fase 0)

1. **Firma de `Wave.create`**: hoy recibe tablero, función de título y función de fin. Recomendado: firma limpia sin
   esos tres parámetros y actualizar stage y fixtures. Alternativa: conservarlos ignorados (compatibilidad, más ruido).
2. **Ayudantes sin consumidores**: recomendado conservar terminate/bind (genéricos) y mover los de dueños por defecto a la
   configuración del mapa. Si algún trigger del mapa original los usa, hay que saberlo antes.
3. **Efectos de entrada/salida**: recomendado que el núcleo emita el evento y un adaptador de presentación cree el efecto
   (núcleo sin rutas de modelos). Alternativa: tabla de rutas configurable leída por el núcleo.

## Límites

La búsqueda no cubre llamadas por cadena ni triggers del mapa original. RestTime, tablero y stages son frontera de partida:
se tocarán sólo en lo necesario para conectarlos por eventos, sin rehacer su lógica. Multijugador sigue sin certificar.

## Decisiones del usuario (2026-10-24)

Aprobadas: firma limpia de `Wave.create(perPlayerLimit, nearChance, interval, waveIndex, waveTotal)`; conservar los
ayudantes genéricos (terminate/bind); mover los de dueños por defecto a `WaveOwnerPolicy`; efectos mediante adaptador
de presentación (`WaveSpawnFx`, evento Reserve con posición).

## Resultado de la Fase 1

Núcleo `requires Table, TimerUtils`; capas nuevas `WaveSpawnFx.j` y `WaveOwnerPolicy.j`; `addSlotGrouped`; evento
Reserve + `GetWaveEventX/Y`. Laboratorios del núcleo sin borde artificial: Lifecycle 49/0, Pause 17/0, Feature 44/0,
Core 16/0, Removal finished=1. Evaluación y Judgment Day: `docs/evaluacion-nucleo-limpio-2026-10-24.md`;
evidencia `evidence/rework-phase1-change.json`, `evidence/jd-rework-phase1.json`.
Cambios de comportamiento aceptados: Finish no se emite en `destroyWave` directo; fxId opaco (sin recorte a 19);
herencia de efecto sólo por los ayudantes de WaveOwnerPolicy (hallazgo abierto: decidir si se restaura en la Fase 2).

## Fase 2: integraciones (orden acordado con el usuario el 2026-10-25)

Copia local previa: `evidence/snapshot-rework-fase1-20261025/` (manifiesto con hashes).

| Prioridad | Integración | Estado |
|---|---|---|
| 1 | Blindaje de salida única en el núcleo | **Hecho**: `p1-lifecycle-v1` 57/0 (`evidence/integ-p1-change.json`) |
| 2 | Stage (`StageExample.j`/`stage1`): firma nueva, `WaveOwnerPolicy`, ligado a RestTime y tablero | **Hecho y probado** en P7: `WaveMultiboardBind` y `WaveRestTimeBindNext` quedan como interfaz de las prioridades 4 y 3 (`evidence/integ-p2-change.json`) |
| 3 | Adaptador RestTime ↔ Finish (solo Waves ligadas por el stage): librería `WaveRestTimeBridge`, `WaveRestTimeBindNext(w, nombre)` | **Hecho**: `WaveRestTimeBridge.j`; supervivencia encadena 10 oleadas |
| 4 | Tablero (`WaveMultiboard.j`/`BMT1`) por eventos, sin `ExecuteFunc`/`CurrentBoardContext`/`WaveByBoard`; `WaveMultiboardBind(w, mb)` | **Hecho**: `WaveMultiboardBind` con refresco propio de 0,25 s; RestBoard 0/1800 |
| 5 | IAManager: `WaveUpsertSlotExByPlayers` (10 usos); revisar luego quién posee los refuerzos | **Hecho**: 10 llamadas migradas y `refreshBoard` retirado |
| 6 | WaveStreaks: `requires WaveOwnerPolicy` | **Hecho** |
| 7 | Build de 114 fuentes y laboratorios de integración | **Hecho**: 117 fuentes compilan; supervivencia 67/0, RestBoard 69/0, Integration 25/0, Table 34/0, ResourceSkills 28/1 (E12) |

Las prioridades 2-6 deben completarse juntas para que el build vuelva a compilar.

Resultado de la Fase 2 (2026-10-25): la partida completa vuelve a funcionar con el núcleo limpio. Evidencia
`evidence/integ-p3p7-change.json`. Cambios de comportamiento: el tablero sigue refrescando en pausa; RestTime se activa
dentro del evento Finish.

Estado de las fases del plan (2026-10-25): 0, 1 y 2 hechas; la 3 (regresiones) se cumplió con la prioridad 7; la 4
(contrato público) está en `docs/contrato-wavecore.md`.

## Organización y nombres (2026-10-25, autorizado por el usuario)

Copias previas en `evidence/fase3-before/` (y `names/` para el renombrado).

| Paso | Cambio | Estado |
|---|---|---|
| Higiene | 17 globales del núcleo con valor inicial; `start()` rechaza una Wave ya terminada (JD-A-006); `WaveSpawnFx` vuelve a recortar fxId > 19 (JD-B-002) | Hecho |
| Nombres | Librería `WaveTest` → `WaveCore` (26 `requires`); función global `registerExternalUnit` → `WaveRegisterExternalUnit` (el método de Wave conserva su nombre); `totalKilled*` → `toKillRemaining*` (100 cambios en 26 archivos) | Hecho |
| Stage | `Trig_w1_Actions` orquesta; presentación en `Stage1PlayIntro(waveIndex)` y composición en `Stage1AddSlots(w, waveIndex)` (código movido sin cambios); fuera una local sin uso | Hecho |
| Builder | Fuera la opción obsoleta `--initialize-death-slot` (diagnóstico de E02); mensaje de error con la ruta real (JD-A-008/JD-B-006) | Hecho |
| Regresión | Lifecycle 57/0, Pause 17/0, Feature 44/0, Core 16/0, Removal finished=1, Integration 25/0, Table 34/0, ResourceSkills 28/1 (E12) | Hecho; supervivencia 67/0 (518/518) y RestBoard 69/0 (0/1800). Evidencia `evidence/fase3-organizacion-change.json` |

## Decisiones abiertas (requieren al usuario; no se cambian sin acuerdo)

- ~~Dueño único de `isWavez`/`TargetWave`/`WaveTgg`~~ **Resuelto (2026-10-25)**: RestTime es el único escritor (`RestTimeLaunchCurrentWave`, `RestTimeOnWaveFinished`, `StartMatchCountdown`); supervivencia 77/0, RestBoard 79/0 (`evidence/owner-globals-change.json`).
- ~~Refuerzos del jefe compuestos por IAManager~~ **Resuelto (2026-10-25)**: la IA solo pide (`AIRegisterBossReinforcementProvider`, `AIGetBossReinforcementWave/WaveIndex`) y el stage compone (`Stage1AddReinforcements`); ReinforcementAudit 7/0, supervivencia 77/0 (`evidence/reinforce-change.json`).
- Herencia de efecto en `WaveRegisterExternalUnit` directo y limpieza del fxId heredado dentro de Death (JD-A-002/003/004):
  sin consumidores activos hoy; restaurarla exige pasar la unidad origen en el evento External.
- E12 (aura): apartado por decisión del usuario; entra en el rework propio de habilidades.

## Siguiente paso

Rework del sistema de oleadas completo salvo las decisiones abiertas de arriba. Opcional: actualizar el repositorio
WDev con este estado (requiere petición expresa del usuario).
