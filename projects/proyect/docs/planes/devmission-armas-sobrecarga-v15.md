# Dev Mission v15: 4 armas fijas, sobrecarga y tienda de mejoras (plan, 05/11/2026)

Base: v14n (`work/titulo-devmission-20261026/TerrainDev-Titulo-v14n.w3x`, SHA-256 3a666349), Classic 1.27b.
Encargos de Leon: `docs/traspasos/encargo-ui-tienda-mejoras-20261105.md` (dos indicaciones) y la del 05/11 sobre
la sobrecarga. Prototipo aprobado para aplicar: `work/tienda-mejoras-20261105/` (UI System Design: LEEME.md,
tienda-mejoras.html, capturas/, `generar.py texturas` para 21 piezas BLP).

## Decisiones de Leon

- **Armas:** se desactivan las armas actuales y la munición (cargador, reserva, zonas `nPtB` y «Abastecer todo»).
  El jugador tiene desde el inicio Pistola (Q), Subfusil (W), Escopeta (E) y Francotirador (R). La tienda sólo
  muestra esas 4 categorías.
- **Tiers:** 7 tiers, cada uno con su color:

  | Tier | Color |
  |---|---|
  | 1 | Yellow |
  | 2 | Green |
  | 3 | Cyan (nuevo) |
  | 4 | Blue |
  | 5 | Orange |
  | 6 | Red |
  | 7 | Purple |

  En el tier t, cada mejora tiene t niveles. Con todas compradas se puede comprar el siguiente modelo.
- **Balas:**

  | Arma | Bala |
  |---|---|
  | Pistola | Shot (Vol. I) |
  | Subfusil | Shot II |
  | Escopeta | Firebrand Shot |
  | Francotirador | Daemonic Arrow (Vinz y Daemonic Sword, Hive 337124: dar crédito) |

  Todas llevan el color del tier.
- **Colores del jugador:** el dash (Valiant Charge) y el movimiento artificial (Windwalk) siguen con el color del
  jugador.
- **Sonidos de disparo** de ShootingGay 0.7: PistolShoot.wav, MachineGunShoot.wav, ShotGunShoot.mp3 y
  SniperRifleShoot.mp3 (créditos a ShootingGay 0.7ENG).
- **Cadencia de escopeta y francotirador:** un tiro cada 0,50 s. Así, en la ráfaga de 1,5 s salen sólo 3; los tiers
  pueden mejorarlo.
- **Sobrecarga (sustituye a la munición):**
  - Usa la barra de blindaje junto a la vida, con un texttag «Sobrecarga» debajo. Barra y texto pasan de verde a rojo
    según sube.
  - Cada disparo suma puntos: la pistola poco, el subfusil más, la escopeta más y el francotirador aún más.
  - Cada 0,10 s la barra baja un valor fijo (refresco). Si el arma está equilibrada, la barra se mantiene; si está
    optimizada, baja; si es muy fuerte, sube.
  - «Mejorar sobrecarga» (el botón de abajo en la tienda, antes la munición suelta) sube el refresco de la barra.
  - La mejora de sobrecarga de cada arma hace que sume menos por disparo.
  - Al subir de tier, el arma suma más: hay que repartir el oro entre mejorar el arma y la barra.
  - **Refrescar sobrecarga:** la tecla R de la recarga pasa a otra tecla. Tarda como la recarga anterior, pone la
    sobrecarga a 0 y se cancela con el dash o al disparar. Se compra en kits en la tienda, en el lugar de
    «Abastecer todo».

## Hechos comprobados en v14n (Scanned)

- **Controlador `Game_Ctrl[p]`:** Disparo `Arp1` (A), Dash `Ard1` (D), Recarga `Aw08` (R). Armas `Aw00`..`Aw06`:
  Q Pistolas, W Subfusiles, E Rifles, S Francotiradores, Z Escopetas, X Cuerpo a cuerpo, C Explosivos.
  - Con el plan, Q W E R chocan sólo con Recarga (R).
- **Ráfaga:** `s__RapidPair_cast` dispara 6 tiros, uno cada `Arm_Int[w]` (pistola 0,25 s = 1,5 s). Para que la
  escopeta y el francotirador den 3 tiros, la ráfaga debe medirse en tiempo (1,5 s / intervalo).
- **Velocidad de bala:** fija, 1200 (`s__RapidBolt_shootFamily`). Alcance `Arm_Alc[w]`. Dispersión `Arm_Disp[w]`.
  Perdigones `Arm_Perd[w]`.
- **Color de bala:** hoy es el del jugador (`s__RapidPair_color` → `originalColor`/`firebrandColor`).
  - Hay que separarlo: un color de tier para la bala y el color del jugador para Windwalk y Valiant.
- **Colores disponibles:**
  - Shot y Shot II: 6 colores, sin Cyan.
  - Firebrand: 9 colores, con Teal, Pink y Silver.
- **Radio de impacto:**

  | Bala | Radio |
  |---|---|
  | Shot | 6 × escala |
  | Shot II | 18 × escala (Green 16,2) |
  | Firebrand | 30 |

