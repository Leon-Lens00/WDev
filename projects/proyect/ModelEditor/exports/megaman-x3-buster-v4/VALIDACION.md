# Validación X3V4 — 23/10/2026

Objetivo: Warcraft III Classic1.27b, MDX800. Ocho componentes/nueve máscaras propias. Estudio191MDX/50paquetes Vinz con hash de originales intacto;13 vistas parciales por recursos explícitos ausentes. Datos y descripciones en references/vinz-estudio-v4/ESTUDIO.md. No se certifica compatibilidad de toda la biblioteca.

- Estructura: ocho MDX releídos de manera exacta y por war3-model; MDL releído y geometría comparada. IDs, padres, matrices, pivotes, tracks y referencias de materiales/texturas válidos. Textura animada enlazada al material de aros.
- Poses:311 por componente de vuelo y255 del flash; raíz inmóvil, frente geométrico máximoX0. Emisión continua Stand y apagada Death; ribbons breves ocultos en Death. Flash Squirt activo en primer paso16.7ms, una vez por secuencia.
- Texturas: nueveBLP1 paleta/alfa8, mipmaps completos. Píxeles contra PNG y decodificador M3 independiente. El lector PillowBLP no interpreta correctamente este alfa; no se usó como autoridad del BLP.
- Visor: ocho piezas, comparación con referencia, lateral/frontal/oblicua, grupos y halo. Capturas nativas del MDX, sin imágenes generadas como sustituto de la revisión.
- Mapa: JassHelper y pJASS,20miembros modificados reextraídos con bytes exactos. YDWE.exe -war3 -loadfile, rama single_test, EnableHost0, un jugador/sinLAN en perfil privado, pantalla3/DP-1. La copia real Maps/Test/WorldEditTestMap.w3x coincide por SHA con fixture.
- Motor: Stand, movimiento oscilatorio de demostración, Birth, Death y escalas0.5/3. Residuos/estelas visibles en desplazamiento, desaparición completa, flash breve registrado.25frames por comando completo con identidad/PID/monitor/workspace y en última revisión foco por frame. Primera captura Stand final incompleta por cambio de foco se descartó y repitió. native-r1 conserva ensayo inicial: siete modelos byteidénticos; sólo cambió grupoB de tres a dos orbes, vuelto a ensayar en copia final.

Mapa final: `45f96cd4793d04f6c60cb5652d66d409cfaf4896ef01610c7281679a411caa13`. Base conservada: `268666e1d846cb3d8df422c87b70c08c4b293b1035ef579529ba2020670c68ac`. Evidencia: ModelEditor/evidence/x3-v4/.

| Modelo | Triángulos | EmisoresPE2 | Estelas |
|---|---:|---:|---:|
| X3_Buster_Cargado | 5412 | 5 | 2 |
| X3_Orbe_Verde | 708 | 4 | 1 |
| X3_Orbe_Naranja | 708 | 4 | 1 |
| X3_Orbe_Cian | 708 | 4 | 1 |
| X3_Grupo_Orbital | 1416 | 8 | 2 |
| X3_Cross_Buster | 6366 | 7 | 2 |
| X3_Conjunto_Fusionado | 9198 | 23 | 6 |
| X3_Flash_Union | 774 | 3 | 0 |

Límites: el aspecto es una interpretación3D del sprite2D; la equivalencia artística exacta es una valoración visual. La física, colisiones, daño, sincronización multijugador y carga masiva no forman parte del ensayo. No se midióFPS. C-Grupo-visual cuesta más que el núcleo solo; usarlo como alternativa y no duplicarlo con C-Buster-fusionado. Los brillos transparentes o residuos pueden salir del plano frontal: no representan el cuerpo ni su colisión. Lanzamiento YDWE por la rama de prueba: no se afirma haber probado Ctrl+F9 desde la interfaz completa del editor.
