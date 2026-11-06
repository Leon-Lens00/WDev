# v15a: relleno de sobrecarga invisible, botones verdes en pausa y un Refrescar que no arrancó

- Fecha: 05/11/2026. Origen: chat Integration (Claude), Dev Mission v15a.
- Entorno: Warcraft III Classic 1.27b, perfil `proton-ydwe-modern`, variante `TerrainDev-Titulo-v15a-auto.w3x`
  (prueba automática de `scripts/prueba_v15a.py`, registros `CustomMapData/lat/v15a-N.txt`).
- Construcción: `Proyect/work/titulo-devmission-20261026/scripts/hacer-v15a.sh`.

## 1. Relleno de la barra de sobrecarga invisible (corregido, comprobado)

- Síntoma: con la sobrecarga al 58% y al 97% el hueco de la barra seguía vacío; el texto sí cambiaba de color.
- Descartado por registro: el relleno no estaba oculto y estaba a la misma altura y posición que el marco. El BLP tiene
  alfa 255 en la franja (Pillow no lee el alfa de estos BLP1 y lo da a 0: no sirve para comprobarlo).
- Causa probable: lo translúcido se ordena por distancia a la cámara. A 399 el relleno, con su centro más a la izquierda
  que el del marco (a 400), quedaba más lejos de la cámara (≈ 462 frente a 457) y el marco lo tapaba.
- Corrección: relleno a 385, con su escala calculada a esa distancia (`Sob_Ancho`). Visto en la cuarta ejecución: barra
  roja llena al 97% bloqueada.

## 2. Botones de arma en verde con el juego en pausa (corregido, comprobado)

- Síntoma: con la confirmación de salida abierta, los cuatro botones de arma eran cuadros verdes.
- Causa: los iconos `war3mapImported\BTNArma0..4.blp` no tenían `DISBTN`; venía de antes (v14n tampoco los tenía).
- Corrección: `ReplaceableTextures\CommandButtonsDisabled\DISBTNArma0..4.blp`, en gris al 45% y opacos
  (`recursos_v15a.py`). Vistos en gris en la cuarta ejecución.

## 3. Refrescar no arrancó una vez (abierto: en investigación)

- Síntoma: en la segunda de cuatro ejecuciones, a los 75 s (paso 150) la orden `stomp` de Aw08 del controlador no
  inició el refresco (`refresco 0` justo después y sin gastar el kit). En el paso 156 la misma orden sí arrancó.
- En las ejecuciones 1, 3 y 4 la misma fase pasó. En la 3 y la 4 se registró el resultado de la orden: aceptada, sin
  orden previa en el controlador.
- Hipótesis sin confirmar: la orden se rechazó por el estado del controlador tras la ráfaga del francotirador; en la
  segunda ejecución el bloqueo llegó en otro paso (48 frente a 56), así que los tiempos eran distintos.
- Impacto: posible pulsación de F sin efecto; no visto con el teclado.
- Pendiente: reproducirlo con el resultado de la orden en el registro (ya añadido a `prueba_v15a.py`) y probar F a
  mano en `v15a-prueba`.

## 4. Orden de disparo rechazada de vez en cuando (abierto; v15c)

- Síntoma: en la prueba automática de v15c (`TerrainDev-Titulo-v15c-auto.w3x`), `IssuePointOrder` de `carrionswarm`
  sobre el controlador devolvió falso en la fase de la pistola T2 de la tercera ejecución: 0 tiros en 1,5 s.
  - Antes de la orden, el controlador no tenía orden actual.
  - En la segunda ejecución, sin registro de la orden, tres fases tampoco dispararon (subfusil T3, escopeta T2 y T7).
- Descartado: enfriamiento (acdn 0 en las habilidades de arma).
- Parecido al punto 3: una orden del controlador rechazada sin causa visible, de forma intermitente.
- Impacto posible: un clic de disparo sin efecto. No se ha visto jugando.
- Pendiente: registrar el estado del controlador (pausa, canalización, maná) cuando se rechace.
- 05/11/2026, ejecuciones 4 y 5: en `prueba_v15c.py`, si se rechaza la orden, se registran maná, vida, pausa, niveles de
  Arpf/Arp1/Arp3, oculta, aturdido, down/firing de RapidPair, distancia al héroe y reloj. En esas dos ejecuciones no
  se repitió (0 de 56 fases). Sigue abierto hasta verlo con ese registro o con el teclado.
