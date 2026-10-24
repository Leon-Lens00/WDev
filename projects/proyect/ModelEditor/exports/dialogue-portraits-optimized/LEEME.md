# Retratos de diálogo: candidatos optimizados

Classic1.27b / MDX800. Copias separadas; no se ha reemplazado el mapa, el diálogo
activo ni UI Studio. Autoría de los personajes/texturas originales: Blizzard.
Adaptación de cámara/proyección del proyecto, reducción de claves por Codex.

Pesos de MDX sin texturas ni compresión del mapa, en bytes:

| Personaje | Original Warcraft | Adaptación actual | Fina0.02 | Equilibrada0.05 | Ligera0.1 |
|---|---:|---:|---:|---:|---:|
| Paladín | 33.391 | 3.434.919 | 599.239 | 401.047 | 296.615 |
| Tauren | 44.174 | 5.919.098 | 1.513.674 | 1.008.938 | 719.482 |

La muestra predeterminada usa0.02 unidades de error máximo por curva. Ahorra
82.55%/74.43% frente a la adaptación, pero aún pesa17.9×/34.3× el original.
La variante0.1 ahorra91.36%/87.84%, con más error permitido, y todavía pesa8.9×/16.3×.
Los cuatro BLP suman164.813bytes y son copias exactas de las dependencias actuales;
esta fase no reduce texturas. Los MDL son fuentes auxiliares y no se importan
además del MDX. Cada carpeta conserva las rutas UI/Dialogue esperadas.

Esto reduce claves redundantes; no reconstruye el rig. La adaptación hornea
movimiento/cámara por vértice, mientras el original lo expresa con muchos menos
huesos. Paladín:21huesos/536claves nativos frente a238nodos/211.878claves antes de
reducir; Tauren:24huesos/587claves frente a425nodos/365.064claves. Los originales
tienen además helpers y otros datos; esos conteos de claves son de sus huesos.
Acercarse realmente al presupuesto original requiere otra representación de la
proyección, conservando o reconstruyendo un rig compacto, y nuevas pruebas de
encuadre, deformación, oclusión y transición. No se acredita con esta reducción.

Se conservan malla, UV, materiales, texturas, rig/pivotes, pose sin animación,
orden/intervalos y extremos exactos de los clips y BlendTime200ms. Tauren Stand-1
sigue estático y no se ha cambiado el ciclo JASS. Los extremos preservan la unión
existente del bucle; no se promete reparar un salto que ya tuviera el origen.

Validación: lectura/escritura MDX/MDL con mdx-m3-viewer5.12.0 y war3-model4.0.1,
comparación de propiedades inmutables, claves retenidas y extremos, todas las
curvas en puntos de quiebre y medios, y todos los vértices del rig admitido.
5.579.175comparaciones de vértices entre diez variantes; máximos dentro de sus
tolerancias. La rotación billboard común no altera la norma del error. Límites
por eje contenidos en los de la adaptación original. Los tests rechazan un pico
que no puede eliminarse y una interpolación no admitida.

Preview: `../../viewer/portraits-optimized/index.html`, servir esa carpeta en
http://127.0.0.1:8765/. Orbital, rejilla/ejes/origen, clips y tiempo sincronizados.
Revisados Paladín Portrait1/Talk1 y Tauren Talk1/Talk2/Portrait3, variante ligera,
Stand-1 conservado, pausa/último fotograma y giro. Consola observada sin errores.
No equivale a recorrer visualmente todos los tiempos de todos los clips.

Vídeo real de pantalla: `../../evidence/portrait-keys-20261022/PREVIEW.mp4`.
14s/H2641280×720/30fps, sin audio: dos fragmentos de7s del registro original
DP-1(4–11sPaladín;57–64sTauren), reducidos a1280 de ancho. No se alteran los
píxeles de modelos. Tiempos de pantalla y tasa de captura no miden FPS del juego.

Evidencia y hashes: `../../evidence/portrait-keys-20261022/metrics.json`,
`validation-latest.json`, `bounds.json`, `verify.log`, `preview-window.json`.
Herramientas: `../../src/optimize-portraits.cjs` y `pack-portrait-preview.cjs`.
Prueba nativa de estos candidatos pendiente; sin afirmaciones de FPS/multijugador.
