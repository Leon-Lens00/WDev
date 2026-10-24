# Resultado — 21 de octubre de 2026

Se creó `TerrainDev-Inventory.w3x` para Warcraft III Classic 1.27b con Inventory & Equipment System 1.4.1, sus objetos, texturas, modelos, requisitos y dependencias. Conserva el terreno y las colocaciones del mapa base. El paladín añadido permite usar inventario/equipo mediante sus habilidades o `-ui`; `-ayudaui` explica los controles. `-misiles` oculta la tabla cuando cubre la IU.

La copia parte del TerrainDev al inicio de esta tarea, SHA-256 `37dcc7954b5318d512bb747e1d3dbae63030392895776759ba1a6933142f86c7`. El mapa principal y su evolución concurrente con RapidFire no se sobrescribieron ni se incorporaron a esta copia. El entregable final tiene SHA-256 `6cea157b51229f9ec32cf9d4d070e5e96be66c332382ef46665f1eaba45a9946`. Identidades y fuentes: [verification.json](verification.json).

## Cambios comprobados

- Se resolvieron las colisiones de Table, TimerUtils, rawcodes e importaciones. UnitDex excluye los dummies de misiles para conservar su contrato de userdata. Se conservaron los objetos/reglas de la demo sin inventar requisitos nuevos.
- La proyección de la cámara usa su ojo real: la diferencia de elevación del terreno impedía mostrar los paneles. Los iconos dinámicos necesitan refrescar la textura después de salir de escala cero; ahora aparecen los ocho.
- Se corrigieron índices de controles visibles, ocultaciones repetidas y liberación de recursos en la copia. Las fuentes conservan créditos.
- El constructor tiene auxiliares binarios propios y congelados; ambos triggers GUI originales se conservan literalmente, además de las 47 fuentes editables. Así, cambios concurrentes del constructor principal no alteran esta integración.

## UI Studio

En `/home/snz/Documentos/WarDatsPy/ui-studio/` se añadió **Warcraft 1.27b · calibrado** y **Captura del juego**. La transformación de pantalla, posición de textos, marcos rasterizados desde los MDX y tooltip ligado a la casilla seleccionada acercan la vista al cliente real. Arrastrar y editar dimensiones usa la misma transformación; exportar conserva las coordenadas originales vJASS.

El diseñador está disponible en [http://127.0.0.1:4317](http://127.0.0.1:4317). Exportación editable: `exports/TerrainDev-calibrado-20261021/`. Copias previas de los archivos cambiados: `studio-before/`. El JSON y las fábricas exportadas no actualizan automáticamente el W3X; `Integracion.txt` describe la conexión con el mapa.

![Diseñador superpuesto a la captura real](evidence/studio-calibrated.png)

## Verificación y límites

JassHelper y pJASS pasan. Todos los miembros reextraídos y la cabecera se verificaron; WCT contiene 47 fuentes exactas, 49 triggers y cero bytes sobrantes. El último ajuste de WTG conserva los triggers GUI: su JASS ejecutable es idéntico al mapa sin laboratorio que se abrió en el juego.

El laboratorio separado pasa **78 controles, cero fallos**: ocho objetos, metadata/mapeo de 30 casillas, requisitos, equipar/desequipar, fuerza +5 y reversión, páginas, ocultación repetida y un misil que llega y vuelve al reciclador sin alarmas. [Registro](evidence/61409-InventoryProbe-page.txt).

Se comprobó por ratón subir/bajar página, tooltip, equipar la corona a nivel 3 y retirarla; el mapa sin laboratorio rechaza la corona a nivel 1. [Equipado](evidence/clean-equipped.png), [retirado](evidence/clean-unequipped.png), [requisito](evidence/delivery-requirement.png). La prueba inicial de clic usaba la posición antigua de Wine: mover el cursor con Hyprland requiere además enviar un movimiento real; las fuentes del mapa no necesitaron un parche para eso.

**UI Studio: 16 pruebas pasan**, incluyendo centros medidos de cuatro botones a menos de cinco píxeles, transformación inversa y exportación inalterada. En navegador se comprobó selección, movimiento, deshacer y tooltip. Las fábricas exportadas compilan con las fuentes finales: `evidence/export-final-compile.json`.

No se acredita multijugador/ausencia de desincronización, guardar y reabrir en NewGen, todas las rutas de venta/soltado/engaste por clic ni eliminación con clic pendiente. La calibración real corresponde a 1920×1080; otros formatos son estimados. La fuente y el personaje del diseñador siguen siendo aproximaciones y el contenido del tooltip usa datos de ejemplo.

Todas las partidas de esta tarea están cerradas; la última confirmó «S» y terminó sin SIGTERM: [cierre](evidence/closed-62896.json). El prefijo propio evita cerrar procesos de otros trabajos.
