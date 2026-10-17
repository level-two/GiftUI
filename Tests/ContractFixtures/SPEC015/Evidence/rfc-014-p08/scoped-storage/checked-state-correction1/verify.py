#!/usr/bin/env python3
"""Offline byte verification only; never invokes a compiler or workload."""
from pathlib import Path
import hashlib
import json
import tarfile

root = Path(__file__).resolve().parent
manifest = json.loads((root / 'manifest.json').read_text())
with tarfile.open(root / 'evidence.tar.gz', 'r:gz') as archive:
    assert set(archive.getnames()) == set(manifest)
    for name, expected in manifest.items():
        assert hashlib.sha256(archive.extractfile(name).read()).hexdigest() == expected, name
result = json.loads((root / 'result.json').read_text())
assert [(r['name'], r['exit']) for r in result['checks']] == [
    ('macro-compile', 0), ('macro-link', 0), ('lower', 0), ('GiftUI', 0), ('P08CounterSchema', 0), ('P08CounterPresentation', 1)]
assert result['source_stayed_frozen'] and result['external_preserved'] and result['authored_preserved']
assert result['initial'] == '1/1 consumed' and result['corrections'] == '1/2 consumed'
print(f'PASS: {len(manifest)} immutable archive members; first presentation failure and attempt accounting preserved')
