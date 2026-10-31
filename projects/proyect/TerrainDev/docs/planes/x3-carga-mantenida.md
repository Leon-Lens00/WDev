# Plan: carga acumulada del X3 Buster

Fecha: 24/10/2026, America/Lima
Estado: **fases 1 y 3 completas: candidato probado en mapa (241/0).** Fase 2 descartada. Falta decidir la promoción a la entrega.
Proyecto/base: `TerrainDev/TerrainDev.w3x`, SHA-256 `f087047bff8c051d26072c5c651513588d7272d38628d23cd697eaa7516e5e23`; 18 bibliotecas de `src/libraries` iguales a `reports/20261023-144114-703534/result.json` (comprobado el 24/10).
Alcance autorizado: diseño y propuesta. Implementar, compilar, ejecutar el juego o el emulador requiere la respuesta del usuario a las decisiones de abajo.

Lectura previa para cualquier agente (Claude o Codex): `Proyect/AGENTS.md`, `TerrainDev/AGENTS.md`, [x3-buster.md](../x3-buster.md), [traspaso Missiles](../../../docs/traspasos/missiles-contexto.md) y este plan.

## Objetivo y aceptación

Sustituir los disparos discretos W/E/R por una carga acumulada al estilo X3: el nivel crece con el tiempo, al soltar sale el disparo correspondiente y, con carga completa, una segunda acción emite el pulso que se une a la hélice. Aceptación: en una partida 1.27b, los umbrales, la liberación, el segundo disparo, la cancelación y la limpieza se observan como se especifica en la fase 3, sin regresión de Q/RapidFire, colores ni de la física X3 entregada.

## Restricciones comprobadas

| Hecho | Evidencia |
|---|---|
| 1.27b sólo da pulsar/soltar para las cuatro flechas (`EVENT_PLAYER_ARROW_*_DOWN/UP`). ESC sólo pulsar. | `src/codegraph-api/common.j:628-635` |
| No hay eventos de tecla arbitraria, ratón ni cursor; 0 nativas `Blz*`. Mantener W no es detectable. | mismo archivo |
| W/E/R son Channel con objetivo de punto (`Ncl2=2`), 0 s de lanzamiento y enfriamiento: la tecla abre el apuntado y el cast llega con el clic. | `reports/20261023-144114-703534/object-Ax3c.json`, `-Ax3s`, `-Ax3z` |
| El controlador se aparca: cada orden de movimiento se intercepta y se recoloca con `SetUnitPosition`. Una canalización usada como "mantener" se cortaría al moverse (inferido por lectura; no probado en juego). | `src/libraries/RapidFire.j:230`, `:320-331` |
| Ya existe la API que necesita la carga: `fireProfile(...,mode 2,...)` deja la hélice esperando y `releasePulse()` emite el pulso. | `src/libraries/X3Buster.j:227`, `:411` |
| `X3Buster.LIFETIME = 4 s` cancela también un cast que espera el pulso y destruye la hélice. | `X3Buster.j:56`, `:382` |

## Datos de carga medidos (laboratorio SNES existente)

Fuente: `labs/x3-snes/runs/final-original/frames.csv` y `final-mod/frames.csv` (columnas `charge`, `charge2`, `stored_second`), Y pulsada en el fotograma 30. Igual en USA y Zero Project. No se repitió el emulador.

| Nivel `charge` | Fotogramas desde pulsar | Segundos (60,0988 fps) |
|---|---:|---:|
| 2 | 1 | 0,017 |
| 4 | 21 | 0,349 |
| 6 | 81 | 1,348 |
| 8 (`stored_second=1`) | 141 | 2,346 |
| 10 (`stored_second=2`) | 201 | 3,345 |

Al soltar con nivel 10 sale la hélice y el segundo disparo queda guardado; pulsar de nuevo 12 o 20 fotogramas después emite el pulso.

**No medido:** el disparo al soltar en los niveles 4, 6 u 8; la duración del segundo disparo guardado si no se pulsa; la carga sin la mejora del brazo.

