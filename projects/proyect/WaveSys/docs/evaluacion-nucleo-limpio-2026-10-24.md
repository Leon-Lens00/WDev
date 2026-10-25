# Evaluación del núcleo de oleadas limpio (rework fase 1)

Fecha: 2026-10-24. Evaluador: Claude (chat WavSys). Base: `src/WaveSysAnAI/SwlsWave/SwlsWave.j`,
`WaveSpawnFx.j`, `WaveOwnerPolicy.j` (hashes en `evidence/rework-phase1-change.json`). Plan:
`docs/planes/rework-conexiones-wavesys-2026-10-24.md`. Estado más fuerte alcanzado: **Tested in map** (laboratorios
aislados del núcleo, un jugador). Build completo de 114 fuentes: **no compila todavía** (integraciones pendientes).

## Qué se verificó

| Ensayo 1.27b | Resultado |
|---|---|
| LifecycleAudit `rw1b-lifecycle-v1` | 49/0 (ciclo de vida, retirada, invariantes I1/I3) |
| PauseAudit `rw1b-pause-v1` | 11/0 (pausa congela reservas) |
| FeatureAudit `rw1b-features-v1` | 44/0 (incluye evento Reserve con posición y fxId como dato opaco) |
| CoreAudit `rw1b-core-v1` | 16/0 |
| RemovalAudit `rw1b-removal-v1` | active=0 tracked=0 finished=1 |

Compilados sin el `endF` vacío ni la `UnitAlive` inyectada: el núcleo ya no los necesita. El primer intento (`rw1-*`)
falló por una global de evento leída sin inicializar; corregido antes de estos resultados.

## Dependencias resultantes

`WaveTest` requiere sólo **Table** y **TimerUtils**. `WavePointGroups` requiere Table y WaveTest. Las capas nuevas
dependen del núcleo, nunca al revés: `WaveSpawnFx` (presentación: Table, WaveTest) y `WaveOwnerPolicy` (política del
mapa: WaveTest, WaveSpawnFx).

## Hallazgos

| # | Clase | Hallazgo | Recomendación |
|---|---|---|---|
| H1 | ERROR (esperado) | Integraciones rotas hasta la fase 2: `StageExample` (firma de `create`, `*ByPlayer(s)`, `setAdditionalPerPlayerPercent`: 29 usos), `IAManager` (`upsertSlotExByPlayers`: 10-11 usos), `WaveMultiboard` (`board`/`WaveByBoard`/`CurrentBoardContext`: 46 usos), `WaveStreaks` (`WaveIsDefaultOwnerPlayerId`, ahora en WaveOwnerPolicy sin `requires`), y RestTime ya no recibe `endF`: sin adaptador no se encadenan los descansos | Fase 2: adaptadores y migración de llamadas |
| H2 | WARNING | 16 globales del núcleo (Tables y triggers de evento) se declaran sin valor inicial. Hoy es seguro porque `Init` las asigna antes de cualquier lectura, pero es la misma clase de fallo que rompió `rw1-*` | Inicializarlas a `0`/`null` en la declaración |
| H3 | WARNING | Superficie pública amplia: métodos internos accesibles (`releaseEntity`, `reconcileRetired`, `unlinkPending`, `cancelReservedSpawn`, `tryDestroyAfterTermination`, `registerWaveUnit`, `untrackUnitByHandle`, `trySpawn`, `onTick`, `pickSlot`, `PendingSpawn_execute`, `Wave_onTick`). Un consumidor podría romper invariantes. Algunos los usan los laboratorios | Declarar el contrato público y marcar el resto como interno (o privado con accesos de laboratorio explícitos) |
| H4 | WARNING | `SetTimerDebugTag`/`TIMER_DEBUG_TAG_WAVE_CORE` son una extensión local de TimerUtils: con un TimerUtils estándar el núcleo no compila | Aislar esas dos llamadas (p. ej. `static if` o envoltorio opcional) |
| H5 | Cambio de contrato | Finish se emite en el fin natural y al completar `terminate`; un `destroyWave` directo no lo emite (antes podía llamar `endF`). En el código activo nadie llama a `destroyWave` fuera del núcleo | Documentado en la cabecera; el adaptador de RestTime debe escuchar Finish |
| H6 | Cambio de comportamiento | `fxId` mayor que 19 ya no se recorta a 19: el núcleo lo guarda tal cual y la presentación no pinta ids desconocidos. La herencia de efecto en `registerExternalUnit` directo se pierde; se conserva en los ayudantes de WaveOwnerPolicy | Aceptado; anotar en el contrato |
| H7 | STYLE | Nombres heredados poco uniformes: librería `WaveTest`, función global `registerExternalUnit` en minúscula junto al método homónimo, `totalKilled` significa «objetivo restante» | Renombrar sólo junto con la fase 2 para no romper consumidores dos veces |
| H8 | PERF | El barrido de retiradas recorre el índice en cada tick (intervalo típico 0,25 s). Coste lineal en unidades activas; sin medición de rendimiento | Medir con carga si se usan oleadas grandes |

