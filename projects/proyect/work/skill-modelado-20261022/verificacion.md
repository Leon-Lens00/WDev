# Preparación de modelado verificada — 2026-10-22

Recuperada la skill original wc3-classic-modeling con sus dos referencias; añadida referencia de entorno Linux y actualizado el consumidor de optimización V11. La fuente de migración conserva sus hashes. AGENTS.md del proyecto enlaza ambas skills para futuras tareas.

- quick_validate.py: ambas skills válidas, código 0; PyYAML 6.0.3 aislado en validator-env, sin modificar Python global.
- Enlaces Markdown locales de ambas skills: todos sus destinos existen; las rutas Windows históricas se señalan como tales.
- Node 22.14.0; war3-model 4.0.1, mdx-m3-viewer 5.12.0 y gl-matrix 3.3.0 cargados.
- Newborn V11 y Rangedborn V11: lectura de MDX con ambos lectores, exportación a MDL/MDX y relectura; comparación de geometría, materiales, texturas, secuencias, pivotes, jerarquía y curvas esqueléticas. Recuentos conservados: 1415/3707 vértices, 2314/4000 triángulos, 20/40 huesos, 9455/8252 claves, 11 secuencias cada uno. Texturas referenciadas presentes. SHA256 de originales sin cambios.
- Blender 3.4.1 arrancó en background con configuración de fábrica. Sin complementos de nombres warcraft/mdl/mdx detectados en esa configuración. No se acredita un puente Blender↔MDX.

Evidencia reproducible: smoke-models.cjs, smoke-result.json y validation.json en esta carpeta. El script conserva sus salidas y rechaza sobrescribirlas; usar otra carpeta de salida si se necesita repetirlo.

Límites: no se renderizó ni se probó en juego, no se midió FPS ni multijugador, no se procesó todo el catálogo ni se reanudaron conversiones pausadas. La recuperación instala instrucciones y verifica un flujo de archivos real para dos pilotos; las modificaciones futuras requieren comprobar su comportamiento específico.
