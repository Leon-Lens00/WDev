# Vista de conversaciones en UI Studio

Continuación vigente: [evaluación y plan de línea, señal y retratos animados](dialogo-retratos-animados-senal.md),22/10/2026. La nueva grabación17.45.26 muestra apertura y cierre completos. Evaluación terminada; implementación de esa ampliación pendiente.

Fecha: 2026-10-22. Objetivo: prototipo editable y animado en el UI Studio local existente. Referencia: captura de Mega Man suministrada por el usuario. El inventario y sus objetos son una guía técnica; esta vista debe mostrar exclusivamente conversaciones.

Alcance: añadir un modo de conversación con dos retratos, marco angular, nombre y escritura progresiva, edición de frases/velocidad, avance/completado y reinicio. Conservar los proyectos anteriores y su exportador; desactivar la demo de inventario en la vista de conversación. No convertir una simulación de navegador en una afirmación de ejecución en Warcraft ni modificar TerrainDev durante esta vista de diseño.

Inspección: CodeGraph consultado en /home/snz/Documentos/WarDatsPy/ui-studio/dist para preset, validateProject, renderStage, renderInspector y exportJass. El esquema de inventario tiene cuatro grupos y sólo rawcodes para imágenes, por lo que una escena de conversación necesita contrato propio versionado y persistencia separada. El servidor local es Node sin paquetes, puerto 4317. CSS/HTML, pruebas y recursos se inspeccionan directamente fuera del índice JS.

Fases: (1) respaldar y preparar recursos a partir de la referencia; (2) añadir vista de diálogo al editor, datos validados y reproducción temporal; (3) comprobar escritura, avanzar, reiniciar, edición/guardado y ausencia de regresión del editor de inventario; (4) capturar comparación visual, conservar JSON editable y documentar alcance de exportación/integración.

Comprobaciones: pruebas Node pertinentes del contrato y del reloj de escritura; suite existente del editor; ensayo real en navegador para las interacciones y adaptación a tamaños. QA visual con referencia y captura juntas. Nunca prometer que la animación web ya funciona en Classic 1.27b.

Estado inicial (superado): inspección y respaldo completados. Respaldo: work/dialogue-studio-20261022/before/.

## Cámara de unidad sin cinemática — 22/10, petición vigente

Implementar en la copia de diálogo el patrón comprobado en
Inventory.onDisplay: posición del propietario → Camera.setPosition/apply →
actualización de interfaz. Unidad de prueba Hpal (igual que TerrainInventory),
seleccionable y móvil, cámara persistente aun con panel cerrado. No ocultar HUD,
no activar cinemática ni resetear cámara al cerrar. Apertura mediante -dialogo;
-reiniciardialogo para reiniciar explícitamente aun abierto. Un único timer y pool.

Marco y textos compartirán Camera.win2World; datos de anclaje/escala física
derivados de la misma geometría del editor. Agregar vista de juego con zona HUD
reservada al editor; conservar diseños y perfil histórico de captura. No modificar
las dependencias congeladas ni el MDX. Respaldos en
work/dialogue-unit-camera-20261022/before/.

Aceptación: editor primero (HUD, texto dentro de marco, exportación consistente),
suite Node, build/pJASS/miembros y una sesión consolidada en 1.27b: mover unidad,
cerrar/reabrir/reiniciar repetidamente en dos zonas, comprobar HUD y alineación.
La hipótesis de integración no se declara fix del fallo anterior sin esas pruebas.
Estado: implementación en curso; partida anterior del usuario identificada, se
reemplazará sólo al cargar el artefacto nuevo para esta prueba autorizada.

