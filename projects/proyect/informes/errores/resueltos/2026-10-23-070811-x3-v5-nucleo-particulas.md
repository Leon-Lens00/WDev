# Pérdida de núcleo y partículas en el port X3 V5
Fecha: 2026-10-23. Agente principal, ModelEditor, Classic1.27b/MDX800.
Síntoma: usuario observa menos centro blanquecino y partículas que ShotsII original.
Causa comprobada en build-x3-v5.cjs: capas de Flare reducidas a alfa0.11 y azules0.32; cuatro emisores de vuelo originales sustituidos por tres genéricos. Esto cambió el apilado luminoso y su riqueza.
Impacto: identidad visual del port A; formato/paquetes anteriores preservados.
Estado: en corrección V6. Se restaurará el apilado y adaptarán F1/F2/Atras sin copiar la trayectoria.
Comprobación prevista: original/V5/V6 en visor3D, lector independiente y prueba nativa aislada.
Consulta auxiliar NASA PDF no pudo abrirse por límite21.5MB del navegador web; fuente Stanford leída correctamente. No afecta a los recursos de modelos.

## Verificación V6
Corregido y comprobado en MDX/MDL, visor3D (24fases) y prueba nativa150capturas enDP-1 con el modelo final. Evidencia: ModelEditor/evidence/x3-v6/{verification,native-verification}.json. Apilado luminoso recuperado, emisores adaptados y envoltura fija con flujo UV; no acredita identidad SNES exacta ni simulación atmosférica. Estado: resuelto el defecto concreto; valoración artística abierta a revisión del usuario.
