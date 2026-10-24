Reevaluación de ronda 1 únicamente. Revisar los cinco IDs de ambos jueces (tres causas), su corrección y regresiones del delta. No abrir auditoría ajena.

JD-A-001/JD-B-002: binding array obligatorio, no lookup de tipo para S[index]. Fixture de JassHelper/pJASS judgment-index-compiled.j muestra que la llamada real es Other.tick. La regresión mantiene ambos destinos sin resolver porque index operators siguen fuera del alcance.

JD-A-002/JD-B-001: debug no es hecho incondicional para .exists. Fixture release judgment-debug-compiled.j conserva S.fallback y comenta feature como NO_DEBUG. Su primer intento no produjo salida y sólo registró errores Wine de descriptor; repetición aislada compiló/validó, logs preservados. No atribuir ese primer intento al código fuente.

JD-A-003: catálogo compartido dentro de un batch sync, liberado en finally. indexFile independiente sigue invalidando su catálogo. Antes hubo 10 lecturas síncronas para tres archivos (9 catálogo más una de reconciliación); después 4 (3+1). La primera aserción esperaba 3 por omitir el hash de reconciliación y se corrigió a 4; la causa de 9 lecturas de catálogo es independiente de ese recuento de la prueba.

Tres casos nuevos fallaron antes y pasan después; 1196 casos/15 suites pasan con las correcciones, build completo y ocho sondas de copias reales pasan. Se conserva un escenario array real positivo, dependencias debug desconocidas y convergencia incremental/reconstrucción. Estos son resultados del padre, no pruebas del juez.

El código corregido todavía requiere actualizar índices/recargar procesos después de la revisión; la evidencia de MCP del alcance r1 corresponde a la revisión previa a esta ronda. No se presenta como prueba de que los procesos hayan recibido este parche todavía.
