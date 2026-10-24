# CodeGraph pendiente de aprobación en Claude

- Fecha/origen: 2026-10-23T22:20:21.474961-05:00, Codex /root. Claude Code2.1.310, WDev.
- Síntoma/evidencia: `claude mcp list` en WDev muestra CodeGraph como
  `Pending approval (run claude to approve)`. Dos conectores claude.ai sí conectan.
- Impacto: no se puede acreditar CodeGraph disponible ni usado por Claude aunque
  exista .mcp.json y el backend esté instalado.
- Causa confirmada: falta aprobación de ese servidor de proyecto en este cliente.
  Workspace confiado no equivale a aprobar el MCP. La configuración habilitada
  no tiene a codegraph en enabledMcpjsonServers.
- Estado: pendiente de aprobación y verificación desde Claude. No se cambia la
  confianza ni se elude el aviso durante una auditoría.
- Acciones/verificaciones: `claude doctor` no encuentra fallos de instalación;
  autenticación ya activa. Se continúa prueba independiente del backend y revisión
  de instrucciones/skills; eso no acredita conexión desde Claude.
- Evidencia adicional: docs/planes/auditar-entorno-claude-20261023.md; informe
  final en docs/claude-entorno-verificacion-20261023.md al cerrar esta auditoría.
- Pendiente: aprobación interactiva del MCP por el usuario y consulta real desde
  Claude sobre la raíz de trabajo correcta. No se ejecutaron juego ni jurados.

## Verificaciones independientes y hallazgo documental

- Backend MCP directo: versión1.6.2+jass-vjass.5, consultaRapidFire en TerrainDev/src
  devuelve41símbolos y fuente real. No es una consulta desde Claude ni cambia su
  estado pendiente. Primera consultaMain.j vacía explicada por una entrada que
  contiene sólo imports; no se aceptó como resultado positivo.
- La referencia jass-explore.md describe.3/extracción30 y capacidades anteriores,
  mientras el backend real reporta.5. Este texto antiguo aparece tanto en la
  adaptaciónClaude como en Codex activo y su copia deWDev. Puede inducir decisiones
  incorrectas sobre capacidades/versiones; queda pendiente actualizarlo contra
  JASS-VJASS.md y revisión instalada. No se atribuye exclusivamente a Claude.
- Toolchain: checkerok con4archivos presentes/fingerprintados;9skills estructurales
  comprobadas. Sin cambios de configuración, fuentes o permisos.
- Estado final de la auditoría: abierto. Aprobación MCP y actualización documental
  siguen pendientes; prueba independiente positiva no significa recuperación del
  cliente. Ver docs/claude-entorno-verificacion-20261023.md y evidencia en
  work/claude-entorno-audit-20261023/.

## Recuperación comprobada tras autorización del usuario

El usuario pidió completar el entorno para operar Codex y Claude. Se habilitó
sólo codegraph en ajustes locales de WDev/Proyect/UI Studio y el permiso exacto
de su herramienta de exploración. La confianza de las dos nuevas entradas se
aceptó por el diálogo normal de Claude; no se editó internamente su estado de
confianza ni se desactivó el sistema general de permisos.

Los3clientes CLI de proyecto muestran Connected. Sesiones propias comprobaron
en `/context all` los imports/memorias,9skills y herramienta MCP cargada; `/mcp`
mostró codegraph conectado con1herramienta. Codex consultó las8raíces activas
con resultados positivos. Se mantuvo la distinción entre originales y snapshots.

La guía antigua se reemplazó por una referencia común.5/extracción32/esquema12,
contrastada con JASS-VJASS.md y el backend. Codex activo y copias Codex/Claude
coinciden en SHA256.19validaciones de skills pasaron. No se ejecutaron revisores
ni juego, ni se acreditó una decisión generativa de Claude a partir de un menú.

Estado final: **resuelto**, aprobación y documento recuperados. Evidencia en
work/entorno-compartido-20261023/ y guía docs/entorno-compartido-codex-claude.md.
Las instrucciones de las fuentes activas siguen siendo las que rigen cada tarea.
