# Builder de integración: selección de InitTrig demasiado amplia

Fecha: 2026-10-23-083435. Codex, WaveSys/Classic1.27b. Estado: corregido pendiente de verificar. Herramienta nueva tools/build-integration-audit.py, primera ejecución integration-v1.

Síntoma: assertion esperaba cuatro identificadores InitTrig de libraries pero encontró seis tras concatenar también el script base. [Log](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/integration-v1-builder.log). Abortó antes de compilar o empaquetar; no se modificó src ni el mapa base.

Causa confirmada: la selección incluía InitTrig_Melee_Initialization y InitTrig_TurtleNet, funciones globales legales del mapa TerrainDev. Corrección: aplicar selección y renombre sólo a las114 fuentes, y añadir luego fixture/script base sin alterarlos. No es un defecto del WaveSys original.

Pendiente: nueva ejecución con id integration-v2 y compilación/validación/reextracción; conservar la primera evidencia.


Recuperación verificada: integration-v2 pasó JassHelper/pJASS, empaquetado y reextracción con114 fuentes; cuatro renombres de biblioteca y dos initializers de escenario desactivados sólo en la entrada generada. Script reextraído exacto y demás miembros preservados. Estado final: resuelto. Evidencia: /home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/integration-v2-build.json y -compile.json. La ejecución en motor todavía es una fase separada.
