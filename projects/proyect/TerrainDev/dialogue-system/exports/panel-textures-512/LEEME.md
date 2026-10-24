# Panel: texturas candidatas de512 · 22/10/2026

Estado: archivos validados y comparación plana revisada en navegador. Sin
sustituir los recursos activos del mapa ni del editor de conversaciones.

| Cada marco rojo/azul | Bytes BLP sin comprimir en MPQ | Reducción |
|---|---:|---:|
|Actual1024×512|1.399.282|—|
|Candidata512×256|350.706|74,9%|
|Candidata512×512|700.230|50,0%|

La opción512×256 promueve el mip1 que ya contenía el archivo, copiando exactamente
su paleta, índices, alfa8 y todos los niveles hasta1×1. Evita una segunda
cuantización. Los dos marcos pasan de2.798.564 a701.412bytes; no es una medida
del ahorro final del W3X comprimido ni de FPS/memoria de GPU.

La opción512×512 remuestrea desde el mip0 a un archivo cuadrado y conserva más
muestras verticales. Las UV normalizadas del MDX no cambian; el tamaño del panel
en pantalla tampoco. No se genera ni reduce texto: los texttags son independientes.
Los bordes y transparencias se conservaron visualmente en las vistas revisadas;
la comparación frente al archivo1024 completo muestra la reducción de detalle
esperable, especialmente en512×256. Igualdad con el mip1 no significa igualdad
con el mip0 ni garantiza el nivel que elija cualquier renderer.

## Investigación del límite

Fuente primaria experimental: Dr Super Good,
[BLP Specifications(WC3)](https://www.hiveworkshop.com/threads/blp-specifications-wc3.279306/).
Distingue carga de archivos grandes desde1.27b y nivel útil máximo512 por dimensión
hasta1.28, cambiado en1.29. BLP y TGA no tienen las mismas restricciones.
La guía Art Tools antigua aparece citada con512×512 pero no se pudo recuperar
el PDF completo por la herramienta web; no se usa como lectura acreditada.
El perfil local incluye RenderEdge_Widescreen.mix: no se ha medido ni modificado
su elección de mip. Prueba nativa de estos candidatos pendiente. Tomar512 como
objetivo conservador para estos BLP; no afirmar máximo absoluto de todo Warcraft.

## Reproducción y comprobaciones

Desde la raíz Proyect:

- `work/shots-vol-i-origen-20261022/plot-env/bin/python TerrainDev/dialogue-system/tools/optimize-panel-textures.py`
- `node TerrainDev/dialogue-system/tools/verify-panel-textures.cjs`

Dos parsers independientes: mdx-m3-viewer5.12 y war3-model4.0.4candidatos/40mips,
RGBA coincidente, cabecera/rangos/tamaños/extremos1×1, alfa8 y hashes comprobados.
El segundo lector recibe cada subrecurso con dimensiones clamped a1 para su
limitación rectangular; no se alteran los bytes analizados. Payloads de512×256
idénticos al mip1 y siguientes del original. Sources/mapa/MDX activos intactos.
Registros en evidence/panel-textures-512/{manifest,validation}.json.

[Comparador del editor](http://127.0.0.1:4317/panel-texture-review/index.html):
rojo/azul,512×256/512×512, referencia1024 o mip1, deslizador de división y vista
completa. PNG decodificadas de cada BLP, misma proporción del MDX; no reemplaza
una prueba de materiales/animación nativa. Mip1 de referencia se decodifica del
original por separado, aunque sus píxeles sean idénticos a la candidata.
