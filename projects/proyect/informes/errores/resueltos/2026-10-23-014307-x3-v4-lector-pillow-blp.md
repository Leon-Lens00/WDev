# Lector Pillow ignora alfa separado de BLP1

ModelEditorV4, Classic1.27b. Al cotejar PNG y BLP1 con Pillow, primer píxel transparente(0,0,0,0) se leyó(0,0,0,255). No se cambió la cabecera de producción. Inspección del pluginBlpImagePlugin: _read_bgra recorre bytes como índices de paleta y usa el alfa de esa paleta; no consume la matriz alfa8 separada. El lector independiente mdx-m3-viewer devuelve(0,0,0,0) correctamente.

Impacto: verificación falsa negativa de textura, no fallo acreditado del archivo. Se sustituye ese cotejo por reconstrucción exacta de índices/alfa contraPNG y posterior lectorBLP independiente con hashRGBA. Header4/subtype1 y mips se conservan. Estado: corregido pendiente del chequeo completo de8texturas.

Recuperación comprobada: verificaciónV4 completa. NueveBLP con hashRGBA coincidente en lector independiente, dimensiones de todos los mipmaps válidas; seis modelos de vuelo con311poses cada uno y frentegeométricoXmáximo0, raíz fija. Flash255poses. Estado: resuelto.
