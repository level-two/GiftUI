#!/usr/bin/env python3
"""Build the exact CMake-selected lower owners for a host-native rehearsal."""
import argparse
import csv
import os
from pathlib import Path
import re
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
manifest = root / '.build/nrf52840/signal-analyzer-static/swift-owner-sources.tsv'
output = args.output.resolve()
modules = output / 'modules'
modules.mkdir(parents=True, exist_ok=True)
cache = output / 'clang-cache'
cache.mkdir(exist_ok=True)
environment = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(cache))
sources = {}
with manifest.open() as stream:
    for row in csv.DictReader(stream, delimiter='\t'):
        sources.setdefault(row['owner'], []).append(Path(row['source']))
dependencies = {
    owner: set().union(*(set(re.findall(r'^import (\w+)$', path.read_text(), re.M))
                         for path in paths))
    for owner, paths in sources.items()
}
objects = []
pending = set(sources)
while pending:
    ready = sorted(owner for owner in pending if not dependencies[owner] & pending)
    if not ready:
        raise SystemExit('selected owner import graph has a cycle')
    for owner in ready:
        missing = dependencies[owner] - sources.keys()
        if missing:
            raise SystemExit(f'{owner}: unavailable selected owners: {sorted(missing)}')
        object_path = output / f'{owner}.o'
        command = [
            'swiftc', '-parse-as-library', '-Osize', '-whole-module-optimization',
            '-package-name', 'GiftUI', '-DGIFTUI_NRF_EMBEDDED',
            '-DGIFTUI_REFERENCE_BITMAP_ONLY', '-module-name', owner,
            '-I', str(modules), '-emit-module', '-emit-object',
            '-emit-module-path', str(modules / f'{owner}.swiftmodule'),
            '-o', str(object_path), *map(str, sources[owner])
        ]
        with (output / f'{owner}.log').open('w') as log:
            result = subprocess.run(command, env=environment, stdout=log, stderr=log)
        if result.returncode:
            raise SystemExit(f'{owner} failed; see {output / (owner + ".log")}')
        objects.append(object_path)
        pending.remove(owner)
        print(f'native-owner={owner}; sources={len(sources[owner])}; status=pass')
(output / 'owner-objects.txt').write_text(''.join(f'{path}\n' for path in objects))
