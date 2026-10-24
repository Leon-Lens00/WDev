# Registro de jugadores de WaveSys

Solicitud: crear un PlayerUtils propio porque `User` pertenece al contrato de la interfaz. Trabajo autorizado sólo sobre la copia independiente de WaveSys; Warcraft III Classic 1.27b, JassHelper instalado, perfil release.

## Decisiones y aceptación

- Crear `src/Players/WavePlayerUtils.j`, sin dependencia de PlayerUtils, Camera, UserInterface ni Table. Mantener `User` y las bibliotecas de interfaz byte a byte.
- `WavePlayer` identifica un slot por id, incluido 0; `NULL=-1`. Expone únicamente las operaciones que necesita la partida: `AmountPlaying`, `fromPlaying`, `fromIndex`, `[]`, `id`, `handle`, `toPlayer`, `isPlaying`, `name`, `nameColored`, `Local` y `LocalId`.
- El registro activo incluye humanos USER/PLAYING en los 12 slots Classic (0..11). No incluye IA ni neutrales. Se construye al inicializar y elimina al recibir EVENT_PLAYER_LEAVE. No incorpora espectadores ni jugadores que entren después.
- Usar un conjunto compacto `WavePlayerRoster` con inverso posición+1, cero para ausentes. Al retirar, actualizar el inverso del id movido; duplicados, ausentes e ids fuera de rango no alteran el conjunto. Orden de iteración no estable tras una salida. Un roster independiente permite verificar el algoritmo real en motor sin simularlo en Python ni alterar la partida activa.
- Migrar los 16 archivos de partida identificados en `evidence/player-utils-migration.json`: selección, vidas, oro, propietario, descansos, streaks, pickups, stage y multiboards/healthbars. Los puentes a MenuClient entregan handles/unidades; no convierten ni sustituyen `Client.user`.
- No corregir otros hallazgos de la auditoría ni certificar la interfaz antigua. E04 queda abierto para sus consumidores de UI, con aislamiento de los consumidores migrados documentado.

## Fases y evidencia prevista

1. [x] Consultar CodeGraph (`PlayerUtils User ...`, consumidores concretos), verificar interfaces; guardar hashes y copias anteriores bajo `evidence/player-utils-before/`. La auditoría original y su manifiesto son la base histórica.
2. [x] Implementar registro y migración preservando codificaciones y finales de línea; comprobar límites de las interfaces de selección/UI.
3. [x] Compilar y validar laboratorio con la implementación exacta, probar retiros sucesivos/no contiguos, duplicados, límites, vaciado, reutilización y roster activo en 1.27b. Registrar comandos, hashes, log nuevo y captura; cerrar sólo la sesión propia.
4. [x] Compilar las 114 fuentes activas conjuntamente con UI preservada. El bloqueo E01 conocido requiere renombrar cuatro InitTrig sólo en la entrada de diagnóstico, identificado en manifiesto; ese resultado no acredita el build original sin adaptación ni una partida completa.
5. [x] Verificar fuente original intacta y UI preservada, sincronización CodeGraph, actualizar README, guía de API y E04 con resultados y límites.

Estado final: implementación, migración, compilación y ensayos completados; resultados y límites en ../wave-player-utils.md. Pendientes de producto fuera de este alcance: UI antigua, mapa completo y desconexiones reales multijugador. No se transfieren los PASS del conjunto a esas comprobaciones.
