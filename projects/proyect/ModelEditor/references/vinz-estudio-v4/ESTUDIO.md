# Estudio Vinz para X3V4

23/10/2026.191 MDX distintos en50 paquetes del archivo descargado. Originales leídos, hashes contrastados y conservados. No son191 diseños distintos ni todos son misiles de vuelo: hay auxiliares, impactos y un bundle mixto.

## Cobertura y límites

Se recorrieron los191 modelos en visor nativo MDX, por páginas de6, y una muestra temprana de Death cuando la secuencia existe. Si no existe, el visor usa la primera secuencia; los nombres/intervalos reales están en el inventario. Las capturas muestran su tiempo efectivo: el rótulo120ms es la solicitud de muestreo y algunas instancias culled arrancan en la primera clave. No se atribuye precisión temporal uniforme a esas láminas.

178 modelos tienen resueltos sus recursos usados por materiales/PE2, incluyendo alias de texturas Classic hermanas que el paquete aporta.13 tienen dependencias ausentes y se marcan parciales: el componente no disponible usa textura transparente de diagnóstico. Las tablas UberSplatData y texturas de cráter originales se recuperaron del MPQ para revisar eventos de suelo. Sonido desactivado; no se prueban aquí ni sonido, motor1.27b de cada original, FPS o multijugador.

Datos reproducibles: `evidence/x3-v4/study/all-models.json`, `resources.json`, `atlas-resources.json`, capturas `atlas-stand/` y `atlas-death/`. El atlas local está en `viewer/vinz-study-v4/`; hashes de sus copias coinciden con originales.

## Personalidades observadas

