#!/usr/bin/env python3
"""Reproduce only the exact Source ownership constraint, not a runtime implementation."""
import hashlib
import json
import pathlib
import shlex
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[6]
OUT = pathlib.Path(__file__).resolve().parent
BASE = ROOT / '.build/contracts/spec-006-rfc-014/d18dacad362b4a35-znvim124/macos-static'
RECORDS = ROOT / '.build/contracts/spec-006-records/tmpuu24enfv/macos-static'
core = json.loads((BASE / 'result.json').read_text())

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

compiler = ROOT / core['compiler']
assert digest(compiler) == core['compiler_sha256']
for name in ('GiftUI.swiftmodule', 'GiftUI.o'):
    assert digest(BASE / name) == core['artifacts'][name]['sha256']
records = json.loads((RECORDS / 'result.json').read_text())
for name, value in records['inputs'].items():
    if name.startswith('Sources/GiftUIObservableState/'):
        assert digest(ROOT / name) == value
command = next(shlex.split(line) for line in (BASE / 'commands.txt').read_text().splitlines()
               if '-module-name GiftUI ' in line)
flags = command[1:command.index('-module-name')]
flags += ['-I', str(BASE), '-I', str(RECORDS)]
contract = ROOT / 'Sources/GiftUIDrawing/CanvasInvocationSource.swift'
source = ROOT / 'Tests/ContractFixtures/SPEC012/RuntimeDerived/ScopedSourceConstraint.swift'
commands = []
results = []
for name, declaration in (
    ('current', contract),
    ('copyable-only-proposal', OUT / 'CopyableOnly.proposed.swift'),
    ('proposed', OUT / 'CanvasInvocationSource.proposed.swift'),
):
    if name != 'current':
        suppressions = '~Copyable' if name == 'copyable-only-proposal' else '~Copyable, ~Escapable'
        declaration.write_text(contract.read_text().replace('protocol CanvasInvocationSource {',
                                                           'protocol CanvasInvocationSource: ' + suppressions + ' {'))
    cmd = [compiler, *flags, '-module-name', 'ConstraintProof', '-emit-object', declaration, source,
           '-o', ROOT / '.build/p06-constraint-proof.o']
    cmd = list(map(str, cmd))
    commands.append(shlex.join(cmd))
    result = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    output = result.stdout + result.stderr
    (OUT / (name + '.log')).write_text(output)
    expected = 0 if name == 'proposed' else 1
    assert result.returncode == expected, output
    if name == 'current': assert "does not conform to protocol 'Copyable'" in output
    if name == 'copyable-only-proposal': assert "does not conform to protocol 'Escapable'" in output
    results.append({'case': name, 'exit': result.returncode, 'log_sha256': digest(OUT / (name + '.log'))})

# Isolate the same default generic requirement spelled by derive's Source clause.
# This is a minimal constraint proof, not a copied implementation of the producer.
for name, constraint in [('producer-current', ''), ('producer-proposed', ' & ~Copyable & ~Escapable')]:
    entry = OUT / (name + '.swift')
    entry.write_text('''import GiftUI
import GiftUIObservableState
package func producer<Source: CanvasInvocationSourceCONSTRAINT>(source: inout Source) {}
package func call<Model: ~Copyable, Schema>(source: inout ScopedCanvasSource<Model, Schema>) {
    producer(source: &source)
}
'''.replace('CONSTRAINT', constraint))
    cmd = list(map(str, [compiler, *flags, '-module-name', 'ConstraintProof', '-emit-object',
                        OUT / 'CanvasInvocationSource.proposed.swift', source, entry,
                        '-o', ROOT / '.build/p06-constraint-proof.o']))
    commands.append(shlex.join(cmd))
    result = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
    output = result.stdout + result.stderr
    (OUT / (name + '.log')).write_text(output)
    assert result.returncode == (1 if name == 'producer-current' else 0), output
    if name == 'producer-current': assert 'Copyable' in output and 'Escapable' in output
    results.append({'case': name, 'exit': result.returncode, 'log_sha256': digest(OUT / (name + '.log'))})
(OUT / 'commands.txt').write_text('\n'.join(commands) + '\n')
inputs = [contract, source, ROOT / 'Sources/GiftUIDrawing/CanvasPlanProducer.swift',
          ROOT / 'Sources/GiftUIObservableState/ObservableModelScope.swift', pathlib.Path(__file__).resolve()]
report = {'compiler': core['compiler'], 'compiler_sha256': core['compiler_sha256'],
          'core_receipt': str(BASE.relative_to(ROOT) / 'result.json'), 'core_receipt_sha256': digest(BASE / 'result.json'),
          'records_receipt': str(RECORDS.relative_to(ROOT) / 'result.json'), 'records_receipt_sha256': digest(RECORDS / 'result.json'),
          'inputs': {str(path.relative_to(ROOT)): digest(path) for path in inputs},
          'observable_module_sha256': digest(RECORDS / 'GiftUIObservableState.swiftmodule'), 'results': results}
(OUT / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print('P06 source constraint proof: current rejects; both suppressions and generic forwarding compile')
