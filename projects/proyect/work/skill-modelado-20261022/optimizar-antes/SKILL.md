---
name: optimize-slendytubbies-wc3-127b
description: Optimizar personajes extraídos de S3 y TDAU para Warcraft III Classic 1.27b, reutilizando el método V11 validado con Newborn y Rangedborn. Aplicar al rig, curvas, MDL/MDX y texturas; no a terreno ni a extracción de ambientes.
---

# Optimización de personajes S3/TDAU

Conservar personalidad, silueta, materiales y movimientos al reducir el coste de los personajes. Mantener S3 y TDAU separados, con una carpeta por personaje y variante. Trabajar en copias; no sustituir originales ni borrar fuentes por aplicar esta skill.

Leer [el método y las métricas V11](references/v11.md) antes de transformar modelos. Los parámetros son un punto de partida validado en dos pilotos TDAU, no un estándar universal ni una garantía para los más de 300 modelos anteriores.

Aplicar también `wc3-classic-modeling` para edición de modelos; si se construye un mapa, usar `build-warcraft3-vjass-127b`. Destino: versión de modelo 800 y juego 1.27b, salvo cambio explícito del usuario.

## Procedimiento

1. Inventariar MDL/MDX, texturas y fuentes. Medir bytes, vértices, triángulos, huesos, helpers, geosets, capas, secuencias y claves TRS por animación. Separar peso del modelo, texturas y paquete.
2. Verificar primero la integridad del MDX contra su MDL con un lector/escritor independiente. Una deformación del binario no se corrige reduciendo polígonos.
3. Corregir jerarquía, transformaciones y pose inicial antes de comprimir curvas. Validar Unanimated, Birth y aparición con CreateUnit sin ocultar la unidad ni forzar Stand inmediatamente.
4. Reducir curvas por secuencia con límites de error y claves de borde conservadas. Comparar posiciones de todos los vértices animados contra la referencia; no basta contar claves.
5. Optimizar texturas conservando colores y mipmaps. Eliminar alfa solamente si todos los píxeles de todos los mipmaps son opacos y el material no necesita transparencia.
6. Probar geometría reducida sólo en una variante separada. No perseguir los números de Arthas a costa del rostro, accesorios, articulaciones o silueta.
7. Entregar MDL, MDX, texturas y métricas antes/después. Distinguir validación numérica/editor de prueba dentro del juego. No extrapolar FPS a partir de bytes.

La aceptación requiere movimientos correctos y aparición sin picos o tamaño gigante, escala de unidad 1.00, texturas correctas de día/noche y prueba con varias unidades. Si un personaje es rígido por diseño, conservarlo así; no inventar animaciones.
