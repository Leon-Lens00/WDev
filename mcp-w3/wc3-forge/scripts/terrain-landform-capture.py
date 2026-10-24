"""Capture and certify a live Forge viewport. Never opens, edits or saves a map.

The JSON camera file is either an exact pose or a camera.frame request (bounds).
Rejected evidence is retained separately and is never marked reviewed/accepted.
"""
import argparse
import base64
import hashlib
import json
import math
import os
from pathlib import Path
import socket
import struct


def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def check(condition, message):
    if not condition:
        raise ValueError(message)


def same_path(a, b):
    return os.path.normcase(os.path.abspath(a)) == os.path.normcase(os.path.abspath(b))


def check_evidence(e, path, sha):
    check(e.get('version') == 1, 'Forge lacks map evidence v1; rebuild GUI')
    check(e.get('loaded') and same_path(e.get('path', ''), str(path)), 'Wrong loaded map')
    check(e.get('loaded_sha256') == sha, 'Loaded map digest differs from expected archive')
    check(not e.get('dirty', True), 'Map session has unsaved changes')
    check(e.get('io_pending', 1) == 0 and not e.get('identity_error'), 'Map identity is not idle/verified')


def same_pose(a, b):
    if a.keys() != b.keys():
        return False
    return all(math.isclose(v, b[k], rel_tol=1e-10, abs_tol=1e-8)
               if isinstance(v, (int, float)) and isinstance(b[k], (int, float))
               else v == b[k] for k, v in a.items())


def validate_capture(r, before, after, framed, pid, build_sha, allowed_errors, expect_water=False, geometry=None):
    check(before == after == r.get('evidence') == r.get('rendered_evidence'), 'Map revision changed or rendered revision is stale')
    check(r.get('renderer_evidence_version') == 1, 'Renderer lacks evidence v1')
    check(r.get('runtime', {}).get('pid') == pid, 'Capture came from another process')
    check(r.get('runtime', {}).get('sha256') == build_sha, 'Running GUI differs from expected build')
    check(same_pose(r.get('camera', {}), framed['state']), 'Camera was reset or moved during capture')
    check(r.get('frame', -1) > framed['frame'], 'Capture did not follow acknowledged camera frame')
    d = r.get('diagnostics', {})
    check(not d.get('crashed', True) and d.get('last_gl_error', -1) == 0, 'Renderer/GL failure')
    check(d.get('has_terrain'), 'No terrain rendered')
    check(d.get('doodad_model_fails', -1) == 0 and d.get('unit_model_fails', -1) == 0, 'Placed models failed to load')
    errors = d.get('viewer_error_details')
    check(isinstance(errors, list) and len(errors) == d.get('viewer_errors'), 'Viewer error identities missing')
    check(all(e in allowed_errors for e in errors), 'Unclassified viewer errors: ' + str([e for e in errors if e not in allowed_errors]))
    terrain = d.get('namespaces', {}).get('terrain', {})
    check(terrain.get('atlasStatus') == 'ok' and terrain.get('paletteFails', -1) == 0 and
          terrain.get('fboIncompleteFails', -1) == 0, 'Terrain texture fallback/failure')
    cliffs = d.get('namespaces', {}).get('cliffs', {})
    check(cliffs.get('lastFailedCells', -1) == 0 and cliffs.get('meshMissPaths', -1) == 0 and
          cliffs.get('paletteFails', -1) == 0, 'Cliff geometry/texture is missing')
    if expect_water:
        check(d.get('has_water'), 'Expected water is absent from renderer')
    if d.get('has_water'):
        check(d.get('water_frames_expected', -1) == d.get('water_frames_loaded', -2), 'Water textures missing/fallback')
    if geometry:
        check([d.get('terrain_width'), d.get('terrain_height')] == [geometry['width'], geometry['height']] and
              d.get('center_offset') == geometry['center_offset'], 'Rendered geometry differs from expected')
    data = base64.b64decode(r['bytes_base64'], validate=True)
    check(data[:8] == b'\x89PNG\r\n\x1a\n' and data[12:16] == b'IHDR', 'Invalid PNG response')
    check(struct.unpack('>II', data[16:24]) == (r['width'], r['height']), 'PNG dimensions differ from metadata')
    check(r['width'] > 0 and r['height'] > 0 and r['viewport_width'] >= r['width'], 'Invalid viewport dimensions')
    return data