## Diseño propuesto

Biblioteca nueva `X3Charge` (`src/libraries/X3Charge.j`), con estado por `RapidPair`. No cambia Missile, MissileRecycler, GroundCollision, GroundMotion, RapidFire ni la física de X3Buster.

Interfaz prevista (tentativa hasta la fase 1):

```
X3Charge.begin(RapidPair pair, integer profile) -> boolean   // empieza la carga; rechaza si ya carga
X3Charge.level(RapidPair pair) -> integer                    // 0,2,4,6,8,10 según el tiempo transcurrido
X3Charge.release(RapidPair pair, real x, real y) -> X3Buster // dispara según el nivel; 0 si no hay disparo
X3Charge.second(RapidPair pair) -> boolean                   // releasePulse() del cast guardado
X3Charge.cancel(RapidPair pair)                              // muerte del actor, destrucción del par o cancelación
```

El tiempo se mide con el reloj existente, no contando ticks. Los umbrales usan la tabla medida. El perfil se copia al empezar la carga.

Adaptadores de entrada, separados del estado:

- **A, alternar con W (recomendado):** primera pulsación de W empieza la carga; W + clic suelta hacia el punto; la siguiente W emite el segundo disparo. No choca con el movimiento, apunta con el clic y se prueba por script con `IssuePointOrder`.
- **B, flecha arriba mantenida (opcional):** único "mantener y soltar" real de 1.27b. Coste: las flechas desplazan la cámara; apunta según la orientación del actor; en LAN el evento llega con retardo de red; no se puede simular por script y necesita control de escritorio.

## Decisiones

Del usuario (24/10/2026):

1. Adaptador **A** (alternar). B no se implementa.
2. Soltar antes del nivel 8 **no dispara**.
3. **W carga con USA** (`X3Demo.profile`, ORIGINAL por defecto) y **R carga con Zero Project**.
4. Fase 1 autorizada.

Del agente, por no estar indicadas (revisables):

- E (Ax3s) se mantiene como Cross Buster USA discreto, sin cambios.
- Nivel 8 dispara el buster cargado actual (modo 0); nivel 10 lanza la hélice (modo 2) y deja el pulso guardado. Que el nivel 8 sea el disparo cargado es una suposición: no está medido.
- Cualquier tecla de carga (W o R) actúa sobre el estado actual: si no hay carga, empieza; si carga, suelta; si hay pulso guardado, lo emite. El perfil queda fijado al empezar.
- Sin cambio de `X3Buster.LIFETIME`: el pulso guardado sólo vale mientras el cast espera (≤ 4 s). Si ya no espera, la pulsación empieza una carga nueva.
- Sin efecto visual de carga ni objetos nuevos; no cambian rawcodes, teclas ni textos de Ax3c/Ax3z.
- Build de candidato con `scripts/build.py --output`, para no sustituir la entrega probada `TerrainDev.w3x` (base también de `union-mapas-20261024.md`) por una revisión sin probar en juego.

Pendientes:

- Efecto visual de carga (coordinar con Models Astra).
- Opcional: caso de laboratorio nuevo (soltar en nivel 8 y no volver a pulsar) para medir el disparo de nivel 8 y la duración del pulso guardado. Requiere autorización para ejecutar el emulador.

## Coordinación con otros trabajos

`docs/planes/union-mapas-20261024.md` (chat Edit Tools) parte de este TerrainDev y conserva Q/W/E/R y la física acreditada. Implementar la carga cambia esa base: acordar con el usuario si va aquí antes de la unión o dentro de la variante de integración. No editar el mapa mientras otro agente lo escriba.

## Fases

### Fase 1: estado de carga y adaptador A

