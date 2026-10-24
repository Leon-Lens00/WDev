"""Separate BLP1 candidates: promote the existing mip or resample to 512 square.

Run with the existing Pillow runtime; never writes active map/UI resources.
The only UI copy is a standalone comparison subdirectory.
"""
from pathlib import Path
import hashlib, json, math, shutil, struct, sys
from PIL import Image
import textures

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'exports/panel-textures-512'
EVIDENCE = ROOT / 'evidence/panel-textures-512'
PUBLIC = textures.ART.parent.parent / 'panel-texture-review'
NAMES = ('FrameOpenRed.blp', 'FrameOpenBlue.blp')
digest = lambda data: hashlib.sha256(data).hexdigest()

def parse(data):
    assert data[:4] == b'BLP1' and len(data) >= 1180
    content, alpha, width, height, kind, subtype = struct.unpack_from('<6I', data, 4)
    assert (content, alpha, kind, subtype) == (1, 8, 4, 1), 'Outside verified palette/alpha contract'
    assert all(n > 0 and n & (n-1) == 0 for n in (width, height))
    offsets = struct.unpack_from('<16I', data, 28)
    sizes = struct.unpack_from('<16I', data, 92)
    levels = []; cursor = 1180
    for level in range(int(math.log2(max(width, height))) + 1):
        w, h = max(1, width >> level), max(1, height >> level)
        offset, size = offsets[level], sizes[level]
        assert offset == cursor and size == 2*w*h and offset+size <= len(data)
        levels.append((w, h, data[offset:offset+size])); cursor += size
    assert cursor == len(data) and levels[-1][:2] == (1, 1)
    assert not any(offsets[len(levels):]) and not any(sizes[len(levels):])
    return dict(width=width, height=height, palette=data[156:1180], levels=levels)

def rgba(parsed, level):
    w, h, payload = parsed['levels'][level]; count = w*h; p = parsed['palette']
    pixels = bytearray(count*4)
    for i, index in enumerate(payload[:count]):
        b, g, r, _ = p[index*4:index*4+4]
        pixels[i*4:i*4+4] = bytes((r, g, b, payload[count+i]))
    return Image.frombytes('RGBA', (w, h), bytes(pixels))

def promote(data, first=1):
    source = parse(data); levels = source['levels'][first:]
    assert levels and max(levels[0][:2]) <= 512
    header = bytearray(data[:28]); struct.pack_into('<2I', header, 12, *levels[0][:2])
    offsets = []; sizes = []; cursor = 1180
    for _, _, payload in levels:
        offsets.append(cursor); sizes.append(len(payload)); cursor += len(payload)
    return bytes(header) + struct.pack('<16I', *(offsets+[0]*(16-len(offsets)))) + struct.pack('<16I', *(sizes+[0]*(16-len(sizes)))) + source['palette'] + b''.join(v[2] for v in levels)

