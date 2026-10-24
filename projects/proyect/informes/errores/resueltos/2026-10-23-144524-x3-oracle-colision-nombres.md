# Colisión de nombres del laboratorio X3

Fecha: 2026-10-23, Codex /root. TerrainDev, CachyOS/Wine, Warcraft III 1.27b, JassHelper. Estado: corregido pendiente de verificar.

El mapa de producción f087047b compiló y pasó pJASS. La nueva copia de laboratorio falló al compilar: `X3Oracle.X3NativeProbe___checks is not a member of X3Oracle`. Causa confirmada: el preprocesador de privados reescribe `checks` y `failures` también al encontrarlos después del receptor público `X3Oracle`.

Reproducción: `python TerrainDev/scripts/prepare_x3_probe.py`. Evidencia: TerrainDev/reports/x3-rom-port-20261023-143455/20261023-144423/compile.json y FrozenThone/runtime/wc3-tools/reports/vjass-20261023-144423-856525/jasshelper.log. No se inició el juego ni se validó el laboratorio fallido.

Corrección: nombres públicos exclusivos `valueChecks/valueFailures` en el generador y consumidor. Recompilar y ejecutar en motor pendientes. Impacto limitado al laboratorio, fuentes de producción sin cambio.

Recuperación comprobada: prepare_x3_probe.py completó JassHelper y empaquetado/reextracción idéntica en reports/x3-rom-port-20261023-143455/20261023-144524. Estado: resuelto (compilación del laboratorio); ejecución funcional aún pendiente.
