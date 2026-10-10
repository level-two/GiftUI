#!/usr/bin/env python3
"""P05 borrowed Layout component evidence; broad conformance remains P10."""
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
parent /= 'contracts/spec-007-bank-layout'
parent.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(dir=parent)) / profile
out.mkdir()
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags += ['-I', str(out), '-I', str(base), '-enable-testing']
commands = []
inputs = [pathlib.Path(__file__).resolve(), ROOT / 'Package.swift', ROOT / 'scripts/contracts/run-spec-007.sh', ROOT / 'scripts/contracts/driver-registry.tsv']
inputs.extend(ROOT / 'Tests/GiftUILayoutTests' / name for name in ('LayoutStackTests.swift', 'LayoutTextTests.swift', 'LayoutGeometryTests.swift'))
checks = []

def run(label, args):
    args = list(map(str, args))
    commands.append(shlex.join(args))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    (out / (label + '.log')).write_text(result.stdout + result.stderr)
    checks.append({'name': label, 'exit': result.returncode})
    if result.returncode:
        raise SystemExit(f'{label}: {out}\n{result.stdout}{result.stderr}')
    return result.stdout

def module(name, sources):
    inputs.extend(sources)
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', *sources,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])

module('GiftUISemanticCore', [ROOT / 'Sources/GiftUISemanticCore/GiftUISemanticCore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordStore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordExpansion.swift', *[ROOT / 'Sources/GiftUISemanticCore' / name for name in ('SemanticStandardPayload.swift', 'SemanticLayoutView.swift', 'SemanticRenderView.swift', 'SemanticRecordLayoutView.swift', 'SemanticRecordRenderView.swift')]])
module('GiftUIExecution', [ROOT / 'Sources/GiftUIExecution/ObservableTargetGeneration.swift'])
module('GiftUIObservableState', [ROOT / 'Sources/GiftUIObservableState' / name for name in (
    'ObservableStateValues.swift', 'ObservableModelIdentity.swift', 'ObservableModelOwnership.swift',
    'ObservableModelTicket.swift', 'ObservableModelScope.swift', 'ObservableModelMutation.swift',
    'ObservableStateModel.swift', 'ObservableStateRegistrationLifecycle.swift', 'ObservableStateRootScope.swift',
    'ObservableStateRootTargetAccess.swift', 'ObservableStateBindingDecorator.swift', 'ObservableSemanticBodyBinding.swift')])
module('GiftUIRuntimeStatic', [ROOT / 'Sources/GiftUIRuntimeStatic' / name for name in (
    'StaticObservableModelStorage.swift', 'StaticObservableRootAdapter.swift', 'StaticObservableRootTargetAccess.swift', 'StaticSemanticRecordStorage.swift')])
if profile != 'nrf52840-embedded':
    module('GiftUIRuntimeDynamic', [ROOT / 'Sources/GiftUIRuntimeDynamic/DynamicSemanticRecordStorage.swift'])
module('GiftUITextResources', sorted((ROOT / 'Sources/GiftUITextResources').glob('*.swift')))
module('GiftUILayout', sorted((ROOT / 'Sources/GiftUILayout').glob('*.swift')))
module('GiftUIRenderCore', sorted((ROOT / 'Sources/GiftUIRenderCore').glob('*.swift')))
module('GiftUIRenderLowering', sorted((ROOT / 'Sources/GiftUIRenderLowering').glob('*.swift')))

fixture = ROOT / 'Tests/ContractFixtures/SPEC007/RuntimeDerived'
module('BankLayoutProbe', [fixture / 'LayoutSupport.swift', fixture / 'LayoutProbe.swift', fixture / 'LayoutOracleProbe.swift'])
for name in ('EscapeLayout', 'EscapeRender'):
    source = fixture / (name + '.swift')
    inputs.append(source)
    cmd = list(map(str, [compiler, *flags, '-module-name', name, '-emit-object', source, '-o', out / (name + '.o')]))
    commands.append(shlex.join(cmd))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    negative = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True)
    (out / (name + '.log')).write_text(negative.stdout + negative.stderr)
    assert negative.returncode != 0 and "does not conform to protocol 'Escapable'" in negative.stderr, negative.stderr
    checks.append({'name': name, 'exit': negative.returncode, 'expected_failure': True})
if profile.startswith('macos'):
    main = out / 'Main.swift'
    main.write_text('import BankLayoutProbe\n@main struct Main { static func main() { let count = giftuiP05Layout() + giftuiP05LayoutOracle(); print("P05 Layout assertions=\\(count) failures=0") } }\n')
    run('link', [compiler, *flags, main, base / 'GiftUI.o', *sorted(out.glob('*.o')), '-o', out / 'layout'])
    execution = run('execute', [out / 'layout']).strip()
else:
    readelf = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    abi = run('target-abi', [readelf, '-h', '-A', out / 'BankLayoutProbe.o'])
    assert 'Tag_ABI_VFP_args: VFP registers' in abi
    arch = 'v6' if profile == 'raspberry-pi-armv6' else 'v7E-M'
    assert re.search(r'Tag_CPU_arch: ' + arch + r'\s*$', abi, re.MULTILINE)
    execution = 'cross-compiled only; no target execution'
report = {'package': 'P05', 'step': 'borrowed-layout', 'profile': profile,
          'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
          'source_dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True)),
          'inputs': {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(inputs))},
          'owner_command': 'scripts/contracts/run-spec-007.sh --profile ' + profile + ' --compiler-baseline rfc-014 --giftui-build ' + str(base.relative_to(ROOT)),
          'core_receipt': str((base / 'result.json').relative_to(ROOT)), 'core_receipt_sha256': digest(base / 'result.json'),
          'compiler': core['compiler'], 'compiler_sha256': core['compiler_sha256'],
          'commands': commands, 'checks': checks, 'execution': execution,
          'artifacts': {p.name: {'sha256': digest(p), 'bytes': p.stat().st_size} for p in out.iterdir()
                        if p.is_file() and p.name != 'result.json'}}
(out / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(f'P05 {profile}: {execution}; {out / "result.json"}')
