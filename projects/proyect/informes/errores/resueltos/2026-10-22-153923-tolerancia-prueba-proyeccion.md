# Tolerancia en prueba de proyección

Fecha: 2026-10-22 15:39:23.299235; UI Studio, chat actual.

Cambio de escala solicitado68%/margen14.4% produjo diferencias de2e-15 entre dos órdenes de operaciones flotantes. La prueba assert.equal esperaba igualdad exacta de top-3, aunque no había diferencia visual. Se sustituye por tolerancia1e-10, inferior a cualquier píxel representable en esta vista. Estado: resuelto por corrección del control; resultado en work/dialogue-composition-20261022/node-user-scale-final.log. No cambia el cálculo de proyección.
