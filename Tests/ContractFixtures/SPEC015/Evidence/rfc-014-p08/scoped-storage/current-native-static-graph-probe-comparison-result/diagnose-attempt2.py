import collections
import datetime
import hashlib
import json
import os
from pathlib import Path
import selectors
import signal
import subprocess
import time

ROOT = Path('/Users/eugene/work/GiftUI')
BASE = ROOT / '.build/contracts/p08-native-static-graph-effect-attribution1'
ROLE = ROOT / '.build/contracts/p08-native-static-graph-role-mapping1'
SESSION_END = datetime.datetime.fromisoformat('2026-10-29T09:00:35.113979+00:00').timestamp()
RAW_CAP = 32 * 1024**2
PRIOR_FILES = ['semantic-complete-snapshots.sil', 'semantic-nonbody-context.stderr']
prior_data = [(BASE / name).read_bytes() for name in PRIOR_FILES]
PRIOR_BYTES = sum(map(len, prior_data))
PRIOR_LINES = sum(data.count(b'\n') for data in prior_data)
BODY_CAP, BODY_LINES = 1024**2 - PRIOR_BYTES, 32768 - PRIOR_LINES

def save(name, value):
    (BASE / name).write_text(json.dumps(value, indent=2) + '\n')

freeze = json.loads((BASE / 'freeze.json').read_text())
assert hashlib.sha256((BASE / 'GraphValidationProbe.swift').read_bytes()).hexdigest() == freeze['copy_sha256']
old = freeze['original_graph_argv']
argv = []
i = 0
while i < len(old):
    arg = old[i]
    if arg in ('-emit-module', '-emit-object'):
        i += 1
        continue
    if arg in ('-emit-module-path', '-o'):
        i += 2
        continue
    if arg.endswith('/AllocationGate/GraphValidationProbe.swift'):
        arg = str(BASE / 'GraphValidationProbe.swift')
    argv.append(arg)
    i += 1
argv += ['-emit-sil', '-o', '/dev/null', '-Xfrontend', '-debug-diagnostic-names',
         '-Xllvm', '-sil-print-all', '-Xllvm', '-sil-print-functions=counterGraphAllocationProbe',
         '-Xllvm', '-sil-print-sourceinfo']
assert len([a for a in argv if '/RuntimeDerived/' in a and a.endswith('.swift')]) == 42
roots = json.loads((ROLE / 'graph-compile-guard/terminal.json').read_text())['last_output_sample']['candidates']
roots = sorted(set(roots + [str(ROLE), str(BASE)]))
paths = set()
for root in roots:
    p = Path(root)
    if not p.is_absolute():
        p = ROOT / p
    paths.update(x for x in p.rglob('*') if x.is_file())
retained_before = sum(p.stat().st_size for p in paths)
assert retained_before + RAW_CAP + 32 * 1024**2 < 2 * 1024**3
start_wall, start_mono = time.time(), time.monotonic()
duration = min(900, SESSION_END - start_wall)
assert duration > 0
save('semantic-attempt2-launch.json', {'argv': argv, 'start_utc': datetime.datetime.fromtimestamp(start_wall, datetime.timezone.utc).isoformat(),
    'deadline_utc': datetime.datetime.fromtimestamp(start_wall + duration, datetime.timezone.utc).isoformat(),
    'duration_seconds': duration, 'same_session_deadline_utc': '2026-10-29T09:00:35.113979+00:00',
    'raw_forecast_and_cap_bytes': RAW_CAP, 'diagnostic_retention_cap_bytes': 1024**2,
    'diagnostic_retention_cap_lines': 32768, 'named_roots': roots, 'retained_before_bytes': retained_before,
    'cumulative_limit_bytes': 2 * 1024**3, 'protected_reserve_bytes': 32 * 1024**2,
    'processing_charge_before_bytes': 474747114, 'additional_help_and_read_charge_bytes': 1024**2, 'prior_retained_semantic_bytes': PRIOR_BYTES, 'prior_retained_semantic_lines': PRIOR_LINES,
    'processing_ceiling_with_forecast_bytes': 474747114 + 1024**2 + RAW_CAP,
    'selection': 'Every raw stream byte counted. Keep last complete caller snapshots with immediately preceding phase markers; keep bounded complete non-body context. No excerpts from partial bodies.',
    'os_limit': 'Userspace deadline/output checks cannot guarantee enforcement during OS suspension/failure.'})
