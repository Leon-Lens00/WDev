# WaveSys E12: El aura pierde miembros vivos al retirar una entrada inválida

Fecha: 2026-10-23T01:57:34-05:00. Agente/chat: Codex, evaluación de WaveSys.

Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`, copia exacta en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/`. Objetivo Warcraft III Classic1.27b. Revisión en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/original-manifest.json`.

Estado: **abierto, sin corrección aplicada a las fuentes**. Prioridad P2; clasificación ERROR.

Fuente: `src/WaveSysAnAI/WaveProjectiles/WaveAuraSkills.j:454`.

Síntoma y causa: La rama null/type0 decrementa MemberCount sin mover la última entrada ni limpiar el resto de mapas de membresía.

Reproducción/evidencia: Miembros1=A,2=retirado,3=C: al barrer3 y luego2, count pasa de3 a2, pero C sigue en3 y queda fuera del recorrido posterior.

Impacto: Puede quedar un buff/propietario de aura sin retirar al terminar; es independiente del borrado Table con tipo erróneo.

Comprobación y límites: Defecto lógico estático; sin ensayo con el objeto rspl y los buffs del mapa original.

Evidencia: [src/WaveSysAnAI/WaveProjectiles/WaveAuraSkills.j](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/src/WaveSysAnAI/WaveProjectiles/WaveAuraSkills.j). Informe general: [Evaluación](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md).

Acciones: diagnóstico, preservación de fuentes y documentación. Pendiente: resolver el contrato de comportamiento cuando corresponda y corregir/probar en una tarea autorizada. Una variante de diagnóstico no cierra esta incidencia.

Confirmación nativa: resource-skills-v2,28controles/27PASS/1FAIL, con recursos exactos DevMission. Se inicia aura real hkni/rspl/A015 y se observan cuatro miembros mediante funciones generadas de sólo lectura. Se retira un miembro interior distinto del source y del último. Al expirar, el último conserva ownerAura=1: FAIL. El inventario forma parte del control compuesto, pero el log no imprime su valor separado; sólo se acredita aquí la pertenencia huérfana. El contador incluso llega a0 antes de la limpieza final; combina compactación defectuosa con el remove de tipo incorrecto E07. Fuentes sin cambios; observadores sólo en entrada generada. Evidencia: WaveSys/evidence/resource-skills-v2-native.txt y build con read_only_aura_observers=true.
