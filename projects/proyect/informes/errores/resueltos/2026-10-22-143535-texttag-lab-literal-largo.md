# Fixture largo rechazado por pJASS
Fecha2026-10-22 14:35 America/Lima. TextTagLab, Classic1.27b, JassHelper release+pJASS. Estado: corregido pendiente de verificar.
El ensayo de1024bytes fue emitido como literal largo. pJASS rechazó compiled.j:2163: String literals over1023chars long crash the game upon loading a saved game. Log /home/snz/Documentos/ChatGPT/FrozenThone/runtime/wc3-tools/reports/vjass-20261022-143535-473211/pjass.log. El builder abortó sin lanzar mapa. Este límite de literal/JASS no demuestra límite de texttag.
Se divide en literales de200caracteres concatenados mediante lecturas de variable en ejecución para medir el texttag, conservando la longitud esperada y registrando StringLength real. No se desactiva el validador. Pendiente compilar/reextraer.

Recuperación: build20261022-143648-823469, laboratorio SHA2566cf5215d…; JassHelper y pJASS PASS, reextracción y conservación de cabecera/miembros PASS. Cadenas largas construidas por tramos. Estado final: resuelto para preparación/compilación; render se evalúa aparte.
