// Linterna.mdx, vista cenital: un cuadro aditivo a 120 de altura con el abanico de LinternaHaz.blp (de linterna_haz.py)
// y cuatro luces omni cálidas a lo largo del haz. +X es el frente de la unidad; se pega en "origin" y sigue su giro.
// Cuadro sin sombra ni niebla, por las dos caras y sin probar ni escribir profundidad: ninguna loma lo corta.
// Sin «haz» (desde la petición de Leon del 06/11) sólo quedan las luces: un círculo en el héroe y tres que se ensanchan.
// Uso: node linterna.cjs SALIDA.mdx [haz]
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [salida, conHaz] = process.argv.slice(2);
const HAZ = conHaz === 'haz';
const L = 1400, W = 700, Z = 120;
// [x, y, intensidad, inicio, fin, intensidad ambiental] de cada luz.
const LUCES = HAZ ? [[250, 0, 3, 60, 400], [550, 0, 3, 100, 550], [850, 0, 3, 150, 650], [1150, 0, 2.5, 150, 650]]
  // Valores de FlashLightBeamMax.mdx (OVOgenez, xgm.guru/p/wc3/212665): atenuación 3..8 e intensidad ambiental alta,
  // que es la que alumbra a las unidades. Repartidas en cono ancho (dibujo de Leon del 06/11): círculo en el héroe y
  // filas que se abren hasta ±480 a 1200 de distancia, unos 22° a cada lado.
  : [[0, 0, 4, 3, 4, 2], [300, 0, 6, 5, 6, 5],
     [600, -170, 8, 7, 8, 6], [600, 170, 8, 7, 8, 6],
     [900, -330, 8, 7, 8, 6], [900, 0, 8, 7, 8, 6], [900, 330, 8, 7, 8, 6],
     [1200, -480, 8, 7, 8, 6], [1200, 0, 8, 7, 8, 6], [1200, 480, 8, 7, 8, 6]];
const luz = (l, i) => `Light "Linterna${i + 1}" {
	ObjectId ${i + HAZ},
	Omnidirectional,
	static AttenuationStart ${l[3]},
	static AttenuationEnd ${l[4]},
	static Intensity ${l[2]},
	static Color { 0.7, 0.9, 1 },
	static AmbIntensity ${l[5] || 0},
	static AmbColor { 1, 1, 1 },
}
`;
const ext = `MinimumExtent { 0, -${W}, 0 },
		MaximumExtent { ${L}, ${W}, 100 },
		BoundsRadius ${L},`;
const mdl = `Version {
	FormatVersion 800,
}
Model "Linterna" {
	BlendTime 150,
	${ext}
}
Sequences 1 {
	Anim "Stand" {
		Interval { 0, 1000 },
		${ext}
	}
}
${HAZ ? `Textures 1 {
	Bitmap {
		Image "war3mapImported\\LinternaHaz.blp",
	}
}
Materials 1 {
	Material {
		Layer {
			FilterMode Additive,
			Unshaded,
			Unfogged,
			TwoSided,
			NoDepthTest,
			NoDepthSet,
			static TextureID 0,
		}
	}
}
Geoset {
	Vertices 4 {
		{ 0, -${W}, ${Z} },
		{ ${L}, -${W}, ${Z} },
		{ ${L}, ${W}, ${Z} },
		{ 0, ${W}, ${Z} },
	}
	Normals 4 {
		{ 0, 0, 1 },
		{ 0, 0, 1 },
		{ 0, 0, 1 },
		{ 0, 0, 1 },
	}
	TVertices 4 {
		{ 0, 0 },
		{ 1, 0 },
		{ 1, 1 },
		{ 0, 1 },
	}
	VertexGroup {
		0,
		0,
		0,
		0,
	}
	Faces 1 6 {
		Triangles {
			{ 0, 1, 2, 0, 2, 3 },
		}
	}
	Groups 1 1 {
		Matrices { 0 },
	}
	${ext}
	Anim {
		${ext}
	}
	MaterialID 0,
	SelectionGroup 0,
}
Bone "Haz" {
	ObjectId 0,
	GeosetId 0,
	GeosetAnimId None,
}
` : ''}${LUCES.map(luz).join('')}PivotPoints ${HAZ + LUCES.length} {
${HAZ ? '\t{ 0, 0, 0 },\n' : ''}${LUCES.map(l => `	{ ${l[0]}, ${l[1]}, 60 },\n`).join('')}}
`;
const m = new M.Model(); m.loadMdl(mdl);
M.assert.equal(m.lights.length, LUCES.length); M.assert.equal(m.geosets.length, +HAZ); M.assert.equal(m.bones.length, +HAZ);
for (const l of m.lights) l.intensity = Math.fround(l.intensity);
const r = M.save(m, salida);
console.log(JSON.stringify({geosets: r.geosets.length,
  luces: r.lights.map(l => [l.name, l.objectId, l.type, l.intensity, Array.from(l.attenuation)]), pivotes: r.pivotPoints.length,
  texturas: r.textures.length}));
