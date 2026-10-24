# Captura de portraits para barras

Fecha:23/10/2026 America/Lima, chat de interfaz, UI Studio local/Classic1.27b.
Estado: en investigación.
Al abrir healthbar-portrait-capture.html, ambos retratos quedaron en Cargando
y apareció Failed to fetch a resource: Http Error. Evidencia: consola/IAB
tab8; página inicial sin PNG exportado. Los mapas y retratos activos no cambiaron.
Hipótesis inicial: resolver del MDX no distingue URL resuelta de dependencia.
Se reutiliza el criterio por extensión del visor portrait-source.js existente
y se registra fetchUrl por error para comprobar dependencias.
Pendiente: reintentar captura fija y verificar personajes antes de convertir BLP.

Diagnóstico: dependencias TeamColor/TeamGlow00..15 del motor no estaban
publicadas en el visor; no era un fallo de los retratos. Tras preparar copias
con rutas concretas, IAB agotó plazos10/30s al recargar (incidencia histórica
de IAB). Además se corrigió ENOENT del auxiliar por un nivel relativo incorrecto.
Se descartó la ramaWebGL del entregable y se archivó en work/healthbars-materials-20261023/discarded-webgl.
Alternativa: pose/esqueleto/cámara animada y texelesBLP de los MDX reales se
rasterizan localmente; dos fotosPNG/BLP128×128 revisadas. Preview2D carga
correctamente en IABtab9. No se afirma que WebGL o IAB genérico se hayan reparado.
Estado: cerrado por alternativa comprobada; material recuperado y53mips
de6BLP verificados por dos lectores, mapa activo conservado.

Seguimiento23/10/2026, ajuste de ancho16px: el selectorPlaywright del botón
Restablecer muestra devolvió No node found at given location aunque el DOM
mostraba un botón habilitado. Se obtuvo árbolAX fresco y el botón33 respondió;
estado75/86% recuperado. La captura por boundingRect produjo una región
desplazada; causa entre scroll y coordenadas del backend no confirmada.
Se sustituyó por fullPage, revisada con ambas barras completas. El validador
auxiliar se invocó por error con python3 sinPillow: falló antes de escribir;
se repitió con el entornoPillow existente y pasó igualdadRGBA de6texturas.
Estadoresuelto por alternativas comprobadas. preview-ui.png y
preview-original-thin.png actuales muestran el escenario completo.
Sólo fallaron auxiliares; no se modificó el mapa.

Seguimiento relleno10px: la sesiónREPL había perdido sus variables y cambió
la numeración de navegadores; usar healthbarTab anterior falló como no definido
y browser2 ya era MCPApps. Se consultó inventario actual: IABbrowser1/tab9,
se vinculó, recargó y capturófullPage. Recuperación comprobada enpreview-fill10.png;
ninguna entrada llegó a otra aplicación. Mantiene estado resuelto.
