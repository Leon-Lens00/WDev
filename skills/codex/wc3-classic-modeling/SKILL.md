---
name: wc3-classic-modeling
description: Crear, editar y estudiar personajes, animaciones, proyectiles y efectos para Warcraft III clásico, usando perfiles de referencia cuando el usuario los elija. Aplicar a trabajo con Blender y modelos MDX/MDL; no a terreno ni scripting de mapas.
---

# Modelado para Warcraft III clásico

Usar esta skill como procedimiento de producción y estudio. Los perfiles son referencias técnicas, no identidades que imitar ni garantías de resultados. No imponer el estilo de un autor si el usuario elige otra dirección.

## Referencias

Cuando se pida aprender de Vinz / Mythic o aplicar sus técnicas, leer [el perfil Vinz](references/vinz.md). Leer los análisis extensos enlazados allí solo para la categoría necesaria.

Destino predeterminado de esta PC: Warcraft III Classic 1.27b, modelos versión 800; respetar otro destino explícito del usuario. Antes de elegir herramientas, leer [el entorno Linux](references/entorno-linux.md): contiene las rutas recuperadas, el flujo MDL/MDX y los límites comprobados. El antiguo documento Windows `wc3 reforg/tools/BLENDER-WARCRAFT.md` no se localizó en la recuperación; no usar sus rutas como comandos Linux ni dar por instalado su puente Blender.

Conservar originales y trabajar en una carpeta de salida distinta, con hashes de entrada. Para cambios de jerarquía, pivotes, curvas o grupos de matrices, comparar deformación y secuencias contra la referencia además de contar elementos. Volver a leer el binario exportado con un lector independiente; comprobar también texturas y dependencias antes de entregar. La prueba visual y en Warcraft se acredita por separado. Usar las skills de construcción y prueba 1.27b cuando el encargo incluya mapa o ejecución en juego.

## Trabajo

