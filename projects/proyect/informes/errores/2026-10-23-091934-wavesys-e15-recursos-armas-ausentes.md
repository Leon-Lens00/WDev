# WaveSys E15: fuentes de armas y recursos DevMission v0.96 incompatibles

Fecha: 2026-10-23T09:19:34.239121-05:00. Codex, evaluación WaveSys Classic1.27b. Estado: abierto; prioridad P1; fallo de integración, sin atribuirlo al mapa histórico por sí solo.

Revisión:114fuentes actuales y recursos del mapa fuente SHA256 66e0ce9f27d741f4785cd26eea46aad2b0f407210f0b94fab06fa2b4e1175a61. Original sólo leído y extraído, intacto.

Síntoma: WeaponInventoryEnsurePlayer intenta añadir U0AF/U0C1/U0C2 pero el héroe sigue con nivel0; CreateUnit pRSN retorna null/tipo0. Native gameplay-api-v1 registra tres FAIL de estos requisitos; los seis héroes, dumi y h004 sí existen. Evidencia: evidence/devmission-unit-objects.json, devmission-ability-objects.json, devmission-U0AF-object.json y ensayo gameplay-api-v1.

Causa confirmada: las definiciones no están en las tablas originales ni personalizadas de DevMission. El índice de objetos U0AF con --game-dir Classic retorna Found=false sin diagnósticos. Config WeaponProfileConfig.j:45–48 las requiere. El manifiesto de extracción/paquete demuestra que las tablas copiadas son exactas; no se perdieron durante la importación.

Impacto: disparo/selección de ranura mediante sus habilidades nativas y pickups de prisionero no se pueden dar por funcionales con esta combinación. La API directa de disparo se ensaya por separado y no repara la entrada del jugador. Otras texturas custom M00G/M00H tampoco figuran en la tabla de habilidades; falta evaluar su representación gráfica.

Acciones: conservar recursos tal cual, registrar incompatibilidad y continuar pruebas independientes. No inventar IDs ni fabricar objetos sustitutos. Pendiente: localizar la versión de objetos correspondiente a estas fuentes o portar deliberadamente sus definiciones y probar entrada real/pickups. No modificado DevMission.
