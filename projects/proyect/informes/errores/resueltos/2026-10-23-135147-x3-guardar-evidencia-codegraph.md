# Guardado auxiliar de evidencia CodeGraph X3

- Fecha: 2026-10-23-135147, America/Lima; agente principal de evaluación X3.
- Entorno: functions.exec JavaScript V8; TerrainDev; ROM original y mod en evaluación, sin cambios productivos.
- Síntoma: `ReferenceError: btoa is not defined` al intentar codificar la respuesta MCP para escribirla mediante Python. La consulta MCP sí terminó, sin fallo de conexión, índice o sincronización.
- Causa confirmada: se supuso una función de navegador que no existe en ese runtime V8.
- Impacto: no se guardó el archivo en ese intento; la respuesta estaba conservada en store. Ninguna conclusión ni resultado físico perdido.
- Acción: recuperar respuesta con load y escribir JSON con apply_patch, sin codificación adicional.
- Verificación: codegraph-src.json existe, parsea con json.loads y contiene content; incluye avisos conocidos de cobertura parcial JASS. No se atribuye validación de ejecución al grafo.
- Estado: resuelto por alternativa de guardado comprobada.
- Evidencia: /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-rom-evaluation-20261023-134543/codegraph-src.json. Reproducción: el mismo runtime no define btoa; no afecta al MCP.
