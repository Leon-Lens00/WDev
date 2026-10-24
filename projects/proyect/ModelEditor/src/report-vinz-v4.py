"""Write observations separately from binary measurements and visual coverage limits."""
from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[1];EV=ROOT/'evidence/x3-v4/study';OUT=ROOT/'references/vinz-estudio-v4';OUT.mkdir(parents=True,exist_ok=True)
data=json.loads((EV/'all-models.json').read_text());resources={e['id']:e for e in json.loads((EV/'atlas-resources.json').read_text())}
notes={
'Arcade Bolts':'Bloques luminosos y fragmentos cuadrados; el núcleo blanco se lee dentro de un contorno de píxeles de color. Identidad deliberadamente arcade, distinta de una llama suave.',
'Firebrand Shots':'Cabeza redonda caliente, halo amplio y gotas pequeñas detrás; impacto con salpicaduras y puntos luminosos separados. Útil para jerarquía núcleo/halo/residuo.',
'Psionic Shots':'Quietos se ven discretos; el conjunto de ribbons es parte esencial de su lectura en recorrido. Impacto con motas separadas y remanente más oscuro.',
'Shots Vol. I':'Punta blanca y silueta larga afilada; variantes simples y dobles comparten lenguaje. Impacto cambia la lectura a estrellas y glóbulos.',
'Shots Vol. II':'Conserva la dirección de ShotsI pero añade puntas radiales y una estrella más evidente en cabeza; fuerte contraste entre centro y rayos.',
'Airstrike Rocket':'Cuerpo metálico oscuro, propulsión blanca y explosión naranja radial con anillos; el brillo acompaña al objeto sin sustituir su forma.',
'Blood Elven Torpedo':'Casco dorado/rojo con propulsión verde; explosión verde clara. La combinación de cuerpo físico y emisión de color distingue la familia.',
'Blood Elven Voyager':'Paquete mixto: plataforma/vehículo elaborado, cohete y GunImpact. La plataforma no se clasifica como un misil pequeño. El cohete tiene dos dependencias ausentes; impacto circular separado.',
'Cannonball':'Esfera negra con reflejo claro; la lectura metálica oscura contrasta con la explosión cálida, humo y marca de suelo. Rain es una variante de cronología.',
'Chain Grenade':'Malla de cadenas/huecos oscuros rodeada de halo de color; UV animadas usadas por materiales. Impacto muy luminoso, con textura y espacio oscuro antes del estallido.',
'Incendiary Bullets Vol. I':'Centro físico oscuro abrazado por una corona de fuego de color; no todos los proyectiles necesitan un centro completamente blanco. Desaparición con estrellas dispersas.',
'Interceptor Shell':'Silueta de punta blindada y motor rojo; impacto distinto del residuo de Rain. Emisión y estelas no tienen el mismo papel que la malla.',
'Runic Rocket':'Lectura cian y glifos/brillos fríos; fuerte estallido radial. El color y el perfil ornamental lo separan de los cohetes de acero.',
'Shock Blast':'Nudo energético pequeño en vuelo; al morir aparecen aros/estructuras concéntricas y cambian las capas visibles. Importa revisar visibilidad por secuencia.',
'Tank Shells':'Punta y carcasa metálicas larga y legible, dos acabados físicos y propulsión cálida; explosión de chispas con trazos radiales.',
'Voyager Rocket':'Aletas ornamentales doradas, carcasa roja y empuje blanco; conserva identidad física aun con efectos luminosos.',
'Bloodstone Arrows':'Flecha con rastros rojos; Bloodless y LSD cambian sangre/paleta/ornamentos. La variante tiene personalidad por elementos presentes, no sólo por RGB.',
'Daemonic Arrow':'Cabeza y rastro violeta visibles; seis texturas HD usadas faltan en esta instalación. Observación parcial: no atribuir a la preview la apariencia original completa.',
'Explosive Bolts':'Punta cálida rodeada por un aro claro y trazos finos; combina objeto y energía circular. Impacto denso y chispeante.',
'Fire Arrows':'Familia heterogénea: llama verde, petardo de motas rojas y punta amarilla; variantes Fireless muestran qué queda al quitar la llama.',
'Frost Arrows':'Azul helado frente a variante descongelada y una variante de maíz; no son tres colores idénticos. El componente físico sigue siendo reconocible.',
'HighElvenArrow':'Flecha ornamental clara/dorada y brillo contenido; ejemplo de silueta física que no depende de un halo enorme.',
'SilverBolts':'Silver y Night comparten carácter de destello frío pero cambian el reparto blanco/azul y el ornamento de cabeza.',
'SpiritArrow':'Forma de doble punta clara, poca emisión; la geometría lleva la identidad y la estela apoya el movimiento.',
'BouncingBlade':'Hoja curva metálica y componente Buff independiente; la pieza auxiliar no se confunde con una segunda trayectoria de misil.',
'BurningSpear':'Lanza de asta visible y punta clara; en el primer Stand se lee principalmente la forma física. No equiparar esta versión con la del bundle posterior.',
'Halberd':'Arma larga con cabeza de alabarda y asta oscura; alto contraste de silueta con poco efecto luminoso.',
'JavelinToss':'Jabalina física con cola cálida intensa; el pequeño objeto conserva dirección dentro de la llama.',
'Pike':'Lanza fina y sobria, punta metálica definida; ejemplo de lectura sin exceso de partículas.',
'Quantum Blade':'Hoja energética azul con pequeños cuerpos/glóbulos curvos agrupados; identidad de energía articulada frente a un rayo recto.',
'RuneSpear':'Punta fría con ornamentos y varias estelas; filamentos finos alrededor de una forma física compacta.',
'StiflingDagger':'Daga con nube/motas verdes; halo corto junto al arma y residuos dispersos de aspecto tóxico.',
'SunSpear':'Asta y punta cálida, emisión mínima; el nombre de una familia no implica una gran bola de luz.',
'WoodenSpear':'Lanza física sencilla, madera y punta clara; referencia de proporciones y legibilidad del objeto.',
'Blizzard II':'Separación entre efecto de lluvia vertical y misil de hielo; cristales, chispas frías y forma puntiaguda cumplen funciones distintas.',
'Carrion Bats (1.32)':'Silueta de murciélago oscura dentro de un brillo rojo/verde; pequeñas estelas y UV. Dos recursos líquidos HD faltan: vista parcial en las seis variantes.',
'Deadly Plumage (1.32)':'Siluetas de plumas y líneas finas doradas/violetas; dependencias HD ausentes impiden reconstruir toda la capa de partículas. No usar como muestra completa.',
'Fire Missiles':'Doce componentes: flecha, creciente, spear, bolas y bolts con variantes de tamaño/rugosidad. FireCrescent tiene curva explícita; las versiones Rough usan un borde granular más irregular.',
'Firebolt':'Chispa cálida compacta con muchas estelas finas. Classic aporta máscaras usadas también por la variante hermana de ruta HD; los alias se registran.',
'Frost Bolt':'Punto frío y cristales frente a un componente Rain vertical con estallido; UV animadas referenciadas y trece estelas.',
'Penance':'Destello dorado pequeño y partículas claras dispersas; el interés está en el brillo y las líneas delicadas, no en una esfera grande. Máscaras Classic hermanas registradas.',
'Storm Bolt':'Pequeño centro de color con arcos/UV y una estela; azul/verde/rojo conservan el lenguaje de descarga.',
'Void Missiles':'Familia paralela a FireMissiles, con púrpura/azul y corazón magenta. Creciente, esfera y Rough mantienen perfiles distintos bajo una paleta común.',
'Void Rain':'Efecto de área/columna y misil separados; aro violeta y brillo lineal aparecen como elementos diferenciados.',
'Widow Poison / Spider Toxin':'Contraste entre charco/espuma oscura y un glóbulo verde muy claro con partículas; distintos roles de veneno e impacto.',
'Winter Blast (1.32)':'Se ve un conjunto frío de luces, pero faltan texturas HD de destello/hielo/grieta: observación parcial, sin validar la apariencia completa.',
'BananaMissile':'Fruta física y variante Bomb con destellos dorados; identidad literal de objeto conservada incluso con emisión.',
'NutMissile':'Nuez texturada y destellos cálidos; textura de objeto, no color plano, como protagonista.',
'Seed Shot / Inside / Squirt':'Estructura orgánica/celda, disparo puntual y chorro son componentes separados. Verde/negro, bordes brillantes y expulsión fina; variantes Classic aportan recursos.',
'TC15 Model Bundle':'Treinta entradas auxiliares además de misiles: cabezas/fragmentos, fuego de edificios, redes, marcas, tar y molino. Se distinguen roles; no se cuentan como treinta diseños de proyectil equivalentes.'
}
assert len(notes)==50
lines=['# Estudio Vinz para X3V4','', '23/10/2026.191 MDX distintos en50 paquetes del archivo descargado. Originales leídos, hashes contrastados y conservados. No son191 diseños distintos ni todos son misiles de vuelo: hay auxiliares, impactos y un bundle mixto.','', '## Cobertura y límites','', 'Se recorrieron los191 modelos en visor nativo MDX, por páginas de6, y una muestra temprana de Death cuando la secuencia existe. Si no existe, el visor usa la primera secuencia; los nombres/intervalos reales están en el inventario. Las capturas muestran su tiempo efectivo: el rótulo120ms es la solicitud de muestreo y algunas instancias culled arrancan en la primera clave. No se atribuye precisión temporal uniforme a esas láminas.','', '178 modelos tienen resueltos sus recursos usados por materiales/PE2, incluyendo alias de texturas Classic hermanas que el paquete aporta.13 tienen dependencias ausentes y se marcan parciales: el componente no disponible usa textura transparente de diagnóstico. Las tablas UberSplatData y texturas de cráter originales se recuperaron del MPQ para revisar eventos de suelo. Sonido desactivado; no se prueban aquí ni sonido, motor1.27b de cada original, FPS o multijugador.','', 'Datos reproducibles: `evidence/x3-v4/study/all-models.json`, `resources.json`, `atlas-resources.json`, capturas `atlas-stand/` y `atlas-death/`. El atlas local está en `viewer/vinz-study-v4/`; hashes de sus copias coinciden con originales.','', '## Personalidades observadas','', '| Paquete | Entradas | Observación visual y función |','|---|---:|---|']
for p in data['packages']:lines.append(f"| [{p['title']}]({p['url']}) | {len(p['models'])} | {notes[p['title']]} |")
lines += ['', '## Aplicación al X3 propio','', '- ShotsI/II: separar blanco interior y contorno de color, conservar dirección y silueta a tamaño de juego.','- Firebrand: núcleo/halo/residuos con tamaños y tiempos diferentes.','- Psionic/RuneSpear: estelas finas en recorrido, sin hornear la física al modelo.','- FireCrescent/VoidCrescent: usar la forma de creciente de la malla para sostener la identidad; una nube de partículas no sustituye el perfil.','- ChainGrenade/StormBolt: UV usadas de verdad para el flujo superficial; en X3V4 se aplica al material de aros.','- Cohetes/Incendiary: dejar zonas de contraste para no quemar toda la cabeza con brillo.','- Separar pulso, orbes, resultado de fusión y flash. Mantener rosa/blanco/azul enA, color/blanco enB y rosa/blanco/verde enC.','', 'No se copian geometrías ni texturas de Vinz al packX3. Las lecciones son técnicas y de jerarquía visual; la identidad de forma procede del X3 confirmado.','', '## Registro individual','', '| ID | Modelo | Tris | PE2 / ribbons | Recurso visual | Secuencias reales |','|---:|---|---:|---|---|---|']
for e in data['entries']:
 state='Parcial' if any(t['used'] for t in resources[e['id']]['missing']) else 'Resuelto'+(' · alias Classic' if resources[e['id']]['aliases'] else '')
 seq='; '.join(f"{s['name']} {s['interval'][0]}–{s['interval'][1]}" for s in e['sequences'])
 lines.append(f"| {e['id']:03} | {e['label']} | {e['triangles']} | {len(e['pe2'])} / {len(e['ribbonDetails'])} | {state} | {seq} |")
(OUT/'ESTUDIO.md').write_text('\n'.join(lines)+'\n')
print('50 family observations and191 individual records written')
