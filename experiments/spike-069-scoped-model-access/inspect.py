#!/usr/bin/env python3
"""Read-only artifact inspection and evidence packaging; no compiler/run trials."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
EVIDENCE = HERE / 'evidence'
BIN = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin'
ledger = json.loads((EVIDENCE / 'ledger.json').read_text())


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inspect(label, args):
    result = subprocess.run([str(arg) for arg in args], cwd=ROOT, text=True, capture_output=True, check=True)
    path = EVIDENCE / (label + '.log')
    path.write_text(result.stdout + result.stderr)
    return {'command': [str(arg) for arg in args], 'exit_code': result.returncode,
            'log': str(path.relative_to(ROOT)), 'sha256': sha(path)}, result.stdout


summary = {'experimental_invocations': len(ledger['trials']), 'invocation_limit': 48,
           'repair_rounds': 1, 'repair_limit': 3, 'negative_diagnostics': [],
           'inspections': {}, 'artifacts': {}}
for trial in ledger['trials']:
    log = (ROOT / trial['log']).read_text()
    assert sha(ROOT / trial['log']) == trial['log_sha256']
    if trial['expected'] == 'rejection':
        errors = [line.split('error:', 1)[1].strip() for line in log.splitlines() if 'error:' in line]
        assert trial['exit_code'] != 0 and errors
        assert any(word in '\n'.join(errors) for word in trial['diagnostic'])
        summary['negative_diagnostics'].append({'trial': trial['number'], 'label': trial['label'], 'errors': errors})
    elif trial['number'] != 5:
        assert trial['exit_code'] == 0
    if trial['exit_code'] == 0 and '-o' in trial['command']:
        path = Path(trial['command'][trial['command'].index('-o') + 1])
        assert path.exists()
        summary['artifacts'][str(path.relative_to(ROOT))] = {'sha256': sha(path), 'file_bytes': path.stat().st_size}
summary['initial_failure'] = {'trial': 5, 'reason': 'LifetimeDependence flag required; fixed in repair 1'}
for number, profile in [(31, 'macos-dynamic'), (33, 'macos-static')]:
    log = (ROOT / ledger['trials'][number - 1]['log']).read_text()
    assert len(re.findall(r' PASS$', log, re.M)) == 16 and 'FAIL' not in log
    summary[profile] = {'modeled_cases_passed': 16, 'executed_on_target_hardware': False,
                        'layout': dict(re.findall(r'^([a-z-]+-stride) ([0-9]+)$', log, re.M))}

base = ROOT / '.build/nrf52840/spike-069'
for name in ['lifetime-driver.o', 'sectioned-lifetime-driver.o', 'reachable.o']:
    for operation, executable, flags in [('symbols', 'nm', ['-a']),
                                        ('attributes', 'readelf', ['-A']),
                                        ('relocations', 'readelf', ['-rW']),
                                        ('sections', 'readelf', ['-SW']),
                                        ('disassembly', 'objdump', ['-dr'])]:
        label = name.replace('.o', '') + '-' + operation
        record, output = inspect(label, [BIN / ('arm-zephyr-eabi-' + executable), *flags, base / name])
        summary['inspections'][label] = record
        if name == 'reachable.o' and operation == 'relocations':
            allocator_lines = [line for line in output.splitlines() if re.search(r'\b(posix_memalign|malloc|calloc|realloc|free|swift_\w*Alloc\w*|swift_alloc\w*)\b', line)]
            summary['reachable_allocator_relocations'] = allocator_lines
            assert not allocator_lines
        if name == 'reachable.o' and operation == 'attributes':
            assert 'Tag_ABI_VFP_args: VFP registers' in output
        if name == 'reachable.o' and operation == 'disassembly':
            summary['indirect_call_lines'] = [line for line in output.splitlines() if re.search(r'\bblx\s+r[0-9]+\b', line)]

record, _ = inspect('pi-lifetime-driver-attributes', [BIN / 'arm-zephyr-eabi-readelf', '-A', ROOT / '.build/raspberry-pi/spike-069/lifetime-driver.o'])
summary['inspections']['pi-attributes'] = record
summary['heap_claim'] = ('No allocator relocation remains in the section-GC fixture rooted at both exported entries. '
                         'Undefined allocator symbol-table entries survive the relocatable link without references. '
                         'This does not establish complete firmware linkage, external helper behavior, whole-image zero heap or stack safety.')
summary['disposition'] = ('A callback-only enforcement refuted. B borrow/key mechanism supported by bounded fixtures; '
                          'actual Canvas capture rejected. Full source-compatible lowering, ownership and B1 closure remain unproved.')

# Compress exact per-trial source snapshots, preserving their original names.
# Remove only files created by this experiment, after byte-for-byte verification
# inside the archive; logs, hashes and trial identities remain individually readable.
snapshots = sorted(EVIDENCE.glob('[0-9][0-9]-*/*.txt'))
archive = EVIDENCE / 'input-snapshots.tar.gz'
if snapshots:
    assert not archive.exists(), 'Do not overwrite prior source evidence'
    with tarfile.open(archive, 'w:gz') as output:
        for path in snapshots:
            output.add(path, arcname=str(path.relative_to(EVIDENCE)))
    with tarfile.open(archive, 'r:gz') as saved:
        for path in snapshots:
            assert saved.extractfile(str(path.relative_to(EVIDENCE))).read() == path.read_bytes()
    for path in snapshots:
        path.unlink()
summary['input_snapshot_archive_sha256'] = sha(archive)
with tarfile.open(archive, 'r:gz') as saved:
    for trial in ledger['trials']:
        folder = f'{trial["number"]:02d}-{trial["label"]}'
        for index, (name, expected_hash) in enumerate(trial['inputs'].items()):
            if Path(name).suffix != '.swift':
                continue
            member = f'{folder}/{index:02d}-{Path(name).name}.txt'
            actual_hash = hashlib.sha256(saved.extractfile(member).read()).hexdigest()
            assert actual_hash == expected_hash, member
summary['all_trial_source_snapshots_verified'] = True
(EVIDENCE / 'inspection.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps({key: summary[key] for key in ['experimental_invocations', 'repair_rounds', 'reachable_allocator_relocations', 'indirect_call_lines', 'disposition']}, indent=2))
