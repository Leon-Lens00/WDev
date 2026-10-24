# Acceso parcial mediante lector web a referencias Vinz / X3

Fecha:2026-10-22 America/Lima. Proyecto ModelEditor, biblioteca de referencia, sin cambios de modelos.

Síntomas: lector web no abre filtro Hive authorsVinz+tagMissile; Fandom X-Buster devuelve402; GIF directos de Retropixel devuelven error400/OK en el lector. No permite identificar la imagen por ese lector.

Acciones: abrir Retropixel en navegador. El navegador cargó correctamente la página y ambos GIF (243×47 y185×155); se inspeccionará su representación visual. El listado local anterior de50 recursos permite avanzar mientras se contrasta el filtro Hive mediante descarga HTTP normal. No se eluden credenciales, pagos ni avisos de seguridad; Fandom se sustituye por otra fuente accesible.

Estado: referencia textual alternativa disponible; verificación visual y recuperación del listado pendientes. Evidencia en `ModelEditor/evidence/vinz-library-20261022/` y plan `docs/planes/biblioteca-vinz-buster-x3.md`.

## Recuperaciones y límite de las capturas

El filtro Hive se recuperó mediante HTTP normal: tres páginas20+20+10, cincuenta paquetes descargados sin fallos;191MDX leídos. Los GIF se veían completos en navegador; las capturas recortadas del backend devolvían negro aunque el DOM situaba la imagen en otras coordenadas que la captura completa. No se cuentan como evidencia del efecto.

El intento de archivado por urllib sin agente de navegador devolvió HTTP406. Se intentó indebidamente la extracción de fotogramas tras ese fallo y encontró FileNotFoundError; no había referencias guardadas. Se usó la descarga de la imagen observada mediante el navegador; los dos GIF se guardaron con éxito en Descargas y se copiaron sin cambios al archivo de referencias, con firma GIF y hashes comprobados. No se necesita Fandom ni el lector web de GIF para continuar. Pendiente inspeccionar fotogramas y cerrar informe.

El lector web resolvió dos enlaces relativos de SpriteDatabase como `/file/files/...` y `/game/file/...`, ambos404. El navegador respetó el enlace absoluto/base y descargó `MegaManX.png` y `WeaponsItems.png` desde los enlaces visibles correctos. La hoja de armas de X3 está archivada con autoría Capcom y extractor Random Talking Bush. La inspección de fotogramas también corrigió una etiqueta provisional: el GIF segundo ya es el resultado fusionado C, no evidencia de la etapa B. El usuario recibió esa corrección; se buscará la referencia explícita antes de crear los modelos.

## Cierre verificado
Estado final: resuelto mediante corrección o alternativa descrita.
Recuperación por navegador y archivos originales de referencia, procedencia y hashes verificados. Muestras ABC corregidas e inspeccionadas. La alternativa permite continuar; los rechazos del lector web no se dan por reparados.
