# Port ROM X3 a Warcraft III Classic 1.27b

## Objetivo y base

Implementación autorizada por el usuario23oct2026. Dos perfiles originales separados, USA y Zero Project IPSV4.1, dentro de TerrainDev; conservar compatibilidad GIF para pruebas/regresiones. Base mapa ad594a94…,17bibliotecas. Laboratorio fuente: labs/x3-snes,6casos completos/4880valores/0discrepancias. Un solo escritor y carpeta de evidencia reports/current-x3.json. No cambiar Missile, Recycler, RapidFire o GroundMotion ni los modelos.

## Diseño y límites

- Nueva X3Kinematics pura: escala2u/px, cadencia60.098806, integración discreta e interpolación lineal entre puntos nativos. Hélice0.5px/paso, aceleración8/256→64/256 a16pasos, límite almacenado5 tras movimiento; tres componentes con offsets y tabla16fases. Pulso recto8px/paso y fase inicial; núcleo y cuatro satélites con sus parámetros originales/mod.
- X3Buster conserva fire() GIF por compatibilidad e incorpora fireProfile(...,profile). Demo W/E usan original y R usa superdisparo Zero Project. Un perfil queda fijado por cast, sin cambiarse al modificar la demo.
- Hélice nativa con3 cuerpos visuales usando recursos existentes. Virtual carrier sin handle adicional. Proyección del eje vertical SNES a perpendicular XY de la dirección de Warcraft; altura visual70. El vuelo no copia daño/colisión de SNES.
- Fusión nativa por ventana de alcance, después de la fase inicial del pulso; conservar prioridad temporal frente a colisiones. Recolocar al pulso, retirar cuatro precursores, mostrar flash y esperar18/F u8/F antes de emitir cinco cuerpos. La formación es estado propio cancelable y su timer tiene propietario único. No crear cinco modelos visibles congelados durante la espera.
- Mantener filtros y barridos GroundCollision del mapa. Cierre de origen/caster/vida, bordes y colisión en retroceso/cruce. No prometer hardware SNES, imagen idéntica o multijugador.

## Fases y aceptación

1. Modelo puro y oracle independiente: generar muestras JASS desde CSV reales, no desde otra implementación de las ecuaciones. Cotejar en motor posiciones/velocidades de vuelo y hélice con tolerancia explícita.
2. Integrar perfiles/tercer orbe/fase de formación/objetos y demo. Ampliar manifiesto y Main con el orden de dependencias real.
3. JassHelper+pJASS y reextracción WCT/JASS/imports; nueva copia de mapa. Regresión GIF69, colores40 y Rapid44 conservados; laboratorio nativo adicional de vuelo, fusión, formación/cancelación y limpieza.
4. Ejecutar en1.27b con perfil propio y cierre por identidad. Revisar imagen de ambas variantes. Preservar fuentes/evidencias y consolidar documentación vigente sin trasladar PASS anteriores al cambio.

## Estado

Completado y probado localmente23oct2026. Producciónf087047bff8c…;18bibliotecas y35imports visuales,15bibliotecas previas sin cambios. W/E USA, R Zero Project4.1, API GIF conservada.

- JassHelper/pJASS, reextracción exacta JASS/WCT/WTG, objetos y recursos: PASS en reports/20261023-144114-703534.
- Flujo final20261023-145909:69GIF+40colores+44RapidFire+39nativas=192controles/0fallos.5259valores observados en CSV nativos cotejados dentro del motor, tolerancia0.012u,0discrepancias.22controles negativos rechazados por los evaluadores.
- Nativo86creados/86retirados, cero casts/cuerpos/flashes. Formación18/8frames, tres componentes, parejas separadas, cancelación/muerte, órdenes E/R e impactos de avance/retroceso comprobados. Ambas variantes revisadas visualmente; demostración local en el informe.
- Incidencias del laboratorio resueltas: nombres privados de JassHelper y blanco colocado fuera del eje de un emisor desplazado por CreateUnit. La última no necesitó cambiar la física. Diagnósticos y recuperación conservados en informes/errores/resueltos y enlazados desde el resultado.
- CodeGraph MCP volvió a consultar ambas raíces tras los cambios; evidencia codegraph-final.json. Relaciones estáticas parciales, proyecciones de módulos y unidad incompleta no sustituyen pruebas.
- Cuatro procesos propios cerrados, recibos de salida0 e inventario fresco sin ventanas/procesos propios. Primeros tres con confirmación+S; el último ya estaba cerrado al retomar y se verificó por identidad. Se preservaron fallos/historia y eliminaron sólo dos fotogramas temporales de inspección.

Resultado central: reports/x3-rom-port-20261023-143455/result.json. Estado vigente: reports/verification.json. Sin carga por mantener tecla, multijugador, nuevo guardado en editor ni benchmark de rendimiento. Missile sigue32Hz; el port de posiciones nativas no aumenta el render a60Hz.
