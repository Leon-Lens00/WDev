"""Finalize the downloaded reference catalog without changing the original maps."""
from pathlib import Path
import hashlib
import json
import re

B = Path('/home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower')
W = Path('/home/snz/Documentos/ChatGPT/Proyect/work/bpower-misiles-20261020')
manifest = json.loads((B/'manifest.json').read_text())
analysis = json.loads((B/'analisis.json').read_text())
reference = json.loads((B/'bibliotecas/procedencia.json').read_text())
normalize = lambda s: '\n'.join(s.splitlines()).strip() + '\n'
core = normalize((B/reference['file']).read_text())
reference['normalized_sha256'] = hashlib.sha256(core.encode()).hexdigest()
reference['identical_map_sources_after_editor_header_and_line_ending_normalization'] = []
for a in analysis:
    versions = []
    for block in a['blocks']:
        s = (B/block['file']).read_text()
        block['missile_version'] = re.findall(r'library\s+Missile\s*/\*\s*(?:version\s+|v)([\d.]+)', s)
        if '// Name: Missile' in s and not block['missile_version']:
            block['missile_version'] = re.findall(r'^// Version:\s*([\d.]+)', s, re.M)
        versions += block['missile_version']
        assert hashlib.sha256((B/block['file']).read_bytes()).hexdigest() == block['sha256']
        if '2.5.1' in block['missile_version']:
            assert normalize(s[s.index('library Missile'):]) == core
            reference['identical_map_sources_after_editor_header_and_line_ending_normalization'].append(block['file'])
    a['missile_versions'] = versions
    a['core_flavor'] = 'JASS/GUI' if a['resource_id'] == '275718' else 'vJASS'
    a['pjass_log'] = str(W/f"{a['resource_id']}-pjass.log")
    a['verification_date'] = '2026-10-20'
    a['embedded_script_sha256'] = hashlib.sha256((B/'extraidos'/a['resource_id']/'war3map.j').read_bytes()).hexdigest()
    m = next(m for m in manifest['maps'] if m['resource_id'] == a['resource_id'])
    assert hashlib.sha256((B/m['file']).read_bytes()).hexdigest() == m['sha256']
    assert hashlib.sha256((B/m['package_file']).read_bytes()).hexdigest() == m['package_sha256']
    m['selection_evidence'] = ('Core JASS/GUI Missile recovered from WCT.' if a['core_flavor']=='JASS/GUI'
        else 'Missile library and consumer code recovered from WCT; explicit resource dependency.')
    m['missile_version'] = versions[0]
    m['core_flavor'] = a['core_flavor']
    m['verification'] = {k: a[k] for k in ['embedded_jass_pjass_exit','vjass_recompiled','game_tested','original_hash_unchanged','wct_recovered_blocks']}
manifest['reference_library'] = reference
manifest['toolchain_record'] = str(W/'toolchain.json')
manifest['coverage'] = {'maps_downloaded':len(analysis),'embedded_jass_scripts_checked':len(analysis),
 'wct_nonempty_blocks_recovered':sum(a['wct_recovered_blocks'] for a in analysis),'embedded_jass_pass':sum(a['embedded_jass_pjass_exit']==0 for a in analysis),
 'embedded_jass_fail':sum(a['embedded_jass_pjass_exit']!=0 for a in analysis),'editable_sources_recompiled':0,'game_tests':0}
for p, d in [(B/'manifest.json',manifest),(B/'analisis.json',analysis),(B/'bibliotecas/procedencia.json',reference)]:
    p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')

def link(label,p): return f'[{label}](<{p}>)'
lines=['# Mapas de referencia: misiles de BPower','',
 'Categoría: **Warcraft III → Misiles → BPower**. Descarga y revisión: 20 de octubre de 2026.', '',
 '[Perfil del autor](https://www.hiveworkshop.com/members/bpower.216087/#resources). Se revisaron sus 23 recursos y se descargaron cinco mapas con uso explícito y código de Missile recuperado.', '',
 'La referencia principal indicada por el usuario es [Missile de BPower](https://www.hiveworkshop.com/threads/missile.265370/): el bloque principal declara **2.5.1**. '+link('Fuente local del hilo', B/reference['file'])+'; '+link('procedencia y hashes', B/'bibliotecas/procedencia.json')+'. Coincide con el núcleo de Armageddon y Frozen Orb tras normalizar saltos de línea y quitar cabeceras del editor. Esta copia viene del código del hilo, no de un sexto mapa.', '',
 '| Mapa original | Missile incluido | pJASS del JASS embebido | Ejemplo útil |','|---|---|---|---|']
