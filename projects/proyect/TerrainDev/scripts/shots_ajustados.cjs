// Shifted copies of Vinz's Shots: the Stand tip lands at +radius, so a
// circle of that radius centred on the unit origin ends exactly at the tip.
// The originals in assets/shots-originales are only read.
// Usage: node scripts/shots_ajustados.cjs  (from TerrainDev)
const c = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const crypto = require('node:crypto');
const root = c.path.resolve(__dirname, '..');
const src = c.path.join(root, 'assets/shots-originales');
const out = c.path.join(root, 'assets/shots-ajustados');
// Every Vol. I (single) and Vol. II color; the Double is not used. Radius = body half-width
// (RapidFire.radiusFor): 6, 18, and 16.2 for the slimmer Vol. II Green.
const models = ['ShotsVolI', 'ShotsVolII'].flatMap(dir =>
  c.fs.readdirSync(c.path.join(src, dir)).filter(f => f.endsWith('.mdx') && !f.includes('Double')).sort().map(f => ({
    file: dir + '/' + f,
    radius: dir === 'ShotsVolI' ? 6 : f === 'Shot II Green.mdx' ? 16.2 : 18,
  })));

function standTip(m) {
  const seq = m.sequences.findIndex(s => s.name === 'Stand');
  c.assert(seq >= 0, 'No Stand sequence');
  let tip = -Infinity, back = Infinity, half = 0;
  for (const t of c.frames(m, seq, 10)) {
    const b = c.bounds(c.pose(m, seq, t).points.flat());
    tip = Math.max(tip, b.max[0]); back = Math.min(back, b.min[0]);
    half = Math.max(half, -b.min[1], b.max[1]);
  }
  return {tip, back, half};
}
function shiftExtent(e, dx) {
  e.min[0] += dx; e.max[0] += dx;
  e.boundsRadius = Math.fround(Math.hypot(...[0, 1, 2].map(i => Math.max(Math.abs(e.min[i]), Math.abs(e.max[i])))));
}

const imports = [];
for (const {file, radius} of models) {
  const m = c.read(c.path.join(src, file));
  const before = standTip(m);
  const dx = Math.fround(radius - before.tip);
  // Bone/particle animations are relative to their pivots, so moving every
  // vertex and pivot moves the whole model, emitters included.
  for (const g of m.geosets) {
    for (let i = 0; i < g.vertices.length; i += 3) g.vertices[i] += dx;
    shiftExtent(g.extent, dx);
    for (const e of g.sequenceExtents) shiftExtent(e, dx);
  }
  for (const p of m.pivotPoints) p[0] += dx;
  shiftExtent(m.extent, dx);
  for (const s of m.sequences) shiftExtent(s.extent, dx);
  const after = standTip(m);
  c.assert(Math.abs(after.tip - radius) < 0.01, `Tip ${after.tip} != ${radius}`);
  c.assert(Math.abs(after.back - before.back - dx) < 0.01 && Math.abs(after.half - before.half) < 0.01);
  const target = c.path.join(out, file.replace(/^ShotsVolII?\//, 'ShotsAjustados/'));
  c.save(m, target);
  const payload = c.fs.readFileSync(target);
  imports.push({
    internal: 'ShotsAjustados\\' + c.path.basename(target),
    file: c.path.relative(c.path.join(root, 'assets'), target),
    sha256: crypto.createHash('sha256').update(payload).digest('hex'),
    source: 'shots-originales/' + file,
    radius, shift_x: +dx.toFixed(4),
    stand_x_before: [+before.back.toFixed(2), +before.tip.toFixed(2)],
    stand_x_after: [+after.back.toFixed(2), +after.tip.toFixed(2)],
    half_width: +after.half.toFixed(2),
  });
  console.log(file, 'dx', dx.toFixed(2), 'X', after.back.toFixed(2), '..', after.tip.toFixed(2));
}
c.fs.writeFileSync(c.path.join(out, 'manifest.json'), JSON.stringify({
  author: 'Vinz (models); X shift by scripts/shots_ajustados.cjs',
  origin: 'Copies of the unmodified originals in shots-originales, translated in X only (vertices, pivots, extents) so the posed Stand tip sits at +radius. Textures come from the game MPQs.',
  imports,
}, null, 2) + '\n');
