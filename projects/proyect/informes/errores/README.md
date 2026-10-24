# Informes de errores

Registro común de fallos detectados por los agentes al trabajar en este
proyecto, TerrainDev, su copia de inventario, UI Studio y las herramientas
utilizadas para desarrollarlos. El informe complementa el aviso en el chat.

Crear `AAAA-MM-DD-HHMMSS-tema.md` con la hora local de America/Lima. Comprobar
que no exista; si coincide, añadir un sufijo. Buscar primero un informe de la
misma incidencia y actualizarlo cuando corresponda. Conservar las aportaciones
de otros agentes. No borrar evidencias históricas; conservar sus ubicaciones y enlaces.

## Contenido mínimo

- Fecha, agente/chat de origen, proyecto, entorno y revisión afectados.
- Síntoma y resultado esperado; evidencia o pasos/comando de reproducción.
- Impacto y causa confirmada, separada de hipótesis pendientes.
- Estado: abierto, en investigación, corregido pendiente de verificar o resuelto.
- Acciones realizadas y comprobaciones: comando/escenario, resultado y límites.
- Pendientes y enlaces a fuentes o registros relevantes.

Actualizar el estado y explicar cómo se comprobó la recuperación. Los logs
extensos pueden ir en una subcarpeta de evidencias con el mismo identificador.
No incluir secretos, credenciales ni volcados innecesarios del entorno.

Los controles negativos previstos y avisos conocidos de cobertura parcial no
son automáticamente errores. Registrar una incidencia si aparece un fallo real
o inesperado, o si esos límites impiden validar el trabajo solicitado.

## Ubicación por estado

- La raíz contiene incidencias abiertas, en investigación o corregidas pendientes
  de verificar. Haberlas atendido o investigado no equivale a resolverlas.
- `resueltos/` contiene informes con recuperación comprobada o cierre justificado
  mediante alternativa, con causa, resultado y límites registrados. Mover allí el
  informe completo al cerrarlo y actualizar los enlaces de documentación vigente.
- Si reaparece un fallo, devolver su informe a la raíz y actualizar el mismo
  historial; no crear duplicados. Conservar logs y evidencias en su ubicación.
- Los estados intermedios de informes archivados son historia; prevalece el
  estado final. No editar snapshots de revisión ni logs históricos para cambiar
  rutas: usar este registro de traslados para localizarlos.
- La extensión será proporcional al fallo; todos los campos mínimos siguen
  siendo necesarios, aunque puedan expresarse brevemente.

### Traslado del 22 de octubre de 2026

Los siguientes informes conservan su nombre dentro de `resueltos/`:

- [2026-10-21-174908-codegraph-etiquetas.md](resueltos/2026-10-21-174908-codegraph-etiquetas.md)
- [2026-10-21-194600-codegraph-expansion-invalidacion.md](resueltos/2026-10-21-194600-codegraph-expansion-invalidacion.md)
- [2026-10-21-202000-codegraph-jurados-ampliacion.md](resueltos/2026-10-21-202000-codegraph-jurados-ampliacion.md)
- [2026-10-21-204938-manual-jasshelper-web.md](resueltos/2026-10-21-204938-manual-jasshelper-web.md)
- [2026-10-21-211753-codegraph-conformidad-vjass.md](resueltos/2026-10-21-211753-codegraph-conformidad-vjass.md)

- [2026-10-22-011732-codegraph-llamada-implicita-this.md](resueltos/2026-10-22-011732-codegraph-llamada-implicita-this.md) — corrección .5 y activación verificadas.

### Recuperación de skills de modelado — 22 de octubre de 2026

- [Skill de modelado recuperada](resueltos/2026-10-22-122308-skill-modelado-ausente.md) — instalada, rutas Linux y conversión de dos pilotos verificadas.
- [Validador de skills](resueltos/2026-10-22-122737-validador-skills-pyyaml.md) — validación recuperada mediante Python aislado con PyYAML.

- [2026-10-22-130507-codegraph-guia-ui-version.md](resueltos/2026-10-22-130507-codegraph-guia-ui-version.md) — versión de la guía UI corregida; nueva raíz de diálogo verificada.

- [Acceso a filtro/previews de Hive](2026-10-22-144539-hive-filtro-previews-web.md) — reabierto: la carga en navegador no acredita la preview inline; el usuario aportó captura de placeholders.

