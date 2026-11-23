# Dev Mission: rework de habilidades (desde v20r)

Pedido de Leon el 20/11/2026, después de subir v20q a GitHub (WDev `dcb03d2d`). Base: v20q (`2c597bd5…`, prueba
`1ead09d5…`). Objetivo: kits cortos (Q W E R), transformaciones ganadas matando, pasivas sin casilla y técnicas de un
solo blanco que afecten en área.

## Lo pedido (resumen fiel)

- **Goku:** Q Kamehameha, W Warp, E Spirit Bomb, R Dragon Fist. El SSJ y demás formas se ganan solos al matar
  enemigos; al terminar la wave vuelve a la forma base. El requisito de muertes lo elige el agente.
- **Freezer:** sus técnicas igual. Power Up con la misma regla de muertes. La X (Destructo Disc) sale sola, sin
  lanzarla, con probabilidad al hacer daño o disparar: menor con armas de fuego rápido, mayor con las de intervalo
  largo.
- **Future Trunks:** se queda con Q W E R. Power Up y Finish Sign (respuesta de Leon) pasan a la regla de muertes.
- **Naruto:** W = Senpuu Odama; en modo Kyuubi la W pasa a ser Chakra Blast (Senpuu no se puede lanzar en Kyuubi).
  El Kyuubi sigue en la R, lanzado a mano (respuesta de Leon). Kage Bunshin fuera por ahora.
- **Tauren:** Q a R igual. La pasiva cambia: con cierta probabilidad, el daño que hace el disparo (Rifle franco u
  otra arma) se aplica igual en un área grande, del tamaño del efecto del pisotón.
- **Cairne:** la A pasa a la W (Tótem del trueno en W; Lanza ancestral fuera). Marca ancestral pasa a pasiva por
  impacto de bala, con probabilidad como la X de Freezer. Réplica y Espíritus guardianes se conservan.
- **Pasivas:** ninguna ocupa casilla en el libro; funcionan por datos.
- **Un solo blanco → área:** las técnicas de un blanco (Rasenrengan, Warp Kamehameha, Death Break, Imprisonment,
  Heat Dome, Senpuu, Burning Slash…) toman también a las unidades cercanas al blanco al lanzar, les aplican el mismo
  movimiento/animación y el daño final cae otra vez sobre ellas y sobre las que hayan llegado a la explosión. Mejor si
  se juntan con el blanco principal para que se vea bien.

## Decisiones del agente

- **Transformación por muertes (fase 2):** cuenta por jugador y por wave; normal 1, élite 5, jefe 15. La cuota de la
  wave es `max(10, enemigos de la wave / jugadores)`. Formas de Goku: SSJ al 20 %, SSJ2 al 40 %, SSJ3 al 60 %, SSJ4
  al 85 % de la cuota. Freezer y Trunks (Power Up): al 30 %; Trunks Finish Sign al 60 %. La forma dura hasta el final
  de la wave (se quita la duración de 50 tics de D.O.N) y al acabar vuelve a la base. Texto pequeño "SSJ 12/30" sólo
  para el jugador.
- **Probabilidad por cadencia (fase 3):** `p = clamp(25 % × intervalo del arma / 1 s, 4 %, 25 %)` por impacto, con
  enfriamiento interno (Destructo 1,5 s, Marca 3 s, Tauren 1 s). Destructo lo lanza la copia dummy en la dirección del
  héroe; la Marca cae sobre el enemigo de más vida a 400 del blanco golpeado.
- **Área del Tauren:** 300 (pisotón de War Stomp), efecto `WarStompCaster` en el punto del impacto.
- **Pasivas:** activas desde el inicio (nivel 1); las cartas aún pueden subirlas.
- **Costes:** se conservan los de v20q (Spirit Bomb sigue 100 / 45 s aunque pase a la E; Tótem del trueno 45 / 14 s
  en la W).

## Fases

1. **v20r – kits y libro** (esta entrega): libros con Q W E R; fuera Power Up de Goku/Freezer/Trunks, Finish Sign,
   Destructo (X), Kage Bunshin, Garra y Rugido del Tauren, Lanza y Marca de Cairne, y las tres pasivas del libro.
   Spirit Bomb a la E; Tótem del trueno a la W; Senpuu y Chakra Blast en la W que se alternan según el Kyuubi.
   Las cartas ya no ofrecen lo quitado. Pasivas de Tauren y Cairne activas desde el inicio.
2. **Transformaciones por muertes** (Goku, Freezer, Trunks) y vuelta a la base al terminar la wave.
3. **Procs:** Destructo de Freezer, Marca ancestral de Cairne y nueva pasiva en área del Tauren.
4. **Área en técnicas de un blanco:** por técnica, reunir a los cercanos con el blanco, aplicarles el movimiento y
   repetir el daño final en área. Probar cada una con registros (-prueba).

