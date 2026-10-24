# Marco ausente en primera prueba en motor
Fecha:2026-10-22. Proyecto TerrainDev/dialogue-system, Classic1.27b. Estado: investigando.
Mapa6a5b0382: texto visible y diálogo activo, pero marco/retratos ausentes. Captura evidence/game-first.png. La geometría MDX800 y texturas BLP1 pasan lectores. Inspección detecta rutas de textura con dos separadores consecutivos en MDX por escape excesivo del generador MDL. Hipótesis: rutas MPQ no resueltas. Se normalizan a un separador y se reconstruye para contrastar en motor. Impacto: primera prueba visual no aprobada, originales intactos. Partida propia cerrada tras confirmación visible y S, salida verificada.

Segunda prueba01ee6c6c: normalizar rutas no hizo visible el marco. La hipótesis inicial no explica el defecto completo. Se instrumenta altura/life/tipo y un efecto sobre la misma unidad para distinguir modelo de proyección/unidad. Segunda partida también cerrada con S.

Prueba por etapas mapa75f7ca44: age200 visión compartida,400 escala XYZ,600 ApplySkin no hacen visible el modelo. age764 sigue ausente; age800 ShowUnit(false)/ShowUnit(true); age907 aparece. Capturas stage-12/13.png. El modelo como efecto ya era visible. Diagnóstico: estado de representación de unidad tras ocultado a escala cero; pendiente repetir con solo ShowUnit en apertura. Se retiran todas las sondas. Orientación invertida confirmada visualmente y se invierte ejeY de geometría. La escala y anclajes se calibran contra1920x1080.

Repetición de apertura limpia: refresco inmediato y a20ms no reproduce la recuperación tardía; no se da por cerrada la causa. Esc sí avanza y revela prefijo del siguiente mensaje. Al aumentar texto a0.036, el texttag nativo lo envuelve en un ancho limitado y se solapan líneas; se restaura0.027 comprobado sin salto adicional. La reflexiónY requiere invertir también winding de triángulos para mantener normal/frente coherentes. Se retrasa refresco a620ms después del cambio de viewport.

Variante dedicada: unidad voladora con Aloc/Avul, sin Aave ni ocultado por escala0. El marco ya aparece de forma estable desde apertura, pero la transformación visual difiere de la variante Aave; captura native-10.png. Se calibra escala/anclaje para este objeto explícito, sin trasladar parámetros de la fábrica anterior. Se retiran probes y recursos de diagnóstico. El frente reflejado conserva winding coherente.

Proyección con eye/target/FOV nativos: marco estable, colores y retratos correctos; Esc cambia interlocutor y muestra un prefijo corto. Se ajusta perfil de viewport cinematográfico con medidas de frustum-10.png (ancho~1698px) a factor0.81 y centroY-0.56. La última frase confirma reflujo automático de texttag; se predividen todas las páginas a36grafemas tanto en UI Studio como en el generador para que los saltos sean estables. Pendiente única: pasada final con esos parámetros.

La suite detectó una expectativa obsoleta en el test de avance tras cambiar a36columnas: X ahora ocupa2páginas. Se mantiene la comprobación de completar primero, y se comprueba explícitamente permanecer en X al pasar de página antes de avanzar al último interlocutor. No se cambia el runtime para satisfacer la expectativa anterior.

La variante con eye+campos nativos de orientación es estable y completa en orientation-10.png; lectura AA304°/R90°/FOV70°. Se descarta la dirección calculada de eye a target para este perfil. La causa interna exacta de su discrepancia no se certifica. No se alteran Camera ni UIPicture compartidos. Se usa dlog con base del dummy ya validado dumi, movimiento fly y alturas inicial/mínima0, escala1 explícita; pose/escala calculadas desde campos nativos. Se retira el texto de diagnóstico y se ajusta el margen inferior una sola vez con la medición de esa captura.

## Recurrencia y cambio de flujo, 22/10 14:15
La revisión 4a5f4c4e encaja en verified-10.png pero se recorta en otra posición de inicio (balanced-10.png). No se confirma calibración general. Posible limitación de coordenadas de la unidad cerca del borde: hipótesis sin instrumentación, no causa demostrada. El usuario solicita concentrar las iteraciones en UI Studio. Se lleva un perfil afín de captura, geometría/alpha de textura, superposición de ambas evidencias y exportación de constantes al editor; no emula el clipping del motor. Sigue abierto el defecto nativo.
Partida propia PID528069: confirmación de salida observada en exit-fifteenth.png, S enviada. El auxiliar necesitó SIGTERM exclusivamente al PID/prefijo/start identificados; salida verificada, no se deja corriendo.

## Contraste de coordenadas, 22/10 14:33
Buildd823df82, PID533281. requested=(2944.001,-6442.396,1234.406), actual=(2944.000,-6442.396,1234.406), fly1007.379. GetWorldBounds[-28672,-28672,8192,8192]. Diferencia<=0.001: la hipótesis de clamp al borde no explica el recorte. Registro conservado en evidence/texttag-lab/dialogue-position-diagnostic.txt. La sesión terminó antes de la siguiente captura; /proc/533281/stat ya ausente y no se presume causa ni se señala crash sin registro. Se prioriza evaluación de texttags solicitada por el usuario, en un laboratorio aparte.

