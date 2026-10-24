> Continuación: la ROM del usuario ya fue evaluada el23oct2026. Ver [evaluación original/Zero Project](x3-evaluacion-rom-original-zero-project.md). Las limitaciones pre-ROM de este informe describen su fecha original.

# X3: investigación de suavidad, alcance y fusión

Fecha: 23-10-2026. Destino de la adaptación: TerrainDev, Warcraft III Classic
1.27b, vJASS, CachyOS/Wine. Esta revisión estudia referencias y código: no cambia
el mapa, los modelos ni las constantes de producción.

## Resultado observado

Las cuatro piezas pequeñas del disparo fusionado tienen un retroceso inicial
visible, seguido de inversión del movimiento y aceleración hacia delante.
La versión actual sólo crea cuatro satélites 24 unidades detrás y los mueve
hacia delante a velocidad constante. Ese desplazamiento inicial de aparición
no reproduce la trayectoria del GIF.

El buster central también muestra avance acelerado al comparar fases visuales
equivalentes. No se ha demostrado que retroceda: cambiar el contorno del sprite,
el tamaño del destello o la extensión de su cola no demuestra velocidad negativa
de su posición lógica. No añadirle retroceso por analogía con los satélites.

Antes de fusionar se distingue el paquete orbital adelantado y un pulso posterior
más rápido. El centro de los orbes tampoco conserva un avance uniforme durante
toda la referencia. Nuestra relación constante 600/1100 es una primera
aproximación de Warcraft, no una proporción extraída del juego original.

## Evidencia y medición

Directorio: [x3-motion-research-20261023](../reports/x3-motion-research-20261023/).
Se decodificaron completos los GIF existentes, sin repintado ni interpolación:

- Tenor del usuario: 150×133, 140 fotogramas, 3040ms. Las duraciones varían;
  contiene retenciones de 100–120ms en el destello.
- Retropixel, disparo mejorado: 185×155, 24 fotogramas, 1690ms. Los primeros
  23 duran 30ms y el último 1000ms. Empieza cuando el cuerpo ya está fusionado.
- Retropixel, disparo estándar: 243×47, 25 fotogramas, 1720ms.

Los hashes y metadatos están en `analysis.json` y los JSON por referencia.
`fusion-lenta-4x.gif` amplía por vecino más cercano y multiplica los tiempos
por tres; no constituye una captura nueva ni un ensayo de Warcraft.

Para el satélite verde superior se agruparon píxeles conexos del centro claro
RGB(224,232,224), descartando transparencia y seleccionando el componente
superior del proyectil. Se conservan los componentes originales en
`fusion-white-core-components.json` y las coordenadas en
`trayectorias-medidas.csv`. Cambios de dibujo introducen aproximadamente 1–2px
de incertidumbre: medir un detalle visible no equivale a leer el origen lógico.

| Frame Retropixel | Tiempo del GIF | X del centro claro verde |
| --- | --- | --- |
| 0 | 0ms | 43.85px |
| 5 | 150ms | 21.54px |
| 8 | 240ms | 31.54px |
| 12 | 360ms | 72.54px |
| 14 | 420ms | 105.23px |
| 16 | 480ms | 139.23px |
| 18 | 540ms | 173.23px |

El retroceso aproximado es 22.31px; el mínimo está cerca del frame5. Al final,
entre frames14 y18, el avance del mismo detalle es 17px por frame GIF.
Por tanto hay retroceso, inversión, aceleración y un tramo final compatible con
un límite de velocidad. Las piezas naranja también retroceden visualmente,
pero no se extrajeron aquí constantes ni centroides equivalentes para ellas.

Para el núcleo se comparó el mismo detalle magenta en la misma fase del ciclo
de cuatro dibujos. Frames0/4/8/12/16: X=88.11/96.11/109.11/129.11/155.11px.
Los incrementos a intervalos iguales de120ms son +8,+13,+20,+26px: evidencia
de aceleración visual, sin retroceso entre esas muestras. No prueba lo que
ocurre en cada tick interno. Gráfica: `trayectorias-medidas.png`.

El Tenor contiene otra limitación importante: en frames58–61 el destello ya
aparece cerca de X78, mientras todavía quedan orbes más a la derecha; después
desaparecen y se retiene el destello. No tomar esa composición como una traza
continua del encuentro físico ni deducir de ella un teletransporte. Su origen
como captura nativa ininterrumpida no está acreditado. Véase
`contacto-fotograma-a-fotograma.png`. Es una referencia de aspecto y secuencia;
no basta para reconstruir todas las constantes del juego.

## Código público y posibilidad de extraer la matemática original

Se inspeccionó código público, guardado como evidencia fuera de las raíces
activas, sin instalar herramientas ni importar código al mapa:

