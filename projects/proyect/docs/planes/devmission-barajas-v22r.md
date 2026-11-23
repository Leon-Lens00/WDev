# Dev Mission: rework de las barajas de la tienda (v22r-v22u)

Objetivo (Leon, 23/11/2026): más variedad de cartas en Armas, Habilidades y Mutación Evo. Una carta tomada no vuelve a
salir salvo que tenga niveles, y deja de salir al llegar al máximo. Fuera el texto superior de Armas y Habilidades.
Base: v22q (`32d3ce7f…`), v22q-prueba (`1017d5e2…`). Classic 1.27b, JASS. Código en
`Proyect/work/titulo-devmission-20261026/scripts/`.

## Decisiones de Leon

- 23/11: quitar el texto superior de Armas y Habilidades. Es "Mutaciones activas" (Cua_TMut); el panel del menú ya
  las muestra.
- 23/11: cartas de armas nuevas por categoría: intervalo, distancia, velocidad, área (sube la escala del proyectil),
  recarga, cartuchos adicionales, balas por cartucho "y otras más". Más cartas también en Habilidades y en jefe/oleadas.
- 23/11: el tier (calidad) de una carta da su valor, independiente de los niveles. Si ya no quedan cartas
  principales, salen bonificaciones sin tope de valor bajo (vida, daño "y demás", a recomendación del agente).

## Fases

| Versión | Contenido | Estado |
|---|---|---|
| v22r | texto fuera, topes, no repetición, bonificaciones sin tope, mutaciones a 3 niveles | Validated |
| v22s | cartas nuevas de armas por categoría (111-120) e iconos de la votación iguales para todos | Validated |
| v22t | cartas nuevas del héroe (121-126): regeneración, armadura, robo de vida, curación al matar, segundo aliento, trébol | Validated |
| v22u | mutaciones nuevas de jefe, élites, comunes y oleada (130-141) | Validated |
| v22v | 5 cartas en Armas y 5 cuadros en cada paso de Mutación Evo | Validated |
| v22w | Segundo aliento: curación poco a poco al salir el jefe | Validated |

## v22r

- **Topes** (Car_Max; tomas por jugador en Car_Tom[p×200+x], por categoría en Car_TomC[p×56+e×8+hueco]):
  - héroe: Vitalidad 5, Zancada 4, Botín 4, Evasión 5, Reembolso 3, Imán 3, Interés 3, Bolsa doble 3;
  - dash y linterna conservan sus topes de estado;
  - armas: Filo 5, Golpe de suerte 4, Vida extra 3;
  - por categoría: Calibre 4, Cargador ágil 3.
- **Dónde se excluyen las cartas al máximo:** al repartir (Car_Heroe, ArmC_Cartas, Arm_TipoAzar), al abrir un paso
  guardado (Her_AlDia), en la mano comprada (HerC_AbrirA, HerC_Libre) y en el cambio de Subir tier inválido (Car_Filo).
- **Bonificaciones sin tope** (sólo si faltan cartas; valor T1..T5):

  | Id | Carta | Efecto | T1..T5 |
  |---|---|---|---|
  | 105 | Fortaleza | vida | 25/40/60/90/120 |
  | 106 | Paso ligero | velocidad | 3/5/8/12/15 |
  | 107 | Fortuna | % oro de bolsas | 2/4/6/9/12 |
  | 110 | Recolector | radio de bolsas | 10/15/20/30/40 |
  | 108 | Afilado | % daño de las armas | 2/3/5/7/9 |
  | 109 | Calibre menor | % daño de una categoría | 3/5/8/12/15 |

  Vida extra ya no rellena.
- **Mutación Evo:** cada mutación hasta 3 niveles (Mut_Tope, Cua_Libres). Si un grupo está entero al máximo, valen
  todas. Con menos candidatas salen menos cuadros. Con 10 rondas no llega a agotarse: el jefe tiene 4 × 3 = 12 niveles.
