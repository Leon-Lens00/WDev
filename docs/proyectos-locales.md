# Proyect y UI Studio

Incorporación autorizada por el usuario el23/10/2026 al repositorio privado WDev.
Son copias de trabajo seleccionadas, no una sincronización automática ni un
respaldo literal de todo el disco.

| Fuente en esta PC | Carpeta dentro de WDev |
|---|---|
| `/home/snz/Documentos/ChatGPT/Proyect/` | [`projects/proyect/`](../projects/proyect/) |
| `/home/snz/Documentos/WarDatsPy/ui-studio/` | [`tools/ui-studio/`](../tools/ui-studio/) |

Se incluyen TerrainDev actual, diálogo/inventario, ModelEditor, WaveSys, fuentes,
pruebas, documentación, recursos de entrada, modelos y exportaciones. `dist/` de
UI Studio se conserva porque contiene el JavaScript activo de la aplicación.
No se aplicaron cambios funcionales ni se compilaron mapas durante esta copia.
Las atribuciones/licencias de modelos y recursos siguen en sus carpetas de origen.

## Evidencias y exclusiones

Se conservan informes/resultados ligeros y muestras finales seleccionadas:
preview de retratos, diálogo con patrulla y pruebas de barras. La evidencia
multimedia masiva, los logs, dumps e históricos grandes siguen en la PC original.
Tampoco se incorporan Wine/runtimes, entornos virtuales, dependencias instaladas,
ROMs, upstream descargado, builds/artifacts regenerables, claves ni `.env`.
Los enlaces simbólicos no se siguen ni convierten en copias de carpetas externas.
`ModelEditor/exports` sí se conserva: contiene entregables y fuentes de modelos.

El [inventario](proyectos-locales-inventario.json) registra cada archivo añadido,
su ruta de origen, tamaño y SHA256; la [lista de exclusiones](proyectos-locales-exclusiones.json)
detalla archivos/directorios omitidos. Las exclusiones de directorios podan el
árbol completo. El inventario cubre las dos raíces importadas; esta guía y sus
metadatos de publicación pertenecen al repositorio de destino.

## Reutilizar o actualizar

Las carpetas originales permanecen en su ubicación y siguen siendo el entorno
activo en esta PC. Los cambios futuros requieren otra copia revisada, commit y
push: GitHub no observa ni sincroniza automáticamente esas carpetas externas.

Los AGENTS.md, scripts y guías conservan sus rutas originales como procedencia.
En otra instalación, adaptar rutas y dependencias antes de ejecutar herramientas;
no interpretar los índices de esta PC como cobertura de la copia de GitHub.
Se conservan codegraph.json, pero las bases `.codegraph/` no se suben. El código
de CodeGraph está en `mcp-w3/codegraph-vjass`; reconstruir índices sólo en raíces
autorizadas, después de configurar el entorno y revisar sus instrucciones.

ModelEditor depende de bibliotecas del runtime externo indicado en
`src/runtime.cjs`. Los compiladores, Warcraft/Wine, dependencias de terceros y
otras rutas locales documentadas necesitan preparación aparte. Esta publicación
acredita copia e integridad de archivos, no portabilidad ni funcionamiento desde
un checkout nuevo. Para recuperar exactamente todas las pruebas históricas se
necesita además el archivo de evidencias que permanece fuera de Git.

## Actualizaciones

- **2026-10-25 — WaveSys**: copia actualizada desde `Proyect/WaveSys` tras la corrección del núcleo de oleadas y el
  rework de conexiones (núcleo `WaveCore`, capas `WaveSpawnFx`/`WaveOwnerPolicy`, puente RestTime, tablero ligado,
  contrato en `projects/proyect/WaveSys/docs/contrato-wavecore.md`). Mismo criterio de exclusión que la incorporación:
  sin `artifacts/`, `.cache/`, capturas `png` ni `log` de evidencia; tampoco la instantánea local de rollback
  `evidence/snapshot-rework-fase1-20261025/`. El inventario se actualizó solo en las entradas de WaveSys
  (`waveSysUpdated`). Ensayos en Warcraft III Classic 1.27b en la PC original; no se repitieron desde esta copia.

