# Planes Warcraft y continuidad del proyecto

## Entorno que determina el plan

Para mapas o código, usar [build-warcraft3-vjass-127b](/home/snz/.codex/skills/build-warcraft3-vjass-127b/SKILL.md) y su entorno local. Resolver las herramientas desde la configuración vigente, sin copiar parámetros de otra instalación. Para vuelo/misiles, usar [crear-misiles-warcraft3-127b](/home/snz/.codex/skills/crear-misiles-warcraft3-127b/SKILL.md) y el núcleo real del proyecto.

Antes de proponer llamadas, inspeccionar las declaraciones/callbacks de la versión exacta. Por ejemplo, homing, arc y curve no tienen necesariamente el mismo contrato en bibliotecas llamadas Missile. Una biblioteca presente puede ayudar con la idea; no obliga a importarla ni demuestra que acepte la combinación solicitada.

## Fases y evidencia: elegir las que correspondan

| Fase | Entregable / comprobación |
|---|---|
| Identificar base | Mapa/fuentes exactos, versión del motor, núcleo/dependencias, rawcodes e imports afectados. Conservar original y definir salida nueva. |
| Modificar fuente | Fuente editable y consumidores coherentes. JassHelper para vJASS, después pJASS con APIs 1.27b del objetivo. Si sólo se entrega código, explicitar dónde termina la integración. |
| Integrar mapa | Objetos, assets y triggers necesarios; empaquetado según el proyecto, reextracción y hash de miembros cambiados. WCT sólo no reconstruye GUI/WTG y objetos. |
| Ensayar comportamiento | Escenario observable en copia de 1.27b: trayectoria, daño/filtros, retirada y recursos, o comportamiento concreto solicitado. Se ejecuta según la autorización vigente con la skill local de pruebas. |
| Ensayar multijugador | Sólo si está en alcance; clientes/condiciones y observables propios. No trasladar a esta fase el PASS de compilación o partida individual. |

No todas las tareas necesitan todas las fases: una modificación de documentación no requiere juego, y una corrección del vuelo necesita más que sintaxis. Un test externo de una fórmula puede servir como referencia matemática; no demuestra que la implementación vJASS o la colisión del motor produzcan ese resultado.

Considerar un solo escritor por mapa y el estado compartido del juego/editor. El plan puede separar análisis de fuentes independientes; la emisión, modificación y prueba del mismo archivo/partida se coordinan. CodeGraph tiene cobertura parcial, especialmente en macros/módulos y llamadas dinámicas: combinarlo con inspección y compilación al delimitar consumidores.

## Qué guardar entre chats

El archivo del plan es el punto de entrada: estado por fase, base del trabajo, decisiones con motivo, evidencia y próximo paso. Si ya existen archivos de decisiones/incidencias, enlazarlos en vez de duplicar sus hechos. Las instrucciones estables van en AGENTS; procedimientos reutilizables, en skills.

Registrar una verificación con comando o acción, objetivo/revisión, resultado observado y enlace a log/captura. Una comprobación prevista lleva ese estado hasta ejecutarse. Si cambian archivos o una decisión, revisar qué evidencia conserva validez: una línea antigua de “completo” no demuestra el estado actual.

Una revisión de `BASE..HEAD` cubre commits. Para trabajo sin commit o mapas/imports nuevos, incluirlos explícitamente mediante inventario/diff y hashes o copia de revisión apropiada. No crear commits sólo para aparentar esa cobertura ni omitir archivos no rastreados.

Los planes y decisiones no se eliminan como limpieza de scratch. Antes de retirar temporales propios, conservar las evidencias que el resultado o una investigación pendiente necesiten. Es continuidad documental del proyecto, no una promesa de que Codex cargue automáticamente todos los archivos en cada chat.
