# Auditoría del entorno Claude ·23/10/2026

Solicitud: comprobar si Claude preparó su entorno para el proyecto al nivel del
entorno local Codex. Auditar sin cambiar configuraciones/aprobaciones ni fuentes.

Puntos de entrada: WDev (checkout GitHub usado por Claude) y Proyect/UI Studio
originales (entorno activo usado por Codex). No confundir copia con fuente activa.

1. Comprobar CLI/autenticación/doctor y configuración filtrada sin leer claves.
2. Revisar importación de instrucciones, nueve skills Claude y referencias locales.
3. Consultar estado MCP desde Claude y probar por separado el backend CodeGraph
   en una raíz ya indexada/autorizada, sin inicializar índices en WDev.
4. Contrastar fuentes/instrucciones activas y evidencias de uso en la sesión
   reciente de WDev; no ejecutar otro agente/LLM ni simular jurados o juego.
5. Guardar resultados y límites. Los cambios del entorno y aprobaciones pendientes
   no forman parte de esta solicitud de comprobación.

Fuentes: configuraciones locales WDev/.claude y .mcp.json, ~/.claude/settings.json,
metadatos no sensibles de ~/.claude.json, documentación oficial Claude Code
memory/skills/mcp y las instrucciones de Proyect. Claude2.1.310 instalado.

Estado: auditoría terminada, preparación parcial acreditada. Instalación/auth y
doctor correctos;9skills enlazadas y referenciasMarkdown comprobadas; toolchain
con4archivos presentes/fingerprintados. Backend.5 probado conRapidFire41símbolos.
CodeGraph en Claude sigue pendiente de aprobación. Se documentaron diferencias
de contexto/raíces y referencia.3 antigua compartida por Claude y Codex.

Informe: docs/claude-entorno-verificacion-20261023.md. Evidencia en
work/claude-entorno-audit-20261023/. Configuraciones y WDev intactos; no se
ejecutó otro LLM, jurados, compilación ni juego. Las correcciones y aprobación
quedan pendientes para una tarea posterior autorizada, no son esta auditoría.
