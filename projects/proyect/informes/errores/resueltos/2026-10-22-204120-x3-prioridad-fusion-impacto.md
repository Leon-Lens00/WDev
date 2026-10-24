# X3: orden de fusión e impacto dentro de un paso

- Fecha:22/10/2026 America/Lima. Agente raíz, TerrainDev Classic1.27b vJASS, base9eb1cc5c7bd17514a3c0ee416d1fbb565f31468a60b943a6d6101550b437394e.
- Hallazgo de revisión: X3Body.onPeriod resuelve la colisión del segmento completo antes de X3Buster.tryFusion. Si el pulso alcanza al par antes de un enemigo en ese mismo tramo, el evento posterior puede adelantarse a la unión.
- Evidencia: orden de llamadas en src/libraries/X3Buster.j; los51controles anteriores no sitúan un enemigo justo después del encuentro en el mismo tick. Es un defecto del orden implementado, pendiente reproducción específica.
- Impacto: potencial daño75 del pulso en vez del primer impacto150 del fusionado y fusión omitida. No afecta a RapidFire ni al núcleo Missile.
- Acción prevista: prueba en motor que demuestra libre el tramo anterior al encuentro y enemigo en el resto del paso. Separar sweeps en la fracción de encuentro; si algo choca antes, no fusionar. Si los tres siguen vivos, unir antes de continuar.
- Estado: investigación/reproducción. No acreditar ausencia de este defecto con los51PASS anteriores.

## Reproducción confirmada antes del arreglo

Laboratorioef92f092e6f2d028700504a8de65d1a7d80ca5a5f8a3ba3322d50badc4897d88, fuentes de producción9eb1cc5c7bd17514a3c0ee416d1fbb565f31468a60b943a6d6101550b437394e:54checks/1fallo, exactamente el nuevo caso. Se comprueba en motor que el tramo hasta la unión está libre y que un enemigo ocupa el resto del mismo paso. Primer daño observado75; no hay unión adicional (5fusions),185creados/retirados,0activos. Evidencia/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-buster-20261022-201342/20261022-204129/x3-engine.txt. Esto confirma el defecto de prioridad, no sólo una sospecha estática.

## Corrección y recuperación

X3Buster.tryFusion calcula la fracción de encuentro antes de resolver colisiones; X3Body.resolveAt comprueba cada precursor sólo hasta ese instante. Un choque anterior impide fusionar y las piezas supervivientes completan el resto de su paso. Cuando el encuentro está libre, la unión ocurre antes de una colisión posterior. No se modificó Missile, GroundCollision ni RapidFire.

Laboratorio final1a404150b10079226b9489c14d92b36d81ed791ad02cf64e9c807512a93d764e, producción4d4c0b227db9ed30edb4dbdcf233dca616a7fd0d62e4f7283312a60351e2a93a:54checks/0failures; el nuevo caso observa primer daño150 (calibración nativa150),6fusions,190creados/retirados y0secuencias/proyectiles/flashes finales. El mismo caso falló antes del cambio con75. Evidencia/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-buster-20261022-201342/20261022-204528/x3-engine.txt. Estado final: resuelto y regresión ejecutada.
