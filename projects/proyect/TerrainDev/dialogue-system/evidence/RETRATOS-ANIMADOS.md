# Retratos del diálogo · estado22/10/2026

Objetivo: Classic1.27b/MDX800, HUD normal, unidad móvil con cámara; UI Studio primero.
Esta revisión sustituye la decisión histórica de torso fijo: se conservan cuerpo,
brazos, manos, tótem, cuello/cara y las curvas originales antes de convertirlos.

## Recuperaciones comprobadas

El supuesto hueco del tótem era oclusión: el fondo gris está enX=-3, actor enX=-2
y parte del modelo alcanzabaX=-4. Se normaliza la profundidad local a±0.45;
a escala máxima1.4 queda por delante del fondo y detrás del marco. El validador
comprueba todos los vértices/claves lineales. UI y juego muestran la pared
recuperada; editor-depth-corrected.png y depth-native-talk-2.png en work.

El tótem original no tiene caras ausentes: mallas portrait/unidad comparten24UV
vértices,14triángulos y, soldadas,9vértices sin bordes abiertos. Se conserva esa
malla; se recupera la base opaca TeamColor y la capaMinotaur Blend de la unidad
original para recuperar sus colores. No se añade una pared ficticia.

Bordes:16quads adicionales hacia dentro (1.2horizontal/0.85vertical), sin alterar
los7quads originales ni el contorno exterior. Frame final23quads/46triángulos.
Camera compartida conserva SHAfde7cb040982ed99b2986e34513c62b4f3d58e1edc6f74237be37f4162d2caae.

## Movimiento y reposo: recuperación comprobada

La cámara original animada y todas las poses elegidas se muestrean cada25ms y se
convierten en animación por vértices. No se congelan huesos del cuerpo ni se
retiran brazos/tótem. Las paletas de geoset se dividen a≤240IDs locales; nodo
 global uint32 no implica presupuesto universal de motor. Pilotos:238nodos Paladín,
425Tauren. Curvas exportadas ordenadas por tiempo; el intento anterior tenía661
tracks con inversiones. Validación en evidence/portrait-validation.json.

Registro único para editor y JASS:3clips de reposo móviles por piloto, duraciones
originales. Tauren Stand-1 está conservado en el MDX pero excluido del ciclo
porque todas sus muestras son estáticas; repetirlo2.667s parece congelación.
NonLooping=0 en las secuencias: no falta habilitar el bucle en el archivo.

El usuario solicita Talk continuo mientras se escribe la página, incluidas
comas/puntos; reposo sólo al completar la página (o pausa explícita). Gate de
puntuación eliminado en editor/JASS.47tests Node pasan, incluido ese contrato.
ShowUnit se limita a cambios de visibilidad; su causalidad aislada no acreditada.
El cambio experimental de nombres aStand/StandWork no resolvió la diferencia y
se revirtió. La selección registrada por JASS se contrastó finalmente en motor.

Causa confirmada del retrato quieto: la lista SEQS estaba en orden de selección,
no de intervalos originales. Ordenar las claves KGTR no bastaba. El control
383001b2 conserva ese defecto; e7b9e535 cambia el orden de SEQS y recalcula los
índices del registro. El motor reproduce ahora giros de cabeza y movimiento de
cuerpo/cara, con repetición de los tres reposos. El control negativo independiente
rechaza los recursos anteriores y acepta los actuales (sequence-order-validation.json).
Paladín: ciclo18.533s; Tauren:14.666s, excluyendo Stand-1 estático2.667s.
Jerarquía canónica y ShowUnit sólo al cambiar visibilidad se conservan, pero no
se atribuye a ellos la causa aislada del reposo quieto.

Evidencia nativa: ordered-idle-paladin.png, ordered-idle-tauren.png, ordered-moving-0..3,
ordered-reopened-1.png; ordered-closure-final-3.png acredita cierre total.
Los diagnósticos -retratoprueba N y -retratoproyectar N son sólo de desarrollo;
-retratoauto restaura el modo automático. El ensayo final usó el automático,
con una comprobación adicional explícita de Talk del Paladín por índice.

