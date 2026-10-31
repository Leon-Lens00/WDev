# Misiles por color — Classic 1.27b

Rapid Fire (W Shots I y R Shots II; el doble se retiró el 26/10/2026) usa las copias `ShotsAjustados\Shot <color>.mdx` y `ShotsAjustados\Shot II <color>.mdx`, autor original Vinz. Son los originales de `assets/shots-originales` desplazados sólo en X por `scripts/shots_ajustados.cjs` para que la punta quede en +radio. Procedencia y SHA256: `assets/shots-ajustados/manifest.json`; créditos HTML en `assets/shots-originales`. Los antiguos `ShotsTeam` (rapid-shot-colors) se retiraron el 26/10/2026.

## Selección

Cada emisión consulta `GetPlayerColor(GetOwningPlayer(actor))`. Por ello funciona también cuando el color del jugador difiere del número de slot. Los misiles que ya vuelan conservan el modelo elegido al salir; recastear actualiza los siguientes sin adelantar el reloj.

Para colores individuales o un esquema de equipos:

```jass
call pair.setColor(PLAYER_COLOR_BLUE)
// Al dejar de usar el color individual/de equipo:
call pair.clearColor()
```

`pair` es un RapidPair existente. El setter cambia el color visual del actor y controlador y guarda el override del emisor; no cambia dueño, alianzas ni daño. `clearColor()` restaura la política del propietario. En Classic no hay GetUnitColor: un SetUnitColor externo no puede leerse automáticamente, por lo que usar este setter para esas unidades. Rojo es enum0 y se compara igual a null; **setColor(null) no borra el override**, equivale a rojo. La ausencia se mantiene en un booleano independiente.

`RapidBolt.shoot(unit,x,y)` conserva su firma y toma el color del propietario. `RapidBolt.shootColor(unit,x,y,playercolor)` sirve para un emisor independiente con color explícito. Valores fuera de los12 colores Classic usan el modelo gris; null coincide con rojo en ese runtime.

## Windwalk por color

`RapidPair` muestra Windwalk de Vinz durante el movimiento artificial, en la familia del misil: Firebrand usa sus 9 colores y Shots sus 6 (`RapidBolt.walkModelOf`). Azul, Verde y Naranja son copias sin tocar de Blue Soul, Necro Soul y Fire. Rojo, Teal, Púrpura, Amarillo, Rosa y Plata salen de Blue Soul con color tomado de la luz de cada Firebrand y un `Ghost2` recoloreado (`scripts/windwalk_colores.cjs`, `scripts/windwalk_texturas.py`). `Ghost2.blp` es un BLP JPEG con BGRA invertido: Pillow pierde su alfa y lo deja opaco (cuadros negros en juego), por eso el script lo decodifica a mano y comprueba el alfa con bytes del archivo. Blood y el Windwalk neutro no se usan.

## Escala y colisión

`RapidBolt.HIT_RADIUS=16.` sigue alimentando las dos consultas barridas del proyectil. `VISUAL_SCALE=HIT_RADIUS/5.832`, aproximadamente2.74348. Dos lectores MDX midieron11.664 unidades de ancho máximo del cuerpo en Stand en las12 variantes; el resultado escalado es32, el diámetro de colisión. Se compararon1.0/1.5/2.74 en el juego con marcadores de radio16. Esto calibra el grosor máximo del cuerpo; el modelo es alargado y su punta sigue anclada al origen. La estela, luz, halo y animación Death pueden rebasar el círculo y no hacen daño adicional.

No se modificaron Missile, MissileRecycler, MissileDiagnostics, GroundMotion, GroundCollision, daño25, velocidad1200 ni intervalo0.25s. La revisión de brillo conserva el núcleo claro y los degradados. El builder importa12 MDX, Flare/star compartidas y12 Glow por color (14 BLP). Comprueba hashes y reextrae los26 miembros; registra rutas personalizadas en war3map.imp. El original y las variantes de inventario/diálogo permanecen aparte.

## Herramientas e índices

Producción: CodeGraph `TerrainDev/src`, perfil release con APIs Classic. Builder y laboratorios: raíz independiente `TerrainDev/scripts`, exclusiones de binarios/cachés, JASS conservative/completeInputs false porque los fixtures no son una unidad completa. No hay aristas automáticas entre índices. Consultas de RapidBolt, Missile.scale/model y GroundCollision.trace orientaron el cambio; los avisos sobre proyecciones/condiciones no sustituyen JassHelper/pJASS ni las pruebas en juego.

Evidencia: `reports/shot-colors-20261022/`. El resultado final enlaza logs y capturas de esta revisión. No se acredita multijugador ni toda futura combinación de habilidades.

## Revisión de brillo integrada — 22/10/2026

Sustitución verificada en `reports/shot-refresh-20261022-184335/result.json`: 12 MDX y14 BLP reextraídos, 1068 poses iguales a los anteriores, escala y física conservadas. Galería de los12 colores observada en1.27b; 40 comprobaciones de integración aprobadas, 23 proyectiles creados/retirados y cero activos finales. Las15 fuentes JASS conservan sus hashes. La regresión anterior de44 mecánicas sigue como evidencia histórica y no se atribuye a esta ejecución. Partida propia cerrada con confirmación S.