- [Generación del plano Shots Vol. I](resueltos/2026-10-22-151223-plano-shots-matplotlib.md) — entorno de dibujo recuperado y PNG/SVG revisados.
- [Shots Vol. I: origen y punta](resueltos/2026-10-22-151600-shots-vol-i-origen-punta.md) — derivados corregidos y comprobados; originales conservados.

### Shots Vol. I: edición y colores

- [Validación MDL recuperada](resueltos/2026-10-22-153852-shots-validacion-mdl.md).
- [Texturas neutralizadas y verificadas](resueltos/2026-10-22-153502-shots-texturas-sesgo-color.md).
- [Empaquetado/cámara recuperados](resueltos/2026-10-22-154111-shots-fixture-empaquetado.md).
- [Cierre y pérdida de foco](2026-10-22-154808-shots-cierre-foco.md): cierre final seguro, efecto de entrada anterior en navegador sin comprobar.

- [Regresión de proyección InventorySys](resueltos/2026-10-22-163705-inventario-proyeccion-movimiento.md): proyección original restaurada y altura calibrada al inicio; recuperación observada en movimiento. Diálogo conserva incidencia propia de precisión fina.

- [Marco de diálogo](resueltos/2026-10-22-130405-dialogo-marco-invisible.md): recuperación comprobada tras restauración y afinado de adaptador; alcance1920×1080SP.
- [Evidencia en monitor incorrecto](resueltos/2026-10-22-172800-dialogo-monitor-evidencia.md): repetida con órdenes nativas y capturas por identidad dePID.

### TerrainDev: misiles por color — 22 de octubre de 2026

- [Resumen de emisores](resueltos/2026-10-22-174308-inspeccion-shots-campo-emisor.md): propiedad correcta y12 modelos verificados por dos lectores.
- [Contador del laboratorio](resueltos/2026-10-22-174655-laboratorio-colores-contador.md): corregido a MissileStats.retired; compilación y40 controles ejecutados.
- [Rojo y null](resueltos/2026-10-22-175240-misiles-color-rojo-null.md): presencia de override explícita, clearColor y caso owner naranja/override rojo comprobados.
- [Interferencia de laboratorios](resueltos/2026-10-22-175821-laboratorios-colores-rapid-interferencia.md): posición restaurada;40 controles de colores y44 de Rapid Fire pasan en la copia final.

### Shots Vol. II y revisión del brillo de ambos volúmenes

- [Núcleo claro recuperado](resueltos/2026-10-22-180100-shots-colores-sin-nucleo-blanco.md): revisión de 36 colores, galería final y comparación en 1.27b.
- [Perfil de ensayo aislado](resueltos/2026-10-22-175120-shots-vol-ii-perfil-ocupado.md): evita contención con otras partidas; sesión propia cerrada.
- [Posición de ventana corregida](resueltos/2026-10-22-181300-shots-ventana-fuera-monitor.md): captura de laboratorio repetida en monitor correcto.

### Diálogo animado y bustos

- [Jerarquía/recuentos/corte recuperados](resueltos/2026-10-22-182141-dialogo-marco-jerarquia-mdx.md).
- [Recursos y herramientas auxiliares recuperados](resueltos/2026-10-22-180241-dialogo-recursos-auxiliares.md).
- [Ayuda de proyección actualizada](resueltos/2026-10-22-175058-ui-studio-ayuda-proyeccion-antigua.md).
- [Vista del navegador: caídas recurrentes, abierta](2026-10-22-190100-ui-studio-vista-navegador.md).
- [Instante del teletransporte pendiente](2026-10-22-185821-dialogo-teletransporte-visibilidad.md).

### TerrainDev: física X3

- [Lectura del GIF recuperada](resueltos/2026-10-22-201028-x3-lectura-gif.md).
- [Facing nativo: fixture corregido](resueltos/2026-10-22-202637-x3-laboratorio-facing.md).
- [Sesión de compilación: registros persistentes](resueltos/2026-10-22-203559-x3-sesion-compilacion.md).
- [Prioridad fusión/impacto corregida y reproducida antes/después](resueltos/2026-10-22-204120-x3-prioridad-fusion-impacto.md).
- [Pausa, validación anticipada y cierre comprobado](resueltos/2026-10-22-205231-x3-regresion-pausa-validacion.md).

