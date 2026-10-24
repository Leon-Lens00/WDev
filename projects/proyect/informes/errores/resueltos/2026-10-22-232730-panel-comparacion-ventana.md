# Comparación panel: control de posición

Fecha: 22/10/2026 America/Lima. Chat de diálogo, Classic1.27b/GE-Proton/Hyprland.
Estado: resuelto.

Al iniciar la copia B d29f771227586dd5, probe.py init produjo AssertionError en
focus(): comprobaba at.x=1920 antes de aplicar fullscreen. Ventana PID849452
pertenecía al monitor2/workspace32, pero estaba en modo ventana con at[452,196]
y size[1016,734]. La captura/entrada posterior se detuvo en el mismo control.
El mapa no falló; sólo se impidió la prueba de apariencia por una precondición
incorrectamente ordenada en el auxiliar copiado de la ejecución anterior.

Corrección: identificar PID/inicio/prefijo/hash, enfocar monitor/workspace/ventana
y aplicar fullscreen antes de exigir coordenadas físicas. Se conserva el control
estricto de las capturas y la identidad. Auxiliar/evidencias: work/panel-comparison-native-20261022.
Pendiente: repetir init y comprobar captura de B en1920x1080 monitor2.

Recuperación comprobada: init volvió0 con PID849452; despues-rojo.png muestra
la copia B a1920x1080 y despues-rojo.json acredita monitorHDMI-A-1/workspace32,
posición[1920,0], ventanafullscreen y hashd29f771227586dd5. Sólo se corrigió
el auxiliar de prueba; ambos mapas conservan sus hashes.
