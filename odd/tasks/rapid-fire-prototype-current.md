# Moving Orc Shaman rapid-fire prototype — integrated delivery
Works: copied integrated candidate and visible Q base; first JassHelper/pJASS/archive build exit0; corrected build02 exit0.
Missing: successful integrated battery, final non-test map, independent verification/review and delivery.
Blockers: first battery aborted after controller Move before casting (failed composite identity predicate unknown); corrected native02 running, result pending, no human approval needed.

## Specs
- S1: "te cuento la idea, sera tener dos personajes, uno que tendra la habilidades y todo pero permanecera fuera de camara, sus acciones sera reflejadas en otro, este modo permitira interactuar ciertas mecanicas, la idea es habilidad punto, permite dispara varios misiles tipo fuego rapido, configurable en 4 por segundo,junto a la unidad a realizar animacion de attack cada vez que salga un misil y su velocidad de animacion suba a 300%, ahora esto tendra un contador o timer, de forma que si vuelven a castear dentro del numero de rafagas ejemplo ya salieron 2 misiles, solo daria reset al tiempo para que salgan mas misiles en lugar de salir un misil casi cerca del otro que romperia el intervalo de 4 por segundo, se entiende esta idea? me confirmas"
- S2: "vale, sera por disparos restantes, al terminar los disparos, regresa a animacion 100%, adicional, que tipos de collision permite el sistema"
- S3: "vale, terminara y daniara al golpear un enemigo, terminara tambien si choca contra arbol/destrictibles, acantilados, y obviamente la salida de limites del mapa."
- S4: "4 estan bien" — response to shots-per-burst question, not the earlier eight-shot example.
- S5: "10" — response to base damage per missile question.
- S6: "si, sera al nuevo punto" — response to updating future shots' aim on recast while already-launched missiles retain their trajectory.
- S7: "direccion fija, 1500" — response to direction with fixed maximum range rather than stopping at the clicked point.
- S8: "si, esta bien" — response to proposed 1200 units/s, approximately 1.25s unobstructed travel over1500.
- S9: "bola de fuego"
- S10: "fisicos"
- S11: "si, seria al visible" — response to damage-source attribution; visible, not off-camera unit.
- S12: "chaman, de lor orcos, referencia el que tiene la habilidad furia que aumenta escala a las unidades y hace veloces"
- S13: "si podra moverse"
- S14: "si angulo fijo" — response to storing the latest cast angle while the Shaman moves, rather than recalculating toward a world point on every shot.
- S15: "si, esto de adcional, la unidad visible en caso este con misiles restantes y la unidad invisible genera una accione de mover, la unidad visible ya no recibira eso como una accion de mover sino se movera mediante movimiento de script, podria ir la del misil, a velocidad de 350, en caso a medio camino termina de lanzar todos lo misiles, retoma con la orden de mover al punto si no hubiera llegado, no se movera facing ni nada mas, solo se movera mediante el movimiento del misil que opinas de esto"
- S16: "si, debera respetar collisiones, y otro, ejemplo esta en movimiento y se manda la acion de disparar, entrara en modo movimiento por script y eso estara activo hasta que la unidad llegue o termine de lanzar los misiles, se daria un stop para que la unidad no este aun con la orden nativa de mover y pase normalmente a mirar al punto de disparo y ejecute sus animaciones, el movimiento debe ser mediante setunitx/setunity ya que ello no cancela animaciones y otros parametros"

- S17: "Mantener 4/s y 300%; reiniciar por tiro" — user-selected option after inspecting stock attack durations. Restart the attack per shot even if it truncates the previous gesture; do not silently change cadence or animation speed.

S18–S27 are historical experiment grants, retained verbatim in odd/tasks/archive/rapid-fire-prototype-through-L73.md. S28 supersedes their single-run, preparation-only and RED-before-each limits for integrated delivery; historical results remain scoped, not global acceptance.

- S28 — Latest user request verbatim:
> Continúa hasta entregar el prototipo jugable completo conforme a los requisitos que ya acordamos.
> Tienes autorización para implementar, compilar, probar y corregir de forma iterativa en copias del proyecto. No me pidas permiso por cada callback, ajuste de fixture, compilación o repetición de una prueba necesaria. Conserva los originales y no cierres mis aplicaciones.
> Prioriza integrar lo pendiente: colisiones, alcance, movimiento, orientación, animaciones y control de ambas unidades. Usa los componentes que ya pasaron sus pruebas.
> No exijas una prueba RED separada antes de implementar cada comportamiento solicitado. Verifica los requisitos mediante una batería integrada; crea diagnósticos adicionales cuando aparezca un fallo que necesite aislarse.
> Si falla un ensayo por colocación, limpieza o temporización, corrige el ensayo dentro de esta autorización. Evita encadenar nuevas rondas de aprobación.
> Mantén un único estado actual breve: qué funciona, qué falta y qué bloquea la entrega. Conserva los informes históricos sin repetirlos en cada actualización.
> La siguiente entrega debe incluir un mapa que pueda abrir y jugar, fuentes y una lista concreta de limitaciones. Las revisiones adicionales pueden continuar después.
> Pregúntame únicamente si hay una decisión de comportamiento sin resolver, necesitas ampliar el alcance o una acción puede afectar mis originales.

