# WaveSys E07: La limpieza de Table usa el tipo equivocado

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P2; clasificación ERROR.

Fuente: `src/WaveSysAnAI/SwlsWave/SwlsWave.j:1081`.

Síntoma y causa: Table.remove llama RemoveSavedInteger, pero WaveActiveUnitByKey se escribió con SaveUnitHandle. El contrato correcto para handles está en Table.handle.remove.

Reproducción/evidencia: core-baseline2: tras muerte normal el contador baja a0, pero WaveActiveUnitByKey.handle.has(key) sigue true. Patrón estático repetido en IA, aura y priest; IA además borra reales como enteros.

Impacto: Retención de referencias y datos que deberían haberse liberado. Tamaño, crecimiento y efecto sobre memoria/FPS no medidos.

Comprobación y límites: Reproducido en el núcleo; los restantes sitios se contrastaron por el tipo real de Table. No es por sí solo prueba de fuga ilimitada.

Evidencia: [evidence/core-engine-baseline2.txt](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/core-engine-baseline2.txt). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.
