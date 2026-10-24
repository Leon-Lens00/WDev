# Dependencia PyYAML del validador de skills

- Fecha: 2026-10-22T12:27:37.280929-05:00; agente Codex; proyecto Proyect, preparación de modelado en CachyOS.
- Revisión: quick_validate.py instalado en /home/snz/.codex/skills/.system/skill-creator/scripts/.
- Estado: en investigación.
- Síntoma/evidencia: `python /home/snz/.codex/skills/.system/skill-creator/scripts/quick_validate.py --help` terminó con código 1, `ModuleNotFoundError: No module named 'yaml'`, línea 10.
- Causa confirmada: el Python seleccionado no dispone de PyYAML.
- Impacto: ese intérprete no puede ejecutar la validación oficial de la skill; no implica defecto de la skill recuperada.
- Acción: buscar intérprete local con PyYAML antes de instalar dependencias.
- Verificación pendiente: ejecutar el validador con la skill instalada usando un intérprete compatible.

## Cierre por alternativa comprobada — 2026-10-22T12:31:46.299563-05:00

Estado final: resuelto para esta tarea mediante un entorno aislado. El Python de sistema y el runtime de documentos no tenían PyYAML. Se creó `work/skill-modelado-20261022/validator-env` y se instaló PyYAML 6.0.3 desde la caché de paquetes; el Python global permanece sin cambios. El intento auxiliar `command -v -a` tenía una opción inválida; se sustituyó por `type -a`, sin modificar herramientas.

Verificación: `validator-env/bin/python /home/snz/.codex/skills/.system/skill-creator/scripts/quick_validate.py RUTA_SKILL` devuelve `Skill is valid!`, código 0 para wc3-classic-modeling y optimize-slendytubbies-wc3-127b. No se afirma que el intérprete global haya sido corregido; la ruta aislada queda registrada para repetir esta validación.

Evidencia: [validation.json](../../../work/skill-modelado-20261022/validation.json).

22/10/2026: al actualizar probar-warcraft3-classic-linux se repite faltaPyYAML con `wc3 python`. Se recupera mediante el mismo validator-env ya documentado, sin instalar dependencias ni cambiar Python global.
