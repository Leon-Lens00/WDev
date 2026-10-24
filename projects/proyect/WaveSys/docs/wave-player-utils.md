# WavePlayerUtils

Biblioteca propia de la copia de WaveSys para Warcraft III Classic 1.27b. Fuente: [WavePlayerUtils.j](../src/Players/WavePlayerUtils.j). No requiere `PlayerUtils`, `UserInterface`, `Camera`, `Table` ni otra biblioteca del mapa. Las APIs del compilador son las Classic registradas en [player-utils-toolchain.json](../evidence/player-utils-toolchain.json).

## Contrato

`WavePlayer` representa un id de slot, sin asignación de instancias. El id 0 es válido; `WavePlayer.NULL=-1`. `fromIndex` admite identidades 0..15, incluidos neutrales, pero sólo los humanos USER/PLAYING de 0..11 pertenecen al registro activo. No registrar IA como humanos. El conjunto se establece al inicializar y se actualiza por `EVENT_PLAYER_LEAVE`; no implementa incorporación tardía, reconexión ni un sistema de espectadores.

| Operación | Resultado |
|---|---|
| `WavePlayer.AmountPlaying` | Cantidad activa actual, puede ser 0 |
| `WavePlayer.fromPlaying(index)` | Jugador en posición 0..cantidad-1; NULL fuera de rango |
| `WavePlayer.fromIndex(pid)` / `WavePlayer[p]` | Identidad del slot; NULL para id inválido o handle null |
| `u.id`, `u.handle`, `u.toPlayer()` | Id y handle nativo; handle null para NULL |
| `u.isPlaying` | Pertenencia al registro propio; false para NULL/IA/neutrales |
| `u.name`, `u.nameColored` | Nombre nativo actual; color nativo actual, incluido rojo/id 0 |
| `WavePlayer.Local`, `WavePlayer.LocalId` | Identidad local, únicamente para decisiones visuales |

`Local` no habilita mutaciones de juego por cliente. En la migración sólo conserva los puntos de selección/cámara ya condicionados por jugador local. El registro activo nunca usa `GetLocalPlayer` para decidir quién pertenece.

Ejemplo para nuevos consumidores:

```jass
library MyWaveFeature requires WavePlayerUtils
    function Example takes nothing returns nothing
        local integer i = 0
        local WavePlayer u
        loop
            exitwhen i >= WavePlayer.AmountPlaying
            set u = WavePlayer.fromPlaying(i)
            // Operar con u.id / u.handle; no confundir i con un id.
            set i = i + 1
        endloop
    endfunction
endlibrary
```

La retirada intercambia con el último elemento y actualiza el inverso del **id movido**. El orden compacto puede cambiar; no persistir posiciones entre eventos. Los recorridos deben ejecutarse sin waits ni modificar el conjunto durante su iteración. Una salida no transfiere unidades, destruye Client ni completa por sí sola la selección; esas políticas siguen siendo responsabilidad de sus subsistemas. No se añadieron callbacks propios de salida.

`WavePlayerRoster` es el conjunto independiente que usa internamente el registro. Expone `create`, `count`, `at`, `contains`, `add`, `remove`, `clear`, `destroy`. `add`/`remove` devuelven false sin mutar ante id inválido, duplicado o ausente. `at` devuelve -1 fuera de rango. No llamar métodos sobre 0, después de destroy ni destruir dos veces. El JassHelper instalado limita estos rosters de arrays de 12 posiciones a 681 instancias simultáneas; `create` puede devolver 0 por agotamiento. WavePlayer utiliza una sola instancia privada de duración de partida. Los ensayos crean dos adicionales, sin acceso al conjunto activo.

## Frontera con la interfaz

Migrados 16 archivos de partida, enumerados con hashes anteriores/actuales en [player-utils-migration.json](../evidence/player-utils-migration.json): selección y sus puentes, oro, vidas, pickups, configuración de propietarios, descansos, stage, streaks y paneles/healthbars propios.

