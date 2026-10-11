#!/usr/bin/env python3
"""Reproduce frozen controls only; no repairs or new compiler controls.

The shared repair guard is exhausted. Execution requires a new explicit bounded
investigation/independent confirmation authorization; creation of this script
is not that authorization. No execution accompanied the stop commit.
"""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[6]
HERE = pathlib.Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--schema-build', required=True, type=pathlib.Path)
args = parser.parse_args()
base = args.schema_build.resolve()
prior = json.loads((base / 'result.json').read_text())
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
for name, expected in prior['inputs'].items():
    assert digest(ROOT / name) == expected, name
for name, expected in prior['artifacts'].items():
    assert digest(base / name) == expected['sha256'], name
command = next(shlex.split(c) for c in prior['commands'] if '-module-name P08ScopedHostProbe ' in c)
compiler = pathlib.Path(command[0])
assert digest(compiler) == prior['compiler_sha256']
flags = command[1:command.index('-module-name')]
out = pathlib.Path(tempfile.mkdtemp(prefix='p08-activation-join-confirmation-', dir=ROOT / '.build/contracts'))
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
observed = json.loads((HERE / 'observed-controls.json').read_text())
results = []
for control in observed['controls']:
    source = ROOT / control['source']
    assert digest(source) == control['sha256']
    cmd = [str(compiler), *flags, '-module-name', 'P08ActivationJoin', '-emit-object', str(source), '-o', str(out / (control['name'] + '.o'))]
    result = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    log = result.stdout + result.stderr
    (out / (control['name'] + '.log')).write_text(log)
    results.append(dict(name=control['name'], command=shlex.join(cmd), exit=result.returncode, matches_observed=result.returncode != 0 and control['diagnostic'] in log))
(out / 'result.json').write_text(json.dumps(results, indent=2) + '\n')
print(out)
assert all(r['matches_observed'] for r in results)
