#!/usr/bin/env python3
"""P03 ownership components. Reuse a verified P02 core; not a complete P03 exit."""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess

root = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--giftui-build', type=pathlib.Path, required=True)
args = parser.parse_args()
base = args.giftui_build.resolve()
report = json.loads((base / 'result.json').read_text())
profile = report['profile']
for name, digest in report['inputs'].items():
    if name.startswith('Sources/GiftUI/'):
        assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert hashlib.sha256((base / name).read_bytes()).hexdigest() == report['artifacts'][name]['sha256']
parent = root / '.build'
if profile == 'raspberry-pi-armv6': parent /= 'raspberry-pi'
if profile == 'nrf52840-embedded': parent /= 'nrf52840'
out = parent / 'rfc014-p03/ownership' / profile
out.mkdir(parents=True, exist_ok=True)
swift = root / report['compiler']
assert hashlib.sha256(swift.read_bytes()).hexdigest() == report['compiler_sha256']
core_command = next(shlex.split(line) for line in (base / 'commands.txt').read_text().splitlines()
                    if '-module-name GiftUI ' in line)
flags = core_command[1:core_command.index('-module-name')] + ['-I', str(out), '-enable-testing']
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
commands = []

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
probe = root / 'Tests/ContractFixtures/SPEC010/RuntimeDerived' / (
    'DynamicBackingProbe.swift' if profile in ('macos-dynamic', 'raspberry-pi-armv6') else 'BackingProbe.swift')
run([swift, *flags, '-module-name', 'P03BackingProbe', '-emit-object', probe, '-o', out / 'backing-probe.o'], 'backing-probe')
if profile.startswith('macos'):
    for fixture in ('IdentityChecks', 'OwnershipChecks', 'BackingChecks'):
        executable = out / fixture
        sources = [root / ('Tests/ContractFixtures/SPEC010/RuntimeDerived/' + fixture + '.swift')]
        if fixture == 'BackingChecks': sources.append(probe)
        run([swift, *flags, *sources,
             base / 'GiftUI.o', *[out / (name + '.o') for name, _ in modules], '-o', executable], fixture + '-link')
        print(run([executable], fixture + '-execution').strip())
else:
    readelf = root / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    abi = run([readelf, '-h', '-A', out / 'backing-probe.o'], 'target-abi')
    assert 'Tag_ABI_VFP_args: VFP registers' in abi
    assert ('Tag_CPU_arch: v6' if profile == 'raspberry-pi-armv6' else 'Tag_CPU_arch: v7E-M') in abi
    print('P03 ownership/backing components: ' + profile + ' compilation/ABI passed; no target execution')

negatives = {
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
print('P03 scope escape/overlap negatives passed: ' + profile)
