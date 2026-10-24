> Actualización posterior: el usuario autorizó restauración. Ya aplicada y probada
> en copias Inventory y Dialogue; ver [restauración](../../work/camera-restore-20261022/RESTAURACION.md).
> El cuerpo siguiente conserva los hallazgos y pendientes de la auditoría previa.

# InventorySys: original, v1.4.3 e integración

22 de octubre de 2026. Objetivo: comparar lo recién descargado, la base que
utilizamos y los cambios propios; observar movimiento sin cerrar la partida del
usuario. Entorno Classic1.27b,1920×1080, perfiles Wine separados.

## Conclusión

El original que teníamos **no estaba alterado**: su W3X coincide byte por byte con
el v1.4.1 incluido en la descarga reciente y con WorldEditTestMap.w3x que ejecutaba
el usuario. Sus miembros extraídos coinciden con source-demo y las42fuentes de
upstream coinciden con WCT (normalizando finales de línea).

La integración sí tiene modificaciones propias. El cambio de Camera.win2World
desde Camera.eye a GetCameraEyePositionX/Y/Z reproduce el desplazamiento/recorte
durante movimiento en una copia controlada de la demo original. El dummy uidm y
los recursos visuales UI se conservaron. La explicación anterior basada sólo en
el dummy era incompleta.

Eso no autoriza una reversión simple como arreglo: en el contraste realizado
dentro de TerrainDev, restaurar Camera.eye hace desaparecer la interfaz en la zona
ensayada. Hace falta resolver también la altura/referencia de cámara en ese mapa.
Esta auditoría no modifica las fuentes ni las entregas.

## Identidad

| Archivo | SHA-256 |
|---|---|
| Descarga v1.4.1, original anterior y mapa de la prueba del usuario | `a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada` |
| Descarga v1.4.3 | `4a387ac8879a0604a297bbf888bfb2a17681dd0716a66d7fcbcddd85be2610b9` |
| TerrainDev-Inventory entregado | `6cea157b51229f9ec32cf9d4d070e5e96be66c332382ef46665f1eaba45a9946` |
| Copia A/B de la demo original | `40736c1fe3a5e961dcd2a414b1ace04a2da8b641215bd4359fed13b77ea5aad2` |

La carpeta recién descargada contiene las dos versiones. Su readme recomienda
v1.4.1 para1.24a–1.28c y v1.4.3 para1.29; por tanto, la etiqueta de la carpeta no
demuestra que se estuviera probando v1.4.3 ni que convenga reemplazar nuestra base
Classic1.27b por ella.

## Cambios del autor: v1.4.1 → v1.4.3

42fuentes no vacías en cada WCT; cambian6:

- InventoryCore y EquipmentCore: ocultar el selector al cerrar; evitar selección
  de casilla de equipo cuando el objeto no tiene slot válido.
- InventoryTooltip y EquipmentItem: recolocar textos/título/coste; límite de línea
  de32a30. El readme lo relaciona con parches1.29.1+.
- InvItemSetups: descripción más corta del Orb of Frost.
- SocketItem: formato del mensaje de confirmación de engaste.

**Camera y UserInterface no cambian. war3map.w3u también es idéntico.** Ningún
cambio de dummies/cámara entre esas versiones explica el contraste observado.
Diffs completos `upstream-*.diff` en el directorio de evidencia.

## Modificaciones locales respecto a v1.4.1

13fuentes adaptadas tienen diferencias, además del reemplazo del inicio/GUI de
demo por TerrainInventory y de las dependencias sustituidas por la base congelada.

| Fuentes | Cambios |
|---|---|
| Camera | Tres orígenes de win2World usan GetCameraEyePosition* en lugar de .eye; destroy usa deallocate en lugar de llamarse a sí mismo. La proyección está implicada directamente en la regresión reproducida. |
| UserInterface | WINDOW_DUMMY uiwn→bwn2; recorridos desde CountShow−1; limpieza de unidades/texttags/índices; propiedad y liberación del timer de clic; refrescar textura y animación tras mostrar. |
| InventoryCore | Table→InventoryTable; guardas de ocultación repetida; quitar llamada duplicada a showPlayer. |
| EquipmentCore | Guardas y contabilidad de DisplayCount al mostrar repetidamente. |
| InventoryItem, EquipHeroModels, EquipItemParser, Table | Renombrar/aislar InventoryTable para convivir con la Table del mapa. |
| InvItemSetups | Remapear I000→V001 y B000→V000 para evitar colisiones. |
| HideInventory | Guardas para inventario inexistente. |
| UnitDex | Excluir dumi/dcst para no disputar userdata con misiles; desactivar generador externo. |
| BonusMod, UnitMaxState | Omitir generación externa de objetos ya importados. |