def run():
    OUT.mkdir(parents=True, exist_ok=True); EVIDENCE.mkdir(parents=True, exist_ok=True)
    images = OUT / 'preview'; images.mkdir(exist_ok=True)
    manifest = dict(target='Classic 1.27b / BLP1', activeChanged=False, nativeTested=False, modelsChanged=False, textures=[])
    for name in NAMES:
        source = ROOT/'assets/UI/Dialogue'/name; data = source.read_bytes(); parsed = parse(data)
        assert (parsed['width'], parsed['height']) == (1024, 512)
        baseline = EVIDENCE/'baseline'/name; baseline.parent.mkdir(exist_ok=True)
        if baseline.exists(): assert baseline.read_bytes() == data
        else: baseline.write_bytes(data)
        candidate = promote(data); out = OUT/'512x256/UI/Dialogue'/name; out.parent.mkdir(parents=True, exist_ok=True); out.write_bytes(candidate)
        after = parse(candidate); assert after['palette'] == parsed['palette']
        assert after['levels'] == parsed['levels'][1:]
        for level in range(len(after['levels'])):
            assert rgba(after, level).tobytes() == rgba(parsed, level+1).tobytes()
        rgba(parsed, 0).save(images/(name+'.original.png'))
        rgba(parsed, 1).save(images/(name+'.mip1.png'))
        rgba(after, 0).save(images/(name+'.512x256.png'))
        # Square alternative keeps the same normalized UVs, with more vertical samples.
        square = rgba(parsed, 0).resize((512,512), Image.Resampling.LANCZOS)
        square_out = OUT/'512x512/UI/Dialogue'; square_out.mkdir(parents=True, exist_ok=True)
        textures.OUT = square_out
        textures.blp(square, name)
        square_data = (square_out/name).read_bytes(); square_parsed = parse(square_data)
        rgba(square_parsed, 0).save(images/(name+'.512x512.png'))
        assert source.read_bytes() == data
        manifest['textures'].append(dict(name=name, source=str(source), sourceSha256=digest(data), beforeBytes=len(data), candidates=[dict(size='512x256', path=str(out), bytes=len(candidate), sha256=digest(candidate), mipPayloadsIdentical=True),dict(size='512x512', path=str(square_out/name), bytes=len(square_data), sha256=digest(square_data), mipPayloadsIdentical=False)]))
    html = '''<!doctype html><meta charset="utf-8"><title>Panel · texturas 512</title>
<style>body{margin:0;background:#101722;color:#e7edf4;font:16px system-ui}main{max-width:1450px;margin:auto;padding:24px}h1{margin:0 0 12px}label{display:inline-block;margin:12px}select,button{font:inherit;padding:8px;background:#273b50;color:white;border:1px solid #718398;border-radius:6px}.view{width:100%;aspect-ratio:140/58.32132;background:repeating-conic-gradient(#35404b 0% 25%,#222a33 0% 50%) 0 0/24px 24px;position:relative}.view img{width:100%;height:100%;object-fit:fill;position:absolute;inset:0}.view .candidate{clip-path:inset(0 0 0 var(--split,50%))}input{width:100%;margin:16px 0}p{color:#bbc8d8;line-height:1.5}output{font-weight:bold}.legend{display:flex;justify-content:space-between;margin:10px 0}</style>
<main><h1>Panel · comparación de texturas</h1><p>Vista plana con la proporción del MDX. Izquierda:referencia elegida. Derecha:candidata. El deslizador permite comparar el mismo borde. El mip1 ya existe en el archivo actual y sirve como referencia del límite documentado de Classic; no mide el nivel elegido por RenderEdge. El filtro del navegador aproxima el aspecto; no acredita reproducción nativa.</p>
<label>Color <select id="color"><option value="Red">Rojo</option><option value="Blue">Azul</option></select></label>
<label>Referencia <select id="reference"><option value="original">Archivo actual · 1024×512</option><option value="mip1">Mip1 actual · 512×256</option></select></label>
<label>Textura candidata <select id="size"><option>512x256</option><option>512x512</option></select></label>
<button id="left">Sólo actual</button> <button id="middle">Comparar</button> <button id="right">Sólo candidata</button>
<div class="legend"><span>Actual:1.399.282bytes</span><output id="metric"></output></div>
<div class="view" id="view"><img id="original" alt="Textura actual del panel"><img class="candidate" id="candidate" alt="Textura candidata del panel"></div>
<label style="display:block">División de la comparación<input id="split" type="range" min="0" max="100" value="50"></label>
<p>512×256:350.706bytes,−74,9%. Es exactamente el mip1 del archivo actual, incluidos alfa y paleta; conserva todos los niveles menores. 512×512:700.230bytes,−50,0%; remuestreo con mayor resolución vertical. El MDX, UV, cámaras, animaciones y textos permanecen iguales. El texto del diálogo se dibuja por separado y no pierde resolución al cambiar estas texturas.</p>
<script>const $=s=>document.getElementById(s);function paint(){const name='FrameOpen'+$('color').value+'.blp';$('original').src='preview/'+name+'.'+$('reference').value+'.png';$('candidate').src='preview/'+name+'.'+$('size').value+'.png';$('view').style.setProperty('--split',$('split').value+'%');$('metric').textContent=$('size').value==='512x256'?'Candidata:350.706bytes':'Candidata:700.230bytes'}$('reference').onchange=$('color').onchange=$('size').onchange=$('split').oninput=paint;$('left').onclick=()=>{$('split').value=100;paint()};$('middle').onclick=()=>{$('split').value=50;paint()};$('right').onclick=()=>{$('split').value=0;paint()};paint();</script></main>'''
    (OUT/'index.html').write_text(html)
    PUBLIC.mkdir(parents=True, exist_ok=True); shutil.copy2(OUT/'index.html', PUBLIC/'index.html'); shutil.copytree(images, PUBLIC/'preview', dirs_exist_ok=True)
    (EVIDENCE/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(manifest, indent=2))

if __name__ == '__main__': run()
