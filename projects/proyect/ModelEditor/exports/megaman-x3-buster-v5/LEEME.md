# X3 Buster A — V5

Revisión del buster básico cargado A, separada de V4. Destino Warcraft III Classic 1.27b, MDX800. B, C, orbes y flash siguen en el pack V4 y no se sustituyen aquí.

Cuerpo azul/cian continuo y más lleno, punta rosa con centro claro. Dos frentes locales intercalados nacen delante, se abren y recorren la superficie hacia atrás; filamentos y residuo corto completan el flujo. Birth/Stand/Death. La punta geométrica está en X=0; la raíz no avanza. El recorrido del visor/mapa es sólo de ensayo.

## Importar

- Modelo: `A-Buster/X3_Buster_Cargado.mdx` (MDL editable al lado).
- Importar los 12 BLP de `A-Buster/X3BusterV5/` con ruta `X3BusterV5\Nombre.blp`, sin `war3mapImported\`.
- No teñir todo el modelo con color de unidad si se quiere conservar la combinación azul/rosa/blanco.

## Base y créditos

Vinz: **Shots Vol. II / Shot II Blue**, geometría, UV y pila de materiales de base. Se parte de nuestra copia ya anclada; se comprime X a0.36 y se ensancha Y/Z a1.06, se añaden planos cruzados y volumen. Nuevo flujo, mallas de envoltura, animaciones y máscaras del proyecto. Las texturas stock Flare, Blue_Glow2 y star5tga proceden del juego. No atribuir el pack entero como original propio; conservar crédito a Vinz y las condiciones adjuntas.

Capcom: identidad visual Mega Man X3. Hoja Weapons and Items extraída por Random Talking Bush; recortes aportados por el usuario. GIF Retropixel: `https://www.megaman.retropixel.net/mmx/3/sprites.php`. Sólo se usó la fila Lv.2 Charged Shot (X3).

## Lectura temporal

El GIF conserva tres fases de vuelo repetidas, a30ms por imagen en ese archivo. La envoltura rosa cambia de extensión y el azul permanece visible. Esto corrige la interpretación de copa fija de V4. El ritmo V5 es una adaptación continua de320ms con dos frentes intercalados para leerlo en3D; no se afirma que reproduzca el timing nativo SNES.

`REFERENCIA-LENTA.gif`: recortes sin repintar, ralentizados a240ms/fase. `FLUJO-3D.gif`: ocho capturas reales del MDX, separadas40ms de animación y mostradas160ms para examinarlas. `MOVIMIENTO-EN-JUEGO.gif`: captura de la comparación V4/V5 en1.27b, escala2.4.

## Archivos y continuidad

Fuentes mantenidas en `ModelEditor/src/build-x3-v5.cjs` y `x3-effect-kit-v5.cjs`; constructor de visor, verificador y laboratorio V5 en la misma carpeta. Evidencias y hashes en `ModelEditor/evidence/x3-v5/`. Plan: `docs/planes/x3-buster-flujo-v5.md`. Originales y ZIP V4 conservados con hashes.
