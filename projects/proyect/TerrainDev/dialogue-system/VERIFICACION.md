# Retratos y diálogo · comprobado22/10/2026

Prevalecen [informe actual](evidence/RETRATOS-ANIMADOS.md), latest-build.json y
latest-game-test.json. Mapa2cb340db: cuerpo/brazos/tótem originales, bordes interiores
ampliados y profundidad delante del fondo gris. SEQS cronológicas corrigen el
reposo; mezcla de poses200ms suaviza Talk→Stand.47tests Node PASS, JassHelper/pJASS
y contraste Classic1.27b SP1920×1080: pausa, reposo, interacción, patrulla y cierre.
Vídeo real95.7s en work/dialogue-tauren-hud-20261022/dialogo-patrulla.mp4, desde la raíz.
La mezcla nueva del editor tiene tests; su comprobación visual queda pendiente
por caída recurrente de IAB. Las secciones siguientes conservan contexto histórico.

## Afinado vigente — 22/10/2026

Ver [AFINADO](../../work/dialogue-fine-20261022/AFINADO.md) y latest-game-test.json.
Eye absoluto desde vector inicial en adaptador; Camera compartida intacta.
Capturas válidas por PID, movimiento nativo real, borde constante en736..738,
residual≤0.001; ambas zonas/reinicio/cierre correctos.36tests Node. UI Studio ajusta
arte/nombre/indicación con perfil medido y conserva exportación JASS. Compacto sólo
comprobado en editor en esta fase; tipografía/otras resoluciones/LAN siguen fuera
de acreditación. Juegos propios cerrados conS. Lo siguiente conserva historia.

## Revisión vigente — restauración de Camera, 22/10/2026

Prevalece latest-game-test.json y [RESTAURACION](../../work/camera-restore-20261022/RESTAURACION.md):
5777003b…, proyección original y calibración de altura inicial. JassHelper/pJASS,
61miembros y cabecera verificados; reconstrucción final byte idéntica al mapa
probado. Movimiento, dos zonas, reaperturas, rojo/azul, texto dentro del marco,
HUD normal y cierre observados. Residual≈1px y hasta0.138unidades de eye lógico en
los diagnósticos; prueba corta SP1920×1080, compacto/otras resoluciones/LAN no
acreditados.35pruebas Node PASS. Juegos propios terminados conS. Capturas nuevas
incorporadas como referencia de UI Studio; su geometría no cambió.

## Historial anterior

# Verificación vigente · 22/10/2026

Objetivo: UI Studio como lugar principal de diseño; Classic1.27b como contraste final. Entorno CachyOS/Wine, cliente1920×1080. Fuentes y copia aisladas de TerrainDev/inventario.

## Revisión vigente: unidad + cámara sin cinemática

Build `b80ca9d9…`, detalle en `latest-build.json` y `latest-game-test.json`.
35/35pruebas Node; nueva comprobación de plano/anclas/textos compartidos y reserva
HUD, además de la suite previa. Editor probado en navegador: vista de juego,
margen3%, guardado y comparación de captura con opacidad0/50. Evidencia
`work/dialogue-unit-camera-20261022/editor-final.png` en la raíz del proyecto.
JassHelper/pJASS, cabecera y miembros reextraídos correctos.

PID623953: Hpal seleccionado, cámara persistente, sin autoapertura ni cinemática;
HUD/órdenes visibles. Apertura, caminar por orden real de clic derecho, cambio de
zona activo, reinicio y cierre/reapertura, retorno a zona0, páginas y variantes
roja/azul, avance por Esc comprobados. Dummy uidm/float/velocidad1 con Aave recupera
el seguimiento observado; no se aisló el campo individual responsable. Desfase
transitorio pequeño durante movimiento pendiente de medir: interfaz final todavía
no aprobada. Compacto no contrastado en esta sesión. Cierre con S observado y
proceso terminado sin SIGTERM; partida anterior610804 también cerrada con S, y
primera prueba619626 ya había terminado antes de intentar el cierre.