Los diffs completos están en `local-*.diff`. Se identifican cambios, no se da por
correcto cada uno automáticamente. Los arreglos de recursos no se mezclan con la
prueba de proyección: el A/B sobre la demo conserva su código original restante.

## Objetos y recursos

- uidm, bwn2 y ewin conservan base y todos sus campos tras resolver las cadenas
  WTS. uidm sigue basado en ewsp, con movimiento float y velocidad1.
- e001 sólo cambia la ruta de su modelo para evitar la colisión de importaciones;
  el recurso remapeado mantiene los bytes originales.
- Los29recursos de modelos/texturas de la demo conservados en la integración son
  idénticos. war3mapMap.blp cambia por ser otro mapa, no un recurso del panel.
- dlog pertenece a la copia posterior de conversaciones; no existía en el
  inventario original ni explica la regresión de esta comparación de inventarios.

## Contrastes en el juego

1. Partida preexistente del usuario628515: su mapa es v1.4.1 exacto. Una orden de
   caminar y tres capturas muestran la interfaz manteniendo su ancla.
2. Integración propia629638, otro prefijo: misma prueba breve reproduce el
   desplazamiento/recorte mientras se mueve; se recupera al detenerse.
3. Laboratorio TerrainDev631592: alternancia de origen, en la misma partida,
   confirma desaparición con Camera.eye y visibilidad con el cálculo local en la
   zona probada. No sirve como arreglo por reversión directa.
4. Laboratorio de demo original634043: todos los miembros originales conservados
   salvo war3map.j y su instrumentación mínima de alternancia. Camera.eye mantiene
   el ancla durante movimiento; GetCameraEyePosition* reproduce desplazamiento y
   recorte; restaurar Camera.eye recupera el marco. Modelos, dummies, terreno,
   texturas y restantes rutinas de la demo no cambian entre ramas.

El mecanismo interno de temporización/render no se midió. La mezcla del estado
lógico de Camera con lecturas del ojo renderizado es una interpretación técnica;
la evidencia causal acotada es el comportamiento diferente de las dos ramas.
Ensayo breve local de un jugador; no cubre otras resoluciones ni multijugador.

Las tres partidas propias terminaron con confirmación visible y S, sin SIGTERM.
No se cerró la del usuario. Al devolver el foco al final, su PID ya no existía;
la comprobación de identidad detuvo la acción, sin inferir motivo de su salida.

## Evidencia y continuidad

[Directorio de evidencia](/home/snz/Documentos/ChatGPT/Proyect/work/inventory-original-audit-20261022/)
contiene hashes,42fuentes por versión,13diffs locales,6diffs del autor, objetos
resueltos, comparación de recursos, extracciones, laboratorios y capturas.
`result.json` identifica cobertura y límites. Los laboratorios sólo actualizan el
JASS ejecutable: su WCT no se entrega como fuente editable de esas variantes.

[Incidencia resuelta en los escenarios probados](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-22-163705-inventario-proyeccion-movimiento.md):
corrección pendiente en integración/diálogo, conservando visibilidad en TerrainDev.
Los errores del parser WTS del auxiliar se corrigieron y registraron por separado.

CodeGraph consultado primero en inventory-integration para Camera.win2World,
UserInterface, Equipment.onDisplay y builder; vigente, sin DISABLED/RECOVERING.
Condiciones/módulos y entradas parciales siguen siendo límites estáticos.
Descargas, snapshots, mapas y evidencias se compararon directamente, fuera de los
índices; no se inicializó ni alteró el repositorio descargado. pJASS y ensayos en
motor se ejecutaron por separado. No se modificaron mapas de entrega ni fuentes.

## Fecha de introducción del cambio

Los inputs archivados acotan la edición al21/10/2026 entre13:08:17y13:09:15, hora de Perú: build20261021-130817 aún usa Camera.eye; build20261021-130915 ya usa GetCameraEyePosition*. Es evidencia del intervalo entre builds, no del segundo exacto de edición. Se introdujo durante la integración inicial del inventario en TerrainDev, antes del trabajo de diálogos del22/10. Ver work/inventory-original-audit-20261022/camera-change-timeline.json.
