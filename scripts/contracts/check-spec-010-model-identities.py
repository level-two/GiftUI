#!/usr/bin/env python3
"""P03 ownership components. Reuse a verified P02 core; not a complete P03 exit."""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess
import tempfile

root = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--giftui-build', type=pathlib.Path, required=True)
args = parser.parse_args()
base = args.giftui_build.resolve()
report = json.loads((base / 'result.json').read_text())
profile = report['profile']
for name, digest in report['inputs'].items():
    if name.startswith(('Sources/GiftUI/', 'Sources/GiftUIMacros/')):
        assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert hashlib.sha256((base / name).read_bytes()).hexdigest() == report['artifacts'][name]['sha256']
parent = root / '.build'
if profile == 'raspberry-pi-armv6': parent /= 'raspberry-pi'
if profile == 'nrf52840-embedded': parent /= 'nrf52840'
parent /= 'rfc014-p03/state'
parent.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(dir=parent)) / profile
out.mkdir()
swift = root / report['compiler']
assert hashlib.sha256(swift.read_bytes()).hexdigest() == report['compiler_sha256']
core_command = next(shlex.split(line) for line in (base / 'commands.txt').read_text().splitlines()
                    if '-module-name GiftUI ' in line)
flags = core_command[1:core_command.index('-module-name')] + ['-I', str(out), '-enable-testing']
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
commands = []
executions = []

def run(command, log):
    command = list(map(str, command))
    commands.append(shlex.join(command))
    result = subprocess.run(command, cwd=root, text=True, capture_output=True)
    (out / (log + '.log')).write_text(result.stdout + result.stderr)
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    if result.returncode:
        raise SystemExit(result.stdout + result.stderr)
    return result.stdout

modules = [
    ('GiftUIObservableState', [root / 'Sources/GiftUIObservableState' / name for name in
                              ('ObservableStateValues.swift', 'ObservableModelIdentity.swift', 'ObservableModelOwnership.swift', 'ObservableModelTicket.swift', 'ObservableModelScope.swift')]),
    ('GiftUIRuntimeStatic', [root / 'Sources/GiftUIRuntimeStatic/StaticObservableModelStorage.swift']),
    ('GiftUIRuntimeDynamic', [root / 'Sources/GiftUIRuntimeDynamic/DynamicObservableModelStorage.swift']),
    ('GiftUIFailureCore', sorted((root / 'Sources/GiftUIFailureCore').glob('*.swift'))),
    ('GiftUIObservableStateFailureAdapterFixture', [root / 'Sources/GiftUIObservableStateFailureAdapterFixture/ObservableStateFailureAdapter.swift']),
]
if profile == 'nrf52840-embedded': modules = [entry for entry in modules if entry[0] != 'GiftUIRuntimeDynamic']
for name, files in modules:
    run([swift, *flags, '-module-name', name, '-emit-module', '-emit-object', *files,
         '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')], name)
fixture_root = root / 'Tests/ContractFixtures/SPEC010/RuntimeDerived'
macro = root / '.build/rfc014-p02/tool/debug/GiftUIMacros-tool'
assert hashlib.sha256(macro.read_bytes()).hexdigest() == report['macro_tool_sha256']
run([macro, '--lower-source', fixture_root / 'State.schema.json', fixture_root / 'State.swift',
     out / 'StateSchema.swift', out / 'StatePresentation.swift'], 'state-lowering')
for name, declaration, body, diagnostic in (
    ('state-effectful-seed', '@State var model = CounterModel(value: externalService.read())',
     'Text("value")', 'unsupported call/effect'),
    ('state-wrong-seed', '@State var model = CounterModel(other: 3)',
     'Text("value")', 'inventoried inert model seed'),
    ('state-shadow', '@State var model = CounterModel(value: 1)',
     'let model = 3; Text(BoundedText(Int32(model)))', 'shadows a State declaration'),
    ('state-computed', '@State var model: CounterModel { CounterModel(value: 1) }',
     'Text("value")', 'direct stored instance variable'),
):
    source = out / (name + '.swift')
    source.write_text('import GiftUI\n@ObservableStateHost struct Root: View {\n'
                      + declaration + '\nvar body: some View { ' + body + ' }\n}\n')
    command = list(map(str, [macro, '--lower-source', fixture_root / 'State.schema.json', source,
                            out / (name + '-schema.swift'), out / (name + '-presentation.swift')]))
    commands.append(shlex.join(command))
    result = subprocess.run(command, cwd=root, text=True, capture_output=True)
    (out / (name + '.log')).write_text(result.stdout + result.stderr)
    assert result.returncode != 0 and diagnostic in result.stderr, result.stdout + result.stderr
    assert not (out / (name + '-schema.swift')).exists()
    assert not (out / (name + '-presentation.swift')).exists()
