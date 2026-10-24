Estado vigente: RESUELTO para los dos pilotos Classic1.27b SP1920×1080.
Reposo recuperado por SEQS cronológicas; transición suavizada con uble0.20.
La revisión visual de la mezcla del editor sigue en la incidencia de navegador.
Los estados siguientes son historia de investigación.

# Deformación del marco multicapa en Classic1.27b
Fecha22/10/2026, chat diálogo; mapa a6f38ff529e8abde66b4db3b6e82346914d2c9478b622c6c6f31f5742f2daa00.
Estado: investigando. Síntoma: retratos y texto aparecen, marco sustituido por geometría triangular grande; reproducción -dialogo, captura work/dialogue-animated-20261022/game-dialogue.png.
Impacto: integración nativa rechazada; compilación y lectura MDX no lo detectaron. El editor usaba el PNG del marco, por lo que esa comprobación no cubría su jerarquía nativa.
Hipótesis: helperObjectId0 se serializa después de BoneObjectId1/2; matrices apuntan aIDs no canónicos para el runtime clásico. Los originales y el marco previo usan IDs en orden de lectura. Se restituirá un Bone billboard directo para el panel y otro para la línea, IDs0/1, manteniendo sus animaciones y las constantes Camera intactas. Causa pendiente de contraste.

Segundo ensayo a3c3d98ec9cd67af: marco correcto después de canonicalizar huesos0/1. Tauren aún genera triángulos extensos fuera del recuadro. Causa adicional encontrada al revisar la malla recortada: faceGroups conserva969índices del original pero faces contiene438. El visor web ignora ese recuento en su dibujo y no reprodujo el fallo nativo. Se actualizan faceGroups/faceTypeGroups al recortar y se exige igualdad de suma de grupos/índices y validez de cada índice antes de exportar. Pendiente tercera comprobación nativa.

Ensayo de bustos66c855de: torso recuperado, pero nuevos vértices del borde estiran triángulos. La interpolación de posición bind con un grupo de huesos distinto no conserva su posición en pose; se corrige transformando el punto de corte posado mediante la inversa de su grupo de skin. Pendiente contraste editor/motor; evidencia bust-opening-05.png.

## Recuperación comprobada
Estado final: resuelto para los dos pilotos, Classic1.27b SP1920×1080.
El marco con Bone0/1, recuentos faceGroups correctos y vértices de corte calculados mediante inversa de skin corrige las deformaciones. Se añadió validación de coordenadas posadas y muestreo25ms de reposo/habla. El primer busto aún invadía el exterior al gesticular el Tauren (safe anterior29ef, bust-fixed-move-3.png): su copia final fija pecho/hombros en reposo y conserva cuello/cara; margen de escala0.85 y desplazamiento1.5. No se afirma conservar todas las curvas corporales.
Mapa final744544ae287f7937892026696723b61ddfa5dd4b40156095244677908af1bbdf: safe-opening-00..06, safe-move-0..4, safe-left-speaking, safe-zone0/1 muestran marco/bustos correctos, sin triángulos escapados observados. Cierre/reapertura y salidaS verificados. No garantiza cualquier modelo, pose o escala del editor. Evidencias en work/dialogue-animated-20261022, desde la raíz del proyecto.

Preferencia final del usuario: ambos cuerpos en pose fija de reposo y sólo cabeza/cuello/gestos con tracks originales. Aplicado también al Paladín; mapa ce990503fcb35ab0672662d1fd31bf55cd26558ff2a2513d05cf835f2bcb0b46 comprobado en editor y1.27b, stand-left-talk-0..3 y stand-moving.png. Sólo cambia el miembro paladin.mdx respecto744544ae, comprobación en revision-diff.json.

## Reabierto: brazo incompleto del Tauren
22/10/2026, mapa ce990503. El usuario señala brazo truncado. La selección de caras en tools/portraits.cjs excluye huesos4/6/7 (antebrazos/mano); deja extremos de brazos superiores visibles dentro de la abertura. Estado: en investigación con referencia HUD original otau. Se añade unidad estándar y selección de diagnóstico a la copia del mapa; no se alteran originales ni Camera.

