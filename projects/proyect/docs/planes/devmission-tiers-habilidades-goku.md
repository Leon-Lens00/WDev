# Dev Mission: tiers de habilidades (Goku primero)

Estado: v21m **Validated** (sin jugar). Base: v21l (`80a935a0…`, prueba `8e495860…`).

## Pedido de Leon (22/11/2026)

- "dar rework a sus mejoras en la tienda, al igual que las armas esta tendra tier".
- "al tener la habilidad a tier maximo debera tener un danio bien alto a nivel de un cartucho completo de armas".
- "en las cartas el tier maximo es el rojo".
- "es como referencia el cartucho ya que el kameha tier maximo no seria como la ultimate R a tier maximo, debe haber
  ese plus adicional".

## Estado actual (lectura de v21k)

- Las técnicas suben por cartas del héroe (`Tec_Cartas`, `Tec_Aprender`): nivel 1-4 (R 1-3). La carta usa
  `Her_Cal = min(4, nivel)`.
- Daño de Goku por fórmula de D.O.N: nivel de la habilidad × 100-400 + fuerza fija (`Gk_Fuerza`, 56 con `Gk_Nivel` 10).
  Q nivel 1: 212 por enemigo, una vez. Muy por debajo de un arma roja.
- Armas: 6 tiers (amarillo, verde, cian, azul, morado, rojo), `Arm_Req` abre T2-T6 en las rondas 1, 2, 4, 6 y 8.

Cargador completo en rojo (T6), un blanco:

| Arma | Cargador |
|---|---|
| Tipo 91 Kin-SAM (área 280) | 2372 |
| MP5 | 2850 |
| FN SCAR | 2925 |
| AWM (perfora 7) | 5316 |
| SPAS-12 (3 perdigones) | 13440 si entran todos |

Referencia elegida: **2900** (FN SCAR / MP5).

## Propuesta

- Tier 1-6 por técnica, con el color de las armas; las cartas de técnica pasan a "Subir tier" con el mismo color y la
  misma puerta por ronda (`Arm_Req`).
- Curva por tier, como el cargador de los rifles: 25 %, 35 %, 45 %, 60 %, 80 %, 100 %.
- Daño total por enemigo y lanzamiento en T6:
  - Q Kamehameha: 2900 (un cargador).
  - W: 2000 (0,7 cargador).
  - R, en todas las formas (Genkidama, Super Kamehameha, Dragon Fist, Big Bang, Ultra Instinto): 5800 (dos cargadores).
  - Kaioken (R en forma 5) no hace daño: su bono a las armas sube por tier.
- E (Revert) y X (forma) no tienen tier.
- Las técnicas que golpean varias veces (Super Kamehameha por tick, Big Bang con explosiones al azar) reparten el total
  entre golpes. La versión de prueba anota el daño total al enemigo más golpeado por lanzamiento para calibrar.
- El daño deja de depender de `Gk_Fuerza`.

## v21m (22/11/2026)

Leon aceptó las cifras ("Sí, con esas cifras") y añadió: "le quitaremos el mana a las habiliades tambien pero en contrar
aunmentaremos mucho mas el CD para no manchas al protagonismo de las armas".

- `scripts/v21m.py`:
  - `Gk_TDano(u, x, total)` = total en T6 × `Tec_Curva[tier]`;
  - Q 2900 (Tec 43), W 2000 (42), R 5800 (40);
  - Big Bang /5 por golpe, Super Kamehameha /40 por tick (D.O.N /20; aquí casi siempre frena por enemigos cerca);
  - Kaioken `Kai_Bono` = 1,5 × curva;
  - `Tec_Max` 6 y `Tec_Tope` (nivel real máximo 4/4/3);
  - cartas con `Tec_Puede` (puerta `Arm_Req` copiada) y `Tec_Cal` (color del tier nuevo, 6 = rojo);
  - `Tec_Des` dice el tier nuevo y su daño por enemigo;
  - el texto flotante del Dragon Fist muestra el daño real.
- `scripts/objetos_v21m.py`: AGk1-5 sin maná; recargas Q 20 s, W 30 s, R 90 s, X 10 s y E 5 s.
- Sólo prueba:
  - registro "goku dano Q|W|R forma N Tt max X enemigos N", con el daño bruto máximo a un enemigo por lanzamiento, 6 s
    después del primer golpe;
  - comando `-gt N`, que pone Q, W y R en el tier N.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21m.w3x | `251c0d08ff04f8b0c70766b1fcdce872180452a1dc916aa68c47195d594a4023` |
| TerrainDev-Titulo-v21m-prueba.w3x | `12c35bf5007982422870093ab536bb03a7db8a8b6755d0d29a2d0cdffea2d8ae` |

Comprobaciones: pJASS correcto en las dos; cambian sólo el j y el w3a (reextraídos por hash); `mpq verify` correcto;
copia en WOE con cmp. Estado **Validated**.

Sin comprobar:
- daño real en el juego, que depende de la armadura;
- el reparto de la Super Kamehameha y del Big Bang;
- cartas con color rojo;
- puerta por ronda;
- la otra versión del texto del libro.

## Próximo paso

Leon prueba v21m-prueba con `-gt 6` (y algún tier bajo): Q, W y la R en varias formas sobre grupos de enemigos. Con el
registro "goku dano" se ajusta el divisor de la Super Kamehameha y del Big Bang para que la R quede cerca de 5800 por
enemigo. Después, la misma regla para Freezer, Trunks y Naruto.
