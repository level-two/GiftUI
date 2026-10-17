#!/usr/bin/env python3
"""Read-only compact evidence verification; no compiler or workload execution."""
import hashlib
import json
from pathlib import Path

base = Path(__file__).resolve().parent
manifest = json.loads((base / 'manifest.json').read_text())
for name, identity in manifest['files'].items():
    payload = (base / name).read_bytes()
    assert len(payload) == identity['size'], name
    assert hashlib.sha256(payload).hexdigest() == identity['sha256'], name
for name, item in manifest['variants'].items():
    assert item['entry'] == 'ENTRY cold=42 reuse=42', name
    for line in (item['cold'], item['reuse']):
        values = dict(field.split('=', 1) for field in line.split()[2:])
        for flag in ('foreign', 'saturated', 'truncated', 'bad_chain', 'io_errors', 'failures', 'unknown_frees'):
            assert values[flag] == '0', (name, flag)
assert 'allocations=0 ' in manifest['variants']['concrete-pair']['cold']
assert 'allocations=25 ' in manifest['variants']['generic-pair']['cold']
for name in ('concrete-inline', 'scoped-inline'):
    assert 'allocations=0 ' in manifest['variants'][name]['cold']
print('PASS: nine synthetic variants, captured identities, results and observer flags; no P08 conformance claim')
