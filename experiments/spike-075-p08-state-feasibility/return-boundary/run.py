#!/usr/bin/env python3
"""Final control pair: two compilations, one identity, five minutes, no repairs."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import time
import uuid

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PARENT = HERE.parent / 'evidence/run-1'
RUN_ID = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ-') + uuid.uuid4().hex[:8]
OUT = ROOT / '.build/spike-075' / RUN_ID
OUT.mkdir(parents=True, exist_ok=False)
receipt = dict(status='preparing', run_id=RUN_ID, invocations=[], input_hashes={},
               experiment_limit=2, identity_limit=1, deadline_seconds=300,
               prior_experiments=5, prior_identity_queries=2, prior_helper_corrections=1,
               new_repair_rounds=0, experiments=0, identity_queries=0)
start = None

def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()

def save():
    receipt['cumulative_experiments'] = 5 + receipt['experiments']
    receipt['cumulative_identity_queries'] = 2 + receipt['identity_queries']
    temporary = OUT / 'receipt.tmp'
    temporary.write_text(json.dumps(receipt, indent=2) + '\n')
    temporary.replace(OUT / 'receipt.json')

def verify(path, expected):
    actual = digest(path)
    if actual != expected:
        raise RuntimeError('input hash mismatch: ' + str(path))
    receipt['input_hashes'][str(path)] = actual

def invoke(label, command, kind):
    global start
    if start is None:
        start = time.monotonic()
    remaining = 300 - (time.monotonic() - start)
    if remaining <= 0:
        raise RuntimeError('five-minute limit')
    key, limit = ('experiments', 2) if kind == 'experiment' else ('identity_queries', 1)
    if receipt[key] >= limit:
        raise RuntimeError('invocation limit')
    receipt[key] += 1
    entry = dict(label=label, kind=kind, command=command, cwd=str(ROOT), status='recorded-before-spawn')
    receipt['invocations'].append(entry)
    save()
    with (OUT / (label + '.stdout')).open('xb') as stdout, (OUT / (label + '.stderr')).open('xb') as stderr:
        proc = subprocess.Popen(command, cwd=ROOT, stdout=stdout, stderr=stderr, start_new_session=True)
        try:
            entry['exit_code'] = proc.wait(timeout=min(120, remaining))
            entry['status'] = 'exited'
        except BaseException:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()
            entry.update(status='interrupted', exit_code=proc.returncode)
            raise
        finally:
            save()
    output = (OUT / (label + '.stdout')).read_text() + (OUT / (label + '.stderr')).read_text()
    if time.monotonic() - start >= 300:
        raise RuntimeError('five-minute limit')
    if entry['exit_code'] < 0 or re.search(r'Stack dump:|PLEASE submit a bug|Assertion.*failed|Segmentation fault', output, re.I):
        raise RuntimeError('crash: ' + label)
    return entry, output

def interrupted(signum, frame):
    raise InterruptedError('signal ' + str(signum))

signal.signal(signal.SIGTERM, interrupted)
signal.signal(signal.SIGINT, interrupted)
save()
try:
    for relative, expected in json.loads((PARENT / 'SHA256.json').read_text()).items():
        verify(PARENT / relative, expected)
    original = json.loads((PARENT / 'receipt.json').read_text())
    native = Path(original['profile_outputs']['macos-dynamic'])
    snapshots = native.parent / 'sources'
    for name, expected in original['hashes'].items():
        path = snapshots / Path(name).name if name.startswith('experiments/') else ROOT / name
        verify(path, expected)
    artifacts = json.loads((PARENT / 'emitted-artifacts.json').read_text())['artifacts']
    actual = {str(p.relative_to(ROOT)) for p in native.glob('P08Shadow.*') if p.is_file()}
    expected = {name for name in artifacts if '/P08Shadow.' in name}
    if actual != expected:
        raise RuntimeError('module companion set mismatch')
    for name, facts in artifacts.items():
        verify(ROOT / name, facts['sha256'])
    receipt['reused_artifacts'] = artifacts
    for path in HERE.iterdir():
        if path.is_file():
            shutil.copy2(path, OUT / path.name)
            receipt['input_hashes'][str(path)] = digest(path)
    base = next(i['command'] for i in original['invocations'] if i['label'] == 'positive')
    entry, output = invoke('compiler-version', [base[0], '--version'], 'identity')
    if entry['exit_code'] != 0 or 'Apple Swift version 6.4 (swift-6.4-RELEASE)' not in output:
        raise RuntimeError('compiler identity mismatch')
    entry['accepted'] = True
    save()
    for label, filename in [('positive', 'Positive.swift'), ('negative', 'Negative.swift')]:
        command = list(base)
        command[command.index('-module-cache-path') + 1] = str(OUT / 'module-cache')
        command[command.index('-o') + 1] = str(OUT / (label + '.o'))
        command = [str(OUT / filename) if arg.endswith('/Positive.swift') else arg for arg in command]
        entry, output = invoke(label, command, 'experiment')
        errors = [line for line in output.splitlines() if re.search(r'\berror:', line)]
        if label == 'positive':
            accepted = entry['exit_code'] == 0 and not errors
            entry['accepted'] = accepted
        else:
            # A rejection is not a passed control. Strong exit review must tie
            # the actual diagnostic to bank0 escaping through returnLocal.
            accepted = entry['exit_code'] != 0 and bool(errors)
            entry['accepted'] = None
            entry['review_required'] = 'Establish local bank0 return escape, not an annotation/harness error.'
        save()
        if not accepted:
            raise RuntimeError(label + ': unexpected result; no repair or successor')
    receipt['status'] = 'completed-awaiting-strong-diagnostic-review'
except BaseException as error:
    receipt.update(status='stopped', stop_reason=type(error).__name__ + ': ' + str(error))
finally:
    if start is not None:
        receipt['compiler_window_seconds'] = time.monotonic() - start
    receipt['artifact_hashes'] = {p.name: digest(p) for p in OUT.glob('*.o')}
    save()
    print(OUT / 'receipt.json')
    print(receipt['status'], receipt.get('stop_reason', ''))
if receipt['status'] != 'completed-awaiting-strong-diagnostic-review':
    sys.exit(1)
