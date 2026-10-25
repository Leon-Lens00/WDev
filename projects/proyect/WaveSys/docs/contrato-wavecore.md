# Contrato público de WaveCore (sistema de oleadas)

Versión del rework (2026-10-25). Objetivo Warcraft III Classic 1.27b, vJASS. Fuente:
`src/WaveSysAnAI/SwlsWave/SwlsWave.j` (librería `WaveCore`, struct `Wave`). Este documento es la referencia para
integrar con el núcleo; lo que no aparece aquí es interno aunque vJASS obligue a dejarlo público.

## Dependencias y capas

| Librería | Papel | Requiere |
|---|---|---|
| `WaveCore` | Núcleo: Waves, slots, reservas, aparición, salidas, pausa, terminación, eventos | `Table`, `TimerUtils` |
| `WavePointGroups` / `WavePointApi` | Puntos desde unidades marcador | `Table`, `WaveCore` |
| `WaveSpawnFx` | Presentación: efectos de entrada (Reserve) y salida (Spawn) | `Table`, `WaveCore` |
| `WaveOwnerPolicy` | Política del mapa: dueños Player(8..12), escalado por jugadores, ayudantes de aparición | `WaveCore`, `WaveSpawnFx` |
| `WaveRestTimeBridge` | Fin de Wave → descanso de RestTime | `WaveCore`, `RestTimeEndFlow` |
| `WaveMultiboard` | Tablero de la Wave ligada | `WaveCore` y sistemas de UI |

El núcleo nunca depende de las capas; las capas y los consumidores (IA, rachas, habilidades) escuchan sus eventos.

## Ciclo de una Wave

```jass
local Wave w = Wave.create(perPlayerLimit, nearChancePercent, intervalSec, waveIndex, waveTotal)
call w.addPoint(x, y)              // puntos fijos (o WavePointGroupApplyToWave)
call w.addNearUnit(hero)           // referencias para aparecer cerca
call w.addSlotEx(...)              // o addSlot / addSlotGrouped / funciones de WaveOwnerPolicy
call WaveMultiboardBind(w, board)  // opcional
call WaveRestTimeBindNext(w, "NombreFuncionSiguiente") // opcional
call w.start()
```

- `create` normaliza: `perPlayerLimit >= 1`, `nearChancePercent` 0..100, `intervalSec > 0` (0,25 por defecto).
- `start` no hace nada si la Wave está destruida, ya arrancada o terminada.
- Fin natural: sin unidades por reservar, sin reservas y sin entidades vivas → evento Finish y destrucción.
- `terminate(killAlive)`: cancela lo no reservado; las reservas pendientes se cancelan al vencer su temporizador;
  con `killAlive` mata las vivas; termina (Finish + destrucción) cuando no queda nada.
- `destroyWave()` directo: destruye sin evento Finish (aborto silencioso) y libera reservas pendientes.
- `pause()` / `resume()`: la pausa congela nuevas reservas **y** las ya creadas (conservan su tiempo restante);
  en pausa solo se reconcilian retiradas.

## Slots

| Llamada | Uso |
|---|---|
| `addSlot(uId, amount, lim, prio, fxId, killGate, isBoss, owner)` | Slot simple |
| `addSlotEx(..., aiProfileId, laneId, behaviorFlags, threatWeight)` | Con metadatos de IA |
| `addSlotGrouped(slotGroupId, ...mismos que addSlotEx...)` | Con `slotGroupId > 0` amplía el slot del mismo grupo/dueño/tipo |

- `lim`: activas simultáneas del slot (mínimo 1). `prio`: cualquier entero; gana el mayor.
- `fxId`: dato opaco para la presentación (`WaveSpawnFx` usa 1..19; mayores se recortan a 19).
- `killGate`: -1 sin bloqueo; si no, el slot solo aparece cuando `toKillRemaining <= killGate`.
- Se rechazan sin contar: rawcode 0, cantidad <= 0, dueño nulo, más de 100 slots.

## Contadores públicos (solo lectura para consumidores)

| Campo | Significado |
|---|---|
| `remainingToSpawn` (`remainingUnits`, `remainingBosses`) | Por reservar |
| `activeOnMap` (`activeUnits`, `activeBosses`) | Reservas pendientes + entidades vivas |
| `pendingReservations` | Reservas aún sin materializar |
| `toKillRemaining` (`toKillUnitsRemaining`, `toKillBossRemaining`) | Objetivo restante (por morir o retirarse) |
| `killsDone` (`killsDoneUnits`, `killsDoneBoss`) | Muertes reales (las retiradas no cuentan) |
| `retiredCount` | Salidas sin muerte |
| `totalToSpawn`, `waveIndex`, `waveTotal`, `isRunning`, `isPaused`, `isFinishing`, `isDestroyed`, `waveToken` | Estado |

