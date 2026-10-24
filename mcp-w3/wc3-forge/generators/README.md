# Generador de terreno Classic 1.27b

Extiende **Tropical Template 1.3** con relieve, costa, camino, árboles importados, plantas y una cascada compuesta. Usa MarkovJunior/WFC real sobre una región de ejemplo y funciona localmente, sin API de IA durante la generación.

También admite una **renovación del archipiélago completo** con `examples/terrain/tropical-whole.json`: muestra y salida de 192 × 96 casillas. Conserva las islas, costas y composiciones originales; genera nuevos materiales y vegetación y variaciones suaves de altura. No inventa una distribución nueva de islas. La cascada y las construcciones mantienen sus piezas y soporte. El modo distingue mar de claros, restringe el WFC a tierra/agua y toma las frecuencias de especies de todo el mapa. `shadows: "omit"` deja el SHD editado vacío, por indicación de Leon.

```powershell
./build/bin/terrain-gen.exe generate --spec examples/terrain/tropical-whole.json --out ../artifacts/warcraft-terrain/otra-prueba-completa
./build/bin/terrain-gen.exe validate --spec examples/terrain/tropical-whole.json --map ../artifacts/warcraft-terrain/otra-prueba-completa/Tropical-Generated-22700.w3x --out ../artifacts/warcraft-terrain/otra-prueba-completa/validation.json
```

Resultado completo vigente: `artifacts/warcraft-terrain/whole-map-v1/release`. El perfil regional anterior sigue disponible y conserva su comportamiento.

La entrega y sus pruebas están en [VALIDACION.md](../../docs/warcraft-terrain/VALIDACION.md). Leon excluyó las sombras de esta entrega: el SHD es provisional y no constituye un horneado aceptado.

## Preparar y generar

En PowerShell, desde `C:\Users\Leon\Documents\ChatGPT\ZXDev\wc3-forge`:

```powershell
./scripts/terrain-setup.ps1
./scripts/terrain-run.ps1 -Out ../artifacts/warcraft-terrain/mi-prueba
./build/bin/terrain-gen.exe validate --spec ../artifacts/warcraft-terrain/mi-prueba/spec.json --map ../artifacts/warcraft-terrain/mi-prueba/Tropical-Generated-12700.w3x --out ../artifacts/warcraft-terrain/mi-prueba/validation.json
```

Requiere Git, Go en `C:/Program Files/Go/bin/go.exe` y los datos de Warcraft clásico. Setup instala SDK .NET 10.0.401 local, fija MarkovJunior, aplica su parche de muestreo y compila host/CLI. Después, `-SkipDownloads` reconstruye con las dependencias locales. Para el visor también hacen falta las dependencias npm de `mcp/` y el ejecutable de cámara ya construido.

Editar [tropical.json](../examples/terrain/tropical.json): muestra, región editable, regiones protegidas, camino, catálogo y cascada. Las rutas relativas parten del JSON. Si se mueve el proyecto, ajustar `source`, `install`, `dotnet` y `host`. El [esquema](../examples/terrain/scene.schema.json) describe los campos. La copia fuente está en `../artifacts/warcraft-terrain/tropical-v1/input/tropical-original.w3x`; también se admite el archivo suministrado por Leon con idéntico SHA256. Se rechaza sobrescribir el origen.

## Lote y determinismo

```powershell
./scripts/terrain-run.ps1 -Batch -Out ../artifacts/warcraft-terrain/mi-lote
./build/bin/terrain-gen.exe generate --spec examples/terrain/tropical.json --seed 12702 --out ../artifacts/warcraft-terrain/otra-semilla
```

El lote genera 12700–12709, repite las tres primeras y compara todos los miembros y estados semánticos. Usa tres posiciones XY de cascada; verifica rechazos de Z incompatible y WFC contradictorio. `batch.json` registra resultados y causas. Cada ejecución guarda mapa, configuración efectiva, catálogo, composición, colocaciones añadidas, informe, manifest y solicitud/resultado/XML del motor.

Para reproducir exactamente una variante entregada, usar su `delivery/<semilla>/spec.json`: el lote también desplaza la cascada, además de variar la semilla.

## Capturar y revisar el terreno 3D

Abrir `build/bin/wc3-forge-camera.exe`, consultar los procesos y elegir el ID de su ventana:

