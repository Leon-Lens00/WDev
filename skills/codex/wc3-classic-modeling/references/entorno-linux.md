# Entorno local de modelado: CachyOS / Linux

Recuperación del 22 de octubre de 2026. Las rutas siguientes se comprobaron en disco; volver a comprobarlas si cambia la PC. La instalación de esta skill no reanuda conversiones ni experimentos históricos pausados.

## Raíces y herramientas

Raíz recuperada: `/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09`.

- Personajes y herramientas vigentes de esa recuperación: `Personajes-WC3-127b/`.
- Pilotos y scripts V11: `Newborn-WC3-127b/`.
- Fuentes de extracción: `Slendytubbies-Extraction/`.
- Node comprobado: `runtime-linux/node-v22.14.0-linux-x64/bin/node` (22.14.0).
- Módulos: `Personajes-WC3-127b/migracion-linux/runtime/node_modules/`: `war3-model` 4.0.1, `mdx-m3-viewer` 5.12.0, `gl-matrix` 3.3.0. Usar require con esa ruta absoluta o createRequire del package.json de ese runtime; no depender del directorio actual ni del antiguo laboratorio Windows.
- Blender: `runtime-linux/blender-3.4.1-linux-x64/blender`, ejecutado con `--background --factory-startup`. La consulta de addon_utils no encontró complementos de nombre warcraft/mdl/mdx en esa configuración. Esto no demuestra que no existan otros complementos en otra instalación; sí impide prometer exportación MDX directa desde esta configuración. No instalar ni cambiar de Blender por rutina: el flujo de archivos MDL/MDX siguiente funciona fuera de Blender.

## Edición y conversión de archivos

Inspeccionar antes de adaptar `Personajes-WC3-127b/scripts/fallen_core.cjs` y `precise_mdl.cjs`. La primera resuelve los módulos locales y expone `read`, `nodes`, `metrics` y `save(model, salidaMdx)`; save escribe también el MDL hermano y contrasta MDL/MDX. No es un conversor universal de todos los recursos. Sus evaluadores de poses aceptan sólo tracks lineales sin secuencia global; no usarlos silenciosamente con Hermite/Bezier, herencia especial o globales. Su comparación geométrica/esquelética no acredita fidelidad de todo un efecto, eventos o cámaras.

La prueba de preparación utilizó copias de Newborn NPC-30235 y Rangedborn NPC-30119 V11, con lectura principal war3-model, escritura independiente mdx-m3-viewer y relectura. Comparó geometría, materiales, referencias de texturas, secuencias, pivotes y tracks de huesos/helpers; conservó los SHA256 de originales. Evidencia: `/home/snz/Documentos/ChatGPT/Proyect/work/skill-modelado-20261022/`. No aplicar los resultados a otros modelos sin comprobar sus componentes.

Para diseñar o esculpir en Blender se puede usar el ejecutable disponible. Importar/exportar el rig y sus animaciones requiere elegir y probar un puente o complemento real para el archivo concreto; la presencia de Blender no lo aporta. No convertir partículas/estelas del juego a mallas y declarar equivalencia sin revisar su comportamiento.

## Rutas históricas y referencias

La skill se recuperó de `Personajes-WC3-127b/migracion-linux/skills/wc3-classic-modeling/`. Se conservaron el perfil Vinz y los hallazgos de optimización. El proyecto original `wc3 reforg` (laboratorio Vinz y Arcane Lance) no está entre las raíces recuperadas localizadas. Sus rutas `C:/Users/Leon/...` en los perfiles son procedencia histórica, no archivos disponibles para ejecutar o una nueva verificación de esos ejercicios. Si el encargo necesita esos artefactos, localizarlos antes de afirmar que se han leído o reutilizado.

La transferencia de muerte sí está en `Personajes-WC3-127b/animaciones/death-master-v2/TRANSFERENCIA.md`. Leer el estado del candidato antes de usarlo. V11 se documenta en `/home/snz/.codex/skills/optimize-slendytubbies-wc3-127b/references/v11.md`.

En Linux `Listo`, `listos` y `En revision` son carpetas distintas. No fusionarlas ni sustituir principales por candidatos como parte de instalar herramientas. Mapas, compilar y probar en Warcraft requieren sus flujos propios; ni parsear ni exportar acredita aspecto en juego o FPS.
