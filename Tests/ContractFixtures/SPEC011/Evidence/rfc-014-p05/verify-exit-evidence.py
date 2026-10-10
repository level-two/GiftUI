#!/usr/bin/env python3
"""Read-only independent P05 receipt verification; run from repository root."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
TESTED = 'fec8a27cf6cf0ae679a1e34ebb90738e8d592f85'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def check_file(path, expected):
    assert sha(path) == expected, str(path)

results = []
for item in json.loads((HERE / 'final-profile-receipts.json').read_text()):
    snapshot = ROOT / item['snapshot']
    original = ROOT / item['source_receipt']
    check_file(snapshot, item['receipt_sha256'])
    check_file(original, item['receipt_sha256'])
    receipt = json.loads(snapshot.read_text())
    assert receipt['source_commit'] == TESTED and not receipt['source_dirty']
    assert receipt['profile'] == item['profile']
    for name, expected in receipt['inputs'].items():
        check_file(ROOT / name, expected)
        committed = subprocess.check_output(['git', 'show', TESTED + ':' + name], cwd=ROOT)
        assert hashlib.sha256(committed).hexdigest() == expected, name
    check_file(ROOT / receipt['compiler'], receipt['compiler_sha256'])
    core_path = ROOT / receipt['core_receipt']
    check_file(core_path, receipt['core_receipt_sha256'])
    core = json.loads(core_path.read_text())
    assert core['profile'] == receipt['profile']
    assert core['compiler_sha256'] == receipt['compiler_sha256']
    for name, expected in core['inputs'].items():
        if name.startswith(('Sources/GiftUI/', 'Sources/GiftUIMacros/')):
            check_file(ROOT / name, expected)
    for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
        check_file(core_path.parent / name, core['artifacts'][name]['sha256'])
    for name, expected in receipt['artifacts'].items():
        artifact = original.parent / name
        check_file(artifact, expected['sha256'])
        assert artifact.stat().st_size == expected['bytes'], name
    assert (original.parent / 'commands.txt').read_text().splitlines() == receipt['commands']
    for check in receipt['checks']:
        assert check['exit'] != 0 if check.get('expected_failure') else check['exit'] == 0
    for name in ('EscapeLayout', 'EscapeRender') if item['spec'] == 'SPEC-007' else ():
        assert "does not conform to protocol 'Escapable'" in (original.parent / (name + '.log')).read_text()
    if receipt['profile'].startswith('macos'):
        expected = ('P05 Layout assertions=196 failures=0' if item['spec'] == 'SPEC-007'
                    else 'P05 Interaction assertions=215 P03 root regressions=183 failures=0')
        assert (original.parent / 'execute.log').read_text().strip() == expected == receipt['execution']
    else:
        abi = (original.parent / 'target-abi.log').read_text()
        arch = 'v6' if receipt['profile'] == 'raspberry-pi-armv6' else 'v7E-M'
        assert re.search(r'Tag_CPU_arch: ' + arch + r'\s*$', abi, re.M)
        assert 'Tag_ABI_VFP_args: VFP registers' in abi
    if item['spec'] == 'SPEC-011':
        layout = json.loads((original.parent / 'key-layout.json').read_text())
        assert layout == receipt['physical_key_layout']
        assert layout['key_stride'] == 206 and layout['component_stride'] == 6
        assert layout['candidate_inline_key_regions'] == 6 * 3 * 206
        assert layout['committed_inline_key_regions'] == 6 * 2 * 206
        assert layout['static_owned_state_stride'] == 7108
        assert layout['pointer_capture_stride'] == 212
    results.append({'spec': item['spec'], 'profile': item['profile'],
                    'receipt_sha256': item['receipt_sha256'],
                    'inputs_verified': len(receipt['inputs']),
                    'artifacts_verified': len(receipt['artifacts']), 'status': 'PASS'})
print(json.dumps({'tested_source': TESTED, 'verification': 'PASS', 'routes': results}, indent=2))