## Valoración

El núcleo cumple el objetivo de la fase 1: sólo depende de utilidades genéricas, expone eventos suficientes para
presentación, descansos e IA, y mantiene todos los contratos verificados (ciclo de vida, retirada, pausa, reciclaje,
contexto de eventos). Los riesgos reales están en H1 (la partida no funciona hasta conectar los adaptadores) y en la
robustez de inicialización y superficie pública (H2, H3). H4-H8 son mejoras o cambios conscientes.

No acredita: build completo, flujo de partida, multijugador, rendimiento con carga.

## Revisión adversarial (Judgment Day, 2 jueces independientes)

Copia congelada `6be7e381…54b1` (17 archivos). Los dos jueces confirmaron, de forma independiente, un defecto grave que
mi evaluación no había visto: **el evento Reserve se disparaba antes de asignar el temporizador de la reserva**, de modo
que un listener que pausara o destruyera la Wave actuaba sobre un temporizador ajeno o reciclado (posible doble
liberación). Corregido en la ronda 1 (Reserve como último paso; `ps.t = null` al liberar) y verificado por ambos jueces
sobre la copia `3c947c49…74ca`; PauseAudit ampliado con reentrada desde Reserve: `rw1c-pause-v2` 17/0. Tras la
corrección: Lifecycle 49/0, Feature 44/0, Core 16/0, Removal finished=1.

Hallazgos no graves que quedan abiertos (detalle en `evidence/jd-rework-phase1.json`):
- Efectos: la herencia de fxId en `registerExternalUnit` directo se perdió; fxId > 19 ya no se recorta; el fxId heredado
  se borra dentro del listener de Death antes que otros listeners; posibles entradas obsoletas tras `destroyWave`.
- Contrato: doble salida si un listener de Death retira o mata la misma unidad (ya existía); `start()` tras `terminate`
  en una Wave nunca iniciada.
- Cobertura: el camino del token reciclado no se ejercita (destroyWave libera antes); sin prueba directa de la capa de
  efectos ni de fugas de temporizadores en reentrada.
- Builder: `--initialize-death-slot` obsoleto.

**JUDGMENT: APPROVED** para el alcance congelado (núcleo limpio, fase 1), con los hallazgos anteriores abiertos.
No acredita build completo, flujo de partida ni multijugador.

## Seguimiento 2026-10-25

- Hallazgo «doble salida si un listener de Death retira o mata la misma unidad» (JD-A-005): **resuelto** con una marca de
  salida en curso (`WaveReleasingByUnit`). LifecycleAudit `p1-lifecycle-v1` 57/0 con R14/R15. Sin control negativo con
  el núcleo anterior.

## Estado final del rework (2026-10-25)

Núcleo `WaveCore` (Table + TimerUtils), capas de presentación, política, puente RestTime y tablero ligado; nombres y
stage ordenados; contrato en `docs/contrato-wavecore.md`. Regresión completa en 1.27b: Lifecycle 57/0, Pause 17/0,
Feature 44/0, Core 16/0, Removal correcto, Integration 25/0, Table 34/0, supervivencia 67/0 (518/518), RestBoard 69/0
(0/1800); ResourceSkills 28/1 por E12 (habilidades, apartado). No acredita multijugador ni revisión visual del tablero.
