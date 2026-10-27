#!/usr/bin/env python3
"""P04 selected Semantic Core/State components; no full-module/adoption claim."""
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
parser.add_argument('--giftui-build', type=pathlib.Path, required=True)
args = parser.parse_args()
base = args.giftui_build.resolve()
core = json.loads((base / 'result.json').read_text())
profile = core['profile']
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
parent /= 'contracts/spec-006-records'
parent.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(dir=parent)) / profile
out.mkdir()
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags += ['-I', str(out), '-I', str(base), '-enable-testing']
commands = []
inputs = [pathlib.Path(__file__).resolve(), ROOT / 'Package.swift']
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

module('GiftUISemanticCore', [ROOT / 'Sources/GiftUISemanticCore/GiftUISemanticCore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordStore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordExpansion.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticStandardPayload.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordPayload.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticLayoutView.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRenderView.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordLayoutView.swift'])
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
module('ScopedTraversal', [ROOT / 'Tests/ContractFixtures/SPEC010/RuntimeDerived/RootProbe.swift',
                           ROOT / 'Tests/ContractFixtures/SPEC006/RuntimeRecords/ScopedTraversalProbe.swift',
                           ROOT / 'Tests/ContractFixtures/SPEC006/RuntimeRecords/RecordBankProbe.swift'])
fixture = ROOT / 'Tests/ContractFixtures/SPEC006/RuntimeRecords'
layout = fixture / 'LayoutProbe.swift'
inputs.append(layout)
run('layouts', [compiler, *flags, '-module-name', 'RecordLayouts', '-emit-ir', layout, '-o', out / 'layouts.ll'])
layout_ir = (out / 'layouts.ll').read_text()
layouts = {}
for name, body in re.findall(r'define[^\n]*@giftui_p04_layout_([a-z0-9_]+)\([^\n]*\)[^{]*\{(.*?)^}', layout_ir, re.S | re.M):
    constant = re.search(r'ret i(?:32|64) (\d+)', body)
    if not constant:
        thunk = re.search(r'tail call swiftcc i(?:32|64) @"([^"]+)"\(\)', body)
        assert thunk, (name, body)
        target = re.search(r'define[^\n]*@"' + re.escape(thunk.group(1)) + r'"\([^\n]*\)[^{]*\{(.*?)^}', layout_ir, re.S | re.M)
        assert target
        constant = re.search(r'ret i(?:32|64) (\d+)', target.group(1))
    assert constant, (name, body)
    layouts[name] = int(constant.group(1))
assert len(layouts) == 7, layouts
layouts['two_bank_reserved_bytes'] = 2 * (layouts['metadata'] + 126 * layouts['record'] + 378 * layouts['prefix'] + 98 * layouts['payload_slot'] + 224 * 4)
(out / 'layouts.json').write_text(json.dumps(layouts, indent=2, sort_keys=True) + '\n')
escape = fixture / 'EscapeView.swift'
inputs.append(escape)
escape_cmd = list(map(str, [compiler, *flags, '-module-name', 'EscapeView', '-emit-object', escape, '-o', out / 'escape.o']))
commands.append(shlex.join(escape_cmd))
(out / 'commands.txt').write_text('\n'.join(commands) + '\n')
negative = subprocess.run(escape_cmd, cwd=ROOT, text=True, capture_output=True)
(out / 'escape.log').write_text(negative.stdout + negative.stderr)
assert negative.returncode != 0 and ("requires that 'SemanticRecordView' conform to 'Escapable'" in negative.stderr), negative.stderr
checks.append({'name': 'borrowed-view-escape-rejected', 'exit': negative.returncode, 'expected_failure': True})
if profile.startswith('macos'):
    main = out / 'Main.swift'
    main.write_text('import ScopedTraversal\n@main struct Main { static func main() { let count = giftuiP04ScopedTraversal(); precondition(count == 30); let banks = giftuiP04RecordBanks(); precondition(banks == 58); let derived = giftuiP04DerivedRecords(); let dynamic = giftuiP04DynamicRecords(); precondition(derived > 0 && derived == dynamic); print("derived-records checks=\(derived) per-profile"); print("record-bank checks=\(banks)"); print("scoped-traversal assertions=30 failures=0") } }\n')
    run('link', [compiler, *flags, main, base / 'GiftUI.o', *sorted(out.glob('*.o')), '-o', out / 'records'])
    execution = run('execute', [out / 'records']).strip()
else:
    readelf = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    abi = run('target-abi', [readelf, '-h', '-A', out / 'ScopedTraversal.o'])
    assert 'Tag_ABI_VFP_args: VFP registers' in abi
    arch = 'v6' if profile == 'raspberry-pi-armv6' else 'v7E-M'
    assert re.search(r'Tag_CPU_arch: ' + arch + r'\s*$', abi, re.MULTILINE)
    execution = 'cross-compiled only; no target execution'
report = {'package': 'P04', 'step': 'runtime-records', 'profile': profile,
          'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
          'source_dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True)),
          'inputs': {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(inputs))},
          'core_receipt': str((base / 'result.json').relative_to(ROOT)), 'core_receipt_sha256': digest(base / 'result.json'),
          'compiler': core['compiler'], 'compiler_sha256': core['compiler_sha256'],
          'commands': commands, 'checks': checks, 'execution': execution, 'layouts': layouts,
          'artifacts': {p.name: {'sha256': digest(p), 'bytes': p.stat().st_size} for p in out.iterdir()
                        if p.is_file() and p.name != 'result.json'}}
(out / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(f'P04 {profile}: {execution}; {out / "result.json"}')
