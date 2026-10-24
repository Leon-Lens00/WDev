"""Contract and own-process accounting tests; never generate maps or open GUIs."""
from pathlib import Path
import copy, importlib.util, json, os, subprocess, sys, tempfile, time, unittest

spec=importlib.util.spec_from_file_location('landform_batch',Path(__file__).with_name('terrain-landform-batch.py'))
batch=importlib.util.module_from_spec(spec);spec.loader.exec_module(batch)

class ManifestTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.seeds={'riberas':[62100,62200,62300],'claros':[63100,63200,63300],'tropical':[52700,52701,52702]}
        batch.write(self.root/'criteria.json',{'format':'wc3-landform-criteria-v1','frozen_before_batch':True,'seeds':self.seeds})
        self.m={'format':batch.FORMAT,'criteria':{'path':'criteria.json','sha256':batch.digest(self.root/'criteria.json')},'recipes':[],'cases':[]}
        for rid,seeds in self.seeds.items():
            if rid=='tropical':
                q={'format':'wc3-scene-spec-v4','mode':'whole-map-landscape','landscape':{'landforms':{'strategy':'test-only'},'materials':{'profile':'test-only'},'brief':{'format':'wc3-landscape-brief-v1','id':'D','seeds':seeds+[52703]}}};cmd='generate'
            else:q={'format':'wc3-territory-recipe-v1','realizer':'landforms-cohorts-v1','id':'Ashenvale-'+rid.title(),'seeds':seeds};cmd='biome-generate'
            p=self.root/(rid+'.json');batch.write(p,q)
            self.m['recipes'].append({'id':rid,'path':p.name,'sha256':batch.digest(p),'command':cmd})
            for seed in seeds:
                self.m['cases'].append({'id':f'{rid}-{seed}','recipe':rid,'seed':seed,'expected_output':f'Tropical-D-{seed}.w3x' if rid=='tropical' else f"paint/{q['id']}-base-materials.w3x"})
        self.path=self.root/'cases.json';batch.write(self.path,self.m)
    def tearDown(self):self.tmp.cleanup()
    def validate(self):batch.write(self.path,self.m);return batch.load_manifest(self.path)
    def test_exact_nine_and_legacy_four_untouched(self):
        before=batch.digest(self.root/'tropical.json');m,recipes,_=self.validate()
        self.assertEqual(len(m['cases']),9);self.assertEqual(recipes['tropical']['declared_seeds'],[52700,52701,52702,52703]);self.assertEqual(before,batch.digest(self.root/'tropical.json'))
        self.assertEqual([c['seed'] for c in m['cases'] if c['recipe']=='tropical'],[52700,52701,52702])
    def test_duplicate_case_id(self):
        self.m['cases'][1]['id']=self.m['cases'][0]['id']
        with self.assertRaisesRegex(ValueError,'case id'):self.validate()
    def test_duplicate_seed_case(self):
        self.m['cases'][1]['seed']=62100
        with self.assertRaisesRegex(ValueError,'duplicate recipe/seed'):self.validate()
    def test_seed_not_declared(self):
        self.m['cases'][0]['seed']=42
        with self.assertRaisesRegex(ValueError,'seed not declared'):self.validate()
    def test_no_legacy_list_truncation(self):
        p=self.root/'tropical.json';q=batch.read(p);q['landscape']['brief']['seeds'].pop();batch.write(p,q);self.m['recipes'][2]['sha256']=batch.digest(p)
        with self.assertRaisesRegex(ValueError,'seed count'):self.validate()
    def test_no_tenth_case_or_missing_case(self):
        self.m['cases'].pop()
        with self.assertRaisesRegex(ValueError,'nine cases'):self.validate()
    def test_non_generation_command_rejected(self):
        self.m['recipes'][0]['command']='harness'
        with self.assertRaisesRegex(ValueError,'command'):self.validate()
    def test_changed_recipe_hash(self):
        q=batch.read(self.root/'riberas.json');q['id']='Changed';batch.write(self.root/'riberas.json',q)
        with self.assertRaisesRegex(ValueError,'hash mismatch'):self.validate()
    def test_path_escape_rejected(self):
        self.m['cases'][0]['expected_output']='../original.w3x'
        with self.assertRaisesRegex(ValueError,'unsafe'):self.validate()
    def test_unknown_field_rejected(self):
        self.m['retry_until_success']=True
        with self.assertRaisesRegex(ValueError,'unknown fields'):self.validate()
    def test_selected_fourth_tropical_seed_not_frozen(self):
        self.m['cases'][-1]['seed']=52703;self.m['cases'][-1]['expected_output']='Tropical-D-52703.w3x'
        with self.assertRaisesRegex(ValueError,'frozen criteria'):self.validate()

@unittest.skipUnless(os.name=='nt','Windows own-process memory API')
class WindowsAccountingTests(unittest.TestCase):
    def test_peak_and_owned_job_cleanup(self):
        p=subprocess.Popen([sys.executable,'-c','import time; data=bytearray(8*1024*1024); time.sleep(3)'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,creationflags=subprocess.CREATE_NO_WINDOW)
        metrics=None
        try:
            metrics=batch.WindowsMetrics(p)
            for _ in range(4):time.sleep(.1);metrics.sample()
            self.assertGreater(metrics.peak or 0,0);self.assertGreater(metrics.job_peak or 0,0)
            metrics.terminate();self.assertNotEqual(p.wait(timeout=5),0)
        finally:
            if metrics:metrics.close()
            if p.poll() is None:p.kill();p.wait(timeout=5)

if __name__=='__main__':unittest.main()
