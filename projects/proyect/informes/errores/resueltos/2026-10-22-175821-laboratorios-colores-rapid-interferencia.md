# Interferencia entre laboratorios de colores y Rapid Fire

- Fecha: 2026-10-22T17:58:21.126519-05:00; agente principal, TerrainDev Classic1.27b.
- Estado: en investigación.
- Síntoma: laboratorio de colores40PASS/0FAIL; luego regresión44controles/2FAIL (velocidad con desviaciónY y daño al blanco). Evidencia: TerrainDev/reports/shot-colors-20261022/20261022-175357/rapid-engine.txt.
- El avanceX fue87.328unidades en0.25s, cercano a87.5; el control combinado también exige mantenerY. No se atribuye todavía a un defecto de velocidad.
- Hipótesis contrastada con fuentes: ShotColorProbe reubicó y dejó la unidad demo en el origen del laboratorio siguiente, -4700,3024. RapidFireProbe crea ahí otro actor con pathing nativo; esa ocupación puede desplazar el spawn y alterar línea de tiro/trayectoY. Las partidas previas de RapidFireProbe no tenían esa unidad ahí.
- Impacto: el ensayo combinado no aprueba la regresión; no se ocultan esos2fallos. El resultado de colores permanece acreditado por sus40casos.
- Acción: conservar/restaurar coordenadas de la demo al finalizar colores y repetir ambos laboratorios sobre copia nueva con las mismas fuentes productivas. No cambiar física para acomodar la prueba.
- Pendiente: confirmar/rechazar la hipótesis con esa repetición y registrar hashes/resultados/límites.

## Recuperación comprobada

La copia nueva /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/shot-colors-20261022/20261022-175921 conserva exactamente las fuentes productivas de la candidata anterior y sólo guarda/restaura la posición de la demo al terminar colores.40PASS/0FAIL de colores y44PASS/0FAIL de RapidFire; avance87.500 en0.250s, daño al blanco correcto. Confirmada interferencia por ocupación del origen del segundo fixture, no un defecto de física. Estado: resuelto.

El primer envío automático de -testcolors no produjo log dentro del plazo (la ventana existía, pero no se había comprobado visualmente la carga). No se contó como fallo de lógica ni como PASS. Se comprobó después el mapa y se reenviaron entradas al HWND propio; se obtuvo el log fresco40/0 y luego se ejecutó -rapid. Los evaluadores rechazaron4 negativos de colores y5 de RapidFire. No se enviaron teclas globales a otras aplicaciones.
