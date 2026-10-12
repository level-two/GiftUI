#!/usr/bin/env python3
"""Actual P08 finite source/model slice; full application/early images remain open."""
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
core_receipt = json.loads((core / 'result.json').read_text())
macro = ROOT / core_receipt['macro_tool']
assert digest(macro) == core_receipt['macro_tool_sha256']
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert digest(core / name) == core_receipt['artifacts'][name]['sha256']
out = pathlib.Path(tempfile.mkdtemp(prefix='p08-counter-', dir=ROOT / '.build/contracts'))
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags = ['-I', str(out), *flags]
fixture = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived'
inputs = [pathlib.Path(__file__).resolve(), fixture / 'Counter.swift', fixture / 'Counter.schema.json', fixture / 'CounterModel.swift', fixture / 'CounterModelProbe.swift', fixture / 'CounterSemantic.swift', fixture / 'CounterSemanticProbe.swift']
commands, checks = [], []
def run(label, command):
    command = list(map(str, command))
    commands.append(shlex.join(command))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (out / (label + '.log')).write_text(result.stdout + result.stderr)
    checks.append(dict(name=label, exit=result.returncode, passed=result.returncode == 0))
    if result.returncode:
        raise SystemExit(f'{label}: {out}\n{result.stdout}{result.stderr}')
    return result.stdout
run('counter-lowering', [macro, '--lower-source', fixture / 'Counter.schema.json', fixture / 'Counter.swift',
                        out / 'CounterSchema.swift', out / 'Counter.swift', out / 'CounterTable.swift', 'P08CounterPresentation'])
for name, source in (('P08CounterSchema', 'CounterSchema.swift'), ('P08CounterPresentation', 'Counter.swift'), ('P08CounterTable', 'CounterTable.swift')):
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', out / source,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])
run('counter-model', [compiler, *flags, '-module-name', 'P08CounterRuntime', '-emit-module', '-emit-object',
                      fixture / 'CounterModel.swift', fixture / 'CounterModelProbe.swift', fixture / 'CounterSemantic.swift', fixture / 'CounterSemanticProbe.swift',
                      '-emit-module-path', out / 'P08CounterRuntime.swiftmodule', '-o', out / 'P08CounterRuntime.o'])
main = out / 'Main.swift'
main.write_text('import P08CounterRuntime\nimport Darwin\n@main struct Main { static func main() { setbuf(stdout, nil); print("P08 counter source/model assertions=\\(p08CounterModel() + p08CounterSemantic()) failures=0") } }\n')
objects = [path for path in sorted(base.glob('*.o')) if path.name not in ('RuntimeCycleProbe.o', 'CycleSchema.o', 'CyclePresentation.o', 'CycleTable.o')]
run('link', [compiler, *flags, main, core / 'GiftUI.o', *objects, *sorted(out.glob('*.o')), '-o', out / 'counter'])
execution = run('execute', [out / 'counter']).strip()
receipt = dict(scope=__doc__, profile=prior['profile'], compiler=str(compiler.relative_to(ROOT)), compiler_sha256=digest(compiler), runtime_build=str(base.relative_to(ROOT)), runtime_receipt_sha256=digest(base / 'result.json'), inputs={str(p.relative_to(ROOT)): digest(p) for p in inputs}, commands=commands, checks=checks, execution=execution)
receipt['artifacts'] = {str(p.relative_to(out)): dict(sha256=digest(p), bytes=p.stat().st_size) for p in out.iterdir() if p.is_file()}
(out / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(execution)
print('P08_COUNTER_EVIDENCE', out)
