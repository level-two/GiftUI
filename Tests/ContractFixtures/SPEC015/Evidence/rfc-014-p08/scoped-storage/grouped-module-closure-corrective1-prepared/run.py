"""Execute exactly one frozen, sequential dependency-aware compile sweep."""
from pathlib import Path
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent
PLAN = json.loads((PACKET / 'prepared.json').read_text())
OUT = Path(PLAN['output'])

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def verify():
    for receipt in ('input-freeze.json', 'recipe-freeze.json'):
        for name, expected in json.loads((PACKET / receipt).read_text()).items():
            path = Path(name)
            if not path.is_absolute():
                path = ROOT / path
            assert digest(path) == expected, ('frozen input changed', name)
    seen = set()
    for row in PLAN['modules']:
        assert set(row['prerequisites']) <= seen, row['module']
        seen.add(row['module'])
        argv = row['command']
        imports = [argv[i + 1] for i, token in enumerate(argv) if token == '-I']
        assert imports == [str(OUT / 'modules')], imports
        assert argv[0] == PLAN['compiler']
        assert str(OUT / 'owners' / row['module']) == row['output']
    assert len(seen) == 25
    assert not OUT.exists(), 'No automatic retry or output reuse'

verify()
if sys.argv[1:] == ['--validate']:
    print('PASS frozen inputs/recipes, 25-node order, isolated imports; no compiler executed')
    raise SystemExit(0)
assert not sys.argv[1:], 'Only --validate or exact no-argument execution is supported'
OUT.mkdir()
for subdir in ('generated', 'modules', 'owners', 'cache', 'logs'):
    (OUT / subdir).mkdir()
environment = dict(os.environ)
environment.update(PLAN['environment'])
result = {'status': 'running', 'initial': '1/1', 'corrections': '1/2', 'checks': []}

def save():
    (OUT / 'result.json').write_text(json.dumps(result, indent=2) + '\n')

def execute(name, argv):
    log = OUT / 'logs' / (name + '.log')
    started = time.monotonic()
    with log.open('xb') as stream:
        process = subprocess.run(argv, cwd=ROOT, env=environment, stdout=stream,
                                 stderr=subprocess.STDOUT)
    return {'name': name, 'command': argv, 'exit': process.returncode,
            'duration_seconds': round(time.monotonic() - started, 3),
            'log': str(log), 'log_sha256': digest(log),
            'errors': re.findall(r'^.*?:\d+:\d+: error: (.*)$',
                                 log.read_text(errors='replace'), re.M)}

lower = execute('lower', PLAN['lower_command'])
lower['generated_sha256'] = {
    path: digest(Path(path)) for path in PLAN['expected_generated_sha256']
    if Path(path).exists()}
lower['status'] = 'passed' if (
    lower['exit'] == 0 and lower['generated_sha256'] == PLAN['expected_generated_sha256']
) else 'failed'
result['lower'] = lower
save()
print('lower', lower['status'], flush=True)
qualified = {}
for row in PLAN['modules']:
    name = row['module']
    missing = [dep for dep in row['prerequisites'] if dep not in qualified]
    generated = [p for p in row['sources'] if str(OUT / 'generated') in p]
    if missing or (generated and lower['status'] != 'passed'):
        check = {'name': name, 'status': 'blocked', 'missing_fresh_prerequisites': missing,
                 'lower_blocked': bool(generated and lower['status'] != 'passed')}
    else:
        owner = Path(row['output'])
        owner.mkdir()
        check = execute(name, row['command'])
        check['resolved_fresh_imports'] = {
            dep: qualified[dep] for dep in row['prerequisites']}
        check['source_sha256'] = {p: digest(Path(p)) for p in row['sources']}
        check['outputs_sha256'] = {str(p): digest(p) for p in owner.iterdir() if p.is_file()}
        required = [owner / (name + suffix) for suffix in ('.swiftmodule', '.o')]
        check['status'] = 'passed' if check['exit'] == 0 and all(
            p.is_file() for p in required) else 'failed'
        if check['status'] == 'passed':
            published = {}
            for suffix in ('.swiftmodule', '.swiftdoc', '.swiftsourceinfo'):
                artifact = owner / (name + suffix)
                if artifact.exists():
                    target = OUT / 'modules' / artifact.name
                    assert not target.exists()
                    shutil.copyfile(artifact, target)
                    published[str(target)] = digest(target)
            qualified[name] = published
            check['published_imports_sha256'] = published
    result['checks'].append(check)
    save()
    print(name, check['status'], flush=True)
for name, expected in json.loads((PACKET / 'input-freeze.json').read_text()).items():
    path = Path(name) if Path(name).is_absolute() else ROOT / name
    assert digest(path) == expected, ('source/input changed during sweep', name)
result['counts'] = {status: sum(row['status'] == status for row in result['checks'])
                    for status in ('passed', 'failed', 'blocked')}
result['status'] = 'compile_closure_passed' if (
    result['counts']['passed'] == 25 and lower['status'] == 'passed'
) else 'compile_closure_failed'
result['later_gates'] = 'Privacy, physical42-origin/callee/concrete-host, safety and strict cold unexecuted'
save()
print(result['status'], result['counts'], flush=True)
raise SystemExit(0 if result['status'] == 'compile_closure_passed' else 1)