```powershell
Get-Process wc3-forge-camera | Select-Object Id, MainWindowTitle
$forgePid = 29884 # sustituir por el ID observado en la sesión actual
node mcp/scripts/terrain-preview.mjs build/bin/wc3-forge-camera.exe $forgePid ../artifacts/warcraft-terrain/mi-prueba/Tropical-Generated-12700.w3x ../artifacts/warcraft-terrain/mi-prueba/spec.json ../artifacts/warcraft-terrain/mi-prueba/preview
```

El cliente stdio selecciona la instancia, espera la carga efectiva del W3X exportado, captura seis encuadres y restaura la cámara. Conserva PNG y JSON con cámara, ruta, frame y errores. **Abrir las imágenes y escribir conclusiones en `visual-review.md`**: el script no decide automáticamente la calidad visual. La cenital es ortográfica a 90°. La vista baja de cascada aumenta la distancia del ojo sin cambiar escala para evitar recortes del primer plano.

Un último argumento opcional admite un JSON de encuadres `{name,bounds,projection,view?,yaw?,pitch?}`. `TERRAIN_VIEWS` limita la captura a nombres separados por comas. No ejecutar dos clientes de captura simultáneos en el mismo PID.

## Inspeccionar y transferir importados

```powershell
./build/bin/terrain-gen.exe inspect --map ../artifacts/warcraft-terrain/tropical-v1/input/tropical-original.w3x --install 'C:/Users/Leon/Downloads/Warcraft III 1.27' --out ../artifacts/warcraft-terrain/inspeccion
./build/bin/terrain-gen.exe transfer --map ../artifacts/warcraft-terrain/tropical-v1/input/tropical-original.w3x --target 'C:/Users/Leon/Documents/W3/dist/Hehe-Forest-Scene-Demo-1.27b.w3x' --install 'C:/Users/Leon/Downloads/Warcraft III 1.27' --ids B000,D006 --x 256 --y 256 --out ../artifacts/warcraft-terrain/importados.w3x
```

Transfiere definiciones, modelos y dependencias, resuelve conflictos de rawcode/ruta y añade una colocación por objeto. `.transfer.json` registra las asignaciones. Admite perfiles personalizados de una variación, MDX 800 y dependencias TEXS. Rechaza bases modificadas, varias variaciones y attachments pendientes. Los recursos ya presentes en el mapa principal conservan bytes y rutas.

## Prueba nativa y comandos auxiliares

`harness --spec SPEC --map MAP --out TEST.w3x` crea una **copia de prueba** con un soldado que recorre el camino y un peón que golpea un B000 para comprobar la recolección. Copiarla a `Maps/` de la instalación y abrirla en Warcraft 1.27b. Revisar F12 y `CustomMapData/TerrainProc-SEED.pld`. Cámara, nombre de registro y plazo dependen de la escena. El mapa final conserva los disparadores originales; no distribuir el harness como versión final.

`audit --map A --target B --out report.json` compara miembros y geometría después de guardar una copia en World Editor. El editor normaliza DOO/WPM/JASS/WTS/W3I y minimapa; no incorporar todo su archivo indiscriminadamente. `resource` extrae un recurso individual para diagnóstico local.

`bake --spec SPEC --map GENERATED --target EDITOR_COPY --out FINAL.w3x` queda disponible para una etapa futura. Exige horneado nativo y geometría equivalente; combina SHD solo dentro de la región editable. Está excluido de la aceptación actual por petición de Leon.

## Pruebas del código

```powershell
$env:PATH = (Join-Path $PWD 'scripts/casclib') + ';' + $env:PATH
$env:WC3_TERRAIN_SPEC = (Resolve-Path examples/terrain/tropical.json).Path
& 'C:/Program Files/Go/bin/go.exe' test ./...
& 'C:/Program Files/Go/bin/go.exe' vet ./...
```

Las pruebas de integración incluyen colisión real de rawcode/textura, lectura de patrones fuera del tamaño de salida y rechazo de terreno protegido modificado o WPM almacenado que bloquea la ruta. Sin `WC3_TERRAIN_SPEC`, se omiten las pruebas con recursos locales.

## Alcance y procedencia

V1 usa una paleta tropical concreta y conserva dimensiones. Las reglas definen forma general y camino; WFC decide ocupación/materiales; las alturas se resuelven después. Las frecuencias de entrada ponderan patrones 2×2, pero las restricciones modifican la distribución final. `markovjunior-sample-bounds.patch` corrige el bucle upstream para recorrer toda la muestra, independiente del tamaño de salida. Su prueba de regresión usa una etiqueta situada fuera de ese tamaño.