- **Textos:** "Nivel n/máx" o "Sin tope" bajo la descripción de la carta; las mutaciones activas muestran su nivel.
- **Registro (sólo prueba):** "carta jP Nombre nivel N/M".
- **Hashes:**
  - v22r `3a56697e9ed9323266e35428a1fecc94095e511df9958f7abc178c2f9d6dfc60`;
  - v22r-prueba `3ffb9372ebb490a49e7dbc07ca8d73489dc1e8dc06c486dc7c20116e21d56c3a`.
- **Comprobado (Validated):** pJASS en las dos variantes, reextracción por cmp del j, bytes-diff sólo j, mpq verify y
  copia en WOE.
- **Sin comprobar:**
  - que la cuarta línea de la descripción quepa en la carta;
  - LAN (la pantalla de cartas sigue sin ensayo de dos clientes).

## v22s

- **Votación de Mutación Evo (Leon: "mostraba diferentes cartas a los jugadores"):** nombres y textos ya salían de
  Cua_Gana, igual en todos; el icono de cada cuadro (Mut_Ico) sólo toma la textura al crear la pieza, así que se quedaba
  con la de antes. Ahora los 3 iconos se rehacen con la textura de la ganadora al empezar la muestra (código común).
  Causa deducida del código; falta verlo en partida.
- **Cartas nuevas de Armas** (categoría al azar entre las que tiene y admiten la carta; valor por calidad T1..T5;
  cuenta por categoría en Car_TomC[p×112+e×16+hueco]):

  | Id | Carta | Efecto | Categorías | Tope | T1..T5 |
  |---|---|---|---|---|---|
  | 111 | Cadencia | % más rápido el intervalo (Arm_IntJ) | todas | 5 | 4/6/8/11/14 |
  | 112 | Alcance | % de alcance | sin cuerpo a cuerpo | 4 | 5/8/11/15/20 |
  | 113 | Bala rápida | % de velocidad de bala | sin cuerpo a cuerpo | 4 | 6/9/13/18/24 |
  | 114 | Calibre grueso | % de área, radio de choque y tamaño | todas | 4 | 6/9/13/18/24 |
  | 115 | Cargador ampliado | % de cargador, al menos +1 por nivel | sin cuerpo a cuerpo | 4 | 8/12/16/22/30 |
  | 116 | Cartuchos extra | % de reserva | sin cuerpo a cuerpo | 4 | 10/15/20/28/36 |
  | 117 | Perforación | +enemigos atravesados | subfusiles, rifles, francotiradores, escopetas | 3 | 1/1/1/2/2 |
  | 118 | Perdigones | +perdigones por disparo | escopetas | 3 | 1/1/1/2/2 |
  | 119 | Precisión | % menos dispersión (máx. 80 %) | subfusiles, rifles, escopetas | 3 | 10/15/20/28/36 |
  | 120 | Puntería letal | % de crítico ×2 | sin cuerpo a cuerpo | 4 | 3/4/6/8/10 |

  Iconos reutilizados de otras cartas. Cargador y reserva con carta: recarga, relleno por oleada, zonas de munición,
  subir tier y compra de balas (Arm_MagJ, Arm_ResJ). El panel guarda la categoría de cada carta (Pan_HT).
- **Hashes:**
  - v22s `a0b8c737a0d5c87c7d738408a916455f443b570c2b0de0c3e9eec5ac797b11bd`;
  - v22s-prueba `8a4e51bdcf601caa74627f5ae972da2a05fe9c61e95966388809d68599307f54`.
- **Comprobado (Validated):** pJASS en las dos variantes, reextracción por cmp del j, bytes-diff sólo j, mpq verify y
  copia en WOE.
- **Sin comprobar:** todo en partida (efectos, textos largos en la carta, iconos de la muestra); LAN.

## v22t

