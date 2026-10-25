import datetime
import hashlib
import json
import math
import multiprocessing
import os
from pathlib import Path
import signal
import subprocess
import threading
import time

ROOT = Path('/Users/eugene/work/GiftUI')
BASE = ROOT / '.build/contracts/p08-native-static-typedBacking61'
LOCAL = ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-typedBacking61-local'
RESULT = LOCAL.with_name('current-native-static-typedBacking61-result')
CMD = ['python3', 'scripts/contracts/check-spec-015-counter.py', '--profile', 'macos-static', '--runtime-build', '.build/contracts/spec-013-runtime-cycle/tmp_92dqehp/macos-static', '--host-build', '.build/contracts/p08-scoped-host-z7a2tnlz', '--collect-failures', '--static-resource-entry-v1']
LIMIT, RESERVE = 2 * 1024**3, 32 * 1024**2

def now():
    return datetime.datetime.now(datetime.timezone.utc)

def write(out, name, value):
    target = out / name
    temp = target.with_suffix(target.suffix + '.tmp')
    temp.write_text(json.dumps(value, indent=2) + '\n')
    temp.replace(target)

def kill_group(pid, sig):
    try:
        os.killpg(pid, sig)
    except ProcessLookupError:
        pass

def deadline_watchdog(out, connection, stop, armed, start_wall, start_mono, duration):
    # Separate OS process: recursive output scanning cannot delay this clock.
    deadline_wall = start_wall + duration
    deadline_mono = start_mono + duration
    lead = min(3.0, duration / 3)
    grace = min(1.0, lead / 2)
    armed.set()
    pid = None
    while not stop.is_set():
        if pid is None and connection.poll():
            pid = connection.recv()
        remaining = min(deadline_wall - time.time(), deadline_mono - time.monotonic())
        if remaining <= lead:
            record = {'reason': 'deadline', 'triggered_utc': now().isoformat(), 'pid': pid,
                      'term_remaining_seconds': remaining}
            write(out, 'deadline-event.json', record)
            if pid is not None:
                kill_group(pid, signal.SIGTERM)
                time.sleep(max(0, min(grace, deadline_mono - time.monotonic() - 0.25,
                                      deadline_wall - time.time() - 0.25)))
                kill_group(pid, signal.SIGKILL)
            record.update(kill_completed_utc=now().isoformat(),
                          completed_inside_deadline=(time.time() <= deadline_wall and time.monotonic() <= deadline_mono))
            write(out, 'deadline-event.json', record)
            return
        stop.wait(min(0.1, max(0.001, remaining - lead)))

