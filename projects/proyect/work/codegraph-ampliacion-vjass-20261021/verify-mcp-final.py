from pathlib import Path
import json, subprocess, queue, threading, time, sqlite3, hashlib

BASE = Path(__file__).resolve().parent
INPUTS = json.loads((BASE / 'real-sources.json').read_text())
stderr = (BASE / 'mcp-final-stderr.log').open('w')
proc = subprocess.Popen(['/home/snz/.local/bin/codegraph', 'serve', '--mcp'], cwd=BASE.parents[1], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=stderr, text=True)
messages = queue.Queue()
def read():
    for line in proc.stdout:
        try: messages.put(json.loads(line))
        except ValueError: pass
threading.Thread(target=read, daemon=True).start()
sequence = 0
def send(message):
    proc.stdin.write(json.dumps(message) + '\n'); proc.stdin.flush()
def rpc(method, params):
    global sequence
    sequence += 1
    send({'jsonrpc': '2.0', 'id': sequence, 'method': method, 'params': params})
    stop = time.monotonic() + 45
    while time.monotonic() < stop:
        message = messages.get(timeout=max(.1, stop-time.monotonic()))
        if message.get('id') != sequence: continue
        assert 'error' not in message, message
        return message['result']
    raise RuntimeError(method + ' timed out')
def observe(root, file):
    with sqlite3.connect((root / '.codegraph/codegraph.db').as_uri()+'?mode=ro', uri=True) as db:
        return {'files': db.execute('select count(*) from files where path=?', (file,)).fetchone()[0],
                'symbols': [r[0] for r in db.execute("select name from nodes where file_path=? and kind in ('method','function') order by name", (file,))]}
def wait(root, file, names, present=True):
    started = time.monotonic()
    while time.monotonic()-started < 15:
        value = observe(root, file)
        if value['files'] == int(present) and value['symbols'] == names:
            return {**value, 'seconds': round(time.monotonic()-started, 3), 'passed': True}
        time.sleep(.2)
    raise AssertionError((root, file, names, value))
