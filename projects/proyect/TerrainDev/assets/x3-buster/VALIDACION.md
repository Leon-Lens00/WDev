# Validación de la primera versión X3

Fecha: 2026-10-22. Estado más fuerte: **Tested in map**, Warcraft III Classic1.27b, sesión local individual.

- Siete MDX800 exportados, comparación exacta de relectura binaria y lector adicional war3-model4.0.1. MDL reabierto con dos lectores; geometría contrastada con tolerancia0.0001 por formato decimal.
- 299 poses por modelo, Birth/Stand/Death. Root permanece en origen, sin traslación; geometría de los seis modelos de vuelo nunca supera X=0. El flash se expande alrededor del origen. Índices de caras, matrices, jerarquía, UV, texturas y bounds comprobados.
- Cuatro texturas BLP1 palette/alfa8/type4/subtype1 con todos sus mipmaps. Píxeles base RGBA contrastados por hash con decodificador independiente mdx-m3-viewer. El lector Pillow no reproduce el alfa de ese formato; se documentó y no se alteró el BLP válido para acomodarlo.
- Galería aislada: 7 modelos y 14 miembros modificados reextraídos idénticos. JassHelper/pJASS PASS. Mapa SHA256 `ad1112469d72af0005a6e4f45d6a25ef8d16e36ebb96da0fcb95023baf569346`.
- Observados en motor: seis modelos de vuelo visibles en Stand, giro orbital y aros locales; aparición, contracción y desaparición; flash Birth visible y desvanecido. Escalas0.5,2.4,3. Núcleo claro y color diferenciado. Sin fondos cuadrados observados.
- Evidencia propia en `ModelEditor/evidence/x3-v1/`: runtime-verification.json, verification.json, capturas *-verified, scale-small, scale-large, game-scale3.png. Primera captura mezclada con otra partida descartada como evidencia de esta prueba. Últimas capturas se comprobaron por PID/prefijo/monitor/workspace.
- Prueba en pantalla3 (DP-1, derecha). Partida propia cerrada, retorno0 y cero procesos restantes en su prefijo. No se cerró otra partida.

MUESTRAS.png es una lámina de recortes reales ampliados, sin repintar los modelos. MUESTRA-ANIMADA.gif conserva el movimiento observado con tiempos de captura aproximados. La galería de ensayo queda en el proyecto, fuera del pack de modelos.

No se ensayaron lógica de fusión, trayectorias, colisiones, daño, rendimiento ni multijugador. Son responsabilidad del apartado de física solicitado por el usuario. Esta interpretación 3D v1 queda disponible para revisión estética del usuario; el test del motor no la convierte en reproducción exacta del sprite.

## CodeGraph

Se consultaron build-x3.cjs, textures-x3.py, model.cjs y fixture-brillo.py antes de adaptar las fuentes; consultas posteriores incorporaron capture-x3.py e identify-x3.py. Sólo fuentesJS/Python de ModelEditor están indexadas; binarios, recursos y evidencias quedan excluidos. El JASS dentro de strings se verificó con el compilador real, no mediante análisis semántico del grafo.
