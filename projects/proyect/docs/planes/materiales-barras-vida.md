# Materiales de barras de vida · 23/10/2026

Objetivo autorizado: preparar materiales del diseño de barras aprobado, con
estética del panel de diálogo, retrato estático BLP intercambiable por personaje
y canal de enemigo más largo, cercano a la primera referencia. Classic 1.27b.

Se reutiliza la raíz indexada de diálogo para herramientas; UI Studio/dist para
la muestra interactiva. Salidas separadas en dialogue-system/exports/health-bars-v1;
no se añaden a assets ni al mapa durante esta preparación.

Decisiones: carcasa azul de jugador 128×256; carcasa granate de enemigo 128×512.
Mismo ancho y base; canal de enemigo de más del doble de altura. Retratos estáticos
128×128 derivados de los modelos reales disponibles, conservando procedencia/pose.
Vida normal y crítica separadas de marco/retrato/texto; números dinámicos en la
preview. SVG editables para marcos; PNG y BLP1 alfa8 con mipmaps completos para
materiales. Cada dimensión ≤512, potencias de dos, según presupuesto documentado
en optimizacion-texturas-panel.md; no se afirma límite universal para BLP/TGA.

Fases:
1. Preparar geometría plana editable y contrato JSON de rectángulos/piezas;
   renderizar retratos estáticos desde MDX reales con pose/cámara documentadas.
2. Convertir PNG a BLP1 con escritor ya verificado; comprobar todos los mips,
   alfa, dependencias, dimensiones y pesos con dos lectores independientes.
3. Mostrar materiales en UI Studio: cambiar vida, personaje y tamaño; comprobar
   que ambos usan los mismos archivos exportados. Captura y paquete reproducible.

Criterio: material real reutilizable, enemigo visiblemente más largo, retratos
intercambiables sin duplicar el marco, cero cambio de mapa activo. La preview no
acredita integración nativa, render de motor ni memoria/FPS. MDX/JASS, build de
mapa y ensayo nativo quedan como la siguiente integración, no como hechos de esta fase.

Estado: preparación iniciada; CodeGraph consultado en diálogo, ModelEditor y UI
Studio. Fuentes compartidas de texturas/MDX inspeccionadas; sin modificaciones.

## Entrega comprobada

23/10/2026: materiales preparados en
`TerrainDev/dialogue-system/exports/health-bars-v1/`, relativo a Proyect.
El enemigo usa textura128×512 y contenido128×448 (vMax0.875). Su canal de
325px frente a133px del jugador es2,4436× más alto, con idéntico ancho10px (ajuste posterior desde36/30/16px).
La altura completa visible es448 frente a256px; el relleno se recorta desde
arriba con origen inferior, sin estirar el gradiente. Estas son dimensiones
de diseño; la escala en pantalla es independiente de la resolución BLP.

| Material BLP | Dimensiones | Bytes |
|---|---|---:|
| FrameBlue | 128×256 | 88.562 |
| FrameRed | 128×512 | 175.946 |
| PortraitPaladin | 128×128 | 44.870 |
| PortraitTauren | 128×128 | 44.870 |
| LifeNormal | 16×256 | 12.122 |
| LifeCritical | 16×256 | 12.122 |

Total378.492bytes(369,62KiB) sin comprimir; no es pesoMPQ ni memoriaGPU.
Contratohealthbars.json define rectángulos y dependencias; los marcos no llevan
el retrato ni las cifras pintadas. PNG fuente, PNG de texeles BLP decodificados,
SVG editables y paquetes game/editables separados. Añadir personaje consiste
en preparar foto128×128, registrar fuente/pose/cámara/hash y ampliar el registro
de retratos sin duplicar la carcasa. La publicación actual de nuevos personajes
requiere actualizar ese contrato y volver a verificar materiales.