class Bridge:
    def __init__(self, pid):
        lockdir = Path(os.environ.get('WC3FORGE_MCP_LOCK_DIR', Path.home() / '.wc3-forge/mcp'))
        self.lock = json.loads((lockdir / f'{pid}.lock').read_text())
        check(self.lock['pid'] == pid, 'Lockfile PID mismatch')
        self.conn = socket.create_connection(('127.0.0.1', self.lock['port']), timeout=35)
        self.reader = self.conn.makefile('rb')
        self.serial = 0

    def call(self, method, params=None):
        self.serial += 1
        self.conn.sendall((json.dumps(dict(jsonrpc='2.0', id=self.serial, method=method,
            params=dict(params or {}, _token=self.lock['token']))) + '\n').encode())
        raw = self.reader.readline(64 * 1024 * 1024)
        check(raw.endswith(b'\n'), 'Bridge response is incomplete/oversized')
        response = json.loads(raw)
        check(response.get('id') == self.serial, 'Unexpected response ID')
        if 'error' in response:
            raise RuntimeError(response['error'])
        return response['result']

    def close(self):
        self.reader.close()
        self.conn.close()


def read_json(path):
    return json.loads(Path(path).read_text(encoding='utf-8-sig'))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--pid', type=int, required=True)
    ap.add_argument('--map', type=Path, required=True)
    ap.add_argument('--sha256', required=True)
    ap.add_argument('--build', type=Path, required=True)
    ap.add_argument('--camera', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--context', type=Path, help='Recipe/seed/reference metadata to retain with capture')
    ap.add_argument('--geometry', type=Path, help='Expected width,height,center_offset JSON')
    ap.add_argument('--allow-viewer-errors', type=Path, help='JSON list of individually reviewed exact error identities')
    ap.add_argument('--expect-water', action='store_true')
    ap.add_argument('--max-width', type=int, default=1600)
    a = ap.parse_args()
    check(not a.out.exists() and not a.out.with_suffix('.json').exists(), 'Refusing to replace existing evidence')
    check(digest(a.map) == a.sha256, 'Disk map differs from requested SHA256')
    build_sha = digest(a.build)
    allowed = read_json(a.allow_viewer_errors) if a.allow_viewer_errors else []
    check(isinstance(allowed, list) and all(isinstance(e, str) for e in allowed), 'Error allowlist must contain exact identities')
    bridge = Bridge(a.pid)
    original = None
    before = None
    r = None
    restored = False
    record = dict(format='wc3-landform-capture-v1', passed=False, reviewed=False,
                  context=read_json(a.context) if a.context else {}, expected_sha256=a.sha256,
                  build_path=str(a.build.resolve()), build_sha256=build_sha, pid=a.pid,
                  allowed_viewer_errors=allowed, camera_request=read_json(a.camera),
                  camera_request_sha256=digest(a.camera))
    try:
        check(bridge.call('bridge.ping')['pid'] == a.pid, 'Bridge selected another PID')
        before = bridge.call('map.status').get('evidence', {})
        check_evidence(before, a.map, a.sha256)
        original = bridge.call('camera.get_state')['state']
        camera = read_json(a.camera)
        framed = bridge.call('camera.frame' if 'bounds' in camera else 'camera.set_state', camera)
        r = bridge.call('viewport.screenshot', dict(max_width=a.max_width, require_clean=True,
                expected_sha256=a.sha256, expected_revision=before['revision']))
        after = bridge.call('map.status').get('evidence', {})
        check_evidence(after, a.map, a.sha256)
        check(digest(a.map) == a.sha256, 'Disk map changed during capture')
        data = validate_capture(r, before, after, framed, a.pid, build_sha, allowed,
                                a.expect_water, read_json(a.geometry) if a.geometry else None)
        record.update({k: v for k, v in r.items() if k != 'bytes_base64'})
        record.update(passed=True, png_sha256=hashlib.sha256(data).hexdigest(), disk_sha256_after=a.sha256)
    except Exception as error:
        record['error'] = str(error)
        if r:
            record['rejected_capture'] = {k: v for k, v in r.items() if k != 'bytes_base64'}
        raise
    finally:
        try:
            if original is not None and bridge.call('map.status').get('evidence') == before:
                restored = same_pose(bridge.call('camera.set_state', original)['state'], original)
        finally:
            bridge.close()
            record['camera_restored'] = restored
            a.out.parent.mkdir(parents=True, exist_ok=True)
            metadata_path = a.out.with_suffix('.json' if record['passed'] else '.rejected.json')
            metadata_path.write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
            if record['passed']:
                a.out.write_bytes(data)
            elif r and 'bytes_base64' in r:
                a.out.with_suffix('.rejected.png').write_bytes(base64.b64decode(r['bytes_base64']))
    print(a.out)


if __name__ == '__main__':
    main()
