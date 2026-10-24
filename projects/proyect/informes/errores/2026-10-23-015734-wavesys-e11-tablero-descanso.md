# WaveSys E11: El tablero inicial sobrescribe la interfaz de descanso y victoria

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P2; clasificación ERROR.

Fuente: `src/Multiboard/InitialWaveMultiboard.j:67`.

Síntoma y causa: Su timer de0.10s sólo discrimina isWavez; RestTime pone isWavez=false, y Populate restablece título Preparando, layout6x5 y estado Selección.

Reproducción/evidencia: RestTimeOnWaveFinished:29 pone false; Countdown escribe tienda/cuenta atrás una vez por segundo; Tick inicial vuelve a escribir hasta diez veces por segundo.

Impacto: Se pisan los títulos de descanso y victoria y se pierde la presentación de la cuenta atrás en el tablero.

Comprobación y límites: Conflicto de escritores demostrado en fuente; no se probó el flujo completo del mapa original.

Evidencia: [src/WaveSysAnAI/SwlsWave/RestTime/RestTimeCountdown.j](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/WaveSysAnAI/SwlsWave/RestTime/RestTimeCountdown.j). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.

Confirmación nativa adicional: integration-v5, 25 controles/24 PASS/1 FAIL, termina COMPLETE. El handler real configura título Descanso/Tienda10; tras0.25s InitialWaveMultiboard lo sustituye por Preparando Wave2/10. La cuenta atrás sí despacha una vez el callback siguiente. Evidencia: WaveSys/evidence/integration-v5-native.txt y captura; Classic1.27b,114bibliotecas, objetos base independientes. No se ejecutó victoria en este ensayo.
