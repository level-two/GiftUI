#!/usr/bin/env python3
"""Execute prepared diagnostic windows sequentially; never infer zero-heap conformance."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[7]
HERE = Path(__file__).resolve().parent
REPLAY = HERE.parent / 'native-allocation-diagnostic/replay.py'


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepared', required=True, type=Path)
    parser.add_argument('--repetitions', type=int, default=1, choices=(1, 2, 3))
    args = parser.parse_args()
    assert Path.cwd().resolve() == ROOT
    prepared = args.prepared.resolve()
    assert ROOT / '.build/contracts' in prepared.parents
    manifest = json.loads((prepared / 'manifest.json').read_text())
    assert not {k: v for k, v in os.environ.items() if k.startswith(('DYLD_', 'Malloc', 'SWIFT_')) and (k, v) != ('MallocNanoZone', '0')}, 'unexpected allocator/runtime overrides'

    def verify():
        for name, expected in manifest['source_hashes'].items():
            assert digest(ROOT / name) == expected, name
        for name, expected in manifest['original_objects'].items():
            assert digest(name) == expected, name
        for name, identity in manifest['retained_dependencies'].items():
            assert digest(ROOT / name) == identity['sha256'], name
        for name, expected in manifest['prepared_artifacts'].items():
            assert digest(prepared / name) == expected, name
        assert digest(manifest['compiler']) == manifest['compiler_sha256']

    verify()
    out = prepared / 'run'
    out.mkdir(exist_ok=False)
    results = {'prepared_manifest_sha256': digest(prepared / 'manifest.json'),
               'candidate_executed': False, 'corrective_cycles_used_before_screen': 0,
               'corrective_cycle_limit': 2, 'allocation_verdict': 'unclassified; observer blind spots remain',
               'runs': [], 'completed': False}
    (out / 'result.json').write_text(json.dumps(results, indent=2) + '\n')
    expected_host = None
    try:
        for repeat in range(1, args.repetitions + 1):
            for label in ('baseline-host-first', 'candidate-silent-host-first', 'candidate-host-first', 'candidate-ordinary'):
                name = f'{label}-{repeat}'
                command = [str(prepared / label), str(out / (name + '.events'))]
                if label.startswith('candidate'):
                    results['candidate_executed'] = True
                with (out / (name + '.stdout')).open('wb') as stdout, (out / (name + '.stderr')).open('wb') as stderr:
                    process = subprocess.run(command, stdout=stdout, stderr=stderr)
                item = {'label': label, 'repeat': repeat, 'argv': command, 'exit': process.returncode}
                results['runs'].append(item)
                (out / 'result.json').write_text(json.dumps(results, indent=2) + '\n')
                assert process.returncode == 0, (name, process.returncode)
                text = (out / (name + '.stderr')).read_text()
                summary = [line for line in text.splitlines() if line.startswith(('HOST ', 'ENTRY ', 'WINDOW ', 'CONTROL '))]
                (out / (name + '-summary.txt')).write_text('\n'.join(summary) + '\n')
                entry = next(line for line in summary if line.startswith('ENTRY '))
                counts = dict(field.split('=') for field in entry.split()[1:])
                assert counts['cold'] == counts['reuse'] and int(counts['cold']) > 0, entry
                if label == 'baseline-host-first':
                    if expected_host is None:
                        expected_host = counts['cold']
                    assert counts['cold'] == expected_host
                elif label == 'candidate-ordinary':
                    assert counts['cold'] == '1735019', 'registered Static workload count changed'
                else:
                    assert counts['cold'] == expected_host, 'host-only workload count changed'
                item['entry'] = counts
                replay = [sys.executable, '-B', str(REPLAY), str(out / (name + '.events')),
                          str(out / (name + '.stderr')), str(out / (name + '-groups.json.gz'))]
                with (out / (name + '-replay.log')).open('wb') as log:
                    subprocess.run(replay, check=True, stdout=log, stderr=subprocess.STDOUT)
                print(name + ': ' + entry, flush=True)
        verify()
        results['completed'] = True
    finally:
        results['artifacts'] = {str(path.relative_to(out)): digest(path) for path in out.iterdir() if path.is_file() and path.name != 'result.json'}
        (out / 'result.json').write_text(json.dumps(results, indent=2) + '\n')
    print('Observation/count/replay complete; classify cold profile allocations before any correction or full collection.')


if __name__ == '__main__':
    main()