### ModelEditor X3: visor y pulidoV3

- [Visor y exportación de muestras recuperados](resueltos/2026-10-22-202200-x3-visor-inicial.md).
- [Orden de nodos y aros recuperados](resueltos/2026-10-22-204037-x3-v2-orden-nodos.md).
- [Movimiento de la galería recuperado](resueltos/2026-10-22-211000-x3-v3-galeria-movimiento.md): umvs300, control de JASS idéntico y partículas en recorrido observadas; cierre comprobado.

### Optimización de retratos: preview y verificación

- [Sonda de curvas corregida](resueltos/2026-10-22-223510-sonda-curvas-retratos.md).
- [Lanzamiento, selector y validación recuperados](resueltos/2026-10-22-225100-preview-retratos.md): preview orbital de ambos personajes y10variantes comprobadas; candidatos sin prueba nativa todavía.


### WaveSys: registro de jugadores propio — 23 de octubre de 2026

- [Consulta de toolchain recuperada](resueltos/2026-10-23-024501-wavesys-manifiesto-toolchain.md): ruta supuesta descartada; configuración y cuatro herramientas/API comprobadas.
- [Foco/perfil de ensayo recuperado](resueltos/2026-10-23-024931-wavesys-prueba-perfil-ocupado.md): guardas evitaron confirmar sobre otra sesión, aislamiento y tres cierres propios comprobados.
- [E04: PlayerUtils antiguo](2026-10-23-015734-wavesys-e04-jugadores-salida.md): abierto para UI; 16 consumidores de partida migrados a WavePlayerUtils y registro nuevo probado. No acredita desconexiones multijugador.

### ModelEditor X3V4 — 23 de octubre de 2026

- [Vinz: dependencias explícitas ausentes](2026-10-23-012100-vinz-recursos-estudio.md):13previews parciales;178resueltas. No afecta al packX3.
- [Atlas/servidor/resolver recuperados](resueltos/2026-10-23-012300-x3-atlas-servidor.md).
- [Lector alfaBLP contrastado](resueltos/2026-10-23-014307-x3-v4-lector-pillow-blp.md).
- [Frente geométrico recuperado](resueltos/2026-10-23-015351-x3-v4-frente-orbes.md).
- [Identidad, foco y cierre comprobados](resueltos/2026-10-23-025500-x3-cierre-normalizacion-prefijo.md).
- [Inspecciones auxiliares recuperadas](resueltos/2026-10-23-030000-x3-inspecciones-auxiliares.md).

### ModelEditor X3 V5 A

- [Lectura temporal corregida](resueltos/2026-10-23-055914-x3-a-copa-estatica.md): cuerpo azul continuo y flujo rosa, verificados en3D y1.27b.
- [Precisión y pivote corregidos](resueltos/2026-10-23-060500-x3-v5-alfa-float32.md): exportación estricta, centro frontal y residuo alineado comprobados.

- [X3V6 2026-10-23-055914-x3-a-copa-estatica.md](resueltos/2026-10-23-055914-x3-a-copa-estatica.md): corrección comprobada; evidencia en ModelEditor/evidence/x3-v6/.

- [X3V6 2026-10-23-070811-x3-v5-nucleo-particulas.md](resueltos/2026-10-23-070811-x3-v5-nucleo-particulas.md): corrección comprobada; evidencia en ModelEditor/evidence/x3-v6/.

- [X3V6 2026-10-23-071200-x3-v6-wrap-textura.md](resueltos/2026-10-23-071200-x3-v6-wrap-textura.md): corrección comprobada; evidencia en ModelEditor/evidence/x3-v6/.

### ModelEditor X3 V7

- [Destino de exportación recuperado](resueltos/2026-10-23-073424-x3-v7-destino-exportacion.md): V6 restaurada exacta desdeZIP y V7 independiente, con guarda y verificación.


### TerrainDev: réplica física X3 mediante GIF — 23 de octubre de 2026

- [Guarda del prefijo normalizada](resueltos/2026-10-23-124722-x3-replica-guarda-prefijo.md).
- [Pasos físicos, llegada y fixture recuperados](resueltos/2026-10-23-125112-x3-replica-pasos-fisicos.md):153controles/0fallos; vídeo final y cierre propio comprobados.
