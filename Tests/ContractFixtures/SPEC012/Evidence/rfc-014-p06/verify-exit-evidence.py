#!/usr/bin/env python3
"""Read-only independent P06 receipt, input, output and oracle reconciliation."""
import hashlib
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[5]
HERE = pathlib.Path(__file__).resolve().parent
index = json.loads((HERE / 'final-index.json').read_text())
result = {'reviewed_implementation': '909a7dab8581368aa776c5d93f7f2b0e33d68ec2',
          'profiles': {}, 'unchanged_controls': {}, 'mismatches': []}
cache = {}

def digest(path):
    if path not in cache:
        cache[path] = hashlib.sha256(path.read_bytes()).hexdigest()
    return cache[path]

def verify(path, expected, label, size=None):
    okay = path.is_file() and digest(path) == expected
    if size is not None:
        okay = okay and path.stat().st_size == size
    if not okay:
        result['mismatches'].append(label)
    return okay

for profile, summary in index.items():
    copied = HERE / (profile + '.json')
    original = ROOT / summary['receipt']
    verify(copied, summary['receipt_sha256'], profile + ': copied receipt')
    verify(original, summary['receipt_sha256'], profile + ': original receipt')
    receipt = json.loads(copied.read_text())
    core_path = ROOT / receipt['core_receipt']
    verify(core_path, receipt['core_receipt_sha256'], profile + ': core receipt')
    core = json.loads(core_path.read_text())
    counts = {'input_hashes': 0, 'artifact_hashes_and_sizes': 0}
    for kind, record, directory in [('p06', receipt, original.parent), ('core', core, core_path.parent)]:
        for name, expected in record['inputs'].items():
            verify(ROOT / name, expected, profile + ':' + kind + ':' + name)
            counts['input_hashes'] += 1
        for name, expected in record['artifacts'].items():
            verify(directory / name, expected['sha256'], profile + ':' + kind + ':' + name, expected['bytes'])
            counts['artifact_hashes_and_sizes'] += 1
        verify(ROOT / record['compiler'], record['compiler_sha256'], profile + ':' + kind + ':compiler')
    negative_names = []
    for check in receipt['checks']:
        assert check['pass'], (profile, check)
        if check['expected_failure']:
            assert check['exit'] != 0
            assert check['expected_failure'] in (original.parent / (check['name'] + '.log')).read_text()
            negative_names.append(check['name'])
    layouts = receipt['layouts']
    assert layouts['counter_two_bank_payload_reserved_bytes'] == 196 * layouts['semantic_slot_stride']
    assert layouts['analyzer_two_bank_payload_reserved_bytes'] == 196 * layouts['analyzer_semantic_slot_stride']
    assert layouts['counter_two_bank_payload_delta'] == 196 * (layouts['semantic_slot_stride'] - layouts['standard_slot_stride'])
    assert layouts['analyzer_two_bank_payload_delta'] == 196 * (layouts['analyzer_semantic_slot_stride'] - layouts['standard_slot_stride'])
    assert layouts['counter_two_bank_total_reserved_bytes'] == 2 * layouts['semantic_metadata_stride'] + 252 * layouts['semantic_record_stride'] + 756 * layouts['semantic_prefix_stride'] + 196 * layouts['semantic_slot_stride'] + 448 * 4
    evidence = (original.parent / ('native-execute.log' if profile.startswith('macos') else 'target-abi.log')).read_text()
    if profile.startswith('macos'):
        assert 'assertions=266 errorMappings=13 finiteTables=24 geometry=17 raster=3624 failures=0' in evidence
    else:
        assert 'Tag_ABI_VFP_args: VFP registers' in evidence
        assert ('Tag_CPU_arch: v6' if profile == 'raspberry-pi-armv6' else 'Tag_CPU_arch: v7E-M') in evidence
    result['profiles'][profile] = {**counts, 'checks': len(receipt['checks']), 'negative_diagnostics_verified': negative_names,
        'source_commit': receipt['source_commit'], 'source_dirty': receipt['source_dirty'],
        'current_recorded_inputs_match': True, 'native_or_abi_log_verified': True,
        'semantic_payload_slots_charged': 196,
        'counter_payload_delta_bytes': layouts['counter_two_bank_payload_delta'],
        'analyzer_payload_delta_bytes': layouts['analyzer_two_bank_payload_delta']}

controls = ['Tests/ContractFixtures/SPEC012/raster-vectors.yaml', 'scripts/contracts/check-spec-012-raster-vectors.rb',
    'Sources/GiftUIRasterCore/RasterStrokeCoverage.swift', 'Sources/GiftUIDrawing/PathConstruction.swift',
    'Sources/GiftUIDrawing/StrokeSnapshot.swift', 'Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFDrawingPlanStorage.swift',
    'Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFLivePathStorage.swift']
for name in controls:
    prior = subprocess.check_output(['git', 'show', 'a17724b2:' + name], cwd=ROOT)
    expected = hashlib.sha256(prior).hexdigest()
    verify(ROOT / name, expected, 'unchanged:' + name)
    result['unchanged_controls'][name] = expected
result['verified'] = not result['mismatches']
(HERE / 'exit-review-evidence-verification.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'verified': result['verified'], 'profiles': len(result['profiles']),
    'input_hashes': sum(p['input_hashes'] for p in result['profiles'].values()),
    'artifact_hashes_and_sizes': sum(p['artifact_hashes_and_sizes'] for p in result['profiles'].values()),
    'unchanged_controls': len(controls), 'mismatches': result['mismatches']}))
assert result['verified']
