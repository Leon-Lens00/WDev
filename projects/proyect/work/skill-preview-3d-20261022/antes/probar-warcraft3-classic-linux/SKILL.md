---
name: probar-warcraft3-classic-linux
description: "Probar mapas de Warcraft III Classic 1.27b en esta PC Linux: lanzamiento LAN individual, NewGen/YDWE/Forge, interacción con el juego, capturas, registros frescos y cierre de la partida propia. Usar para pruebas dentro del juego o manejo del editor; complementar build-warcraft3-vjass-127b para código y control-escritorio-linux para entradas gráficas. No acredita Reforged, otras PC ni multijugador sin ensayo específico."
---

# Pruebas Warcraft III Classic en Linux

## Preparación

1. Leer las instrucciones del workspace. En esta PC el entorno está en `/home/snz/Documentos/ChatGPT/FrozenThone`; consultar allí `docs/herramientas-wc3.txt` y `wc3-environment.json` antes de usar Forge/complementos. Las rutas y versiones pueden cambiar: comprobarlas.
   Comprobar los destinos concretos de `wc3 verificar`: un fallo del acceso de Forge no invalida por sí solo NewGen, YDWE, compilación o `play`. Ver el desajuste local de rutas en la guía; conservar los parámetros de otros perfiles válidos.
2. Leer [la guía local](references/guia-local.md). Contiene recetas de lanzamiento, teclas, cierre y evidencia comprobada. No reconstruir el procedimiento a partir de PIDs, coordenadas o logs de otro ensayo.
3. Para modificar mapas/JASS, leer `/home/snz/.codex/skills/build-warcraft3-vjass-127b/SKILL.md`. Para interacción visual, leer `/home/snz/.codex/skills/control-escritorio-linux/SKILL.md` y comprobar capacidades/permisos actuales. Preferir CLI/API de aplicación donde resuelvan el trabajo.
4. Inventariar procesos, prefijos y ventanas antes de lanzar. Usar una copia, un escritor por mapa, y registrar hash, versión, objetivo y criterio de éxito. Conservar editores y partidas preexistentes.

## Modo de partida: preferencia LAN de esta PC

El usuario pidió el22/10/2026 usar partidas LAN para pruebas visuales, especialmente con agentes o instancias independientes: una partida individual puede pausarse al perder foco. Preferir el lanzador LAN del componente cuando esté disponible; si no lo hay, arrancar el juego en su menú con un perfil aislado y crear la partida desde Red de área local. `wc3 play MAPA` usa `-loadfile` para partida individual y no cumple esa preferencia; no inventar un flag `--lan` en ese comando. Consultar el procedimiento y límites en [la guía local](references/guia-local.md#lan-para-pruebas-visuales-sin-pausa-de-foco).

Cada agente conserva su propio PID, prefijo, puerto/partida y evidencias. Una partida LAN con un único host para inspección visual no acredita sincronización entre clientes. Si LAN falla o añade demora, el usuario autoriza volver al arranque individual anterior; informar el modo usado y no presentar ese fallback como prueba LAN. Mantener SP también para reproducciones que lo requieran explícitamente.

## Bucle rápido

- **Usar lanzamiento LAN individual por defecto** en las pruebas independientes que deban seguir avanzando mientras el usuario o los agentes cambian de ventana: **un anfitrión LAN automático y un solo cliente Warcraft por ensayo**, con mapa y sesión propios. Cuando dos agentes prueben a la vez, cada uno debe tener su host, cliente, mapa y registros separados; no unirlos a la misma partida. Leer [LAN individual y agentes](references/lan-individual.md) antes de lanzarlo. Validar continuidad fuera de foco; esta modalidad está respaldada por lectura del código local, todavía sin prueba específica de un cliente en juego. No presentarla como solución ya comprobada.
- Reservar `play` para pruebas individuales atendidas en primer plano o que requieran expresamente modo individual; en esos casos puede usarse `/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 play /ruta/absoluta/COPIA-COMPILADA.w3x`. El lanzador valida JASS y prepara una ruta corta en el perfil gráfico moderno; no implementa LAN ni evita por sí mismo la pausa al perder el foco. No abrir el editor sin necesidad.
- Si cambia vJASS, compilar con JassHelper, validar con pJASS y verificar el script reextraído de la copia antes de jugar. No confundir validación sintáctica con corrección en motor.
- Abrir editor cuando la tarea exija objetos, GUI, guardado o integración del editor. Usar los lanzadores del Taller, una copia y comprobar los registros de compilación/empaquetado al guardar.
- Arrancar en segundo plano o con una sesión de herramienta que permita seguir trabajando: `play` permanece esperando hasta que termina el juego. Identificar el nuevo proceso y su ventana; guardar identidad antes de enviar entradas.
- Comprobar visualmente que cargó el mapa correcto. Usar mensajes Win32 con HWND identificado para teclas/comandos breves cuando el auxiliar exista y funcione; si no, enfocar y usar entrada de escritorio con captura actual. No confundir códigos de teclas Linux y Win32.
- Esperar condiciones observables con límite y sondeo breve; no encadenar pausas largas a ciegas. Informar del avance si el trabajo dura más de un minuto.

## Evaluación y cierre

- Exigir registros nuevos de esta ejecución, todos los archivos esperados, totales y controles. Una marca COMPLETE o un CHECK PASS de preparación no aprueba el producto. Buscar fallos y escenarios ausentes; un timeout es incompleto.
- Conservar logs, parámetros, hashes y capturas relevantes antes de cerrar. Medir rendimiento con trabajo equivalente y resultados funcionales equivalentes; contadores no son FPS.
- En esta PC, usar como cierre preferido la secuencia indicada por el usuario: enfocar la ventana identificada de la partida propia, pulsar `Win+Q`, soltar ambas teclas, esperar `0,25 s` y pulsar `S` para confirmar la salida. Antes de `S`, comprobar que la confirmación pertenece a esa partida y conserva el foco; si la ventana ya cerró, no enviar `S`. Verificar que terminó el proceso. Los detalles y alternativas están en la sección de cierre de la guía local. Si se atasca, SIGTERM solo al proceso creado por esta prueba, tras revalidar PID, inicio, prefijo y comando. No usar cierres globales ni terminar editores del usuario.
- Mover temporales propios a papelera con `gio trash`. Conservar evidencia final, fuentes, originales y archivos del usuario.
- Informar qué se probó, resultado, evidencia y límites. Separar `Compiled`, `Validated`, `Tested in map` y `Tested in multiplayer`; una ejecución con fallos sigue siendo una prueba con fallos. No trasladar LAN de una versión a otra.

## Alcance

Esta skill conserva un método local observado; no concede acceso al escritorio ni exige repetir calibraciones ya documentadas. La guía incluye controles de vigencia. El usuario autoriza como preferencia de ejecución el host LAN individual para evitar pausas en sus pruebas independientes. No confundir ese transporte con una validación multijugador: los ensayos de sincronización con varios clientes siguen siendo una fase aparte, pendiente si el usuario la aplazó.
