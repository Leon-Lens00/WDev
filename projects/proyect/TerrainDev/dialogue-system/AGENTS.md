# Copia de conversaciones — CodeGraph y alcance

- Esta raíz es la copia de conversación para Warcraft III Classic 1.27b,
  independiente de TerrainDev principal y de la demo de inventario.
- Antes de optimizar, integrar o limpiar recursos del diálogo, consultar el
  [registro de pesos, integración y pendientes](../../docs/planes/optimizacion-texturas-panel.md#registro-de-pesos-y-consideraciones-para-continuar).
  Distinguir mapa activo, copia comparativa 512 y candidatos de retratos; una
  optimización entregada por separado no está incorporada al builder. Mantener
  modelos/texturas compartidas y tamaños MPQ diferenciados al informar ahorros.
- Para las barras de vida de esta misma interfaz, consultar
  [materiales y contrato](../../docs/planes/materiales-barras-vida.md).
  Retratos estáticos BLP por personaje, marco/vida/cifras separados. Los
  materiales se preparan en exports/health-bars-v1; no se importan al mapa por
  existir en esa carpeta. Variante horizontal separada en
  exports/health-bars-horizontal-v1, ya integrada: ambos usan iconos Art nativos;
  héroePlayer10 compartido haciaP0/control básico, avanzadofalse evitaiconolateral.
  Reservar dueñoauxiliar:comparte todas susunidades. Enemigoiconoaladerecha,
  relleno10px de izquierda a derecha. Conservar la vertical aprobada.
  Priorizar el selector de disposición en healthbars.html de UI Studio.
- Consultar primero `codegraph_explore` con
  `projectPath: /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system`
  y símbolos concretos, por ejemplo ConversationAdvance, ConversationUI.Start,
  BeginPage y Render. El índice contiene `src`, `build.py`, `tools` y las APIs
  declaradas; excluye builds, evidence, assets, exports y cachés.
- `src/DialogueData.j` se genera mediante `tools/story.mjs` desde el contrato
  del editor; revisar su generador antes de editar el resultado. El mapa se
  construye con el builder propio `build.py`, no con el de TerrainDev principal.
- Perfil `release` acreditado por el builder que usa el launcher vjass sin
  `--debug`; `completeInputs: false`. Las copias de API en `codegraph-api/`
  son entradas de análisis y no se importan al mapa. Procedencia y SHA-256 en
  `work/codegraph-nuevas-raices-20261022/api-provenance.json`, relativo a Proyect.
- Las bibliotecas de UserInterface, Camera y la base congelada se leen desde
  `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration`.
  No forman parte de este índice y no hay enlaces automáticos entre raíces.
  Para callbacks o consumidores no resueltos, contrastar ambos contextos y las
  fuentes; no interpretar una arista ausente como ausencia de llamada.
- Tras editar, comprobar vigencia de la respuesta; el watcher sólo está activo
  mientras el proyecto permanezca abierto por MCP. En uso sólo CLI, sincronizar.
  Aplicar la política de nuevas raíces autorizadas de AGENTS.md del proyecto.
- Compilar y probar en el juego siguen siendo verificaciones separadas. Un solo
  escritor por mapa; no iniciar ni cerrar partidas de otro agente al indexar.
  Informar fallos en la carpeta común siguiendo las instrucciones del proyecto.
