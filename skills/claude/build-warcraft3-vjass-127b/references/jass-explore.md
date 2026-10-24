# CodeGraph original con soporte local JASS/vJASS

Instalación activa: `/home/snz/Documentos/MCP W3/codegraph-vjass`, basada en el
CodeGraph upstream v1.6.2, commit `6560052a6f856855d3f71eee838fd66ccfa4285d`.
El extractor/resolvedor JASS/vJASS está integrado dentro del original: no llama a
jassgraph ni depende de Go. Reutiliza SQLite/FTS, consultas, exploración, impacto,
persistencia y sincronización incremental del original.

Servidor MCP `codegraph`, herramienta principal `codegraph_explore`. El registro
se guarda en `/home/snz/.codex/config.toml` (Codex) y en `.mcp.json` de la raíz del repo (Claude Code; requiere aprobar el servidor al abrir la sesión). El catálogo de un chat anterior puede
requerir recargar MCP o iniciar una sesión que lea la configuración. El puente
anterior `wc3-jass-explore` está desactivado, conservado como alternativa manual.

## Alcance y uso

Elegir la raíz explícita del proyecto del usuario; no indexar todo el taller ni
otro mapa como muestra. CodeGraph escribe su índice `.codegraph/` en la raíz
elegida; no modifica fuentes ni mapas. Necesita fuentes de texto extraídas: no
extrae por sí solo `.w3x`, `.w3m`, `.wct` o `.wtg`. Crear el índice si preparar ese
proyecto está dentro de la tarea autorizada; no crear índices de proyectos ajenos.

```bash
/home/snz/.local/bin/codegraph init /ruta/fuentes --yes
/home/snz/.local/bin/codegraph query Nombre --path /ruta/fuentes --json
/home/snz/.local/bin/codegraph explore 'Init Nombre' --path /ruta/fuentes
/home/snz/.local/bin/codegraph sync /ruta/fuentes
/home/snz/.local/bin/codegraph index /ruta/fuentes
```

En MCP, pasar `query` con nombres concretos y `projectPath` con la raíz elegida,
especialmente si el servidor arrancó sin proyecto predeterminado. El original
expone por defecto sólo `codegraph_explore`; las demás consultas se conservan en
CLI/API y pueden habilitarse mediante la configuración original de herramientas.

## Interpretación

Reconoce `.j`, `.jass`, `.vjass`, declaraciones, natives, parámetros, variables,
constantes, bibliotecas/scopes, structs, interfaces, módulos, campos y métodos.
Resuelve referencias compatibles con ámbitos léxicos, visibilidad privada,
prefijos `public`, callbacks explícitos, tipos declarados de receptores y herencia.
Conserva ambigüedad/receptores desconocidos sin escoger un método por semejanza.
Las relaciones llevan `metadata.jassStaticSubset`; no son demostraciones del motor.

La revisión local 3 añade proyecciones estáticas acotadas de textmacros con
argumentos simples y módulos anidados entre fuentes indexables. Conserva el
contexto thistype de cada consumidor y ámbitos de origen para helpers privados.
Los miembros generados se anclan a la invocación; su docstring conserva el origen.
La fuente devuelta sigue siendo la del disco, no un cuerpo generado editable.
Los imports sólo enlazan archivos dentro del alcance ya indexable, sin abrir
rutas externas. Cambios y borrados JASS reextraen los consumidores JASS aunque
sus bytes permanezcan iguales.

Resuelve algunos helpers execute/evaluate nombrados, ExecuteFunc literal global,
operadores getter/setter y receptores simples de factories/arrays con tipo
conocido. Los ciclos, ambigüedades y casos no admitidos conservan diagnósticos.
Sólo simplifica condiciones simples thistype.miembro.exists demostradas por
declaraciones públicas incondicionales del mismo struct, incluida su negación.
Sigue siendo soporte **parcial**: sin Zinc, hooks/delegates, evaluación general
de static-if/debug, data-flow completo, dispatch de valores de function-interface,
strings calculados o cadenas arbitrarias. Tampoco implementa toda la semántica
de herencia/destructores, macros con escapes o módulos generados por macros.
Consultar JASS-VJASS.md para límites exactos; complete sólo es estado de indexado.

Usar JassHelper/pJASS con las APIs del mapa para compilación y compatibilidad
Classic 1.27b. Este grafo no valida recursos, desync, ejecución ni multijugador.

## Entorno y mantenimiento

El lanzador usa el Node 24.16.0 del paquete linux-x64 original, aislado en
`/home/snz/.local/share/codegraph-vjass/runtime/`; no utiliza ni cambia el Node 26
del sistema. Conserva el kernel original para los otros lenguajes. Telemetría y
comprobaciones de actualización están desactivadas en este lanzador.

`codegraph --version` muestra la base 1.6.2; la identidad MCP/daemon es
`1.6.2+jass-vjass.3`, diferente del upstream para evitar compartir el daemon
equivocado. No ejecutar `upgrade` sobre esta variante: reemplazaría el soporte
local. Para actualizar, conservar el parche y volver a aplicar/comprobar cambios.
La extracción vigente es 30; reconstruir índices de revisiones anteriores y recargar los
servidores MCP ya abiertos para evitar que sigan ejecutando la revisión anterior.

Capacidades y límites detallados: `JASS-VJASS.md` en el checkout. Evidencia:
`/home/snz/Documentos/ChatGPT/Proyect/work/codegraph-original-vjass-20261020/`.
La validación local no incluye la evaluación A/B de agentes con Claude/Sonnet ni
certifica ahorros de tokens o soporte completo de vJASS.

Como alternativa de lectura, el jassgraph anterior sigue disponible por su CLI;
no mezclar sus candidatos léxicos con las relaciones resueltas de CodeGraph sin
conservar su procedencia.