AjusteHUD: la conversión de perspectiva sólo en la pose inicial deformaba la cara durante habla; sustituida en Tauren por proyección de cada pose25ms y animación de vértices en MDX800. Ensayo30538c63 funciona en Classic con229nodos, pero deja arriba un fragmento del brazo levantado: final-tauren-talk-3.png. Se retiran ambos brazos completos/tótem de la copia, conservando cuello/pecho, para evitar extremos visibles. Bordes interiores1.2×0.85unidades, contorno exterior sin cambiar. Pendiente último contraste.

## Restitución de tótem y movimiento corporal original
El usuario corrige el criterio anterior: conservar brazos/manos/tótem y después solicita también sus movimientos originales, usando bordes interiores para cubrir sobrantes. Se descarta la retirada de brazos del ensayo intermedio. Al retirar la congelación corporal, `node tools/portraits.cjs` falla antes del build con `Camera portrait exceeds Classic matrix-group byte limit`. Causa confirmada: un grupo independiente por vértice animado supera los 256 identificadores locales de la malla (vertexGroups Uint8Array); no acredita un fallo del motor. Se dividirá la malla en geosets con paletas locales válidas sin congelar el cuerpo; límite global conservador de la herramienta no debe confundirse con el límite local del formato. Pendiente exportación y contraste UI/motor.

Hallazgo del usuario en4c5d62bd: zonas sin modelo/huecos en el Tauren. screen2-idle-5 y variants-native-talk-3 muestran un fragmento superior separado del tótem y parte del cuerpo fuera del encuadre. No se acepta aún la conversión completa. Hipótesis: proyección/perspectiva/clamp de la adaptación, o geometría original pensada para cámara de HUD más estrecha; se contrastará contra fuente sin alterar. La división de paletas permitió exportar402nodos y el motor carga, pero eso no acredita fidelidad geométrica.

Precisión del usuario: pared trasera del tronco, imagen /tmp/codex-clipboard-ac5d75ea-5a0f-4065-b264-8a6d7c4fdefc.png. Se extrae Tauren.mdx de war3.mpq (212765bytes) y se compara con portrait: ambos tienen24vértices y14triángulos de tótem, mismosUV/posiciones con traslaciónY218.278. Al soldar las costuras hay9vértices y cero bordes abiertos: no falta una pared geométrica. La unidad usa material con baseTeamColor opaca y capaMinotaur Blend; portrait usa sólo Minotaur None. Se recupera el material de la unidad en un geoset separado con esas mismas caras y el mismo Bone_Totum_Portrait23; no se añade pared duplicada. Hipótesis de recuperación visual pendiente de contraste. La vista original sin adaptar portrait-source.html confirma que el fragmento de la mano ya existe en la fuente; eso por sí solo no explicaba la pared señalada.

Integridad de variantes: el exportador concatenaba claves en orden de índices seleccionados[1,4,0,2,3,5], que no coincide con sus tiempos absolutos. Se detectan inversiones de frames en unsorted-tracks-before.json. Esto invalida la fidelidad de movimiento de las variantes del mapa5bbb aunque cargue; la corrección ordena las claves por tiempo antes de serializar. Se añade comprobación de orden estrictamente creciente en el binario generado. Capturas previas siguen acreditando material/encuadre, no la alternancia fiel final.

Causa decisiva confirmada por el usuario y por las coordenadas: el fondo gris del marco está enX=-3; el centro de los actores enX=-2 y su geometría alcanzabaX=-4.000000015, por lo que el fondo ocluía parte trasera del tronco. No faltaban caras. Recuperar el material cambió el color pero no corregía esa oclusión: se rectifica esa hipótesis anterior. Se normaliza la profundidad de todas las poses/cámaras a±0.45 local sin colapsar el orden relativo; a la escala máxima1.4 del editor queda[-2.63,-1.37], delante del fondo y detrás del marco. Se añade validación sobre todos los vértices/claves exportados, además del orden cronológico. Pendiente contraste final UI/motor.

Hallazgo adicional del usuario en5bd19d4e: al terminar habla el retrato parece quedarse tieso. Las capturas depth-idle-complete muestran cambios pequeños, pero aún no acreditan transición/reposo nativos correctos. Se mantiene abierta la incidencia y no se acepta la alternancia nativa. Revisando selección por índice, orden de intervalos, clips y ShowUnit por tick. Profundidad corregida observada independientemente en UI y motor.