1. [MMX3-ZeroProject](https://github.com/justin3009/MMX3-ZeroProject), revisión
   `b1ffc579861b028306bf5db636ed02489bb6eded`. Su `MMX3_Tables.asm` identifica
   `$81:C0E8` como rutina de la espiral y `$81:C54D` como entrada de cuerpo
   combinado/pellets. `MMX3_OriginalLocations.asm`, líneas1677–1704, modifica
   la tabla `$86:BBA0` y anula cuatro bytes en `$81:C5AF` para cambiar la
   dispersión. Es una pista concreta para investigar la ROM original, pero
   esos datos activos pertenecen a un mod. Hay tablas comentadas alternativas;
   no se ha probado que sean bytes exactos de la versión original. El bloque
   `Zero_SpiralBusterWIP` es además una reimplementación incompleta: no copiarlo
   como matemática acreditada de X.
2. [MegamanX3SNESRecomp](https://github.com/mstan/MegamanX3SNESRecomp), revisión
   `371c3e83b97c258ac553430742b2f79d7e93ebe9`. Admite X3 USA y genera código
   localmente desde una ROM aportada por el usuario; no publica ese código
   derivado. Su documentación de símbolos reconoce una sola etiqueta semántica
   de X3 (`Emulation_RESET`), aunque tenga muchos límites de instrucción
   identificados. No es una descompilación comentada del buster lista para usar.
   Licencia del proyecto: PolyForm Noncommercial1.0.0; no se incorpora al mapa.

La ROM USA soportada por ese proyecto tiene SHA256
`65b03268afac296330e8ff8d60dd0825879e13ed658b37713c034a3bd074f1d7`.
No se hallaron archivos `.sfc`/`.smc` al buscar nombres en este proyecto,
`/home/snz/Documentos/MCP W3/` y `/home/snz/Descargas/`. Esto no prueba que
no exista una ROM en otra carpeta o dentro de un archivo comprimido.

Sí es técnicamente posible recuperar posiciones, velocidades, aceleraciones,
límites y transiciones desde una copia propia de la ROM: verificar región/hash,
observar escrituras de los objetos de disparo alrededor de las entradas
anteriores, desensamblar sus rutinas y registrar una ejecución por tick.
Hay que determinar formato fijo, orden de integración y condiciones de cambio;
no asumirlos por un comentario. Contrastar después la traza con vídeo sin mods.
No se realizó esa extracción ni se descargó una ROM en esta investigación.

La galería alternativa Fandom rechazó la consulta; se siguió con las referencias
locales verificadas. [Incidente y cierre por alternativa](../../informes/errores/resueltos/2026-10-23-123234-x3-galeria-remota.md).

## Contraste con producción y propuesta de adaptación

Se ejecutó CodeGraph MCP antes de inspeccionar fuentes, raíz
`/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src`, consultas concretas sobre
`X3Buster.j ORBIT_SPEED PULSE_SPEED FUSED_SPEED tryFusion merge X3Body resolveAt
Missile.j acceleration` y `Missile.j move acceleration vel distance recycle
TIMER_TIMEOUT`. Devolvió fuente actual con cobertura parcial y avisos conocidos
de proyecciones/condicionales; no es una validación de ejecución SNES o Warcraft.

Comprobado en fuente:

- Orbes600, pulso1100, núcleo1200 y satélites700 unidades/s, constantes.
- Unión: destello y creación inmediata de núcleo y cuatro satélites en abanico
  con ángulos fijos. No hay fase de arranque frenado/aceleración ni inversión.
- Órbita ligada a distancia dividida por velocidad constante. Con aceleración
  deberá definirse explícitamente por edad/tabla de fase, sin reutilizar esa
  equivalencia como si siguiera siendo cierta.
- Missile común avanza a32Hz. `.speed` es distancia por paso y `.acceleration`
  incremento por paso; no reciben directamente unidades/s y unidades/s².
  La distancia acumulada también usa velocidad con signo. No acreditar un
  movimiento de retroceso y su vida útil cambiando sólo un campo.

Una aproximación local adecuada, pendiente de calibrar, es dar a cada cuerpo
su posición longitudinal propia y una ley por fases. Para satélites:
`v(t)=min(vmax,v0+a*t)` con `v0<0` y `a>0`; integrar de forma continua hasta el
límite y continuar linealmente después. El giro ocurre en `-v0/a`. El núcleo
puede arrancar con velocidad pequeña no negativa y aceleración propia, sin
atribuirle un retroceso no comprobado. Las componentes laterales de verdes y
naranjas necesitan parámetros separados; un abanico de rayas rectas no basta.

Mantener sin cambios el núcleo compartido de Missile y las habilidades
RapidFire/GroundMotion. Evaluar una cadencia propia o representación interpolada
para X3 y medir coste/resultado en1.27b antes de prometer mayor suavidad. Las
colisiones deben barrer la posición real, incluido el retroceso, y conservar
prioridad temporal de encuentro frente a impacto, limpieza y vida acotada.
Una cadencia mayor por sí sola no reproduce la aceleración ni el arranque.

Los138 controles anteriores prueban la versión actual en1.27b; no prueban
fidelidad al SNES. Para una revisión futura habrá que añadir trayectorias por
edad, continuidad de la unión, inversión, velocidad límite, colisión durante
retroceso y regresión de la prioridad ya corregida. Esta investigación no
ejecutó nuevas partidas ni compilaciones y no presenta esas mejoras como hechas.
