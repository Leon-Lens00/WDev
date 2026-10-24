# Ráfaga de seis misiles y pareja controlador–ejecutor

Fecha: 2026-10-21, America/Lima. Estado: implementado y probado localmente en1.27b; entrega y evidencias en reports/verification.json.

Base: TerrainDev, Warcraft III Classic 1.27b, Missile 2.5.1 + MissileRecycler 1.4.5.2 con corrección local y MissileDiagnostics. Identidad de la entrega previa: SHA-256 `37dcc7954b5318d512bb747e1d3dbae63030392895776759ba1a6933142f86c7`, recogida en `reports/verification.json`. Verificar de nuevo al implementar: no sobrescribir ediciones posteriores del mapa.

## Alcance solicitado

El usuario autorizó implementar el movimiento separado tomando Missile como referencia, sin modificar su núcleo, y pidió SetUnitPosition en la primera transición desde movimiento nativo y SetUnitX/Y después. Se conservan los originales. Las verificaciones nuevas se registran en reports/rapid-fire/20261021-125158.

Dos unidades por pareja: un controlador fuera de cámara que recibe órdenes/tiene las habilidades y un ejecutor visible que representa sus resultados. Sólo el controlador tiene Rapid Fire; el ejecutor no lanza una habilidad nativa para disparar.

## Requisitos confirmados y cronología

- Seis misiles durante una ventana nominal de 1.5 s; primer misil inmediato. El intervalo depende de cantidad y duración configuradas.
- Respuesta posterior del usuario: un recast vuelve a dejar seis pendientes, conserva el reloj del siguiente disparo y actualiza el punto de puntería.
- Stop y Hold quedan fuera de las acciones del prototipo. La transición nueva no emite stop: cancela la locomoción nativa mediante SetUnitPosition, sólo al entrar desde move/smart/patrol.
- Interpretación comunicada: `intervalo = duración / cantidad = 0.25 s`. Disparos en `0, .25, .50, .75, 1.00, 1.25`; cierre de la última ranura en `1.50`. Esa cola mantiene la protección entre disparos y deja terminar la última animación. No describir el último disparo como ocurrido en 1.50.
- Al recastear durante ráfaga o cola: `pendientes = 6`, actualizar punto, conservar `próximoDisparo`. No emitir inmediatamente ni crear/reiniciar otro emisor. Una emisión máxima por ranura. Los misiles ya volando mantienen el destino que recibieron al salir.
- Un recast puede prolongar la actividad más allá de los 1.5 s originales. Recasts continuos pueden mantenerla activa: es consecuencia del requisito de reponer seis, no una ráfaga limitada a seis en total.
- Factor de animación del ejecutor: 3.0 durante la actividad; iniciar `attack` una vez por salida. Al cerrar, restaurar el factor base gestionado por el controlador (1.0 en el prototipo), sin pisar modificadores futuros ajenos.
- Facing continuo hacia el punto de puntería vigente, calculado desde la posición actual del ejecutor. Movimiento y orientación de disparo son vectores independientes.
- Movimiento artificial recto a 350 unidades/s durante la actividad; nuevas órdenes cambian el destino. Sin colisión con unidades, con restricciones de terreno/árboles/destructibles/cliffs. No debe saltar de arriba abajo o viceversa.
- Al cerrar, si queda viaje válido, entregar una única orden move nativa hacia el último destino; si ya llegó o no existe destino, no emitirla.

## Diseño aplicado

### Estado por pareja, sin globals de puntería compartidos

Guardar controlador, ejecutor, destino de movimiento y su validez, punto de puntería, fase del emisor, pendientes, siguiente ranura, bloqueo físico, propiedad de animación/pathing y guardia de órdenes internas. Table enlaza unidades con su pareja. Una pareja no puede alterar timers o destinos de otra.

Dos ejes de estado independientes:

| Emisor | Locomoción | Resultado |
|---|---|---|
| Inactivo | Sin intención de viaje | Reposo |
| Inactivo | Viaje pendiente | Move nativo, con su pathfinding |
| Ráfaga/cola | Sin viaje | Disparar quieto y orientar al punto |
| Ráfaga/cola | Viaje válido | Movimiento artificial recto a 350, mirando a la puntería |
| Ráfaga/cola | Tramo bloqueado | Quedarse antes del obstáculo y conservar destino; nuevas órdenes pueden desbloquear otra dirección |

