import datetime
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time

HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('typedBacking61_guard', HERE / 'launch-full4h2.py')
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)
OUT = guard.BASE / 'guard4h2-controls'
OUT.mkdir()
rows = []
zero = lambda: (0, [])
for name, command, expected in [
    ('success', [sys.executable, '-c', 'raise SystemExit(0)'], 0),
    ('nonzero', [sys.executable, '-c', 'raise SystemExit(7)'], 7),
    ('launch-failure', ['/nonexistent/typedBacking61-control-command'], None),
]:
    terminal = guard.run(OUT / name, command, 6, zero, 1048576, 4096, scan_interval=0.05)
    passed = terminal['exit'] == expected and terminal['within_deadline']
    if name == 'launch-failure':
        passed = passed and 'FileNotFoundError' in terminal['launch_error']
    rows.append({'case': name, 'passed': passed, 'terminal': terminal})

calls = [0]
def stalled_usage():
    calls[0] += 1
    if calls[0] > 1:
        time.sleep(60)
    return 0, []

pid_path = OUT / 'term-child.pid'
work = "import os,signal,time; signal.signal(signal.SIGTERM,signal.SIG_IGN); pid=os.fork(); open(" + repr(str(pid_path)) + ",'w').write(str(pid if pid else os.getpid())); time.sleep(60)"
terminal = guard.run(OUT / 'stalled-scan-term-ignore-child', [sys.executable, '-c', work], 6,
                     stalled_usage, 1048576, 4096, scan_interval=0.05)
child_pid = int(pid_path.read_text())
observed = subprocess.run(['ps', '-p', str(child_pid), '-o', 'stat='], text=True, capture_output=True)
child_inactive = observed.returncode == 1 or (observed.returncode == 0 and observed.stdout.strip().startswith('Z'))
rows.append({'case': 'stalled-scan-term-ignore-child',
    'passed': terminal['guard']['reason'] == 'deadline' and terminal['guard']['completed_inside_deadline'] and terminal['within_deadline'] and terminal['scanner_still_blocked'] and child_inactive,
    'child_pid': child_pid, 'child_ps_return': observed.returncode, 'child_ps_stdout': observed.stdout,
    'child_ps_stderr': observed.stderr, 'child_inactive': child_inactive, 'terminal': terminal})

calls = [0]
def over_limit():
    calls[0] += 1
    return (0 if calls[0] == 1 else 1048576), []
terminal = guard.run(OUT / 'output-limit', [sys.executable, '-c', 'import time; time.sleep(60)'],
                     6, over_limit, 1048576, 4096, scan_interval=0.05)
rows.append({'case': 'output-limit', 'passed': terminal['guard']['reason'] == 'output_envelope' and terminal['exit'] < 0 and terminal['within_deadline'], 'terminal': terminal})
record = {'finished_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
          'passed': all(r['passed'] for r in rows), 'cases': rows,
          'limitations': 'Controlled normal OS execution only; no absolute suspension/scheduling guarantee. Historical full4h1 lateness cause unproved.'}
(OUT / 'controls.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({'passed': record['passed'], 'cases': [{'case': r['case'], 'passed': r['passed']} for r in rows], 'result': str(OUT / 'controls.json')}), flush=True)
raise SystemExit(0 if record['passed'] else 1)
