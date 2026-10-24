# Lectura de nombres MPQ

Fecha local: 2026-10-22 15:03:21.908609; diálogo Classic 1.27b, agente de este chat.

Síntoma: filtro auxiliar de `wc3ctl ls war3.mpq --json` falló con AttributeError al aplicar lower() a Name=null. No se modificaron archivos del juego. Causa confirmada: entradas sin nombre admitidas por el inventario MPQ.

Estado: resuelto. Se repitió la lectura con `(f.get("Name") or "").lower()`; código 0 y nombres TTF obtenidos. Sólo acredita inventario y recuperación del auxiliar, no la fuente realmente usada en pantalla.
