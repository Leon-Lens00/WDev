"""Dev Mission title v12i (30/10/2026): RapidFire 1.8.1 in the play zone, on the v12h script.

v12h is plain compiled JASS patched by hand, so the new libraries are compiled apart. A and B are the same libraries,
B adding UnitHitShape, GroundCollision, GroundMotion and RapidFire; the lines B adds go into v12h:
- globals at the end of the globals block, with new struct ids above the ones in use;
- functions right before Game_Enter, in order;
- library initializers in the map's initializer list, keeping Missile before RapidBolt.

Each player gets a RapidPair: the character is the actor and 'rfct' the controller the player selects.

Usage: rapid_v12i.py IN_J OUT_J A_J B_J
"""
from difflib import SequenceMatcher
from pathlib import Path
import re
import sys

import puente_v12 as base

ENTER = '''    set Game_Hero[p]=CreateUnit(Player(p), id, GetLocationX(start), GetLocationY(start), 270)
    set Game_On[p]=true
'''
PAIR = '''    set Game_Hero[p]=CreateUnit(Player(p), id, GetLocationX(start), GetLocationY(start), 270)
    set Game_Ctrl[p]=CreateUnit(Player(p), 'rfct', s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.)
    call SetUnitVertexColor(Game_Ctrl[p], 255, 255, 255, 0)
    // The burst moves the character at the speed of rfct.
    // The character only follows its controller: no native attack or auto acquire.
    call UnitRemoveAbility(Game_Hero[p], 'Aatk')
    call SetUnitMoveSpeed(Game_Hero[p], 350.)
    set Game_Pair[p]=s__RapidPair_create(Game_Ctrl[p] , Game_Hero[p])
    set Game_On[p]=true
'''
INITS = ['UnitHitShape__Init', 'GroundCollision___Init']
LAST = ['s__RapidBolt_MissileStruct__onInit', 'RapidFire___Init']


def lines(path):
    return Path(path).read_text(encoding='latin-1').replace('\r\n', '\n').split('\n')


def added(a, b):
    """Lines of b that a lacks, in order, split into the globals part and the rest."""
    end = b.index('endglobals')
    glob, code = [], []
    for tag, _, _, j1, j2 in SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
        if tag in ('insert', 'replace'):
            for j in range(j1, j2):
                (glob if j < end else code).append(b[j])
    return glob, code


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    a, b = lines(sys.argv[3]), lines(sys.argv[4])
    glob, code = added(a, b)
    used = [int(n) for n in re.findall(r'constant integer si__\w+=(\d+)', s)]
    next_id = max(used) + 1
    out = []
    old = set(re.findall(r'constant integer (si__\w+)=', s))
    for g in glob:
        m = re.match(r'constant integer (si__\w+)=\d+$', g)
        if m and (m[1] in old or 'Missile' in m[1]):
            continue
        if m:
            g = 'constant integer %s=%d' % (m[1], next_id)
            next_id += 1
        out.append(g)
    glob = out + ['unit array Game_Ctrl', 'integer array Game_Pair']
    # Mains, initializers and the renumbered init function stay out: the map has its own.
    code = [l for l in code if 'jasshelper__init' not in l and 'ExecuteFunc(' not in l and l != '//------------------------------------']
    # JassHelper writes private prefixes with __ or ___ depending on the build: use the map's spelling.
    known = {}
    for t in set(re.findall(r'\b\w*__\w*\b', s)):
        known[re.sub('_+', '_', t)] = t
    own = set(re.findall(r'(?:function |constant \w+ |\w+ array |^\w+ )(\w+__\w*)', '\n'.join(glob + code), re.M))
    fix = lambda m: m[0] if m[0] in own else known.get(re.sub('_+', '_', m[0]), m[0])
    glob = [re.sub(r'\b\w*__\w*\b', fix, l) for l in glob]
    text = re.sub(r'\b\w*__\w*\b', fix, '\n'.join(code))
    i = s.index('endglobals' + base.N)
    s = s[:i] + base.N.join(glob) + base.N + s[i:]
    s = base.once(s, '// v12g: player p enters the play zone with the chosen character, base unit for now.\n',
                  text + '\n// v12g: player p enters the play zone with the chosen character, base unit for now.\n')
    s = base.once(s, ENTER, PAIR)
    s = base.once(s, '        call SelectUnit(Game_Hero[p], true)\n', '        call SelectUnit(Game_Ctrl[p], true)\n')
    i = s.index('function jasshelper__init3735 takes nothing returns nothing')
    j = s.index('call ExecuteFunc("s__Missile_onInit")', i)
    k = s.index(base.N, j) + len(base.N)
    s = s[:j] + ''.join('call ExecuteFunc("%s")%s' % (f, base.N) for f in INITS) + s[j:k] + \
        ''.join('call ExecuteFunc("%s")%s' % (f, base.N) for f in LAST) + s[k:]
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s), 'globales', len(glob), 'lineas', len(code))
