# Shots Vol. I: anclaje frontal y pack de colores

Fecha: 2026-10-22. Objetivo autorizado: ajustar las seis variantes simples y seis Double de Vinz, preservando originales, y preparar un pack aparte para los colores de jugadores de Classic 1.27b. El usuario pide evaluar color de equipo automático y si cubre todos los efectos antes de escoger método.

## Base y contrato

Entradas: descargas/warcraft3/misiles/vinz/shots-vol-i/manifest.json y originales. Diagnóstico: work/shots-vol-i-origen-20261022/mediciones.json. Punta Stand en X=48.423839569; cuerpo y sus emisores de vuelo se deben anclar frontalmente. Double conserva separación entre las dos puntas. Impactos y luz se revisan de forma separada; no aplicar una traslación global indiscriminada. Mantener intervalos y deformación interna, geometría relativa, materiales/emisiones/sonidos del pack de anclaje.

Destino: MDX800, juego 1.27b, 12 playercolor (0..11), confirmado contra common.j Classic. Los 24 colores de parches posteriores quedan fuera del objetivo. Color visual por playercolor, no asumir equivalencia entre ID de jugador, equipo/alianza y color reasignado.

## Fases

1. Preparar tooling reproducible en ModelEditor/src y su índice CodeGraph mínimo, excluyendo assets/evidencias/exports. Leer capacidades locales de escritores, emisores y material. Estado: completado.
2. Generar pack de anclaje en exportación nueva: desplazar sólo la estructura del cuerpo/vuelo y compensar su transición Death; mantener emisores de impacto en origen. Validación numérica por secuencia y relectura independiente. Estado: completado dentro de la cobertura descrita en ModelEditor/VALIDACION.md.
3. Evaluar prototipo teamcolor con geometría/materiales/partículas frente a alternativas fijas. Extraer la paleta y texturas de la instalación objetivo; no confundir tintado con sustitución nativa de textura. Elegir método por identificación de equipo, conservación visual y control disponible en 1.27b. Estado: completado dentro de la cobertura descrita en ModelEditor/VALIDACION.md.
4. Crear pack separado con MDL/MDX y dependencias, colores documentados y asignación compatible con GetPlayerColor. Preparar comparación visual y un mapa de prueba separado si el entorno lo permite. Estado: completado dentro de la cobertura descrita en ModelEditor/VALIDACION.md.
5. Verificar fuentes intactas, paquetes completos, imports y modelo en juego en escalas diferentes; documentar resultados y límites sin extrapolar multijugador. Estado: completado dentro de la cobertura descrita en ModelEditor/VALIDACION.md.

Aceptación: punta geométrica Stand en plano X=0 dentro de tolerancia 1e-3; ausencia de adelanto geométrico en Birth por muestras/controles analíticos pertinentes; Death y puntos de impacto coherentes; colores de cuerpo, brillo, partículas y luz contrastados; originales por SHA256 intactos. Un verificador de archivos o visor no sustituye el ensayo en Warcraft.

Índice nuevo: ModelEditor, sólo herramientas JavaScript y sus pruebas; no expande ni acredita el JASS generado dentro de strings. Dependencias externas en la recuperación Slendytubbies se leen directamente; no se indexan ni se copian para aparentar cobertura.

## Resultado — 22 de octubre

Método elegido: doce variantes fijas que conservan las máscaras; 24 MDX simples/Double, tres BLP compartidas y resolver GetPlayerColor validado con pJASS. Pack de anclaje separado con 12 MDX. Archivos/poses verificados y ensayo visual en 1.27b (mapa c y capturas conservadas). No se integró en la biblioteca del mapa ni se acreditan física/colisiones, FPS o LAN. Las luces se contrastan estructuralmente, sin medición fotométrica. Detalles, incidencias y límites en ModelEditor/VALIDACION.md.