proc = subprocess.Popen(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
print(json.dumps({'pid': proc.pid, 'launch': str(BASE / 'semantic-attempt2-launch.json'), 'duration_seconds': duration}), flush=True)
sel = selectors.DefaultSelector()
for stream, name in ((proc.stdout, 'stdout'), (proc.stderr, 'stderr')):
    sel.register(stream, selectors.EVENT_READ, name)
pending = {'stdout': b'', 'stderr': b''}
raw = {'stdout': 0, 'stderr': 0}
context = []
context_bytes = 0
snapshots = collections.deque()
snapshot_bytes = snapshot_lines = 0
body = None
body_bytes = 0
phase = b''
unrelated_phase_bytes_discarded = 0
complete_seen = discarded_bodies = discarded_bytes = 0
stop_reason = None

def line_received(line, stream):
    global body, body_bytes, phase, context_bytes, complete_seen, unrelated_phase_bytes_discarded
    global snapshot_bytes, snapshot_lines, discarded_bodies, discarded_bytes
    if body is None and line.startswith(b'sil ') and line.rstrip().endswith(b'{'):
        body = [phase, line] if phase else [line]
        body_bytes = sum(map(len, body))
        return
    if body is not None:
        body.append(line)
        body_bytes += len(line)
        if body_bytes > BODY_CAP or len(body) > BODY_LINES:
            raise RuntimeError('complete_current_body_projected_cap')
        if line.startswith(b'} // end sil function'):
            complete_seen += 1
            data = b''.join(body)
            n = len(body)
            snapshots.append((data, n))
            snapshot_bytes += len(data)
            snapshot_lines += n
            while snapshot_bytes + context_bytes > BODY_CAP or snapshot_lines + len(context) > BODY_LINES:
                removed, removed_lines = snapshots.popleft()
                discarded_bodies += 1
                discarded_bytes += len(removed)
                snapshot_bytes -= len(removed)
                snapshot_lines -= removed_lines
            body = None
            body_bytes = 0
        return
    # Preserve all outside-body diagnostic/phase bytes up to the fixed cap.
    # The latest phase marker is also bound to every retained complete body.
    if b'***' in line or b'Run #' in line:
        phase = line
        unrelated_phase_bytes_discarded += len(line)
        return
    context.append(line)
    context_bytes += len(line)
    while snapshots and (snapshot_bytes + context_bytes > BODY_CAP or snapshot_lines + len(context) > BODY_LINES):
        removed, removed_lines = snapshots.popleft()
        discarded_bodies += 1
        discarded_bytes += len(removed)
        snapshot_bytes -= len(removed)
        snapshot_lines -= removed_lines
    if context_bytes > BODY_CAP or len(context) > BODY_LINES:
        raise RuntimeError('aggregate_context_cap')

try:
    while sel.get_map():
        if time.time() >= start_wall + duration or time.monotonic() >= start_mono + duration:
            raise RuntimeError('fixed_compile_or_session_deadline')
        for key, _ in sel.select(timeout=0.1):
            chunk = os.read(key.fileobj.fileno(), 16384)
            if not chunk:
                sel.unregister(key.fileobj)
                continue
            name = key.data
            raw[name] += len(chunk)
            if sum(raw.values()) >= RAW_CAP - 128 * 1024:
                raise RuntimeError('raw_output_forecast_cap')
            pending[name] += chunk
            while b'\n' in pending[name]:
                line, pending[name] = pending[name].split(b'\n', 1)
                line_received(line + b'\n', name)
            if len(pending[name]) > 65536:
                raise RuntimeError('single_line_cap')
    for name, data in pending.items():
        if data:
            line_received(data, name)
except Exception as error:
    stop_reason = str(error)
    os.killpg(proc.pid, signal.SIGKILL)
finally:
    sel.close()
code = proc.wait(timeout=2)
# Drain remaining pipe tails after the group ends; charge all read bytes.
# If the tail unexpectedly exceeds the32MiB forecast, retain explicit uncertainty.
tail_bytes = 0
for stream, name in ((proc.stdout, 'stdout'), (proc.stderr, 'stderr')):
    while True:
        chunk = stream.read(16384)
        if not chunk:
            break
        raw[name] += len(chunk)
        tail_bytes += len(chunk)
        if sum(raw.values()) > RAW_CAP:
            stop_reason = stop_reason or 'raw_pipe_tail_exceeded_forecast'
            break
    stream.close()
data = b''.join(x[0] for x in snapshots)
ctx = b''.join(context)
assert len(data) + len(ctx) + PRIOR_BYTES <= 1024**2
assert data.count(b'\n') + ctx.count(b'\n') + PRIOR_LINES <= 32768
(BASE / 'semantic-attempt2-complete-snapshots.sil').write_bytes(data)
(BASE / 'semantic-attempt2-nonbody-context.stderr').write_bytes(ctx)
save('semantic-attempt2-terminal.json', {'exit': code, 'stop_reason': stop_reason, 'raw_stream_bytes_counted': raw,
    'finished_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'elapsed_seconds': time.monotonic() - start_mono,
    'complete_bodies_seen': complete_seen, 'complete_bodies_retained': len(snapshots),
    'earlier_complete_bodies_discarded': discarded_bodies, 'discarded_complete_body_bytes': discarded_bytes,
    'incomplete_body_discarded': body is not None, 'incomplete_body_bytes': body_bytes,
    'pending_unprocessed_bytes': sum(map(len, pending.values())),
    'retained_snapshot_bytes': len(data), 'retained_context_bytes': len(ctx),
    'all_read_raw_bytes_counted_before_selection': True, 'pipe_tail_read_bytes': tail_bytes, 'emitted_equals_read_proved': stop_reason is None, 'unrelated_phase_bytes_discarded': unrelated_phase_bytes_discarded, 'prior_retained_semantic_bytes': PRIOR_BYTES,
    'processing_charge_ceiling_bytes': 474747114 + 1024**2 + RAW_CAP,
    'complete_context_limitations': 'A cap-triggered stop cannot establish compiler rejection attribution. Earlier complete snapshots discarded by ring are counted; terminal compiler-phase context is preserved only if run completes without cap.'})
print(json.dumps({'exit': code, 'stop_reason': stop_reason, 'raw': raw, 'complete_bodies_seen': complete_seen,
                  'retained_snapshot_bytes': len(data), 'retained_context_bytes': len(ctx)}), flush=True)
