# Comparación textual MDL demasiado estricta

- Fecha: 2026-10-22 15:38 America/Lima; chat ModelEditor, Node 22.14, mdx-m3-viewer 5.12, war3-model 4.0.1, MDX800.
- Síntoma: el verificador rechazó MDL por `lights.0.flags` 0 frente a 512. El primer auxiliar de diagnóstico falló al comparar estructuras de distinta longitud; se corrigió el manejo de null/undefined y se repitió.
- Evidencia: `ModelEditor/evidence/mdl-roundtrip-differences.json`.
- Causa confirmada: MDL expresa el tipo en el bloque `Light`/`ParticleEmitter2`, no como bits numéricos. El lector textual normaliza 512/4096 de forma distinta al binario original. También reordena las curvas de partículas (KGTR/KP2E), sin cambiar su nombre ni valores. La comparación por posición del array era incorrecta.
- Impacto: falso rechazo del verificador textual. Los MDX conservan todos los bits y curvas originales y pasan relectura completa exacta; no se requiere cambiar el binario.
- Acción: comparar curvas por tag y normalizar sólo los bits implícitos de tipo en la comparación MDL. Mantener los demás flags y datos estrictos.
- Estado: pendiente de repetir la validación completa. No acredita aspecto en juego.


## Cierre — 22 de octubre de 2026

Recuperación: comparación canónica de los 36 MDL correcta; todos los MDX conservan exactamente los flags y tracks al reabrirlos. 11628 poses y componentes pasan verificación. Estado final: resuelto.