- Determinar si se necesita personaje, animación de modelo existente o efecto/proyectil. Respetar el parche conocido; gráficos clásicos no identifica un parche exacto. Avanzar en diseño e inspección mientras falte ese dato, pero resolverlo antes de afirmar compatibilidad.
- Inspeccionar las herramientas disponibles antes de elegir un flujo Blender → MDX/MDL. Una skill no instala Blender ni aporta un exportador. No afirmar que una exportación está validada hasta probar una secuencia y sus dependencias con el flujo real.
- Al generar BLP1 paletizadas con alfa de 8 bits para clásico, usar cabecera coherente: `compression=1`, `alphaBits=8`, `pictureType=4`, `pictureSubType=1`; verificarla directamente junto con mipmaps y píxeles antes de empaquetar. No copiar `pictureType=5`/subtipo `0` de un escritor genérico: produjo glow cuadrado en Arcane Lance. El visor war3-model 4.0.1 ignora esos dos campos y puede mostrar bien un archivo defectuoso. Corrección confirmada por Leon en juego; evidencia en el perfil y `models/arcane-lance/validation/GLOW-FIX.md` del proyecto. No extrapolar esta cabecera a BLP2 u otras compresiones.
- Al recolorear texturas de un modelo, conservar su alfa y comprobar el filtro de cada capa que la usa. Las texturas propias de Burning Rage (Vinz, p. ej. `RoyalGlow02.blp`) son BLP1 JPEG con alfa de 8 bits y van en capas Blend (filtro 2); reescribirlas sin alfa dejó un cráneo violeta macizo sobre la unidad en Dev Mission v14h (captura de Leon, 04/11/2026). Pillow lee esos BLP JPEG con alfa 255 y colores erróneos: decodificar el JPEG del primer mipmap a mano (cabecera común + datos, canales B, G, R, A, invertidos en la salida CMYK de Pillow) y comparar la media de alfa del original y del derivado. Método en `Proyect/work/titulo-devmission-20261026/scripts/efectos_v14h.py` (`jpeg_blp`, `blp1`).
- Para personajes, trabajar silueta y atlas a cámara de juego, luego deformación y movimiento secundario. Para animación existente, revisar esqueleto, secuencias, eventos, attachments y materiales animados antes de modificar. No reemplazar animaciones ajenas fuera del alcance solicitado.
- Para proyectiles, estudiar por separado cuerpo, estelas, impacto y desaparición. Comparar parámetros, ventanas de emisión y variantes; contar polígonos no basta para describir un efecto.
- Preferencia del usuario22/10/2026: mostrar primero los modelos y sus secuencias en un **espacio3D/visor orbital**, con rejilla/ejes y origen visible, antes de abrir Warcraft. Evaluar varias vistas, silueta, núcleo, opacidad, partículas y estelas; una captura plana en juego no sustituye esa revisión. Para el lanzamiento posterior, conservar el método anterior con perfil propio cuando sea necesario. No imponer LAN por la preferencia inicial que el usuario corrigió. Respetar la fase de muestra solicitada sin convertir cada iteración en una aprobación obligatoria.
- Para los proyectiles de Leon, mantener el anclaje de Birth/Stand/Death en el origen; el juego aporta recorrido y orientación. Mostrar por defecto las secuencias centradas. Separar cualquier recorrido de demostración con el tag `Movimiento prueba |`, sin exportarlo al MDX. Esto no prohíbe animación local de piezas, expansión del impacto ni offsets de emisores. No imponerlo a animaciones de personajes con otras necesidades.
- Al interpretar curvas, restar el inicio de la secuencia para expresar tiempos relativos y comprobar si usan una secuencia global. Verificar que las animaciones de textura estén referenciadas por capas antes de atribuirles un efecto visible. Revisar dependencias de modelos en emisores PE1 además de las texturas.
- Verificar autoría por componente en colaboraciones: publicar un paquete o aportar un arma no atribuye al mismo autor el cuerpo y las animaciones. Clasificar recursos por su función real; una máquina con aspecto de edificio puede ser una unidad móvil.
- Convertir el estudio en un ejercicio original revisable. Elegir las técnicas que sirven al encargo; las cantidades de huesos, emisores o resolución de una referencia no son presupuestos obligatorios.
- Conservar originales y procedencia al estudiar recursos ajenos. Guardar derivados separados y respetar créditos y condiciones de redistribución de cada recurso.
- Reportar con precisión qué se verificó: estructura de archivo, reproducción visual o prueba en juego. Reconocer pruebas del usuario como evidencia aportada por él, sin atribuirse su ejecución.

## Aprendizaje persistente

Para retratos que quedan quietos tras Talk, discrepancias entre visor y motor o saltos al cambiar de clip, leer [reproducción y transición de retratos Classic](references/portrait-playback-classic.md). Distinguir orden de SEQS, orden de claves, contenido estático, bucle y mezcla de poses; incluye controles nativos de Paladín/Tauren y sus límites.

Para rehacer un retrato nativo con poco peso, con cámara incorporada y pared invisible, leer [retrato ligero con pared](references/retrato-ligero-classic.md) y usar `scripts/retrato_ligero.cjs`.

Para optimización, conversión con deformaciones, pose Unanimated o fallos al crear unidades, leer [optimización y compatibilidad clásica](references/optimization-classic.md). Incluye los hallazgos de los pilotos Newborn/TDAU y sus límites. Para esos personajes, combinar con `optimize-slendytubbies-wc3-127b`, que conserva scripts, tolerancias y métricas V11. No convertir los resultados de dos pilotos en garantía para otros modelos.

Mantener las evidencias voluminosas en el proyecto: originales, hashes, mediciones, capturas y resultados de pruebas. Mantener en los perfiles solo decisiones reutilizables y enlaces a evidencia. No copiar todo el catálogo a la skill.

Al incorporar una técnica, registrar observación, fuente, aplicación propuesta y estado de validación. Actualizar el perfil con conclusiones de ejercicios reales, distinguiendo hipótesis de resultados comprobados. Una técnica observada en un autor no se convierte automáticamente en regla general. Si cambia la ubicación del proyecto, actualizar el enlace de evidencia; el perfil debe seguir siendo útil por sí mismo.
