# X3: diferencia en relectura de máscara BLP

Fecha:2026-10-22 America/Lima. Entorno ModelEditor, generador procedural X3/Pillow.

Síntoma: el generador de máscaras rechazó la igualdad de píxeles RGBA de una BLP reabierta frente a su PNG fuente. No se continuó una fase dependiente con estas texturas. Referencias originales intactas.

Estado: investigando píxeles/cabecera para localizar si el fallo está en escritura o comprobación. Evidencia en ModelEditor/assets/x3-v1 y fuente src/textures-x3.py. Sin atribuir todavía corrupción en motor ni compatibilidad.

Causa localizada en el lector: Pillow BLP1Decoder `_read_bgra` usa el alfa de la paleta e interpreta sólo índices; no lee el plano alfa8 separado del mip. Se observaron1220 diferencias sólo de alfa en píxeles negros de Glow; RGB coincide. No modificar cabecera válida para acomodar ese lector. Se cambia la verificación a RGB de Pillow + RGBA decodificado de índices/plano alfa y se añadirá el lector independiente mdx-m3-viewer para mipmaps completos. El binario fuente mantiene alpha8/type4/subtype1.

## Cierre verificado
Estado final: resuelto mediante corrección o alternativa descrita.
Las cuatro máscaras BLP fueron releídas por mdx-m3-viewer: RGBA SHA256 exacto frente a PNG fuente; todos los niveles mip cargados con dimensiones correctas. Verificación manual separada del alfa y cabecera PASS. No se cambió BLP para acomodar el lector Pillow.
