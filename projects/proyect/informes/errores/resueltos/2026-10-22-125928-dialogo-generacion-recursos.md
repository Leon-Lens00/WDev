# Generación inicial de recursos de conversación
Fecha: 2026-10-22. Agente: chat UI/dialogue. Entorno: Classic 1.27b, Node26, Pillow12.3, MDX800.
Estado: en investigación.

Dos validaciones del generador nuevo fallaron antes de empaquetar: comparación del canal alfa al releer BLP1 con Pillow; parser MDL war3-model rechazó un decimal sin cero inicial en Scaling. El lector independiente MDL sí aceptó la entrada. Fuentes: TerrainDev/dialogue-system/tools/{textures.py,model.cjs}.
Impacto: los recursos no se consideran listos; todavía no se incorporaron al mapa. Se investiga la lectura BLP y se normalizará la sintaxis decimal. No afecta mapas anteriores ni el editor UI.

Resuelto: decimales normalizados a 0.08; lectores MDL independientes aceptan y vértices coinciden con MDX800. La discrepancia alfa procede de Pillow12.3: BLP1Decoder._read_bgra usa alfa de paleta e ignora plano alfa separado. mdx-m3-viewer decodificó las cuatro BLP1 con alfa8 y todos sus mips coincidentes byte a byte. No se cambió el formato válido para satisfacer el lector incorrecto. Pendiente separado: representación en motor.
