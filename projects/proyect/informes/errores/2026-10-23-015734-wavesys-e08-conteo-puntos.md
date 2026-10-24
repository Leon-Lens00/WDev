# WaveSys E08: Aplicar puntos devuelve una cantidad que no se insertó

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P2; clasificación ERROR.

Fuente: `src/WaveSysAnAI/SwlsWave/WavePointGroups.j:309`.

Síntoma y causa: Se retorna count del grupo aunque Wave.addPoint rechace inserciones por su límite100; el grupo admite128.

Reproducción/evidencia: core-baseline2: Wave ya tiene99 puntos, grupo2; retorno2 y sólo1 punto añadido.

Impacto: StageExample compara el retorno con el tamaño del grupo y no detecta truncación.

Comprobación y límites: Reproducido en motor. La recogida, deduplicación y ordenación del grupo sí pasaron en el fixture final.

Evidencia: [evidence/core-engine-baseline2.txt](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/core-engine-baseline2.txt). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.
