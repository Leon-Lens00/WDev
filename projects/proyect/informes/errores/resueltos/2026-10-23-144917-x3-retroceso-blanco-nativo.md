# Impacto de retroceso del laboratorio nativo X3

Fecha2026-10-23; Codex /root. TerrainDev, WarcraftIII1.27b, CachyOS/Proton, producción f087047b, fixture70845a1c. Estado: en investigación.

Evidencia: TerrainDev/reports/x3-rom-port-20261023-143455/20261023-144524/native-engine.txt. NativeProbe38controles:37PASS/1FAIL, oracle5259valores/0diferencias,77creados/77retirados,0activos. Falla exclusivamente `native retreating satellites sweep enemies behind union point`. Regresión153PASS sobre esta revisión.

Esperado: enemigo90unidades detrás de la unión recibe daño durante retroceso USA. Observado: predicado hit+vida falsa. No se registró todavía el término exacto fallido. Hipótesis: blanco/camino detrás del inicio de la franja despejada, desplazamiento de CreateUnit o terminación por obstáculo. No se ha demostrado defecto de producción. Se instrumentará posición real, vida, hits/walls, barrido y el mismo ensayo trasladado dentro de la franja acreditada. No afirmar aceptación funcional total mientras falte esta comprobación.

Investigación adicional: el caso aislado20261023-145002 dio2impactos/50daño sin cambios de producción; el flujo completo20261023-145524 reprodujo0impactos. La hipótesis de obstáculo se contradijo: GroundCollision baselineBehind=0 y walls=0. Se observó un origen X20u distinto después de RapidProbe, compatible con la recolocación de CreateUnit al ocupar el mismo spawn que otro actor. El fixture usaba sy fijo y no el eje real del cast para situar su enemigo. Corrección bajo comprobación: construir el blanco con lastFusionX/Y y shot.angle, fijar su posición después de CreateUnit y acreditar terreno+posición. Se registra también unionY y angle para confirmar la causa y descartar mera coincidencia. La física sigue exactamente f087047b.

## Recuperación comprobada — resuelto

Flujo completo corregido20261023-145909:153regresionesPASS +39nativasPASS,5259valores/0diferencias,86cuerpos nativos creados/retirados y cero casts/proyectiles/flashes. Ambos evaluadores rechazaron22controles negativos. Ver native-engine.txt y native-validated.json en esa carpeta.

Causa confirmada en el fixture: después de Rapid Fire queda un actor en el spawn. El emisor nativo nace desplazado por CreateUnit, y conserva esa posición Y aunque el ensayo sólo cambia X. Registro: uniónY2961.081, ángulo0.045; el blanco antiguo se colocabaY3044 usando sy3024, lejos de la trayectoria de retroceso (aproxY2977 al retroceder90u). GroundCollision no bloqueó el trayecto (walls0) y el emisor no pasó cerca del blanco. En ejecución aislada, sin el actor previo, ese blanco sí recibía2impactos.

El caso corregido sitúa el blanco con lastFusionX/Y y shot.angle, verifica terreno y posición y observa2impactos en el flujo completo. No fue necesario modificar la física f087047b. El registro diagnóstico largo de Preload se trunca a255caracteres; los predicados PASS, contadores de aceptación y datos de origen citados no se truncaron. Logs de los intentos fallidos conservados. La recuperación corresponde al laboratorio; no se atribuye una corrección inexistente al sistema de misiles.
