# X3: acumulación de brillo en primera muestra

Fecha: 2026-10-22. Proyecto ModelEditor, Classic 1.27b, primera construcción v1.
Estado: corregido pendiente de comprobación visual.

Primera galería en motor: el buster muestra demasiado blanco y la cabeza azul queda oculta. Evidencia: ModelEditor/evidence/x3-v1/game-stand-full.png. Causa: superficies cerradas aditivas TwoSided y superposición de las envolventes hasta la punta; el doble dibujo suma luminosidad. Se cambian superficies cerradas a una cara con winding exterior y se separan longitudinalmente corona rosa, collar azul/verde y punta clara. Originales conservados.

También falló el filtro de identidad de la ventana por comparar WINEPREFIX con una barra final literal. Se resolvió normalizando Path.resolve; la identidad PID718496/start11383006/prefijo propio quedó comprobada antes de actuar. Primera captura parcial tras mover ventana corregida esperando nuevo frame y recapturando. No se envió entrada a otra aplicación.

## Capturas compartidas del escritorio
Una captura de Death tomó otra prueba que se había mostrado en el monitor, identificada por contenido y PID ajeno720275. Esa captura no se considera evidencia X3. Se conserva sin usar para entrega. El usuario indicó pantalla3; se fijó la ventana propia721447 en el monitor derecho DP-1 y se repitieron capturas comprobando PID, monitor y workspace en cada frame. El helper Win32 usó exclusivamente el HWND del prefijo X3; no se envió el chat de prueba a la partida ajena.

## Activación nativa recuperada
La galería permanecía en pausa al perder la activación nativa durante el auxiliar de consola, aunque Hyprland mostraba su ventana enfocada. Un clic real dentro de la ventana propia, tras comprobar PID/prefijo/monitor, recuperó la simulación y aplicó el comando pendiente. Se incorporó la activación a src/capture-x3.py. El flash Birth aparece y se desvanece en birth-verified/000.png y siguientes: fallo de captura/activación, no ausencia del modelo.

## Cierre verificado
Estado final: resuelto. Segunda construcción muestra collar azul/verde diferenciado y núcleo claro; capturas game-scale3.png y MUESTRAS.png inspeccionadas. Birth/Stand/Death y escalas0.5/2.4/3 observadas en la partida propia. Capturas finales verifican PID721447 y DP-1. Cierre confirmado en ventana propia, lanzador terminó0 y cero procesos del prefijo; partida ajena conservada. El modelado sigue como primera interpretación visual pendiente de valoración del usuario, no copia exacta ni física comprobada.

## Registro final
Una llamada auxiliar para guardar source-hashes.json falló por nombre de variable e en lugar de ev; no alteró modelos ni ZIP. Se corrigió la llamada, se escribió el registro y se releyó idéntico. Estado final resuelto; el SHA del ZIP sigue siendo2149df953c1d617f5a96880e5b3b4f0faf3515aa6f1dbc208f3778a249f8d752.
