# WaveSys E05: Las habilidades agotan índices acumulativos sin reciclar

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P1; clasificación ERROR.

Fuente: `src/WaveSysAnAI/WaveProjectiles/WaveRangedSkills.j:386`.

Síntoma y causa: CastCount crece y no se devuelve; BossLightningIndex=castId*bj_MAX_PLAYER_SLOTS+playerId. La API Classic local fija bj_MAX_PLAYER_SLOTS=16.

Reproducción/evidencia: castId512 produce índices8192..8207, fuera de un array Classic. El contador se comparte entre casts normales y boss. Otros siete módulos usan contadores acumulativos similares.

Impacto: Las sesiones largas y refuerzos repetidos pueden alcanzar accesos inválidos aun con pocas habilidades simultáneas.

Comprobación y límites: Desbordamiento demostrado por expresión y límites de arrays; no se reprodujeron 512 casts en motor ni se atribuye un crash concreto.

Evidencia: [artifacts/diagnostic-renamed-init-compiled.j](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/artifacts/diagnostic-renamed-init-compiled.j). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.
