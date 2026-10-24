# Sesgo cromático en las texturas de Shots

- Fecha: 2026-10-22 15:35 America/Lima. Agente: chat de edición de modelos. Entorno: Classic 1.27b, MDX800, ModelEditor; fuentes Vinz intactas.
- Síntoma: `textures.py` rechazó Flare.blp al comprobar neutralidad. La fase dependiente de modelos falló por faltar palette.json; no debía ejecutarse después del rechazo. Un parche de recuperación fue rechazado por intentar borrar/añadir la misma ruta dentro de la operación; se reescribió como actualización.
- Evidencia: extracción local de war3.mpq y decodificación Pillow. Diferencia máxima entre canales RGB: Flare 17 (170/1024 píxeles >2), star5tga 81 (1871/4096), Blue_Glow2 87 (675/1024).
- Impacto: tintar sólo los segmentos/geosets dejaría sesgo azul en el pack de jugadores. Originales intactos; no se entregaron modelos defectuosos.
- Causa confirmada: RGB no neutral en las tres texturas fuente. La fase dependiente se lanzó pese al error anterior.
- Estado: en corrección. Neutralizar las tres máscaras conservando brillo máximo/alfa, generar mipmaps BLP1 coherentes y ejecutar fases dependientes sólo después de éxito. El pack de anclaje conservará las texturas originales.
- Pendiente: relectura de píxeles/cabeceras/mipmaps y construcción de los 24 modelos. Aspecto en juego se acredita por separado.


## Cierre — 22 de octubre de 2026

Recuperación: las tres máscaras fueron neutralizadas; píxeles, cabeceras y mipmaps pasan relectura. Se construyeron y verificaron los 24 modelos de jugadores. Se observan sus colores y estrellas en Warcraft 1.27b (ModelEditor/evidence/impact/06.png). Estado final: resuelto.
