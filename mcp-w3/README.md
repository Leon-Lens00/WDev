# MCP W3

Copia completa (con modificaciones locales adaptadas a Warcraft III) de:

| Carpeta | Origen | Commit base |
|---|---|---|
| `wc3-forge/` | https://github.com/StephenSHorton/wc3-forge (GPL-3.0) | `4ce58432ec47d073822222929bdb8603c257c9fb` |
| `codegraph-vjass/` | https://github.com/colbymchenry/codegraph (MIT) | `6560052a6f856855d3f71eee838fd66ccfa4285d` |
| `wc3-agent-lab/` | propio, sin repositorio git | — |

- `_historial-git/*.bundle`: historial git original de cada clon
  (`git clone _historial-git/wc3-forge.bundle wc3-forge-hist`).
- Los archivos de las carpetas incluyen los cambios locales sin commitear.
- No incluido (regenerable): `node_modules`, `bin/Release`, `obj`, `.git`,
  `wc3-forge/.tools` (SDK .NET), `wc3-forge/build/bin` (exe), `wc3ctl/downloads`,
  `wc3-agent-lab/bin` y `downloads`, `*.log`.
