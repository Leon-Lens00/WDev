# Perfil gráfico ocupado durante la prueba de Shots Vol. II

- Fecha: 2026-10-22 17:51 America/Lima. Agente: chat ModelEditor. Classic 1.27b / perfil NewGen moderno. Modelos Vol. II, mapa de laboratorio SHA256 91eab92fdbbe33297f48fe360d3ce5343c54dd0c459698e1b7bfec44f4732a77.
- Síntoma: `wc3.py play` devolvió código 2: ya hay una partida en el perfil moderno. La comprobación previa no encontró una instancia terminada de arrancar; otra se inició durante la preparación.
- Evidencia: se identificó proceso 663900, prefijo `FrozenThone/runtime/proton-newgen-modern-test/pfx/`, mapa distinto `c3ff128a85dc1c7b.w3x`. No pertenece a esta prueba; no se cerró ni recibió entradas.
- Causa confirmada: contención de perfil entre trabajos, no fallo de los MDX ni del compilador. La protección del lanzador funcionó como corresponde.
- Impacto: los archivos/6174 poses y el mapa compilado/reextraído ya se verificaron, pero este intento no acredita funcionamiento en motor.
- Acciones: continuar organización/documentación y comprobar disponibilidad. Evaluar un perfil propio aislado sin modificar el lanzador ni la partida activa si sigue ocupado.
- Estado: pendiente de prueba visual. Conservar la partida ajena. No atribuir PASS del mapa a este intento rechazado.

## Recuperación comprobada

Se creó un prefijo propio por copia Btrfs reflink, con archivos escribibles independientes y hashes de war3.exe/d3d8/d3d9 contrastados. No se modificó la configuración compartida. Cargó el mapa 91eab92fdbbe3329, capturado en `ModelEditor/evidence/vol-ii/game-stand.png`; cierre propio verificado con retorno 0 en `exit.json`. Posteriormente cargó el mapa comparativo de ambos volúmenes 4da6392c4abc1ea7, con capturas en `evidence/brillo/`. La contención del perfil está resuelta para este trabajo mediante aislamiento; no se acredita que el perfil compartido esté libre.

Estado: resuelto el bloqueo de ensayo propio. La pérdida de núcleo claro tiene informe independiente abierto.
