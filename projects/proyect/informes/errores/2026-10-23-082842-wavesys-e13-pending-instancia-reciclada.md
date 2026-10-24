# WaveSys E13: Un temporizador pendiente modifica una instancia de Wave reciclada

Fecha: 2026-10-23T08:28:42.483762-05:00. Codex, evaluación completa. Classic1.27b, copia actual de WaveSys; fuente original sin cambios.

Estado: **abierto; diagnóstico sin corrección de producto**. P1 ERROR.

Fuente: src/WaveSysAnAI/SwlsWave/SwlsWave.j:367.

Síntoma/reproducción: Reservar una unidad, destroyWave antes de1.5s, crear otra Wave y un slot de2 unidades. Mismo waveId4, token15→16 y slot97 reutilizado. Tras el timer antiguo la nueva remainingToSpawn pasa de2 a3.

Causa confirmada: Al detectar token distinto, PendingSpawn_execute llama cancelReservedSpawn sobre ps.wave aunque ese id ya representa otra instancia. ps.slot también puede haberse reciclado.

Impacto: Se corrompen cantidades y objetivos de otra oleada; puede alterar su ritmo o bloquear el fin.

Verificación: laboratorio features-v1 compilado/validado/empaquetado/reextraído y ejecutado en Classic.44 controles,2 fallos; uno corresponde a esta incidencia. [Log](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/features-v1-native.txt), [fixture](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/tests/FeatureAudit.j).

Límites: Reproducido en 1.27b con destrucción directa y reutilización inmediata; no demuestra que el stage normal destruya de esa forma.

Pendiente: corrección autorizada y contraste del mismo caso, con regresión de consumidores.
