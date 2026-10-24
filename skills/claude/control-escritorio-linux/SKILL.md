---
name: control-escritorio-linux
description: Controlar visualmente el escritorio local Linux con Hyprland mediante capturas, clics y teclado. Usar para computer use, interactuar con aplicaciones y probar interfaces o juegos en esta PC cuando la sesión permita acceso local.
---

# Control del escritorio Linux

## Capacidades verificadas

En esta PC (CachyOS, Hyprland/Wayland) ya se tomaron capturas y se abrió un vídeo mediante un clic real. La comprobación del 13 de octubre de 2026 encontró `/usr/bin/grim`, `/usr/bin/hyprctl`, `/usr/bin/ydotool` y `/usr/bin/wtype`; el servicio de usuario `ydotool` estaba activo y `/dev/uinput` era escribible.

Este procedimiento usa herramientas locales mediante shell. No presupone que el plugin oficial de Computer Use esté habilitado. Comprueba las capacidades locales antes de afirmar que el control gráfico es imposible. Prefiere un conector, API, CLI o control de navegador específico cuando resuelva mejor la tarea.

## Comprobar la sesión

Confirma que hay shell local y acceso al escritorio con lecturas:

```bash
command -v grim hyprctl ydotool wtype
systemctl --user is-active ydotool
test -w /dev/uinput
hyprctl -j version
hyprctl -j monitors
hyprctl -j clients
```

La presencia de herramientas no amplía permisos ni autoriza eludir restricciones de la sesión, sandbox o administrador. Un chat en la nube sin acceso local no puede usar este escritorio por haber leído la skill. Si falta acceso, explica el bloqueo real.

## Ver y actuar

Consulta monitores y ventanas actuales e identifica la ventana solicitada. No reutilices coordenadas de otro chat: esta PC tuvo dos monitores y después tres, con posiciones diferentes.

Guarda una captura en `work/` del workspace actual y mírala con la herramienta de imágenes locales antes de elegir dónde hacer clic:

```bash
mkdir -p work
grim work/escritorio.png
```

Para capturar un monitor, usa su nombre verificado, por ejemplo `grim -o eDP-1 work/escritorio.png`. Sus coordenadas son locales al monitor: conviértelas a coordenadas del compositor usando posición, escala y transformación actuales. Ten en cuenta cualquier reducción del tamaño de la imagen mostrada.

En Hyprland 0.56.2 funcionó la sintaxis Lua siguiente para posicionar el cursor. Las coordenadas son un ejemplo: sustitúyelas por las obtenidas de la captura actual, verifica la posición y después haz clic:

```bash
hyprctl dispatch 'hl.dsp.cursor.move({x = 500, y = 400})'
hyprctl -j cursorpos
ydotool click -D 100 0xC0
```

El antiguo dispatcher `hyprctl dispatch movecursor` falló en esta versión. `ydotool mousemove --absolute` también produjo una posición incorrecta con varios monitores; usa la posición del compositor. Si cambia la versión, verifica la sintaxis compatible.

Para escribir, `wtype` y `ydotool` están disponibles. Comprueba el foco y pasa texto como argumentos correctamente escapados o mediante subprocess; no interpolar texto del usuario como código de shell. Las entradas afectan al escritorio real y a la ventana enfocada, no a una sesión gráfica aislada.

Realiza una acción o un grupo pequeño de acciones coherentes y verifica el resultado con una captura nueva o el estado de la aplicación.

## Pruebas de juegos

En Warcraft III Classic 1.27b se verificaron después capturas, teclado, comandos del mapa y cierre de partidas de prueba con los perfiles locales modernos. Para ese procedimiento, leer `skills/claude/probar-warcraft3-classic-linux/SKILL.md`. Comprobar de nuevo foco, ventana e interpretación de entradas en la sesión actual. Esto no acredita otros juegos, todas las entradas, control continuo de vídeo ni una latencia garantizada.

## Persistencia

Invoca esta skill como `/control-escritorio-linux` o deja que Claude la cargue por su descripción. Si no aparece en una sesión nueva, reinicia la sesión y comprueba que `.claude/skills` apunta a `skills/`. Estas instrucciones conservan el procedimiento, no crean acceso local donde no lo hay.
