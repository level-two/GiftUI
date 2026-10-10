#!/usr/bin/env python3
"""P03 first increment. Reuse a verified P02 core module; do not claim a profile exit."""
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
assert report['profile'] == 'macos-static'
for name, digest in report['inputs'].items():
    if name.startswith('Sources/GiftUI/'):
        assert hashlib.sha256((root / name).read_bytes()).hexdigest() == digest, name
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert hashlib.sha256((base / name).read_bytes()).hexdigest() == report['artifacts'][name]['sha256']
out = root / '.build/rfc014-p03/identity'
out.mkdir(parents=True, exist_ok=True)
swift = root / '.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
assert hashlib.sha256(swift.read_bytes()).hexdigest() == report['compiler_sha256']
flags = ['-swift-version', '6', '-enable-experimental-feature', 'LifetimeDependence',
         '-enable-experimental-feature', 'Lifetimes', '-package-name', 'giftui',
         '-module-cache-path', str(out / 'cache'), '-disable-sandbox',
         '-I', str(base), '-I', str(out), '-parse-as-library',
         '-whole-module-optimization', '-enable-testing']
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
                              ('ObservableStateValues.swift', 'ObservableModelIdentity.swift')]),
    ('GiftUIFailureCore', sorted((root / 'Sources/GiftUIFailureCore').glob('*.swift'))),
    ('GiftUIObservableStateFailureAdapterFixture', [root / 'Sources/GiftUIObservableStateFailureAdapterFixture/ObservableStateFailureAdapter.swift']),
]
for name, files in modules:
    run([swift, *flags, '-module-name', name, '-emit-module', '-emit-object', *files,
         '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')], name)
run([swift, *flags, root / 'Tests/ContractFixtures/SPEC010/RuntimeDerived/IdentityChecks.swift',
     base / 'GiftUI.o', *[out / (name + '.o') for name, _ in modules], '-o', out / 'identity-checks'], 'link')
print(run([out / 'identity-checks'], 'execution').strip())
