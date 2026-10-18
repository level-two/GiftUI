#!/usr/bin/env python3
"""Candidate 2: one sequential maintained macro/P02+P04/P07/schema4/counter attempt."""
from pathlib import Path
import hashlib
import json
import os
import re
import subprocess
import sys
import time

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent
PLAN = json.loads((PACKET / 'prepared.json').read_text())
OUT = Path(PLAN['output'])


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def verify_inputs():
    for receipt in ('input-freeze.json', 'recipe-freeze.json'):
        for name, expected in json.loads((PACKET / receipt).read_text()).items():
            path = Path(name) if Path(name).is_absolute() else ROOT / name
            assert digest(path) == expected, ('changed frozen input', name)


def verify():
    verify_inputs()
    assert not OUT.exists(), 'No retry or output reuse'
    assert PLAN['source_commits'] == ['778233fc', '34601caa']
    methods = re.findall(r'^    func (test\w+)\(', (ROOT / 'Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift').read_text(), re.M)
    assert methods == json.loads((PACKET / 'registered-methods.json').read_text())
    assert len(methods) == PLAN['method_count'] == 19
    main = (PACKET / 'TestMain-macos.swift').read_text()
    assert re.findall(r'#selector\(ObservableStateHostMacroTests\.(test\w+)\)', main) == methods
    assert [x['name'] for x in PLAN['stages']] == [
        'macro-compile', 'macro-link', 'macro-tests-link', 'macro-tests',
        'fresh-core-and-registered-records', 'fresh-runtime-cycle',
        'fresh-schema4-activation-host', 'complete-counter-safety']
    assert PLAN['stages'][-1]['command'][-1] == '--collect-failures'
    assert '--activation-join' in PLAN['stages'][-2]['command']
    assert not any('cold' in token for stage in PLAN['stages'] for token in stage['command'])
    for source in (PACKET / 'macro-sources').read_text().splitlines():
        assert source.startswith(str(ROOT / 'Sources/GiftUIMacros') + '/')
        assert str(Path(source).relative_to(ROOT)) in json.loads((PACKET / 'input-freeze.json').read_text())


verify()
if sys.argv[1:] == ['--validate']:
    print('PASS static frozen inputs/recipe, 19 registered macro methods, prior working macOS environment, sequential P02+P04/P07/schema4-activation/counter384; no compiler/tests/producers executed')
    raise SystemExit(0)
assert not sys.argv[1:]
# Serialize all eight stages, including the fresh macro build, under the repository lock.
if not os.environ.get('GIFTUI_VALIDATION_LOCK_OWNER'):
    os.execvp('ruby', ['ruby', str(ROOT / 'scripts/lib/serialize-validation.rb'), sys.executable, str(PACKET / 'run.py')])
OUT.mkdir()
(OUT / 'macro/macro').mkdir(parents=True)
(OUT / 'logs').mkdir()
result = {'status': 'running', 'source_commits': PLAN['source_commits'],
          'source_candidate': '1/1 consumed; automatic source repairs 0/0',
          'strict_cold_eligible': False, 'stages': [], 'remaining': PLAN['remaining']}
receipts = {}


def save():
    (OUT / 'result.json').write_text(json.dumps(result, indent=2) + '\n')


def qualify(path, started):
    path = Path(path).resolve()
    assert path.is_relative_to(ROOT / '.build') and path.is_file()
    assert path.stat().st_mtime_ns >= started, 'Stale receipt rejected'
    data = json.loads(path.read_text())
    assert data['profile'] == 'macos-static'
    for name, expected in data['inputs'].items():
        assert digest(ROOT / name) == expected, ('producer input changed', name)
        # Generated macro executable is a genuine fresh P02/P07 input; source inputs
        # must be represented by the candidate-specific pre-execution freeze.
        if not name.startswith('.build/'):
            assert json.loads((PACKET / 'input-freeze.json').read_text()).get(name) == expected, ('unfrozen producer source', name)
    for name, value in data.get('artifacts', {}).items():
        artifact = (path.parent / name).resolve()
        assert artifact.is_relative_to(path.parent)
        assert digest(artifact) == value['sha256'], ('producer artifact changed', name)
    if 'compiler' in data:
        assert digest(ROOT / data['compiler']) == data['compiler_sha256']
    for check in data.get('checks', []):
        if 'pass' in check:
            assert check['pass'] is True, check
        elif 'passed' in check:
            assert check['passed'] is True, check
        elif check.get('expected_failure') is True:
            assert check['exit'] != 0, check
        else:
            assert check['exit'] == 0, check
    return {'path': str(path), 'sha256': digest(path), 'data': data}


