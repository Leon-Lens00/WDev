# Lectura del repositorio privado por conector

- Fecha/agente: 2026-10-23T22:01:53.820748-05:00, Codex /root. Repositorio Leon-Lens00/WDev.
- Síntoma: github_get_repo devolvió404 y list_repositories no mostró repositorios.
- Evidencia: CLI gh autenticada como Leon-Lens00 leyó el mismo repositorio privado,
  su rama main y su árbol completo de6975archivos, revisión `8c38cc1033e49c88c74ebebcf2b444bd52669868`.
- Impacto: el conector no permite esta lectura, pero no bloquea la auditoría local.
- Causa confirmada: las dos vías muestran accesos diferentes; la configuración
  exacta de permisos del conector no se investigó ni se modificó.
- Acción/verificación: alternativa gh en modo lectura, árbol no truncado y
  comparación con los archivos versionados del checkout WDev. HEAD local/remoto
  iguales, status limpio, cero archivos versionados ausentes del disco.
- Estado: cerrado mediante alternativa comprobada. No afirmar recuperación del
  conector; sigue sin acreditar acceso. No se inició sesión nueva ni se subió nada.
- Evidencia: `work/github-audit-20261023/`, informe de alcance en
  `docs/github-verificacion-20261023.md`. Sin pendientes para esta lectura.
