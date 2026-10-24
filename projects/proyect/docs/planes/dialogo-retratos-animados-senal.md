# Diálogo: línea, despliegue, señal y retratos animados

Fecha: 22/10/2026. Estado: implementado y contrastado en editor/Classic1.27b; límites y detalle de teletransporte documentados.
Continuación de [UI Studio y diálogo](dialogo-ui-studio.md).

## Objetivo y base

Reproducir la apertura/cierre de la referencia Mega Man: línea que se extiende
desde el centro, despliegue vertical, estática y adquisición/pérdida de señal en
ambos retratos. Evaluar retratos originales de Warcraft con reposo y habla,
configurables por personaje. Prioridad del usuario: iterar en UI Studio y hacer
una prueba final consolidada en Classic 1.27b, sin modo cinemático.

Base conservada: TerrainDev/dialogue-system/TerrainDev-Dialogue.w3x,
SHA256 ea4073c65837ff39b36376a6f4e4923d569a8fbd44fc2df363e9329d3b9dee45.
Camera compartida, SHA256
fde7cb040982ed99b2986e34513c62b4f3d58e1edc6f74237be37f4162d2caae.
La evaluación inicial no modificó producción. La implementación posterior está en el informe vigente al final de este documento.

## Lo observado en el nuevo vídeo

Entrada: /home/snz/Vídeos/recording_2026-10-22_17.45.26.mp4,
1920×1080, 10.773333s; SHA256
bc97dcf04a14ea983da7262cc94f90c82961b8f078cde6c18741d36dad0e98d0.
Es una grabación de la referencia Mega Man en un reproductor, no una prueba de
Warcraft. Los tiempos siguientes corresponden a la grabación, no acreditan el
reloj interno del juego de referencia. Muestreo de detalle a20fps: resolución
temporal aproximada50ms, con posible desfase de selección de fotograma.

| Tiempo aproximado | Observación |
| --- | --- |
| 5.40–5.50s | Línea horizontal crece simétricamente desde el centro hasta el ancho final. |
| 5.55–5.70s | Se despliega verticalmente el marco; ambos retratos contienen estática. |
| 5.70–6.00s | Comienza nombre/texto mientras disminuye la estática y aparecen los rostros. |
| 8.70–9.00s | Desaparecen nombre/texto; la estática sustituye gradualmente ambos rostros con el panel aún abierto. |
| 9.05–9.15s | Marco y recuadros se comprimen verticalmente hasta quedar una línea. |
| 9.15–9.35s | La línea se contrae hacia el centro y desaparece. |

La escritura se solapa con el final de adquisición de señal. El cierre no es
sólo ocultar el panel ni una contracción instantánea. No es necesario deducir
la técnica original para reproducir su resultado con un plano MDX800.

Evidencias en ../../work/dialogue-portrait-eval-20261022/:
new-overview.png, new-opening-detail.png, new-closing-detail.png,
opening-crop.png y closing-crop.png. Las hojas se leen por filas, de izquierda
a derecha. opening-crop empieza en5.35s y closing-crop en8.65s, ambas20fps.
La grabación anterior12.40.44 confirma la apertura, pero no mostraba el cierre.

## Evaluación inicial: estado técnico de partida

CodeGraph consultado con projectPath de diálogo para ConversationUI.j,
tools/model.cjs y build.py; también las raíces de inventario y UI Studio para
el ejemplo de modelos y dialogue-core.js/dialogue-editor.js. Las fuentes
devueltas son las actuales. JASS conserva completeInputs=false: el grafo no
sustituye compilación ni pruebas de motor.

El modelo actual tiene4quads (marcos rojo/azul y dos imágenes de retrato),
1hueso billboard y secuencias Stand, Stand Alternate, Birth y Death. Birth/Death
sólo cambian altura0.08↔1 en180ms: falta el trazado/retracción horizontal de la
línea y falta la estática. Los textos son independientes, con pool14texttags.

El ejemplo nativo de equipo registra modelos enteros y los añade como efectos
al dummy. No demuestra control de animación del efecto en1.27b. Para controlar
un retrato por SetUnitAnimationByIndex, la propuesta es asignarlo como modelo
propio de una unidad visual, sin colisión/interacción, proyectada por la misma
Camera del panel. No se propone cambiar Camera.win2World ni sus constantes.

En Classic1.27b no se dispone de un SetUnitModel genérico para cambiarlo en
ejecución: el builder ya genera dlog con umdl en war3map.w3u. Los actores deberán
tener tipos/rawcodes propios generados al construir, uno por modelo registrado;
el registro conserva ruta del recurso y rawcode generado. Elegir un personaje
en el editor no significa que cualquier MDX pueda cargarse dinámicamente en una
unidad existente dentro de la partida.

## Retratos originales inspeccionados

