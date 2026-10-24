"""Pure JSON contract tests. No map, MPQ, GUI or generator operations."""
from pathlib import Path
import copy
import importlib.util
import json
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('habitat_audit', Path(__file__).with_name('terrain-landform-habitat-audit.py'))
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class HabitatAuditTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.contract = {'format': audit.FORMAT, 'frozen_before_batch': True,
                         'categories': audit.CATEGORIES.copy(),
                         'geometry': {'width': 11, 'height': 11, 'vertex_resolution': 128},
                         'area_policy': {'minimum_fraction': .8, 'reject_zero': True, 'require_total': True},
                         'density_policy': copy.deepcopy(audit.DENSITY)}
        self.baseline = self.layers(50, 30)
        self.metrics = {'forest-interior': {'count': 40, 'nearest_quantiles': [8192**.5, 128, 128],
                                             'neighbors256': 5}, 'forest-edge': {'count': 20}}

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, path, data):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data), encoding='utf-8')

    def layers(self, interior, edge):
        dry = interior + edge
        return {'map_sha256': 'a'*64, 'vertex_resolution': 128,
                'dry': [True]*dry + [False]*(121-dry),
                'habitat_counts': {'forest-interior': interior, 'forest-edge': edge, 'water': 121-dry}}

    def case(self, directory, layers=None):
        layers = layers or self.baseline
        self.write(directory/'physical-layers.json', layers)
        self.write(directory/'forest-metrics.json', self.metrics)
        self.write(directory/'validation.json', {'passed': True, 'map_sha256': layers['map_sha256'], 'forest': self.metrics})

    def contract_file(self):
        self.contract['baseline'] = {'map_sha256': 'a'*64}
        for key, value in [('physical_layers', self.baseline), ('forest_metrics', self.metrics),
                           ('visual_review', {'map_sha256': 'a'*64, 'accepted_forge_views': True})]:
            path = self.root/(key+'.json')
            self.write(path, value)
            self.contract['baseline'][key] = {'path': path.name, 'sha256': audit.digest(path)}
        path = self.root/'contract.json'
        self.write(path, self.contract)
        return path

    def test_exact_eighty_percent_passes(self):
        result = audit.compare(self.contract, self.baseline, self.layers(40, 24), self.metrics)
        self.assertTrue(result['passed'])
        self.assertEqual(result['areas']['forest-total']['minimum_vertices'], 64)

    def test_insufficient_area_fails_even_with_valid_density_and_valid_total(self):
        result = audit.compare(self.contract, self.baseline, self.layers(39, 25), self.metrics)
        self.assertFalse(result['passed'])
        self.assertTrue(result['density_passed'])
        self.assertTrue(result['areas']['forest-total']['passed'])
        self.assertFalse(result['areas']['forest-interior']['passed'])

    def test_zero_area_is_rejected_despite_valid_density(self):
        result = audit.compare(self.contract, self.baseline, self.layers(80, 0), self.metrics)
        self.assertFalse(result['passed'])
        self.assertTrue(result['density_passed'])
        self.assertTrue(result['areas']['forest-total']['passed'])

    def test_density_fails_independently_of_area(self):
        metrics = copy.deepcopy(self.metrics)
        metrics['forest-interior']['neighbors256'] = 2.99
        result = audit.compare(self.contract, self.baseline, self.baseline, metrics)
        self.assertTrue(result['area_passed'])
        self.assertFalse(result['density_passed'])

    def test_missing_category_and_invalid_grid_fail_closed(self):
        layers = self.layers(40, 24)
        layers['dry'].pop()
        with self.assertRaisesRegex(ValueError, 'dry grid'):
            audit.compare(self.contract, self.baseline, layers, self.metrics)
        baseline = self.layers(80, 0)
        with self.assertRaisesRegex(ValueError, 'absent or zero'):
            audit.compare(self.contract, baseline, self.baseline, self.metrics)

    def test_contract_hash_and_minimum_cannot_be_relaxed(self):
        path = self.contract_file()
        audit.load_contract(path)
        self.contract['area_policy']['minimum_fraction'] = .79
        self.write(path, self.contract)
        with self.assertRaisesRegex(ValueError, '80 percent'):
            audit.load_contract(path)
        self.contract['area_policy']['minimum_fraction'] = .8
        self.write(path, self.contract)
        self.write(self.root/'physical_layers.json', self.layers(49, 30))
        with self.assertRaisesRegex(ValueError, 'hash mismatch'):
            audit.load_contract(path)

    def test_case_identity_and_metrics_are_bound_to_validation(self):
        directory = self.root/'case'
        self.case(directory)
        self.assertTrue(audit.audit_case(self.contract, self.baseline, directory)['passed'])
        self.assertFalse(audit.audit_case(self.contract, self.baseline, directory, 'b'*64)['passed'])
        metrics = copy.deepcopy(self.metrics)
        metrics['forest-interior']['count'] += 1
        self.write(directory/'forest-metrics.json', metrics)
        result = audit.audit_case(self.contract, self.baseline, directory)
        self.assertFalse(result['passed'])
        self.assertIn('differ', result['failures'][0])

    def test_batch_records_nine_and_only_grants_tropical_scope(self):
        manifest = {'format': 'wc3-landform-batch-v1', 'recipes': [], 'cases': []}
        batch = {'format': 'wc3-landform-batch-result-v1', 'passed': True, 'status': 'passed', 'cases': []}
        for recipe in ('riberas', 'claros', 'tropical'):
            manifest['recipes'].append({'id': recipe, 'command': 'generate' if recipe == 'tropical' else 'biome-generate'})
            for seed in (1, 2, 3):
                case = {'id': recipe+'-'+str(seed), 'recipe': recipe, 'seed': seed, 'expected_output': 'map.w3x'}
                manifest['cases'].append(case)
                batch['cases'].append({**case, 'status': 'passed', 'map_sha256': 'a'*64})
                if recipe == 'tropical':
                    self.case(self.root/recipe/str(seed))
        self.write(self.root/'manifest.json', manifest)
        self.write(self.root/'batch.json', batch)
        rows = audit.audit_batch(self.contract, self.baseline, self.root)
        self.assertEqual(len(rows), 9)
        self.assertEqual(sum(v['status'] == 'not-applicable' for v in rows), 6)
        self.assertEqual(sum(v.get('passed') is True for v in rows), 3)
        self.case(self.root/'tropical/3', self.layers(39, 25))
        self.assertFalse(audit.audit_batch(self.contract, self.baseline, self.root)[-1]['passed'])
        batch['cases'].pop()
        self.write(self.root/'batch.json', batch)
        with self.assertRaisesRegex(ValueError, 'complete nine-case'):
            audit.audit_batch(self.contract, self.baseline, self.root)


if __name__ == '__main__':
    unittest.main()
