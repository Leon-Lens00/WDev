---
name: probar-warcraft3-classic-linux
description: "Probar mapas de Warcraft III Classic 1.27b en esta PC Linux: lanzamiento rápido, NewGen/YDWE/Forge, interacción con el juego, capturas, registros frescos y cierre de la partida propia. Usar para pruebas dentro del juego o manejo del editor; complementar build-warcraft3-vjass-127b para código y control-escritorio-linux para entradas gráficas. No acredita Reforged, otras PC ni multijugador sin ensayo específico."
---

# Pruebas Warcraft III Classic en Linux

## Preparación

1. Leer las instrucciones del workspace. En esta PC el entorno está en `/home/snz/Documentos/ChatGPT/FrozenThone`; consultar allí `docs/herramientas-wc3.txt` y `wc3-environment.json` antes de usar Forge/complementos. Las rutas y versiones pueden cambiar: comprobarlas.
2. Leer [la guía local](references/guia-local.md). Contiene recetas de lanzamiento, teclas, cierre y evidencia comprobada. No reconstruir el procedimiento a partir de PIDs, coordenadas o logs de otro ensayo.
3. Para modificar mapas/JASS, leer `/home/snz/.codex/skills/build-warcraft3-vjass-127b/SKILL.md`. Para interacción visual, leer `/home/snz/.codex/skills/control-escritorio-linux/SKILL.md` y comprobar capacidades/permisos actuales. Preferir CLI/API de aplicación donde resuelvan el trabajo.
4. Inventariar procesos, prefijos y ventanas antes de lanzar. Usar una copia, un escritor por mapa, y registrar hash, versión, objetivo y criterio de éxito. Conservar editores y partidas preexistentes.

## Bucle rápido

- Para probar lógica con un mapa ya compilado, usar `/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 play /ruta/absoluta/COPIA-COMPILADA.w3x`. No abrir el editor sin necesidad. El lanzador valida JASS y prepara una ruta corta en el perfil gráfico moderno.
- Si cambia vJASS, compilar con JassHelper, validar con pJASS y verificar el script reextraído de la copia antes de jugar. No confundir validación sintáctica con corrección en motor.
- Abrir editor cuando la tarea exija objetos, GUI, guardado o integración del editor. Usar los lanzadores del Taller, una copia y comprobar los registros de compilación/empaquetado al guardar.
- Arrancar en segundo plano o con una sesión de herramienta que permita seguir trabajando: `play` permanece esperando hasta que termina el juego. Identificar el nuevo proceso y su ventana; guardar identidad antes de enviar entradas.
- Comprobar visualmente que cargó el mapa correcto. Usar mensajes Win32 con HWND identificado para teclas/comandos breves cuando el auxiliar exista y funcione; si no, enfocar y usar entrada de escritorio con captura actual. No confundir códigos de teclas Linux y Win32.
- Esperar condiciones observables con límite y sondeo breve; no encadenar pausas largas a ciegas. Informar del avance si el trabajo dura más de un minuto.

## Evaluación y cierre

- Exigir registros nuevos de esta ejecución, todos los archivos esperados, totales y controles. Una marca COMPLETE o un CHECK PASS de preparación no aprueba el producto. Buscar fallos y escenarios ausentes; un timeout es incompleto.
- Conservar logs, parámetros, hashes y capturas relevantes antes de cerrar. Medir rendimiento con trabajo equivalente y resultados funcionales equivalentes; contadores no son FPS.
- Cerrar mediante menú o WM_CLOSE de la ventana identificada; verificar si apareció confirmación y si terminó el proceso. Si se atasca, SIGTERM solo al proceso creado por esta prueba, tras revalidar PID, inicio, prefijo y comando. No usar cierres globales ni terminar editores del usuario.
- Mover temporales propios a papelera con `gio trash`. Conservar evidencia final, fuentes, originales y archivos del usuario.
- Informar qué se probó, resultado, evidencia y límites. Separar `Compiled`, `Validated`, `Tested in map` y `Tested in multiplayer`; una ejecución con fallos sigue siendo una prueba con fallos. No trasladar LAN de una versión a otra.

## Alcance

Esta skill conserva un método local observado; no concede acceso al escritorio ni exige repetir calibraciones ya documentadas. La guía incluye controles de vigencia. LAN es una fase aparte y se ejecuta cuando esté dentro de lo solicitado. No iniciar pruebas multijugador aplazadas por el usuario.
