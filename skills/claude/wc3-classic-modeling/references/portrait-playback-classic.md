# Retratos: reproducción y transición en Classic 1.27b

Hallazgo local del 22/10/2026, MDX800, Paladín/Tauren adaptados al panel de
diálogo de TerrainDev. Sirve para investigar una animación que el visor muestra
pero una unidad del juego reproduce mal. No establece requisitos universales
para cualquier MDX, cámara o motor.

## Separar los síntomas

- **Quieto después de Talk:** verificar SEQS, claves, índice elegido, duración,
  contenido del reposo y estado del controlador antes de atribuirlo al bucle.
- **Salto de pose Talk → Stand:** si ambos clips se mueven por separado,
  investigar la mezcla de transición como un problema distinto.
- **Parte del personaje invisible:** comprobar también oclusión del fondo/marco
  antes de añadir caras; no es evidencia de un fallo de animación por sí sola.

## Causa confirmada: SEQS fuera de orden cronológico

El exportador de estos retratos seleccionaba primero reposo principal y Talk,
añadiendo después otras variantes. Copiaba sus intervalos originales, por lo que
la lista SEQS terminaba desordenada. Ejemplo Paladín, inicios en milisegundos:
`[80000, 113333, 86667, 103333, 120000]`.

Además, concatenar claves en ese orden había desordenado tracks KGTR. Ordenar
las claves corrigió esa anomalía, pero el reposo nativo siguió fallando hasta
ordenar **también SEQS** por inicio de intervalo. Control383001b2 frente a
e7b9e535: recuperados los movimientos de cabeza/cuerpo y los ciclos de reposo.
Renombrar clips, cambiar jerarquía por sí sola o suspender la proyección periódica
no recuperó aquel fallo; no presentar esas hipótesis como la causa demostrada.

Al seleccionar/reordenar secuencias para una copia:

1. Inspeccionar el orden real del binario y sus intervalos; el orden de una lista
   alfabética del visor no acredita los índices de SetUnitAnimationByIndex.
2. Para este flujo, conservar los tiempos originales y ordenar las secuencias
   seleccionadas por inicio. Recalcular todos los consumidores de índices:
   reposo, Talk, variantes y datos del editor/JASS. No basta con ordenar SEQS
   manteniendo los índices anteriores.
3. Mantener orden cronológico de claves dentro de cada track. Investigar claves
   repetidas/conflictivas; no borrarlas silenciosamente. Distinguir tracks de
   secuencia global, cuyo dominio temporal es independiente.
4. Releer el MDX generado: en estos pilotos los intervalos son disjuntos y
   crecientes, las claves estrictamente crecientes y el registro apunta al
   nombre/duración esperados. Detectar solapamientos antes de aplicar esta receta
   a otro archivo; no retimar ni imponer inicio cero como reparación automática.
5. Conservar un recurso anterior que reproduzca el defecto y comprobar que el
   validador lo rechaza. Contrastar después reproducción continua, cambio
   Talk/reposo, repetición de variantes, reapertura y movimiento en el juego.

El visor de UI Studio forzaba directamente secuencia/frame y podía mostrar las
poses aunque el orden fallara en el motor. Esa vista, un índice registrado por
JASS o una compilación correcta no acreditan reproducción nativa.

## Bucle y reposos realmente estáticos

Todas las secuencias exportadas de estos pilotos tenían `NonLooping=0`: ya
permitían bucle. No faltaba habilitarlo. No poner ese valor a todos los clips
de otros modelos por costumbre: Death u otras acciones pueden ser no cíclicas.

Tauren `Stand -1` no mostró movimiento en las muestras cada25ms de sus2.667s.
Se conservó en el MDX como referencia y se excluyó sólo de la alternancia que
debía mostrar reposos móviles. No inventar animación ni borrar un reposo quieto
que sea intencionado. El muestreo y el umbral de movimiento pertenecen a este
exportador, no prueban inmovilidad de cualquier curva entre muestras.

## Salto de pose: mezcla independiente del bucle

El dummy `uidm` tenía `uble=0.0`; los actores heredaban ese campo de objeto.
Cambiar sólo `MODL.BlendTime` a200ms no suavizó suficientemente el salto en el
control6df68d55. El candidato2cb340db mantuvo ese MDX y configuró `uble=0.20`
segundos, Real tipo1, únicamente en los dos actores de retrato. El marco
conservó mezcla cero. Relectura de objetos y vídeo nativo mostraron una
transición repartida entre varios fotogramas.

Revisar tanto el valor del modelo como el efectivo de la unidad creada antes
de dar por configurada la mezcla. No extender el cambio a la biblioteca Camera
ni al dummy compartido para arreglar sólo los retratos. Los200ms son el ajuste
local aceptado, no una duración universal ni garantía de una curva idéntica al
HUD original.

UI Studio implementó mezcla lineal de las traslaciones horneadas durante200ms,
desde la última pose mostrada, incluyendo interrupciones y rebobinado. Sus
tests pasan, pero la revisión visual de ese último cambio quedó pendiente por
caídas de IAB. No atribuirle validación visual ni equivalencia exacta con el
motor. La prioridad del editor se mantiene; resolver su incidencia por separado.

## Evidencia y alcance

Estado: **Tested in map**, Classic1.27b SP1920×1080, dos pilotos. No acredita
multijugador, otros formatos, cualquier retrato ni clipping por píxel.

Raíz de fuentes:
`/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system/`.
Implementación: `tools/portraits.cjs`, `tools/portrait-camera.cjs`,
`tools/verify-portraits.cjs`, `src/ConversationUI.j` y `build.py`. Inspeccionar
sus versiones antes de reutilizar; los manifiestos latest son mutables.

- [Informe y límites](/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system/evidence/RETRATOS-ANIMADOS.md).
- [Historial de la incidencia resuelta](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-22-182141-dialogo-marco-jerarquia-mdx.md).
- [Control negativo de SEQS](/home/snz/Documentos/ChatGPT/Proyect/work/dialogue-tauren-hud-20261022/sequence-order-validation.json).
- [Campos de mezcla reextraídos](/home/snz/Documentos/ChatGPT/Proyect/work/dialogue-tauren-hud-20261022/actor-blend-validation.json).
- [Vídeo nativo: pausa, reposo, interacción, patrulla y cierre](/home/snz/Documentos/ChatGPT/Proyect/work/dialogue-tauren-hud-20261022/dialogo-patrulla.mp4).

Mapa del control de recuperación de reposo: `e7b9e535…`.
Mapa final de mezcla/patrulla:
`2cb340dbf906b8da9a061a2e4f08f0905e012c018c3e88a63284b2b5e07725be`.
