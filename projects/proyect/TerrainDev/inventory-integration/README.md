## Restauración vigente de cámara — 22/10/2026

Proyección Camera.eye original recuperada. Calibración inicial optativa por jugador
para altura del controlador, fuera de win2World. Inventario/equipo probados en
movimiento y reapertura, Classic1.27b SP1920×1080. Build d523040e…; ver
[restauración](../../work/camera-restore-20261022/RESTAURACION.md) y latest-build.json.
La demostración sigue independiente del diálogo. Las notas siguientes son historia.

# TerrainDev con InventorySys 1.4.1

**Auditoría del22/10:** el cambio local Camera.win2World (.eye→GetCameraEyePosition*)
reproduce desplazamiento/recorte durante movimiento en una copia A/B de la demo.
El original y uidm no estaban alterados. La reversión simple tampoco sirve en
la zona de TerrainDev ensayada: desaparece el panel. Corrección pendiente; ver
[comparación y evidencia](COMPARACION-ORIGINAL-20261022.md). Las comprobaciones
históricas siguientes no acreditan estabilidad de la interfaz durante movimiento.

Objetivo: Warcraft III Classic 1.27b. Copia independiente del mapa de desarrollo al inicio de esta tarea, 21 de octubre de 2026. El mapa principal continúa evolucionando en otra tarea y no se sobrescribe desde aquí.

Entrega: `TerrainDev-Inventory.w3x`. Inventario de 150 objetos en cinco páginas, equipo de catorce posiciones, bonificaciones/requisitos y ocho objetos iniciales del ejemplo. Se añade un paladín para cada jugador humano, con las habilidades originales de abrir inventario y equipo. Créditos de TriggerHappy y de las dependencias conservados en cada fuente.

Comandos: `-inventario`, `-equipo`, `-ui` para ambos, `-ayudaui` para controles y `-misiles` para ocultar/mostrar la tabla de diagnósticos cuando tapa la interfaz. La tabla sigue observando mientras está oculta. El terreno y sus unidades/triggers se conservan.

## Fuentes y construcción

- `baseline.w3x`, `baseline-build.json`, `foundation-src/`: base congelada. No dependen del último build de TerrainDev.
- `src/`: fuentes adaptadas y entrada TerrainInventory. `upstream/`: recuperación de la demo sin editar. `source-demo/`: miembros originales extraídos.
- `build.py` y `build_support.py`: auxiliares propios congelados; compila las fuentes vigentes y crea una salida nueva, combina objetos sin sobrescribir IDs originales, conserva cabecera y comprueba todos los miembros reextraídos. Los fuentes existentes de `src/` se consideran editables y no se regeneran al reconstruir.
- `latest-build.json`: identidad del entregable y rutas de compilación/verificación.
- `InventoryProbe.j`, `build.py --probe`: laboratorio separado; nunca se incorpora al entregable. `latest-probe.json` identifica el mapa ensayado.
- `play_isolated.py MAPA`: usa el runtime moderno instalado y un prefijo propio, copiado por reflink. Nunca cierra la otra partida de la instalación compartida. Cerrar y confirmar la partida propia antes de otra ejecución.

Reconstruir: `python3 /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration/build.py`.

Cambios de compatibilidad: InventoryTable aislada, un TimerUtils, filtro de UnitDex para dumi/dcst, remapeo de I000/B000/dummy.mdx del inventario, incorporación de MorphAlternateDisable=0 y retirada de generadores externos. La cámara proyecta desde el ojo real; se corrigen controles visibles, ocultar repetido y liberación de recursos. Las texturas se refrescan después de mostrar el modelo para evitar iconos antiguos.

## Diseñador y comparación

UI Studio: `/home/snz/Documentos/WarDatsPy/ui-studio/`. Vista **Warcraft 1.27b · calibrado**, con opción **Captura del juego**. Referencia editable en `exports/TerrainDev-calibrado-20261021/` dentro de esa carpeta. El perfil se calibró en la captura a 1920×1080; otros clientes y formatos son estimados. No altera las coordenadas vJASS exportadas. El personaje sigue siendo una guía, y la tipografía es aproximada.

`studio-before/` respalda los archivos anteriores del diseñador. `render_frames.py` rasteriza sus marcos a partir de los MDX/UV/atlas de la demo. El JSON exportado y sus fábricas no modifican automáticamente un W3X: para aplicar otro diseño se deben integrar en las llamadas y actualizaciones del mapa, como explica `Integracion.txt`.

Evidencias, controles y capturas: `evidence/`. Resultado detallado y límites: `RESULTADO.md`.