## Tasks
- T1 [S1,S9,S12,S15-S22] route=worker status=done(scoped-prerequisites-only) commit=unavailable(no-user-commits) — Preserve validated prerequisites; no full mover/pathfinder equivalence claim.
- T2 [S1-S17,S28] route=worker status=done(compilable-corrected-candidate) commit=unavailable(no-user-commits) — Integrated candidate copied and corrected revision compiled; native behavior not yet verified.
- T3 [S1-S17,S28] route=parent status=in_progress(native02-running) commit=unavailable(no-user-commits) — First run failed; corrected build02 exit0, native02 running with outcome pending; no separate RED per behavior.
- T4 [S1-S17,S28] route=verify status=pending(proportional-review) commit=unavailable(no-user-commits) — Proportional review, not per-callback gates; additional reviews may continue after delivery.
- T5 [S1-S17,S28] route=parent status=pending(delivery) commit=unavailable(no-user-commits) — Deliver playable/openable map, sources and concrete limitations.
- T6 [S23] route=worker(context-backstop) status=done(projectskillcopy) commit=unavailable(no-user-commits) — Verified three-file project skill import preserved.

## Workflow
current_workflow: integrated_delivery
Canonical current state: this file only. Preserve originals and historical reports. No commits, publishing, installing or closing applications authorized. Ask only for unresolved behavior, scope expansion or risk to originals.
Implementation context (not new user behavior): projects/rapid-fire-prototype/playable/ now contains the integrated copy, prepared base and new UI objects (visible Q); originals preserved, immutable inputs in playable/build-inputs/. Controller/order handling and precise diagnostics corrected; 17 prior static plus 12 correction checks exit0, NOT NATIVE VERIFIED. Risk4 native assessment remains unassessable (untracked): independent verification pending, no native approval. Parent build02 job17 completed exit0; fresh exact-profile preflight02 FREE at snapshot, game02 job19 launched and observer job18 pending. Launcher01 exit0 proves neither closure nor profile freedom; no application closed by agent.

## Log
L1 — Original user request verbatim: "te cuento la idea, sera tener dos personajes, uno que tendra la habilidades y todo pero permanecera fuera de camara, sus acciones sera reflejadas en otro, este modo permitira interactuar ciertas mecanicas, la idea es habilidad punto, permite dispara varios misiles tipo fuego rapido, configurable en 4 por segundo,junto a la unidad a realizar animacion de attack cada vez que salga un misil y su velocidad de animacion suba a 300%, ahora esto tendra un contador o timer, de forma que si vuelven a castear dentro del numero de rafagas ejemplo ya salieron 2 misiles, solo daria reset al tiempo para que salgan mas misiles en lugar de salir un misil casi cerca del otro que romperia el intervalo de 4 por segundo, se entiende esta idea? me confirmas"
L2–L73 — Historical reference: odd/tasks/archive/rapid-fire-prototype-through-L73.md (exact L73 checkpoint); earlier full L2–L54 history remains in unchanged odd/tasks/rapid-fire-prototype.md. No historical experiment restriction overrides S28.
L74 — Latest user request verbatim; integrated-delivery rebaseline, tracking only:
> Continúa hasta entregar el prototipo jugable completo conforme a los requisitos que ya acordamos.
> Tienes autorización para implementar, compilar, probar y corregir de forma iterativa en copias del proyecto. No me pidas permiso por cada callback, ajuste de fixture, compilación o repetición de una prueba necesaria. Conserva los originales y no cierres mis aplicaciones.
> Prioriza integrar lo pendiente: colisiones, alcance, movimiento, orientación, animaciones y control de ambas unidades. Usa los componentes que ya pasaron sus pruebas.
> No exijas una prueba RED separada antes de implementar cada comportamiento solicitado. Verifica los requisitos mediante una batería integrada; crea diagnósticos adicionales cuando aparezca un fallo que necesite aislarse.
> Si falla un ensayo por colocación, limpieza o temporización, corrige el ensayo dentro de esta autorización. Evita encadenar nuevas rondas de aprobación.
> Mantén un único estado actual breve: qué funciona, qué falta y qué bloquea la entrega. Conserva los informes históricos sin repetirlos en cada actualización.
> La siguiente entrega debe incluir un mapa que pueda abrir y jugar, fuentes y una lista concreta de limitaciones. Las revisiones adicionales pueden continuar después.
> Pregúntame únicamente si hay una decisión de comportamiento sin resolver, necesitas ampliar el alcance o una acción puede afectar mis originales.

L75 — S28 integrated candidate/base/UI copies prepared; build01 exit0, first native COMPLETE|1|3|1|0 fixture ABORT after controller Move before casting (composite identity predicate unknown, not movement proof). Controller/order correction and diagnostics: 17+12 static checks exit0, NOT NATIVE VERIFIED; corrected build02 exit0, native02 running/pending; final map, independent review and delivery pending. Evidence: [integration](../../projects/rapid-fire-prototype/playable/reports/integration-preparation.json), [packaging](../../projects/rapid-fire-prototype/playable/reports/packaging-preparation.json), [build01](../../projects/rapid-fire-prototype/playable/reports/integrated-01-build.json), [native01](../../projects/rapid-fire-prototype/playable/reports/integrated-01-native-reader.json), [correction](../../projects/rapid-fire-prototype/playable/reports/integrated-01-correction.json), [build02](../../projects/rapid-fire-prototype/playable/reports/integrated-02-build.json).
