# Dev Mission v15c: prototipo experimental

**No reemplaza al mapa entregado.** El mapa de referencia sigue siendo la línea v14
(`../../TerrainDev-Titulo-v14k.w3x` en esta copia; v14n es la última v14 en Proyect). Esta carpeta guarda el prototipo
de armas fijas con sobrecarga y la tienda nueva para seguir probándolo aparte.

- Mapa: `TerrainDev-Titulo-v15c.w3x`, SHA-256 `54aa3dc0cbc5bd2122616054b54d7ee37445d05df930c611c65e66eee2358656`.
  Sin registros de prueba.
- Base: `TerrainDev-Titulo-v14n.w3x` → v15a (`hacer-v15a.sh`) → v15c (`hacer-v15c.sh`). Las rutas de los scripts
  apuntan a `Proyect/work/titulo-devmission-20261026`, la carpeta activa; aquí son copia.

## Qué cambia respecto a v14

- 4 armas fijas en Q/W/E/R (pistola, subfusil, escopeta, francotirador), 7 modelos por arma.
- Sin munición ni «Abastecer todo»: sobrecarga en la barra de armadura, con refresco cada 0,10 s y Refrescar (F) con
  kits.
- Tienda del prototipo de UI System: vista de modelos y árbol de 6 mejoras por modelo, con el color del tier.
- Balas del color del tier (Shot, Shot II, Firebrand, Daemonic Arrow) y sonidos de ShootingGay.
- Precios v15d (una arma a T7 ≈ 28 200 oro).

## Estado

- Validated: pJASS; reextracción y `mpq verify`.
- Tested in map (un jugador): prueba automática con registros y capturas.
  - Detalle: `docs/planes/devmission-armas-sobrecarga-v15.md`.
- Abierto:
  - Rechazo ocasional de la orden de disparo (`informes/errores/2026-11-05-200240-v15a-refrescar-y-barra.md`).
  - Caída a unos 6 FPS en la ronda 9–10 de una partida jugada por Leon. La medición dio el hilo principal del juego
    al 100 % de un núcleo, memoria estable en 573 MB y gráficos casi parados. Causa sin investigar (`informes/errores/2026-11-05-211500-v15c-fps-ronda-10.md`).
- Sin comprobar: LAN de dos clientes y balance en partida completa.

Créditos: Vinz (Shots, Firebrand); Vinz y Daemonic Sword (Daemonic Arrow, Hive 337124); ShootingGay 0.7ENG
(sonidos); prototipo y texturas de UI System.
