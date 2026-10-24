# Multiboard de diagnóstico de misiles

Objetivo autorizado: observar dentro de la partida las variaciones del sistema y detectar acumulaciones futuras. Objetivo técnico: Classic 1.27b, Missile 2.5.1 y MissileRecycler 1.4.5.2 con el arreglo local de vida temporizada. La identidad previa y sus fuentes se conservan en `reports/latest-multiboard.json` y su directorio.

## Decisiones y contratos

- Añadir `MissileDiagnostics`, independiente del núcleo, antes de MissileRecycler/Missile. Ambos incluyen hooks opcionales. Sin tocar trayectoria, velocidad, colisiones, duración ni política de reciclaje.
- Registrar creación/retirada real de instancias y precreación/préstamo/devolución/descarte de dummies. El seguimiento usa los handles recibidos, no enumeración de unidades con Locust.
- Separar reserva, préstamo, espera de efectos y descarte. La reserva normal no es una fuga. Un vigilante cada segundo comprueba vida y plazos, contabiliza descartes reales, libera sus propias referencias y detecta pérdidas inesperadas. Ventana adicional de tolerancia evita confundir orden de timers con un atasco.
- El panel se actualiza al cambiar métricas; agrupa cambios de una misma ejecución en un refresco diferido. La edad y las expiraciones se revisan cada segundo. No recorrer todos los misiles ni dibujar la tabla en cada paso físico.
- Contadores/picos históricos, instancias actuales y edad, dummies vivos, estado de la reserva y descartes, plazos vencidos, operaciones inválidas, cobertura omitida y consistencia. Una edad elevada sólo pide revisión: no prueba fuga. Alarmas históricas permanecen visibles después de desaparecer el síntoma.
- Límite de seguimiento de unidades: 8190 registros, independiente del límite del núcleo. Si se supera, mostrar cobertura omitida y alerta; nunca bloquear el sistema. No afirmar cobertura de todos los handles, memoria, FPS o bibliotecas ajenas.
- Una multiboard global de diagnóstico, visible al empezar; comando `-misiles` oculta/muestra sólo para el jugador que lo escribe. Crear y modificar handles/estado sincronizado fuera de GetLocalPlayer; sólo la visibilidad se aplica localmente. No había otra multiboard en la base. Las futuras tablas deben coordinar su visibilidad.

## Fases y aceptación

1. Inspección y respaldo: completada. Mapa actual coincide con el SHA de la entrega anterior; fuentes y mapa respaldados.
2. Instrumentación/panel: completada. Once fuentes editables; hooks opcionales y tabla de 19 filas. Contrato y límites en README. No se añaden emisores ni controles negativos a la entrega.
3. Construcción: completada. JassHelper+pJASS, miembros reextraídos y WCT/WTG preservados. Ninguna modificación en los originales. Se comprobó por código el último ID válido del núcleo (8191), separado del límite de 8190 registros de unidades del observador; el límite de carga no se ha ensayado.
4. Ensayos de juego y editor: completados en la revisión actual, `reports/game-test/20261021-024016/`. Las 90 retiradas existentes pasan sin regresión. Panel normal: pico60, creadas/retiradas90, 96 unidades de reserva, 66 descartes, 24 préstamos de reserva y cero alarmas. Se distinguen espera de efectos y descarte. Un dummy pausado artificialmente produjo exactamente un plazo vencido/alarma; tras recuperarlo, reserva96, vencidos0 y alarma histórica1. Retorno inválido y ocultar/mostrar comprobados. Nueve etapas verificadas, cero fallos del fixture; logs nuevos y capturas. Copia abierta, guardada y reabierta en NewGen; once fuentes WCT preservadas, JASS recompilado con multiboard y pJASS válido, dos triggers GUI y terreno/imports conservados. También compila sin la biblioteca opcional del panel. Evidencia enlazada en `reports/verification.json`. Se cerraron sólo las sesiones creadas para estos ensayos.

Entrega completada. No se probó multijugador, carga máxima ni el límite de seguimiento; esos resultados no se infieren de esta suite. Cualquier cambio futuro de estos núcleos debe revalidar los hooks. Identidad final y fuentes en `reports/verification.json`.
