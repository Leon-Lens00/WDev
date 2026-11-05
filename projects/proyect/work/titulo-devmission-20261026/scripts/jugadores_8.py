"""Open the title copy's war3map.j to 8 user players (26/10/2026), matching w3i_8.py.

Edits only config, InitCustomPlayerSlots and InitCustomTeams: players 3-8 get user slots, start locations from
inicios.json, colour = player index and team 0, written the way the editor writes players 1-2. Fails if any
expected block is missing. Keeps CRLF.

Usage: jugadores_8.py IN_J INICIOS_JSON OUT_J
"""
from pathlib import Path
import json, sys

t = Path(sys.argv[1]).read_bytes().decode('latin-1')
starts = [e['start'] for e in json.loads(Path(sys.argv[2]).read_text())['players_3_8']]
N = '\r\n'


def num(v):
    return ('- %.1f' % -v) if v < 0 else '%.1f' % v


def sub(old, new):
    global t
    assert t.count(old) == 1, old
    t = t.replace(old, new)


sub('    call SetPlayers(2)' + N + '    call SetTeams(2)', '    call SetPlayers(8)' + N + '    call SetTeams(8)')
sub('    call DefineStartLocation(1, 2944.0, - 5696.0)' + N, '    call DefineStartLocation(1, 2944.0, - 5696.0)' + N
    + ''.join('    call DefineStartLocation(%d, %s, %s)' % (k + 2, num(x), num(y)) + N for k, (x, y) in enumerate(starts)))
sub('    call SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)' + N, '    call SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)' + N
    + ''.join('    call SetPlayerSlotAvailable(Player(%d), MAP_CONTROL_USER)' % p + N for p in range(2, 8)))
slot = ''.join(N.join(['    // Player %d' % p, '    call SetPlayerStartLocation(Player(%d), %d)' % (p, p),
                       '    call SetPlayerColor(Player(%d), ConvertPlayerColor(%d))' % (p, p),
                       '    call SetPlayerRacePreference(Player(%d), RACE_PREF_RANDOM)' % p,
                       '    call SetPlayerRaceSelectable(Player(%d), true)' % p,
                       '    call SetPlayerController(Player(%d), MAP_CONTROL_USER)' % p, '']) + N for p in range(2, 8))
sub('    call SetPlayerController(Player(1), MAP_CONTROL_USER)' + N + N + 'endfunction',
    '    call SetPlayerController(Player(1), MAP_CONTROL_USER)' + N + N + slot + 'endfunction')
sub('    call SetPlayerTeam(Player(1), 0)' + N, '    call SetPlayerTeam(Player(1), 0)' + N
    + ''.join('    call SetPlayerTeam(Player(%d), 0)' % p + N for p in range(2, 8)))
Path(sys.argv[3]).write_bytes(t.encode('latin-1'))
print('ok', len(t))
