---
name: systematic-debugging
description: "Investigar fallos, regresiones y resultados técnicos inesperados mediante reproducción, trazado de causas y comprobación de correcciones. Usar al depurar código, compilación, integración o ejecución; incluye orientación para Warcraft III Classic 1.27b en CachyOS/Wine."
license: MIT
metadata:
  upstream: "obra/superpowers:systematic-debugging"
  upstream-version: "7.0.0"
  local-adaptation: "Codex y entorno local, 2026-10-20"
---

# Depuración sistemática

Adaptación de Superpowers; [procedencia y archivos de origen](references/provenance.json). Investigar antes de corregir, con una comprobación proporcional al fallo. La instalación no activa revisores, otros procesos de Superpowers ni cambios de entorno.

## Del síntoma a la causa

1. **Delimitar el fallo.** Identificar el proyecto, versión, entrada real y diferencia entre resultado esperado y observado. Leer las instrucciones y configuración pertinentes; distinguir una afirmación del usuario de un comportamiento ya reproducido. Si falta un dato que decide la corrección, preguntar por él y continuar lo independiente.
2. **Observar o reproducir.** Leer el diagnóstico completo y su primera causa útil. Ejecutar la reproducción mínima autorizada y registrar comando/acción, entrada o hash, salida, código y cobertura. Reutilizar evidencia de la misma revisión mientras siga vigente; un proceso que no arrancó, cero casos o una simulación no reproducen el comportamiento objetivo. Si no se reproduce, explicitar la incertidumbre y recoger datos pertinentes.
3. **Localizar la frontera.** Seguir el dato o llamada hacia su origen: productor, transformaciones, consumidor y condición que dispara el síntoma. Comparar cambios recientes y un caso de referencia equivalente. Instrumentar sólo donde permita distinguir hipótesis; no imprimir el entorno completo ni credenciales. Para cadenas largas o esperas, consultar [trazado-y-esperas.md](references/trazado-y-esperas.md).
4. **Contrastar una hipótesis.** Formular qué causa explica el síntoma, qué observación la contradiría y la prueba mínima que las separa. Cambiar una causa a la vez. Separar el arreglo funcional de refactorizaciones o ajustes de rendimiento.

Para Warcraft, leer [warcraft-127b.md](references/warcraft-127b.md) antes de elegir herramientas o interpretar un PASS. En otros proyectos usar su runtime, runner y construcción existentes; no importar recetas de Warcraft ni instalar otro stack por rutina.

## Corregir y verificar

Corregir la fuente que mantiene el proyecto y revisar los consumidores afectados. Conservar originales y trabajar sobre salidas/copias nuevas cuando corresponda. Una solicitud sólo de diagnóstico o revisión no autoriza aplicar una corrección.

Cuando exista un runner apropiado, usar una regresión que reproduzca el defecto y comprobar que detecta el fallo antes del arreglo. Si el comportamiento depende de un motor o interfaz, definir el escenario observable y probarlo ahí dentro del alcance autorizado. No reemplazarlo por una reimplementación de la lógica en otro lenguaje ni fabricar tests que sólo comprueben el texto del cambio. Una edición sencilla no exige una infraestructura de pruebas nueva.

Después del arreglo, repetir el caso que fallaba y las comprobaciones pertinentes a los consumidores modificados. Si sólo se pudo compilar, ése es el resultado; informar qué sigue pendiente. Un resultado válido identifica revisión, entradas, cobertura y evidencia, sin obligar a repetirlo por empezar un mensaje nuevo.

Si un intento falla, incorporar lo aprendido y revisar la hipótesis antes de otro cambio. Tras varios intentos sin avance, detener la cadena de parches, resumir evidencia e inspeccionar causas compartidas/configuración/arquitectura. El número de intentos no demuestra un defecto arquitectónico. Consultar al usuario cuando la solución implique una decisión de alcance o comportamiento que no esté autorizada.

## Entrega y continuidad

Informar síntoma, causa confirmada o sospecha, cambio aplicado si estaba autorizado, comprobaciones reales y límites. Mantener desacuerdos y verificaciones pendientes visibles.

Si la investigación cruza sesiones o deja una decisión importante, registrar en el archivo de incidencias/decisiones o plan existente del proyecto la hipótesis, evidencia, intentos descartados y siguiente comprobación. Enlazar logs extensos en lugar de copiarlos. No guardar esa continuidad únicamente en scratch que se vaya a borrar; no convertir cada ajuste pequeño en un informe nuevo.