report = {'method': 'Fresh MCP stdio connection to the installed launcher, explicit projectPath. Watcher observations are read-only SQLite: no query or sync during transitions.', 'roots': []}
fixtures = []
try:
    init = rpc('initialize', {'protocolVersion': '2024-11-05', 'capabilities': {}, 'clientInfo': {'name': 'jass-coverage-verification', 'version': '1'}})
    report['server'] = init['serverInfo']
    assert init['serverInfo']['version'] == '1.6.2+jass-vjass.3', init
    send({'jsonrpc': '2.0', 'method': 'notifications/initialized', 'params': {}})
    for item in INPUTS:
        root = Path(item['root'])
        query = {'missiles': 'RapidBolt.shoot RapidBolt.launch RapidBolt.missileIterateP RapidBolt.onPeriod',
                 'inventory': 'InventoryCore.LClickItemSlot InventoryCore.Inventory.setTooltipTitle',
                 'ui': 'projectionRect renderStage'}[item['label']]
        response = rpc('tools/call', {'name': 'codegraph_explore', 'arguments': {'projectPath': str(root), 'query': query, 'maxFiles': 2}})
        assert not response.get('isError'), response
        text = '\n'.join(c.get('text', '') for c in response['content'])
        if item['label'] != 'ui': assert 'Bounded macro/module projections' in text
        (BASE / f"final-active-mcp-{item['label']}.txt").write_text(text)
        row = {'label': item['label'], 'root': str(root), 'query': query, 'response_characters': len(text), 'transitions': {}}
        token = f'CGExpandedProbe{proc.pid}'
        if item['label'] != 'ui':
            d = root / f'cg_expansion_definition_{proc.pid}.j'
            u = root / f'cg_expansion_consumer_{proc.pid}.j'
            assert not d.exists() and not u.exists()
            fixtures.extend([d, u])
            module = f'module {token}\nstatic method first takes nothing returns nothing\nendmethod\nendmodule\n'
            consumer = f'struct {token}Consumer extends array\nimplement {token}\nendstruct\n'
            d.write_text(module); u.write_text(consumer)
            row['transitions']['create_definition_and_consumer'] = wait(root, u.name, ['first'])
            d.write_text(module.replace('first', 'second'))
            row['transitions']['modify_definition_only'] = wait(root, u.name, ['second'])
            assert u.read_text() == consumer
            d.unlink()
            row['transitions']['delete_definition_only'] = wait(root, u.name, [])
            u.unlink()
            row['transitions']['delete_consumer'] = wait(root, u.name, [], False)
        else:
            p = root / f'cg_expansion_probe_{proc.pid}.js'
            assert not p.exists(); fixtures.append(p)
            p.write_text(f'function {token}First() {{}}\n')
            row['transitions']['create'] = wait(root, p.name, [token+'First'])
            p.write_text(f'function {token}Second() {{}}\n')
            row['transitions']['modify'] = wait(root, p.name, [token+'Second'])
            p.unlink()
            row['transitions']['delete'] = wait(root, p.name, [], False)
        for f, expected in item['files'].items():
            assert hashlib.sha256((root/f).read_bytes()).hexdigest() == expected
        row['original_hashes_unchanged'] = True
        report['roots'].append(row)
        (BASE / 'mcp-final-verification.json').write_text(json.dumps(report, indent=2))
    # Installed-runtime checks for the juror fixes, with no direct source change.
    root = Path(INPUTS[0]['root'])
    p = root / f'cg_juror_semantics_{proc.pid}.j'
    assert not p.exists(); fixtures.append(p)
    prefix = f'CGJuror{proc.pid}'
    owner, other = prefix+'S', prefix+'Other'
    array_call, scalar_call = prefix+'ArrayCall', prefix+'ScalarCall'
    p.write_text(f"""struct {other} extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct {owner} extends array
method operator [] takes integer index returns {other}
return {other}(index)
endmethod
method tick takes nothing returns nothing
endmethod
debug integer feature
static if not thistype.feature.exists then
static method fallback takes nothing returns nothing
endmethod
endif
endstruct
globals
{owner} array /* note */ {prefix}Values
endglobals
function {array_call} takes nothing returns nothing
call {prefix}Values[0].tick()
endfunction
function {scalar_call} takes nothing returns nothing
local {owner} scalar = 0 // array
call scalar[0].tick()
endfunction
""")
    stop = time.monotonic()+15
    while time.monotonic() < stop:
        with sqlite3.connect((root / '.codegraph/codegraph.db').as_uri()+'?mode=ro', uri=True) as db:
            def callees(name):
                return [r[0] for r in db.execute("select t.qualified_name from edges e join nodes s on s.id=e.source join nodes t on t.id=e.target where s.file_path=? and s.qualified_name=? and e.kind='calls' order by t.qualified_name", (p.name, name))]
            array_targets, scalar_targets = callees(array_call), callees(scalar_call)
            fallback = db.execute('select count(*) from nodes where file_path=? and qualified_name=?', (p.name,owner+'.fallback')).fetchone()[0]
        if array_targets == [owner+'.tick'] and scalar_targets == [] and fallback == 1: break
        time.sleep(.2)
    else: raise AssertionError({'array_targets':array_targets,'scalar_targets':scalar_targets,'debug_fallback':fallback})
    report['juror_semantics'] = {'array_with_block_comment':array_targets, 'scalar_with_array_comment':scalar_targets, 'debug_fallback_preserved':fallback==1, 'passed':True}
    p.unlink()
    report['juror_semantics']['cleanup'] = wait(root,p.name,[],False)
    report['passed'] = True
finally:
    for p in fixtures:
        if p.exists(): p.unlink()
    proc.stdin.close()
    try: proc.wait(timeout=10)
    except subprocess.TimeoutExpired: proc.terminate(); proc.wait(timeout=5)
    stderr.close()
    report['fixture_files_removed'] = all(not p.exists() for p in fixtures)
    (BASE / 'mcp-final-verification.json').write_text(json.dumps(report, indent=2))
print(json.dumps(report, indent=2))
