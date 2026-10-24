# Inspección auxiliar de Shots: propiedad incorrecta

- Fecha: 2026-10-22T17:43:08.918271-05:00; chat TerrainDev, agente principal.
- Entorno: Node22.14, mdx-m3-viewer5.12, MDX800, Classic1.27b.
- Estado: resuelto.
- Síntoma: el primer resumen auxiliar lanzó TypeError al aplicar Array.from a e.scaling. No completó la verificación de12 modelos; no se consideró aprobado.
- Causa confirmada: ParticleEmitter2 usa segmentScaling, verificado con las claves del objeto leído; scaling era undefined. No era un fallo del modelo.
- Acción: repetir el resumen con segmentScaling. Sin editar modelos, texturas ni lector.
- Comprobación:12 MDX800 leídos por mdx-m3-viewer y war3-model, texturas/secuencias y poses de Stand medidas. Resultado guardado en TerrainDev/reports/shot-colors-20261022/models.json.
- Impacto: sólo el resumen previo; el empaquetado/compilación continuaron independientes. La lectura de archivos aún no acredita aspecto en juego.