Resultado: implementado y probado sin cinemática. Build b80ca9d9,35pruebas Node,
JassHelper/pJASS/miembros correctos. Primer ensayo mantuvo el dummy de misiles y
reprodujo pérdida del marco; segundo usa configuración nativa uidm/float/velocidad1
y Aave, recupera seguimiento en movimiento/zonas/reaperturas dentro de la muestra.
Se incorpora su HUD y captura al editor para siguientes ajustes. Evidencia y
cobertura: TerrainDev/dialogue-system/latest-game-test.json y
work/dialogue-unit-camera-20261022/. Partidas propias terminadas, UI Studio vivo.
Pendiente: desfase pequeño durante movimiento/equivalencia final, compacto en
nuevo modo, otras resoluciones. Incidencia130405 sigue abierta para esos límites.

## Vídeo y ampliación del objetivo

El usuario aportó recording_2026-10-22_12.40.44.mp4 y pidió evaluar/desarrollar el modelo plano para reproducir el efecto en el juego. Es una grabación de Mega Man, no una ejecución de Warcraft. Duración 23,783 s. Fotogramas en work/dialogue-studio-20261022/video muestran panel rojo/azul según interlocutor y escritura progresiva. Se amplía el trabajo a un recurso plano MDX800 con variantes y animaciones de apertura/cierre, texto dinámico separado y copia TerrainDev-Dialogue.w3x; se conservarán los mapas e inventario previos. Probar en 1.27b si la preparación/compilación es viable. No hornear frases completas en el modelo.

## Prioridad del usuario: calibrar en UI Studio — 22/10 14:25

Implementada la vista Warcraft1920×1080 con perfil de captura y comparación por opacidad de dos evidencias reales: verified-10.png (marco completo) y balanced-10.png (recorte en otra zona). Calibración afín explícita, no emulación del motor. El lienzo se ajusta al espacio disponible. Referencia/cinemática y formatos16:9/4:3 permanecen como vistas de composición.

Contrato compartido: dist/dialogue-calibration.js contiene dimensiones modelo140×58.321, fuentePNG1942×809 con alfa x63..1876/y47..763, BLP1024×512, perfil de pantalla y proyección. dialogueProjection alimenta la vista y projectionJass genera DialogueProjection.j; el builder consume esa misma salida. Depth400/FOV70/frustum0.81/centerY-0.49 como base provisional. Campos planeWidth/Height/Top ajustan la equivalencia de captura; campos nativos depth/frustumWidth/centerY se exportan a JASS. La pendiente31.75 es un ajuste local observado, no una ley de Warcraft.

El JSON guarda el perfil además de mensajes, texto y parámetros; los proyectos anteriores migran conservando historia. tools/story.mjs --input ARCHIVO permite preparar el diseño exportado antes de build.py. El builder vuelve a preparar la entrada guardada, compila19fuentes y preserva miembros ajenos. Retratos personalizados, colores/tipografía y anclajes de texto de la vista aún no se convierten automáticamente; integración completa editor→mapa pendiente.

Verificación:27/27pruebas Node; prueba real en navegador de cambio de ancho, profundidad400→1200 (escala3.241→9.723 con tamaño de pantalla fijo), centroY y restauración; exportación JASS del navegador idéntica a fuente del builder. JassHelper/pJASS y reextracción PASS en build20261022-141729-284004 (f76b2e57…). No se vuelve a abrir el juego para iteraciones del editor. Proceso propio528069 terminado y verificado.

Pendiente motor: el recorte dependiente de posición sigue abierto en [incidencia principal](../../informes/errores/resueltos/2026-10-22-130405-dialogo-marco-invisible.md). La hipótesis de límites de unidad requiere medir solicitado/real antes de otra calibración. Próxima prueba del motor deberá contrastar ambas zonas y reapertura, tras estabilizar diseño en el editor. No afirmar calibración general, sincronización multijugador ni equivalencia tipográfica exacta.

