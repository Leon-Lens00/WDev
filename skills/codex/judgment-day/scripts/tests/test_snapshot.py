import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('snapshot', Path(__file__).parents[1] / 'snapshot.py')
snapshot = importlib.util.module_from_spec(spec)
spec.loader.exec_module(snapshot)


class SnapshotTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.source = self.base / 'source'; self.source.mkdir()
        (self.source / 'spell.j').write_text('function F takes nothing returns nothing\nendfunction\n')
        self.dest = self.base / 'review'

    def freeze(self):
        return snapshot.create(self.source, self.dest, ['spell.j'])['tree_sha256']

    def test_roundtrip_preserves_source_and_rejects_changed_copy(self):
        original = (self.source / 'spell.j').read_bytes()
        identity = self.freeze()
        self.assertTrue(snapshot.verify(self.dest, identity)['verified'])
        (self.dest / 'spell.j').chmod(0o644)
        (self.dest / 'spell.j').write_text('changed')
        with self.assertRaises(ValueError): snapshot.verify(self.dest, identity)
        self.assertEqual((self.source / 'spell.j').read_bytes(), original)

    def test_added_or_removed_files_invalidate_review(self):
        identity = self.freeze()
        extra = self.dest / 'extra.j'; extra.write_text('extra')
        with self.assertRaises(ValueError): snapshot.verify(self.dest, identity)
        extra.unlink(); (self.dest / 'spell.j').unlink()
        with self.assertRaises(ValueError): snapshot.verify(self.dest, identity)

    def test_replaced_manifest_does_not_replace_parent_identity(self):
        identity = self.freeze()
        target = self.dest / 'spell.j'; target.chmod(0o644); target.write_text('new bytes')
        marker = self.dest / snapshot.MARKER; marker.chmod(0o644)
        manifest = json.loads(marker.read_text())
        manifest['files']['spell.j'] = snapshot.digest(target.read_bytes())
        manifest['tree_sha256'] = snapshot.tree_id(manifest['files'])
        marker.write_text(json.dumps(manifest))
        with self.assertRaises(ValueError): snapshot.verify(self.dest, identity)

    def test_source_and_snapshot_symlinks_are_rejected(self):
        (self.source / 'link.j').symlink_to(self.source / 'spell.j')
        with self.assertRaises(ValueError): snapshot.create(self.source, self.dest, ['link.j'])
        identity = self.freeze()
        (self.dest / 'link.j').symlink_to(self.source / 'spell.j')
        with self.assertRaises(ValueError): snapshot.verify(self.dest, identity)

    def test_escape_recursion_duplicates_and_existing_output_are_rejected(self):
        for files in [['../outside.j'], ['/etc/passwd'], ['spell.j', './spell.j']]:
            with self.subTest(files=files), self.assertRaises(ValueError): snapshot.create(self.source, self.dest, files)
        with self.assertRaises(ValueError): snapshot.create(self.source, self.source / 'review', ['spell.j'])
        self.freeze()
        with self.assertRaises(ValueError): snapshot.create(self.source, self.dest, ['spell.j'])

    def test_source_size_limit_is_explicit(self):
        (self.source / 'large.j').write_bytes(b'x' * (snapshot.MAX_FILE + 1))
        with self.assertRaises(ValueError): snapshot.create(self.source, self.dest, ['large.j'])

    def test_reserved_name_rejected_before_destination_is_created(self):
        nested = self.source / 'sub'; nested.mkdir()
        (nested / snapshot.MARKER).write_text('{}')
        with self.assertRaises(ValueError): snapshot.create(self.source, self.dest, ['sub/' + snapshot.MARKER])
        self.assertFalse(self.dest.exists())

    def test_non_object_manifest_is_a_controlled_error(self):
        identity = self.freeze()
        marker = self.dest / snapshot.MARKER; marker.chmod(0o644)
        for data in [[], None, 'invalid']:
            marker.write_text(json.dumps(data))
            with self.subTest(data=data), self.assertRaises(ValueError): snapshot.verify(self.dest, identity)

    def test_changed_original_invalidates_current_candidate(self):
        identity = self.freeze()
        self.assertTrue(snapshot.verify_source(self.source, self.dest, identity)['source_matches'])
        (self.source / 'spell.j').write_text('new source version')
        self.assertTrue(snapshot.verify(self.dest, identity)['verified'])
        with self.assertRaises(ValueError): snapshot.verify_source(self.source, self.dest, identity)


if __name__ == '__main__': unittest.main()
