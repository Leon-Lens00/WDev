# X3: precisión de exportación

Fecha: 2026-10-22, agente ModelEditor, Classic 1.27b / MDX800.
Estado: corregido, pendiente de verificar.

La primera ejecución de src/build-x3.cjs fue detenida por la comparación exacta MDX: alpha, lifeSpan y timeMiddle estaban representados en doubles JS frente a float32 en el binario. No se entregó ese resultado. Se normalizaron esos campos con Math.fround en el constructor, conservando el validador estricto. Verificación pendiente: exportar y releer siete modelos con ambos lectores. Impacto: retraso en la producción; originales ajenos intactos.

## Cierre verificado
Estado final: resuelto mediante corrección o alternativa descrita.
Siete modelos exportados y releídos: comparación binaria exacta PASS; lector independiente war3-model PASS y 299 poses por modelo. evidencia/x3-v1/build.json y verification.json.
