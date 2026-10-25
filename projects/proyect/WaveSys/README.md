# WaveSys — copia independiente de evaluación y pruebas

**Alcance vigente:** [sólo el sistema de oleadas](docs/evaluacion-nucleo-oleadas-2026-10-23.md): puntos, generación, reservas, cupos, eventos y ciclo de vida. Los informes amplios conservan antecedentes de otros componentes; no definen el trabajo activo.

Origen: `/home/snz/Documentos/WarDatsPy/struct/`, copiado el 23 de octubre de 2026. Las 162 fuentes/artefactos JASS y PowerShell coinciden byte a byte con `evidence/original-manifest.json` al copiar. No se mezcla `struct-rebuild`.

- `src/`: copia de trabajo. Después de la auditoría se añadió `Players/WavePlayerUtils.j` y se migraron 16 consumidores de partida. Los demás originales, incluida la interfaz, siguen intactos; hashes y respaldos en `evidence/player-utils-migration.json` y `evidence/player-utils-before/`. El 24/10/2026 se corrigieron E02, E13 y E03 en `SwlsWave.j` (más guard en WaveStreaks y filtro por tipo registrado en 9 limpiadores de habilidades) ([plan](docs/planes/ciclo-vida-e13-e03-e02-2026-10-24.md), `evidence/lifecycle-e02-e13-change.json`); verificados en 1.27b con `lifecycle-*` (LifecycleAudit 49/0, supervivencia 67/0); `evidence/lifecycle-e03-change.json`. E11 (multiboard en descansos; registrado también como E16) corregido en `InitialWaveMultiboard.j`/`RestTimeCountdown.j`; `evidence/e16-change.json`. E06, E07, E08 y E14 corregidos y verificados (E07 con observadores de solo lectura, `evidence/e07-verification.json`); `evidence/e06-e07-e08-e14-change.json`. E09: la pausa congela las reservas ya creadas; `evidence/e09-change.json`.
- `artifacts/`: salidas nuevas de compilación y posibles mapas de ensayo.
- `evidence/`: manifiestos, procedencia y resultados.
- `docs/planes/`: alcance y continuidad de evaluación.
- `codegraph-api/`: APIs Classic exactas para análisis; nunca concatenarlas ni importarlas al mapa.

El builder original `src/build/build-jass.ps1` concatena fuentes, excluye Pruebas/build/MissileExamples/logs y no compila ni valida objetos del mapa. Sin PowerShell disponible, el primer harness se generó reproduciendo ese conjunto de 113 entradas, con declaraciones explícitas de rects del mapa para comprobar sintaxis. No es integración en el mapa original.

Índice CodeGraph en esta raíz: fuentes activas JASS de `src/`, herramientas Python de prueba, fixtures y APIs Classic (el builder PowerShell se lee directamente). Excluye derivados, experimentos, backups, evidencias y `resources/**`. Perfil release porque las compilaciones de evaluación se ejecutan sin debug; `completeInputs=false`: no se indexan scripts generados ni recursos binarios; los rects de escenario siguen fuera. DevMission aporta recursos leídos en copias, sin convertir el índice en una unidad completa. El índice no sustituye JassHelper, pJASS ni Warcraft III 1.27b.


## Evaluación y uso del laboratorio

[Evaluación completa vigente](docs/evaluacion-completa-wavesys-2026-10-23.md): 15 hallazgos priorizados y cobertura de114 fuentes. El recorrido de diez oleadas pasó67/67 controles con518 apariciones/muertes y victoria; usa un barrido automático, no valida balance. El conjunto exacto sigue bloqueado por E01; los objetos de armas actuales no están completos en DevMission, E15. Las variantes de diagnóstico no corrigen `src/`.

[Informe inicial histórico](docs/evaluacion-wavesys-2026-10-23.md), [cobertura por archivo](docs/cobertura-por-archivo-2026-10-23.md) y [procedencia de recursos](evidence/devmission-resource-pack.json).

[Registro independiente de jugadores](docs/wave-player-utils.md): `WavePlayerUtils`/`WavePlayer` para la partida; `PlayerUtils`/`User` sigue perteneciendo a la interfaz. El nuevo registro pasó 39 controles en 1.27b tanto aislado como junto al antiguo, con 144 retiradas por ejecución. Las 114 fuentes actuales compilan y validan en el harness de diagnóstico que adapta E01. No acredita aún el mapa completo ni desconexiones multijugador.

Para reconstruir el mismo laboratorio con un identificador NUEVO:

```bash
python3 /home/snz/Documentos/ChatGPT/Proyect/WaveSys/tools/build-core-audit.py --run-id mi-prueba-nueva
```

No reutilizar un identificador que ya tenga salidas: el builder conserva las evidencias previas. `--initialize-death-slot` aplica únicamente al JASS generado el cambio aislado E02; no modifica la biblioteca. `--fixture tests/RemovalAudit.j` elige la observación diferida de retirada. Nunca usar el borde TheEnd vacío de estos laboratorios en el mapa real.

Mapas y registros finales están en `artifacts/` y `evidence/`; el mapa base TerrainDev sólo se lee y se modifica una copia de su script para el laboratorio. Los laboratorios básicos no contienen los objetos/imports de supervivencia; los de integración con `--resource-base` usan el paquete verificado de DevMission. Las APIs de `codegraph-api/` se usan únicamente para el índice.

Para reconstruir el ensayo del registro propio, usar otro identificador nuevo:

```bash
python3 /home/snz/Documentos/ChatGPT/Proyect/WaveSys/tools/build-core-audit.py --run-id jugadores-nuevo --source-set players --fixture tests/PlayerUtilsAudit.j
```

`--source-set players-coexist` incorpora también el PlayerUtils original. `--break-roster-inverse` sirve sólo como control negativo deliberado: modifica la entrada generada y debe producir FAIL. Nunca entregar ese mapa como versión corregida.


## Recursos originales y laboratorios ampliados

`resources/devmission-v096/` contiene sólo recursos extraídos de `/home/snz/Descargas/DevMission v0.96.w3x`, cuyo hash se conserva en `evidence/devmission-source-provenance.json`. El original no se modifica ni ejecuta. No importar su script/terreno por estas instrucciones.

La base `artifacts/TerrainDev-WaveResources-v1.w3x` se construyó con `tools/build-resource-base.py`;246recursos reextraídos coinciden por hash. Para un escenario nuevo, con identificador no usado:

```bash
python3 /home/snz/Documentos/ChatGPT/Proyect/WaveSys/tools/build-integration-audit.py --run-id ensayo-nuevo --fixture tests/SurvivalAudit.j --resource-base
```

`--aura-observers` sólo para `tests/ResourceSkillsAudit.j`: añade cuatro observadores de lectura al código generado, sin cambiar `src/`. Los fixtures de supervivencia y API son automatizaciones de diagnóstico; no son una entrega jugable corregida. Consultar los manifiestos y el informe para conocer modificaciones y cobertura. Selección manual/timeout, multijugador y calidad visual completa continúan sin acreditar.
