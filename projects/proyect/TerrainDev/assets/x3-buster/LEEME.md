# Mega Man X3 — Buster, estudio 3D v1

Destino: Warcraft III Classic 1.27b, MDX versión 800. Geometría y máscaras propias construidas a partir de las referencias visuales confirmadas; no son modelos extraídos de Mega Man ni modificaciones de los modelos Vinz.

| Carpeta | Modelo | Uso |
|---|---|---|
| A-Buster | X3_Buster_Cargado | Pulso cargado rosa/blanco con collar azul; reutilizable como segundo lanzamiento |
| B-Orbes-individuales/Verde | X3_Orbe_Verde | Orbe o satélite verde |
| B-Orbes-individuales/Naranja | X3_Orbe_Naranja | Orbe o satélite naranja |
| B-Orbes-individuales/Cian | X3_Orbe_Cian | Orbe de núcleo frío |
| B-Grupo-visual | X3_Grupo_Orbital | Opción con tres orbes y giro local integrado |
| C-Buster-fusionado | X3_Cross_Buster | Núcleo final rosa con collar y aros verdes |
| C-Flash-union | X3_Flash_Union | Destello centrado en el lugar de unión |

Cada modelo incluye MDX, MDL editable y sus cuatro BLP. Las copias de las texturas son idénticas entre carpetas y se importan una sola vez con sus rutas comunes.

## Anclaje y animaciones

Orientación frontal +X. Punta de cada proyectil en (0,0,0), geometría detrás de X=0. Root no tiene traslación. Birth 180 ms, Stand cíclico de 800 ms, Death 500 ms con desvanecimiento. El flash tiene Stand de una ejecución y se expande alrededor del origen; no es un proyectil de vuelo. El grupo y los aros giran sólo en el espacio local. Los glints residuales duran 120 ms.

## Uso de las piezas

Para tu sistema independiente: crea los orbes por separado y aplica sus offsets/órbitas en el código del juego. El grupo orbital es una opción visual adicional; no uses a la vez grupo y orbes en el mismo lugar salvo que quieras duplicarlos. El segundo pulso puede usar A. Al juntarse ambos lanzamientos, el sistema decide cuándo retirar las primeras piezas, reproducir Flash y crear C. Los cuatro satélites de la referencia C se consiguen con dos instancias del orbe verde y dos del naranja, cada una con movimiento definido por tu sistema.

No contienen avance mundial, detección de unidades, fusión lógica, daño ni colisiones. El eje +X sirve para orientar el modelo mediante el sistema que ya utilizas. El tamaño base está en unidades de modelo; usa la escala que necesite tu mapa.

## Importación

Importa los MDX deseados con el nombre/ruta que elijas. Para cada textura elimina el prefijo war3mapImported y usa exactamente:

- X3Buster\Band.blp
- X3Buster\Solid.blp
- X3Buster\Glow.blp
- X3Buster\Spark.blp

Conserva las barras de ruta del gestor de importación de Warcraft. Los PNG de las fuentes quedan en assets/x3-v1 del proyecto; no hacen falta en el mapa. MDL tampoco es necesario en el juego.

## Procedencia

Mega Man X3 y sus diseños: Capcom. Guía principal aportada por el usuario: https://tenor.com/iA3z0BfiPC1.gif (COFFEE_Drinker). Referencias adicionales Retropixel y WeaponsItems, SpriteDatabase / RandomTalkingBush. Archivo, fotogramas y hashes en ModelEditor/references/megaman-x3/procedencia.json. La biblioteca Vinz permanece separada y conserva los créditos de cada recurso.

Esta v1 es una interpretación 3D para revisión visual, no una reproducción exacta del sprite original ni aprobación final del usuario. Validación y límites en VALIDACION.md.
