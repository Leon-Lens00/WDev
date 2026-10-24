# Shots I y II: recoloreado elimina los tonos claros

- Fecha: 2026-10-22, America/Lima.
- Proyecto/entorno: ModelEditor, MDX800, Warcraft III Classic 1.27b.
- Síntoma: los packs de jugadores presentan color plano frente al núcleo claro del original; reportado por el usuario.
- Reproducción: comparar el original azul/rojo con derivados actuales. Captura inicial de Vol. II en `ModelEditor/evidence/vol-ii/game-stand.png`.
- Causa confirmada en archivos: el tinte anterior usa `max(colorFuente)*RGBJugador`. Elimina el mínimo RGB que representaba el componente neutro. Ejemplo geoset original azul de ambos volúmenes [0.333333,0.6,1]; variante roja actual [1,0.011765,0.011765]. El azul de jugador tiene rojo cero, por lo que la suma aditiva de esas capas no puede producir blanco.
- Impacto: presentación visual del pack de jugadores de ambos volúmenes. Los originales y las correcciones de pivote no sufren esta pérdida.
- Estado: resuelto mediante nueva revisión de ambos packs; comprobación final en motor descrita abajo.
- Acción: `src/team-tint.cjs` conserva componente neutro de cada color fuente. Candidatos bajo `exports/candidatos-brillo`; no sustituyen packs entregados.
- Verificación: 24 candidatos simples exportados y reparseados en dos lectores. Comparativa en Warcraft III 1.27b: 12 casos, originales/actuales/candidatos, azul y rojo de Vol. I y II a escala 1 y 3. Capturas `evidence/brillo/comparison-stand.png` y `comparison-scale3.png`; mapa SHA256 4da6392c4abc1ea7ccc1758dbb595071aaf99dbc37d1c7e5eb77d132067d7d80. Los actuales carecen del núcleo blanco y los candidatos lo recuperan; Vol. II candidato queda más blanco/intenso que su referencia, por lo que no se presenta como corrección final. Comparativa bajo `evidence/brillo/`.
- Límites: no se está certificando reproducción idéntica de la textura original después de neutralizarla ni rendimiento o multijugador.

### Incidencia del verificador BLP

Durante la muestra con texturas por color, Pillow `seek(1)` devolvió EOFError: su plugin BLP sólo expone la imagen base, no fotogramas/mipmaps. No se completó aquel intento de validación. Se sustituyó esa comprobación por contraste de offsets, tamaños y bytes de cada mip en el archivo, manteniendo la relectura de píxeles base y alfa. La incidencia afecta al método de inspección, no demuestra corrupción del asset. Estado: pendiente repetir generador tras corregir el verificador.

Segundo intento: la variante gris genera menos de 256 entradas útiles y `getpalette()` entrega una lista corta; el escritor asumía 768 bytes. IndexError. Se rellena únicamente el tramo no usado de la tabla, sin modificar índices útiles. El build dependiente se intentó indebidamente tras ese fallo y rechazó la ausencia de Flare.blp; no produjo un pack completo. Se repiten las fases de forma secuencial y se exige éxito del generador antes del build. No afecta a paquetes previos.

Recuperación del generador: doce texturas completas, header BLP1 1/8/4/1, cadena hasta 1×1, offsets/tamaños/bytes contrastados, alfa base exacto y error máximo de cuantización de canal 6/255. Build posterior: 36 modelos (24 Vol. I simple/doble y 12 Vol. II simple), relectura binaria independiente PASS. Conserva Flare/star originales y cambia sólo tono de Glow por variante. Prueba visual del gradiente pendiente en este punto.

La galería completa mostró desplazamiento de tono al conservar offsets azules: naranja demasiado próximo al amarillo y rojo hacia naranja. Se sustituye rotación relativa de hue por hue de jugador conservando saturación/intensidad y componente neutra de fuente; azul conserva referencia exacta. Estas capturas intermedias se conservan como estudio, no prueba final.

## Resultado final y cierre

El usuario pidió tratar la muestra para acercarse al original. Se aplicó la recuperación de gradiente con hue del jugador sobre la parte coloreada y componente neutra conservada. Se mantienen Flare/star originales y Glow propio por color. La galería final `ab41ef6dec0961214c9209bc2125571c330781718b9f2a9c30cc428ce01a6a4b` cargó los 36 derivados (I simple/doble, II simple) y se capturaron todos los colores en escala 1.5. Impacto/desaparición de Vol. II observados.

Comparación final original/pack anterior/revisión para azul y rojo de ambos volúmenes, escalas1 y3, mapa `fa1014c3bcc52e3c2a225645113f4caf650ab952224770db138c8e540ba9b78e`. Se recupera centro blanco y transición coloreada; no se pretende igualdad píxel a píxel de variantes con máscaras originales de otros colores. Captura `ModelEditor/evidence/brillo/comparison-final-scale3.png`; lámina de recortes sin alterar el color `comparacion-final.png`. Los extremos de brillo dependen de escala, solapamiento y fondo.

Verificación final: 36 modelos, 5988 poses iguales a las bases ancladas, estructura ajena a color exacta, MDL completo contrastado, 108 dependencias presentes, originales conservados por hash. Doce glows BLP1 completos con alfa exacto y error RGB de cuantización máximo5/255. ZIP de Vol.I36 modelos y Vol.II18 modelos (incluyen originales anclados), CRC y bytes completos comprobados. Manifestación de pruebas en `ModelEditor/REVISION-BRILLO.md` y hashes en `evidence/brillo/packages.json`.

Resueltos también los errores del verificador BLP y el intento dependiente tras generación fallida. La muestra primera demasiado blanca y la rotación relativa con desplazamientos de tono quedan archivadas como estudios. Los paquetes originales/anteriores no se sobrescribieron. Se entrega la revisión `shots-vol-i-organizados-brillo` / `shots-vol-ii-organizados-brillo`. No acredita física del sistema de misiles, rendimiento, LAN ni fotometría. Birth mantiene curvas/poses verificadas; la toma corta en motor no se usa como prueba independiente de esa transición.
