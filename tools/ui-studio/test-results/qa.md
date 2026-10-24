# Verificación de UI Studio — 2026-09-20

Estado Warcraft: **Validated** — exportador compilado y validado estáticamente; sin prueba de juego ni multijugador.

- Cinco pruebas Node superadas: identidad y distribución de casillas, conversión de coordenadas, intercambio JSON, rechazo de datos inválidos/duplicados, escape de strings y geometría de ventanas.
- Export inicial de 74 elementos compilado con JassHelper y pJASS contra common.j/Blizzard.j de la toolchain local 1.27b. Ver `compile.json` y `compiled.j`.
- Navegador: creación de texto, modificación inmediata de contenido/X, arrastre, duplicación, eliminación, deshacer, recuperación después de recargar y cambio simulado de página comprobados.
- Guardado en carpeta local comprobado desde la UI; JSON reimportado mediante selector de archivo, con el texto de prueba recuperado correctamente. Se restauró el preset de 74 elementos al terminar.
- Entrega inicial guardada en `../exports/2026-09-20T23-32-43-895Z/`, con JSON, JASS y guía. La carpeta anterior es una entrega de prueba con un texto añadido.
- Los dos WebMCP se registraron y se probaron: leer diseño, modificar posición existente, rechazar ID inexistente y deshacer la modificación en la UI.
- Las 52 texturas del catálogo existen. HTML, JS, CSS, catálogo y PNG comprobados por HTTP. La API rechaza proyectos inválidos (400) y orígenes ajenos (403).
- Vista inspeccionada en la ventana estrecha de Codex y en escritorio 1440 × 900. Sin errores en el registro de consola consultado al terminar las pruebas de interacción.
- La espera de un evento de descarga de Blob no se pudo confirmar en el navegador integrado. Se añadió y verificó la entrega directa en carpeta local; es el camino recomendado en Codex.
- SHA-256 del mapa original vuelve a coincidir con `a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada`.

Límites: guía del héroe 2D, marcos/tipografía aproximados, color de unidades y orden visual sujetos al render de Warcraft, acciones exportadas como enlaces sin efectos de juego. Se requiere adaptar los puntos de creación y los reposicionamientos dinámicos antes de usar el diseño en un W3X.