uses={'275718':'Eventos y configuración GUI; API diferente de vJASS.', '258518':'Emisor con varias cabezas y tipos de proyectil; referencia histórica.', '245470':'Lluvia de meteoros; emisor, tiempo de vuelo y explosión.', '245192':'Fireball, ChaoticBoulder, BoneSpirit, Leap, FistOfThunder y GuidedArrow usan Missile.', '243397':'Proyectil padre, emisión periódica y ráfaga radial al retirarse.'}
for m in manifest['maps']:
    v=m['verification'];state='PASS' if v['embedded_jass_pjass_exit']==0 else '**FAIL: 2 errores**'
    lines.append(f"| {link(m['title'],B/m['file'])} ([Hive]({m['source_url']})) | {m['core_flavor']} {m['missile_version']} | {state} | {uses[m['resource_id']]} |")
lines += ['', '## Alcance de la comprobación','',
 'Los cinco mapas originales y sus ZIP se conservaron sin cambios, con SHA-256. Se extrajeron cinco `war3map.j` y 59 bloques WCT no vacíos (4, 15, 8, 24 y 8 respectivamente). Todos los WCT son versión 1, sin bytes finales sin consumir. Los cinco W3I son versión 25 y W3E versión 11; esto acredita formato, no funcionamiento completo en 1.27b.', '',
 'pJASS se ejecutó sobre los cinco scripts ya compilados que venían dentro de los mapas, con los `common.j` y `Blizzard.j` locales de Classic 1.27b. Cuatro pasan. Hydra falla por `ndist` y `bdist` usados sin inicializar, en las líneas 2215 y 2221 de su JASS embebido. Se conserva intacto; no se ha demostrado qué efecto tendría en partida.', '',
 'No se recompilaron las fuentes vJASS recuperadas ni la copia independiente del núcleo. No se abrieron los mapas en el editor ni se probaron en juego o multijugador. El PASS de pJASS no acredita esas etapas. La edición GUI aparece en Hive como “Awaiting update”.', '',
 '## Selección y organización','',
 'Se seleccionaron los recursos por su biblioteca y consumidores, no por encontrar “Missile” en una ruta de modelo. Traps y Meat Hook tienen menciones de modelos; Townportal menciona MissileRecycler, que es otro componente. No se incluyeron como mapas que usan esta biblioteca. Tampoco todos los hechizos de Simple Spell Collection la usan: IceSiege y Chaosflare, por ejemplo, no usan el núcleo Missile.', '',
 '- `mapas/`: originales W3X. `paquetes/`: ZIP originales de Hive.',
 '- `fuentes/<id>/`: bloques WCT decodificados a UTF-8, numerados por índice; no forman automáticamente un único archivo compilable. Los triggers GUI y objetos requieren también WTG/W3A/W3U e imports.',
 '- `extraidos/<id>/`: miembros seleccionados del MPQ y WCT decodificado; no es un desempaquetado completo.',
 '- `bibliotecas/`: fuente de Missile 2.5.1 del hilo indicado y procedencia.',
 '- `evidencia/`: páginas y descripciones observadas, separadas del código.', '',
 link('Manifiesto con hashes',B/'manifest.json')+' · '+link('Análisis por mapa y bloque',B/'analisis.json')+' · '+link('Registro de herramientas',W/'toolchain.json')+' · '+link('Errores de Hydra',W/'258518-pjass.log'), '',
 'Para diseñar nuevas habilidades: '+link('crear-misiles-warcraft3-127b',Path('/home/snz/.codex/skills/crear-misiles-warcraft3-127b/SKILL.md'))+'. Mantener la atribución a BPower y las cabeceras/créditos de las bibliotecas y recursos reutilizados.', '']
(B/'CATALOGO.md').write_text('\n'.join(lines))
index=B.parents[2]/'INDICE.md'
# Only create our new download index; preserve any future manually maintained index.
if not index.exists(): index.write_text('# Descargas del proyecto\n\n- Warcraft III → Misiles → '+link('BPower: mapas y biblioteca Missile',B/'CATALOGO.md')+'\n')
print(json.dumps(manifest['coverage'],ensure_ascii=False));print('Original/package/source hashes checked; two cores match the reference.')
