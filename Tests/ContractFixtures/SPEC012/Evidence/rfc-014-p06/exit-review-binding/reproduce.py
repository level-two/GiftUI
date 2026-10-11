#!/usr/bin/env python3
"""Narrow independent binding-order reproduction; no production edits."""
import hashlib
import json
import pathlib
import shlex
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[6]
HERE = pathlib.Path(__file__).resolve().parent
receipt = json.loads((HERE.parent / 'macos-static.json').read_text())
index = json.loads((HERE.parent / 'final-index.json').read_text())
base = ROOT / pathlib.Path(index['macos-static']['receipt']).parent
core = ROOT / pathlib.Path(receipt['core_receipt']).parent
out = ROOT / '.build/contracts/spec-012-p06-exit-review'
out.mkdir(parents=True, exist_ok=True)
compiler = ROOT / receipt['compiler']
command = shlex.split(next(c for c in receipt['commands'] if '-module-name CounterCanvas ' in c))
flags = command[1:command.index('-module-name')]
flags += ['-I', str(out)]
commands = [
    [str(ROOT / '.build/rfc014-p02/tool/debug/GiftUIMacros-tool'), '--lower-source', str(base / 'Counter.json'), str(HERE / 'CounterCanvas.swift'), str(out / 'CounterSchema.swift'), str(out / 'CounterCanvas.swift')],
    [str(compiler), *flags, '-module-name', 'CounterCanvas', '-emit-module', '-emit-object', str(out / 'CounterCanvas.swift'), '-emit-module-path', str(out / 'CounterCanvas.swiftmodule'), '-o', str(out / 'CounterCanvas.o')],
    [str(compiler), *flags, str(HERE / 'Main.swift'), str(core / 'GiftUI.o'), str(core / 'SignalAnalyzerDomain.o'), *[str(p) for p in sorted(base.glob('*.o')) if p.name != 'CounterCanvas.o'], str(out / 'CounterCanvas.o'), '-o', str(out / 'binding-order')],
    [str(out / 'binding-order')],
]
# Persist exact commands before execution.
(HERE / 'commands.txt').write_text('\n'.join(shlex.join(c) for c in commands) + '\n')
for number, command in enumerate(commands):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (HERE / f'{number}.log').write_text(result.stdout + result.stderr)
    if result.returncode:
        raise SystemExit(f'command {number} failed: {result.stdout}{result.stderr}')
    print(result.stdout, end='')
files = [HERE / 'CounterCanvas.swift', HERE / 'Main.swift', compiler, out / 'CounterCanvas.swift', out / 'CounterCanvas.o', out / 'binding-order']
(HERE / 'result.json').write_text(json.dumps({
    'reviewed_source_commit': '909a7dab8581368aa776c5d93f7f2b0e33d68ec2',
    'core_receipt': receipt['core_receipt'], 'core_receipt_sha256': receipt['core_receipt_sha256'],
    'native_component_only': True,
    'result': (HERE / '3.log').read_text().strip(),
    'files': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
}, indent=2, sort_keys=True) + '\n')