def reference(receipt):
    return {'path': receipt['path'], 'sha256': receipt['sha256']}


try:
    for stage in PLAN['stages']:
        verify_inputs()
        argv = [str(Path(receipts[token[1:-1]]['path']).parent)
                if token.startswith('{') and token.endswith('}') else token for token in stage['command']]
        env = dict(os.environ)
        # Keep direct and registered Python producers from touching the preexisting pycache.
        env['PYTHONDONTWRITEBYTECODE'] = '1'
        if stage.get('runner_environment'):
            env.update(PLAN['environment'])
        prefix = OUT / 'logs' / stage['name']
        started = time.time_ns()
        timer = time.monotonic()
        with Path(str(prefix) + '.stdout').open('xb') as stdout, Path(str(prefix) + '.stderr').open('xb') as stderr:
            process = subprocess.run(argv, cwd=ROOT, stdout=stdout, stderr=stderr, env=env)
        text = Path(str(prefix) + '.stdout').read_text(errors='replace')
        row = {'name': stage['name'], 'command': argv, 'exit': process.returncode,
               'seconds': round(time.monotonic() - timer, 3),
               'stdout_sha256': digest(str(prefix) + '.stdout'), 'stderr_sha256': digest(str(prefix) + '.stderr')}
        result['stages'].append(row)
        save()
        print(stage['name'], process.returncode, flush=True)
        if process.returncode:
            result['status'] = 'failed_stage_dependents_unrun_no_retry_or_repair'
            save()
            raise SystemExit(process.returncode)
        if stage['name'] == 'macro-tests':
            assert re.findall(r'^executions=19 failures=0 skips=0$', text, re.M) == ['executions=19 failures=0 skips=0']
            row['registered_methods'] = 19
        if 'key' not in stage:
            save()
            continue
        hits = re.findall(stage['receipt_regex'], text, re.M)
        assert len(hits) == 1, ('receipt discovery not unique', stage['name'], hits)
        path = Path(hits[0].strip())
        if stage.get('directory_output'):
            path /= 'result.json'
        receipt = qualify(path, started)
        data = receipt['data']
        receipts[stage['key']] = receipt
        row['receipt'] = reference(receipt)
        if stage['key'] == 'core':
            assert data['package'] == 'P02'
            checks = {x['check']: x for x in data['checks']}
            assert {'CounterPresentation', 'AnalyzerPresentation', 'DeclarationHost', 'native-execution'} <= checks.keys()
            assert {'CounterPresentation.swift', 'CounterPresentation.o', 'AnalyzerPresentation.swift', 'AnalyzerPresentation.o', 'DeclarationHost.o'} <= data['artifacts'].keys()
            hits = re.findall(r'^P04 macos-static:[\s\S]*?;\s*(\S+/result\.json)\s*$', text, re.M)
            assert len(hits) == 1
            p04 = qualify(hits[0], started)
            assert p04['data']['package'] == 'P04'
            assert p04['data']['core_receipt_sha256'] == receipt['sha256']
            row['registered_P04'] = reference(p04)
        elif stage['key'] == 'runtime':
            assert data['package'] == 'P07'
            assert data['core_receipt_sha256'] == receipts['core']['sha256']
        elif stage['key'] == 'host':
            assert data['runtime_receipt_sha256'] == receipts['runtime']['sha256']
            assert {'activation-join', 'activation-copy', 'activation-callback', 'activation-constant-callback', 'activation-backing', 'execute'} <= {x['name'] for x in data['checks']}
        elif stage['key'] == 'counter':
            assert data['runtime_receipt_sha256'] == receipts['runtime']['sha256']
            assert data['host_receipt_sha256'] == receipts['host']['sha256']
            assert data['collection_complete'] and data['passed'] and not data['fresh_focused']
            assert len(data['planned_scoped_labels']) == len(set(data['planned_scoped_labels'])) == 384
        save()
    verify_inputs()
    result['status'] = 'prerequisite_validation_passed_current_callee_cold_resources_acceptance_open'
    save()
except Exception as error:
    result['status'] = 'setup_or_receipt_qualification_failure_dependents_unrun_no_retry_or_repair'
    result['error'] = repr(error)
    save()
    raise
