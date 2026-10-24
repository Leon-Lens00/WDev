# X3: pulido y revisión previa en espacio3D

Fecha22/10/2026. Requisitos: volver al lanzamiento SP anterior con prefijo propio; mostrar antes un visor3D real; pulir los siete componentes hacia el acabado de proyectiles Vinz, conservando identidad X3 y física externa. V1 entregada se conserva.

Base: ModelEditor/src/build-x3.cjs, siete MDX800 en exports/megaman-x3-buster-v1; bibliotecas locales mdx-m3-viewer5.12.0/war3-model4.0.1. Originales de Vinz en descargas/warcraft3/misiles/vinz/biblioteca-originales. El índice de código cubre ModelEditor; fuentes externas y binarios son fronteras.

Fases: 1) corregir instrucciones (hecho); 2) estudiar en archivos y visor Shots I/II y Psionic, registrar observaciones; 3) visor3D local orbital con MDX reales, origen/ejes, secuencias, comparaciónv1/revisión y referencias; 4) generar revisiónv2 separada, máscaras y capas suaves, volumen menos facetado, partículas/estelas locales sin avance mundial; 5) relectura/poses/recursos y revisión visual de todos los componentes; mostrar al usuario antes de cargar juego. Tras mostrar la muestra3D, el usuario pidió intentar el lanzamiento con YDWE, sin LAN, un jugador. Usar sólo una sesión propia, MapTest.EnableHost=0, y conservar las otras partidas. El modo single_test observado lanza YDWE.exe -war3 -loadfile; se puede utilizar esa rama para evitar recompilar la galería desde triggers ajenos.

Comprobaciones: binario800 con lectores independientes, texturasalfa/mips, puntaX=0 y raíz sin avance, bounds/secuencias, carga real sin dependencias faltantes en visor, vistas lateral/oblicua/frontal, Birth/Stand/Death y comparación con v1. El visor no certifica resultado del motor, FPS ni multijugador. Registrar hashes y evidencia, incertidumbres y siguiente paso.

Estado actualizado: visor orbital real funcionando; V2 mostrada antes de juego y ejecutada con YDWE. V3 incorpora la petición posterior de anchura/partículas y su revisión visual.


Actualización del usuario: V2 mejora, pide cuerpos más anchos y partículas continuas/estela. Crear V3 separada: ancho transversal +30% A/C y +25% orbes, mantener longitud/origen, dos emisores de residuo independientes del movimiento del modelo (60+36 partículas/s por pieza), vida0,42/0,32s, ribbons0,16/0,22s. Ver en el visor V2/V3 antes del juego. V2 ya cargó por YDWE un jugador, sin LAN; sesión propia cerrada y otras partidas conservadas. V3 requiere verificación nueva.


Cierre: V3 completa y entregable en exports/megaman-x3-buster-v3.zip, hash/detalles evidence/x3-v3/archive.json. Siete modelos/299 poses, recursos verificados; visor V2/V3 y referencias funcionando. YDWE un jugador/sin LAN con mapaaba08fc... probado en pantalla3, Birth/Stand/Death y residuo en recorrido; galería umvs300 corregida por control de JASS idéntico. Sesiones propias cerradas y perfiles/intermedios a papelera. Originales, V1/V2 y física ajena conservados. Aprobación estética del usuario y física de fusión/colisiones siguen fuera de esta entrega.
