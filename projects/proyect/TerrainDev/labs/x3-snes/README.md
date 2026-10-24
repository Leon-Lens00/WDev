# Laboratorio SNES: Mega Man X3

Ensayo completo de la ROM del usuario, original USA y Zero Project IPS V4.1, ejecutado en MesenCE 2.2.1 sobre CachyOS. Todo el material de esta actividad está en esta carpeta. El original de Descargas se conserva y el mapa Warcraft sigue en su revisión anterior.

## Resultado

Seis casos finales: dos variantes, derecha/izquierda con intervalo 12, y derecha con intervalo 20. Cada caso recorre640 fotogramas desde un estado propio de su ROM; se observaron6 fusiones y30 cuerpos combinados. **1220 actualizaciones de vuelo,4880 valores de X/Y/vx/vy cotejados,0 diferencias** frente a las rutinas aisladas de la evaluación previa. Los seis terminan sin cuerpos relevantes activos y con proceso cerrado. Resultado: [native-comparison.json](analysis/native-comparison.json).

| Medición | Original USA | Zero Project IPS V4.1 |
|---|---:|---:|
| Encuentro → aparición de los cinco cuerpos | 18 fotogramas,~0.29951s | 8 fotogramas,~0.13311s |
| Encuentro → primer movimiento de esos cuerpos | 19 fotogramas | 9 fotogramas |
| Retroceso de pareja1 | 60.53125px | 0px |
| Retroceso de pareja2 | 45px | 10.5px |
| Recolocación de la unión, caso derecha/intervalo 12 | -20px | -12px |

La recolocación toma la coordenada entera del segundo pulso y conserva la fracción del portador. Su magnitud depende del encuentro: intervalo 20 dio-27px en ambos; no debe convertirse en una constante de retroceso. A izquierda se refleja la dirección, con diferencias de redondeo/posición de origen. Después, los satélites tienen su propio retroceso/aceleración: son fases distintas.

Cadencia calculada desde masterClock y frameCount del emulador:~60.098806fotogramas/s. El hecho de ejecutar en modo rápido en el PC no cambia esa escala temporal de la ROM. La transición de18/8 frames se repitió en los tres casos de cada variante.

El portador helicoidal crea **tres slots hijos** y las trazas muestran subtipos1,2,3 con fases diferentes. La representación Warcraft actual de dos orbes es una adaptación, no una copia exacta de esos slots. La prueba tardía de intervalo 30 dejó escapar el precursor de pantalla antes de la unión; no se forzó artificialmente un encuentro.

En los casos de intervalo 12 la unión puede ocurrir durante la animación/crecimiento del segundo pulso, antes de entrar en su fase de desplazamiento recto. En intervalo 20 sí se observaron4 actualizaciones de esa fase a8px/paso. No reducir todo el criterio de unión a que dos centros geométricos se alcancen.

## Organización

- `runtime/`: ejecutable portable, bibliotecas extraídas, settings, datos propios y rutas XDG. [Recibo de instalación](runtime/install-receipt.json).
- `scripts/`: launcher Python, preparación/observación Lua, comparación y vídeo. Es la única raíz nueva indexada en CodeGraph;5 fuentes actuales. No indexa binarios, ROMs, upstream ni resultados. La fuente estática anterior se conserva como evidencia en analysis.
- `runs/final-*`: seis ensayos acreditados con CSV, entradas, capturas representativas, copia exacta de escenario Lua y sus hashes. Las dos variantes gap20 conservan los322 PNG fuente del vídeo.
- `runs/ready-original-fixed/ready.mss` y `runs/ready-mod/ready.mss`: estados independientes preparados desde cada arranque, sin cruzarlos entre ROMs.
- Resto de `runs/`: logs y evidencia de preparación/controles previos. Los PNG de vídeo redundantes se retiraron; no se borraron los CSV ni las evidencias de incidencias.
- `analysis/static-20261023-134543/`: estudio anterior trasladado íntegro, incluidas copias privadas de ROM. El enlace histórico desde reports conserva sus rutas sin duplicar datos.
- `upstream/`: metadatos oficiales y fuente de consulta fijada a la release; no se ejecuta como herramienta ni se indexa.
- `tmp/` y `runtime/tmp/`: vacíos al cierre.

Limpieza: [recibo](analysis/cleanup.json),2095 archivos/directorios prescindibles retirados,56120955 bytes liberados. Se retiraron los cinco helpers concretos /tmp/x3-* de la investigación anterior y tres fuentes piloto Lua sustituidas por prepare_scene/trace. No se tocaron temporales ajenos, archivos del usuario ni evidencias Warcraft.

