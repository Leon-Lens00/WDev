# Entradas de API para CodeGraph

Copias byte a byte de common.j y Blizzard.j Classic usados por el builder local.
Sólo sirven de entradas declaradas de análisis en codegraph.json/jass.apiFiles;
no se añaden a Main.j, a la lista de bibliotecas ni al mapa. El compilador ya
recibe los archivos originales por sus argumentos.

Procedencia y SHA-256: work/codegraph-this-20261022/profile-plan.json, relativo
a la raíz del proyecto Proyect. Al cambiar la toolchain, comprobar y renovar
estas copias y reconstruir el índice; no sustituirlas por APIs de otro parche.
