#!/usr/bin/env python3
"""Replay the frozen independent counterexample without rewriting its history."""
import hashlib
import json
import pathlib
import shlex
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[5]
HERE = pathlib.Path(__file__).resolve().parent
old = HERE / 'exit-review-binding'
evidence = HERE / 'repair-exit-binding'
evidence.mkdir(exist_ok=True)
receipt = json.loads((HERE / 'macos-static.json').read_text())
index = json.loads((HERE / 'final-index.json').read_text())
base = ROOT / pathlib.Path(index['macos-static']['receipt']).parent
core = ROOT / pathlib.Path(receipt['core_receipt']).parent
out = ROOT / '.build/contracts/spec-012-p06-repair-review'
out.mkdir(parents=True, exist_ok=True)
main = (old / 'Main.swift').read_text()
before = 'precondition(began == 1 && outcome == .capacityExhausted && released == 1)'
after = 'precondition(began == 0 && outcome == .invalidModelAccess && released == 1)'
assert main.count(before) == 1
(out / 'Main.swift').write_text(main.replace(before, after))
compiler = ROOT / receipt['compiler']
command = shlex.split(next(c for c in receipt['commands'] if '-module-name CounterCanvas ' in c))
flags = command[1:command.index('-module-name')]
flags += ['-I', str(out)]
commands = [
    [str(ROOT / '.build/rfc014-p02/tool/debug/GiftUIMacros-tool'), '--lower-source', str(base / 'Counter.json'), str(old / 'CounterCanvas.swift'), str(out / 'CounterSchema.swift'), str(out / 'CounterCanvas.swift')],
    [str(compiler), *flags, '-module-name', 'CounterCanvas', '-emit-module', '-emit-object', str(out / 'CounterCanvas.swift'), '-emit-module-path', str(out / 'CounterCanvas.swiftmodule'), '-o', str(out / 'CounterCanvas.o')],
    [str(compiler), *flags, str(out / 'Main.swift'), str(core / 'GiftUI.o'), str(core / 'SignalAnalyzerDomain.o'), *[str(p) for p in sorted(base.glob('*.o')) if p.name != 'CounterCanvas.o'], str(out / 'CounterCanvas.o'), '-o', str(out / 'binding-order')],
    [str(out / 'binding-order')],
]
(evidence / 'commands.txt').write_text('\n'.join(shlex.join(c) for c in commands) + '\n')
for number, command in enumerate(commands):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (evidence / f'{number}.log').write_text(result.stdout + result.stderr)
    if result.returncode:
        raise SystemExit(f'command {number} failed: {result.stdout}{result.stderr}')
    print(result.stdout, end='')
files = [old / 'CounterCanvas.swift', old / 'Main.swift', out / 'Main.swift', compiler,
         ROOT / '.build/rfc014-p02/tool/debug/GiftUIMacros-tool',
         out / 'CounterCanvas.swift', out / 'CounterCanvas.o', out / 'binding-order']
(evidence / 'result.json').write_text(json.dumps({
    'reviewed_source_commit': '431293f9a11fdf7c48020520a37f8be1c31ce304',
    'core_receipt': receipt['core_receipt'], 'core_receipt_sha256': receipt['core_receipt_sha256'],
    'native_component_only': True, 'expected_assertion_change': {'before': before, 'after': after},
    'result': (evidence / '3.log').read_text().strip(),
    'files': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
}, indent=2, sort_keys=True) + '\n')