- **Cartas nuevas del héroe** (en Her_Pool 10-15, con las demás; valor por calidad T1..T5; tope en Car_Max):

  | Id | Carta | Efecto | Tope | T1..T5 |
  |---|---|---|---|---|
  | 121 | Regeneración | +vida por segundo (BonusMod en el héroe) | 4 | 2/3/5/8/12 |
  | 122 | Armadura | +armadura (BonusMod en el héroe) | 4 | 1/2/3/4/6 |
  | 123 | Robo de vida | cura un % del daño real hecho a unidades de la oleada (Mvp_Golpe) | 4 | 1/2/3/4/5 % |
  | 124 | Curación al matar | +vida por baja (junto a Bat_Matar) | 4 | 3/5/8/12/16 |
  | 125 | Segundo aliento | al empezar cada oleada, cura un % de la vida máxima (Ronda_Lanzar) | 3 | 10/15/20/30/40 % |
  | 126 | Trébol | +suerte fija en la tirada de calidad (Her_TiraCalBruto) | 3 | 2/3/4/6/8 |

- **Fuera:** recarga y poder de técnicas (están en los datos de objeto de cada técnica) y escudo (en 1.27b no se puede
  reducir el daño recibido desde el script sin riesgo con golpes mortales).
- Iconos reutilizados.
- **Hashes:**
  - v22t `6144cdf07476215914dcb38033c134520b2c4f0103873d375ba0007db8e8c796`;
  - v22t-prueba `cbd15d552b06d8c2e85cf560425596fb7b09806466291fc68d3ab561271c685f`.
- **Comprobado (Validated):** pJASS en las dos variantes, reextracción por cmp del j, bytes-diff sólo j, mpq verify y
  copia en WOE.
- **Sin comprobar:** en partida (sobre todo regeneración y armadura con BonusMod en el héroe, y que sigan tras
  reaparecer o transformarse); LAN.

## v22u

- **Mutaciones nuevas** (ids 130-141, porque del 18 en adelante son cartas del héroe; hasta 3 niveles como las demás;
  efecto por nivel):

  | Id | Grupo | Mutación | Efecto por nivel |
  |---|---|---|---|
  | 130 | jefe | Caparazón | +5 armadura |
  | 131 | jefe | Sangre eterna | recupera 0,5 % de la vida máxima por segundo |
  | 132 | jefe | Embestida | ataque +20 %, carrera +15 % |
  | 133 | élites | Élite robusta | +40 % vida |
  | 134 | élites | Élite furiosa | +30 % daño |
  | 135 | élites | Élite ágil | carrera y ataque +20 % |
  | 136 | comunes | Coraza | +2 armadura |
  | 137 | comunes | Colmillos | +20 % daño |
  | 138 | comunes | Frenesí | ataque +15 % |
  | 139 | comunes | Vanguardia | cuerpo a cuerpo (sin los tipos 2, 4, 5 y 7): +35 % vida, +10 % carrera |
  | 140 | oleada | Marea creciente | los que salen pasados 30 s: +30 % vida, +20 % daño |
  | 141 | comunes | Estallido | el 10 % de los comunes explota al morir: (8 + 4 × ronda) de daño a los héroes a 200 |

- **Sorteo:** lista virtual Mut_V (jefe 0-6, élites 7-13, comunes 14-29) en Cua_Elegir, Cua_ElegirPeso, Cua_Libres y
  el Pacto mutante (Car_MutLibre). Mut_Grupo y Mut_Es sustituyen los rangos fijos 0-3 / 4-7 / 8-17 en el panel, la
  purga (sigue sin tocar las del jefe), los textos y los iconos (Pan_MIco sólo para mutaciones).
- El panel muestra como mucho 10 iconos por grupo; con el Pacto mutante podrían activarse más de 10 comunes distintas
  y las sobrantes no tendrían icono (ya pasaba igual).
- Iconos reutilizados. Registro de prueba: Mut_Anotar cuenta también 130-141.
- **Hashes:**
  - v22u `5d414a3175f59d6e0da632ff992f2c38f436ce9d4a04043c2345ec7a23f58885`;
  - v22u-prueba `7f1245f9635c88456c51053cd430031c0c5dec56e566fbe38aee0fef1f9efe6b`.
- **Comprobado (Validated):** pJASS en las dos variantes, reextracción por cmp del j, bytes-diff sólo j, mpq verify y
  copia en WOE.
- **Sin comprobar:** en partida (que salgan las nuevas en la votación, sus efectos, el panel con más mutaciones); LAN.

## v22u-prueba jugada (23/11)

