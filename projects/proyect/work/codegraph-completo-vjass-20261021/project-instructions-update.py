from pathlib import Path
import hashlib,json
b=Path(__file__).resolve().parent
p=b.parents[1]/'AGENTS.md'
s=p.read_text()
s=s.replace('Se comprobó la actualización\n  automática al crear, modificar y eliminar archivos en las tres raíces.', 'La revisión actual se comprobó con canarios aislados de JASS y JavaScript\n  (altas, cambios, bajas, perfil y datos), observando SQLite antes de cualquier\n  consulta/sync adicional; las tres raíces reales se reconstruyeron y consultaron\n  por MCP sin modificar sus fuentes.')
start=s.index('- El soporte JASS/vJASS sigue siendo parcial.')
end=s.index('- Los mapas, builds y evidencias históricas',start)
s=s[:start]+'''- Integración JASS/vJASS estructural en el pipeline original: scopes/tipos,
  operadores y cadenas de receptores declarados, herencia/delegates, templates,
  valores de función acotados, hooks, lifecycle e inicialización. Los imports
  sólo enlazan entradas indexadas; datos SLK requieren jass.dataFiles explícito
  dentro de la raíz y respetan exclusiones. No ejecutar herramientas externas.
- Las proyecciones de macros/módulos conservan origen e invocación real; la fuente
  devuelta es el archivo original, no un cuerpo expandido editable. Cambiar una
  fuente JASS, el perfil o datos declarados invalida también consumidores JASS
  sin cambios de bytes. Respetar avisos y límites de trabajo/profundidad/tamaño.
- El perfil jass de codegraph.json distingue conservative (predeterminado),
  release y debug. No elegirlo por conveniencia: debe corresponder al build.
  completeInputs sólo es true cuando el conjunto indexado es una unidad completa;
  ver una library opcional en otro archivo no demuestra que se compile. Sin ese
  contexto, condiciones y destinos se conservan como candidatos/desconocidos.
- Zinc/C/cJASS, salidas de herramientas externas no indexadas, strings arbitrarios
  y aliasing/dispatch no demostrable siguen siendo fronteras explícitas. Una
  arista candidata no acredita ejecución y una arista ausente no prueba ausencia
  de consumidores. Contrastar diagnósticos/casos inciertos con JassHelper/pJASS;
  compilación y pruebas en Warcraft 1.27b siguen siendo comprobaciones separadas.
''' +s[end:]
start=s.index('- Revisión local vigente:')
end=s.index('\n## Evitar la complacencia',start)
s=s[:start]+'''- Revisión local vigente: `1.6.2+jass-vjass.4`, extracción 31, esquema 12.
  Los MCP abiertos antes de instalarla deben recargarse: reconstruir la base no
  sustituye su código en memoria. Perfil, capacidades y límites en
  `/home/snz/Documentos/MCP W3/codegraph-vjass/JASS-VJASS.md`; evidencia y revisión
  en `docs/planes/codegraph-soporte-completo-vjass.md` y
  `work/codegraph-completo-vjass-20261021/`. La adaptación A/B usa Codex y la
  política CodeGraph-first del proyecto; no acredita adopción espontánea ni
  reproduce el ensayo Claude de upstream.
''' +s[end:]
# This script is intentionally run only after .4 is installed and indexes rebuilt.
record=b/'project-instructions-preimage.json'
record.write_text(json.dumps({'path':str(p),'before_sha256':hashlib.sha256(p.read_bytes()).hexdigest()},indent=2))
(b/'AGENTS-before-v4.md').write_bytes(p.read_bytes());p.write_text(s)
print(str(p))
