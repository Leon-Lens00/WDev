# Prueba nativa de barras horizontales

Fecha23/10/2026, Codex. Proyecto TerrainDev/dialogue-system, Classic1.27b/Proton.
Estado:resuelto por correcciones y alternativa autorizada.

Preparación:la guarda de identidad comparó WINEPREFIX literalmente. Proton lo
expone terminado en /; la ruta esperada no lo llevaba. AssertionError antes de
enviar entradas. Intento posterior de abrir captura inexistente también falló,
consecuencia de esa interrupción. No se afectó a otra partida.
Evidencia:PID1057437, cmd C:\WarcraftIII\war3.exe -window; prefijo privado
TerrainDev/dialogue-system/runtime-lan/pfx/. Causa confirmada:normalización.
Acción:normalizar exclusivamente barra final con rstrip('/'), revalidar PID e
inicio contra /proc y conservar prefijo/ventana/mapa en identidad propia.
Pendiente:comprobar recuperación y prueba funcional.

La ventanaLAN terminó con retraso trasWin+Q:la comprobación posterior encontró /proc ausente antes deSIGTERM; no se envió señal. SP arranca con PID1058541. Primera captura mostró Dolphin pese a identidad correcta:ventana flotante mantenía coordenadas del monitor anterior. Forzar fullscreen en el monitor2 colocó el cliente1920×1080 enHDMI-A-1; captura full.png confirma el mapa y barras. No hubo defecto de carga de las barras.

La revisión con iconos completos decontrol compartido produjo un fallo aislado de
captura fullPage deIAB:AX y carga correctos, mensaje Unable to capture screenshot.
Se consultó browser-troubleshooting y la alternativa documentada getScreenshot
funcionó, mostrando ambos marcos en cuadrícula. No se cambió el dibujo por ello.

Cambio solicitado:propietarioauxiliar10 con control compartido y colorP0. Ensayo avanzado mostró icono nativo lateral y marco azul propio:work/healthbars-shared-native-20261023/shared-loaded.png. La hipótesis propiedad→ocultación completa no basta con el control avanzado. UnitMetaData.slk efectivo deWar3x1.27b no contieneuhhb/hideHeroBar, por lo que no se añade un campo supuesto. Se contrasta control básico frente al avanzado antes de elegir otro mecanismo. Proceso1066292 cerrado Win+Q/S y ausencia comprobada.


Desenlace23/10/2026:control básico(shared_control=true, advanced=false) elimina
el icono lateral. No se usó un campo de ocultación supuesto. Capturasbasic-loaded.png
frente ashared-loaded.png; misma Hpal/owner10. Selección yórdenes disponibles.
Entrada nativaL, clic izquierdo completó Luzsagrada:holy-after-left.png muestra
maná190 frente255 y efecto decuración. Losprimeros clics fuera de la parte
seleccionable del modelo se rechazaron como punto; no era fallo de control.
Movimiento porclicderecho confirmado en posiciones3184,-5712 →3408,-5418 y
capturas player-move-c1.png; logs guardados. La vista IAB se recuperó con
getScreenshot. Map94ca3ebf compila y se reextrae correctamente;37mips y303estados
verificados. Vídeo final46,63s yprueba actual en latest-healthbar-test.json.
Partidas propias cerradas Win+Q/S y ausencia deprocesos comprobada enclosed.json.
LAN no se completó; se cierra mediante fallbackSP autorizado, no como LANPASS.