Implementación reproducible: tools/render-healthbar-portraits.cjs obtiene la pose
y cámara animada del MDX original en Portrait-1 +600ms. tools/healthbar-materials.py
rasteriza la foto estática con geometría/UV/texeles reales; excluye TeamGlow,
usa rojo para TeamColor y fondo opaco oscuro. En Paladín se aplica encuadre
fotográfico1.35 y desplazamientoY−44px a256px; Tauren conserva zoom1/offset0.
Pose/cámara/encuadre/hashes están en manifest.json y sources/*-render.json.
El render local usa textura sin reproducir iluminación completa de Warcraft;
no equivale a una capturaHUD ni a un portrait animado. No se modificaron originales.

Verificación: tools/verify-healthbar-materials.cjs valida6BLP/53mips con
mdx-m3-viewer5.12 y war3-model4.0, coincidencia exacta RGBA entre lectores,
cabeceras1/8/4/1, offsets/tamaños,1×1 final, potencias de dos y dimensiones≤512.
Comprueba aperturas transparentes y contrato de rectángulos/UV. Los PNG usados
en preview coinciden por hashRGBA con mip0 verificado: preview-validation.json.
Ambos ZIP comprobados; reproducir con comandos del LEEME.txt y --pack tras validar.

Preview funcional en `http://127.0.0.1:4317/healthbars.html`, enlazada desdeREADME
de diálogo. Controles reales comprobados:0/20/60/100%, cambio de retrato en ambas
carcasas, fondo de captura/cuadrícula, escala70/150 y restablecer muestra. Sin
errores de consola observados. Capturas preview-ui/critical/zero/variants.png
en el paquete; la pestaña queda abierta como entrega. El fondo de juego es una
captura histórica, las barras superpuestas son preview2D actual.

CodeGraph consultado antes y después en diálogo/UI Studio; nuevos auxiliares
se alojan en raíces existentes. ModelEditor sólo se leyó para reutilizar pose,
cámara y parsers. Los avisos de análisis indirecto JASS de diálogo permanecen
como límites conocidos, ajenos al renderer. Ninguna consulta sustituye el ensayo.

Incidencia de captura resuelta por alternativa comprobada:
[informe](../../informes/errores/resueltos/2026-10-23-092200-barras-captura-retratos.md).
Se descartó la ramaWebGL que dependía deTeamColor/Glow y sufrió timeoutsIAB;
sus fuentes quedaron archivadas en work/healthbars-materials-20261023/discarded-webgl.
No se declara reparado el problema general del navegador con WebGL.

Mapa activo conserva SHA256
`2cb340dbf906b8da9a061a2e4f08f0905e012c018c3e88a63284b2b5e07725be`.
IntegraciónMDX/JASS, actualización por vida real y pruebaClassic siguen pendientes.
Siguiente paso: consumir este contrato en el compositor de UI Studio y en un
modelo plano de interfaz, preservando la cámara/proyección original del sistema;
probar en una copia separada tras agrupar ajustes en el editor.

## Ajuste de anchura del relleno

23/10/2026, corrección visual solicitada por el usuario: relleno algo más delgado.
lifeRect pasa de x46/ancho36 a x49/ancho30 para ambos roles (−16,7%), manteniendo
el centro en x64 y las alturas133/325. Se conserva el marco y la canaleta; las
bandas laterales oscuras quedan simétricas. Normal y crítico comparten el ajuste.
La modificación está en el generador/contrato, por lo que se conserva al regenerar.
Referencia anterior en exports/health-bars-v1/revisions/fill-36-*/.

Ajuste comprobado en UI Studio: vida normal75/86% y crítica20%; capturas
preview-ui.png y preview-critical.png actualizadas. Las seis texturas conservan
sus hashes y sus53mips válidos; cambian sólo los rectángulos de relleno del
contrato, replicados en ambos ZIP. Mapa activo sin cambios.

23/10/2026: el usuario pide acercarse más al grosor de la primera referencia.
Relleno16px centrado(x56), frente a30px previo(−46,7%); también se estrecha
la carcasa vertical de62 a34px. Base del retrato, cifras, alturas133/325 y
proporción2,44× conservadas. Cambian sólo FrameBlue/Red BLP, SVG y contrato;
fotos y rellenos conservan hashes. Todos53mips verificados por dos lectores,
PNG de preview coincide con mip0. Revisados estados normal/crítico en UI Studio.
Muestra y paquetes actualizados; referencia30px archivada enrevisions/fill-30-*.

