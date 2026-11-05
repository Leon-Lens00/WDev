"""Dev Mission v12m (31/10/2026): adds the compiled wave set to the compiled map script, without duplicating code.

v12l/war3map.j is compiled JASS patched by hand, so WaveSys is compiled apart with the map's own Table and TimerUtils and merged here
by function. JassHelper names private members differently on each run, so those are aligned first; every function both sides share
must then be identical, or the merge stops.

Usage: insertar.py IN_J COMPILADO OUT_J
"""
from pathlib import Path
import re
import sys

FUNC = re.compile(r'^[ \t]*(?:constant[ \t]+)?function[ \t]+(\w+)[ \t]+takes.*?^[ \t]*endfunction[ \t]*\n', re.S | re.M)
WAVE_INIT = 'jasshelper__init3867'
# The map runs its own Table and TimerUtils; these only served to compile the set.
SKIP = {'main', 'config', WAVE_INIT, 'sa___prototype2_TimerUtils___init', 'sc___prototype2_execute', 'sc___prototype2_evaluate'}
SKIP_GLOBAL = re.compile(r'^(si__Table|si__TableArray|st___prototype2)')
BLOCK_ANCHOR = '// AbilitySilence by leandrotp: silence or unsilence'
MAIN_ANCHOR = '    call ExecuteFunc("jasshelper__init3735")\n'
START_ANCHOR = '    // The dialogue still has one camera and one owner: the first player.\n'
START = '''function DevWave_Arrancar takes nothing returns nothing
    local integer p = 0
    call DestroyTimer(GetExpiredTimer())
    loop
        exitwhen p > 7
        if Game_On[p] then
            call DevWave_AddTarget(Game_Hero[p])
        endif
        set p = p + 1
    endloop
    call DevWave_Start()
endfunction

'''


def load(path):
    return Path(path).read_text(encoding='latin-1', newline='').replace('\r\n', '\n')


def globals_block(s):
    return re.search(r'^globals\n(.*?)^endglobals', s, re.S | re.M)


def global_names(block):
    out = {}
    for line in block.split('\n'):
        t = re.sub(r'//.*', '', line).strip()
        if t:
            m = re.match(r'(?:constant\s+)?(\w+)\s+(?:array\s+)?(\w+)', t)
            out[m.group(2)] = t
    return out


def align(s, known):
    """Renames the private members of Table and TimerUtils to the names the map uses."""
    def fix(m):
        t = m.group(0)
        if t in known:
            return t
        for a, b in (('Table__', 'Table___'), ('TimerUtils___', 'TimerUtils__')):
            if a in t and t.replace(a, b) in known:
                return t.replace(a, b)
        return t
    # The init of TimerUtils also sits on a different generated trigger.
    return re.sub(r'\b\w*(?:Table__|TimerUtils___)\w*\b', fix, s).replace('st___prototype2[(1)]', 'st___prototype3[(11)]')


def code(body):
    return [t for t in (re.sub(r'//.*', '', line).strip() for line in body.split('\n')) if t]


def once(s, old, new):
    if s.count(old) != 1:
        raise SystemExit(f'anchor {s.count(old)}x: {old!r}')
    return s.replace(old, new)


if __name__ == '__main__':
    j_in, j_wave, j_out = sys.argv[1:4]
    m, w = load(j_in), load(j_wave)
    map_funcs = {x.group(1): x.group(0) for x in FUNC.finditer(m)}
    map_globals = global_names(globals_block(m).group(1))
    w = align(w, set(map_funcs) | set(map_globals))

    new_funcs, shared = [], 0
    for x in FUNC.finditer(w):
        name, body = x.group(1), x.group(0)
        if name in SKIP:
            continue
        if name in map_funcs:
            if code(map_funcs[name]) != code(body):
                raise SystemExit(f'different body: {name}')
            shared += 1
        else:
            new_funcs.append(body)

    new_globals = []
    for name, decl in global_names(globals_block(w).group(1)).items():
        if SKIP_GLOBAL.match(name):
            continue
        if name not in map_globals:
            new_globals.append(decl)
        elif map_globals[name] != decl:
            raise SystemExit(f'different global: {decl} / {map_globals[name]}')

    init = FUNC.search(w[w.index('function ' + WAVE_INIT):]).group(0)
    init = re.sub(r'.*st___prototype2.*\n', '', init)
    init = re.sub(r'.*ExecuteFunc\("TimerUtils__init"\).*\n', '', init)
    init = init.replace(WAVE_INIT, 'DevWave_Inicio')
    if 'TimerUtils' in init or 'Table' in init:
        raise SystemExit('init still runs a shared library')

    block = '// Dev Mission v12m: WaveSys, compiled apart (scripts/oleada_v12m).\n' + ''.join(new_funcs) + init + '\n' + START
    m = once(m, BLOCK_ANCHOR, block + BLOCK_ANCHOR)
    m = once(m, MAIN_ANCHOR, MAIN_ANCHOR + '    call ExecuteFunc("DevWave_Inicio")\n')
    m = once(m, START_ANCHOR, '    call TimerStart(CreateTimer(), 3., false, function DevWave_Arrancar)\n' + START_ANCHOR)
    end = globals_block(m).end(1)
    m = m[:end] + '// Dev Mission v12m: WaveSys.\n' + '\n'.join(new_globals) + '\n' + m[end:]

    Path(j_out).write_text(m.replace('\n', '\r\n'), encoding='latin-1', newline='')
    print(f'funciones nuevas {len(new_funcs)}, compartidas {shared}, globales nuevas {len(new_globals)}')
