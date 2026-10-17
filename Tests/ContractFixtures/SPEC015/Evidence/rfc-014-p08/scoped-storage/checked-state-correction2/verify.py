#!/usr/bin/env python3
"""Offline frozen bytes/command accounting; executes no compiler or test."""
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
    ('macro-compile', 0), ('macro-link', 0), ('regression-compile', 1)]
assert result['compiled_macro_source_frozen'] and result['external_preserved'] and result['authored_preserved']
assert result['disposition'].startswith('WIP:')
print(f'PASS: {len(manifest)} immutable members; regression and provider gates remain unexecuted')