for name in ('StateSchema', 'StatePresentation'):
    files = [out / (name + '.swift')]
    run([swift, *flags, '-module-name', name, '-emit-module', '-emit-object', *files,
         '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')], name)
    modules.append((name, files))
state_probe = fixture_root / 'StateProbe.swift'
run([swift, *flags, '-module-name', 'P03StateProbe', '-emit-object', state_probe,
     '-o', out / 'state-probe.o'], 'state-probe')
probe = root / 'Tests/ContractFixtures/SPEC010/RuntimeDerived' / (
    'DynamicBackingProbe.swift' if profile in ('macos-dynamic', 'raspberry-pi-armv6') else 'BackingProbe.swift')
run([swift, *flags, '-module-name', 'P03BackingProbe', '-emit-object', probe, '-o', out / 'backing-probe.o'], 'backing-probe')
if profile.startswith('macos'):
    for fixture in ('IdentityChecks', 'OwnershipChecks', 'BackingChecks', 'StateChecks'):
        executable = out / fixture
        sources = [root / ('Tests/ContractFixtures/SPEC010/RuntimeDerived/' + fixture + '.swift')]
        if fixture == 'BackingChecks': sources.append(probe)
        if fixture == 'StateChecks': sources.append(state_probe)
        run([swift, *flags, *sources,
             base / 'GiftUI.o', *[out / (name + '.o') for name, _ in modules], '-o', executable], fixture + '-link')
        execution = run([executable], fixture + '-execution').strip()
        executions.append(execution)
        print(execution)
else:
    readelf = root / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    for artifact in ('backing-probe', 'state-probe'):
        abi = run([readelf, '-h', '-A', out / (artifact + '.o')], artifact + '-target-abi')
        assert 'Tag_ABI_VFP_args: VFP registers' in abi
        assert ('Tag_CPU_arch: v6' if profile == 'raspberry-pi-armv6' else 'Tag_CPU_arch: v7E-M') in abi
    print('P03 ownership/backing components: ' + profile + ' compilation/ABI passed; no target execution')

negatives = {
    'state-raw-reference': ('does not conform', '''import GiftUI
        class Model {}
        let state = State<Model>(seed: Model())
    '''),
    'state-assignment': ('get-only', '''import GiftUI
        import StateSchema
        func replace(_ state: inout State<CounterSchema>, _ key: _GiftUIModelKey<CounterSchema>) {
            state.wrappedValue = key
        }
    '''),
    'ticket-escape': ('Escapable', """import GiftUIObservableState
        import GiftUIRuntimeStatic
        enum Schema {}
        func escape(_ storage: inout StaticObservableModelStorage<UInt8, Schema>) throws(ObservableStateError) -> ObservableModelTicket<Schema> {
            try storage.withLifetime { (scope) throws(ObservableStateError) in try scope.materialize(1) }
        }
    """),
    'backing-overlap': ('overlapping accesses', """import GiftUIObservableState
        import GiftUIRuntimeStatic
        enum Schema {}
        func overlap(_ storage: inout StaticObservableModelStorage<UInt8, Schema>) throws(ObservableStateError) {
            try storage.withLifetime { (scope) throws(ObservableStateError) in
                try storage.withLifetime { _ in () }
            }
        }
    """),
}
for name, (diagnostic, source) in negatives.items():
    path = out / (name + '.swift')
    path.write_text(source)
    command = [str(swift), *map(str, flags), '-emit-object', str(path), '-o', str(out / (name + '.o'))]
    commands.append(shlex.join(command))
    result = subprocess.run(command, cwd=root, text=True, capture_output=True)
    (out / (name + '.log')).write_text(result.stdout + result.stderr)
    assert result.returncode != 0 and diagnostic in result.stderr, result.stdout + result.stderr
(out / 'commands.txt').write_text('\n'.join(commands) + '\n')
inputs = sorted(set([pathlib.Path(__file__).resolve(), *[path for _, files in modules for path in files],
                     *fixture_root.glob('*')]))
receipt = {
    'package': 'P03', 'slice': 'State representation and lowering; selected production components',
    'profile': profile, 'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(),
    'core_receipt': str(base / 'result.json'),
    'core_receipt_sha256': hashlib.sha256((base / 'result.json').read_bytes()).hexdigest(),
    'inputs': {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs if p.is_file()},
    'executions': executions, 'negative_controls': [*negatives, 'state-effectful-seed', 'state-wrong-seed', 'state-shadow', 'state-computed'],
    'artifacts': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in out.iterdir()
                  if p.suffix in ('.o', '.swiftmodule', '.swift')},
    'boundary': 'No production reconciler/callback, complete-module, whole-image or target execution claim.',
}
(out / 'result.json').write_text(json.dumps(receipt, indent=2, sort_keys=True) + '\n')
print('P03 State/ownership controls passed: ' + profile + '; ' + str(out / 'result.json'))