- Estado: implementada; compilada como candidato el 24/10/2026. No probada en juego.
- Cambió: `src/libraries/X3Charge.j` (nuevo, sha256 `44cd6b0d…`), `src/libraries/X3BusterDemo.j` (`97a28fda…`), `libraries.json` (orden y entradas), `src/Main.j` (import tras X3Buster), `scripts/build.py` (opción `--output`). Sin cambios en objetos, rawcodes, teclas, X3Buster ni núcleos.
- Interfaz real: `X3Charge.press(pair,profile,x,y)` devuelve REJECTED 0 / BEGAN 1 / FIRED 2 / EMPTY 3 / SECOND 4; también `begin`, `release`, `second`, `cancel`, `level`, `levelAt`, `stateOf` y los contadores `begins/charged/full/empty/seconds/rejected`. Estado indexado por RapidPair y validado contra el actor que empezó la carga; el cast guardado se valida con `waiting`, `caster` y `born`, porque los slots de X3Buster se reutilizan.
- Consumidores: X3BusterDemo (único llamador según CodeGraph `src`). Los probes `scripts/X3Probe.j:302` («native W … creates charged physics») y `scripts/X3NativeProbe.j:197` («native R selects Zero Project») esperan un disparo inmediato de W y R: con la carga fallarán por diseño y deben adaptarse en la fase 3. El resto de los probes llama a `fireProfile`/`fire` directamente y E no cambió.
- Resultado observado:
  - `python3 scripts/build.py --output maps/work/x3-charge-20261024/TerrainDev-charge.w3x`: código 0, JassHelper validado, pJASS «Parse successful» (7157 líneas de war3map.j), miembros reextraídos iguales, triggers WTG/WCT con X3Charge, objetos encontrados.
  - Candidato SHA-256 `5df3e8a98daf27f3fd41a6b2d7ff5167b3f4d3ed16571c72f6c3677b412ecf4d`. 17 bibliotecas iguales a la entrega; sólo cambian X3Charge (nueva) y X3BusterDemo.
  - Entrega `TerrainDev.w3x` (`f087047b…`) y `reports/latest-build.json` intactos (`sha256sum -c`).
  - CodeGraph `src`: X3Charge indexado y ruta Cast → press → storedAlive, sin avisos de vigencia.
  - Un primer intento falló por un error de la opción nueva: [informe resuelto](../../../informes/errores/resueltos/2026-10-24-012448-build-salida-candidato.md).
- Evidencia: `reports/20261024-012519-601990/result.json`, `build/20261024-012519-601990/`. El launcher también escribe su informe vjass en `FrozenThone/runtime/wc3-tools/reports/`.
- Límites: compilar no demuestra el comportamiento. Comportamientos sin probar: soltar con el disparo bloqueado o en LIMIT pierde la carga; si la hélice muere antes del segundo disparo, el pulso sale solo mientras el cast espera (≤ 4 s).

### Fase 2: adaptador B (si se elige)

- Estado: descartada por el usuario (24/10/2026)
- Requiere: fase 1
- Cambia: adaptador de flechas en `X3Charge.j` o librería aparte; comportamiento de cámara documentado.
- Verificación prevista: prueba manual con control de escritorio.
- Resultado observado: no ejecutado

### Fase 3: laboratorio y regresión en 1.27b

- Estado: **ejecutada el 24/10/2026: Tested in map (candidato), 241 controles, 0 fallos.**
- Cambió (sólo laboratorio, nada se importa a producción):
  - `scripts/X3Probe.j`: W ahora empieza la carga, sin cuerpos; la segunda W a nivel 8 crea el disparo cargado (etapas 120–121).
  - `scripts/X3NativeProbe.j`: R empieza la carga; a nivel 10 suelta la hélice y la tercera R emite el pulso; se conserva el control «native R selects Zero Project…» con los mismos 9 cuerpos y 1 fusión (etapas 130–132).
  - Nuevo `scripts/X3ChargeProbe.j` (`-charge`, 43 controles).
  - Nuevo `scripts/prepare_x3_charge_probe.py`: mapa de laboratorio sobre el candidato.
  - Nuevo `scripts/verify_x3_charge.py`: evaluador y controles negativos.
  - `scripts/run_x3_pipeline.py`: fixture y etapas opcionales; pausa de 0,5 s entre envíos.
  - `scripts/verify_x3_probe.py`: recuento y etiquetas W parametrizados; la evidencia del 23/10 sigue validando con los valores por defecto.
  - `scripts/x3_runtime.py`: opción `--integrated` por proceso.
