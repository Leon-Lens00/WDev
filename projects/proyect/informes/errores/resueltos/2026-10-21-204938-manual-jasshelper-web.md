# Referencia web de JassHelper no disponible

- Fecha: 2026-10-21T20:49:38.330404-05:00; agente principal, consulta de alcance de soporte completo.
- Entorno: CodeGraph 1.6.2+jass-vjass.3/extracción 30, Warcraft III 1.27b.
- Síntoma: el resultado de búsqueda del manual histórico alojado en WurstScript
  devolvió HTTP 404 al abrirlo, tanto raw como página GitHub.
- Referencia: https://github.com/wurstscript/WurstScript/blob/master/Wurstpack/vexorianjasshelper/jasshelpermanual.html
- Causa confirmada: esa URL no permitió recuperar el recurso. No se demuestra
  por ello que el manual haya sido eliminado de todos los repositorios.
- Impacto: no se usa el snippet de búsqueda como documentación recuperada.
  Ningún fallo del compilador, índice o servidor CodeGraph observado.
- Recuperación: lectura directa del manual y changelog adyacentes al compilador
  configurado en FrozenThone/wc3toolchain.json. Estado resuelto mediante fuente
  local. La documentación de CodeGraph se abrió correctamente en su revisión
  original 6560052a6f856855d3f71eee838fd66ccfa4285d.
- Manual local: /home/snz/Documentos/ChatGPT/FrozenThone/editors/newgen/jasshelper/standart/jasshelpermanual.html
- Compilador SHA-256: 23a3cf524d42581c3d5149db96cc64aeded46b30dbfc12f6815f039da6b55985.
- Manual SHA-256: 41b92dcab46da263544413e40060accb8613ee9dade1c0f9bcf0f6bb7c049dae.
- Límite: fechas divergentes entre título/cabecera del manual y changelog; la
  identidad del binario se fija por hash y su comportamiento se contrastará con
  fixtures, sin inferir su versión sólo por la fecha del HTML.
