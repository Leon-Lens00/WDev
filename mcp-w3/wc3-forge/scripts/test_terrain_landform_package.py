"""Dependency relocation tests without MPQs, GUI access, or external tools."""
from pathlib import Path
import importlib.util
import json
import tempfile
import unittest

def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).parent / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

pkg = load('landform_package', 'terrain-landform-package.py')
repro = load('landform_reproduce', 'terrain-landform-reproduce.py')

class RelocationTests(unittest.TestCase):
    def test_preserves_physical_sha_and_rebinds_runtime_donor(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            original, package, relocated, out = (root/name for name in ['original','package','relocated','out'])
            original.mkdir()
            donor = original/'donor.w3x'
            donor.write_bytes(b'test archive placeholder; no archive reader needed')
            plan, profile = original/'plan.json', original/'physical-profile.json'
            pkg.write(plan, {'format':'wc3-landform-plan-v1','features':[]})
            pkg.write(profile, {'format':'wc3-landform-profile-v1', 'donor':{'path':str(donor),'sha256':pkg.sha(donor)}})
            runtime = original/'runtime-profile.json'
            pkg.write(runtime, {'source':'donor.w3x','source_sha256':pkg.sha(donor),'install':'unbundled Classic'})
            recipe = original/'recipe.json'
            pkg.write(recipe, {'profile':{'path':'runtime-profile.json','sha256':pkg.sha(runtime)},
                'landforms':{'plan':{'path':'plan.json','sha256':pkg.sha(plan)},
                            'profile':{'path':'physical-profile.json','sha256':pkg.sha(profile)}}})
            expected_profile, expected_plan = pkg.sha(profile), pkg.sha(plan)
            mapping, immutable = pkg.collect_inputs([recipe], package)
            # Force binding to use packaged references even after original and
            # package locations disappear. The original drive is not a fallback.
            recipe_id = str(recipe.resolve())
            package.rename(relocated)
            original.rename(root/'original-offline')
            binder = repro.InputBinder(relocated,out,root/'classic',{'path_map':mapping,'immutable_json':immutable})
            resolved = repro.read(binder.bind(recipe_id))
            self.assertEqual(resolved['landforms']['profile']['sha256'], expected_profile)
            self.assertEqual(resolved['landforms']['plan']['sha256'], expected_plan)
            self.assertEqual(pkg.sha(Path(resolved['landforms']['profile']['path'])), expected_profile)
            runtime_copy = repro.read(Path(resolved['profile']['path']))
            self.assertTrue(Path(runtime_copy['source']).is_file())
            self.assertEqual(runtime_copy['source_sha256'],pkg.sha(Path(runtime_copy['source'])))
            self.assertEqual(runtime_copy['install'],str(root/'classic'))
            self.assertEqual(resolved['profile']['sha256'],pkg.sha(Path(resolved['profile']['path'])))

    def test_rejects_runtime_dependency_cycles(self):
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder);a=root/'a.json';b=root/'b.json'
            pkg.write(a,{'other':str(b)});pkg.write(b,{'other':str(a)})
            mapping,immutable=pkg.collect_inputs([a],root/'package')
            binder=repro.InputBinder(root/'package',root/'out',root/'classic',{'path_map':mapping,'immutable_json':immutable})
            with self.assertRaisesRegex(ValueError,'Cyclic runtime'):
                binder.bind(str(a.resolve()))

if __name__=='__main__':
    unittest.main()
