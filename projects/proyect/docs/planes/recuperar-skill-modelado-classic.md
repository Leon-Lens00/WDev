# Recuperar preparación de modelado Classic

Fecha: 2026-10-22. Objetivo autorizado: resolver la dependencia wc3-classic-modeling ausente y dejar instrucciones útiles en esta PC para MDL/MDX versión 800, Warcraft III Classic 1.27b. No modificar los modelos originales ni reanudar trabajos históricos pausados.

## Base y decisiones

La copia existe en Personajes-WC3-127b/migracion-linux/skills dentro de Slendytubbies-WC3-recuperado-2026-10-09. Se recupera esa fuente, conservando referencias y su procedencia, en /home/snz/.codex/skills/wc3-classic-modeling. No se necesita crear una skill diferente ni indexar código fuera de las raíces CodeGraph autorizadas. Las rutas Windows históricas se distinguirán de las rutas Linux verificadas; no acreditar exportador Blender por la mera presencia del ejecutable.

## Entregables y comprobaciones

1. Recuperar la skill y sus referencias; guardar copia y hashes en work/skill-modelado-20261022. Estado: recuperada en disco.
2. Adaptar rutas de entorno y la referencia V11 de la skill de optimización. Preservar criterios de rig, curvas, BLP y autoría. Estado: completada.
3. Validar ambas skills con quick_validate.py, enlaces locales y lectura/escritura/relectura de copias de Newborn y Rangedborn V11 con los módulos locales. Comprobar Blender en background sin modificar preferencias. Estado: completada, ambas skills válidas y dos modelos comprobados.

Aceptación: la dependencia existe con nombre correcto y referencias accesibles; validadores pasan; el flujo de archivos MDL/MDX queda comprobado en dos modelos reales con fuentes intactas. Esto no acredita importación/exportación MDX en Blender, aspecto en juego, multijugador ni todos los modelos.

## Incidencias

- informes/errores/resueltos/2026-10-22-122308-skill-modelado-ausente.md
- informes/errores/resueltos/2026-10-22-122737-validador-skills-pyyaml.md

Trabajo completado. AGENTS.md enlaza las dos skills; originales y copias de migración conservan sus hashes. Evidencias en [verificacion.md](../../work/skill-modelado-20261022/verificacion.md), [validation.json](../../work/skill-modelado-20261022/validation.json) y [smoke-result.json](../../work/skill-modelado-20261022/smoke-result.json). No se ha probado un exportador Blender ni se han repetido pruebas en juego; no son requisitos para cerrar la dependencia de instrucciones ausente. Cada futura edición de modelos requiere su validación específica.