Diagnóstico adicional: NonLooping=0 en todas las secuencias exportadas, por tanto falta de flagLoop descartada. Medición de traslaciones por clip: Tauren Stand-1 no tiene movimiento (0 en todas las muestras), a diferencia de Portrait1/2/3; mantenerlo2.667s en el ciclo parece congelación aunque esté en bucle. Se conserva exportado para referencia y se excluyen clips inmóviles de reposo automático mediante medición25ms. ShowUnit se limita además a cambios reales de visibilidad y se ejecuta antes de escoger animación; su causalidad aislada no está demostrada. Petición nueva del usuario: Talk continuo durante puntuación, sólo cambiar a reposo al terminar la página; eliminado gate de Wait tanto en editor como JASS. Pendiente prueba de esta revisión.

Ensayo2fcd2bbb: renombrar copias a Stand/StandWork no recupera visualmente el movimiento esperado; descartado y revertido. No se atribuye el fallo a nombres. Se prepara aislamiento: -retratoprueba N suspende selección automática y fuerza un clip, TimeScale1 explícito; permite distinguir controlador de reproducción MDX. Guardia ShowUnit y excluir Stand inmóvil siguen como correcciones limitadas, no como causa general acreditada.

Aislamiento4402eb5f: forzar índices0/2/3 yTimeScale1 con selector automático suspendido no reproduce el movimiento previsto; también con llamadas de proyección suspendidas (-retratoproyectar4). Capturas probe*, projection-off*. Eso descarta atribuirlo sólo al cambio Talk→Idle o a reescalar/proyectar en cadaTick. Se contrasta jerarquía del MDX: todos los vértices cuelgan de un Helperbillboard declarado al final, igual frontera ya problemática del primer marco; candidato nuevo con Bonebillboard0 primero y huesos de vértices hijos1..N, sin cambiar curvas/intervalos. Causa aún pendiente de verificación nativa.

Ensayo383001b2: Bonebillboard0 primero no recupera las variantes iniciales; última secuencia4 sí produce cambios de boca/cejas en last-clip-before-order0..2. No se atribuye causa general a jerarquía. Se conserva ordencanónico de huesos y se corrige otra anomalía del exportador: los propios intervalos SEQS estaban reordenados[1,4,2,3,5]/[1,4,0,2,3,5]. Nuevo export mantiene orden cronológico de fuente y recalcula idle/talk/variantes por registro; pendiente contrastee7b9e535.

Recuperación e7b9e535: SEQS cronológicas corrige el retrato quieto. Las series ordered-idle-* acreditan movimiento automático repetido en ambos pilotos. El usuario confirma recuperación pero señala un salto brusco Talk→Stand al terminar la página. Se conserva abierto para ese ajuste: el exportador fuerza out.blendTime=0. Hipótesis separada del bucle ya resuelto: falta interpolación entre poses de clips distintos. Probar BlendTime200ms conservando secuencias/curvas y contrastar en motor; no declarar transición suave por compilar. Vídeo base conservado como control.

Mezcla: el objeto uidm base declara uble=0.0; los actores lo heredaban. Cambiar sólo MODL.BlendTime a200ms conserva un salto de pose en blend200-real-probe.mp4 (7.66s); no se da por corregido. Se configura uble=0.20 únicamente en dpa0/dta0, preservando cero del marco y parámetros Camera. Pendiente contraste. Entrada rápida wtype no llega a la ventana Wine (chat vacío); esa toma es inválida. ydotool type sí muestra escritura y se usará con foco/PID comprobados.

Recuperación final2cb340db comprobada: JassHelper/pJASS, reextracción y47tests;
validadores MDX/objetos y contraste nativo A/B. El control6df conserva uble0 y
salta; el candidato2cb mezcla durante varios fotogramas. Grabación real final
work/dialogue-tauren-hud-20261022/dialogo-patrulla.mp4: pausa parcial/Stand móvil,
reanudación, reposo automático, interacción, patrulla y cierre total. Identidad
819827/hash2cb/HDMI-A-1/32 registrada, proceso ausente. La falta de bucle no era
la causa (NonLooping0); tampoco nombresStand, proyección periódica o jerarquía
por sí solos. Cuerpo/armas íntegros; fondo gris ya no ocluye la pared del tótem.
Límites: dos pilotos, SP1920×1080; otras resoluciones, multijugador, compacto
nativo y mezcla visual nueva de UI pendientes en sus registros específicos.