No equiparar fin del emisor con fin de los proyectiles: éstos pueden seguir volando después de devolver la locomoción al motor.

### Controlador y recepción de órdenes

- Mantenerlo fuera de cámara, seleccionable y capaz de recibir la habilidad. No asumir que una unidad oculta/pausada sigue ofreciendo la misma interacción de usuario.
- Su posición no determina origen, orientación, distancia ni daño: éstos se calculan desde el ejecutor.
- Propuesta de selección: al seleccionar el ejecutor, dirigir la selección al controlador y mantener cámara sobre el ejecutor. Comprobar interfaz y selección real en 1.27b antes de adoptarlo definitivamente.
- Interceptar point orders de move/smart sobre suelo y normalizarlas como intención de desplazamiento. Evitar que el controlador abandone su zona; no espejar recursivamente las órdenes generadas internamente.
- Habilidad de punto sin cooldown/coste en el prototipo, con rango suficiente, cast point/follow-through mínimos y evento de efecto comprobado. Probar que alcanza la zona visible desde el proxy, no sólo que existe su objeto.
- La capa admite registrar otras habilidades en el futuro. El proxy por sí solo no evita conflictos entre scripts, animaciones, muerte, stun o movimiento: la autoridad del ejecutor debe permanecer centralizada.
- Fuera de alcance inicial: Stop/Hold del usuario, ataque a objetivo, follow, recogida de ítems y colas Shift. No tratarlos silenciosamente como move.

### Transiciones de locomoción

Al entrar en ráfaga desde un move nativo:

1. Conservar intención/destino y posición actual.
2. Activar estado artificial y guardia de órdenes internas.
3. Primer tick de duración cero: SetUnitPosition en la posición actual, una sola vez y antes del primer attack. La prueba position-probe en 1.27b dejó order=0 y desplazamiento posterior=0; con SetUnitX/Y conservó move y avanzó262.451. Los siguientes pasos usan sólo XY. Recasts no repiten la transición.
4. Aplicar factor de animación/orientación gestionados; primer misil y `attack` inmediato.
5. Desplazar en los pasos siguientes únicamente después de comprobar el tramo.

Durante ráfaga, una orden move sólo actualiza intención; no enviar move al ejecutor. La dirección de avance no cambia su facing de disparo. Al llegar al destino, marcar llegada y mantener la ráfaga quieta; otra orden puede iniciar otro tramo.

Al cerrar la cola: desactivar el desplazamiento artificial, restaurar estado gestionado y entregar como máximo una orden de viaje restante. En muerte/eliminación, limpiar emisor y movimiento sin ordenar a una unidad inexistente. Decidir explícitamente la política de stun/interrupciones antes de ampliar esos casos; la separación proxy/ejecutor no acredita inmunidad a ellos.

### Colisiones: adaptación necesaria, no simple reutilización de Leap

Evidencia del código inspeccionado:

- `Missile.move` modifica XY, altura y facing antes de ejecutar callbacks. Al usar `Missile.createEx(ejecutor,...)` se impone el facing de desplazamiento, contrario al facing de puntería independiente solicitado.
- `onTerrain` sólo se llama con `z < 0`. No representa por sí solo la regla de no cruzar bordes descendentes.
- En `MissileStruct` se evalúan unidades antes que destructibles y terreno. Esos callbacks, sin otra adaptación, no garantizan elegir el obstáculo más cercano en un tramo donde hay un blanco detrás de un árbol/pared.
- La demo `Leap` (`../descargas/warcraft3/misiles/bpower/fuentes/245192/trigger-0029.j`) prueba el destino y desactiva pathing para un salto. No certifica un movimiento terrestre que respete todos los segmentos.

Propuesta:

