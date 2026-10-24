# Depuración de Warcraft III Classic 1.27b

Usar [build-warcraft3-vjass-127b](/home/snz/.codex/skills/build-warcraft3-vjass-127b/SKILL.md) y su referencia de entorno para resolver configuración, versiones, APIs y comandos locales. Las rutas son datos que comprobar; no reconfigurar Forge/Wine como consecuencia de un fallo en otro componente.

| Síntoma | Primera frontera que discrimina causas |
|---|---|
| Error de JassHelper | Fuente editable, imports y versión exacta de bibliotecas; diagnóstico inicial frente a errores derivados de macros/módulos. |
| Error de pJASS | JASS compilado e identidad de `common.j`/`Blizzard.j`. pJASS comprueba ese script; no demuestra un fallo visible en partida ni consume vJASS sin compilar. |
| El mapa usa código anterior | Identidad del mapa lanzado y del `war3map.j` reextraído frente a la salida compilada; comprobar también WCT/fuentes del editor si se guardó desde él. |
| Falla un comando de Forge | Destino y perfil concretos del comando. Un destino ausente no invalida automáticamente JassHelper, pJASS, otros editores o `play`. |
| Misil falla en vuelo/daño | Consumidor y núcleo exactos: velocidad por paso, altura/terreno, homing y curvas, filtro/recuerdo de impactos, orden de callbacks y retirada. Consultar la skill de misiles si es la mecánica afectada. |
| Congelación, fuga o carga | Número de instancias, emisiones, grupos/handles, reentrada y límites; comparar trabajo equivalente antes de atribuir una mejora de rendimiento. |
| Desincronización multijugador | Estado sincronizado, RNG, handles y escrituras bajo contexto local. Una compilación o partida de un cliente no acredita sincronización. |

CodeGraph ayuda a localizar símbolos y consumidores en fuentes extraídas, con cobertura JASS/vJASS parcial. Revisar los diagnósticos: no expande todos los módulos/macros ni resuelve todo dispatch dinámico. Una ausencia de arista no demuestra ausencia de uso.

Trabajar sobre la fuente editable cuando exista; si el alcance sólo proporciona JASS compilado para diagnóstico/corrección, indicar ese límite y no afirmar que WCT o el proyecto editable quedaron actualizados. No tocar las demos descargadas originales para ocultar fallos históricos.

Para empaquetado, verificar miembros reextraídos y conservar originales. Para juego/editor, seguir [probar-warcraft3-classic-linux](/home/snz/.codex/skills/probar-warcraft3-classic-linux/SKILL.md) sólo cuando esa prueba esté autorizada. Mantener un escritor por mapa/MPQ y evitar que pruebas concurrentes compartan la misma partida/editor. Un worktree no aísla los prefijos Wine ni archivos externos referidos por rutas absolutas.

Separar los estados: fuente examinada, vJASS compilado, JASS validado, mapa empaquetado/verificado, ensayo en 1.27b y ensayo multijugador. Una advertencia heurística no demuestra un defecto; un PASS de una etapa no cubre las siguientes.
