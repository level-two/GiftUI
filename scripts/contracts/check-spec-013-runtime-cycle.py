#!/usr/bin/env python3
"""P07 finite runtime migration checks; full application/resource gates remain P08-P12."""
import argparse
import hashlib
import json
import pathlib
import re
import shlex
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--profile', required=True)
parser.add_argument('--giftui-build', type=pathlib.Path, required=True)
args = parser.parse_args()
base = args.giftui_build.resolve()
core = json.loads((base / 'result.json').read_text())
profile = core['profile']
assert args.profile == profile
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
for name, expected in core['inputs'].items():
    if name.startswith(('Sources/GiftUI/', 'Sources/GiftUIMacros/')):
        assert digest(ROOT / name) == expected, name
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert digest(base / name) == core['artifacts'][name]['sha256']
compiler = ROOT / core['compiler']
assert digest(compiler) == core['compiler_sha256']
command = next(shlex.split(line) for line in (base / 'commands.txt').read_text().splitlines()
               if '-module-name GiftUI ' in line)
flags = command[1:command.index('-module-name')]
parent = ROOT / '.build'
if profile == 'raspberry-pi-armv6': parent /= 'raspberry-pi'
if profile == 'nrf52840-embedded': parent /= 'nrf52840'
parent /= 'contracts/spec-013-runtime-cycle'
parent.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(dir=parent)) / profile
out.mkdir()
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags += ['-I', str(out), '-I', str(base), '-enable-testing']
commands = []
inputs = [pathlib.Path(__file__).resolve(), ROOT / 'Package.swift', ROOT / 'scripts/contracts/run-spec-013.sh', ROOT / 'scripts/contracts/driver-registry.tsv']
checks = []

def run(label, args, failure=None):
    args = list(map(str, args))
    commands.append(shlex.join(args))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    (out / (label + '.log')).write_text(result.stdout + result.stderr)
    okay = result.returncode == 0 if failure is None else result.returncode != 0 and failure in result.stdout + result.stderr
    checks.append({'name': label, 'exit': result.returncode, 'pass': okay, 'expected_failure': failure})
    if not okay:
        raise SystemExit(f'{label}: {out}\n{result.stdout}{result.stderr}')
    return result.stdout

def module(name, sources):
    inputs.extend(sources)
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', *sources,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])

module('GiftUISemanticCore', [ROOT / 'Sources/GiftUISemanticCore/GiftUISemanticCore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordStore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordExpansion.swift', *[ROOT / 'Sources/GiftUISemanticCore' / name for name in ('SemanticStandardPayload.swift', 'SemanticLayoutView.swift', 'SemanticRenderView.swift', 'SemanticRecordLayoutView.swift', 'SemanticRecordRenderView.swift')]])
module('GiftUITextResources', sorted((ROOT / 'Sources/GiftUITextResources').glob('*.swift')))
module('GiftUILayout', sorted((ROOT / 'Sources/GiftUILayout').glob('*.swift')))
module('GiftUIRenderCore', sorted((ROOT / 'Sources/GiftUIRenderCore').glob('*.swift')))
module('GiftUIExecution', sorted((ROOT / 'Sources/GiftUIExecution').glob('*.swift')))
module('GiftUIInteraction', sorted((ROOT / 'Sources/GiftUIInteraction').glob('*.swift')))
module('GiftUIObservableState', [ROOT / 'Sources/GiftUIObservableState' / name for name in (
    'ObservableStateValues.swift', 'ObservableModelIdentity.swift', 'ObservableModelOwnership.swift',
    'ObservableModelTicket.swift', 'ObservableModelScope.swift', 'ObservableModelMutation.swift',
    'ObservableStateModel.swift', 'ObservableStateRegistrationLifecycle.swift', 'ObservableStateRootScope.swift',
    'ObservableStateRootTargetAccess.swift', 'ObservableStateBindingDecorator.swift', 'ObservableSemanticBodyBinding.swift')])
