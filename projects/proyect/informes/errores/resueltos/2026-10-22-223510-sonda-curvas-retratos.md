# Sonda de curvas de retratos

- Fecha/origen:22/10/2026 22:35 America/Lima, Codex /root, ModelEditor Node26.10.0,
  mdx-m3-viewer5.12.0, retratos Classic1.27b MDX800.
- Síntoma/evidencia: una consulta de inspección intentó `animation.tracks.slice`
  y produjo TypeError. Se esperaba obtener dos claves del primer hueso animado.
- Causa confirmada: el parser MDLX expone `frames` y `values`, no `tracks`.
- Impacto: sólo falló esa sonda de lectura; ningún recurso fue modificado.
- Acciones/verificación: repetir inspección con `plain()`/Object.entries mostró
  correctamente frames/values, intervalos y jerarquía. Resultado:894 claves por
  curva inicial de Paladín y KGTR lineal globalSequenceId=-1.
- Estado:resuelto. Límite: esta recuperación sólo acredita la inspección, no la
  optimización todavía pendiente. Sin pendientes propios de esta incidencia.
