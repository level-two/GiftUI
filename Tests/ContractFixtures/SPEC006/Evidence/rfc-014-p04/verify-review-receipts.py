#!/usr/bin/env python3
"""Read-only verifier for the evidence reused by the independent P04 review."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
entries = json.loads((Path(__file__).parent / 'final-profile-receipts.json').read_text())
checked = 0

for entry in entries:
    record = entry['record_receipt']
    receipts = (
        ('record', entry['record_receipt_path'], entry['record_receipt_sha256']),
        ('core', record['core_receipt'], record['core_receipt_sha256']),
    )
    for kind, name, expected in receipts:
        path = ROOT / name
        receipt = entry[kind + '_receipt']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, str(path)
        assert json.loads(path.read_text()) == receipt, str(path)
        checked += 1
        for name, expected in receipt['inputs'].items():
            assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected, name
            checked += 1
        for name, expected in receipt['artifacts'].items():
            artifact = path.parent / name
            assert hashlib.sha256(artifact.read_bytes()).hexdigest() == expected['sha256'], str(artifact)
            assert artifact.stat().st_size == expected['bytes'], str(artifact)
            checked += 1
        compiler = ROOT / receipt['compiler']
        assert hashlib.sha256(compiler.read_bytes()).hexdigest() == receipt['compiler_sha256'], str(compiler)
        checked += 1
    print(record['profile'] + ': verified')

print(f'Verified hash/size entries: {checked}')
