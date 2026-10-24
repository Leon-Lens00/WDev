# Preview de retratos: lanzamiento y selector

- Fecha/origen:22/10/2026, Codex /root, ModelEditor, Hyprland Lua/Brave,
  mdx-m3-viewer5.12.0. Candidatos Classic1.27b/MDX800, sin cambiar mapa activo.
- Síntomas/evidencia: un lanzamiento con sintaxis antigua `hyprctl dispatch exec`
  fue rechazado (exit7, ningún proceso creado). Al abrir después el visor, la
  selección inicial de secuencia aparecía vacía aunque la animación0 se reproducía.
- Causas confirmadas: dispatcher actual requiere API Lua; el valor anterior vacío
  del select se conservaba por coerción numérica `+''===0`.
- Impacto: lanzamiento auxiliar fallido y etiqueta inicial ausente, sin cambios
  en modelos ni daño al escritorio. Animación y comparación numérica independientes.
- Acciones: lanzar ventana propia, mover sólo su dirección a workspace12/DP-1,
  restaurar foco previo. `preview-window.json` acredita monitor1/x3846. Corregir
  selección para aceptar el valor anterior sólo cuando no sea vacío y regenerar.
- Otro incidente: la repetición de exportación/validación terminó conSIGTERM143
  después de la sexta variante. Causa de la señal no determinada; no atribuirla
  a los modelos. La primera ejecución completa había validado las10variantes.
  Se desacopló la verificación de la exportación (`--verify`, proceso propio)
  y volvió a comprobar los hashes y las10variantes hasta terminar correctamente.
- Recuperación: selector inicial muestraPortrait-1 tras recarga; ambos actores
  reproducen Talk/Portrait. Giro, pausa y último fotograma comprobados. Consola
  del visor sin errores observados. verify.log y validation-latest.json contienen
  los10resultados,5.579.175comparaciones de vértices. Bounds contenidos y hashes
  de los recursos activos intactos. Vídeo14s decodificado íntegramente sin error.
- Estado:resuelto mediante corrección/alternativa verificada. Sin pendientes de
  esta incidencia; prueba nativa sigue fuera del alcance de esta preview.
- Evidencia: `ModelEditor/evidence/portrait-keys-20261022/`, plan en
  `docs/planes/optimizacion-retratos-dialogo.md`. Límite: visor, sin motor nativo.