23/10/2026, petición adicional: adelgazar específicamente el relleno verde.
lifeRect ahora x59/ancho10, centrado enx64 (−37,5% frente a16). Carcasa34px,
base/retratos, cifras y alturas sin cambios. Las seis texturas conservan hashes;
53mips pasan de nuevo, cambia sólo contrato/composición. Vista normal75/86%
comprobada en UI Studio y guardada enpreview-fill10.png. Se actualizan paquetes
y documento para conservar este ancho al regenerar; nativo sigue pendiente.

## Variante horizontal con icono nativo del héroe

Petición23/10/2026: conservar la vertical y preparar otra variante recostada.
La vida mínima queda a la izquierda y aumenta hacia la derecha. Héroe:
barra azul junto al icono nativo superior izquierdo, sin duplicar portrait.
Enemigo: barra granate más larga y foto BLP propia, también horizontal.

Preparación en exports/health-bars-horizontal-v1, raíz de herramientas de diálogo
y preview healthbars.html de UI Studio con selector de disposición. Texturas
≤512 por dimensión; relleno10px y relación de longitudes325/133=2,44×. PNG de
preview debe representar texeles BLP reales; marco/relleno/icono/cifras separados.

Fases: generar marcos horizontales SVG/PNG/BLP y contrato; verificar BLP y mips
con dos lectores; incorporar selector a la muestra, probar0/20/60/100% y ambas
orientaciones; guardar imagen y paquetes separados. La referencia nativa del
héroe en preview procede de la captura de fondo, no de un BLP personalizado.
En cuadrícula se muestra ese mismo recorte para ubicar el anclaje. El selector
de personaje del héroe sólo se usa en vertical; en horizontal lo aportará el
HUD nativo del juego. Mapas e integración nativa fuera de esta variante visual.


Resultado23/10/2026: variante horizontal preparada y seleccionada por defecto en
UI Studio. Relleno10px con anclaje izquierdo; héroe usa referencia del icono nativo
superior izquierdo, sin fotoBLP duplicada. Enemigo conserva foto intercambiable.
Carcasa héroe256×64(contenido224×64), enemigo512×128(contenido448×96);
longitudes útiles133/325px. SeisBLP suman334804bytes(326,96KiB), 53mips.
Generador tools/healthbar-horizontal.py; verificador verify-healthbar-horizontal.cjs.

Verificados:dos lectores independientes concuerdan enRGBA de todos los mips;
PNG usados porUI Studio coinciden con mip0; cabeceraBLP1 alfa8 y dimensionesPOT
≤512. Para últimos mips rectangulares, el lector war3-model recibe dimensiones
mínimas1×1 del subrecurso, como en el verificador vertical. Transparencia del
hueco del retrato y esquinas, recortes y origen de relleno comprobados.

Browser:estados75/86,20crítico,0,100,60; cambio de fotoenemigo aPaladín,
cuadrícula con recorteHUD, vuelta avertical60 y reset horizontal75/86.
Capturas en exports/health-bars-horizontal-v1/preview-*.png; validation.json y
preview-validation.json conservan resultados. ZIP separados de materiales
importables y editables verificados. Los hashes de las seis texturas verticales
y del mapa activo2cb340db permanecen intactos. IntegraciónMDX/JASS y anclaje
nativo siguen pendientes; la captura delHUD no acredita su integración.

CodeGraph consultado antes de edición y tras cambios en raíces diálogo/UI Studio:
healthbar-horizontal.py, verify-healthbar-horizontal.cjs, healthbars.js paint/bar.
Fuentes nuevas presentes y actuales, sin avisos de indisponibilidad. El grafo
excluye exportaciones y no sustituye verificaciónBLP ni prueba enmotor.
Enlaces a planes deREADME/AGENTS comprobados con sus rutas originales correctas.
El ajuste de ruta erróneo del agente se detectó y revirtió; informe:
informes/errores/resueltos/2026-10-23-130612-enlaces-planes-dialogo.md.

## Integración horizontal autorizada23/10/2026

