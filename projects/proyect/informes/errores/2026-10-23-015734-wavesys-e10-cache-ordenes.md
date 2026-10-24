# WaveSys E10: La memoria de órdenes puede impedir reanudar persecución

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P2; clasificación ERROR.

Fuente: `src/WaveSysAnAI/AI/IAManager.j:1259`.

Síntoma y causa: Se omite attack al mismo target por el valor cacheado; habilidades custom emiten stop y no invalidan ese caché.

Reproducción/evidencia: WaveBarrierStart:229, WaveRangedStartHrifCast:408 y WaveMortarSkillsTryExecute:364 emiten stop; las ramas custom de AIEvaluateUnit retornan sin AIResetOrderState.

Impacto: Tras una habilidad, un objetivo que sigue siendo el mismo puede no recibir una nueva orden de persecución. La auto adquisición nativa puede ocultarlo a corta distancia.

Comprobación y límites: Ruta estática contrastada; no se reprodujo este caso con las habilidades y objetos reales en el motor.

Evidencia: [evidence/codegraph-coverage.md](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/codegraph-coverage.md). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.

Confirmación nativa: skills-v1,28controles/27PASS/1FAIL. hfoo recibe attack851983 contra héroe distante~4000; barrera real activa stop, expira tras5s y a5.75s GetUnitCurrentOrder=0. AI sigue activo pero caché del mismo objetivo impide reenviar ataque. Sin objetos custom necesarios para este caso. Log: WaveSys/evidence/skills-v1-native.txt. Sin corrección aplicada.
