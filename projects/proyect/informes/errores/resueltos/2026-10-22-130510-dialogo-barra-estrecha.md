# Barra superior fuera de pantalla estrecha
2026-10-22. UI Studio, vista diálogo, 640x850. Estado: corregido pendiente de verificar.
Evidencia DOM: innerWidth640, scrollWidth705; NAV alcanza704.8px, oculta tema/ayuda. Causa: fila superior no envuelve entre620 y700px. Cambio limitado a workspace diálogo: dos filas y navegación flexible bajo700px. No afecta exportador de inventario. Pendiente: repetir medición y screenshot.

Resuelto: navegador640x850: innerWidth640, scrollWidth625; todos los botones caben, captura editor-640.png. Restablecido tamaño de ventana tras comprobación.