module('GiftUIRenderLowering', [ROOT / 'Sources/GiftUIRenderLowering/RenderProductionValues.swift'])
module('GiftUIDrawing', [ROOT / 'Sources/GiftUIDrawing' / name for name in ('DrawingLimits.swift', 'DrawingValues.swift')])
module('GiftUIRuntimeCore', [ROOT / 'Sources/GiftUIRuntimeCore' / name for name in (
    'RuntimeProfileValues.swift', 'RuntimeProfileValidation.swift', 'RuntimeStorageRegistry.swift',
    'RuntimeOwnerFailure.swift', 'RuntimeCoordinatorCleanup.swift', 'RuntimeCompletePipeline.swift', 'RuntimeCoordinatorContracts.swift', 'RuntimeProfileStorage.swift')])
module('GiftUIRuntimeStatic', [ROOT / 'Sources/GiftUIRuntimeStatic/StaticRuntimeExecutionCoordinator.swift'])
if profile != 'nrf52840-embedded':
    module('GiftUIRuntimeDynamic', [ROOT / 'Sources/GiftUIRuntimeDynamic/DynamicRuntimeExecutionCoordinator.swift'])
module('RuntimeCycleProbe', [ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/RuntimeValuesProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedOwnerProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedCoordinatorProbe.swift'])
for name, source, diagnostic in (
    ('escape-owner', 'struct Escape<M: ~Copyable, S>: ~Copyable { let owner: ScopedOwner<M, S> }', 'non-Escapable'),
    ('copy-owner', 'func copyOwner<M: ~Copyable, S>(_ owner: borrowing ScopedOwner<M, S>) { let other = copy owner; _ = other }', 'noncopyable'),
):
    negative = out / (name + '.swift')
    negative.write_text(source + '\n')
    run(name, [compiler, *flags, '-module-name', 'ScopedOwnerNegative', '-emit-object',
               ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedOwnerProbe.swift', negative,
               '-o', out / (name + '.o')], failure=diagnostic)
for name, source, diagnostic in (
    ('escape-coordinator', 'struct Escape<M: ~Copyable, S>: ~Copyable { let coordinator: ScopedCoordinator<M, S> }', 'non-Escapable'),
    ('copy-coordinator', 'func copyCoordinator<M: ~Copyable, S>(_ coordinator: borrowing ScopedCoordinator<M, S>) { let other = copy coordinator; _ = other }', 'noncopyable'),
):
    negative = out / (name + '.swift')
    negative.write_text(source + '\n')
    run(name, [compiler, *flags, '-module-name', 'ScopedCoordinatorNegative', '-emit-object',
               ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedCoordinatorProbe.swift', negative,
               '-o', out / (name + '.o')], failure=diagnostic)
if profile.startswith('macos'):
    main = out / 'Main.swift'
    main.write_text('import RuntimeCycleProbe\n@main struct Main { static func main() { print("P07 values assertions=\\(giftuiP07Values()) failures=0") } }\n')
    run('link', [compiler, *flags, main, base / 'GiftUI.o', *sorted(out.glob('*.o')), '-o', out / 'runtime-cycle'])
    execution = run('execute', [out / 'runtime-cycle']).strip()
else:
    readelf = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    abi = run('target-abi', [readelf, '-h', '-A', out / 'RuntimeCycleProbe.o'])
    assert 'Tag_ABI_VFP_args: VFP registers' in abi
    arch = 'v6' if profile == 'raspberry-pi-armv6' else 'v7E-M'
    assert re.search(r'Tag_CPU_arch: ' + arch + r'\s*$', abi, re.MULTILINE)
    execution = 'cross-compiled only; no target execution'
report = {'package': 'P07', 'step': 'scoped-coordinator-forwarding', 'profile': profile,
          'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
          'source_dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True)),
          'inputs': {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(inputs))},
          'core_receipt': str((base / 'result.json').relative_to(ROOT)), 'core_receipt_sha256': digest(base / 'result.json'),
          'compiler': core['compiler'], 'compiler_sha256': core['compiler_sha256'],
          'commands': commands, 'checks': checks, 'execution': execution,
          'artifacts': {p.name: {'sha256': digest(p), 'bytes': p.stat().st_size} for p in out.iterdir()
                        if p.is_file() and p.name != 'result.json'}}
(out / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(f'P07 {profile}: {execution}; {out / "result.json"}')
