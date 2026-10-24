# Optimización de claves de retratos · 22/10/2026

Solicitud: reducir el aumento de tamaño de los retratos de diálogo y mostrar una
preview antes de sustituir los recursos activos. Destino Classic 1.27b, MDX800.

Base: `TerrainDev/dialogue-system/assets/UI/Dialogue/Portraits/{paladin,tauren}.mdx`.
La adaptación hornea cámara y vértices cada25ms; BONE representa >99.5% de ambos
MDX. Registro, geometría, materiales, texturas, jerarquía, intervalos, orden SEQS
y BlendTime200ms deben conservarse. Consumidores: diálogo JASS y UI Studio;
esta fase produce candidatos separados y no cambia ninguno de esos consumidores.

1. Conservar copias/hash de entradas en `ModelEditor/evidence/portrait-keys-20261022/`.
2. Implementar reducción temporal de traslaciones lineales por secuencia, con
   extremos y claves ajenas conservados. Rechazar rigs o interpolaciones fuera
   del contrato verificado. Comparar tolerancias0.005/0.01/0.02/0.05/0.1 unidades.
3. Releer MDX con dos parsers, comparar datos inmutables y errores de todas las
   curvas/vértices en sus puntos de quiebre. Probar límites y controles negativos.
4. Entregar MDX/MDL y dependencias en exports separado y visor orbital con
   rejilla/ejes/origen, reproducción sincronizada antes/después y selección de clips.
5. Comprobar visualmente ambos personajes y la interacción del visor, guardar
   evidencia y actualizar este documento con resultados y límites.

Criterios: menos bytes/claves; error <= tolerancia declarada; todas las secuencias
con sus límites intactos; malla/texturas/jerarquía idénticas; preview funcional.
La reproducción en visor no demuestra funcionamiento nativo ni mejora de FPS.
Prueba en Warcraft y reemplazo de recursos quedan fuera de esta muestra previa.

Estado final de esta fase: candidatos y preview entregados. Se implementaron
`ModelEditor/src/optimize-portraits.cjs`, sus cuatro controles, empaquetador y
fuentes de visor.10variantes verificadas,5.579.175comparaciones de vértices;
MDX/MDL leídos por dos parsers. Curvas/extremos y datos inmutables comprobados;
límites por eje no crecen. Ningún recurso activo cambiado (hashes comprobados).

Variante fina0.02:599.239/1.513.674bytes, ahorro82.6%/74.4%. Ligera0.1:
296.615/719.482bytes, ahorro91.4%/87.8%. Frente a los originales33.391/44.174bytes,
la fina aún pesa17.9×/34.3×: esta fase no iguala su presupuesto. Para acercarse
más hay que reconsiderar el horneado por vértice y el rig compacto original;
no basta con seguir quitando claves sin degradar la animación.

Preview comparativa real abierta en DP-1/workspace12; controles de personaje,
clip, calidad, pausa, final del clip y giro comprobados; consola sin errores
observados. Vídeo14s y capturas en `ModelEditor/evidence/portrait-keys-20261022/`.
Métricas en metrics.json; verificación final en validation-latest.json/verify.log;
bounds.json acredita contención. README de exports detalla cobertura y límites.

CodeGraph consultado antes/después en ModelEditor, y antes en diálogo/UI Studio;
watcher/sync incorporó las nuevas fuentes. Viewer/x3 y exports/evidence están
excluidos y se leyeron directamente. Sin estados DISABLED/RECOVERING observados.
No se cambió ni compiló el mapa; contraste nativo de estos candidatos pendiente.
