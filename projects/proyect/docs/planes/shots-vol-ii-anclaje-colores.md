# Shots Vol. II — edición y organización

Fecha: 2026-10-22. Solicitud: repetir el ajuste de punta, coherencia de efectos, pack de jugadores y organización por color de Vol. I sobre Shots Vol. II de Vinz. El usuario eligió conservar sólo la forma simple publicada; no crear Double.

Objetivo: Classic 1.27b, MDX800. Originales y procedencia en `descargas/warcraft3/misiles/vinz/shots-vol-ii/`. Código dentro del índice existente `ModelEditor`; exports/assets/build/evidence excluidos. Conservar sin cambios Vol. I y sus fuentes/hashes.

## Fases

1. Descargar ZIP original y comprobar CRC/hashes; inventariar jerarquía, geometría, texturas, luces, emisores y secuencias de los seis MDX. Estado: completado (ZIP CRC y siete hashes conservados).
2. Determinar el ajuste según sus datos reales, no asumir estructura idéntica a Vol. I. Punta de Stand en X=0, centro transversal alineado; conservar el origen del impacto y la deformación local. Actualizar bounds conservadoramente. Estado: completado; helpers exclusivos separan estela de impacto.
3. Preparar seis derivados con colores originales y doce variantes de jugadores. Conservar máscaras, cantidades, velocidades, tiempos y filtros; recolorear luz y partículas con texturas neutrales si hacen falta. Rutas exclusivas ShotsVolII para coexistir con Vol. I. Estado: producido; revisión de núcleo blanco terminada y aplicada en colección nueva con gradiente.
4. Relectura independiente, comparación de componentes/poses por secuencia, originales intactos, dependencias completas y comparación visual en copia de 1.27b si hay sesión disponible. No probar sobre partidas ajenas; inventariar prefijos/ventanas y separar monitor propio. Estado: archivos y 6174 poses verificados; mapa cargado en 1.27b, vuelo Stand observado. El ensayo comparativo de color prueba azul/rojo de ambos volúmenes a escala 1 y 3.
5. Entregar colección `shots-vol-ii-organizados/{Colores-de-jugadores,Colores-originales}/Misil-simple/COLOR/` con MDX, MDL, recursos, créditos e imports, ZIP y manifiestos. Estado: colección organizada de 18 modelos creada; ZIP final completado en la revisión `shots-vol-ii-organizados-brillo.zip`, CRC y bytes verificados.

Aceptación: frente geométrico de vuelo en X=0 dentro de 1e-3; no desplazar globalmente el impacto; no omitir emisores/luces/eventos en validación. Separar lectura/poses de prueba en motor y de colisiones/LAN (fuera de alcance). Las luces se comprueban en datos y visualmente donde sea observable, sin prometer medición fotométrica.

Tooling previo: `ModelEditor/src/model.cjs`, `anchor.cjs`, `build-shots.cjs`, `verify-shots.cjs`, `textures.py`, `fixture.py` y `organize.cjs`, consultados por CodeGraph antes de adaptar. Mantener scripts Vol. II separados o parámetros explícitos para no regenerar accidentalmente Vol. I.

## Revisión solicitada del núcleo claro

El usuario pidió verificar la pérdida de brillo blanco en ambos volúmenes. Se confirmó en datos y motor. La muestra diagnóstica está separada en `ModelEditor/exports/candidatos-brillo`; Vol. II recupera blanco con intensidad excesiva frente al original, por lo que no se sustituye la colección principal. Informe resuelto: `informes/errores/resueltos/2026-10-22-180100-shots-colores-sin-nucleo-blanco.md`. El diagnóstico actual no acredita una calibración final ni cobertura visual de todos los colores.

## Cierre

A petición posterior del usuario, se terminó la calibración y revisión de color de ambos volúmenes. Bases/originales/paquetes previos conservados. Vol.II entregado en `ModelEditor/exports/shots-vol-ii-organizados-brillo/` y ZIP homónimo: 18 modelos, seis originales anclados y doce jugadores simples, cada color con recursos/créditos. Vol.I revisión equivalente con simple/doble. Pruebas y límites en `ModelEditor/REVISION-BRILLO.md`; comparación final en `evidence/brillo/comparacion-final.png`. No hay pendiente dentro de la edición/organización solicitada; integración de colisiones y LAN no forman parte del encargo.
