# Texturas del panel · 22/10/2026

Objetivo: investigar el límite efectivo BLP de Classic1.27b y preparar una
optimización verificable, priorizando preview y conservando recursos activos.
Fuentes: tools/textures.py, portrait-assets.py, model.cjs de dialogue-system;
BLP Specifications(WC3), Dr Super Good, ensayo directo publicado en Hive.

Base: FrameOpenRed/Blue BLP1 paletizados,1024×512, alfa8, mipmaps completos;
1.399.282bytes cada uno. MDX18.580bytes; frame esquelético pequeño, sin horneado
denso como los retratos. Modelos/JASS/UV/geometría/cámara fuera del cambio.

1. Registrar fuente, límites de versión/formato y particularidad RenderEdge del
   perfil de pruebas; no confundir BLP con TGA, ni carga con detalle efectivo.
2. Copia candidata512×256 promoviendo mip1 existente, sin reescribir píxeles;
   conservar paleta, alfa8 y demás niveles hasta1×1. Considerar512×512 como
   alternativa de detalle vertical con mismaUV, sin aprobarlo por su tamaño.
3. Validar cabecera, rangos, tamaños, todos los payloads y decodificación
   independiente; controlar hashes de los recursos activos y MDX sin cambios.
4. Comparación visual de panel rojo/azul y transparencia, en preview separado;
   entregar archivos/ahorro y distinguir validación de archivo/visor de nativa.

Estado: investigación confirma documentalmente límite de mip útil≤512 por
 dimensión hasta1.28, retirado1.29.1.27b permite archivos mayores según el autor.
Perfil local RenderEdge aún no contrastado para ese límite concreto. El candidato
512×256 evita depender de esa extensión. No modificar ni lanzar repetidamente
el mapa de trabajo durante esta evaluación.

Resultado:4candidatos generados y40mips verificados por dos lectores.512×256
copia exacta del mip1,−74,9%;512×512 remuestreo,−50%. Comparador plano publicado
en UI Studio/panel-texture-review/index.html, revisados rojo/azul, cambio de
calidad y referencia. Fuentes y mapa activos sin cambios. Ver exports/LEEME.md
y evidence/panel-textures-512. Alcance nativo/RenderEdge pendiente, no requerido
para entregar esta investigación y muestras separadas.

## Comparación de mapas preparada y probada

22/10/2026: tools/prepare-panel-comparison.py genera copiasA/B aisladas;
CodeGraph consultado antes/después, watcher incluyó el nuevo auxiliar.
Se reextrajeron71miembros: sólo FrameOpenRed/Blue difieren; cabecera512bytes,
JASS, MDX,objetos e importaciones conservados; pJASS pasa.
Antes2cb340dbf906b8da / despuésd29f771227586dd5. TamañoMPQ total:
9.614.934 → 9.414.585bytes(−200.349;−2,08%).

Prueba nuevaSP Classic1.27b/RenderEdge1920x1080 enHDMI-A-1: ambos colores
enA/B revisados; B apertura,revelado,retratos,patrulla y cierre observados.
Sin distorsión ni pérdida importante apreciable en las muestras; no certifica
el mip elegido porGPU ni FPS/memoria. Inicio/race aleatorio cambia terreno/HUD
entre sesiones, por lo que no se afirma igualdad píxel a píxel. Retratos
optimizados de ModelEditor siguen fuera de esteA/B. Procesos propios cerrados.

Manifiesto y rutas: TerrainDev/dialogue-system/evidence/panel-textures-512/latest-map-comparison.json.
Evidencia: work/panel-comparison-native-20261022/.
Incidencia auxiliar resuelta: informes/errores/resueltos/2026-10-22-232730-panel-comparacion-ventana.md.

## Registro de pesos y consideraciones para continuar

Registro solicitado por el usuario el 22/10/2026. Los tamaños siguientes son
bytes de archivo sin compresión MPQ; no equivalen a memoria GPU ni a tamaño
comprimido dentro del mapa. Para presentar KiB, dividir por 1024.

| Recurso | Antes (bytes) | Candidato optimizado (bytes) | Estado |
|---|---:|---:|---|
| Conversation.mdx | 18.580 | 18.580 | Sin cambios de modelo |
| FrameOpenRed.blp | 1.399.282 | 350.706 | Integrado sólo en la copia comparativa 512 |
| FrameOpenBlue.blp | 1.399.282 | 350.706 | Integrado sólo en la copia comparativa 512 |
| Portraits/paladin.mdx | 3.434.919 | 599.239 | Variante fina 0.02 separada; prueba nativa pendiente |
| Portraits/tauren.mdx | 5.919.098 | 1.513.674 | Variante fina 0.02 separada; prueba nativa pendiente |

