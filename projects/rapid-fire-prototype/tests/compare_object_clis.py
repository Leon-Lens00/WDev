#!/usr/bin/env python3
"""Differential public CLI check against an explicit retained external baseline.

No git/history access. Baseline ROOT requires outputs beside that frozen package;
only reported evidence and owned copies are created. No message normalization.
"""
import argparse
import json
from pathlib import Path
from test_instant_controller import Session, TIMING, SUCCESS, ROOT, b, preserved


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--evidence', type=Path, required=True)
    a = p.parse_args()
    baseline = a.baseline.resolve()
    b.guard([a.evidence], [baseline, ROOT/'tools/prepare_objects.py'])
    a.evidence.mkdir(parents=True)
    package = baseline.parents[1]
    old = Session(package/'differential-old', baseline)
    new = Session(package/'differential-new', ROOT/'tools/prepare_objects.py')
    recipe = json.loads((ROOT/'base/objects.json').read_text())
    supported = dict(kind='unit', id='o001', field='uaen', level=0, value=0)
    cases = [('previous-recipe',recipe,None)]
    for label,change,error in [
        ('unknown', {'field':'xxxx'}, 'unknown or disallowed field'),
        ('kind', {'kind':'item'}, 'invalid owned object kind or id'),
        ('foreign-id', {'id':'o999'}, 'invalid owned object kind or id'),
        ('level', {'level':1}, 'invalid metadata level'),
        ('type', {'value':'0'}, 'value type does not match metadata')]:
        cases.append((label,[dict(supported,**change)],error))
    results = []
    for label,rows,error in cases:
        left,lo,ld = old.invoke(label,rows)
        right,ro,rd = new.invoke(label,rows)
        assert left == right, (label,left,right)
        if error is None:
            assert left == SUCCESS and lo.read_bytes() == ro.read_bytes()
        else:
            assert left == (1,b'',('error: '+error+'\n').encode())
            assert not any(p.exists() for p in (lo,ld,ro,rd))
        results.append(dict(case=label,exit_stdout_stderr_identical=True,
                            output_bytes_identical=error is None,inputs_unchanged=True))
    left,lo,ld = old.invoke('new-timing',TIMING)
    right,ro,rd = new.invoke('new-timing',TIMING)
    assert left == (1,b'',b'error: unknown or disallowed field\n') and not lo.exists() and not ld.exists()
    assert right == SUCCESS
    readback = preserved(new.before,ro.read_bytes())
    b.write_new(a.evidence/'comparison.json',b.json_bytes(dict(
        cases=results,intentional_new_fields_difference='old rejects; new accepts correctly typed controller-only ucpt/ucbs',
        readback=readback,stdout_stderr_path_normalization='NONE; common messages are byte-identical',
        baseline=str(baseline))))
    print('PASS: previous recipe output bytes and common rejection streams identical; new timing fields intentional')


if __name__ == '__main__':
    main()
