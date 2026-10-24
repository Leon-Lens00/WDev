# Cambio de foco y perfil compartido ocupado durante ensayo WavePlayerUtils

Fecha: 2026-10-23-024931, Codex/WaveSys, Classic 1.27b en Hyprland/GE-Proton. Estado: en investigación; no se atribuye fallo al registro nuevo.

La sesión propia players-alone-v1 (PID907063, identidad conservada) terminó 39 controles sin fallos. Al cerrar, el guard de foco abortó antes de enviar S: otra ventana Warcraft III PID907756 tenía el foco en otro monitor. Se intentó después lanzar players-coexist-v1; play lo rechazó por perfil moderno ocupado. Causa confirmada del rechazo: hay otra partida concurrente. Propietario de esa otra partida desconocido; preservarla.

Evidencia: [ventanas](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/players-focus-change-windows.json), [rechazo del lanzamiento](/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/players-coexist-v1-play.log). No se envió la confirmación a la ventana ajena.

Acciones: volver a enfocar únicamente la sesión propia, comprobar su diálogo antes de cerrarla; buscar perfil aislado para ensayos restantes. Pendiente verificar cierre propio y alternativa de lanzamiento. Las pruebas no lanzadas no acreditan recuperación ni coexistencia.

## Desenlace comprobado

Estado final: resuelto con aislamiento y guardas; no se atribuye defecto al registro.

Precisión de la causa: PID907756 pertenecía al perfil independiente de ModelEditor (`build/x3-v4-ydwe-runtime/pfx`), no al perfil compartido de nuestra sesión. El rechazo de play se debió a que nuestra propia PID907063 seguía abierta tras el aborto de confirmación por foco. Se cerró sólo907063 mediante SIGTERM tras verificar PID/inicio/comando/prefijo; en ese momento907756 seguía vivo. No se enviaron teclas de confirmación a907756 ni se terminó su proceso.

Se creó una copia reflink del perfil bajo WaveSys/.cache/player-test-profile y se aplicó una sustitución de DATA/logs únicamente en una copia generada del launcher. La sesión de coexistencia913833 recibió el mapa correcto por hash y fd de proceso. Su ventana quedó con workspace32 y geometría/monitor1 inconsistentes; las capturas iniciales de DP/HDMI no correspondían a la prueba y no se usan como evidencia de juego. Mover sólo la ventana propia a workspace1 resolvió la visibilidad/avance y produjo log nuevo completo:39 controles,0 fallos. La sesión negativa915000 produjo10 fallos esperados. Ambas se cerraron por Win+Q, revisión de diálogo propio y S; identidad y cierre conservados.

También se intentó ver una captura antes de terminar el exec que la producía: la herramienta devolvió imagen inválida. Esperar la sesión y abrir el archivo completo recuperó la lectura. No es fallo de JASS ni del producto.

Evidencias: players-concurrent-state.json, players-isolated-profile.json, players-isolated-launcher.json, los logs nativos y *-closed.json bajo WaveSys/evidence. La prueba positiva aislada original también completó39 controles/0 fallos. Las tres PIDs propias están terminadas. Los negativos fueron deliberados, no una regresión en src.
