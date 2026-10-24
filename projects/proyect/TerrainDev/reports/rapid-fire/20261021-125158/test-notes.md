# Investigación y correcciones del laboratorio

Se conservan los ensayos fallidos. No equivalen a PASS de la entrega.

- Los primeros callbacks no avanzaban: el fixture leía p sin inicializar. Tras inicializar explícitamente p/q a0, el mismo recorrido produjo registros y cobertura positiva. El temporizador de monitorización se creó explícitamente y se usó1/32s; no se cambió el núcleo de Missile.
- 20261021-132656: cuatro fallos del fixture. Se pedía cero proyectiles a1.7s aunque los últimos aún podían volar hasta2s. Se extendió esa observación a2.1s sin alterar el emisor. Los endpoints del cliff tenían pathing válido sólo en el centro, no en toda la huella; se buscaron endpoints con huella libre y cambio real de altura/nivel. El flag SetTerrainPathable se había interpretado al revés; la pared se dejó bloqueada antes del siguiente ensayo.
- 20261021-133151: una comprobación fallida. El readback nativo confirmó que la pared seguía bloqueada al iniciar el caso final. Se restauró con flag true y se comprobó IsTerrainPathable=false antes del disparo.
- 20261021-133527:44 comprobaciones, cero fallos;47 emisiones observadas con mínimo0.250s;5 controles negativos rechazados por el evaluador. Incluye último tramo, pared, árbol, cliff4↔3 y rampa de altura333.750↔244.625.

El primer tick instantáneo tiene prueba independiente en position-probe. SetUnitPosition cancela la orden de viaje; SetUnitX/Y conserva move. La implementación separada usa esa transición antes del primer attack.

La otra ventana de Warcraft usa inventory-integration/runtime-isolated; no es propiedad de este laboratorio. Las partidas de este trabajo se identifican por PID/inicio/prefijo/hash y se cierran individualmente.
