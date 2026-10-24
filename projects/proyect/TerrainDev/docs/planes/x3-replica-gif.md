# Réplica visual de la física X3 mediante GIF

Autorización: usuario23-10-2026, implementar aproximación antes de aportar ROMs.
Objetivo: Classic1.27b, fuentes/MDX actuales de TerrainDev; preservar originales,
RapidFire, GroundMotion, Missile y reciclador. La variante comunitaria se
estudiará separadamente cuando se aporte su ROM/parche; no mezclar sus valores.

Base: mapa4d4c0b227db9ed30edb4dbdcf233dca616a7fd0d62e4f7283312a60351e2a93a,
fuentes/manifest y copia de QA archivadas en reports/x3-gif-replica-*/baseline/.
Referencia y límites: docs/x3-investigacion-movimiento-20261023.md, mediciones
originales en reports/x3-motion-research-20261023/. Es aproximación del GIF,
no extracción ni certificación de parámetros SNES.

## Decisiones y fases

1. Ajustar sólo X3Buster: orbes lentos, pulso con aceleración y techo, núcleo
   con arranque lento; satélites con velocidad longitudinal inicialmente
   negativa, aceleración y techo, y componentes laterales verde/naranja
   diferentes. Órbita por edad, independiente de la velocidad.
2. Integrar distancia analítica por edad para evitar que el orden de Euler
   cambie parámetros al variar el paso. Mantener32Hz del motor compartido;
   no prometer64Hz ni tocar otros consumidores para esta mejora visual.
   Separar tiempo, distancia con signo y posiciones XY de las colisiones.
   Resolver el encuentro y los sweeps anteriores al mismo antes de fusionar.
3. Suavizar transición con breve formación del disparo fusionado; conservar
   presupuesto8cuerpos+1flash, MUI, cancelación y propiedad de limpieza.
   No añadir otros sistemas de efectos ni modificar MDX en esta fase.
4. JassHelper/pJASS y build verificado, ampliación de X3Probe para retroceso,
   inversión, aceleración, límite, separación y colisión al regresar. Conservar
   regresiones de prioridad, enemigos, obstáculos, MUI, límite y retirada, más
   las suites de40colores y44RapidFire. Parámetros esperados nuevos deben
   justificarse con la curva elegida, no cambiarse sólo para pasar.
5. Ensayo atendido en perfil aislado, captura/vídeo del resultado, validación de
   logs frescos y cierre de la partida propia. Registrar límites de apariencia,
   muestreo32Hz y ausencia de validación multijugador/ROM. Guardado/reapertura
   del editor no requerido: no se alteran objetos ni el formato de triggers.

Aceptación: comportamiento visible por fases y continuidad de posiciones;
colisiones también durante retroceso; equilibrio de creados/retirados y cero
activos; fuentes compartidas idénticas; entrega compilada/reextraída y motor
comprobado. El GIF tiene retenciones y composición que impiden deducir toda
la física nativa: calibración visual explícita y sustituible al estudiar ROMs.

Estado inicial: inspección CodeGraph de src/scripts y referencias terminada;
implementación y verificaciones pendientes.

## Resultado final

Implementado y probado en mapa. Entregaad594a94d93592d0bdb0a90d38cad420deed8b92ac67179891519b3c16bdc7f1,
X3Buster0.2.0-local-gif. Sólo cambia esa biblioteca; las16restantes y los
recursos permanecen idénticos. JassHelper/pJASS, reextracción y153controles
de motor correctos (69X3,40colores,44RapidFire);15controles negativos
rechazados. Medidas reales: retroceso verde44.555u; velocidades máximas
verde1140/naranja1080;198cuerpos X3 creados/retirados,0activos.

El ajuste verde usa mínimos cuadrados y escala artística2u/píxel, con
v0−626/aceleración4363; no se presentan los valores como constantes SNES.
Se conservan32Hz y las fronteras de colisión XY, W/E discretas y origen fijo.
La fusión usa bisección dentro del paso y barridos anteriores al encuentro.

Hubo dos fallos reales durante la adaptación: usar el reloj largo como ID de
tick (546callbacks/272lecturas repetidas en el ensayo final) y recortar speed
con un alcance redondeado ajeno al destino de Missile. Ambos corregidos y
comprobados; también se corrigieron tiempos/diagnósticos del fixture.
[Informe resuelto](../../../informes/errores/resueltos/2026-10-23-125112-x3-replica-pasos-fisicos.md).

Evidencia completa: reports/x3-gif-replica-20261023-124052/result.json,
laboratorio20261023-130447, reports/verification.json. Vídeo real12.03s
en ese laboratorio, demo-replica-gif.mp4: recorte/escala sin interpolación ni
cambio de velocidad, captura vigilada por PID/foco/geometría. El emisor
repetitivo y actores extra pertenecen sólo al laboratorio.

Instancias propias cerradas. El cierre final requirió SIGTERM al PID propio
revalidado después de mostrar confirmación y no salir por botón; no se afirma
cierre normal. Sin partidas en el perfil propio al verificar. ROM original,
variante comunitaria, carga por mantener tecla y multijugador quedan pendientes
de tareas/evidencia específicas; no son parte de esta réplica por GIF.
