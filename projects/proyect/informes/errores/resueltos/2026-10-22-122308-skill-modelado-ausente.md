# Dependencia de modelado no localizada

- Fecha: 2026-10-22T12:23:08.243646-05:00. Agente: Codex, chat de preparación de editor de modelos.
- Proyecto/entorno: /home/snz/Documentos/ChatGPT/Proyect, CachyOS; objetivo documentado Warcraft III Classic 1.27b, modelos versión 800.
- Revisión: contenido instalado de optimize-slendytubbies-wc3-127b consultado en esta sesión; sin cambios de código.
- Estado: abierto.
- Síntoma: la skill de optimización indica aplicar también `wc3-classic-modeling`, pero esta última no aparece en el catálogo de sesión ni en los archivos SKILL.md de /home/snz/.codex y /home/snz/.agents.
- Evidencia: lectura de /home/snz/.codex/skills/optimize-slendytubbies-wc3-127b/SKILL.md y búsqueda `rg --files --hidden /home/snz/.codex /home/snz/.agents -g SKILL.md -g '!node_modules' -g '!.git'`, filtrada por wc3/modeling/modelado/warcraft/slendy. La búsqueda devuelve optimización y skills de construcción/misiles/prueba, sin wc3-classic-modeling.
- Impacto: no se puede declarar completo el conjunto especializado para edición general de modelos. No se ha intentado transformar ni validar un modelo.
- Causa confirmada: referencia a una skill no localizada en las raíces examinadas. Hipótesis: instalación pendiente, renombrada o situada fuera de esas raíces.
- Acciones/verificaciones: comprobada presencia y contenido de optimización; revisado catálogo y ambas raíces. Sin instalación ni modificación de skills.
- Pendiente: localizar o preparar la skill de modelado y comprobar sus herramientas cuando se concrete el primer trabajo. La existencia de otras herramientas fuera de estas raíces no se ha descartado.

## Investigación y recuperación en curso

La copia original se localizó en `/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/migracion-linux/skills/wc3-classic-modeling/`. Causa: copia preservada fuera de las raíces de descubrimiento activas. Se recuperará conservando sus referencias; los enlaces Windows se distinguirán de rutas Linux comprobadas.

## Recuperación comprobada — 2026-10-22T12:31:46.299563-05:00

Estado final: resuelto. Se recuperó la skill original en `/home/snz/.codex/skills/wc3-classic-modeling`, preservando referencias de Vinz y optimización. Se añadió entorno Linux, se actualizaron referencias V11 y se enlazaron ambas skills en AGENTS.md del proyecto. Se conserva la copia fuente de migración con hashes idénticos.

`quick_validate.py`: código 0 para ambas skills. Ocho enlaces Markdown locales válidos. Node 22.14.0 cargó war3-model 4.0.1, mdx-m3-viewer 5.12.0 y gl-matrix 3.3.0. Lectura con dos lectores y exportación/relectura de Newborn y Rangedborn V11 en salidas separadas: geometría/materiales/texturas/secuencias/pivotes/jerarquía/curvas comparados; métricas preservadas, nueve texturas referenciadas presentes, originales MDX con SHA256 intactos.

Blender 3.4.1 arranca en background, pero la configuración de fábrica no aporta complemento MDX detectado. Esto se documenta como límite, no como validación de un exportador Blender. El laboratorio histórico wc3 reforg no se localizó; sus enlaces Windows quedan identificados como procedencia histórica. No se ejecutaron pruebas visuales ni en juego, benchmark, todo el catálogo ni conversiones pausadas.

Evidencias: [verificación](../../../work/skill-modelado-20261022/verificacion.md), [resultados de modelos](../../../work/skill-modelado-20261022/smoke-result.json), [validación y hashes](../../../work/skill-modelado-20261022/validation.json), [procedencia](../../../work/skill-modelado-20261022/origen.json).
