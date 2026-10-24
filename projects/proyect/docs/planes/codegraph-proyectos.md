# Preparación de CodeGraph para los proyectos actuales

Fecha: 2026-10-21. Objetivo: habilitar consultas de las fuentes actuales sin
mezclar TerrainDev, la copia de inventario y el diseñador de IU.

## Alcance y decisiones

- TerrainDev: indexar `TerrainDev/src`, con RapidFire, GroundMotion y las
  bibliotecas vigentes. Las copias de mapas y los JASS generados quedan fuera.
- Inventario: indexar `TerrainDev/inventory-integration`, conservando `src`,
  `foundation-src` y auxiliares propios. Excluir los builds, evidencias,
  runtime, upstream original, demo extraída y respaldos del diseñador.
  La copia tiene una base congelada propia; no sustituirla por TerrainDev actual.
- UI Studio: indexar `/home/snz/Documentos/WarDatsPy/ui-studio/dist`, cuyos
  JavaScript son los archivos ejecutados y mantenidos en este proyecto.
- Preservar mapas, fuentes y resultados de las pruebas previas. Esta operación
  no vuelve a compilar ni acredita nuevas pruebas del juego o multijugador.
- Registrar hashes antes/después en `work/codegraph-proyectos-20261021/`.

## Entregables y aceptación

1. Inicializar los tres índices con el lanzador local JASS/vJASS. Comprobar
   archivos/nodos no vacíos y que cada índice contiene sólo su alcance.
2. Ejecutar consultas MCP reales: RapidFire/GroundMotion, Inventory/UserInterface
   y un símbolo del diseñador. Conservar resultados y notas de cobertura parcial.
3. Añadir en AGENTS.md las rutas explícitas, el uso previo a explorar/cambiar
   código y la actualización/verificación de vigencia. Para macros, módulos,
   ambigüedad o código omitido, inspección dirigida y validadores existentes.
4. Confirmar hashes sin cambios de las fuentes/mapas observados y registrar
   el estado final. Los chats ya abiertos deberán releer las instrucciones;
   esta tarea no envía mensajes a otros chats ni prueba su cumplimiento futuro.

## Estado y resultados

Preparación completada. Los tres índices están inicializados, con
`index.state=complete`, `pendingRefs=0` y sin recomendación de reindexado.

| Índice | Archivos | Nodos | Aristas |
|---|---:|---:|---:|
| TerrainDev/src | 16 | 938 | 1124 |
| inventory-integration | 56 | 2664 | 3747 |
| ui-studio/dist | 4 | 126 | 734 |

Se ejecutaron consultas MCP reales de RapidFire/GroundMotion,
Inventory/UserInterface/TerrainInventory y screenToUI/uiToScreen. Los avisos de
extracción vJASS se conservaron; las macros y llamadas encadenadas siguen siendo
cobertura parcial, sin certificación de consumidores completos.

`AGENTS.md` contiene las tres rutas, consulta prioritaria, vigilancia automática,
recuperación manual y los límites del grafo. Se comprobaron por SHA-256 los
71 archivos de fuentes y mapas inventariados: ninguno cambió. Las exclusiones
del índice de inventario se verificaron consultando su base en modo lectura.

Evidencias: `work/codegraph-proyectos-20261021/verification.json`, los tres
`*-init.json`, `*-sync.json`, `*-status.json` y `*-mcp.json`.

Continuación: al retomar los otros chats, releer AGENTS.md y elegir la raíz de la
variante que se está modificando. No se enviaron mensajes a esos chats ni se
ejecutaron builds o partidas.

## Verificación del funcionamiento original y actualización automática

Se contrastó upstream v1.6.2, commit
`6560052a6f856855d3f71eee838fd66ccfa4285d`, con la variante instalada. Motor MCP,
ciclo de vida por proyecto, watcher, bloqueo de escritor e integración del
instalador Codex son idénticos al commit original. La configuración real usa
el lanzador local y `serve --mcp`; Node 24.16.0 es compatible. No hay
`--no-watch`, `CODEGRAPH_NO_WATCH` ni modo de sólo lectura configurados.

Corrección de la conclusión anterior: esta versión SÍ vigila los proyectos
abiertos por `projectPath`. Una frase de `server-instructions.ts` dice todavía
lo contrario; el motor, sus pruebas y el ensayo real la contradicen. No hace
falta ejecutar `sync` en cada edición cuando el watcher funciona.

- Se consultaron de nuevo las tres raíces por MCP. Después se observó SQLite
  en modo lectura, sin ejecutar consultas CodeGraph ni `sync` durante el ensayo.
  Crear, renombrar un símbolo dentro del archivo y borrar el archivo temporal
  se reflejó automáticamente: 9/9 transiciones, aproximadamente 0,4–0,6 segundos.
  Todos los archivos temporales fueron eliminados, también del grafo.
- El responsable de escritura compartido fue PID 3434, `ready=true`. El diseño
  comparte propietario entre procesos y libera los proyectos explícitos tras
  600000 ms sin consultas (o desalojo de caché/cierre). La siguiente consulta
  vuelve a abrir, sincronizar y vigilar; no se promete vigilancia permanente
  con el servidor cerrado o el índice liberado por inactividad.
- Se ejecutaron seis suites: `mcp-projectpath-lifecycle`,
  `mcp-require-project-path`, `mcp-writer-lock`, `mcp-status-freshness`,
  `mcp-staleness-banner` y `jass-vjass`: **92 pruebas aprobadas**, ninguna omitida.
  Cubren reapertura/catch-up, varios motores, relevo del escritor, avisos de
  vigencia, esquema sin raíz predeterminada y resolución/sync del subconjunto
  JASS/vJASS. No certifican el lenguaje completo ni el funcionamiento del mapa.
- UI Studio no heredaba el AGENTS.md de este proyecto. Se añadió su propia guía
  en `/home/snz/Documentos/WarDatsPy/ui-studio/AGENTS.md` para chats abiertos allí.
  Los agentes deben releer la guía y consultar el índice: la instalación no
  acredita que todos los chats existentes ya lo estén usando.
- Cierre del ensayo: las tres bases pasaron `PRAGMA quick_check`; sus estados
  indicaron cero archivos pendientes, cero referencias pendientes y ninguna
  recomendación de reindexado. Se conservaron los recuentos originales
  (16/56/4 archivos), sin restos de las sondas. Los 71 hashes de fuentes/mapas
  siguieron iguales y las exclusiones de inventario continuaron respetándose.

Evidencias adicionales: `auto-sync-verification.json`,
`upstream-audit-tests.log` y `audit-verification.json` en el directorio de
evidencias existente. Las consultas reales de esta revisión se guardan como
`*-audit-mcp.json`. La prueba reproducible está en `verify-autosync.py`;
requiere abrir previamente las tres raíces por MCP para activar sus watchers.

Fuentes originales:

- https://github.com/colbymchenry/codegraph/blob/6560052a6f856855d3f71eee838fd66ccfa4285d/src/mcp/engine.ts
- https://github.com/colbymchenry/codegraph/blob/6560052a6f856855d3f71eee838fd66ccfa4285d/src/mcp/project-lifecycle.ts
- https://github.com/colbymchenry/codegraph/blob/6560052a6f856855d3f71eee838fd66ccfa4285d/src/installer/instructions-template.ts