Corrección del usuario:icono enemigo al extremo derecho; usar iconos nativos de
unidad, no fotografías de los retratos. Héroe conserva iconoHUD. Se conserva la
variante vertical previa. Pasos:reflejar carcasa enemiga y ajustar contrato,
resolver iconos desde archivosClassic, actualizar muestra, generar modelosMDX800
con estados0..100 y enlace a vida real, compilar/empaquetar con builder existente,
verificar imports/objetos/JASS y hacer una prueba final agrupada en1.27b.
Cámara, proyección y dependencias originales no se modifican. Alcance actualSP;
no prometer lectura dinámica deiconArt por API inexistente en1.27b:registro de
rawcode→recurso nativo para personajes disponibles, ampliable por fuente.


Cambio de objetivo del usuario durante integración:ocultar el iconoHUD de héroe
por propiedad de un jugadorauxiliar con control compartido y color del controlador;
barra azul completa con iconoArt propio al ladoizquierdo. Hipótesis de ocultación
por propiedad pendiente de ensayo; no se cambia Camera ni el sistemaUI original.
Mapa sólo define slots0/1:se reserva Player10, ausente de slots de usuario. La
alianza de control afecta a todo su ejército, por lo que no se toma un jugador
con unidades ajenas. Hpal comparte visión/control haciaP0 y color derivado deP0.
Se verifica movimiento y habilidad por entrada humana simulada, no sólo órdenesJASS.
Carcasaazul256×128/contenido256×96, vida133px; icono64px. Enemigo se conserva.
Primera integración nativaHUD queda archivada enwork/healthbars-native-20261023/
TerrainDev-native-HUD.w3x ytest-native-HUD.json; vídeo de esa revisión50,87s.


## Resultado final de control compartido ·23/10/2026

Implementado y probado en94ca3ebfd1249033f1ea1f868792d2aac59df659edcf6e96519433427caa3e81.
Player10(propietario auxiliar fuera de slots0/1) posee Hpal; Player0 tiene control
básico y visión compartida. SetUnitColor toma el color dePlayer0. El control
avanzado se deja false:al activarlo aparece un icono nativo lateral de aliado;
el básico lo oculta y mantiene órdenes/habilidades. No fue necesario tocarHUD,
Camera/UserInterface ni usar campos deobjetos no acreditados en1.27b.

Prueba nativaSP1920×1080:selección, panel deórdenes, clicderecho con desplazamiento
real y Luzsagrada medianteL+nuevo clicizquierdo (255→190 maná y curación visible).
Dump confirma owner10/sharedControl1, posiciones3184,-5712→3408,-5418;
registros y capturas enwork/healthbars-shared-native-20261023. Bucle de patrulla,
apertura/escritura/cierre del diálogo, estados normal/crítico/cero y cambio de
iconoobjetivo comprobados. Vídeo final barras-control-compartido.mp4,46,63s.
latest-healthbar-test.json registra alcance ySHA; últimaspartidas cerradas y
closed.json confirma ausencia. LAN no completado:alternativaSP autorizada.

Ambos marcos tienen iconoArt64×64. Azul256×128, contenido256×96; granate512×128,
contenido448×96 e icono a la derecha. Relleno10px, longitudes133/325px(2,44×).
4BLP288752bytes +3MDX112716bytes=401468bytes, sin duplicar iconos internos.
37mips coinciden por doslectores;303estados/606extremos y dependencias validados;
imports reextraídos son idénticos. La vertical aprobada sigue intacta.

UI Studio muestra los mismos texelesBLP y un fondo real nuevo con barrasocultas
y sin icono nativo dehéroe; ya permite comparar ambos retratospropios enmarco.
Mapa, builder, documentación y paquetes actualizados. Registro deiconos actual:
Hpal/otau; incorporar otros exige ampliar registro/modelo/rawcode. Propietario10
reservado:el control compartido afecta a todas susunidades. No se ha validado
multijugador, otrosaspectos, economía/XP ni sistemas deotros mapas con esteowner.

CodeGraph consultado en raícesdiálogo,UIStudio e inventarioantes/después; fuentes
nuevas indexadas sin fallos de vigencia. completeInputsfalse y staticif siguen
siendo límites explícitos; compilador y ensayo nativo aportan evidencia aparte.
Incidencias depreparación y primerintento deicono:resueltas, ver
[informe](../../informes/errores/resueltos/2026-10-23-134500-barras-prueba-nativa.md).
