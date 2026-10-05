#!/usr/bin/env python3
"""Publish or verify current reference traces; historical evidence is never a fallback."""
import argparse
import hashlib
import json
from pathlib import Path


def inputs(root):
    paths = []
    for directory in ['Sources', 'firmware/nrf52840/applications/signal-analyzer-static', 'Tests/GiftUIHostConfigurationTests']:
        paths += [p for p in (root / directory).rglob('*') if p.suffix in ['.swift', '.c', '.h', '.conf']]
    return {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(paths)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('operation', choices=['publish', 'verify'])
    parser.add_argument('directory', type=Path)
    parser.add_argument('--log', type=Path)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[2])
    args = parser.parse_args()
    expected = inputs(args.root.resolve())
    if args.operation == 'verify':
        metadata = json.loads((args.directory / 'identity.json').read_text())
        if metadata['inputs'] != expected:
            raise ValueError('reference traces do not match current source inputs')
        for name, digest in metadata['traces'].items():
            if hashlib.sha256((args.directory / name).read_bytes()).hexdigest() != digest:
                raise ValueError('reference trace bytes changed: ' + name)
        return
    if args.log is None:
        raise ValueError('publish requires a successful current test log')
    lines = args.log.read_text().splitlines()
    groups = {
        'macos-dynamic-reference-trace.tsv': {'reference=macos-dynamic': 120, 'reference=macos-dynamic-other-frame': 9, 'reference=macos-dynamic-action': 12},
        'macos-static-paced-reference-trace.tsv': {'reference=macos-static': 818, 'reference=macos-static-action': 12},
    }
    outputs = {}
    for name, prefixes in groups.items():
        for prefix, count in prefixes.items():
            actual = sum(line.startswith(prefix + '\t') for line in lines)
            if actual != count:
                raise ValueError(f'{prefix}: expected {count} current records, got {actual}')
        selected = [line for line in lines if any(line.startswith(prefix + '\t') for prefix in prefixes)]
        outputs[name] = ('\n'.join(selected) + '\n').encode()
    metadata = {'source_log': str(args.log.resolve()), 'source_log_sha256': hashlib.sha256(args.log.read_bytes()).hexdigest(),
                'inputs': expected, 'traces': {name: hashlib.sha256(data).hexdigest() for name, data in outputs.items()}}
    args.directory.mkdir(parents=True, exist_ok=True)
    for name, data in outputs.items():
        temp = args.directory / (name + '.tmp')
        temp.write_bytes(data)
        temp.replace(args.directory / name)
    temp = args.directory / 'identity.json.tmp'
    temp.write_text(json.dumps(metadata, indent=2) + '\n')
    temp.replace(args.directory / 'identity.json')


if __name__ == '__main__':
    main()
