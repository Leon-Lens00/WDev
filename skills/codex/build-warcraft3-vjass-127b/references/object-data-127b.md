# Datos de objeto (w3u/w3t/w3a…) en Classic 1.27b

Hallazgos de TerrainDev (26/10/2026) al crear unidades con modelos de misil.
Cada uno costó una ronda de prueba fallida; comprobarlos antes de dar por buena
una modificación de objetos.

## Tipo de campo (kind) según la metadata, no según el valor

Cada modificación w3u guarda un tipo: 0 int, 1 real, 2 unreal, 3 string. Debe
coincidir con la columna `type` de `Units/UnitMetaData.slk` (o la metadata del
tipo de objeto correspondiente) del parche objetivo.

- `usca` (escala del modelo) y `ussc` (escala de selección) son **real (1)**.
- `ucol`, `uacq`, `ucpt`, `ucbs`, `umvh` son **unreal (2)**.
- Un tipo equivocado no da error al empaquetar: el editor y el juego leen el
  campo como **0**. Con `usca` 0 el modelo no se ve, pero sus partículas sí
  (las partículas no escalan con `usca`), lo que parece un modelo enterrado o
  diminuto y desvía el diagnóstico hacia altura, pausa o animación.
- `wc3ctl` (y otros decodificadores) muestran el float aunque el tipo sea
  incorrecto: leer el valor de vuelta **no** valida el tipo. Validar en el
  builder cada campo float contra la metadata (real→1, unreal→2) y abrir el
  objeto en el editor cuando haya duda.

Copia de metadata 1.27b local:
`/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/classic-assets/Units/`
(`UnitMetaData.slk`, `unitUI.slk`, `UnitBalance.slk`, de War3Patch.mpq).

## Círculo de selección

- `UI\MiscData.txt` [SelectionCircle] `ScaleFactor=72` (War3Patch.mpq 1.27b):
  el cuadrado del círculo mide 72 × `ussc` de ancho → **radio 36 × ussc**.
- El anillo dibujado ocupa 0,88–0,98 de ese radio (`SelectionCircle*.blp`).
- No hay nativa 1.27b para leer `ussc`: si el código lo necesita, registrar el
  valor por tipo desde `unitUI.slk`.

## Collision size (`ucol`) y alcance nativo

Medido en juego (TerrainDev, 26/10/2026), bisección a 0,25 de
`IsUnitInRangeXY(u, x+d, y, 0)`:

| `ucol` | Radio medido |
|---|---|
| 24 | 23,8 |
| 32 | 31,8 |
| 48 | 47,9 |
| 96 | 95,9 |
| 144 | 143,9 |

- El radio que usa `IsUnitInRangeXY` es el `ucol` del objeto **sin redondeo**,
  también por encima de 64. El redondeo en casillas de 16 que citan los foros es
  del pathing (ocupación al moverse), no de este test.
- `SetUnitScale` en tiempo de ejecución **no** cambia ese radio: una
  abominación a escala 2 sigue midiendo 47,9. Para un jefe grande, escalar con
  `usca` en los datos de objeto y escalar también `ucol` y `ussc`. Si se escala
  en ejecución, la colisión propia debe registrar esa escala por unidad.
- `GroupEnumUnitsInRange` sólo cuenta el centro. Enumerar con radio + el
  máximo de colisión del mapa y filtrar con `IsUnitInRangeXY`; así lo hace
  BPower Missile 2.5.1.
- `Units\MiscData.txt` (War3Patch.mpq 1.27b): `MaxCollisionRadius=200`.

## Altura de vuelo

- Una unidad con velocidad `umvs` 0 se quedó a ras de suelo pese a
  `UnitAddAbility/RemoveAbility('Amrf')` + `SetUnitFlyHeight` (observado en
  juego). Con `umvs` 1 la misma secuencia sí la elevó. Usar velocidad ≥ 1 sin
  órdenes, o comprobar en juego, cuando una unidad inmóvil necesite altura.
- `umvh` fija la altura por defecto; `GetUnitDefaultFlyHeight` la devuelve.
- Un modelo con el origen en su centro queda medio enterrado a altura 0;
  para que repose sobre el suelo, altura = su radio.
- El círculo de selección se dibuja en el suelo: con la unidad elevada, la
  perspectiva lo separa del modelo. Para comparar círculo y modelo, dejar el
  modelo apoyado en el suelo.

## Comprobación mínima tras cambiar objetos

1. Tipos de campo validados contra la metadata del parche.
2. Objeto abierto en el editor (escala/selección no a 0) o captura en juego del
   modelo completo, no sólo de partículas.
3. Altura/visibilidad observadas en juego cuando dependan de nativas.
