# Skills

Dos versiones de las mismas skills (formato `SKILL.md`):

- `codex/`: copia sin modificar de `~/.codex/skills` (2026-10-23), para Codex.
- `claude/`: adaptada a Claude Code (2026-10-23). `.claude/skills` es un enlace simbólico a esta carpeta.

| Skill | Uso |
|---|---|
| `build-warcraft3-vjass-127b` | Crear, auditar y compilar mapas W3X y JASS/vJASS (Classic 1.27b) |
| `probar-warcraft3-classic-linux` | Probar mapas en Warcraft III Classic en Linux |
| `crear-misiles-warcraft3-127b` | Habilidades de misiles en JASS/vJASS |
| `optimize-slendytubbies-wc3-127b` | Optimizar personajes extraídos para 1.27b |
| `wc3-classic-modeling` | Modelos, animaciones y efectos de WC3 clásico |
| `systematic-debugging` | Investigación de fallos y regresiones |
| `writing-plans` | Planes técnicos de varias fases |
| `judgment-day` | Revisión adversarial: Codex con `spawn_agent`; Claude con dos `Agent` Explore (solo lectura) |
| `control-escritorio-linux` | Control del escritorio Hyprland (capturas, clics) |

## Cambios de la versión `claude/`

- Referencias cruzadas relativas en lugar de `/home/snz/.codex/skills/...`.
- `judgment-day` usa la herramienta `Agent`; se quitaron los `agents/openai.yaml`.
- CodeGraph se registra en `.mcp.json` (raíz del repo).
- Se retiraron las copias antiguas de `.pi/skills`.

Algunas referencias apuntan a rutas de esta PC fuera del repo
(p. ej. `/home/snz/Documentos/ChatGPT/Proyect/...`, `/home/snz/Documentos/MCP W3/...`).
