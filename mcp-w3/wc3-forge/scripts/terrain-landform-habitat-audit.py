"""Audit tropical forest area independently of tree density, using JSON only.

Single pilot: --contract CONTRACT --case-dir PILOT --out REPORT
Nine-case batch: --contract CONTRACT --batch-dir BATCH --out REPORT
Batch mode records all nine cases; Biome cases are explicitly outside this
supplement and retain their own per-ID habitat-area and coverage inspections.
This does not read MPQs, alter maps, or grant visual/native acceptance.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import re

FORMAT = 'wc3-landform-habitat-acceptance-v1'
CATEGORIES = ['forest-interior', 'forest-edge']
DENSITY = {'category': 'forest-interior', 'minimum_count': 30,
           'maximum_median_distance': 160, 'minimum_neighbors_256': 3,
           'reference_nearest_quantiles': [math.sqrt(8192), 128, 128],
           'maximum_relative_quantile_deviation': .25}


def read(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError('duplicate JSON key: ' + key)
            result[key] = value
        return result
    def invalid(value):
        raise ValueError('nonfinite JSON number: ' + value)
    return json.loads(Path(path).read_text(encoding='utf-8-sig'),
                      object_pairs_hook=unique, parse_constant=invalid)


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def number(value):
    return type(value) in (int, float) and math.isfinite(value)


def check_layers(value, geometry):
    size = geometry['width'] * geometry['height']
    require(value.get('vertex_resolution') == geometry['vertex_resolution'],
            'physical resolution differs from acceptance geometry')
    dry = value.get('dry')
    require(isinstance(dry, list) and len(dry) == size and
            all(type(v) is bool for v in dry), 'invalid physical dry grid')
    counts = value.get('habitat_counts')
    require(isinstance(counts, dict) and all(type(v) is int and v >= 0 for v in counts.values()),
            'invalid habitat counts')
    require(sum(counts.values()) == size and counts.get('water') == size - sum(dry),
            'habitat counts disagree with physical grid')
    require(isinstance(value.get('map_sha256'), str) and
            re.fullmatch('[0-9a-f]{64}', value['map_sha256']), 'invalid map identity')
    return counts


def compare(contract, baseline, layers, metrics):
    counts = check_layers(layers, contract['geometry'])
    base = check_layers(baseline, contract['geometry'])
    failures, areas = [], {}
    fraction = contract['area_policy']['minimum_fraction']
    step = contract['geometry']['vertex_resolution']
    for category in CATEGORIES + ['forest-total']:
        old = sum(base.get(k, 0) for k in CATEGORIES) if category == 'forest-total' else base.get(category, 0)
        current = sum(counts.get(k, 0) for k in CATEGORIES) if category == 'forest-total' else counts.get(category, 0)
        require(old > 0, 'baseline forest category is absent or zero: ' + category)
        minimum = math.ceil(old * fraction)
        passed = current > 0 and current >= minimum
        areas[category] = {'baseline_vertices': old, 'actual_vertices': current,
                           'minimum_vertices': minimum, 'retained_fraction': current / old,
                           'estimated_area_world_units2': current * step * step,
                           'passed': passed}
        if not passed:
            failures.append(f'{category}: area {current} < required {minimum}, or zero')
    density_failures = []
    for category in CATEGORIES:
        m = metrics.get(category) if isinstance(metrics, dict) else None
        require(isinstance(m, dict), 'missing forest metrics: ' + category)
        require(type(m.get('count')) is int and m['count'] >= 0, 'invalid tree count: ' + category)
        if m['count'] == 0:
            density_failures.append(category + ': zero trees')
    policy = contract['density_policy']
    m = metrics[policy['category']]
    quantiles = m.get('nearest_quantiles')
    require(isinstance(quantiles, list) and len(quantiles) == 3 and
            all(number(v) and v >= 0 for v in quantiles) and quantiles == sorted(quantiles),
            'invalid forest distance quantiles')
    require(number(m.get('neighbors256')) and m['neighbors256'] >= 0, 'invalid neighbor density')
    if m['count'] < policy['minimum_count']:
        density_failures.append('interior tree count below historical minimum')
    if quantiles[1] > policy['maximum_median_distance']:
        density_failures.append('interior median tree distance above historical maximum')
    if m['neighbors256'] < policy['minimum_neighbors_256']:
        density_failures.append('interior neighbors256 below historical minimum')
    deviations = [abs(a / b - 1) for a, b in zip(quantiles, policy['reference_nearest_quantiles'])]
    if any(v > policy['maximum_relative_quantile_deviation'] for v in deviations):
        density_failures.append('interior distance quantile exceeds historical deviation')
    failures.extend(density_failures)
    return {'passed': not failures, 'area_passed': all(v['passed'] for v in areas.values()),
            'density_passed': not density_failures, 'areas': areas,
            'density': {'count': m['count'], 'nearest_quantiles': quantiles,
                        'neighbors256': m['neighbors256'], 'relative_deviations': deviations},
            'failures': failures}


def load_contract(path):
    path = Path(path).resolve()
    contract = read(path)
    require(contract.get('format') == FORMAT and contract.get('frozen_before_batch') is True,
            'unsupported or unfrozen habitat contract')
    require(contract.get('categories') == CATEGORIES, 'forest categories must retain interior and edge')
    require(contract.get('area_policy') == {'minimum_fraction': .8, 'reject_zero': True,
            'require_total': True}, 'v1 requires the unchanged 80 percent and nonzero area policy')
    require(contract.get('density_policy') == DENSITY, 'historical density criteria changed')
    geometry = contract.get('geometry', {})
    require(all(type(geometry.get(k)) is int and geometry[k] > 0 for k in
                ('width', 'height', 'vertex_resolution')), 'invalid acceptance geometry')
    refs, baseline = {}, contract.get('baseline', {})
    for key in ('physical_layers', 'forest_metrics', 'visual_review'):
        ref = baseline.get(key, {})
        require(isinstance(ref.get('path'), str), 'missing baseline reference: ' + key)
        target = (path.parent / ref['path']).resolve()
        require(digest(target) == ref.get('sha256'), 'baseline hash mismatch: ' + key)
        refs[key] = read(target)
    require(refs['physical_layers'].get('map_sha256') == baseline.get('map_sha256') ==
            refs['visual_review'].get('map_sha256') and
            refs['visual_review'].get('accepted_forge_views') is True,
            'baseline map identity or visual acceptance mismatch')
    require(compare(contract, refs['physical_layers'], refs['physical_layers'],
                    refs['forest_metrics'])['passed'], 'approved baseline fails its own contract')
    return contract, refs['physical_layers']


def audit_case(contract, baseline, directory, expected_sha=None):
    directory = Path(directory).resolve()
    row = {'directory': str(directory), 'status': 'failed', 'passed': False}
    try:
        files = {key: directory / name for key, name in
                 [('physical_layers', 'physical-layers.json'), ('forest_metrics', 'forest-metrics.json'),
                  ('validation', 'validation.json')]}
        layers, metrics, validation = (read(files[key]) for key in files)
        row['json_sha256'] = {key: digest(path) for key, path in files.items()}
        row['map_sha256'] = layers.get('map_sha256')
        require(validation.get('passed') is True and
                validation.get('map_sha256') == layers.get('map_sha256'),
                'case validation failed or references another map')
        require(expected_sha is None or expected_sha == layers.get('map_sha256'),
                'batch result references another physical map')
        require(validation.get('forest') == metrics, 'forest metrics differ from case validation')
        row.update(compare(contract, baseline, layers, metrics))
        row['status'] = 'passed' if row['passed'] else 'failed'
    except (OSError, ValueError, TypeError, KeyError) as error:
        row['failures'] = [str(error)]
    return row


def audit_batch(contract, baseline, directory):
    directory = Path(directory).resolve()
    manifest, batch = read(directory / 'manifest.json'), read(directory / 'batch.json')
    expected, actual = manifest.get('cases', []), batch.get('cases', [])
    require(manifest.get('format') == 'wc3-landform-batch-v1' and
            batch.get('format') == 'wc3-landform-batch-result-v1' and
            len(expected) == len(actual) == 9, 'a complete nine-case batch is required')
    require(batch.get('passed') is True and batch.get('status') == 'passed' and
            all(v.get('status') == 'passed' for v in actual), 'batch is incomplete or failed')
    recipes = {v['id']: v['command'] for v in manifest['recipes']}
    require(set(recipes.values()) <= {'generate', 'biome-generate'}, 'unknown batch command')
    require(len({v['id'] for v in expected}) == 9 and len({v['id'] for v in actual}) == 9,
            'duplicate batch case IDs')
    rows, tropical = [], 0
    for case in expected:
        matches = [v for v in actual if v['id'] == case['id']]
        require(len(matches) == 1, 'missing batch case: ' + case['id'])
        result = matches[0]
        require(all(result.get(k) == case.get(k) for k in ('recipe', 'seed', 'expected_output')),
                'batch case identity differs: ' + case['id'])
        require(type(case['seed']) is int and case['seed'] >= 0 and
                re.fullmatch('[a-z][a-z0-9-]*', case['recipe']), 'invalid batch case path')
        dest = directory / case['recipe'] / str(case['seed'])
        if recipes[case['recipe']] == 'generate':
            tropical += 1
            row = audit_case(contract, baseline, dest, result.get('map_sha256'))
        else:
            row = {'directory': str(dest), 'status': 'not-applicable',
                   'reason': 'Biome uses its own per-ID habitat-area and coverage inspector; this supplement grants no Biome pass.'}
        rows.append({'id': case['id'], 'recipe': case['recipe'], 'seed': case['seed'], **row})
    require(tropical == 3, 'this supplement expects exactly three tropical cases in the batch')
    return rows


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--contract', type=Path, required=True)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--case-dir', type=Path, action='append')
    group.add_argument('--batch-dir', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(argv)
    report = {'format': 'wc3-landform-habitat-audit-v1', 'passed': False,
              'scope': 'Supplemental tropical forest area and density only; no visual, native or game acceptance.',
              'cases': []}
    try:
        contract, baseline = load_contract(args.contract)
        report['contract_sha256'] = digest(args.contract)
        report['baseline_map_sha256'] = contract['baseline']['map_sha256']
        report['cases'] = (audit_batch(contract, baseline, args.batch_dir) if args.batch_dir else
                           [audit_case(contract, baseline, path) for path in args.case_dir])
        applicable = [v for v in report['cases'] if v['status'] != 'not-applicable']
        report['passed'] = bool(applicable) and all(v.get('passed') is True for v in applicable)
        report['applicable_cases'] = len(applicable)
    except (OSError, ValueError, TypeError, KeyError) as error:
        report['error'] = str(error)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(json.dumps({'passed': report['passed'], 'report': str(args.out),
                      'error': report.get('error'), 'applicable_cases': report.get('applicable_cases')}))
    return 0 if report['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