## Evaluación de texttags solicitada, 22/10 14:35
Antes de finalizar modos amplio/compacto, evaluar29casos en copia TerrainDev-TextTagLab.w3x: tamaños0.018/.027/.036/.045;40/80/160caracteres con/sin espacios; ancho de i/W;2/4/8líneas explícitas;128/256/512/1024bytes, tildes, color, saltos\n y|n, prefijos por grafemas. Una sola sesión de laboratorio con rotación automática, cinco tags persistentes, capturas+StringLength. Medir anchos/altos/renglones de la imagen, no confundir cadena válida con render íntegro. Fuentes de foro contrastadas: Hive character-limit.264073, customwindow-v1-1-1-2.207526 y local-text-tags.275280. No trasladar100tags a100caracteres. La integración posterior deberá conservar texto completo, paginar y validar anchos; si hace falta fragmentar renglones, probar un pool limitado. El fallo del marco sigue separado.

Evaluación terminada: [ESTUDIO-TEXTTAGS](../../TerrainDev/dialogue-system/ESTUDIO-TEXTTAGS.md),29casos capturados y longitudes verificadas, medidas y fuentes web conservadas. PID558533 cerrado conS, sinSIGTERM. Límites visuales demostrados, no máximo universal de caracteres. Listo para diseñar amplio/compacto; siguiente implementación: composición por métricas y pool acotado de fragmentos, con aviso de capacidades en el editor. No se cambia aún el renderer ni se da por corregido el marco.

## Composición compartida y editor primero — 22/10 15:10

Implementación autorizada por el usuario: modos amplio/compacto por mensaje, hasta tres renglones y cuatro fragmentos por renglón; pool fijo de14texttags (12cuerpo+nombre+indicación), sin crear uno por letra. Un módulo puro de composición en dist se importará también en tools/story.mjs: decide saltos, páginas, fragmentos, anchos y posiciones antes de escribir. Los prefijos conservan grafemas Unicode; colores externos al texto, sin interpretar códigos |c del usuario. Fuente local Fonts/FRIZQT__.TTF extraída de war3.mpq; UI/war3skins de War3xlocal selecciona esa fuente. Sus métricas de avance TTF no coinciden aún con todos los avances del laboratorio: perfil provisional con margen y advertencias, no equivalencia pixel perfecta. Conservar perfil/procedencia y permitir corregirlo una sola vez.

Los JSONv1 anteriores migrarán agregando presentación amplia por defecto. Compacto usará el mismo MDX escalado, posiciones de texto y tamaño nativo derivados del mensaje; no cambiar el recurso del modelo. Pruebas: ajuste por ancho proporcional (i/W), conservación de texto/paragraphs/Unicode, máximos de pool/páginas y ausencia de movimiento al revelar prefijos; Node+prueba real en UI Studio con guardado/lectura; generación, JassHelper/pJASS y reextracción de copia. Una sesión final del juego contrastará fragmentos, ambos tamaños y cierre. El fallo previo de proyección continúa abierto; una compilación no lo cierra.

## Preferencia visual nueva del usuario — 22/10 15:40
Referencia 1000109243.jpg (1280×687): panel azul x222..1056, y164..477, aproximadamente65% del ancho; usuario quiere esa base algo mayor y más arriba. Objetivo rutinario: +5–6% respecto al panel de referencia, centro unos2% de altura más arriba. Diseño global próximo68% (antes84.6) y margen inferior aumentado, sin letra más pequeña. El texto debe quedar dentro del panel; la imagen evidencia segunda línea sobre el borde. Ajustar y revisar primero en UI Studio. No aplicar compactación adicional a esta muestra base por duplicado.

Prueba de ojo→objetivo no resolvió la incidencia130405: zona0 encaja y zona1 sigue recortada con la misma orientación, así que no se considera fix. Hay diagnósticos durante conversación activa en ray-wide/compact/zone1-diagnostic.txt. Siguiente contraste: posicionamiento absoluto de la unidad con SetUnitPosition frente a SetUnitX/Y, sin modificar MDX ni bibliotecas.

## Resultado de composición y escala elegida — 22/10 15:45

