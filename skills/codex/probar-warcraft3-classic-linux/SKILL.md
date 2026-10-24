---
name: probar-warcraft3-classic-linux
description: "Probar mapas de Warcraft III Classic 1.27b en esta PC Linux: lanzamiento local, NewGen/YDWE/Forge, interacción con el juego, capturas, registros frescos y cierre de la partida propia. Usar para pruebas dentro del juego o manejo del editor; complementar build-warcraft3-vjass-127b para código y control-escritorio-linux para entradas gráficas. No acredita Reforged, otras PC ni multijugador sin ensayo específico."
---

# Pruebas Warcraft III Classic en Linux

## Preparación

1. Leer las instrucciones del workspace. En esta PC el entorno está en `/home/snz/Documentos/ChatGPT/FrozenThone`; consultar allí `docs/herramientas-wc3.txt` y `wc3-environment.json` antes de usar Forge/complementos. Las rutas y versiones pueden cambiar: comprobarlas.
   Comprobar los destinos concretos de `wc3 verificar`: un fallo del acceso de Forge no invalida por sí solo NewGen, YDWE, compilación o `play`. Ver el desajuste local de rutas en la guía; conservar los parámetros de otros perfiles válidos.
2. Leer [la guía local](references/guia-local.md). Contiene recetas de lanzamiento, teclas, cierre y evidencia comprobada. No reconstruir el procedimiento a partir de PIDs, coordenadas o logs de otro ensayo.
3. Para modificar mapas/JASS, leer `/home/snz/.codex/skills/build-warcraft3-vjass-127b/SKILL.md`. Para interacción visual, leer `/home/snz/.codex/skills/control-escritorio-linux/SKILL.md` y comprobar capacidades/permisos actuales. Preferir CLI/API de aplicación donde resuelvan el trabajo.
4. Inventariar procesos, prefijos y ventanas antes de lanzar. Usar una copia, un escritor por mapa, y registrar hash, versión, objetivo y criterio de éxito. Conservar editores y partidas preexistentes.

## Lanzamiento y revisión previa

Corrección posterior del usuario22/10/2026 para el trabajo de modelos: volver al lanzamiento anterior `play`/`-loadfile`, con perfil propio si hay otras partidas abiertas. No imponer LAN como requisito de estas revisiones. Conservar el flujo LAN para encargos que lo elijan o requieran, según [la referencia](references/lan-individual.md).

Para modelos, mostrar primero el MDX y sus animaciones en un **visor 3D con cámara orbital, rejilla/ejes y origen**, y revisar forma, materiales, emisión y desaparición antes de abrir Warcraft. Distinguir la muestra del visor de la prueba en motor. La revisión3D previa no añade una petición automática de permiso; respetar cuándo el usuario quiere revisar la muestra antes de continuar.

## Bucle rápido

- Usar el lanzamiento anterior `/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 play /ruta/absoluta/COPIA-COMPILADA.w3x` para las pruebas individuales del flujo de modelos. Valida JASS y prepara una ruta corta en el perfil gráfico moderno. Si está ocupado, usar una copia aislada comprobada del perfil; conservar otras sesiones. `play` no implementa LAN y puede pausar fuera de foco: comprobar activación real durante la observación.
- Si el encargo elige LAN o requiere varios clientes de la misma partida, seguir [LAN individual y agentes](references/lan-individual.md) o el flujo multijugador correspondiente. Cada ensayo independiente conserva host/cliente/mapa/registros propios; no mezclar partidas ni atribuir aislamiento al comando compartido sin comprobarlo.
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

Esta skill conserva un método local observado; no concede acceso al escritorio ni exige repetir calibraciones ya documentadas. La guía incluye controles de vigencia. La corrección del usuario recupera el arranque individual anterior para este flujo de modelos, precedido por la muestra en un visor3D. LAN queda disponible cuando se elija expresamente. No confundir ese transporte con una validación multijugador: los ensayos de sincronización con varios clientes siguen siendo una fase aparte, pendiente si el usuario la aplazó.
