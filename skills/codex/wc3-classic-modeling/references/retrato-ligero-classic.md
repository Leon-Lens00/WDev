# Retrato ligero con pared invisible (Classic 1.27b)

Técnica del 30/10/2026 para Tauren y Paladín de Dev Mission, MDX800. Rehace un
retrato nativo para mostrarlo con una unidad en el mundo, con la cámara del retrato
incorporada al modelo y sin que ningún vértice salga de un rectángulo. Pesa casi como
el original. Script: [scripts/retrato_ligero.cjs](../scripts/retrato_ligero.cjs).
Evidencia: `Proyect/work/titulo-devmission-20261026/RESULTADO.md`, secciones v11c y v11d.

## Problema

`TerrainDev/dialogue-system/tools/portrait-camera.cjs` hornea cámara y perspectiva en
cada vértice: un hueso por vértice con una pista muestreada cada 25 ms. El resultado
es exacto, pero el Tauren llegó a 425 nodos, 365 064 claves y 5,9 MB.

## Método

1. Partir del original y conservar esqueleto, bindings, rotaciones, texturas, orden e
   índices de secuencias. Retirar el geoset del fondo (`replaceableId` 2).
2. Muestrear cámara y vértices proyectados cada 25 ms en las secuencias elegidas.
   Esa trayectoria es el objetivo; cada vértice se recorta a la pared.
3. Colgar el esqueleto de una cadena fija de tres nodos:
   `PortraitBillboard` (hueso) → `PortraitFlat` (ayudante, S = ds, s(t), s(t), aplana
   la profundidad y aplica la perspectiva) → `PortraitView` (ayudante, T y R de cámara).
4. Ajustar por mínimos cuadrados el vértice de reposo contra la trayectoria. `HID` = 1
   da a los fotogramas ocultos tras el marco el mismo peso que a los visibles.
5. Corregir por hueso, de padre a hijo: traslación en el plano de pantalla y escala
   uniforme, escritas en KGTR/KGSC del propio hueso y reducidas con Ramer-Douglas-Peucker
   (`TTOL` .5, `STOL` .07, `CK` 4, `ROUNDS` 2). Después volver a ajustar los vértices.
6. Fijar al nodo 0 los vértices que nunca se ven.
7. Pared: con la cadena final del archivo, proyectar cada vértice sobre los semiespacios
   ±XL, ±YL (POCS, por fotograma y hasta 2000 pasadas). Solo cambia la posición de
   reposo, así que no añade claves. Hacerlo al final: antes, los pasos 4-6 la deshacen.
8. Renumerar los `ObjectId` por orden de bloques (huesos, luego ayudantes) y actualizar
   `parentId`, `matrixIndices` y `pivotPoints`. Ordenar las pistas KGTR, KGRT, KGSC.

## Uso

```bash
node scripts/retrato_ligero.cjs CARPETA_SALIDA 25
```

Escribe `.mdx`, `.mdl` y `ajuste.json`. Para otro retrato, editar en el script:

- `base`: raíz que contiene `ModelEditor/src/model.cjs` y `TerrainDev/dialogue-system/tools`.
- La lista `[id, nombre, idle, talk]` y la ruta de los originales.
- `repairTotem`, que es exclusivo del Tauren.
- `XL`, `YL` (pared) y `VX`, `VY` (abertura visible), en unidades de marco de ancho `W`.

## Resultado medido

| Modelo | Original | Horneado | Ligero | Comprimido |
|---|---|---|---|---|
| Tauren | 44 174 B | 5 919 098 B | 65 426 B | ≈30 KB |
| Paladín | 33 391 B | 3 434 919 B | 45 923 B | ≈24 KB |

Fotograma a fotograma cada 25 ms, sin `Stand -1`: 0 vértices fuera de la pared. Sin
ella, el nativo proyectado se sale ≈31,7 (Tauren) y ≈30,4 (Paladín).

Coste frente al horneado: RMS 0,66 y máximo 7,94 en el Tauren; RMS 1,03 y máximo 11,70
en el Paladín, en unidades de marco. Píxeles que difieren más de un 20 %: 17,4 % y 4,1 %.

## Límites

- La pared es un desplazamiento fijo, no un deslizamiento por fotograma: el vértice
  queda dentro también cuando no toca la pared, y el contorno se recoge un poco. En el
  Paladín, la capa queda algo más corta.
- Las secuencias `Stand` se excluyen del ajuste. El `Stand -1` del Tauren se ve mal si
  se reproduce; ni el título ni `ConversationUI` lo usan. Comprobar qué secuencias usa
  cada mapa antes de reutilizar un retrato.
- El borde cortado por la pared se nota si queda a la vista. En v11e se cubrió con un
  marco delante del retrato (profundidad 403 contra 405) que tapa 14 téxeles por lado.
- Probado en juego solo en la pantalla de título con puente. Diálogos en partida y
  multijugador quedaron sin probar.

## Retratos con cuernos o piezas muy salidas (Cairne, 30/10/2026)

El método base falló con `HeroTaurenChieftainCIN_Portrait`: el nativo se sale ≈30 de la
pared y el desplazamiento fijo recogía los cuernos sobre la cara. Tres correcciones, en
`Proyect/work/titulo-devmission-20261026/scripts/retrato_cairne.cjs`:

1. **Elegir la secuencia de reposo midiendo el giro de `Bone_Head` y `Jaw`.** No tomar
   `Portrait - 1` por el nombre: en Cairne gira la cabeza 55° y abre la boca 51°, y se veía
   como un fallo del modelo. `Portrait - 2` gira 12° y 3°. Al cruzar la grabación con el
   audio, lo roto coincidía con el reposo, no con Talk.
2. **Ajustar solo las secuencias que reproduce el mapa.** Las demás empeoran el ajuste.
3. **Horneo parcial en lugar de pared.** Cada vértice que toca la pared, o que se aleja
   más de `BAKE` (3) del objetivo, recibe un hueso propio colgado de `PortraitBillboard`
   con su trayectoria recortada (RDP con `BTOL` .15). Incluye los vértices fijados al
   nodo 0 que se estiran dentro del marco. Cada geoset admite 256 grupos.
4. **Limpiar las banderas de no heredar (`flags & 7`) de todos los nodos.** `NoseRing`
   tenía `flags 2`: en el motor no heredaba la cadena y el aro salía enorme. `skin()` y
   `mdx-m3-viewer` no lo ven, y el dibujo del modelo con la textura real parecía correcto.

Medido: de RMS 1,32 y máximo 19,7 a RMS 0,22 y máximo 2,76, con 95 vértices horneados,
3396 claves y 141 KB sin comprimir (80 KB antes). El error numérico no detecta los puntos
1 y 4: el ajuste era bueno y aun así se veía roto. Si el dibujo del archivo coincide con el
nativo y el juego no, revisar `flags` antes de tocar el ajuste.

## Comprobaciones

- Medir la pared en todos los fotogramas sobre el archivo final. Mirar unos pocos
  fotogramas llevó a una afirmación falsa en v11c.
- Revisar el retrato en juego: con ids intercalados el modelo queda en reposo, sin
  error, y `mdx-m3-viewer` lo lee bien.
- Mostrar errores al ejecutar: ocultar stderr escondió un fallo del script.
