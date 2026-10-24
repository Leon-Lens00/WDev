# WaveSys E03: RemoveUnit deja la oleada esperando unidades inexistentes

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P1; clasificación ERROR.

Fuente: `src/WaveSysAnAI/SwlsWave/SwlsWave.j:1914`.

Síntoma y causa: Sólo EVENT_PLAYER_UNIT_DEATH descuenta las unidades; no hay reconciliación de GetUnitTypeId=0 ni conexión con DEINDEX.

Reproducción/evidencia: core-baseline2 crea una unidad real, la retira con RemoveUnit y observa activeOnMap=1 y activeTrackedCount=1.

Impacto: La condición de fin en onTick exige activeOnMap<=0: retirar entidades sin matarlas puede bloquear el fin de oleada y terminate.

Comprobación y límites: Reproducido en motor para el contador; no se afirma una retirada de enemigos en el flujo normal actual, cuyos RemoveUnit visibles son principalmente dummies/markers.

Evidencia: [evidence/core-engine-baseline2.txt](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/core-engine-baseline2.txt). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.

## Contraste diferido adicional

Ensayo diferido removal-delayed: setup=1 y engineRemoved=1 tras esperar0.5s; active=1, tracked=1, finished=0 y forceTerminated=0, con ticks naturales y una comprobación explícita de fin.

Reproducido en 1.27b después de la eliminación real del motor; tampoco finalizó mediante terminate(true). No implica que el flujo normal actual retire enemigos con RemoveUnit.

[Evidencia final](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/removal-delayed-engine.txt). Se descarta que fuera solamente el retraso nativo de RemoveUnit.
