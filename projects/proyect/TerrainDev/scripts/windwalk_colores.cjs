// Windwalk (Vinz) for every missile color, so the feet effect matches the bolt.
// The palette follows the Firebrand family (nine colors; RapidBolt.firebrandColor):
// each target is the key light color of the matching unmodified Firebrand Shot.
// Blue, Green and Orange reuse Vinz's own Blue Soul, Necro Soul and Fire unchanged.
// The other six come from Blue Soul with the ModelEditor gradient tint (neutral part
// kept, chroma moved to the target hue). Blue Soul draws its ribbons and ghost
// particles with the stock Ghost2.blp, which is itself blue, so each new color
// also gets its own recolored Ghost2 (scripts/windwalk_texturas.py).
// Usage (from TerrainDev): node scripts/windwalk_colores.cjs palette
//   then plot-env python -I scripts/windwalk_texturas.py, then node ... build
const c = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const {gradientTint} = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/tint-gradient.cjs');
const crypto = require('node:crypto');
const root = c.path.resolve(__dirname, '..');
const src = c.path.join(root, 'assets/windwalk-originales');
const out = c.path.join(root, 'assets/windwalk-colores');
const firebrand = c.path.join(root, 'assets/firebrand-shots/FirebrandShots');
const sha = file => crypto.createHash('sha256').update(c.fs.readFileSync(file)).digest('hex');
const ORIGINALS = {
  'Windwalk/Windwalk.mdx': '1826d0a6c997bd519a286ff493a78b864cdc7b3f87e7ed5b74e11811c9353f01',
  'Windwalk/Windwalk Blood.mdx': '57a3e3c6b965d7b2adcb5ea144a1b705508e2b9dcb630cf9551ec9c49e1ec000',
  'Windwalk/Windwalk Blue Soul.mdx': 'cd16180f2cfe846b8cd5f606d2d9d04319338c8d4e1e9f270df19b5aaacebfe9',
  'Windwalk/Windwalk Fire.mdx': 'fd5a0ed17db3a15001d49403e8ed23a133a96724252f561efdf6ad175463f05a',
  'Windwalk/Windwalk Necro Soul.mdx': '450af49839f45ad2dff80506dcc5331065b35e9d81ea7f4bd840bba86c593d79',
  'Textures/Ghost2.blp': '0225ffcefdfe95fd308cf12881b142cd8a1656dbfc282748a73a01d82987c18c',
};
const REUSED = {Blue: 'Windwalk Blue Soul.mdx', Green: 'Windwalk Necro Soul.mdx', Orange: 'Windwalk Fire.mdx'};
const COLORS = ['Red', 'Blue', 'Teal', 'Purple', 'Yellow', 'Orange', 'Green', 'Pink', 'Silver'];
const BASE = 'Windwalk Blue Soul.mdx';
const GHOST = 'Textures\\Ghost2.blp';

function checkOriginals() {
  for (const [file, hash] of Object.entries(ORIGINALS)) c.assert.equal(sha(c.path.join(src, file)), hash, file);
}
function palette() {
  checkOriginals();
  const colors = COLORS.map(name => {
    const m = c.read(c.path.join(firebrand, `Firebrand Shot ${name}.mdx`));
    c.assert.equal(m.lights.length, 1);
    const rgb = Array.from(m.lights[0].color, x => Math.round(x * 255));
    return {name, rgb, source: `firebrand-shots/FirebrandShots/Firebrand Shot ${name}.mdx (Lite color)`,
      reused: REUSED[name] || null};
  });
  c.fs.mkdirSync(out, {recursive: true});
  c.fs.writeFileSync(c.path.join(out, 'palette.json'), JSON.stringify(colors, null, 2) + '\n');
  console.log(colors.map(x => x.name + ' ' + x.rgb.join(',')).join(' | '));
}
function build() {
  checkOriginals();
  const colors = JSON.parse(c.fs.readFileSync(c.path.join(out, 'palette.json')));
  const textures = JSON.parse(c.fs.readFileSync(c.path.join(out, 'textures.json')));
  const folder = c.path.join(out, 'Windwalk');
  const imports = [];
  for (const color of colors) {
    const target = c.path.join(folder, `Windwalk ${color.name}.mdx`);
    if (color.reused) {
      c.fs.copyFileSync(c.path.join(src, 'Windwalk', color.reused), target);
    } else {
      const m = c.read(c.path.join(src, 'Windwalk', BASE));
      // index 2 is any non-Blue value: Blue keeps its source fields in gradientTint.
      const tint = s => gradientTint(s, color.rgb, 2);
      for (const e of m.particleEmitters2) e.segmentColors = e.segmentColors.map(tint);
      for (const r of m.ribbonEmitters) {
        c.assert(!r.animations.some(a => a.name === 'KRCO'));
        r.color = tint(r.color);
      }
      for (const l of m.lights) {
        c.assert(!l.animations.some(a => ['KLAC', 'KLBC'].includes(a.name)));
        l.color = tint(l.color);
        l.ambientColor = tint(l.ambientColor);
      }
      for (const g of m.geosetAnimations) {
        c.assert(!g.animations.some(a => a.name === 'KGAC'));
        g.color = tint(g.color);
      }
      const ghost = m.textures.filter(t => t.path === GHOST);
      c.assert.equal(ghost.length, 1);
      const texture = textures.find(t => t.name === color.name);
      c.assert(texture && sha(c.path.join(out, texture.file)) === texture.sha256, `Missing texture for ${color.name}`);
      ghost[0].path = texture.internal;
      c.save(m, target);
      imports.push({internal: texture.internal, file: c.path.join('windwalk-colores', texture.file), sha256: texture.sha256, source: 'windwalk-originales/' + texture.source});
    }
    imports.push({internal: `Windwalk\\Windwalk ${color.name}.mdx`, file: c.path.relative(c.path.join(root, 'assets'), target),
      sha256: sha(target), source: 'windwalk-originales/Windwalk/' + (color.reused || BASE),
      method: color.reused ? 'unmodified copy' : 'gradient tint to ' + color.rgb.join(',') + '; Ghost2 replaced'});
    console.log(color.name, color.reused ? 'copy of ' + color.reused : 'tinted', sha(target).slice(0, 12));
  }
  c.fs.writeFileSync(c.path.join(out, 'manifest.json'), JSON.stringify({
    author: 'Vinz (Windwalk); colors by scripts/windwalk_colores.cjs',
    origin: 'Unmodified Windwalk originals in windwalk-originales. Blue/Green/Orange are byte copies; the rest are Blue Soul with tinted particle, ribbon and light colors and a recolored Ghost2. Everything else (geometry, timing, sizes, filters, alpha) is unchanged.',
    imports,
  }, null, 2) + '\n');
}
if (process.argv[2] === 'palette') palette();
else if (process.argv[2] === 'build') build();
else throw new Error('Usage: windwalk_colores.cjs palette|build');
