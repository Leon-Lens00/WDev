# Inspección auxiliar de PNG sin Pillow

Fecha: 2026-10-22T12:36:35.456430-05:00. Origen: chat de integración de inventario y diálogo. Proyecto: UI Studio, Python del sistema CachyOS, diseño de conversación 2026-10-22.

Síntoma: el script auxiliar para copiar recursos e imprimir tamaño/alfa importó PIL; Python devolvió ModuleNotFoundError: No module named PIL antes de copiar. Impacto: se interrumpió esa inspección auxiliar; no afectó fuentes ni imágenes.

Causa confirmada: Pillow no está disponible en ese intérprete. Acción: copiar con shutil e inspeccionar cabecera PNG mediante struct de la biblioteca estándar. No instalar dependencias para esta operación.

Verificación: ambas imágenes copiadas; cabeceras PNG legibles y dimensiones obtenidas. El marco tiene canal alfa. Su aspecto fue inspeccionado en la salida de ImageGen; la transparencia y composición se comprobarán también en navegador.

Estado: resuelto mediante alternativa; no se afirma disponibilidad de Pillow. Evidencia de recursos: /home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/dialogue/.

2026-10-23 ModelEditor V10, /root: import PIL accidental con Python del sistema volvió a fallar. Repetido con work/shots-vol-i-origen-20261022/plot-env/bin/python: 12 capturas procesadas, GIF/PNG creados. Recuperación comprobada; no se instalaron paquetes globales.