## Editor, compilación y límites

UI Studio127.0.0.1:4317 usa MDX/BLP reales del marco y retratos; no scissor de
retrato. Fondo/HUD son captura histórica y tipografía aproximada. Screenshot
editor-ordered-final.png muestra un reposo móvil seleccionado manualmente; el intento posterior de volver a automático agotó espera. Caídas recurrentes del navegador
siguen abiertas; servidor y fuentes conservados.

JassHelper release/pJASS, reextracción y preservación de cabecera/miembros
comprobadas por build.py. latest-build.json y latest-game-test.json identifican
el mismo W3X 2cb340dbf906b8da9a061a2e4f08f0905e012c018c3e88a63284b2b5e07725be,
probado en motor; ninguna modificación del mapa después de ese contraste.
LAN no inició: fallbackSP autorizado. Pruebas propias enHDMI-A-1; preservar
instancias ajenas y comprobar coordenadas/monitor/workspace además dePID.
No acreditar multijugador, otras resoluciones, compacto nativo ni cualquierMDX.
La interpretaciónFOV, muestreo25ms y overscan bajo el marco no equivalen a un
recorte por píxel del motor. Teletransporte instantáneo tiene incidencia aparte.

Evidencia de esta fase: work/dialogue-tauren-hud-20261022 en raíz del proyecto.
Fuentes originales en work/dialogue-animated-20261022/originals y Tauren-original-unit.mdx.
Recuperación: [modelo/controlador](../../../informes/errores/resueltos/2026-10-22-182141-dialogo-marco-jerarquia-mdx.md). Incidencia abierta:
[navegador](../../../informes/errores/2026-10-22-190100-ui-studio-vista-navegador.md).
CodeGraph consultado antes/después en dialogue-system y ui-studio/dist, sin estados
de recuperación. JASS completeInputs=false y LoadN.execute son límites conocidos;
compilador, tests y motor son verificaciones independientes.

## Mezcla y vídeo final

Después de recuperar el bucle, el usuario señaló el salto Talk→Stand. El dummy
uidm tiene uble=0; los retratos heredaban ese campo. Cambiar sólo MODL.BlendTime
no basta (control6df68d55). Se configura uble=0.20 en dpa0/dta0 y BlendTime200ms
en sus MDX; dlog sigue con0. Relectura de objetos en actor-blend-validation.json.
Control nativo blend200-real-probe.mp4 frente a blend-unit-probe.mp4: la nueva
transición reparte el cambio de pose durante varios fotogramas. Se suaviza el
salto; no se acredita una curva idéntica al HUD original para cualquier modelo.

UI Studio incorpora mezcla lineal de las traslaciones horneadas por200ms, desde
la pose mostrada incluso si se interrumpe.47tests, incluidos inicio/final,
interrupción y rebobinado. La nueva vista tab7 volvió a fallar al crearse: este
ajuste del editor todavía no tiene contraste visual; screenshot previo no lo
acredita. La implementación del visor no es una garantía de interpolación exacta
idéntica al motor.

Vídeo final: [dialogo-patrulla.mp4](../../../work/dialogue-tauren-hud-20261022/dialogo-patrulla.mp4).
95.7s, H2641920×1080/30fps, sin audio ni cortes de acciones; sólo remux faststart.
0:03apertura;0:06pausa parcial con Stand móvil;0:13reanudación;
0:23reposo automático;0:44y0:54avance/interlocutor;1:00–1:26patrulla;
1:31cierre. Las dos imágenes pausadas conservan el mismo texto visible mientras
los retratos cambian de pose. Mínima diferencia de redondeo impide igualdad
binaria de píxeles; medidas/tolerancia en pause-visual-validation.json.
Patrulla usa IssuePointOrder("patrol"), sin teletransporte. La cámara compartida
no cambia. Capturas patrol-start/out/return/closed, identidad/hash/monitor32HDMI,
timeline y decodificación íntegra conservados. PID819827 ausente después de
confirmación de salida observada; no se envió S porque ya había terminado.
