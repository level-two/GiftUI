#!/usr/bin/env python3
"""P08 first slice: scoped host/controller components, excluding schema migration.

This explicitly selected module gate does not replace the complete SPEC-015 gate.
"""
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
args = parser.parse_args()
base = args.runtime_build.resolve()
prior = json.loads((base / 'result.json').read_text())
assert prior['profile'].startswith('macos'), 'first-slice execution is native only'
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
for name, expected in prior['inputs'].items():
    assert digest(ROOT / name) == expected, name
for name, expected in prior['artifacts'].items():
    assert digest(base / name) == expected['sha256'], name
command = next(shlex.split(c) for c in prior['commands'] if '-module-name RuntimeCycleProbe ' in c)
compiler = pathlib.Path(command[0])
assert digest(compiler) == prior['compiler_sha256']
flags = command[1:command.index('-module-name')]
core = pathlib.Path(flags[flags.index('-I') + 1])
out = pathlib.Path(tempfile.mkdtemp(prefix='p08-scoped-host-', dir=ROOT / '.build/contracts'))
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags += ['-I', str(out)]
commands, checks = [], []
inputs = [pathlib.Path(__file__).resolve()]
# Selected SO-06 delivery remains the separately invoked counter driver; hash its
# source boundary without importing fixture-private access types into owned routes.
inputs.extend([ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift', ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorageProbe.swift'])
def run(label, command, diagnostic=None):
    command = list(map(str, command))
    commands.append(shlex.join(command))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    log = result.stdout + result.stderr
    (out / (label + '.log')).write_text(log)
    okay = result.returncode == 0 if diagnostic is None else result.returncode != 0 and diagnostic in log
    checks.append(dict(name=label, exit=result.returncode, passed=okay, diagnostic=diagnostic))
    if not okay:
        raise SystemExit(f'{label}: {out}\n{log}')
    return result.stdout
for name in ('GiftUICapabilities', 'GiftUIFailureCore', 'GiftUISurfaceCore', 'GiftUIDisplayCore', 'GiftUIRasterCore', 'GiftUIBackendIntegration', 'GiftUIHostConfiguration'):
    # Generated schema-3 projections are intentionally outside this component slice.
    sources = sorted((ROOT / 'Sources' / name).glob('*.swift'))
    inputs.extend(sources)
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', *sources,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])
probe = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/ScopedHostProbe.swift'
inputs.append(probe)
run('scoped-host-probe', [compiler, *flags, '-module-name', 'P08ScopedHostProbe', '-emit-module', '-emit-object', probe,
                        '-emit-module-path', out / 'P08ScopedHostProbe.swiftmodule', '-o', out / 'P08ScopedHostProbe.o'])
for label, source, diagnostic in (
    ('copy-host', 'func reject(_ host: borrowing SignalAnalyzerPresetHostInstance<P08ScopedLiveOwner>) { let other = copy host; _ = other }', 'noncopyable'),
    ('escape-host', 'struct Reject: ~Copyable { let host: SignalAnalyzerPresetHostInstance<P08ScopedLiveOwner> }', 'non-Escapable'),
):
    path = out / (label + '.swift')
    path.write_text('import GiftUIHostConfiguration\n' + source + '\n')
    run(label, [compiler, *flags, '-module-name', 'P08ScopedHostNegative', '-emit-object', probe, path,
                '-o', out / (label + '.o')], diagnostic)
main = out / 'Main.swift'
main.write_text('import P08ScopedHostProbe\n@main struct Main { static func main() { print("P08 scoped host assertions=\\(p08ScopedHostController()) failures=0") } }\n')
run('link', [compiler, *flags, main, core / 'GiftUI.o', *sorted(base.glob('*.o')), *sorted(out.glob('*.o')), '-o', out / 'scoped-host'])
execution = run('execute', [out / 'scoped-host']).strip()
receipt = dict(scope='P08 scoped host/controller component; generated schema and complete application gates remain open', profile=prior['profile'], runtime_build=str(base.relative_to(ROOT)), runtime_receipt_sha256=digest(base / 'result.json'), compiler=str(compiler.relative_to(ROOT)), compiler_sha256=digest(compiler), inputs={str(p.relative_to(ROOT)): digest(p) for p in inputs}, checks=checks, execution=execution, commands=commands)
receipt['artifacts'] = {str(p.relative_to(out)): dict(sha256=digest(p), bytes=p.stat().st_size) for p in out.iterdir() if p.is_file()}
(out / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(execution)
print('P08_SCOPED_HOST_EVIDENCE', out)