22/10 15:30: texto largo/compacto con avances nativos probado (composition-final-wide.png / composition-final-compact.png). El marco sigue demasiado alto, especialmente compacto, mientras posiciones de texto son estables. Se contrasta ahora dirección GetCameraTargetPosition-eye en ProjectFrame frente a trigonometría de CAMERA_FIELD_ANGLE_OF_ATTACK; es hipótesis hasta medir y capturar ambas zonas. Se añade flecha arriba para volcar diagnóstico durante conversación activa (antes se volcaba tras resetear cámara al cerrar). No modificar bibliotecas congeladas.

22/10 15:42 — contraste completado. Dirección nativa ojo→objetivo NO corrige el fallo: ray-wide.png encaja en zona0 y ray-zone1-wide.png vuelve a recortar en zona1, dentro de una misma ejecución PID596865. Las cámaras activas tienen casi igual Z/orientación/FOV; antes se había comparado contra un Dump posterior al ResetToGameCamera, que mezclaba dos estados. Telemetría activa ray-wide-diagnostic.txt / ray-zone1-diagnostic.txt. La dirección real se conserva como formulación geométrica explícita, sin atribuirle recuperación.

SetUnitPosition tampoco resuelve: variante A/B build-position-manifest.json, PID601243, position-target.png vs position-ab.png; tamaño/posición siguen incorrectos, sin clamp XY. Se retira el experimento SetUnitPosition y la tecla abajo; se conserva flecha arriba para obtener diagnóstico durante la conversación. Se detiene la cadena de cambios de proyección: falta determinar el transform/render real de la unidad y su interacción con el terreno/cliente; GetUnitFlyHeight+GetLocationZ es un cálculo, no una lectura independiente del Z renderizado. No presentar la hipótesis de terreno como causa confirmada.

La escala visual solicitada por el usuario ya se ajustó en UI Studio (ancho68%, margen14.4%, letra0.027) y se conserva en conversation.wc3dialogue.json y work/dialogue-composition-20261022/user-scale-design.json. El texto se compone y exporta correctamente, pero no se aprueba la alineación nativa final. Todos los procesos propios de esta fase se cerraron conS y verificación de salida. Estado: abierto, delimitado al marco y su equivalencia con las coordenadas de texto.

## Evidencia del usuario: recurrencia al reabrir

22/10/2026, chat de diálogo. El usuario informa que a veces aparece al repetir
`-dialogo`. Capturas aportadas:

- `/tmp/codex-clipboard-c72b0f35-1611-46a1-9b2f-a7954a010ed3.png`
- `/tmp/codex-clipboard-44d4716e-fd0f-4513-afc1-6db2df8a44ac.png`

En ambas, el escenario y los anclajes del nombre/cuerpo permanecen visualmente
iguales; el marco se desplaza y aumenta, llegando a recortarse por lados opuestos.
Esto añade reapertura en el mismo escenario como reproducción informada; no
atribuirlo exclusivamente a cambiar de zona. Las capturas no incluyen telemetría
ni permiten saber cuánto tiempo llevaba abierto el panel en cada caso.

Inspección CodeGraph de `ConversationUI.j` vigente: `ConversationOpen` rechaza
aperturas mientras `Active`, reutiliza una sola unidad `Frame` y reinicia el mismo
timer `Clock`. No se observa creación acumulativa de paneles/timers por ese comando.
`Tick` aplica la cámara y actualiza texto y marco cada 0.01 segundos. Marco y texto
usan transformaciones distintas (proyección nativa manual y `Camera.win2World`).
Además, al reabrir se llama `ProjectFrame` antes de reaplicar `Cam`; la cámara se
reaplica en el primer Tick, mientras que el cierre previo hace `ResetToGameCamera`.
Es una diferencia de orden verificable que debe incluirse en el contraste de
reapertura, pero no demuestra por sí sola el desplazamiento persistente: los ticks
siguientes vuelven a proyectar. No se aplica otro parche de calibración sin aislar
esa diferencia y el estado renderizado de la unidad. Estado: abierto.

La sesión abierta a petición del usuario se conserva; esta inspección no envía
teclas, cierra el juego ni modifica el mapa cargado. Las consultas MCP devolvieron
fuentes vigentes; los avisos de dispatch indirecto de cargas generadas siguen
siendo límites estáticos conocidos, sin fallo de sincronización en estas consultas.

## Cámara ligada a unidad sin cinemática, 22/10 16:08

Build6e047923, PID619626. Patrón Inventory.onDisplay integrado: Hpal propietario, Camera.setPosition/aplicar, win2World común para marco/textos; HUD visible, sin ShowInterface/ResetToGameCamera y sin autoapertura. Capturas unit-camera-loaded/open/reopen/zone1/zone1-restart.png. La reapertura en zona0 puede encajar; el marco desaparece en zona1 mientras UIText permanece fijo. Integración solicitada funcional, recuperación visual todavía no demostrada. No presentar el cambio de cámara como causa confirmada/fix. Continúa contraste del dummy visual con fábrica nativa (visibilidad, altura y ciclo de render). Fuentes y librerías compartidas intactas.

