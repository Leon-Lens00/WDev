"""Verify delivery files and freeze a manifest; never invent visual/native approvals."""
from pathlib import Path
from html.parser import HTMLParser
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
T = ROOT / 'artifacts/warcraft-terrain/contextual-materials-v1'
OUT = T / 'release'


def read(p):
    return json.loads(p.read_text(encoding='utf-8-sig'))


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


class References(HTMLParser):
    def __init__(self):
        super().__init__()
        self.refs = []

    def handle_starttag(self, tag, attrs):
        self.refs.extend(v for k, v in attrs if k in {'src', 'href'} and v)


def main():
    contract = read(OUT / 'reproduction-inputs.json')
    for relative, expected in contract['inputs'].items():
        assert sha(OUT / relative) == expected, relative
    table = []
    for case in contract['cases']:
        b, seed = case['brief'], case['seed']
        for mode, suffix, key in [('generated', '', 'generated_sha256'), ('editor', '-editor', 'editor_sha256')]:
            path = f'maps/{mode}/Tropical-{b}-{seed}-materials{suffix}.w3x'
            assert sha(OUT / path) == case[key]
        audit = read(OUT / f'evidence/editor/{b}/' / ('audit.json' if b == 'F' else 'audit-v2.json'))
        assert audit['passed'] and audit['same_terrain'] and audit['same_object_geometry']
        assert audit['source_sha256'] == case['generated_sha256']
        assert audit['saved_sha256'] == case['editor_sha256']
        for review_path in [T / f'visual/{b}/visual-review.json', T / f'editor/{b}/visual-review.json']:
            review = read(review_path)
            assert review['accepted']
            for original, expected in review['reviewed_inputs'].items():
                assert sha(Path(original)) == expected, original
        table.append(f'| {b} · {seed} | [Generado](maps/generated/Tropical-{b}-{seed}-materials.w3x) | [World Editor](maps/editor/Tropical-{b}-{seed}-materials-editor.w3x) |')
    for name in ['source-atlas/visual-review.json', 'visual/E-53701/visual-review.json']:
        review = read(T / name)
        assert review['accepted']
        for original, expected in review['reviewed_inputs'].items():
            assert sha(Path(original)) == expected, original
    tests = read(T / 'reproduction/tests-audit-v2/results.json')
    assert tests['test_exit'] == tests['vet_exit'] == 0
    assert read(T / 'reproduction/pjass-native.json')['accepted']
    assert read(T / 'reproduction/pjass-generated-inherited.json')['passed']
    assert read(T / 'reproduction/portable-release/result.json')['passed']
    assert len(read(T / 'reproduction/batch-results.json')) == 12
    assert all(x['repaint_exact'] and x['integrated_exact'] for x in read(T / 'reproduction/exact.json'))
    # Recheck preservation against original inventory rather than trusting a prior report.
    baseline = read(T / 'baseline/baseline.json')
    for original, expected in baseline['protected'].items():
        assert sha(Path(original)) == expected, original
    frozen = read(T / 'baseline/frozen-before-batch.json')
    for original, expected in frozen['inputs'].items():
        assert sha(Path(original)) == expected, original
    session = read(T / 'baseline/session-after.json')
    assert session['own_forge_window_closed'] and session['user_document_not_saved_or_closed']
    readme = '''# Materiales contextuales — D/E/F

**Validated. T0–T8 completos; P8/P9 cerrados mediante esta entrega.** Tres paisajes Classic 1.27b de 192×96 celdas con suelo corregido. Se conservan la geografía, el agua y todos los objetos. Sombras y pruebas dentro del juego excluidas.

[Abrir el atlas antes/después](atlas/index.html) · [Dependencias](dependencies.json) · [Manifest SHA256](manifest.json).

| Mapa | Reproducción exacta | Copia guardada y reabierta realmente |
|---|---|---|
''' + '\n'.join(table) + '''

Las copias generadas son el resultado determinista. Las copias World Editor son editables y tienen las normalizaciones nativas auditadas; su archivo completo no es idéntico al generado.

## Resultado

«Tierra con hierba» ocupa 5,08 / 5,04 / 5,28 % de los vértices secos de D/E/F, frente a 29,67–32,44 % antes y 5,09 % en el original. No mide píxeles visibles. La síntesis utiliza 5670 muestras fuente y mezcla tierra, hierba desigual y hojas por contexto; no impone una cuota global de hierba.

Los doce casos cumplen los criterios congelados. La mayor mancha seca de esa textura en los finales es 80 / 87 / 84 vértices (antes 627 / 828 / 983). Se mantienen todas las texturas de núcleos rígidos, agua, bordes y pisos arquitectónicos existentes.

## Reproducir en otra carpeta

Windows amd64 y Python 3.10 o posterior. La CLI y todas las entradas del repintado están incluidas; no necesita instalación de Warcraft ni descargas.

```powershell
python reproduce.py --out ../materiales-reproducidos
```

Ejecutar desde esta carpeta, con una salida nueva fuera del paquete. También funciona desde otra ubicación usando la ruta completa de `reproduce.py`. El script verifica entradas, reubica rutas en copias locales y exige los tres SHA256 generados. La prueba de esta vía está en `evidence/reproduction/portable-release/result.json`. No sobrescribe resultados anteriores ni simula guardados del editor.

La generación integrada también se reprodujo exactamente para D/E/F: `evidence/reproduction/exact.json`. Los `config/*-integrated.json` y recetas conservan las rutas originales del workspace a Classic, host .NET 10 y bibliotecas. Esta ruta requiere esas dependencias locales; el script portátil automatiza el repintado de las bases congeladas.

## Implementación y dependencias

`bin/terrain-gen-materials.exe` es la CLI congelada de generación/repintado. `bin/terrain-gen-materials-audit-v2.exe` incluye la corrección acotada del auditor nativo. `source.zip` contiene fuentes de la CLI y host, scripts y esquemas; `go.mod/go.sum` fijan módulos. Compilación de CLI con Go 1.26.1: `go build -o terrain-gen-materials-audit-v2.exe ./cmd/terrain-gen`. Se comprobó desde el ZIP con módulos ya instalados, sin red (`evidence/reproduction/source-build.json`). No se promete identidad binaria entre compilaciones de Go.

El perfil y las solicitudes originales siguen intactos. La copia local del perfil cambia de hash al cambiar su ruta `source`; se actualiza la referencia de forma explícita, sin modificar muestras ni algoritmos. El W3X resultante sigue siendo idéntico.

## Evidencia

- `atlas/`: 16 imágenes fuente, 52 comparaciones/diagnósticos finales y tres imágenes del caso adicional E53701, con metadatos y revisiones. El HTML incluye también vistas nativas. Las capturas son originales; no se editaron para simular resultados.
- `evidence/editor/`: tres guardados/reaperturas documentados, 18 capturas examinadas, auditorías y diferencias por campos/regiones. D/E aceptados en `audit-v2.json`; F en `audit.json`. Los rechazos iniciales D/E permanecen.
- `evidence/reproduction/`: suite Go completa, vet, tres pJASS nativos, tres repintados exactos, tres generaciones integradas exactas, tres reproducciones portátiles exactas e independencia de semilla. Los tres scripts generados heredaron compilación de P tras comprobar sus bytes (`evidence/inherited-pjass/`).
- `evidence/baseline/`: 2963 archivos anteriores y 26 entradas congeladas conservados; sesión del usuario mantenida. La instancia Forge propia quedó cerrada.
- `profile/`: perfil final, criterios congelados y esquemas descriptivos. Los esquemas JSON se añadieron al empaquetar; el contrato Go y los criterios ya estaban fijados antes del lote.

World Editor conserva W3E exacto y geometría de objetos, con redondeo Z máximo 0,000481. Recalcula huellas y construcción según las texturas. El control nativo D antes/después cambia solo construcción (11948 celdas), con cero diferencias de tránsito a pie/vuelo. E/F tienen auditorías propias de rutas; no se les atribuye ese control comparativo de D.

El auditor v2 usa 256 unidades para relaciones explícitas de acceso entre escenas, coincidiendo con su reserva de hábitats preexistente; mantiene 128 dentro de estructuras, búsqueda de puerto hasta 96 y colisión 32. Pruebas positivas y negativas acreditan el límite. Esta corrección resolvió los rechazos iniciales D/E sin modificar mapas ni relajar los criterios de materiales.

## Límites y autoría

Perfil específico de esta paleta tropical y cuadrícula. Las vecindades de troncos/rocas aproximan el contexto; no reconocen cualquier importado ni la cobertura exacta de mallas. El holdout espacial es diagnóstico porque puede compartir vecindarios de borde. Flores moradas y artefactos de modelos lejanos heredados se conservan. No se acredita balance o pruebas de unidades dentro del juego.

El donante Tropical Template 1.3 y sus importados/créditos permanecen intactos. `LICENSE-wc3-forge.txt` corresponde al código wc3-forge; no sustituye las licencias de Warcraft ni de los recursos del mapa. Los guardados nativos son evidencia local, no pruebas dentro del juego.
'''
    (OUT / 'README.md').write_text(readme, encoding='utf-8')
    # Exact copy of the human-facing current workspace guide for provenance; links remain workspace-relative.
    docdir = OUT / 'docs-workspace'
    docdir.mkdir(exist_ok=True)
    for name in ['MATERIALES-CONTEXTUALES.md', 'STATUS-MATERIALES-CONTEXTUALES.md', 'CONTRATO-MATERIALES-CONTEXTUALES.md', 'STATUS-PAISAJES-INTEGRADOS.md']:
        shutil.copyfile(ROOT / 'docs/warcraft-terrain' / name, docdir / name)
    (docdir / 'README.md').write_text('Copias de documentación del workspace. Sus enlaces relativos se resuelven desde docs/warcraft-terrain del proyecto original. Para usar el paquete movido, consultar ../README.md y ../atlas/index.html.\n', encoding='utf-8')
    parser = References()
    parser.feed((OUT / 'atlas/index.html').read_text(encoding='utf-8'))
    for ref in parser.refs:
        if not ref.startswith(('#', 'http:', 'https:')):
            assert (OUT / 'atlas' / ref.split('#')[0]).is_file(), ref
    write(OUT / 'delivery-validation.json', {'status': 'Validated', 'milestones': ['T' + str(i) for i in range(9)],
          'closes': ['P8', 'P9'], 'cases': contract['cases'], 'batch_cases': 12,
          'protected_files_verified': len(baseline['protected']), 'frozen_inputs_verified': len(frozen['inputs']),
          'atlas_references_verified': len(parser.refs), 'repaint_reproductions': 3, 'integrated_reproductions': 3,
          'portable_reproductions': 3, 'world_editor_saves_reopened': 3,
          'native_script_compilations': 3, 'generated_script_compilations_inherited_by_hash': 3,
          'shadows': 'excluded', 'game': 'excluded', 'reviews': 'Existing manual approvals and every reviewed input hash checked; not auto-generated.'})
    manifest = {f.relative_to(OUT).as_posix(): {'sha256': sha(f), 'bytes': f.stat().st_size}
                for f in sorted(OUT.rglob('*')) if f.is_file() and f != OUT / 'manifest.json'}
    write(OUT / 'manifest.json', {'format': 'wc3-material-release-manifest-v1', 'status': 'Validated', 'files': manifest})
    for name, info in read(OUT / 'manifest.json')['files'].items():
        assert sha(OUT / name) == info['sha256'], name
    print(f'Validated: {len(manifest)} package files; all six maps, review hashes, preserved inputs and atlas links checked.')


if __name__ == '__main__':
    main()
