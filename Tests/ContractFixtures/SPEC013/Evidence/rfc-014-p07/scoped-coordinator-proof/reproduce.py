#!/usr/bin/env python3
"""Exact scoped conformance probe; proposed protocols are evidence-only shadows."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess

ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--runtime-build', type=Path, required=True)
args = parser.parse_args()
build = args.runtime_build.resolve()
receipt = json.loads((build / 'result.json').read_text())
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
for name, expected in receipt['inputs'].items():
    assert digest(ROOT / name) == expected, name
for name, expected in receipt['artifacts'].items():
    assert digest(build / name) == expected['sha256'], name
command = next(shlex.split(c) for c in receipt['commands'] if '-module-name RuntimeCycleProbe ' in c)
flags = command[:command.index('-module-name')]
current = (HERE / 'Current.swift').read_text()
proposal = current.replace('ExecutionAdmissionSink, ExecutionOpportunityRunner', 'ProposedAdmissionSink, ProposedOpportunityRunner')
proposal += '''
// Proposed declaration correction only. Exact fact/result signatures retained.
protocol ProposedAdmissionSink: ~Copyable, ~Escapable {
    associatedtype StateChangeFact: Sendable
    associatedtype CompletionFact: Sendable
    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome
    mutating func submit(stateChange: StateChangeFact) -> ExecutionAdmissionOutcome
    mutating func submit(completion: CompletionFact) -> ExecutionAdmissionOutcome
}
protocol ProposedOpportunityRunner: ~Copyable, ~Escapable {
    associatedtype OwnerFailure: Equatable & Sendable
    mutating func runOpportunity() -> RunCycleResult<OwnerFailure>
}
func run<Model: ~Copyable, Schema>(_ models: borrowing ObservableModelScope<Model, Schema>) {
    var coordinator = ScopedCoordinator(models: models.borrowedScope())
    _ = coordinator.submit(stateChange: 1)
    _ = coordinator.runOpportunity()
}
'''
(HERE / 'Proposed.swift').write_text(proposal)
(HERE / 'CopyableOnly.swift').write_text(proposal.replace('protocol ProposedAdmissionSink: ~Copyable, ~Escapable', 'protocol ProposedAdmissionSink: ~Copyable').replace('protocol ProposedOpportunityRunner: ~Copyable, ~Escapable', 'protocol ProposedOpportunityRunner: ~Copyable'))
results = {}
commands = []
for name in ['Current', 'CopyableOnly', 'Proposed']:
    invocation = [*flags, '-module-name', 'ScopedCoordinatorProof', '-emit-object', str(HERE / (name + '.swift')), '-o', str(build / (name + 'Coordinator.o'))]
    commands.append(shlex.join(invocation))
    completed = subprocess.run(invocation, cwd=ROOT, text=True, capture_output=True)
    output = completed.stdout + completed.stderr
    (HERE / (name + '.log')).write_text(output)
    if name == 'Current':
        assert completed.returncode != 0 and "protocol 'Copyable'" in output, output
    elif name == 'CopyableOnly':
        assert completed.returncode != 0 and "protocol 'Escapable'" in output, output
    else:
        assert completed.returncode == 0, output
    results[name] = {'exit': completed.returncode, 'source_sha256': digest(HERE / (name + '.swift')), 'log_sha256': digest(HERE / (name + '.log'))}
(HERE / 'commands.txt').write_text('\n'.join(commands) + '\n')
(HERE / 'result.json').write_text(json.dumps({'source_commit': subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(), 'source_dirty': bool(subprocess.check_output(['git','status','--porcelain'],cwd=ROOT,text=True)), 'runtime_receipt': str(build / 'result.json'), 'runtime_receipt_sha256': digest(build / 'result.json'), 'compiler': receipt['compiler'], 'compiler_sha256': receipt['compiler_sha256'], 'results': results, 'scope': 'compile-only actual model-scope conformance; no integrated runtime execution or acceptance'},indent=2,sort_keys=True)+'\n')
print(json.dumps(results,indent=2))