Registros de una oleada (la 6) y su descanso: en la votación salieron Embestida, Élite furiosa y Frenesí; ganó Élite
furiosa. Se tomaron Robo de vida T4, Armadura T4 y Segundo aliento T3 sin errores. No llegó a la oleada 7, así que no
hay efectos de mutaciones medidos.

## v22v

- Leon: "en la tienda de armas hay que agregar una tarjeta y 2 en la de jefes, ya que son pocas a comparacion de las
  habilidades que lleva 5".
- **Armas:** 5 cartas (Cua_HCand[p×40+35..39]). La cola de pulls guarda 4 por pull; la quinta va en
  HerC_A5C/Q/T[p×8+i]. En Armas la quinta casilla es carta, no el refresco del héroe (Her_Nombre, Her_Des, Her_Tinte).
- **Mutación Evo:** Cua_NE = 5 con cualquier número de jugadores (antes 3 con 1-2, 4 con 3-5, 5 con 6+); jefe y
  élites ya no se limitan a 4. Interpretación: "la de jefes" es toda la pantalla de Mutación Evo (jefe, élites y
  comunes).
- **Hashes:**
  - v22v `68360b17ae485d9bd38e2af0d9a33c9cb55e902afb2088d252c7858194463327`;
  - v22v-prueba `84ac55880fdd517c3d5f86297ce1fadee41c9a33f8d7abb6d787d0c410a1544d`.
- **Comprobado (Validated):** pJASS en las dos variantes, reextracción por cmp del j, bytes-diff sólo j, mpq verify y
  copia en WOE.
- **Sin comprobar:** en partida (que la quinta carta de Armas se vea, se elija y se conserve al salir con ESC de un
  pull; los 5 cuadros de la votación); LAN.

## v22w

- **Fallo de v22t:** Segundo aliento curaba al empezar la oleada, pero Ronda_Reponer ya llena la vida al acabar cada
  oleada (y el héroe es invulnerable en el descanso): no hacía nada. Informe en
  `Proyect/informes/errores/2026-11-23-084939-devmission-segundo-aliento-sin-efecto.md`.
- **Ahora (Leon: "poco a poco, al empezar el jefe, con los tier sube la duración"):** al salir el jefe de la oleada,
  cada héroe con la carta recupera el 2 % de su vida máxima por segundo (1 % cada 0,5 s) durante 5/7/10/14/20 s según
  T1..T5; tomarla otra vez suma segundos (tope 3).
- **Revisión de las demás mejoras:** todas las variables que escriben las cartas del héroe, de armas y las
  bonificaciones se leen en un efecto. Las que dependen del ritmo (Interés y Codicia al empezar el descanso, Vida extra
  con 25 vidas, Cartuchos extra con reserva finita, Marea creciente con aparición escalonada por el límite de vivos,
  Regeneración y Robo de vida durante la oleada) tienen sentido. Revisión de lectura, no de partida.
- **Hashes:**
  - v22w `03a41396c52cdad1677960eb910398cb6f18e8d90e05fef8cff1662df61a7f13`;
  - v22w-prueba `1ed96c6d46bcc5cd759e72abf50c4a54467587c7fda6a628f27d15fbf73f2c0f`.
- **Comprobado (Validated):** pJASS en las dos variantes, reextracción por cmp del j, bytes-diff sólo j, mpq verify y
  copia en WOE.
- **Sin comprobar:** en partida (registro "aliento jP N s" en `lat/v22w-*.txt` al salir el jefe); LAN.

## Próximo paso

Leon juega v22w-prueba varias rondas (incluye lo de v22r, v22s y v22t):
- tomar varias veces la misma carta hasta el máximo y ver que deja de salir; sin cartas, que salen las bonificaciones;
- tomar cartas nuevas de Armas y del héroe y notar su efecto;
- en la votación, que salgan mutaciones nuevas, que los iconos de la muestra sean los de las ganadoras y que el panel
  las muestre en su grupo;
- notar Estallido, Marea creciente y las del jefe.

Con eso termina el rework de barajas; después, calibrar con lo que se vea en partida.
