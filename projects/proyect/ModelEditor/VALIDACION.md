# Validación de Shots Vol. I

Fecha: 22 de octubre de 2026. Destino: Warcraft III Classic 1.27b, MDX800. Estado más fuerte: **Tested in map**, para los escenarios visuales descritos abajo. No es una certificación de un sistema de colisiones ni de multijugador.

## Resultado y decisión

Se entregan dos packs: doce derivados de anclaje con los seis colores originales y veinticuatro variantes de jugadores (doce simples y doce Double). La variante fija preserva las máscaras de estrellas y demás partículas. El prototipo TC funciona con unidades roja/azul, pero sustituye esas máscaras por TeamGlow; su luz sigue teniendo color propio en el archivo. Por eso se eligieron variantes fijas con selección al lanzar mediante GetPlayerColor. El helper Classic se validó con pJASS, sin integrarlo en una biblioteca de misiles existente.

## Archivos y geometría

- Los trece archivos fuente descargados coinciden con sus SHA256. Base del mapa de ensayo conservada intacta; hash en `build/visual-20261022c/fixture.json`.
- 36 MDX reabiertos completamente sin diferencias después de escritura binaria; segundo lector war3-model y compañeros MDL contrastados. Sólo en la comparación textual se normalizan bits de tipo implícitos (Light 512, PE2 4096) y orden de tracks por tag; el MDX conserva los flags originales.
- 11628 poses a paso de 5 ms más claves. Error máximo frente al desplazamiento esperado: 0.000002981; discrepancia de evaluadores: 0.000000209. Punta máxima Birth/Stand: X=0.
- Birth tiene comprobación continua adicional: las posiciones locales previas a la escala padre son lineales con extremos no positivos y la escala padre es no negativa. El cuerpo no puede adelantar el plano frontal entre muestras. Se verificaron las hipótesis concretas de estas curvas y grupos.
- Double conserva las puntas laterales y alinea su plano frontal con X=0. El origen queda entre ambas.
- Los puntos de Stars, Lumps, A Uno, luz y evento de sonido conservan sus posiciones durante todas las muestras. Se conservan geometría relativa, cantidades, velocidades, tamaño, filtros y tiempos. Death compensa la contracción del cuerpo; no mueve el impacto hacia atrás con una traslación global.
- Colores del pack de jugadores: RGB medidos de TeamColor00..11. Tres máscaras neutrales BLP1, alfa8, pictureType4/subType1, mipmaps completos y píxeles reabiertos exactamente. Dependencias locales completas.

Evidencia numérica: [verification.json](evidence/verification.json), [texturas](evidence/textures.json), [manifiesto](evidence/build-manifest.json), [plano](evidence/plano-ajustado.png).

## Ensayo en el motor

JassHelper y pJASS pasaron. Base W3I versión 25. Se reextrajeron los 39 miembros sustituidos/importados del mapa final y se compararon sus bytes antes de abrirlo. Sesión final: `play-20261022-154839-301634`, mapa SHA256 `36c445d288631cb9326da1eab9fc6a970609d9926699be0dff95716b8da6401d`.

Escena: 24 variantes del pack de jugadores, originales simples Blue/Red, derivados de anclaje simples Blue/Red y dos unidades con el mismo prototipo TC (roja/azul). Se observaron Stand, Birth y Death. Escalas 0.5, 1.5 y 3 comprobadas visualmente entre sesiones b/c. Los doce colores y ambas formas cargan; se observan sus partículas de impacto. La fuente de luz se comprobó estructuralmente; no se midió fotométricamente la iluminación de cada color por separado.

- [Galería en 1.27b](evidence/game-grid.png).
- [Escala 3](evidence/game-scale3.png).
- [Escala 0.5](evidence/game-scale05.png).
- [Impacto: estrellas originales conservadas frente a TC](evidence/impact/06.png).
- [Captura de Birth](evidence/birth/05.png).

La primera cámara del laboratorio miraba hacia arriba y se corrigió a 290 grados. No era un fallo del modelo. El laboratorio c tiene controles `-stand`, `-birth`, `-impact`, `-scale`, `-pause`, `-resume`. Se aisló la ventana de esta prueba en el monitor DP-1 al detectar otra partida de otro trabajo en un prefijo diferente. El mapa de ese otro trabajo no forma parte de esta evidencia y no se cerró.

La partida propia final terminó con confirmación dirigida a su HWND, retorno 0; no se enviaron teclas globales en ese cierre. Se documentó por separado una entrada global S accidental durante un cierre anterior.

## Límites prácticos

El anclaje corresponde al frente de la malla. Halos translúcidos y partículas de impacto pueden extenderse a su alrededor. El modelo no contiene CollisionShapes; no se inspeccionó ni cambió el radio, paso, trayectoria o llegada de un sistema del mapa. La reproducción sobre unidades no prueba por sí sola herencia de teamcolor de efectos creados con AddSpecialEffect. No se ensayó combate, LAN, rendimiento ni cambios de color de un proyectil ya creado.

## Incidencias

- [Texturas con sesgo de color, recuperado](../informes/errores/resueltos/2026-10-22-153502-shots-texturas-sesgo-color.md).
- [Verificador MDL, recuperado](../informes/errores/resueltos/2026-10-22-153852-shots-validacion-mdl.md).
- [Empaquetado/cámara del laboratorio, recuperado](../informes/errores/resueltos/2026-10-22-154111-shots-fixture-empaquetado.md).
- [Anclaje frontal, derivado corregido](../informes/errores/resueltos/2026-10-22-151600-shots-vol-i-origen-punta.md).
- [Incidente de foco: efecto en navegador no comprobado](../informes/errores/2026-10-22-154808-shots-cierre-foco.md).
