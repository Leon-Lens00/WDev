# Misiles por color de propietario — 22 de octubre de 2026

Objetivo: sustituir FireBall de Rapid Fire por los 12 MDX800 Misil-simple de Vinz organizados en ModelEditor. Originales intactos. Destino: Classic 1.27b, CachyOS/Wine; Missile2.5.1 y su movimiento/reciclaje conservados.

Base: TerrainDev.w3x d7fd80bfeb175762ee9ed80331f1ac72a3913c3a7d5257c520338f1f467f0414, 15 bibliotecas. Consulta CodeGraph: RapidBolt.shoot/resolve, Missile.scale/model, GroundCollision.trace y GetPlayerColor. El grafo devuelve fuentes actuales, proyecciones y avisos conocidos; JassHelper/pJASS y motor siguen siendo verificaciones separadas.

Decisiones: color del propietario leído en cada emisión, no número del slot ni número arbitrario de equipo. API RapidPair.setColor(playercolor) para un color individual/de equipo; clearColor() restaura la política del propietario. La primera propuesta null-reset fue descartada al comprobar que rojo enum0 se compara igual a null en Classic: se usa un booleano separado. Classic no tiene GetUnitColor. Proyectiles en vuelo mantienen el color elegido al salir. Se conserva shoot(unit,x,y) para consumidores actuales. HIT_RADIUS16 es compartido por ambos traces del proyectil y la calibración visual. La estela/death no define una colisión ampliada.

Fases:
1. Comprobar hashes, MDX800, texturas y geometría de los12 modelos; copiar recursos a assets con procedencia y créditos. Registrar import paths únicos.
2. Adaptar sólo RapidFire (selección, override y escala) y builder (imports reproducibles y reextracción). Sin cambios en Missile, Recycler, GroundMotion ni daño/tiempos.
3. Compilar/empaquetar. Probar12 colores, propietario con color distinto al slot, override, cambio de color/recast y reciclaje. Contrastar escala en juego con marcadores del radio y repetir la regresión Rapid Fire afectada.
4. Actualizar docs/verificación con hashes y cobertura real; cerrar sólo la instancia propia del juego.

Builder y laboratorios tienen raíz CodeGraph propia TerrainDev/scripts: Python/JASS auxiliares, sin binarios ni cachés; JASS conservative/incompleto porque no son una unidad de compilación. No confundir sus probes con código de producción ni interpretar aristas entre índices. Mantener tablas de raíces y guía al completar la integración.

Estado: completado y probado localmente en Classic1.27b. Modelos/texturas reextraídos por hash; build reproducible y WCT preservados.12 MDX800 revisados con dos lectores. Calibración1/1.5/2.74 y paleta12 observadas en juego; escala16/5.832 seleccionada para el ancho máximo del cuerpo32. Laboratorio de colores40PASS y regresión RapidFire44PASS,9 controles negativos rechazados. Se restaura posición de la demo entre laboratorios; desaparecieron los dos fallos de aislamiento sin cambiar física. Instancia propia cerrada mediante menú del HWND propio y confirmación S; no hubo teclas globales en el cierre final. Resultados y límites en reports/shot-colors-20261022/result.json y reports/verification.json. Multijugador/carga y guardado en editor de esta revisión no acreditados.

## Sustitución visual — 22 de octubre de 2026

Aplicada la revisión `shots-vol-i-organizados-brillo`: 12 MDX y14 BLP, conservando rutas de los modelos. Geometría y1068 poses exactas respecto a la revisión anterior; emisión, materiales y anclaje conservados. Radio16 y escala16/5.832 sin cambios. Copia previa, hashes y evidencia nueva en `reports/shot-refresh-20261022-184335/`. Compilación y prueba de integración se registran en el resultado de esa carpeta. No cambia fuentes JASS ni mecánicas.
