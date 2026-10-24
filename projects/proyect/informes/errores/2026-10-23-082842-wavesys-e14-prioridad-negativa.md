# WaveSys E14: Los slots admiten prioridad negativa pero nunca se eligen

Fecha: 2026-10-23T08:28:42.483762-05:00. Codex, evaluación completa. Classic1.27b, copia actual de WaveSys; fuente original sin cambios.

Estado: **abierto; diagnóstico sin corrección de producto**. P2 ERROR.

Fuente: src/WaveSysAnAI/SwlsWave/SwlsWave.j:1422.

Síntoma/reproducción: Wave con un único slot válido de una unidad, prio=-1 y killGate=-1: pickSlot retorna0.

Causa confirmada: addSlotInternal conserva prio sin validar; pickSlot inicializa maxPrio=-1 y retorna0 cuando sigue negativo.

Impacto: Una configuración aceptada por la API puede quedar detenida sin mensaje. Las prioridades del stage actual son no negativas; no se atribuye este fallo a su configuración.

Verificación: laboratorio features-v1 compilado/validado/empaquetado/reextraído y ejecutado en Classic.44 controles,2 fallos; uno corresponde a esta incidencia. [Log](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/features-v1-native.txt), [fixture](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/tests/FeatureAudit.j).

Límites: Defecto de contrato/validación reproducido en motor; no implica bloqueo de las diez oleadas configuradas.

Pendiente: corrección autorizada y contraste del mismo caso, con regresión de consumidores.
