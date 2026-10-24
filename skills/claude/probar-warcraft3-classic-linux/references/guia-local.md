# Guía local: probar mapas, manejar editores y cerrar Warcraft III

Preparada el 19-10-2026 a partir de pruebas de FrozenThone y del chat **EditoresNewGen**. Describe Warcraft III Classic 1.27b en esta PC CachyOS/Hyprland. Los resultados históricos son evidencia del procedimiento, no una nueva aprobación del mapa que se pruebe.

## 1. Qué usar y por qué

- **Skill de pruebas:** este procedimiento repetible de ejecución y observación.
- **Skill de JASS:** construcción, compatibilidad, dependencias y análisis del código.
- **Skill de escritorio:** detección de monitores, capturas, foco, ratón y teclado.
- **AGENTS.md/configuración:** rutas y restricciones propias del proyecto.
- **Lanzadores existentes:** operaciones mecánicas. Reutilizarlos evita reconstruir a mano el entorno Proton.

Entorno: `/home/snz/Documentos/ChatGPT/FrozenThone`.
Entrada común: `/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3`.
Consultar `docs/herramientas-wc3.txt` y `wc3-environment.json` en ese entorno.

### Comprobación de rutas del 20-10-2026

La entrada del Taller existe y resuelve a `FrozenThone/scripts/wc3-taller.py`. `wc3 verificar` encontró ausentes únicamente los destinos de fuente/GUI de Forge y su enlace del Taller: la configuración aún señala `/home/snz/Documentos/WarDatsPy/wc3-forge`, mientras la copia actual está en `/home/snz/Documentos/MCP W3/wc3-forge`.

Los destinos comprobados de `play`, NewGen, YDWE, GE-Proton, DXVK, JassHelper, pJASS y APIs Classic siguen presentes. Conservar sus perfiles y parámetros; esta revisión fue de rutas y lanzadores, sin repetir partidas. Resolver Forge por separado antes de usar `wc3 forge`, `mcp` o `probe`; no reparar enlaces ni modificar configuración global automáticamente. El comando `python3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py play COPIA.w3x` es la entrada directa del mismo flujo de juego.

El lanzador activo usa wc3ctl Classic local 0.3.0. La descarga y el prototipo 0.4.10 de la carpeta nueva todavía no sustituyen ese ejecutable. No confundir la prueba de Studio nativo con una prueba de mapas dentro del juego.

El perfil para `play` es `runtime/proton-newgen-modern-test/pfx`, con GE-Proton 11, DXVK 3.1.1 y RenderEdge. YDWE tiene otro perfil: `runtime/proton-ydwe-modern/pfx`. No intercambiar prefijos, lanzadores ni handles. El Wine 8 histórico mostró terreno negro; no usarlo como referencia gráfica. Confirmar las versiones activas si cambió la instalación.

## 2. Antes de cada ejecución

Definir el escenario y qué demostraría un fallo. Ejemplo: «crear 100 proyectiles por lotes; deben terminar los 100 y quedar cero activos», además de revisar la imagen si corresponde. Elegir la suite pertinente antes de lanzar.

Crear un directorio propio `work/<prueba>-<fecha>-<ejecucion>/` para manifiesto, logs y capturas. Guardar SHA-256 de la fuente y mapa, versión de bibliotecas, comando, hora de inicio y archivos de salida esperados. Si el mapa escribe nombres fijos, archivar/mover a papelera los logs anteriores antes de arrancar; no tocar logs de una partida ajena. Comparar contenido, fecha de modificación y comienzo de ejecución. Si la resolución del reloj no permite distinguirlos, usar un identificador de ejecución o comprobar su ausencia previa y creación nueva.

Antes de interactuar, comprobar acceso local y estado actual:

```bash
command -v grim hyprctl ydotool wtype
systemctl --user is-active ydotool
test -w /dev/uinput
hyprctl -j version
hyprctl -j clients
hyprctl -j monitors
```

Guardar el inventario inicial de procesos y ventanas. Para el juego nuevo, registrar PID Linux, campo de inicio de `/proc/PID/stat`, comando y WINEPREFIX exacto de `/proc/PID/environ`; leer solo los campos necesarios, sin volcar otras variables privadas. Comparar antes/después. Asociar la ventana con el PID. Un título «Warcraft III» por sí solo no identifica al propietario. Si la asociación es ambigua, resolverla antes de enviar entradas o cerrar.

## 3. Ruta rápida: mapa compilado → juego

Para ModelEditor, la corrección posterior del usuario22/10/2026 recupera el arranque anterior `play`/perfil aislado. Mostrar y revisar primero los modelos en un visor3D; abrir el juego después como verificación de motor. Si se elige LAN, consultar [LAN individual y agentes](lan-individual.md); no unir ensayos independientes a una partida compartida.