Permanecen byte a byte `libraries/PlayerUtils.j`, Camera, UserInterface, SyncInteger, SpacebarDetect y `UI System/MyIU/MenuClient.j`. `Client.user` conserva tipo `User`. Los puentes de partida pasan unidades/handles a Client y no sustituyen ese campo. Cambió la firma de `SelectionEnsureHeroCreated` a `WavePlayer`; su único consumidor activo, SelectionSystem, se migró también. Código externo a esta carpeta que llamara esa función con User necesitaría adaptar el argumento.

La migración elimina el acceso directo de esos 16 consumidores a `User`; pueden seguir dependiendo indirectamente de la interfaz a través de MenuClient. El defecto E04 del PlayerUtils antiguo **permanece abierto en la UI**. No presentar este aislamiento como reparación de sus listas ni de los otros once hallazgos de la auditoría.

## Verificación ejecutada

Estado más fuerte del registro nuevo: **Tested in map**, en laboratorio Classic 1.27b individual. Fuentes de partida originales preservadas en WarDatsPy. En la copia sólo cambiaron las 16 sustituciones explícitas y se añadió la biblioteca; originales anteriores conservados para comparación.

| Ensayo | Resultado | Evidencia |
|---|---|---|
| Biblioteca exacta, sin PlayerUtils ni UI | 39 controles, 0 fallos; 144 retiradas | [log nativo](../evidence/players-alone-v1-native.txt), [build](../evidence/players-alone-v1-build.json), [captura](../evidence/players-alone-v1-screen.png) |
| Biblioteca exacta junto al PlayerUtils original | 39 controles, 0 fallos; 144 retiradas | [log nativo](../evidence/players-coexist-v1-native.txt), [build](../evidence/players-coexist-v1-build.json) |
| Control negativo: omitir el inverso del jugador movido sólo en entrada generada | Rechazado: 10 de 39 controles fallan; incluye reproducción E04 | [log](../evidence/players-negative-v1-native.txt), [build](../evidence/players-negative-v1-build.json), [captura](../evidence/players-negative-v1-screen.png) |
| Conjunto actual, 114 fuentes, UI preservada | JassHelper y pJASS correctos con adaptación de diagnóstico E01 | [compilación](../evidence/players-full-diagnostic-v1-compile.json), [114 hashes y adaptación](../evidence/players-full-diagnostic-v1-manifest.json), [orden de inicialización](../evidence/players-initialization-order.txt) |

El fixture ejecuta la implementación real vJASS en el motor: ids no consecutivos, cero, duplicados, ausentes, límites, vaciado, reutilización, independencia de conjuntos, nombre/color y comparación del registro de partida con los slots nativos. Doce rotaciones de retirada comprueban pertenencia, cardinalidad, unicidad y enumeración en cada transición. El humano real del laboratorio es uno; las 144 retiradas se realizan sobre rosters independientes de prueba. **No son 144 desconexiones de clientes**. El enlace al evento nativo de salida está compilado, pero las desconexiones reales con varios clientes y la ausencia de desync quedan pendientes.

El harness completo declara 15 rects null y config/main mínimos y renombra cuatro InitTrig únicamente en el JASS generado para superar el bloqueo E01 existente. No se jugó ese harness ni acredita una partida completa de supervivencia, objetos/imports, interfaz visible o comportamiento de los 16 consumidores en todas sus fases. El índice CodeGraph conserva perfil release y completeInputs=false; sus consultas verificaron fuentes y conexiones, no esas pruebas de motor.

Los tres mapas de ensayo se compilaron, validaron, empaquetaron y reextrajeron con comparación del script y miembros ajenos. Las tres sesiones propias se cerraron por identidad de proceso; una usó SIGTERM individual tras dos abortos del guard de foco, las otras la confirmación de salida. Se preservaron las partidas ajenas. La incidencia de foco/perfil quedó [resuelta con aislamiento y cierres comprobados](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-024931-wavesys-prueba-perfil-ocupado.md).

Plan y decisiones: [player-utils-independiente](planes/player-utils-independiente-2026-10-23.md). El builder original descubre automáticamente la nueva fuente bajo Players; no se modificó su script PowerShell ni se importaron las APIs del índice al mapa.
