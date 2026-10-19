"""One compiler-free qualification claim. Production entry is reviewed-launch.py."""
from pathlib import Path
import fcntl
import json
import os
import sys
import time
import traceback
from qualify import ROOT, actual, read, require, verify_context, verify_packet, verify_environment

PACKET = Path(__file__).resolve().parent

def fsync_directory(path):
    descriptor = os.open(str(path), os.O_RDONLY)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)

def atomic_new_json(path, value):
    """Publish complete bytes with an atomic no-overwrite hard-link claim."""
    path = Path(path)
    temporary = path.with_name(path.name + '.unpublished')
    payload = (json.dumps(value, sort_keys=True, indent=2) + '\n').encode()
    descriptor = os.open(str(temporary), os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    try:
        with os.fdopen(descriptor, 'wb') as stream:
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
        os.link(temporary, path)  # Atomic and fails if terminal already exists.
        fsync_directory(path.parent)
    finally:
        # Only this newly-created unpublished file is removable. Consumption
        # markers, receipts and terminal files are never replaced or removed.
        temporary.unlink()
        fsync_directory(path.parent)

def check_lock(descriptor, path):
    require(not path.is_symlink() and path.resolve() == path, 'validation lock alias')
    held, current = os.fstat(descriptor), path.stat()
    require((held.st_dev, held.st_ino) == (current.st_dev, current.st_ino), 'validation lock replaced')

def claim_and_qualify(out, pins, check, verify, provenance):
    """The same claim/terminal path is exercised by harmless temporary fixtures."""
    require(not out.exists() and not out.is_symlink(), 'permanent qualification marker consumed; no replay')
    check()
    out.mkdir()  # Sole qualification allowance consumed before the first read pass.
    fsync_directory(out.parent)
    marker = [out.stat().st_dev, out.stat().st_ino]
    claim = dict(status='CONSUMED_not_terminal', reviewed_pins=pins,
                 marker_identity=marker, consumed_ns=time.time_ns(),
                 qualification_attempts=1, compiler_launches=0, counter_launches=0,
                 schema4_launches=0, repairs=0, retries=0, provenance=provenance)
    try:
        atomic_new_json(out / 'claim.json', claim)
        before = verify()
        check()
        after = verify()
        require(before == after, 'qualification boundary disagreement')
        require([out.stat().st_dev, out.stat().st_ino] == marker and out.resolve() == out, 'qualification marker replaced')
        terminal = dict(after, reviewed_pins=pins, marker_identity=marker,
                        consumed_ns=claim['consumed_ns'], finished_ns=time.time_ns(),
                        qualification_attempts=1, provenance=provenance)
        check()
    except BaseException:
        terminal = dict(status='STOP_compiler_free_qualification_failed',
                        reviewed_pins=pins, marker_identity=marker,
                        consumed_ns=claim['consumed_ns'], finished_ns=time.time_ns(),
                        error=traceback.format_exc(), qualification_attempts=1,
                        compiler_launches=0, counter_launches=0, schema4_launches=0,
                        repairs=0, retries=0, historical_wrapper_status='STOP',
                        p08_closed=False, r07_closed=False, t8_1_closed=False)
    atomic_new_json(out / 'terminal.json', terminal)
    return 0 if terminal['status'] == 'PASS_retained_macos_static_counter426_only' else 1

def main():
    require(sys.flags.isolated and sys.flags.no_site and sys.flags.dont_write_bytecode and sys.pycache_prefix == '/dev/null', 'isolated qualification startup')
    require(sys.executable == '/Applications/Xcode.app/Contents/Developer/usr/bin/python3', 'absolute frozen qualification Python')
    verify_environment(os.environ)
    require(len(sys.argv) == 4, 'independent full reviewed pins required')
    pins = sys.argv[1:]
    verify_packet(ROOT, PACKET, *pins)
    recipe = read(PACKET / 'recipe.json')
    out = Path(recipe['output_root'])
    require(out.parent.resolve() == out.parent and out.parent.is_dir(), 'canonical output parent')
    require(not out.exists() and not out.is_symlink(), 'permanent qualification marker consumed; no replay')
    lock_path = ROOT / '.build/validation.lock'
    descriptor = os.open(str(lock_path), os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW | os.O_CLOEXEC, 0o600)
    try:
        fcntl.flock(descriptor, fcntl.LOCK_EX)
        def check():
            check_lock(descriptor, lock_path)
            verify_packet(ROOT, PACKET, *pins)
        check()
        # No child/driver/compiler is spawned. All work is read-only evidence
        # authentication plus new receipts under the distinct permanent marker.
        return claim_and_qualify(out, pins, check, lambda: verify_context(ROOT, PACKET),
                                dict(packet=str(PACKET), recipe=recipe,
                                     working_tree=__import__('qualify').git(ROOT, 'status', '--porcelain').decode()))
    finally:
        os.close(descriptor)

if __name__ == '__main__':
    raise SystemExit(main())