```bash
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 verificar
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 play /ruta/absoluta/COPIA-COMPILADA.w3x
```

`verificar` comprueba presencia y accesos; no prueba las herramientas en profundidad. `play` extrae el script, valida con pJASS y prepara una copia por hash en `Maps/CodexTest/`. Los registros quedan en `runtime/wc3-tools/reports/play-<fecha>/`: `launch.json`, `pjass.log` y `runtime.log`. El lanzador muestra la ruta exacta del informe.

Para automatizar, iniciar el lanzador con `subprocess.Popen` y redirigir su salida a un archivo propio, o usar una sesión de ejecución reanudable. Pasar argumentos como lista. La llamada normal espera a que se cierre el juego; no bloquear toda la interacción esperando su retorno. `play` rechaza otro `war3.exe` en su perfil: identificar la partida existente y conservarla. No matarla para liberar el perfil.

Si cambia vJASS: seguir la skill de construcción, obtener JASS compilado, inyectarlo en una copia y reextraer/verificar. pJASS no transforma vJASS. No probar un mapa compilado de una revisión diferente por tener el mismo nombre.

Esperar una condición concreta: ventana visible, mapa cargado, línea inicial del laboratorio o resultado final. Sondear aproximadamente cada 0.2–1 s con plazo configurable; los ensayos previos usaron hasta 180 s para algunos laboratorios. Un equipo lento puede necesitar otro plazo. Al agotarse, capturar estado y marcar incompleto; no asumir aprobación.

## 4. Editor: cuándo abrirlo y cómo iterar

```bash
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 forge /ruta/absoluta/COPIA.w3x
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 newgen /ruta/absoluta/COPIA.w3x
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 ydwe /ruta/absoluta/COPIA.w3x
```

Elegir un editor. Los accesos no crean automáticamente la copia que figura en estos ejemplos. Forge Save As repaca primero el archivo abierto: abrir ya una copia. No escribir el mismo mapa desde dos editores.

En NewGen/YDWE se verificaron apertura, objetos y prueba con teclado. Confirmar el mapa y foco actuales antes de cada grupo de acciones:

| Acción | Atajo habitual | Condición que revisar |
|---|---|---|
| Abrir mapa | Ctrl+O | Diálogo y ruta de la copia |
| Objetos | F6 | Ventana y objetos esperados |
| Guardar | Ctrl+S | Compilación y empaquetado sin errores |
| Probar desde editor | Ctrl+F9 | Configuración actual de prueba y mapa cargado |

No aplicar estos atajos automáticamente a Forge: comprobar sus menús. En YDWE, revisar HostTest/modo LAN y número de clientes antes de Ctrl+F9; puede abrir varias instancias. Para LAN individual, usar la rama `EnableHost=1` y `HostTest.Option=0` descrita en [la referencia de aislamiento](lan-individual.md); `Clients=1` por sí solo no basta. No cambiar el perfil compartido de un editor ya abierto.

En la calibración YDWE se observaron JassHelper 0, CompilerResult true y PackerResult true; guardar y reabrir comprobó persistencia. Los textos exactos pueden variar. La reparación local de carga diferida de módulos Lua está documentada en `work/ydwe-calibracion/resultado.txt`; no reaplicarla rutinariamente. Guardar sin diálogo de error no acredita por sí solo que el script nuevo esté en el MPQ.

## 5. Entradas rápidas y capturas

Preferir el auxiliar Win32 ya probado para teclas breves si existe, se ejecuta en el perfil correcto y se identifica la ventana. Ejemplo conservado, dependiente de este workspace:

`work/two-candidate-tests-20261018/wine_ui_newgen.py` junto a `window_probe.exe`.
Fuente: `work/relativistic-rc8-20261016/window_probe.c`.

Comprobar los dos archivos antes del arranque. Sin argumentos, el wrapper enumera HWND, PID Windows y título. Reconciliar esa lista con la única partida nueva del perfil; en caso de duda, usar foco/captura del escritorio. HWND Win32, dirección de Hyprland y PID Linux son identificadores distintos. El auxiliar original no verifica la propiedad del HWND: esa comprobación corresponde al operador.

El wrapper admite `HWND 13` (Enter), `HWND text -todos` y `HWND close` (WM_CLOSE). Ejecutarlo con Python y argumentos separados, sustituyendo HWND por el obtenido en esa ejecución. La secuencia Enter → texto → Enter se probó en la galería de misiles. `-todos` es un comando de ese mapa, no de Warcraft. El texto del auxiliar es ASCII por bytes; no prometer Unicode. Verificar el efecto antes de enviar más acciones.

