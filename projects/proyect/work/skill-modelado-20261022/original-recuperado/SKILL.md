---
name: wc3-classic-modeling
description: Crear, editar y estudiar personajes, animaciones, proyectiles y efectos para Warcraft III clásico, usando perfiles de referencia cuando el usuario los elija. Aplicar a trabajo con Blender y modelos MDX/MDL; no a terreno ni scripting de mapas.
---

# Modelado para Warcraft III clásico

Usar esta skill como procedimiento de producción y estudio. Los perfiles son referencias técnicas, no identidades que imitar ni garantías de resultados. No imponer el estilo de un autor si el usuario elige otra dirección.

## Referencias

Cuando se pida aprender de Vinz / Mythic o aplicar sus técnicas, leer [el perfil Vinz](references/vinz.md). Leer los análisis extensos enlazados allí solo para la categoría necesaria.

En el equipo de Leon está preparado un flujo local documentado en `C:/Users/Leon/Documents/ChatGPT/wc3 reforg/tools/BLENDER-WARCRAFT.md`: Blender 5.2 para diseño/importación mediante puente, Blender 3.4.1 portátil para MDL/MDX. Consultar ese documento antes de reinstalar complementos o afirmar soporte completo. El puente no reproduce todos los efectos y su exportación probada es básica.

## Trabajo

- Determinar si se necesita personaje, animación de modelo existente o efecto/proyectil. Respetar el parche conocido; gráficos clásicos no identifica un parche exacto. Avanzar en diseño e inspección mientras falte ese dato, pero resolverlo antes de afirmar compatibilidad.
- Inspeccionar las herramientas disponibles antes de elegir un flujo Blender → MDX/MDL. Una skill no instala Blender ni aporta un exportador. No afirmar que una exportación está validada hasta probar una secuencia y sus dependencias con el flujo real.
- Al generar BLP1 paletizadas con alfa de 8 bits para clásico, usar cabecera coherente: `compression=1`, `alphaBits=8`, `pictureType=4`, `pictureSubType=1`; verificarla directamente junto con mipmaps y píxeles antes de empaquetar. No copiar `pictureType=5`/subtipo `0` de un escritor genérico: produjo glow cuadrado en Arcane Lance. El visor war3-model 4.0.1 ignora esos dos campos y puede mostrar bien un archivo defectuoso. Corrección confirmada por Leon en juego; evidencia en el perfil y `models/arcane-lance/validation/GLOW-FIX.md` del proyecto. No extrapolar esta cabecera a BLP2 u otras compresiones.
- Para personajes, trabajar silueta y atlas a cámara de juego, luego deformación y movimiento secundario. Para animación existente, revisar esqueleto, secuencias, eventos, attachments y materiales animados antes de modificar. No reemplazar animaciones ajenas fuera del alcance solicitado.
- Para proyectiles, estudiar por separado cuerpo, estelas, impacto y desaparición. Comparar parámetros, ventanas de emisión y variantes; contar polígonos no basta para describir un efecto.
- Para los proyectiles de Leon, mantener el anclaje de Birth/Stand/Death en el origen; el juego aporta recorrido y orientación. Mostrar por defecto las secuencias centradas. Separar cualquier recorrido de demostración con el tag `Movimiento prueba |`, sin exportarlo al MDX. Esto no prohíbe animación local de piezas, expansión del impacto ni offsets de emisores. No imponerlo a animaciones de personajes con otras necesidades.
- Al interpretar curvas, restar el inicio de la secuencia para expresar tiempos relativos y comprobar si usan una secuencia global. Verificar que las animaciones de textura estén referenciadas por capas antes de atribuirles un efecto visible. Revisar dependencias de modelos en emisores PE1 además de las texturas.
- Verificar autoría por componente en colaboraciones: publicar un paquete o aportar un arma no atribuye al mismo autor el cuerpo y las animaciones. Clasificar recursos por su función real; una máquina con aspecto de edificio puede ser una unidad móvil.
- Convertir el estudio en un ejercicio original revisable. Elegir las técnicas que sirven al encargo; las cantidades de huesos, emisores o resolución de una referencia no son presupuestos obligatorios.
- Conservar originales y procedencia al estudiar recursos ajenos. Guardar derivados separados y respetar créditos y condiciones de redistribución de cada recurso.
- Reportar con precisión qué se verificó: estructura de archivo, reproducción visual o prueba en juego. Reconocer pruebas del usuario como evidencia aportada por él, sin atribuirse su ejecución.

## Aprendizaje persistente

Para optimización, conversión con deformaciones, pose Unanimated o fallos al crear unidades, leer [optimización y compatibilidad clásica](references/optimization-classic.md). Incluye los hallazgos de los pilotos Newborn/TDAU y sus límites. Para esos personajes, combinar con `optimize-slendytubbies-wc3-127b`, que conserva scripts, tolerancias y métricas V11. No convertir los resultados de dos pilotos en garantía para otros modelos.

Mantener las evidencias voluminosas en el proyecto: originales, hashes, mediciones, capturas y resultados de pruebas. Mantener en los perfiles solo decisiones reutilizables y enlaces a evidencia. No copiar todo el catálogo a la skill.

Al incorporar una técnica, registrar observación, fuente, aplicación propuesta y estado de validación. Actualizar el perfil con conclusiones de ejercicios reales, distinguiendo hipótesis de resultados comprobados. Una técnica observada en un autor no se convierte automáticamente en regla general. Si cambia la ubicación del proyecto, actualizar el enlace de evidencia; el perfil debe seguir siendo útil por sí mismo.
