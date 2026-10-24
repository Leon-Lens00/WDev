# Biblioteca Vinz y selección del buster de Mega Man X3

Fecha: 2026-10-22. Objetivo del usuario: descargar todos los tipos de misiles de Vinz y guardarlos organizados como referencia; identificar visualmente disparo cargado y súper cargado de Mega Man X3 antes de crear modelos. Sólo modelos/efectos, sin física ni integración de habilidades. Destino posterior Classic1.27b/MDX800, sujeto a confirmar las muestras.

## Decisiones y alcance

- El catálogo se define por autor Vinz (Hive usuario230106) y etiqueta Missile en Classic SD Models. Incluye variantes de cada ZIP; no equivale a todos los efectos/personajes del autor. Conservar aparte cualquier requisito de parche moderno publicado.
- Reutilizar la carpeta `descargas/warcraft3/misiles/vinz/` y el índice existente ModelEditor para herramientas nuevas. Conservar fuentes ZIP, contenidos, créditos, URL, fecha y SHA256.
- Los Shots I/II editados y entregados no se modifican ni se mezclan con originales de estudio.
- No crear modelos del buster hasta que el usuario confirme las referencias correctas. Se pueden estudiar y separar cuerpo, brillo, estela, destello y aura de carga mientras tanto.

## Fases

1. Contrastar listado local de50 paquetes con paginación pública actual de Hive, autor y etiqueta. Estado: completado, tres páginas20+20+10 y cincuenta recursos.
2. Descargar paquetes originales; probar CRC, extracción segura y hashes; organizar por función/familia con un catálogo y manifiesto. Estado: completado;50ZIP y todos los contenidos contrastados.
3. Inventariar MDX y dependencias/texturas, anotar versiones y límites de lectura; no declarar compatibilidad por nombre ni alterar referencias. Estado: completado;191MDX800 leídos sin errores, dependencias registradas sin certificar1.27b.
4. Presentar muestras visuales de X3 diferenciando carga habitual y carga de brazos/Cross Charge cuando corresponda; pedir identificación y guardar su decisión. Estado: completado, usuario confirmó A/B/C. Fuente observada: retropixel.net/mmx/3/sprites.php, animaciones acreditadas del juego por Capcom.
5. Sólo después de confirmación: elaborar el pack de modelos visuales y validarlo, manteniendo física fuera. Estado: completado tras autorización explícita; siete MDX, recursos, fuentes, galería en1.27b y muestras.

## Evidencia y límites

Código dentro de `ModelEditor/src`, ya indexado. Assets, descargas, builds y evidencia fuera de cobertura del grafo. El índice anterior de50 recursos está en `work/catalogo-vinz-20261022/index.json`; debe contrastarse con páginas actuales. Las animaciones remotas se revisan en navegador y se muestran como referencias, no como modelos 3D ya construidos ni como diagramas de física.

## Referencias A/B/C precisadas

El usuario confirmó A básico, B dos disparos de colores que giran/se entrecruzan y C su fusión; después entregó `https://tenor.com/iA3z0BfiPC1.gif`. El GIF está archivado con hash y se inspeccionaron140 fotogramas/3040ms. Primer disparo de orbes giratorios, segundo pulso cargado, flash y resultado de núcleo rosa/aros verdes/satélites. Se corrigió la etiqueta provisional del GIF segundo de Retropixel: ya contenía C, no la faseB. Lámina de revisión final `ModelEditor/references/megaman-x3/muestras-ABC.png`; contrato y selección `SELECCION.md` en la misma carpeta. En aquel punto se presentaron primero las referencias. Tras autorización se construyeron siete modelosMDX independientes, en exports/megaman-x3-buster-v1.

Biblioteca terminada: `descargas/warcraft3/misiles/vinz/biblioteca-originales/CATALOGO.md`.50paquetes,191MDX,191hashes distintos, seis categorías, ZIP originales de3.1MiB, custom assets y créditos incluidos. No se tocó la colección de Shots editada. Construcción y prueba de componentes terminadas; queda la valoración estética de las muestras por el usuario.

## Autorización de modelado recibida

El usuario indicó: «crea individualmente cada misil, y el buster, dentro del juego ya le daré su física». Por tanto, la fase de construcción queda autorizada y no requiere otra pregunta de aprobación de referencias. Se usarán las formas del GIF aportado y la lámina ABC. Pack previsto: A pulso cargado, tres orbes verde/naranja/cian, primer grupo orbital como referencia visual, núcleo/anillos C y flash de unión. Los satélites de C reutilizan orbes individuales; no imponer su separación mundial dentro del MDX.

Verificaciones previstas: MDX800, binario/texto reparseados por dos lectores; geometría/pivotes/bounds/secuencias; recursos BLP1 coherentes con alfa/mips; punta de cuerpo en X=0 en Stand; sin avance mundial programado. Galería de modelos en copia de1.27b, sin lógica de trayectoria/daño/fusión. Entregar muestras visuales y fuentes MDL además de MDX y texturas, como primera revisión susceptible de ajustes.

## Entrega v1 terminada

Siete modelos en `ModelEditor/exports/megaman-x3-buster-v1/`, con MDL, recursos locales, LEEME, validación y muestras reales. Probetas numéricas y texturas PASS; galería compilada/reextraída y probada en1.27b, escalas0.5/2.4/3 y Birth/Stand/Death. Perfil propio cerrado limpiamente. El usuario pidió pantalla3; queda registrado en ModelEditor/AGENTS.md y en el identificador de ventana del ensayo. No se implementó física ni se tocaron packs anteriores.

ZIP final: `2149df953c1d617f5a96880e5b3b4f0faf3515aa6f1dbc208f3778a249f8d752`,54archivos,3156692bytes. CRC y cada byte contrastados. Perfil propio e intermedios movidos a papelera, conservando dos galerías finales y todas las evidencias.