Copias extraídas con prioridad de parches de los archivos locales1.27b;
originales intactos. Procedencia/hashes en portrait-provenance.json y estructura
en portrait-models.json, dentro de la carpeta de evidencias anterior.

| Modelo | Estructura | Reposo | Habla |
| --- | --- | --- | --- |
| HeroPaladin_portrait.mdx | MDX800;241vértices,21huesos,3geosets,1cámara animada | índices1,2,3: Portrait | índices4,5: Portrait Talk |
| Tauren_portrait.mdx | MDX800;404vértices,24huesos,3geosets,1cámara animada | índices1,2,5: Portrait | índices3,4: Portrait Talk |

Sus cámaras, posiciones de geometría e índices difieren. Tauren incluye un quad
auxiliar de gran extensión y textura replaceable; su apariencia y necesidad
deben comprobarse visualmente antes de retirarlo. No se ha reproducido aún la
deformación completa ni importado estos retratos en el juego para este uso.

La documentación original de Blizzard Art Tools describe _Portrait.mdx,
cámara de retrato y secuencias Portrait/Portrait Talk. Copia local art-tools.pdf
y texto art-tools.txt, sección Optional: Creating Model Portraits.
Fuente: https://xgm.guru/files/100/344093/comments/545702/Warcraft_III_Art_Tools_Documentation%5Ben%5D.pdf

## Decisiones de diseño propuestas

1. Separar marco, dos actores de retrato y dos superficies acotadas de estática.
   La línea es geometría independiente: crece en ancho antes de desplegar el
   marco y se contrae después de plegarlo. Un solo reloj controla las fases.
2. Usar originales _Portrait.mdx como punto de partida. Perfil por personaje:
   recurso/identidad, rawcode generado, secuencias de reposo/habla, escala,
   desplazamiento, orientación y márgenes seguros. Los índices se obtienen del
   archivo concreto; no compartir un índice fijo entre personajes.
3. Cámara de retrato original como referencia de encuadre. Asignar el modelo a
   una unidad del mundo no aplica automáticamente esa cámara. Preparar copias
   adaptadas con transform raíz y composición estable respecto a la Camera UI;
   conservar huesos/animaciones y comprobar la secuencia entera.
4. Habla durante revelado del texto, reposo al completar/esperar; permitir reposo
   durante pausas largas. Cambiar interlocutor/reiniciar/cerrar cancela el estado
   anterior. Esto no acredita sincronización labial con audio.
5. Ajustar primero escala/posición para contener pelo, orejas y cuernos en todas
   las poses elegidas. El borde del marco por sí solo no recorta un modelo3D.
   El scissor del visor web tampoco acredita recorte en Warcraft. Si el modelo
   no cabe, editar una copia específica (fondo, torso o accesorios irrelevantes)
   y revisar visualmente; no recortar partes importantes de la cabeza por defecto.
6. Si el encuadre3D no permite el acabado elegido, evaluar como alternativa un
   atlas animado prerenderizado del retrato sobre quad: recorte rectangular
   determinista, a costa de flexibilidad3D. Máscaras con profundidad siguen sin
   validar; no comprometer la implementación a esa hipótesis.

## Contrato temporal y entregables

Estados propuestos: CLOSED → LINE_OPEN → UNFOLD → ACQUIRE → DIALOGUE →
SIGNAL_LOSS → FOLD → LINE_CLOSE → CLOSED. ACQUIRE permite iniciar escritura antes
de terminar la desaparición del ruido, como en la referencia.

Perfil inicial para ajustar en UI Studio, no medición exacta del original:
línea150ms; despliegue200ms; adquisición300ms; escritura al acabar despliegue;
pérdida300ms; pliegue150ms; retracción150ms. Exponer estos tiempos en un contrato
serializable compartido; el reloj nativo10ms debe cuantizarlos explícitamente.
Una transición nueva invalida la anterior; no acumular timers ni actores al
repetir comandos. Cierre inmediato seguro es necesario al desmontar la vista.

### Fase1 — referencia reproducible en UI Studio

Ampliar dialogue-core.js, dialogue-editor.js y dialogue.css con reloj/controles
de fases, línea, ruido y revelado; conservar JSONv1 mediante campos opcionales
con valores predeterminados. Ruido acotado a los recuadros, generado desde una
secuencia/atlas reproducible. Pausar, reiniciar, abrir y cerrar en el editor;
mostrar instante/estado y permitir revisar fotogramas. El JSON guardado es la
entrada del exportador, no un segundo conjunto manual de tiempos.

### Fase2 — piloto de retratos reales

Paladín y Tauren cubren un rostro habitual y uno con cuernos. Integrar visor MDX
real en el editor o un preview prerenderizado claramente identificado; nunca
simular habla escalando una imagen y atribuirlo al MDX. Vista con rectángulo
seguro y opciones de encuadre por perfil. Validar secuencias, texturas,
replaceables, materiales y cámara. Decidir encuadre3D o atlas según evidencia.
El método de recorte nativo es una puerta de validación, no un hecho resuelto.

