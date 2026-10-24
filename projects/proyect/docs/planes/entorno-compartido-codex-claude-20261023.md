# Completar entorno compartido Codex/Claude ·23/10/2026

Autorización: «déjala listo al completo para ya poder operar con ambas».
Cerrar las diferencias de la auditoría sin cambiar código funcional ni mapas.

Decisión de alcance: Proyect y UI Studio originales siguen siendo fuentes activas
para ambos clientes. WDev conserva las copias de respaldo y las skills adaptadas;
no crear índices duplicados de esas copias para fingir equivalencia. Si se pide
trabajar una copia como proyecto independiente, preparar sus raíces específicas.

1. Conservar los archivos que se cambien, sin credenciales. Configurar entrada
   CLAUDE.md/imports, skills y MCP en Proyect y UI Studio; alinear entrada WDev.
   Habilitar sólo el servidor codegraph en la configuración local de cada entrada,
   sin habilitar todas las herramientas ni desactivar comprobaciones de permisos.
2. Actualizar jass-explore.md en skill Codex activa y copias Codex/Claude contra
   JASS-VJASS.md vigente: identidad.5, extracción32/esquema12 y límites reales.
3. Verificar CLI Claude, aprobación/conexión MCP, catálogo/contexto de una sesión
   interactiva sin enviar trabajos a otro LLM; validar skills con el auxiliar.
4. Consultar raíces activas por MCP desde los clientes disponibles, con símbolos
   reales y cobertura positiva; toolchain por checker. No ejecutar juego ni jurados.
5. Cerrar o actualizar incidencia de aprobación/documentación según evidencia;
   guardar configuración, comandos, resultados y límites. Documentar el uso
   compartido y sincronización de respaldo sin crear índices padre/solapados.

Fuentes: auditoría docs/claude-entorno-verificacion-20261023.md, instrucciones
activas y docs oficiales Claude Code memory/mcp. Local: Claude2.1.310,
CodeGraph1.6.2+jass-vjass.5. Evidencia en work/entorno-compartido-20261023/.

Estado: configuración y verificación local completadas. Claude conectado en
WDev/Proyect/UI Studio; contextos interactivos muestran memorias,9skills y herramienta
MCP cargada.8consultas MCP positivas por Codex y19validaciones de skills correctas.
Se conservaron los demás permisos/servidores y no se usó bypass. Las sesiones
interactivas propias sólo ejecutaron comandos locales y se cerraron normalmente.

Guía operativa: docs/entorno-compartido-codex-claude.md y guía equivalente WDev.
Incidencia de aprobación/referencia resuelta y trasladada a resueltos. Mantener
las fuentes activas originales; respaldar sólo ajustes versionables, sin permisos
locales, credenciales, bases de índices ni repetir toda la copia de1.3GB.
