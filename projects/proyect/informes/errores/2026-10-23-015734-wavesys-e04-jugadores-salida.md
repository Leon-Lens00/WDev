# WaveSys E04: PlayerUtils corrompe el índice compacto de jugadores al salir

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto en PlayerUtils/UI; consumidores de partida aislados con un nuevo registro probado**. Prioridad P1; clasificación ERROR.

Fuente: `src/libraries/PlayerUtils.j:187`.

Síntoma y causa: Se asigna PlayingPlayerIndex[i]=PlayingPlayerIndex[AmountPlaying], aunque i es una posición compacta y la clave del inverso debe ser el id del jugador movido.

Reproducción/evidencia: Con usuarios 0,1,2,3: sale 1, el jugador 3 queda en posición1 pero su inverso sigue en3. Al salir3, se modifica posición3 fuera del rango activo, quedando 3 en el recorrido y desapareciendo2.

Impacto: Los 17 consumidores de fromPlaying pueden dar premios, resucitar o recorrer usuarios equivocados.

Comprobación y límites: Defecto lógico estático y escenario trazado; no se ejecutó un ensayo de desconexiones con varios clientes.

Evidencia: [evidence/codegraph-coverage.md](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/codegraph-coverage.md). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.

## Actualización autorizada: WavePlayerUtils, 23/10/2026

El usuario solicitó un registro propio para la partida. Se añadió [WavePlayerUtils.j](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/Players/WavePlayerUtils.j) en la copia, sin dependencia del User de UI. Dieciséis consumidores usan WavePlayer ahora. PlayerUtils y sus cinco consumidores de interfaz permanecen byte a byte. El original de WarDatsPy sigue intacto.

Verificación: biblioteca exacta aislada y junto al PlayerUtils original, cada una 39 controles/0 fallos y144 transiciones de retirada en rosters de prueba dentro de Classic1.27b. Control negativo generado sin actualización inversa:10 fallos, incluido el escenario E04. JassHelper/pJASS validaron114 fuentes activas juntas mediante la adaptación E01 sólo en la entrada generada. [Guía y evidencias](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/wave-player-utils.md).

Alcance: el registro nuevo evita la corrupción en los consumidores migrados. Las pruebas de retiros del conjunto no son desconexiones reales de clientes. Pendientes: corregir/probar el PlayerUtils que aún usa UI y probar salidas reales con varios clientes. Esta incidencia conserva estado abierto y ubicación original por ese alcance pendiente.
