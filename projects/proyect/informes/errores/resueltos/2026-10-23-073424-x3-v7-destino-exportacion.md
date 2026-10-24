# Destino incorrecto del primer build V7
Fecha23-10-2026. ModelEditor, MDX800, agente principal.
Síntoma: build V7 escribió MDX/MDL y build.json en V6; verificador V7 rechazó build.json ausente. La causa fue require('./x3-effect-kit-v6.cjs') retenido al copiar el builder. El kit define el destino. No se probó ese artefacto en juego.
Impacto: carpeta exportada V6 y evidencia build.json alteradas temporalmente. ZIP V6 intacto SHA7f11f56dfaeb2ccc21791188e44812ec5c894b8f5cef02b348ddb8cdc68eb50a.
Recuperación: restauración exacta desde ese ZIP, comparación SHA de todos sus miembros y retiro a papelera sólo deX3BusterV7 creado dentro deV6. build.json recuperado de procedencia.json del paquete V6.
Estado: corregido, falta comprobar build/export V7 y el destino de ambos paquetes.

Recuperación comprobada: todos los archivos V6 idénticos byte a byte al ZIP, ZIP SHA intacto, build.json V6 apunta a MDX e9842e...f25d. V7 apunta a su propia carpeta, MDX09d138...67fd5, relectura estricta/independiente y311poses aprobadas. Se agregó guarda de destino al builder. Visor recargado con V6 correcto y V7 nuevo. Estado: resuelto.

Comprobación adicional: ejecutar builder con guardas vuelve a producir mismo MDX V7 sin alterar ningún miembro V6. Archivo build-destination-check.json. Prueba nativa V7 posterior150capturas y cierre0; datos en native-verification.json.
