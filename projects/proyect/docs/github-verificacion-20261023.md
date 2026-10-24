# Verificación de WDev en GitHub ·23/10/2026

Repositorio: https://github.com/Leon-Lens00/WDev (privado), rama main,
revisión `8c38cc1033e49c88c74ebebcf2b444bd52669868`. Lectura por gh con la sesión existente.
No se subieron archivos, no se configuraron remotos ni se modificó WDev.

## Alcance corregido por el usuario

El usuario pidió subir únicamente `/home/snz/Documentos/MCP W3/` y
`/home/snz/Documentos/ChatGPT/WDev/`. La carpeta desde la que trabaja este chat,
`/home/snz/Documentos/ChatGPT/Proyect/`, no es WDev. Su ausencia no es un fallo
respecto al encargo de subida. La primera inspección se amplió a todo lo trabajado
para responder la pregunta inicial; los hallazgos se separan según ese alcance.

## Comprobaciones

- Checkout WDev: HEAD y origin/main iguales a la revisión remota consultada,
 6975archivos versionados, status limpio, cero diferencias de lista y cero
 archivos versionados ausentes del disco. Árbol remoto no truncado.
- MCP W3 está copiado bajo mcp-w3. CodeGraph:1367archivos de su árbol publicado
 coinciden byte por byte con las fuentes locales comparadas, incluida JASS-VJASS.md.
- Forge:2243coincidencias directas;48diferencias binarias quedan explicadas
 íntegramente por normalización CRLF→LF. No se encontró cambio de contenido en ellas.
- Las9skills Codex copiadas suman78archivos, todos idénticos a sus fuentes locales.
- No se promete una copia literal de cada archivo del disco: WDev tiene3053archivos
 locales ignorados. En MCP se encontraron7577extras sin blob idéntico remoto:
 7566cubiertos por reglas de exclusión y11sin esa exclusión. Los11son descargas,
 metadatos/hashes de releases y auxiliares locales en bin; se detallan en
 mcp-extra-classification.json. La comparación inicial también poda caches,
 runtime/build y omite symlinks; no acredita copia completa de esos elementos.
- Evidencias, binarios regenerables y dependencias descargadas requieren una
 política de respaldo separada si se quiere restaurar exactamente todo el entorno.

## Trabajo de este proyecto que quedó fuera del encargo

1. `/home/snz/Documentos/ChatGPT/Proyect/`: TerrainDev actual, diálogo, integración
 de inventario, ModelEditor, WaveSys, docs e informes. Los nombres no aparecen
 como tales en el remoto; se compararon también hashes globalmente por si estaban
 renombrados. Ninguno de los8943archivos examinados de ModelEditor tuvo un blob
 idéntico en el árbol remoto, incluidos optimize-portraits.cjs y PREVIEW.mp4.
 TerrainDev/src23/23y scripts29/29no tienen blob idéntico. Otras carpetas comparten
 algunas dependencias; no implica que sus proyectos actuales estén respaldados.
2. `/home/snz/Documentos/WarDatsPy/ui-studio/`:256archivos examinados sin blob
 idéntico remoto. No confundir con el frontend de Forge, que es otro componente.

Para respaldar todo lo trabajado, estas son las dos raíces adicionales principales
identificadas. Este informe no autoriza publicarlas ni recomienda subir builds,
runtimes, cachés y vídeos indiscriminadamente.

## Método, evidencia y límites

Árbol Git remoto completo de6975blobs, comparación por SHA1 de blob Git sobre bytes
reales y tamaño, búsqueda de coincidencias en cualquier ruta, y comprobación
adicional CRLF→LF para las48diferencias de Forge. No se leen fuentes para acreditar
compatibilidad ni se compila/prueba el código; esta es una auditoría de archivos.
No se examinan contenidos embebidos dentro de mapas/ZIP ni Git LFS remoto, y no
se auditan todos los directorios del home. Resultado referido a esa revisión;
no se garantiza ausencia de cambios posteriores.

Datos: `work/github-audit-20261023/remote-identity.json`, remote-tree.json,
comparison.json, wdev-status.json, forge-eol-check.json y mcp-extra-classification.json.

Conector GitHub: [lectura por alternativa CLI](../informes/errores/resueltos/2026-10-23-220153-github-conector-repo-privado.md).
