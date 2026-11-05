# Centrar modelos de misil y medir su área de impacto

Método validado por el usuario en TerrainDev el 26/10/2026 con los Shots de
Vinz (primero el rojo Vol. I y Vol. II; después aplicado a todos los colores)
y Firebrand. El Double se retiró del mapa el mismo día. Lo confirmó visualmente en el juego
y disparando. Aplicarlo a cualquier modelo nuevo antes de fijar su colisión.

## 1. Medir el modelo animado, no el archivo

- Medir la pose real de la secuencia `Stand` en varios fotogramas, con
  `pose()`/`bounds()` de `Proyect/ModelEditor/src/model.cjs`. Los vértices sin
  animar engañan: en los Shots un hueso traslada +1,2 en X, y la punta real
  está en 48,42 / 65,67, no en 47,22 / 64,46.
- No fiarse de las extensiones guardadas en el MDX: Shot II trae copiadas las
  de Vol. I (−62..47).
- Registrar por modelo: punta (X máx.), cola (X mín.) y semiancho (Y/Z).
- La cola de muchos misiles es estela que se desvanece. No forma parte del
  cuerpo de impacto.

## 2. Radio = semiancho del cuerpo

- El radio de colisión sale del **ancho**, no del largo:
  - Vol. I: 6.
  - Vol. II: 18; verde y aqua, 16,2.
  - Firebrand: radio(f) × escala, que es 30 en el modelo rojo.
- Un círculo que alcance la punta desde el origen se descartó: queda 8 veces
  más ancho que el proyectil e impacta de lado.
- Las partículas no escalan con la escala del modelo. Medir la geometría.

## 3. Centrar: la punta en +radio

Un círculo centrado en el origen de la unidad o misil debe terminar justo en la
punta:

- **Copia desplazada en X (preferida, validada):** desplazamiento = radio −
  punta animada. Ejemplos: Vol. I −42,42 y Vol. II −47,67. Mover sólo la X de
  vértices, pivotes y extensiones (modelo, secuencias, geosets). Las animaciones
  son relativas al pivote, y las partículas se mueven con él.
- **No llevar la punta a 0.** Así se hicieron los modificados antiguos: el
  círculo sobresale un radio vacío por delante.
- **Sin copia (originales intactos):** desplazar el centro de colisión en el
  código, con adelanto = punta − radio, en la dirección de vuelo. Usar la punta
  animada. Se usó como paso intermedio y se retiró al tener copias de todos los
  colores: mantener ambas vías duplica casos (adelanto, primer barrido).

Implementación: `TerrainDev/scripts/shots_ajustados.cjs`.
- Lee `assets/shots-originales` sin modificarlos.
- Recorre todos los MDX de Vol. I simple (radio 6) y Vol. II (radio 18; verde
  16,2); omite el Double. Desplazamientos: Vol. I −42,42; Vol. II −47,67;
  Vol. II verde −43,02.
- Escribe `assets/shots-ajustados/ShotsAjustados/*.mdx` y su manifiesto.
- Comprueba que el MDX resultante sólo difiere en esas posiciones, con ida y
  vuelta por dos analizadores.