- Usar Missile para los proyectiles y un controlador XY separado para el ejecutor, con validación **antes** de aplicarle cada avance. No cambiar el movimiento global de Missile para esta habilidad.
- Compartir un servicio de consulta de segmentos/huella, con políticas distintas: los proyectiles incluyen unidades válidas; el ejecutor las ignora.
- Validar todo el segmento y el radio corporal, con subpasos acotados; no sólo el punto final. A 350 y paso 1/32, el desplazamiento bruto es 10.9375 unidades por tick. Subdividir según huella/malla evita cruzar una franja estrecha entre muestras.
- Comprobar límites del mundo, obstáculos vivos y transitabilidad real; distinguir paredes de cliff y rampas transitables. No bloquear todas las rampas sólo porque cambie `GetTerrainCliffLevel`, ni permitir un salto por existir un destino válido al otro lado.
- Un punto de walkability no basta para la huella completa del ejecutor. La demo TerrainPathability/IsTerrainWalkable es candidata para estudiar consultas de suelo sin colisión de unidades; aún no está instalada en TerrainDev ni probada para esta mecánica.
- Si se necesita una consulta dinámica de pathing, comprobar si incluye huellas de edificios: ignorar unidades y bloquear edificios no son automáticamente la misma política. Resolverlo explícitamente en la fase de colisiones.
- Elegir primer impacto real del segmento para que un proyectil no dañe un blanco detrás de un obstáculo. Adaptador propio del consumidor, incluyendo el último segmento en `onFinish`; no alterar el orden común de callbacks de otros consumidores.
- Comprobar también el segmento ejecutor→boca del arma: un offset de salida no debe hacer nacer el proyectil al otro lado de una pared.
- Ante bloqueo artificial, detener antes del contacto y conservar destino; no deslizar ni buscar ruta alternativa durante la ráfaga. Al acabar, el move nativo podrá buscar ruta.

### Configuración inicial propuesta, ajustable

Ejecutor con modelo Rifleman (animación attack por comprobar), sin ataque automático ni huida que compita con el controlador. Proyectil FireBallMissile ya usado en el laboratorio, daño25, velocidad1200, radio16 y alcance máximo1000. Puntería por coordenadas; no homing sobre una unidad. El daño y nacimiento pertenecen al ejecutor, no al proxy.

Propuesta de filtro: enemigos vivos terrestres, excluyendo ejecutor, controlador y dummies; árboles/destructibles bloqueantes vivos terminan el proyectil sin destruirse automáticamente. La política sobre aliados, edificios y vuelo de un proyectil sobre un borde descendente debe quedar explícita al cerrar el contrato de colisiones; la unidad ejecutora sí tiene prohibido saltar desniveles.

### Integración de bibliotecas y diagnóstico

Reutilizar Missile/MissileRecycler, TimerUtils, Table, SpellEffectEvent/RegisterPlayerUnitEvent, WorldBounds e IsDestructableTree. No importar SpellIndex o toda Leap por anticipación. Las bibliotecas adicionales se eligen por pruebas de la necesidad concreta.

Archivos aplicados: `GroundCollision.j`, `GroundMotion.j`, `RapidFire.j` y `RapidFireDemo.j`. Registrar fuentes en Main/manifiesto/WTG/WCT. Adaptar el builder para añadir los nuevos objetos/unidades/habilidad sin perder n000, n001, A000, dumi, dcst, terreno ni triggers originales. Rawcodes a reservar tras verificar inventario, no asumir IDs libres.

Añadir a diagnóstico, mediante extensión separada: ráfagas activas, pendientes por pareja, emisiones, recasts, intervalos mínimos observados, movimiento artificial activo/bloqueado, handed-off moves y emisores/timers vivos. Los proyectiles siguen usando los contadores actuales. No contar el ejecutor como dummy del pool.

## Fases de ejecución (completadas dentro del alcance)

