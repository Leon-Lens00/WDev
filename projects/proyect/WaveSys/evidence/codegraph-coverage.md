# CodeGraph — evidencia de uso y límites

23-10-2026. Primera consulta por MCP a `/home/snz/Documentos/WarDatsPy/struct` con SwlsWave.j/IAManager.j/WavePointApi.j/WavePointGroups.j/StageExample.j: raíz no indexada. Se continuó con lectura directa y no se inicializó allí.

Tras solicitud del usuario de una copia aislada: raíz `/home/snz/Documentos/ChatGPT/Proyect/WaveSys`, sin índice ancestro aplicable. Init por CLI indexó115 archivos (113 fuentes JASS activas y2 APIs), 16.715 nodos y69.547 aristas. El builder PowerShell no es fuente semántica indexada: se leyó directamente. Posteriormente se incorporaron el fixture JASS y builder Python por watcher.

Consultas MCP reales a la raíz nueva:

- Wave.onTick / PendingSpawn_execute / WavePointGroupApplyToWave / AIResetOrderState / AIMaybeIssueAttackOrder.
- UnitAlive / native / WaveTest: localizó la declaración en SpellIndex.j:30.
- WaveTrapUpdateStuns / WaveTrapCastStart / WaveAuraRemoveMember / WavePriestRemoveMember / WaveSkillVisualDestroy / WaveRangedBossLightningIndex.
- AISelectTargetHero / WaveCountPlayingUsers / RestTimeOnWaveFinished / HeroLivesHandleDeath / SelectionStartFlow.
- User.onLeave / User.fromPlaying / PlayingPlayerIndex / InitialWaveMultiboardTick / PopulateInitialWaveMultiboard:17 consumidores de fromPlaying.

Consultas auxiliares al índice propietario TerrainDev/scripts: build.py/map_script/run/build para conocer el proceso real del mapa base; no se modificó TerrainDev.

Perfil release, compilaciones sin debug, completeInputs=false. common.j/Blizzard.j exactos copiados y hashes en api-provenance.json. Nunca se concatenan al mapa. Exclusiones en codegraph.json: src/build, src/Pruebas, src/backups, artifacts, evidence y cachés. La raíz está registrada en AGENTS.md y README.

Respuestas con límites: ExecuteFunc calculado no demuestra su destino sin flujo de valor; macros muestran origen e invocación, no cuerpos editables; condiciones pueden conservar candidatos y las unidades de compilación externas no están completas. No se observaron bloqueos de vigencia DISABLED/RECOVERING. La posible cobertura de tests inferida por aristas no demuestra su ejecución: el laboratorio usa un borde TheEnd y sus entradas efectivas están en los manifiestos de build.

Consulta final MCP WaveRemovalAudit / Observe: reconoce la biblioteca y su wiring Retire→Observe, además de ambos fixtures como consumidores de Wave. Sin aviso de vigencia bloqueada.


## Seguimiento: PlayerUtils independiente, 23/10/2026

Consultas MCP ejecutadas antes de editar: `PlayerUtils User UserInterface User.onLeave User.fromPlaying`; `PlayerUtils User InitialGoldConfig SelectionHeroSpawn SelectionSystem HeroLives WaveStreaks build-core-audit`. Se completó el inventario directo de usos de User sobre las 113 entradas activas del manifiesto.

Después de editar: `WavePlayerUtils WavePlayerRoster remove WavePlayer AmountPlaying SelectionEnsureHeroCreated`; `WavePlayerRoster WavePlayerUtils OnLeave SelectionClientBridge SelectionHeroSpawn`; cierre con `WavePlayerUtils WavePlayerRoster`. projectPath siempre /home/snz/Documentos/ChatGPT/Proyect/WaveSys. El índice devolvió fuente actual, remove->contains, OnLeave->remove, el consumidor SelectionSystem de SelectionEnsureHeroCreated y la nueva dependencia WavePlayerUtils del puente. Sin avisos de falta de vigencia, DISABLED o RECOVERING.

Avisos conservados: macros/módulos y compilación condicional no evaluada en las dependencias, ExecuteFunc calculado en Wave, completeInputs=false y perfil release. El rótulo «tested via callers» del grafo no demuestra que OnLeave haya recibido desconexiones reales: el fixture ejercita directamente el roster, no salidas de clientes. JassHelper/pJASS y las tres sesiones nativas están documentados por separado en docs/wave-player-utils.md. No se infieren conexiones entre índices ni se indexaron mapas/evidencias.

## Ampliación final de evaluación, 23/10/2026

Consultas MCP con projectPath WaveSys: builders/IntegrationAudit/SwlsSound/RestTimeOnWaveFinished; StageExample/Trig_w1_Actions/WavePointGroupsConfig/WaveByBoard; WavePointGroupRegister/Build/PointApi; TheEnd/endF/eventos/SurvivalEnd; TryExecute de Aura, Ranged, Mortar, Priest, Trap, SiegeZone y Waveform; limpieza/compactación de aura; WaveDamageCredit API real; SelectionSystem/SelectionHeroSpawn/SelectionStartFlow/TenderSystem; WeaponInventoryCore/FireActive/ProfileConfig; Client/UserInterface; HeroLivesHandleDeath/OnDeath; WaveStreaks/proyectiles; AIBossReinforcementApply/ApplySlots/AIOnWaveExternal/ClearTrackedHeroes; DialogDisplayBJ/PauseGame. Se ampliaron directamente fragmentos elididos.

Índice propietario TerrainDev/scripts: build.py Reader/units/encode_units y rapid_objects.py abilities/encode_abilities, para leer/verificar tablas Classic v2 y conocer empaquetado. No se modificaron esas fuentes ni se copiaron dependencias para aparentar aristas entre raíces.

Se añadió resources/** a exclusiones. Perfil release y completeInputs=false mantenidos. Respuestas sin DISABLED/RECOVERING; avisos conocidos de condiciones, macros y ExecuteFunc conservados. La evidencia de ejecución es cada registro nativo, no los rótulos tested-via-callers. Matriz explícita en complete-coverage.json; no es cobertura de líneas/ramas.

Consulta final MCP: build-resource-base.py / build-integration-audit.py / ResourceSkillsAudit / SurvivalAudit / WavePlayerRoster. Reconoció herramientas actuales, observadores opcionales y consumidores de PlayerHero en los nuevos fixtures; sin aviso de vigencia bloqueada. No se interpretó la ausencia de ramas elididas como ausencia de consumidores.
