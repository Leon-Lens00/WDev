# Comprobación de CodeGraph con el desarrollo existente

Fecha: 2026-10-21. Alcance: comprobar instalación/consultas/instrucciones respecto de TerrainDev, copia de InventorySys y diseñador UI Studio. Revisión de funcionamiento e instrucción; sin cambiar fuentes del producto, mapas ni configuración de CodeGraph.

## Resultado

La integración es utilizable en este chat. Se ejecutó realmente `codegraph_explore` con `projectPath` explícito en las tres raíces. Los resultados localizan los cambios previos: `Camera.win2World` con ojo real, `UIButton.showPlayer` con refresco de textura, `Inventory.show` idempotente, filtro UnitDex para dumi/dcst, InventoryTable aislada y transformación `projection.js` de UI Studio.

| Raíz | Archivos | Nodos | Aristas | Estado |
|---|---:|---:|---:|---|
| TerrainDev/src | 16 | 850 | 1141 | complete |
| TerrainDev/inventory-integration | 56 | 2576 | 3737 | complete |
| /home/snz/Documentos/WarDatsPy/ui-studio/dist | 4 | 126 | 734 | complete |

Los tres estados indican revisión `1.6.2+jass-vjass.2`, extracción 29, cero referencias pendientes y cero cambios pendientes. No recomiendan reconstrucción. La versión breve del CLI es `1.6.2`; el campo `index.builtWithVersion` identifica la adaptación local. `PRAGMA quick_check` devuelve `ok` en las tres bases. Los 76 hashes de archivos indexados coinciden con disco.

Se contrastaron 713 líneas devueltas por las consultas iniciales con las fuentes actuales, sin diferencias. El comparador conserva la línea vacía final, como el renderizador: descartarla inicialmente produjo tres discrepancias artificiales de EOF, descartadas al corregir la comparación. No eran diferencias del índice o del código.

Aristas estáticas representativas verificadas: RapidFire.RapidBolt.shoot → Missile.createXYZ; UIButton/UIPicture/UIText.update → Camera.win2World; geometryValue → previewValue; renderStage → projectionRect. Los nombres y posiciones son del código vigente. La cabecera genérica «Dynamic-dispatch links» de la respuesta no acredita dispatch dinámico vJASS; prevalecen sus avisos de cobertura y el alcance declarado.

## Actualización automática

Se abrieron las tres raíces mediante MCP y luego se creó, modificó y borró una función temporal independiente en cada raíz. La observación fue mediante SQLite de sólo lectura, sin consultar CodeGraph ni ejecutar sync durante las transiciones. Resultado: **9/9**, aproximadamente 0,4–0,5 s cada una. Las sondas fueron retiradas; los conjuntos/hash de archivos indexados regresaron al estado inicial. No se importaron al juego ni al navegador.

El índice de inventario respeta las exclusiones de build, evidence, runtime-isolated, source-demo, upstream y studio-before. TerrainDev actual y foundation-src del inventario siguen separados. Las fuentes y el mapa del inventario y los archivos de UI Studio coinciden además con los hashes de `TerrainDev/inventory-integration/verification.json` de la entrega anterior.

## Instrucción y límites

La sección CodeGraph de AGENTS.md es coherente: consulta previa por raíz, lectura directa para lo no cubierto/recortado, comprobación de vigencia, separación de variantes, recuperación y prohibición de sustituir la adaptación mediante upgrade. La guía propia de UI Studio aclara que CSS/HTML, server.mjs, pruebas y exportaciones están fuera de su índice JavaScript.

Se observaron 286 avisos de cobertura parcial en TerrainDev y 624 en inventario; cero errores de extracción registrados. UI Studio no registra diagnósticos. Los avisos incluyen macros, módulos, operadores y condiciones sin expansión/resolución completa. No prueban errores del juego ni cobertura completa de consumidores.

«No tests found» aparece en las consultas aunque existen ensayos del proyecto fuera del índice. La instrucción lo advierte correctamente. Los 78 controles del inventario, 16 pruebas del diseñador y las pruebas de juego anteriores siguen siendo evidencias independientes; esta comprobación no volvió a ejecutar sus builds o partidas ni amplía su cobertura.

Única corrección textual sugerida: el recordatorio persistente de la PC suministrado en el mensaje conserva «Las pruebas visuales dentro de Warcraft III aún no se han validado». Esa frase ya no describe las pruebas locales documentadas. Sustitución propuesta: «Se han realizado pruebas visuales locales de Warcraft III Classic 1.27b; consultar el informe de cada mapa para conocer su cobertura. Esto no acredita todos los flujos ni multijugador». No se cambió esa instrucción durante esta revisión.

## Evidencias

`work/codegraph-comprobacion-inventario-20261021/`: `explore-0/1/2.json`, `explore-filter.json`, `status-0/1/2.json`, `index-check.json`, `snippet-check.json`, `watcher-check.json` y el procedimiento reproducible `check_watcher.py`.
