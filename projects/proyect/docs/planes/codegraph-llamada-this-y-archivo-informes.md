# Corrección de receptor implícito y organización de informes

Estado: completado, 22 de octubre de 2026. Autorización: «adelante», tras el
contraste de ambos chats, y traslado de informes resueltos a otra subcarpeta.

## Alcance y aceptación

- Corregir la relación omitida RapidPair.spell → RapidPair.cast cuando un método
  estático declara local thistype this. Mantener sin resolver usos sin receptor
  válido y referencias de función a métodos de instancia.
- Comprobar build real y APIs Classic; configurar perfiles únicamente con
  evidencia del comando de compilación. API inputs serán copias declaradas
  dentro de las raíces autorizadas, sin imports nuevos al mapa.
- Separar informes cerrados en informes/errores/resueltos/. Mantener abiertos o
  pendientes en la raíz; conservar evidencias y actualizar enlaces e instrucciones.
- No modificar mecánicas, mapas ni entregas; no ampliar dictámenes de jurados
  anteriores a cambios nuevos.

## Fases

1. Reproducción mínima con el pipeline real y prueba negativa antes del arreglo;
   inspección del receptor y contraste con JassHelper Classic.
2. Corrección aislada en work/codegraph-this-20261022/checkout; tests del caso,
   regresión JASS/otros lenguajes pertinente y build. Baseline de archivos activo
   guardado para evitar sobrescribir trabajo concurrente.
3. Instalar código validado, reconstruir índices necesarios, comprobar arista y
   contexto por CLI/MCP. Los procesos antiguos requieren recarga; no confundir
   un proceso nuevo de verificación con el transporte del chat actual.
4. Actualizar el informe de la incidencia con resultados y mover los resueltos;
   comprobar enlaces locales y dejar registro breve de pendientes y cierre.

## Evidencia inicial

Revisión instalada .4, extracción 31, esquema 12. Índice complete y quick_check
ok; cast no resuelto en RapidFire.j:271. compiled.j:4041 de la entrega actual
contiene s__RapidPair_cast(this, ...). Las 15 bibliotecas coinciden con el
manifiesto. No hay codegraph.json en TerrainDev/src; no contiene APIs Classic.

## Resultado del parche y estado de cierre

Implementado e instalado .5/extracción 32/esquema 12; 6093 pruebas pasan y 36 se
omiten, 466 suites pasan. Oráculos: tres positivos y dos negativos previstos.
Build y comparación de fuentes instaladas contra candidata correctos.
Tres índices reales reconstruidos e íntegros; nuevas API inputs y perfil release
sustentados por builders reales, completeInputs false. Tres consultas MCP de un
proceso nuevo y dos transiciones watcher pasan. Cinco informes ya cerrados se
trasladaron a resueltos/; el sexto espera la recarga final de la aplicación.

Evidencia: work/codegraph-this-20261022/. Respaldo de código/dist/config e índices:
production-backup-20261022-013435/. No se han cambiado mapas ni bibliotecas.
Próximo y último paso: recarga oficial de MCP. El observador separado verificará
el proceso nuevo y los índices, cerrará y moverá el informe si la comprobación
pasa. La consulta posterior de este chat se registra por separado, sin atribuir
al cliente antiguo las llamadas de la conexión de prueba.

Cierre: recarga de la aplicación comprobada por observador; seis informes
resueltos archivados, sin incidencias abiertas en la raíz al finalizar.

Verificación final del cliente: tres consultas reales desde este chat pasaron
tras la reconexión de configuración MCP, con spell → cast visible. La aplicación
recreó tres procesos; no fue necesario pulsar el botón adicional de recarga.
No quedan pasos de sesión pendientes de esta corrección.
