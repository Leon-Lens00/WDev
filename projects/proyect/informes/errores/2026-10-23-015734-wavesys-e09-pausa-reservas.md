# WaveSys E09: La pausa permite materializar apariciones ya reservadas

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P2; clasificación WARNING.

Fuente: `src/WaveSysAnAI/SwlsWave/SwlsWave.j:1379`.

Síntoma y causa: pause detiene sólo loopTimer. PendingSpawn_execute tiene timer propio y no consulta isPaused.

Reproducción/evidencia: core-baseline2 reserva una aparición, pausa antes de que se materialice y observa paused=1 y tracked=1 al cumplirse1.5s.

Impacto: La pausa es parcial: deja avanzar el materializado y no congela ataques nativos ni timers de habilidades.

Comprobación y límites: Comportamiento reproducido; si la API pretende sólo suspender nuevas reservas, debe documentarlo. No se modifica la semántica sin decisión de diseño.

Evidencia: [evidence/core-engine-baseline2.txt](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/core-engine-baseline2.txt). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.
