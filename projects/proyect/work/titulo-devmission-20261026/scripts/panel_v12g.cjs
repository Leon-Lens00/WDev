// Dev Mission v12g (30/10/2026): one hero life bar for everyone, the character's icon as a piece of its own.
// HealthHero.mdx keeps frame and life only. Each icon is that model's fourth quad, alone, with one sequence: same bone,
// same place, so the two line up when both units stand at the same screen point.
// Usage: node panel_v12g.cjs HealthHero.mdx OUT_DIR
const path = require('path');
const { read, save } = require('../../../ModelEditor/src/model.cjs');

const ICON_GEOSET = 3;
const ICONS = [['HealthIconTauren', 'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'],
  ['HealthIconCairne', 'ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp']];
const [input, out] = process.argv.slice(2);

const bar = read(input);
if (bar.geosets.length !== 4 || bar.textures[ICON_GEOSET].path.indexOf('BTNHeroPaladin') < 0) throw new Error('unexpected panel');
if (bar.geosetAnimations.some(g => g.geosetId === ICON_GEOSET)) throw new Error('icon quad is animated');
bar.geosets.pop();
bar.materials.pop();
bar.textures.pop();
save(bar, path.join(out, 'HealthHero.mdx'));

for (const [name, texture] of ICONS) {
  const m = read(input);
  const g = m.geosets[ICON_GEOSET];
  g.materialId = 0;
  g.sequenceExtents = g.sequenceExtents.slice(0, 1);
  m.geosets = [g];
  m.materials = [m.materials[ICON_GEOSET]];
  m.materials[0].layers[0].textureId = 0;
  m.textures = [m.textures[ICON_GEOSET]];
  m.textures[0].path = texture;
  m.textureAnimations = [];
  m.geosetAnimations = [];
  m.bones = [m.bones[0]];
  m.pivotPoints = [m.pivotPoints[0]];
  m.sequences = [m.sequences[0]];
  m.sequences[0].name = 'Stand';
  m.name = name;
  save(m, path.join(out, name + '.mdx'));
}
console.log('ok', ICONS.map(i => i[0]).join(' '));
