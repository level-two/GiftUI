#!/usr/bin/env python3
"""Future guarded static invocation only; no campaign import or compiler API."""
from pathlib import Path
import hashlib
import importlib.util
import json
import sys


def main():
    packet = Path(__file__).resolve().parent
    invocation = json.loads((packet / 'invocation.json').read_text())
    if sys.flags.optimize or not sys.flags.dont_write_bytecode:
        raise RuntimeError('STOP: require -B without optimization')
    if (sys.argv != invocation['argv'][2:]
            or invocation['argv'][:2] != ['python3', '-B']
            or list(sys.version_info[:3]) != invocation['python_version']
            or sys.executable != invocation['python_executable']
            or Path.cwd().resolve() != Path(invocation['cwd'])):
        raise RuntimeError('STOP: exact invocation/interpreter/cwd required')
    output = Path(sys.argv[4])
    if output.exists():
        raise RuntimeError('STOP: output exists; no overwrite/retry')
    freeze_bytes = Path(sys.argv[2]).read_bytes()
    freeze = json.loads(freeze_bytes)
    if freeze['argv'] != invocation['argv'] or freeze['total_static_inputs'] != 113:
        raise RuntimeError('STOP: freeze/invocation mismatch')
    for inventory in ('packet_files', 'preserved_files'):
        for item in freeze[inventory]:
            path = packet / item['path'] if inventory == 'packet_files' else Path(item['path'])
            content = path.read_bytes()
            if len(content) != item['bytes'] or hashlib.sha256(content).hexdigest() != item['sha256']:
                raise RuntimeError(('STOP: frozen identity changed', str(path)))
    inherited = json.loads((packet / 'inherited-cases.json').read_text())['cases']
    new = json.loads((packet / 'new-cases.json').read_text())['cases']
    assert len(inherited) == 59 and len(new) == 54
    cases = inherited + new
    assert len({case['id'] for case in cases}) == 113
    spec = importlib.util.spec_from_file_location('a7_static_diagnostic_parser', packet / 'diagnostic_parser.py')
    parser = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(parser)
    assert parser.A7_POLICY == json.loads((packet / 'policy.json').read_text())
    assert new[0]['stderr'].encode() == (packet / 'inputs/archived-A7.stderr').read_bytes()
    assert new[0]['stdout'].encode() == (packet / 'inputs/archived-A7.stdout').read_bytes()
    results = []
    for case in cases:
        arguments = {}
        if 'context' in case:
            arguments['context'] = case['context']
        if 'trusted_input' in case:
            trusted = case['trusted_input']
            assert trusted['fixture_file'] in ('inputs/SignalPrimitiveValues.swift', 'inputs/AnalyzerPresentation.swift')
            data = (packet / trusted['fixture_file']).read_bytes()
            data += trusted.get('append_bytes', '').encode()
            if trusted.get('as_text'):
                data = data.decode()
            arguments['trusted_input'] = {'path': trusted['path'], 'bytes': data}
        try:
            records = parser.classify_negative_diagnostics(
                case['control'], case['exit'], case['stdout'], case['stderr'],
                case['primary_path'], case['dependency_paths'], **arguments)
        except AssertionError as error:
            assert case['expected_accept'] is False, ('unexpected rejection', case['id'], str(error))
            results.append({'id': case['id'], 'accepted': False, 'rejection': str(error)})
            continue
        assert case['expected_accept'] is True, ('unexpected acceptance', case['id'])
        display_count = sum(len(record['display_notes']) for record in records)
        assert display_count == case.get('expected_display_note_count', 0)
        if case['id'].startswith('A7-'):
            policy = parser.A7_POLICY
            assert len(records) == case['expected_primary_count'] == 4
            for record, target in zip(records, policy['primaries']):
                assert record['notes'] == []
                assert record['primary']['source'] == [target['source']]
                assert record['dependency_evidence'] == policy['primary_message'] + '\n' + target['source']
                assert policy['excerpt_text'] not in record['dependency_evidence']
                assert policy['gutter'] not in record['dependency_evidence']
                assert record['display_notes'] == [{
                    'stream': 'stderr',
                    'enclosing_primary': {key: record['primary'][key] for key in ('file', 'line', 'column', 'severity', 'message')},
                    'excerpt': {'line': 11, 'text': policy['excerpt_text'], 'raw': '11 | ' + policy['excerpt_text']},
                    'raw_gutter': policy['gutter'],
                    'declared_source_path': case['primary_path'],
                    'input_sha256': policy['input_sha256'],
                    'has_located_note_header': False,
                    'contributes_dependency_evidence': False,
                }]
        elif 'expected_dependency_evidence' in case:
            assert len(records) == case['expected_primary_count'] == 1
            assert records[0]['notes'] == []
            assert records[0]['primary']['source'] == [parser.A4_POLICY['primary_source']]
            assert records[0]['dependency_evidence'] == case['expected_dependency_evidence']
        results.append({'id': case['id'], 'accepted': True, 'display_note_count': display_count, 'records': records})
    receipt = {'status': 'STATIC_FIXTURE_EXPECTATIONS_MATCHED_ONLY', 'campaign_authority': False,
               'compiler_invocations': 0, 'total_inputs': 113, 'inherited_inputs': 59, 'new_inputs': 54,
               'freeze_sha256': hashlib.sha256(freeze_bytes).hexdigest(), 'argv': invocation['argv'], 'results': results}
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x') as destination:
        json.dump(receipt, destination, indent=2, sort_keys=True)
        destination.write('\n')
    print(json.dumps({'status': receipt['status'], 'inputs': 113, 'output': str(output)}))


if __name__ == '__main__':
    main()