Invariantes verificados en laboratorio: `activeOnMap == pendingReservations + entidades indexadas` y
`toKillRemaining == remainingToSpawn + activeOnMap`.

## Unidades externas y retiradas

- `WaveRegisterExternalUnit(source, summoned, isBoss)`: registra una unidad creada fuera del núcleo en la Wave de
  `source`; amplía objetivo y activos. Doble registro ignorado.
- `WaveRetireUnit(u)`: retirada inmediata sin muerte (llamar antes de `RemoveUnit` si se quiere síncrona).
  Devuelve `false` si la unidad no está registrada o su salida ya se está procesando.
- Retirada automática: una unidad indexada eliminada por el motor (p. ej. `RemoveUnit`) se reconcilia en el siguiente
  tick, también en pausa y durante `terminate`.
- **Salida única**: cada unidad registrada recibe exactamente un evento Death (muerte o retirada); si un listener de
  Death intenta retirarla o matarla otra vez, se ignora.

## Eventos

Registro: `RegisterWave<Evento>Event(code)` con `Start`, `Pause`, `Resume`, `Finish`, `Reserve`, `Spawn`, `Death`,
`External`.

| Lectura de contexto | Válida en |
|---|---|
| `GetWaveEventWave()` | todos |
| `GetWaveEventUnit()`, `GetWaveEventSlot()`, `IsWaveEventBoss()`, `IsWaveEventExternal()` | Spawn, Death, External (Slot y Boss también en Reserve) |
| `GetWaveEventKiller()` | Death (null en retirada) |
| `IsWaveEventRetired()` | Death |
| `GetWaveEventUnitTypeId()` | Death (tipo registrado aunque la unidad ya no exista) |
| `GetWaveEventX()`, `GetWaveEventY()` | Reserve |

- Un evento disparado dentro de otro restaura el contexto exterior al terminar.
- Reserve se dispara cuando la reserva ya está completa (temporizador en marcha): un listener puede pausar o destruir.
- Regla para consumidores de Death: filtrar por `GetWaveEventUnitTypeId()`, no por `GetUnitTypeId(unidad)`
  (vale 0 si la unidad fue eliminada), y comprobar `IsWaveEventRetired()` si la salida no debe contar como baja.

## Consultas y utilidades

`GetWaveByUnit(u)`, `GetWaveSlotByUnit(u)`, `IsWaveManagedUnit(u)`, `w.getActiveIndexedCount()`,
`w.getActiveIndexedUnit(i)`, getters `getToKill*Remaining` / `getKillsDone*`, `isOperational()`,
`PauseWave`/`ResumeWave`, `TerminateWaveInstanceGraceful/ForceKill(waveId)`,
`BindWaveToUnitDeath`/`UnbindWaveFromUnitDeath` (la muerte del ancla termina la Wave).

## Interno (público solo por limitación de vJASS)

`releaseEntity`, `reconcileRetired`, `unlinkPending`, `cancelReservedSpawn`, `tryDestroyAfterTermination`,
`registerWaveUnit`, `untrackUnitByHandle`, `PendingSpawn_execute`, `Wave_onTick`, `onTick`, `trySpawn`, `pickSlot`,
`selectSpawnPoint`, `tryGetNearUnitPoint`, `getRandomPointIndex`. Los laboratorios usan algunos (`onTick`, `trySpawn`,
`pickSlot`) para forzar pasos; un consumidor de partida no debe llamarlos.

## Estado de partida (fuera del núcleo)

`isWavez`, `TargetWave` y `WaveTgg` (GameState) los escribe solo RestTime: `StartMatchCountdown(primeraFuncion)` al
empezar, `RestTimeLaunchCurrentWave` al lanzar cada oleada (`isWavez = true`) y `RestTimeOnWaveFinished` al terminar.
El stage y el resto de sistemas solo los leen.

## Refuerzos de jefe (IA ↔ stage)

IAManager decide cuándo un jefe pide refuerzos y ejecuta el proveedor registrado con
`AIRegisterBossReinforcementProvider(code)`; dentro, `AIGetBossReinforcementWave()` y
`AIGetBossReinforcementWaveIndex()` dan el contexto. El stage registra su composición (`Stage1RegisterBossReinforcements`,
desde `InitStage1`) y añade los slots con `WaveUpsertSlotExByPlayers`. Sin proveedor, la IA no añade nada.

## Límites conocidos

- Más de 4095 unidades indexadas por Wave no se reconcilian (`untrackedOverflow` lo cuenta).
- `SetTimerDebugTag`/`TIMER_DEBUG_TAG_WAVE_CORE` pertenecen al TimerUtils local del proyecto.
- Herencia de efecto: solo para unidades creadas con los ayudantes de `WaveOwnerPolicy`.
- Probado en laboratorios de un jugador; multijugador sin certificar.