CodeGraph consultado antes/después en las raíces propietarias de diálogo, UI
Studio y dependencias congeladas; consultas finales cameraFrame/dialogueProjection
y ConversationBindUnit/ProjectFrame/FollowCamera vigentes, sin DISABLED/RECOVERING.
Dispatch LoadN.execute sigue como límite estático conocido; las pruebas Node,
compilador y motor se ejecutaron por separado.

Las notas siguientes describen la fase histórica con otro dummy y cinemática;
no sustituyen este resultado ni certifican la nueva revisión.

- **Editor:**34/34pruebas Node (`work/dialogue-composition-20261022/node-delivery.log` en la raíz del proyecto). Cobertura: anchos proporcionales i/W, palabras largas, páginas, párrafos vacíos, grafemas, posiciones estables durante escritura, pool12+2, packing de palabras, nombres largos, migración v1, cuota8190prefijos, colores y reproducción temporal. UI real: mensajes amplio/compacto, segunda página, cambio de escala68%/margen14.4% desde controles, zoom, guardado JSON y lectura WebMCP; persistencia tras recarga. La expectativa de proyección usa tolerancia1e-10, sin cambiar sus cálculos.
- **Perfil nativo:**111glifos, ocho repeticiones por muestra, diez capturas válidas `evidence/metrics-final-00..09.png`, PID589024. `tools/measure-glyphs.py` y `evidence/native-glyph-metrics.json` conservan método/datos. No usar `metrics2-01..09`: repetían la primera página porque la flecha estaba deshabilitada; Esc produjo las diez páginas finales. `_`=15px por120px/8; espacio7px a partir de W+8espacios+W. Las medidas TTF daban huecos: [recuperación](../../informes/errores/resueltos/2026-10-22-151631-dialogo-union-fragmentos.md).
- **Renderer:**pool fijo14texttags. Escritura/páginas/colores y uniones continuas observadas en `composition-final-wide.png`, `composition-final-compact.png`, `ray-wide.png`. Texto ancho y estrecho mantiene anclas. Otros tamaños interpolados, pares de glifos arbitrarios y otras resoluciones no acreditados por este ensayo.
- **Build:**JassHelper release, pJASS, cabecera y miembros reextraídos verificados. Identidad de entrega en `latest-build.json`; manifest/logs históricos en `work/dialogue-composition-20261022/`. El build final retira el experimento SetUnitPosition/tecla abajo; no se relanza el juego sólo por esa retirada. Conserva la fórmula ojo→objetivo, que no demostró resolver el defecto. El texto/datos y el modelo son los contrastados en esta fase; no se declara aceptación nativa general.
- **Fallo persistente del marco:**zona0 puede encajar y zona1 vuelve a recortar, dentro de una misma ejecución (`ray-wide.png`/`ray-zone1-wide.png`). Compacto también muestra desalineación respecto al texto. Orientación por ángulos vs ojo→objetivo y SetUnitPosition vs SetUnitX/Y no resuelven. La lectura de altura de vuelo más terreno no es una lectura independiente del Z renderizado. [Incidencia abierta](../../informes/errores/resueltos/2026-10-22-130405-dialogo-marco-invisible.md); no atribuir una causa sin más evidencia.
- **Cierre:**PIDs584835,589024,592225,596865y601243 cerrados después de observar confirmación y pulsarS; salida verificada, sinSIGTERM. No queda una partida propia abierta. Servidor UI Studio preservado.
- **CodeGraph:**consultado antes y después en dist, dialogue-system y dependencias propietarias inventory-integration. Módulos nuevos incorporados al índice existente; sin DISABLED/RECOVERING. Diagnóstico parcial: LoadN.execute en datos generados se conserva como despacho indirecto candidato; JassHelper/pJASS y ejecución son verificaciones separadas. Las pruebas/evidencias/builds están excluidos del índice y se comprobaron por sus herramientas. No se modificaron APIs ni bibliotecas congeladas.

Estado más fuerte: **Tested in map, con fallo de alineación del marco**. Editor/composición listos para continuar diseñando; interfaz nativa final pendiente. Sin multijugador ni guardado/reapertura en NewGen.
