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
    if output.parent.exists():
        raise RuntimeError('STOP: output root exists; no overwrite/retry')
    if Path(sys.argv[2]) != packet / 'packet-freeze.json':
        raise RuntimeError('STOP: wrong freeze path')
    freeze_bytes = Path(sys.argv[2]).read_bytes()
    freeze = json.loads(freeze_bytes)
    if freeze['argv'] != invocation['argv'] or freeze['total_static_inputs'] != 1057:
        raise RuntimeError('STOP: freeze/invocation mismatch')
    expected_packet_files = {item['path'] for item in freeze['packet_files']} | {'packet-freeze.json'}
    if {str(path.relative_to(packet)) for path in packet.rglob('*') if path.is_file()} != expected_packet_files:
        raise RuntimeError('STOP: closed packet inventory mismatch')
    if any(path.is_symlink() for path in packet.rglob('*')):
        raise RuntimeError('STOP: packet symlink is forbidden')
    for inventory in ('packet_files', 'preserved_files'):
        for item in freeze[inventory]:
            path = packet / item['path'] if inventory == 'packet_files' else Path(item['path'])
            content = path.read_bytes()
            if len(content) != item['bytes'] or hashlib.sha256(content).hexdigest() != item['sha256']:
                raise RuntimeError(('STOP: frozen identity changed', str(path)))
    output.parent.mkdir(parents=True, exist_ok=False)
    (output.parent / 'attempt.json').write_text(json.dumps({'status': 'STATIC_ATTEMPT_STARTED_NO_RETRY', 'freeze_sha256': hashlib.sha256(freeze_bytes).hexdigest()}))
    inherited = json.loads((packet / 'inherited-cases.json').read_text())['cases']
    new = json.loads((packet / 'new-cases.json').read_text())['cases']
    assert len(inherited) == 888 and len(new) == 169
    cases = inherited + new
    assert len({case['id'] for case in cases}) == 1057
    spec = importlib.util.spec_from_file_location('armv6_a4_static_diagnostic_parser', packet / 'diagnostic_parser.py')
    parser = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(parser)
    assert parser.PRIVATE_STORAGE_POLICY == json.loads((packet / 'storage-policy.json').read_text())
    assert parser.PRIVATE_COUNT_POLICY == json.loads((packet / 'count-policy.json').read_text())
    assert parser.PRIVATE_HELPER_CONTINUATION_POLICY == json.loads((packet / 'continuation-policy.json').read_text())
    assert parser.PRIVATE_HELPER_LEADING_POLICY == json.loads((packet / 'leading-policy.json').read_text())
    assert new[0]['stderr'].encode() == (packet / 'inputs/armv6-a4/archived-A4.stderr').read_bytes()
    assert new[0]['stdout'].encode() == (packet / 'inputs/armv6-a4/archived-A4.stdout').read_bytes()
    assert parser.ARMV6_A4_POLICY == json.loads((packet / 'policy.json').read_text())
    assert parser.ARMV6_A4_CONTROL == json.loads((packet / 'opt-in-control.json').read_text())
    for label in ('A4', 'A7', 'A8'):
        assert getattr(parser, label + '_POLICY') == json.loads((packet / ('macos-static-' + label + '-policy.json')).read_text())
    results = []
    for case in cases:
        arguments = {}
        if 'context' in case:
            arguments['context'] = case['context']
        if 'trusted_input' in case:
            trusted = case['trusted_input']
            assert trusted['fixture_file'] in ('inputs/SignalPrimitiveValues.swift', 'inputs/AnalyzerPresentation.swift', 'inputs/A8-AnalyzerPresentation.swift', 'inputs/private-storage.swift', 'inputs/private-count.swift', 'inputs/private-helper-continuation.swift', 'inputs/private-helper-leading.swift', 'inputs/armv6-a4/SignalPrimitiveValues.swift', 'inputs/armv6-a4/edited-declaration.swift')
            data = (packet / trusted['fixture_file']).read_bytes()
            data += trusted.get('append_bytes', '').encode()
            if trusted.get('as_text'):
                data = data.decode()
            arguments['trusted_input'] = {'path': trusted['path'], 'bytes': data}
        if 'trusted_precompile' in case:
            arguments['trusted_precompile'] = case['trusted_precompile']
        if 'trusted_provenance' in case:
            from copy import deepcopy
            provenance = deepcopy(case['trusted_provenance'])
            for item in provenance['artifacts'].values():
                fixture = item.pop('fixture_file')
                assert fixture in ('inputs/domain/SignalAnalyzerDiagnostic.swift', 'inputs/domain/SignalPrimitiveValues.swift', 'inputs/domain/AcquisitionState.swift', 'inputs/domain/SignalAnalyzerDomain.swiftmodule')
                item['bytes'] = (packet / fixture).read_bytes() + item.pop('append_bytes', '').encode()
            arguments['trusted_provenance'] = provenance
        if 'trusted_core' in case and case['trusted_core'] is not None:
            from copy import deepcopy
            core = deepcopy(case['trusted_core'])
            for prefix, allowed in (
                ('receipt', {'inputs/core/leading-P02-result.json','inputs/core/leading-current-commit-result.json','inputs/core/leading-reject-check-exit-bool.json','inputs/core/leading-reject-check-pass-int.json','inputs/core/leading-reject-failed-check.json','inputs/core/leading-reject-missing-artifact.json','inputs/core/leading-reject-stale-commit.json','inputs/core/leading-reject-stale-digest.json','inputs/core/leading-reject-wrong-artifact-hash.json','inputs/core/leading-reject-wrong-compiler.json','inputs/core/leading-reject-wrong-execution.json','inputs/core/leading-reject-wrong-package.json','inputs/core/leading-reject-wrong-plugin.json','inputs/core/leading-reject-wrong-profile.json','inputs/core/leading-reject-wrong-source.json','inputs/core/leading-reject-wrong-toolchain-path.json','inputs/core/helper-reject-check-exit-bool.json','inputs/core/helper-reject-check-pass-int.json','inputs/core/helper-P02-result.json','inputs/core/helper-current-commit-result.json','inputs/core/helper-reject-failed-check.json','inputs/core/helper-reject-missing-artifact.json','inputs/core/helper-reject-stale-commit.json','inputs/core/helper-reject-stale-digest.json','inputs/core/helper-reject-wrong-artifact-hash.json','inputs/core/helper-reject-wrong-compiler.json','inputs/core/helper-reject-wrong-execution.json','inputs/core/helper-reject-wrong-package.json','inputs/core/helper-reject-wrong-plugin.json','inputs/core/helper-reject-wrong-profile.json','inputs/core/helper-reject-wrong-source.json','inputs/core/helper-reject-wrong-toolchain-path.json','inputs/core/count-reject-wrong-package.json','inputs/core/count-reject-wrong-profile.json','inputs/core/count-reject-failed-check.json','inputs/core/count-reject-wrong-source.json','inputs/core/count-reject-wrong-compiler.json','inputs/core/count-reject-wrong-plugin.json','inputs/core/count-reject-missing-artifact.json','inputs/core/count-reject-wrong-artifact-hash.json','inputs/core/count-reject-stale-commit.json','inputs/core/count-reject-stale-digest.json','inputs/core/count-reject-wrong-execution.json', 'inputs/core/count-P02-result.json', 'inputs/core/count-current-commit-result.json', 'inputs/core/P02-result.json', 'inputs/core/reject-wrong-package.json', 'inputs/core/reject-wrong-profile.json', 'inputs/core/reject-wrong-source-hash.json', 'inputs/core/reject-failed-check.json', 'inputs/core/reject-wrong-compiler-hash.json', 'inputs/core/reject-missing-artifact.json', 'inputs/core/current-commit-result.json', 'inputs/core/current-commit-stale-digest.json', 'inputs/core/current-commit-stale-source-commit.json', 'inputs/core/current-commit-wrong-digest.json'}),
                ('artifact', {'inputs/core/GiftUI.swiftmodule', 'inputs/core/count-GiftUI.swiftmodule', 'inputs/core/helper-GiftUI.swiftmodule', 'inputs/core/leading-GiftUI.swiftmodule'}),
            ):
                fixture_key = prefix + '_fixture'
                if fixture_key in core:
                    fixture = core.pop(fixture_key)
                    assert fixture in allowed
                    core[prefix + '_bytes'] = (packet / fixture).read_bytes() + core.pop(prefix + '_append_bytes', '').encode()
            arguments['trusted_core'] = core
        if 'trusted_core' in case and case['trusted_core'] is None:
            arguments['trusted_core'] = None
        if 'trusted_current_commit' in case:
            arguments['trusted_current_commit'] = case['trusted_current_commit']
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
        if case['id'].startswith('ARM-A4-'):
            p = parser.ARMV6_A4_POLICY
            assert len(records) == 1 and records[0]['notes'] == []
            assert records[0]['primary']['source'] == [p['primary_source']]
            assert records[0]['dependency_evidence'] == p['primary_message'] + '\n' + p['primary_source']
            assert p['excerpt_text'] not in records[0]['dependency_evidence']
            assert p['gutter'] not in records[0]['dependency_evidence']
            for note in records[0]['display_notes']:
                assert note['contributes_dependency_evidence'] is False
                assert note['has_located_note_header'] is False and note['filesystem_lookup'] is False
                assert note['raw_gutter'] == p['gutter'] and note['input_sha256'] == p['input_sha256']
                assert note['enclosing_primary'] == {key: records[0]['primary'][key] for key in ('file', 'line', 'column', 'severity', 'message')}
        elif case['id'].startswith(('PS-', 'PC-', 'PHC-', 'PHL-')):
            selected = (parser.PRIVATE_HELPER_LEADING_POLICY if case['id'].startswith('PHL-') else parser.PRIVATE_HELPER_CONTINUATION_POLICY if case['id'].startswith('PHC-') else parser.PRIVATE_COUNT_POLICY if case['id'].startswith('PC-') else parser.PRIVATE_STORAGE_POLICY)
            assert len(records) == case['expected_primary_count'] == 1
            assert records[0]['notes'] == []
            assert records[0]['primary']['source'] == [selected['primary_source']]
            assert records[0]['dependency_evidence'] == selected['primary_message']
            note = records[0]['display_notes'][0]
            assert note['raw_block'] == selected['virtual_block']
            assert note['contributes_dependency_evidence'] is False and note['filesystem_lookup'] is False
            assert note['virtual_label'] == selected['virtual_label']
            assert note['enclosing_primary'] == {k: records[0]['primary'][k] for k in ('file', 'line', 'column', 'severity', 'message')}
        elif case['id'].startswith(('A7-', 'A8-')):
            policy = parser.A8_POLICY if case['id'].startswith('A8-') else parser.A7_POLICY
            assert len(records) == case['expected_primary_count'] == policy['required_primary_count']
            for record, target in zip(records, policy['primaries']):
                assert record['notes'] == []
                assert record['primary']['source'] == [target['source']]
                assert record['dependency_evidence'] == policy['primary_message'] + '\n' + target['source']
                assert policy['excerpt_text'] not in record['dependency_evidence']
                assert policy['gutter'] not in record['dependency_evidence']
                assert record['display_notes'] == [{
                    'stream': 'stderr',
                    'enclosing_primary': {key: record['primary'][key] for key in ('file', 'line', 'column', 'severity', 'message')},
                    'excerpt': {'line': policy['excerpt_line'], 'text': policy['excerpt_text'], 'raw': str(policy['excerpt_line']) + ' | ' + policy['excerpt_text']},
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
               'compiler_invocations': 0, 'total_inputs': 1057, 'inherited_inputs': 888, 'new_inputs': 169,
               'freeze_sha256': hashlib.sha256(freeze_bytes).hexdigest(), 'argv': invocation['argv'], 'results': results}
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x') as destination:
        json.dump(receipt, destination, indent=2, sort_keys=True)
        destination.write('\n')
    print(json.dumps({'status': receipt['status'], 'inputs': 1057, 'output': str(output)}))


if __name__ == '__main__':
    main()
