# Recursos auxiliares de la investigación de texturas del panel

Entorno: Classic1.27b/MDX800, diálogo TerrainDev,22/10/2026. Estado: resuelto mediante alternativas disponibles; sin cambiar mapa ni recursos activos.

- La herramienta web no pudo abrir el PDF Art Tools alojado en XGM por content-type application/octet-stream. La conclusión de límites se apoya en el informe experimental directo de Dr Super Good, BLP Specifications(WC3), que sí se pudo leer. No se atribuye lectura completa al PDF.
- Dos rutas supuestas de RenderEdge.ini no existen; búsqueda por nombres encontró RenderEdge_Widescreen.mix. No se ha demostrado que esa extensión cambie el límite BLP.
- El módulo pngjs no existe en el runtime de modelos. No instalarlo: se usará el Python ya disponible work/shots-vol-i-origen-20261022/plot-env con Pillow para escribir las imágenes de comparación. La verificación BLP usa sus parsers existentes.

Impacto: métodos auxiliares sustituidos; la comprobación específica del límite efectivo en el perfil local sigue pendiente, separada del límite documentado del motor Classic. Conservar fuente y candidatos separados.

Recuperación: candidatos generados con Pillow del entorno existente. Verificador independiente mdx-m3-viewer/war3-model compara40mips de4candidatos; todos pasan. El segundo parser recibe dimensiones normalizadas por subrecurso para su limitación con el último mip rectangular, sin alterar el archivo. La URL de directorio del comparador devolvió404 y Brave mostró ERR_BLOCKED_BY_CLIENT; se corrigió a /panel-texture-review/index.html según la entrada real del servidor. Vista cargada sin cambiar protecciones. Un selector por etiqueta no encontró coincidencia; snapshot mostró combobox y la selección por rol funcionó. No se atribuyen esos fallos auxiliares al BLP ni al motor.
