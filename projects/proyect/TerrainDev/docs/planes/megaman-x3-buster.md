# Física X3: cargado y supercargado

Objetivo: TerrainDev Classic1.27b, vJASS, CachyOS/Wine. Base47522cd81caa904206d4917de202f15e1b0865939c240b511875bb6585a2ce59. Mantener Rapid Fire/movimiento y núcleos compartidos. Usuario pide preparar la interacción con los modelos disponibles; GIFhttps://tenor.com/iA3z0BfiPC1.gif determina el orden. No es una reproducción medida del código SNES.

## Observado y decisiones

La copia local del GIF, SHA2568ad5303ac32ba4d5718a1fa097f8062b603d61945cde19a16f72d8d880871714, contiene140 fotogramas/3040ms. Orbes delante y pulso detrás; encuentro produce flash y cuerpo fusionado con satélites. Lámina local revisada en work/x3-reference-frames.png. La fuente A/B/C se consultó como referencia, no como instrucciones.

Se implementan dos orbes verde/naranja individuales, giro opuesto alrededor del eje de avance (XY+altura). El pulso alcanza su centro desde atrás. Sólo pueden fusionarse los tres cuerpos vivos de la misma secuencia; un impacto previo impide la fusión. Cuatro satélites posteriores forman abanico, con trayectoria y daño propios. Los modelos MDX800 y4BLP se copian desde ModelEditor/exports/megaman-x3-buster-v1 sin alterar fuentes. El grupo visual de3orbes no se importa.

La primera demo usa W:cargado directo, E:supercargado automático. La API separa iniciar los orbes y liberar el pulso para cambiar el control posteriormente. No se implementa mantener/soltar teclas ni carga acumulada todavía. Tiempos, velocidades y daños son decisiones iniciales configurables de Warcraft, no valores SNES certificados. Colisión barrida GroundCollision: terreno/árboles/destructibles/cliffs y enemigos terrestres; un impacto por cuerpo. No perforación. Dirección fijada al lanzamiento, sin homing ni cambios del movimiento del actor.

## Implementación y verificación

1. X3Buster.j: secuencias MUI, cuerpos Missile independientes, órbita por offsets propios, colisiones sobre offsets reales, encuentro barrido, fusión única y retirada segura por callbacks. TimerUtils para flash y reloj32Hz para salida del pulso/limpieza; máximo8cuerpos y1flash por secuencia, vida acotada y límite simultáneo.
2. X3BusterDemo.j y objetos Classic: W/E desde el controlador existente, ejecutor visible sin órdenes de movimiento. Rapid Fire Q se conserva. Main.j/libraries.json en el mismo orden que WCT. Builder añade sólo manifiesto X3 y objetos nuevos.
3. JassHelper/pJASS, reextracción exacta de imports/fuentes y miembros ajenos. CodeGraph antes/después en src/scripts, APIs release incompletas; compilar y ejecutar por separado.
4. Laboratorio dentro de1.27b: cargado recto, separación/orbita, pulso posterior, fusión única y coordenadas,4satélites, bloqueo antes de unión, enemigo, rutas simultáneas, cancelación/vida/retirada. Repetir regresión44Rapid Fire y40colores ante integración de objetos/builder. Capturas de interacción, logs nuevos, originales intactos, cerrar sólo partida propia. Pruebas atendidas en primer plano; LAN sin pausa pendiente de validación del lanzador, no se requiere cambiar infraestructura para este ensayo.

Estado: preparación. No hay PASS anticipados. Los resultados y próximos pasos se actualizarán aquí y reports/verification.json.

## Avance y recuperaciones

- Implementadas las17bibliotecas editables (15previas sin cambios, X3Buster y X3BusterDemo),5MDX/4BLP, objetosAx3c/Ax3s y manifiesto propio.
- Motor1.27b confirma orden de orbes/pulso/unión/satélites; escenarios de MUI, cancelación, enemigos, destructibles y límite64.
- El fixture confundía facing solicitado con facing actual: medición0→34.95→90 demuestra giro progresivo. Se corrigió el tiempo de observación sin modificar la física. Informe resuelto2026-10-22-202637-x3-laboratorio-facing.md.
- La revisión añadió enemigo posterior al encuentro dentro de un mismo paso. La versión inicial falla con primer daño75 y fusión omitida. La corrección divide los sweeps en la fracción de encuentro: nuevo caso observa150 y fusión real;54controles X3 pasan,190creados/retirados,0activos. Informe2026-10-22-204120-x3-prioridad-fusion-impacto.md.
- Pruebas atendidas en perfil aislado TerrainDev/build/x3-runtime/pfx, pantallaDP-1, sin cerrar partidas de otros perfiles. El flujo individual vigente reemplaza la recomendación provisional de LAN individual para esta tarea. No se ensayó multijugador.
- Resultado final y hashes: reports/verification.json y reports/x3-buster-20261022-201342/result.json (regresión/limpieza se registran al cerrar).

## Resultado de la revisión final

Producción4d4c0b227db9ed30edb4dbdcf233dca616a7fd0d62e4f7283312a60351e2a93a. JassHelper/pJASS,9imports X3 y26recursos previos,17bibliotecas WCT/WTG y objetos verificados. Motor:54X3+40colores+44RapidFire=138checks/0fallos;14controles negativos rechazados. Nuevo caso de prioridad: primer impacto150; versión anterior75. X3final190creados/190retirados,0proyectiles/secuencias/flashes. Perfil propio sin juegos pendientes; launcherretorno0, cierre documentado. La captura opcional final fue detenida por identidad/geometría de ventana; la muestra anterior queda identificada como histórica. No falta trabajo de física de esta fase; control de carga por tecla, emisión desde caster desplazado y multijugador quedan fuera de esta primera versión.

## Continuación del23-10-2026

El usuario solicitó una réplica más próxima al GIF antes de aportar ROMs.
La entrega vigente pasa a ad594a94…; el resultado anterior acredita la primera
versión. Ver [réplica GIF](x3-replica-gif.md), con retroceso/aceleración,153controles
correctos, vídeo final y límites. El código comunitario se estudiará como
variante separada cuando esté disponible; no se han extraído parámetros ROM.