1. Contrato confirmado: primer disparo inmediato, intervalo0.25, recast repone seis sin cambiar reloj, sin Stop/Hold. Movimiento separado y transición SetUnitPosition inicial autorizados después.
2. Construir pareja y probar selección/cámara, habilidad en proxy y transmisión de move con guardias de recursión. Sin proyectiles ni movimiento artificial todavía.
3. Implementar emisor y proyectil en reposo: seis emisiones, animación3x y orientación; recasts repetidos sin doble timer ni disparos consecutivos adelantados.
4. Desarrollar/probar consultas de colisión y controlador XY a 350; integrar transiciones con move nativo y separación de facing. No dar por válido un destino sin recorrer el tramo.
5. Integrar objetos, fuentes editables y métricas. Compilar JassHelper+pJASS, empaquetar/reextraer y comprobar conservación de miembros y roundtrip NewGen.
6. Ensayar escenarios reales y registrar identidad/contadores/capturas. No inferir multijugador a partir del prototipo local.

## Matriz de diseño y cobertura

- Sin recast: seis salidas en ranuras0,.25,...1.25; cierre1.50, speed de animación3.0 y una llamada attack por salida.
- Recast justo antes/después de una ranura, incluidos recasts en la cola final; objetivo y seis pendientes actualizados, ninguna distancia temporal inferior al intervalo por el recast, un solo emisor por pareja.
- Cambios de puntería mientras se avanza hacia otro punto: trayectoria del ejecutor cambia sólo por órdenes move; facing sigue puntería. Misiles anteriores conservan su destino de salida.
- Orden move desde reposo y cambio de destino durante ráfaga; llegada antes de acabar; bloqueo y ruta nativa al terminar. Sin doble movimiento al activar desde move nativo.
- Árbol, destructible, esquina estrecha, pared entre muestras, cliff ascendente/descendente, rampa y borde del mapa. Huella completa sin atravesar; actor pasa por unidades según contrato.
- Proyectil: unidad antes de obstáculo vs unidad detrás del obstáculo, origen contra pared, último tramo, árbol muerto y blanco inválido; daño una vez y retiro correcto.
- Restauración de animación/pathing gestionados y cleanup en final normal, muerte/eliminación e interrupciones que se incluyan. Misiles ya emitidos no se confunden con el timer del emisor.
- Dos parejas simultáneas y recasts prolongados; sin contaminación de destinos, timers ni animación entre parejas; contadores vuelven al reposo después de terminar vuelos/descartes.

## Resultado de la implementación

- Bibliotecas nuevas separadas; Missile, MissileRecycler y MissileDiagnostics conservan sus hashes de la base.
- Objetos rfct/rfex/rftg/Arpf integrados y editables; controlador con velocidad 350 para mostrar Mover. Se interceptan point orders y se aparca el proxy. Melee Initialization desactivado por petición posterior del usuario; sus acciones se conservan recuperables.
- 44 comprobaciones en motor, cero fallos;47 emisiones observadas a 0.250 s, ventana inicial1.5s y54 emisiones totales del emisor. Se contrastan instancias reales, daño, posición, facing y órdenes. Recasts antes/después de ranura, cambio de aim sin retarget de vuelos emitidos, movimiento350, cancelación inicial instantánea una vez, retarget, llegada, handoff nativo, unidades ignoradas por locomoción, árbol/árbol muerto, pared estrecha, límite, cliff4↔3 y rampa real, último tramo, parejas simultáneas y muerte.
- Regresión:90 creados/90 retirados,70 llegadas/10 colisiones/10 cancelaciones, cero fallos; nueve etapas del panel pasan. Evaluadores rechazan controles negativos. Los controles negativos sólo existen en laboratorios.
- NewGen: copia abierta, guardada y reabierta;15 fuentes, objetos, formatoClassic25 y pJASS comprobados. Terreno W3E, colocaciones DOO y modelos conservados. El editor regenera minimapa y84 celdas WPM (40 de walkability); esa copia no sustituye la entrega, que conserva el WPM original. Ver editor/pathing-diff.json.
- Cobertura acotada: las muestras de huella no certifican todos los modelos/esquinas/puentes; Stop/Hold, órdenes a objetivo, Shift, stun/silencio, otras autoridades de animación/pathing, muchas parejas y multijugador quedan fuera del prototipo.

Evidencia vigente: reports/verification.json, reports/rapid-fire/20261021-133527/result.json y reports/game-test/20261021-133841/. Intentos fallidos y correcciones del fixture: reports/rapid-fire/20261021-125158/test-notes.md. No atribuir sus fallos iniciales al núcleo común sin la investigación registrada.

