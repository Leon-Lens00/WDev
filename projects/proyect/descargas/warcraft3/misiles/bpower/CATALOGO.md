# Mapas de referencia: misiles de BPower

Categoría: **Warcraft III → Misiles → BPower**. Descarga y revisión: 20 de octubre de 2026.

[Perfil del autor](https://www.hiveworkshop.com/members/bpower.216087/#resources). Se revisaron sus 23 recursos y se descargaron cinco mapas con uso explícito y código de Missile recuperado.

La referencia principal indicada por el usuario es [Missile de BPower](https://www.hiveworkshop.com/threads/missile.265370/): el bloque principal declara **2.5.1**. [Fuente local del hilo](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/bibliotecas/Missile-BPower-2.5.1-hive.j>); [procedencia y hashes](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/bibliotecas/procedencia.json>). Coincide con el núcleo de Armageddon y Frozen Orb tras normalizar saltos de línea y quitar cabeceras del editor. Esta copia viene del código del hilo, no de un sexto mapa.

| Mapa original | Missile incluido | pJASS del JASS embebido | Ejemplo útil |
|---|---|---|---|
| [Missile [GUI] version 1.6.1](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/mapas/275718-missile-gui/Missile GUI.w3x>) ([Hive](https://www.hiveworkshop.com/threads/missile-gui-version-1-6-1.275718/)) | JASS/GUI 1.6.1 | PASS | Eventos y configuración GUI; API diferente de vJASS. |
| [Hydra v4.2](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/mapas/258518-hydra/Hydra.w3x>) ([Hive](https://www.hiveworkshop.com/threads/hydra-v4-2.258518/)) | vJASS 1.4 | **FAIL: 2 errores** | Emisor con varias cabezas y tipos de proyectil; referencia histórica. |
| [Armageddon v.2.4.1](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/mapas/245470-armageddon/Armageddon.w3x>) ([Hive](https://www.hiveworkshop.com/threads/armageddon-v-2-4-1.245470/)) | vJASS 2.5.1 | PASS | Lluvia de meteoros; emisor, tiempo de vuelo y explosión. |
| [Simple Spell Collection#1 v.2.0](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/mapas/245192-simple-spell-collection/Simple Spell Collection #1.w3x>) ([Hive](https://www.hiveworkshop.com/threads/simple-spell-collection-1-v-2-0.245192/)) | vJASS 2.0.2 | PASS | Fireball, ChaoticBoulder, BoneSpirit, Leap, FistOfThunder y GuidedArrow usan Missile. |
| [Frozen Orb v2.1](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/mapas/243397-frozen-orb/Frozen Orb.w3x>) ([Hive](https://www.hiveworkshop.com/threads/frozen-orb-v2-1.243397/)) | vJASS 2.5.1 | PASS | Proyectil padre, emisión periódica y ráfaga radial al retirarse. |

## Alcance de la comprobación

Los cinco mapas originales y sus ZIP se conservaron sin cambios, con SHA-256. Se extrajeron cinco `war3map.j` y 59 bloques WCT no vacíos (4, 15, 8, 24 y 8 respectivamente). Todos los WCT son versión 1, sin bytes finales sin consumir. Los cinco W3I son versión 25 y W3E versión 11; esto acredita formato, no funcionamiento completo en 1.27b.

pJASS se ejecutó sobre los cinco scripts ya compilados que venían dentro de los mapas, con los `common.j` y `Blizzard.j` locales de Classic 1.27b. Cuatro pasan. Hydra falla por `ndist` y `bdist` usados sin inicializar, en las líneas 2215 y 2221 de su JASS embebido. Se conserva intacto; no se ha demostrado qué efecto tendría en partida.

No se recompilaron las fuentes vJASS recuperadas ni la copia independiente del núcleo. No se abrieron los mapas en el editor ni se probaron en juego o multijugador. El PASS de pJASS no acredita esas etapas. La edición GUI aparece en Hive como “Awaiting update”.

## Selección y organización

Se seleccionaron los recursos por su biblioteca y consumidores, no por encontrar “Missile” en una ruta de modelo. Traps y Meat Hook tienen menciones de modelos; Townportal menciona MissileRecycler, que es otro componente. No se incluyeron como mapas que usan esta biblioteca. Tampoco todos los hechizos de Simple Spell Collection la usan: IceSiege y Chaosflare, por ejemplo, no usan el núcleo Missile.

- `mapas/`: originales W3X. `paquetes/`: ZIP originales de Hive.
- `fuentes/<id>/`: bloques WCT decodificados a UTF-8, numerados por índice; no forman automáticamente un único archivo compilable. Los triggers GUI y objetos requieren también WTG/W3A/W3U e imports.
- `extraidos/<id>/`: miembros seleccionados del MPQ y WCT decodificado; no es un desempaquetado completo.
- `bibliotecas/`: fuente de Missile 2.5.1 del hilo indicado y procedencia.
- `evidencia/`: páginas y descripciones observadas, separadas del código.

[Manifiesto con hashes](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/manifest.json>) · [Análisis por mapa y bloque](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/analisis.json>) · [Registro de herramientas](</home/snz/Documentos/ChatGPT/Proyect/work/bpower-misiles-20261020/toolchain.json>) · [Errores de Hydra](</home/snz/Documentos/ChatGPT/Proyect/work/bpower-misiles-20261020/258518-pjass.log>)

Para diseñar nuevas habilidades: [crear-misiles-warcraft3-127b](</home/snz/.codex/skills/crear-misiles-warcraft3-127b/SKILL.md>). Mantener la atribución a BPower y las cabeceras/créditos de las bibliotecas y recursos reutilizados.
