# Integración InventorySys y calibración UI Studio

Fecha: 2026-10-21, America/Lima. Objetivo: Warcraft III Classic 1.27b.

## Alcance y base

Solicitud: copiar TerrainDev, integrar Inventory & Equipment System 1.4.1 con objetos/imports/dependencias y comparar en juego con `/home/snz/Documentos/WarDatsPy/ui-studio` para corregir diferencias comprobadas.

Originales inmutables: `TerrainDev.w3x`, `maps/originals/TerrainDev.w3x` y demo externa. Entrega separada: `inventory-integration/TerrainDev-Inventory.w3x`. Fuentes y constructor propios dentro de `inventory-integration/`; no modificar el constructor de TerrainDev. Partir del mapa actual verificado y fuentes correspondientes, conservar terreno, colocaciones y triggers originales.

Decisiones: mantener 150 huecos/5 páginas, 14 posiciones de equipo y reglas de objetos de la demo; añadir héroe utilizable con habilidades originales y comandos de acceso. No inventar requisitos de objetos ajenos a los suministrados. Conservar créditos.

## Contratos revisados

- Table de Bribe 3.1.0.1 (misiles) y Table de Vexorian 3.1 (inventario) no comparten API: aislar la segunda como InventoryTable.
- TimerUtils existente expone NewTimerEx/GetTimerData/ReleaseTimer: conservar una sola implementación.
- UnitDex será dueño de userdata excepto `dumi` y `dcst`, excluidos en onFilter para conservar el contrato del reciclador. Probar reserva y vuelo después de integrar.
- Copiar objetos Classic con sus modificaciones de objetos base, resolver TRIGSTR de demo sin colisionar con WTS del destino. No sobrescribir IDs distintos sin revisar.
- UserInterface crea unidades proyectadas por cámara; no admite Frame API. Sus rutas locales heredadas requieren revisión/ensayo multijugador separado, fuera de esta comparación local.
- UI Studio es una aproximación; JSON y fábricas exportadas aún no modifican automáticamente el mapa. Comparar puntos de controles, marcos, texto y relación de aspecto en capturas reales antes de ajustar.

## Fases y evidencias

1. Extraer demo y mapa actual, registrar hashes, recuperar WCT habilitado y revisar objetos/dependencias.
2. Preparar copia, fuentes editables WCT y constructor: aislar Table, filtrar UnitDex, combinar objetos/imports, compilar JassHelper y pJASS, reextraer y comprobar cambios por hash y originales conservados.
3. Ejecutar copia en juego. Comprobar carga, abrir/cerrar inventario/equipo, páginas, seleccionar/equipar/desequipar/soltar/vender y requisitos con los elementos suministrados; comprobar misiles mediante laboratorio independiente si es necesario.
4. Mostrar UI Studio, obtener capturas comparables, identificar diferencias observadas y ajustar predicción/implementación donde corresponda; repetir comprobaciones afectadas. Mantener copia de archivos modificados y pruebas del editor web.
5. Conservar informe con mapas/hash, capturas, comandos, resultados y límites. Abrir/guardar/reabrir una copia en NewGen para comprobar edición si es viable.

## Estado

Integración y calibración entregadas. El resultado, identidad, evidencias y límites están en `inventory-integration/RESULTADO.md` y `verification.json`. Se completaron construcción, comparación visual y verificaciones locales; guardar/reabrir en NewGen y multijugador siguen sin acreditarse.

## Avance de implementación y calibración

- Base fijada al SHA-256 inicial `37dcc7954b5318d512bb747e1d3dbae63030392895776759ba1a6933142f86c7`; el mapa principal está siendo actualizado por otro trabajo. La copia y sus once fuentes base están fijadas en `baseline.w3x`, `baseline-build.json` y `foundation-src/`. No heredar los nuevos cambios de RapidFire durante esta tarea.
- Integración compilada y reextraída, con 47 fuentes WCT y dos triggers GUI originales (49 triggers, cero bytes sobrantes). Colisiones remapeadas: item I000→V001, destructible B000→V000, dummy importado→UI\\InventoryDummy.mdx. Doodads de la demo excluidos para conservar los del terreno. Se añade sólo MorphAlternateDisable=0 de sus constantes, sin copiar sus cambios de balance.
- UnitDex excluye dumi/dcst; Table antigua aislada como InventoryTable; TimerUtils existente conservado. Se retiran generadores ObjectMerger: se importan sus objetos ya generados.
- Cámara: la elevación calculada difería ~22.8 unidades de la cámara real en el terreno. win2World usa el ojo real del cliente; marcos, botones y personaje aparecen en juego después del cambio.
- Correcciones de ciclo de vida en la copia: rangos de controles visibles, liberación de timer de clic, destrucción de unidades/textos/instancias, Camera.deallocate, ignorar unidades sin inventario en ocultar y ocultación idempotente. Compiladas; los escenarios de eliminación con clic pendiente requieren ensayo específico adicional.
- Primer laboratorio final: 75 controles sin fallos. Incluye ocho objetos, metadata de 30 texturas y mapeo de 30 botones, requisitos de nivel, fuerza +5/reversión, páginas, ocultar repetido, exclusión UnitDex y vuelo/reciclaje de un misil sin alarmas. No prueba multijugador ni ventas/soltado por clic real.
- UI Studio modificado: transformación de vista, guías de consola, referencia de captura, rasterización de marcos MDX, anclaje de textos, tooltip que sigue selección, edición con transformación coherente. Dieciséis pruebas pasan; exportador conserva coordenadas. Navegador comprobado: seleccionar, movimiento por teclado, deshacer y tooltip dinámico.
- Pruebas de juego ahora en prefijo independiente `runtime-isolated/`, para evitar interferir con la otra tarea. Cierre comprobado con Win+Q y S, proceso terminado; `evidence/closed.json`.
- Cierre: iconos resueltos refrescando la textura al mostrar el modelo; ocho iconos visibles. Laboratorio limpio: 78 controles sin fallos. Ratón real: páginas, tooltip, equipar/desequipar y requisito de nivel comprobados. El primer clic desfasado correspondía al movimiento sintético de Hyprland/Wine; enviar movimiento real antes del clic resuelve la prueba sin cambiar el mapa.
- Constructor binario congelado dentro de la integración para aislar cambios concurrentes; WTG conserva literalmente los dos registros GUI originales. Fuentes y script ejecutable contrastados con el ensayado; identidad final en verification.json.
- Partida final PID 62896 cerrada con S, sin SIGTERM; ningún war3.exe de este prefijo sigue ejecutándose. Informe y exportación conservados.