| Textura conservada | Dimensiones | Bytes | Consumidor |
|---|---|---:|---|
| Signal.blp | 256×256 | 175.942 | Panel: ruido sin señal |
| Portraits/Heropaladin.blp | 256×256 | 74.502 | Paladín |
| Portraits/Minotaur.blp | 256×256 | 87.611 | Tauren |
| PortraitBackground.blp | 8×8 | 1.350 | Panel y retratos |
| PortraitTeamColor.blp | 8×8 | 1.350 | Ambos retratos |
| Line.blp | 8×8 | 1.350 | Panel: línea de despliegue |

Las cuatro dependencias de textura de los candidatos de retratos (dos propias y
dos compartidas) se compararon por bytes con el mapa y son idénticas. No sumar
dos veces las texturas compartidas al calcular el presupuesto total. El panel
Conversation.mdx más sus cinco texturas suma 898.634 bytes (877,57 KiB) en la
copia 512. Sus FrameOpen son 512×256; el modelo y las UV conservan la proporción.

### Estado de integración que no debe confundirse

- El mapa activo `TerrainDev-Dialogue.w3x` y `latest-build.json` siguen en la
  revisión 2cb340dbf906b8da, con recursos anteriores.
- La comparación `exports/panel-comparison-20261022-232339-908878/` contiene
  `TerrainDev-Dialogue-Panel-Antes.w3x` (2cb340dbf906b8da) y
  `TerrainDev-Dialogue-Panel-512.w3x` (d29f771227586dd5). Sólo cambian dos BLP;
  conserva los retratos de 3.434.919 y 5.919.098 bytes. Está probada en SP.
- Los retratos finos permanecen en
  `ModelEditor/exports/dialogue-portraits-optimized/0.02/`, desde la raíz del
  proyecto. Su reducción es de claves de animación, no de texturas. Ver
  [plan de retratos](optimizacion-retratos-dialogo.md) para métodos y cobertura.
- El mapa comprimido A/B pesa 9.614.934 → 9.414.585 bytes: ahorro 200.349 bytes
  (2,08 %). La reducción de los dos BLP sin comprimir es del 74,9 %. No atribuir
  ese porcentaje al mapa entero ni afirmar una mejora de FPS/memoria no medida.

### Pendientes y reglas para una integración futura

1. Priorizar UI Studio para ajustes visuales y hacer una prueba final agrupada
   en Classic 1.27b. Conservar siempre una base y sus hashes para comparar.
2. Al integrar definitivamente las texturas, actualizar la fuente/generación
   que alimenta el builder y la preview. Una copia W3X parcheada no modifica
   el pipeline activo: comprobar una reconstrucción por reextracción y hashes
   para evitar que reaparezcan los BLP 1024×512.
3. Integrar y probar los retratos finos como un cambio separado: ambos actores,
   variantes de reposo, Talk→Stand con mezcla de 200 ms, pausa de texto,
   apertura/cierre y patrulla. Conservar geometría, dependencias, SEQS en orden
   cronológico y sus índices. La preview y los validadores no sustituyen ese ensayo.
4. El mapa todavía importa `FrameRed.blp`, `FrameBlue.blp`, `PortraitAlia.blp`
   y `PortraitX.blp`: 3.150.448 bytes sin comprimir en conjunto. Son recursos
   históricos candidatos a limpieza, NO una eliminación ya realizada. Antes de
   retirarlos, revisar referencias MDX, código, generadores y diseños guardados;
   comprobar consumidores fuera del índice y actualizar `war3map.imp` y builder.
   El ahorro comprimido de esa limpieza debe medirse, no inferirse de esta suma.
5. No asumir un límite universal de textura de 512×512. Distinguir versión,
   formato BLP/TGA, dimensiones del archivo y mip útil. El 512×256 conserva
   exactamente los payloads del mip1 original y siguientes; 512×512 es una
   alternativa remuestreada. La prueba visual con RenderEdge no identifica
   qué mip eligió la GPU. Conservar alfa, paleta, mipmaps, dimensiones y UV.
6. Al informar pesos, identificar artefacto/hash, modelo y texturas separadas,
   recursos compartidos, tamaño sin comprimir y tamaño final W3X. Validar
   dependencias, miembros y cabecera; distinguir pJASS, preview y prueba nativa.

Evidencia de tamaños y miembros: `evidence/panel-textures-512/latest-map-comparison.json`
en la raíz de diálogo; `work` del manifiesto conserva la reextracción A/B.


Actualización23/10/2026:mapa activo94ca3ebf integra barras horizontales y control
compartido básico. El panel y sus retratos conservan los recursos previos; no se
han promovido por esta integración las texturas512 ni los retratosfinos. El
estado2cb340db de este informe describe la base del22/10. Consultar último
latest-build/latest-healthbar-test y materiales-barras-vida.md para el actual.
