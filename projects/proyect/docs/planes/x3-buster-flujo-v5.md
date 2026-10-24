# X3 A: cuerpo azul y flujo rosa — V5

23-10-2026. Objetivo: corregir la interpretación de A, conservar V4 y las piezas B/C. Classic 1.27b, MDX800, punta geométrica X=0, física externa. Skill wc3-classic-modeling; diagnóstico con systematic-debugging.

Evidencia: hoja del usuario, fila Lv.2 Charged Shot (X3); GIF Retropixel buster-estandar, fotogramas 3–14. Tres fases repetidas a 30ms por imagen en ese GIF (no acredita timing nativo SNES). Azul continuo y descarga rosa que cambia de posición/extensión, más acentos verdes. V4 usaba una copa rosa/blanca casi fija; ésa es la lectura a corregir.

1. Aislar secuencia y documentar fuentes, límites y anatomía. Guardar comparación ampliada y bucle lento.
2. Derivar base de geometría/UV de Shot II Blue de Vinz, conservar procedencia. Acortar/ensanchar y completar volumen azul; punta rosa unida al cuerpo, capas de flujo que se abren y viajan atrás. No convertir el blanco aditivo en carcasa opaca.
3. Visor 3D real, comparación V4/V5 y ShotsII, reproducción lenta y varias vistas. Ajustar por observación. No abrir juego antes.
4. Relectura MDX/MDL independiente, recursos completos, fases de vuelo y origen. Empaquetar A con sus recursos y fuentes. Prueba nativa separada si se realiza; no hereda la validación V4.

Fuentes indexadas: ModelEditor; consulta CodeGraph a vol-ii.cjs, model.cjs, x3-effect-kit-v4.cjs, build-x3-v4.cjs y visor. Fuentes devueltas vigentes; sin cobertura de aspecto/render nativo.

Estado: referencia temporal examinada; implementación pendiente. V4 y originales intactos.

Final: fases1–4 completadas. Nuevo A en exports/megaman-x3-buster-v5; original V4 conservado. 474poses, lectores independientes, visor3D y prueba nativa YDWE SP/DP-1 con150capturas, escala0.5/2.4/3 y cierre0. Evidencia: ModelEditor/evidence/x3-v5/{build,verification,native-verification,closure}.json. V5 adapta el ciclo3D; no afirma timingSNES exacto.
