"""Manual recorder public tooling contracts; never gameplay certification."""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
import re
from unittest.mock import patch
from pathlib import Path
import subprocess
import unittest

import test_build as fixtures

PROJECT = fixtures.TOOL.parents[1]
MANUAL = PROJECT / 'src/manual'
READER = PROJECT / 'tools/read_manual_logs.py'


def row(seq, event, data, *, stamp=None):
    return 'IL141M|manual-001|fresh_label|%d|%d|%d|recorder|%s|%s' % (
        (seq - 1) // 128, seq, seq if stamp is None else stamp, event, data)


class ManualTests(fixtures.CliTests):
    # Inherited public CLI tests are intentional preservation checks.
    def manual_arguments(self):
        self.base.write_bytes(fixtures.map_bytes((PROJECT / 'baseline/members/war3map.j').read_bytes()))
        args = self.arguments()
        for flag, value in (('--globals', MANUAL / 'globals.j'), ('--functions', MANUAL / 'functions.j'),
                            ('--entry', 'ILM_Init')):
            args[args.index(flag) + 1] = str(value)
        return args + ['--early-functions', str(MANUAL / 'early.j'), '--hooks', str(MANUAL / 'hooks.json')]

    def test_manual_insertion_strip_restores_every_original_byte(self):
        args = self.manual_arguments()
        before = self.base.read_bytes()
        code, out, err = self.invoke(args)
        self.assertEqual((code, err), (0, ''))
        report = json.loads(out)
        script = (self.root / 'runs/inv-001/assembled.j').read_bytes()
        stripped = script
        for span in reversed(report['insertions']):
            data = stripped[span['offset']:span['offset'] + span['size']]
            self.assertEqual(hashlib.sha256(data).hexdigest(), span['sha256'])
            stripped = stripped[:span['offset']] + stripped[span['offset'] + span['size']:]
        self.assertEqual(stripped, (PROJECT / 'baseline/members/war3map.j').read_bytes())
        self.assertEqual(self.base.read_bytes(), before)
        self.assertLess(script.index(b'function ILM_Log '), script.index(b'function InventoryCore___LClickItemSlot '))
        self.assertEqual(script.count(b'call ILM_Init()'), 1)
        self.assertNotIn(b'call IL_Start()', script)
        self.assertEqual(self.calls, [])

    def test_manual_manifest_drift_fails_without_publication(self):
        args = self.manual_arguments()
        original = (PROJECT / 'baseline/members/war3map.j').read_bytes()
        self.base.write_bytes(fixtures.map_bytes(original + b'// drift'))
        before = self.base.read_bytes()
        self.assertEqual(self.invoke(args), (1, '', 'error: invalid manual hooks\n'))
        self.assertEqual(self.base.read_bytes(), before)
        self.assertFalse((self.root / 'runs').exists())

    def test_manual_manifest_anchor_function_and_count_fail_closed(self):
        args = self.manual_arguments()
        manifest = json.loads((MANUAL / 'hooks.json').read_text())
        path = self.root / 'hooks.json'
        args[-1] = str(path)
        for field, value in (('sha256', '0' * 64), ('name', 'AbsentFunction')):
            changed = json.loads(json.dumps(manifest))
            changed['functions'][0][field] = value
            path.write_text(json.dumps(changed))
            self.assertEqual(self.invoke(args), (1, '', 'error: invalid manual hooks\n'))
        for field, value in (('anchor', 'absent'), ('count', 2)):
            changed = json.loads(json.dumps(manifest))
            changed['functions'][0]['hooks'][0][field] = value
            path.write_text(json.dumps(changed))
            self.assertEqual(self.invoke(args), (1, '', 'error: invalid manual hooks\n'))
        self.assertFalse((self.root / 'runs').exists())

    def test_reader_complete_partial_and_overflow(self):
        for terminal, expected in (('USER_STOP', 0), ('OVERFLOW', 1), (None, 1)):
            with self.subTest(terminal=terminal):
                rows = [row(1, 'BEGIN', 'schema=1')]
                if terminal:
                    rows.append(row(2, 'TERMINAL', 'reason=%s rows=2 dropped=%d' % (
                        terminal, int(terminal == 'OVERFLOW'))))
                directory = self.root / str(terminal)
                directory.mkdir()
                self.chunk(directory, 0, rows)
                result = self.read_cli(directory)
                self.assertEqual((result.returncode, result.stderr), (expected, ''))
                report = json.loads(result.stdout)
                self.assertEqual(report['status'], 'observation_complete' if expected == 0 else 'partial')
                self.assertFalse(report['semantic_certification'])

    def chunk(self, directory, index, rows):
        path = directory / ('IL141M-manual-001--fresh_label--%d.pld' % index)
        path.write_text('function PreloadFiles takes nothing returns nothing\n' + ''.join(
            ' call Preload( "' + r + '" )\n' for r in rows) + 'endfunction\n')
        return path

    def read_cli(self, path, *extra):
        return subprocess.run([os.sys.executable, '-B', str(READER), str(path), '--run-id', 'manual-001',
                               '--session', 'fresh_label', '--not-before', '0', *map(str, extra)],
                              capture_output=True, text=True, timeout=20)

    def test_reader_rejection_preserves_inputs_and_existing_report(self):
        directory = self.root / 'logs'
        directory.mkdir()
        path = self.chunk(directory, 0, [row(1, 'BEGIN', 'schema=1'),
                                         row(2, 'TERMINAL', 'reason=USER_STOP rows=2 dropped=0')])
        original = path.read_bytes()
        report = self.root / 'existing.json'
        report.write_bytes(b'existing report')
        result = self.read_cli(directory, '--report', report)
        self.assertEqual((result.returncode, result.stdout, result.stderr), (2, '', 'error: invalid manual evidence\n'))
        self.assertEqual(path.read_bytes(), original)
        self.assertEqual(report.read_bytes(), b'existing report')

    def test_reader_negative_protocol_rules(self):
        good = [row(1, 'BEGIN', 'schema=1'), row(2, 'TERMINAL', 'reason=USER_STOP rows=2 dropped=0')]
        cases = {
            'row-order': [good[0], row(3, 'MARK', 'manual')],
            'time-backwards': [row(1, 'BEGIN', 'schema=1', stamp=5), good[1]],
            'counter': [good[0], row(2, 'TERMINAL', 'reason=USER_STOP rows=3 dropped=0')],
            'false-complete': [good[0], row(2, 'TERMINAL', 'reason=USER_STOP rows=2 dropped=1')],
            'unknown-reason': [good[0], row(2, 'TERMINAL', 'reason=SUCCESS rows=2 dropped=0')],
            'unsafe': [good[0], row(2, 'MARK', 'bad\\path')],
            'trailing-row': good + [row(3, 'MARK', 'manual')],
            'oversize-field': [good[0], row(2, 'MARK', 'x' * 161)],
            'wrong-session': [good[0].replace('fresh_label', 'other')],
        }
        for name, rows in cases.items():
            directory = self.root / name
            directory.mkdir()
            path = self.chunk(directory, 0, rows)
            before = path.read_bytes()
            report = self.root / (name + '.json')
            result = self.read_cli(directory, '--report', report)
            self.assertEqual((result.returncode, result.stdout, result.stderr), (2, '', 'error: invalid manual evidence\n'), name)
            self.assertEqual(path.read_bytes(), before)
            self.assertFalse(report.exists())

    def test_reader_chunk_capacity_natural_order_and_terminals(self):
        directory = self.root / 'capacity'
        directory.mkdir()
        for index in range(64):
            rows = [row(seq, 'BEGIN' if seq == 1 else 'MARK', 'schema=1' if seq == 1 else 'manual')
                    for seq in range(index * 128 + 1, (index + 1) * 128 + 1)]
            if index == 63:
                rows[-1] = row(8192, 'TERMINAL', 'reason=OVERFLOW rows=8192 dropped=1')
            self.chunk(directory, index, rows)
        result = self.read_cli(directory)
        self.assertEqual((result.returncode, result.stderr), (1, ''))
        report = json.loads(result.stdout)
        self.assertEqual((report['rows'], report['chunks'], report['terminal']),
                         (8192, 64, {'reason': 'OVERFLOW', 'rows': 8192, 'dropped': 1}))
        self.assertEqual([r['sequence'] for r in report['observations']], list(range(1, 8193)))
        self.assertEqual(result.stdout, json.dumps(report, indent=2, ensure_ascii=True) + '\n')
        # A complete observation may also end exactly at the reserved final row.
        path = directory / 'IL141M-manual-001--fresh_label--63.pld'
        path.write_bytes(path.read_bytes().replace(b'OVERFLOW rows=8192 dropped=1', b'USER_STOP rows=8192 dropped=0'))
        result = self.read_cli(directory)
        self.assertEqual((result.returncode, result.stderr), (0, ''))

    def test_reader_directory_selection_manifest_and_exclusive_output(self):
        directory = self.root / 'selected'
        directory.mkdir()
        selected = self.chunk(directory, 0, [row(1, 'BEGIN', 'schema=1'),
                                             row(2, 'TERMINAL', 'reason=USER_STOP rows=2 dropped=0')])
        (directory / 'IL141M-manual-001--fresh_label--other--0.pld').write_bytes(b'other session data')
        (directory / 'IL141M-other--fresh_label--0.pld').write_bytes(b'other build data')
        manifest = directory / 'session.json'
        manifest.write_text(json.dumps({'chunks': [selected.name]}))
        output = self.root / 'new-report.json'
        result = self.read_cli(manifest, '--report', output)
        self.assertEqual((result.returncode, result.stderr), (0, ''))
        self.assertEqual(output.read_text(), result.stdout)
        from_directory = self.read_cli(directory)
        self.assertEqual((from_directory.returncode, from_directory.stdout, from_directory.stderr),
                         (0, result.stdout, ''))

    def test_reader_filesystem_and_chunk_rejections_preserve_bytes(self):
        good = [row(1, 'BEGIN', 'schema=1'), row(2, 'TERMINAL', 'reason=USER_STOP rows=2 dropped=0')]
        for case in ('missing', 'duplicate', 'trailing', 'leading-zero', 'oversize', 'stale',
                     'unsafe-wrapper', 'symlink', 'hardlink', 'report-alias', 'manifest-path', 'nonfinite'):
            with self.subTest(case=case):
                directory = self.root / case
                directory.mkdir()
                path = self.chunk(directory, 0, good)
                target = directory
                extra = []
                if case == 'missing':
                    path.rename(directory / path.name.replace('--0.pld', '--1.pld'))
                elif case == 'duplicate':
                    target = directory / 'manifest.json'
                    target.write_text(json.dumps({'chunks': [path.name, path.name]}))
                elif case == 'trailing':
                    self.chunk(directory, 1, [row(129, 'MARK', 'manual')])
                elif case == 'leading-zero':
                    path.rename(directory / path.name.replace('--0.pld', '--00.pld'))
                elif case == 'oversize':
                    path.write_bytes(b'x' * 65537)
                elif case == 'stale':
                    extra = ['--not-before', '999999999999']
                elif case == 'unsafe-wrapper':
                    path.write_bytes(path.read_bytes().replace(b'endfunction', b'call ExecuteFunc("evil")\nendfunction'))
                elif case == 'symlink':
                    other = directory / 'data'
                    path.rename(other)
                    path.symlink_to(other)
                elif case == 'hardlink':
                    os.link(path, directory / 'alias')
                elif case == 'report-alias':
                    extra = ['--report', path]
                elif case == 'manifest-path':
                    target = directory / 'manifest.json'
                    target.write_text(json.dumps({'chunks': ['../' + path.name]}))
                elif case == 'nonfinite':
                    extra = ['--not-before', 'nan']
                before = {p: p.read_bytes() for p in directory.iterdir() if p.is_file()}
                result = self.read_cli(target, *extra)
                self.assertEqual((result.returncode, result.stdout, result.stderr),
                                 (2, '', 'error: invalid manual evidence\n'))
                self.assertEqual({p: p.read_bytes() for p in before}, before)

    def test_manual_optional_pair_and_input_guards(self):
        args = self.manual_arguments()
        self.assertEqual(self.invoke(args[:-2]),
                         (1, '', 'error: manual mode requires --early-functions and --hooks together\n'))
        self.assertFalse((self.root / 'runs').exists())
        hook = self.root / 'alias.json'
        hook.symlink_to(MANUAL / 'hooks.json')
        args[-1] = str(hook)
        self.assertEqual(self.invoke(args), (1, '', 'error: symlink input: ' + str(hook) + '\n'))
        self.assertFalse((self.root / 'runs').exists())

    def test_manifest_return_and_page_and_pickup_coverage(self):
        original = (PROJECT / 'baseline/members/war3map.j').read_bytes()
        manifest = json.loads((MANUAL / 'hooks.json').read_text())
        plans = self.module.manual_hooks(original, manifest)
        for name, count in (('equip', 10), ('unequip', 2)):
            self.assertEqual(sum(payload.count(('ILM_Log("' + name + '", "RETURN"').encode())
                                 for _, payload in plans), count)
        self.assertEqual(sum(b'"SHOWN"' in payload for _, payload in plans), 2)
        pickup = original.index(b'            call RemoveItem(itm)')
        self.assertIn(pickup, [offset for offset, _ in plans])
        early = (MANUAL / 'early.j').read_text()
        for forbidden in ('s__', 'Create', 'TriggerEvaluate', 'Preload', 'GetRandom', 'GetLocalPlayer'):
            self.assertNotIn(forbidden, early)
        self.assertIn('ILM_QUEUE_ROWS - 1', early)
        self.assertIn('ILM_CHUNK_ROWS * ILM_MAX_CHUNKS - 1', early)
        late = (MANUAL / 'functions.j').read_text()
        self.assertIn('ILM_ChunkCount == ILM_CHUNK_ROWS', late)
        self.assertIn('set ILM_ChunkIndex = ILM_ChunkIndex + 1', late)
        self.assertIn('if ILM_Used then', late)
        self.assertIn('if not ILM_Active then', late)

    def test_manual_flag_remains_invalid_on_sibling_recover(self):
        args = ['recover', '--map', str(self.base), '--project', str(self.root / 'recovery'),
                '--expected-sha256', self.module.digest(self.base.read_bytes()),
                '--early-functions', str(self.globals)]
        before = self.base.read_bytes()
        out, err = io.StringIO(), io.StringIO()
        with patch.object(os.sys, 'argv', ['build.py']), contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            with self.assertRaises(SystemExit) as stopped:
                self.module.main(args, archive_factory=fixtures.Archive, runner=self.runner)
        self.assertEqual(stopped.exception.code, 2)
        self.assertEqual(out.getvalue(), '')
        self.assertEqual(err.getvalue(), 'usage: build.py [-h] {recover,assemble,build} ...\n'
                         'build.py: error: unrecognized arguments: --early-functions ' + str(self.globals) + '\n')
        self.assertEqual(self.base.read_bytes(), before)
        self.assertFalse((self.root / 'recovery').exists())
        self.assertEqual(self.calls, [])

    def test_recorder_declaration_order_and_public_snapshot_surface(self):
        sources = (MANUAL / 'early.j').read_text() + (MANUAL / 'functions.j').read_text()
        declarations = re.findall(r'^function (\w+) takes', sources, re.M)
        self.assertEqual(len(declarations), len(set(declarations)))
        self.assertTrue(all(name.startswith('ILM_') for name in declarations))
        for match in re.finditer(r'\b(ILM_\w+)\(', sources):
            self.assertLess(sources.index('function ' + match[1] + ' takes'), match.start())
        for match in re.finditer(r'function (ILM_\w+)\)', sources):
            self.assertLess(sources.index('function ' + match[1] + ' takes'), match.start())
        sample = sources.split('function ILM_Sample takes', 1)[1].split('endfunction', 1)[0]
        self.assertEqual(set(re.findall(r'\bs__\w+', sample)),
                         {'s__Inventory_getItem', 's__Inventory_getItemId'})
        self.assertIn('itemValue != ILM_Items[i] or customValue != ILM_Custom[i]', sample)
        self.assertIn('exitwhen i == 150 or not ILM_Active', sample)

    def test_source_observational_contract(self):
        sources = '\n'.join((MANUAL / n).read_text() for n in ('globals.j', 'early.j', 'functions.j'))
        for forbidden in ('CreateItem(', 'CreateUnit(', 'SetPlayerState(', 'SetHeroStr(', 'IssuePointOrder(',
                          's___Equipment_', 's__InvItem_tempCustomId', 'GetRandomInt(', 'IL_Start'):
            self.assertNotIn(forbidden, sources)
        for command in ('-im start <label>', '-im status', '-im mark', '-im save', '-im stop'):
            self.assertIn(command, sources)
        hooks = (MANUAL / 'hooks.json').read_text()
        for name in ('AcquireItem___Actions', 'InventoryCore___LClickItemSlot', 's__Equipment_equip',
                     's__Equipment_unequip', 'YesNoDialog___OnClick', 'SellItem___Actions',
                     'SellItem___OnAgree', 'DropItem___Actions', 'DropItem___OnAgree',
                     'SocketItem___Actions', 'SocketItem___OnAgree'):
            self.assertIn(name, hooks)


if __name__ == '__main__':
    unittest.main()
