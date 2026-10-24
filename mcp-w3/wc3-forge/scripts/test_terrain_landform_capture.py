import base64
import copy
import importlib.util
from pathlib import Path
import struct
import unittest

spec = importlib.util.spec_from_file_location('capture', Path(__file__).with_name('terrain-landform-capture.py'))
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)


class CaptureContractTests(unittest.TestCase):
    def setUp(self):
        self.e = dict(version=1, loaded=True, path=str(Path('map.w3x').resolve()), loaded_sha256='a' * 64,
                      revision=4, load_generation=2, dirty=False, io_pending=0)
        self.pose = dict(x=0, y=0, z=400, pitch=1.5707963267948966, yaw=0,
                         distance=5000, projection='orthographic', ortho_height=7000, fov=1)
        self.framed = dict(state=self.pose, frame=20)
        self.r = dict(evidence=self.e, rendered_evidence=self.e, renderer_evidence_version=1,
                      runtime=dict(pid=42, sha256='build'), camera=self.pose, frame=22,
                      width=4, height=3, viewport_width=8, viewport_height=6,
                      bytes_base64=base64.b64encode(b'\x89PNG\r\n\x1a\n' + struct.pack('>I',13)+b'IHDR'+struct.pack('>II',4,3)).decode(),
                      diagnostics=dict(crashed=False,last_gl_error=0,has_terrain=True,has_water=True,
                          doodad_model_fails=0,unit_model_fails=0,viewer_errors=0,viewer_error_details=[],
                          water_frames_loaded=30,water_frames_expected=30,terrain_width=129,terrain_height=129,
                          center_offset=[-7680,-8704],namespaces=dict(terrain=dict(atlasStatus='ok',paletteFails=0,fboIncompleteFails=0),
                              cliffs=dict(lastPlaced=0,lastFailedCells=0,meshMissPaths=0,paletteFails=0))))

    def validate(self, r=None, after=None, allowed=()):
        return capture.validate_capture(r or self.r, self.e, after or self.e, self.framed,
                                        42,'build',allowed,True,dict(width=129,height=129,center_offset=[-7680,-8704]))

    def test_valid_capture(self):
        capture.check_evidence(self.e,Path('map.w3x'),'a'*64)
        self.assertTrue(self.validate().startswith(b'\x89PNG'))

    def test_identity_failures(self):
        for patch in [dict(dirty=True),dict(version=0),dict(path='another.w3x'),dict(loaded_sha256='b'*64),
                      dict(io_pending=1),dict(identity_error='failed-save')]:
            with self.subTest(patch=patch), self.assertRaises(ValueError):
                capture.check_evidence(dict(self.e,**patch),Path('map.w3x'),'a'*64)

    def test_rejects_stale_wrong_or_changed_capture(self):
        patches=[dict(renderer_evidence_version=0),dict(frame=20),dict(runtime=dict(pid=43,sha256='build')),
                 dict(runtime=dict(pid=42,sha256='old-build')),dict(camera=dict(self.pose,x=128)),
                 dict(rendered_evidence=dict(self.e,revision=3)),dict(width=9)]
        for patch in patches:
            with self.subTest(patch=patch),self.assertRaises(ValueError):
                self.validate(dict(self.r,**patch))
        with self.assertRaises(ValueError):
            self.validate(after=dict(self.e,revision=5))

    def test_missing_models_water_textures_geometry_and_error_identity(self):
        for patch in [dict(doodad_model_fails=1),dict(unit_model_fails=1),dict(has_water=False),
                      dict(water_frames_loaded=29),dict(terrain_width=193),dict(last_gl_error=1282),
                      dict(crashed=True),dict(viewer_errors=1),
                      dict(namespaces=dict(terrain=dict(atlasStatus='ok',paletteFails=1,fboIncompleteFails=0)))]:
            r=copy.deepcopy(self.r);r['diagnostics'].update(patch)
            with self.subTest(patch=patch),self.assertRaises(ValueError): self.validate(r)
        r=copy.deepcopy(self.r);r['diagnostics'].update(viewer_errors=1,viewer_error_details=['known plank fallback'])
        with self.assertRaises(ValueError): self.validate(r)
        self.assertTrue(self.validate(r,allowed=['known plank fallback']))
        r['diagnostics']['viewer_error_details']=['new failure']
        with self.assertRaises(ValueError): self.validate(r,allowed=['known plank fallback'])

    def test_allowing_a_lookup_probe_never_allows_missing_cliff_cells(self):
        r=copy.deepcopy(self.r)
        r['diagnostics'].update(viewer_errors=1,viewer_error_details=['known variation probe'])
        self.assertTrue(self.validate(r,allowed=['known variation probe']))
        for field in ['lastFailedCells','meshMissPaths','paletteFails']:
            broken=copy.deepcopy(r)
            broken['diagnostics']['namespaces']['cliffs'][field]=1
            with self.subTest(field=field), self.assertRaises(ValueError):
                self.validate(broken,allowed=['known variation probe'])


if __name__ == '__main__':
    unittest.main()
