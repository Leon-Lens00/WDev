# Comparador auxiliar WTS: comentarios

Fecha: 2026-10-22T16:34:20.613182-05:00. Proyecto: auditoría InventorySys en Classic1.27b. Estado: resuelto.

El comparador inline de objetos falló con KeyError844, al usar STRING seguido directamente de llave en su expresión regular. El WTS original contiene un comentario de procedencia entre STRING844 y su llave. Fallo del auxiliar de esta auditoría; no del mapa.

Se amplió la lectura para admitir el comentario y BOM; el control strings(fresh141)[844] == EquipmentWindow pasó, y la resolución completa de objetos en fresh141/fresh143/integrated terminó sin referencias pendientes. Salida unit-objects.json y asset-compare.json en work/inventory-original-audit-20261022/. No se modificaron mapas, WTS ni bibliotecas. El formato sólo se acredita para estos archivos.