- Resultado observado (`reports/x3-charge-20261024/20261024-013521/validated-result.json`):

  | Etapa | Controles | Fallos | Creados/retirados |
  |---|---:|---:|---|
  | x3 (W cargado) | 71 | 0 | 198/198, 7 fusiones |
  | colores | 40 | 0 | 221/221 |
  | Rapid Fire | 44 | 0 | intervalo mín. 0,250 s |
  | nativo (oráculo 5259 valores, error máx. 0,000) | 43 | 0 | 86/86 |
  | carga | 43 | 0 | 41/41; 13 cargas, 6 completas, 3 de nivel 8, 1 vacía, 5 segundos disparos |

  12 controles negativos rechazados. 0 casts, proyectiles ni flashes activos al final.
- Casos de carga acreditados: umbrales 1/21/81/141/201 fotogramas; nivel 4, 8 y 10 reales en motor; soltar por debajo de 8 no dispara; nivel 8 crea un cuerpo; nivel 10 crea la hélice y guarda el pulso; el pulso se fusiona en 5 cuerpos; segundo disparo repetido rechazado; un pulso guardado más allá de 4 s se descarta y la pulsación empieza otra carga; el perfil queda fijado al empezar (R con carga de W dispara con USA, y W con carga de Zero emite el pulso Zero); muerte del actor; slot de par reciclado sin herencia; dos pares simultáneos; Rapid Fire durante la carga; órdenes nativas W y R.
- Entorno: mapa de laboratorio `maps/work/TerrainDev-x3-charge-20261024-013521.w3x` (SHA-256 `c99a9681…`), perfil aislado `build/x3-runtime`, Intel Mesa/Vulkan por proceso (`libvulkan_intel.so` en el proceso, porque persiste el desajuste NVIDIA kernel/NVML), eDP-1 1920×1080, un cliente.
- Incidencia: la etapa de colores perdió su comando de chat y se reenvió manualmente; las tres últimas etapas se ejecutaron con la pausa nueva. [Informe abierto](../../../informes/errores/2026-10-24-013648-x3-pipeline-chat-perdido.md), pendiente de una ejecución completa de las cinco etapas seguidas.
- Cierre: Win+Q, confirmación comprobada en captura y S; proceso propio terminado con código 0 (`closure.json`). Una partida WaveSys de otro agente (PID 1326311) arrancó durante la prueba y se dejó intacta.
- Límites: un solo cliente; el adaptador alterna, no detecta soltar la tecla; el disparo de nivel 8 sigue siendo una suposición (no medida en SNES); no se probó la interacción de un jugador real con clics, sólo órdenes por script; sin multijugador, guardado en editor ni rendimiento.

Fuera de alcance mientras no se pida: multijugador, guardado y reapertura en editor, rendimiento.

## Continuidad

Prueba manual: el usuario la hará con clics antes de decidir (24/10/2026). No promover hasta entonces. Lanzador: `python3 scripts/x3_runtime.py reports/x3-charge-20261024/manual/fixture.json --integrated` (mapa candidato sin laboratorios).
Próximo paso: decisión del usuario sobre la promoción: build sin `--output` para sustituir `TerrainDev.w3x` (`f087047b…`) por el candidato (`5df3e8a9…`). Afecta a `docs/planes/union-mapas-20261024.md`, que parte de la entrega actual: coordinar antes con ese trabajo. Opcional: prueba manual con clics de un jugador real, y repetir el pipeline completo para cerrar el informe de chat perdido.
Verificaciones pendientes: multijugador, guardado y reapertura en editor, rendimiento, disparo de nivel 8 frente a SNES, efecto visual de carga.
Sin commit: el repo de Proyect no tiene commits.
