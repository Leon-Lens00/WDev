# Rapid Fire y movimiento independiente

Objetivo: Warcraft III Classic1.27b, JASS/vJASS. Implementación local separada del núcleo de BPower. `GroundCollision`, `GroundMotion`, `RapidFire` y `RapidFireDemo` se incrustan como fuentes editables en el mapa. No se copia el movimiento de Missile sobre la unidad visible porque éste también impone su orientación.

## Usar el prototipo

Al cargar, la cámara sigue al fusilero visible y la selección corresponde a su controlador fuera de cámara. Seleccionar de nuevo al fusilero vuelve a seleccionar ese controlador. **Q y clic en suelo** lanza Rapid Fire; **clic derecho en suelo** transmite el destino de movimiento. Los blancos de demostración son unidades enemigas inmóviles. `-misiles` muestra/oculta la tabla.

Seis proyectiles por ventana nominal de1.5s: primero inmediato, luego cada0.25s; última salida en1.25s y liberación de movimiento/animación en1.50s. Durante la actividad, recastear repone seis pendientes y cambia la puntería de los siguientes proyectiles; conserva el reloj. El punto de cast sólo da la dirección: cast y recast proyectan la puntería a RANGE desde el actor, así que orientación y tiros no giran si el actor pasa el punto pulsado. Los proyectiles que ya salieron mantienen su destino. Recasts continuos pueden prolongar la ráfaga.

El ejecutor reproduce `attack` por salida y usa factor de animación3.0. Al cerrar restaura1.0. El prototipo asume que esta capa posee el factor de animación y el pathing del ejecutor: futuros buffs o sistemas de movimiento deben coordinar esa propiedad.

## Movimiento

`GroundMotion.create(unit)` crea estado separado; `destination(x,y)` actualiza el destino. Fuera de la ráfaga emite move nativo. `enter()` toma la locomoción: si había move/smart/patrol, realiza un **tick inicial de duración cero con SetUnitPosition en las coordenadas actuales**, antes del primer attack. Así cancela el viaje nativo sin una orden stop ni un paso extra de velocidad. `step(dt)` usa únicamente SetUnitX/Y tras comprobar el tramo; recastear no vuelve a llamar a enter. `leave(true)` devuelve como máximo un move hacia el destino todavía pendiente.

Velocidad artificial350unidades/s, radio24, paso1/32s. Cambiar el destino no altera la puntería. La orientación se calcula hacia la puntería desde la posición actual. El movimiento ignora unidades; se detiene antes de un obstáculo y conserva el destino. Al terminar la ráfaga, el motor puede buscar una ruta nativa restante. No hay deslizamiento ni búsqueda de ruta durante el avance artificial.

`GroundCollision.trace` barre tramos en subpasos de hasta8unidades, comprueba centro y ocho puntos de la huella, pathing, objetos/árboles vivos, cambios abruptos de altura y límites del mundo. Emplea un ítem oculto para consultar walkability sin colisión con unidades; oculta/restaura ítems visibles cercanos durante la consulta. La técnica toma como referencia TerrainPathability/IsTerrainWalkable de Rising_Dusk/BPower, sin modificar Missile. Rect, grupo, location e ítem de consulta persisten durante la partida, compartidos por las consultas síncronas.

La huella se aproxima con muestras; no representa exactamente cualquier forma de modelo. Los destructibles con pathing inexistente se aproximan mediante radio y altura de oclusión/árbol. Un recurso futuro con huella especial debe probarse y configurar su radio; no se acredita transitabilidad universal de modelos/imports ni puentes personalizados.

## Proyectil y pareja

Valores editables en RapidFire: familias Firebrand (Q, radio30), Shots I (W, radio6) y Shots II (R, radio18), escala1, velocidad1200, daño25, alcance fijo `RapidBolt.RANGE=1350`, altura igual al radio (a ras de suelo; chocar en desniveles es deseado). Estela/halo/death son decorativos. Durante el movimiento artificial el actor lleva Windwalk de Vinz en `origin`, del color del misil; se destruye al salir del modo. Importar en otro mapa: [guía](importar-rapid-fire.md). Ver [selección por propietario y override individual/equipo](misiles-colores.md). Daña una vez al primer enemigo terrestre válido y termina; excluye controlador y dummies. Aliados y unidades voladoras no reciben impacto. Árboles y suelo bloqueantes terminan el vuelo sin destruirse automáticamente. También se comprueba el último segmento del vuelo y el tramo hasta la boca del arma; la colisión se resuelve en el consumidor, conservando el orden de callbacks del núcleo común.

`RapidPair.create(controller,actor)` enlaza unidades mediante Table. Sólo el controlador posee `Arpf`, basada en Channel de punto, sin coste/cooldown. La selección y cámara son cambios locales de UI; la lógica y creación de handles se ejecutan fuera de ramas GetLocalPlayer. El ticker de movimiento/reloj persiste durante la partida; cada pareja posee un timer reutilizable para aparcar el controlador después de una orden. La destrucción libera ese timer, mappings y movimiento, elimina el proxy y deja el cuerpo visible a su propietario. Muerte o eliminación del cuerpo/proxy retira la pareja en el siguiente tick. Los misiles ya emitidos terminan su propio vuelo.

Objetos generados reproduciblemente por `scripts/rapid_objects.py`: `rfct`controlador, `rfex`ejecutor, `rftg`blanco y `Arpf`habilidad. `scripts/build.py` conserva los objetos originales y comprueba colisiones de IDs.

Las seis filas añadidas al panel muestran ráfagas/pendientes, movimientos/bloqueos, tiros/recasts, mínimo intervalo/base, transiciones instantáneas/pasosXY y retornos nativos/proyectiles vivos. Los mínimos son observaciones del emisor, no una medida de FPS o latencia de entrada.

Fuera del prototipo: Stop/Hold, órdenes a unidades como follow/ataque/recoger, Shift, stun/silencio y coordinación con otros dueños de animación/pathing. Las pruebas locales no acreditan multijugador ni rendimiento con muchas parejas.

La identidad y resultados de la revisión entregada se consultan en `reports/verification.json`; los laboratorios están en `reports/rapid-fire/` y no se incrustan en la entrega.

## Guardado y verificación

Verificación22oct2026:40 controles de colores y44 del laboratorio de Rapid Fire, sin fallos, con las mismas fuentes productivas del mapa entregado. La base anterior acreditó además regresión90,9 etapas del panel y guardado/reapertura en NewGen; esos núcleos siguen intactos. No se repitió guardado de editor para la revisión de colores. En la copia histórica guardada, NewGen regeneró84 celdas del WPM,40con cambio de walkability, además del minimapa. La entrega conserva el WPM original. Comparar `reports/rapid-fire/20261021-125158/editor/pathing-diff.json` antes de trasladar una copia guardada sobre la entrega. No se ha certificado el nuevo pathing para todo el mapa.
