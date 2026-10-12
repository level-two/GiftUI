#!/usr/bin/env python3
"""Actual P08 finite counter owner/layout/drawing/render components; host and early images remain open."""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--runtime-build', required=True, type=pathlib.Path)
parser.add_argument('--host-build', type=pathlib.Path, default=ROOT / '.build/contracts/p08-scoped-host-c5eocina')
args = parser.parse_args()
base = args.runtime_build.resolve()
prior = json.loads((base / 'result.json').read_text())
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
for name, expected in prior['inputs'].items():
    if name not in ('Sources/GiftUISemanticCore/SemanticRecordStore.swift', 'Sources/GiftUIHostConfiguration/HostScheduledOpportunityController.swift'):
        assert digest(ROOT / name) == expected, name
for name, expected in prior['artifacts'].items():
    assert digest(base / name) == expected['sha256'], name
command = next(shlex.split(c) for c in prior['commands'] if '-module-name RuntimeCycleProbe ' in c)
compiler = pathlib.Path(command[0])
assert digest(compiler) == prior['compiler_sha256']
flags = command[1:command.index('-module-name')]
core = pathlib.Path(flags[flags.index('-I') + 1])
core_receipt = json.loads((core / 'result.json').read_text())
macro = ROOT / core_receipt['macro_tool']
assert digest(macro) == core_receipt['macro_tool_sha256']
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert digest(core / name) == core_receipt['artifacts'][name]['sha256']
host = args.host_build.resolve()
host_receipt = json.loads((host / 'result.json').read_text())
assert host_receipt['compiler_sha256'] == prior['compiler_sha256']
for name, expected in host_receipt['inputs'].items():
    if name not in ('Sources/GiftUISemanticCore/SemanticRecordStore.swift', 'Sources/GiftUIHostConfiguration/HostScheduledOpportunityController.swift'):
        assert digest(ROOT / name) == expected, name
for name, expected in host_receipt['artifacts'].items():
    assert digest(host / name) == expected['sha256'], name
out = pathlib.Path(tempfile.mkdtemp(prefix='p08-counter-', dir=ROOT / '.build/contracts'))
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags = ['-I', str(out), '-I', str(host), *flags]
fixture = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived'
inputs = [pathlib.Path(__file__).resolve(), fixture / 'Counter.swift', fixture / 'Counter.schema.json', fixture / 'CounterModel.swift', fixture / 'CounterModelProbe.swift', fixture / 'CounterSemantic.swift', fixture / 'CounterSemanticProbe.swift', fixture / 'CounterGeometry.swift', fixture / 'CounterStaticGeometry.swift', fixture / 'CounterRender.swift', fixture / 'CounterFixedStorageProbe.swift']
storage_sources = sorted(fixture.glob('StaticCounter*.swift'))
join_sources = [fixture / name for name in ('CounterAdmission.swift', 'CounterPipelineOwner.swift', 'CounterProfileStorage.swift', 'CounterStorageMeasurement.swift', 'CounterStorageRegions.swift', 'CounterCoordinatorProbe.swift', 'CounterWorkload.swift', 'CounterHostAssembly.swift', 'CounterHostOwner.swift', 'CounterHostProbe.swift')]
inputs.extend(join_sources)
inputs.extend(storage_sources)
commands, checks = [], []
def run(label, command, diagnostic=None):
    command = list(map(str, command))
    commands.append(shlex.join(command))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (out / (label + '.log')).write_text(result.stdout + result.stderr)
    okay = result.returncode == 0 if diagnostic is None else result.returncode != 0 and all(value in result.stdout + result.stderr for value in diagnostic)
    checks.append(dict(name=label, exit=result.returncode, passed=okay, diagnostic=diagnostic))
    if not okay:
        raise SystemExit(f'{label}: {out}\n{result.stdout}{result.stderr}')
    return result.stdout
# Rebuild the unchanged selected runtime graph with the one newly guarded
# Semantic Core reset method. Never import the historical module as fresh source.
rebuilt_runtime = []
for old in prior['commands']:
    pieces = shlex.split(old)
    if '-module-name' not in pieces or '-emit-module' not in pieces:
        continue
    module_name = pieces[pieces.index('-module-name') + 1]
    if not module_name.startswith('GiftUI'):
        continue
    sources = [pathlib.Path(value) for value in pieces[pieces.index('-module-name') + 2:] if value.endswith('.swift')]
    inputs.extend(sources)
    run(module_name, [compiler, *flags, '-module-name', module_name, '-emit-module', '-emit-object', *sources,
                      '-emit-module-path', out / (module_name + '.swiftmodule'), '-o', out / (module_name + '.o')])
    rebuilt_runtime.append(module_name)
host_sources = sorted((ROOT / 'Sources/GiftUIHostConfiguration').glob('*.swift')) + sorted((ROOT / 'Sources/GiftUIHostConfiguration/Generated').glob('*.swift'))
inputs.extend(host_sources)
run('GiftUIHostConfiguration', [compiler, *flags, '-module-name', 'GiftUIHostConfiguration', '-emit-module', '-emit-object', *host_sources,
                               '-emit-module-path', out / 'GiftUIHostConfiguration.swiftmodule', '-o', out / 'GiftUIHostConfiguration.o'])
