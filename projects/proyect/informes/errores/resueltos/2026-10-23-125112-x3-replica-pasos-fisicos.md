# X3: fallo del conteo de pasos de la réplica GIF

Fecha: 2026-10-23T12:51:12.657674-05:00. Agente raíz. TerrainDev Classic1.27b/CachyOS; producción candidataa82aa430dc9e26da20d6c2643d94d6941856f4cd80188342355db95fc96bbc91; laboratorio6fc9c2f5b2cdb360cab59148f4922f2b400d19d0332c9cbbb7abd0e015adda87.

Síntoma reproducido:69comprobaciones completadas,12fallos. Fallan desplazamiento orbital, velocidades/fin de vida y prioridad de unión.198cuerpos creados/retirados,7fusiones; el retroceso y su daño sí pasan. Evidencia completa: TerrainDev/reports/x3-gif-replica-20261023-124052/20261023-124607/x3-engine.txt.

Impacto: no aprobar esta candidata ni trasladar el PASS anterior. La edad local del cuerpo y sus coordenadas pueden divergir del paso real de Missile; afecta a continuidad y colisiones.

Hipótesis principal: prepare usa igualdad del reloj de larga duración como identificador de tick; si dos pasos comparten lectura, se omite un paso local y se deja la posición central que Missile escribió. Falta confirmar la repetición en un registro del motor. La compilación y pJASS pasan; no es un fallo sintáctico.

Acciones: conservar fuentes y log de la candidata; añadir contador de lecturas repetidas del reloj, separar preparación/consumo por callback físico en lugar de inferir ticks desde tiempo leído. Repetir casos y regresiones, comprobar recuperación y dejar evidencia de antes/después.

Estado: en investigación. No hay recuperación acreditada todavía.

## Control de secuencia del builder

Un intento de prepare_x3_probe se inició mientras la compilación corregida seguía en ejecución; la guarda de hashes rechazó las fuentes que todavía no coincidían con latest-build. No se lanzó esa copia ni se atribuyó un PASS. La recuperación exige esperar el fin confirmado del build antes de repetir la preparación. Se conserva este incidente auxiliar aquí para no ocultar la salida AssertionError.

## Segunda ejecución: confirmación del reloj y seis pendientes

Lab4b2a9f57edfb570c..., producción436cb72e...;69checks,6fallos,198/198retirados,7fusiones. El contador independiente registra548callbacks físicos y273lecturas de reloj repetidas: confirma que la lectura no identifica ticks consecutivos. La preparación por callback recupera órbita, velocidades finales y prioridad (daño150), pero tres muestras de retroceso se tomaron demasiado tarde por los tiempos cuantizados del fixture. Cambiar el inicio del muestreo para observar la transición real de state==2. Quedan tres fallos de finalización antes del límite: revisar el recorte de speed contra un alcance calculado separadamente de origin.distance; no ampliar la espera para ocultarlos. Los archivos de progreso no se escribieron hasta inicializar las nuevas variables de diagnóstico: inicializarlas explícitamente antes de Save. La copia se cerró por Win+Q/S, preservando el juego ajeno PID1038158. Logs y capturas en20261023-125249/.

Cierre tercera copia: Win+Q mostró confirmación propia. S no cerró dentro de7s y el foco pasó a otro PID1044138; no se reenviaron teclas a esa ventana. Se revalidaron PID1041985/inicio/prefijo/hash344c68ab y se aplicó SIGTERM exclusivamente a esa partida. Proceso ausente comprobado; se conservaron los juegos de ModelEditor. El diagnóstico auxiliar quedó atendido con el fallback autorizado; no se atribuye cierre normal a esa copia.

## Recuperación comprobada

Última producciónad594a94d93592d0bdb0a90d38cad420deed8b92ac67179891519b3c16bdc7f1; laboratorio9b8d056a6717d3ed... en20261023-130447/.69X3+40colores+44RapidFire=153comprobaciones,0fallos; evaluador rechaza15controles negativos.198cuerpos X3 creados/retirados,7fusiones,0activos/casts/flashes. Reloj independiente546callbacks/272lecturas repetidas. Retroceso verde44.555u, velocidad finalverde1140/naranja1080, prioridad de unión150, retroceso25conun evento de daño. Progreso ahora escribe archivos desde el inicio tras inicializar diagnósticos.

La segunda corrección deja a Missile detectar la llegada con su origin.distance y limita sólo posición barrida/renderizada; recupera el fin normal sin esperar4s. El único fallo de la tercera copia era el fixture naranja: muestreaba antes de0.64875s; se aumentó sólo esa espera a0.375s. La producciónad594a94no cambió entre tercera y cuarta copia. Fuente/laboratorio revisados;16bibliotecas compartidas idénticas.

Estado: resuelto en motor local1.27b. No acredita fidelidad a constantes de ROM ni sincronización multijugador. Se conservan todas las evidencias negativas y cierres individuales.

Cierre final y vídeo: grabación propia12.03s, foco/geometría vigilados, captura válida. Win+Q mostró confirmación propia; el clic en Salir no cerró dentro de5s. Se aplicó el fallback SIGTERM sólo al PID1048507 tras comprobar inicio/prefijo/mapa9b8d056a. No quedó ningún juego en el perfil propio. No presentar ese cierre como normal; retorno del lanzador241 coherente con la terminación. No había juegos restantes al inventario final.
