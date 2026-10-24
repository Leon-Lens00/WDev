# LAN individual para pruebas independientes sin pausa por foco

La preferencia inicial del22/10/2026 era LAN individual para trabajo fuera de foco. La corrección posterior del usuario recupera el lanzamiento anterior para ModelEditor y solicita mostrar primero los modelos en un visor3D. Esta referencia queda para pruebas que elijan LAN explícitamente; no impone migrar los ensayos de modelos.

En LAN, cada agente prueba su propio mapa con anfitrión auxiliar y **una sola ventana Warcraft**. El host no es otra instancia del juego. Los trabajos separados no comparten partida ni resultados.

## Estado y configuración comprobada por lectura

La implementación local de YDWE contiene esta modalidad:

```ini
[MapTest]
EnableHost = 1

[HostTest]
Option = 0
```

Aplicar esos valores únicamente a la instalación de prueba que pertenece al ensayo, conservando los demás ajustes. El archivo local de referencia es `/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE/bin/EverConfig.cfg`. No cambiarlo mientras lo utiliza otro editor/agente. `EnableHost=0` abre una partida individual convencional y no resuelve esta necesidad.

El código `script/ydwe/ydwe_on_test.lua` hace lo siguiente:

- Con `EnableHost=1`, crea `ydhost` y lanza el cliente con `-auto`.
- Con `HostTest.Option=0`, devuelve exactamente un cliente y escribe `bot_autostart=1`.
- En `ydhost-source/src/game.cpp`, ese modo comienza la cuenta atrás cuando hay un cliente conectado; `StartCountDown` espera que los clientes hayan terminado de recibir el mapa.
- Con `Option=1`, la otra rama usa un mínimo de dos para `Clients`. Cambiar únicamente `Clients=1` no selecciona el modo individual.

Esto confirma la ruta de código, **no una ejecución satisfactoria de esta modalidad en 1.27b**. El historial LAN de dos/cuatro clientes no sustituye la comprobación de continuidad de un cliente. No recomendar `-nowfpause` como arreglo confirmado para nuestro 1.27b. No eliminar la pausa añadiendo llamadas periódicas a `PauseGame(false)` al mapa: alterarían la lógica ensayada y no acreditan funcionamiento fuera de foco.

## Aislamiento antes de ejecutar trabajos en paralelo

El lanzador actual `scripts/ydwe-moderno.py` fija un único `DATA`/WINEPREFIX y rechaza otra sesión abierta. Además, `ydwe_on_test.lua` escribe `plugin/ydhost/map.cfg` y `ydhost.cfg` en su instalación. **El comando actual no proporciona sesiones independientes por agente.** No inventar opciones `--session` o `--prefix`, ni saltarse su protección de sesión.

Antes de habilitar concurrencia, preparar mediante un mecanismo de aislamiento real:

- Un directorio de sesión con identificador único por agente/ejecución y un WINEPREFIX propio con instalación YDWE/host de trabajo independiente. No compartir por enlaces archivos que se escriben durante la prueba.
- Copias de mapa, archivos `map.cfg`/`ydhost.cfg`, mapa temporal del editor y salida `CustomMapData` separados. Revisar los enlaces a carpetas compartidas: un prefijo distinto no impide que apunten al mismo archivo físico.
- Nombre de partida único y asociación explícita al host correcto. Separar prefijos no aísla automáticamente el descubrimiento LAN: varios hosts pueden anunciarse a la vez en la misma PC. Comprobar la selección de partida del cliente automático; no dar por hecho que elegirá la suya. Usar un mecanismo de selección o aislamiento de red probado antes de paralelizar la conexión.
- Registrar el puerto TCP realmente asignado al host y la identidad de host/cliente. No asignar un mismo puerto fijo a todos ni cambiar puertos por conjetura. Confirmar ausencia de conflictos en el arranque.
- Manifiesto propio con agente, sesión, nombre de partida, hash del mapa, rutas, prefijo, PID/inicio de host y cliente y HWND de esa ventana. Usar esos datos para entradas, recolección de resultados y cierre.

Si el mecanismo de aislamiento aún no existe, ejecutar en serie en una sesión disponible y avisar de esa limitación. No afirmar que basta con cambiar el INI para permitir pruebas paralelas. Esta actualización de la skill no implementa un nuevo lanzador aislado.

## Comprobación mínima de continuidad

Al habilitar esta modalidad, antes de confiarle laboratorios largos:

1. Validar el mapa compilado con la toolchain Classic y arrancar únicamente el host y cliente propios. Con YDWE, Ctrl+F9 debe usar la configuración de esa sesión.
2. Confirmar por ventana/log que el mapa correcto entró en partida LAN, no que sigue en el lobby. Debe haber un cliente real; no añadir otro Warcraft o IA como requisito supuesto.
3. Observar un contador o temporizador del mapa que avance durante la partida. Preferir instrumentación ya existente; si falta, usar una copia diagnóstica breve. Guardar el valor inicial, velocidad de juego y tiempo monotónico de pared.
4. Cambiar el foco a otra aplicación durante unos diez segundos sin abrir F10 ni una confirmación de salida. Volver y comprobar que el tiempo simulado y el escenario avanzaron durante ese intervalo. El avance esperado debe tener en cuenta velocidad y carga. Registrar los valores y las marcas de tiempo; una animación o una captura aislada no demuestra progreso de la simulación.
5. Si se requiere concurrencia, repetir con dos sesiones aisladas y mapas/resultados distinguibles. Alternar el foco y comprobar por separado continuidad, identidad de mapa y archivos de salida de ambos. Coordinar las entradas globales de escritorio entre agentes; solo una ventana puede recibir el foco real a la vez. Preferir entradas dirigidas al HWND propio cuando funcionen.
6. Si el contador se detiene, el cliente entra en otro host, aparece espera por lag/desconexión o faltan logs, conservar evidencia y marcar el caso fallido/incompleto. No atribuirlo automáticamente al mapa ni esconderlo reenfocando la ventana continuamente.

Con un contador ya existente basta la prueba observable; no crear una batería de infraestructura para validar esta preferencia. Distinguir pausa por foco, menú/pausa manual y espera de red.

## Recogida, cierre y alcance

Leer solo los registros de la sesión y exigir los criterios funcionales del ensayo. Conservar evidencia antes de salir. Seguir la secuencia de cierre de la guía principal únicamente sobre la ventana propia; después terminar solo el host auxiliar creado por esa sesión, verificando PID/inicio y propiedad. No cerrar hosts o clientes por nombre global ni tocar editores ajenos. Temporales propios a papelera.

Registrar el modo como «LAN individual, un cliente» y su resultado de continuidad. Mantener `Tested in map` para la prueba funcional con un cliente; **no otorgar `Tested in multiplayer`** por usar transporte LAN ni por tener dos ensayos independientes abiertos. Sigue pendiente la validación sincronizada entre varios clientes de la misma partida cuando corresponda.

Fuentes locales leídas el 22-10-2026 (rutas desde FrozenThone): `runtime/proton-ydwe-modern/pfx/drive_c/Tools/YDWE/script/ydwe/ydwe_on_test.lua`, `tools/ydwe-lan-fix/ydhost-source/src/game.cpp`, `tools/ydwe-lan-fix/ydhost-source/src/socket.cpp` y `scripts/ydwe-moderno.py`.
