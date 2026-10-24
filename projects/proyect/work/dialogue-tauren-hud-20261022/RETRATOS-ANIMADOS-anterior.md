# Diálogo animado y bustos: entrega del22/10/2026

Mapa final: ce990503fcb35ab0672662d1fd31bf55cd26558ff2a2513d05cf835f2bcb0b46.
Objetivo: Classic1.27b, MDX800, SP1920×1080, unidad móvil y HUD normal.

## Resultado

El marco traza una línea, se despliega y muestra estática en ambos recuadros.
Los bustos están cargados detrás antes de revelar su imagen; la escritura empieza
al terminar el despliegue y se solapa con los300ms de adquisición de señal.
Al cerrar desaparece el texto, entra la estática, se pliega el marco y se retrae
la línea. Un cierre solicitado durante apertura se encola hasta terminarla;
no crea otra unidad ni otro timer. El desmontaje final oculta los tres actores.

Dos pilotos: Paladín y Tauren, copias de _portrait.mdx originales, sin modificar
los recursos de instalación. Ambos muestran cuello y parte superior del torso.
Por preferencia final del usuario: pecho/hombros fijos en la primera pose de
reposo; cuello, cabeza, mandíbula y gestos conservan sus tracks originales de
reposo/habla. No es sincronización labial con sonido. Los IDs congelados y el
perfil están en portrait-registry.json. En el Tauren se retiran antebrazos/manos
y tótem para que las gesticulaciones corporales no invadan las esquinas.

El corte se hace en coordenadas de la pose de referencia; los nuevos vértices
se llevan a bind mediante inversa de su grupo de skin, conservando UVs.
Se comprueban recuentos de faces, validez de índices y límites de la malla posada.
Muestreo de animaciones25ms para márgenes, no prueba matemática continua.
Transform raíz billboard y compresión de profundidad0.02; se conserva profundidad
interna del rostro. La cámara del retrato sirve para preparar la copia, no se
asume que una unidad del mundo aplique automáticamente esa cámara.

## Comparación solicitada: recorte por coordenadas y bordes

| Opción | Viabilidad y límite en este entorno |
| --- | --- |
| Recortar malla antes de exportar | Sí; dividir triángulos contra rectángulo en la pose elegida. El skin posterior puede mover el corte; exige revisar las secuencias. Es el método de las copias actuales. |
| Ocultar automáticamente sólo lo que sale de X/Y durante render | MDX800 no expone una condición espacial por píxel ni shader de clipping propio. GeosetAnim ofrece alfa por geoset, animable por tiempo. Separar cada triángulo y programar alfa oculta el triángulo entero, produce saltos, multiplica geosets y sigue sin cortar la parte que cruza el borde. No adoptado. |
| Marco más ancho/largo | Viable como geometría opaca delante del retrato, con depth test/set activos. Hacia dentro reduce el área útil; hacia fuera tapa más escenario. Transparencia exterior del PNG no actúa como máscara. No se ensanchó el arte final: el usuario eligió mantener torso fijo y cabeza animada. |

Elección vigente: bustos recortados, pose corporal fija, encuadre por personaje y
cobertura opaca del marco actual. Bordes adicionales quedan como recurso si un
personaje nuevo lo necesita; no sustituyen corregir una malla deformada. En el
perfil actual la abertura mide aproximadamente24.36×18.95unidades del plano.
El Tauren final muestreado ocupa X[-11.867,12.125],Y[-9.898,8.030]; su corte inferior
queda bajo el borde. Paladín X≈[-12.5,12.5],Y[-11,4.964]. Los límites se refieren al
plano de cada busto antes de la escala de unidad; no son píxeles de pantalla.

Fuentes primarias contrastadas: copia local de Blizzard Art Tools,
work/dialogue-portrait-eval-20261022/art-tools.txt, líneas87–112 y193–244;
https://raw.githubusercontent.com/flowtsohg/mdx-m3-viewer/master/src/parsers/mdlx/geosetanimation.ts
(alpha/color por geoset) y
https://raw.githubusercontent.com/flowtsohg/mdx-m3-viewer/master/src/parsers/mdlx/layer.ts
(flags de profundidad). El PDF web no abrió por tipo de contenido; copia local
leída. La ausencia de recorte nativo es el alcance de formato/API Classic
inspeccionados; no se estudiaron modificaciones del motor.

