# Afinado del diálogo y diferencias frente al original

22/10/2026, Classic1.27b; TerrainDev/dialogue-system y UI Studio. Objetivo: corregir la deriva pequeña y que el editor muestre mejor el resultado sin iterar el arte dentro del juego.

## Cambio aplicado

Camera compartida no se modifica en esta fase: SHA fde7cb040982ed99b2986e34513c62b4f3d58e1edc6f74237be37f4162d2caae, misma revisión de restauración. ConversationUI guarda el desplazamiento inicial eye-at de Camera.create; al seguir la unidad reconstruye eye de forma absoluta desde ese vector. Conserva setPosition y win2World originales, ejes, distancia, ángulos y calibración de altura inicial. Evita acumular pequeños deltas en el adaptador de orientación fija del diálogo. No sirve como cámara libre rotatoria sin adaptar ese contrato. Se añaden comandos de ensayo -caminardialogo/-parardialogo (orden nativa, no teleport), separados de la conversación.

UI Studio: modelo y texttags comparten anclas/exportación, pero el render nativo del arte no coincide exactamente con el ajuste empírico de UIText. Se midieron líneas blancas del PNG y de calibrated-moving-0.png, con perfil/procedencia en model-preview-profile.json. modelPreviewRect ajusta sólo arte y retratos de la vista gameplay; la proyección JASS no cambia. El nombre usa el factor1.37 real del renderer y la indicación su tamaño0.017, posición y etiqueta [Esc]. Se conservan fondo/HUD, texto y tamaño elegidos. Selector de presentación recibe nombre accesible explícito; se comprobaron amplio/compacto y se restauró amplio. Textura/modelo/mapa original no editados. Perfil del arte ajustado en captura, no una emulación general del motor.

## Resultado

Mapa final: ea4073c65837ff39b36376a6f4e4923d569a8fbd44fc2df363e9329d3b9dee45. Build /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system/build/20261022-172800-389335. JassHelper release, pJASS y reextracción/conservación de miembros correctos. PID649780: orden nativa de movimiento; x/y cambia desde3184,-5712 a3631.045,-4928.609; capturas fine-final-moving-0..3 muestran marco completo. Borde inferior mantiene736/737/738 en las cuatro, frente a1px de variación anterior. Las diferencias eye lógico/nativo son como máximo0.001 en los registros actuales (antes hasta0.138); target coincide a0.000. Ambas zonas, reinicio repetido, cierre/reapertura y escritura por páginas observados. Una primera ejecución34b7d91d confirmó residual0.001 pero no acreditó su movimiento: monitor incorrecto, descartado.

36/36pruebas Node; incluye puntos de control del arte nativo e invariancia de proyección al ajustar preview. Navegador real: selección amplio/compacto, perfiles, nombre/tamaño e indicación, superposición50% y persistencia, finalwide. editor-final.png es la captura verificada después de actualizar el estado; no usar la primera imagen transitoria. Tipografía del navegador aproximada. No hay ensayo nuevo de compacto en motor, sesiones extensas, otra resolución o multijugador. fine-final-blue.png era intención del nombre: contiene una página roja; no acredita azul en esta corrida. Variantes ya contrastadas en la revisión anterior de esta misma composición; no se reclasifica esa evidencia histórica como nueva.

## ¿Es idéntico al sistema original?

No. Lo restaurado fue la proyección Camera.eye y su configuración; la integración mantiene adaptaciones documentadas. constant-differences.json y camera-vs-original.diff comparan fuentes exactas con saltos normalizados.

| Parte | Respecto al original141 |
|---|---|
| Camera,7constantes originales | Todas iguales: CHECK_DELTAZ -1200/950, SCREEN .544/.302, aspecto, e001 y propietario. También win2World, ejes y valores iniciales de eye/at iguales. |
| Código Camera | Calibración local inicial optativa y su uso al aplicar ZOFFSET; destroy termina con deallocate en vez de recursión. Ninguna edición nueva aquí durante este afinado. |
| UserInterface,11constantes originales | Diez iguales; WINDOW_DUMMY uiwn→bwn2. |
| Código UserInterface | Persisten límites de recorridos, limpieza, timer de clic y refresco de textura/animación al mostrar. |
| Inventory/Equipment y dependencias | Persisten guardas al abrir/cerrar, contabilidad; Table→InventoryTable; rawcodes I000/B000→V001/V000; filtrado de dummies y generación de objetos externa omitida. Fuentes completas en auditoría enlazada. |
| Recursos y unidades originales UI | uidm y29recursos visuales se comprobaron idénticos en auditoría previa; no se editaron después. El dlog/modelo Conversation y el controlador Hpal son la adaptación de diálogo independiente. |
| Diseño de diálogo | Modelo/textos/pool14, profundidad400 y layout son nuestros; no son parámetros del inventario original. Demo de objetos/inventario desactivada en esta copia. |

Auditoría completa de integración: ../../TerrainDev/inventory-integration/COMPARACION-ORIGINAL-20261022.md. Comparación original frente a descarga reciente fue idéntica: la alteración de proyección ocurrió durante nuestra integración, no en el archivo descargado.

CodeGraph consultado antes/después en Camera, ConversationUI y UI Studio. Sin DISABLED/RECOVERING; completeInputs false y despacho/macros candidatos siguen siendo límites estáticos. Compilador,36tests y juego aportan comprobaciones separadas. No se invocaron agentes auxiliares.

PIDs647574/649780 cerrados con confirmaciónS observada, sinSIGTERM, ambos ausentes. UI Studio permanece disponible. Informe del monitor cerrado tras repetir con capturas del monitor obtenido por PID y registros de posiciones. Alcance máximo: Tested in map en1920×1080SP; no aprobación universal ni pixel-perfect de fuente.
