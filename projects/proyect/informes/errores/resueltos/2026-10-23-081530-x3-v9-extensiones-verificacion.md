# X3 V9: comprobación de preservación

Fecha: 2026-10-23T08:15:30.475753
Agente raíz; ModelEditor, Classic1.27b MDX800.
Síntoma: verify-x3-v9.cjs rechazó la reconstrucción exacta V7 después de recolocar los filamentos verdes.
Evidencia: ModelEditor/evidence/x3-v9/preservation-diff.json. 528 diferencias serializadas.
Impacto: validación pendiente; no lanzar juego hasta resolver el motivo.
Hipótesis: los filamentos ampliaron los bounds recalculados; comprobar que geometría/curvas anteriores son idénticas.
Estado: en investigación.

Causa confirmada: sólo bounds/extensiones cambiaron (Z pasó de±21 a±22.7846). Las otras propiedades originales eran idénticas. Se recolocaron los filamentos dentro de las extensiones originales. Verificación repetida: reconstrucción V7 byte a byte PASS, 311 poses PASS, recursos y periodos PASS. Estado: resuelto. Captura visual del diseño nuevo continúa por separado.