La sesión619626 ya no existía al intentar el cierre; game.py rechazó la acción por /proc/619626/stat ausente. La captura posterior también quedó rechazada y no se generó; no se atribuye crash ni cierre al agente sin evidencia. No se enviaron teclas ni SIGTERM. Diagnósticos frescos1..3 conservados en work/dialogue-unit-camera-20261022/first-session-diagnostic-*.txt; los demás logs de numeración fija son históricos, no evidencia de esta ejecución.

Contraste siguiente: dlog basado en uidm (dummy original de interfaz), movimiento float/velocidad mínima1 y desbloqueo de altura Aave sin ocultar mediante escala cero. Antes heredaba hfoo/dumi con movimiento fly y velocidad0. Esto prueba la configuración del dummy nativo como conjunto, no aísla todavía qué campo individual explica el fallo.

## Resultado del dummy de interfaz nativo — 22/10, buildb80ca9d9

PID623953, mapa b80ca9d93ca03939c5c46e9eccd99a59d7957c837b712d17c0425f1935f92f67. Dlog ahora deriva de uidm/ewsp con float, velocidad mínima1, topes de inclinación originales y Aave para altura; no se toca el MDX ni las bibliotecas. El fallo grave (quedarse en una zona/desaparecer) no reaparece en la muestra: zona0, traslado activo a zona1, orden real de caminar con clic derecho, reinicio, cierre/reapertura, retorno a zona0, páginas y variantes roja/azul. HUD permanece operativo, Esc observado. Capturas evidence/unit-camera-native-{open,zone1,moving,moved-settled,restart,reopen,return0,blue,esc,closed}.png. Datos de ejecución en latest-game-test.json y work/dialogue-unit-camera-20261022/result.json.

La recuperación observada corresponde al reemplazo completo de configuración del dummy, junto al seguimiento de unidad y proyección compartida; no se atribuye a un campo individual ni a la frecuencia del timer. En movimiento aún se observa un pequeño desfase relativo transitorio entre marco/texto, sin medir latencia ni tolerancia. Se conserva abierto para ese ajuste y la equivalencia visual final; no dar aprobación general. No se ensayó compacto en esta nueva sesión.

UI Studio incorpora vista gameplay, HUD real de esta prueba como fondo y comparación seleccionable con captura nativa. Editor primero y 35 pruebas Node; escala/anclas comparten Camera.win2World. Partida cerrada tras confirmación visible unit-camera-native-exit.png y S; salida verificada sin SIGTERM. No queda esta partida abierta. La partida anterior entregada al usuario610804 también salió con S al reemplazarla.

## Auditoría posterior de InventorySys

La comparación con descarga reciente confirmó que uidm/modelos originales se conservaron en inventario, pero Camera.win2World se había modificado de .eye a GetCameraEyePosition*. Una copia A/B de la demo original reproduce descolocación sólo al activar esa modificación, mientras restaurar .eye recupera el marco. Ver /home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-22-163705-inventario-proyeccion-movimiento.md. Por tanto, la explicación previa basada sólo en el dummy es incompleta; la proyección compartida también requiere corrección. No se aplica cambio a diálogo en esta auditoría.

## Recuperación adicional de proyección — 22/10/2026

La cámara compartida restauró eye original y calibra base del controlador una sola vez fuera de proyección. Diálogo5777003b probadoPID639115: marco/texto alineados, ambas zonas, reinicios, cierre, rojo/azul y movimiento. Error targetZ -22.789→0.000 en registros; no vuelve el marco gigante/recorte en esta muestra. Residual≈1px (eye lógico hasta0.138 de diferencia), sin prueba larga ni compacto en esta revisión: continúa abierta para precisión final, no se presume fallo grande pendiente. Evidencias work/camera-restore-20261022/RESTAURACION.md. Proyección inventario resuelta en informes/errores/resueltos/2026-10-22-163705-inventario-proyeccion-movimiento.md.

## Cierre de regresión reproducida — 22/10/2026

Restauración de Camera.eye + calibración inicial de altura + reconstrucción absoluta eye en adaptador de diálogo. Mapa ea4073c65837ff39b36376a6f4e4923d569a8fbd44fc2df363e9329d3b9dee45; PID649780: ambas zonas/reinicios/cierre, movimiento nativo con posiciones distintas y cuatrocapturas estables, residual≤0.001. Ya no aparece el marco gigante/recortado ni variación1px en esta muestra. UI Studio ajustado a arte/tamaño del nombre con36tests. AFINADO en work/dialogue-fine-20261022 conserva todo. Estado: resuelto para fallo de marco en1920×1080SP. Fuente aproximada, otras resoluciones, compacto nuevo y sesioneslargas/LAN son límites de cobertura; no se declaran fallos observados ni validación universal.
