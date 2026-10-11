#!/usr/bin/env python3
"""Compile-only SPEC-015 boundary proof. Proposed declarations are not authority."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--runtime-build', type=Path, required=True)
args = parser.parse_args()
build = args.runtime_build.resolve()
receipt = json.loads((build / 'result.json').read_text())
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
assert all(c['pass'] for c in receipt['checks'])
for name, expected in receipt['inputs'].items():
    assert digest(ROOT / name) == expected, name
for name, expected in receipt['artifacts'].items():
    assert digest(build / name) == expected['sha256'], name
assert digest(Path(receipt['compiler'])) == receipt['compiler_sha256']
assert digest(ROOT / receipt['core_receipt']) == receipt['core_receipt_sha256']
command = next(shlex.split(c) for c in receipt['commands'] if '-module-name RuntimeCycleProbe ' in c)
flags = command[:command.index('-module-name')]
source = ROOT / 'Sources/GiftUIHostConfiguration/HostConfigurationResults.swift'
production = source.read_text()
start = production.index('package enum MVPHostLifecycleState')
end = production.index('package protocol MVPHostConfigurationValidator', start)
current = (HERE / 'Current.swift').read_text()
assert production[start:end] in current, 'Current must retain exact host declarations'
assert 'StaticRuntimeExecutionCoordinator' in current and 'DynamicRuntimeExecutionCoordinator' in current
proposal = current.replace('package protocol MVPHostInstance: ~Copyable {', 'package protocol MVPHostInstance: ~Copyable, ~Escapable {')
(HERE / 'Proposed.swift').write_text(proposal)
concrete = proposal.replace('var host = ScopedHost(coordinator: consume coordinator)', 'let result = constructScoped(coordinator: consume coordinator)\n    guard case .constructed(var host) = consume result else { return }')
concrete += '''
// Evidence-only inert validation-result payload. This proof does not validate.
package struct HostValidationResult {}
// Existing internal result cases with explicit generic lifetime constraints.
package enum HostPresetConstructionResult<Instance>: ~Copyable, ~Escapable
where Instance: MVPHostInstance & ~Copyable & ~Escapable {
    case invalid(HostValidationResult)
    case constructed(Instance)
}
// Candidate internal concrete return, dependent on the consumed coordinator.
// No associated Instance and no escaping callback or pointer fallback.
@_lifetime(copy coordinator)
func constructScoped<Coordinator>(coordinator: consuming Coordinator)
    -> HostPresetConstructionResult<ScopedHost<Coordinator>>
where Coordinator: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable {
    .constructed(ScopedHost(coordinator: consume coordinator))
}
'''
(HERE / 'ConcreteConstruction.swift').write_text(concrete)
constraints = 'where C: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable'
(HERE / 'CopyHost.swift').write_text(concrete + '\nfunc forbiddenCopy<C>(_ host: borrowing ScopedHost<C>)\n' + constraints + ' {\n    let copied = copy host\n    _ = consume copied\n}\n')
(HERE / 'EscapeHost.swift').write_text(concrete + '\nstruct EscapingBox<C>\n' + constraints + ' { let host: ScopedHost<C> }\n')
bootstrap = ROOT / 'Sources/GiftUIHostConfiguration/HostPresetBootstrap.swift'
factory_source = bootstrap.read_text()
start = factory_source.index('package protocol MVPValidatedHostInstanceFactory')
end = factory_source.index('package enum HostPresetConstructionResult', start)
factory = proposal + '\npackage struct HostConstructedInstanceAudit: Equatable, Sendable {}\n' + factory_source[start:end]
factory += '''
struct ProbeFactory<C>: MVPValidatedHostInstanceFactory
where C: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable {
    typealias Instance = ScopedHost<C>
    @_lifetime(copy self)
    mutating func construct(validatedBy report: HostAssemblyReport) -> Instance { fatalError() }
    borrowing func audit(_ instance: borrowing Instance) -> HostConstructedInstanceAudit { .init() }
}
'''
(HERE / 'FactoryCurrent.swift').write_text(factory)
(HERE / 'FactorySuppressionRejected.swift').write_text(factory.replace('associatedtype Instance: MVPHostInstance', 'associatedtype Instance: MVPHostInstance & ~Copyable & ~Escapable'))
parent = ROOT / '.build/contracts/spec-015-lifetime-boundary'
parent.mkdir(parents=True, exist_ok=True)
out = Path(tempfile.mkdtemp(prefix='p08-', dir=parent))
expected = {'Current': "inherited protocol 'Escapable'", 'Proposed': None, 'ConcreteConstruction': None, 'CopyHost': "noncopyable", 'EscapeHost': "Escapable", 'FactoryCurrent': "does not conform to 'Copyable'", 'FactorySuppressionRejected': "cannot suppress 'Escapable' requirement of an associated type"}
results, commands = {}, []
for name, diagnostic in expected.items():
    invocation = [*flags, '-module-name', 'P08HostLifetimeProof', '-emit-object', str(HERE / (name + '.swift')), '-o', str(out / (name + '.o'))]
    commands.append(shlex.join(invocation))
    completed = subprocess.run(invocation, cwd=ROOT, text=True, capture_output=True)
    output = completed.stdout + completed.stderr
    (HERE / (name + '.log')).write_text(output)
    if diagnostic is None:
        assert completed.returncode == 0, output
    else:
        assert completed.returncode != 0 and diagnostic in output, output
    results[name] = {'exit': completed.returncode, 'expected_diagnostic': diagnostic, 'source_sha256': digest(HERE / (name + '.swift')), 'log_sha256': digest(HERE / (name + '.log'))}
    artifact = out / (name + '.o')
    if artifact.exists(): results[name]['object_sha256'] = digest(artifact)
(HERE / 'commands.txt').write_text('\n'.join(commands) + '\n')
tracked = [source, bootstrap, ROOT / 'docs/specs/spec-015-host-configuration.md', ROOT / 'docs/specs/spec-013-runtime-profiles.md', ROOT / 'docs/specs/spec-009-execution-cycle-and-frame-handoff.md']
(HERE / 'result.json').write_text(json.dumps({'source_commit': subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(), 'source_dirty': bool(subprocess.check_output(['git','status','--porcelain'],cwd=ROOT,text=True)), 'authority_and_source_sha256': {str(p.relative_to(ROOT)): digest(p) for p in tracked}, 'runtime_receipt': str(build / 'result.json'), 'runtime_receipt_sha256': digest(build / 'result.json'), 'verified_runtime_inputs': len(receipt['inputs']), 'verified_runtime_artifacts': len(receipt['artifacts']), 'compiler': receipt['compiler'], 'compiler_sha256': receipt['compiler_sha256'], 'object_directory': str(out.relative_to(ROOT)), 'results': results, 'scope': 'compile-only exact host/protocol and actual P07 coordinator types; inert report/audit/result payload scaffolding; no host validation, runtime execution, lifecycle, resource, target or package acceptance'},indent=2,sort_keys=True)+'\n')
print(json.dumps(results,indent=2))