## Comprobaciones previstas

pJASS; reextracción de j/w3a/w3u; bytes-diff; `mpq verify`; copia a WOE con cmp. En -prueba: registro de
lanzamientos (bridge → técnica real) y de procs/transformaciones. LAN sólo si alguna fase toca `GetLocalPlayer` de
forma nueva (el texto de muertes lo hace: LAN en la fase 2).

## Estado

Ver el registro de entregas al final.

## Registro de entregas

### v20r – fase 1 (20/11/2026)

Fuentes: `scripts/objetos_v20r.py` (w3a), `scripts/v20r.py` (j), `scripts/hacer-v20r.sh`; lanzadores
`entrar-v20r.sh` y `entrar-v20r-prueba.sh`.

| Personaje | Q | W | E | R |
|---|---|---|---|---|
| Goku | Kamehameha | Warp Kamehameha | Spirit Bomb | Super Dragon Fist |
| Freezer | You Will Die | Imprisonment Ball | Death Break | Death Ball |
| Trunks | Burning Attack | Finish Buster | Heat Dome | Burning Slash |
| Naruto | RasenShuriken | Senpuu Odama / Chakra Blast (Kyuubi) | Rasenrengan | Kyuubi |
| Tauren | Embestida espiritual | Tótem arrojado | Lanzar roca | Bombardeo |
| Cairne | Grieta ancestral | Tótem del trueno | Espíritu ancestral | Estampida |

- Pasivas sin casilla y activas desde el inicio: Disparo encantado (Tauren, aún la de v20q hasta la fase 3),
  Réplica y Espíritus guardianes (Cairne).
- Sin Power Up/Finish Sign/Destructo/Marca hasta las fases 2 y 3: en v20r Goku, Freezer y Trunks no se transforman.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20r.w3x | `93df84bd07450b5e2f0b7729f6c12fda728945ed0cb52bed3d7abd079c9eead5` |
| TerrainDev-Titulo-v20r-prueba.w3x | `849a657aa7ef9d088026d1513212501afe21e3b458a686336aa606086f678cc7` |

Comprobado: pJASS en las dos; j y w3a reextraídos iguales; bytes-diff sólo (attributes), (listfile), j y w3a;
`mpq verify`; copias en WOE con cmp. **Validated**; sin jugar. Por comprobar en juego: que la W de Naruto cambie al
entrar y salir del Kyuubi y que las cartas no ofrezcan lo quitado.

Siguiente: fase 2 (transformaciones por muertes).

### v20s – fase 2 (20/11/2026)

Fuentes: `scripts/v20s.py` (j), `scripts/objetos_v20s.py` (w3a), `scripts/hacer-v20s.sh`; lanzadores
`entrar-v20s.sh` y `entrar-v20s-prueba.sh`.

- Puntos por jugador y wave (`Frm_Pts`, desde `Mvp_Muerte`): normal 1, élite 5, jefe 15. Cuota
  `max(10, DevWave_Total / DevWave_Jug)`.
- Goku: SSJ 20 %, SSJ2 40 %, SSJ3 60 %, SSJ4 85 %; sube un nivel por muerte con el morph de D.O.N (`GkF_B77` vía
  `ExecuteFunc`).
- Trunks: SSJ 25 %, SSJ2 50 % (`TrF_gi4`), Finish Sign 75 % (Roar del héroe, 3600 s).
- Freezer: Power Up 30 % (Berserk del héroe, 3600 s).
- Sin corte a los 50 s: la forma se pierde al morir (se recupera matando) o al terminar la wave (`Frm_Fin`, quita
  B04B/B03N y deja a Goku/Trunks en la base). Aviso de texto sólo al jugador.
- -prueba: líneas "forma …", "finish sign", "power up freezer" y "fin de wave" en `lat\v20s-don.txt` (con -reg).
- Sin `GetLocalPlayer` nuevo: no hace falta LAN para esta fase.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20s.w3x | `7932534b2b7f75d542535ae5bf0ab13fab80928b9077801360d62cb51f5189d8` |
| TerrainDev-Titulo-v20s-prueba.w3x | `08a00843b5ab1fa13c305c9beb4cb4facc5362a388777671de350fdb1957f60b` |

Comprobado: pJASS en las dos; j y w3a reextraídos iguales; bytes-diff sólo (attributes), j y w3a; `mpq verify`;
construcción reproducible (mismo hash al repetir); copias en WOE con cmp. **Validated**; sin jugar.
Por comprobar en juego: que el morph se vea al cruzar cada umbral, que no se corte a los 50 s, que vuelva a la base al
acabar la wave y tras morir, y que los buffs de Freezer/Trunks se quiten.

