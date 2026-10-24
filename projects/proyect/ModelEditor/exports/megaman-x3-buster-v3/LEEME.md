# Buster de Mega Man X3 — revisión V3

Warcraft III Classic 1.27b · MDX800. Revisión del 22/10/2026, conservada aparte de V1/V2.

Cuerpo transversal 30% más ancho en A/C y 25% en los orbes respecto de V2; longitud y punta conservadas. Núcleo blanco, capas de color suaves y emisión continua durante Stand. Dos nuevos emisores por proyectil dejan motas coloreadas y chispas claras, con vida0,42/0,32s, dirección trasera y sin ModelSpace: el residuo queda en el mundo al mover el proyectil. Estelas geométricas breves de0,16/0,22s en los busters y0,16s en los orbes. Emisión nueva60+36 partículas/s por pieza; el grupo opcional triplica ese conjunto. No es una medición de rendimiento.

## Piezas

| Carpeta | Componente |
|---|---|
| A-Buster | Pulso cargado individual |
| B-Orbes-individuales/Verde | Orbe verde individual |
| B-Orbes-individuales/Naranja | Orbe naranja individual |
| B-Orbes-individuales/Cian | Orbe cian individual |
| B-Grupo-visual | Grupo orbital opcional con giro local |
| C-Buster-fusionado | Cuerpo resultante de la unión, con aros locales |
| C-Flash-union | Destello de unión, efecto centrado de una sola reproducción |

Los orbes se entregan separados. Para los satélites de C se pueden reutilizar los orbes verde/naranja. El grupo orbital es una alternativa visual; usarlo además de los orbes duplica efectos.

## Importación

Cada carpeta contiene su MDX, MDL editable y siete BLP. Importar el MDX elegido y las texturas con estas rutas exactas:

- `X3BusterV3\Glow.blp`
- `X3BusterV3\Core.blp`
- `X3BusterV3\Band.blp`
- `X3BusterV3\Filament.blp`
- `X3BusterV3\Ring.blp`
- `X3BusterV3\Ribbon.blp`
- `X3BusterV3\Spark.blp`

Las siete texturas son iguales entre carpetas: en un mapa basta una copia de cada ruta. No importar el MDL como otro recurso del mismo modelo. V3 usa su propio prefijo de texturas para poder convivir con V1/V2.

## Contrato para el sistema de proyectiles

+X es el frente. La geometría de vuelo termina en X=0; raíz fija en0,0,0. Birth0–180ms; Stand200–1000ms en bucle; Death1200–1700ms sin bucle. Death detiene la emisión y apaga el cuerpo; permitir que termine antes de eliminar el efecto si se desea ver la desaparición. El flash expande alrededor del origen y no es un proyectil.

El MDX no contiene desplazamiento mundial, seguimiento, colisiones, daño, fusión automática ni asociación a equipos. El sistema externo controla recorrido, orientación y reunión de los dos lanzamientos. Las partículas y halos no son una esfera de colisión y pueden ocupar espacio alrededor del cuerpo.

## Autoría y referencias

Interpretación3D propia de las referencias confirmadas de Mega Man X3 (Capcom), incluido el GIF aportado por el usuario. Geometría y máscaras de este pack creadas para el proyecto. Se estudiaron los originales de Vinz para capas aditivas, núcleo claro, partículas y estelas; no contiene modelos ni texturas de Vinz y no se le atribuye la autoría de esta revisión. Biblioteca original y procedencia conservadas aparte en el proyecto.

Esta es una revisión artística para seguir afinando con las muestras; no se declara reproducción exacta del sprite ni aprobación estética definitiva.