| Paquete | Entradas | Observación visual y función |
|---|---:|---|
| [Arcade Bolts](https://www.hiveworkshop.com/threads/arcade-bolts.314822/) | 6 | Bloques luminosos y fragmentos cuadrados; el núcleo blanco se lee dentro de un contorno de píxeles de color. Identidad deliberadamente arcade, distinta de una llama suave. |
| [Firebrand Shots](https://www.hiveworkshop.com/threads/firebrand-shots.319649/) | 9 | Cabeza redonda caliente, halo amplio y gotas pequeñas detrás; impacto con salpicaduras y puntos luminosos separados. Útil para jerarquía núcleo/halo/residuo. |
| [Psionic Shots](https://www.hiveworkshop.com/threads/psionic-shots.319594/) | 9 | Quietos se ven discretos; el conjunto de ribbons es parte esencial de su lectura en recorrido. Impacto con motas separadas y remanente más oscuro. |
| [Shots Vol. I](https://www.hiveworkshop.com/threads/shots-vol-i.315258/) | 12 | Punta blanca y silueta larga afilada; variantes simples y dobles comparten lenguaje. Impacto cambia la lectura a estrellas y glóbulos. |
| [Shots Vol. II](https://www.hiveworkshop.com/threads/shots-vol-ii.315512/) | 6 | Conserva la dirección de ShotsI pero añade puntas radiales y una estrella más evidente en cabeza; fuerte contraste entre centro y rayos. |
| [Airstrike Rocket](https://www.hiveworkshop.com/threads/airstrike-rocket.314936/) | 1 | Cuerpo metálico oscuro, propulsión blanca y explosión naranja radial con anillos; el brillo acompaña al objeto sin sustituir su forma. |
| [Blood Elven Torpedo](https://www.hiveworkshop.com/threads/blood-elven-torpedo.315903/) | 1 | Casco dorado/rojo con propulsión verde; explosión verde clara. La combinación de cuerpo físico y emisión de color distingue la familia. |
| [Blood Elven Voyager](https://www.hiveworkshop.com/threads/blood-elven-voyager.312541/) | 3 | Paquete mixto: plataforma/vehículo elaborado, cohete y GunImpact. La plataforma no se clasifica como un misil pequeño. El cohete tiene dos dependencias ausentes; impacto circular separado. |
| [Cannonball](https://www.hiveworkshop.com/threads/cannonball.315873/) | 4 | Esfera negra con reflejo claro; la lectura metálica oscura contrasta con la explosión cálida, humo y marca de suelo. Rain es una variante de cronología. |
| [Chain Grenade](https://www.hiveworkshop.com/threads/chain-grenade.315385/) | 4 | Malla de cadenas/huecos oscuros rodeada de halo de color; UV animadas usadas por materiales. Impacto muy luminoso, con textura y espacio oscuro antes del estallido. |
| [Incendiary Bullets Vol. I](https://www.hiveworkshop.com/threads/incendiary-bullets-vol-i.314966/) | 6 | Centro físico oscuro abrazado por una corona de fuego de color; no todos los proyectiles necesitan un centro completamente blanco. Desaparición con estrellas dispersas. |
| [Interceptor Shell](https://www.hiveworkshop.com/threads/interceptor-shell.319609/) | 2 | Silueta de punta blindada y motor rojo; impacto distinto del residuo de Rain. Emisión y estelas no tienen el mismo papel que la malla. |
| [Runic Rocket](https://www.hiveworkshop.com/threads/runic-rocket.315223/) | 1 | Lectura cian y glifos/brillos fríos; fuerte estallido radial. El color y el perfil ornamental lo separan de los cohetes de acero. |
| [Shock Blast](https://www.hiveworkshop.com/threads/shock-blast.315459/) | 6 | Nudo energético pequeño en vuelo; al morir aparecen aros/estructuras concéntricas y cambian las capas visibles. Importa revisar visibilidad por secuencia. |
| [Tank Shells](https://www.hiveworkshop.com/threads/tank-shells.315646/) | 2 | Punta y carcasa metálicas larga y legible, dos acabados físicos y propulsión cálida; explosión de chispas con trazos radiales. |
| [Voyager Rocket](https://www.hiveworkshop.com/threads/voyager-rocket.314981/) | 1 | Aletas ornamentales doradas, carcasa roja y empuje blanco; conserva identidad física aun con efectos luminosos. |
| [Bloodstone Arrows](https://www.hiveworkshop.com/threads/bloodstone-arrows.309858/) | 4 | Flecha con rastros rojos; Bloodless y LSD cambian sangre/paleta/ornamentos. La variante tiene personalidad por elementos presentes, no sólo por RGB. |
| [Daemonic Arrow](https://www.hiveworkshop.com/threads/daemonic-arrow.337124/) | 1 | Cabeza y rastro violeta visibles; seis texturas HD usadas faltan en esta instalación. Observación parcial: no atribuir a la preview la apariencia original completa. |
| [Explosive Bolts](https://www.hiveworkshop.com/threads/explosive-bolts.351836/) | 1 | Punta cálida rodeada por un aro claro y trazos finos; combina objeto y energía circular. Impacto denso y chispeante. |
| [Fire Arrows](https://www.hiveworkshop.com/threads/fire-arrows.310448/) | 6 | Familia heterogénea: llama verde, petardo de motas rojas y punta amarilla; variantes Fireless muestran qué queda al quitar la llama. |
| [Frost Arrows](https://www.hiveworkshop.com/threads/frost-arrows.309707/) | 3 | Azul helado frente a variante descongelada y una variante de maíz; no son tres colores idénticos. El componente físico sigue siendo reconocible. |
| [HighElvenArrow](https://www.hiveworkshop.com/threads/highelvenarrow.259593/) | 1 | Flecha ornamental clara/dorada y brillo contenido; ejemplo de silueta física que no depende de un halo enorme. |
| [SilverBolts](https://www.hiveworkshop.com/threads/silverbolts.259287/) | 2 | Silver y Night comparten carácter de destello frío pero cambian el reparto blanco/azul y el ornamento de cabeza. |
| [SpiritArrow](https://www.hiveworkshop.com/threads/spiritarrow.245374/) | 1 | Forma de doble punta clara, poca emisión; la geometría lleva la identidad y la estela apoya el movimiento. |
| [BouncingBlade](https://www.hiveworkshop.com/threads/bouncingblade.258506/) | 2 | Hoja curva metálica y componente Buff independiente; la pieza auxiliar no se confunde con una segunda trayectoria de misil. |
| [BurningSpear](https://www.hiveworkshop.com/threads/burningspear.239752/) | 1 | Lanza de asta visible y punta clara; en el primer Stand se lee principalmente la forma física. No equiparar esta versión con la del bundle posterior. |
| [Halberd](https://www.hiveworkshop.com/threads/halberd.257144/) | 1 | Arma larga con cabeza de alabarda y asta oscura; alto contraste de silueta con poco efecto luminoso. |
| [JavelinToss](https://www.hiveworkshop.com/threads/javelintoss.258228/) | 1 | Jabalina física con cola cálida intensa; el pequeño objeto conserva dirección dentro de la llama. |
| [Pike](https://www.hiveworkshop.com/threads/pike.245376/) | 1 | Lanza fina y sobria, punta metálica definida; ejemplo de lectura sin exceso de partículas. |
| [Quantum Blade](https://www.hiveworkshop.com/threads/quantum-blade.245373/) | 1 | Hoja energética azul con pequeños cuerpos/glóbulos curvos agrupados; identidad de energía articulada frente a un rayo recto. |
| [RuneSpear](https://www.hiveworkshop.com/threads/runespear.261783/) | 1 | Punta fría con ornamentos y varias estelas; filamentos finos alrededor de una forma física compacta. |
| [StiflingDagger](https://www.hiveworkshop.com/threads/stiflingdagger.259671/) | 1 | Daga con nube/motas verdes; halo corto junto al arma y residuos dispersos de aspecto tóxico. |
| [SunSpear](https://www.hiveworkshop.com/threads/sunspear.236541/) | 1 | Asta y punta cálida, emisión mínima; el nombre de una familia no implica una gran bola de luz. |
| [WoodenSpear](https://www.hiveworkshop.com/threads/woodenspear.245375/) | 1 | Lanza física sencilla, madera y punta clara; referencia de proporciones y legibilidad del objeto. |
| [Blizzard II](https://www.hiveworkshop.com/threads/blizzard-ii.320476/) | 2 | Separación entre efecto de lluvia vertical y misil de hielo; cristales, chispas frías y forma puntiaguda cumplen funciones distintas. |
| [Carrion Bats (1.32)](https://www.hiveworkshop.com/threads/carrion-bats-1-32.333134/) | 6 | Silueta de murciélago oscura dentro de un brillo rojo/verde; pequeñas estelas y UV. Dos recursos líquidos HD faltan: vista parcial en las seis variantes. |
| [Deadly Plumage (1.32)](https://www.hiveworkshop.com/threads/deadly-plumage-1-32.333201/) | 3 | Siluetas de plumas y líneas finas doradas/violetas; dependencias HD ausentes impiden reconstruir toda la capa de partículas. No usar como muestra completa. |
| [Fire Missiles](https://www.hiveworkshop.com/threads/fire-missiles.313049/) | 12 | Doce componentes: flecha, creciente, spear, bolas y bolts con variantes de tamaño/rugosidad. FireCrescent tiene curva explícita; las versiones Rough usan un borde granular más irregular. |
| [Firebolt](https://www.hiveworkshop.com/threads/firebolt.340383/) | 2 | Chispa cálida compacta con muchas estelas finas. Classic aporta máscaras usadas también por la variante hermana de ruta HD; los alias se registran. |
| [Frost Bolt](https://www.hiveworkshop.com/threads/frost-bolt.352867/) | 2 | Punto frío y cristales frente a un componente Rain vertical con estallido; UV animadas referenciadas y trece estelas. |
| [Penance](https://www.hiveworkshop.com/threads/penance.337543/) | 2 | Destello dorado pequeño y partículas claras dispersas; el interés está en el brillo y las líneas delicadas, no en una esfera grande. Máscaras Classic hermanas registradas. |
| [Storm Bolt](https://www.hiveworkshop.com/threads/storm-bolt.323769/) | 3 | Pequeño centro de color con arcos/UV y una estela; azul/verde/rojo conservan el lenguaje de descarga. |
| [Void Missiles](https://www.hiveworkshop.com/threads/void-missiles.313156/) | 12 | Familia paralela a FireMissiles, con púrpura/azul y corazón magenta. Creciente, esfera y Rough mantienen perfiles distintos bajo una paleta común. |
| [Void Rain](https://www.hiveworkshop.com/threads/void-rain.316011/) | 2 | Efecto de área/columna y misil separados; aro violeta y brillo lineal aparecen como elementos diferenciados. |
| [Widow Poison / Spider Toxin](https://www.hiveworkshop.com/threads/widow-poison-spider-toxin.351827/) | 2 | Contraste entre charco/espuma oscura y un glóbulo verde muy claro con partículas; distintos roles de veneno e impacto. |
| [Winter Blast (1.32)](https://www.hiveworkshop.com/threads/winter-blast-1-32.333278/) | 2 | Se ve un conjunto frío de luces, pero faltan texturas HD de destello/hielo/grieta: observación parcial, sin validar la apariencia completa. |
| [BananaMissile](https://www.hiveworkshop.com/threads/bananamissile.259787/) | 2 | Fruta física y variante Bomb con destellos dorados; identidad literal de objeto conservada incluso con emisión. |
| [NutMissile](https://www.hiveworkshop.com/threads/nutmissile.260357/) | 1 | Nuez texturada y destellos cálidos; textura de objeto, no color plano, como protagonista. |
| [Seed Shot / Inside / Squirt](https://www.hiveworkshop.com/threads/seed-shot-inside-squirt.340345/) | 5 | Estructura orgánica/celda, disparo puntual y chorro son componentes separados. Verde/negro, bordes brillantes y expulsión fina; variantes Classic aportan recursos. |
| [TC15 Model Bundle](https://www.hiveworkshop.com/threads/tc15-model-bundle.326219/) | 30 | Treinta entradas auxiliares además de misiles: cabezas/fragmentos, fuego de edificios, redes, marcas, tar y molino. Se distinguen roles; no se cuentan como treinta diseños de proyectil equivalentes. |

## Aplicación al X3 propio

- ShotsI/II: separar blanco interior y contorno de color, conservar dirección y silueta a tamaño de juego.
- Firebrand: núcleo/halo/residuos con tamaños y tiempos diferentes.
- Psionic/RuneSpear: estelas finas en recorrido, sin hornear la física al modelo.
- FireCrescent/VoidCrescent: usar la forma de creciente de la malla para sostener la identidad; una nube de partículas no sustituye el perfil.
- ChainGrenade/StormBolt: UV usadas de verdad para el flujo superficial; en X3V4 se aplica al material de aros.
- Cohetes/Incendiary: dejar zonas de contraste para no quemar toda la cabeza con brillo.
- Separar pulso, orbes, resultado de fusión y flash. Mantener rosa/blanco/azul enA, color/blanco enB y rosa/blanco/verde enC.

No se copian geometrías ni texturas de Vinz al packX3. Las lecciones son técnicas y de jerarquía visual; la identidad de forma procede del X3 confirmado.

## Registro individual

| ID | Modelo | Tris | PE2 / ribbons | Recurso visual | Secuencias reales |
|---:|---|---:|---|---|---|
| 000 | Arcade Bolts · Arcade Bolt Blues | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 001 | Arcade Bolts · Arcade Bolt FIre | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 002 | Arcade Bolts · Arcade Bolt Lemon | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 003 | Arcade Bolts · Arcade Bolt Lime | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 004 | Arcade Bolts · Arcade Bolt Psyche | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 005 | Arcade Bolts · Arcade Bolt Red | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 006 | Firebrand Shots · Firebrand Shot Blue | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 007 | Firebrand Shots · Firebrand Shot Green | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 008 | Firebrand Shots · Firebrand Shot Orange | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 009 | Firebrand Shots · Firebrand Shot Pink | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 010 | Firebrand Shots · Firebrand Shot Purple | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 011 | Firebrand Shots · Firebrand Shot Red | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 012 | Firebrand Shots · Firebrand Shot Silver | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 013 | Firebrand Shots · Firebrand Shot Teal | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 014 | Firebrand Shots · Firebrand Shot Yellow | 1 | 10 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 015 | Psionic Shots · Psionic Shot Blue | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 016 | Psionic Shots · Psionic Shot Green | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 017 | Psionic Shots · Psionic Shot Orange | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 018 | Psionic Shots · Psionic Shot Pink | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 019 | Psionic Shots · Psionic Shot Purple | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 020 | Psionic Shots · Psionic Shot Red | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 021 | Psionic Shots · Psionic Shot Silver | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 022 | Psionic Shots · Psionic Shot Teal | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 023 | Psionic Shots · Psionic Shot Yellow | 1 | 9 / 10 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 024 | Shots Vol. I · Shot Blue | 24 | 4 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 025 | Shots Vol. I · Shot Blue Double | 48 | 5 / 0 | Resuelto | Stand 100–500; Birth 2000–2100; Death 3800–4800 |
| 026 | Shots Vol. I · Shot Green | 24 | 4 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 027 | Shots Vol. I · Shot Green Double | 48 | 5 / 0 | Resuelto | Stand 100–500; Birth 2000–2100; Death 3800–4800 |
| 028 | Shots Vol. I · Shot Orange | 24 | 4 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 029 | Shots Vol. I · Shot Orange Double | 48 | 5 / 0 | Resuelto | Stand 100–500; Birth 2000–2100; Death 3800–4800 |
| 030 | Shots Vol. I · Shot Purple | 24 | 4 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 031 | Shots Vol. I · Shot Purple Double | 48 | 5 / 0 | Resuelto | Stand 100–500; Birth 2000–2100; Death 3800–4800 |
| 032 | Shots Vol. I · Shot Red | 24 | 4 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 033 | Shots Vol. I · Shot Red Double | 48 | 5 / 0 | Resuelto | Stand 100–500; Birth 2000–2100; Death 3800–4800 |
| 034 | Shots Vol. I · Shot Yellow | 24 | 4 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 035 | Shots Vol. I · Shot Yellow Double | 48 | 5 / 0 | Resuelto | Stand 100–500; Birth 2000–2100; Death 3800–4800 |
| 036 | Shots Vol. II · Shot II Blue | 24 | 8 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 037 | Shots Vol. II · Shot II Green | 24 | 8 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 038 | Shots Vol. II · Shot II Orange | 24 | 8 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 039 | Shots Vol. II · Shot II Purple | 24 | 8 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 040 | Shots Vol. II · Shot II Red | 24 | 8 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 041 | Shots Vol. II · Shot II Yellow | 24 | 8 / 0 | Resuelto | Stand 100–500; Birth 2000–2300; Death 4000–5000 |
| 042 | Airstrike Rocket · Airstrike Rocket | 304 | 11 / 1 | Resuelto | Stand 2000–3000; Death 4000–10000 |
| 043 | Blood Elven Torpedo · Blood Elven Torpedo | 528 | 16 / 1 | Resuelto | Stand 2000–3000; Death 4000–6000 |
| 044 | Blood Elven Voyager · Blood Elven Voyager | 4416 | 29 / 31 | Resuelto | Stand 100–4100; Stand 2 6000–12000; Stand 3 13000–15000; Stand Work 18000–19500; Attack Spell 20000–20700; Spell Channel 21000–21600; Spell Two 22000–24000; Portrait 24200–27200; Stand Victory 27400–30400; Death 31000–36000; Stand Ready 40000–40400; Spell Slam 42000–43250; Morph 60000–62000; Attack Alternate 80000–80600; Attack Alternate 2 82000–82600; Attack Slam Alternate 84000–84600; Attack Slam Alternate 2 86000–86600; Attack Slam Alternate 3 87000–87600; Attack Slam Alternate 4 88000–88600; Attack Walk Stand Barrage Alternate 89000–89400; Attack Walk Stand Spin Alternate 90000–90500; Attack Walk Stand Whirl Barrage Alternate 92000–92800; Birth Alternate 93000–94000; Morph Alternate 109000–111000; Spell Alternate 112000–113200; Spell Five Alternate 114500–115500; Spell Two Alternate 116000–118800; Spell Three Alternate 119000–119900; Spell Channel Alternate 121000–121600; Spell Channel Two Alternate 123000–123400; Spell Channel Three Alternate 123500–123900; Spell Four Alternate 124000–125700; Spell Throw Alternate 126000–127400; Spell Throw Two Alternate 129000–130000; Stand Alternate 131000–135000; Stand Alternate 2 136000–137000; Stand Alternate 3 138000–140000; Stand Ready Alternate 141000–141500; Portrait Alternate 142000–143000; Stand Victory Alternate 143400–146400; Spell Channel Four Alternate 148000–148400; Spell Slam Two Alternate 149000–150600; Spell Slam Alternate 153000–154500; Spell Six Alternate 155000–156000; Spell Seven Alternate 157000–158000; Spell Eight Alternate 159000–160500; Spell Channel Five Alternate 161000–161600; Death Alternate 162000–167000; Birth 180000–245000; Walk Alternate 245300–249300; Walk Alternate 2 249600–250600; Walk Alternate 3 250900–252900 |
| 045 | Blood Elven Voyager · GunImpact | 2 | 1 / 0 | Resuelto | Birth 167–1033 |
| 046 | Blood Elven Voyager · VoyagerRocket02 | 526 | 4 / 1 | Parcial | birth - 1 3333–4333; birth - 2 4667–5667; birth - 3 6000–7000; birth - 4 7333–8333; birth - 5 8667–9667; birth - 6 10000–11000; birth - 7 11333–12333; birth - 8 12667–13667; birth - 9 14000–15000; birth - 10 15333–16333; Death 20400–22000; Death 22700–24300; Death 25200–26800 |
| 047 | Cannonball · Cannonball | 218 | 14 / 0 | Resuelto | Birth 500–520; Stand 2000–3000; Death 4000–6000 |
| 048 | Cannonball · Cannonball C | 218 | 11 / 0 | Resuelto | Birth 500–520; Stand 2000–3000; Death 4000–6000 |
| 049 | Cannonball · Cannonball D | 218 | 11 / 0 | Resuelto | Birth 500–520; Stand 2000–3000; Death 4000–6000 |
| 050 | Cannonball · Cannonball D Rain | 218 | 11 / 0 | Resuelto | Stand 3000–6000 |
| 051 | Chain Grenade · Chain Grenade Blue | 672 | 9 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 052 | Chain Grenade · Chain Grenade Green | 672 | 9 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 053 | Chain Grenade · Chain Grenade Orange | 672 | 9 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 054 | Chain Grenade · Chain Grenade Purple | 672 | 9 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 055 | Incendiary Bullets Vol. I · Incendiary Bullet Blue | 222 | 10 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 056 | Incendiary Bullets Vol. I · Incendiary Bullet Green | 222 | 10 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 057 | Incendiary Bullets Vol. I · Incendiary Bullet Orange | 222 | 10 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 058 | Incendiary Bullets Vol. I · Incendiary Bullet Purple | 222 | 10 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 059 | Incendiary Bullets Vol. I · Incendiary Bullet Red | 222 | 10 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 060 | Incendiary Bullets Vol. I · Incendiary Bullet Yellow | 222 | 10 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 061 | Interceptor Shell · Interceptor Shell | 916 | 23 / 8 | Resuelto | Stand 2000–3000; Death 4000–10000 |
| 062 | Interceptor Shell · Interceptor Shell Rain | 916 | 23 / 8 | Resuelto | Stand 3200–10000 |
| 063 | Runic Rocket · Runic Rocket | 248 | 13 / 1 | Resuelto | Stand 2000–3000; Death 4000–10000 |
| 064 | Shock Blast · Shock Blast Blue | 10 | 10 / 0 | Resuelto | Stand 1000–2000; Death 4000–5000 |
| 065 | Shock Blast · Shock Blast Green | 10 | 10 / 0 | Resuelto | Stand 1000–2000; Death 4000–5000 |
| 066 | Shock Blast · Shock Blast Orange | 10 | 10 / 0 | Resuelto | Stand 1000–2000; Death 4000–5000 |
| 067 | Shock Blast · Shock Blast Purple | 10 | 10 / 0 | Resuelto | Stand 1000–2000; Death 4000–5000 |
| 068 | Shock Blast · Shock Blast Red | 10 | 10 / 0 | Resuelto | Stand 1000–2000; Death 4000–5000 |
| 069 | Shock Blast · Shock Blast Yellow | 10 | 10 / 0 | Resuelto | Stand 1000–2000; Death 4000–5000 |
| 070 | Tank Shells · Tank Shell Black | 480 | 16 / 1 | Resuelto | Stand 2000–3000; Death 4000–10000 |
| 071 | Tank Shells · Tank Shell Silver | 480 | 16 / 1 | Resuelto | Stand 2000–3000; Death 4000–10000 |
| 072 | Voyager Rocket · Voyager Rocket | 336 | 12 / 1 | Resuelto | Stand 2000–3000; Death 4000–10000 |
| 073 | Bloodstone Arrows · Bloodstone Arrow | 319 | 2 / 1 | Resuelto | Stand 100–1800; Death 2000–2500 |
| 074 | Bloodstone Arrows · Bloodstone Arrow Bloodless | 319 | 1 / 1 | Resuelto | Stand 100–1800; Death 2000–2500 |
| 075 | Bloodstone Arrows · Bloodstone Arrow LSD | 319 | 2 / 1 | Resuelto | Stand 100–1800; Death 2000–2500 |
| 076 | Bloodstone Arrows · Bloodstone Arrow LSD 2 | 319 | 3 / 1 | Resuelto | Stand 100–1800; Death 2000–2500 |
| 077 | Daemonic Arrow · Daemonic Arrow | 2498 | 12 / 0 | Parcial | Birth 1000–1500; Stand 4000–6000; Death 8000–9000 |
| 078 | Explosive Bolts · ExplosiveBolt | 710 | 24 / 2 | Resuelto | Birth 1000–1200; Stand 4000–5000; Death 8000–9000 |
| 079 | Fire Arrows · BonefireArrow1 | 348 | 3 / 1 | Resuelto | Stand 100–900; Birth 1450–1800; Death 2000–2500 |
| 080 | Fire Arrows · BonefireArrowFireless | 270 | 0 / 1 | Resuelto | Stand 100–900; Birth 1450–1800; Death 2000–2500 |
| 081 | Fire Arrows · FirecrackerArrow | 284 | 4 / 0 | Resuelto | Stand 100–900; Birth 1450–1800; Death 2000–2500 |
| 082 | Fire Arrows · FirecrackerArrowFireless | 284 | 2 / 1 | Resuelto | Stand 100–900; Birth 1450–1800; Death 2000–2500 |
| 083 | Fire Arrows · SearingArrow | 301 | 4 / 1 | Resuelto | Stand 100–900; Birth 1450–1800; Death 2000–2500 |
| 084 | Fire Arrows · SearingArrowFireless | 301 | 1 / 1 | Resuelto | Stand 100–900; Birth 1450–1800; Death 2000–2500 |
| 085 | Frost Arrows · Azul Arrow | 350 | 4 / 1 | Resuelto | Stand 100–1400; Birth 1450–1800; Death 2000–2500 |
| 086 | Frost Arrows · Azul Arrow Defrosted | 350 | 2 / 1 | Resuelto | Stand 100–1400; Birth 1450–1800; Death 2000–2500 |
| 087 | Frost Arrows · Maiz con Arrow | 634 | 5 / 1 | Resuelto | Stand 100–1400; Birth 1450–1800; Death 2000–2500 |
| 088 | HighElvenArrow · HighElvenArrow | 108 | 1 / 1 | Resuelto | Stand 100–500; Death 501–1500 |
| 089 | SilverBolts · NightBolts | 86 | 3 / 0 | Resuelto | Stand 0–467; Death 468–1000; Birth 1100–1400 |
| 090 | SilverBolts · SilverBolts | 55 | 3 / 0 | Resuelto | Stand 0–467; Death 468–1000; Birth 1100–1400 |
| 091 | SpiritArrow · SpiritArrow | 26 | 0 / 1 | Resuelto | Birth 0–33; Stand 167–1733; Death 2033–2300 |
| 092 | BouncingBlade · BouncingBlade7 | 59 | 1 / 0 | Resuelto | Death 100–999; Stand 1000–1540 |
| 093 | BouncingBlade · BouncingBladeBuff | 57 | 1 / 0 | Resuelto | Death 100–999; Stand 1000–2680 |
| 094 | BurningSpear · BurningSpear | 15 | 1 / 0 | Resuelto | Birth 0–33; Death 133–467; Stand 1133–2533 |
| 095 | Halberd · Halberd | 35 | 0 / 0 | Resuelto | Stand 100–500 |
| 096 | JavelinToss · JavelinToss | 34 | 2 / 1 | Resuelto | Stand 0–467; Death 468–1000 |
| 097 | Pike · Pike | 23 | 0 / 0 | Resuelto | Birth 0–33; Death 133–467; Stand 1133–2533 |
| 098 | Quantum Blade · QuantumBlade | 58 | 2 / 0 | Resuelto | Stand 0–500; Birth 533–567; Death 667–2033 |
| 099 | RuneSpear · RuneSpear | 60 | 1 / 4 | Resuelto | Stand 100–1000; Death 1200–1500 |
| 100 | StiflingDagger · StiflingDagger | 101 | 1 / 1 | Resuelto | Stand 100–500; Death 501–600 |
| 101 | SunSpear · SunSpear | 30 | 1 / 0 | Resuelto | Birth 333–667; Stand 1333–1667; Death 2333–2833 |
| 102 | WoodenSpear · WoodenSpear | 15 | 0 / 0 | Resuelto | Birth 0–33; Death 133–467; Stand 1133–2533 |
| 103 | Blizzard II · Blizzard II | 100 | 14 / 2 | Resuelto | Stand 1000–4000 |
| 104 | Blizzard II · Blizzard II Missile | 100 | 12 / 2 | Resuelto | Death 1750–4000; Birth 5000–5200; Stand 7000–7400 |
| 105 | Carrion Bats (1.32) · Carrion Bat Avocado HD | 754 | 6 / 8 | Parcial | Birth 1000–1500; Stand Walk 4000–4600; Stand Walk 2 6000–6500; Stand Walk 3 8000–9000; Death 10000–11000 |
| 106 | Carrion Bats (1.32) · Carrion Bat Avocado SD | 754 | 6 / 8 | Parcial | Birth 1000–1500; Stand Walk 4000–4600; Stand Walk 2 6000–6500; Stand Walk 3 8000–9000; Death 10000–11000 |
| 107 | Carrion Bats (1.32) · Carrion Bat Blood HD | 754 | 6 / 6 | Parcial | Birth 1000–1500; Stand Walk 4000–4600; Stand Walk 2 6000–6500; Stand Walk 3 8000–9000; Death 10000–11000 |
| 108 | Carrion Bats (1.32) · Carrion Bat Blood SD | 754 | 6 / 6 | Parcial | Birth 1000–1500; Stand Walk 4000–4600; Stand Walk 2 6000–6500; Stand Walk 3 8000–9000; Death 10000–11000 |
| 109 | Carrion Bats (1.32) · Carrion Bat Jade HD | 754 | 6 / 6 | Parcial | Birth 1000–1500; Stand Walk 4000–4600; Stand Walk 2 6000–6500; Stand Walk 3 8000–9000; Death 10000–11000 |
| 110 | Carrion Bats (1.32) · Carrion Bat Jade SD | 754 | 6 / 6 | Parcial | Birth 1000–1500; Stand Walk 4000–4600; Stand Walk 2 6000–6500; Stand Walk 3 8000–9000; Death 10000–11000 |
| 111 | Deadly Plumage (1.32) · Deadly Plumage HD Gold | 208 | 10 / 8 | Parcial | Birth 1000–1500; Stand 4000–5000; Death 8000–9000 |
| 112 | Deadly Plumage (1.32) · Deadly Plumage HD Purple | 208 | 10 / 8 | Parcial | Birth 1000–1500; Stand 4000–5000; Death 8000–9000 |
| 113 | Deadly Plumage (1.32) · Deadly Plumage SD Purple | 208 | 10 / 8 | Parcial | Birth 1000–1500; Stand 4000–5000; Death 8000–9000 |
| 114 | Fire Missiles · FireArrow | 44 | 5 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2500 |
| 115 | Fire Missiles · Fire Crescent Tailed | 72 | 5 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 116 | Fire Missiles · Fire Spear | 2 | 8 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 117 | Fire Missiles · Fireball Major | 2 | 18 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 118 | Fire Missiles · Fireball Medium | 2 | 17 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 119 | Fire Missiles · Fireball Minor | 2 | 17 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 120 | Fire Missiles · Firebolt Major | 1 | 10 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 121 | Fire Missiles · Firebolt Medium | 1 | 10 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 122 | Fire Missiles · Firebolt Minor | 1 | 10 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 123 | Fire Missiles · Firebolt Rough Major | 1 | 12 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 124 | Fire Missiles · Firebolt Rough Medium | 1 | 11 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 125 | Fire Missiles · Firebolt Rough Minor | 1 | 11 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 126 | Firebolt · Firebolt | 12 | 12 / 11 | Resuelto · alias Classic | Birth 1000–2000; Stand 4000–5000; Death 8000–9000 |
| 127 | Firebolt · Firebolt Classic | 12 | 12 / 11 | Resuelto | Birth 1000–2000; Stand 4000–5000; Death 8000–9000 |
| 128 | Frost Bolt · FrostBoltV1 | 538 | 21 / 13 | Resuelto | Birth 1000–2000; Stand 4000–5000; Death 8000–9000 |
| 129 | Frost Bolt · FrostBoltRainV | 538 | 21 / 13 | Resuelto | Birth 1000–3000 |
| 130 | Penance · Penance | 18 | 3 / 5 | Resuelto · alias Classic | Birth 1000–2000; Stand 4000–5000; Death 8000–9000 |
| 131 | Penance · Penance - Classic | 18 | 3 / 5 | Resuelto | Birth 1000–2000; Stand 4000–5000; Death 8000–9000 |
| 132 | Storm Bolt · Storm Bolt | 842 | 13 / 1 | Resuelto | Birth 1000–1200; Stand 4000–5000; Death 8500–10000 |
| 133 | Storm Bolt · Storm Bolt Green | 842 | 13 / 1 | Resuelto | Birth 1000–1200; Stand 4000–5000; Death 8500–10000 |
| 134 | Storm Bolt · Storm Bolt Red | 842 | 13 / 1 | Resuelto | Birth 1000–1200; Stand 4000–5000; Death 8500–10000 |
| 135 | Void Missiles · Void Arrow | 44 | 5 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2500 |
| 136 | Void Missiles · Void Crescent Tailed | 72 | 5 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 137 | Void Missiles · Void Spear | 2 | 8 / 6 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 138 | Void Missiles · Voidball Major | 2 | 15 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 139 | Void Missiles · Voidball Medium | 2 | 15 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 140 | Void Missiles · Voidball Minor | 2 | 15 / 2 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–3000 |
| 141 | Void Missiles · Voidbolt Major | 40 | 11 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 142 | Void Missiles · Voidbolt Medium | 40 | 11 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 143 | Void Missiles · Voidbolt Minor | 40 | 11 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 144 | Void Missiles · Voidbolt Rough Major | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 145 | Void Missiles · Voidbolt Rough Medium | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 146 | Void Missiles · Voidbolt Rough Minor | 1 | 8 / 0 | Resuelto | Stand 100–900; Birth 1000–1400; Death 2000–2800 |
| 147 | Void Rain · Void Rain | 1 | 10 / 2 | Resuelto | Stand 1000–3000 |
| 148 | Void Rain · Void Rain Missile | 1 | 10 / 4 | Resuelto | Birth 500–800; Stand 1000–1900; Death 4000–5000 |
| 149 | Widow Poison / Spider Toxin · SpiderToxin | 1 | 13 / 0 | Resuelto | Stand 1000–1800; Stand 2 2000–2500; Birth 2800–3000; Stand 3 4000–5000; Stand 4 6000–7000; Stand 5 8000–9000; Death 10000–11000 |
| 150 | Widow Poison / Spider Toxin · WidowPoison | 136 | 26 / 6 | Resuelto | Birth 1000–1200; Stand 4000–5000; Death 8000–10000 |
| 151 | Winter Blast (1.32) · Winter Blast HD | 1956 | 23 / 3 | Parcial | Stand 1000–3000 |
| 152 | Winter Blast (1.32) · Winter Blast SD | 1956 | 22 / 3 | Parcial | Stand 1000–3000 |
| 153 | BananaMissile · BananaMissile | 52 | 2 / 0 | Resuelto | Stand 0–467; Stand 2 468–900; Stand 3 901–1400; Death 1500–1700 |
| 154 | BananaMissile · BananaBomb | 132 | 2 / 0 | Resuelto | Stand 0–1000; Stand 2 1000–2000; Stand 3 2001–3000; Death 3500–4200 |
| 155 | NutMissile · NutMissile | 113 | 2 / 0 | Resuelto | Stand 1–467; Stand 2 468–900; Stand 3 901–1400; Death 1500–1700 |
| 156 | Seed Shot / Inside / Squirt · Seed Inside | 3014 | 2 / 0 | Resuelto · alias Classic | Birth 1000–2000; Stand 4000–5000; Death 8000–10000; Medium Birth 11000–12000; Medium Stand 14000–15000; Medium Death 18000–20000; Large Birth 21000–22000; Large Stand 24000–25000; Large Death 28000–30000 |
| 157 | Seed Shot / Inside / Squirt · Seed Inside Classic | 3014 | 2 / 0 | Resuelto | Birth 1000–2000; Stand 4000–5000; Death 8000–10000; Medium Birth 11000–12000; Medium Stand 14000–15000; Medium Death 18000–20000; Large Birth 21000–22000; Large Stand 24000–25000; Large Death 28000–30000 |
| 158 | Seed Shot / Inside / Squirt · Seed Shot | 682 | 6 / 4 | Resuelto | Birth 1000–2000; Stand 4000–5000; Death 8000–9000 |
| 159 | Seed Shot / Inside / Squirt · Seed Squirt | 12 | 9 / 0 | Resuelto · alias Classic | Stand 1000–2500 |
| 160 | Seed Shot / Inside / Squirt · Seed Squirt Classic | 12 | 9 / 0 | Resuelto | Stand 1000–2500 |
| 161 | TC15 Model Bundle · BE Bloody Head0 | 213 | 0 / 0 | Resuelto | Stand 4000–4400; Death 8000–9000 |
| 162 | TC15 Model Bundle · BE Bloody Head1 | 213 | 0 / 0 | Resuelto | Stand 4000–4400; Death 8000–9000 |
| 163 | TC15 Model Bundle · BE Bloody Head2 | 213 | 0 / 0 | Resuelto | Stand 4000–4400; Death 8000–9000 |
| 164 | TC15 Model Bundle · BE Head0 | 213 | 0 / 0 | Resuelto | Stand 4000–4400; Death 8000–9000 |
| 165 | TC15 Model Bundle · BE Head1 | 213 | 0 / 0 | Resuelto | Stand 4000–4400; Death 8000–9000 |
| 166 | TC15 Model Bundle · BE Head2 | 213 | 0 / 0 | Resuelto | Stand 4000–4400; Death 8000–9000 |
| 167 | TC15 Model Bundle · Besieger Target | 2 | 1 / 0 | Resuelto | Birth 1000–1200; Stand 4000–5000; Death 8000–9000 |
| 168 | TC15 Model Bundle · Bloody Elf Head Missile | 213 | 15 / 0 | Resuelto | Birth 1000–1100; Stand 4000–4400; Death 8000–9000 |
| 169 | TC15 Model Bundle · MBuilding Fire Large | 0 | 5 / 0 | Resuelto | Stand 33–1000; Death 3333–11100 |
| 170 | TC15 Model Bundle · MBuilding Fire Large NE | 0 | 5 / 0 | Resuelto | Stand 33–1000; Death 3333–11100 |
| 171 | TC15 Model Bundle · MBuilding Fire Large UD | 0 | 5 / 0 | Resuelto | Stand 33–1000; Death 3333–11100 |
| 172 | TC15 Model Bundle · MBuilding Fire Small | 0 | 4 / 0 | Resuelto | Stand 33–1000; Death 3333–11100 |
| 173 | TC15 Model Bundle · MBuilding Fire Small NE | 0 | 4 / 0 | Resuelto | Stand 33–1000; Death 3333–11100 |
| 174 | TC15 Model Bundle · MBuilding Fire Small UD | 0 | 4 / 0 | Resuelto | Stand 33–1000; Death 3333–11100 |
| 175 | TC15 Model Bundle · BurningSpear | 644 | 14 / 3 | Resuelto | Birth 1000–1100; Stand 4000–4400; Death 8000–9000 |
| 176 | TC15 Model Bundle · Burning Spear Target | 0 | 9 / 0 | Resuelto | Stand 33–1000; Death 3333–11100 |
| 177 | TC15 Model Bundle · Chainsnare_AirTarget | 68 | 0 / 3 | Resuelto | Birth 1833–2333; Stand 3000–5000; Death 5333–6000; Birth Medium 8500–9000; Stand Medium 9667–11667; Death medium 12000–12667; Birth Large 15033–15533; Stand Large 16200–18200; Death Large 18533–19200 |
| 178 | TC15 Model Bundle · ChainsnareTarget | 60 | 0 / 3 | Resuelto | Birth 1833–2333; Stand 3000–5000; Death 5333–6000; Birth Medium 6867–7367; Stand Medium 8033–10033; Death Medium 10367–11033; Birth Large 12200–12700; Stand Large 13367–15367; Death Large 15700–16367 |
| 179 | TC15 Model Bundle · ChainsnareMissile | 32 | 0 / 0 | Resuelto | Stand - 1 9667–11333; Birth 11867–11900; Death 16667–18267 |
| 180 | TC15 Model Bundle · Mighty Finger | 28 | 5 / 0 | Resuelto | Birth 1000–1200; Stand 4000–5000; Death 8000–9000 |
| 181 | TC15 Model Bundle · Orb of Judgement Target | 4 | 2 / 0 | Resuelto | Stand 0–1000; Stand 1067–2200; Stand 2767–3533 |
| 182 | TC15 Model Bundle · Tar Pool | 0 | 6 / 0 | Resuelto | Birth 1000–1100; Stand 4000–4200; Death 8000–9000 |
| 183 | TC15 Model Bundle · Tar Target | 0 | 1 / 0 | Resuelto | Stand 0–1000; Birth 1133–1267; Death 1500–1667 |
| 184 | TC15 Model Bundle · Tarred Elf Head | 213 | 15 / 0 | Resuelto | Birth 1000–1100; Stand 4000–4400; Death 8000–9000 |
| 185 | TC15 Model Bundle · Tarred Elf Head II | 213 | 15 / 0 | Resuelto | Birth 1000–1100; Stand 4000–4400; Death 8000–9000 |
| 186 | TC15 Model Bundle · Valiant Rush I | 2 | 3 / 0 | Resuelto | Stand 1000–2600 |
| 187 | TC15 Model Bundle · Valiant Rush II | 2 | 6 / 0 | Resuelto | Stand 1000–2600 |
| 188 | TC15 Model Bundle · Vanguard Explosion | 0 | 12 / 0 | Resuelto | Stand 3000–4000 |
| 189 | TC15 Model Bundle · VanquisherTarget | 2 | 5 / 0 | Resuelto | Birth 0–1833 |
| 190 | TC15 Model Bundle · Windmill House | 1888 | 8 / 0 | Resuelto | Birth 10000–30000; Stand 36000–37000; Death 40000–42500; Decay 50000–55000; Portrait 60000–62000 |
