"""Build a navigable, offline proposal atlas from biome-discover records.

Does not approve candidates. Existing manually reviewed images stay distinct.
"""
from pathlib import Path
import argparse, collections, html, json, math

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('discovery',type=Path)
    a=ap.parse_args(); root=a.discovery.resolve()
    read=lambda n:json.loads((root/n).read_text(encoding='utf-8-sig'))
    items=read('inventory.json'); candidates=read('candidates.json')
    byid={o['id']:o for o in items}; counts=collections.Counter(o['rawcode'] for o in items)
    proposals=[]
    for c in candidates:
        anchor=byid[c['anchors'][0]]; xy=anchor['xy']
        for radius in [128,384,768]:
            members=[o for o in items if math.dist(o['xy'],xy)<=radius]
            edge=[o['id'] for o in members if math.dist(o['xy'],xy)>radius-128]
            proposals.append(dict(id=f"{c['id']}-r{radius}",anchor=anchor['id'],radius=radius,
                bounds={'min':[v-radius for v in xy],'max':[v+radius for v in xy]},
                members=[o['id'] for o in members],border_members=edge,
                alert='possible truncated context; inspect larger window' if edge else '',
                rare=counts[anchor['rawcode']]<=25,status='proposal; not approved',
                confidence='spatial only; no semantic confidence'))
    (root/'multiscale-proposals.json').write_text(json.dumps(proposals,indent=2)+'\n')
    esc=html.escape
    cards=[]
    for family,n in sorted(counts.items()):
        sample=next(o for o in items if o['rawcode']==family)
        link=f'family-visual/family-{family}.png'
        cards.append(f'<article id="{family}"><h2>{family} Â· {n} objetos</h2><a href="{link}"><img loading="lazy" src="{link}"></a><p>{esc(sample["model"])}</p><p>{"Cola de familias raras" if n<=25 else "Familia abundante: consultar sectores"}</p></article>')
    sectors=''.join(f'<a href="sector-visual/sector-{y}-{x}.png"><img loading="lazy" src="sector-visual/sector-{y}-{x}.png" alt="Sector {y},{x}"></a>' for y in range(4,0,-1) for x in range(1,5))
    rows=''.join(f'<tr><td>{esc(p["id"])}</td><td>{p["anchor"]}</td><td>{len(p["members"])}</td><td>{len(p["border_members"])}</td><td>{esc(p["alert"])}</td></tr>' for p in proposals)
    doc=f'''<!doctype html><meta charset="utf-8"><title>Atlas de incorporación</title><style>body{{font:16px system-ui;background:#16231d;color:#edf1eb;margin:32px}}a{{color:#b7e7ce}}img{{max-width:100%}}.grid{{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}}.families{{display:grid;grid-template-columns:repeat(2,1fr);gap:24px}}td,th{{text-align:left;border-bottom:1px solid #52675b;padding:8px}}article{{min-width:0}}p{{overflow-wrap:anywhere}}</style><h1>Atlas de incorporaciÃ³n Â· Ashenvale</h1><p>{len(items)} objetos inventariados. Las propuestas espaciales no son aprobaciones. La pertenencia autorizada estÃ¡ en review-v2.json y la biblioteca; una imagen general no revisa cada objeto individual.</p><p><a href="review-v2.json">RevisiÃ³n manual e imÃ¡genes examinadas</a> Â· <a href="inventory.json">Inventario con coordenadas y recursos</a> Â· <a href="multiscale-proposals.json">Miembros y recortes multiescala</a></p><h2>Plano por sectores</h2><div class="grid">{sectors}</div><h2>Familias y detalles pequeÃ±os</h2><div class="families">{''.join(cards)}</div><h2>Propuestas y alertas de borde</h2><p>Radios 128, 384 y 768 unidades WC3. Borde: anillo exterior de128; alerta conservadora de posible contexto cortado, no detector de templos. Revisar la ventana mayor antes de decidir miembros.</p><table><thead><tr><th>Propuesta</th><th>Ancla</th><th>Miembros</th><th>En borde</th><th>Alerta</th></tr></thead><tbody>{rows}</tbody></table>'''
    (root/'index.html').write_text(doc,encoding='utf-8')
    print(len(proposals),'proposals; no approvals created')

if __name__=='__main__': main()