Siguiente: fase 3 (procs de Destructo y Marca, pasiva en área del Tauren). Hecha en v20t.

### v20t – fase 3 (20/11/2026)

Fuentes: `scripts/v20t.py` (j), `scripts/hacer-v20t.sh`; lanzadores `entrar-v20t.sh` y `entrar-v20t-prueba.sh`.

- Pasivas por impacto de bala (`Arm_Impacto` → `Prc_Golpe` con `ExecuteFunc`). Probabilidad por impacto
  `clamp(25 % × intervalo del arma en la mano, 4 %, 25 %)`: arma de 0,8 s → 20 %; ametralladoras de 0,09-0,17 s → 4 %;
  arma de 1 s → 25 %.
- **Freezer:** Destructo Disc (A0IY) sale solo, lo lanza la copia como la X de antes; 1,5 s entre procs y no se lanza si
  el anterior sigue en curso (`Dcp_Ocupada`).
- **Cairne:** Marca ancestral (cuerpo `Cop_MarcaHacer`, el botón viejo sigue llamándolo) sobre el enemigo de más vida a
  400 del blanco; 3 s entre procs.
- **Tauren:** el daño del impacto se repite a 300 alrededor del blanco con el efecto WarStompCaster; 1 s entre procs.
  Fuera el triple del 4.º impacto.
- -prueba: líneas "pasiva tauren/destructo/marca j… prob …" en `lat\v20t-don.txt` (con -reg).
- Sin objetos nuevos ni `GetLocalPlayer` nuevo: no hace falta LAN.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20t.w3x | `f3cb2627da5cb5bea79ce61324d044b15654ef213c7dc6ff1b8a6fa73baae744` |
| TerrainDev-Titulo-v20t-prueba.w3x | `5b1d5a40d9e9db9034cd38541a508c4a8db560cf429f784aa858df373bf76b93` |

Comprobado: pJASS en las dos; j reextraído igual; bytes-diff sólo (attributes), (listfile) y j; `mpq verify`;
construcción reproducible; copias en WOE con cmp. **Validated**; sin jugar.
Por comprobar en juego: frecuencia de cada proc con armas rápidas y lentas, que Destructo salga hacia donde apunta el
héroe, que la Marca se vea y el área del Tauren coincida con el efecto del pisotón.

Siguiente: fase 4 (técnicas de un blanco en área). Hecha en v20u.

### v20u – fase 4 (20/11/2026)

Fuentes: `scripts/v20u.py` (j), `scripts/hacer-v20u.sh`; lanzadores `entrar-v20u.sh` y `entrar-v20u-prueba.sh`.

Técnicas de un blanco: Warp Kamehameha (A0IA), Imprisonment Ball (A0IV), Death Break (A0J1), Heat Dome (A086),
Burning Slash (A03W), Senpuu Odama (A0AI) y Rasenrengan (A0F5). El daño en área ya existía desde v19d (`Dcp_Eco`:
cada golpe de la copia al blanco se repite a los enemigos a 300 de él, incluidos los que llegan).

- Nuevo (`Jun_*`): al lanzar, hasta 8 enemigos a 300 del blanco se juntan con él (a 80 en 0,4 s) y copian cada 0,04 s
  su posición, altura de vuelo, giro y pausa. No se juntan jefes, unidades ya pausadas ni las de otro grupo.
- Fin: 0,4 s seguidos sin motor de D.O.N, copia sin orden y blanco sin pausa y en el suelo; también si muere el
  blanco o a los 10 s. Al soltarlos vuelven a su altura y se recolocan en suelo transitable.
- `Dcp_Eco` repite el daño a 12 enemigos (antes 8).
- -prueba: líneas "area j… tecnica … juntos N" y "area fin j… tics N" en `lat\v20u-don.txt` (con -reg).
- Sin `GetLocalPlayer` nuevo: no hace falta LAN.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20u.w3x | `33e30b145ce8483ab3473ad8adddba4146eaa9fa88a330109e958e22b6572154` |
| TerrainDev-Titulo-v20u-prueba.w3x | `988626f3806d20becf1a6cf3322c7f9b15dafb4fe219b3cd11e32909cf8640e8` |

Comprobado: pJASS en las dos; j reextraído igual; bytes-diff sólo (attributes) y j; `mpq verify`; construcción
reproducible; copias en WOE con cmp. **Validated**; sin jugar.
Por comprobar en juego, técnica por técnica: que los juntados se vean con el blanco y suban con él, cuánto duran
(línea "tics"), que reciban el daño final y que al soltarse no queden quietos ni atascados (las oleadas deben volver a
darles orden).
