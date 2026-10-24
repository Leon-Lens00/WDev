# WaveSys E02: La muerte de invocados aborta antes de avisar y limpiar

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P1; clasificación ERROR.

Fuente: `src/WaveSysAnAI/SwlsWave/SwlsWave.j:1919`.

Síntoma y causa: La variable local WaveSlot s queda sin inicializar en la rama ExternalIsBoss y se lee al pasarla a WaveFireDeath en la línea 2015.

Reproducción/evidencia: core-baseline2: listener externo=0 y asociación WaveByUnit presente tras la muerte. Mismo fixture con sólo s=0 en JASS generado: listener=1 y asociación ausente.

Impacto: Se pierden avisos de IA/rachas/limpieza de habilidades; queda una asociación obsoleta para la unidad externa.

Comprobación y límites: Reproducido en 1.27b y causa contrastada con un cambio aislado. El registro automático de invocados no está conectado en las fuentes activas.

Evidencia: [evidence/core-engine-baseline2.txt](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/core-engine-baseline2.txt). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.