- El builder importa **sólo** ese manifiesto, con el prefijo `ShotsAjustados\`.
  Los originales (`ShotsVolI\`, `ShotsVolII\`) y los modificados antiguos
  (`ShotsTeam\`, `assets/rapid-shot-colors`) ya no se importan; los originales
  quedan en disco como entrada del script.

Después, comparar los hashes de los originales y comprobar que el resto del
modelo es igual: lo único distinto debe ser el desplazamiento en X.

## 4. Verificar con el círculo de selección nativo

Sólo con elementos del propio juego; el usuario rechazó rayos o dibujos
añadidos.

- Radio del círculo = 36 × `ussc`, según
  `UI\MiscData.txt [SelectionCircle] ScaleFactor=72`. Para un radio r, poner
  `ussc` = r/36.
- Crear unidades de prueba con:
  - el modelo del misil, `usca` 1 y el `ussc` anterior; `usca` y `ussc` son
    de tipo **real (1)**, no unreal: si no, se leen como 0;
  - velocidad ≥ 1 (con 0 se ignoró `SetUnitFlyHeight`);
  - altura = radio, para que el modelo centrado repose en el suelo, donde se
    dibuja el círculo; en el aire la perspectiva separa ambos;
  - jugador propio (rojo), para ver el círculo verde.
- Poner lado a lado el original y el ajustado. El usuario arrastra la selección
  y juzga si el círculo encierra el ancho y llega a la punta.
- Detalles de datos de objeto: `build-warcraft3-vjass-127b/references/object-data-127b.md`.

## 5. Colisión en vuelo (RapidFire, TerrainDev)

- `radiusFor` da el ancho y `modelOf` el modelo: siempre
  `ShotsAjustados\Shot <color>.mdx` o `Shot II <color>.mdx`. Sin
  adelanto: el círculo va en el origen del misil.
- `sweep` barre el círculo entre la posición anterior y la actual.
- Los cuerpos enemigos usan su círculo de selección (`UnitHitShape`, 36 ×
  `ussc` por tipo, desde `unitUI.slk`) con `GroundCollision.shaped`.
- Un modelo doble (dos cuerpos en Y=±15) necesita un barrido por cuerpo: un
  solo círculo ancho golpearía en el hueco. TerrainDev lo retiró.
- Con la copia ajustada, la punta nace a +radio del punto de disparo, no unos
  48–66 por delante. Si se quiere la salida adelantada, mover el lanzamiento, no
  el modelo.

## 6. Unidades grandes y jefes: que reciban los disparos

Comprobado en el juego el 26/10/2026, con jefes abominación a escala 2 y 3;
el usuario confirmó que reciben bien los golpes.

- El cuerpo de impacto de nuestros misiles es el **círculo de selección**
  (36 × `ussc`), registrado por tipo en `UnitHitShape`. El misil golpea si su
  barrido pasa a menos de radio del misil + radio de selección del centro de la
  unidad. Los tipos no registrados usan `IsUnitInRangeXY`, que se basa en `ucol`
  exacto y suele ser bastante menor que el modelo: con misiles finos, el
  disparo atraviesa el cuerpo.
- Para agrandar una unidad, escalar a la vez:
  - `usca` (modelo);
  - `ussc` (selección e impacto del misil);
  - `ucol` (ataques, hechizos nativos y movimiento; máximo 200).

  Además, registrar el tipo en `UnitHitShape`, porque 1.27b no puede leer
  `ussc` desde el código.
  Ejemplo: abominación (2,1 / 48) a escala 3 → `ussc` 6,3 y `ucol` 144, con
  `register('rbs3',6.3,144.)`.
- `SetUnitScale` en ejecución sólo agranda el modelo: no cambia `ucol` ni el
  registro. Un jefe que crece durante la partida necesita guardar su escala
  por unidad en la colisión propia.
- Medición nativa y detalles de `ucol`: `build-warcraft3-vjass-127b/references/object-data-127b.md`.

## 7. Altura de vuelo

Un misil alto (antes Z=70) parece pasar por encima de la unidad aunque golpee:
el impacto es un círculo en el plano, sin altura. Volar casi a ras de suelo,
con Z = radio del cuerpo del misil (Firebrand 30, Vol. I 6, Vol. II 18), para
que el modelo centrado no atraviese el terreno. En BPower Missile 2.5.1, la Z
de `createXYZ` es relativa al terreno del punto.

## Pendiente (26/10/2026)

- Con vuelo bajo, `resolve` trata `m.z < 0` como muro: en terreno irregular el
  misil podría detenerse. No observado; revisar si aparece.
- Unidades de prueba y demo sólo en candidatos (`maps/work/cuerpos-*`); la
  entrega no se ha promovido.
