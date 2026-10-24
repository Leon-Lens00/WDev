"""Read public author resources into local evidence; never execute downloaded code."""
from concurrent.futures import ThreadPoolExecutor
from html.parser import HTMLParser
import json
from pathlib import Path
import re
from urllib.parse import urljoin
from urllib.request import Request, urlopen

ROOT = Path('/home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower')
EVIDENCE = ROOT / 'evidencia'
BASE = 'https://www.hiveworkshop.com'
VOID = set('area base br col embed hr img input link meta param source track wbr'.split())


class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []
        self.href = None
        self.anchor = []
        self.links = []
        self.body_depth = None
        self.body_done = False
        self.body = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag not in VOID:
            self.stack.append(tag)
        if tag == 'a':
            self.href = attrs.get('href')
            self.anchor = []
        if tag == 'div' and 'bbWrapper' in attrs.get('class', '').split() and not self.body_done and self.body_depth is None:
            self.body_depth = len(self.stack)
        if self.body_depth and tag in ['br', 'div', 'pre', 'li', 'tr']:
            self.body.append('\n')

    def handle_endtag(self, tag):
        if tag == 'a' and self.href:
            self.links.append({'url': urljoin(BASE, self.href), 'title': ''.join(self.anchor).strip()})
            self.href = None
        if self.body_depth and len(self.stack) == self.body_depth and tag == 'div':
            self.body_done = True
            self.body_depth = None
        if tag in self.stack:
            index = len(self.stack) - 1 - self.stack[::-1].index(tag)
            del self.stack[index:]

    def handle_data(self, text):
        if self.href:
            self.anchor.append(text)
        if self.body_depth:
            self.body.append(text)


def fetch(resource):
    identity = re.search(r'\.(\d+)/', resource['url'])[1]
    target = EVIDENCE / f'{identity}.html'
    try:
        if not target.exists():
            with urlopen(Request(resource['url'], headers={'User-Agent': 'Mozilla/5.0'}), timeout=30) as response:
                data = response.read(8 << 20)
            target.write_bytes(data)
        parser = Page()
        parser.feed(target.read_text())
        text = ''.join(parser.body)
        (EVIDENCE / f'{identity}-descripcion.txt').write_text(text)
        relevant = [line.strip()[:240] for line in text.splitlines() if re.search(r'missile|projectile|\bhoming\b', line, re.I)]
        downloads = list({a['url']: a for a in parser.links if ('/download' in a['url'] or '/legacy-download' in a['url'] or re.search(r'/attachments/[^/]*w3[xm]', a['url']))}.values())
        return {**resource, 'id': identity, 'description_file': str(EVIDENCE / f'{identity}-descripcion.txt'),
                'missile_mentions': relevant, 'downloads': downloads}
    except Exception as error:
        return {**resource, 'id': identity, 'error': str(error)}


if __name__ == '__main__':
    parser = Page()
    parser.feed((EVIDENCE / 'recursos-pagina-1.html').read_text())
    resources = {a['url']: a for a in parser.links if re.search(r'/threads/[^/]+\.\d+/$', a['url']) and a['title'] and not any(s in a['url'] for s in ['contact-us', 'a-special-audio-message', 'interview-with-'])}
    with ThreadPoolExecutor(max_workers=3) as pool:
        records = list(pool.map(fetch, resources.values()))
    (ROOT / 'recursos-del-perfil.json').write_text(json.dumps(records, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps([{'title': r['title'], 'id': r['id'], 'missile_mentions': r.get('missile_mentions', [])[:4], 'downloads': len(r.get('downloads', [])), 'error': r.get('error')} for r in records], indent=2, ensure_ascii=False))
