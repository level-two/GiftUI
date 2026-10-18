#!/usr/bin/env python3
"""Guarded static runner candidate. Requires separate reviewed execution authority.

Imports only the packet's pure parser; never imports a campaign entrypoint.
This file has been prepared by source/syntax inspection, not executed.
"""
from pathlib import Path
import hashlib
import importlib.util
import json
import sys


def main():
    if sys.flags.optimize or not sys.flags.dont_write_bytecode:
        raise RuntimeError('STOP: require python3 -B without optimization')
    packet = Path(__file__).resolve().parent
    invocation = json.loads((packet / 'invocation.json').read_text())
    if (sys.argv != invocation['argv'][2:]
            or getattr(sys, 'orig_argv', None) != invocation['argv']):
        raise RuntimeError('STOP: exact separately authorized static argv required')
    if Path.cwd().resolve() != Path(invocation['cwd']):
        raise RuntimeError('STOP: run from the declared repository root')
    freeze_path = Path(sys.argv[2])
    output = Path(sys.argv[4])
    if freeze_path != packet / 'packet-freeze.json' or output.exists():
        raise RuntimeError('STOP: wrong freeze or output already exists; no overwrite/retry')
    freeze_bytes = freeze_path.read_bytes()
    freeze = json.loads(freeze_bytes)
    if freeze['argv'] != invocation['argv'] or freeze['total_static_inputs'] != 59:
        raise RuntimeError('STOP: invocation/freeze mismatch')
    for inventory in ('packet_files', 'preserved_files'):
        for item in freeze[inventory]:
            path = packet / item['path'] if inventory == 'packet_files' else Path(item['path'])
            content = path.read_bytes()
            if len(content) != item['bytes'] or hashlib.sha256(content).hexdigest() != item['sha256']:
                raise RuntimeError(('STOP: identity changed before classification', str(path)))

    inherited = json.loads((packet / 'inherited-cases.json').read_text())['cases']
    new = json.loads((packet / 'new-cases.json').read_text())['cases']
    assert len(inherited) == 22 and len(new) == 37
    assert len({case['case_id'] for case in new}) == 24
    cases = inherited + new
    assert len({case['id'] for case in cases}) == 59
    # No campaign wrapper, compiler, producer or test entrypoint is imported.
    spec = importlib.util.spec_from_file_location('a4_static_diagnostic_parser', packet / 'diagnostic_parser.py')
    parser = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(parser)
    assert parser.A4_POLICY == json.loads((packet / 'policy.json').read_text())
    policy = parser.A4_POLICY
    a4_input = (packet / 'inputs/SignalPrimitiveValues.swift').read_bytes()
    assert hashlib.sha256(a4_input).hexdigest() == policy['input_sha256']
    assert new[0]['id'] == 'A4-P01'
    assert new[0]['stdout'].encode() == (packet / 'inputs/archived-A4.stdout').read_bytes()
    assert new[0]['stderr'].encode() == (packet / 'inputs/archived-A4.stderr').read_bytes()
    results = []
    for case in cases:
        arguments = {}
        if 'context' in case:
            arguments['context'] = case['context']
        if 'trusted_input' in case:
            trusted = case['trusted_input']
            # Only this packet-supplied file may supply bytes; stderr selects none.
            assert trusted['fixture_file'] == 'inputs/SignalPrimitiveValues.swift'
            arguments['trusted_input'] = {'path': trusted['path'], 'bytes': a4_input}
        try:
            records = parser.classify_negative_diagnostics(
                case['control'], case['exit'], case['stdout'], case['stderr'],
                case['primary_path'], case['dependency_paths'], **arguments)
        except AssertionError as error:
            assert case['expected_accept'] is False, ('unexpected rejection', case['id'], str(error))
            results.append({'id': case['id'], 'expected_accept': False, 'accepted': False,
                            'rejection': str(error)})
            continue
        assert case['expected_accept'] is True, ('unexpected acceptance', case['id'])
        display_count = sum(len(record['display_notes']) for record in records)
        if 'expected_display_note_count' in case:
            assert len(records) == case['expected_primary_count'] == 1
            assert display_count == case['expected_display_note_count']
            record = records[0]
            assert record['notes'] == []
            assert record['primary']['source'] == [policy['primary_source']]
            assert record['dependency_evidence'] == case['expected_dependency_evidence']
            assert policy['excerpt_text'] not in record['dependency_evidence']
            assert policy['gutter'] not in record['dependency_evidence']
            for display in record['display_notes']:
                assert display == {
                    'stream': 'stderr',
                    'enclosing_primary': {key: record['primary'][key] for key in ('file', 'line', 'column', 'severity', 'message')},
                    'excerpt': {'line': 1, 'text': policy['excerpt_text'], 'raw': ' 1 | ' + policy['excerpt_text']},
                    'raw_gutter': policy['gutter'],
                    'declared_source_path': case['primary_path'],
                    'input_sha256': policy['input_sha256'],
                    'has_located_note_header': False,
                    'contributes_dependency_evidence': False,
                }
        else:
            assert display_count == 0, ('inherited input gained display allowance', case['id'])
        results.append({'id': case['id'], 'expected_accept': True, 'accepted': True,
                        'display_note_count': display_count, 'records': records})
    # First unexpected result raises above; no automatic repair, retry or tuning.
    receipt = {'status': 'STATIC_FIXTURE_EXPECTATIONS_MATCHED_ONLY',
               'campaign_authority': False, 'compiler_invocations': 0,
               'total_inputs': 59, 'inherited_inputs': 22, 'new_inputs': 37,
               'freeze_sha256': hashlib.sha256(freeze_bytes).hexdigest(),
               'argv': invocation['argv'], 'results': results}
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x') as destination:
        json.dump(receipt, destination, indent=2, sort_keys=True)
        destination.write('\n')
    print(json.dumps({'status': receipt['status'], 'inputs': 59, 'output': str(output)}))


if __name__ == '__main__':
    main()
