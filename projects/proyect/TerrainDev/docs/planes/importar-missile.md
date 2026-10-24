# TerrainDev con Missile y bibliotecas auxiliares

Fecha: 2026-10-21, America/Lima. Implementación autorizada por el usuario.

## Objetivo y base

Entregar una copia editable de TerrainDev dentro de este proyecto, con Missile de BPower 2.5.1, sus objetos/assets y una base útil de bibliotecas Classic. Conservar terreno, colocaciones, objetos existentes, triggers GUI y créditos. La fuente `/home/snz/Descargas/TerrainDev.w3x` y la copia `maps/originals/TerrainDev.w3x` quedan intactas; su identidad está en `reports/original.json`.

La inspección encontró W3I 25, W3E 11, WTG 7 y WCT 1; dos triggers GUI, sin fuentes vJASS en WCT, dos unidades custom (`n000`, `n001`) y una habilidad custom (`A000`). El JASS original pasa pJASS con las APIs locales de 1.27b. El nombre interno es Swamped Temple_v2, autor Kai Trausenegger / Anomines; conservar esos créditos.

## Selección y contratos

- Missile 2.5.1 y MissileRecycler 1.4.5.2 comparten el ID dedicado `dumi`; importar el modelo dummy de Vexorian desde la demo de BPower. El reciclador declara UnitAlive una sola vez.
- WorldBounds, ErrorMessage, TimerUtils, Table, RegisterPlayerUnitEvent, SpellEffectEvent, IsDestructableTree y DummyCaster forman la base auxiliar. Verificar las dependencias exactas antes de compilar. No añadir otro reciclador, UnitIndexer o damage engine por anticipación.
- Reutilizar versiones de los ejemplos descargados; conservar fuentes y procedencia. MissileRecycler procede del hilo original de Bribe. Desactivar su directiva ObjectMerger porque el objeto se integra explícitamente en el mapa.
- DummyCaster utiliza una unidad dedicada `dcst`; evitar los IDs existentes. Los efectos/buffs futuros requerirán sus propios objetos y contratos de lanzamiento.
- Bibliotecas editables visibles en una categoría WTG separada, con textos WCT emparejados por índice. Conservar el contenido binario original de los triggers GUI. Fuentes modulares externas acompañan el proyecto para reconstruir la copia.

## Fases

1. **Inspección y copia — completada.** Original y extracción conservados; toolchain y JASS base comprobados. Evidencia en `reports/` y `build/base-extracted/`.
2. **Fuentes, objetos y editor — completada.** Diez fuentes, dos unidades (`dumi`, `dcst`) y el modelo dummy. WTG/WCT contienen los dos triggers originales más diez textos emparejados. Procedencia en `libraries.json` y `assets/objects.json`.
3. **Compilación y empaquetado — completada.** JassHelper y pJASS con APIs 1.27b; salida `TerrainDev.w3x`. Reextracción y hashes comprobados. Se conserva HM3W, terreno, colocaciones y contenido ajeno. Script reproducible en `scripts/build.py`; cada revisión tiene informes separados.
4. **Pruebas de integración — completada.** Revisión corregida abierta/guardada/reabierta en NewGen, fuentes y corrección preservadas y recompilación válida. Laboratorio final: 90/90 misiles retirados (70 llegadas, 10 impactos y 10 cancelaciones), 12 reutilizaciones, 66 excedentes eliminados, cero vivos fuera del pool y cero fallos; Table/TimerUtils cubiertos parcialmente. Tres controles negativos rechazados por el evaluador. La primera medición usó una enumeración que omite Locust y solicitó reciclaje demasiado pronto. La medición corregida acreditó reutilización, pero encontró 66 excedentes vivos. Un ensayo separado con tres unidades idénticas confirmó que PauseUnit bloquea la vida temporizada en 1.27b (pausada viva, sin pausa y reanudada muertas a los 4s). Se añadió PauseUnit(false) sólo al descarte de excedentes. Evidencia final en `reports/verification.json`, `reports/editor-final/` y `reports/game-test/20261021-020858/`. Multijugador y futuros hechizos/buffs fuera del alcance actual.

## Continuidad

Entrega completada: `TerrainDev.w3x`, SHA-256 `5f1ed0ed404b96a941e69e5a6831ebe0f808de15b0b32be07692f03a0aa9285b`. Originales comprobados sin cambios. La corrección del reciclador es local y está documentada; conservarla al actualizar upstream. Los laboratorios no forman parte de los triggers de la entrega.
