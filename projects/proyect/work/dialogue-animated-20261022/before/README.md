# Diálogos Classic 1.27b · editor primero

**Modo vigente: unidad + cámara, sin cinemática.** Se crea el Hpal del ejemplo
nativo, seleccionable y móvil. La cámara lo sigue cada10ms incluso con el diálogo
cerrado. No se oculta el HUD ni se abre automáticamente la conversación. Orden:
posición de propietario → Camera.setPosition/aplicar → marco y textos mediante
Camera.win2World. `ConversationBindUnit(u)` permite cambiar el propietario después
de iniciar el prototipo. Dummy visual derivado de uidm original (float, velocidad1,
desbloqueo de altura Aave), conservando el modelo y sin ocultado por escala cero.

Comandos: `-dialogo` abre; `-reiniciardialogo` reinicia aun abierto;
`-cerrardialogo` cierra; Esc/derecha completa y después avanza. Clic derecho mueve
la unidad con el panel abierto. `-vista0`/`-vista1` trasladan la unidad de prueba.
UI Studio incluye **Juego · unidad + cámara**, fondo de HUD real y comparación
**Juego · unidad + cámara + HUD**. El margen3% se mide sobre la zona reservada del
HUD en esta vista; el perfil histórico conserva sus propios parámetros. Los
diseños v1 previos siguen admitidos. Ver `latest-game-test.json` para cobertura de
la revisión actual; las secciones siguientes conservan contexto de calibración.

UI Studio: http://127.0.0.1:4317/ → Conversaciones. El diseño actual sigue la última referencia del usuario: panel de una escala base68 del editor, un poco mayor y más arriba que la muestra azul. `conversation.wc3dialogue.json` es la entrada guardada. El editor permite ventanas amplias/compactas por mensaje, revisar cada página, escritura progresiva, pausa/completado, zoom50/75/100%, colores y comparación de capturas.

El compositor compartido es `/home/snz/Documentos/WarDatsPy/ui-studio/dist/dialogue-layout.js`. El navegador y `tools/story.mjs` usan sus mismos renglones, páginas, fragmentos y posiciones. Cada página admite3renglones y4fragmentos por renglón. El renderer reutiliza14texttags permanentes:12cuerpo, nombre e indicación; no crea uno por letra. Las posiciones se fijan antes de animar. Los nombres demasiado anchos se abrevian con…; se conserva el nombre completo en el JSON.

El perfil `dialogue-font-metrics.js` guarda avances de111glifos medidos en Classic a altura0.027 y1920×1080, incluido español. Las métricas TTF estándar dieron huecos y se sustituyeron por medidas nativas. Las formas tipográficas del navegador son aproximadas; otros tamaños/resoluciones requieren contraste y los glifos sin medidas se avisan. El modo compacto mantiene la letra legible y reduce el marco. El texto fuente conserva los grafemas; la salida JASS normaliza cada prefijo a NFC para la fuente Classic. Colores mediante selector, sin códigos de formato embebidos. Las conversaciones que exceden8190prefijos se rechazan antes de generar datos: dividir en capítulos.

Desde esta carpeta:

```bash
node tools/story.mjs --input /ruta/conversacion.wc3dialogue.json
python3 build.py
```

La preparación genera `DialogueData.j`, `DialogueProjection.j`, `evidence/story.json` y `evidence/composed-story.json`. El builder vuelve a preparar el JSON guardado, compila con JassHelper release y pJASS, empaqueta una copia y reextrae/compara cabecera y todos los miembros. `latest-build.json` identifica el artefacto. El editor no reconstruye automáticamente el W3X. Cambios de texto, presentación, tamaño, color, velocidad y pausas ya alimentan el renderer; retratos nuevos cargados en el navegador aún no se convierten automáticamente a BLP/MDX.

La copia conserva las11bibliotecas base,5utilidades compartidas y3fuentes propias. Inventory/Equipment, sus catálogos y demo están desactivados; la proyección compartida se restauró con autorización del usuario; TerrainDev principal permanece intacto. El modelo MDX800 tiene16vértices,8triángulos,4planos,1hueso billboard y apertura/cierre180ms. Arte: marcos preparados con ImageGen; retratos estáticos provisionales procedentes de la referencia Mega Man aportada por el usuario.

En el mapa: Esc/derecha completa y después avanza; al terminar cierra. `-dialogo` reabre desde el chat normal. Diagnóstico de desarrollo: arriba escribe `Logs/DialogueProjection-N.txt` durante la conversación; `-vista0`/`-vista1` trasladan la unidad a otra zona; `-metricas` muestra la cuadrícula de glifos y Esc recorre sus diez páginas, reutilizando el pool. `-caminardialogo`/`-parardialogo` son órdenes de ensayo de movimiento nativo.
Cámara/posiciones actualizadas cada10ms; letras con reloj propio configurable (30grafemas/s en la muestra).

**Cámara vigente:** win2World vuelve a Camera.eye original. La adaptación de altura
se calibra una sola vez al iniciar, fuera de la proyección, después de aplicar
el controlador. No altera escala, ejes ni frustum del sistema. Probados movimiento,
dos zonas, reinicios, texto largo, rojo/azul y cierre con HUD normal. Referencias
del editor actualizadas con capturas de esta revisión. [Informe de restauración](../../work/camera-restore-20261022/RESTAURACION.md).

El afinado posterior reconstruye eye desde el vector inicial en el adaptador; en
cuatro capturas de movimiento el borde no cambia de fila y el residual lógico/nativo
es≤0.001. [Detalles y diferencias originales](../../work/dialogue-fine-20261022/AFINADO.md).
No se afirma inmovilidad perfecta en cualquier escenario. Compacto con esta revisión, otras resoluciones, sesiones
largas, multijugador y roundtrip NewGen pendientes. La vista del editor aproxima
el motor y su tipografía. Ver `latest-game-test.json` para alcance exacto.