- **Herramientas de color:** `TerrainDev/scripts/windwalk_colores.cjs` y `valiant_colores.cjs`, con `gradientTint`
  de ModelEditor y texturas con `plot-env python`.
- **Oro:**
  - Al morir un enemigo: `max(3, vida/5) × (2 + ronda) / 3`.
  - Al acabar cada ronda: `40r + 10r²`.
  - Registro de v14l: unos 250 de oro en la ronda 1 y unos 1300 en la ronda 2.

## Daemonic Arrow

- `Daemonic Arrow.zip` (Descargas) es la versión Reforged: usa texturas `_hd.w3mod:` que 1.27b no tiene. Copia sin
  tocar en `TerrainDev/assets/daemonic-arrow-original/` (SHA-256 del MDX 0fd0d97b).
- Leon aportó la versión clásica (`Daemonic Arrow - Classic.rar`), extraída a
  `TerrainDev/assets/daemonic-arrow-classic/`: `Daemonic Arrow Classic.mdx` (v800, SHA-256 2b9a576a).
  - Texturas en `war3mapImported\` (flareshot01_bw, dust3, RoyalGlow, flaresimple01_bw, flaresimple02_bw, smoke_bw,
    flash01_bw) más las del juego Purple_Star, Dust5ABlack y GenericGlow2_64. Todas BLP1, potencia de dos, ≤ 256.
  - 8 geosets, 12 emisores PRE2, Birth/Stand/Death, radio de límites 120,6. El cuerpo va por X (−102..115); ancho Y
    ±17 en el geoset 4 y ±33,5 en el halo (geoset 7).
  - Morado a recolorear (v15b): RoyalGlow.blp, Purple_Star y los colores de segmento de los PRE2.

## Decisiones de Leon del 05/11/2026 (tercera)

- **Texttags de la tienda:** se optimizan como en v14f (la tienda los crea al abrir). Además desaparecen al cerrar y no
  vuelven hasta el siguiente descanso, para no chocar con los texttags de las barras de vida.

## Valores provisionales (sin respuesta aún; cambiar si Leon decide otra cosa)

1. **Sobrecarga al 100 %:** el arma no dispara hasta bajar del 60 % (o hasta refrescar), con el sonido de error.
2. **Tecla de Refrescar sobrecarga:** F, libre en la rejilla.

## Fases

1. **v15a, núcleo de combate (sin tienda nueva):**
   - 4 armas fijas en Q W E R, con un tier por arma y estadísticas T1 en tablas.
   - Se quitan munición, recarga, zonas `nPtB` y «Abastecer todo», y se ocultan las demás categorías.
   - Ráfaga medida en tiempo. Color de bala por tier. Sonidos.
   - Barra y texttag de sobrecarga, refresco cada 0,10 s y Refrescar con kits (kits iniciales provisionales).
   - Pruebas por registros: calor por disparo, refresco y cancelación.
2. **v15b, recursos:**
   - Variantes Cyan de Shot, Shot II y Firebrand (Teal como base).
   - Daemonic Arrow clásico en 7 colores, medido con el método de `shots_ajustados.cjs` para su radio.
3. **v15c, tienda de mejoras** según el prototipo:
   - Ranuras fijas de trackables: 7 modelos, centro, 6 del anillo, Volver y Comprar.
   - Texturas de `generar.py`.
   - Presupuesto de texttags: el prototipo usa 39-51; el tope es 100.
4. **v15d, balance:**
   - Precios: tabla con multiplicador.
   - Valores de calor y refresco por tier, ajustados con el registro de una partida completa.

Cada fase entrega un mapa normal sin registros, más `-prueba` y `-prueba-intro`, según la skill mapa-dev-mission.
Sus comprobaciones se marcan Validated / Tested in map por separado.

## Estado

### v15a entregada el 05/11/2026 (Tested in map, un jugador)

Base `TerrainDev-Titulo-v14n.w3x`; construcción `work/titulo-devmission-20261026/scripts/hacer-v15a.sh`
(v15a.py, objetos_v15a.py, recursos_v15a.py, prueba_v15a.py). Importa 19 archivos:
- objetos (w3a, w3b, imp);
- HudCarga y DISBTNArma0..4;
- 4 sonidos de ShootingGay 0.7ENG;
- `DaemonicArrow\Daemonic Arrow Purple.mdx` (a5601e4b), con 5 texturas.

Hay reextracción comparada y `mpq verify` en las cuatro variantes, y pJASS correcto.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v15a.w3x | 20f096f2 |
| v15a-prueba | 4db23486 |
| v15a-prueba-intro | 042815dc |
| v15a-auto (no se entrega) | 39962c93 |

Prueba automática (`entrar-v15a-auto.sh`), 4 ejecuciones. La cuarta pasa entera:
- Pistola T1, 9 s seguidos: 38 tiros, sobrecarga en 0.
- Francotirador: se bloquea a 99,2 tras 24 tiros; bloqueado no emite nada (0); se desbloquea en 59,2.
- Refrescar:
  - si disparas a los 0,5 s, se cancela y conservas el kit;
  - si se completa, deja la sobrecarga en 0 y gasta 1 kit;
  - sin kits, no arranca.
- Ráfagas de 1,5 s: escopeta 3, subfusil 12, pistola 6, francotirador 3.

Capturas: barra roja al 97% con «bloqueada»; texto debajo de la barra; flecha morada; iconos grises en pausa.

Defectos corregidos durante la prueba: el relleno quedaba tapado por el marco (ahora a 385) y faltaban los DISBTN.
Abierto: un Refrescar que no arrancó en 1 de 4 ejecuciones
(`informes/errores/2026-11-05-200240-v15a-refrescar-y-barra.md`).

Sin comprobar:
- F con el teclado;
- comandos de chat de la variante -prueba;
- la tienda provisional;
- LAN de dos clientes (la barra usa alfa local con GetLocalPlayer).

Provisional:
- el HUD aún muestra el nombre del modelo del tier (p. ej. «Whitworth T1»);
- Shot y Shot II usan azul en T3 hasta v15b.

Siguiente: v15b (variantes cian y recoloreado de la Daemonic).

### v15b, v15c y v15d entregadas juntas el 05/11/2026 como v15c (Tested in map, un jugador)

Base `TerrainDev-Titulo-v15a.w3x` (se comprueba su j). Construcción `scripts/hacer-v15c.sh`:
- fuentes: v15c.py, objetos_v15c.py, hits_v15c.cjs, prueba_v15c.py;
- 48 imports: objetos, las 20 texturas Tm del prototipo de UI System (`tienda-mejoras-20261105/texturas`), 4 modelos
  de zona de clic y los 21 archivos de `TerrainDev/assets/balas-colores` (manifest.json).

Hay reextracción comparada y `mpq verify` en las cuatro variantes, y pJASS correcto.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v15c.w3x | 54aa3dc0 |
| v15c-prueba | c22d96ea |
| v15c-prueba-intro | 165fff0d |
| v15c-auto (no se entrega) | 95af276d |

Contenido:
- **v15b**: color de bala por tier en las 4 armas, las 28 combinaciones (Shot / Shot II / Firebrand / Daemonic Arrow)
  en Yellow, Green, Cyan, Blue, Orange, Red y Purple.
- **v15c**: tienda del prototipo.
  - Vista de modelos: 7 ranuras por arma y ficha con stats y mejoras.
  - Vista de árbol: centro y 6 nodos con flechas giradas, glow, candado y marca.
  - Botones Volver/Comprar; 43 texttags creados al abrir y destruidos al cerrar; 140 piezas.
  - En el slot 3: precisión; perdigones en la escopeta desde T2; perforación en el francotirador.
- **v15d**: precios.
  - Nivel n+1 de una mejora: r5(b·(1+0,5n)), con b = r5(20·(1+0,5m)).
  - Modelos 2..7: 200 / 500 / 900 / 1300 / 1750 / 2250. Una arma a T7 cuesta unos 28,2k.
  - Mejorar sobrecarga: 150·n, 7 niveles. Kit: 60.

Prueba automática (`entrar-v15c-auto.sh`), 5 ejecuciones; capturas en `v15c-auto/capturas` (quinta) y `previas/`:
- Precios observados: pistola m0 4 mejoras por 80, modelo 2 por 200, m1 por 375 (330 + 45; ver abajo) y modelo 3 por
  500. La segunda mejora de sobrecarga lleva el gasto a 450.
- Las estadísticas por tier y nivel siguen las fórmulas. Tras cada disparo la velocidad vuelve a 1200.
- Visual:
  - flechas del árbol giradas hacia cada nodo;
  - color del tier en marcos, iconos y textos;
  - modelo bloqueado con candados y «Completa el Raven (0/36)»;
  - iconos de perdigones y perforación.
- Balas: colores por tier vistos (p. ej. Daemonic cian en T3, verde en T2; pistola T5 naranja).

Corregido tras las capturas:
- el texto de tier/lema/«Modelos» salía del panel (ahora alineado a 1252);
- la flecha de arriba pisaba la etiqueta del nodo: esa etiqueta va ahora a la derecha del nodo (vista en la quinta).

Límites de la prueba (no del mapa):
- Varias compras seguidas en un solo hilo pasan el límite de operaciones, porque cada compra refresca la tienda. Por
  eso un hilo de prueba se cortó y el siguiente pagó el resto (330 + 45). En el juego cada clic es un hilo propio.
- La figura verde de las capturas es el puntero (mano orca), no una unidad: no hay unidades cerca de la tienda.

Abierto: la orden de disparo se rechazó en 1 de 28 fases de la tercera ejecución (y 3 en la segunda); ninguno en la cuarta ni la quinta, ya con registro del estado al rechazar. Ver el informe
`informes/errores/2026-11-05-200240-v15a-refrescar-y-barra.md`, punto 4.

Sin comprobar:
- clics reales del ratón en la tienda (la prueba llama a las funciones);
- F y el teclado;
- LAN de dos clientes;
- balance en una partida completa.

Créditos: Vinz (Shots, Firebrand); Vinz y Daemonic Sword (Daemonic Arrow, Hive 337124); ShootingGay 0.7ENG
(sonidos); prototipo y texturas de UI System.
