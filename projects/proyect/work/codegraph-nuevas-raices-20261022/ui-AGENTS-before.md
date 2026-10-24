# Instrucciones de UI Studio

<!-- CODEGRAPH_START -->
## CodeGraph

- Para comprender/localizar o cambiar el código indexado de `dist`, consultar
  primero `codegraph_explore` con nombres de archivos/símbolos y
  `projectPath: /home/snz/Documentos/WarDatsPy/ui-studio/dist`.
  Si la herramienta está diferida, cargarla por nombre.
- Alternativa: `/home/snz/.local/bin/codegraph explore "SIMBOLOS" --path /home/snz/Documentos/WarDatsPy/ui-studio/dist`.
  El código devuelto cuenta como leído. Ampliar la consulta o leer directamente
  sólo los detalles no cubiertos o cuya vigencia no pueda verificarse.
- El índice actual contiene los JavaScript de `dist`. `server.mjs`, pruebas,
  documentos y exportaciones están fuera: inspeccionarlos con otras herramientas.
  No interpretar ausencia en este grafo como ausencia en todo UI Studio.
<!-- CODEGRAPH_END -->

La primera consulta MCP sincroniza y activa vigilancia de cambios en disco.
Crear, modificar y eliminar archivos se actualiza automáticamente mientras el
índice siga abierto. El servidor libera proyectos tras 10 minutos sin consultas;
la siguiente consulta reabre y sincroniza. Revisar avisos `DISABLED`, `RECOVERING`
o archivos pendientes; esperar/reintentar, sincronizar con
`/home/snz/.local/bin/codegraph sync /home/snz/Documentos/WarDatsPy/ui-studio/dist`
o leer las fuentes afectadas si la vigencia no puede comprobarse. Con CLI sin
MCP activo, sincronizar después de editar. El grafo no sustituye las pruebas.

La instalación local incluye adaptación JASS/vJASS de otros proyectos; no
reemplazarla mediante `codegraph upgrade` sin conservar y probar el parche.
Revisión local vigente: `1.6.2+jass-vjass.3`, extracción 30. Recargar servidores
MCP anteriores para usar esa revisión; no basta con reconstruir el índice.

## Notificación de errores

- Guardar el informe de cada fallo real o inesperado relacionado con este
  proyecto en `/home/snz/Documentos/ChatGPT/Proyect/informes/errores/` y enlazarlo
  al avisar en el chat. Consultar el formato en el `README.md` de esa carpeta.
  Usar `AAAA-MM-DD-HHMMSS-tema.md`, añadir un sufijo si ya existe y actualizar
  el mismo informe con repeticiones, recuperación y verificaciones. No
  sobrescribir informes de otros agentes ni guardar claves o datos sensibles.
  Si no se puede guardar, comunicarlo en el chat junto con el error original.
- Informar al usuario en el chat cuando se detecte un fallo real o inesperado al
  explorar, modificar, compilar, indexar o probar el proyecto. Indicar qué falló,
  la evidencia relevante y su impacto. Si compromete una conclusión o bloquea
  un paso, avisar antes de continuar con el trabajo que dependa de él.
- Comunicar también su desenlace: corrección y comprobación de recuperación, o
  qué queda pendiente y qué no pudo validarse. Continuar el trabajo independiente
  ya autorizado; avisar de un error no exige pedir permiso para cada recuperación.
- En CodeGraph, incluir fallos de conexión MCP, extracción, índice o
  sincronización, y estados `DISABLED`/`RECOVERING` que persistan o impidan
  verificar la vigencia. Informar si fue necesario usar una alternativa de lectura.
- Agrupar repeticiones del mismo fallo y actualizar su estado. Distinguir errores
  confirmados de sospechas, controles negativos previstos y avisos conocidos de
  cobertura parcial; estos últimos requieren aviso cuando afecten a la tarea.