Compositor compartido implementado,34pruebas Node PASS y prueba de controles/guardado en navegador. Pool14tags compilado y contrastado: uniones corregidas con111avances nativos (evidence/native-glyph-metrics.json). Editor muestra páginas, modos por mensaje, guías, ancho útil, presupuesto y zoom. JSON guardado desde UI Studio con ancho68/margen14.4/tamaño2.45 (nativo0.027), siguiendo última imagen del usuario; todos los mensajes de esta muestra usan la escala base, manteniendo compacto como opción. Entrada y referencia nueva conservadas. Ver README/VERIFICACION del componente para contrato y límites.

El marco nativo sigue pendiente: ambas hipótesis (dirección y posicionamiento absoluto de unidad) contrastadas y no resolvieron; se retiró el experimento SetUnitPosition. No continuar cambiando coeficientes sin aislar el transform real del modelo/unidad. La siguiente investigación debe usar capturas+diagnóstico activo y distinguir Z renderizado de altura calculada; no repetir iteraciones de diseño en el juego. Todos los procesos propios cerrados; editor vivo. Fuentes de texto, datos y pruebas listas, sin promoción de la copia a TerrainDev principal.

## Restauración de Camera autorizada — 22/10

Restituir las tres componentes de win2World a Camera.eye, conservar corrección de destroy y cambios ajenos. Medir ojo/objetivo lógico frente al motor y alturas del punto CHECK_DELTAZ/dummy/propietario en copia de diálogo. Corregir calibración o anclaje fuera de win2World según evidencia; no convertir lecturas de cámara renderizada en origen de UI. Después compilar/reextraer ambas copias y probar movimiento, reapertura y dos zonas, inventario/equipo y diálogo con HUD normal. Sin promoción al TerrainDev principal. La partida de usuario anterior ya no existe al inventariar ventanas; ningún cierre realizado.

Restauración implementada y verificada: proyección original; calibración inicial local targetZ-ZOFFSET tras0.1s, usada sólo en campos de cámara. Ambas copias compiladas/reextraídas; diálogo5777003b e inventario d523040e probados. Movimiento, dos zonas/reinicios/rojo/azul/cierre correctos en muestra; residual≈1px, no equivalencia perfecta ni LAN.35tests Node. Capturas de revisión actual en UI Studio; geometría intacta. Evidencias/resultados y límites en work/camera-restore-20261022/RESTAURACION.md. PIDs propios637864/639115/640845 cerrados conS, sinSIGTERM.

## Afinado de precisión autorizado — 22/10/2026

Mantener Camera compartida y sus parámetros originales. Comprobar deriva incremental en setPosition y estabilizar únicamente el adaptador del diálogo usando el desplazamiento ojo/objetivo inicial; comparar diagnósticos en dos zonas y movimiento. Corregir equivalencia de arte y texto en UI Studio con capturas existentes, ampliar muestra compacta en una prueba final consolidada. Registrar exactamente diferencias frente al original y mantenerlas separadas de preferencias de diseño. Ver work/dialogue-fine-20261022.

Afinado implementado: adaptador eye absoluto sin cambiar Camera compartida; residual≤0.001 y borde sin variar de fila en4capturas de movimiento válido.36tests, UI amplio/compacto y comparación50%, arte y nombre ajustados sin alterar JASS. Mapa final ea4073c65837ff39b36376a6f4e4923d569a8fbd44fc2df363e9329d3b9dee45; comprobado SP1920×1080, dos zonas/reinicio/cierre; compacto sóloeditor, fuente aproximada, sinLAN. work/dialogue-fine-20261022/AFINADO.md contiene diffs/constantes y evidencia. Primera serie de movimiento descartada por monitor ajeno; repetición con órdenes nativas y capturas porPID válida;PIDs propios cerrados conS.

## Continuación: bustos y señal
Implementados línea/despliegue/ruido y retratos MDX reales; preferencia final cuerpo fijo, cabeza animada. [Informe vigente](../../TerrainDev/dialogue-system/evidence/RETRATOS-ANIMADOS.md), mapa ce990503…,41tests y prueba1.27b.
