# Acceso parcial de web a filtros y previews Hive

- Fecha: 2026-10-22, America/Lima; agente Codex, catálogo de proyectiles Vinz del proyecto Proyect.
- Entorno/revisión: herramienta web de esta sesión; sitio Hive en vivo.
- Estado: en recuperación.
- Síntoma/evidencia: web click a imagen 48 de Psionic Shots devuelve Internal Error. web open del filtro autores Vinz + tag=4 y dos variantes devuelve URL no accesible. Las fichas individuales sí se leen.
- Impacto: el filtro y el acceso directo a la preview no pueden acreditarse con esa ruta de web.
- Causa: no confirmada; limitación de acceso/procesamiento de la herramienta a estas URLs. No se ha demostrado caída del sitio.
- Acción/verificación: urllib obtuvo HTML público del filtro combinado con código de éxito y lo guardó en work/catalogo-vinz-20261022/missiles-index.html. El HTML de Psionic Shots permite obtener URLs originales de previews sin descargar medios.
- Pendiente: terminar catálogo y verificar fuentes/previews accesibles. No descargar medios para eludir restricciones de visualización.

## Cierre mediante alternativa comprobada

Estado final: resuelto para el catálogo por alternativa. Las tres páginas del filtro y las 50 fichas se leyeron por HTTP público; 50/50 fichas ofrecen URL original de preview en su HTML. No se descargaron medios. El navegador abrió Psionic Shots y confirmó imágenes cargadas (naturalWidth 470 y 579, complete true). La herramienta web sigue sin procesar ciertas URLs de filtro/imagen; no se atribuye el fallo al sitio ni se afirma que todas las previews se hayan visto animadas.

Evidencias: [cobertura](../../../work/catalogo-vinz-20261022/cobertura.json), [catálogo](../../../work/catalogo-vinz-20261022/catalogo-completo.json) y HTML originales en esa carpeta. Las imágenes se presentan mediante sus URLs originales con enlace a la ficha fuente. Sin ensayos de compatibilidad ni importaciones al proyecto.

## Reapertura: previews inline no visibles

Estado actual: en investigación. El usuario aportó captura `/tmp/codex-clipboard-39e61561-a75c-46e0-ae0d-95eef9bebe62.png`: en la tabla del chat el primer recurso muestra un placeholder de imagen, no su preview. La validación anterior sólo comprobó que Hive servía la imagen en el navegador; no probó su renderizado en el mensaje final. Se corrige el alcance del cierre anterior. No es evidencia de un defecto del archivo MDX.

Se investiga la frontera de presentación de medios remotos del chat: acceso a URL, política de URL segura, carga/decodificación y renderizado de tabla. No se descargarán medios para sortear restricciones de visualización.

## Diagnóstico de presentación inline — 22 de octubre de 2026

Estado actual: diagnóstico parcial; pendiente identificar la condición exacta y validar una presentación inline funcional. El usuario sólo solicitó verificar el motivo, no modificar la aplicación.

Resultados comprobados:

- HEAD a las mismas URLs CDN de Psionic Shots y Shots Vol. I devuelve 200, image/webp y longitudes 2239168/1567000 bytes. No se descargaron sus cuerpos. La captura no demuestra un defecto de los MDX descargados.
- Código instalado en app.asar, versión package.json 26.1002.52244: oZc/cZc comprueban URLs Markdown no exentas mediante H1a, que llama a /ecosystem/url_safe; la lista de dominios exentos incluye openai.com, chatgpt.com y chat.com. Hive no está en esa lista. safeUrl sólo se asigna si la comprobación permite la URL.
- bZc muestra el fallback cuando no hay safeUrl tras concluir la comprobación (o medios restringidos). CZc también muestra el fallback cuando onError detecta que la imagen no cargó. wZc define el recuadro con min-h-24/min-w-24 (96px), fondo y el icono observado en la captura. Por tanto, el aspecto corresponde al fallback de imagen de la aplicación; el aspecto por sí solo no distingue política de URL, fallo del verificador o error de carga.
- Los logs de la app del 21/22 de octubre consultados no aportaron una respuesta de URL segura para estas imágenes. No se ha leído el estado de red del renderer del chat ni se ha confirmado que el bundle cargado en memoria sea idéntico al instalado. No atribuir el disparador exacto a seguridad, CORS, formato WebP, tamaño, Hive ni un defecto de tablas sin evidencia adicional.

Corrección de la conclusión anterior: verificar carga en el navegador no acreditaba que las imágenes se vieran dentro del chat. La tabla anterior no se entregó con previews inline verificadas. Como acceso disponible se conserva la ficha fuente con las previews: https://www.hiveworkshop.com/threads/shots-vol-i.315258/ . No se modificaron políticas, autenticación ni instalación, ni se descargaron medios para sortear restricciones.

Evidencias: [captura del usuario](../../work/catalogo-vinz-20261022/diagnostico-inline/captura-usuario.png), [fragmentos del código instalado y resultados](../../work/catalogo-vinz-20261022/diagnostico-inline/evidencia.json). Pendiente, si se pide depurar la app: capturar el resultado de carga/verificación del renderer para separar los disparadores, sin debilitar controles.