## UI Studio y contrato

http://127.0.0.1:4317/ → Conversaciones. Renderiza los MDX/BLP reales del marco y
bustos, con el visor local5.12 y licencia incluida. Sin scissor de retratos:
se ven las salidas que exceden el marco; el arte opaco cubre su superficie.
Fondo de terreno/HUD es una captura histórica, no una partida en vivo.

Controles: modelo Paladín/Tauren, escala0.5..1.4, desplazamientos±5, reposo/habla/
automático, abrir/cerrar/pausar/reiniciar y selector de fase con instante10ms.
Tiempos compartidos en JSON:150ms línea,200despliegue,300adquisición,300pérdida,
150plegado y150retracción. Cada duración10..2000ms, múltiplo de10.
Las imágenes cargadas son sólo diseño: el exportador del mapa exige un modelo
registrado. No hay sustitución dinámica de umdl en una unidad1.27b existente.

Registro de actores/rawcodes dpa0,dta0; frame dlog. Unidades visuales reutilizadas,
colisión/interacción desactivadas; un timer10ms y pool14texttags. No efectos por
letra. Camera compartida conserva SHA
fde7cb040982ed99b2986e34513c62b4f3d58e1edc6f74237be37f4162d2caae.

Para regenerar recursos desde los originales conservados:

```bash
/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python tools/portrait-assets.py
node tools/portraits.cjs
python3 build.py
```

Para cambiar sólo JSON ya registrado, basta build.py (prepara story y frame).
El JSON del editor se guarda/exporta; no reconstruye automáticamente el mapa.

## Verificación y evidencia

41/41tests Node, sin fallos: work/dialogue-animated-20261022/ui-tests-bust.log.
JassHelper release/pJASS y reextracción/preservación de miembros/cabecera pasan.
MDX/MDL revisados por lectores independientes y checks de corte/curvas faciales.

En el mismo directorio work: editor-body-stand.png muestra la última vista UI
recuperada; stand-left-talk-0..3, stand-right-talking y stand-moving muestran el
último mapa. La revisión744544ae de la misma sesión conserva safe-opening-*,
safe-close-*, safe-zone0/1, safe-queued-closed-final y safe-reopen. Comparación
revision-diff.json: sólo cambia paladin.mdx y metadatos(attributes) entre ambas;
JASS, frame, Camera y Tauren son idénticos. safe-frame-measurements.json mide la
fila735 del borde inferior en cinco capturas de movimiento de esa revisión.
No usar safe-blue-talk.png para acreditar azul: era la segunda página roja;
el azul real está en safe-left-speaking.png. safe-queued-close.png contiene la
línea de cierre, no el estado cerrado; éste lo prueba safe-queued-closed-final.

PIDs propios690900,693094,694405,702911,704240,706399 y708387 cerrados; final708387
salió con confirmaciónS, sinSIGTERM. Identidad por PID/inicio/prefijo/hash y
ventana guardada para cada prueba. No se cerraron partidas ajenas.

Sin acreditación de LAN, otras resoluciones, compacto nativo de esta revisión,
sesiones largas o roundtrip NewGen. Tipografía web aproximada. Sólo dos pilotos;
otros modelos requieren preparar su busto y revisar todas las poses elegidas.
El instante de teletransporte de desarrollo conserva incidencia separada abierta:
../../../informes/errores/2026-10-22-185821-dialogo-teletransporte-visibilidad.md.

CodeGraph: consultas antes/después en dialogue-system y ui-studio/dist; fuentes
nuevas vigentes, sin DISABLED/RECOVERING. El índiceJASS conserva completeInputs=false
y LoadN.execute como dispatch candidato; el compilador/motor se ejecutaron aparte.
Assets, builds/evidencia y vendor no acreditan cobertura semántica del grafo.

Incidencias recuperadas en informes/errores/resueltos/:182141(modelo),180241(recursos),
175058(ayuda),190100(vista del navegador). Los errores se conservan como historial;
no se presentan como resultados correctos de las revisiones intermedias.
