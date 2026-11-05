# Tienda v14k: retratos invisibles y zonas de clic pintadas que no se dibujan

- Fecha: 04/11/2026. Agente: Claude (chat de Dev Mission). Proyecto: TerrainDev-Titulo v14k, copia en
  `work/titulo-devmission-20261026`. Warcraft III Classic 1.27b, perfil proton-ydwe-modern.

## 1. Retratos de la tienda invisibles — corregido, comprobado en el mapa

- Síntoma: el golem, el Tauren y Cairne ('dta0'/'dca0' con la cadena PortraitBillboard→PortraitFlat→PortraitView)
  no se veían en la tienda (X 2400). El registro diag confirmó la posición, la altura, que no estaban ocultos y
  que estaban vivos (`evidencia/vista-v14k-diag`).
- Causa confirmada: el hueso con billboard se pone de canto lejos de X 0 (igual que uidb con |X| > ~600).
- Corrección: `scripts/retrato_sin_billboard.cjs` quita la bandera 0x8 y fija una rotación de -90° en Y en cada
  secuencia. Hay unidades nuevas 'dgo0', 'dts0' y 'dcs0'.
- Comprobación: recorridos `evidencia/vista-v14k-vista2` a `vista-v14k-vista5`. Los tres retratos se ven
  derechos, sin espejo.

## 2. Zonas de clic pintadas no visibles — abierto

- Síntoma: en v14k-tienda y v14k-vista, los modelos ShopHit*-pintada (quads a 14 sobre el suelo, TeamColor00-06,
  flags 0xF1) no aparecen.
- Combinaciones probadas, todas sin quads visibles:
  - filtro aditivo (3) con los cuadros a alfa 255;
  - cuadros al 60 % de alfa;
  - sin ShopPlano (el suelo verde sí se ve);
  - filtro 0 opaco (`evidencia/vista-v14k-vista5`).
- Los clics sí funcionan: las compras del recorrido se registran en `lat`.
- Hipótesis pendientes, ninguna confirmada:
  - el trackable no dibuja ese modelo con esa cámara;
  - una propiedad de la geometría base (v14a ShopHit*.mdx) lo oculta.
- Pendiente: probar con un modelo visible conocido (p. ej. un modelo del juego) como trackable en la misma posición.

## 3. Retrato enorme y sin aplanar al abrir la tienda — corregido, comprobado en LAN

- Síntoma: en la LAN de dos clientes (`work/titulo-devmission-20261026/v14k-lan/lan/try1`, capturas a004/b004), en
  el primer instante tras abrir la tienda el golem salía enorme y fuera del marco en los dos clientes.
- Causa: el giro fijo de PortraitBillboard tenía claves sólo dentro de cada secuencia. Antes de que el motor fije
  la animación, se usaba el valor por defecto y la cadena no se aplanaba.
- Corrección: `retrato_sin_billboard.cjs` pone el giro en una secuencia global propia (1000 ms).
- Comprobación: en `try3`, la primera captura tras abrir sale bien en los dos clientes. Las capturas son cada
  ~2 s, así que un parpadeo de menos de 2 s podría escaparse.
