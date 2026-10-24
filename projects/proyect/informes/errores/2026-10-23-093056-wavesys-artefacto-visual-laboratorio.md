# Artefacto visual en laboratorio con recursos

Fecha: 2026-10-23T09:30:56.890686-05:00. Codex, WaveSys Classic1.27b/Wine, resource-skills-v2 y survival-resources-v4. Estado: abierto, causa sin determinar.

Síntoma: formas triangulares negras/verdes invaden parte derecha de capturas del juego, distintas del terreno regular; evidence/resource-skills-v2-screen.png y survival-resources-v4-progress.png. No se atribuyen automáticamente a WaveSys: hay modelos, overlays, terreno independiente y render Wine por aislar. No se certifica calidad visual de todos los recursos con el PASS lógico.

Impacto acreditado: representación gráfica inesperada en capturas de estos laboratorios. No se midieron colisión, daño ni fallo del motor causado por el artefacto. Los logs de lógica continuaron y la progresión terminó en victoria. Las capturas fallidas por monitor ajeno de gameplay-api-v1 son otra incidencia y no se usan aquí.

Acciones: preservar captura/mapa/hashes; registrar límite visual. Pendiente: escena mínima de cada efecto/overlay y control sin overlay, misma cámara/terreno, para separar geometría importada, UI y renderer. Sin corrección ni atribución de causa.
