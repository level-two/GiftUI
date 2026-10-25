import datetime
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import threading
import time

ROOT = Path('/Users/eugene/work/GiftUI')
os.chdir(ROOT)
BASE = ROOT / '.build/contracts/p08-native-static-typedBacking61'
BASE.mkdir(exist_ok=True)
OUT = BASE / 'focused-matching'
OUT.mkdir()  # Exclusive one-run claim; never reuse or overwrite a launch.
(OUT / 'launch-guard.py').write_text(Path(__file__).read_text())
CMD = ['python3', 'scripts/contracts/check-spec-015-counter.py', '--profile', 'macos-static', '--runtime-build', '.build/contracts/spec-013-runtime-cycle/tmp_92dqehp/macos-static', '--host-build', '.build/contracts/p08-scoped-host-z7a2tnlz', '--fresh-focused', '--select-family', 'runtime', '--static-resource-entry-v1']
LIMIT, RESERVE = 2 * 1024**3, 32 * 1024**2
now = lambda: datetime.datetime.now(datetime.timezone.utc)
def write(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2) + '\n')
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
source_freeze = json.loads((ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-typedBacking61-local/after.json').read_text())
assert all(digest(ROOT / p) == h for p, h in source_freeze['sources'].items()), 'frozen input drift'
owned = [BASE, ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-typedBacking61-local', ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-typedBacking61-result']
owned.append(ROOT / '.build/contracts/spec-013-runtime-cycle/tmp_92dqehp')
owned.append(ROOT / '.build/contracts/p08-scoped-host-z7a2tnlz')
build = ROOT / '.build/contracts'
prior_dirs = (set(build.glob('p08-counter-*')) | set((build / 'spec-013-runtime-cycle').glob('tmp*')))
def usage():
    candidates = (set(build.glob('p08-counter-*')) | set((build / 'spec-013-runtime-cycle').glob('tmp*'))) - prior_dirs
    total = sum(p.stat().st_size for directory in owned + sorted(candidates) for p in directory.rglob('*') if p.is_file())
    return total, candidates
initial_bytes, _ = usage()
assert initial_bytes + 194000000 + RESERVE < LIMIT, 'insufficient output reserve'
stop = threading.Event()
ready = threading.Event()
state = {'reason': None}
proc = None
start = now()
deadline = start + datetime.timedelta(hours=4)
def guard():
    ready.wait()
    while not stop.is_set():
        size, candidates = usage()
        reason = 'deadline' if now() >= deadline else 'output_envelope' if size + RESERVE >= LIMIT else None
        if reason and proc is not None and proc.poll() is None:
            state.update(reason=reason, triggered_utc=now().isoformat(), retained_bytes=size)
            try:
                os.killpg(proc.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            time.sleep(2)
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            return
        stop.wait(min(30, max(0.01, (deadline - now()).total_seconds())))
watcher = threading.Thread(target=guard, daemon=True)
watcher.start()  # Guard is armed before workload spawn.
write('launch.json', {'authority': 'Human-approved typed-backing direction; matching focused runtime only under ordinary 4-hour/2GiB/32MiB guard; full awaits actual compiled gate', 'start_utc': start.isoformat(), 'deadline_utc': deadline.isoformat(), 'command': CMD, 'guard_armed_before_spawn': True, 'output_limit': LIMIT, 'reserve': RESERVE, 'initial_retained_bytes': initial_bytes, 'frozen_inputs_verified': len(source_freeze['sources'])})
try:
    with (OUT / 'stdout').open('wb') as stdout, (OUT / 'stderr').open('wb') as stderr:
        proc = subprocess.Popen(CMD, cwd=ROOT, stdout=stdout, stderr=stderr, start_new_session=True)
        write('ownership.json', {'pid': proc.pid, 'process_group': proc.pid, 'guard_pid': os.getpid(), 'start_utc': start.isoformat(), 'deadline_utc': deadline.isoformat()})
        ready.set()
        print(json.dumps({'pid': proc.pid, 'guard_pid': os.getpid(), 'start_utc': start.isoformat(), 'deadline_utc': deadline.isoformat(), 'capture': str(OUT)}), flush=True)
        code = proc.wait()
finally:
    ready.set()
    stop.set()
    watcher.join(timeout=5)
size, candidates = usage()
write('terminal.json', {'finished_utc': now().isoformat(), 'exit': code, 'guard': state, 'retained_bytes': size, 'output_candidates': [str(p.relative_to(ROOT)) for p in sorted(candidates)], 'within_deadline': now() <= deadline, 'within_output_envelope': size + RESERVE <= LIMIT})
print(json.dumps({'exit': code, 'guard_reason': state['reason'], 'terminal': str(OUT / 'terminal.json')}), flush=True)
raise SystemExit(code if code >= 0 else 128 - code)