## Vídeo

[Comparación original / Zero Project](analysis/comparacion-original-zero-project.mp4):2.679 s,161 fotogramas por variante,1536×760, H.264, sin audio ni interpolación. Misma línea temporal de botones, diferencia de velocidad/transición conservada. Escalado por vecino más próximo para ver píxeles. [Recibo y hashes](analysis/video-receipt.json),[muestra](analysis/video-muestra.png).

## Procedimiento y reproducción

MesenCE 2.2.1 Linuxx64, commit `20ba206cef5ba207c21203176d02cb9f43dda9fb`, descargado de [release oficial](https://github.com/nesdev-org/MesenCE/releases/tag/2.2.1). ZIP SHA256 `c88ff4d251b407515c43d3332d641927655cd69fb538996b6a21da4509dbb58f`, cotejado con el digest publicado antes de extraer; el ZIP se eliminó al terminar. Binarios/settings quedan junto al emulador; no hay instalación global. `HOME` se conserva. Se acotan TMPDIR y rutas XDG dentro de runtime. Lua propio tiene IO local para evidencias y red deshabilitada.

La preparación entra por Start/B en la introducción y espera hasta X quieto, control libre, cámara estable. El estado se crea dentro de un callback de ejecución real en$008103. El ensayo carga el estado de su propia ROM y activa una sola vez el bit de mejora del buster: original$1FD1|2; mod$1FD1|2 y$F418|2. Las escrituras se registran en equipment-preparation.txt. Después sólo hay entrada de mando y lecturas de observación: **no se escriben posiciones, velocidades, carga, estados de disparo ni rutinas**.

Se mantiene Y durante420 fotogramas para cargar completamente ambos disparos. Soltar el primero y pulsar Y tras12/20 fotogramas produce los casos acreditados. El intento inicial de200 fotogramas sólo tenía la carga parcial necesaria para la hélice; no acredita una secuencia completa de dos disparos. Registros definitivos usan$0A30,$0A66,$0A67; las etiquetas de carga de los primeros pilotos eran exploratorias.

Desde esta carpeta, usando un nombre de ensayo nuevo:

```sh
python3 scripts/run_lab.py original trace nueva-original --gap 12
python3 scripts/run_lab.py mod trace nueva-mod --facing left --gap 12
python3 scripts/analyse_trace.py
python3 scripts/render_video.py
```

El comparador acredita los seis `final-*` conservados, no cualquier ejecución nueva por su nombre. El launcher conserva una copia de cada escenario y registra hash, parámetros, PID/inicio, ROM y cierre; el nombre debe permanecer dentro de runs. En un laboratorio limpio se pueden regenerar los estados con `prepare_scene` y nombres `ready-original-fixed` / `ready-mod`. No sobrescribe una ejecución existente.

CodeGraph propietario: `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/labs/x3-snes/scripts`. Consultas MCP previas/posteriores sobre run_lab, prepare_scene, trace/log_event/load_ready, analyse_case y render_video. [Respuesta final](analysis/codegraph-final.json). Python y Lua estructurales; no hay aristas hacia las rutinas ROM ni validación de hardware por el grafo.

## Cobertura, límites y continuidad

Esto acredita ejecución **emulada del juego completo** en su núcleo SNES/CX4, con capturas generadas por el emulador y datos observados de sus objetos. No es la ejecución aislada anterior ni una prueba en hardware físico. Se cubre una escena sin enemigos, un equipo y los intervalos/sentidos indicados; no son pruebas exhaustivas de impactos, daño, niveles o entradas. No se ensayó la interfaz gráfica de MesenCE: se usó su modo oficial --testRunner, sin cambiar el foco del escritorio.

El mapa Warcraft permanece SHA256 `ad594a94d93592d0bdb0a90d38cad420deed8b92ac67179891519b3c16bdc7f1`, perfil GIF0.2.0. No se implementó todavía el port exacto original/mod. La continuación debe tratar por separado recolocación de unión, fase18/8 frames, creación de cinco cuerpos, tablas discretas de la hélice y vuelo combinado, manteniendo los contratos propios de colisión/vida de Warcraft.

[Procesos propios cerrados](analysis/closure.json). [Incidentes de bootstrap recuperados](../../../informes/errores/resueltos/2026-10-23-140432-x3-mesen-cierre-script.md). Los avisos del depurador sobre lecturas de RAM no inicializada durante arranque se conservan en los logs; por sí solos no se presentan como defectos del juego.