### Fase3 — modelo y copia de diálogo

Extender tools/model.cjs para línea/ruido y los estados necesarios; evitar
alterar la geometría final del marco durante reposo. Extender tools/story.mjs
para consumir contrato/registro, generar datos JASS e importar sólo recursos
necesarios. build.py genera tipos visuales con umdl y rawcodes sin colisiones.
ConversationUI.j proyecta todas las piezas por Cam.win2World, controla estados
y actores propios, preservando HUD, unidad móvil y los14tags existentes.

### Fase4 — verificación

Primero editor: abrir/cerrar, pausas, completar, cambio de actor, reinicio a mitad
de transición, amplio/compacto, guardado/migración y secuencias completas de ambos
retratos. Suite Node existente y pruebas del contrato temporal/integración;
comprobar instantes límite e interrupciones, sin pruebas que copien el código.
MDX800 relectura independiente y comprobación de dependencias/BLP.

Después JassHelper/pJASS, preservación/reextracción de miembros y una sesión
consolidada1.27b: ambos actores, habla/reposo, cierre/reapertura repetidos,
movimiento y dos zonas. Comparar capturas con UI Studio y documentar diferencias.
No acreditar LAN, otras resoluciones ni clipping3D antes de ensayarlos.

## Continuidad

La evaluación dio paso a las fases implementadas documentadas al final. Hallazgo documental inicial:
dialogueNotes aún avisa de una incidencia de proyección ya resuelta; corregir
su ayuda antes de entregar la siguiente versión del editor. Ver
[informe](../../informes/errores/resueltos/2026-10-22-175058-ui-studio-ayuda-proyeccion-antigua.md).

Fallos auxiliares de lectura recuperados:
[informe resuelto](../../informes/errores/resueltos/2026-10-22-174500-evaluacion-portrait-lecturas.md).

## Implementación y decisión final

Fases1–4 realizadas. El usuario eligió cabeza/cuello/rostro animados y torso fijo
en una pose de reposo para ambos pilotos, en lugar de ampliar el marco.
El recorte espacial automático no está expuesto por MDX800; el builder prepara
mallas y el marco opaco cubre el margen. Ver
[entrega/contrato/verificación](../../TerrainDev/dialogue-system/evidence/RETRATOS-ANIMADOS.md).
Último mapa ce990503…,41tests Node PASS, JassHelper/pJASS y contraste nativo con
partida cerrada. Recursos/jerarquía/ayuda/vista del navegador recuperados. No
acreditaLAN/otrosformatos ni cada instante de teletransporte de desarrollo.

## Actualización autorizada: cuerpo original, tótem y variantes
22/10/2026: el usuario reemplaza la decisión de torso fijo. Conservar movimiento original del cuerpo, brazos y tótem; ensanchar/rediseñar bordes interiores si algún gesto sobresale. Añadir todas las variantes originales Stand/Portrait de reposo (excluir Base/Portrait Talk al escoger reposo), con duraciones reales.
Trabajo: (1) generar recursos completos y registro de variantes, paletas locales <=256; (2) alternancia determinista por duración en UI Studio y JASS usando el mismo registro; (3) inspección del ciclo completo en UI, ajustar borde cuando haya evidencia de desborde; (4) compilar/reextraer y sesión consolidada Classic1.27b con referencia HUD original; cerrar partida propia. Estado: fase1 en curso. Evidencia work/dialogue-tauren-hud-20261022. Se mantiene Camera compartida intacta y no se activa cinemática.

Avance20:54: fases1–3 implementadas,45tests Node; profundidad gris corregida en motor. Fase4 abierta: discrepancia de reposo nativo; NonLooping0, clipStand1 estático excluido, nombresStand descartados. Aislamiento por índice/TimeScale1 antes de nuevas hipótesis. Ver informe vigente y work/dialogue-tauren-hud-20261022.

## Cierre de la revisión de cuerpo/variantes y transición

2cb340db,22/10: exportación completa y variantes móviles implementadas. Orden
SEQS cronológico corrige reproducción nativa; uble0.20 sólo en actores suaviza
Talk→Stand.47tests Node, JassHelper/pJASS/reextracción y contraste nativo; vídeo
real95.7s de pausa parcial/Stand, interacción, patrulla y cierre. Proceso propio
terminado. La fase nativa de esta revisión queda comprobada para dos pilotos
SP1920×1080; no equivale a completar toda la matriz futura de formatos/LAN.
Pendiente específico: comprobar visualmente la mezcla nueva en UI Studio cuando
se recupere IAB (tab7 falló al crearse); los tests de interpolación sí pasan.
No sustituir esta limitación por el screenshot del editor anterior al blend.
Ver latest-game-test.json y evidence/RETRATOS-ANIMADOS.md para evidencia y límites.
