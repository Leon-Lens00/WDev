# Dev Mission: Armas por cartas (desde v20v)

Pedido de Leon el 20/11/2026, después del rework de habilidades (v20r–v20u). Base: v20u (`33e30b14…`, prueba
`988626f3…`).

## Lo pedido

- Guardar la tienda de compra actual, **desactivada**.
- La sección **Armas** pasa a ser de selección por cartas: subir de tier y aprender armas nuevas.
- Respetar el límite de tier por ronda que ya había (p. ej. el tier máximo sólo tras la ronda 8).
- Siempre una carta asegurada de subir tier, si se puede, y otra de arma nueva.
- Las mejoras de un arma no salen de armas que el jugador aún no tiene.
- Las cartas de armas, daño y ataque del apartado del héroe pasan a esta sección.

Respuestas de Leon:

- **Cuántas cartas:** 2 elecciones gratis por oleada.
- **Qué cartas se mueven:** "todo lo que tenga relación con las armas, daño, ataque".
- **Vida y munición:** "saldrá una carta que dará vida, como ganar 1 al pasar una wave"; la munición se recarga sola
  al completo al superar cada wave.

## Decisiones del agente

- **Elecciones:** 2 por oleada y 1 la primera vez, como recomendé y Leon eligió. Se reparten al empezar el descanso
  (`Her_Sortear`); si no se eligen, se pierden. 4 cartas y sin refresco. Al elegir una se reparte otra mano con el
  estado nuevo.
- **Límite de tier:** el de la tienda vieja (`Arm_Req`): T2 tras la ronda 1, T3 tras la 2, T4 tras la 4, T5 tras la 6
  y T6 tras la 8.
- **Mano de Armas:**
  - primero, si se puede, Subir tier de un arma que tiene y Arma nueva (T1) de una categoría que no tiene;
  - el resto al azar y sin repetir entre:
    - Subir tier o Arma nueva de otra categoría;
    - Filo;
    - Golpe de suerte;
    - Calibre y Cargador ágil, sólo de un arma que tiene;
    - Vida extra;
  - 12 % de que la cuarta sea una maldita de daño.
- **Cartas que pasan a Armas:**
  - Filo (20), Golpe de suerte (23), Calibre (83) y Cargador ágil (84);
  - las malditas de daño: Pacto maldito (28), Sed de sangre (33), Ruleta (36) y Pacto de sombras (80).
- **Lo que le queda al héroe:**
  - estadísticas y economía;
  - dash;
  - linterna (Pilas y Recarga rápida son de la linterna, no del arma);
  - las malditas Codicia (34) y Mutante (35);
  - las técnicas.
- **Vida extra:** la interpreté como +1 vida al elegirla. Se elige en el descanso, después de pasar la wave.
- **Munición:** al terminar cada oleada, cargador y reserva quedan llenos en todas las armas. Las zonas de munición
  siguen como estaban.
- **Color de la carta Subir tier:** el del tier nuevo (T1 amarillo … T5 morado, T6 rojo). Las cartas Subir tier y Arma
  nueva llevan de icono la foto de la categoría.

## Registro de entregas

### v20v (20/11/2026)

Fuentes: `scripts/v20v.py` (j), `scripts/hacer-v20v.sh`; lanzadores `entrar-v20v.sh` y `entrar-v20v-prueba.sh`.

- **Tienda vieja:** sigue entera en el código, apagada con `ArmC_TiendaVieja = false`. Si se pone a `true`, el cuadro
  Armas vuelve a abrir la tienda vieja (`Cua_IrArmas`).
- **Modo nuevo de cuadros (`Cua_Modo` 3):**
  - cartas en `Cua_HCand[p*40+35..38]`;
  - `Her_K`, `Cua_Item` y `Cua_Cuantos` lo conocen;
  - cabecera azul "Armas (i/n) · suerte N".
- **Funciones nuevas:** `ArmC_Cartas`, `ArmC_Poner`, `ArmC_Hacer`, `ArmC_Subir`, `ArmC_Maldita`, `ArmC_Des`,
  `ArmC_Municion`.
- **Cartas nuevas:** 86 Subir tier, 87 Arma nueva, 88 Vida extra.
- **Pool del héroe:** 21, 22, 26, 27, 18, 19, 37, 38, 24 y 81. Los repuestos (dash o linterna al máximo, pulls extra y
  puesta al día) usan los 8 primeros.
- **-prueba:** las líneas "armas cartas j…", "armas elige j… carta … cat … tier … vidas …" y "armas municion llena" van
  a `lat\v20v-don.txt` (con -reg).

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20v.w3x | `011e6feac65613b8cb5f74095326cf3b04f2d53ebfee8847262a71a0ff385219` |
| TerrainDev-Titulo-v20v-prueba.w3x | `cefaae848ce961ede97d6346c57920770332c052782954e88176bb66e8982606` |

**Comprobado:**
- pJASS en las dos variantes;
- j reextraído igual;
- bytes-diff: sólo cambian (attributes) y j;
- `mpq verify`;
- construcción reproducible;
- copias en WOE con cmp.

Estado: **Validated**; sin jugar. No hay `GetLocalPlayer` nuevo. La parte local que se toca (`Cua_Ver`) sólo cambia
colores y textos. Aun así, la tienda pide LAN según la memoria; queda pendiente.

**Por comprobar en juego:**
- que el cuadro Armas abra las cartas y vuelva al inicio tras la 2.ª elección;
- que la foto de la categoría se vea bien en la carta (190×95);
- los textos de Subir tier y Arma nueva;
- que el arma nueva aparezca en los botones;
- que Vida extra sume;
- que la munición se llene al terminar la wave;
- que el héroe ya no ofrezca Filo, Golpe de suerte, Calibre, Cargador ágil ni las malditas de daño.