La cascada traslada piezas y soporte manteniendo escalas, rotaciones y alturas relativas del conjunto original. No admite rotación, deformación ni otra cota de desembocadura. El minimapa incrustado se conserva del template hasta un guardado nativo; la revisión usa el terreno 3D. No se ha probado multijugador ni balance melee. Se conserva el ambiente/niebla del template.

Crédito de mapa en WTS: **meatfactory**. El archivo suministrado incluye los modelos importados, sin atribución individual suficiente para afirmar su autoría. Se conservan sus créditos y definiciones. MarkovJunior: MIT; ImageSharp: licencia Six Labors. Ver [dependencies.json](dependencies.json) y [contracts.md](contracts.md). Los datos extraídos de Warcraft no se incorporan al código fuente.


## Recomposición completa v2

`whole-map-recompose` genera otro archipiélago tropical de 192 × 96, trasladando seis escenas completas. Conserva 794 piezas del círculo, templo, plataforma, laguna, puente y cascada; cambia la costa, el relieve y sus posiciones. Diez adornos del puente reciben un ajuste local anotado para despejar accesos. Las definiciones y recursos importados se conservan byte por byte.

Desde `wc3-forge`:

```powershell
./scripts/terrain-recompose.ps1 -Batch -Out ../artifacts/warcraft-terrain/mi-recomposicion
```

El destino debe ser nuevo. El lanzador compila la CLI, extrae la biblioteca, genera las diez semillas declaradas y valida los W3X reextraídos. Para una semilla: omitir `-Batch` y añadir `-Seed 32700`. Con `-ForgeProcessId <PID comprobado>` captura además las once vistas de cada salida mediante el cliente MCP; sin ese parámetro deja la revisión visual pendiente. No declara aprobación visual ni controla World Editor automáticamente.

Comandos individuales:

```powershell
./build/bin/terrain-gen.exe library --spec examples/terrain/tropical-recompose.json --out ../artifacts/mi-biblioteca
./build/bin/terrain-gen.exe generate --spec examples/terrain/tropical-recompose.json --seed 32700 --out ../artifacts/mi-mapa
./build/bin/terrain-gen.exe validate --spec ../artifacts/mi-mapa/spec.json --map ../artifacts/mi-mapa/Tropical-Recomposed-32700.w3x --out ../artifacts/mi-mapa/recheck.json
./build/bin/terrain-gen.exe editor-audit --spec ../artifacts/mi-mapa/spec.json --map ../artifacts/mi-mapa/Tropical-Recomposed-32700.w3x --target ../artifacts/mi-copia-guardada.w3x --out ../artifacts/auditoria-editor.json
```

Antes de `editor-audit`, copiar el generado a otro archivo, abrirlo y guardarlo en World Editor Classic 1.27b. El comando comprueba terreno, geometría, recursos, cámaras, inicio, llamadas compiladas, rutas locales y bloqueo de mar profundo después del guardado. Informa separadamente los cambios nativos de WPM, minimapa, contador de guardados, comentarios WTS, redondeos de Z y hasta un píxel del marcador MMP. SHD debe seguir idéntico y vacío. El archivo entregable generado conserva los importados y créditos originales; la copia del editor se conserva como evidencia.

La receta usa fuente/hash fijos y una instalación Classic local. Las rutas relativas del JSON se resuelven desde ese JSON. `spec.json` emitido contiene rutas absolutas efectivas para reproducir en esta máquina; para otra máquina se ajustan instalación, fuente, .NET y host manteniendo el hash del donante. Revisar `scene-v2.schema.json` y las restricciones adicionales de Go.

El estado máximo de esta etapa es `Validated`: Leon excluyó pruebas dentro del juego y sombras. Las cuatro rutas comprobadas son círculo, patio del templo, plataforma y cruce de puente con dos puntos sobre el tablero. Los enlaces paisajísticos entre masas de tierra no prometen balance ni conectividad melee global.

Entrega de recomposición R0–R8: [resultado y evidencia](../../docs/warcraft-terrain/RECOMPOSICION.md). Tres variantes 32700/32702/32703 revisadas, guardadas en el editor y repetidas con archivos idénticos.