| Tecla | Código Linux para ydotool | VK Win32 del auxiliar |
|---|---:|---:|
| Enter | 28 | 13 |
| Esc | 1 | 27 |
| F6 | 64 | 117 |
| F9 | 67 | 120 |
| F10 | 68 | 121 |
| Ctrl izquierdo | 29 | 17 |

`Ctrl+S` mediante ydotool: `29:1 31:1 31:0 29:0`. Esos valores no sirven como VK Win32. El auxiliar sencillo envía una tecla completa, no ofrece combinaciones mantenidas. Usar ydotool para el atajo cuando corresponda. Soltar modificadores en un bloque finally si un script puede interrumpirse. Para rutas Windows con ydotool, verificar `type --help` y usar `type -e 0` cuando esa versión interprete escapes; pasar el texto como un argumento para conservar las barras.

Para ratón o entrada global, tomar y mirar captura nueva, identificar ventana y foco. Sintaxis Lua que funcionó en esta instalación de Hyprland; sustituir dirección y coordenadas por las actuales y comprobar versión:

```text
hyprctl dispatch 'hl.dsp.focus({window="address:0x..."})'
hyprctl dispatch 'hl.dsp.cursor.move({x=...,y=...})'
hyprctl dispatch 'hl.dsp.window.close({window="address:0x..."})'
```

El dispatcher antiguo `closewindow` falló en el contexto revisado. No repetirlo a ciegas. Para capturar, obtener el monitor de la ventana actual y su nombre de `hyprctl -j monitors`; después `grim -o NOMBRE /ruta/absoluta/captura.png`. No asumir eDP-1 ni 1920×1080. Guardar JSON de ventana/monitor; corregir posición, escala y transformación antes de hacer clic. Si cambia la disposición, recalcular. Revisar información privada antes de compartir capturas.

Comprobar terreno, interfaz y respuesta real. Que existan DLL no demuestra que estén cargadas; si se investiga el render, contrastar `/proc/PID/maps`, runtime.log y captura. El modo probado fue `-window` con fullscreen del compositor y RenderEdge; no cambiar globalmente resolución, perfiles ni teclas del usuario para repetir una prueba.

## 6. Leer resultados sin falsos positivos

Exigir inicio y final frescos, todos los logs secundarios, totales esperados y cero fallos donde ese sea el criterio. Guardar el resultado bruto y la interpretación. Ejemplos:

- `AUTO COMPLETE` con `failedChecks=1`: terminó, **falló**.
- 98 controles del fixture correctos: la preparación fue válida; revisar por separado los síntomas del sistema.
- Un subtest GroupCapacity terminado no aprueba el resto de Suite.
- Timeout sin resultado final: **incompleto**, aunque haya PASS parciales.
- Un control negativo que introduce un fallo debe ser rechazado por el evaluador; verificarlo al crear o cambiar un laboratorio.

Para comparar versiones, usar el mismo fixture y parámetros, registrar diferencias deliberadas y confirmar que se ejecuta trabajo equivalente. Un índice que omite contactos puede parecer rápido sin ser correcto. Contadores de operaciones no miden FPS ni memoria total. Para carga, aumentar por tandas y medir retiros/activos; que una creación masiva se corte en un hilo no demuestra el límite de instancias simultáneas. Mantener laboratorios fuera del mapa de producción.

## 7. Cerrar la prueba y conservar el trabajo

1. Recoger logs y capturas antes del cierre. Un juego que sigue abierto no implica que el laboratorio siga ejecutándose.
2. Cierre preferido en esta PC, indicado por el usuario el 21-10-2026: enfocar la ventana identificada de la partida propia, pulsar `Win+Q`, soltar ambas teclas, esperar `0,25 s` y pulsar `S` en la confirmación de salida. Con ydotool, los códigos Linux son Win izquierdo `125`, Q `16` y S `31`; liberar Win y Q antes de enviar S. Comprobar antes de `S` que el diálogo pertenece a esa partida y mantiene el foco. Si la ventana ya cerró, omitir `S`; si el diálogo aún no apareció tras los 0,25 s, esperar su aparición con plazo breve antes de confirmar. Esta secuencia es una preferencia del usuario; su incorporación documental no acredita una nueva prueba de ejecución. Si el atajo no está disponible o no muestra la confirmación esperada, usar el menú del juego (F10 y opciones observadas) o WM_CLOSE de su HWND, respondiendo únicamente a la confirmación de esa prueba.
3. Esperar brevemente y comprobar proceso/ventana. Si no sale, verificar de nuevo PID, tiempo de inicio, comando y prefijo exactos contra la identidad registrada al crear la partida. Solo entonces enviar SIGTERM al PID propio y comprobar su salida. Si no se puede demostrar propiedad, no terminarlo.
4. No usar `pkill wine`, `killall war3.exe` ni `wineserver -k` para limpiar una prueba. Pueden cerrar trabajo ajeno. No cerrar el editor del usuario. Un editor creado para el ensayo solo se cierra si no conserva trabajo pendiente y se identifica igual de bien.
5. Cerrar descriptores y recoger el proceso del lanzador. Mover descartes propios a papelera con `gio trash`; si el sistema de archivos temporal no admite papelera, moverlos primero a un directorio propio en el disco del workspace y después enviarlos a papelera. Conservar informe y evidencia útil.

