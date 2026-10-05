#!/usr/bin/env python3
"""Snapshot current preparation inputs and observed evidence, not conformance."""
import hashlib
import gzip
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent / 'evidence'
OUT.mkdir(parents=True, exist_ok=True)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


manifest = json.loads((ROOT / '.build/iteration-003/spike-014/manifest.log').read_text().split('swiftpm-command:')[0])
graph = {}
for target in manifest['targets']:
    edges = []
    for dep in target['dependencies']:
        for kind, args in dep.items():
            edges.append(args[0] if kind != 'product' else 'external:' + args[1] + '/' + args[0])
    graph[target['name']] = sorted(edges)


def closure(name):
    found = set()
    pending = [name]
    while pending:
        item = pending.pop()
        if item in found:
            continue
        found.add(item)
        pending.extend(graph.get(item, []))
    return sorted(found)


tracked = subprocess.check_output(['git', 'ls-files'], cwd=ROOT, text=True).splitlines()
inputs = [name for name in tracked if name == 'Package.swift' or name.startswith(('Sources/', 'firmware/nrf52840/', 'scripts/nrf52840/', 'scripts/raspberry-pi/', 'scripts/contracts/'))]
hashes = {name: sha(ROOT / name) for name in inputs if (ROOT / name).is_file()}
(OUT / 'maintained-input-hashes.tsv').write_text('path\tsha256\n' + ''.join(f'{name}\t{value}\n' for name, value in sorted(hashes.items())))
reports = []
for p in sorted((ROOT / '.build/test-reports/all-hardware-free').glob('run-*/metadata.txt'), key=lambda p: p.stat().st_mtime, reverse=True)[:3]:
    values = dict(line.split('=', 1) for line in p.read_text().splitlines() if '=' in line)
    ledger = p.parent / 'results.tsv'
    rows = ledger.read_text().splitlines() if ledger.exists() else []
    reports.append({'path': str(p.relative_to(ROOT)), 'sha256': sha(p), 'metadata': values,
        'terminal_status_present': 'status' in values, 'recorded_checks': len(rows),
        'nonzero_checks': [row.split('\t')[:2] for row in rows if row.split('\t')[1] != '0'],
        'ledger_sha256': sha(ledger) if ledger.exists() else None,
        'last_recorded_check': rows[-1].split('\t')[0] if rows else None})
    name = values['invocation_id']
    (OUT / (name + '-metadata.txt')).write_text(p.read_text())
    (OUT / (name + '-results.tsv')).write_text(ledger.read_text() if ledger.exists() else '')
resources = json.loads((ROOT / 'docs/iterations/iteration-002-cleanup/evidence/16-nrf-connected/paired-resources.json').read_text())
elf = ROOT / '.build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf'
snapshot = {
    'repository_revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
    'maintained_input_count': len(hashes),
    'maintained_input_inventory_sha256': sha(OUT / 'maintained-input-hashes.tsv'),
    'production_diff': subprocess.check_output(['git', 'diff', '--name-only', '--', 'Package.swift', 'Sources', 'firmware', 'scripts'], cwd=ROOT, text=True).splitlines(),
    'manifest_products': {p['name']: p['targets'] for p in manifest['products']},
    'manifest_target_count': len(graph),
    'target_dependency_graph': graph,
    'selected_closures': {name: closure(name) for name in ['GiftUI', 'GiftUIRuntimeStatic', 'GiftUIBackendIntegration', 'GiftUIHostConfiguration']},
    'aggregate_observations': reports,
    'prior_nrf_resource_evidence': {'path': 'docs/iterations/iteration-002-cleanup/evidence/16-nrf-connected/paired-resources.json',
        'evidence_revision': resources['revision'], 'candidate': resources['images']['candidate'],
        'observed_elf_sha256': sha(elf), 'matches_recorded_candidate': sha(elf) == resources['images']['candidate']['sha256']},
}
(OUT / 'baseline.json').write_text(json.dumps(snapshot, indent=2) + '\n')
probe = json.loads((ROOT / '.build/iteration-003/spike-014/results.json').read_text())
for row in probe['probes']:
    p = ROOT / row['log']
    retained = OUT / (row['profile'] + '-' + p.name + '.gz')
    retained.write_bytes(gzip.compress(p.read_bytes(), mtime=0))
    row['retained_log'] = str(retained.relative_to(ROOT))
    row['retained_log_sha256'] = sha(retained)
(OUT / 'spike-014-results.json').write_text(json.dumps(probe, indent=2) + '\n')
print('snapshot:', len(hashes), 'maintained inputs;', len(graph), 'targets;', len(snapshot['manifest_products']), 'products')
for row in reports:
    print(row['metadata']['invocation_id'], row['metadata'].get('status', 'no-terminal-status'), row['recorded_checks'], row['last_recorded_check'])
print('nRF ELF matches retained candidate:', snapshot['prior_nrf_resource_evidence']['matches_recorded_candidate'])
