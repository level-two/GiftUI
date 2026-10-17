#!/usr/bin/env python3
"""Offline candidate-1 counterexample verification; no Swift/profile execution."""
import argparse
import collections
import gzip
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--replay-silent', type=Path, help='NEW .build/contracts directory for offline binary replay')
    args = parser.parse_args()
    manifest = json.loads((HERE / 'manifest.json').read_text())
    archive = (HERE / 'observations.tar.gz').read_bytes()
    assert sha(archive) == manifest['archive_sha256'] and len(archive) == manifest['archive_size']
    with tarfile.open(fileobj=io.BytesIO(gzip.decompress(archive)), mode='r:') as tar:
        assert {m.name for m in tar.getmembers()} == set(manifest['members'])
        data = {}
        for member in tar.getmembers():
            assert member.isfile() and '..' not in Path(member.name).parts
            payload = tar.extractfile(member).read()
            identity = manifest['members'][member.name]
            assert len(payload) == identity['size'] and sha(payload) == identity['sha256']
            data[member.name] = payload
    assert sha(data['prepared-manifest.json']) == manifest['prepared_manifest_sha256']
    assert sha(data['run/result.json']) == manifest['raw_run_result_sha256']
    raw_run = json.loads(data['run/result.json'])
    assert raw_run['completed'] and raw_run['candidate_executed']
    assert len(raw_run['runs']) == 4
    for row in raw_run['runs']:
        expected = '1735019' if row['label'] == 'candidate-ordinary' else '1733216'
        assert row['exit'] == 0 and row['entry'] == {'cold': expected, 'reuse': expected}
    result = {'verdict': 'strict Static zero-heap FAIL; candidate unaccepted/not adopted',
              'candidate_commit': manifest['candidate_commit'], 'corrective_cycles_used': 0,
              'complete_allocation_bound': False, 'runs': {}, 'original_action_sites': {}}
    groups_by_label = {}
    symbols_by_label = {}
    for label in ('baseline-host-first', 'candidate-silent-host-first', 'candidate-host-first', 'candidate-ordinary'):
        summary = json.loads(data[f'run/{label}-1-groups.json.summary.json'])
        groups = json.loads(gzip.decompress(data[f'run/{label}-1-groups.json.gz']))['groups']
        pcs = json.loads(gzip.decompress(data[f'symbols/{label}-pcs.json.gz']))
        windows = [line for line in data[f'run/{label}-1.stderr'].decode().splitlines() if line.startswith('WINDOW ')]
        assert len(windows) == 2
        for line in windows:
            fields = dict(item.split('=') for item in line.split()[2:])
            for flag in ('foreign', 'saturated', 'truncated', 'bad_chain', 'io_errors', 'failures', 'unknown_frees'):
                assert fields[flag] == '0', (label, flag)
        groups_by_label[label] = groups
        symbols_by_label[label] = pcs
        stats = collections.defaultdict(lambda: collections.Counter())
        for index, group in enumerate(groups):
            if group['cohort'] != 1:
                continue
            frames = [pcs[pc] for pc in group['pcs']]
            names = [frame['name'] for frame in frames]
            if any('Swift.print' in name or 'counterTrace' in name for name in names):
                continue
            if not any(('Metadata' in name or 'WitnessTable' in name) and name.startswith(('_Z', 'swift_')) for name in names):
                continue
            for frame in frames:
                if not frame['image'].endswith('/' + label):
                    continue
                name = frame['name']
                family = ('gesture-down' if 'ExecutionGestureAdapter.down' in name else
                          'runtime-bridge-dispatch' if 'RuntimeRecordInteractionBridge.dispatch' in name else
                          'pipeline-dispatch' if 'CounterPipelineOwner' in name and '.dispatch' in name else
                          'pipeline-admit' if 'CounterPipelineOwner' in name and '.admitAndSeal' in name else None)
                if family:
                    row = stats[family]
                    for target, field in [('count', 'count'), ('requested', 'requested'), ('usable', 'reserved'), ('retained_after_reuse', 'live_reserved')]:
                        row[target] += group[field]
                    row.setdefault('groups', []).append(index)
                    break
        result['original_action_sites'][label] = {key: dict(value) for key, value in stats.items()}
        result['runs'][label] = {'windows': summary['windows'], 'max_frames': summary['max_frames'],
                                 'group_count': summary['group_count']}
    ordinary = result['original_action_sites']['candidate-ordinary']
    for family, expected in [('pipeline-admit', (2, 32)), ('gesture-down', (5, 208)),
                             ('pipeline-dispatch', (2, 32)), ('runtime-bridge-dispatch', (2, 64))]:
        assert (ordinary[family]['count'], ordinary[family]['requested']) == expected
    assert sum(row['retained_after_reuse'] for row in ordinary.values()) == 64
    silent = groups_by_label['candidate-silent-host-first']
    pcs = symbols_by_label['candidate-silent-host-first']
    tls = silent[0]
    names = [pcs[pc]['name'] for pc in tls['pcs']]
    assert tls['cohort'] == tls['count'] == 1 and tls['requested'] == tls['reserved'] == tls['live_reserved'] == 16
    assert any(name == 'swift_beginAccess' for name in names)
    assert any('SwiftTLSContext' in name for name in names)
    assert any('physicalFacts()' in name for name in names)
    assert not any('counterTrace' in name or 'Swift.print' in name for name in names)
    for index, size in [(1, 16), (2, 48)]:
        group = silent[index]
        assert group['cohort'] == group['count'] == 1 and group['requested'] == group['reserved'] == size
        assert any('TextResourceValidator.validate' in pcs[pc]['name'] for pc in group['pcs'])
        assert not any('counterTrace' in pcs[pc]['name'] or 'Swift.print' in pcs[pc]['name'] for pc in group['pcs'])
    result['independent_cold_counterexamples'] = {'tls': {'group': 0, 'count': 1, 'requested_usable': 16},
                                                 'text_validation_metadata': {'groups': [1, 2], 'count': 2, 'requested_usable': 64}}
    result['fixture_reuse_literal'] = {'group': 1015, 'count': silent[1015]['count'],
                                       'requested': silent[1015]['requested'], 'usable': silent[1015]['reserved']}
    assert result['fixture_reuse_literal'] == {'group': 1015, 'count': 2, 'requested': 136, 'usable': 160}
    recorded = json.loads((HERE / 'result.json').read_text())
    assert result == recorded, 'derived result mismatch'
    if args.replay_silent:
        destination = args.replay_silent.resolve()
        assert ROOT / '.build/contracts' in destination.parents
        destination.mkdir(parents=True, exist_ok=False)
        for suffix in ('.stderr', '.events'):
            name = 'candidate-silent-host-first-1' + suffix
            (destination / name).write_bytes(data['run/' + name])
        prepared = json.loads(data['prepared-manifest.json'])
        replay = HERE.parent / 'native-allocation-diagnostic/replay.py'
        assert sha(replay.read_bytes()) == prepared['source_hashes'][str(replay.relative_to(ROOT))]
        subprocess.run([sys.executable, '-B', str(replay), str(destination / 'candidate-silent-host-first-1.events'),
                        str(destination / 'candidate-silent-host-first-1.stderr'), str(destination / 'groups.json.gz')], check=True)
    print('PASS: immutable observations/counterexamples verified; strict screen FAIL, original11/336 unchanged; corrections0/2')


if __name__ == '__main__':
    main()
