#!/usr/bin/env python3
"""Opt-in synthetic diagnostic; use a fresh .build output. Does not compile GiftUI."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--variant', required=True, choices=['baseline', 'full-cmo', 'serialized', 'constructor-always', 'generic-pair', 'concrete-pair'])
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
base = Path(__file__).resolve().parent
manifest = json.loads((base / 'manifest.json').read_text())
record = json.loads((base / args.variant / 'result.json').read_text())
compiler = Path('.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc').resolve()
assert hashlib.sha256(compiler.read_bytes()).hexdigest() == record['compiler_sha256']
for name, identity in manifest['retained_dependencies'].items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == identity['sha256'], name
output = args.output.resolve()
assert '.build' in output.parts
output.mkdir(parents=True, exist_ok=False)
for name in ('ProbeCore.swift', 'ProbeCaller.swift', 'ProbeInput.c'):
    shutil.copyfile(base / args.variant / name, output / name)
# Replay the exact captured commands with only the disposable output relocated.
original = str(Path(record['original_output']).parent.resolve())
variant = Path(record['original_output']).name
(output / variant).mkdir()
for index, command in enumerate(record['commands']):
    relocated = [field.replace(original, str(output)) for field in command]
    result = subprocess.run(relocated, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (output / f'command-{index}.log').write_bytes(result.stdout)
    assert result.returncode == 0, (index, result.returncode)
    if index == len(record['commands']) - 1:
        print('\n'.join(line for line in result.stdout.decode().splitlines() if line.startswith(('ENTRY ', 'WINDOW '))))