def run(out, command, duration, usage, limit, reserve, forecast=0, scan_interval=5):
    out.mkdir()  # Exclusive one-run ownership, never resume/overwrite.
    (out / 'launch-guard.py').write_bytes(Path(__file__).read_bytes())
    initial, candidates = usage()
    if initial + forecast + reserve >= limit:
        raise RuntimeError('insufficient output forecast/reserve')
    ctx = multiprocessing.get_context('fork')
    stop = ctx.Event()
    armed = ctx.Event()
    receiving, sending = ctx.Pipe(duplex=False)
    last = {'bytes': initial, 'candidates': candidates, 'sample_utc': now().isoformat(), 'scan_error': None}
    finished = threading.Event()
    output_finished = threading.Event()
    proc = None
    start = now()
    mono = time.monotonic()
    deadline = start + datetime.timedelta(seconds=duration)
    watchdog = ctx.Process(target=deadline_watchdog,
        args=(out, receiving, stop, armed, start.timestamp(), mono, duration))
    caffeinate = None
    scanner = None
    code = None
    launch_error = None
    try:
        # Task-local assertions only: no global power or toolchain settings.
        caffeinate = subprocess.Popen(['/usr/bin/caffeinate', '-dims', '-w', str(os.getpid())],
                                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        watchdog.start()
        if not armed.wait(timeout=1):
            raise RuntimeError('independent deadline watchdog did not arm')
        write(out, 'launch.json', {'authority': 'Human-authorized fresh typedBacking61 full retry after guard review',
            'start_utc': start.isoformat(), 'deadline_utc': deadline.isoformat(), 'duration_seconds': duration,
            'command': command, 'guard_pid': os.getpid(), 'watchdog_pid': watchdog.pid,
            'caffeinate_pid': caffeinate.pid, 'guard_armed_before_spawn': True,
            'wall_and_monotonic_deadlines': True, 'output_limit': limit, 'reserve': reserve,
            'initial_retained_bytes': initial, 'forecast_bytes': forecast,
            'os_limitation': 'Process scheduling, suspension or OS failure can delay userspace enforcement; task-local caffeinate mitigates normal idle/system sleep, no absolute OS guarantee.'})
        with (out / 'stdout').open('wb') as stdout, (out / 'stderr').open('wb') as stderr:
            proc = subprocess.Popen(command, cwd=ROOT, stdout=stdout, stderr=stderr, start_new_session=True)
            sending.send(proc.pid)
            write(out, 'ownership.json', {'pid': proc.pid, 'process_group': proc.pid,
                'guard_pid': os.getpid(), 'watchdog_pid': watchdog.pid, 'caffeinate_pid': caffeinate.pid,
                'start_utc': start.isoformat(), 'deadline_utc': deadline.isoformat()})
            print(json.dumps({'pid': proc.pid, 'guard_pid': os.getpid(), 'watchdog_pid': watchdog.pid,
                'caffeinate_pid': caffeinate.pid, 'start_utc': start.isoformat(),
                'deadline_utc': deadline.isoformat(), 'capture': str(out)}), flush=True)

            def scan_outputs():
                while not finished.is_set():
                    try:
                        size, found = usage()
                        last.update(bytes=size, candidates=found, sample_utc=now().isoformat())
                        if size + reserve >= limit:
                            event = {'reason': 'output_envelope', 'triggered_utc': now().isoformat(), 'retained_bytes': size}
                            write(out, 'output-event.json', event)
                            kill_group(proc.pid, signal.SIGTERM)
                            time.sleep(0.25)
                            kill_group(proc.pid, signal.SIGKILL)
                            event['kill_completed_utc'] = now().isoformat()
                            write(out, 'output-event.json', event)
                            return
                    except Exception as error:
                        last['scan_error'] = repr(error)
                        write(out, 'output-error.json', {'error': repr(error), 'utc': now().isoformat()})
                        kill_group(proc.pid, signal.SIGTERM)
                        time.sleep(0.25)
                        kill_group(proc.pid, signal.SIGKILL)
                        return
                    finished.wait(scan_interval)
                output_finished.set()

            scanner = threading.Thread(target=scan_outputs, daemon=True)
            scanner.start()
            code = proc.wait()
    except Exception as error:
        launch_error = repr(error)
        if proc is not None:
            kill_group(proc.pid, signal.SIGKILL)
            code = proc.wait()
    finally:
        finished.set()
        # Never perform or wait for a recursive scan on the deadline path.
        if scanner is not None:
            scanner.join(timeout=0.5)
        if (out / 'deadline-event.json').exists():
            watchdog.join(timeout=1.5)
        stop.set()
        if watchdog.pid is not None:
            watchdog.join(timeout=0.5)
            if watchdog.is_alive():
                watchdog.terminate()
                watchdog.join(timeout=0.5)
        if caffeinate is not None:
            caffeinate.terminate()
            caffeinate.wait(timeout=1)
    event = None
    for name in ['deadline-event.json', 'output-event.json', 'output-error.json']:
        if (out / name).exists():
            event = json.loads((out / name).read_text())
            break
    terminal = {'finished_utc': now().isoformat(), 'exit': code, 'launch_error': launch_error,
        'guard': event, 'last_output_sample': last, 'output_sample_final': False,
        'within_deadline': now() <= deadline and time.monotonic() <= mono + duration,
        'within_output_envelope_at_last_sample': last['bytes'] + reserve <= limit,
        'scanner_still_blocked': scanner is not None and scanner.is_alive()}
    write(out, 'terminal.json', terminal)
    print(json.dumps({'exit': code, 'launch_error': launch_error, 'guard': event, 'terminal': str(out / 'terminal.json')}), flush=True)
    return terminal

def main():
    os.chdir(ROOT)
    freeze = json.loads((LOCAL / 'after.json').read_text())
    if not all(hashlib.sha256((ROOT / p).read_bytes()).hexdigest() == h for p, h in freeze['sources'].items()):
        raise RuntimeError('frozen five-source identity drift')
    build = ROOT / '.build/contracts'
    owned = [BASE, LOCAL, RESULT, build / 'spec-013-runtime-cycle/tmp_92dqehp',
             build / 'p08-scoped-host-z7a2tnlz', build / 'p08-counter-wo_a9okt', build / 'p08-counter-oc77dnep']
    prior = set(build.glob('p08-counter-*'))
    def usage():
        candidates = set(build.glob('p08-counter-*')) - prior
        size = sum(p.stat().st_size for d in owned + sorted(candidates) for p in d.rglob('*') if p.is_file())
        return size, [str(p.relative_to(ROOT)) for p in sorted(candidates)]
    terminal = run(BASE / 'full4h2', CMD, 4 * 3600, usage, LIMIT, RESERVE, forecast=620000000)
    code = terminal['exit']
    raise SystemExit(1 if terminal['launch_error'] else code if code is not None and code >= 0 else 128 - (code or 0))

if __name__ == '__main__':
    main()
