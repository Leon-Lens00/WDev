# WaveSys E06: Los eventos anidados borran el contexto del evento exterior

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P2; clasificación ERROR.

Fuente: `src/WaveSysAnAI/SwlsWave/SwlsWave.j:186`.

Síntoma y causa: Push escribe globals y Clear los pone a cero; no hay pila/restauración al despachar otro evento.

Reproducción/evidencia: En core-baseline2 un listener Start llama pause; el siguiente listener Start recibe Wave=0.

Impacto: Un consumidor posterior puede recibir instancia, unidad, killer o slot incorrectos bajo reentrada.

Comprobación y límites: Reproducido en 1.27b con Start→Pause; no implica que todos los listeners existentes disparen eventos anidados.

Evidencia: [evidence/core-engine-baseline2.txt](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/core-engine-baseline2.txt). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.
