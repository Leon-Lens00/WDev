# Validación V3 —22/10/2026

- Siete MDX versión800 escritos y releídos; roundtrip exacto de los campos serializados y lector independiente war3-model4.0.1. MDL hermano conserva geometría con tolerancia0,0001.
-299 poses por modelo: raíz en0,0,0, sin Translation de raíz, geometría de vuelo Xmáximo0 y bounds válidos. Padres/IDs canónicos, matrices, caras/UV y recursos correctos.
- Siete BLP1 paletizados: alfa8, pictureType4/subtype1, mipmaps completos; píxeles RGBA y dimensiones contrastados con lector independiente. Las copias de texturas por carpeta son idénticas.
- Todos los componentes de vuelo incluyen emisores de residuo sin ModelSpace, emisión positiva durante Stand y apagada en Death; ribbons con vida corta y visibilidad terminada. Flash Squirt conserva ventanas50ms que alcanzan el primer paso16,7ms, sin emisión continua.
- Visor MDX real mdx-m3-viewer5.12.0: piezas individuales/grupo, silueta V2/V3, perspectiva orbital, partículas continuas, recorrido externo opcional y apagado. No se confunde el GIF fuente con un render3D.
- Galería compilada JassHelper+pJASS y17 miembros reextraídos byte a byte. Mapa final SHA256 aba08fc7990035442296295159031a53346dcecd8130a15c95b599e02175b5b3. Base del mapa conservada SHA256268666e1d846cb3d8df422c87b70c08c4b293b1035ef579529ba2020670c68ac.
- Prueba en Classic1.27b mediante YDWE.exe -war3 -loadfile: un jugador, EnableHost0 en copia privada, sin LAN. Hash del WorldEditTestMap cargado comprobado. Capturas en pantalla3/DP-1 verificadas por PID/prefijo/workspace.
- Emisión/cuerpo/aros visibles, movimiento de demostración y residuos observados. Birth muestra flash y Death elimina cuerpo y partículas al final. Galería corregida umvs0→300: control con JASS y MDX idénticos acreditó recuperación del desplazamiento visual.

Evidencia detallada fuera del pack: ModelEditor/evidence/x3-v3/{verification.json,movement-control.json,loaded-map.json,visual-notes.md,move-verified,birth-verified,impact-verified}. Fuentes en ModelEditor/src/. Consultas CodeGraph previas a cambios y posteriores sobre esa raíz; el JASS generado dentro de strings es frontera y se compila aparte.

No acredita editorCtrlF9, físicas de fusión/impacto, otro mapa, FPS ni multijugador. El movimiento del laboratorio y del visor no forma parte del MDX. Ajuste artístico pendiente de valoración del usuario.
