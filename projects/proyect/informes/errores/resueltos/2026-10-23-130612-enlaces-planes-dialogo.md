# Ajuste incorrecto de enlaces detectado y revertido

Fecha:23/10/2026 13:06 America/Lima. Agente:Codex, variante horizontal de barras.
Proyecto:TerrainDev/dialogue-system, documentación local Classic1.27b.
Estado:resuelto.

Síntoma y evidencia:durante revisión confundí el destino de ../../docs/planes/
y lo declaré roto por comprobar TerrainDev/docs en lugar de resolver el enlace
desde el archivo. El enlace original era correcto. Cambié README a ../../../
y la validación is_file() falló inmediatamente con AssertionError.
Impacto:enlaces incorrectos temporalmente enREADME; sin cambios en juego/materiales.
Causa confirmada:error del agente al contar los niveles de directorio.

Acción:restaurar ../../docs/planes/ y comprobar todos los enlaces con ese prefijo
enREADME yAGENTS resolviéndolos desde p.parent y eliminando el fragmento#.
Resultado:PASS; ambos planes existen. El usuario recibió corrección del aviso.
Límite:esos enlaces en los dos archivos, no una auditoría global de documentación.