No reutilizar PIDs o HWND de esta guía ni de los informes históricos.

## 8. Informe breve y límites

Formato sugerido: «Mapa/hash y versión. Escenario. Esperado frente a observado. Compilación/validación. Resultado dentro del juego. Evidencia. Pendientes». Por ejemplo: «100 creados, 100 retirados, activos finales 0; imagen correcta. Tested in map. Multijugador pendiente».

La validación multijugador requiere un ensayo independiente, con clientes/versiones identificados y comparación de contadores/checksums según el caso. El host LAN con un único cliente es aquí un mecanismo de ejecución para evitar pausas, no evidencia de sincronización. No heredar la aprobación de una RC anterior ni confundir dos clientes locales con dos equipos físicos. Si el usuario aplazó multijugador, conservarlo pendiente.

## Evidencia local de origen

Rutas relativas a `/home/snz/Documentos/ChatGPT/FrozenThone`:

- `scripts/wc3-play.py`: validación, staging y perfil de juego.
- `scripts/newgen-moderno.py`, `scripts/ydwe-moderno.py`: perfiles activos.
- `work/ydwe-calibracion/resultado.txt`: guardar, reabrir y Ctrl+F9; contexto EditoresNewGen, chat `01a1198b-7aca-7861-8df9-a3c09a5ff6db` leído el 19-10-2026.
- `work/two-candidate-tests-20261018/run_case.py`, `capture_game.py`, `run_gallery.py`: ejemplos históricos de espera/captura. Sus cierres no incorporan todas las comprobaciones de propiedad de esta guía; no copiarlos como limpiadores generales.
- `docs/contraste-candidato-two-en-juego-20261018.txt`: resultados parciales, fallos y límites de rendimiento.

Consultar evidencia histórica sin convertir sus resultados en los de una ejecución nueva. Esta skill documenta el método; no instala un controlador nuevo ni ejecuta pruebas al ser leída.

## LAN para pruebas visuales sin pausa de foco

Preferencia inicial del usuario22/10/2026, corregida después para ModelEditor: LAN es una opción para evitar la pausa al cambiar foco, pero el flujo de modelos vuelve al lanzamiento anterior y muestra primero la revisión3D. Cuando se elija LAN, verificar el avance del reloj/animación mientras otra ventana tiene foco antes de afirmar que se resolvió ese síntoma. No desactivar protecciones ni modificar globalmente el juego.

El lanzador común `wc3 play MAPA` sólo admite mapa; su revisión actual ejecuta `war3.exe -loadfile ... -window`, que inicia SP. No dispone de `--lan`. Para LAN manual, preparar la copia compilada/validada en un prefijo propio, arrancar `war3.exe -window` mediante el entorno moderno existente y elegir Red de área local → Crear partida → copia por hash. Registrar prefijo, puerto, PID/inicio, hash y modo antes de interactuar; un menú abierto todavía no acredita una partida LAN iniciada.

En diálogo hay un auxiliar específico en `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system/tools/launch-lan.py`; inspeccionar su ayuda, estado del perfil y evidencia vigente antes de reutilizarlo. El auxiliar prepara/lanzará el menú; la creación de partida se completa visualmente. No comparte ni cierra partidas ajenas.

Para pruebas de sincronización entre clientes, usar el flujo LAN específico (YDWE HostTest previamente verificado en esta PC) y su número de clientes/puertos; no abrir varios clientes por defecto para una prueba de apariencia. El modo LAN de un host aislado evita interferencias de foco, pero no convierte el resultado en una validación multijugador ni entre equipos físicos.

Excepción autorizada por el usuario22/10/2026: si iniciar LAN falla o tarda, volver al arranque individual que ya funcionaba. No convertir la preferencia LAN en un bloqueo del trabajo. Cerrar sólo el menú/partida propia antes del fallback y registrar que la comprobación se hizo enSP.