run('counter-lowering', [macro, '--lower-source', fixture / 'Counter.schema.json', fixture / 'Counter.swift',
                        out / 'CounterSchema.swift', out / 'Counter.swift', out / 'CounterTable.swift', 'P08CounterPresentation'])
for name, source in (('P08CounterSchema', 'CounterSchema.swift'), ('P08CounterPresentation', 'Counter.swift'), ('P08CounterTable', 'CounterTable.swift')):
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', out / source,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])
run('counter-model', [compiler, *flags, '-module-name', 'P08CounterRuntime', '-emit-module', '-emit-object',
                      fixture / 'CounterModel.swift', fixture / 'CounterModelProbe.swift', fixture / 'CounterSemantic.swift', fixture / 'CounterSemanticProbe.swift', fixture / 'CounterGeometry.swift', fixture / 'CounterStaticGeometry.swift', fixture / 'CounterRender.swift', fixture / 'CounterFixedStorageProbe.swift', *storage_sources, *join_sources,
                      '-emit-module-path', out / 'P08CounterRuntime.swiftmodule', '-o', out / 'P08CounterRuntime.o'])
copy_negative = out / 'CounterHostCopyNegative.swift'
copy_negative.write_text('import GiftUIHostConfiguration\nfunc reject(_ host: borrowing SignalAnalyzerPresetHostInstance<CounterHostOwner>) { let duplicate = copy host; _ = duplicate }\n')
backing_negative = out / 'CounterHostBackingNegative.swift'
positive = (fixture / 'CounterHostProbe.swift').read_text().split('package func p08CounterHost()')[0]
positive = positive.replace('let ownedChecks = counterOwnedSchedulerCompatibility(assembly.report)', 'let ownedChecks = 0')
positive = positive.replace('runCounterHost(failAfterRuntime: Bool)', 'rejectCounterHostEscape(failAfterRuntime: Bool)')
positive = positive.replace('        guard case .valid(let audit)', '        var escaped: SignalAnalyzerPresetHostInstance<CounterHostOwner>? = nil\n        guard case .valid(let audit)', 1)
begin = positive.index('                                        precondition(host.lifecycleState')
end = positive.index('                                        return count + 5', begin) + len('                                        return count + 5')
positive = positive[:begin] + '                                        _ = host.activate()\n                                        escaped = consume host\n                                        return 1' + positive[end:]
positive = positive.replace('        return checks', '        var escapedOwner = escaped.take()!\n        _ = escapedOwner.runOpportunity()\n        escapedOwner.teardown()\n        return checks')
backing_negative.write_text(positive)
counter_sources = [fixture / name for name in ('CounterModel.swift', 'CounterModelProbe.swift', 'CounterSemantic.swift', 'CounterSemanticProbe.swift', 'CounterGeometry.swift', 'CounterStaticGeometry.swift', 'CounterRender.swift', 'CounterFixedStorageProbe.swift')]
for label, negative, diagnostic in (
    ('counter-host-copy', copy_negative, ('noncopyable',)),
    ('counter-host-backing', backing_negative, ("lifetime-dependent variable 'escaped' escapes its scope", "activationBacking")),
):
    run(label, [compiler, *flags, '-module-name', 'P08CounterRuntime', '-emit-object', *counter_sources, *storage_sources, *join_sources, negative, '-o', out / (label + '.o')], diagnostic)
main = out / 'Main.swift'
main.write_text('import P08CounterRuntime\nimport Darwin\n@main struct Main { static func main() { setbuf(stdout, nil); print("P08 counter components assertions=\\(p08CounterModel() + p08CounterSemantic() + p08CounterFixedStorage() + p08CounterCoordinator() + p08CounterHost()) failures=0") } }\n')
objects = []  # All selected runtime objects were freshly rebuilt above.
host_objects = [path for path in sorted(host.glob('GiftUI*.o')) if path.name != 'GiftUIHostConfiguration.o']
run('link', [compiler, *flags, main, core / 'GiftUI.o', *objects, *host_objects, *sorted(out.glob('*.o')), '-o', out / 'counter'])
execution = run('execute', [out / 'counter']).strip()
receipt = dict(scope=__doc__, profile=prior['profile'], compiler=str(compiler.relative_to(ROOT)), compiler_sha256=digest(compiler), runtime_build=str(base.relative_to(ROOT)), runtime_receipt_sha256=digest(base / 'result.json'), host_build=str(host.relative_to(ROOT)), host_receipt_sha256=digest(host / 'result.json'), inputs={str(p.relative_to(ROOT)): digest(p) for p in inputs}, commands=commands, checks=checks, execution=execution)
receipt['artifacts'] = {str(p.relative_to(out)): dict(sha256=digest(p), bytes=p.stat().st_size) for p in out.iterdir() if p.is_file()}
(out / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(execution.splitlines()[-1])
print('P08_COUNTER_EVIDENCE', out)
